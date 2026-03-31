# Page: Issue詳細

## Purpose
Issueの詳細情報、Definition of Done、サブタスク、作業ログプレースホルダーを表示・管理する。

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
        └── WorkLogSection (現状はプレースホルダー。API契約は GET/POST/PATCH/DELETE まで利用可能)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| Issue情報 | `GET /issues/{issueId}` | セクションスケルトン | リトライ |
| Definition of Done | `GET /issues/{issueId}/definition-of-done` | セクションスケルトン | リトライ |
| サブタスク | `GET /issues/{issueId}/subtasks` | リストスケルトン | リトライ |
| 作業ログAPI (UI接続は次フェーズ) | `GET /issues/{issueId}/work-logs` | 現状は未接続 | 現状は未接続 |

## UI States
| 状態 | 表現 |
|------|------|
| loading | セクションスケルトン |
| error | ErrorState + リトライ |
| success | Issue詳細表示 |

## Interactions
- ステータス選択 → API経由で更新
- DoDチェック切替 → 楽観的更新 → API
- DoD追加ボタン → 入力欄を表示して API 経由で追加
- 担当者リンククリック → `/users/[userId]`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| ステータス変更 | `PATCH /issues/{issueId}/status` | バッジ即時更新 | Toast(error) |
| DoD切替 | `PATCH /issues/{issueId}/definition-of-done/{doneItemId}` | チェック即時反映 | ロールバック + Toast(error) |
| DoD追加 | `POST /issues/{issueId}/definition-of-done` | Toast(success) + リスト再取得 | Toast(error) |

## Notes
- WorkLogSectionは現状「工事中」プレースホルダーを表示する
- `GET/POST /issues/{issueId}/work-logs` と `PATCH/DELETE /issues/{issueId}/work-logs/{workLogId}` のAPI契約と生成クライアント型はPhase 2時点で利用可能
- `GET /issues/{issueId}/work-logs` は対象Issueが存在しない場合でも空配列を返す
- 作業ログの更新/削除UIは未接続のまま据え置き
- 現状の Issue詳細 / 編集UI ではテンプレート項目値を表示・編集しない
