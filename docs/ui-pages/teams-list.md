# Page: チーム一覧

## Purpose
マネージャーは管轄チーム、メンバーは所属チームを一覧表示する。

## Route
`/teams`

## Access Control
- 認証: 必要
- ロール: 全員（Manager: チーム作成ボタン表示）

## Layout
AppLayout

## Component Tree
```
TeamListPage
└── AppLayout
    ├── PageHeader
    │   ├── Title ("チーム")
    │   └── [Manager] Button (チーム作成)
    ├── TeamCard[]
    │   ├── TeamName
    │   ├── MemberCount
    │   └── ConditionBadge (コンディション概況 — 良好/注意/警告)
    └── [Manager] CreateTeamModal
        ├── Input (チーム名)
        ├── MemberSelector
        └── Button (作成)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| チーム一覧 | `GET /teams` | スケルトンカード×6 | リトライ |

`GET /teams` のレスポンスに `memberCount` と `conditionStatus` ("good" / "caution" / "warning") を含める。

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×6 (2列グリッド) |
| empty | EmptyState: UsersIcon, "チームがありません", Manager: チーム作成ボタン |
| error | ErrorState + リトライボタン |
| success | TeamCardのグリッド表示 |

## Interactions
- TeamCardクリック → `/teams/[teamId]` に遷移
- チーム作成ボタン (Manager) → CreateTeamModal表示
- ページネーション: `?page=1&per_page=20`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| チーム作成 | `POST /teams` | Toast(success) + モーダル閉じ + 一覧再取得 | Toast(error) + フィールドエラー |

## Notes
- チーム作成はマネージャーのみ。`[Manager]` のボタン・モーダルはメンバーには表示されない。
- 「いずれかのチームでmanager」かどうかで判定。
