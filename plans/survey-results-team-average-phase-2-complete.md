## Phase 2 Complete: Add Per-Member Delta Context

Implemented compact per-member delta indicators in the survey results tab so each member row shows how its average compares with the team baseline. Members without valid scored answers now render a neutral `--` state instead of a misleading negative comparison, and the authoritative UI docs were synced to match.

**Files created/changed:**
- teamdev-2026-front/src/features/surveys/components/SurveyResultsTab.tsx
- teamdev-2026-front/src/features/surveys/components/__tests__/SurveyResultsTab.test.tsx
- docs/ui-pages/project-detail.md
- docs/ui-specification.md

**Functions created/changed:**
- SurveyResultsTab
- getDeltaClasses
- formatDelta

**Tests created/changed:**
- SurveyResultsTab renders positive delta badges
- SurveyResultsTab renders negative delta badges
- SurveyResultsTab renders exact zero delta output
- SurveyResultsTab renders neutral `--` when no member comparison is available
- SurveyResultsTab preserves mixed delta states across multiple members

**Docs synced/created:**
- docs/ui-pages/project-detail.md
- docs/ui-specification.md

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (formatter, linter, tests, typecheck)

**Docs Sync Status:** Synced

**Git Commit Message:**
```
feat(surveys): show member delta against team average

Add a compact per-member delta in survey results so project
managers can compare individual scores against the team
baseline at a glance, while keeping no-answer rows neutral.
```