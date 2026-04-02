# Page: アラート一覧

**Related Feature Spec:** `specs/features/manual-testing-ux-followups.md` (Scope B)

## Phase 1 Sync Status
- `GET /alerts` の各 alert には `projectName` が含まれる
- `projectName` は project title を優先し、relation が欠損した場合は `Project {projectId}` にフォールバックする
- `suggestedActions` のレスポンス shape は維持されている
- Seed 済み action plan の title / description は日本語
- `projectName` のカード表示、category / project filter、non-blank refetch、API `message` 優先 toast は Phase 2+ の継続項目

## Purpose
横断的なアラート一覧を表示し、レベル/ステータスで絞り込み、解決・再開操作を行う。

## Route
`/alerts`

## Access Control
- 認証: 必要
- ロール: 全員
- 備考: 解決/再開の最終権限は API 側で判定する

## Layout
AppLayout

## Component Tree
```
AlertListPage
└── AppLayout (title="アラート")
    ├── AlertSummary
    │   ├── Badge (全て)
    │   ├── Badge (Yellow)
    │   ├── Badge (Red)
    │   ├── Badge (活動中)
    │   └── Badge (解決済み)
    ├── FilterBar
    │   ├── Select (レベル: yellow/red)
    │   └── Select (ステータス: active/resolved)
    ├── AlertCard[]
    │   ├── AlertLevel (yellow/red)
    │   ├── Category
    │   ├── Description
    │   ├── SuggestedActions[] (S-02-10: アクションサジェスト — MVP内)
    │   ├── CreatedAt
    │   ├── ResolvedBadge? (解決済み)
    │   └── Actions (解決, 再開)
    └── Pagination
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アラート一覧 | `GET /alerts` | スケルトンカード×3 | リトライ |

**Contract Note:** レスポンスには `alerts[].projectName` と既存 shape の `alerts[].suggestedActions[]` が含まれる。

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×3 |
| refetching | 専用 state なし（フィルター変更時は loading に戻る） |
| empty | EmptyState: BellIcon, "アラートはありません" |
| error | ErrorState + リトライ |
| success | AlertSummary + FilterBar + AlertCardリスト |

## Interactions
- フィルター変更 → ローカル state 更新 + データ再取得
- URL クエリパラメータ同期は未実装
- 解決ボタン → API
- 再開ボタン → API
- ページネーション: クライアント側で 10 件ごとに分割

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| 解決 | `PATCH /alerts/{alertId}/resolve` | Toast(success) + 一覧再取得 | Toast(error: 固定メッセージ) |
| 再開 | `POST /alerts/{alertId}/reopen` | Toast(success) + 一覧再取得 | Toast(error: 固定メッセージ) |

## Notes
- SuggestedActions はカード内に直接表示される
- `GET /alerts` 契約には `projectName` が含まれるが、現在の AlertCard UI では未表示
- `projectName` は project title を優先し、relation が欠損した場合は `Project {projectId}` にフォールバックする
- SuggestedActions の title / description は seed data で日本語化されている
- category / project filter、non-blank refetch、API `message` 優先 toast は Phase 2+ で対応する
