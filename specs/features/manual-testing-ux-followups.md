# Spec: Manual Testing UX Follow-ups

**Version:** 1.0
**Last Updated:** 2026/04/02
**Parent Specs:** `specs/business/issue-management.md`, `specs/business/alert-system.md`, `specs/business/project-management.md`, `specs/business/visualization.md`
**Related UI Docs:** `docs/ui-pages/issue-detail.md`, `docs/ui-pages/alerts-list.md`, `docs/ui-pages/project-detail.md`
**Source Notes:** `debug-repot.md`

---

## 概要

手動テストで確認された UX 課題を、実装しやすい 3 つのスコープに再編成した仕様。各スコープは既存の業務仕様を変更するものと、既存仕様を UI で正しく表現するものを分けて定義する。

本 spec に含めるのは次の 3 スコープ:

1. Issue 詳細の作業ログ権限とフィードバック
2. グローバルアラート一覧の文脈表示・ローカライズ・再取得 UX
3. Project 詳細の可視化安定性と担当可視化

**除外事項:** 「メンバー貢献のソートを API 側からフロント側へ移す」という元メモは本 spec から除外する。現行のメンバー貢献タブはすでにクライアントサイドでソート可能であり、再仕様化の対象はアラート一覧の再取得 UX のみとする。

---

## Scope Summary

| Scope | Primary Screen | Goal | Included Items |
|---|---|---|---|
| A | `/issues/[issueId]` | 作業ログ操作の権限と失敗理由を UI で明示する | 作業ログ権限ガード、manager override、API message toast |
| B | `/alerts` | アラートの出どころを理解でき、フィルタ切替でも空白にならない一覧にする | project name 表示、日本語 action plans、refetch UX、API message toast |
| C | `/projects/[projectId]` | Project 詳細の視認性と操作フィードバックを改善する | Kanban assignee 表示、担当一覧パネル、DnD message toast、insights/survey loading、survey chart 安定描画 |

---

## Scope A — Issue Detail: Work Log Permission & Feedback

### User Stories

1. **Issue 閲覧者として**、自分に権限のない作業ログ操作が最初から無効化されていてほしい。不要な 403 を踏まないため。
2. **作業ログ操作を行うユーザーとして**、失敗した理由を API の文言そのままで知りたい。何が禁止されているのか即座に理解するため。
3. **PM として**、Issue の tagged team に紐づく manager 権限を持つ場合は、Issue の担当者でなくても作業ログを扱いたい。実務上のフォローや監督を行うため。

### Business Rules

- 手動の作業ログ追加・編集・削除を許可する対象は以下:
  - Issue assignee
  - Issue に紐づく tagged team の member
  - Project に紐づくいずれかの team で `permissionRole = 'manager'` を持つユーザー
- 上記の権限はサーバーサイドで必ず検証する。フロントの表示制御は補助であり、認可の代替ではない。
- 現在のフロント実装にある「manager 判定の placeholder 値」に依存して権限を推測してはならない。Issue 詳細画面が利用する API レスポンスで、現在ユーザーの capability を判断できる情報を取得できること。

### UI Requirements

- 権限のないユーザーには、作業ログの新規追加フォームを有効状態で見せない。
  - UI は「非表示」または「disabled + 補助文言」のいずれでもよい
  - ただし、有効な送信ボタンを表示して送信後に 403 を返す挙動は許容しない
- 権限のないユーザーには、既存作業ログの編集・削除アクションも有効状態で見せない。
- サーバーが 4xx / 422 を返し、レスポンスに `message` が含まれる場合、作業ログ mutation の error toast はその `message` をそのまま表示する。
- `message` が取得できない場合のみ、汎用 fallback toast を表示する。

### API / Contract Requirements

- Issue 詳細画面が読む API には、現在ユーザー向けの作業ログ capability を表す情報を含める。
- capability は booleans でも role metadata でもよいが、少なくとも次の UI 判定が可能でなければならない:
  - 作業ログを新規追加できるか
  - 任意の既存作業ログを編集 / 削除できるか
  - 自分が作成した作業ログのみ編集 / 削除できるか

### Acceptance Criteria

- 非 assignee / 非 tagged-team member / 非 manager のユーザーが Issue 詳細を開いたとき、作業ログ作成 UI は有効化されない。
- manager ユーザーは assignee でなくても作業ログを作成できる。
- 作業ログ mutation が 403 / 422 を返したとき、toast には API の `message` がそのまま表示される。
- UI の権限ガードが stale でも、最終的な認可はサーバーが守る。

---

## Scope B — Global Alerts List: Context, Localization & Refetch UX

### User Stories

1. **PM として**、一覧の各アラートがどの project に属するものかを一目で知りたい。対応先を素早く判断するため。
2. **PM として**、推奨アクションが日本語で表示されていてほしい。画面上でそのままチームに共有するため。
3. **一覧利用者として**、level や status を切り替えるたびにページ全体が空白にならず、前の結果を見ながら待てるようにしてほしい。文脈を失わないため。
4. **アラート操作を行うユーザーとして**、解決 / 再開に失敗した理由を API の文言で知りたい。再試行条件を理解するため。

### Scope Boundary

- 本 scope は **グローバルの `/alerts` 一覧ページのみ** を対象とする。
- Project 詳細ページ内の alerts タブはこの scope の対象外とする。

### UI Requirements

- 各 AlertCard には、関連する project name を表示する。
- Suggested actions の title / description は日本語で表示する。
- 初回ロード時は従来どおり skeleton 表示でよい。
- ただし、初回成功後に level / status などの filter を切り替えた場合は、前回の一覧と summary を維持したままインラインの loading 表示を出す。
- filter 変更時に、カード一覧領域が完全に空白になる挙動は許容しない。
- resolve / reopen が 4xx / 422 を返し、レスポンスに `message` が含まれる場合、toast はその `message` をそのまま表示する。

### Data / Contract Requirements

- グローバル alerts API は、最終的に UI が project name を表示できる契約を満たすこと。
- 実現方法は次のいずれでもよい:
  - API が `projectName` を直接返す
  - フロントが `projectId` から project 一覧を参照して name を解決する
- ただし、表示要件そのものは必須とし、「projectId のみ表示」は不可とする。

### Content Requirements

- ActionPlan の seed data / master data は日本語で管理する。
- alerts 画面でだけ翻訳するのではなく、alert suggested action として使われる title / description 自体が日本語であること。

### Acceptance Criteria

- `/alerts` の全カードに project name が表示される。
- level filter を切り替えたとき、一覧は blank にならず前回データか固定サイズ placeholder を維持する。
- Suggested actions は日本語で表示される。
- resolve / reopen failure 時の toast は API の `message` を優先表示する。

---

## Scope C — Project Detail: Visual Stability & Assignment Visibility

### User Stories

1. **PM として**、進捗ボードのカードを見ただけで担当者を把握したい。誰に確認すべきか即座に判断するため。
2. **PM として**、メンバーごとにどの Issue を持っているかを一覧したい。担当偏りやボトルネックを把握するため。
3. **Project 詳細の利用者として**、インサイトタブやアンケート結果タブを開いたときに blank を見たくない。ロード中であることを理解しやすくするため。
4. **Project 詳細の利用者として**、アンケート結果チャートは常に実際のグラフとして見えてほしい。背景だけ見えて肝心の分析が見えない状態を避けるため。
5. **ボード利用者として**、無効な status 遷移を DnD した場合は、ロールバックだけでなく理由も API 文言で知りたい。

### Progress Board Requirements

- Kanban card は assignee avatars を表示する。
- ProgressBoard 内に、メンバー別の担当 Issue 一覧パネルを追加する。
  - 配置は progress board の直下または隣接領域
  - 各 member row には member name、assigned issue count、assigned issue list を表示
  - Issue list は issue detail への遷移導線を持つ
  - 担当 Issue がない member には empty 表示を出す
- DnD による Issue status 更新が失敗した場合:
  - card は元の column に rollback される
  - API が `message` を返した場合、その `message` を error toast に表示する
  - `in_progress -> done` のような無効遷移は引き続きサーバー側で reject される

### Insights / Survey Loading Requirements

- InsightsTab と SurveyResultsTab は、初回ロード時に視認可能な loading state を表示する。
- 「タブを開いた直後に大きな空白だけが見える」状態は許容しない。
- 初回成功後の再取得では、以下のいずれかの挙動を必須とする:
  - 前回の成功コンテンツを維持しつつインライン loading indicator を出す
  - 固定サイズの skeleton placeholder を表示してレイアウト高さを維持する
- due date 未設定やデータ空状態は loading と区別して表示する。

### Survey Score Chart Stability Requirements

- Survey score chart は、初回タブ表示時・タブ再表示時のいずれでも可視のグラフとして描画されなければならない。
- chart container は mount 時点で **正の width / height を持つ measurable container** として扱う。
- レイアウト計測がまだできない場合は、chart 本体を mount して blank にするのではなく、fallback skeleton または placeholder を表示する。
- 「カード背景だけ表示され、Recharts が `width(-1)` / `height(-1)` を警告する」状態は不正とする。

### Acceptance Criteria

- Progress board の kanban card で assignee が視認できる。
- Progress board に member-assignment panel が追加され、member ごとの assigned issues を一覧できる。
- DnD failure 時に rollback と exact-message toast の両方が起きる。
- InsightsTab / SurveyResultsTab のロード時に blank hole が発生しない。
- Survey score chart が first open と tab switch 後の両方で可視に描画される。

---

## Out of Scope

- グローバル alerts page 以外の alert 表示の redesign
- AI 分析 spec (`specs/features/project-insights-ai-analysis.md`) の要求変更
- メンバー貢献タブのソート方式変更
