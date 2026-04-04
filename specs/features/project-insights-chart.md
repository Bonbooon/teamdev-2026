# Spec: Project Insights — 予実チャート (Phase A)

**Version:** 1.0
**Last Updated:** 2026/04/01
**Parent Spec:** `specs/business/visualization.md`
**Related Spec:** `specs/features/project-insights-ai-analysis.md` (Phase B)

---

## 概要

プロジェクト詳細ページに新タブ「インサイト」を追加し、ストーリーポイントの予実乖離を可視化する複合チャート（棒グラフ＋折れ線グラフ）を実装する。PMが予定と実績の乖離を一目で把握し、遅延の早期検知を可能にする。

---

## User Stories

1. **PMとして**、プロジェクトの予定ストーリーポイントと実績ストーリーポイントの推移を時系列チャートで確認したい。遅延がどの程度かを視覚的に把握するため。
2. **PMとして**、PJ全体 / チーム / メンバー単位でチャートのスコープを切り替えたい。どのチーム・メンバーが遅れているかを特定するため。
3. **PMとして**、時間軸を週次 / 月次で切り替えたい。プロジェクト期間に応じた粒度で確認するため。
4. **チームメンバーとして**、自分やチームの予実推移を確認し、進捗を把握したい。

---

## UI 配置

- **ページ:** `/projects/{projectId}` (ProjectDetailPage)
- **タブ:** 「インサイト」
- **タブ順序:** 進捗ボード → アラート → アンケート結果 → メンバー貢献 → **インサイト** → 設定
- **タブ内構成:**
  1. フィルターバー（スコープ選択＋時間単位切り替え）
  2. 複合チャート（棒 + 折れ線）
  3. `due_at` 未設定時の注意バナー（チャート非表示）
  4. *(Phase B で追加)* AI 分析ボタン＋レスポンス表示エリア

---

## フィルターバー仕様

### スコープ選択（2段階ドロップダウン）

**第1ドロップダウン: スコープ種別**
| 値 | ラベル |
|---|---|
| `project` | プロジェクト全体 |
| `team` | チーム |
| `member` | メンバー |

**デフォルト:** `project`

**第2ドロップダウン: 対象選択**
- `project` 選択時: 非表示（プロジェクト全体なので対象不要）
- `team` 選択時: PJ に紐づくチーム一覧を表示。選択チームで絞り込み
- `member` 選択時: 上記で選択中のチームのメンバー一覧を表示。チーム未選択時は PJ 全体のメンバーから選択

**動作:**
- スコープ種別変更 → 対象選択リセット → チャート再描画
- 対象選択変更 → チャート再描画

### 時間単位切り替え

| 値 | ラベル |
|---|---|
| `weekly` | 週次 |
| `monthly` | 月次 |

**デフォルト:** プロジェクト期間 ≤ 12週 → `weekly`、> 12週 → `monthly`
**ユーザーが手動で切り替え可能**

---

## チャート仕様

### チャートタイプ
棒グラフ（累計予定pt）＋折れ線グラフ（累計実績pt）の複合チャート

### 軸
- **X 軸:** 日付。プロジェクト `created_at` ～ `due_at` の範囲。時間単位に応じて週の開始日 or 月の開始日をティック
- **Y 軸:** ストーリーポイント（累計）

### データ系列

#### 棒グラフ: 予定累計ストーリーポイント（Planned）
- 各期間のティック時点で「累計で何ポイント完了しているべきか」を示す
- **計算方法: 線形分配**
  - PJ 全体の対象 Issue（SP が null でないもの）の `deadline` と `story_points` から計算
  - 各 Issue の `story_points` を、その Issue の `deadline` が属する期間バケットに割り当て
  - 累計値として表示
  - `deadline` が null の Issue は除外
- **スコープ別:**
  - `project`: PJ 全体の全 Issue
  - `team`: 選択チームのメンバーにアサインされた Issue
  - `member`: 選択メンバーにアサインされた Issue

#### 折れ線グラフ: 実績累計ストーリーポイント（Actual）
- 各期間のティック時点で「実際に累計で何ポイント完了しているか」を示す
- **計算方法:**
  - `status = 'done'` かつ `closed_at` が当該期間以前の Issue の `story_points` を合算
- **スコープ別:** 予定と同じフィルタリング

### チャートライブラリ
指定なし（Recharts を推奨。既に `package.json` に追加済み）

### `due_at` 未設定時の動作
- チャート非表示
- 黄色の注意バナー表示: 「プロジェクトの期限 (due_at) が設定されていません。チャートを表示するにはプロジェクト設定で期限を設定してください。」

---

## API エンドポイント

### `GET /api/projects/{projectId}/progress-chart`

予実チャートに必要なデータを返す。

**認可:**
- `auth:sanctum` 必須
- PJ に紐づくチームのメンバーであること（既存の PJ アクセス権チェックと同等）
- 未認証: `401`、非メンバー: `403`、PJ 不存在: `404`

**クエリパラメータ:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `scope` | `string` | No | `project` | `project` / `team` / `member` |
| `target_id` | `uuid` | Conditional | — | `scope=team` 時は `teamId`、`scope=member` 時は `teamMemberId`。`scope=project` 時は不要 |
| `interval` | `string` | No | `weekly` | `weekly` / `monthly` |

**レスポンス (200 OK):**

```json
{
  "chart": {
    "projectId": "uuid",
    "scope": "project",
    "targetId": null,
    "interval": "weekly",
    "startDate": "2026-01-05",
    "endDate": "2026-04-05",
    "buckets": [
      {
        "date": "2026-01-05",
        "plannedCumulative": 15,
        "actualCumulative": 12
      },
      {
        "date": "2026-01-12",
        "plannedCumulative": 30,
        "actualCumulative": 28
      },
      {
        "date": "2026-01-19",
        "plannedCumulative": 45,
        "actualCumulative": 40
      }
    ],
    "totalPlannedPoints": 100,
    "totalActualPoints": 75,
    "deviationPercent": 25.0
  }
}
```

**レスポンスフィールド:**

| Field | Type | Description |
|-------|------|-------------|
| `projectId` | `uuid` | プロジェクトID |
| `scope` | `string` | 適用スコープ |
| `targetId` | `uuid?` | スコープ対象のID（project時はnull） |
| `interval` | `string` | 時間間隔 |
| `startDate` | `date` | チャート開始日（プロジェクト created_at） |
| `endDate` | `date` | チャート終了日（プロジェクト due_at） |
| `buckets` | `array` | 各時間バケットのデータ |
| `buckets[].date` | `date` | バケット開始日 |
| `buckets[].plannedCumulative` | `int` | 予定累計ストーリーポイント |
| `buckets[].actualCumulative` | `int` | 実績累計ストーリーポイント |
| `totalPlannedPoints` | `int` | 予定合計SP（deadline付きIssuのSP合計） |
| `totalActualPoints` | `int` | 実績合計SP（完了IssueのSP合計） |
| `deviationPercent` | `float` | 現時点の乖離率。`evaluationAt` は、評価日当日の終了時刻（サーバーのタイムゾーンにおける 23:59:59.999…）と `project.due_at` の早い方を使用する。`deadline` / `closed_at` が `evaluationAt` 以下（`<= evaluationAt`）のものを集計対象に含め、同時点の cumulative を用いて `(planned - actual) / planned * 100` で算出する。`planned = 0` の場合は `0`。負の値は `0` にクランプされる |

**エラーレスポンス:**

| Status | 条件 |
|--------|------|
| `400` | `scope=team/member` で `target_id` 未指定 / 無効な interval |
| `401` | 未認証 |
| `403` | PJ のチームメンバーでない |
| `404` | PJ が存在しない / `due_at` が null（`{ "message": "Project has no due date", "code": "NO_DUE_DATE" }`） |

---

## 予実乖離アラートトリガー

### 新規 TriggerDefinition

既存の `trigger_definitions` テーブルに新しいレコードを作成（シーダーまたはマイグレーションで）。

| Field | Value |
|-------|-------|
| `name` | `予実乖離アラート` |
| `trigger_class` | `App\Application\Alert\Triggers\PlanVsActualDeviationTrigger` |
| `description` | `予定と実績のストーリーポイント乖離が閾値を超えた場合にアラートを発火` |
| `target_type` | `project` |
| `condition_type` | `threshold` |
| `condition_value` | `25` |
| `condition_params` | `{"direction": "below_plan_only"}` |
| `alert_level` | `yellow` |
| `is_active` | `true` |

### トリガーロジック: `PlanVsActualDeviationTrigger`

```
planned = 現時点のバケットまでの累計予定SP
actual  = 現時点までの累計実績SP

IF planned > 0 AND (planned - actual) / planned >= 0.25:
    → Yellow Alert 発火
```

- **方向:** 実績が計画を下回る方向のみ（`actual < planned`）
- **閾値:** 固定 25%（`condition_value` から取得）
- **発火タイミング:**
  1. **定期チェック:** 既存の `alerts:process` コマンド（毎日1回、cron 実行）に追加
  2. **リアルタイム:** ページ表示時に API レスポンスの `deviationPercent` をフロントで判定し、バナー表示

### UI 通知

- プロジェクト詳細ページ内の**インサイトタブにアラートバナー**表示
- 既存の `Alert` モデルに統合（`category` として新規値 `plan_vs_actual_deviation` を追加）
- アラートタブにも表示される（既存動作と同様）

### AlertCategory 追加

`App\Domain\Alert\ValueObjects\AlertCategory` enum に追加:
```
plan_vs_actual_deviation - 予実乖離
```

### ActionPlan（提案アクション）

| Code | Title | Description |
|------|-------|-------------|
| `review-estimates` | 見積もりの再確認 | Issue の見積もりポイントと実績を比較し、過小見積もりのパターンがないか確認してください |
| `reprioritize-backlog` | バックログの優先順位見直し | 残りの Issue の優先順位を見直し、期限内に完了すべきものにフォーカスしてください |
| `check-blocked-issues` | ブロックされた Issue の確認 | 進捗のない Issue がブロックされていないか確認し、ブロッカーの解消を優先してください |

---

## バケット計算ロジック（サーバーサイド）

### 入力
- プロジェクトの `created_at`, `due_at`
- `interval`: `weekly` or `monthly`
- `scope` + `target_id` によるフィルタリング

### ステップ

1. **バケット生成:**
   - `weekly`: `created_at` の週初め（月曜日）から `due_at` の週末まで、7日刻み
   - `monthly`: `created_at` の月初から `due_at` の月末まで、月刻み

2. **対象 Issue フィルタリング:**
   - `story_points IS NOT NULL`
   - スコープに応じたフィルタ:
     - `project`: プロジェクトの全 Issue
     - `team`: `issue_assignees` → `team_members` で選択チーム所属のメンバーにアサインされた Issue
     - `member`: `issue_assignees` で選択メンバーにアサインされた Issue

3. **Planned 計算（各バケット）:**
   - 当該バケットの終了日以前に `deadline` がある Issue の `story_points` を累計
   - 例: バケット `2026-01-12` では、`deadline <= 2026-01-18`（週末）の Issue の SP 合計

4. **Actual 計算（各バケット）:**
   - `status = 'done'` かつ `closed_at` が当該バケットの終了日以前の Issue の `story_points` を累計
   - 例: バケット `2026-01-12` では、`closed_at <= 2026-01-18` の完了 Issue の SP 合計

5. **乖離率計算（End-of-Day Semantics）:**
   - 評価時刻: `evaluationAt = min(サーバーTZにおける当日の end-of-day, project.due_at)` とする（`end-of-day` は当日 `23:59:59.999` を指す）
   - 計画累計: 評価時刻までに `deadline <= evaluationAt` となるIssueのSP累計
   - 実績累計: 評価時刻までに `closed_at <= evaluationAt` となる完了IssueのSP累計
   - `deviationPercent = (plan - actual) / plan * 100`
   - 計画が0の場合は0
   - 負の値は `0` にクランプされる
   - **注意:** この `deviationPercent` は progress-chart 表示用の EOD 累計指標である。予実乖離アラートトリガーは独自のバケット基準で評価するため、本指標と一致しないことがある

---

## フロントエンド実装

### 新規ファイル

| File | Description |
|------|-------------|
| `src/features/projects/components/InsightsTab.tsx` | インサイトタブのメインコンポーネント |
| `src/features/projects/components/ProgressChart.tsx` | Recharts を使った複合チャート |
| `src/features/projects/components/ChartFilterBar.tsx` | スコープ・時間単位の選択UI |
| `src/features/projects/hooks/useProgressChart.ts` | SWR フック: `GET /api/projects/{projectId}/progress-chart` |

### 変更ファイル

| File | Change |
|------|--------|
| `src/features/projects/components/ProjectDetailPage.tsx` | `TabKey` に `"insights"` 追加、タブ設定にインサイトタブ追加 |

### InsightsTab 構造

```
InsightsTab
├── ChartFilterBar（スコープ・時間単位）
├── due_at 未設定バナー（条件付き）
├── 乖離アラートバナー（deviationPercent >= 25 の場合）
├── ProgressChart（チャート本体）
└── (Phase B) AI分析セクション
```

### ChartFilterBar Props

| Prop | Type | Description |
|------|------|-------------|
| `scope` | `"project" \| "team" \| "member"` | 現在のスコープ |
| `targetId` | `string \| null` | 選択対象ID |
| `interval` | `"weekly" \| "monthly"` | 時間単位 |
| `teams` | `Array<{id, name}>` | PJ 紐づきチーム一覧 |
| `members` | `Array<{id, name}>` | 選択チームのメンバー一覧 |
| `onScopeChange` | `(scope, targetId?) => void` | スコープ変更コールバック |
| `onIntervalChange` | `(interval) => void` | 時間単位変更コールバック |

### ProgressChart Props

| Prop | Type | Description |
|------|------|-------------|
| `buckets` | `Array<{date, plannedCumulative, actualCumulative}>` | チャートデータ |
| `interval` | `"weekly" \| "monthly"` | X軸のフォーマット用 |

### 状態管理
- **Loading:** Skeleton (チャートエリアにプレースホルダー)
- **Empty:** EmptyState — 「ストーリーポイントが設定された Issue がありません」
- **エラー:** ErrorState with retry

---

## バックエンド実装

### 新規ファイル

| File | Description |
|------|-------------|
| `app/Interfaces/Http/Controllers/Project/ProgressChartController.php` | エンドポイントコントローラー |
| `app/Application/Project/UseCases/GetProgressChartUseCase.php` | チャートデータ計算ユースケース |
| `app/Application/Project/DTOs/ProgressChartData.php` | レスポンスDTO |
| `app/Application/Alert/Triggers/PlanVsActualDeviationTrigger.php` | 予実乖離トリガー |
| `tests/Feature/Interfaces/Http/Project/ProgressChartControllerTest.php` | API テスト |
| `tests/Unit/Application/Alert/Triggers/PlanVsActualDeviationTriggerTest.php` | トリガーテスト |
| `tests/Unit/Application/Project/UseCases/GetProgressChartUseCaseTest.php` | ユースケーステスト |

### 変更ファイル

| File | Change |
|------|--------|
| `routes/api.php` | 新ルート追加 |
| `app/Domain/Alert/ValueObjects/AlertCategory.php` | `plan_vs_actual_deviation` 追加 |
| `database/seeders/` | TriggerDefinition & ActionPlan シーダー |
| `app/Application/Alert/Services/AlertTriggerService.php` | 新トリガー登録（自動検出なら不要） |

### ルート追加

```
GET /api/projects/{projectId}/progress-chart → ProgressChartController@index
```

---

## テストケース

### API テスト (ProgressChartControllerTest)

| TestCase | Description |
|----------|-------------|
| `test_returns_weekly_chart_for_project_scope` | PJ 全体の週次チャートデータを正しく返す |
| `test_returns_monthly_chart_for_project_scope` | PJ 全体の月次チャートデータを正しく返す |
| `test_returns_chart_for_team_scope` | チームスコープで正しくフィルタリングされたデータを返す |
| `test_returns_chart_for_member_scope` | メンバースコープで正しくフィルタリングされたデータを返す |
| `test_returns_404_when_project_has_no_due_date` | `due_at` null の場合 404 + `NO_DUE_DATE` コード |
| `test_returns_404_when_project_not_found` | 存在しない PJ で 404 |
| `test_returns_403_for_non_member` | PJ 非メンバーで 403 |
| `test_returns_401_for_unauthenticated` | 未認証で 401 |
| `test_returns_400_for_team_scope_without_target_id` | `scope=team` で `target_id` 未指定 |
| `test_returns_400_for_invalid_interval` | 無効な interval パラメータ |
| `test_excludes_issues_without_story_points_from_planned` | SP null の Issue が予定から除外される |
| `test_deviation_percent_calculated_correctly` | 乖離率の計算が正しい |
| `test_buckets_are_cumulative` | バケットが累計値になっている |

### トリガーテスト (PlanVsActualDeviationTriggerTest)

| TestCase | Description |
|----------|-------------|
| `test_triggers_yellow_when_deviation_at_25_percent` | 25%乖離で Yellow 発火 |
| `test_triggers_yellow_when_deviation_above_25_percent` | 25%超で Yellow 発火 |
| `test_no_trigger_when_deviation_below_25_percent` | 25%未満で発火しない |
| `test_no_trigger_when_actual_exceeds_planned` | 実績が計画を上回る場合は発火しない |
| `test_no_trigger_when_planned_is_zero` | 予定が0の場合は発火しない |
| `test_returns_correct_category` | カテゴリが `plan_vs_actual_deviation` |

### フロントエンドテスト

| TestCase | Description |
|----------|-------------|
| `test_insights_tab_renders_chart` | チャートが表示される |
| `test_scope_dropdown_changes_chart` | スコープ変更でチャート再描画 |
| `test_interval_toggle_changes_chart` | 時間単位変更でチャート再描画 |
| `test_no_due_date_shows_warning_banner` | `due_at` 未設定で注意バナー表示 |
| `test_deviation_alert_banner_displayed_when_threshold_exceeded` | 乖離 ≥ 25% でアラートバナー表示 |

---

## OpenAPI アノテーション

コントローラーに `#[OA\Get]`, `#[OA\Parameter]`, `#[OA\Response]` を追加し、`mise codegen-openapi` でフロント型を自動生成する。

---

## マイグレーション

新テーブルの追加は不要。既存テーブルの利用:
- `issues` (story_points, deadline, closed_at, status)
- `issue_assignees` (issue_id, team_member_id)
- `team_members` (team_id)
- `projects` (created_at, due_at)
- `alerts` (新カテゴリ追加のみ)

`AlertCategory` enum への値追加のみ（PHP コード変更のみ、DB マイグレーション不要）。

---

## 実装順序（推奨フェーズ分割）

### Phase 1: API — チャートデータエンドポイント
- `GetProgressChartUseCase` + `ProgressChartData` DTO
- `ProgressChartController` + ルート追加 + OpenAPI
- API テスト

### Phase 2: API — 予実乖離トリガー
- `AlertCategory` に `plan_vs_actual_deviation` 追加
- `PlanVsActualDeviationTrigger` 実装
- TriggerDefinition シーダー + ActionPlan シーダー
- トリガーテスト

### Phase 3: Frontend — インサイトタブ + チャート
- `ProjectDetailPage.tsx` にタブ追加
- `InsightsTab`, `ChartFilterBar`, `ProgressChart` コンポーネント
- `useProgressChart` SWR フック
- フロントテスト

### Phase 4: Frontend — アラートバナー + 注意表示
- `due_at` 未設定時の注意バナー
- 乖離 ≥ 25% 時のアラートバナー
- テスト

---

## 依存関係

- **Recharts:** `teamdev-2026-front/package.json` に追加済み
- **既存の `ProgressCalculationService`:** チャート計算は新 UseCase に集約（既存サービスとの重複を避けるため独立）
- **既存の `AlertTriggerService`:** 新トリガーの登録
- **OpenAPI codegen:** API 追加後に `mise codegen-openapi` が必要
