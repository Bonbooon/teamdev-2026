# Page: Issue作成

## Purpose
選択したIssueテンプレートの項目定義に基づいて、プロジェクト内にIssueを作成する。

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
        ├── Select (テンプレート選択)
        ├── Input (タイトル)
        ├── Select (ストーリーポイント — 必須, 1 / 2 / 3 / 5 / 8 / 13)
        ├── Input (見積時間 — 必須, 分単位)
        ├── DatePicker (期限)
        ├── Select (ステータス)
        ├── DynamicTemplateFields
        │   ├── Checkbox (boolean)
        │   ├── Input[type=number] (integer / number)
        │   ├── Input[type=date] (date)
        │   ├── Input[type=datetime-local] (datetime)
        │   └── Textarea (string / json)
        ├── DefinitionOfDone
        │   └── ChecklistEditor
        │       ├── Input[] (受け入れ条件)
        │       └── Button (条件追加)
        ├── AssignmentSection
        │   ├── Text (MVPではteam tags / assigneesの入力UIは未実装)
        │   └── Text (現状はアサインなしでIssue作成可能。将来対応時に仕様を更新)
        └── Button (作成)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| テンプレート一覧 | `GET /issue-templates` | Select無効化 | リトライ |
| 選択テンプレート詳細 | `GET /issue-templates/{templateId}` | DynamicTemplateFields を未表示 | リトライ |
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
- テンプレート選択 → `GET /issue-templates/{templateId}` を取得し、`template.items` から動的項目を描画する
- テンプレート切り替え → `templateItemValues` を再初期化する
- サーバー側でも `templateItemValues` のキーを再検証し、未知のキーは `templateItemValues.{itemKey}` のフィールドエラーとして返す
- DefinitionOfDone → 項目の動的追加/削除
- フォーム送信 → React Hook Form + Zod バリデーション + テンプレート必須項目チェック
- テンプレート必須チェック → `false` と `0` は有効値として扱う（`itemKey` はスキーマ上必須だが、UIは欠損時にも安全にスキップする）

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| Issue作成 | `POST /projects/{projectId}/issues` | Toast(success) + `/projects/[projectId]` に遷移 + SWRキャッシュ再検証 | Toast(error) + フィールドエラー |

## Notes
- storyPoints: 必須、1 / 2 / 3 / 5 / 8 / 13 から選択
- estimatedMinutes: 必須、分単位の整数
- DynamicTemplateFields は `template.items` を `position` 順に描画する
- 対応する `valueType` は `boolean`, `integer`, `number`, `date`, `datetime`, `string`, `json`
- 動的項目の入力値は `templateItemValues` として送信される
- `issue_template_id` はサーバー側でも存在確認され、無効または削除済みテンプレートIDは `issue_template_id` のフィールドエラーになる
- アサインUIは現状プレースホルダー表示のみ
