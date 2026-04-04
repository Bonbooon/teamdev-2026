## Plan: Front PR 28 Build Review Fixes

This plan fixes the frontend PR 28 build failure in workspace-1 and addresses the still-valid survey chart test review comments on the same branch. The work stays scoped to the frontend branch and only syncs the root worktree if the frontend branch advances.

**Task Type:** Code-Only

**Phases 3**
1. **Phase 1: Address Survey Chart Review Feedback**
    - **Objective:** Make the survey chart tests verify the actual `SurveyScoreChart` sizing and axis contract rather than passing because of permissive mocks.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/__tests__/features/surveys/SurveyScoreChart.test.tsx`
    - **Tests to Write:** Update the existing `SurveyScoreChart` test cases to assert `ResponsiveContainer` width and height props, the explicit root container height, and the computed `YAxis` domain.
    - **Steps:**
        1. Refactor the `recharts` mocks so the tests can observe the props passed from `SurveyScoreChart`.
        2. Replace brittle global style selection with root-container assertions scoped to the rendered component.
        3. Run the targeted survey chart test file and confirm the updated assertions pass.

2. **Phase 2: Clear Frontend Build Blockers**
    - **Objective:** Remove the lint violations that currently fail the frontend Build Check workflow on PR 28.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/src/features/projects/components/ProgressBoard/GanttChart.tsx`, `teamdev-2026-front/src/features/projects/components/ProgressBoard/KanbanBoard.tsx`, `teamdev-2026-front/src/features/projects/components/__tests__/ProjectDetailPage-tabs.integration.test.tsx`
    - **Tests to Write:** Update the existing `ProjectDetailPage` tabs integration test setup to use import-based mocked hook references and rerun the affected suite.
    - **Steps:**
        1. Remove the unused prop bindings in `GanttChart` and `KanbanBoard` without changing their runtime behavior.
        2. Replace the forbidden `require()`-based mocked hook access in the integration test with static imports or typed mocked references.
        3. Run the targeted integration test and `pnpm build` to confirm the build blockers are gone.

3. **Phase 3: Review, Gate, And Sync PRs**
    - **Objective:** Verify the combined changes, run the required gates, and sync the linked root PR if the frontend branch advances.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/`, `plans/`
    - **Tests to Write:** None; verification uses the existing frontend checks and workspace quality gates.
    - **Steps:**
        1. Run code review on the frontend changes from the completed phases.
        2. Run frontend verification plus `./scripts/quality-gates.sh` from the workspace-1 root.
        3. Prepare the frontend and root follow-up diffs needed to update PR 28 and PR 51.

**Open Questions 2**
1. Sync root PR 51 after the frontend branch moves? Recommended answer: yes.
2. Any docs impact expected? Current answer: no, unless the implementation reveals behavior drift.