import OpenAI from "openai";
import type {
  ChatCompletionMessageParam,
  ChatCompletionTool,
} from "openai/resources/chat/completions";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

function buildSystemPrompt(): string {
  const now = new Date();
  const todayStr = now.toLocaleDateString("ja-JP", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    weekday: "long",
  });
  const isoToday = now.toLocaleDateString("sv-SE", { timeZone: "Asia/Tokyo" }); // YYYY-MM-DD

  return `あなたはプロジェクト管理アプリのSlackボットアシスタントです。
プロジェクトマネージャーがプロジェクトの進捗管理、Issue管理、アラート確認を行うのを手助けします。

現在の日付: ${todayStr} (${isoToday})
タイムゾーン: Asia/Tokyo

【重要】日付に関するルール:
- deadlineは必ずYYYY-MM-DD形式で返すこと
- deadlineは必ず明日(${isoToday}の翌日)以降にすること。今日や過去の日付は不可
- 「金曜まで」→ 次の金曜日の日付を計算すること
- 「来週」→ 来週月曜の日付を計算すること
- 期限の指定がない場合 → deadlineパラメータを省略すること（推測しない）。省略された場合はシステム側でデフォルトの期限が設定される

ユーザーのメッセージに基づいて、適切なツール（関数）を呼び出してください。
- ダッシュボードや全体の状況を聞かれたら → show_dashboard
- Issue一覧や課題の確認を聞かれたら → list_issues
- 新しいIssueやタスクの作成を頼まれたら → create_issue
- どのツールにも当てはまらない場合 → ツールを呼ばずに日本語で返答してください

簡潔に、丁寧に対応してください。`;
}

const tools: ChatCompletionTool[] = [
  {
    type: "function",
    function: {
      name: "show_dashboard",
      description:
        "プロジェクトのダッシュボード（進捗、アラート、チーム状況）を表示する",
      parameters: {
        type: "object",
        properties: {
          project_id: {
            type: "string",
            description:
              "プロジェクトID（省略時はデフォルトプロジェクトを使用）",
          },
        },
        required: [],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "list_issues",
      description: "プロジェクトのIssue（課題・タスク）一覧を表示する",
      parameters: {
        type: "object",
        properties: {
          project_id: {
            type: "string",
            description:
              "プロジェクトID（省略時はデフォルトプロジェクトを使用）",
          },
          status: {
            type: "string",
            enum: ["not_in_progress", "in_progress", "in_review", "done"],
            description: "ステータスでフィルタリング",
          },
        },
        required: [],
      },
    },
  },
  {
    type: "function",
    function: {
      name: "create_issue",
      description: "新しいIssue（課題・タスク）を作成する",
      parameters: {
        type: "object",
        properties: {
          title: {
            type: "string",
            description: "Issueのタイトル",
          },
          story_points: {
            type: "number",
            enum: [1, 2, 3, 5, 8, 13],
            description: "ストーリーポイント（デフォルト: 3）",
          },
          deadline: {
            type: "string",
            description: "期限（YYYY-MM-DD形式）",
          },
          estimated_minutes: {
            type: "number",
            description: "見積もり時間（分）",
          },
        },
        required: ["title"],
      },
    },
  },
];

export interface AiRouteResult {
  type: "dashboard" | "issues" | "create_issue" | "text";
  args: Record<string, string | number | undefined>;
  textReply?: string;
}

export async function routeWithAi(
  userMessage: string
): Promise<AiRouteResult> {
  const messages: ChatCompletionMessageParam[] = [
    { role: "system", content: buildSystemPrompt() },
    { role: "user", content: userMessage },
  ];

  const response = await openai.chat.completions.create({
    model: "gpt-4o",
    messages,
    tools,
    tool_choice: "auto",
  });

  const choice = response.choices[0]!;
  const toolCall = choice.message.tool_calls?.[0];

  if (toolCall && "function" in toolCall) {
    let args: Record<string, string | number | undefined>;
    try {
      args = JSON.parse(toolCall.function.arguments) as Record<
        string,
        string | number | undefined
      >;
    } catch {
      return {
        type: "text" as const,
        args: {},
        textReply: "ツールの引数解析に失敗しました。もう一度お試しください。",
      };
    }
    switch (toolCall.function.name) {
      case "show_dashboard":
        return { type: "dashboard", args };
      case "list_issues":
        return { type: "issues", args };
      case "create_issue":
        return { type: "create_issue", args };
    }
  }

  // No tool call — return the text reply
  return {
    type: "text",
    args: {},
    textReply:
      choice.message.content || "すみません、理解できませんでした。",
  };
}
