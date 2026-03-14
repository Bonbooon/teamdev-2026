# Page: サーベイ

## Purpose
メンバー: 未回答のパルスサーベイに回答。マネージャー: サーベイ配信設定を管理。

## Route
`/surveys`

## Access Control
- 認証: 必要
- ロール: 全員（Manager: 設定タブ表示、Member: 回答タブ表示）

## Layout
AppLayout

## Component Tree
```
SurveyPage
└── AppLayout
    ├── [Member] SurveyAnswerSection
    │   └── SurveyCard[]
    │       ├── SurveyTitle (テンプレート名)
    │       ├── TeamName (どのチームのサーベイか)
    │       ├── DueDate
    │       └── SurveyForm (定型質問のみ)
    │           ├── ScaleQuestion[] (1-5評価)
    │           ├── MultipleChoiceQuestion[]
    │           └── Button (回答送信)
    └── [Manager] SurveyManagement
        └── SurveyConfigByTeam[]
            ├── TeamName
            ├── Select (テンプレート — 定型質問テンプレから選択)
            ├── Select (配信頻度: 毎日/毎週/隔週)
            ├── Select (配信タイミング: 1日の初め/1日の終わり)
            ├── Toggle (有効/無効)
            └── Button (保存)
```

## サーベイテンプレート（MVP）
1. **チーム健康度** — チーム内の協力・コミュニケーション・信頼に関する質問
2. **モチベーション** — 仕事への意欲・成長実感・目標達成感に関する質問
3. **業務負荷** — 業務量・時間的余裕・ストレスに関する質問

## Data Requirements
| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| 未回答サーベイ | `GET /surveys/my/pending` | スケルトンカード | リトライ |

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード |
| empty | EmptyState: "回答待ちのサーベイはありません" |
| error | ErrorState + リトライ |
| success | SurveyCard表示 |

## Interactions
- ScaleQuestion → 1-5のラジオボタン選択
- 回答送信 → React Hook Form + Zod バリデーション
- サーベイ設定 (Manager) → テンプレート・頻度・タイミングを設定

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| 回答送信 | `POST /surveys/{surveyId}/answers` | Toast(success) + カード非表示 | Toast(error) + フィールドエラー |

## Notes
- 質問内容のカスタマイズはMVPスコープ外
- 定型テンプレートのみ
