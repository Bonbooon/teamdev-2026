## Plan: Survey Score Chart Render Fix

Investigate and fix the survey score chart so it renders reliably inside the project survey results tab without Recharts emitting invalid startup size warnings. The work will lock the failure mode in tests, simplify the chart sizing contract, and verify the survey tab still renders correctly inside the workspace-1 frontend worktree.

**Task Type:** Code-Only

**Phases**
1. **Phase 1: Lock Current Failure Mode**
    - **Objective:** Add or adjust frontend tests so the chart startup sizing behavior is covered before changing implementation.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/__tests__/features/surveys/SurveyScoreChart.test.tsx`
    - **Tests to Write:** `renders chart after size becomes available`, `does not stay stuck in fallback on first valid render`, `uses a stable container size contract`
    - **Steps:**
        1. Review the existing chart tests and identify gaps around first-render sizing.
        2. Add or refine failing tests that model the invalid initial size and successful subsequent render.
        3. Run the targeted frontend test file to confirm the new assertions fail or expose the current behavior.

2. **Phase 2: Fix Chart Sizing Contract**
    - **Objective:** Update the survey chart component to avoid the invalid Recharts startup dimension path and render consistently inside the survey results card.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/src/features/surveys/components/SurveyScoreChart.tsx`, `teamdev-2026-front/src/features/surveys/components/SurveyResultsTab.tsx`
    - **Tests to Write:** `renders chart with stable height`, `keeps survey results chart visible when survey tab mounts`
    - **Steps:**
        1. Implement the smallest change that removes the unstable percentage height startup path.
        2. Keep the existing loading and empty-state behavior intact unless the fix requires a narrower change.
        3. Re-run the targeted tests and adjust assertions only where the new sizing contract changes expected behavior.

3. **Phase 3: Verify Integration and Quality Gates**
    - **Objective:** Confirm the survey tab remains correct in the broader project detail flow and pass the required frontend quality gates.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/__tests__/features/surveys/SurveyScoreChart.test.tsx`, `teamdev-2026-front/__tests__/features/surveys/SurveyResultsTab.test.tsx`
    - **Tests to Write:** `survey results tab renders chart content with real chart component coverage if needed`
    - **Steps:**
        1. Review whether the survey results tab tests need minor integration coverage after the component fix.
        2. Run the required frontend checks and the repo quality gates from the workspace-1 worktree.
        3. Prepare the final completion summary once the worktree changes are verified.

**Open Questions**
1. Should the final fix keep the custom fallback skeleton path, or can it be simplified if Recharts sizing becomes deterministic?
2. Is a root worktree commit updating the frontend submodule pointer expected after the frontend repo commit, or should this task remain committed only in the frontend repo?