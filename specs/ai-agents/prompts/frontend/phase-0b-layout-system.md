# Phase 0B: Layout System — AppLayout + Sidebar + Header

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System)
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 2 (レイアウト構成)
- `docs/ui-pages/login.md`, `docs/ui-pages/profile-setup.md`
- 既存: `src/layouts/Layout.tsx`, `src/layouts/Sidebar/`

## 実装スコープ

### 1. レイアウトコンポーネント作成

| ファイル | 用途 | 適用ページ |
|---------|------|-----------|
| `src/layouts/AppLayout.tsx` | Sidebar + Header + PageContent | `/`, `/teams`, `/projects` 等 |
| `src/layouts/AuthLayout.tsx` | 中央寄せ、Sidebar/Headerなし | `/login` |
| `src/layouts/SetupLayout.tsx` | 中央寄せ、max-w-2xl、Sidebar/Headerなし | `/profile/setup` |
| `src/layouts/Header/index.tsx` | TabNavigation + PageTitle | AppLayout内 |
| `src/layouts/Header/TabNav.tsx` | タブナビゲーション | Header内 |
| `src/layouts/Sidebar/index.tsx` | リファクタ: QuickActions + UserSection | AppLayout内 |
| `src/layouts/Sidebar/QuickActions.tsx` | PJ作成・チーム作成ボタン (Manager) | Sidebar内 |
| `src/layouts/Sidebar/UserSection.tsx` | アバター + プロフィールリンク + ログアウト | Sidebar内 |

### 2. AppLayout の設計

```
┌──────────────────────────────────────────────────────┐
│  AppLayout                                           │
│  ┌──────────┬───────────────────────────────────────┐│
│  │          │  Header                               ││
│  │          │  (TabNav: /, /teams, /projects,        ││
│  │          │   /alerts, /surveys)                   ││
│  │          ├───────────────────────────────────────┤│
│  │ Sidebar  │                                       ││
│  │ (w-72)   │  {children}                           ││
│  │ fixed    │  (max-w: 1280px, mx-auto)             ││
│  │          │                                       ││
│  └──────────┴───────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

**AppLayout props:**
```typescript
type AppLayoutProps = {
  children: React.ReactNode;
  title?: string;
};
```

### 3. Header TabNavigation

```typescript
const TABS = [
  { key: '/', label: 'ダッシュボード' },
  { key: '/teams', label: 'チーム' },
  { key: '/projects', label: 'プロジェクト' },
  { key: '/alerts', label: 'アラート' },
  { key: '/surveys', label: 'サーベイ' },
];
```

アクティブ判定は `useRouter().pathname` でprefix matchする。

### 4. Sidebar 構成

```
Sidebar
├── Logo (Propass)
├── Quick Actions
│   ├── Button (PJ作成) [Manager]
│   └── Button (チーム作成) [Manager]
├── (spacer)
└── User Section
    ├── アバター + ユーザー名
    ├── プロフィール編集リンク → /profile/setup
    └── ログアウトボタン (ConfirmDialog付き)
```

**Manager判定:** `useAuth()` から取得したユーザー情報で「いずれかのチームでmanager」かを判定。

### 5. 既存ページの移行

| ページ | 変更内容 |
|--------|---------|
| `pages/login/index.tsx` | `Layout` → `AuthLayout` に変更 |
| `pages/profile/setup.tsx` | `Layout` → `SetupLayout` に変更 |
| `pages/index.tsx` | `Layout` → `AppLayout` に変更 |

### 6. 既存 Layout.tsx の扱い

`src/layouts/Layout.tsx` は `AppLayout.tsx` で置き換える。既存の `Sidebar/` は構成を変更して再利用する。古い `Layout.tsx` は削除。

## コーディング規約

- レイアウトコンポーネントは `src/layouts/` に配置
- `cn()` ユーティリティを使用
- Sidebar は `fixed left-0 top-0 h-screen w-72`
- PageContent は `ml-72`
- ログアウトボタンは `ConfirmDialog` (Phase 0Aで作成済み) を使用

## 受け入れ基準

- [ ] `AppLayout`, `AuthLayout`, `SetupLayout` の3レイアウトが作成されている
- [ ] Header にタブナビゲーション（5タブ）が表示される
- [ ] Sidebar にQuickActions + UserSectionが表示される
- [ ] QuickActionsはManager判定で表示/非表示
- [ ] ログアウトにConfirmDialogが表示される
- [ ] 既存3ページが新レイアウトに移行されている
- [ ] 古い `Layout.tsx` が削除されている
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- features/ ディレクトリの作成
- 新規ページの作成（既存ページの移行のみ）
- ダッシュボードのタブ構成（Phase 2Aで実装）
