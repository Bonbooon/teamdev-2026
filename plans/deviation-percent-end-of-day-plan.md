## Plan: End-of-Day Deviation Percent

Change `deviationPercent` from whole-project totals to an end-of-day cumulative metric for project insights, keep chart buckets as visualization-only data, and update the spec plus API contract text so the behavior is explicit. Scope includes the progress-chart API, AI context alignment, and generated OpenAPI/client artifacts; the alert trigger is intentionally left unchanged.

**Task Type:** Code + Docs

**Phases (3 phases)**

1. **Phase 1: Progress Chart End-of-Day Semantics**
    - **Objective:** Update the project insights feature spec and the progress-chart backend so `deviationPercent` is calculated at `min(now()->endOfDay(), project.due_at)` using cumulative planned and actual points up to that cutoff, independent of the selected chart interval.
    - **Files/Functions to Modify/Create:**
        - `specs/features/project-insights-chart.md` — clarify `deviationPercent` semantics and examples
        - `teamdev-2026-api/web/app/Application/Project/UseCases/GetProgressChartUseCase.php` — update `execute()` and extract an end-of-day cumulative helper
        - `teamdev-2026-api/web/app/Interfaces/Http/Controllers/Project/ProgressChartController.php` — clarify OpenAPI description for `deviationPercent`
        - `teamdev-2026-api/web/app/Application/Project/DTOs/ProgressChartData.php` — confirm DTO remains shape-compatible
        - `teamdev-2026-api/web/tests/Feature/Interfaces/Http/Project/ProgressChartControllerTest.php` — add regression coverage and update old total-based expectation
    - **Tests to Write:**
        - `test_deviation_percent_uses_end_of_day_cumulative_points` — future-heavy backlog does not count toward today's deviation
        - `test_deviation_percent_excludes_actual_points_closed_after_end_of_day` — actual cumulative respects the same cutoff
        - `test_deviation_percent_clamps_cutoff_to_project_due_at` — overdue projects do not evaluate beyond due_at
    - **Docs Impact:**
        - `specs/features/project-insights-chart.md`
        - OpenAPI property description in `ProgressChartController.php`
    - **Steps:**
        1. Write the new progress-chart feature tests and run them to capture the current failure.
        2. Update the feature spec language so the desired behavior is explicit before finalizing implementation.
        3. Implement the end-of-day cumulative helper and switch `deviationPercent` to use it while keeping bucket generation and totals intact.
        4. Update the controller annotation text for `deviationPercent`.
        5. Run the targeted progress-chart tests again and confirm they pass.

2. **Phase 2: AI Context Deviation Alignment**
    - **Objective:** Align the AI project context's `deviationPercent` with the same end-of-day cumulative semantics so AI analysis uses the same project health definition as the progress chart.
    - **Files/Functions to Modify/Create:**
        - `teamdev-2026-api/web/app/Application/Project/Services/AiContextCollector.php` — update project-level deviation calculation and add end-of-day cutoff helper(s)
        - `teamdev-2026-api/web/tests/Unit/Application/Project/Services/AiContextCollectorTest.php` — add/update project metric assertions
        - `teamdev-2026-api/web/app/Application/Project/Services/AiPromptBuilder.php` — verify prompt wording still matches the updated semantics
    - **Tests to Write:**
        - `test_collect_project_data_uses_end_of_day_cumulative_deviation` — project metrics exclude future planned work
        - `test_collect_project_data_clamps_deviation_cutoff_to_due_at` — overdue projects use due_at as the cap
    - **Docs Impact:**
        - None expected unless implementation reveals prompt/document wording drift
    - **Steps:**
        1. Add the AI context tests that demonstrate the semantic mismatch and run them to see the failure.
        2. Implement the same end-of-day cumulative logic inside `AiContextCollector`.
        3. Verify `AiPromptBuilder` wording remains accurate for the new metric semantics.
        4. Run the targeted AI context tests and any dependent prompt tests.

3. **Phase 3: Contract Sync, Codegen, and Consumer Verification**
    - **Objective:** Regenerate API/frontend OpenAPI artifacts, verify generated client docs stay in sync, and confirm frontend consumers continue to work with the updated metric value.
    - **Files/Functions to Modify/Create:**
        - `teamdev-2026-api/docs/openapi/openapi.json` — regenerated from backend annotations
        - `teamdev-2026-front/openapi/openapi.json` — regenerated frontend snapshot
        - `teamdev-2026-front/src/api/api/projects/_projectId@string/progress-chart/index.ts` — regenerated aspida client output
        - `teamdev-2026-front/src/features/projects/components/InsightsTab.tsx` — consumer verification only; no behavior change expected
        - `teamdev-2026-front/src/features/projects/components/__tests__/InsightsTab.test.tsx` — only if generated/doc-related assertions need adjustment
    - **Tests to Write:**
        - No new product tests expected; rely on code generation plus targeted frontend verification that existing threshold behavior still passes.
    - **Docs Impact:**
        - Generated OpenAPI and client artifacts must reflect the updated contract text
    - **Steps:**
        1. Run the repo OpenAPI generation workflow after the backend annotation change.
        2. Review generated API and frontend artifacts for the updated `deviationPercent` description.
        3. Run the relevant frontend verification to confirm consumers remain numeric-threshold based.
        4. Run final quality gates across the completed plan.

**Open Questions**
1. Should `totalPlannedPoints` and `totalActualPoints` remain their existing overall chart totals while only `deviationPercent` changes semantics? Assumption for this plan: yes, to keep the response contract minimally disruptive.