# {{template}}

# 環境構築方法

## Macの方

ルートディレクトリで`Make init`を実行

## Windowsの方

ルートディレクトリで以下を順番に実行

1. `docker-compose build --no-cache --force-rm`
2. `docker compose up -d`
3. `docker-compose exec app composer install`
4. `docker-compose exec app cp .env.example .env`
5. `docker-compose exec app php artisan key:generate`
6. `docker-compose exec front touch .env.local`
7. `docker-compose exec front cp .env.example .env.local`
8. `docker-compose exec front npm install`

<br />
<br />

# 技術選定

- **Laravel** - api
- **Next.js** - front
- **TypeScript** - front
- **aspida(aspidaSWR)** - REST APIクライアント
- **swagger** - 型定義
- **openapi2aspida** - 型定義ファイル生成
- **breeze** - 認証

<br />
<br />

# 型定義

teamdev-2026-api/docs/openapi/openapi.jsonに記述
<br />
<br />

# 型生成

## Macの方

ルートディレクトリで`make codegen-openapi`を実行

## Windowsの方

ルートディレクトリで以下を実行

```
docker compose up -d front
docker compose exec front npm i && \
docker compose exec front npm run codegen:openapi:container && \
docker compose exec front npm run format
```

# 実行方法

1. `docker compose up -d`でコンテナを立ち上げる
2. `cd teamdev-2026-front`でteamdev-2026-frontディレクトリに移動して`npm run dev`を実行
3. `http://localhost:3000`をブラウザで立ち上げる

## when renaming `api` and `front` directories:

For api → (new-name):

compose.yml (3 mounts: openapi, web, ./teamdev-2026-api/db-store)
package.json (openapi:pull script references ../teamdev-2026-api/docs/openapi/openapi.json)
.gitignore (/teamdev-2026-api/db-store)
README.md (mentions openapi.json)
For front → (new-name):

compose.yml (Dockerfile path Dockerfile)
package.json (husky hook path)
Docs/specs (not critical, but for consistency):

Multiple files in docs and specs mention these paths
Recommendation: If you rename again, update all references above to keep paths consistent.
