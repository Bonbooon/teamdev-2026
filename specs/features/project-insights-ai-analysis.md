# Spec: Project Insights — AI 分析 (Phase B)

**Version:** 1.0
**Last Updated:** 2026/04/01
**Parent Spec:** `specs/business/visualization.md`
**Prerequisite:** `specs/features/project-insights-chart.md` (Phase A)

---

## 概要

Phase A で実装した予実チャートの下に、LLM（GPT-5.4）を活用した AI 分析機能を追加する。PMがボタン一つでプロジェクトの遅延原因を分析し、データに基づいたネクストアクションの提案を受けられる。サーベイ結果、Issue の状態、メンバーの貢献データなどをコンテキストとして渡すことで、PJ ごとの精度の高い分析を実現する。

---

## User Stories

1. **PMとして**、予実の乖離がある際にAIに「何が原因か」を分析させ、問題を特定したい。
2. **PMとして**、AIから具体的なネクストアクション（1on1実施、チーム施策提案など）を受け取り、即座に行動に移したい。
3. **PMとして**、過去のAI分析結果を振り返り、施策の効果を追跡したい。
4. **PMとして**、分析のスコープ（PJ全体/チーム/メンバー）を選んで、適切な粒度のアクションプランを受け取りたい。

---

## 権限

- **AI 分析機能の利用:** PJ に紐づくいずれかのチームで `permissionRole = 'manager'` を持つユーザーのみ
- **過去の分析結果の閲覧:** 同上（マネージャー限定タブ内に配置）
- 権限チェックはサーバーサイドで行い、フロントでもボタンの表示/非表示を制御

---

## UI 配置

Phase A で追加した「インサイト」タブ内に配置。

### タブ内構成（Phase B 完了後）

```
InsightsTab
├── ChartFilterBar（スコープ・時間単位）← Phase A
├── due_at 未設定バナー ← Phase A
├── 乖離アラートバナー ← Phase A
├── ProgressChart ← Phase A
├── ─── 区切り線 ───
├── AI分析セクション（マネージャーのみ表示）
│   ├── スコープ選択（チャートと連動）
│   ├── 「AIに分析させる」ボタン
│   ├── ローディングアニメーション
│   ├── 分析結果表示エリア（インライン展開）
│   │   ├── 注意書きバナー: 「AIの回答には誤りが含まれる場合があります」
│   │   ├── 推定原因セクション（複数）
│   │   └── アクションプランセクション（最大5つ）
│   └── 過去の分析履歴リスト（日付降順）
```

---

## AI 分析リクエストフロー

```
[フロント] ─ POST /api/projects/{projectId}/ai-analysis ─→ [Laravel API]
                                                                │
                                                    コンテキスト収集（DB クエリ）
                                                                │
                                                    プロンプト構築（テンプレート）
                                                                │
                                                    OpenAI API 呼び出し（同期 Job）
                                                                │
                                                    レスポンスパース + DB 保存
                                                                │
[フロント] ←── GET /api/projects/{projectId}/ai-analysis/{id} ←─┘
  (ポーリングで完了を検知)
```

### 方式: (B) 非同期ジョブ + ポーリング

1. フロントが `POST` でジョブを起動 → 即座に `202 Accepted` + `analysisId` を返す
2. Laravel Queue Job が OpenAI API を呼び出し → 結果を DB に保存
3. フロントが `GET` で数秒おきにポーリング → `status: "processing"` or `status: "completed"`
4. 完了したら結果を表示

---

## API エンドポイント

### `POST /api/projects/{projectId}/ai-analysis`

AI 分析ジョブを起動する。

**認可:**
- `auth:sanctum` 必須
- PJ に紐づくいずれかのチームで `permissionRole = 'manager'` であること
- 未認証: `401`、マネージャーでない: `403`

**リクエストボディ:**

```json
{
  "scope": "project",
  "targetId": null
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `scope` | `string` | Yes | `project` / `team` / `member` |
| `targetId` | `uuid?` | Conditional | `scope=team` → teamId、`scope=member` → teamMemberId |

**レスポンス (202 Accepted):**

```json
{
  "analysis": {
    "id": "uuid",
    "status": "processing",
    "createdAt": "2026-04-01T10:00:00Z"
  }
}
```

**エラーレスポンス:**

| Status | 条件 |
|--------|------|
| `400` | scope=team/member で targetId 未指定 |
| `401` | 未認証 |
| `403` | マネージャーでない |
| `404` | PJ 不存在 |
| `429` | レート制限（同一PJで直近5分以内にリクエスト済み） |

---

### `GET /api/projects/{projectId}/ai-analysis/{analysisId}`

分析結果を取得する。

**認可:** POST と同じ（マネージャー限定）

**レスポンス (200 OK) — 処理中:**

```json
{
  "analysis": {
    "id": "uuid",
    "status": "processing",
    "createdAt": "2026-04-01T10:00:00Z"
  }
}
```

**レスポンス (200 OK) — 完了:**

```json
{
  "analysis": {
    "id": "uuid",
    "status": "completed",
    "scope": "project",
    "targetId": null,
    "createdAt": "2026-04-01T10:00:00Z",
    "completedAt": "2026-04-01T10:00:25Z",
    "requestedBy": {
      "userId": "uuid",
      "userName": "田中太郎"
    },
    "result": {
      "causes": [
        {
          "description": "○○さんが持っている××Issueが9日ほど進捗がないようです。直近のサーベイの結果によると○○さんはPJ内の所属チームである▽▽チームの平均結果と比べて「チームと気軽に雑談できるか？」「チームに相談しやすいと感じるか？」という質問に対してそれぞれ2ポイントも低く回答しております。",
          "relatedData": {
            "issueIds": ["uuid"],
            "memberIds": ["uuid"],
            "surveyQuestionIds": ["uuid"]
          }
        }
      ],
      "actionPlans": [
        {
          "description": "○○さんとの1on1を実施し、コンディションのヒアリングをしてみてはいかがでしょうか？",
          "priority": 1
        },
        {
          "description": "▽▽チーム内で心理的安全性が確保されていない恐れがあります。▽▽チーム全体でランチ会を開いてみることをチームに提案してみてはいかがでしょうか？",
          "priority": 2
        }
      ]
    }
  }
}
```

**レスポンス (200 OK) — 失敗:**

```json
{
  "analysis": {
    "id": "uuid",
    "status": "failed",
    "createdAt": "2026-04-01T10:00:00Z",
    "completedAt": "2026-04-01T10:00:30Z",
    "error": "AI分析に失敗しました。しばらくしてからやり直してください。"
  }
}
```

---

### `GET /api/projects/{projectId}/ai-analysis`

過去の分析結果一覧を取得する（日付降順）。

**認可:** マネージャー限定

**レスポンス (200 OK):**

```json
{
  "analyses": [
    {
      "id": "uuid",
      "status": "completed",
      "scope": "project",
      "targetId": null,
      "createdAt": "2026-04-01T10:00:00Z",
      "completedAt": "2026-04-01T10:00:25Z",
      "requestedBy": {
        "userId": "uuid",
        "userName": "田中太郎"
      },
      "summary": "推定原因: 2件、アクションプラン: 3件"
    }
  ]
}
```

---

## データベース

### 新テーブル: `ai_analysis_results`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | `uuid` | No | PK |
| `project_id` | `uuid` | No | FK → projects.id |
| `requested_by` | `uuid` | No | FK → users.id（リクエストしたユーザー） |
| `scope` | `varchar(20)` | No | `project` / `team` / `member` |
| `target_id` | `uuid` | Yes | スコープ対象ID |
| `status` | `varchar(20)` | No | `processing` / `completed` / `failed` |
| `context_summary` | `json` | Yes | 送信したコンテキストの要約（デバッグ用） |
| `prompt_tokens` | `int` | Yes | 使用した入力トークン数 |
| `completion_tokens` | `int` | Yes | 使用した出力トークン数 |
| `result` | `json` | Yes | AI レスポンス（パース済み JSON） |
| `error_message` | `text` | Yes | 失敗時のエラーメッセージ |
| `created_at` | `timestamp` | No | リクエスト日時 |
| `completed_at` | `timestamp` | Yes | 完了/失敗日時 |

**インデックス:**
- `project_id` + `created_at DESC`（一覧取得用）
- `id`（ポーリング用）

---

## コンテキスト収集（3段階フィルタリング）

AI にプロンプトを投げる前に、サーバーサイドでデータを収集・構造化する。

### Stage 1: DB クエリ（フィルタリング）

#### Issue データ
- **対象:** `status != 'done'` かつ（`deadline < NOW()` OR 進捗率が期待以下）
- **ソート:** `story_points DESC`, `deadline ASC`
- **上限:** 100件
- **取得フィールド:** id, title, status, story_points, estimated_minutes, deadline, started_at, closed_at
- **関連データ:**
  - アサイニー名（`issue_assignees` → `team_members` → `users`）
  - サブタスク（当該 Issue の子 Issue のみ）: id, title, status, story_points
  - WorkLog 合計: `SUM(work_logs.minutes_logged)`
  - DoD 完了率: `COUNT(completed) / COUNT(total)`

#### サーベイデータ
- **対象:** PJ に紐づくチームのサーベイ結果、直近3回分
- **集計:** 質問カテゴリ別の平均スコア
- **メンバー内訳:** 各メンバーの質問別スコア（チーム平均との差異計算用）

#### メンバーデータ
- **対象:** PJ に紐づくチームの全メンバー
- **取得:** 名前, 完了 Issue の SP 合計（`status='done'` の SP 合計）, 未完了 Issue 数, アサイン中 Issue 数

#### プロジェクトデータ
- タイトル, ステータス, created_at, due_at
- 予実乖離率（Phase A の計算ロジックを流用）

### Stage 2: PHP 構造化（データ圧縮）

各データを以下の構造に変換:

```php
$context = [
    'project' => [
        'title' => 'string',
        'status' => 'string',
        'startDate' => 'date',
        'dueDate' => 'date',
        'deviationPercent' => 25.0,
        'totalPlannedPoints' => 100,
        'totalActualPoints' => 75,
    ],
    'issues' => [
        [
            'title' => 'string',
            'assignee' => 'string',
            'storyPoints' => 5,
            'estimatedMinutes' => 300,
            'actualMinutesLogged' => 450,
            'progressPercent' => 60.0,
            'daysOverdue' => 3,
            'subtasks' => ['完了: 2/5'],
            'status' => 'in_progress',
        ],
        // ... max 100 items
    ],
    'surveyResults' => [
        'teamAverages' => [
            ['question' => 'チームと気軽に雑談できるか？', 'avgScore' => 3.5, 'maxScore' => 5.0],
        ],
        'memberScores' => [
            ['memberName' => '田中', 'question' => 'チームと気軽に雑談できるか？', 'score' => 1.5, 'teamAvg' => 3.5],
        ],
    ],
    'members' => [
        ['name' => '田中', 'completedPoints' => 15, 'openIssueCount' => 3, 'assignedIssueCount' => 5],
    ],
];
```

### Stage 3: プロンプト構築（AiPromptBuilder）

`AiPromptBuilder` が Stage 2 の `$context` 配列を受け取り、**テンプレート文字列**によって自然言語の User Prompt テキストに変換する。AI やその他の要約手法は使用しない — 純粋な PHP 文字列テンプレートのみで構築する。

#### 変換ルール

1. `$context['project']` → プロジェクト概要テキスト
2. `$context['issues']` → Issue ごとに1行の要約テキスト（ループ）
3. `$context['surveyResults']` → サーベイ要約テキスト（チーム平均 + 乖離メンバー）
4. `$context['members']` → メンバー別サマリーテキスト

#### User Prompt 出力例

```
## プロジェクト概要
プロジェクト「新規機能開発」は2026-01-15に開始し、期限は2026-04-30です。
現在の進捗率は35%で、期待進捗率60%に対して25.0%の乖離があります。
（総予定SP: 100、総実績SP: 75）

## 注目すべきIssue一覧
- 「ログイン機能」(5SP) 担当: 田中 / ステータス: in_progress / 期限超過: 3日 / 実作業時間: 450分(見積300分) / サブタスク完了: 2/5
- 「検索API実装」(8SP) 担当: 佐藤 / ステータス: in_progress / 期限超過: 1日 / 実作業時間: 120分(見積480分) / サブタスク完了: 0/3

## サーベイ結果（直近3回平均）
チーム平均:
- 「チームと気軽に雑談できるか？」: 3.5 / 5.0
- 「チームに相談しやすいと感じるか？」: 3.8 / 5.0

チーム平均との乖離が大きいメンバー:
- 田中: 「チームに相談しやすいと感じるか？」スコア 1.5（チーム平均 3.8、差 -2.3）

## メンバー別サマリー
- 田中: 完了SP 15 / 未完了Issue 3件 / アサイン中 5件
- 佐藤: 完了SP 22 / 未完了Issue 1件 / アサイン中 2件

上記のデータを分析し、遅延の原因とアクションプランをJSON形式で出力してください。
```

#### 実装制約

- **必ず `AiPromptBuilder` を経由すること。** `$context` 配列を直接 JSON シリアライズしてプロンプトに埋め込む方法は禁止。自然言語テンプレートに変換することで、LLM が文脈を正しく理解し、Few-shot example と同じ形式の入力を受け取れるようにする。
- テンプレート内の固有名詞（メンバー名、Issue タイトル等）はエスケープ不要（プロンプト内テキスト）
- User Prompt の末尾に `"上記のデータを分析し、遅延の原因とアクションプランをJSON形式で出力してください。"` という指示文を付加する
- トークン予算を超える場合は Issue リストを乖離率降順で打ち切る（Stage 1 の上限100件に加え、ここでも最終的にトークン数を見てトリミング）

---

## System Prompt

```
あなたはプロジェクトマネジメントの専門家です。ソフトウェア開発チームの進捗データとサーベイ結果を分析し、プロジェクト遅延の原因を特定してネクストアクションを提案してください。

## ルール
- 必ず日本語で回答してください。
- 必ず「推定原因」と「アクションプラン」の両方を含めてください。
- 推定原因はデータに基づいて具体的に記述し、各原因は300文字以内にしてください。
- アクションプランは最大5つまで、各アクションは150文字以内にしてください。
- コンテキストに含まれるメンバー名、チーム名、Issue名のみを使用してください。コンテキストに存在しない固有名詞を使わないでください。
- 各原因には、どのデータポイントから導出したか根拠を明記してください。
- アクションは具体的で実行可能な内容にしてください（「改善する」のような抽象的な指示は避ける）。

## 出力形式
以下のJSON形式で出力してください。他のテキストは含めないでください。

{
  "causes": [
    {
      "description": "原因の説明（300文字以内）",
      "relatedData": {
        "issueIds": ["関連するIssueのIDリスト"],
        "memberIds": ["関連するメンバーのIDリスト"],
        "surveyQuestionIds": ["関連するサーベイ質問のIDリスト"]
      }
    }
  ],
  "actionPlans": [
    {
      "description": "アクションの説明（150文字以内）",
      "priority": 1
    }
  ]
}
```

### Few-shot Example（プロンプト内に含める）

```
## 参考例

入力例:
プロジェクト「新規機能開発」は期限の60%が経過していますが、進捗は35%です。
田中さんの担当Issue「ログイン機能」は9日間進捗がありません。
直近サーベイで田中さんは「相談しやすさ」について、チーム平均3.8に対し1.5と回答しています。

出力例:
{
  "causes": [
    {
      "description": "田中さんが担当している「ログイン機能」Issueが9日間進捗がない状態です。直近のサーベイ結果では、田中さんの「相談しやすさ」スコアがチーム平均3.8に対して1.5と大幅に低く、チーム内で相談しづらい状況にある可能性があります。",
      "relatedData": {
        "issueIds": ["issue-uuid-1"],
        "memberIds": ["member-uuid-1"],
        "surveyQuestionIds": ["question-uuid-1"]
      }
    }
  ],
  "actionPlans": [
    {
      "description": "田中さんとの1on1を実施し、現在の状況やブロッカーをヒアリングしてください。",
      "priority": 1
    },
    {
      "description": "チーム全体の心理的安全性向上のため、カジュアルなランチ会の開催をチームに提案してください。",
      "priority": 2
    }
  ]
}
```

---

## OpenAI API 呼び出し仕様

| Setting | Value |
|---------|-------|
| **Model** | `gpt-5.4` |
| **Temperature** | `0.3` |
| **Response Format** | `json_object` (Structured Output / JSON mode) |
| **Max Tokens** | `2000` |
| **Timeout** | `60 seconds` |

### トークン予算

| セクション | 予算 |
|------------|------|
| System Prompt | ~1,000 tokens |
| PJ 概要 + サーベイ要約 | ~1,500 tokens |
| Issue データ（100件 × ~45 tokens） | ~4,500 tokens |
| メンバーサマリー | ~1,000 tokens |
| **合計入力** | **~8,000 tokens** |
| **出力** | **~2,000 tokens** |

100件で収まらない場合は、乖離率（`(estimatedMinutes - actualMinutesLogged) / estimatedMinutes`）の大きい順にトップN件に絞る。

---

## Hallucination 対策

### MVP で実装（必須）

1. **Structured Output (JSON mode):** GPT-5.4 の `response_format: { type: "json_object" }` で出力構造を強制。パース失敗時は status=`failed` にしてエラーメッセージを返す
2. **Temperature 0.3:** 創造性を抑えて事実ベースの出力に寄せる
3. **UI 注意書き:** 分析結果の上部に常時表示 — 「⚠️ この分析結果はAIによるものです。内容に誤りが含まれる場合があります。実際のデータと照合の上ご判断ください。」
4. **固有名詞制約:** System Prompt で「コンテキストに含まれる固有名詞のみ使用」と明示
5. **Few-shot examples:** System Prompt に模範回答例を含めて出力品質を安定化

### Phase 2 以降（将来実装）

6. **Post-validation:** AI 出力の `memberIds`, `issueIds` がコンテキスト内に存在するかサーバーサイドで検証
7. **Reference citation:** 各原因にデータ根拠を表示

---

## レスポンスバリデーション（JSON Schema）

AI から受け取った JSON をサーバーサイドでバリデーションする。

```json
{
  "type": "object",
  "required": ["causes", "actionPlans"],
  "properties": {
    "causes": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["description"],
        "properties": {
          "description": { "type": "string", "maxLength": 300 },
          "relatedData": {
            "type": "object",
            "properties": {
              "issueIds": { "type": "array", "items": { "type": "string" } },
              "memberIds": { "type": "array", "items": { "type": "string" } },
              "surveyQuestionIds": { "type": "array", "items": { "type": "string" } }
            }
          }
        }
      }
    },
    "actionPlans": {
      "type": "array",
      "minItems": 1,
      "maxItems": 5,
      "items": {
        "type": "object",
        "required": ["description", "priority"],
        "properties": {
          "description": { "type": "string", "maxLength": 150 },
          "priority": { "type": "integer", "minimum": 1, "maximum": 5 }
        }
      }
    }
  }
}
```

バリデーション失敗時: ログに記録 + status=`failed` + ユーザーにリトライ促すエラー表示。

---

## レート制限

- 同一プロジェクトに対して直近5分以内に分析リクエスト済みの場合、`429 Too Many Requests` を返す
- 実装: `ai_analysis_results` テーブルの `created_at` を確認（キャッシュ/Redis 不要）

---

## フロントエンド実装

### 新規ファイル

| File | Description |
|------|-------------|
| `src/features/projects/components/AiAnalysisSection.tsx` | AI 分析セクション全体（ボタン + 結果表示 + 履歴） |
| `src/features/projects/components/AiAnalysisResult.tsx` | 分析結果の表示コンポーネント（原因 + アクション） |
| `src/features/projects/components/AiAnalysisHistory.tsx` | 過去の分析履歴リスト |
| `src/features/projects/hooks/useAiAnalysis.ts` | POST（起動）+ GET（ポーリング）のフック |
| `src/features/projects/hooks/useAiAnalysisHistory.ts` | 履歴一覧取得の SWR フック |

### 変更ファイル

| File | Change |
|------|--------|
| `src/features/projects/components/InsightsTab.tsx` | AI 分析セクション追加（マネージャーのみ） |

### ポーリング動作

1. POST 成功 → `analysisId` を取得
2. `setInterval(3000)` で GET ポーリング開始
3. `status === "completed"` or `status === "failed"` → ポーリング停止
4. 最大ポーリング回数: 30回（約90秒）→ タイムアウトエラー表示

### UI コンポーネント詳細

#### 「AIに分析させる」ボタン
- マネージャーのみ表示
- スコープはチャートのスコープと連動
- 処理中はボタン無効化 + ローディングアニメーション

#### 分析結果表示
```
┌──────────────────────────────────────────────┐
│ ⚠️ この分析結果はAIによるものです。           │
│ 内容に誤りが含まれる場合があります。           │
│ 実際のデータと照合の上ご判断ください。         │
└──────────────────────────────────────────────┘

🔍 推定原因

1. ○○さんが持っている××Issueが9日ほど進捗がないようです...
   (300文字以内)

2. △△チームの期限切れIssueが5件あり...
   (300文字以内)

📋 アクションプラン

1. ○○さんとの1on1を実施し...（150文字以内）
2. ▽▽チーム全体でランチ会を...（150文字以内）
3. ○○さんがほかに所属しているチームの方に...（150文字以内）
```

#### 過去の分析履歴
- 日付降順リスト
- 各行: 日時 + スコープ + 要約（「推定原因: 2件、アクションプラン: 3件」）
- クリックで展開して詳細表示
- 削除・アーカイブ機能なし

---

## バックエンド実装

### 新規ファイル

| File | Description |
|------|-------------|
| `app/Models/AiAnalysisResult.php` | Eloquent モデル |
| `app/Interfaces/Http/Controllers/Project/AiAnalysisController.php` | コントローラー（POST/GET/一覧） |
| `app/Application/Project/UseCases/RequestAiAnalysisUseCase.php` | 分析リクエスト起動 |
| `app/Application/Project/UseCases/GetAiAnalysisResultUseCase.php` | 結果取得 |
| `app/Application/Project/UseCases/ListAiAnalysisResultsUseCase.php` | 履歴一覧取得 |
| `app/Application/Project/Services/AiContextCollector.php` | コンテキスト収集（3段階フィルタリングの Stage 1 + 2） |
| `app/Application/Project/Services/AiPromptBuilder.php` | プロンプト構築（Stage 3） |
| `app/Application/Project/Services/OpenAiClient.php` | OpenAI API クライアント（json mode） |
| `app/Jobs/ProcessAiAnalysisJob.php` | 非同期ジョブ |
| `database/migrations/xxxx_create_ai_analysis_results_table.php` | マイグレーション |
| `tests/Feature/Interfaces/Http/Project/AiAnalysisControllerTest.php` | API テスト |
| `tests/Unit/Application/Project/Services/AiContextCollectorTest.php` | コンテキスト収集テスト |
| `tests/Unit/Application/Project/Services/AiPromptBuilderTest.php` | プロンプト構築テスト |

### 変更ファイル

| File | Change |
|------|--------|
| `routes/api.php` | 新ルート3つ追加 |
| `config/services.php` | OpenAI API key 設定追加 |
| `.env.example` | `OPENAI_API_KEY` 追加 |

### ルート追加

```
POST   /api/projects/{projectId}/ai-analysis          → AiAnalysisController@store
GET    /api/projects/{projectId}/ai-analysis           → AiAnalysisController@index
GET    /api/projects/{projectId}/ai-analysis/{id}      → AiAnalysisController@show
```

---

## テストケース

### API テスト (AiAnalysisControllerTest)

| TestCase | Description |
|----------|-------------|
| `test_manager_can_request_analysis` | マネージャーが分析をリクエストできる |
| `test_member_cannot_request_analysis` | 一般メンバーは 403 |
| `test_unauthenticated_returns_401` | 未認証で 401 |
| `test_returns_404_for_nonexistent_project` | PJ 不存在で 404 |
| `test_rate_limit_within_5_minutes` | 5分以内の再リクエストで 429 |
| `test_get_processing_analysis` | 処理中の分析結果取得 |
| `test_get_completed_analysis` | 完了した分析結果取得 |
| `test_get_failed_analysis` | 失敗した分析結果取得 |
| `test_list_analyses_ordered_by_date_desc` | 履歴が日付降順 |
| `test_list_analyses_only_visible_to_manager` | 一般メンバーからは 403 |
| `test_scope_team_requires_target_id` | scope=team で targetId 必須 |
| `test_scope_member_requires_target_id` | scope=member で targetId 必須 |

### コンテキスト収集テスト (AiContextCollectorTest)

| TestCase | Description |
|----------|-------------|
| `test_collects_issues_excluding_done_status` | 完了 Issue を除外 |
| `test_limits_issues_to_100` | 上限100件 |
| `test_collects_survey_results_last_3` | サーベイ直近3回分 |
| `test_filters_by_team_scope` | チームスコープのフィルタリング |
| `test_filters_by_member_scope` | メンバースコープのフィルタリング |
| `test_includes_subtasks_for_filtered_issues` | 該当 Issue のサブタスクのみ含む |
| `test_includes_worklog_summary` | WorkLog 合計を含む |

### プロンプト構築テスト (AiPromptBuilderTest)

| TestCase | Description |
|----------|-------------|
| `test_builds_system_prompt_with_rules` | System Prompt にルールが含まれる |
| `test_builds_user_prompt_with_context` | コンテキストデータが埋め込まれる |
| `test_prompt_within_token_budget` | トークン予算内に収まる |

### フロントエンドテスト

| TestCase | Description |
|----------|-------------|
| `test_ai_button_hidden_for_non_manager` | 非マネージャーにはボタン非表示 |
| `test_ai_button_triggers_request` | ボタンクリックで POST |
| `test_loading_state_during_polling` | ポーリング中のローディング表示 |
| `test_result_displayed_on_completion` | 完了時に結果表示 |
| `test_error_displayed_on_failure` | 失敗時のエラー表示 |
| `test_disclaimer_banner_always_shown` | 注意書きバナーが常時表示 |
| `test_history_list_rendered` | 履歴リストが表示される |

---

## 環境変数

| Key | Description | Example |
|-----|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API キー | `sk-...` |
| `OPENAI_MODEL` | 使用モデル名 | `gpt-5.4` |
| `OPENAI_MAX_TOKENS` | 最大出力トークン | `2000` |
| `OPENAI_TEMPERATURE` | 温度パラメータ | `0.3` |

---

## 実装順序（推奨フェーズ分割）

### Phase 1: DB + モデル + マイグレーション
- `ai_analysis_results` テーブル作成
- `AiAnalysisResult` Eloquent モデル
- マイグレーション

### Phase 2: コンテキスト収集 + プロンプト構築
- `AiContextCollector` サービス（3段階フィルタリング）
- `AiPromptBuilder` サービス（テンプレート + system prompt）
- ユニットテスト

### Phase 3: OpenAI クライアント + ジョブ
- `OpenAiClient`（API 呼び出し + JSON パース + バリデーション）
- `ProcessAiAnalysisJob`（非同期ジョブ）
- `RequestAiAnalysisUseCase`

### Phase 4: API エンドポイント
- `AiAnalysisController`（POST / GET / 一覧）
- ルート追加 + OpenAPI アノテーション
- 権限チェック（マネージャー判定）
- API テスト

### Phase 5: フロントエンド
- `AiAnalysisSection` + `AiAnalysisResult` + `AiAnalysisHistory`
- `useAiAnalysis` + `useAiAnalysisHistory` フック
- `InsightsTab` にセクション追加
- フロントテスト

---

## 依存関係

- **Phase A（チャート）** が完了していること（InsightsTab が存在すること）
- **OpenAI PHP SDK:** `composer require openai-php/laravel`（または直接 HTTP クライアント使用）
- **Laravel Queue:** 既存の Queue 設定を使用（`database` or `redis` ドライバ）
- **OpenAPI codegen:** API 追加後に `mise codegen-openapi` が必要
