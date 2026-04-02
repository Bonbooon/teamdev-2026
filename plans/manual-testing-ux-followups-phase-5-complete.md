## Phase 5 Complete: Work Log Permission Contract and UI

Updated the issue-detail worklog flow so manager permissions are honored in the API, the issue detail contract exposes worklog mutation capability, and the frontend only enables worklog create / edit / delete affordances when the current viewer is allowed to use them. This phase also synced OpenAPI and generated client output, kept docs current, and preserved exact API `message` text in worklog mutation failures.

**Files created/changed:**
- teamdev-2026-api/web/app/Application/Issue/UseCases/DeleteWorkLogUseCase.php
- teamdev-2026-api/web/app/Application/Issue/UseCases/UpdateWorkLogUseCase.php
- teamdev-2026-api/web/app/Interfaces/Http/Controllers/Issue/IssueController.php
- teamdev-2026-api/web/tests/Feature/Interfaces/Http/Issue/IssueControllerTest.php
- teamdev-2026-api/web/tests/Feature/Interfaces/Http/Issue/WorkLogControllerTest.php
- teamdev-2026-api/docs/openapi/openapi.json
- teamdev-2026-front/openapi/openapi.json
- teamdev-2026-front/src/api/$api.ts
- teamdev-2026-front/src/api/api/issues/_issueId@string/index.ts
- teamdev-2026-front/src/features/issues/components/IssueDetailPage.tsx
- teamdev-2026-front/src/features/issues/components/WorkLogSection.tsx
- teamdev-2026-front/src/features/issues/components/__tests__/WorkLogSection.test.tsx
- teamdev-2026-front/src/features/issues/hooks/useIssue.ts
- docs/ui-pages/issue-detail.md
- docs/ui-specification.md

**Functions created/changed:**
- IssueController::show
- IssueController::storeWorkLog
- IssueController::updateWorkLog
- IssueController::deleteWorkLog
- IssueController::resolveWorkLogTeamMember
- IssueController::isUserManagerOfIssueTeams
- UpdateWorkLogUseCase::execute
- DeleteWorkLogUseCase::execute
- IssueDetailPage worklog capability plumbing
- WorkLogSection permission-guarded empty state and mutation handling
- WorkLogSection::extractErrorMessage

**Tests created/changed:**
- WorkLogControllerTest::test_manager_can_create_work_log_without_assignee_status
- WorkLogControllerTest::test_manager_can_update_other_members_work_log
- WorkLogControllerTest::test_manager_can_delete_other_members_work_log
- WorkLogControllerTest::test_non_manager_cannot_create_work_log_as_outsider
- IssueControllerTest::test_get_issue_detail_includes_can_mutate_work_logs_true_for_team_members
- IssueControllerTest::test_get_issue_detail_includes_can_mutate_work_logs_false_for_non_members
- WorkLogSection permission gating and exact-message toast coverage

**Docs synced/created:**
- docs/ui-pages/issue-detail.md
- docs/ui-specification.md

**Review Status:** APPROVED

**Quality Gates Status:** ✅ PASSED (backend `scripts/fmtl.sh`, backend full Laravel suite via `docker compose exec app php artisan test`, frontend `pnpm check`, `pnpm check:fix`, `pnpm format`, `pnpm lint:fix`, `pnpm typecheck`, `pnpm test`, `pnpm openapi`, final `pnpm typecheck`)

**Docs Sync Status:** Synced

**Git Commit Message:**
```
API: feat(api): expose work log mutation capabilities
FRONT: feat(front): guard work log mutations by capability
ROOT: docs(workspace): sync issue detail worklog follow-ups
```