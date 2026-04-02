# デモマネージャー共有Googleアカウント運用手順

## 目的

最終発表までは、デモ確認用に 1 つの共有 Google アカウントをデモマネージャーとして利用する。
この運用は、既存の `DEMO_MANAGER_EMAIL` ベースのシーディングと Google OAuth ログイン実装に合わせた暫定措置である。

関連判断は `docs/architecture/adr/0010-demo-manager-shared-google-account-until-final-presentation.md` を参照すること。

## プレースホルダー情報

- デモ用Googleアカウント: `<DEMO_MANAGER_EMAIL_PLACEHOLDER>`
- パスワード管理担当: `<PASSWORD_OWNER_NAME>`
- 連絡方法: `<PASSWORD_OWNER_CONTACT_METHOD>`

例:
- デモ用Googleアカウント: `demo-manager-placeholder@example.com`
- パスワード管理担当: `山田太郎`
- 連絡方法: `Slack DM`

## セキュリティ方針

- パスワードはリポジトリに書かない
- パスワードは README、Issue、PR、公開 Slack チャンネルに書かない
- パスワードが必要な場合は `<PASSWORD_OWNER_NAME>` に直接聞く
- 2 段階認証や復旧コードが必要な場合も `<PASSWORD_OWNER_NAME>` に直接連絡する
- デモ用途以外ではこのアカウントを使わない

## 事前チェックリスト

- `teamdev-2026-api/web/.env` の `DEMO_MANAGER_EMAIL` が `<DEMO_MANAGER_EMAIL_PLACEHOLDER>` になっている
- `GOOGLE_OAUTH_CLIENT_ID` が設定されている
- `GOOGLE_OAUTH_CLIENT_SECRET` が設定されている
- `GOOGLE_OAUTH_REDIRECT_URI` が現在のフロントエンド URL と一致している
- アプリが起動している
- 初回利用時はプロフィール設定を完了する前提で作業する
- DB を作り直した直後であれば、先に Google ログインしてから seed する

## ログイン手順

1. パスワードが必要なら `<PASSWORD_OWNER_NAME>` に直接連絡する
2. アプリのログイン画面を開く
3. Google ログインを選ぶ
4. デモ用 Google アカウント `<DEMO_MANAGER_EMAIL_PLACEHOLDER>` でサインインする
5. 追加認証が出た場合は `<PASSWORD_OWNER_NAME>` に確認する
6. 初回ログインならプロフィール設定を完了する
7. ログイン後、ダッシュボード・プロジェクト・アラート・サーベイが表示できることを確認する

## DB 初期化後にデモデータを使う手順

1. `teamdev-2026-api/web/.env` の `DEMO_MANAGER_EMAIL` を `<DEMO_MANAGER_EMAIL_PLACEHOLDER>` に設定する
2. `migrate:fresh` を実行する
3. フロントエンドで `<DEMO_MANAGER_EMAIL_PLACEHOLDER>` でログインする
4. 初回ログインならプロフィール設定を完了する
5. `db:seed` を実行する
6. フロントエンドを再読み込みしてデモデータを確認する

実行例:

```bash
mise run app-shell
php artisan migrate:fresh
# ここでブラウザからデモ用 Google アカウントでログイン（初回ならプロフィール設定も完了）してから次を実行する
php artisan db:seed
```

## 運用ルール

- できるだけ同時に複数人が触らない
- デモ直前は発表担当者を優先する
- アカウント設定変更は勝手に行わない
- パスワード変更時は `<PASSWORD_OWNER_NAME>` が責任を持ってチームに周知する
- 本運用は最終発表までの暫定対応であり、その後に恒久対応を再検討する