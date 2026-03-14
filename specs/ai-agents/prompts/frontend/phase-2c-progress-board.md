# Phase 2C: Progress Board — カンバン + ガント統合ビュー

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A**, **Phase 0B**, **Phase 1B** (Projects), **Phase 1C** (Issues)
- 作業ディレクトリ: `teamdev-2026-front/`

## 依存パッケージ追加

```bash
pnpm add @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

ガントチャートライブラリは `docs/ui-references/gantt-chart/` に参考情報がある。ライブラリ選定は実装時に判断する（候補: frappe-gantt, カスタム実装）。

## Source of Truth

- `docs/ui-specification.md` — Section 5.7 (PJ詳細 ProgressBoardTab), Section 6.7 (DnD), Section 6.10 (進捗率), Section 7.5
- `docs/ui-pages/project-detail.md`
- `docs/ui-references/library-comparison.md`

## 実装スコープ

### ディレクトリ構成

```
src/features/projects/components/ProgressBoard/
├── index.tsx              # ViewToggle + ビュー切替コンテナ
├── ViewToggle.tsx         # ガント/カンバン セグメントコントロール
├── KanbanBoard.tsx        # @dnd-kit ベースのカンバンボード
├── GanttChart.tsx         # ガントチャートビュー
├── GroupBySelector.tsx    # ガント用グルーピング切替
├── IssueCard.tsx          # カンバン用ドラッグ可能カード
└── GanttRow.tsx           # ガント用行コンポーネント
```

### 設計方針

1. **データ共有:** カンバンとガントは `useProjectIssues(projectId)` の同一SWRキーを共有。ビュー切替時にAPIを重複して叩かない。
2. **ビュー切替:** `localStorage` で最後の選択を記憶。デフォルトはガントビュー。
3. **Issue作成ボタン:** ViewToggle横に常時表示。

### KanbanBoard (@dnd-kit)

```typescript
// カラム定義
const KANBAN_COLUMNS = [
  { id: 'not_in_progress', label: '未着手' },
  { id: 'in_progress', label: '進行中' },
  { id: 'in_review', label: 'レビュー中' },
  { id: 'done', label: '完了' },
];
```

**IssueCard 表示内容:**
- IssueTitle
- AssigneeAvatars (アサイン者アバター)
- StoryPointsBadge
- DueDate
- ProgressBar

**DnD 楽観的更新パターン:**
```typescript
const handleDragEnd = async (event: DragEndEvent) => {
  const { active, over } = event;
  if (!over) return;

  const issueId = active.id;
  const newStatus = over.id;

  // 1. SWRキャッシュを楽観的に更新
  mutate(`projects/${projectId}/issues`, (prev) =>
    prev.map(issue =>
      issue.id === issueId ? { ...issue, status: newStatus } : issue
    ), false
  );

  try {
    // 2. API呼び出し
    await patchIssueStatus(issueId, newStatus);
    // 3. 再検証
    mutate(`projects/${projectId}/issues`);
    mutate(`projects/${projectId}`); // 進捗率更新
  } catch {
    // 4. ロールバック
    mutate(`projects/${projectId}/issues`);
    toast.error('ステータス変更に失敗しました');
  }
};
```

### GanttChart

**GroupBySelector (デフォルト: ステータス別):**
```typescript
const GROUPING_OPTIONS = [
  { value: 'status', label: 'ステータス別' },   // デフォルト
  { value: 'assignee', label: 'アサイン者別' },
  { value: 'flat', label: 'フラット' },
];
```

**ガントバーの色分け (予実比較):**
```typescript
function getGanttBarColor(issue: Issue): 'green' | 'yellow' | 'red' {
  const daysElapsed = dayjs().diff(dayjs(issue.startedAt), 'day');
  const daysDue = dayjs(issue.deadline).diff(dayjs(issue.startedAt), 'day');
  const expectedProgress = (daysElapsed / daysDue) * 100;

  if (issue.progressPercent >= expectedProgress) return 'green';
  if (issue.progressPercent >= expectedProgress * 0.8) return 'yellow';
  return 'red';
}
```

**表示要素:**
- TimelineHeader: 日付軸（日/週表示）
- TodayLine: 今日の縦線
- GanttGroup: グルーピングラベル + GanttRow[]
- GanttRow: IssueName + GanttBar (予定+実績) + ProgressIndicator

### ViewToggle

セグメントコントロール形式。選択状態は `localStorage('progressBoardView')` で記憶。

```typescript
type ViewMode = 'gantt' | 'kanban';

function useViewMode(): [ViewMode, (mode: ViewMode) => void] {
  const [mode, setMode] = useState<ViewMode>(() =>
    (localStorage.getItem('progressBoardView') as ViewMode) || 'gantt'
  );
  useEffect(() => localStorage.setItem('progressBoardView', mode), [mode]);
  return [mode, setMode];
}
```

## 受け入れ基準

- [ ] ProgressBoardTabにViewToggle (ガント/カンバン) が表示される
- [ ] デフォルトはガントビュー、localStorage記憶
- [ ] カンバンでIssueカードのDnDによるステータス変更が動作する
- [ ] DnDで楽観的更新 → 失敗時ロールバックが動作する
- [ ] IssueCardにTitle/Avatars/Points/DueDate/ProgressBarが表示される
- [ ] ガントにGroupBySelector (ステータス/アサイン者/フラット) が表示される
- [ ] ガントバーの色がgreen/yellow/redで予実比較に基づく
- [ ] TodayLineが表示される
- [ ] IssueCard/GanttRowクリック → `/issues/[issueId]` 遷移
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- ガントバーのドラッグによる日程変更（MVP外）
- ガント上での直接Issue作成
