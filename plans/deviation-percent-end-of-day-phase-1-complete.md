## Phase 1 Complete: Progress Chart End-of-Day Semantics

Updated the progress-chart `deviationPercent` metric to use end-of-day cumulative semantics instead of whole-project totals, and synced the project insights spec plus API contract text to that behavior. This phase also included a formatter-only frontend cleanup required to satisfy the repo quality gates in the main worktree.

**Files created/changed:**
- `plans/deviation-percent-end-of-day-plan.md`
- `specs/features/project-insights-chart.md`
- `teamdev-2026-api/web/app/Application/Project/UseCases/GetProgressChartUseCase.php`
- `teamdev-2026-api/web/app/Interfaces/Http/Controllers/Project/ProgressChartController.php`
- `teamdev-2026-api/web/tests/Feature/Interfaces/Http/Project/ProgressChartControllerTest.php`
- `teamdev-2026-front/__tests__/features/projects/InsightsTab-loading.test.tsx` (formatting only)
- `teamdev-2026-front/src/api/$api.ts` (formatting only)
- `teamdev-2026-front/src/api/api/projects/_projectId@string/ai-analyses/index.ts` (formatting only)
- `teamdev-2026-front/src/api/api/projects/_projectId@string/ai-analyses/_analysisId@string/index.ts` (formatting only)
- `teamdev-2026-front/src/features/projects/components/AiAnalysisHistory.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/AiAnalysisResult.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/AiAnalysisSection.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/ChartFilterBar.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/InsightsTab.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/__tests__/AiAnalysisHistory.test.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/__tests__/AiAnalysisResult.test.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/__tests__/AiAnalysisSection.test.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/components/__tests__/InsightsTab.test.tsx` (formatting only)
- `teamdev-2026-front/src/features/projects/hooks/__tests__/useAiAnalysis.test.ts` (formatting only)
- `teamdev-2026-front/src/features/projects/hooks/__tests__/useAiAnalysisHistory.test.ts` (formatting only)
- `teamdev-2026-front/src/features/projects/hooks/useAiAnalysis.ts` (formatting only)
- `teamdev-2026-front/src/features/projects/hooks/useAiAnalysisHistory.ts` (formatting only)
- `teamdev-2026-front/src/features/projects/utils/formatAiTimestamp.ts` (formatting only)

**Functions created/changed:**
- `GetProgressChartUseCase::execute()`
- `GetProgressChartUseCase::calculateCumulativeAtTime()`
- `ProgressChartController` OpenAPI response annotation for `deviationPercent`

**Tests created/changed:**
- `test_deviation_percent_uses_end_of_day_cumulative`
- `test_future_planned_work_excluded_from_deviation_percent`
- `test_actual_points_closed_after_eod_excluded_from_deviation_percent`
- `test_overdue_project_clamps_evaluation_at_to_due_at`

**Docs synced/created:**
- `specs/features/project-insights-chart.md`
- `ProgressChartController.php` OpenAPI description for `deviationPercent`

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (formatter, linter, tests, typecheck)

**Docs Sync Status:** Synced

**Git Commit Message:**
```
fix(api): use end-of-day deviation percent
```