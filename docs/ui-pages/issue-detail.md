# Page: Issue詳細

## Purpose
Issueの詳細情報、サブタスク、進捗、関連アラートを表示・管理する。

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
    │   ├── StatusBadge (ステータス変更可能)
    │   ├── ProgressBar (自動算出 S-03-08)
    │   └── Actions
    │       └── Button (編集 → EditIssueModal)
    ├── IssueBody
    │   ├── SMARTFields (読み取り専用)
    │   ├── AssigneeList
    │   │   └── Avatar[] + Name
    │   ├── DefinitionOfDone
    │   │   └── Checklist (チェック切替可)
    │   └── DueDateInfo
    ├── SubtaskSection (S-03-06 + S-03-09)
    │   ├── SubtaskList
    │   │   └── SubtaskRow[]
    │   │       ├── Checkbox
    │   │       ├── SubtaskName
    │   │       ├── EstimatedTime
    │   │       ├── StatusBadge
    │   │       ├── Badge ("予期せぬ作業" — 該当時のみ)
    │   │       └── Toggle ("予期せぬ作業" フラグ — 後から付与/解除可能)
    │   └── Button (サブタスク追加)
    │       └── Checkbox ("予期せぬ作業として登録")
    ├── WorkLogSection (フェーズ2 — MVP外)
    ├── Sidebar (右側)
    │   ├── ProgressSummary (予定 vs 実績)
    │   ├── TimelineInfo (開始日, 期限)
    │   └── RelatedAlerts (このIssueに関連するアラート — MVP内)
    └── EditIssueModal (全フィールド編集可能)
        ├── Input (タイトル)
        ├── Textarea (説明)
        ├── SMARTTemplateFields
        ├── AssigneeSelector (複数選択可)
        ├── Select (ステータス: 未着手/進行中/レビュー中/完了)
        ├── Select (優先度: low/medium/high/critical)
        ├── Input (ストーリーポイント — 必須, 1-13)
        ├── Input (見積時間 — 必須, 分単位)
        ├── DefinitionOfDone (ChecklistEditor)
        ├── DatePicker (開始日)
        ├── DatePicker (期限)
        ├── Select (チームタグ)
        └── Button (保存)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| Issue情報 | `GET /issues/{issueId}` | セクションスケルトン | リトライ |
| 関連アラート | `GET /issues/{issueId}/alerts` | リストスケルトン | リトライ |
| サブタスク | `GET /issues/{issueId}/sub-issues` | リストスケルトン | リトライ |
| 作業ログ (フェーズ2) | `GET /issues/{issueId}/work-logs` | — | — |

## UI States
| 状態 | 表現 |
|------|------|
| loading | セクションスケルトン |
| error | ErrorState + リトライ |
| success | Issue詳細表示 |

## Interactions
- StatusBadgeクリック → ステータス変更ドロップダウン
- DoDチェック切替 → 楽観的更新 → API
- 編集ボタン → EditIssueModal
- サブタスク追加ボタン → インラインフォーム
- アサイン者アバター/名前クリック → `/users/[userId]`
- "予期せぬ作業" Toggle → フラグ付与/解除

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| ステータス変更 | `PATCH /issues/{issueId}/status` | バッジ即時更新 | Toast(error) |
| DoD切替 | `PATCH /issues/{issueId}/definition-of-dones` | チェック即時反映 | ロールバック + Toast(error) |
| Issue編集 | `PATCH /issues/{issueId}` | Toast(success) + モーダル閉じ + 再取得 | Toast(error) + フィールドエラー |
| サブタスク追加 | `POST /issues/{issueId}/sub-issues` | Toast(success) + リスト再取得 | Toast(error) |

## Notes
- 進捗率はバックエンド算出。フロントは表示のみ (S-03-08)
- WorkLogSectionはフェーズ2だがコンポーネント枠は確保
- "予期せぬ作業" フラグは作成時にも後からも変更可能
