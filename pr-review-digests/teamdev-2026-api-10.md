# PR Review Digest

## PR Summary
- PR: https://github.com/Bonbooon/teamdev-2026-api/pull/10
- Title: Feat/alert system aggregate
- Author: @Bonbooon
- Branch: feat/alert-system-aggregate → main
- Review decision: 
- Diff stats: +5487 / -2 across 75 files
- Commits: 13

## Copilot PR Summary Review
### Review by @copilot-pull-request-reviewer (COMMENTED, 2026-03-12T17:25:29Z)
## Pull request overview

プロジェクト遅延を検知・通知する「アラートシステム基盤（Phase 1〜7）」を、Laravel の Clean Architecture 構成（Domain / Application / Infrastructure）で追加し、SendGrid 通知と定期実行（1時間ごと）までを含めて実装するPRです。

**Changes:**
- アラート関連のモデル（Alert/AlertLog/ActionPlan/Trigger*）と Issue 関連モデルを追加し、マイグレーション・Factory を整備
- トリガー評価（Project / Issue / Workload）・進捗計算・重複排除/レート制限（実装は一部）・実行ログ記録のサービス/リポジトリを追加
- SendGridメール送信ジョブ + 配信ログ、alerts:process コマンドとスケジューラ登録、テスト（Unit/Integration/Feature）を追加

### Reviewed changes

Copilot reviewed 72 out of 72 changed files in this pull request and generated 11 comments.

<details>
<summary>Show a summary per file</summary>

| File | Description |
| ---- | ----------- |
| web/tests/Unit/Models/IssueTest.php | Issueモデルのリレーション/キャスト/Factory検証を追加 |
| web/tests/Unit/Models/EmailDeliveryLogTest.php | EmailDeliveryLogの作成・ステータス・リレーション検証を追加 |
| web/tests/Unit/Models/AlertTest.php | Alertモデルのリレーション/Enumキャスト検証を追加 |
| web/tests/Unit/Models/AlertLogTest.php | AlertLogのPK/リレーション/キャスト検証を追加 |
| web/tests/Unit/Jobs/SendAlertEmailTest.php | SendGrid送信ジョブのHTTP送信/ログ記録/リトライ設定を検証 |
| web/tests/Unit/Application/Alert/Triggers/WorkloadOverloadTriggerTest.php | Workloadトリガーの判定ロジックをユニットテスト |
| web/tests/Unit/Application/Alert/Triggers/ProjectProgressDelayTriggerTest.php | Project進捗遅延トリガーの判定ロジックをユニットテスト |
| web/tests/Unit/Application/Alert/Triggers/IssueProgressDelayTriggerTest.php | Issue進捗遅延トリガーの判定ロジックをユニットテスト |
| web/tests/Unit/Application/Alert/Services/AlertEmailServiceTest.php | 通知テンプレートデータとメール送信レート制限を検証 |
| web/tests/Unit/Application/Alert/Services/ActionPlanSuggestionServiceTest.php | アクションプラン候補取得のユニットテスト（未完了含む） |
| web/tests/Integration/Infrastructure/Persistence/Eloquent/EloquentTriggerExecutionLogRepositoryTest.php | TriggerExecutionLogリポジトリの永続化・検索を統合テスト |
| web/tests/Integration/Infrastructure/Persistence/Eloquent/EloquentAlertRepositoryTest.php | AlertリポジトリのCRUD/検索/解決を統合テスト |
| web/tests/Integration/Application/Alert/Services/ProgressCalculationServiceTest.php | 進捗/速度/負荷計算の統合テストを追加 |
| web/tests/Integration/Application/Alert/Services/AlertTriggerServiceTest.php | トリガー処理・重複排除・レート制限・ログ作成を統合テスト |
| web/tests/Feature/Console/ProcessAlertsCommandTest.php | alerts:process コマンドのプロジェクト走査・ログ・例外耐性をFeatureテスト |
| web/database/migrations/2026_03_10_000001_create_email_delivery_logs_table.php | 配信ログテーブルとレート制限用インデックス/FKを追加 |
| web/database/factories/TriggerExecutionLogFactory.php | TriggerExecutionLog用Factoryを追加 |
| web/database/factories/TriggerDefinitionFactory.php | TriggerDefinition用Factoryを追加 |
| web/database/factories/TeamFactory.php | Team名の一意性を高め、Factory衝突を回避 |
| web/database/factories/IssueWorkLogFactory.php | IssueWorkLog用Factoryを追加 |
| web/database/factories/IssueTemplateFactory.php | IssueTemplate用Factoryを追加 |
| web/database/factories/IssueFactory.php | Issue用Factory（ステータス/期限/見積などのstate含む）を追加 |
| web/database/factories/IssueAssigneeFactory.php | IssueAssignee用Factoryを追加 |
| web/database/factories/EmailDeliveryLogFactory.php | EmailDeliveryLog用Factory（sent/failed/bounced state）を追加 |
| web/database/factories/AlertLogFactory.php | AlertLog用Factory（resolved state）を追加 |
| web/database/factories/AlertFactory.php | Alert用Factory（resolved/red/yellow state）を追加 |
| web/database/factories/AlertActionPlanSuggestionFactory.php | AlertActionPlanSuggestion用Factoryを追加 |
| web/database/factories/ActionPlanFactory.php | ActionPlan用Factoryを追加 |
| web/config/services.php | SendGrid設定（api_key/from）を追加 |
| web/app/Providers/RepositoryServiceProvider.php | Alert系リポジトリ/サービスのDI登録とAlertTriggerService組み立てを追加 |
| web/app/Models/TriggerExecutionLog.php | TriggerExecutionLogモデル（casts/relations）を追加 |
| web/app/Models/TriggerDefinition.php | TriggerDefinitionモデル（UUID/casts/relations）を追加 |
| web/app/Models/IssueWorkLog.php | IssueWorkLogモデル（UUID/casts/relations）を追加 |
| web/app/Models/IssueTemplate.php | IssueTemplateモデル（UUID/casts）を追加 |
| web/app/Models/IssueAssignee.php | IssueAssignee Pivotモデルを追加 |
| web/app/Models/Issue.php | Issueモデル（UUID/casts/relations）を追加 |
| web/app/Models/EmailDeliveryLog.php | EmailDeliveryLogモデル（UUID/casts/relations）を追加 |
| web/app/Models/AlertLog.php | AlertLogモデル（casts/relations）を追加 |
| web/app/Models/AlertActionPlanSuggestion.php | AlertActionPlanSuggestion Pivotモデルを追加 |
| web/app/Models/Alert.php | Alertモデル（UUID/casts/relations）を追加 |
| web/app/Models/ActionPlan.php | ActionPlanモデル（UUID/relations）を追加 |
| web/app/Jobs/SendAlertEmail.php | SendGrid送信ジョブ + 配信ログ記録を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentTriggerExecutionLogRepository.php | TriggerExecutionLog永続化/検索を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentTriggerDefinitionRepository.php | TriggerDefinition検索を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentProjectRepository.php | in_progress プロジェクト一括取得を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentIssueRepository.php | Issue取得/集計の実装を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentAlertRepository.php | Alert永続化/検索/解決の実装を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentAlertLogRepository.php | AlertLog永続化/検索の実装を追加 |
| web/app/Infrastructure/Persistence/Eloquent/EloquentActionPlanRepository.php | ActionPlan検索/一覧の実装を追加 |
| web/app/Console/Kernel.php | alerts:process の1時間ごとのスケジュール登録 |
| web/app/Console/Commands/ProcessAlertsCommand.php | alerts:process コマンド（全in_progress処理、例外時継続）を追加 |
| web/app/Application/Project/Repositories/ProjectRepositoryInterface.php | findAllInProgress() を追加 |
| web/app/Application/Issue/Repositories/IssueRepositoryInterface.php | IssueRepositoryInterface を追加 |
| web/app/Application/Alert/Triggers/WorkloadOverloadTrigger.php | 作業負荷過多トリガーを追加 |
| web/app/Application/Alert/Triggers/TriggerResult.php | トリガー評価結果DTOを追加 |
| web/app/Application/Alert/Triggers/TriggerEvaluatorInterface.php | トリガー評価インターフェースを追加 |
| web/app/Application/Alert/Triggers/ProjectProgressDelayTrigger.php | プロジェクト進捗遅延トリガーを追加 |
| web/app/Application/Alert/Triggers/IssueProgressDelayTrigger.php | Issue進捗遅延トリガーを追加 |
| web/app/Application/Alert/Services/ProgressCalculationService.php | 進捗/速度/負荷計算サービスを追加 |
| web/app/Application/Alert/Services/AlertTriggerService.php | トリガー統合処理（重複排除/レート制限/ログ）を追加 |
| web/app/Application/Alert/Services/AlertEmailService.php | 通知ジョブdispatch + 配信レート制限を追加 |
| web/app/Application/Alert/Services/ActionPlanSuggestionService.php | トリガー結果に基づく推奨アクション紐付けを追加 |
| web/app/Application/Alert/Repositories/TriggerExecutionLogRepositoryInterface.php | TriggerExecutionLogのリポジトリIFを追加 |
| web/app/Application/Alert/Repositories/TriggerDefinitionRepositoryInterface.php | TriggerDefinitionのリポジトリIFを追加 |
| web/app/Application/Alert/Repositories/AlertRepositoryInterface.php | AlertのリポジトリIFを追加 |
| web/app/Application/Alert/Repositories/AlertLogRepositoryInterface.php | AlertLogのリポジトリIFを追加 |
| web/app/Application/Alert/Repositories/ActionPlanRepositoryInterface.php | ActionPlanのリポジトリIFを追加 |
| web/app/Application/Alert/DTOs/TriggerContext.php | TriggerContext DTOを追加 |
| web/app/Application/Alert/DTOs/CreateAlertInput.php | Alert作成入力DTOを追加 |
| web/app/Application/Alert/DTOs/AlertSummary.php | Alert一覧用DTOを追加 |
| web/app/Application/Alert/DTOs/AlertDetail.php | Alert詳細用DTOを追加 |
| web/app/Application/Alert/DTOs/ActionPlanSuggestion.php | 推奨アクションDTOを追加 |
</details>





> https://github.com/Bonbooon/teamdev-2026-api/pull/10#pullrequestreview-3938415717

### Review by @copilot-pull-request-reviewer (COMMENTED, 2026-03-13T11:33:14Z)
## Pull request overview

Copilot reviewed 75 out of 75 changed files in this pull request and generated 14 comments.




> https://github.com/Bonbooon/teamdev-2026-api/pull/10#pullrequestreview-3943370424


## Fetched Review Comments (Unresolved, Non-Copilot)
No unresolved non-Copilot review comments found.

## Cloud Copilot Review Comments
- @copilot-pull-request-reviewer web/tests/Unit/Application/Alert/Services/ActionPlanSuggestionServiceTest.php:85 — このテストは PHPUnit\Framework\TestCase を継承したまま Mockery を使っていますが、tearDown で Mockery::close()（または MockeryPHPUnitIntegration）が無いので「risky」になりやすいです。また markTestIncomplete() が残っており、テストスイートに incomplete が混ざった状態になります。[q] CI の品質ゲートとして incomplete/risky を許容する運用でしょうか？ 許容しない場合は、Laravel の Tests\TestCase + RefreshDatabase に移して DB を使った統合テストとして完成させるか、ユニットとして完結する形にリファクタしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202912
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:141 — attachActionPlanSuggestions() が app() で ActionPlanSuggestionService を引いており、AlertTriggerService の依存がコンストラクタから見えなくなっています（テスト差し替えもしづらいです）。他の依存と同様に ActionPlanSuggestionService（または Interface）をコンストラクタ注入して、サービスロケータを避けた方が保守性が上がります。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202964
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:80 — TriggerContext の triggerDefinitionId に get_class($evaluator)（クラス名）を入れていますが、trigger_execution_logs.trigger_definition_id は UUID で trigger_definitions.id への外部キー制約があります（migrations で uuid + FK）。このままだと本番環境でトリガー実行ログ作成時に必ず FK 違反になり、アラート処理全体が失敗します。TriggerDefinition を事前に作成し、その UUID（id）を参照する形にしてください（例: evaluator から name を決めて TriggerDefinitionRepository で引いて id を渡すなど）。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202981
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/WorkloadOverloadTrigger.php:41 — suggestedActionCodes が 'reassign-vacation' 等の小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlanRepository::findByCodes() で ActionPlan.code と完全一致検索します。テストでは 'ACT_REVIEW_TIMELINE' のようなコードが使われており、このままだと本トリガー経由ではアクションプランが一切紐付かない可能性が高いです。ActionPlan.code の命名規則に合わせたコード体系（定数/Enum 化含む）へ揃えてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203024
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/ProjectProgressDelayTrigger.php:46 — suggestedActionCodes が 'scope-reduction' 等の小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlan.code との完全一致で引き当てます。現状のテスト/実装だと 'ACT_...' 系コードが前提になっているため、このトリガーからのサジェストが空になり得ます。ActionPlan.code と同一のコード体系に統一してください（[q] ActionPlan のコード規約は 'ACT_...' で確定でしょうか？）。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203049
- @copilot-pull-request-reviewer web/app/Jobs/SendAlertEmail.php:142 — HTML メール本文を組み立てる際に、projectName / alertDescription をそのまま HTML に埋め込んでいます。プロジェクト名やアラート説明に HTML 断片が入ると、メールクライアントによっては意図しない表示・リンク化や HTML インジェクションが起き得ます。少なくとも htmlspecialchars 等でエスケープするか、テンプレート（Blade/Mailables）側で安全にレンダリングするようにしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203065
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/ProgressCalculationService.php:177 — calculateProjectVelocity() が findByProjectId() でプロジェクト配下 Issue を全件ロードしてから PHP 側で filter しています。alerts:process が全 in_progress プロジェクトに対して定期実行される前提だと、Issue 数が増えた時にメモリ/DB 負荷が跳ねやすいです。閉塞件数（直近14日）・総数などはクエリ集計（whereNotNull/whereBetween + count など）で DB 側に寄せる形にするとスケールしやすくなります。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203086
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/ProjectProgressDelayTrigger.php:68 — YELLOW 側の suggestedActionCodes も小文字ハイフン形式で、ActionPlan.code（完全一致検索）と噛み合わない可能性が高いです。少なくとも同一サービス内で 'ACT_...' とハイフン形式が混在するとサジェストが機能しないので、コード体系を統一してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203105
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/IssueProgressDelayTrigger.php:37 — suggestedActionCodes が小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlan.code と完全一致で検索します。テスト（ActionPlanSuggestionServiceTest）では 'ACT_...' 系が使われており、このままだと IssueProgressDelayTrigger の推奨アクションが紐付かない可能性が高いです。ActionPlan.code と同一のコード体系に統一してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203134
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:76 — `triggerDefinitionId` が解決できない場合に `'test-trigger-id'` を入れて評価を継続していますが、本番でここに到達すると FK 不整合や「定義が無いトリガー」を評価してしまう原因になります。`null` のまま扱う（評価をスキップ/例外）など、環境依存のプレースホルダを本番ロジックに残さない形にしてください。  — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635632
- @copilot-pull-request-reviewer web/database/seeders/TriggerDefinitionSeeder.php:65 — `$this->command` はシーダの実行コンテキストによって `null` の可能性があるため、`$this->command?->info(...)` など null-safe にしておくと安全です。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635650
- @copilot-pull-request-reviewer web/database/migrations/2026_03_13_105421_add_trigger_class_to_trigger_definitions.php:5 — マイグレーションファイルに `declare(strict_types=1);` がありません。本リポジトリでは他の新規PHPファイルで strict_types を宣言しているため、このファイルも追加してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635663
- @copilot-pull-request-reviewer web/tests/Unit/Models/EmailDeliveryLogTest.php:67 — `sendgrid_response` は Model で `json` cast されるため、取得時は配列になります。このテストでは `json_encode(...)`（文字列）を入れて `assertEquals` しているので失敗します。テストデータは配列で渡すか、期待値側も cast 後の型に合わせてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635682
- @copilot-pull-request-reviewer web/app/Jobs/SendAlertEmail.php:58 — `handle()` の catch で `logFailure()` して再throwしているため、キュー実行時は最終的に `failed()` も呼ばれて失敗ログが二重に作成されます（試行回数分+永久失敗時の追加）。失敗ログは `failed()` のみに寄せるか、`handle()` 側は既存ログの更新にするなど、重複しない設計にしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635693
- @copilot-pull-request-reviewer web/tests/Unit/Application/Alert/Services/ActionPlanSuggestionServiceTest.php:85 — このテストは `markTestIncomplete()` により常に incomplete となり、CI結果に「incomplete tests」を残します。Feature/Integration に移す前提でも、現PRではテストを実装するか、少なくとも未完了テストとしてコミットしない（別PRに分離する）対応をお願いします。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635712
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:80 — `TriggerContext` を全 evaluator に対して `targetType: 'project'`・`targetEntityId: $project->id` で固定しているため、`IssueProgressDelayTrigger`（issueId 前提）や `WorkloadOverloadTrigger`（teamMemberId 前提）が誤ったIDで評価されます。各 Trigger の `TriggerTargetType` に応じて評価対象（プロジェクト配下の Issue / メンバーなど）を列挙して context を作るか、プロジェクト用 evaluator のみに絞って実行するようにしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635723
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/ProgressCalculationService.php:116 — `daysRemaining` を `max(0, ...)` で丸めているため、期限超過時でも `daysRemaining` が 0 になり、`IssueProgressDelayTrigger` 側の `daysOverdue` が常に 0 になります。期限超過を表現したいなら符号付き日数（例: `diffInDays(..., false)`）を返すか、別キーで `daysOverdue` を算出して返すようにしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635734
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/ProgressCalculationService.php:188 — `calculateProjectVelocity()` がプロジェクトの全 Issue を取得して PHP 側でフィルタ・集計しており、Issue 数が多いとメモリ/実行時間が比例して増えます。クローズ数・総数・残数などはDB集計（count/sum + where closed_at >= cutoff 等）で取得する形に寄せると、スケジューラ実行時の負荷が安定します。  — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635751
- @copilot-pull-request-reviewer web/database/seeders/TriggerDefinitionSeeder.php:31 — `condition_params` は Model 側で `array` cast しているので、ここで `json_encode(...)` すると二重エンコードや型不整合の原因になります。`condition_params` は配列のまま渡してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635765
- @copilot-pull-request-reviewer web/database/seeders/TriggerDefinitionSeeder.php:61 — `TriggerDefinition::updateOrCreate(..., $trigger)` に `id` / `trigger_class` / `description` を含めていますが、`TriggerDefinition` の `$fillable` に存在しないため MassAssignmentException でシーダが落ちます（少なくともテストで `$this->seed()` している箇所に影響）。Model の `$fillable` を更新し、さらに `id` は更新対象から外す（既存レコードの PK を変更しない）形に修正してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635783
- @copilot-pull-request-reviewer web/app/Models/TriggerDefinition.php:44 — `TriggerDefinitionSeeder` で使用している `trigger_class` / `description` が `$fillable` に含まれていないため、create/updateOrCreate で代入できません。今回追加したカラムを `$fillable`（必要なら `$casts`）に追加してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635805
- @copilot-pull-request-reviewer web/app/Console/Commands/ProcessAlertsCommand.php:59 — 外側の catch でも `Command::SUCCESS` を返してしまうため、スケジューラ/監視からは失敗を検知できません。意図的に常に 0 を返す設計かどうか [q] 確認したいです。失敗を検知したい場合は `Command::FAILURE` を返しつつ、プロジェクト単位の例外は現状通り握りつぶす形が扱いやすいです。  — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635823
- @copilot-pull-request-reviewer web/app/Console/Kernel.php:17 — スケジュール実行が1時間を超えた場合に次回起動と重なって二重実行される可能性があります。運用上の事故を避けるため、`withoutOverlapping()`（必要なら `onOneServer()`）の付与を検討してください。  — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2930635835

## Code-change Required Review Comments
No unresolved inline comments tied to CHANGES_REQUESTED reviews.
