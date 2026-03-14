# Page: プロフィール登録

## Purpose
初回ログイン後のプロフィール登録・編集画面。

## Route
`/profile/setup`

## Access Control
- 認証: 必要
- ロール: 全員

## Layout
SetupLayout（Sidebar・Headerなし、中央寄せ、max-w-2xl）

## Component Tree
```
ProfileSetupPage
└── SetupLayout (中央寄せ, max-w-2xl)
    └── ProfileForm
        ├── AvatarUpload (Google画像プレフィル)
        ├── Input (姓, 名)
        ├── Input (姓カナ, 名カナ)
        ├── Input (職種・役職)
        ├── TagInput (得意分野)
        ├── Input (趣味)
        ├── DatePicker (入社日)
        ├── Textarea (職歴)
        ├── ExternalLinksEditor
        │   └── Input[] (URL)
        └── Button (保存)
```

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| 既存プロフィール | `GET /users/me/profile` | フォームスケルトン | リトライ |
| **mutation: 保存** | `POST /users/me/profile` | ボタンスピナー | Toast(error) + フィールドエラー |

## UI States
| 状態 | 表現 |
|------|------|
| loading | フォームスケルトン |
| error | ErrorState + リトライ |
| success | フォーム表示（既存データがあればプレフィル） |

## Interactions
- フォーム入力 → React Hook Form + Zod バリデーション
- 保存ボタン → API送信 → 成功時 Toast(success) + `/` にリダイレクト
- Google画像がある場合はアバターにプレフィル

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| プロフィール保存 | `POST /users/me/profile` | Toast(success) + `/` リダイレクト | Toast(error) + フィールドエラー |

## Existing Code
- `src/pages/profile/setup.tsx` — 既存実装あり。SetupLayout適用+UIコンポーネント置換。

## Notes
- 得意分野はタグ入力（S-06-01）
- 外部リンクは動的追加/削除が可能
