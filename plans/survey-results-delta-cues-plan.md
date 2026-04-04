## Plan: Refine Survey Delta Cues

Refine the survey results member-row cues so the delta badge reads exactly as requested and the expand affordance no longer looks like a downward score indicator. The change stays frontend-only and is validated phase by phase with review, quality gates, commits, and pushes.

**Task Type:** Code-Only

**Phases 3**
1. **Phase 1: Align Delta Badge Colors**
    - **Objective:** Make the member delta badge styling match the requested semantics exactly: red below average, black when equal, green above.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/src/features/surveys/components/SurveyResultsTab.tsx`, `teamdev-2026-front/src/features/surveys/components/__tests__/SurveyResultsTab.test.tsx`
    - **Tests to Write:** Badge-state assertions for below/equal/above team average.
    - **Steps:**
        1. Add or tighten tests for red, black, and green delta states.
        2. Update the zero-delta styling so it reads as black rather than neutral gray while preserving the no-data placeholder state.
        3. Run focused frontend tests, review the change, run full workspace quality gates, and then commit and push the phase.

2. **Phase 2: Replace Expand Icon**
    - **Objective:** Replace the member-row detail toggle icon with a simple chevron `V` so it cannot be mistaken for a negative delta.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/src/features/surveys/components/SurveyResultsTab.tsx`, `teamdev-2026-front/src/features/surveys/components/__tests__/SurveyResultsTab.test.tsx`
    - **Tests to Write:** Expand-control rendering assertion for the chevron icon behavior if needed.
    - **Steps:**
        1. Update the SVG path to a simple chevron while keeping the current expand/collapse rotation behavior.
        2. Confirm the existing member expansion interaction still behaves correctly.
        3. Review the change, run full workspace quality gates, and then commit and push the phase.

3. **Phase 3: Final Review And Validate**
    - **Objective:** Re-verify the combined survey-results follow-up and close the task cleanly.
    - **Files/Functions to Modify/Create:** Completion records in `worktrees/workspace-1/plans/`.
    - **Tests to Write:** None; run existing validation only.
    - **Steps:**
        1. Review the final combined diff for regressions and UI clarity.
        2. Run `./scripts/quality-gates.sh` from `worktrees/workspace-1`.
        3. Record plan completion and push the final close-out commit.

**Open Questions 1**
1. No open product ambiguity remains; use explicit black text for the equal-to-team-average badge while keeping the neutral `--` no-data state distinct.