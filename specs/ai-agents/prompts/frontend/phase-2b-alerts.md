# Phase 2B: Alerts — アラート一覧

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System), **Phase 0B** (Layout System)
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 4.6 (AlertCard), Section 5.10 (アラート一覧), Section 6.11 (権限判定), Section 7.8
- `docs/ui-pages/alerts-list.md`
- `specs/business/alert-system-implementation.md`

## 実装スコープ

### ディレクトリ構成

```
src/features/alerts/
├── components/
│   ├── AlertListPage.tsx
│   ├── AlertCard.tsx
│   ├── AlertSummary.tsx
│   └── AlertFilterBar.tsx
└── hooks/
    └── useAlerts.ts
```

```
src/pages/alerts/
└── index.tsx              # → AlertListPage
```

### AlertCard コンポーネント

```typescript
type AlertCardProps = {
  level: 'yellow' | 'red';
  category: string;
  title: string;
  description: string;
  suggestedActions: string[];    // S-02-10: アクションサジェスト
  createdAt: string;
  projectName: string;
  assigneeId: string;
  currentUserId: string;
  onResolve?: () => void;
  onReopen?: () => void;
};
```

**スタイル:**
- Yellow: `border-l-4 border-warning-500 bg-warning-50`
- Red: `border-l-4 border-error-500 bg-error-50`
- SuggestedActions: カード内にリスト表示

**権限判定:**
```typescript
const canResolve = alert.assigneeId === currentUser.id;
// canResolve === false → 解決/再開ボタンは非表示（disabledではなく非表示）
```

### FilterBar

```typescript
const ALERT_FILTERS = {
  level: [
    { value: '', label: '全て' },
    { value: 'yellow', label: 'イエロー' },
    { value: 'red', label: 'レッド' },
  ],
  status: [
    { value: '', label: '全て' },
    { value: 'active', label: 'アクティブ' },
    { value: 'resolved', label: '解決済み' },
  ],
};
```

フィルターはURLクエリパラメータと同期。

### API エンドポイント

| 操作 | メソッド | エンドポイント |
|------|---------|--------------|
| アラート一覧 | GET | `/alerts` |
| 解決 | POST | `/alerts/{alertId}/resolve` |
| 再開 | POST | `/alerts/{alertId}/reopen` |

## 受け入れ基準

- [ ] `/alerts` でアラート一覧が表示される
- [ ] AlertCardにSuggestedActions（推奨アクション）が表示される
- [ ] Yellow/Red でスタイルが異なる
- [ ] フィルター（レベル/カテゴリ/PJ/ステータス）が動作する
- [ ] 通知先ユーザー本人のみ解決/再開ボタンが表示される
- [ ] ページネーションが動作する
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- アプリ内通知（ベルアイコン）— MVP外
