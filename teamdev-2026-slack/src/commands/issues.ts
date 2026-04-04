import type { SlashCommand, RespondFn } from "@slack/bolt";
import { listIssues, type Issue } from "../api";

const API_TOKEN = process.env.API_TOKEN || "";
const DEFAULT_PROJECT_ID = process.env.DEFAULT_PROJECT_ID || "";

function statusEmoji(status: string): string {
  switch (status) {
    case "done":
      return "✅";
    case "in_progress":
      return "🔵";
    case "in_review":
      return "🟡";
    case "not_in_progress":
      return "⚪";
    default:
      return "❓";
  }
}

function statusLabel(status: string): string {
  switch (status) {
    case "done":
      return "完了";
    case "in_progress":
      return "進行中";
    case "in_review":
      return "レビュー中";
    case "not_in_progress":
      return "未着手";
    default:
      return status;
  }
}

function formatIssue(issue: Issue, index: number): string {
  const assignees =
    issue.assignees.map((a) => a.userName).join(", ") || "未割当";
  const deadline = issue.deadline
    ? new Date(issue.deadline).toLocaleDateString("ja-JP")
    : "なし";
  return (
    `*${index + 1}.* ${statusEmoji(issue.status)} *${issue.title}*\n` +
    `      ステータス: ${statusLabel(issue.status)} | SP: ${issue.storyPoints} | 期限: ${deadline}\n` +
    `      担当: ${assignees}`
  );
}

export async function handleIssues(
  command: SlashCommand,
  respond: RespondFn
) {
  const args = command.text.trim();
  const projectId = args || DEFAULT_PROJECT_ID;

  if (!projectId) {
    await respond(
      "プロジェクトIDを指定してください: `/issues <project-id>`\n" +
        "または `.env` に `DEFAULT_PROJECT_ID` を設定してください。"
    );
    return;
  }

  try {
    const data = await listIssues(projectId, API_TOKEN);
    const issues = data.issues;

    if (issues.length === 0) {
      await respond({
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "📋 このプロジェクトにはIssueがありません。",
            },
          },
        ],
      });
      return;
    }

    // Group by status
    const grouped: Record<string, Issue[]> = {};
    for (const issue of issues) {
      const key = issue.status;
      if (!grouped[key]) grouped[key] = [];
      grouped[key].push(issue);
    }

    const sections = Object.entries(grouped).flatMap(([status, items]) => [
      {
        type: "section" as const,
        text: {
          type: "mrkdwn" as const,
          text: `*${statusEmoji(status)} ${statusLabel(status)}* (${items.length}件)`,
        },
      },
      {
        type: "section" as const,
        text: {
          type: "mrkdwn" as const,
          text: items.map((iss, i) => formatIssue(iss, i)).join("\n\n"),
        },
      },
      { type: "divider" as const },
    ]);

    await respond({
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: `📋 Issue一覧 (全${data.pagination.total}件)`,
            emoji: true,
          },
        },
        ...sections,
        {
          type: "context",
          elements: [
            {
              type: "mrkdwn",
              text: `🔗 _Project ID: ${projectId}_`,
            },
          ],
        },
      ],
    });
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "不明なエラーが発生しました";
    await respond(`❌ Issue一覧の取得に失敗しました: ${message}`);
  }
}
