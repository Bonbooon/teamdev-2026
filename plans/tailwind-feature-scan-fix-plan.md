## Plan: Fix Tailwind Feature Scan

Patch the frontend styling regression by fixing Tailwind’s content scan scope so utilities used in `src/features` are actually generated. The work stays frontend-only, validates the survey-results surface that exposed the issue, and closes with full workspace quality gates green.

**Task Type:** Code-Only

**Phases 3**
1. **Phase 1: Add Tailwind Regression Coverage**
    - **Objective:** Lock the root cause down with a small regression check and patch the Tailwind content scan configuration.
    - **Files/Functions to Modify/Create:** `teamdev-2026-front/tailwind.config.ts`, regression test under `teamdev-2026-front/__tests__/`
    - **Tests to Write:** Regression test asserting Tailwind content scanning includes `src/features`.
    - **Steps:**
        1. Add a failing regression check for the Tailwind content paths.
        2. Update the Tailwind content configuration so feature components are scanned.
        3. Run focused frontend validation, review the change, run full workspace quality gates, and then commit and push the phase.

2. **Phase 2: Validate Survey Styling Path**
    - **Objective:** Re-verify the survey-results styling path that exposed the issue and confirm no secondary fix is needed.
    - **Files/Functions to Modify/Create:** Phase completion record in `worktrees/workspace-1/plans/` if no further product-code change is required.
    - **Tests to Write:** None beyond existing validation unless a second issue is discovered.
    - **Steps:**
        1. Review the config fix against the survey-results component surface.
        2. Run full workspace quality gates from `worktrees/workspace-1`.
        3. Record the validated phase state and commit and push the phase.

3. **Phase 3: Final Review And Close**
    - **Objective:** Close the investigation with final validation and completion records.
    - **Files/Functions to Modify/Create:** Completion records in `worktrees/workspace-1/plans/`.
    - **Tests to Write:** None.
    - **Steps:**
        1. Run final review on the completed config fix.
        2. Reconfirm full workspace quality gates are green.
        3. Record completion and commit and push the final close-out.

**Open Questions 1**
1. No product ambiguity remains; use the minimal config fix by adding `./src/features/**/*.{js,ts,jsx,tsx,mdx}` to Tailwind content scanning rather than broadening the scan to all of `src/**/*`.