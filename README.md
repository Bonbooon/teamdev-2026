# teamdev-2026

## クローン

サブモジュール込みでクローンしてください。

```bash
git clone git@github.com:Bonbooon/teamdev-2026.git --recursive
```

## 紐づくサブモジュールのリポジトリ

- [teamdev-2026-api](https://github.com/Bonbooon/teamdev-2026-api)
  - バックエンド API（Laravel）
- [teamdev-2026-front](https://github.com/Bonbooon/teamdev-2026-front)
  - フロントエンド（Next.js）

## 開発環境のセットアップ

以下の手順に従って、開発環境をセットアップしてください。

### 1. リポジトリのクローン

任意の作業ディレクトリに移動し、ターミナルで以下のコマンドを実行する。

```bash
git clone git@github.com:Bonbooon/teamdev-2026.git --recursive
```

### 2. プロジェクトディレクトリに移動

```bash
cd teamdev-2026
```

### 3. 開発環境のセットアップ

```bash
mise run setup
```

このコマンドが以下の処理を自動で実行します：

- サブモジュールの設定とチェックアウト
- サブモジュールの最新コミットへの更新
- Dockerコンテナのビルド
- 共有PostgreSQLコンテナの起動確認
- 現在のworktree用スタックの起動
- バックエンド（Laravel）とフロントエンド（Next.js）の依存関係インストール
- データベースの初期化（マイグレーション・シード）

### 4. フロントの開発用サーバーを起動

```bash
cd teamdev-2026-front
pnpm dev
```

### 5. 開発環境の確認

セットアップ完了後、以下のURLでサービスにアクセスできます：

- **フロントエンド**: http://localhost:3000
- **バックエンドAPI**: http://localhost
- **Swagger UI**: http://localhost:8080
- **PostgreSQL**: 共有PostgreSQLは `localhost:5432` で公開されます。`mise run db-shell` は共有DBコンテナに接続します。ホスト側から確認する場合は `psql -h localhost -p 5432 -U user -d posse` を利用してください

## 基本操作

```bash
# 現在のworktreeの開発スタックを起動
# 共有DBを自動確認し、必要に応じて旧コンテナを掃除する
mise run start

# 共有PostgreSQLのみを事前に起動/確認
mise run ensure-shared-db

# 共有PostgreSQLのみを停止
mise run stop-shared-db

# コンテナの状態確認
mise run ps

# 現在のworktreeのコンテナを停止
# 共有PostgreSQLは停止しない
mise run down

# 現在のworktreeのコンテナ/ボリュームを削除
# 共有PostgreSQLは削除しない
mise run destroy

# すべてのコンテナをビルド
mise run build
```

### WorktreeごとのDocker構成

- `compose.yml` は各worktreeの `front` `app` `web` `swagger-ui` を起動し、`postgresql` サービスは持ちません
- `compose.shared.yml` は全worktree共通のPostgreSQLコンテナを1つだけ起動し、`localhost:5432` で公開します
- worktree側の `app` / `web` コンテナは外部Dockerネットワーク `teamdev-2026-shared` 経由で共有DBへ接続し、Laravelの `DB_HOST=postgresql` はそのまま使えます
- `mise run stop-shared-db` は共有PostgreSQLコンテナだけを停止し、worktree側の `front` / `app` / `web` / `swagger-ui` コンテナには触れません
- `mise run ensure-shared-db` / `mise run start` は、旧構成で残った誤った共有ネットワーク名を検知した場合、shared PostgreSQL を正しい `teamdev-2026-shared` ネットワークへ自動的に作り直します
- `mise run start` は共有DBの起動確認に加えて、移行前の古い `postgresql` / `web` / `swagger-ui` コンテナが現在のポートを掴んでいる場合に自動掃除し、`docker compose up -d --remove-orphans` 相当でworktreeスタックを起動します
- `mise run wt-setup` は worktree 用の `.env` / `APP_KEY` を整えるだけで、共有DBに対する `migrate` / `seed` は実行しません。共有DBを意図的に初期化したい場合だけ `mise run laravel-init` を明示的に実行してください
- `mise run worktree-info` で現在の `web` / `swagger` ポートと、共有DBが `localhost:5432` で使われることを確認できます
- すべてのworktreeは同じDBを共有するため、マイグレーションやシードの実行結果は他のworktreeにも反映されます

### 開発支援

```bash
# 依存関係の再インストール
mise run install-deps

# フォーマットと静的解析
mise run fmtl
```

### コンテナシェル

```bash
# Laravel（API）コンテナに接続
mise run app-shell

# フロントエンドコンテナに接続
mise run front-shell

# 共有PostgreSQLコンテナに接続
mise run db-shell
```

### サブモジュール管理

```bash
# サブモジュールを設定されたブランチにチェックアウト
mise run submodule-checkout

# サブモジュールを最新版に更新
mise run submodule-update
```

## 本番環境で Google OAuth を有効化する

このアプリの Google ログインは、フロントエンドで認可コードを受け取り、API がそのコードを Google に交換する popup ベースの OAuth フローです。現在の実装では専用の `/auth/callback` ページを使わず、フロントエンドの origin を `redirect_uri` として扱います。

### 1. Google Cloud 側で行うこと

1. Google Cloud の Google Auth Platform で OAuth クライアントを作成する
2. クライアント種別は `Web application` を選ぶ
3. `Authorized JavaScript origins` に本番フロントエンドの origin を登録する  
   例: `https://app.example.com`
<<<<<<< HEAD
4. `Authorized redirect URIs` にも、上記と同じ本番フロントエンドの origin を登録する  
   例: `https://app.example.com`  
   （この値はフロントエンドから指定する `redirect_uri` と完全に一致している必要があります）
=======
4. `Authorized redirect URIs` にも同じ origin を登録する
   例: `https://app.example.com`
>>>>>>> 3331277 (docs(auth): clarify popup oauth redirect registration)
5. OAuth consent screen の Branding / Audience / Data Access を設定する
6. アプリが `Testing` のままだとテストユーザーしかログインできないため、公開前に `In Production` に切り替える
7. 外部公開アプリとして運用する場合は、アプリ名、サポート連絡先、ホームページ、プライバシーポリシー、利用規約を設定する

### 2. フロントエンドの環境変数

`teamdev-2026-front` 側では、以下を設定してください。

```bash
NEXT_PUBLIC_APP_URL=https://app.example.com
NEXT_PUBLIC_GOOGLE_CLIENT_ID=xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
```

### 3. API の環境変数

`teamdev-2026-api/web` 側では、以下を設定してください。

```bash
FRONTEND_URL=https://app.example.com
GOOGLE_OAUTH_CLIENT_ID=xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxxxxxxx
GOOGLE_OAUTH_REDIRECT_URI=https://app.example.com
```

> 注意: `GOOGLE_OAUTH_CLIENT_SECRET` は機密情報です。`.env` などの設定ファイルをリポジトリにコミットせず、GitHub Actions の Secrets や Secret Manager 等の仕組みを用いて安全に管理してください。
### 4. 設定時の注意

- `NEXT_PUBLIC_GOOGLE_CLIENT_ID` と `GOOGLE_OAUTH_CLIENT_ID` は同じ値にしてください
- `FRONTEND_URL`、`NEXT_PUBLIC_APP_URL`、`GOOGLE_OAUTH_REDIRECT_URI` は同じ本番フロントエンド origin にしてください
- Google Cloud 側でも、上記と同じ origin を `Authorized JavaScript origins` と `Authorized redirect URIs` の両方に登録してください
- 現在の実装では `GOOGLE_OAUTH_REDIRECT_URI` に callback パスではなくフロントエンド origin を設定してください
- API 側は `FRONTEND_URL` を CORS と Google popup origin の許可判定に使うため、URL がずれるとログインできません

### 5. 動作確認

1. 本番フロントエンドにアクセスする
2. `Google でログイン` を押す
3. 新規ユーザーならプロフィール設定画面に遷移する
4. 既存ユーザーならトップページに遷移する

## デモマネージャーでデモデータにアクセスする手順

Google OAuth の実装上、デモマネージャー用ユーザーは先に Google ログインで作成されている必要があります。そのため `migrate:fresh --seed` ではなく、以下の順序で実行してください。

1. `teamdev-2026-api/web/.env` の `DEMO_MANAGER_EMAIL` に、デモで使う Google アカウントのメールアドレスを設定する
2. API コンテナ内で `php artisan migrate:fresh` を実行する
3. フロントエンドで `DEMO_MANAGER_EMAIL` と同じ Google アカウントでログインする
4. 初回ログインの場合はプロフィール設定を完了する
5. API コンテナ内で `php artisan db:seed` を実行する
6. フロントエンドを再読み込みし、デモマネージャーとしてダッシュボード・プロジェクト・アラート・サーベイを確認する

API コンテナに入って実行する例:

```bash
mise run app-shell
php artisan migrate:fresh
php artisan db:seed
```

`mise run laravel-init` はこの手順を対話的に補助します。`.env` と `APP_KEY` を整えたあと `migrate:fresh` を実行し、`DEMO_MANAGER_EMAIL` の確認と Google ログイン完了を待ってから `db:seed` を続行します。

補足:

- `php artisan migrate:fresh --seed` だと、Google ログイン前にデモマネージャーのユーザーが未作成のため失敗します
- デモ用シーダーは `DEMO_MANAGER_EMAIL` で既存ユーザーを検索し、その実ユーザーIDにチーム・プロジェクト・アラートを紐付けます

## 補足

### miseのインストール

`mise run setup`を実行した際に以下のようなエラーが表示される場合：

```
zsh: command not found: mise
```

**解決方法：**

1. **Homebrewでのインストール**

   ```bash
   brew install mise
   ```

2. **miseの有効化**

   ```bash
   echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **動作確認**
   以下のコマンドを実行して、activateが成功したか確認します。
   ```bash
   mise dr
   ```

**Homebrewがインストールされていない場合：**

- [mise CLI のインストール方法](https://mise.jdx.dev/getting-started.html#installing-mise-cli)を参照してください

**注意：** miseの有効化後は、新しいターミナルセッションを開くか `source ~/.zshrc` を実行してください。

### Windowsで`mise doctor`が`cannot find a config file`になる場合

Windowsネイティブ環境では、`mise`の`env._.source`でbashスクリプトを読み込む構成が不安定です。特に`C:\Windows\System32\bash.exe`（WSL launcher）が使われると、`failed to load config`や`cannot find a config file`のように見えるエラーになります。

このリポジトリでは、Windows向けに以下の方針へ切り替えています。

1. `mise`タスク自体はGit Bashで実行する
2. linked worktreeごとのDocker分離設定は `.worktree.env` で明示的に管理する
3. PostgreSQLは `compose.shared.yml` の共有コンテナを `localhost:5432` で使い、worktreeごとに分離されるのは主に `web` と `swagger` のホストポート
4. 現在のworktreeに割り当てられたポートは `mise run worktree-info` で確認する

Windowsでは以下を満たしてください。

1. Git for Windowsをインストールする
2. 新しいターミナルを開き直す
3. リポジトリルートで`mise tasks`または`mise run ps`を実行する
4. linked worktreeを起動する場合は `mise run start` を使い、必要に応じて古い `postgresql` / `web` / `swagger-ui` コンテナの自動掃除を行わせる

もしまだ失敗する場合は、以下のいずれかに`bash.exe`が存在するか確認してください。

- `C:\Program Files\Git\bin\bash.exe`
- `C:\Program Files\Git\usr\bin\bash.exe`
- `C:\Users\<your-user>\scoop\apps\git\current\bin\bash.exe`

## Architecture Diagrams

Generated SVGs are organized by type under [docs/generated-diagrams](docs/generated-diagrams):

- [docs/generated-diagrams/system-contexts](docs/generated-diagrams/system-contexts) — C4 context/container/component diagrams
- [docs/generated-diagrams/use-cases](docs/generated-diagrams/use-cases) — use case diagrams
- [docs/generated-diagrams/domain-models](docs/generated-diagrams/domain-models) — domain model diagrams
- [docs/generated-diagrams/object-examples](docs/generated-diagrams/object-examples) — object example diagrams
