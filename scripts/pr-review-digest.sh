#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/pr-review-digest.sh            # uses current branch PR
#   ./scripts/pr-review-digest.sh 123        # uses PR #123

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh is not installed." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed." >&2
  exit 1
fi

PR="${1:-$(gh pr view --json number --jq '.number')}"
REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
OWNER="${REPO%/*}"
NAME="${REPO#*/}"

if ! [[ "$PR" =~ ^[0-9]+$ ]]; then
  echo "Error: PR number must be numeric. Got: $PR" >&2
  exit 1
fi

REPO_NAME="$(echo "$NAME" | tr '/ ' '--')"

PR_JSON="$(gh pr view "$PR" --json title,body,url,author,reviewDecision,changedFiles,additions,deletions,commits,headRefName,baseRefName)"
UNRESOLVED_THREADS_JSON="$(gh api graphql -f query='query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          comments(first: 100) {
            nodes {
              author { login }
              body
              createdAt
              line
              originalLine
              path
              url
              pullRequestReview {
                state
                submittedAt
                author { login }
              }
            }
          }
        }
      }
    }
  }
}' -F owner="$OWNER" -F name="$NAME" -F number="$PR" | jq '.data.repository.pullRequest.reviewThreads.nodes | map(select(.isResolved == false and .isOutdated == false))')"

# Fetch top-level PR review bodies (includes Copilot's summary review comment)
REVIEWS_JSON="$(gh api graphql -f query='query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviews(first: 50) {
        nodes {
          author { login }
          body
          state
          submittedAt
          url
        }
      }
    }
  }
}' -F owner="$OWNER" -F name="$NAME" -F number="$PR" | jq '.data.repository.pullRequest.reviews.nodes')"

# Filter for Copilot summary reviews (top-level review body, non-empty)
COPILOT_SUMMARY_REVIEWS_JSON="$(echo "$REVIEWS_JSON" | jq '
  [ .[]?
    | select(
        (.author.login // "" | ascii_downcase | test("copilot"))
        and ((.body // "") | length > 0)
      )
    | {
        author: (.author.login // "unknown"),
        body: (.body // ""),
        state,
        submittedAt,
        url: (.url // "")
      }
  ]
  | sort_by(.submittedAt)
')"

FETCHED_COMMENTS_JSON="$(echo "$UNRESOLVED_THREADS_JSON" | jq '
  . as $threads |
  [
    $threads[]? as $thread
    | $thread.comments.nodes[]?
    | {
        author: (.author.login // "unknown"),
        body: (.body // ""),
        createdAt,
        path: (.path // $thread.path // "unknown"),
        line: (.line // .originalLine // 0),
        url: (.url // ""),
        reviewState: (.pullRequestReview.state // null),
        reviewAuthor: (.pullRequestReview.author.login // null),
        reviewSubmittedAt: (.pullRequestReview.submittedAt // null)
      }
  ]
  | unique_by(
      if (.url // "") != "" then .url
      else ((.author // "") + "|" + (.path // "") + "|" + ((.line // 0)|tostring) + "|" + (.body // ""))
      end
    )
')"

NON_COPILOT_UNRESOLVED_COMMENTS_JSON="$(echo "$FETCHED_COMMENTS_JSON" | jq '
  [ .[]
    | select(
        ((.author // "") | ascii_downcase | test("copilot") | not)
        and
        ((.reviewAuthor // "") | ascii_downcase | test("copilot") | not)
      )
  ]
')"

OUTDIR="$REPO_ROOT/pr-review-digests"
if [ ! -d "$OUTDIR" ]; then
  mkdir "$OUTDIR"
fi
OUTFILE="$OUTDIR/${REPO_NAME}-${PR}.md"

{
  echo "# PR Review Digest"
  echo ""

  echo "## PR Summary"
  echo "$PR_JSON" | jq -r '"- PR: " + .url + "\n- Title: " + .title + "\n- Author: @" + .author.login + "\n- Branch: " + .headRefName + " → " + .baseRefName + "\n- Review decision: " + (.reviewDecision // "N/A") + "\n- Diff stats: +" + (.additions|tostring) + " / -" + (.deletions|tostring) + " across " + (.changedFiles|tostring) + " files\n- Commits: " + ((.commits|length)|tostring)'
  echo ""

  echo "## Copilot PR Summary Review"
  echo "$COPILOT_SUMMARY_REVIEWS_JSON" | jq -r '
    if length == 0 then
      "No Copilot summary review found."
    else
      .[] |
      "### Review by @" + .author + " (" + .state + ", " + .submittedAt + ")\n" +
      .body + "\n" +
      "> " + .url + "\n"
    end
  '
  echo ""

  echo "## Fetched Review Comments (Unresolved, Non-Copilot)"
  echo "$NON_COPILOT_UNRESOLVED_COMMENTS_JSON" | jq -r '
    if length == 0 then
      "No unresolved non-Copilot review comments found."
    else
      sort_by(.createdAt)
      | .[]
      | "- @" + .author + " " + (.path + ":" + (.line|tostring)) + " — " +
        (.body | gsub("\\n"; " ")) + " — " + .url
    end
  '
  echo ""

  echo "## Cloud Copilot Review Comments"
  echo "$FETCHED_COMMENTS_JSON" | jq -r '
    [ .[] | select((.author | ascii_downcase | test("copilot")) or ((.reviewAuthor // "") | ascii_downcase | test("copilot"))) ]
    | if length == 0 then
        "No Copilot reviewer comments found in unresolved threads."
      else
        sort_by(.createdAt)
        | .[]
        | "- @" + .author + " " + (.path + ":" + (.line|tostring)) + " — " +
          (.body | gsub("\\n"; " ")) + " — " + .url
      end
  '
  echo ""

  echo "## Code-change Required Review Comments"
  echo "$FETCHED_COMMENTS_JSON" | jq -r '
    [ .[] | select(.reviewState == "CHANGES_REQUESTED") ]
    | if length == 0 then
        "No unresolved inline comments tied to CHANGES_REQUESTED reviews."
      else
        sort_by(.createdAt)
        | .[]
        | "- @" + .author + " " + (.path + ":" + (.line|tostring)) + " — " +
          (.body | gsub("\\n"; " ")) + " — " + .url
      end
  '
} | tee "$OUTFILE"

echo ""
echo "Saved (overwritten): $OUTFILE"
