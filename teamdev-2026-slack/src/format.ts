import type { Issue } from "./api";

const STATUS_PRESENTATION: Readonly<Record<string, { emoji: string; label: string }>> = {
  done: { emoji: "✅", label: "完了" },
  in_progress: { emoji: "🔵", label: "進行中" },
  in_review: { emoji: "🟡", label: "レビュー中" },
  not_in_progress: { emoji: "⚪", label: "未着手" },
};

export function statusEmoji(status: string): string {
  return STATUS_PRESENTATION[status]?.emoji ?? "❓";
}

export function statusLabel(status: string): string {
  return STATUS_PRESENTATION[status]?.label ?? status;
}

export function progressBar(percent: number): string {
  const safePercent = Math.max(0, Math.min(100, percent));
  const filled = Math.round(safePercent / 10);
  const empty = 10 - filled;
  return "█".repeat(filled) + "░".repeat(empty) + ` ${Math.round(safePercent)}%`;
}

export function formatIssueLine(issue: Issue, index: number): string {
  const assignees =
    issue.assignees.map((a) => a.userName).join(", ") || "未割当";
  const deadline = issue.deadline
    ? new Date(issue.deadline).toLocaleDateString("ja-JP")
    : "なし";
  return (
    `*${index + 1}.* ${statusEmoji(issue.status)} *${issue.title}*\n` +
    `      SP: ${issue.storyPoints} | 期限: ${deadline} | 担当: ${assignees}`
  );
}

/** Valid story point values accepted by the backend */
export const VALID_STORY_POINTS = [1, 2, 3, 5, 8, 13] as const;
