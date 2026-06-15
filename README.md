# Propass

Propass は、ソフトウェア開発チームの進捗遅延を早めに察知し、次のアクションを取りやすくするために制作したチーム運営支援アプリです。プロジェクト管理、課題管理、アラート、サーベイを 1 つの体験にまとめ、チームの生産性とコンディションの両方を見える化することを目指しました。

## 概要

- フロントエンド: `teamdev-2026-front`（Next.js / TypeScript）
- バックエンド API: `teamdev-2026-api/web`（Laravel / PostgreSQL）
- 補助機能: `teamdev-2026-slack`（Slack ボット、任意利用）

## 制作背景

### 課題

既存のタスク管理ツールは、課題の登録や担当管理には強い一方で、プロジェクトが遅れそうな兆候を早期に捉えたり、遅延時の次アクションまで支援したりする部分は弱いと感じていました。特にチーム開発では、進捗の遅れとメンバーの負荷・状態が連動して悪化しやすく、単純なタスク一覧だけでは状況判断が難しくなります。

### 目的

Propass では、次の 2 点を重視しました。

1. プロジェクトマネージャーが「遅れそうか」「どこに手を打つべきか」を早く判断できること
2. チームメンバーが無理なく進捗を記録でき、チーム全体の状態共有につながること

## 主要機能

### 1. プロジェクト / チーム管理

- チーム作成、メンバー招待、プロジェクト作成
- 役割や担当の整理
- チーム単位での閲覧権限の切り替え

### 2. 課題管理

- SMART を意識した課題テンプレート
- 進捗、作業ログ、DoD、サブタスク管理
- プロジェクト詳細からの課題作成と一覧確認

### 3. 遅延検知とアラート

- 進捗差分や状態に応じたアラート
- アラート一覧と詳細確認
- 推奨アクション提示による意思決定支援

### 4. サーベイ / コンディション把握

- チーム向けサーベイ配信設定
- メンバー回答の集約
- チーム状態の可視化

### 5. 補助的な分析機能

- 進捗チャート
- メンバー別の貢献状況表示
- Slack ボットによる運用補助（任意）

## 技術選定およびその意図

### Next.js + TypeScript

- 画面数が多く状態遷移も複雑なため、型安全なフロントエンドを重視しました
- ルーティングとページ構成が分かりやすく、提出後にコードを読まれる場面でも追いやすい構成です

### Laravel + PostgreSQL

- チーム、プロジェクト、課題、サーベイなど関係の多いデータを扱うため、RDB を前提に設計しました
- Laravel は API 実装、認証、テスト、周辺ライブラリの整備がしやすく、短期間でも設計を崩しにくい点を評価しました

### OpenAPI + aspida

- バックエンド API から生成した契約をフロントエンドで利用し、型の不整合を減らしています
- 画面側の実装者が API 仕様を追いやすく、変更影響も見えやすくなります

### SWR / React Hook Form / Zod

- サーバー状態の取得と再検証を簡潔に扱うために SWR を採用しました
- 入力フォームは React Hook Form と Zod を組み合わせ、バリデーションを型と近い場所に寄せています

### Docker + mise

- 開発環境差分を減らし、チームで同じ起動手順を共有するために Docker を採用しました
- 日常操作は `mise` task に寄せ、セットアップや品質確認の導線を揃えています

## アーキテクチャ概要

```text
Browser
  -> Next.js Frontend
  -> Nginx
  -> Laravel API
  -> PostgreSQL
```

- フロントエンドは `teamdev-2026-front`
- バックエンドは `teamdev-2026-api/web`
- API 契約は OpenAPI から生成し、フロントの型付きクライアントへ接続
- バックエンドは `Domain / Application / Infrastructure / Interfaces` を意識した構成です

詳細資料:

- `docs/ui-specification.md`
- `docs/architecture/README.md`
- `specs/business/product-brief.md`

## ローカルセットアップ

### 1. クローン

```bash
git clone git@github.com:Bonbooon/teamdev-2026.git --recursive
cd teamdev-2026
```

### 2. 初回セットアップ

```bash
mise run setup
```

### 3. フロントエンド起動

```bash
cd teamdev-2026-front
pnpm dev
```

### 4. 主なアクセス先

- Frontend: `http://localhost:3000`
- API: `http://localhost`
- Swagger UI: `http://localhost:8080`

### 5. よく使うコマンド

```bash
# ルート / API 側
mise run start
mise run fmtl
mise run ft

# フロント側
cd teamdev-2026-front
pnpm check
pnpm typecheck
pnpm test
```

## 今後の改善

- モバイル / タブレット対応
- GitHub 連携の拡張による進捗自動更新の強化
- アラート精度の改善と説明可能性の向上
- チーム状態の推移を追える分析 UI の拡充

## 補足

- `docs/` には人が読むための設計資料を、`specs/` には実装と仕様の対応を整理しています
- Slack ボットは補助機能であり、アプリ本体の理解には必須ではありません
