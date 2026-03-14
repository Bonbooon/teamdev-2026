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
    │   │   └── ProjectCard[]
    │   │       ├── ProjectName
    │   │       ├── ProgressBar
    │   │       ├── StatusBadge
    │   │       └── DueDate
    │   └── MembersTab
    │       ├── WorkloadTable (S-07-01)
    │       │   ├── MemberRow[]
    │       │   │   ├── Avatar + Name
    │       │   │   ├── IssueCount (完了/着手中/未着手)
    │       │   │   ├── TotalPoints
    │       │   │   └── WorkloadIndicator (green/yellow/red — デフォルト閾値、カスタマイズはMVP外)
    │       │   └── Pagination
    │       └── [Manager] Button (メンバー招待)
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
| メンバー一覧 | `GET /teams/{teamId}/members` | テーブルスケルトン | リトライ |
| ワークロード | `GET /teams/{teamId}/member-workloads` | テーブルスケルトン | リトライ |
| コンディション | `GET /teams/{teamId}/condition-summary` | カードスケルトン | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | ヘッダースケルトン + タブ内スケルトン |
| empty (プロジェクト) | EmptyState: "プロジェクトがありません" |
| empty (メンバー) | EmptyState: "メンバーがいません" + 招待ボタン(Manager) |
| error | ErrorState + リトライ |
| success | タブ表示 |

## Interactions
- ProjectCardクリック → `/projects/[projectId]` に遷移
- メンバー行のアバター/名前クリック → `/users/[userId]` に遷移
- メンバー招待 (Manager) → InviteMemberModal
- チーム編集 (Manager) → EditTeamModal
- ページネーション (MembersTab): `?page=1&per_page=20`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| メンバー追加 | `POST /teams/{teamId}/members` | Toast(success) + 一覧再取得 | Toast(error) |
| メール招待 | `POST /teams/{teamId}/invitations` | Toast(success) + モーダル閉じ | Toast(error) |
| チーム編集 | `PATCH /teams/{teamId}` | Toast(success) + モーダル閉じ + 再取得 | Toast(error) |

## Notes
- WorkloadIndicator閾値: green ≤ 80%, yellow 80-100%, red > 100% (基準値: 40pt/週)
- メンバーのアバター/名前は `/users/[userId]` へのリンク
