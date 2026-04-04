## Phase 1 Complete: Add Team Average Summary

Implemented the survey results summary team average metric using the existing per-question `averageScore` data, then synced the authoritative UI docs to match the shipped behavior. This phase stayed frontend-only in product logic and passed the full workspace quality gates.

**Files created/changed:**
- teamdev-2026-front/src/features/surveys/components/SurveyResultsTab.tsx
- teamdev-2026-front/src/features/surveys/components/__tests__/SurveyResultsTab.test.tsx
- teamdev-2026-front/__tests__/features/surveys/SurveyResultsTab.test.tsx
- docs/ui-pages/project-detail.md
- docs/ui-specification.md

**Functions created/changed:**
- SurveyResultsTab
- calculateTeamAverage

**Tests created/changed:**
- SurveyResultsTab summary renders `チーム平均スコア`
- SurveyResultsTab handles missing and mixed `averageScore` values
- SurveyResultsTab preserves single-question and two-decimal formatting behavior
- SurveyResultsTab integration summary shows the displayed team average value

**Docs synced/created:**
- docs/ui-pages/project-detail.md
- docs/ui-specification.md

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (formatter, linter, tests, typecheck)

**Docs Sync Status:** Synced

**Git Commit Message:**
```
feat(surveys): add team average to survey results summary

Show a compact team average in the survey results tab using
existing per-question average scores so managers can compare
project-wide sentiment at a glance. Sync the UI docs to the
shipped summary behavior.
```