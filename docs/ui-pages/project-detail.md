# Page: プロジェクト詳細

**Related Feature Specs:** `specs/features/project-insights-chart.md`, `specs/features/project-insights-ai-analysis.md`, `specs/features/manual-testing-ux-followups.md` (Scope C)

## Purpose
プロジェクトの進捗ボード（カンバン/ガント統合）、アラート、設定を管理する。

## Route
`/projects/[projectId]`

## Access Control
- 認証: 必要
- ロール: プロジェクトメンバー全員（`project.canManage` が true の場合のみ編集・アサイン・ステータス変更を表示）

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
    │   └── Actions ([Manager] 編集, [Manager] ステータス変更)
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
    [SurveyResultsTab] SummaryCard / SurveyScoreChart / MemberBreakdown[]
    │   ├── InsightsTab
    │   │   ├── ChartFilterBar
    │   │   ├── DueDateWarning
    │   │   ├── DeviationAlertBanner
    │   │   ├── ProgressChart
    │   │   └── [Manager] AIAnalysisSection
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
| PJ情報 | `GET /projects/{projectId}` | ヘッダースケルトン | リトライ | `project.canManage` で manager-only controls の表示を切り替える |
| Issue一覧 | `GET /projects/{projectId}/issues` | ボードスケルトン | リトライ | カンバン+ガント+担当一覧パネル共有 |
| アラート | `GET /projects/{projectId}/alerts` | リストスケルトン | リトライ | |
| 予実チャート | `GET /projects/{projectId}/progress-chart` | フィルターバー + チャートスケルトン | リトライ | インサイトタブ |
| アンケート結果 | `GET /projects/{projectId}/survey-results` | サマリー + チャート + メンバー内訳スケルトン | リトライ | アンケート結果タブ |

カンバンとガントは同一APIデータ (`GET /projects/{projectId}/issues`) を共有。SWRキー1つで管理。

## UI States
| 状態 | 表現 |
|------|------|
| loading | ボードスケルトン |
| tab-loading | インサイトはフィルターバー + チャート、アンケート結果はサマリー + チャート + メンバー内訳のスケルトンを表示し、空白にしない |
| empty | EmptyState: "Issueがありません" + Issue作成ボタン |
| error | ErrorState + リトライ |
| success | ProgressBoardTab表示 |

## Interactions
- [Manager] ProjectHeader のステータス操作 → プロジェクトステータス変更
- PJステータス変更失敗時は API `message` を優先して Toast 表示
- ViewToggle → ガント/カンバン切替（localStorage記憶）
- Issue作成ボタン → `/projects/[projectId]/issues/new` に遷移
- カンバンDnD → ステータス変更（楽観的更新）
- カンバンDnD が business rule で reject された場合はロールバックし、API `message` を Toast 表示
- IssueCard/GanttRowクリック → `/issues/[issueId]` に遷移
- GroupBySelector → グルーピング切替（ステータス別/アサイン者別/フラット）

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| PJステータス変更 | `PATCH /projects/{projectId}/status` | Toast(success) + 再取得 | Toast(error: API `message` 優先) |
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
- member assignment panel の issue 行は現在、読み取り専用の要約表示であり issue detail へのリンクではない（リンク化は今後の改善候補）
- InsightsTab の loading は filter bar と chart の skeleton を先に描画し、blank area を出さない
- SurveyResultsTab の loading は summary card / chart / member breakdown の skeleton を順に描画する
- SurveyResultsTab の summary card は質問数・回答者数・チーム平均スコアを表示し、チーム平均スコアは `surveyResults.questions[].averageScore` の平均値を小数第2位まで表示する
- SurveyResultsTab の member breakdown 行は各メンバーの平均スコア badge に加えてチーム平均との差分 badge を表示する。差分は `member.answers[].selectedOptionScore` の平均値とチーム平均との差を小数第2位まで表示し、正/負/`0.00` をそのまま出し分ける。有効な scored answer がないメンバーは差分に中立プレースホルダ `--` を表示する
- SurveyScoreChart は 24rem の明示的な高さを持つ container 内で即時描画し、初回表示でも blank chart にならないようにする
