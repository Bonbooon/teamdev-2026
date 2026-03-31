## Phase 5 Complete: Replace team projects placeholder with live project list

Replaced the TeamDetailPage projects-tab placeholder with a connected `ProjectList` that fetches team-scoped projects, renders loading/error/empty states, and links each project to its detail page with status and due-date context. This phase passed review, synced the affected team-detail docs, and cleared the full workspace quality gates in `workspace-1`.

**Files created/changed:**
- `teamdev-2026-front/src/features/teams/components/TeamDetailPage.tsx`
- `teamdev-2026-front/src/features/teams/components/ProjectList.tsx`
- `teamdev-2026-front/src/features/teams/components/__tests__/ProjectList.test.tsx`
- `docs/ui-pages/team-detail.md`
- `docs/ui-specification.md`

**Functions created/changed:**
- `TeamDetailPage()`
- `ProjectList()`

**Tests created/changed:**
- `src/features/teams/components/__tests__/ProjectList.test.tsx`

**Docs synced/created:**
- `docs/ui-pages/team-detail.md`
- `docs/ui-specification.md`
- `plans/complete-ui-components-phase-5-complete.md`

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (`./scripts/quality-gates.sh` in `workspace-1`)

**Docs Sync Status:** Synced

**Git Commit Message:**
`feat(teams): show team projects in detail view`