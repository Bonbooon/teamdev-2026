# Page: ログイン

## Purpose
Google OAuthによるログイン画面。未認証ユーザーのエントリポイント。

## Route
`/login`

## Access Control
- 認証: 不要
- ロール: 全員

## Layout
AuthLayout（Sidebar・Headerなし、中央寄せ）

## Component Tree
```
LoginPage
└── AuthLayout (中央寄せ, bg-gray-50)
    └── LoginCard
        ├── Logo
        ├── Description
        └── GoogleLoginButton（既存）
```

## Data Requirements
なし（クライアントサイドのみ）

## UI States
| 状態 | 表現 |
|------|------|
| loading | GoogleLoginButtonにスピナー表示 |
| error | Toast(error) でエラーメッセージ表示 |
| success | `/` または `/profile/setup` にリダイレクト |

## Interactions
- GoogleLoginButtonクリック → Google OAuth認証フロー開始
- 認証成功 → プロフィール未登録なら `/profile/setup`、登録済みなら `/` にリダイレクト
- 認証失敗 → Toast(error) でメッセージ表示（401: 認証失敗、409: アカウント競合、503: サービス利用不可、500: サーバーエラー）

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| Google認証 | `POST /auth/google/login` | リダイレクト | Toast(error) |

## Existing Code
- `src/components/GoogleLoginButton.tsx` — 既存実装あり。そのまま使用。
- `src/hooks/useAuth.ts` — `login()` メソッドあり。
- `src/pages/login/index.tsx` — 既存実装あり。AuthLayout適用のみ変更。

## Notes
- MVPではGoogle OAuth のみ。他の認証方法は未対応。
