# PR Review Digest

## PR Summary
- PR: https://github.com/Bonbooon/teamdev-2026-api/pull/10
- Title: Feat/alert system aggregate
- Author: @Bonbooon
- Branch: feat/alert-system-aggregate → main
- Review decision: 
- Diff stats: +5337 / -2 across 72 files
- Commits: 8

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


## Fetched Review Comments (Unresolved, Non-Copilot)
No unresolved non-Copilot review comments found.

## Cloud Copilot Review Comments
- @copilot-pull-request-reviewer web/tests/Unit/Application/Alert/Services/ActionPlanSuggestionServiceTest.php:85 — このテストは PHPUnit\Framework\TestCase を継承したまま Mockery を使っていますが、tearDown で Mockery::close()（または MockeryPHPUnitIntegration）が無いので「risky」になりやすいです。また markTestIncomplete() が残っており、テストスイートに incomplete が混ざった状態になります。[q] CI の品質ゲートとして incomplete/risky を許容する運用でしょうか？ 許容しない場合は、Laravel の Tests\TestCase + RefreshDatabase に移して DB を使った統合テストとして完成させるか、ユニットとして完結する形にリファクタしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202912
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:137 — attachActionPlanSuggestions() が app() で ActionPlanSuggestionService を引いており、AlertTriggerService の依存がコンストラクタから見えなくなっています（テスト差し替えもしづらいです）。他の依存と同様に ActionPlanSuggestionService（または Interface）をコンストラクタ注入して、サービスロケータを避けた方が保守性が上がります。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202964
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:74 — TriggerContext の triggerDefinitionId に get_class($evaluator)（クラス名）を入れていますが、trigger_execution_logs.trigger_definition_id は UUID で trigger_definitions.id への外部キー制約があります（migrations で uuid + FK）。このままだと本番環境でトリガー実行ログ作成時に必ず FK 違反になり、アラート処理全体が失敗します。TriggerDefinition を事前に作成し、その UUID（id）を参照する形にしてください（例: evaluator から name を決めて TriggerDefinitionRepository で引いて id を渡すなど）。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926202981
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/AlertTriggerService.php:190 — TriggerExecutionLogRepository に渡している triggerDefinitionId が get_class($evaluator) のままになっており、trigger_execution_logs.trigger_definition_id（uuid, FK）と型・値が一致しません。try/catch は testing 環境しか握りつぶさないため、本番では例外が再スローされて alerts:process が落ち続けるはずです。TriggerDefinition の UUID を解決して渡す（または TriggerExecutionLog 側のスキーマ/設計をクラス名保存に合わせて変更する）形に揃えてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203000
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/WorkloadOverloadTrigger.php:41 — suggestedActionCodes が 'reassign-vacation' 等の小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlanRepository::findByCodes() で ActionPlan.code と完全一致検索します。テストでは 'ACT_REVIEW_TIMELINE' のようなコードが使われており、このままだと本トリガー経由ではアクションプランが一切紐付かない可能性が高いです。ActionPlan.code の命名規則に合わせたコード体系（定数/Enum 化含む）へ揃えてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203024
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/ProjectProgressDelayTrigger.php:46 — suggestedActionCodes が 'scope-reduction' 等の小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlan.code との完全一致で引き当てます。現状のテスト/実装だと 'ACT_...' 系コードが前提になっているため、このトリガーからのサジェストが空になり得ます。ActionPlan.code と同一のコード体系に統一してください（[q] ActionPlan のコード規約は 'ACT_...' で確定でしょうか？）。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203049
- @copilot-pull-request-reviewer web/app/Jobs/SendAlertEmail.php:137 — HTML メール本文を組み立てる際に、projectName / alertDescription をそのまま HTML に埋め込んでいます。プロジェクト名やアラート説明に HTML 断片が入ると、メールクライアントによっては意図しない表示・リンク化や HTML インジェクションが起き得ます。少なくとも htmlspecialchars 等でエスケープするか、テンプレート（Blade/Mailables）側で安全にレンダリングするようにしてください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203065
- @copilot-pull-request-reviewer web/app/Application/Alert/Services/ProgressCalculationService.php:177 — calculateProjectVelocity() が findByProjectId() でプロジェクト配下 Issue を全件ロードしてから PHP 側で filter しています。alerts:process が全 in_progress プロジェクトに対して定期実行される前提だと、Issue 数が増えた時にメモリ/DB 負荷が跳ねやすいです。閉塞件数（直近14日）・総数などはクエリ集計（whereNotNull/whereBetween + count など）で DB 側に寄せる形にするとスケールしやすくなります。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203086
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/ProjectProgressDelayTrigger.php:68 — YELLOW 側の suggestedActionCodes も小文字ハイフン形式で、ActionPlan.code（完全一致検索）と噛み合わない可能性が高いです。少なくとも同一サービス内で 'ACT_...' とハイフン形式が混在するとサジェストが機能しないので、コード体系を統一してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203105
- @copilot-pull-request-reviewer web/app/Application/Alert/Triggers/IssueProgressDelayTrigger.php:37 — suggestedActionCodes が小文字ハイフン形式ですが、ActionPlanSuggestionService は ActionPlan.code と完全一致で検索します。テスト（ActionPlanSuggestionServiceTest）では 'ACT_...' 系が使われており、このままだと IssueProgressDelayTrigger の推奨アクションが紐付かない可能性が高いです。ActionPlan.code と同一のコード体系に統一してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203134
- @copilot-pull-request-reviewer web/app/Jobs/SendAlertEmail.php:83 — SendGrid 設定値の存在チェックが `=== ''` だけだと、config() が null を返した場合に検知できません（null のまま Http::withToken() に渡る）。env 未設定時に想定外の型で例外になったり、誤ったリクエストが飛ぶ可能性があります。`empty()` 等で null/空文字を両方弾く、もしくは `(string)` キャストした上で厳密に検証してください。 — https://github.com/Bonbooon/teamdev-2026-api/pull/10#discussion_r2926203156

## Code-change Required Review Comments
No unresolved inline comments tied to CHANGES_REQUESTED reviews.
