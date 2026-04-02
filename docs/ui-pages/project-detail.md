# Page: プロジェクト詳細

## Purpose
プロジェクトの進捗ボード（カンバン/ガント統合）、アラート、設定を管理する。

## Route
`/projects/[projectId]`

## Access Control
- 認証: 必要
- ロール: 全員（Manager: 編集・アサイン操作可能）

## Layout
AppLayout

## Component Tree
```
ProjectDetailPage
└── AppLayout
    ├── ProjectHeader
    │   ├── ProjectName
    │   ├── StatusBadge
    │   ├── ProgressBar (全体進捗)
    │   └── Actions (編集, ステータス変更)
    ├── Tabs
    │   ├── ProgressBoardTab (S-05-02 + S-07-02, デフォルト)
    │   │   ├── ViewToggle (ガント / カンバン 表示切替)
    │   │   │  ※ デフォルト: ガントビュー
    │   │   │  ※ ユーザーの最後の選択をlocalStorageで記憶
    │   │   ├── Button (Issue作成 — ビュー共通、ViewToggle横に配置)
    │   │   ├── [カンバンビュー]
    │   │   │   └── KanbanBoard
    │   │   │       ├── Column (未着手)
    │   │   │       │   └── IssueCard[] (ドラッグ可能)
    │   │   │       │       ├── IssueTitle
    │   │   │       │       ├── AssigneeChips (担当者名チップ)
    │   │   │       │       ├── StoryPointsBadge
    │   │   │       │       ├── DueDate
    │   │   │       ├── Column (進行中)
    │   │   │       ├── Column (レビュー中)
    │   │   │       └── Column (完了)
    │   │   ├── MemberAssignmentPanel
    │   │   │   └── MemberAssignmentRow[]
    │   │   │       ├── MemberName / UnassignedLabel
    │   │   │       ├── AssignedIssueCount
    │   │   │       └── AssignedIssueSummary[]
    │   │   │           ├── IssueTitle
    │   │   │           └── IssueMeta (status, story points)
    │   │   └── [ガントビュー]
    │   │       └── GanttChart
    │   │           ├── GroupBySelector (デフォルト: ステータス別)
    │   │           │   ├── Option: ステータス別
    │   │           │   ├── Option: アサイン者別
    │   │           │   └── Option: フラット
    │   │           ├── TimelineHeader (日付軸)
    │   │           ├── TodayLine (今日の縦線)
    │   │           └── GanttGroup[]
    │   │               ├── GroupLabel
    │   │               └── GanttRow[]
    │   │                   ├── IssueName
    │   │                   ├── GanttBar (予定+実績, green/yellow/red)
    │   │                   └── ProgressIndicator
    │   ├── AlertsTab
    │   │   └── AlertCard[]
    │   └── SettingsTab
    │       ├── ProjectInfo (読み取り専用表示)
    │       ├── TeamAssignment (S-05-03)
    │       │   ├── AssignedTeam[]
    │       │   │   ├── TeamName
    │       │   │   ├── MemberCount
    │       │   │   └── [Manager] Button (解除)
    │       │   └── [Manager] Button (チームをアサイン → AssignTeamModal)
    │       ├── [Manager] Button (PJ編集 → EditProjectModal)
    │       ├── [Manager] AssignTeamModal
    │       │   ├── TeamSearch
    │       │   ├── TeamList[] (未アサインのチームのみ)
    │       │   └── Button (アサイン)
    │       └── [Manager] EditProjectModal (S-05-05)
    │           ├── Input (PJ名)
    │           ├── Textarea (概要)
    │           ├── DatePicker (開始日, 終了日)
    │           ├── Select (ステータス: 未着手/進行中/完了/一時停止/キャンセル)
    │           └── Button (保存)
```

## Data Requirements
| データ | エンドポイント | loading | error | 備考 |
|--------|--------------|---------|-------|------|
| PJ情報 | `GET /projects/{projectId}` | ヘッダースケルトン | リトライ | |
| Issue一覧 | `GET /projects/{projectId}/issues` | ボードスケルトン | リトライ | カンバン+ガント+担当一覧パネル共有 |
| アラート | `GET /projects/{projectId}/alerts` | リストスケルトン | リトライ | |

カンバンとガントは同一APIデータ (`GET /projects/{projectId}/issues`) を共有。SWRキー1つで管理。

## UI States
| 状態 | 表現 |
|------|------|
| loading | ボードスケルトン |
| empty | EmptyState: "Issueがありません" + Issue作成ボタン |
| error | ErrorState + リトライ |
| success | ProgressBoardTab表示 |

## Interactions
- ViewToggle → ガント/カンバン切替（localStorage記憶）
- Issue作成ボタン → `/projects/[projectId]/issues/new` に遷移
- カンバンDnD → ステータス変更（楽観的更新）
- カンバンDnD が business rule で reject された場合はロールバックし、API `message` を Toast 表示
- IssueCard/GanttRowクリック → `/issues/[issueId]` に遷移
- GroupBySelector → グルーピング切替（ステータス別/アサイン者別/フラット）

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| Issueステータス変更 (DnD) | `PATCH /issues/{issueId}/status` | 楽観的更新 | ロールバック + Toast(error: API `message` 優先) |
| PJ編集 | `PATCH /projects/{projectId}` | Toast(success) + モーダル閉じ | Toast(error) |
| チームアサイン | `POST /projects/{projectId}/teams` | Toast(success) + 再取得 | Toast(error) |
| チーム解除 | `DELETE /projects/{projectId}/teams/{teamId}` | Toast(success) + 再取得 | Toast(error) |

## Notes
- ガントの色分け: expectedProgress対比でgreen/yellow/red
- Issue一覧は1つのSWRキーで管理し、ビュー切替時にAPIを重複して叩かない
- カンバンDnDの楽観的更新はSWRキャッシュ直接操作
- Kanban card は assignee が存在する場合に担当者名チップを表示する
- ProgressBoard の member assignment panel は assignee ごとに issue title / status / story points を grouped 表示し、未割り当て issue は「未割り当て」にまとめる
- Issue が 0件のとき、member assignment panel は EmptyState を表示する
- member assignment panel の issue 行は現時点では issue detail へのリンクではなく、読み取り専用の要約表示
