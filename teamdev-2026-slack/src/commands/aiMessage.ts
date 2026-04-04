import type { SayFn } from "@slack/bolt";
import { AxiosError } from "axios";
import { routeWithAi } from "../ai";
import { MOCK_PROJECT, MOCK_ALERTS, MOCK_TEAM_HEALTH } from "../mockData";
import { listIssues, createIssue, type Issue } from "../api";

const API_TOKEN = process.env.API_TOKEN || "";
const DEFAULT_PROJECT_ID = process.env.DEFAULT_PROJECT_ID || "";
const DEFAULT_TEMPLATE_ID = process.env.DEFAULT_TEMPLATE_ID || "";
const DEFAULT_TEAM_ID = process.env.DEFAULT_TEAM_ID || "";
const DEFAULT_ASSIGNEE_ID = process.env.DEFAULT_ASSIGNEE_ID || "";

function statusEmoji(status: string): string {
  switch (status) {
    case "done": return "✅";
    case "in_progress": return "🔵";
    case "in_review": return "🟡";
    case "not_in_progress": return "⚪";
    default: return "❓";
  }
}

function statusLabel(status: string): string {
  switch (status) {
    case "done": return "完了";
    case "in_progress": return "進行中";
    case "in_review": return "レビュー中";
    case "not_in_progress": return "未着手";
    default: return status;
  }
}

function progressBar(percent: number): string {
  const filled = Math.round(percent / 10);
  const empty = 10 - filled;
  return "█".repeat(filled) + "░".repeat(empty) + ` ${percent}%`;
}

async function sendDashboard(say: SayFn) {
  const p = MOCK_PROJECT;
  const alertBlocks = MOCK_ALERTS.map((a) => ({
    type: "section" as const,
    text: {
      type: "mrkdwn" as const,
      text: `${a.level === "red" ? ":red_circle:" : ":large_yellow_circle:"} *${a.level.toUpperCase()}* — ${a.description}`,
    },
  }));

  await say({
    blocks: [
      { type: "header", text: { type: "plain_text", text: `📊 ${p.title}`, emoji: true } },
      {
        type: "section",
        fields: [
          { type: "mrkdwn", text: `*ステータス:*\n🟢 進行中` },
          { type: "mrkdwn", text: `*期限:*\n${new Date(p.dueAt).toLocaleDateString("ja-JP")}` },
        ],
      },
      {
        type: "section",
        text: { type: "mrkdwn", text: `*進捗:* ${progressBar(p.progress)}\n完了 ${p.completedIssues} / 全 ${p.totalIssues} Issue` },
      },
      { type: "divider" },
      { type: "section", text: { type: "mrkdwn", text: "*🚨 アラート*" } },
      ...alertBlocks,
      { type: "divider" },
      {
        type: "section",
        fields: [
          { type: "mrkdwn", text: `*👥 チーム状況*\nメンバー: ${MOCK_TEAM_HEALTH.totalMembers}人` },
          { type: "mrkdwn", text: `*アンケート回答率:* ${MOCK_TEAM_HEALTH.surveyResponseRate}%\n*コンディション:* ${MOCK_TEAM_HEALTH.avgCondition}` },
        ],
      },
    ],
    text: "ダッシュボード",
  });
}

async function sendIssues(say: SayFn, args: Record<string, string | number | undefined>) {
  const projectId = (args.project_id as string) || DEFAULT_PROJECT_ID;
  if (!projectId) {
    await say("プロジェクトIDが設定されていません。");
    return;
  }

  try {
    const data = await listIssues(projectId, API_TOKEN, args.status as string | undefined);
    const issues = data.issues;

    if (issues.length === 0) {
      await say("📋 このプロジェクトにはIssueがありません。");
      return;
    }

    const grouped: Record<string, Issue[]> = {};
    for (const issue of issues) {
      if (!grouped[issue.status]) grouped[issue.status] = [];
      grouped[issue.status]!.push(issue);
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
          text: items
            .map((iss, i) => {
              const assignees = iss.assignees.map((a) => a.userName).join(", ") || "未割当";
              const deadline = iss.deadline ? new Date(iss.deadline).toLocaleDateString("ja-JP") : "なし";
              return `*${i + 1}.* ${statusEmoji(iss.status)} *${iss.title}*\n      SP: ${iss.storyPoints} | 期限: ${deadline} | 担当: ${assignees}`;
            })
            .join("\n\n"),
        },
      },
      { type: "divider" as const },
    ]);

    await say({
      blocks: [
        { type: "header", text: { type: "plain_text", text: `📋 Issue一覧 (全${data.pagination.total}件)`, emoji: true } },
        ...sections,
      ],
      text: "Issue一覧",
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "不明なエラー";
    await say(`❌ Issue一覧の取得に失敗しました: ${message}`);
  }
}

async function sendCreateIssue(say: SayFn, args: Record<string, string | number | undefined>) {
  const title = (args.title as string) || "Untitled Issue";
  const storyPoints = (args.story_points as number) || 3;
  const estimatedMinutes = (args.estimated_minutes as number) || 60;
  const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split("T")[0]!;
  let deadline = (args.deadline as string) ||
    new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]!;
  // API requires deadline > today
  if (deadline <= new Date().toISOString().split("T")[0]!) {
    deadline = tomorrow;
  }

  if (!DEFAULT_PROJECT_ID) {
    await say("プロジェクトIDが設定されていません。");
    return;
  }

  try {
    const result = await createIssue(
      DEFAULT_PROJECT_ID,
      {
        issue_template_id: DEFAULT_TEMPLATE_ID,
        title,
        story_points: storyPoints,
        estimated_minutes: estimatedMinutes,
        deadline: `${deadline}T23:59:59Z`,
        status: "not_in_progress",
        assigneeIds: DEFAULT_ASSIGNEE_ID ? [DEFAULT_ASSIGNEE_ID] : [],
        teamIds: DEFAULT_TEAM_ID ? [DEFAULT_TEAM_ID] : [],
        definitionOfDoneItems: ["完了条件を確認する"],
      },
      API_TOKEN
    );

    await say({
      blocks: [
        { type: "header", text: { type: "plain_text", text: "✅ Issueを作成しました", emoji: true } },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: `*タイトル:*\n${result.issue.title}` },
            { type: "mrkdwn", text: `*ステータス:*\n未着手` },
          ],
        },
        {
          type: "section",
          fields: [
            { type: "mrkdwn", text: `*SP:*\n${storyPoints}` },
            { type: "mrkdwn", text: `*期限:*\n${deadline}` },
          ],
        },
        {
          type: "context",
          elements: [{ type: "mrkdwn", text: `🆔 Issue ID: \`${result.issue.id}\`` }],
        },
      ],
      text: "Issue作成完了",
    });
  } catch (err: unknown) {
    let message = err instanceof Error ? err.message : "不明なエラー";
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
    await say(`❌ Issue作成に失敗しました:\n${message}`);
  }
}

export async function handleMessage(text: string, say: SayFn) {
  try {
    const result = await routeWithAi(text);

    switch (result.type) {
      case "dashboard":
        await sendDashboard(say);
        break;
      case "issues":
        await sendIssues(say, result.args);
        break;
      case "create_issue":
        await sendCreateIssue(say, result.args);
        break;
      case "text":
        await say(result.textReply || "すみません、理解できませんでした。");
        break;
    }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "不明なエラー";
    await say(`❌ AIの処理中にエラーが発生しました: ${message}`);
  }
}
