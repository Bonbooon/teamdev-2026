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
        ├── Input (ストーリーポイント — 必須, 1-21)
        ├── Input (見積時間 — 必須, 分単位)
        ├── DatePicker (期限)
        ├── Select (ステータス)
        ├── CheckboxGroup (チームタグ — project.teams から複数選択)
        ├── AssigneeSelector
        │   └── MemberCheckbox[] (選択済みチームのメンバーのみ・複数選択可)
        ├── DefinitionOfDone
        │   └── ChecklistEditor
        │       ├── Input[] (受け入れ条件)
        │       └── Button (条件追加)
        └── Button (作成)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| テンプレート一覧 + 項目定義 | `GET /issue-templates` | Select無効化 | リトライ |
| プロジェクト詳細（チームタグ表示用） | `GET /projects/{projectId}` | フォームスケルトン | リトライ |
| チームメンバー | `GET /teams/{teamId}/members` | AssigneeSelectorをスケルトン表示 | リトライ |
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
- チームタグ選択 → プロジェクトに紐づくチームを複数選択できる
- チームタグ変更 → アサイン対象者をリセットし、選択済みチームのメンバーだけを候補表示
- DefinitionOfDone → 項目の動的追加/削除
- フォーム送信 → React Hook Form + Zod バリデーション
- 送信時バリデーション → チーム1件以上、アサイン対象者1人以上、Definition of Done 1件以上が必須

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| Issue作成 | `POST /projects/{projectId}/issues` | Toast(success) + `/projects/[projectId]` に遷移 + SWRキャッシュ再検証 | Toast(error) + フィールドエラー |

## Notes
- storyPoints: 必須、1-21の整数
- estimatedMinutes: 必須、分単位の整数
- `GET /issue-templates` はテンプレート本体と `items[]` を返す
- チームタグは `GET /projects/{projectId}` の `project.teams[]` を使って描画する
- 現状の画面はテンプレート項目をまだ描画せず、SMARTプレースホルダー切替のみを行う
- SMART入力値は現状保存されず、必須バリデーション対象でもない
- AssigneeSelector はチームタグ選択後にだけ表示され、選択済みチームのメンバーを統合表示する
- Definition of Done は完了時だけでなく、Issue作成時にも1件以上必須
