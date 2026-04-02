## Plan: AI Analysis Phase 1 Foundation

This plan establishes the minimum async and persistence foundation required for Project Insights AI analysis in workspace-1. It makes queued execution real, adds durable analysis state storage, and wires the model and config surface needed by later API and frontend phases without implementing the AI flow yet.

**Task Type:** Code + Docs

**Phases 3**
1. **Phase 1: Enable Real Queue Execution**
    - **Objective:** Switch the worktree from queueable-in-name-only jobs to actual asynchronous queue processing suitable for 202 plus polling flows.
    - **Files/Functions to Modify/Create:** compose.yml, teamdev-2026-api/web/config/queue.php, teamdev-2026-api/web/.env.example, queue table migrations under teamdev-2026-api/web/database/migrations, and helper runtime wiring only if it is necessary to support the worker service.
    - **Tests to Write:** Backend test that verifies a future AI analysis job is queued rather than executed inline when the database queue connection is active, plus focused migration assertions for queue infrastructure where practical.
    - **Docs Impact:** Minimal in this phase; document only implementation decisions that become repository conventions.
    - **Steps:**
        1. Write a failing test that expresses the expected queued dispatch behavior for future AI analysis jobs.
        2. Add Laravel queue table migrations and configure the example environment for database-backed queues.
        3. Add a dedicated queue worker runtime in compose and rerun the focused test to confirm the async contract is structurally supported.

2. **Phase 2: Add AI Analysis Persistence Schema**
    - **Objective:** Create durable storage for processing, completed, and failed analysis results, including rate-limit lookup support.
    - **Files/Functions to Modify/Create:** AI analysis result migration under teamdev-2026-api/web/database/migrations and teamdev-2026-api/web/app/Models/AiAnalysisResult.php.
    - **Tests to Write:** Database assertions for required columns, nullability, casts, and indexes, plus focused tests that support recent-by-project queries for later rate limiting.
    - **Docs Impact:** specs/database/schema.md and docs/architecture/data-model.md to document the new ai_analysis_results table and its role.
    - **Steps:**
        1. Write failing schema and model expectations for the AI analysis result record.
        2. Add the ai_analysis_results migration with the spec-defined fields and indexes.
        3. Add the model with JSON and timestamp casts, then rerun the focused tests.

3. **Phase 3: Wire AI Runtime Configuration**
    - **Objective:** Prepare the backend configuration surface needed by later OpenAI client and job implementation without adding the client itself yet.
    - **Files/Functions to Modify/Create:** teamdev-2026-api/web/config/services.php and teamdev-2026-api/web/.env.example.
    - **Tests to Write:** Configuration resolution tests for OPENAI_API_KEY, OPENAI_MODEL, OPENAI_MAX_TOKENS, and OPENAI_TEMPERATURE.
    - **Docs Impact:** No spec change expected unless implementation reveals a mismatch with specs/features/project-insights-ai-analysis.md.
    - **Steps:**
        1. Write failing configuration expectations for the OpenAI settings that later phases will consume.
        2. Add OpenAI service config and environment placeholders with defaults aligned to the spec.
        3. Rerun the focused tests and confirm the groundwork is ready for later job and API phases.

**Open Questions 1**
1. Should framework queue tables be documented alongside domain tables, or should docs stay limited to ai_analysis_results?