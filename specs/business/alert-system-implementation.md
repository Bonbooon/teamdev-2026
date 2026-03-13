# Alert System Implementation Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/business-logic/workflows/alert-system.md`  
**Domain Model:** `docs/diagrams/domain-models/alert-aggregate.puml`  
**Strategy Reference:** `docs/business-logic/prototype-strategy.md`

---

## Purpose

Define the complete alert system implementation for Phase 1, including:
- All 8 alert categories and their trigger conditions
- Yellow/Red severity levels
- Alert creation, resolution, and logging
- Suggested action generation and delivery
- Email notification via SendGrid

This spec is the **operational definition** of alerts described in `specs/business/alert-system.md`.

---

## Scope

**MUST Features (Phase 1):**
- S-02-01: Alert List Board (display)
- S-02-03: Project Progress Delay Alert (yellow/red triggers) ✅ **Implemented in Phase 1**
- S-02-04: Issue Progress Delay Alert (yellow/red triggers) ⏳ **Deferred to Phase 2**
- S-02-05: Workload Overload Alert (yellow/red triggers) ⏳ **Deferred to Phase 2**
- S-02-10: Action Suggest (display suggested actions with alerts)

> **Phase 1 Implementation Note**: The first release focuses on **project-level triggers only** (S-02-03).
> Issue-level (S-02-04) and team-member-level (S-02-05) triggers are fully coded and tested but
> disabled in the service provider until Phase 2, when the evaluation context for iterating
> project issues and team members is implemented. This allows us to validate the core alert
> infrastructure with a simpler scope first.

**WANT Features (Phase 1, lower priority):**
- S-02-02: Detailed Alert List
- S-02-06: Communication Gap Alert
- S-02-07: Key Person Absence Alert
- S-02-08: Document Stagnation Alert
- S-02-09: Assignment Paralysis Alert

**Out of Scope (Phase 2+):**
- PM customization of trigger thresholds
- Advanced analytics
- Alert history/trending

---

## Domain Entities

### Alert (Aggregate Root)
- `id: UUID`
- `projectId: UUID` - Scoped to exactly one project
- `description: String` - Human-readable description
- `level: AlertLevel` - "yellow" or "red"
- `isResolved: Boolean` - true when resolved
- `createdAt: DateTime`

### AlertLevel Enum
```
red    - Critical, immediate action required
yellow - Early warning, preventive action possible
```

### AlertLog (Entity)
- `id: BigInt` - Sequence ID for time-series analysis
- `alertId: UUID`
- `triggeredAt: DateTime`
- `resolvedAt: DateTime?` - Null if still open

**Purpose:** Track each time alert triggers; allows trend analysis ("flapping alerts")

### ActionPlan (Entity)
- `id: UUID`
- `code: String` - Machine-readable identifier (e.g., "decompose-tasks")
- `title: String` - Human-readable action title
- `description: String` - Full description of the action
- `createdAt: DateTime`

### AlertActionPlanSuggestion (Entity)
- `alertId: UUID`
- `actionPlanId: UUID`
- `priority: Int` - 1 (highest), 2, 3 (lower suggestions)
- `rationale: Json?` - Context-specific data explaining why this action
- `suggestedAt: DateTime`

**Rationale JSON Example:**
```json
{
  "currentProgress": 35.5,
  "expectedProgress": 50.0,
  "progressGap": -14.5,
  "daysRemaining": 10,
  "tasksRemaining": 45,
  "projectedCompletionDate": "2026-03-30"
}
```

---

## Alert Categories & Triggers

### Category 1: Project Progress Delay (S-02-03)

**Purpose:** Alert PM that entire project timeline is at risk

**🟡 Yellow Trigger:**
- Timeline milestone: Reached 50% of total timeline
- Progress check: Completed < 50% of tasks
- Duration: Condition persists for 1+ day

**Logic:**
```
IF (daysElapsed / totalDays) >= 0.50
   AND (tasksCompleted / totalTasks) < 0.50
   AND isYellowAlertActive = false
THEN createAlert(yellow)
```

**🔴 Red Trigger:**
- Velocity-based prediction: Remaining work projected beyond deadline
- Calculation: `(tasksRemaining / avgCompletionRatePerDay) > daysRemaining`

**Action Suggestions (Yellow):**
1. Priority: "Reprioritize top 3 blocked tasks"
2. Priority: "Decompose large tasks to unblock dependencies"
3. Priority: "Reallocate team members to critical path"

**Action Suggestions (Red):**
1. Priority: "Emergency meeting: scope reduction necessary"
2. Priority: "Propose deadline extension options"
3. Priority: "Simulate adding temporary resources"

---

### Category 2: Individual Issue Progress Delay (S-02-04)

**Purpose:** Alert PM/assignee that specific task is falling behind

**🟡 Yellow Trigger:**
- Timeline milestone: 50% of issue deadline elapsed
- Progress check: Issue status still "not_in_progress" or minimal completion
- Logic: Issue is not started, but 50% of time is gone

**🔴 Red Trigger:**
- Projected completion beyond deadline
- Logic: `(remainingWorkEstimate / avgWorkPerDay) > daysRemaining`
- Alternative: Issue deadline passed but status not "done"

**Action Suggestions:**
- "Start work immediately on this task"
- "Request help from [team members with expertise]"
- "Reduce scope of this task"

---

### Category 3: Workload Overload (S-02-05)

**Purpose:** Alert PM that team member capacity is exceeded

**🟡 Yellow Trigger:**
- Estimated work on active issues > available work hours for next 5 days
- Logic: `SUM(estimatedMinutes for active issues) > (teamMemberAvailableHours * 60 * 5 days)`

**🔴 Red Trigger:**
- Overallocation by >150%
- Logic: `estimatedMinutes > (availableHours * 60 * 1.5)`
- Immediate action needed to prevent burnout

**Action Suggestions:**
- "Move lower-priority issues to backlog"
- "Reassign tasks to under-utilized team members"
- "Extend deadlines for lower-priority items"

---

### Category 4: Communication Gap / Information Blockage (S-02-06)

**Purpose:** Alert team when information flow is stalled

**🟡 Yellow Trigger:**
- No comments/updates on blocker issue for 24 hours
- Logic: `NOW() - lastCommentTime > 24 hours` AND issue status = "in_review"

**🔴 Red Trigger:**
- Blocker issue unresolved for 48+ hours AND dependent tasks waiting
- Cascading delay across multiple team members

**Action Suggestions:**
- "Comment on issue to unblock"
- "Schedule quick sync with assignee"
- "Escalate to project manager"

---

### Category 5: Key Person Absence Impact (S-02-07)

**Purpose:** Alert PM about single points of failure

**🟡 Yellow Trigger:**
- Team member on vacation AND owns >3 active issues
- Logic: Team member marked as "on_vacation" AND `assignedIssuesCount >= 3`

**🔴 Red Trigger:**
- Key person absent AND critical path task waiting
- Logic: Team member on vacation AND owns task on critical path

**Action Suggestions:**
- "Reassign vacation-time issues to [backup person]"
- "Schedule knowledge transfer session"
- "Update team on task status before vacation"

---

### Category 6: Document Stagnation (S-02-08)

**Purpose:** Alert team to update documentation during active project

**🟡 Yellow Trigger:**
- No documentation updates for 7+ days during active project
- Logic: `NOW() - lastDocUpdateTime > 7 days` AND project.status = "in_progress"

**🔴 Red Trigger:**
- No updates for 14+ days during active project

**Action Suggestions:**
- "Update project documentation"
- "Create runbook for [critical component]"
- "Record architectural decisions in ADR"

---

### Category 7: Assignment Paralysis (S-02-09)

**Purpose:** Alert PM when new task created but not assigned

**🟡 Yellow Trigger:**
- Issue created 24 hours ago
- No assignee set
- Logic: `NOW() - createdAt > 24 hours` AND `assignees.count() == 0`

**🔴 Red Trigger:**
- Issue unassigned for 48+ hours
- Dependencies waiting on this task

**Action Suggestions:**
- "Assign task to [team member name]"
- "Clarify task requirements before assignment"
- "Decompose task to smaller pieces"

---

### Category 8: Buffer Depletion (Future, not in Phase 1)

Reserved for future implementation.

---

## Action Plans (Pre-defined Library)

All ActionPlan entries are pre-seeded in database. Reference:

| Code | Title | Description |
|------|-------|-------------|
| `decompose-tasks` | Decompose large tasks | Break down large task into smaller subtasks to identify blockers |
| `prioritize-critical` | Reprioritize to critical path | Focus team on critical-path items first |
| `reallocate-resources` | Reallocate team members | Move resources from low-priority to high-priority work |
| `scope-reduction` | Reduce scope | Remove non-critical features to meet deadline |
| `extend-deadline` | Extend deadline | Propose realistic new deadline with stakeholders |
| `request-help` | Request help | Ask colleagues with relevant expertise |
| `start-immediately` | Start work immediately | Begin task without further delay |
| `unblock-issue` | Unblock issue | Resolve blocker/comment to unblock dependent work |
| `schedule-sync` | Schedule sync meeting | Quick meeting to clarify or handoff |
| `escalate` | Escalate to PM | Brief manager for decision-making |
| `knowledge-transfer` | Knowledge transfer | Share key information before vacation/handoff |
| `update-documentation` | Update documentation | Record architectural decisions or runbooks |
| `assign-task` | Assign task | Set assignee(s) for task |
| `reassign-vacation` | Reassign vacation tasks | Move tasks to available team member |

---

## Alert Trigger Execution

### Trigger Service (Background Job)

**Frequency:** Every 1 hour (configurable)

**Process:**
1. Fetch all active projects
2. For each project:
   - Calculate project progress metrics
   - Check all 8 trigger conditions
   - For each triggered condition:
     - Check if alert already exists (avoid duplicates)
     - If new trigger: Create Alert + AlertLog
     - If existing alert: Just add new AlertLog entry
     - Generate suggested ActionPlans
     - Send email notification via SendGrid

**Idempotency:** Trigger should be safe to run multiple times; duplicates prevented by checking `alerts.isResolved = false`

---

## Alert Email Notifications (SendGrid Integration)

### Email Template Structure

**For Yellow Alerts:**
```
Subject: ⚠️ [Project Name]: [Alert Description]

Body:
---
Hi [PM Name],

Early warning: Your project "[Project Name]" shows signs of potential delay.

Current Status:
- Progress: 35% complete (expected: 50%)
- Timeline: 10 days remaining
- Risk: High if current pace continues

Recommended Next Steps:
1. [Action 1]: [Rationale]
2. [Action 2]: [Rationale]
3. [Action 3]: [Rationale]

View Details: [Link to Project Dashboard]

-- Motivation Cloud Teamwork
```

**For Red Alerts:**
```
Subject: 🔴 URGENT [Project Name]: [Alert Description]

Body:
---
Hi [PM Name],

Urgent: Your project "[Project Name]" is projected to miss deadline.

Projected Completion: [Date] (deadline: [Date])
Days Overdue: [N] days

Critical Actions Needed:
1. [Action 1]: [Rationale]
2. [Action 2]: [Rationale]
3. [Action 3]: [Rationale]

Immediate Action Required: [Link to Project]

-- Motivation Cloud Teamwork
```

### SendGrid Configuration

**Environment Variables:**
- `SENDGRID_API_KEY` - SendGrid API key
- `SENDGRID_FROM_EMAIL` - Sender email (alerts@motiv.cloud)
- `SENDGRID_ALERT_TEMPLATE_YELLOW` - Template ID for yellow alerts
- `SENDGRID_ALERT_TEMPLATE_RED` - Template ID for red alerts

**Retry Logic:**
- Max retries: 3
- Backoff: exponential (1m, 5m, 15m)
- On final failure: Log to `alert_logs` with `email_status = failed`

**Rate Limiting:**
- Max 10 alerts per project per day
- Prevents alert spam/fatigue

---

## Alert Resolution & Lifecycle

### Manual Resolution
PM can mark alert as resolved via:
- API: `PATCH /api/projects/{projectId}/alerts/{alertId}/resolve`
- UI: "Resolve" button on alert card

**Effect:**
- `Alert.isResolved = true`
- Latest `AlertLog.resolvedAt` set to NOW
- No further emails for this alert

### Automatic Reopening
If alert trigger becomes true again:
- System creates new `AlertLog` entry
- `Alert.isResolved` remains true (alert itself is persistent)
- Sends another email (new AlertLog indicates re-trigger)

---

## Data Retention & Cleanup

- **AlertLog:** Keep indefinitely (audit trail)
- **Resolved Alerts:** Keep indefinitely (historical)
- **Email Delivery Logs:** Keep 90 days (compliance)

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `GET /api/projects/{projectId}/alerts` | GET | List all alerts for project |
| `GET /api/projects/{projectId}/alerts/{alertId}` | GET | Get alert details with suggested actions |
| `PATCH /api/projects/{projectId}/alerts/{alertId}/resolve` | PATCH | Manually resolve alert |
| `GET /api/alerts` | GET | List all alerts across projects (PM dashboard) |

---

## Test Cases

### Project Progress Delay Alert (S-02-03)

**TC-02-03-01:** Yellow trigger activated
- Setup: Project 50% timeline elapsed, <50% tasks complete
- Action: Run trigger service
- Expected: Yellow alert created, email sent

**TC-02-03-02:** Red trigger activated
- Setup: Project with low velocity, deadline projected 5 days past due
- Action: Run trigger service
- Expected: Red alert created, red email sent

**TC-02-03-03:** Alert resolved manually
- Setup: Active yellow alert
- Action: PM clicks "Resolve"
- Expected: Alert marked resolved, no more emails until re-trigger

### Issue Progress Delay Alert (S-02-04)

**TC-02-04-01:** Yellow trigger for unstarted issue
- Setup: Issue created 3 days ago, deadline 7 days total, status = "not_in_progress"
- Action: Run trigger service
- Expected: Yellow alert created

**TC-02-04-02:** Red trigger for overdue issue
- Setup: Issue deadline passed, status ≠ "done"
- Action: Run trigger service
- Expected: Red alert created

### Workload Overload Alert (S-02-05)

**TC-02-05-01:** Team member overallocated
- Setup: Team member assigned 120 hours of work, only 40 available hours
- Action: Run trigger service
- Expected: Yellow alert created for team member

### Email Delivery

**TC-Email-01:** SendGrid delivery success
- Action: Trigger alert, check SendGrid event log
- Expected: Email delivered successfully

**TC-Email-02:** SendGrid delivery failure with retry
- Setup: Mock SendGrid to fail once, then succeed
- Action: Trigger alert
- Expected: First attempt fails, second attempt succeeds

**TC-Email-03:** Rate limiting prevents spam
- Setup: Create 15 alerts for same project in same hour
- Expected: Only 10 emails sent (others queued)

---

## Acceptance Criteria

- ✅ All 8 alert categories implemented (3 MUST, 5 WANT)
- ✅ Yellow/Red triggers calculated correctly
- ✅ Suggested actions generated and ranked by priority
- ✅ Emails sent via SendGrid with templates
- ✅ Alert resolution tracked in AlertLog
- ✅ No duplicate alerts (idempotent trigger)
- ✅ Rate limiting prevents alert fatigue
- ✅ PM can view all alerts across projects
- ✅ PM can resolve alerts manually

---

## Dependencies & Ordering

**Must complete before:**
- Any feature that depends on alerts (action plans, automation)

**Requires:**
- S-01-01, S-01-02, S-01-03, S-01-04 (authentication)
- S-03-01, S-03-02 (issues exist)
- S-05-01 (projects exist)
- S-04-01 (teams exist)
- S-05-02 (pulse survey)

---

## Notes

- Alert triggers are dev-configured in Phase 1, not customizable by PMs
- Threshold values are hardcoded in trigger service; Phase 2 may add PM settings
- All timestamps in UTC
- Email templates stored in SendGrid, not in database
