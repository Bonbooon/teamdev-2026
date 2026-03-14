# Page: ダッシュボード

## Purpose
ロール別トップページ。選択チームでのロール（manager/member）に応じてタブ構成が動的に変わる。

## Route
`/`

## Access Control
- 認証: 必要
- ロール: 全員（タブ構成がロールにより変化）

## Layout
AppLayout

## Component Tree
```
DashboardPage
└── AppLayout
    ├── DashboardHeader
    │   ├── TeamSwitcher (複数チーム所属時のみ表示)
    │   │   └── Dropdown (チーム選択)
    │   │      ※ 選択中チームでのロール(manager/member)に応じてタブ構成が変わる
    │   └── Tabs (選択中チームでのロール別タブ)
    │
    │  ── 選択チームで manager の場合 ──
    │
    ├── [Manager] AlertsTab (デフォルト)
    │   ├── AlertSummaryCards (黄/赤カウント)
    │   └── AlertCard[] (該当チーム管轄PJのアラート一覧)
    │
    ├── [Manager] TeamManagementTab
    │   └── TeamSummaryCard (選択中チームのサマリー)
    │       ├── MemberCount (メンバー数)
    │       ├── ProjectCount (PJ数)
    │       ├── ActiveAlertCount (アクティブアラート数)
    │       ├── ConditionOverview (S-05-02: 不調検知)
    │       │   ├── チーム平均スコア
    │       │   └── FlaggedMembers[] (平均より下に乖離しているメンバー — アバター+名前+フラグ)
    │       └── Link (チーム詳細へ → /teams/[teamId])
    │
    ├── [Manager] ProjectProgressTab
    │   └── ProjectSummaryCard[] (選択チームのPJ進捗)
    │
    ├── [Manager] SurveySettingsTab
    │   └── SurveyConfigByTeam
    │       ├── SurveyTemplate (使用テンプレート — 定型質問のみ)
    │       ├── SurveyFrequency (配信頻度: 毎日/毎週/隔週)
    │       ├── SurveyDeliveryTime (配信タイミング: 1日の初め/1日の終わり 等)
    │       ├── SurveyStatus (有効/無効 トグル)
    │       └── Button (設定編集)
    │
    │  ── 選択チームで member の場合 ──
    │
    ├── [Member] MyWorkTab (デフォルト)
    │   └── IssueGroupByProject[]
    │       ├── ProjectHeader
    │       └── IssueRow[] (選択チーム内でアサイン済みIssue)
    │
    ├── [Member] ProjectProgressTab
    │   └── ProjectSummaryCard[] (選択チームのPJ進捗)
    │
    └── [Member] SurveyAnswerTab
        └── PendingSurveyCard[] (選択チームのサーベイ)
```

## Data Requirements

**マネージャー:**

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アラート一覧 | `GET /alerts?status=active` | スケルトンカード | リトライ |
| 管轄チーム | `GET /teams` | スケルトンカード | リトライ |
| PJ進捗サマリー | `GET /projects` | スケルトンカード | リトライ |
| 不調検知 (S-05-02) | `GET /teams/{teamId}/condition-summary` | スケルトンカード | リトライ |

**メンバー:**

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アサイン済みIssue | `GET /issues?assignee=me` | スケルトンリスト | リトライ |
| 所属チーム | `GET /teams` | スケルトンカード | リトライ |
| 未回答サーベイ | `GET /surveys/my/pending` | スケルトンカード | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | カードスケルトン |
| empty | 「プロジェクトがありません」+ 作成ボタン |
| error | リトライボタン |
| success | ロール別タブ表示 |

## Interactions
- TeamSwitcher で別チーム選択 → タブ構成が動的に変更、データ再取得
- 選択チームは `localStorage` で記憶
- 1チームのみ所属 → TeamSwitcherは非表示
- FlaggedMembersのアバター/名前クリック → `/users/[userId]` に遷移

## Mutations
なし（閲覧専用。サーベイ設定編集は SurveySettingsTab 内で処理）

## Notes
- チーム切替のロール判定はチーム単位。チームAでmanager、チームBでmemberの場合、切替でタブ構成が変わる。
- ダッシュボードのManager用AlertsTabとアラート一覧ページ(`/alerts`)は別。ダッシュボードは選択チームに絞ったサマリー表示。
