## 説明

プロジェクトの遅延を防止するため、アラートシステムの基盤（Phase 1-7）を実装しました。

プロダクトの4本柱の1つである「**遅延の防止**」を実現するため、プロジェクトやタスクの進捗状況をリアルタイムで監視し、遅延リスクを自動検知してPMにアラート通知を送信するシステムです。

**実装範囲（Phase 1-7）:**
- ✅ Phase 1: ドメインモデル（Alert, AlertLog, ActionPlan等）
- ✅ Phase 2: リポジトリ & DTO層
- ✅ Phase 3: Issue リポジトリ & 進捗計算サービス
- ✅ Phase 4: トリガー評価ロジック（3つのMUSTカテゴリ）
- ✅ Phase 5: AlertTriggerService（重複排除・レート制限）
- ✅ Phase 6: SendGrid メール通知統合
- ✅ Phase 7: スケジューラコマンド（1時間毎に実行）

**未実装（Phase 8-9）:**
- Phase 8: REST API エンドポイント（アラート一覧・詳細・解決）
- Phase 9: ドキュメント同期

## 変更内容

### 1. ドメインモデル（Phase 1）
- **Alert**: アグリゲートルート、プロジェクトに紐づく
- **AlertLog**: アラート発火履歴のイベントソーシング
- **ActionPlan**: アラート毎の推奨アクション（分解、リソース追加等）
- **AlertActionPlanSuggestion**: アラートとアクションプランの関連
- **Issue**: タスク管理用モデル（進捗計算の基礎データ）

**関連ファイル:**
- `app/Models/Alert.php`
- `app/Models/AlertLog.php`
- `app/Models/ActionPlan.php`
- `app/Models/AlertActionPlanSuggestion.php`
- `app/Models/Issue.php` + `IssueAssignee.php`, `IssueWorkLog.php`
- `app/Models/TriggerDefinition.php`, `TriggerExecutionLog.php`

### 2. リポジトリ層（Phase 2-3）
- **AlertRepository**: アラートのCRUD、検索、重複排除
- **IssueRepository**: タスク取得、進捗計算用データ取得
- **ProgressCalculationService**: プロジェクト・Issueの進捗率計算

**関連ファイル:**
- `app/Application/Alert/Repositories/AlertRepositoryInterface.php`
- `app/Infrastructure/Persistence/Alert/EloquentAlertRepository.php`
- `app/Application/Alert/Services/ProgressCalculationService.php`

### 3. トリガー評価ロジック（Phase 4）
**3つのMUSTカテゴリのトリガー実装:**

#### a) プロジェクト進捗遅延アラート
- **Yellow**: 進捗率 < 期待進捗率 - 10%
- **Red**: 進捗率 < 期待進捗率 - 20% OR 納期まで7日以内で未達成

#### b) Issueタスク進捗遅延アラート  
- **Yellow**: ステータスが3日間 `in_progress` で進捗なし
- **Red**: 納期超過 + 未完了

#### c) 作業負荷過多アラート
- **Yellow**: 作業時間が週40時間を超過
- **Red**: 作業時間が週60時間を超過

**関連ファイル:**
- `app/Domain/Alert/Triggers/ProjectProgressDelayTrigger.php`
- `app/Domain/Alert/Triggers/IssueProgressDelayTrigger.php`
- `app/Domain/Alert/Triggers/WorkloadOverloadTrigger.php`

### 4. AlertTriggerService（Phase 5）
**中核サービス:**
- トリガー評価の統合
- 重複アラート排除（同じ条件で既に発火済みなら作成しない）
- プロジェクト全体のアラート処理

**機能:**
- `evaluateProjectAlerts()`: プロジェクト全体のアラート評価
- `evaluateTriggers()`: 各トリガーの条件判定
- `deduplicateAlerts()`: 既存の未解決アラートと重複チェック

**関連ファイル:**
- `app/Application/Alert/Services/AlertTriggerService.php`

### 5. SendGrid メール通知（Phase 6）
**Email統合:**
- SendGrid API経由でアラート通知メール送信
- **レート制限**: 10通/プロジェクト/24時間（プロジェクト毎に独立）
- Laravel HTTPファサードでテスタビリティ確保
- キュージョブで非同期送信（3回リトライ、指数バックオフ）

**メールテンプレートデータ:**
- プロジェクト名、進捗率、納期
- アラートレベル（yellow/red）、説明文
- 推奨アクション

**関連ファイル:**
- `app/Application/Alert/Services/AlertEmailService.php`
- `app/Jobs/SendAlertEmail.php`
- `app/Models/EmailDeliveryLog.php`
- `database/migrations/2026_03_10_000001_create_email_delivery_logs_table.php`

### 6. スケジューラコマンド（Phase 7）
**バッチ処理:**
- Artisanコマンド: `alerts:process`
- **実行頻度**: 1時間毎（`Kernel.php`で`->hourly()`登録）
- 全ての`in_progress`プロジェクトに対してアラート評価を実行
- エラー発生時もログ記録して処理継続（グレースフルデグラデーション）

**関連ファイル:**
- `app/Console/Commands/ProcessAlertsCommand.php`
- `app/Console/Kernel.php` (スケジュール登録)

### アーキテクチャ特性
- **Clean Architecture**: ドメイン層 → アプリケーション層 → インフラ層
- **Repository Pattern**: データ永続化の抽象化
- **依存性注入**: ServiceProviderで全サービス登録
- **TDD**: 全機能でテストファースト開発
- **イベントソーシング**: AlertLogでアラート発火履歴を記録

## スクリーンショット

N/A（バックエンドAPI実装のため)

## 関連リンク

**仕様書:**
- [Alert System Specification](../specs/business/alert-system-implementation.md)
- [Prototype Strategy](../docs/business-logic/prototype-strategy.md)
- [Product Brief](../specs/business/product-brief.md)

**実装計画:**
- [Alert System Implementation Plan](../plans/alert-system-implementation-plan.md)

**完了ドキュメント:**
- [Phase 1 Complete](../plans/project-aggregate-implementation-phase-1-complete.md)
- [Phase 6 Complete](../plans/alert-system-phase-6-complete.md)
- [Phase 7 Complete](../plans/alert-system-phase-7-complete.md)

**ドメインモデル図:**
- [Alert Aggregate PlantUML](../docs/diagrams/domain-models/alert-aggregate.puml)

## 確認したこと

### テストカバレッジ
- ✅ **290テスト全てパス** (2 risky, 1 incomplete, 290 passed)
- ✅ **820アサーション**
- ✅ **ユニットテスト**: 全ドメインモデル、サービス、トリガー
- ✅ **フィーチャーテスト**: ProcessAlertsCommand（6テスト）
- ✅ **Mockery使用**: AlertTriggerServiceのコール検証

### 品質ゲート
- ✅ **Laravel Pint**: 341ファイル（PSR-12準拠）
- ✅ **PHPStan**: Level 5、エラー0件
- ✅ **型安全性**: strict_types宣言、`any`型なし
- ✅ **コード規約**: Clean Architecture、Repository Pattern

### 手動確認
- ✅ トリガー評価ロジック検証（各条件でアラート生成）
- ✅ 重複排除検証（同一条件で複数回発火しない）
- ✅ レート制限検証（プロジェクト毎に独立、10通/日上限）
- ✅ エラーハンドリング検証（1プロジェクト失敗でも他は継続）

### マイグレーション
新規テーブル作成:
- `alerts`
- `alert_logs`
- `action_plans`
- `alert_action_plan_suggestions`
- `issues`
- `issue_assignees`
- `issue_work_logs`  
- `trigger_definitions`
- `trigger_execution_logs`
- `email_delivery_logs`

## 備考

### Phase 8以降の作業
**次のフェーズ（Phase 8）:**
- REST API エンドポイント実装
  - `GET /api/projects/{id}/alerts` - アラート一覧
  - `GET /api/alerts/{id}` - アラート詳細
  - `POST /api/alerts/{id}/resolve` - アラート解決
  - `GET /api/alerts` - 全アラート一覧（管理者用）
- OpenAPI スキーマ生成
- フロントエンド型定義再生成

**Phase 9:**
- ドキュメント同期（ADR、仕様書更新）

### 技術的負債・今後の改善
- [ ] ActionPlan のシーダー作成（固定の推奨アクション登録）
- [ ] SendGrid テンプレートID管理（現在はハードコード）
- [ ] アラート通知先のユーザー管理（現在はプロジェクトマネージャーのみ）
- [ ] カスタムトリガー閾値設定（Phase 2機能、現在は固定値）

### コミット履歴
```
1ff8455 feat(alerts): add scheduled command for hourly alert processing
15b25e6 feat(alerts): add SendGrid email integration with per-project rate limiting
f246fe9 fix(test): make TeamFactory names unique to prevent collision
7771e31 feat(alert): add AlertTriggerService with deduplication and rate limiting
5b54f8b feat(alert): add trigger evaluators for 3 MUST alert categories
082fe86 feat(alert): add issue repository and progress calculation service
7f339c3 feat(alert): add repositories and DTOs for alert system
6e63d92 feat(alert): add domain models for alert system
```

## 確認事項
- [ ] CIがパスしていること
