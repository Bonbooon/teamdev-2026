# UI設計 / 仕様書 — Motivation Cloud Teamwork

**バージョン:** 1.0  
**最終更新:** 2026/04/01  
**対象:** フェーズ1 MVP

---

## 目次

1. [画面定義（Screen Definition）](#1-画面定義)
2. [レイアウト構成（Layout System）](#2-レイアウト構成)
3. [デザイントークン（Design Tokens）](#3-デザイントークン)
4. [共通コンポーネント一覧（Component Inventory）](#4-共通コンポーネント一覧)
5. [ページごとのコンポーネント](#5-ページごとのコンポーネント)
6. [インタラクションルール（Interaction Rules）](#6-インタラクションルール)
7. [データ要件（Data Requirements）](#7-データ要件)
8. [状態管理ルール（State Handling）](#8-状態管理ルール)
9. [フロントエンド構造（Frontend Architecture）](#9-フロントエンド構造)
10. [命名規則（Naming Conventions）](#10-命名規則)
11. [スタイリング方針（Styling Strategy）](#11-スタイリング方針)
12. [アクセシビリティ（Accessibility）](#12-アクセシビリティ)
13. [エラー / 空状態のパターン](#13-エラー--空状態のパターン)
14. [アイコン / アセット方針](#14-アイコン--アセット方針)
15. [AIエージェント向けUI仕様フォーマット](#15-aiエージェント向けui仕様フォーマット)

---

## 1. 画面定義

### 1.1 全ページ一覧

| パス | ページ名 | 要件ID | 認証 | ロール | 説明 | 実装状況 |
|------|----------|--------|------|--------|------|----------|
| `/login` | ログイン | S-01-01, S-01-03 | 不要 | 全員 | Google OAuthログイン | ✅ Phase 0 |
| `/profile/setup` | プロフィール登録 | S-01-02 | 必要 | 全員 | 初回登録・編集 | ✅ Phase 0 |
| `/` | ダッシュボード | S-08-01, S-08-02 | 必要 | 全員 | ロール別トップページ | ⬜ Phase 2A |
| `/teams` | チーム一覧 | S-04-01, S-04-02 | 必要 | 全員 | マネージャー: 管轄チーム / メンバー: 所属チーム | ✅ Phase 1A |
| `/teams/[teamId]` | チーム詳細 | S-04-03 | 必要 | 全員 | タブ: プロジェクト一覧, メンバー一覧 | ✅ Phase 1A |
| `/projects` | プロジェクト一覧 | — | 必要 | 全員 | 参加中プロジェクト一覧 | ✅ Phase 1B |
| `/projects/[projectId]` | プロジェクト詳細 | S-05-04 | 必要 | 全員 | 進捗ボード, ガントチャート, アラート | ✅ Phase 1B |
| `/projects/[projectId]/issues/new` | Issue作成 | S-03-01 | 必要 | 全員 | 動的テンプレート項目付きIssue作成 | ✅ Phase 1C |
| `/issues/[issueId]` | Issue詳細 | S-03-05, S-03-06 | 必要 | 全員 | サブタスク, 進捗, ステータス管理 | ✅ Phase 1C |
| `/alerts` | アラート一覧 | S-02-01, S-02-02 | 必要 | 全員 | 横断的アラート一覧 | ⬜ Phase 2B |
| `/surveys` | サーベイ | S-05-01 | 必要 | 全員 | パルスサーベイ回答 | ⬜ Phase 3A |
| `/users/[userId]` | プロフィール閲覧 | S-06-02 | 必要 | 全員 | 他メンバーのプロフィール表示 | ⬜ Phase 3B |

### 1.2 ルーティング構造

```
/
├── login                              # 公開ページ（認証不要）
├── profile/setup                      # 認証必要
├── teams/
│   └── [teamId]/                      # チーム詳細
├── projects/
│   ├── [projectId]/                   # プロジェクト詳細
│   │   └── issues/new                 # Issue作成
├── issues/
│   └── [issueId]/                     # Issue詳細
├── alerts/                            # アラート一覧
├── surveys/                           # サーベイ
└── users/
    └── [userId]/                      # プロフィール閲覧
```

### 1.3 各画面の状態定義

すべての画面で以下の4状態を必ず定義する。

| 状態 | 説明 | UI表現 |
|------|------|--------|
| `loading` | データ取得中 | スケルトン or スピナー |
| `empty` | データなし | EmptyStateコンポーネント（アイコン + メッセージ + アクションボタン） |
| `error` | エラー発生 | ErrorStateコンポーネント（エラーメッセージ + リトライボタン） |
| `success` | 正常表示 | 通常のデータ表示 |

**画面別の状態表現:**

| ページ | loading | empty | error |
|--------|---------|-------|-------|
| ダッシュボード | カードスケルトン | 「プロジェクトがありません」+ 作成ボタン | リトライボタン |
| チーム一覧 | カードスケルトン | 「チームがありません」+ 作成ボタン(Manager) | リトライボタン |
| チーム詳細 | タブ内スケルトン | タブ別EmptyState | リトライボタン |
| プロジェクト一覧 | カードスケルトン | 「プロジェクトがありません」 | リトライボタン |
| プロジェクト詳細 | ボードスケルトン | 「Issueがありません」+ 作成ボタン | リトライボタン |
| Issue作成 | フォームスケルトン | — | バリデーションエラー表示 |
| Issue詳細 | セクションスケルトン | — | リトライボタン |
| アラート一覧 | カードスケルトン | 「アラートはありません」 | リトライボタン |
| サーベイ | フォームスケルトン | 「回答待ちのサーベイはありません」 | リトライボタン |

### 1.4 アクセス制御

**重要: ロールはチーム単位で判定する。** 同一ユーザーがチームAではmanager、チームBではmemberになりうる。

| ロール | 単位 | 説明 |
|--------|------|------|
| manager | チーム単位 | そのチーム内でのマネージャー権限 |
| member | チーム単位 | そのチーム内での一般メンバー権限 |
| 未認証 | — | ログイン前。`/login` のみアクセス可能 |
| 認証済・プロフィール未登録 | — | `/profile/setup` にリダイレクト |

**ロール別のUI制御:**

| マネージャー専用アクション | 文脈 |
|---------------------------|------|
| チーム作成 | いずれかのチームでmanagerの場合に表示 |
| メンバー招待 | 該当チームのmanagerの場合に表示 |
| PJ作成 | 該当チームのmanagerの場合に表示 |
| PJステータス更新 | PJに紐づくチームのmanagerの場合に表示 |
| サーベイ配信設定 | 該当チームのmanagerの場合に表示 |

**アクセス制御の実装:**
- `AuthGuard` コンポーネント（既存）で認証チェック
- ロール別UIはチーム文脈に基づく条件レンダリングで制御（ページ単位ではなくコンポーネント単位）
- チーム詳細・PJ詳細など特定チーム文脈がある画面では、そのチームでのロールで判定
- ダッシュボード・Sidebar等の横断画面では、いずれかのチームでmanagerかどうかで判定

---

## 2. レイアウト構成

### 2.1 レイアウトパターン

```
┌──────────────────────────────────────────────────────┐
│  AppLayout                                           │
│  ┌──────────┬───────────────────────────────────────┐│
│  │          │  Header                               ││
│  │          │  (タブナビゲーション: ページ切替用)     ││
│  │          ├───────────────────────────────────────┤│
│  │ Sidebar  │                                       ││
│  │ (w-72)   │  PageContent                          ││
│  │          │  (max-w: 1280px)                      ││
│  │ アクション│                                       ││
│  │ ユーザー │                                       ││
│  └──────────┴───────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

### 2.2 構成要素

| 要素 | 幅 | 位置 | 役割 |
|------|-----|------|------|
| Sidebar | 288px (`w-72`) | 左固定 (`fixed`) | クイックアクション、ユーザー情報 |
| Header | 残り幅 | ページコンテンツ上部 | タブナビゲーション（ページ切替・ビュー切替） |
| PageContent | 残り幅 | `ml-72` | 各ページのコンテンツ |

**役割の分離:**
- **Sidebar（左）:** アクション系（クイック操作）のみを配置する。アラートはSidebarに表示しない。
- **Header（上部）:** タブで管理したいものを配置する。ページ間ナビゲーション、ダッシュボード内のビュー切替など。

### 2.3 Sidebarの構成

Sidebarにはアクション系のみを配置する。アラートはSidebarに表示しない。

```
Sidebar
├── Logo (POSSE)
├── Quick Actions
│   ├── Button (PJ作成) [Manager — いずれかのチームでmanagerの場合表示]
│   └── Button (チーム作成) [Manager — いずれかのチームでmanagerの場合表示]
├── (spacer)
└── User Section
    ├── アバター + ユーザー名
    ├── プロフィール編集リンク
    └── ログアウトボタン
```

> **Note:** Issue作成ボタンはSidebarに置かない。Issue作成はプロジェクト文脈が必要なため、プロジェクト詳細ページ内のProgressBoardTab等から遷移する。

### 2.4 Headerのタブナビゲーション

Headerにはページ切替用のタブを配置する。現在のページがアクティブ状態で表示される。

```
Header
├── PageTitle (現在のページ名)
└── TabNavigation
    ├── ダッシュボード    → /
    ├── チーム           → /teams
    ├── プロジェクト      → /projects
    ├── アラート          → /alerts
    └── サーベイ          → /surveys
```

### 2.5 ダッシュボードのタブ構成（Header内）

ダッシュボードページでは、Headerに **チーム切替** と **ビュー切替タブ** の2段構成となる。
選択中チームでのロールに応じてタブ構成が動的に変わる。

**チーム切替:**
- 複数チーム所属時のみ表示
- 選択チームは `localStorage` で記憶

**マネージャー向け (S-08-01) — 選択チームでmanagerの場合:**
| タブ | デフォルト | 内容 |
|------|-----------|------|
| アラート | ✅ | 選択チーム管轄PJのアラート一覧 |
| チーム管理 | | 選択チームの詳細 |
| PJ進捗管理 | | 選択チームのPJ進捗サマリー |
| サーベイ設定 | | 選択チームのサーベイ配信設定 |

**メンバー向け (S-08-02) — 選択チームでmemberの場合:**
| タブ | デフォルト | 内容 |
|------|-----------|------|
| マイワーク | ✅ | 選択チーム内でアサインされたIssue一覧 |
| PJ進捗 | | 選択チームのPJ進捗 |
| サーベイ回答 | | 選択チームの未回答サーベイ |

### 2.6 レスポンシブ対応

**MVPではデスクトップのみ対応。** タブレット・モバイル対応はフェーズ2以降で検討する。

| ブレークポイント | 幅 | レイアウト |
|-----------------|-----|----------|
| desktop | ≥ 1280px | サイドバー + フルコンテンツ |

> **Note:** MVP期間中はモバイル・タブレット対応を行わない。最小表示幅は1280pxを想定する。

### 2.7 スクロールルール

- **Sidebar:** 固定 (`fixed`)、コンテンツが溢れる場合は内部スクロール
- **PageContent:** メインスクロール対象
- **モーダル:** 背景スクロールロック (`overflow: hidden` on body)
- **テーブル:** 横スクロール可能（`overflow-x: auto`）

### 2.8 レイアウト別適用

| レイアウト | 適用ページ |
|-----------|-----------|
| AuthLayout（Sidebar・Header なし） | `/login` |
| SetupLayout（Sidebar・Header なし、中央寄せ） | `/profile/setup` |
| AppLayout（Sidebar + Header + PageContent） | その他全ページ |

---

## 3. デザイントークン

### 3.1 色（Colors）

**配色テーマ: Nordic Clarity（北欧の明晰さ）**

キーワード: 信頼・安定・成功/順調。寒色〜中性色の3色でブランドを構成し、暖色（黄/赤）はアラート専用に確保する。

**プライマリー — Slate Blue（信頼・知性）:**

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| `primary-50` | `#EEF2F8` | 背景ハイライト |
| `primary-100` | `#D5E0F0` | ホバー背景 |
| `primary-200` | `#AABFDA` | 軽いボーダー・タグ |
| `primary-300` | `#7F9EC4` | 無効状態 |
| `primary-500` | `#4A6FA5` | メインブランド色 |
| `primary-600` | `#3B5A88` | ホバー・フォーカス |
| `primary-700` | `#2D466B` | アクティブ |
| `primary-800` | `#1F3250` | サイドバー背景 |
| `primary-900` | `#142236` | テキスト強調 |

**セカンダリー — Sage（成功・順調・前進）:**

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| `secondary-50` | `#EFF7F2` | 順調バッジ背景 |
| `secondary-100` | `#D6ECDF` | ホバー背景 |
| `secondary-200` | `#ADD9BF` | 軽いボーダー |
| `secondary-300` | `#8EC9A5` | 無効状態 |
| `secondary-500` | `#6EA88C` | 順調ステータス・進捗バー |
| `secondary-600` | `#588A71` | ホバー |
| `secondary-700` | `#436B57` | アクティブ・テキスト |

**アクセント — Cool Gray（中立・補助）:**

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| `accent-50` | `#F2F3F5` | サブセクション背景 |
| `accent-100` | `#E0E3E7` | ボーダー・ディバイダー |
| `accent-300` | `#B0B6BF` | 無効テキスト |
| `accent-500` | `#8E96A0` | サブテキスト・セカンダリアイコン |
| `accent-700` | `#5C6370` | ボディテキスト補助 |

**セマンティックカラー（アラート — 暖色はここだけ）:**

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| `success-50` | `#ECFDF5` | 成功背景 |
| `success-500` | `#10B981` | 成功アイコン・テキスト |
| `success-600` | `#059669` | 成功ボタン |
| `warning-50` | `#FFFBEB` | イエローアラート背景 |
| `warning-500` | `#F59E0B` | イエローアラートアイコン |
| `warning-600` | `#D97706` | イエローアラートボーダー |
| `error-50` | `#FEF2F2` | レッドアラート背景 |
| `error-500` | `#EF4444` | レッドアラートアイコン |
| `error-600` | `#DC2626` | エラーテキスト・ボーダー |
| `info-50` | `#EFF6FF` | 情報背景 |
| `info-500` | `#3B82F6` | 情報アイコン |

**ニュートラル:**

| トークン名 | 値 | 用途 |
|-----------|-----|------|
| `gray-50` | `#F9FAFB` | ページ背景 |
| `gray-100` | `#F3F4F6` | カード背景（alt） |
| `gray-200` | `#E5E7EB` | ボーダー |
| `gray-300` | `#D1D5DB` | 無効状態ボーダー |
| `gray-400` | `#9CA3AF` | プレースホルダー |
| `gray-500` | `#6B7280` | サブテキスト |
| `gray-700` | `#374151` | ボディテキスト |
| `gray-900` | `#111827` | 見出しテキスト |
| `white` | `#FFFFFF` | カード背景・サイドバー |

### 3.2 タイポグラフィ

| トークン | 値 |
|---------|-----|
| フォントファミリー | `"Inter", "Noto Sans JP", system-ui, sans-serif` (**仮決め — 後日確定**) |
| ベースフォントサイズ | `14px` |
| 行間 | `1.5` |

**見出しスケール:**

| レベル | サイズ | ウェイト | 行間 | 用途 |
|--------|--------|---------|------|------|
| h1 | `24px` (`text-2xl`) | `bold` | `1.25` | ページタイトル |
| h2 | `20px` (`text-xl`) | `bold` | `1.3` | セクションタイトル |
| h3 | `16px` (`text-base`) | `semibold` | `1.4` | カードタイトル |
| body | `14px` (`text-sm`) | `normal` | `1.5` | 本文 |
| caption | `12px` (`text-xs`) | `normal` | `1.5` | 補足テキスト |

### 3.3 スペーシングスケール

Tailwindデフォルトの4px基準を使用する。

| トークン | 値 | 用途 |
|---------|-----|------|
| `space-1` | `4px` | アイコンとテキストの間 |
| `space-2` | `8px` | 関連要素間 |
| `space-3` | `12px` | フォーム要素間 |
| `space-4` | `16px` | カード内パディング |
| `space-6` | `24px` | セクション間 |
| `space-8` | `32px` | ページセクション間 |
| `space-10` | `40px` | ページパディング（横） |
| `space-12` | `48px` | 大セクション間 |

### 3.4 ボーダー・角丸・影

| トークン | 値 | 用途 |
|---------|-----|------|
| `rounded-md` | `6px` | ボタン・入力 |
| `rounded-lg` | `8px` | カード |
| `rounded-xl` | `12px` | モーダル・大カード |
| `rounded-full` | `9999px` | アバター・バッジ |
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | カード |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | ドロップダウン |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | モーダル |

---

## 4. 共通コンポーネント一覧

### 4.1 フォーム要素

#### Button

| prop | 型 | デフォルト | 説明 |
|------|-----|----------|------|
| `variant` | `"primary" \| "secondary" \| "danger" \| "ghost"` | `"primary"` | 見た目 |
| `size` | `"sm" \| "md" \| "lg"` | `"md"` | サイズ |
| `disabled` | `boolean` | `false` | 無効状態 |
| `loading` | `boolean` | `false` | ローディング中（スピナー表示+disabled） |
| `icon` | `ReactNode` | — | 左アイコン |
| `fullWidth` | `boolean` | `false` | 幅100% |

**variant別スタイル:**

| variant | 通常 | ホバー | 無効 |
|---------|------|--------|------|
| primary | `bg-primary-500 text-white` | `bg-primary-600` | `bg-primary-300 cursor-not-allowed` |
| secondary | `bg-white border-gray-300 text-gray-700` | `bg-gray-50` | `bg-gray-100 text-gray-400` |
| danger | `bg-error-500 text-white` | `bg-error-600` | `bg-error-300` |
| ghost | `bg-transparent text-gray-700` | `bg-gray-100` | `text-gray-400` |

#### Input

| prop | 型 | 説明 |
|------|-----|------|
| `label` | `string` | ラベルテキスト |
| `error` | `string` | エラーメッセージ |
| `hint` | `string` | ヒントテキスト |
| `required` | `boolean` | 必須マーク表示 |
| `disabled` | `boolean` | 無効状態 |
| `prefix` | `ReactNode` | 入力前のアイコン/テキスト |
| `suffix` | `ReactNode` | 入力後のアイコン/テキスト |

#### Textarea

| prop | 型 | 説明 |
|------|-----|------|
| `label` | `string` | ラベル |
| `error` | `string` | エラーメッセージ |
| `rows` | `number` | 初期行数 |
| `maxLength` | `number` | 最大文字数（カウンター表示） |

#### Select

| prop | 型 | 説明 |
|------|-----|------|
| `label` | `string` | ラベル |
| `options` | `{ value: string; label: string }[]` | 選択肢 |
| `error` | `string` | エラーメッセージ |
| `placeholder` | `string` | 未選択時テキスト |

#### Checkbox / Radio

| prop | 型 | 説明 |
|------|-----|------|
| `label` | `string` | ラベル |
| `checked` | `boolean` | チェック状態 |
| `disabled` | `boolean` | 無効状態 |

### 4.2 フィードバック

#### Toast

react-toastify を使用（既存導入済み）。

| 種類 | アイコン | 色 | 用途 |
|------|---------|-----|------|
| success | ✓ | `success-500` | 作成・更新成功 |
| error | ✕ | `error-500` | API失敗 |
| warning | ⚠ | `warning-500` | 確認促し |
| info | ℹ | `info-500` | 情報通知 |

**ルール:**
- 表示位置: 右上 (`top-right`)
- 自動消去: 3秒
- 同時表示最大: 3件

#### Modal

| prop | 型 | 説明 |
|------|-----|------|
| `isOpen` | `boolean` | 表示状態 |
| `onClose` | `() => void` | 閉じるコールバック |
| `title` | `string` | モーダルタイトル |
| `size` | `"sm" \| "md" \| "lg"` | 幅 (`sm: 400px`, `md: 560px`, `lg: 720px`) |
| `children` | `ReactNode` | コンテンツ |

**ルール:**
- オーバーレイ: `bg-black/50`
- ESCキーで閉じる
- オーバーレイクリックで閉じる
- フォーカストラップ

#### ConfirmDialog

| prop | 型 | 説明 |
|------|-----|------|
| `title` | `string` | 確認タイトル |
| `message` | `string` | 確認メッセージ |
| `confirmLabel` | `string` | 確認ボタンラベル |
| `variant` | `"danger" \| "warning"` | ボタン色 |
| `onConfirm` | `() => void` | 確認コールバック |
| `onCancel` | `() => void` | キャンセルコールバック |

### 4.3 データ表示

#### Table

| prop | 型 | 説明 |
|------|-----|------|
| `columns` | `Column[]` | 列定義（`key`, `label`, `width`, `sortable`, `render`） |
| `data` | `T[]` | データ配列 |
| `loading` | `boolean` | ローディング状態（スケルトン行表示） |
| `emptyMessage` | `string` | データなし時のメッセージ |
| `onRowClick` | `(row: T) => void` | 行クリックコールバック |

#### Card

| prop | 型 | 説明 |
|------|-----|------|
| `children` | `ReactNode` | コンテンツ |
| `padding` | `"sm" \| "md" \| "lg"` | パディング |
| `hoverable` | `boolean` | ホバーエフェクト |
| `onClick` | `() => void` | クリックコールバック |

#### Badge

| prop | 型 | 説明 |
|------|-----|------|
| `variant` | `"default" \| "success" \| "warning" \| "error" \| "info"` | 色 |
| `size` | `"sm" \| "md"` | サイズ |
| `children` | `ReactNode` | テキスト |

#### Avatar

| prop | 型 | 説明 |
|------|-----|------|
| `src` | `string` | 画像URL |
| `name` | `string` | フォールバック用の名前（イニシャル表示） |
| `size` | `"sm" \| "md" \| "lg"` | サイズ (`sm: 32px`, `md: 40px`, `lg: 48px`) |

#### Tabs

| prop | 型 | 説明 |
|------|-----|------|
| `tabs` | `{ key: string; label: string; count?: number }[]` | タブ定義 |
| `activeKey` | `string` | 現在のタブ |
| `onChange` | `(key: string) => void` | タブ変更コールバック |

#### Pagination

| prop | 型 | 説明 |
|------|-----|------|
| `currentPage` | `number` | 現在ページ |
| `totalPages` | `number` | 総ページ数 |
| `onPageChange` | `(page: number) => void` | ページ変更コールバック |

### 4.4 状態表示

#### Loading（既存）

スピナーコンポーネント。`animate-spin` を使用。

#### Skeleton

| prop | 型 | 説明 |
|------|-----|------|
| `variant` | `"text" \| "circle" \| "rect"` | 形状 |
| `width` | `string` | 幅 |
| `height` | `string` | 高さ |
| `count` | `number` | 繰り返し数 |

#### EmptyState

| prop | 型 | 説明 |
|------|-----|------|
| `icon` | `ReactNode` | アイコン |
| `title` | `string` | タイトル |
| `description` | `string` | 説明文 |
| `action` | `{ label: string; onClick: () => void }` | アクションボタン |

#### ErrorState

| prop | 型 | 説明 |
|------|-----|------|
| `message` | `string` | エラーメッセージ |
| `onRetry` | `() => void` | リトライコールバック |

### 4.5 ナビゲーション

#### Dropdown

| prop | 型 | 説明 |
|------|-----|------|
| `trigger` | `ReactNode` | トリガー要素 |
| `items` | `{ label: string; onClick: () => void; icon?: ReactNode; danger?: boolean }[]` | メニュー項目 |
| `align` | `"left" \| "right"` | 表示位置 |

### 4.6 プロジェクト固有コンポーネント

#### AlertCard

| prop | 型 | 説明 |
|------|-----|------|
| `level` | `"yellow" \| "red"` | アラートレベル |
| `category` | `string` | カテゴリ名 |
| `title` | `string` | アラートタイトル |
| `description` | `string` | 説明 |
| `suggestedActions` | `Array<{ actionPlanId?: string; code?: string; title?: string; description?: string; rationale?: string; priority?: number }>` | 推奨アクション（API の `suggestedActionPlans` をフラット化して受ける, S-02-10, MVP内） |
| `createdAt` | `string` | 発生日時 |
| `projectName` | `string` | 関連プロジェクト名 |
| `canResolve` | `boolean` | 解決ボタン表示可否（フロント判定: `alert.assigneeId === currentUser.id`） |

**スタイル:**
- Yellow: `border-l-4 border-warning-500 bg-warning-50`
- Red: `border-l-4 border-error-500 bg-error-50`

#### ProgressBar

| prop | 型 | 説明 |
|------|-----|------|
| `value` | `number` | 進捗率 (0-100) |
| `variant` | `"default" \| "success" \| "warning" \| "danger"` | 色 |
| `showLabel` | `boolean` | パーセント表示 |
| `size` | `"sm" \| "md"` | 高さ |

**色ルール:**
- 0-49%: `primary-500`
- 50-79%: `warning-500`
- 80-100%: `success-500`
- 予実差 > 15%: `error-500`

#### StatusBadge

| prop | 型 | 説明 |
|------|-----|------|
| `status` | `"not_in_progress" \| "in_progress" \| "in_review" \| "done"` | ステータス |

**色マッピング:**
- `not_in_progress`: `bg-gray-100 text-gray-600`
- `in_progress`: `bg-info-50 text-info-500`
- `in_review`: `bg-warning-50 text-warning-600`
- `done`: `bg-success-50 text-success-600`

#### ConditionBadge

| prop | 型 | 説明 |
|------|-----|------|
| `condition` | `"good" \| "caution" \| "warning"` | コンディション状態 |

**色マッピング:**
- `good`: `bg-success-50 text-success-600` (良好)
- `caution`: `bg-warning-50 text-warning-600` (注意)
- `warning`: `bg-error-50 text-error-600` (警告)

**判定基準:**
- `good`: FlaggedMembersが0人
- `caution`: FlaggedMembersが1人以上かつチーム人数の30%未満
- `warning`: FlaggedMembersがチーム人数の30%以上

---

## 5. ページごとのコンポーネント

### 5.1 ログインページ (`/login`)

```
LoginPage
└── AuthLayout (中央寄せ, bg-gray-50)
    └── LoginCard
        ├── Logo
        ├── Description
        └── GoogleLoginButton（既存）
```

### 5.2 プロフィール登録 (`/profile/setup`)

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

### 5.3 ダッシュボード (`/`)

ロールはチーム単位のため、複数チームを掛け持ちしているユーザーはチーム切替が必要。

```
DashboardPage
└── AppLayout
    ├── DashboardHeader
    │   ├── TeamSwitcher (複数チーム所属時のみ表示)
    │   │   └── Dropdown (チーム選択)
    │   │      ※ 選択中チームでのロール(manager/member)に応じてタブ構成が変わる
    │   └── Tabs (選択中チームでのロール別タブ)
    │
    │  ── 選択チームで manager の場合 ──
    │
    ├── [Manager] AlertsTab (デフォルト)
    │   ├── AlertSummaryCards (黄/赤カウント)
    │   └── AlertCard[] (該当チーム管轄PJのアラート一覧)
    │
    ├── [Manager] TeamManagementTab
    │   └── TeamSummaryCard (選択中チームのサマリー)
    │       ├── MemberCount (メンバー数)
    │       ├── ProjectCount (PJ数)
    │       ├── ActiveAlertCount (アクティブアラート数)
    │       ├── ConditionOverview (S-05-02: 不調検知)
    │       │   ├── チーム平均スコア
    │       │   └── FlaggedMembers[] (平均より下に乖離しているメンバー — アバター+名前+フラグ)
    │       └── Link (チーム詳細へ → /teams/[teamId])
    │
    ├── [Manager] ProjectProgressTab
    │   └── ProjectSummaryCard[] (選択チームのPJ進捗)
    │
    ├── [Manager] SurveySettingsTab
    │   └── SurveyConfigByTeam
    │       ├── SurveyTemplate (使用テンプレート — 定型質問のみ)
    │       ├── SurveyFrequency (配信頻度: 毎日/毎週/隔週)
    │       ├── SurveyDeliveryTime (配信タイミング: 1日の初め/1日の終わり 等)
    │       ├── SurveyStatus (有効/無効 トグル)
    │       └── Button (設定編集)
    │
    │  ── 選択チームで member の場合 ──
    │
    ├── [Member] MyWorkTab (デフォルト)
    │   └── IssueGroupByProject[]
    │       ├── ProjectHeader
    │       └── IssueRow[] (選択チーム内でアサイン済みIssue)
    │
    ├── [Member] ProjectProgressTab
    │   └── ProjectSummaryCard[] (選択チームのPJ進捗)
    │
    └── [Member] SurveyAnswerTab
        └── PendingSurveyCard[] (選択チームのサーベイ)
```

> **チーム切替の挙動:**
> - 1チームのみ所属 → TeamSwitcherは非表示
> - 複数チーム所属 → TeamSwitcher表示、チーム切替でタブ構成とデータが切り替わる
> - チームAでmanager、チームBでmemberの場合 → 切替でManager用/Member用タブが動的に変わる
> - 選択中チームは `localStorage` で記憶し、次回アクセス時に復元

### 5.4 チーム一覧 (`/teams`)

```
TeamListPage
└── AppLayout
    ├── PageHeader
    │   ├── Title ("チーム")
    │   └── [Manager] Button (チーム作成)
    ├── TeamCard[]
    │   ├── TeamName
    │   ├── MemberCount
    │   └── ConditionBadge (コンディション概況 — 良好/注意/警告)
    └── [Manager] CreateTeamModal
        ├── Input (チーム名)
        ├── MemberSelector
        └── Button (作成)
```

> **Note:** チーム作成はマネージャーのみ。`[Manager]` のボタン・モーダルはメンバーには表示されない。

### 5.5 チーム詳細 (`/teams/[teamId]`)

```
TeamDetailPage
└── AppLayout
    ├── TeamHeader
    │   ├── TeamName
    │   ├── TeamStatusBadge
    │   └── [Manager] Actions
    │       ├── Button (メンバー招待 → InviteMemberModal)
    │       └── Button (チーム編集 → EditTeamModal)
    ├── Tabs
    │   ├── ProjectsTab (デフォルト)
    │   │   └── ProjectList
    │   │       ├── loading: Skeleton[]
    │   │       ├── error: ErrorState
    │   │       ├── empty: EmptyState
    │   │       └── success: ProjectLink[]
    │   │           ├── ProjectTitle
    │   │           ├── StatusBadge
    │   │           ├── [Optional] Description
    │   │           └── DueDate
    │   └── MembersTab
    │       └── WorkloadTable
    │           ├── empty: "メンバーがいません"
    │           └── MemberRow[]
    │               ├── NameLink
    │               ├── RoleBadge
    │               └── StatusBadge
    ├── [Manager] InviteMemberModal
    │   ├── Tabs (追加方法切替)
    │   │   ├── [既存ユーザー追加タブ]
    │   │   │   ├── UserSearch (名前/メールで検索)
    │   │   │   ├── UserList[] (検索結果)
    │   │   │   └── Button (追加 — 招待メールなし、即チーム参加)
    │   │   └── [メール招待タブ]
    │   │       ├── Input (メールアドレス)
    │   │       └── Button (招待 → 招待メール送信 → リンクからaccept)
    │   └── Select (ロール: manager / member)
    └── [Manager] EditTeamModal
        ├── Input (チーム名)
        ├── MemberList[]
        │   ├── Avatar + Name
        │   ├── RoleBadge (manager / member)
        │   ├── Toggle (活動ステータス: 活動中 / 非活動)
        │   └── Button (削除)
        └── Button (保存)
```

### 5.6 プロジェクト一覧 (`/projects`)

```
ProjectListPage
└── AppLayout
    ├── PageHeader
    │   ├── Title ("プロジェクト")
    │   └── [Manager] Button (PJ作成)
    ├── FilterBar
    │   ├── Select (ステータス: 全て/未着手/進行中/完了)
    │   └── Select (チーム: 自分が所属する全チームから絞り込み)
    │   ※ 表示対象は自分が所属するチームのPJのみ
    ├── ProjectCard[]
    │   ├── ProjectName
    │   ├── ProgressBar
    │   ├── StatusBadge
    │   ├── TeamBadge[]
    │   ├── DueDate
    │   └── AlertCount (yellow/red)
    └── [Manager] CreateProjectModal
        ├── Select (チーム — 必須、managerであるチームのみ選択可)
        ├── Input (PJ名)
        ├── Textarea (概要)
        ├── DatePicker (開始日, 終了日)
        └── Button (作成)
```

### 5.7 プロジェクト詳細 (`/projects/[projectId]`)

```
ProjectDetailPage
└── AppLayout
    ├── ProjectHeader
    │   ├── ProjectName
    │   ├── StatusBadge
    │   ├── ProgressBar (全体進捗)
    │   └── Actions (編集, ステータス変更)
    ├── Tabs
    │   ├── ProgressBoardTab (S-05-02 + S-07-02, デフォルト)
    │   │   │
    │   │   │  ※ カンバンとガントは統合UIとして同一タブ内に表示
    │   │   │  ※ 同一APIデータ (GET /projects/{projectId}/issues) を共有
    │   │   │  ※ 重複リクエストしない（SWRキー共有）
    │   │   │
    │   │   ├── ViewToggle (ガント / カンバン 表示切替)
    │   │   │  ※ デフォルト: ガントビュー
    │   │   │  ※ ユーザーの最後の選択をlocalStorageで記憶
    │   │   ├── Button (Issue作成 — ビュー共通、ViewToggle横に配置)
    │   │   ├── [カンバンビュー]
    │   │   │   └── KanbanBoard
    │   │   │       ├── Column (未着手)
    │   │   │       │   └── IssueCard[] (ドラッグ可能)
    │   │   │       │       ├── IssueTitle
    │   │   │       │       ├── AssigneeAvatars (アサイン者アバター)
    │   │   │       │       ├── StoryPointsBadge
    │   │   │       │       ├── DueDate
    │   │   │       │       └── ProgressBar
    │   │   │       ├── Column (進行中)
    │   │   │       ├── Column (レビュー中)
    │   │   │       └── Column (完了)
    │   │   └── [ガントビュー]
    │   │       └── GanttChart
    │   │           ├── GroupBySelector (グルーピング切替フィルター — デフォルト: ステータス別)
    │   │           │   ├── Option: ステータス別 (todo/wip/completed) ← デフォルト
    │   │           │   ├── Option: アサイン者別
    │   │           │   └── Option: フラット (グルーピングなし)
    │   │           ├── TimelineHeader (日付軸)
    │   │           ├── TodayLine (今日の縦線)
    │   │           └── GanttGroup[] (選択したグルーピングで分割)
    │   │               ├── GroupLabel (ステータス名 / アサイン者名 / なし)
    │   │               └── GanttRow[]
    │   │                   ├── IssueName
    │   │                   ├── GanttBar (予定 + 実績、色は予実比較で green/yellow/red)
    │   │                   └── ProgressIndicator
    │   ├── AlertsTab
    │   │   └── AlertCard[]
    │   └── SettingsTab
    │       ├── ProjectInfo (読み取り専用表示)
    │       ├── TeamAssignment (S-05-03)
    │       │   ├── AssignedTeam[] (アサイン済みチーム一覧)
    │       │   │   ├── TeamName
    │       │   │   ├── MemberCount
    │       │   │   └── [Manager] Button (解除)
    │       │   └── [Manager] Button (チームをアサイン → AssignTeamModal)
    │       ├── [Manager] Button (PJ編集 → EditProjectModal を開く)
    │       ├── [Manager] AssignTeamModal (モーダル)
    │       │   ├── TeamSearch (チーム検索)
    │       │   ├── TeamList[] (検索結果 — 未アサインのチームのみ)
    │       │   └── Button (アサイン)
    │       └── [Manager] EditProjectModal (モーダル, S-05-05)
    │           ├── Input (PJ名)
    │           ├── Textarea (概要)
    │           ├── DatePicker (開始日, 終了日)
    │           ├── Select (ステータス: 未着手/進行中/完了/一時停止/キャンセル — S-05-06)
    │           └── Button (保存)
```

> **重要: カンバン+ガント統合の設計方針**
> - カンバンビューとガントビューは同じ `ProgressBoardTab` 配下に配置する
> - `ViewToggle` コンポーネントで表示を切り替える（セグメントコントロール形式）
> - **デフォルトはガントビュー。** ユーザーの選択は `localStorage` で記憶する
> - データソースは `GET /projects/{projectId}/issues` の単一APIを共有する
> - SWRの同一キーを参照し、ビュー切替時にAPIを重複して叩かない
> - カンバンでのDnDステータス変更はガントビューにもリアルタイム反映される（同一SWRキャッシュ）

### 5.8 Issue作成 (`/projects/[projectId]/issues/new`)

```
IssueCreatePage
└── AppLayout
    ├── PageHeader
    │   └── Title ("Issue作成")
    └── IssueForm
      ├── Select (テンプレート選択)
      ├── Input (タイトル)
      ├── Select (ストーリーポイント — 必須, 1-21)
      ├── Input (見積時間 — 必須, 分単位)
      ├── DatePicker (期限)
      ├── Select (ステータス)
      ├── DynamicTemplateFields
      │   ├── Checkbox (boolean)
      │   ├── Input[type=number] (integer / number)
      │   ├── Input[type=date] (date)
      │   ├── Input[type=datetime-local] (datetime)
      │   └── Textarea (string / json)
      ├── DefinitionOfDone
      │   └── ChecklistEditor
      │       ├── Input[] (受け入れ条件)
      │       └── Button (条件追加)
      ├── AssignmentSection
      │   └── Text (アサインUIは未実装のプレースホルダー)
      └── Button (作成)
```

### 5.9 Issue詳細 (`/issues/[issueId]`)

```
IssueDetailPage
└── AppLayout
    ├── IssueHeader
    │   ├── IssueTitle
    │   ├── StatusBadge
    │   ├── StoryPoints
    │   ├── MetaInfo (見積時間, 期限, 担当者リンク)
    │   └── Select (ステータス変更)
    ├── DefinitionOfDone
    │   ├── Checklist (チェック切替可)
    │   └── Button (条件追加)
    ├── SubtaskEditor
    │   └── SubtaskRow[]
    └── WorkLogSection
      │  エンティティ: IssueWorkLog（手動記録 + GitHub連携による自動記録）
      │  出典: specs/business/issue-management.md,
      │        specs/database/table-schema-plan.sql (issue_work_logs),
      │        specs/api/openapi-contracts.md (GET/POST /issues/{issueId}/work-logs, PATCH/DELETE /issues/{issueId}/work-logs/{workLogId})
      ├── EmptyState (ログ0件時)
      ├── WorkLogEntry[]
      │   ├── Minutes
      │   ├── Description
      │   ├── LoggedAt
      │   ├── Button (編集)
      │   └── Button (削除)
      ├── WorkLogInlineEditForm (編集中のみ)
      │   ├── Input[type=number] (minutes)
      │   ├── Textarea (description)
      │   ├── Input[type=date] (logged_at)
      │   ├── Button (保存)
      │   └── Button (キャンセル)
      ├── WorkLogCreateForm
      │   ├── Input[type=number] (minutes)
      │   ├── Textarea (description)
      │   ├── Input[type=date] (logged_at)
      │   └── Button (追加)
      └── ConfirmDialog (削除確認)
```

### 5.10 アラート一覧 (`/alerts`)

```
AlertListPage
└── AppLayout
    ├── PageHeader
    │   └── Title ("アラート")
    ├── AlertSummary
    │   ├── StatCard (赤アラート数)
    │   └── StatCard (黄アラート数)
    ├── FilterBar
    │   ├── Select (レベル: yellow/red)
    │   ├── Select (カテゴリ)
    │   ├── Select (プロジェクト)
    │   └── Select (ステータス: active/resolved)
    └── AlertCard[]
        ├── AlertLevel (yellow/red)
        ├── Category
        ├── Title
        ├── Description
        ├── ProjectName
        ├── SuggestedActions[] (S-02-10: アクションサジェスト — MVP内)
        ├── CreatedAt
        └── Actions (解決, 再開)
            ※ 「解決」「再開」はアラートの通知先として指定されたユーザー本人のみ操作可能
```

### 5.11 サーベイ (`/surveys`)

```
SurveyPage
└── AppLayout
    ├── PageHeader
    │   └── Title ("サーベイ")
    ├── [Member] PendingSurveyList
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

> **Note:** 質問内容のカスタマイズはMVPスコープ外。定型質問テンプレートのみ。
>
> **テンプレート種類（MVP）:**
> 1. **チーム健康度** — チーム内の協力・コミュニケーション・信頼に関する質問
> 2. **モチベーション** — 仕事への意欲・成長実感・目標達成感に関する質問
> 3. **業務負荷** — 業務量・時間的余裕・ストレスに関する質問

### 5.12 プロフィール閲覧 (`/users/[userId]`)

```
UserProfilePage
└── AppLayout
    ├── ProfileHeader
    │   ├── Avatar (lg)
    │   ├── UserName
    │   └── JobTitle
    ├── ProfileDetails
    │   ├── ExpertiseTags[] (S-06-01)
    │   ├── AboutMe
    │   ├── WorkHistory
    │   └── ExternalLinks[]
    └── ActivitySummary
        ├── TeamMemberships
        └── RecentIssues
```

> **導線:** アプリ内でアバターやユーザー名が表示されている箇所すべてから `/users/[userId]` へリンクする。
> - チーム詳細 > メンバー一覧のアバター/名前
> - Issue詳細 > アサイン者のアバター/名前
> - ダッシュボード > 不調検知のFlaggedMembers
> - ワークロードテーブルのメンバー行
> - Sidebar > 自分のアバター（自プロフィール）

---

## 6. インタラクションルール

### 6.1 フォームバリデーション

| タイミング | ルール |
|-----------|--------|
| 入力中（onBlur） | フィールドを離れた時にバリデーション実行 |
| 送信時（onSubmit） | 全フィールドのバリデーション実行、最初のエラーにフォーカス |
| サーバーエラー（422） | APIからのバリデーションエラーをフィールドに紐付けて表示 |

**実装:** React Hook Form + Zod（既存導入済み）

**表示ルール:**
- エラーメッセージはフィールド直下に赤字 (`text-error-600 text-xs`) で表示
- エラー状態のフィールドは赤ボーダー (`border-error-500`)
- 必須フィールドにはラベル横に赤アスタリスク (`*`)

### 6.2 確認ダイアログの使用ルール

以下の操作でConfirmDialogを表示する。

| 操作 | variant | メッセージ例 |
|------|---------|-------------|
| 削除 | `danger` | 「この〇〇を削除しますか？この操作は取り消せません。」 |
| ステータス変更（完了/キャンセル） | `warning` | 「プロジェクトを完了にしますか？」 |
| ログアウト (S-01-04) | `warning` | 「ログアウトしますか？」 |
| ページ離脱（未保存フォーム） | `warning` | 「変更が保存されていません。ページを離れますか？」 |

**表示しない操作:**
- 通常の作成・更新
- ステータス変更（進行中へ）
- ナビゲーション（未保存なし）

### 6.3 ローディング表示

| 操作 | 表示 |
|------|------|
| ページ初回ロード | スケルトン（ページ構造に合わせた形） |
| データリフレッシュ | 前回データ表示 + 背景でSWR再検証 |
| mutation（作成/更新/削除） | ボタンにスピナー + ボタンdisabled |
| ファイルアップロード | プログレスバー |

### 6.4 エラーハンドリング

| エラー種別 | HTTP | 対応 |
|-----------|------|------|
| バリデーションエラー | 422 | フィールド個別にエラー表示 |
| 認証エラー | 401 | `/login` にリダイレクト（既存実装） |
| 権限エラー | 403 | Toast (error) + 操作ブロック |
| リソース不在 | 404 | 404ページ表示 |
| サーバーエラー | 500 | ErrorState + リトライボタン |
| ネットワークエラー | — | Toast (error) 「通信に失敗しました」 |

### 6.5 mutation共通フロー

すべての更新処理（POST/PATCH/DELETE）は以下のフローに従う。

```
ユーザーがアクションを実行
  ↓
[確認ダイアログが必要な操作の場合] ConfirmDialog表示
  ↓
ボタンにスピナー表示 + disabled化
  ↓
APIリクエスト送信
  ↓
成功時:
  - Toast (success) 表示（例: 「プロジェクトを作成しました」）
  - SWRキャッシュ再検証（mutate）
  - モーダルを閉じる / ページ遷移
失敗時:
  - Toast (error) 表示
  - バリデーションエラーの場合はフィールドにエラー表示
  - ボタンを再有効化
```

### 6.6 ページネーション

すべてのリスト表示はページネーション（ページ番号クリック）で対応する。無限スクロールは使用しない。

| 設定 | 値 |
|------|-----|
| デフォルト件数 | 20件/ページ |
| 表示形式 | `< 1 2 3 ... 10 >` |
| URLパラメータ | `?page=1&per_page=20` |
| APIパラメータ | `page`, `per_page`, `sort`, `sort_dir`（既存API仕様に準拠） |

**ページネーション対象ページ:**

| ページ | 対象データ |
|--------|-----------|
| チーム一覧 | チームカード |
| プロジェクト一覧 | プロジェクトカード |
| アラート一覧 | アラートカード |
| チーム詳細 > メンバータブ | ワークロードテーブル行 |
| PJ詳細 > ProgressBoard | Issueカード（カンバン/ガント共通） |
| ダッシュボード > マイワーク | Issue行 |

### 6.7 ドラッグ&ドロップ（カンバンボード）

- Issue カードのドラッグでステータス変更
- ドラッグ中: カードに影 + 元位置にプレースホルダー
- ドロップ時: 楽観的更新 → API呼び出し → 失敗時ロールバック

### 6.8 ワークロードインジケーター (S-07-01)

デフォルト閾値（カスタマイズはMVP外）:

| 色 | 条件 | 意味 |
|----|------|------|
| 🟢 green | ポイント合計 ≤ 基準値の80% | 余裕あり |
| 🟡 yellow | 基準値の80% < ポイント合計 ≤ 基準値の100% | 注意 |
| 🔴 red | ポイント合計 > 基準値の100% | 過負荷 |

> **基準値:** スプリント期間あたりの想定消化ポイント。デフォルト = 40pt/週。
> この値はフロント側の定数 (`WORKLOAD_THRESHOLD`) として管理し、フェーズ2でチーム設定からカスタマイズ可能にする。

### 6.9 不調検知 (S-05-02)

- サーベイ結果のスコアが **チーム平均 − 1σ（標準偏差）** を下回るメンバーにフラグ表示
- 表示場所: ダッシュボード > TeamManagementTab > ConditionOverview
- フラグの算出はバックエンド側で行い、`GET /teams/{teamId}/condition-summary` のレスポンスに `flaggedMembers[]` を含める

### 6.10 進捗率の計算ロジック (S-03-08)

specに基づき、Issue進捗率はバックエンドで算出しAPIレスポンスに含める。フロントでは表示のみ。

**Issue単位の進捗率（優先順位）:**
1. **サブタスクベース**（サブタスクがある場合）: `completedSubtasks / totalSubtasks × 100`
2. **Definition of Doneベース**（サブタスクなし）: `completedCriteria / totalCriteria × 100`
3. **作業ログベース**（どちらもなし）: `actualMinutesLogged / estimatedMinutes × 100`
4. **フォールバック**: 0%

**プロジェクト進捗率:**
- 各Issueの進捗を集計（Issue数ベース: `completedIssues / totalIssues × 100`）
- バックエンドで計算済みの値をフロントはそのまま表示

**ガントチャートの色分け（予実比較）:**
```
expectedProgress = (daysElapsed / daysDue) × 100

actualProgress >= expectedProgress        → green
actualProgress >= expectedProgress × 0.8  → yellow
actualProgress <  expectedProgress × 0.8  → red
```

**アラートトリガー:**
- 予実差 `abs(accuracyVariance) > 20%` でアラート発火（バックエンド側処理）

### 6.11 アラートの解決/再開の権限判定

```tsx
const canResolve = alert.assigneeId === currentUser.id;
```

- `alert.assigneeId`: アラートの通知先ユーザーID（APIレスポンスに含まれる）
- `currentUser.id`: ログイン中のユーザーID
- `canResolve === false` の場合、「解決」「再開」ボタンは非表示（disabled ではなく非表示）

---

## 7. データ要件

### 7.1 ダッシュボード (`/`)

**マネージャー:**

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アラート一覧 | `GET /alerts?status=active` | スケルトンカード | リトライ |
| 管轄チーム | `GET /teams` | スケルトンカード | リトライ |
| PJ進捗サマリー | `GET /projects` | スケルトンカード | リトライ |
| 不調検知 (S-05-02) | `GET /teams/{teamId}/condition-summary` | スケルトンカード | リトライ |

**メンバー:**

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アサイン済みIssue | `GET /issues?assignee=me` | スケルトンリスト | リトライ |
| 所属チーム | `GET /teams` | スケルトンカード | リトライ |
| 未回答サーベイ | `GET /surveys/my/pending` | スケルトンカード | リトライ |

### 7.2 チーム一覧 (`/teams`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| チーム一覧 | `GET /teams` | スケルトンカード×6 | リトライ |

> **Note:** `GET /teams` のレスポンスに `memberCount` と `conditionStatus` ("good" / "caution" / "warning") を含める。一覧表示でチームごとの `condition-summary` を個別取得しない。

### 7.3 チーム詳細 (`/teams/[teamId]`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| チーム情報 | `GET /teams/{teamId}` | ヘッダースケルトン | リトライ |
| プロジェクト一覧 | `GET /projects?team_id={teamId}` | カードスケルトン | リトライ |
| メンバー一覧 | `GET /teams/{teamId}/members` | テーブルスケルトン | リトライ |

### 7.4 プロジェクト一覧 (`/projects`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| PJ一覧 | `GET /projects` | スケルトンカード×6 | リトライ |

### 7.5 プロジェクト詳細 (`/projects/[projectId]`)

| データ | エンドポイント | loading | error | 備考 |
|--------|--------------|---------|-------|------|
| PJ情報 | `GET /projects/{projectId}` | ヘッダースケルトン | リトライ | |
| Issue一覧 (**カンバン+ガント共有**) | `GET /projects/{projectId}/issues` | ボードスケルトン | リトライ | カンバンビューとガントビューで同一データを共有。SWRキー1つで管理し重複リクエストしない |
| アラート | `GET /projects/{projectId}/alerts` | リストスケルトン | リトライ | |

> **Note:** `progress-board` と `gantt` の個別エンドポイントは使用しない。`issues` エンドポイントから取得したデータをフロント側でカンバン表示・ガント表示に変換する。

### 7.6 Issue作成 (`/projects/[projectId]/issues/new`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| テンプレート一覧 | `GET /issue-templates` | Select無効化 | リトライ |
| プロジェクト詳細（チームタグ表示用） | `GET /projects/{projectId}` | フォームスケルトン | リトライ |
| チームメンバー | `GET /teams/{teamId}/members` | AssigneeSelectorをスケルトン表示 | リトライ |
| **mutation** | `POST /projects/{projectId}/issues` | ボタンスピナー | Toast(error) + フィールドエラー |

> **Issueテンプレート（MVP）:**
> テンプレートにより、SMARTフィールドのプレースホルダーテキストやDoDのサンプル項目が変わる。
> 1. **開発タスク** — 機能開発・技術的改善向け
> 2. **バグ修正** — 不具合修正向け（再現手順、期待結果、実際の結果のガイド）
> 3. **調査・検証** — リサーチ・PoC向け
> 4. **ドキュメント** — ドキュメント作成・更新向け

> **現在の作成フロー:**
> project detail の `teams[]` をチームタグとして表示し、チームを1件以上選択した後に、そのチームに属するメンバーだけをアサイン候補として読み込む。送信時は `teamIds` と `assigneeIds` を両方含め、Definition of Done も1件以上必須。

### 7.7 Issue詳細 (`/issues/[issueId]`)

| データ | エンドポイント | loading | error | 備考 |
|--------|--------------|---------|-------|------|
| Issue情報 | `GET /issues/{issueId}` | セクションスケルトン | リトライ | |
| サブタスク | `GET /issues/{issueId}/subtasks` | リストスケルトン | リトライ | |
| 作業ログ | `GET /issues/{issueId}/work-logs` | カード内ローディング表示 | カード内エラー表示 | エンティティ: IssueWorkLog |
| mutation: 作業ログ追加 | `POST /issues/{issueId}/work-logs` | 専用の送信中表示なし | 専用の mutation エラー表示なし | フォーム送信後に一覧再取得 |
| mutation: 作業ログ更新 | `PATCH /issues/{issueId}/work-logs/{workLogId}` | 専用の送信中表示なし | 専用の mutation エラー表示なし | インライン編集で更新 |
| mutation: 作業ログ削除 | `DELETE /issues/{issueId}/work-logs/{workLogId}` | ConfirmDialog 表示 | 専用の mutation エラー表示なし | 確認後に一覧再取得 |
| **mutation: ステータス** | `PATCH /issues/{issueId}/status` | バッジスピナー | Toast(error) | |
| **mutation: DoD** | `PATCH /definition-of-done/{doneItemId}` | チェック切替 | Toast(error) + ロールバック | |

### 7.8 アラート一覧 (`/alerts`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| アラート一覧 | `GET /alerts` | スケルトンカード×6 | リトライ |
| **mutation: 解決** | `POST /alerts/{alertId}/resolve` | ボタンスピナー | Toast(error) | ※ アラート通知先ユーザー本人のみ操作可 |
| **mutation: 再開** | `POST /alerts/{alertId}/reopen` | ボタンスピナー | Toast(error) | ※ アラート通知先ユーザー本人のみ操作可 |

### 7.9 サーベイ (`/surveys`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| 未回答サーベイ | `GET /surveys/my/pending` | スケルトンカード | リトライ |
| **mutation: 回答** | `POST /surveys/{surveyId}/answers` | ボタンスピナー | Toast(error) + フィールドエラー |

### 7.10 プロフィール閲覧 (`/users/[userId]`)

| データ | エンドポイント | loading | error |
|--------|--------------|---------|-------|
| プロフィール | `GET /users/{userId}/profile` | セクションスケルトン | リトライ |

---

## 8. 状態管理ルール

### 8.1 方針

| 種類 | ツール | 用途 |
|------|--------|------|
| サーバー状態 | SWR | APIデータの取得・キャッシュ・再検証 |
| ローカルUI状態 | `useState` | モーダル開閉, タブ選択, フィルター値 |
| フォーム状態 | React Hook Form + Zod | フォーム入力・バリデーション |
| 認証状態 | `useAuth` hook (SWR) | 認証トークン・ユーザー情報 |
| URLベース状態 | Next.js Router (`useRouter`) | ページ, クエリパラメータ |

### 8.2 SWRの使い方

```
SWRキー設計:
  "auth/me"                          → 認証ユーザー
  "teams"                            → チーム一覧
  "teams/{teamId}"                   → チーム詳細
  "teams/{teamId}/members"           → チームメンバー
  "projects"                         → プロジェクト一覧
  "projects/{projectId}"             → プロジェクト詳細
  "projects/{projectId}/issues"      → Issue一覧
  "issues/{issueId}"                 → Issue詳細
  "alerts"                           → アラート一覧
  "surveys/my/pending"               → 未回答サーベイ
```

**キャッシュ戦略:**

| 設定 | 値 | 理由 |
|------|-----|------|
| `revalidateOnFocus` | `true` | タブ復帰時にデータ最新化 |
| `revalidateOnReconnect` | `true` | ネットワーク復帰時 |
| `dedupingInterval` | `2000ms` | 短時間の重複リクエスト防止 |

**mutation後の再検証:**

```
作成・更新・削除後 → 関連するSWRキーをmutate()で再検証

例: Issue作成後
  → mutate("projects/{projectId}/issues")
  → mutate("projects/{projectId}")  // 進捗率更新
```

### 8.3 楽観的更新

以下の操作では楽観的更新を適用する。

| 操作 | 楽観的更新内容 | 失敗時 |
|------|---------------|--------|
| Issueステータス変更 | ステータスバッジ即時更新 | ロールバック + Toast(error) |
| DoD チェック切替 | チェック即時反映 | ロールバック + Toast(error) |
| カンバンドラッグ&ドロップ | カード位置即時移動 | ロールバック + Toast(error) |

### 8.4 グローバル状態は使わない

React Context や Redux/Zustand のようなグローバル状態管理は導入しない。
- サーバー状態 → SWR
- 認証 → useAuth (SWR)
- UI状態 → useState (コンポーネントローカル)
- ページ間の状態受け渡し → URLクエリパラメータ

---

## 9. フロントエンド構造

### 9.1 ディレクトリ構成

```
src/
├── api/                    # aspida生成コード（自動生成、手動編集しない）
│   ├── $api.ts
│   └── @types/
│
├── components/
│   ├── ui/                 # 汎用UIコンポーネント（デザインシステム）
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Textarea.tsx
│   │   ├── Select.tsx
│   │   ├── Checkbox.tsx
│   │   ├── Modal.tsx
│   │   ├── ConfirmDialog.tsx
│   │   ├── Table.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── Avatar.tsx
│   │   ├── Tabs.tsx
│   │   ├── Pagination.tsx
│   │   ├── Dropdown.tsx
│   │   ├── Skeleton.tsx
│   │   ├── EmptyState.tsx
│   │   ├── ErrorState.tsx
│   │   ├── ProgressBar.tsx
│   │   └── StatusBadge.tsx
│   │
│   └── common/             # ドメイン横断の共通コンポーネント
│       ├── AuthGuard.tsx
│       ├── GoogleLoginButton.tsx
│       ├── Loading.tsx
│       └── LogoutButton.tsx
│
├── features/               # 機能別モジュール
│   ├── dashboard/
│   │   ├── components/     # ダッシュボード固有コンポーネント
│   │   │   ├── AlertsTab.tsx
│   │   │   ├── MyWorkTab.tsx
│   │   │   ├── TeamManagementTab.tsx
│   │   │   └── ProjectProgressTab.tsx
│   │   └── hooks/          # ダッシュボード固有フック
│   │
│   ├── teams/
│   │   ├── components/
│   │   │   ├── TeamCard.tsx
│   │   │   ├── TeamHeader.tsx
│   │   │   ├── WorkloadTable.tsx
│   │   │   ├── CreateTeamModal.tsx
│   │   │   ├── EditTeamModal.tsx
│   │   │   └── InviteMemberModal.tsx
│   │   └── hooks/
│   │
│   ├── projects/
│   │   ├── components/
│   │   │   ├── ProjectCard.tsx
│   │   │   ├── ProjectHeader.tsx
│   │   │   ├── ProgressBoard/
│   │   │   │   ├── index.tsx          # ViewToggle + カンバン/ガント切替
│   │   │   │   ├── KanbanBoard.tsx
│   │   │   │   ├── GanttChart.tsx
│   │   │   │   └── ViewToggle.tsx
│   │   │   ├── CreateProjectModal.tsx
│   │   │   ├── EditProjectModal.tsx
│   │   │   ├── AssignTeamModal.tsx
│   │   │   └── FilterBar.tsx
│   │   └── hooks/
│   │
│   ├── issues/
│   │   ├── components/
│   │   │   ├── IssueForm.tsx          # 作成フォーム
│   │   │   ├── EditIssueModal.tsx     # 編集モーダル
│   │   │   ├── IssueCard.tsx
│   │   │   ├── IssueHeader.tsx
│   │   │   ├── DynamicTemplateFields.tsx
│   │   │   ├── SubtaskEditor.tsx
│   │   │   ├── DefinitionOfDone.tsx
│   │   │   ├── AssigneeSelector.tsx
│   │   │   └── WorkLogSection.tsx    # Issue詳細の作業ログCRUD UI
│   │   └── hooks/
│   │
│   ├── alerts/
│   │   ├── components/
│   │   │   ├── AlertCard.tsx
│   │   │   ├── AlertSummary.tsx
│   │   │   └── AlertFilterBar.tsx
│   │   └── hooks/
│   │
│   ├── surveys/
│   │   ├── components/
│   │   │   ├── SurveyCard.tsx
│   │   │   ├── ScaleQuestion.tsx
│   │   │   └── MultipleChoiceQuestion.tsx
│   │   └── hooks/
│   │
│   └── profile/
│       ├── components/
│       │   ├── ProfileForm.tsx
│       │   ├── ProfileView.tsx
│       │   └── ExpertiseTags.tsx
│       └── hooks/
│
├── hooks/                  # グローバルカスタムフック
│   ├── useAuth.ts
│   └── useMediaQuery.ts
│
├── layouts/                # レイアウトコンポーネント
│   ├── AppLayout.tsx
│   ├── AuthLayout.tsx
│   ├── SetupLayout.tsx
│   ├── Header/
│   │   ├── index.tsx       # タブナビゲーション
│   │   └── TabNav.tsx
│   └── Sidebar/
│       ├── index.tsx       # アクション + ユーザー
│       ├── QuickActions.tsx
│       └── UserSection.tsx
│
├── lib/                    # 外部ライブラリ設定
│   └── axios.ts
│
├── pages/                  # Next.js Pages Router
│   ├── _app.tsx
│   ├── index.tsx           # → features/dashboard
│   ├── login/
│   │   └── index.tsx
│   ├── profile/
│   │   └── setup.tsx       # → features/profile
│   ├── teams/
│   │   ├── index.tsx       # → features/teams
│   │   └── [teamId].tsx
│   ├── projects/
│   │   ├── index.tsx       # → features/projects
│   │   ├── [projectId]/
│   │   │   ├── index.tsx
│   │   │   └── issues/
│   │   │       └── new.tsx # → features/issues
│   ├── issues/
│   │   └── [issueId].tsx   # → features/issues
│   ├── alerts/
│   │   └── index.tsx       # → features/alerts
│   ├── surveys/
│   │   └── index.tsx       # → features/surveys
│   └── users/
│       └── [userId].tsx    # → features/profile
│
├── services/               # API呼び出しラッパー（型付き）
│   └── schema/
│
├── styles/
│   └── globals.css
│
└── utils/                  # ユーティリティ関数
    ├── avatar.ts
    ├── client.ts
    ├── pagination.ts
    └── validation-errors.ts
```

### 9.2 pagesとfeaturesの関係

**ルール:** `pages/` はルーティングエントリポイントのみ。ロジックとUIは `features/` に配置する。

```tsx
// pages/teams/index.tsx（薄いラッパー）
import TeamListPage from "@/features/teams/components/TeamListPage";
export default TeamListPage;
```

---

## 10. 命名規則

### 10.1 ファイル・ディレクトリ

| 対象 | ルール | 例 |
|------|--------|-----|
| コンポーネントファイル | PascalCase | `TeamCard.tsx` |
| フック | camelCase (use prefix) | `useAuth.ts` |
| ユーティリティ | kebab-case | `validation-errors.ts` |
| ページファイル | kebab-case (Next.js規約) | `[teamId].tsx` |
| ディレクトリ | kebab-case | `features/`, `components/ui/` |
| テストファイル | `*.test.tsx` | `TeamCard.test.tsx` |

### 10.2 コード内

| 対象 | ルール | 例 |
|------|--------|-----|
| コンポーネント | PascalCase | `TeamCard`, `AlertSummary` |
| 関数・変数 | camelCase | `handleSubmit`, `isLoading` |
| カスタムフック | `use` + PascalCase | `useAuth`, `useTeamMembers` |
| 定数 | UPPER_SNAKE_CASE | `TOKEN_KEY`, `PUBLIC_PATHS` |
| 型・インターフェース | PascalCase | `TeamMember`, `AlertCardProps` |
| Props型 | コンポーネント名 + `Props` | `ButtonProps`, `TeamCardProps` |
| イベントハンドラ | `handle` + 動詞 | `handleCreate`, `handleStatusChange` |
| コールバックprop | `on` + 動詞 | `onClick`, `onStatusChange` |

### 10.3 SWRキー

| ルール | 例 |
|--------|-----|
| APIパスと一致させる | `"teams"`, `"teams/{teamId}/members"` |
| 動的パラメータは実値展開 | `\`teams/${teamId}/members\`` |

---

## 11. スタイリング方針

### 11.1 方針

**Tailwind CSS**（既存導入済み）をスタイリングの唯一の手段とする。

### 11.2 ルール

| ルール | 説明 |
|--------|------|
| インラインstyle禁止 | 動的な値（例: ガントチャートの位置）以外は使わない |
| CSS Modules不使用 | Tailwindに統一 |
| `@apply` 最小限 | `globals.css` でのベーススタイルのみ |
| クラス順序 | レイアウト → サイズ → 余白 → 色 → テキスト → その他 |
| 条件付きクラス | テンプレートリテラルまたは `clsx` ライブラリを使用 |

### 11.3 Tailwind設定の拡張

```ts
// tailwind.config.ts — Nordic Clarity テーマ
theme: {
  extend: {
    colors: {
      primary: {
        50:  "#EEF2F8",
        100: "#D5E0F0",
        200: "#AABFDA",
        300: "#7F9EC4",
        500: "#4A6FA5",
        600: "#3B5A88",
        700: "#2D466B",
        800: "#1F3250",
        900: "#142236",
      },
      secondary: {
        50:  "#EFF7F2",
        100: "#D6ECDF",
        200: "#ADD9BF",
        300: "#8EC9A5",
        500: "#6EA88C",
        600: "#588A71",
        700: "#436B57",
      },
      accent: {
        50:  "#F2F3F5",
        100: "#E0E3E7",
        300: "#B0B6BF",
        500: "#8E96A0",
        700: "#5C6370",
      },
      success: {
        50:  "#ECFDF5",
        500: "#10B981",
        600: "#059669",
      },
      warning: {
        50:  "#FFFBEB",
        500: "#F59E0B",
        600: "#D97706",
      },
      error: {
        50:  "#FEF2F2",
        500: "#EF4444",
        600: "#DC2626",
      },
      info: {
        50:  "#EFF6FF",
        500: "#3B82F6",
      },
    },
    fontFamily: {
      sans: ['"Inter"', '"Noto Sans JP"', 'system-ui', 'sans-serif'],
    },
  },
}
```

---

## 12. アクセシビリティ

内部ツールのため最小限だが、以下は必ず守る。

### 12.1 必須ルール

| ルール | 実装方法 |
|--------|---------|
| ボタンにはラベルを付ける | アイコンのみボタンには `aria-label` |
| フォーム入力にはラベルを付ける | `<label htmlFor>` または `aria-label` |
| 画像にはalt属性 | 装飾画像は `alt=""` |
| キーボード操作可能 | Tab/Enter/Escape で基本操作可能 |
| フォーカス可視 | `focus:ring-2 focus:ring-primary-500` |
| カラーコントラスト | テキストは WCAG AA (4.5:1) 以上 |
| モーダルのフォーカストラップ | モーダル内でTabが循環 |
| エラーの伝達 | `aria-invalid`, `aria-describedby` でエラーメッセージ紐付け |

### 12.2 キーボードショートカット

| キー | 操作 |
|------|------|
| `Escape` | モーダルを閉じる / ドロップダウンを閉じる |
| `Enter` | フォーム送信 / ボタン押下 |
| `Tab` / `Shift+Tab` | フォーカス移動 |

---

## 13. エラー / 空状態のパターン

### 13.1 EmptyState

```
┌─────────────────────────┐
│       [アイコン]          │
│                         │
│     タイトル             │
│     説明テキスト         │
│                         │
│   [アクションボタン]      │
└─────────────────────────┘
```

**ページ別の空状態:**

| ページ | アイコン | タイトル | 説明 | アクション |
|--------|---------|---------|------|-----------|
| チーム一覧 | Users | チームがありません | チームを作成して始めましょう | チーム作成 (Manager) |
| PJ一覧 | Folder | プロジェクトがありません | プロジェクトを作成して始めましょう | PJ作成 (Manager) |
| PJ進捗ボード | ClipboardList | Issueがありません | Issueを作成して進捗を管理しましょう | Issue作成 |
| アラート一覧 | BellOff | アラートはありません | すべてのプロジェクトは順調です | — |
| サーベイ | CheckCircle | 回答待ちのサーベイはありません | — | — |
| マイワーク | Inbox | アサインされたIssueはありません | — | — |

### 13.2 ErrorState

```
┌─────────────────────────┐
│       [エラーアイコン]     │
│                         │
│     エラーが発生しました   │
│     データを取得できませんでした │
│                         │
│       [再試行]            │
└─────────────────────────┘
```

### 13.3 404ページ

```
┌─────────────────────────┐
│                         │
│          404             │
│  ページが見つかりません     │
│  お探しのページは存在しません │
│                         │
│    [ダッシュボードに戻る]   │
└─────────────────────────┘
```

---

## 14. アイコン / アセット方針

### 14.1 アイコンライブラリ

**Heroicons**（`@heroicons/react`）を使用する。

| 理由 |
|------|
| Tailwind公式チーム作成 |
| outline / solid の2バリアント |
| React コンポーネントとして使用可能 |
| Tree-shakable |

**使い分け:**

| バリアント | 用途 |
|-----------|------|
| `outline` (24px) | ナビゲーション, アクションアイコン |
| `solid` (20px) | ステータスインジケーター, バッジ内 |
| `mini` (20px) | テーブル内, 小さいUI要素 |

### 14.2 アイコン割り当て

| 用途 | アイコン |
|------|---------|
| ダッシュボード | `HomeIcon` |
| チーム | `UserGroupIcon` |
| プロジェクト | `FolderIcon` |
| Issue | `ClipboardDocumentListIcon` |
| アラート | `BellAlertIcon` |
| サーベイ | `ChatBubbleLeftRightIcon` |
| プロフィール | `UserCircleIcon` |
| 設定 | `Cog6ToothIcon` |
| 作成 | `PlusIcon` |
| 編集 | `PencilIcon` |
| 削除 | `TrashIcon` |
| 検索 | `MagnifyingGlassIcon` |
| フィルター | `FunnelIcon` |
| ログアウト | `ArrowRightOnRectangleIcon` |
| 成功 | `CheckCircleIcon` |
| 警告(Yellow) | `ExclamationTriangleIcon` |
| エラー(Red) | `XCircleIcon` |
| 情報 | `InformationCircleIcon` |

### 14.3 画像

| ルール | 説明 |
|--------|------|
| フォーマット | SVGを優先。写真はWebP/PNG |
| アバター | Google OAuth画像 + `/user-default.svg` フォールバック（既存） |
| ロゴ | `/posselogo.svg`（既存） |
| Next.js Image | `<Image>` コンポーネントで最適化 |

---

## 15. AIエージェント向けUI仕様フォーマット

AIにページ実装を指示する際は、以下のフォーマットを使用する。

### 15.1 ページ仕様テンプレート

```markdown
# Page: [ページ名]

## Purpose
[ページの目的を1-2文で]

## Route
[パス]

## Access Control
- 認証: 必要/不要
- ロール: manager / member / 全員

## Layout
[使用レイアウト: AppLayout / AuthLayout / SetupLayout]

## Components
- [コンポーネント名1]
  - props: [主要なprops]
- [コンポーネント名2]
  ...

## Data Requirements
| データ | エンドポイント | メソッド |
|--------|--------------|---------|
| ... | ... | ... |

## UI States
| 状態 | 表現 |
|------|------|
| loading | [具体的なスケルトン/スピナー] |
| empty | [EmptyState: icon, title, description, action] |
| error | [ErrorState: message, retry] |
| success | [通常表示] |

## Interactions
- [操作1]: [挙動]
- [操作2]: [挙動]
  ...

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| ... | ... | ... | ... |

## Responsive
[デスクトップ / タブレット / モバイルでの表示差]
```

### 15.2 ページ仕様例: プロジェクト一覧

```markdown
# Page: プロジェクト一覧

## Purpose
ユーザーが参加中の全プロジェクトを一覧表示し、進捗状況を俯瞰する。

## Route
/projects

## Access Control
- 認証: 必要
- ロール: 全員（Managerは作成ボタンあり）

## Layout
AppLayout

## Components
- PageHeader
  - title: "プロジェクト"
  - action: Button (PJ作成, Manager only)
- FilterBar
  - Select (ステータス: 全て/未着手/進行中/完了)
  - Select (チーム)
- ProjectCard[]
  - props: project (name, progress, status, teams[], dueDate, alertCount)
- CreateProjectModal
  - Input (PJ名, required)
  - Textarea (概要)
  - DatePicker (開始日, 終了日)
  - Button (作成)

## Data Requirements
| データ | エンドポイント | メソッド |
|--------|--------------|---------|
| PJ一覧 | /projects | GET |
| チーム一覧 (フィルター用) | /teams | GET |

## UI States
| 状態 | 表現 |
|------|------|
| loading | スケルトンカード×6 (2列グリッド) |
| empty | EmptyState: FolderIcon, "プロジェクトがありません", "プロジェクトを作成して始めましょう", PJ作成ボタン(Manager) |
| error | ErrorState: "データを取得できませんでした", リトライボタン |
| success | ProjectCardのグリッド表示 |

## Interactions
- ProjectCardクリック → /projects/[projectId] に遷移
- PJ作成ボタン → CreateProjectModal表示
- フィルター変更 → URLクエリパラメータ更新 + データ再取得

## Mutations
| 操作 | エンドポイント | 成功時 | 失敗時 |
|------|--------------|--------|--------|
| PJ作成 | POST /projects | Toast(success) + モーダル閉じ + 一覧再取得 | Toast(error) + フィールドエラー |

## Responsive
- desktop: 2列グリッド
- tablet: 2列グリッド (カード幅縮小)
- mobile: 1列
```

### 15.3 コンポーネント仕様テンプレート

```markdown
# Component: [コンポーネント名]

## Purpose
[コンポーネントの目的]

## Props
| prop | 型 | 必須 | デフォルト | 説明 |
|------|-----|------|----------|------|
| ... | ... | ... | ... | ... |

## Variants
[variant別の見た目の違い]

## States
[disabled, loading, error等の状態]

## Events
[onClick, onChange等のイベント]

## Accessibility
[aria属性, キーボード操作]

## Example Usage
\```tsx
<ComponentName prop1="value" prop2={value} />
\```
```

---

## 付録: 実装優先度

フェーズ1で実装する順序:

| 優先度 | 項目 | 理由 |
|--------|------|------|
| P0 | UIコンポーネント基盤 (`components/ui/`) | 全ページの前提 |
| P0 | AppLayout + Sidebar + Header 改修 | 全ページの前提 |
| P1 | チーム一覧 + チーム詳細 | 依存の起点 |
| P1 | プロジェクト一覧 + プロジェクト詳細 | コア機能 |
| P1 | Issue作成 + Issue詳細 | コア機能 |
| P2 | ダッシュボード（ロール別タブ） | 全機能統合 |
| P2 | アラート一覧 | WANT機能 |
| P2 | カンバン + ガント統合ビュー | 可視化 |
| P3 | サーベイ | Phase 1.5 |
| P3 | プロフィール閲覧 | 追加機能 |

**MVP外（フェーズ2以降）:**

| 項目 | 理由 |
|------|------|
| GitHub Actions連携 (S-03-10) | 優先度低、MVP後に評価 |
| アプリ内通知（ベルアイコン + 未読バッジ等） | MVPではアラートページを見に行く運用。通知はメール（SendGrid）のみ |
| レスポンシブ対応（タブレット/モバイル） | デスクトップのみ |
| 高度な分析・履歴トレンド | フェーズ2 |
| チームモチベーション/パルスサーベイ高度化 | フェーズ2 |
| サーベイ質問カスタマイズ | 定型質問テンプレートのみ。カスタマイズはフェーズ2 |
