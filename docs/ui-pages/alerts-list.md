# Page: アラート一覧

## Purpose
横断的なアラート一覧を表示し、フィルタリング・解決・再開操作を行う。

## Route
`/alerts`

## Access Control
- 認証: 必要
- ロール: 全員（解決/再開はアラート通知先ユーザー本人のみ）

## Layout
AppLayout

## Component Tree
```
AlertListPage
└── AppLayout
    ├── PageHeader
    │   └── Title ("アラート")
    ├── FilterBar
    │   ├── Select (レベル: yellow/red)
    │   ├── Select (カテゴリ)
    │   ├── Select (プロジェクト)
    │   └── Select (ステータス: active/resolved)
    └── AlertCard[]
        ├── AlertLevel (yellow/red)
        ├── Category
        ├── Title
        ├── Description
        ├── ProjectName
        ├── SuggestedActions[] (S-02-10: アクションサジェスト — MVP内)
        ├── CreatedAt
        └── Actions (解決, 再開)
            ※ 「解決」「再開」はアラート通知先ユーザー本人のみ操作可能
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アラート一覧 | `GET /alerts` | スケルトンカード×6 | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×6 |
| empty | EmptyState: BellIcon, "アラートはありません" |
| error | ErrorState + リトライ |
| success | AlertCardリスト表示 |

## Interactions
- フィルター変更 → URLクエリパラメータ更新 + データ再取得
- 解決ボタン → ConfirmDialog → API
- 再開ボタン → API
- ページネーション: `?page=1&per_page=20`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| 解決 | `POST /alerts/{alertId}/resolve` | Toast(success) + 一覧再取得 | Toast(error) |
| 再開 | `POST /alerts/{alertId}/reopen` | Toast(success) + 一覧再取得 | Toast(error) |

## Notes
- 権限判定: `alert.assigneeId === currentUser.id` でフロント判定
- canResolve === false → 解決/再開ボタンは非表示（disabledではなく非表示）
- SuggestedActions はカード内に直接表示
