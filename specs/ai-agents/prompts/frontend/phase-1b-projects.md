# Phase 1B: Projects — プロジェクト一覧 + プロジェクト詳細

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System), **Phase 0B** (Layout System)
- 並列実行可能: Phase 1A, Phase 1C と同時実行可
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 5.6 (PJ一覧), Section 5.7 (PJ詳細), Section 7.4, 7.5
- `docs/ui-pages/projects-list.md`, `docs/ui-pages/project-detail.md`
- `specs/business/project-management.md`

## 実装スコープ

### ディレクトリ構成

```
src/
├── features/projects/
│   ├── components/
│   │   ├── ProjectListPage.tsx
│   │   ├── ProjectDetailPage.tsx
│   │   ├── ProjectCard.tsx
│   │   ├── ProjectHeader.tsx
│   │   ├── ProgressBoard/
│   │   │   ├── index.tsx          # ViewToggle + プレースホルダー
│   │   │   └── ViewToggle.tsx
│   │   ├── CreateProjectModal.tsx
│   │   ├── EditProjectModal.tsx
│   │   ├── AssignTeamModal.tsx
│   │   └── FilterBar.tsx
│   └── hooks/
│       ├── useProjects.ts
│       ├── useProject.ts
│       └── useProjectIssues.ts
├── pages/projects/
│   ├── index.tsx                  # → ProjectListPage
│   └── [projectId]/
│       └── index.tsx              # → ProjectDetailPage
```

### ページ実装

**プロジェクト一覧 (`/projects`):**
- FilterBar: ステータス + チーム（所属チームのみ）
- ProjectCard: ProjectName + ProgressBar + StatusBadge + TeamBadge[] + DueDate + AlertCount
- Manager: PJ作成ボタン + CreateProjectModal (チーム選択必須)
- ページネーション

**プロジェクト詳細 (`/projects/[projectId]`):**
- ProjectHeader: ProjectName + StatusBadge + ProgressBar + Actions
- 3タブ: ProgressBoardTab (default), AlertsTab, SettingsTab
- ProgressBoardTab: ViewToggle + Issue作成ボタン + プレースホルダー表示
  - **注意:** KanbanBoard と GanttChart の実装は Phase 2C で行う。このフェーズではViewToggle + プレースホルダーのみ。
- AlertsTab: AlertCard[] (カードの実体は Phase 2B だが、APIデータ表示のみここで対応)
- SettingsTab: ProjectInfo + TeamAssignment + EditProjectModal + AssignTeamModal

### SWRフック

```typescript
// useProjects.ts
const useProjects = (params?: { page?: number; status?: string; teamId?: string }) =>
  useSWR(buildKey('projects', params), fetcher);

// useProject.ts
const useProject = (projectId: string) =>
  useSWR(`projects/${projectId}`, fetcher);

// useProjectIssues.ts — カンバン+ガント共有データ
const useProjectIssues = (projectId: string) =>
  useSWR(`projects/${projectId}/issues`, fetcher);
```

### API エンドポイント

| 操作 | メソッド | エンドポイント |
|------|---------|--------------|
| PJ一覧取得 | GET | `/projects` |
| PJ詳細取得 | GET | `/projects/{projectId}` |
| Issue一覧取得 | GET | `/projects/{projectId}/issues` |
| PJアラート取得 | GET | `/projects/{projectId}/alerts` |
| PJ作成 | POST | `/projects` |
| PJ編集 | PATCH | `/projects/{projectId}` |
| チームアサイン | POST | `/projects/{projectId}/teams` |
| チーム解除 | DELETE | `/projects/{projectId}/teams/{teamId}` |

### EditProjectModal のステータス選択肢

```typescript
const PROJECT_STATUSES = [
  { value: 'not_started', label: '未着手' },
  { value: 'in_progress', label: '進行中' },
  { value: 'completed', label: '完了' },
  { value: 'on_hold', label: '一時停止' },
  { value: 'cancelled', label: 'キャンセル' },
];
```

## コーディング規約

- pages/ は薄いラッパー
- フィルターはURLクエリパラメータと同期 (`useRouter`)
- フォームは react-hook-form + zod
- PJ作成モーダルのチームSelectは、managerであるチームのみ表示

## 受け入れ基準

- [ ] `/projects` でプロジェクト一覧が表示される
- [ ] `/projects/[projectId]` でプロジェクト詳細（3タブ）が表示される
- [ ] ProgressBoardTabにViewToggle + Issue作成ボタンが表示される
- [ ] SettingsTabでチームアサイン/解除ができる
- [ ] Manager: PJ作成/編集モーダルが動作する
- [ ] フィルターがURLクエリパラメータと同期する
- [ ] ページネーションが動作する
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- KanbanBoard / GanttChart の実装（Phase 2C）
- AlertCardコンポーネントの実装（Phase 2B — ただしデータ取得・表示は行う）
