# Page: チーム詳細

## Purpose
チームの情報、プロジェクト一覧、メンバーのワークロードを確認する。

## Route
`/teams/[teamId]`

## Access Control
- 認証: 必要
- ロール: 全員（Manager: 招待・編集ボタン表示）

## Layout
AppLayout

## Component Tree
```
TeamDetailPage
└── AppLayout
    ├── TeamHeader
    │   ├── TeamName
    │   ├── TeamStatusBadge
    │   └── [Manager] Actions
    │       ├── Button (メンバー招待 → InviteMemberModal)
    │       └── Button (チーム編集 → EditTeamModal)
    ├── Tabs
    │   ├── ProjectsTab (デフォルト)
    │   │   └── ProjectList
    │   │       ├── loading: Skeleton[]
    │   │       ├── error: ErrorState
    │   │       ├── empty: EmptyState
    │   │       └── success: ProjectLink[]
    │   │           ├── ProjectTitle
    │   │           ├── StatusBadge
    │   │           ├── [Optional] Description
    │   │           └── DueDate
    │   └── MembersTab
    │       └── WorkloadTable
    │           ├── empty: "メンバーがいません"
    │           └── MemberRow[]
    │               ├── NameLink
    │               ├── RoleBadge
    │               └── StatusBadge
    ├── [Manager] InviteMemberModal
    │   ├── Tabs (追加方法切替)
    │   │   ├── [既存ユーザー追加タブ]
    │   │   │   ├── UserSearch (名前/メールで検索)
    │   │   │   ├── UserList[] (検索結果)
    │   │   │   └── Button (追加 — 招待メールなし、即チーム参加)
    │   │   └── [メール招待タブ]
    │   │       ├── Input (メールアドレス)
    │   │       └── Button (招待 → 招待メール送信 → リンクからaccept)
    │   └── Select (ロール: manager / member)
    └── [Manager] EditTeamModal
        ├── Input (チーム名)
        ├── MemberList[]
        │   ├── Avatar + Name
        │   ├── RoleBadge (manager / member)
        │   ├── Toggle (活動ステータス: 活動中 / 非活動)
        │   └── Button (削除)
        └── Button (保存)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| チーム情報 | `GET /teams/{teamId}` | ヘッダースケルトン | リトライ |
| プロジェクト一覧 | `GET /projects?team_id={teamId}` | カードスケルトン | リトライ |
| メンバー一覧 | `GET /teams/{teamId}/members` | テーブルスケルトン | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | ヘッダースケルトン + タブ内スケルトン |
| empty (プロジェクト) | EmptyState: "プロジェクトがありません" |
| empty (メンバー) | テーブル内メッセージ: "メンバーがいません" |
| error | ErrorState + リトライ |
| success | ProjectsTab: プロジェクトカード一覧 / MembersTab: メンバーテーブル |

## Interactions
- ProjectsTabのプロジェクトカードクリック → `/projects/[projectId]` に遷移
- メンバー名クリック → `/users/[userId]` に遷移
- メンバー招待 (Manager) → InviteMemberModal
- チーム編集 (Manager) → EditTeamModal

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| メンバー追加 | `POST /teams/{teamId}/members` | Toast(success) + 一覧再取得 | Toast(error) |
| メール招待 | `POST /teams/{teamId}/invitations` | Toast(success) + モーダル閉じ | Toast(error) |
| チーム編集 | `PATCH /teams/{teamId}` | Toast(success) + モーダル閉じ + 再取得 | Toast(error) |

## Notes
- プロジェクト一覧は `team_id` クエリで対象チームに絞り込む
- 期限未設定のプロジェクトは "期限未設定" と表示する
