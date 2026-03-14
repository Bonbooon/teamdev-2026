# Phase 1A: Teams — チーム一覧 + チーム詳細

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System), **Phase 0B** (Layout System)
- 並列実行可能: Phase 1B, Phase 1C と同時実行可
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 5.4 (チーム一覧), Section 5.5 (チーム詳細), Section 7.2, 7.3
- `docs/ui-pages/teams-list.md`, `docs/ui-pages/team-detail.md`
- `specs/business/team-management.md`
- `specs/api/openapi-design-reference.json` — Teams エンドポイント

## 実装スコープ

### ディレクトリ構成

```
src/
├── features/teams/
│   ├── components/
│   │   ├── TeamListPage.tsx
│   │   ├── TeamDetailPage.tsx
│   │   ├── TeamCard.tsx
│   │   ├── TeamHeader.tsx
│   │   ├── WorkloadTable.tsx
│   │   ├── CreateTeamModal.tsx
│   │   ├── EditTeamModal.tsx
│   │   └── InviteMemberModal.tsx
│   └── hooks/
│       ├── useTeams.ts
│       ├── useTeam.ts
│       └── useTeamMembers.ts
├── pages/teams/
│   ├── index.tsx           # → TeamListPage
│   └── [teamId].tsx        # → TeamDetailPage
```

### ページ実装

**チーム一覧 (`/teams`):**
- TeamCard: TeamName + MemberCount + ConditionBadge
- Manager: チーム作成ボタン + CreateTeamModal
- ページネーション: `?page=1&per_page=20`
- TeamCardクリック → `/teams/[teamId]`

**チーム詳細 (`/teams/[teamId]`):**
- TeamHeader: TeamName + StatusBadge + Manager用Actions
- Tabs: ProjectsTab (default) + MembersTab
- ProjectsTab: ProjectCard[] (名前/進捗/ステータス/期限)
- MembersTab: WorkloadTable (Avatar+Name/IssueCount/TotalPoints/WorkloadIndicator) + Pagination
- Manager: InviteMemberModal (既存ユーザー追加 + メール招待の2タブ), EditTeamModal

### SWRフック

```typescript
// useTeams.ts
const useTeams = (params?: { page?: number; per_page?: number }) =>
  useSWR(`teams?page=${params?.page}&per_page=${params?.per_page}`, fetcher);

// useTeam.ts
const useTeam = (teamId: string) =>
  useSWR(`teams/${teamId}`, fetcher);

// useTeamMembers.ts
const useTeamMembers = (teamId: string, params?: { page?: number }) =>
  useSWR(`teams/${teamId}/members?page=${params?.page}`, fetcher);
```

### API エンドポイント

| 操作 | メソッド | エンドポイント |
|------|---------|--------------|
| チーム一覧取得 | GET | `/teams` |
| チーム詳細取得 | GET | `/teams/{teamId}` |
| メンバー一覧取得 | GET | `/teams/{teamId}/members` |
| ワークロード取得 | GET | `/teams/{teamId}/member-workloads` |
| コンディション取得 | GET | `/teams/{teamId}/condition-summary` |
| チーム作成 | POST | `/teams` |
| チーム編集 | PATCH | `/teams/{teamId}` |
| メンバー追加 | POST | `/teams/{teamId}/members` |
| メール招待 | POST | `/teams/{teamId}/invitations` |

### WorkloadIndicator 閾値

```typescript
const WORKLOAD_THRESHOLD = 40; // pt/週

function getWorkloadColor(points: number): 'green' | 'yellow' | 'red' {
  if (points <= WORKLOAD_THRESHOLD * 0.8) return 'green';
  if (points <= WORKLOAD_THRESHOLD) return 'yellow';
  return 'red';
}
```

## コーディング規約

- pages/ は薄いラッパー: `import TeamListPage from '@/features/teams/components/TeamListPage'; export default TeamListPage;`
- メンバー行のアバター/名前は `/users/[userId]` への `next/link`
- フォームは react-hook-form + zod
- mutation後は関連SWRキーを `mutate()` で再検証

## 受け入れ基準

- [ ] `/teams` でチーム一覧が表示される
- [ ] `/teams/[teamId]` でチーム詳細（2タブ）が表示される
- [ ] TeamCardにConditionBadge（良好/注意/警告）が表示される
- [ ] WorkloadTableにWorkloadIndicator (green/yellow/red) が表示される
- [ ] Manager: チーム作成/編集/メンバー招待モーダルが動作する
- [ ] ページネーションが動作する
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- ダッシュボードのTeamManagementTab（Phase 2A）
- プロジェクト詳細のチームアサイン（Phase 1B）
