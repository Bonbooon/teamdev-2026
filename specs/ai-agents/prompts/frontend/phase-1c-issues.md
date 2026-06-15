# Phase 1C: Issues — Issue作成 + Issue詳細

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A** (Design System), **Phase 0B** (Layout System)
- 並列実行可能: Phase 1A, Phase 1B と同時実行可
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 5.8 (Issue作成), Section 5.9 (Issue詳細), Section 7.6, 7.7
- `docs/ui-pages/issue-create.md`, `docs/ui-pages/issue-detail.md`
- `specs/business/issue-management.md`

## 実装スコープ

### ディレクトリ構成

```
src/
├── features/issues/
│   ├── components/
│   │   ├── IssueCreatePage.tsx
│   │   ├── IssueDetailPage.tsx
│   │   ├── IssueForm.tsx
│   │   ├── IssueHeader.tsx
│   │   ├── SMARTTemplateFields.tsx
│   │   ├── SubtaskEditor.tsx
│   │   ├── DefinitionOfDone.tsx
│   │   ├── AssigneeSelector.tsx
│   │   └── WorkLogSection.tsx       # フェーズ2 — スタブのみ
│   └── hooks/
│       ├── useIssue.ts
│       ├── useIssueSubtasks.ts
│       └── useIssueTemplates.ts
├── pages/
│   ├── projects/[projectId]/issues/
│   │   └── new.tsx                   # → IssueCreatePage
│   └── issues/
│       └── [issueId].tsx             # → IssueDetailPage
```

### IssueForm のバリデーションスキーマ

```typescript
import { z } from 'zod';

export const issueCreateSchema = z.object({
  templateId: z.string().uuid(),
  title: z.string().min(1, 'タイトルは必須です').max(200),
  specific: z.string().min(1, '必須です'),
  measurable: z.string().min(1, '必須です'),
  achievable: z.string().min(1, '必須です'),
  relevant: z.string().min(1, '必須です'),
  deadline: z.string().datetime(),
  assigneeIds: z.array(z.string().uuid()).min(1, 'アサイン者は1人以上必要です'),
  storyPoints: z.number().int().min(1).max(13),
  estimatedMinutes: z.number().int().min(1),
  startedAt: z.string().datetime().optional(),
  definitionOfDones: z.array(z.object({
    description: z.string().min(1),
  })).min(1, '受け入れ条件は1つ以上必要です'),
  subtasks: z.array(z.object({
    title: z.string().min(1),
    estimatedMinutes: z.number().int().min(0),
    isUnexpectedWork: z.boolean().default(false),
  })).optional(),
  teamTag: z.string().optional(),
});
```

### Issue詳細の楽観的更新

```typescript
// DoDチェック切替の楽観的更新パターン
const toggleDoD = async (dodId: string, isCompleted: boolean) => {
  // 1. SWRキャッシュを楽観的に更新
  mutate(`issues/${issueId}`, (prev) => ({
    ...prev,
    definitionOfDones: prev.definitionOfDones.map(d =>
      d.id === dodId ? { ...d, isCompleted } : d
    ),
  }), false);

  try {
    // 2. API呼び出し
    await client.api.issues._issueId(issueId).definition_of_dones.$patch({ body: { id: dodId, isCompleted } });
    // 3. 再検証
    mutate(`issues/${issueId}`);
  } catch {
    // 4. ロールバック
    mutate(`issues/${issueId}`);
    toast.error('更新に失敗しました');
  }
};
```

### "予期せぬ作業" フラグ

- サブタスク作成時: Checkboxで選択可能
- 既存サブタスク: Toggleで後から付与/解除可能
- フラグ付きサブタスクには Badge("予期せぬ作業") を表示

### Issueテンプレート（MVP, 4種類）

| テンプレート | SMARTプレースホルダーの変化 |
|-------------|--------------------------|
| 開発タスク | Specific: "実装する機能の詳細を記述", Measurable: "テスト項目・受け入れ条件" |
| バグ修正 | Specific: "再現手順を記述", Measurable: "修正後の期待結果" |
| 調査・検証 | Specific: "調査対象と目的", Measurable: "成果物（ドキュメント、PoC等）" |
| ドキュメント | Specific: "ドキュメントの対象範囲", Measurable: "レビュー完了基準" |

## 受け入れ基準

- [ ] `/projects/[projectId]/issues/new` でIssue作成フォームが表示される
- [ ] テンプレート選択でSMARTフィールドのプレースホルダーが変わる
- [ ] storyPoints (1-13) と estimatedMinutes の入力が必須
- [ ] サブタスクの動的追加/削除、"予期せぬ作業" チェックが動作する
- [ ] DoDの動的追加/削除が動作する
- [ ] `/issues/[issueId]` でIssue詳細が表示される
- [ ] DoDチェック切替で楽観的更新が動作する
- [ ] Zodバリデーションが正しく動作する
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- WorkLogSection の実装（スタブのみ配置、フェーズ2）
- カンバンボード内のカードUI（Phase 2C）
