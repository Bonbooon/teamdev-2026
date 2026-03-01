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
- 全コンテナの起動
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
- **Solr管理画面**: http://localhost:8983
- **PostgreSQL**: `mise run db-shell`でコンテナに接続し、`psql -d posse -U user`でPostgreSQLにアクセス後、`\dt`でテーブル一覧を確認

## 基本操作
```bash
# 開発サーバーの起動
mise run up

# コンテナの状態確認
mise run ps

# すべてのコンテナを停止
mise run down

# すべてのコンテナを削除
mise run destroy

# すべてのコンテナをビルド
mise run build
```

### 開発支援
```bash
# 依存関係の再インストール
mise run install-deps

# コードのリント
mise run lint
```

### コンテナシェル
```bash
# Laravel（API）コンテナに接続
mise run app-shell

# フロントエンドコンテナに接続
mise run front-shell

# データベースに接続
mise run db-shell
```

### サブモジュール管理
```bash
# サブモジュールを設定されたブランチにチェックアウト
mise run submodule-checkout

# サブモジュールを最新版に更新
mise run submodule-update
```

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

## Architecture Diagrams

### System Context
![System Context](./generated-diagrams/system-context.svg)

### Use Cases
![Use Cases](./generated-diagrams/use-cases.svg)

### Domain Model
![Domain Model](./generated-diagrams/domain-model.svg)

### Object Example
![Object Example](./generated-diagrams/object-example.svg)