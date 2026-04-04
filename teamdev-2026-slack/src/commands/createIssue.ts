import type { SlashCommand, RespondFn } from "@slack/bolt";
import { AxiosError } from "axios";
import { createIssue } from "../api";
import { VALID_STORY_POINTS } from "../format";

const API_TOKEN = process.env.API_TOKEN || "";
const DEFAULT_PROJECT_ID = process.env.DEFAULT_PROJECT_ID || "";
const DEFAULT_TEMPLATE_ID = process.env.DEFAULT_TEMPLATE_ID || "";
const DEFAULT_TEAM_ID = process.env.DEFAULT_TEAM_ID || "";
const DEFAULT_ASSIGNEE_ID = process.env.DEFAULT_ASSIGNEE_ID || "";

/**
 * Parse free-form text into issue fields.
 * Expected format: `/create-issue [projectId] title: ... sp: N due: YYYY-MM-DD`
 * Minimal: `/create-issue Fix the login bug`
 */
function parseIssueText(text: string) {
  // Extract key:value pairs
  const spMatch = text.match(/\bsp:\s*(\d+)/i);
  const dueMatch = text.match(/\bdue:\s*(\d{4}-\d{2}-\d{2})/i);
  const estMatch = text.match(/\best:\s*(\d+)/i);

  // Remove matched patterns from text to get the title
  let title = text
    .replace(/\bsp:\s*\d+/i, "")
    .replace(/\bdue:\s*\d{4}-\d{2}-\d{2}/i, "")
    .replace(/\best:\s*\d+/i, "")
    .trim();

  // If title starts with a UUID-like string, treat it as project ID
  let projectId = "";
  const uuidMatch = title.match(
    /^([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s*/i
  );
  if (uuidMatch) {
    projectId = uuidMatch[1]!;
    title = title.slice(uuidMatch[0].length).trim();
  }

  // Remove "title:" prefix if present
  title = title.replace(/^title:\s*/i, "").trim();

  return {
    projectId: projectId || DEFAULT_PROJECT_ID,
    title: title || "Untitled Issue",
    storyPoints: spMatch ? parseInt(spMatch[1]!, 10) : 3,
    estimatedMinutes: estMatch ? parseInt(estMatch[1]!, 10) : 60,
    deadline:
      dueMatch?.[1] ||
      new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        .toISOString()
        .split("T")[0],
  };
}

export async function handleCreateIssue(
  command: SlashCommand,
  respond: RespondFn
) {
  const text = command.text.trim();

  if (!text) {
    await respond(
      "使い方: `/create-issue <タイトル> [sp:3] [due:2026-04-10] [est:60]`\n" +
        "例: `/create-issue ログインバグの修正 sp:5 due:2026-04-10`"
    );
    return;
  }

  const parsed = parseIssueText(text);

  if (!parsed.projectId) {
    await respond(
      "プロジェクトIDが不明です。`.env` に `DEFAULT_PROJECT_ID` を設定するか、" +
        "UUIDを先頭に指定してください。"
    );
    return;
  }

  if (!(VALID_STORY_POINTS as readonly number[]).includes(parsed.storyPoints)) {
    await respond(
      `❌ ストーリーポイントは ${VALID_STORY_POINTS.join(", ")} のいずれかを指定してください。`
    );
    return;
  }

  if (!DEFAULT_TEMPLATE_ID) {
    await respond(
      "❌ IssueテンプレートIDが未設定です。`.env` に `DEFAULT_TEMPLATE_ID` を設定してください。"
    );
    return;
  }

  if (!DEFAULT_TEAM_ID || !DEFAULT_ASSIGNEE_ID) {
    await respond(
      "❌ チームIDまたは担当者IDが未設定です。`.env` に `DEFAULT_TEAM_ID` と `DEFAULT_ASSIGNEE_ID` を設定してください。"
    );
    return;
  }

  // Ensure deadline is after today
  const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split("T")[0]!;
  if (!parsed.deadline || parsed.deadline <= new Date().toISOString().split("T")[0]!) {
    parsed.deadline = tomorrow;
  }

  try {
    const result = await createIssue(
      parsed.projectId,
      {
        issue_template_id: DEFAULT_TEMPLATE_ID,
        title: parsed.title,
        story_points: parsed.storyPoints,
        estimated_minutes: parsed.estimatedMinutes,
        deadline: parsed.deadline,
        status: "not_in_progress",
        assigneeIds: DEFAULT_ASSIGNEE_ID ? [DEFAULT_ASSIGNEE_ID] : [],
        teamIds: DEFAULT_TEAM_ID ? [DEFAULT_TEAM_ID] : [],
        definitionOfDoneItems: ["完了条件を確認する"],
      },
      API_TOKEN
    );

    const issue = result.issue;

    await respond({
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "✅ Issueを作成しました",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: `*タイトル:*\n${issue.title}` },
            { type: "mrkdwn", text: `*ステータス:*\n未着手` },
          ],
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*ストーリーポイント:*\n${parsed.storyPoints}`,
            },
            { type: "mrkdwn", text: `*期限:*\n${parsed.deadline}` },
          ],
        },
        {
          type: "context",
          elements: [
            {
              type: "mrkdwn",
              text: `🆔 Issue ID: \`${issue.id}\``,
            },
          ],
        },
      ],
    });
  } catch (err: unknown) {
    let message =
      err instanceof Error ? err.message : "不明なエラーが発生しました";
    if (err instanceof AxiosError && err.response?.data) {
      const data = err.response.data as Record<string, unknown>;
      if (data.errors) {
        const details = Object.entries(data.errors as Record<string, string[]>)
          .map(([field, msgs]) => `${field}: ${msgs.join(", ")}`)
          .join("\n");
        message = `${data.message || "Validation failed"}\n${details}`;
      } else if (data.message) {
        message = data.message as string;
      }
    }
    await respond(`❌ Issue作成に失敗しました:\n${message}`);
  }
}
