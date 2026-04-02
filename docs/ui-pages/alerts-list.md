# Page: アラート一覧

**Related Feature Spec:** `specs/business/alert-system.md`

## Current Sync Status
- `GET /alerts` の各 alert には `projectName` が含まれる
- `AlertCard` は `projectName` が存在する場合にカード内へ表示する
- `projectName` は project title を優先し、relation が欠損した場合は `Project {projectId}` にフォールバックする
- `suggestedActions` のレスポンス shape は維持されている
- Seed 済み action plan の title / description は日本語
- フィルター変更時は SWR `keepPreviousData` により前回の一覧表示を維持したまま再取得する
- 解決 / 再開の失敗 toast は backend の `message` を優先し、未提供時のみ既存 fallback を使う
- このフェーズで alert API contract の追加変更はない
- category / project filter は後続フェーズに残している

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
    │   ├── ProjectName?
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

**Contract Note:** レスポンスには `alerts[].projectName` と既存 shape の `alerts[].suggestedActions[]` が含まれる。Phase 2 はこの既存 contract を UI で利用しており、backend 変更は発生していない。

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×3 |
| refetching | 専用 indicator は出さず、前回の AlertSummary / AlertCard リストを維持したまま再取得 |
| empty | EmptyState: BellIcon, "アラートはありません" |
| error | ErrorState + リトライ |
| success | AlertSummary + FilterBar + AlertCardリスト |

## Interactions
- フィルター変更 → ローカル state 更新 + 前回表示を維持したままデータ再取得
- URL クエリパラメータ同期は未実装
- 解決ボタン → API
- 再開ボタン → API
- ページネーション: グローバル規約に従い `?page=1&per_page=20` で管理

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| 解決 | `PATCH /alerts/{alertId}/resolve` | Toast(success) + 一覧再取得 | Toast(error: API `message` 優先、未提供時は固定 fallback) |
| 再開 | `POST /alerts/{alertId}/reopen` | Toast(success) + 一覧再取得 | Toast(error: API `message` 優先、未提供時は固定 fallback) |

## Notes
- SuggestedActions はカード内に直接表示される
- `AlertCard` は `projectName` が存在する場合に表示する
- `projectName` は project title を優先し、relation が欠損した場合は `Project {projectId}` にフォールバックする
- SuggestedActions の title / description は seed data で日本語化されている
- category / project filter は後続フェーズで対応する
