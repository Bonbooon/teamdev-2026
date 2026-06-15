# Phase 0A: Design System — UIコンポーネント基盤

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 先行フェーズ: なし（最初に実行）
- 作業ディレクトリ: `teamdev-2026-front/`

## 依存パッケージ追加

```bash
pnpm add clsx tailwind-merge @heroicons/react
```

## Source of Truth

- `docs/ui-specification.md` — Section 3 (デザイントークン), Section 4 (共通コンポーネント一覧)
- `teamdev-2026-front/tailwind.config.ts` — 現状のTailwind設定
- `teamdev-2026-front/src/styles/globals.css` — 現状のグローバルCSS

## 実装スコープ

### 1. Tailwind Config 更新 (`tailwind.config.ts`)

デザイントークン（Section 3）を Tailwind に反映する:

```typescript
// tailwind.config.ts に追加する colors
colors: {
  primary: {
    50: '#EEF2F8', 100: '#D5E0F0', 200: '#AABFDA', 300: '#7F9EC4',
    500: '#4A6FA5', 600: '#3B5A88', 700: '#2D466B', 800: '#1F3250', 900: '#142236',
  },
  secondary: {
    50: '#EFF7F2', 100: '#D6ECDF', 200: '#ADD9BF', 300: '#8EC9A5',
    500: '#6EA88C', 600: '#588A71', 700: '#436B57',
  },
  accent: {
    50: '#F2F3F5', 100: '#E0E3E7', 300: '#B0B6BF', 500: '#8E96A0', 700: '#5C6370',
  },
  success: { 50: '#ECFDF5', 500: '#10B981', 600: '#059669' },
  warning: { 50: '#FFFBEB', 500: '#F59E0B', 600: '#D97706' },
  error: { 50: '#FEF2F2', 500: '#EF4444', 600: '#DC2626' },
  info: { 50: '#EFF6FF', 500: '#3B82F6' },
},
fontFamily: {
  sans: ['"Inter"', '"Noto Sans JP"', 'system-ui', 'sans-serif'],
},
fontSize: {
  xs: ['12px', { lineHeight: '1.5' }],
  sm: ['14px', { lineHeight: '1.5' }],
  base: ['16px', { lineHeight: '1.4' }],
  xl: ['20px', { lineHeight: '1.3' }],
  '2xl': ['24px', { lineHeight: '1.25' }],
},
```

### 2. globals.css 更新

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Noto+Sans+JP:wght@400;500;600;700&display=swap');

body {
  font-family: 'Inter', 'Noto Sans JP', system-ui, sans-serif;
  font-size: 14px;
  line-height: 1.5;
}
```

### 3. ユーティリティ関数 (`src/utils/cn.ts`)

```typescript
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### 4. UIコンポーネント作成 (`src/components/ui/`)

以下の19コンポーネントを作成する。各コンポーネントのprops定義・variant・スタイルは `docs/ui-specification.md` Section 4 に厳密に従うこと。

| ファイル | Section | 要点 |
|---------|---------|------|
| `Button.tsx` | 4.1 | variant: primary/secondary/danger/ghost, size: sm/md/lg, loading状態 |
| `Input.tsx` | 4.1 | label, error, hint, required, prefix/suffix |
| `Textarea.tsx` | 4.1 | label, error, rows, maxLength (カウンター) |
| `Select.tsx` | 4.1 | label, options, error, placeholder |
| `Checkbox.tsx` | 4.1 | label, checked, disabled |
| `Modal.tsx` | 4.2 | isOpen, onClose, title, size: sm/md/lg, ESC/オーバーレイで閉じる, フォーカストラップ |
| `ConfirmDialog.tsx` | 4.2 | title, message, confirmLabel, variant: danger/warning |
| `Table.tsx` | 4.3 | columns, data, loading (スケルトン行), emptyMessage, onRowClick |
| `Card.tsx` | 4.3 | padding: sm/md/lg, hoverable, onClick |
| `Badge.tsx` | 4.3 | variant: default/success/warning/error/info, size: sm/md |
| `Avatar.tsx` | 4.3 | src, name (イニシャルフォールバック), size: sm(32px)/md(40px)/lg(48px) |
| `Tabs.tsx` | 4.3 | tabs, activeKey, onChange |
| `Pagination.tsx` | 4.3 | currentPage, totalPages, onPageChange |
| `Dropdown.tsx` | 4.5 | trigger, items, align: left/right |
| `Skeleton.tsx` | 4.4 | variant: text/circle/rect, width, height, count |
| `EmptyState.tsx` | 4.4 | icon, title, description, action |
| `ErrorState.tsx` | 4.4 | message, onRetry |
| `ProgressBar.tsx` | 4.6 | value, variant, showLabel, size: sm/md, 色ルール |
| `StatusBadge.tsx` | 4.6 | status → 色マッピング |

**ConditionBadge** も Section 4.6 に定義あり。追加で作成すること。

### 5. 既存コンポーネント移動

既存の `src/components/` 配下のファイルを `src/components/common/` に移動:
- `AuthGuard.tsx` → `src/components/common/AuthGuard.tsx`
- `GoogleLoginButton.tsx` → `src/components/common/GoogleLoginButton.tsx`
- `Loading.tsx` → `src/components/common/Loading.tsx`

移動後、`_app.tsx` など既存のimportパスを更新すること。

## コーディング規約

- 全コンポーネントは `React.forwardRef` でrefを転送する（Input, Textarea, Select, Button）
- propsの型は `コンポーネント名Props` (例: `ButtonProps`)
- `cn()` ユーティリティを使ってクラス名を結合
- 各コンポーネントは1ファイルに型定義+実装をまとめる
- `export` はnamed export（default export不可。ページコンポーネントのみdefault export）

## 受け入れ基準

- [ ] `tailwind.config.ts` にデザイントークンが反映されている
- [ ] `globals.css` にフォント定義が追加されている
- [ ] `src/utils/cn.ts` が作成されている
- [ ] 19 + 1 (ConditionBadge) = 20 の UIコンポーネントが `src/components/ui/` に作成されている
- [ ] 各コンポーネントのprops型がui-specification.md Section 4 と一致している
- [ ] 既存コンポーネントが `src/components/common/` に移動され、importパスが更新されている
- [ ] `pnpm typecheck` がエラーなく通る
- [ ] `pnpm lint` がエラーなく通る

## やらないこと

- ページコンポーネントの作成（Phase 0B以降）
- features/ ディレクトリの作成（Phase 1以降）
- API通信ロジック
- テストファイルの作成（実装完了後に別途対応）
