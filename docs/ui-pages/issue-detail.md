# Page: Issue詳細

**Related Business Spec:** `specs/business/issue-management.md`  
**Related Feature Spec:** `specs/features/manual-testing-ux-followups.md`

## Purpose
Issueの詳細情報、Definition of Done、サブタスク、作業ログを表示・管理する。

## Route
`/issues/[issueId]`

## Access Control
- 認証: 必要
- ロール: 全員

## Layout
AppLayout

## Component Tree
```
IssueDetailPage
└── AppLayout
    ├── IssueHeader
    │   ├── IssueTitle
    │   ├── StatusBadge
    │   ├── StoryPoints
    │   ├── MetaInfo (見積時間, 期限, 担当者リンク)
    │   ├── Select (ステータス変更)
    │   ├── Button (削除)
    │   └── ConfirmDialog (削除確認)
    └── IssueContent
        ├── DefinitionOfDone
        │   └── Checklist (完了のみ / Completion only)
        ├── SubtaskEditor
        │   ├── SubtaskCreateForm
        │   └── SubtaskRow[]
        │       ├── Title
        │       ├── StoryPoints
        │       ├── StatusLabel
        │       ├── Button (編集)
        │       └── Button (削除)
        └── WorkLogSection
            ├── EmptyState (ログ0件時)
            ├── WorkLogEntry[]
            │   ├── Minutes
            │   ├── Description
            │   ├── LoggedAt
            │   ├── Button (編集)
            │   └── Button (削除)
            ├── WorkLogCreateForm
            │   ├── PermissionGuard / HelperText
            │   ├── Input[type=number] (分数)
            │   ├── Textarea (説明)
            │   ├── Input[type=date] (作業日)
            │   └── Button (追加)
            └── ConfirmDialog (削除確認)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| Issue情報 (`projectId`, capabilities を含む) | `GET /issues/{issueId}` | セクションスケルトン | リトライ |
| Definition of Done | `GET /issues/{issueId}/definition-of-done` | セクションスケルトン | リトライ |
| サブタスク | `GET /issues/{issueId}/subtasks` | リストスケルトン | リトライ |
| 作業ログ | `GET /issues/{issueId}/work-logs` | カード内ローディング表示 | カード内エラー表示 |

## UI States
| 状態 | 表現 |
|------|------|
| loading | Issue詳細の読み込み中はセクションスケルトン、作業ログはカード内に「読み込み中...」を表示 |
| error | Issue詳細の取得失敗時は ErrorState + リトライ、作業ログはカード内エラー文言を表示 |
| success(empty) | 作業ログ EmptyState + 新規作業ログフォーム |
| success(with logs) | 作業ログ一覧 + 新規作業ログフォーム |
| editing | 対象作業ログ行またはサブタスク行がインライン編集フォームに切り替わる |
| confirmingDelete | イシュー、サブタスク、作業ログはすべて ConfirmDialog で削除確認を表示 |

## Interactions
- ステータス選択 → API経由で更新
- DoDチェック切替 → 楽観的更新 → API（Issue詳細では完了のみ可能）
- `issue.capabilities.canMutateWorkLogs = false` の場合、作業ログとサブタスクの追加 / 編集 / 削除 UI、およびイシュー削除 affordance を有効状態で表示しない
- ヘッダーの削除ボタン → ConfirmDialog 表示 → 確認後に API 経由で削除し、成功時は Toast を表示して `/projects/{issue.projectId}` へ遷移
- サブタスク作成フォーム送信 → API経由でサブタスクを作成し、一覧を再取得
- サブタスクの編集ボタン → 対象行をインライン編集フォームに切り替え、保存後に一覧を再取得
- サブタスクの削除ボタン → ConfirmDialog 表示 → 確認後に API 経由で削除し、一覧を再取得
- 作業ログ追加フォーム送信 → API経由で作業ログを追加し、一覧を再取得
- 作業ログの編集ボタン → 対象行をインライン編集フォームに切り替え、保存後に一覧を再取得
- 作業ログの削除ボタン → ConfirmDialog 表示 → 確認後に API 経由で削除し、一覧を再取得
- 担当者リンククリック → `/users/[userId]`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| ステータス変更 | `PATCH /issues/{issueId}/status` | バッジ即時更新 | Toast(error: API `message` 優先) |
| イシュー削除 | `DELETE /issues/{issueId}` | Success toast を表示し、`/projects/{issue.projectId}` へ遷移 | Toast(error: `extractIssueErrorMessage` で API `message` 優先) |
| DoD切替 | `PATCH /issues/{issueId}/definition-of-done/{doneItemId}` | チェック即時反映 | ロールバック + Toast(error) |
| サブタスク作成 | `POST /issues/{parentIssueId}/subtasks` | フォームをリセットし、一覧を再取得 | Toast(error) |
| サブタスク更新 | `PATCH /issues/{issueId}` | インライン編集を閉じ、一覧を再取得 | Toast(error) |
| サブタスク削除 | `DELETE /issues/{parentIssueId}/subtasks/{subtaskId}` | 一覧を再取得 | Toast(error) |
| 作業ログ追加 | `POST /issues/{issueId}/work-logs` | フォームをリセットし、一覧を再取得 | Toast(error: API `message` 優先) |
| 作業ログ更新 | `PATCH /issues/{issueId}/work-logs/{workLogId}` | インライン編集を閉じ、一覧を再取得 | Toast(error: API `message` 優先) |
| 作業ログ削除 | `DELETE /issues/{issueId}/work-logs/{workLogId}` | 確認ダイアログを閉じ、一覧を再取得 | Toast(error: API `message` 優先) |

## Notes
- SubtaskEditor は一覧表示、新規追加、インライン編集、削除確認まで接続済み
- IssueHeader / SubtaskEditor / WorkLogSection は `issue.capabilities.canMutateWorkLogs` を共有し、同じ active-member 判定で削除ボタンや mutation affordance を切り替える
- `GET /issues/{issueId}` の `issue.projectId` は、イシュー削除成功後の `/projects/{projectId}` リダイレクトに使用する
- サブタスク作成時は親Issueの assignees を `assigneeIds` に再利用し、見積時間は親Issueの `estimatedMinutes` を優先して送る
- サブタスクの編集UIは現状 `title` と `story_points` のみをインライン更新する
- サブタスク削除権限は作成者単位ではなく issue 単位で扱い、許可ユーザーは任意のサブタスクを削除できる
- WorkLogSection は空状態、一覧表示、新規追加、インライン編集、削除確認まで接続済み
- `GET /issues/{issueId}` の `issue.capabilities.canMutateWorkLogs` は、current viewer が issue に紐づく team の active member かどうかを表す
- WorkLogSection は `issue.capabilities.canMutateWorkLogs` を参照して、追加 / 編集 / 削除 affordance を切り替える
- 作業ログの編集 / 削除権限は作成者単位ではなく issue 単位で扱い、許可ユーザーは任意の作業ログを操作できる
- 現状の Issue詳細 UI では、ステータス変更と DoD の切替は専用 capability を持たず、未認可ユーザーは API の 403 を受ける
- Issue詳細の DoD は completion-only で、未完了項目を完了にする操作のみ許可し、項目追加は行わない
- 作業ログの追加・編集フォームは `logged_at` を日付入力で扱い、既存ログの `loggedAt` を編集フォームへ初期表示する
- 現状の作業ログ UI は `minutes`、`description`、`loggedAt` を表示し、API の `source` は画面表示していない
- `GET /issues/{issueId}/work-logs` は対象Issueが存在しない場合でも空配列を返す
- 現状の Issue詳細 / 編集UI ではテンプレート項目値を表示・編集しない
