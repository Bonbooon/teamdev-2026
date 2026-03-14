# Phase 2A: Dashboard — ロール別ダッシュボード

## 制御フレーズ

> Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing.

## 前提条件

- 完了必須: **Phase 0A**, **Phase 0B**, **Phase 1A** (Teams), **Phase 1B** (Projects)
- 作業ディレクトリ: `teamdev-2026-front/`

## Source of Truth

- `docs/ui-specification.md` — Section 2.5 (ダッシュボードのタブ構成), Section 5.3 (ダッシュボード), Section 7.1
- `docs/ui-pages/dashboard.md`

## 実装スコープ

### ディレクトリ構成

```
src/features/dashboard/
├── components/
│   ├── DashboardPage.tsx
│   ├── TeamSwitcher.tsx
│   ├── AlertsTab.tsx           # Manager
│   ├── TeamManagementTab.tsx   # Manager
│   ├── ProjectProgressTab.tsx  # Manager + Member
│   ├── SurveySettingsTab.tsx   # Manager
│   ├── MyWorkTab.tsx           # Member
│   ├── SurveyAnswerTab.tsx     # Member
│   └── TeamSummaryCard.tsx
└── hooks/
    ├── useSelectedTeam.ts      # localStorage + チーム切替
    └── useTeamRole.ts          # チームでのロール判定
```

### TeamSwitcher ロジック

```typescript
// useSelectedTeam.ts
function useSelectedTeam() {
  const { data: teams } = useTeams();
  const [selectedTeamId, setSelectedTeamId] = useState<string>(() =>
    localStorage.getItem('selectedTeamId') || ''
  );

  useEffect(() => {
    if (selectedTeamId) localStorage.setItem('selectedTeamId', selectedTeamId);
  }, [selectedTeamId]);

  // 1チームのみ → 自動選択、TeamSwitcher非表示
  // 複数チーム → Dropdown表示
  const showSwitcher = (teams?.length ?? 0) > 1;

  return { selectedTeamId, setSelectedTeamId, showSwitcher, teams };
}
```

### ロール別タブ構成

**Manager (選択チームでmanagerの場合):**
| タブ | デフォルト | コンポーネント |
|------|-----------|---------------|
| アラート | ✅ | AlertsTab — AlertSummaryCards + AlertCard[] |
| チーム管理 | | TeamManagementTab — TeamSummaryCard (MemberCount, PJCount, AlertCount, ConditionOverview + FlaggedMembers) |
| PJ進捗管理 | | ProjectProgressTab — ProjectSummaryCard[] |
| サーベイ設定 | | SurveySettingsTab — SurveyConfigByTeam |

**Member (選択チームでmemberの場合):**
| タブ | デフォルト | コンポーネント |
|------|-----------|---------------|
| マイワーク | ✅ | MyWorkTab — IssueGroupByProject[] |
| PJ進捗 | | ProjectProgressTab — ProjectSummaryCard[] |
| サーベイ回答 | | SurveyAnswerTab — PendingSurveyCard[] |

### データ要件

**Manager:**
| データ | エンドポイント |
|--------|--------------|
| アラート一覧 | `GET /alerts?status=active&team_id={teamId}` |
| チームサマリー | `GET /teams/{teamId}` |
| 不調検知 | `GET /teams/{teamId}/condition-summary` |
| PJ一覧 | `GET /projects?team_id={teamId}` |

**Member:**
| データ | エンドポイント |
|--------|--------------|
| アサイン済みIssue | `GET /issues?assignee=me&team_id={teamId}` |
| PJ一覧 | `GET /projects?team_id={teamId}` |
| 未回答サーベイ | `GET /surveys/my/pending?team_id={teamId}` |

### ConditionOverview (不調検知 S-05-02)

TeamSummaryCard内にFlaggedMembers[]を表示:
- チーム平均スコア表示
- 平均より下に乖離しているメンバーのアバター+名前+フラグ
- アバター/名前クリック → `/users/[userId]`

## 受け入れ基準

- [ ] TeamSwitcherが複数チーム所属時のみ表示される
- [ ] チーム切替でタブ構成が動的に変わる（manager/member）
- [ ] 選択チームがlocalStorageで記憶される
- [ ] Manager: 4タブ（アラート/チーム管理/PJ進捗/サーベイ設定）が表示される
- [ ] Member: 3タブ（マイワーク/PJ進捗/サーベイ回答）が表示される
- [ ] TeamManagementTabにConditionOverview（FlaggedMembers）が表示される
- [ ] `pnpm typecheck` がエラーなく通る

## やらないこと

- サーベイの回答フォーム実装（Phase 3A）
- AlertCardの実装（Phase 2Bの成果物を利用）
