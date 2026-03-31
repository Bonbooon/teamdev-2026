# Page: Issue詳細

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
    │   └── Select (ステータス変更)
    └── IssueContent
        ├── DefinitionOfDone
        │   ├── Checklist (チェック切替可)
        │   └── Button (条件追加)
        ├── SubtaskEditor
        │   └── SubtaskRow[]
        └── WorkLogSection
            ├── EmptyState (ログ0件時)
            ├── WorkLogEntry[]
            │   ├── Minutes
            │   ├── Description
            │   ├── LoggedAt
            │   ├── Button (編集)
            │   └── Button (削除)
            ├── WorkLogCreateForm
            │   ├── Input[type=number] (分数)
            │   ├── Textarea (説明)
            │   ├── Input[type=date] (作業日)
            │   └── Button (追加)
            └── ConfirmDialog (削除確認)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| Issue情報 | `GET /issues/{issueId}` | セクションスケルトン | リトライ |
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
| editing | 対象作業ログ行がインライン編集フォームに切り替わる |
| confirmingDelete | ConfirmDialog で削除確認を表示 |

## Interactions
- ステータス選択 → API経由で更新
- DoDチェック切替 → 楽観的更新 → API
- DoD追加ボタン → 入力欄を表示して API 経由で追加
- 作業ログ追加フォーム送信 → API経由で作業ログを追加し、一覧を再取得
- 作業ログの編集ボタン → 対象行をインライン編集フォームに切り替え、保存後に一覧を再取得
- 作業ログの削除ボタン → ConfirmDialog 表示 → 確認後に API 経由で削除し、一覧を再取得
- 担当者リンククリック → `/users/[userId]`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| ステータス変更 | `PATCH /issues/{issueId}/status` | バッジ即時更新 | Toast(error) |
| DoD切替 | `PATCH /issues/{issueId}/definition-of-done/{doneItemId}` | チェック即時反映 | ロールバック + Toast(error) |
| DoD追加 | `POST /issues/{issueId}/definition-of-done` | Toast(success) + リスト再取得 | Toast(error) |
| 作業ログ追加 | `POST /issues/{issueId}/work-logs` | フォームをリセットし、一覧を再取得 | 専用の mutation エラー表示は未実装 |
| 作業ログ更新 | `PATCH /issues/{issueId}/work-logs/{workLogId}` | インライン編集を閉じ、一覧を再取得 | 専用の mutation エラー表示は未実装 |
| 作業ログ削除 | `DELETE /issues/{issueId}/work-logs/{workLogId}` | 確認ダイアログを閉じ、一覧を再取得 | 専用の mutation エラー表示は未実装 |

## Notes
- WorkLogSection は空状態、一覧表示、新規追加、インライン編集、削除確認まで接続済み
- 作業ログの追加・編集フォームは `logged_at` を日付入力で扱い、既存ログの `loggedAt` を編集フォームへ初期表示する
- 現状の作業ログ UI は `minutes`、`description`、`loggedAt` を表示し、API の `source` は画面表示していない
- `GET /issues/{issueId}/work-logs` は対象Issueが存在しない場合でも空配列を返す
- 現状の Issue詳細 / 編集UI ではテンプレート項目値を表示・編集しない
