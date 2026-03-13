# Alert System Architecture

This document describes the alert architecture that is currently implemented in the API worktree.  
It focuses on the Phase 1 alert pipeline for project progress delay detection.

---

# 1. Core Design Principle

Do **not** create separate boolean/timestamp columns in each business table to track whether an alert has been sent.

Example of what **not** to do:

- `tasks.overdue_notified_at`
- `surveys.reminder_sent_at`
- `users.inactivity_warning_sent_at`

This approach tightly couples alert logic to the schema and becomes difficult to maintain as the number of alert types grows.

Instead, alert triggers are managed **centrally** through trigger definitions and execution logs.

---

# 2. Persisted Structures

The current implementation uses the following tables:

### `trigger_definitions`

Stores dev-configured trigger metadata.

| column | description |
|------|-------------|
| id | UUID primary key |
| name | human-readable trigger name |
| trigger_class | evaluator class name |
| target_type | `project`, `issue`, `team_member` |
| condition_type | trigger rule type |
| condition_value | optional scalar threshold |
| condition_params | JSON thresholds/metadata |
| alert_level | default alert level |
| is_active | whether the definition is active |

### `trigger_execution_logs`

Records each evaluation/trigger outcome.

| column | description |
|------|-------------|
| id | primary key |
| trigger_definition_id | FK to `trigger_definitions` |
| target_entity_id | evaluated project/issue/member id |
| status | `evaluated` or `triggered` |
| metadata | optional JSON payload (alert level, description) |
| triggered_at | timestamp of evaluation |

### Alert aggregate tables

- `alerts`: active/resolved alert records per project/category
- `alert_logs`: repeated trigger history for an alert
- `alert_action_plan_suggestions`: pivot rows connecting alerts to seeded action plans
- `email_delivery_logs`: email send success/failure audit for the queued SendGrid job

---

# 3. Scheduler Strategy

Phase 1 uses a coarse-grained scheduled command.

Laravel scheduler entrypoint:

```bash
php artisan schedule:run
```

Laravel scheduler configuration:

```php
$schedule->command('alerts:process')->hourly()->withoutOverlapping();
```

Current command behavior:

1. `alerts:process` loads all `in_progress` projects
2. The command iterates the collection in chunks of 100
3. `AlertTriggerService` filters registered evaluators to `project` target type only
4. Each evaluator calculates metrics and returns either `null` or a `TriggerResult`
5. The service always writes a `trigger_execution_logs` row
6. Triggered results create or reuse an alert and append `alert_logs` subject to cooldown

This is simpler than the original time-window design, but it means processing cost grows with the number of active projects.

---

# 4. Duplicate Prevention and Cooldown

The current implementation prevents noisy duplicates in two layers:

1. Active alert reuse
    Existing unresolved alerts are looked up by project and category. A new `alerts` row is created only when no active alert exists.

2. Alert log cooldown
    Additional `alert_logs` rows are rate-limited:
    - yellow: 24 hours
    - red: 6 hours

`trigger_execution_logs` remain append-only and are used as an audit trail, not as the primary duplicate-prevention mechanism.

---

# 5. Trigger Coverage in Phase 1

Implemented evaluators in code:

- `ProjectProgressDelayTrigger`
- `IssueProgressDelayTrigger`
- `WorkloadOverloadTrigger`

Active in scheduled processing:

- `ProjectProgressDelayTrigger` only

Deferred to Phase 2:

- issue-level evaluation
- team-member workload evaluation
- the iteration contexts needed to invoke those evaluators from `alerts:process`

---

# 6. Email Job Processing

SendGrid delivery has been prepared as queue-backed infrastructure:

1. `AlertEmailService` builds a payload and dispatches `SendAlertEmail`
2. `SendAlertEmail` runs on the `emails` queue
3. `EmailDeliveryLog` records success or final failure

Queue worker command:

```bash
php artisan queue:work
```

Important current limitation:

- `AlertTriggerService` does not currently call `AlertEmailService`
- As a result, `alerts:process` creates alerts/logs/suggestions but does not send emails yet
---

# 7. Infrastructure Requirements

The following background processes are relevant:

- Laravel scheduler (`schedule:run`)
- Queue workers (`queue:work`) once alert email dispatch is wired into the trigger flow

These can run as container services (e.g., on AWS ECS).

---

# 8. Benefits of Current Architecture

This design provides:

- Centralized trigger metadata via `trigger_definitions`
- Auditable evaluation history via `trigger_execution_logs`
- Separation between alert state, trigger execution, and email delivery logs
- No schema pollution
- Reviewable path toward future trigger types
- Basic idempotent alert processing for project-level alerts

The main tradeoff is scalability: the current implementation scans all in-progress projects hourly rather than using a bounded time-window query model.

---

# 9. Recommended Follow-up

The main gaps between architecture and product intent are:

- wire `AlertEmailService` into the trigger flow
- implement alert resolution/reopen lifecycle
- add alert read/resolve HTTP endpoints
- enable issue/team-member trigger iteration in Phase 2
- revisit `alerts:process` scalability if the number of active projects grows significantly

In addition, future phases must complete and enable all planned alert categories, not only the currently active project-level category.

If docs should match product intent (not only current code), prioritize these implementation gaps first:

- wire `AlertEmailService` into `alerts:process`
- add alert read/resolve endpoints
- implement actual resolution/reopen lifecycle
