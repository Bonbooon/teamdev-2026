import type { SlashCommand, RespondFn } from "@slack/bolt";
import { MOCK_PROJECT, MOCK_ALERTS, MOCK_TEAM_HEALTH } from "../mockData";

function alertEmoji(level: "red" | "yellow"): string {
  return level === "red" ? ":red_circle:" : ":large_yellow_circle:";
}

function progressBar(percent: number): string {
  const filled = Math.round(percent / 10);
  const empty = 10 - filled;
  return "█".repeat(filled) + "░".repeat(empty) + ` ${percent}%`;
}

export async function handleDashboard(
  _command: SlashCommand,
  respond: RespondFn
) {
  const p = MOCK_PROJECT;
  const alertBlocks = MOCK_ALERTS.map((a) => ({
    type: "section" as const,
    text: {
      type: "mrkdwn" as const,
      text: `${alertEmoji(a.level)} *${a.level.toUpperCase()}* — ${a.description}`,
    },
  }));

  await respond({
    blocks: [
      {
        type: "header",
        text: { type: "plain_text", text: `📊 ${p.title}`, emoji: true },
      },
      {
        type: "section",
        fields: [
          {
            type: "mrkdwn",
            text: `*ステータス:*\n${p.status === "in_progress" ? "🟢 進行中" : p.status}`,
          },
          {
            type: "mrkdwn",
            text: `*期限:*\n${new Date(p.dueAt).toLocaleDateString("ja-JP")}`,
          },
        ],
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `*進捗:* ${progressBar(p.progress)}\n完了 ${p.completedIssues} / 全 ${p.totalIssues} Issue`,
        },
      },
      { type: "divider" },
      {
        type: "section",
        text: { type: "mrkdwn", text: "*🚨 アラート*" },
      },
      ...alertBlocks,
      { type: "divider" },
      {
        type: "section",
        fields: [
          {
            type: "mrkdwn",
            text: `*👥 チーム状況*\nメンバー: ${MOCK_TEAM_HEALTH.totalMembers}人`,
          },
          {
            type: "mrkdwn",
            text: `*アンケート回答率:* ${MOCK_TEAM_HEALTH.surveyResponseRate}%\n*コンディション:* ${MOCK_TEAM_HEALTH.avgCondition}`,
          },
        ],
      },
      {
        type: "context",
        elements: [
          {
            type: "mrkdwn",
            text: "💡 _このダッシュボードはデモ用のモックデータです_",
          },
        ],
      },
    ],
  });
}
