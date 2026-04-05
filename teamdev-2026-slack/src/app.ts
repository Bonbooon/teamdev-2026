import { App } from "@slack/bolt";
import "dotenv/config";
import { handleDashboard } from "./commands/dashboard";
import { handleIssues } from "./commands/issues";
import { handleCreateIssue } from "./commands/createIssue";
import { handleMessage } from "./commands/aiMessage";

const requiredEnvVars = [
  "SLACK_BOT_TOKEN",
  "SLACK_APP_TOKEN",
  "OPENAI_API_KEY",
  "API_TOKEN",
  "API_BASE_URL",
] as const;
for (const v of requiredEnvVars) {
  if (!process.env[v]) {
    console.error(`❌ Missing required env var: ${v}`);
    process.exit(1);
  }
}

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  appToken: process.env.SLACK_APP_TOKEN,
  socketMode: true,
});

app.command("/dashboard", async ({ command, ack, respond }) => {
  await ack();
  await handleDashboard(command, respond);
});

app.command("/issues", async ({ command, ack, respond }) => {
  await ack();
  await handleIssues(command, respond);
});

app.command("/create-issue", async ({ command, ack, respond }) => {
  await ack();
  await handleCreateIssue(command, respond);
});

// Help — shows available commands
app.event("app_home_opened", async ({ event, client }) => {
  await client.views.publish({
    user_id: event.user,
    view: {
      type: "home",
      blocks: [
        { type: "header", text: { type: "plain_text", text: "🤖 プロジェクト管理ボット", emoji: true } },
        { type: "section", text: { type: "mrkdwn", text: "Slackからプロジェクトを管理できるAIアシスタントです。" } },
        { type: "divider" },
        { type: "section", text: { type: "mrkdwn", text: "*スラッシュコマンド:*\n• `/dashboard` — プロジェクトの概況を表示\n• `/issues` — Issue一覧を表示\n• `/create-issue <タイトル> [sp:N] [due:YYYY-MM-DD]` — Issue作成" } },
        { type: "section", text: { type: "mrkdwn", text: "*AI自然言語 (メンション or DM):*\n• 「プロジェクトの状況を教えて」\n• 「Issue一覧を見せて」\n• 「ログインバグの修正、SP5で金曜まで」" } },
      ],
    },
  });
});

// AI-powered natural language handler — responds to @mentions and DMs
app.event("app_mention", async ({ event, say, client }) => {
  const text = event.text.replace(/<@[A-Z0-9]+>/g, "").trim();
  if (!text) {
    await say("何かお手伝いできることはありますか？ 例: 「プロジェクトの状況を教えて」");
    return;
  }
  // Show typing indicator while AI processes (best-effort)
  await client.reactions.add({ channel: event.channel, timestamp: event.ts, name: "hourglass_flowing_sand" }).catch(() => {});
  try {
    await handleMessage(text, say);
  } finally {
    await client.reactions.remove({ channel: event.channel, timestamp: event.ts, name: "hourglass_flowing_sand" }).catch(() => {});
  }
});

app.message(async ({ message, say, client }) => {
  if (message.channel_type !== "im") return;
  if (message.subtype) return;
  if (!("text" in message) || !message.text) return;
  await client.reactions.add({ channel: message.channel, timestamp: message.ts, name: "hourglass_flowing_sand" }).catch(() => {});
  try {
    await handleMessage(message.text, say);
  } finally {
    await client.reactions.remove({ channel: message.channel, timestamp: message.ts, name: "hourglass_flowing_sand" }).catch(() => {});
  }
});

(async () => {
  await app.start();
  console.log("⚡ Slack bot is running (Socket Mode)");
  console.log(`   API: ${process.env.API_BASE_URL || "(not set)"}`);
  console.log(`   Project: ${process.env.DEFAULT_PROJECT_ID || "(not set)"}`);
  console.log(`   AI Model: gpt-4o`);
})();