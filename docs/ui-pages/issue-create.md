# Page: Issue作成

## Purpose
SMARTテンプレートに基づいてプロジェクト内にIssueを作成する。

## Route
`/projects/[projectId]/issues/new`

## Access Control
- 認証: 必要
- ロール: 全員

## Layout
AppLayout

## Component Tree
```
IssueCreatePage
└── AppLayout
    ├── PageHeader
    │   └── Title ("Issue作成")
    └── IssueForm
        ├── Select (テンプレート選択 — 複数種類、プレースホルダーが変わる)
        ├── Input (タイトル)
        ├── SMARTTemplateFields
        │   ├── Textarea (Specific: 何をすべきか)
        │   ├── Textarea (Measurable: 完了基準)
        │   ├── Textarea (Achievable: スコープ)
        │   ├── Textarea (Relevant: プロジェクト目標との関連)
        │   └── DatePicker (Time-bound: 期限)
        ├── AssigneeSelector
        │   └── MemberSelect (複数選択可)
        ├── Input (ストーリーポイント — 必須, 1-13)
        ├── Input (見積時間 — 必須, 分単位)
        ├── DatePicker (開始日)
        ├── DefinitionOfDone
        │   └── ChecklistEditor
        │       ├── Input[] (受け入れ条件)
        │       └── Button (条件追加)
        ├── SubtaskEditor (S-03-06)
        │   └── SubtaskRow[]
        │       ├── Input (サブタスク名)
        │       ├── Input (見積時間)
        │       ├── Checkbox ("予期せぬ作業" フラグ)
        │       └── Button (削除)
        ├── Select (チームタグ)
        └── Button (作成)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| テンプレート一覧 | `GET /issue-templates` | Select無効化 | リトライ |
| チームメンバー | `GET /teams/{teamId}/members` | Select無効化 | リトライ |
| **mutation** | `POST /projects/{projectId}/issues` | ボタンスピナー | Toast(error) + フィールドエラー |

## Issueテンプレート（MVP）
1. **開発タスク** — 機能開発・技術的改善向け
2. **バグ修正** — 不具合修正向け（再現手順、期待結果、実際の結果のガイド）
3. **調査・検証** — リサーチ・PoC向け
4. **ドキュメント** — ドキュメント作成・更新向け

## UI States
| 状態 | 表現 |
|------|------|
| loading | フォームスケルトン |
| error | バリデーションエラー表示 |
| success | フォーム表示 |

## Interactions
- テンプレート選択 → SMARTフィールドのプレースホルダーテキストが変化
- DefinitionOfDone → 項目の動的追加/削除
- SubtaskEditor → サブタスクの動的追加/削除
- "予期せぬ作業" チェック → サブタスクにフラグ付与
- フォーム送信 → React Hook Form + Zod バリデーション

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| Issue作成 | `POST /projects/{projectId}/issues` | Toast(success) + `/projects/[projectId]` に遷移 + SWRキャッシュ再検証 | Toast(error) + フィールドエラー |

## Notes
- storyPoints: 必須、1-13の整数
- estimatedMinutes: 必須、分単位の整数
- SMART全フィールドが入力必須
- DoDが未設定だと完了にできない（バックエンド制約）
