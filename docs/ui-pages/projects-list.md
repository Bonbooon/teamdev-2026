# Page: プロジェクト一覧

## Purpose
ユーザーが所属するチームのプロジェクトを一覧表示し、進捗状況を俯瞰する。

## Route
`/projects`

## Access Control
- 認証: 必要
- ロール: 全員（Manager: PJ作成ボタン表示）

## Layout
AppLayout

## Component Tree
```
ProjectListPage
└── AppLayout
    ├── PageHeader
    │   ├── Title ("プロジェクト")
    │   └── [Manager] Button (PJ作成)
    ├── FilterBar
    │   ├── Select (ステータス: 全て/未着手/進行中/完了)
    │   └── Select (チーム: 自分が所属する全チームから絞り込み)
    │   ※ 表示対象は自分が所属するチームのPJのみ
    ├── ProjectCard[]
    │   ├── ProjectName
    │   ├── ProgressBar
    │   ├── StatusBadge
    │   ├── TeamBadge[]
    │   ├── DueDate
    │   └── AlertCount (yellow/red)
    └── [Manager] CreateProjectModal
        ├── Select (チーム — 必須、managerであるチームのみ選択可)
        ├── Input (PJ名)
        ├── Textarea (概要)
        ├── DatePicker (開始日, 終了日)
        └── Button (作成)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| PJ一覧 | `GET /projects` | スケルトンカード×6 | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×6 (2列グリッド) |
| empty | EmptyState: FolderIcon, "プロジェクトがありません", "プロジェクトを作成して始めましょう", PJ作成ボタン(Manager) |
| error | ErrorState + リトライ |
| success | ProjectCardのグリッド表示 |

## Interactions
- ProjectCardクリック → `/projects/[projectId]` に遷移
- PJ作成ボタン (Manager) → CreateProjectModal表示
- フィルター変更 → URLクエリパラメータ更新 + データ再取得
- ページネーション: `?page=1&per_page=20`

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| PJ作成 | `POST /projects` | Toast(success) + モーダル閉じ + 一覧再取得 | Toast(error) + フィールドエラー |

## Notes
- PJ一覧は「自分が所属するチーム」のプロジェクトのみ表示
- PJ作成時のチームSelectは、managerであるチームのみが選択肢に表示される
