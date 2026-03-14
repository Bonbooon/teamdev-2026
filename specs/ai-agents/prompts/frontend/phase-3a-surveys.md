# Phase 3A: Surveys — サーベイ回答 + 設定

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A**, **Phase 0B**, **Phase 2A** (Dashboard)
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 5.11 (サーベイ), Section 7.9
- `docs/ui-pages/surveys.md`

## 実装スコープ

### ディレクトリ構成

```
src/features/surveys/
├── components/
│   ├── SurveyPage.tsx
│   ├── SurveyCard.tsx
│   ├── ScaleQuestion.tsx
│   ├── MultipleChoiceQuestion.tsx
│   └── SurveyConfigForm.tsx      # Manager用設定フォーム
└── hooks/
    └── useSurveys.ts
```

```
src/pages/surveys/
└── index.tsx                      # → SurveyPage
```

### サーベイテンプレート（MVP, 3種類）

| テンプレート | カテゴリ |
|-------------|---------|
| チーム健康度 | チーム内の協力・コミュニケーション・信頼 |
| モチベーション | 仕事への意欲・成長実感・目標達成感 |
| 業務負荷 | 業務量・時間的余裕・ストレス |

### Member: サーベイ回答

- SurveyCard: SurveyTitle + TeamName + DueDate + SurveyForm
- ScaleQuestion: 1-5のラジオボタン（各質問）
- MultipleChoiceQuestion: 選択式（各質問）
- 回答送信: react-hook-form + zodバリデーション

### Manager: サーベイ設定

SurveyConfigByTeam:
- Select (テンプレート — 3種類から選択)
- Select (配信頻度: 毎日/毎週/隔週)
- Select (配信タイミング: 1日の初め/1日の終わり)
- Toggle (有効/無効)
- Button (保存)

### API エンドポイント

| 操作 | メソッド | エンドポイント |
|------|---------|--------------|
| 未回答サーベイ取得 | GET | `/surveys/my/pending` |
| 回答送信 | POST | `/surveys/{surveyId}/answers` |

## 受け入れ基準

- [ ] `/surveys` でサーベイページが表示される
- [ ] Member: 未回答サーベイがカード形式で表示される
- [ ] ScaleQuestion (1-5) が動作する
- [ ] 回答送信が動作する（Toast + カード消去）
- [ ] Manager: サーベイ配信設定フォームが表示される
- [ ] EmptyState: "回答待ちのサーベイはありません"
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- 質問内容のカスタマイズ（MVP外）
- サーベイ結果の分析画面（フェーズ2）
