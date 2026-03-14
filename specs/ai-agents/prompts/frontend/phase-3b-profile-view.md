# Phase 3B: Profile View — プロフィール閲覧

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System), **Phase 0B** (Layout System)
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 5.12 (プロフィール閲覧), Section 7.10
- `docs/ui-pages/user-profile.md`

## 実装スコープ

### ディレクトリ構成

```
src/features/profile/
├── components/
│   ├── ProfileForm.tsx        # 既存: /profile/setup 用（リファクタ対象）
│   ├── ProfileView.tsx        # 新規: 閲覧用
│   ├── UserProfilePage.tsx    # 新規: /users/[userId] ページ
│   └── ExpertiseTags.tsx      # 新規: 得意分野タグ表示
└── hooks/
    └── useUserProfile.ts
```

```
src/pages/users/
└── [userId].tsx               # → UserProfilePage
```

### UserProfilePage

```typescript
// pages/users/[userId].tsx
import UserProfilePage from '@/features/profile/components/UserProfilePage';
export default UserProfilePage;
```

### Component Tree

```
UserProfilePage
└── AppLayout
    ├── ProfileHeader
    │   ├── Avatar (lg: 48px)
    │   ├── UserName
    │   ├── JobTitle
    │   └── [自分の場合] Button (プロフィール編集 → /profile/setup)
    ├── ProfileDetails
    │   ├── ExpertiseTags[] (S-06-01) — Badge コンポーネントで表示
    │   ├── AboutMe (自己紹介テキスト)
    │   ├── WorkHistory (職歴テキスト)
    │   └── ExternalLinks[] (リンクを新しいタブで開く)
    └── ActivitySummary
        ├── TeamMemberships — 所属チーム一覧（チーム名クリック → /teams/[teamId]）
        └── RecentIssues — 最近の担当Issue（Issue名クリック → /issues/[issueId]）
```

### SWRフック

```typescript
// useUserProfile.ts
const useUserProfile = (userId: string) =>
  useSWR(`users/${userId}/profile`, fetcher);
```

### 自分のプロフィール判定

```typescript
const { data: me } = useAuth();
const isSelf = me?.id === userId;
// isSelf の場合、「プロフィール編集」ボタンを表示
```

### 導線（他コンポーネントからのリンク）

このフェーズでは、以下のコンポーネントにプロフィールリンクを追加する:

| コンポーネント | リンク要素 | ファイル |
|---------------|----------|---------|
| WorkloadTable | メンバー行のAvatar+Name | `features/teams/components/WorkloadTable.tsx` |
| IssueDetailPage | AssigneeList のAvatar+Name | `features/issues/components/IssueDetailPage.tsx` |
| TeamManagementTab | FlaggedMembersのAvatar+Name | `features/dashboard/components/TeamManagementTab.tsx` |
| Sidebar/UserSection | 自分のアバター | `layouts/Sidebar/UserSection.tsx` |

各箇所で `<Link href={`/users/${userId}`}>` でラップする。

### API エンドポイント

| 操作 | メソッド | エンドポイント |
|------|---------|--------------|
| プロフィール取得 | GET | `/users/{userId}/profile` |

## 受け入れ基準

- [ ] `/users/[userId]` でプロフィール閲覧画面が表示される
- [ ] ExpertiseTags がBadgeで表示される
- [ ] ExternalLinks が新しいタブで開く
- [ ] 自分のプロフィール閲覧時に「編集」ボタンが表示される
- [ ] チーム詳細/Issue詳細/ダッシュボード/Sidebarからプロフィールへのリンクが動作する
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- プロフィール編集機能の変更（既存 `/profile/setup` をそのまま使用）
