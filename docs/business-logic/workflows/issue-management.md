# Issue Management Workflow

> Corresponds to: `specs/business/issue-management.md` (S-03-01 through S-03-08)

## Issue Lifecycle

### 1. Issue Creation (S-03-01)

A team member or project manager creates an issue within a project scope:

- **Required**: title, template, at least one team, at least one assignee, at least one Definition of Done item, story points, estimated minutes, deadline
- Initial status: `not_in_progress`
- `issue_template_id` must reference an existing template record
- `templateItemValues` keys must match the selected template's `itemKey` values (mapped to the DB column `item_key`); unknown keys are rejected before issue creation with field-level validation errors

### 2. Assignee Management (S-03-02)

- Assignees must be team members belonging to one of the issue's assigned teams
- At least one assignee is required before work can begin
- Removing the last assignee is prevented by domain validation

### 3. Definition of Done (S-03-04)

- DoD items are description-based checklist entries
- Each item tracks `is_completed` (boolean)
- Completion rate feeds into progress calculation (40% weight)

### 4. Status Transitions (S-03-05)

Valid transitions enforced by `StatusTransitionValidator`:

```
not_in_progress → in_progress
in_progress → in_review
in_review → done
in_review → in_progress (revision)
done → in_progress (reopen)
```

Every transition creates an `IssueStatusEvent` audit record.

### 5. Subtask Management (S-03-06)

- Subtasks are child issues (`parent_issue_id` set)
- Must belong to the same project as parent
- Subtask completion rate feeds into progress calculation (30% weight)

### 6. Progress Calculation (S-03-08)

`ProgressCalculationService` computes weighted progress:

| Component | Weight | Source |
|-----------|--------|--------|
| DoD completion | 40% | Completed items / Total items |
| Subtask completion | 30% | Done subtasks / Total subtasks |
| Time progress | 30% | Logged minutes / Estimated minutes |

If a component has no data (e.g., no subtasks), its weight is redistributed proportionally.

### 7. Work Log Recording

- Manual time logging by team members
- Current API contract is available via `GET/POST /api/issues/{issueId}/work-logs` and `PATCH/DELETE /api/issues/{issueId}/work-logs/{workLogId}`
- Write requests accept `minutes`, optional `description`, and optional `logged_at`
  - `logged_at` maps to the domain model's `started_at`. The storage model also includes an optional/nullable `ended_at` column; for manual work logs, `ended_at` is not provided by the client and duration is derived from `minutes` (the column may remain null or be populated by internal processes or other integrations).
- Source enum: `manual`, `github_api`, `github_actions`
- `GET /api/issues/{issueId}/work-logs` returns `workLogs: []` when the issue does not exist
- GitHub-based sources deferred to Phase 2 (per ADR 0008)

### 8. Template Management (S-03-03)

Templates are **global** (not project-scoped):

- Templates have a name, description, and active flag
- `GET /api/issue-templates` returns active templates together with embedded template item definitions
- Template items define field schema: item_key, label, value_type, is_required, position
- Supported value types: string, integer, date, datetime, boolean, number, json
- Issues can optionally reference a template; template values are stored per-issue
