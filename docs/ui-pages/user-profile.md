# Page: プロフィール閲覧

## Purpose
他メンバーのプロフィール情報を閲覧する。

## Route
`/users/[userId]`

## Access Control
- 認証: 必要
- ロール: 全員

## Layout
AppLayout

## Component Tree
```
UserProfilePage
└── AppLayout
    ├── ProfileHeader
    │   ├── Avatar (lg)
    │   ├── UserName
    │   └── JobTitle
    ├── ProfileDetails
    │   ├── ExpertiseTags[] (S-06-01)
    │   ├── AboutMe
    │   ├── WorkHistory
    │   └── ExternalLinks[]
    └── ActivitySummary
        ├── TeamMemberships
        └── RecentIssues
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| プロフィール | `GET /users/{userId}/profile` | セクションスケルトン | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | セクションスケルトン |
| error | ErrorState + リトライ |
| success | プロフィール表示 |

## Interactions
- ExternalLinksクリック → 外部リンクを新しいタブで開く

## Mutations
なし（閲覧専用）

## 導線
アプリ内でアバターやユーザー名が表示されている箇所すべてから `/users/[userId]` へリンクする:
- チーム詳細 > メンバー一覧のアバター/名前
- Issue詳細 > アサイン者のアバター/名前
- ダッシュボード > 不調検知のFlaggedMembers
- ワークロードテーブルのメンバー行
- Sidebar > 自分のアバター（自プロフィール）

## Notes
- 自分のプロフィールを閲覧した場合は「編集」ボタンを表示 → `/profile/setup` に遷移
