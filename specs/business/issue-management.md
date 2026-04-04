# Issue Management Specification

**Version:** 1.0  
**Last Updated:** 2026/04/05  
**Human Documentation:** `docs/business-logic/workflows/issue-management.md`  
**Domain Model:** `docs/diagrams/domain-models/issue-aggregate.puml`

---

## Purpose

Define the complete issue (task) management system including:
- Issue creation with SMART templates
- Subtask management and progress tracking
- Status lifecycle management
- Assignee and role management
- Work logging and CI/CD integration

---

## Scope

**MUST Features (Phase 1):**
- S-03-01: Issue Creation with Templates
- S-03-02: Assignee Management
- S-03-03: SMART Template Format
- S-03-04: Acceptance Criteria (Definition of Done)
- S-03-05: Status Updates
- S-03-06: Subtask Management
- S-03-08: Auto Progress Calculation

**WANT Features (Phase 1):**
- S-03-09: Unexpected Work Registration
- S-03-10: CI/CD Integration

---

## Domain Entities

### Issue (Aggregate Root)
- `id: UUID`
- `projectId: UUID` - Parent project
- `parentIssueId: UUID?` - Null for top-level, set for subtasks
- `issueTemplateId: UUID` - References template used
- `title: String`
- `storyPoints: StoryPoints` - Estimation unit
- `estimatedMinutes: EstimatedMinutes` - Total work estimate
- `deadline: DateTime?`
- `startedAt: DateTime?`
- `closedAt: DateTime?`
- `status: IssueStatus` - not_in_progress, in_progress, in_review, done
- `createdAt: DateTime`
- `updatedAt: DateTime`

### IssueStatus Enum
```
not_in_progress - Not yet started
in_progress     - Work in progress
in_review       - Complete, waiting review
done            - Accepted, closed
```

### IssueAssignee (Entity)
- `issueId: UUID`
- `teamMemberId: UUID` - Can have multiple assignees

### IssueDefinitionOfDone (Entity)
- `id: UUID`
- `issueId: UUID`
- `description: String` - Acceptance criteria item
- `isCompleted: Boolean`

### IssueWorkLog (Entity)
- `id: UUID`
- `issueId: UUID`
- `teamMemberId: UUID`
- `source: WorkLogSource` - manual, github_api, github_actions
- `externalLogId: String?` - GitHub commit ID, action ID, etc.
- `startedAt: DateTime`
- `endedAt: DateTime?`
- `minutes: Int` - Work duration
- `createdAt: DateTime`

### IssueStatusEvent (Entity)
- `id: BigInt`
- `issueId: UUID`
- `fromStatus: IssueStatus?` - Null if first event
- `toStatus: IssueStatus`
- `changedBy: UUID?` - User who triggered change
- `createdAt: DateTime`

---

## Requirements

### S-03-01: Issue Creation

**Requirement ID:** S-03-01  
**Type:** MUST (Phase 1)  
**Actor:** Team Member, Project Manager  
**Precondition:** User authenticated, project exists, template selected  

**Main Flow:**
1. User navigates to project → "Create Issue" button
2. Select issue template (SMART template)
3. Fill template-specific fields
4. Select one or more team tags from the project's assigned teams (required)
5. Select assignees from members of the selected teams (required: at least 1)
6. Add Definition of Done items (required: at least 1)
7. Set story points, estimated minutes, and deadline (required)
8. Click "Create"
9. Issue created, user redirected to the project detail page

**Template Selection:**
Templates are **global** (not project-scoped). Examples:
- "Backend Feature"
- "Frontend Component"
- "Bug Fix"
- "Tech Debt"
- "Documentation"

**Required Fields (Global):**
- Title (max 255 chars)
- Deadline (future date)
- Template selection
- Team tags (1+)
- Assignees (1+, selected from chosen teams)
- Definition of Done items (1+)
- Story points (required, Fibonacci scale 1-13: 1, 2, 3, 5, 8, 13)
- Estimated minutes (required, positive integer)

**Template-Specific Fields:**
Each template defines additional required fields. See S-03-03.

**Template Contract Note:**
- `GET /api/issue-templates` provides the active templates used in the selector.
- After selection, the UI fetches `GET /api/issue-templates/{templateId}` and renders the returned `items[]` dynamically.

**Business Rules:**
- Issue cannot be created without project
- At least one team tag must be selected
- Assignees must be active team members of the selected project teams
- Definition of Done must contain at least one non-empty item
- Deadline must be ≥ today
- Story points: Fibonacci scale 1-13 (1, 2, 3, 5, 8, 13)
- Estimated minutes must be entered as a positive integer
- `issue_template_id` must reference an existing issue template
- Dynamic template item values are submitted as `templateItemValues`, keyed by each item's `itemKey`
- `templateItemValues` may only contain `itemKey` values defined on the selected template

**Error Cases:**
- Missing required field → 422 Unprocessable Entity
- Invalid assignee (not in selected project team) → 422 error
- Deadline in past → 422 error
- Invalid or non-existent `issue_template_id` → 422 error on `issue_template_id`
- Unknown `templateItemValues` key → 422 error on `templateItemValues.{itemKey}`
- Project not found → 404 Not Found

**Acceptance Criteria:**
- ✅ Issue created with all required fields
- ✅ Selected team tags saved with issue
- ✅ Assignees set correctly
- ✅ Definition of Done items saved
- ✅ Story points saved
- ✅ Deadline set
- ✅ Template item values saved when provided
- ✅ Status defaults to "not_in_progress"
- ✅ Created timestamp recorded

**Test Cases:**
- TC-03-01-01: Create issue with all required fields → issue created
- TC-03-01-02: Create without team tags → validation error
- TC-03-01-03: Create without assignees → validation error
- TC-03-01-04: Create without Definition of Done items → validation error
- TC-03-01-05: Deadline in past → validation error
- TC-03-01-06: Invalid or non-existent template ID → validation error on `issue_template_id`
- TC-03-01-07: Unknown `templateItemValues` key → field-level validation error on `templateItemValues.{itemKey}`

**API Endpoint:**
```
POST /api/projects/{projectId}/issues
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "title": "string",
  "issue_template_id": "uuid",
  "story_points": 5,
  "estimated_minutes": 480,
  "deadline": "2026-03-15",
  "status": "not_in_progress",
  "assigneeIds": ["uuid", ...],
  "teamIds": ["uuid", ...],
  "definitionOfDoneItems": ["string", ...],
  "templateItemValues": {
    "requireFlag": false,
    "requiredCount": 0,
    "plannedAt": "2026-04-15",
    "startedAt": "2026-04-15T10:00",
    "notes": "string or json payload"
  }
}

Response (201 Created):
{
  "issue": { ...Issue object... }
}
```

Validation Notes:
- `issue_template_id` is validated at the request layer and must reference an existing template record
- Unknown keys under `templateItemValues` are rejected at validation time and returned as field-level errors under `errors["templateItemValues.{itemKey}"]`

---

### S-03-02: Assignee Management

**Requirement ID:** S-03-02  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager, Issue Assignee  
**Precondition:** Issue exists, team member is active in project  

**Main Flow - Add Assignee:**
1. User opens issue detail
2. Click "Add Assignee" or "+ Assign"
3. Select team member from list (filtered to project members)
4. Assignee added immediately
5. Notification sent to new assignee (email)

**Main Flow - Remove Assignee:**
1. User clicks "X" next to assignee name
2. Confirmation dialog
3. Assignee removed
4. Notification sent to removed assignee

**Business Rules:**
- Issue can have multiple assignees
- Assignee must be active team member of a team assigned to project
- Cannot remove last assignee if issue is in_progress
- Changing assignee creates IssueStatusEvent (audit trail)

**Validation Rules:**
- Team member must have `status = active` in team_members table
- Team member must be in team assigned to issue's project

**Error Cases:**
- Team member not found → 404 Not Found
- Team member not in project → 422 Unprocessable Entity
- Cannot remove last assignee → 422 error
- Issue not found → 404 Not Found

**Acceptance Criteria:**
- ✅ Assignee added to issue
- ✅ Assignee notified (email)
- ✅ Multiple assignees supported
- ✅ Cannot remove last assignee
- ✅ Assignee change logged

**Test Cases:**
- TC-03-02-01: Add assignee to issue → assignee added
- TC-03-02-02: Remove assignee → assignee removed
- TC-03-02-03: Add invalid assignee → validation error
- TC-03-02-04: Remove only assignee → validation error

**API Endpoint:**
```
POST /api/issues/{issueId}/assignees
Request:
{
  "teamMemberId": "uuid"
}

DELETE /api/issues/{issueId}/assignees/{teamMemberId}
```

---

### S-03-03: SMART Template Format

**Requirement ID:** S-03-03  
**Type:** MUST (Phase 1)  
**Actor:** PM (configures templates), Team Members (fills during issue creation)  
**Precondition:** Project exists  

**Implementation Model:**

Phase 3 renders template input fields from each template's ordered `items[]` definition instead of using hardcoded SMART input components.

**Template Item Shape:**

```
IssueTemplateItem {
  id: UUID
  itemKey: String
  label: String
  position: Int
  isRequired: Boolean
  valueType: Enum(string, integer, date, datetime, boolean, number, json)
}
```

**UI Behavior:**
- Template selection triggers `GET /api/issue-templates/{templateId}`
- The form renders inputs from `template.items`, ordered by `position`
- Supported input types are `boolean`, `integer`, `number`, `date`, `datetime`, `string`, and `json`
- Items without `itemKey` are defensively skipped for rendering and required validation (the schema requires `itemKey`, but the UI handles malformed data gracefully)

**Validation Rules:**
- All required items with an `itemKey` must have a value before submit
- `false` and `0` are valid required values
- Empty string and whitespace-only string values are invalid for required string-like fields
- Submitted values are keyed by `itemKey` inside `templateItemValues`

**Acceptance Criteria:**
- ✅ Issue form renders the selected template's items dynamically
- ✅ Cannot create issue without all required template items
- ✅ Required boolean `false` and numeric `0` values are accepted
- ✅ Items without `itemKey` do not block submission
- ✅ Template validation runs before save

**Test Cases:**
- TC-03-03-01: Render selected template items dynamically → fields shown in `position` order
- TC-03-03-02: Required boolean field set to `false` → issue created
- TC-03-03-03: Required integer field set to `0` → issue created
- TC-03-03-04: Required item without `itemKey` → skipped by rendering and validation

---

### S-03-04: Acceptance Criteria (Definition of Done)

**Requirement ID:** S-03-04  
**Type:** MUST (Phase 1)  
**Actor:** Assigned team member, assigned team manager  
**Precondition:** Issue created, user authenticated  

**Main Flow:**
1. During issue creation: PM fills "How will we know it's complete?" field
2. System parses input as acceptance criteria items
3. Each item becomes an `IssueDefinitionOfDone` entry
4. Assigned issue-team member can check off items as complete
5. Issue cannot be marked "done" until all items checked

**Criteria Format:**
PM enters criteria in natural language, one per line:
```
- API endpoint returns 200 for valid request
- Invalid request returns 422 with error message
- Response includes pagination metadata
- Unit tests cover all success cases
- Integration test with database passes
```

**Parsing:** System parses dash-separated list into individual items.

**Completion Tracking:**
```
IssueDefinitionOfDone {
  id: UUID
  issueId: UUID
  description: String (text from above)
  isCompleted: Boolean (default: false)
}
```

**Progress Calculation:**
```
completionPercentage = completedItems / totalItems * 100
```

Used in alert triggers (S-02-04, see alert-system-implementation.md).

**Business Rules:**
- Minimum 1 acceptance criterion required
- Cannot mark issue "done" if any criterion unchecked
- Active members of teams assigned to the issue, including assigned-team managers, can create and update DoD items
- Criteria can be updated before issue started; after started, editing requires PM approval
- Completing all criteria is necessary but not sufficient for "done" status (assignee must explicitly mark done)

**Error Cases:**
- No criteria provided → validation error
- Attempt to mark done with incomplete criteria → 422 error
- Outsider tries to add or update a criterion → 403 error

**Acceptance Criteria:**
- ✅ Definition of Done items required
- ✅ Cannot mark done until all items completed
- ✅ Progress tracked and visible
- ✅ Completion prevents status transitions

**Test Cases:**
- TC-03-04-01: Create issue with 5 acceptance criteria → all tracked
- TC-03-04-02: Complete 3/5 criteria → progress shows 60%
- TC-03-04-03: Attempt to mark done with incomplete → 422 error
- TC-03-04-04: Complete all criteria → can mark done
- TC-03-04-05: Outsider adds or updates criterion → 403 error

**API Endpoint:**
```
GET /api/issues/{issueId}/definition-of-done

PATCH /api/issues/{issueId}/definition-of-done/{doneItemId}
Request:
{
  "isCompleted": true
}

POST /api/issues/{issueId}/definition-of-done
Request:
{
  "description": "string"
}
```

---

### S-03-05: Status Updates

**Requirement ID:** S-03-05  
**Type:** MUST (Phase 1)  
**Actor:** Assigned team member, assigned team manager  
**Precondition:** Issue exists, user authenticated  

**Main Flow:**
1. Open issue detail
2. Click status dropdown
3. Select new status from available options
4. System validates transition
5. Update saved, IssueStatusEvent created
6. Notifications sent to team

**Status Transitions:**

```
not_in_progress
    ↓
    in_progress (start work)
         ↓
         in_review (mark for review)
         ↓
         done (accepted)
         
    OR back to in_progress (review rejected)
```

**Status Logic:**
- `not_in_progress` → `in_progress`: Sets `startedAt = NOW()`
- `in_progress` → `in_review`: Requires at least some work logged
- `in_review` → `done`: Requires all Definition of Done items checked
- `in_review` → `in_progress`: Reset if review rejected
- Any → `not_in_progress`: Back to original state (revert)

**Business Rules:**
- Active members of teams assigned to the issue can change status
- Assigned-team managers are allowed via active membership
- `startedAt` immutable once set
- `closedAt` set when moved to done
- Invalid transitions blocked (e.g., `not_in_progress` → `in_review`)

**Error Cases:**
- Invalid transition → 422 Unprocessable Entity
- Permission denied (user is not in an assigned issue team) → 403 Forbidden
- Issue not found → 404 Not Found

**Acceptance Criteria:**
- ✅ Status updated correctly
- ✅ Only valid transitions allowed
- ✅ Timestamps recorded (startedAt, closedAt)
- ✅ Status change logged in IssueStatusEvent
- ✅ Team notified of status change

**Test Cases:**
- TC-03-05-01: Start issue → status = in_progress, startedAt set
- TC-03-05-02: Mark in_review → status updated
- TC-03-05-03: Mark done → closedAt set
- TC-03-05-04: Invalid transition (not_in_progress → done) → 422 error
- TC-03-05-05: Outsider changes status → 403 error

**API Endpoint:**
```
PATCH /api/issues/{issueId}/status
Authorization: Bearer {token}
Request:
{
  "status": "in_progress" | "in_review" | "done"
}

Response:
{
  "issue": { ...updated issue... },
  "event": { ...IssueStatusEvent... }
}
```

---

### S-03-06: Subtask Management

**Requirement ID:** S-03-06  
**Type:** MUST (Phase 1)  
**Actor:** Assigned team member, assigned team manager  
**Precondition:** Parent issue exists  

**Main Flow - Create Subtask:**
1. Open parent issue detail
2. Click "Add Subtask" button
3. Enter subtask title, estimate, deadline
4. Assign to team member
5. Subtask created as child of parent

**Main Flow - Update Subtask:**
1. Subtask appears as row in subtask list
2. Click row to open subtask detail
3. Edit title, estimate, deadline, status
4. Changes saved

**Main Flow - Complete Subtask:**
1. Mark subtask status as done
2. Progress bar updates on parent issue
3. Alert trigger recalculates project progress

**Subtask Entity:**
```
Issue {
  parentIssueId: UUID  // Set to parent issue ID
  // All other fields same as regular issue
}
```

**Business Rules:**
- Subtask is still an Issue (same model, different parent_id)
- Active members of teams assigned to the parent issue, including assigned-team managers, can create subtasks
- Subtask deadline cannot exceed parent deadline
- Subtask story points rolled up to parent (estimated minutes sum)
- Cannot delete parent issue while subtasks exist (must delete subtasks first or move to backlog)
- Subtask status changes cascade to parent progress calculation

**Nesting Limit:** Subtasks cannot have sub-subtasks (max 1 level deep)

**Error Cases:**
- Subtask deadline > parent deadline → 422 error
- Parent issue not found → 404 Not Found
- Subtask deadline in past → 422 error
- Outsider tries to create subtask → 403 Forbidden

**Acceptance Criteria:**
- ✅ Create subtasks under parent issue
- ✅ Edit subtask details
- ✅ Subtask status tracked independently
- ✅ Parent progress updated when subtasks complete
- ✅ Cannot exceed parent deadline

**Test Cases:**
- TC-03-06-01: Create subtask → subtask appears under parent
- TC-03-06-02: Subtask deadline > parent → validation error
- TC-03-06-03: Complete 2/3 subtasks → parent progress 67%
- TC-03-06-04: Complete all subtasks → parent eligible for done
- TC-03-06-05: Outsider creates subtask → 403 error

**API Endpoint:**
```
POST /api/issues/{parentIssueId}/subtasks
Request:
{
  "title": "string",
  "estimatedMinutes": 120,
  "deadline": "2026-03-12T17:00:00Z",
  "teamMemberId": "uuid"
}

GET /api/issues/{parentIssueId}/subtasks

PATCH /api/issues/{subtaskId}
// Update subtask (same as regular issue)
```

---

### S-03-08: Auto Progress Calculation

**Requirement ID:** S-03-08  
**Type:** MUST (Phase 1)  
**Actor:** System (automatic)  
**Precondition:** Issue has subtasks or Definition of Done items  

**Purpose:** Calculate real-time progress percentage for an issue.

**Progress Calculation Logic:**

**Priority 1: Subtask-Based (if subtasks exist)**
```
progressPercent = (completedSubtasks / totalSubtasks) * 100
completedSubtasks = count(subtask.status == "done")
```

**Priority 2: Definition of Done (if no subtasks)**
```
progressPercent = (completedCriteria / totalCriteria) * 100
completedCriteria = count(definition_of_done.isCompleted == true)
```

**Priority 3: Work Log Based (if neither)**
```
progressPercent = (actualMinutesLogged / estimatedMinutes) * 100
actualMinutesLogged = sum(work_log.minutes)
```

**Fallback:** If no tracker, progress = 0% (issue not started)

**Display:**
- Progress bar on issue detail (visual 0-100%)
- Numeric percentage displayed
- Updated in real-time as subtasks/DoD completed

**Accuracy Calculation (for alerts):**
```
predictedCompletionDate = startedAt + (estimatedMinutes / actualWorkRatePerDay)
accuracyVariance = (predictedCompletionDate - deadline) / deadline * 100

IF abs(accuracyVariance) > 20% THEN alert (see alert-system-implementation.md)
```

**Business Rules:**
- Progress never goes backward (idempotent)
- Progress calculated on-demand when displayed (not cached)
- Can recalculate by calling `/issues/{id}/recalculate-progress` (admin only)

**Acceptance Criteria:**
- ✅ Subtask completion updates parent progress
- ✅ Definition of Done completion updates progress
- ✅ Work logged updates progress
- ✅ Progress displayed on issue detail
- ✅ Progress accurate to actual completion state

**Test Cases:**
- TC-03-08-01: 2/4 subtasks done → progress 50%
- TC-03-08-02: 3/5 DoD items checked → progress 60%
- TC-03-08-03: 100 minutes logged of 400 estimated → progress 25%
- TC-03-08-04: Complete all subtasks → progress 100%, can mark done

---

### S-03-09: Unexpected Work Registration (WANT)

**Requirement ID:** S-03-09  
**Type:** WANT (Phase 1, lower priority)  
**Actor:** Issue assignee, Project Manager  
**Precondition:** Issue in progress  

**Purpose:** Quickly log unexpected work that wasn't estimated initially.

**Main Flow:**
1. During issue work, find unexpected complexity
2. Click "Log Additional Work" or "+ Add unexpected work"
3. Enter minutes spent and brief description
4. Work logged immediately
5. Estimated minutes updated (adds to total)
6. Progress recalculated

**Work Entry:**
```
IssueWorkLog {
  minutes: 60,
  description: "Unexpected database optimization needed",
  source: "manual",
  startedAt: NOW(),
  endedAt: NOW()
}

// Also update Issue.estimatedMinutes += 60
```

**Business Rules:**
- Can add unexpected work at any time during issue progress
- Updates total estimate (for delay prediction)
- Logged as WorkLog entry (auditable)
- Triggers alert if total estimate now exceeds deadline capacity

**Acceptance Criteria:**
- ✅ Log additional work minutes
- ✅ Estimated minutes updated
- ✅ Progress recalculated
- ✅ Work entry auditable

**Test Cases:**
- TC-03-09-01: Log 60 minutes unexpected work → estimate updated
- TC-03-09-02: Unexpected work pushes estimate past deadline → alert triggered

---

### S-03-10: CI/CD Integration (WANT)

**Requirement ID:** S-03-10  
**Type:** WANT (Phase 1, lower priority)  
**Actor:** System (GitHub Actions webhook)  
**Precondition:** Issue linked to GitHub branch  

**Purpose:** Automatically update issue progress based on GitHub commits and CI/CD results.

**Integration Points:**

**1. Commit-Based Progress:**
- Developer pushes commits to feature branch
- GitHub webhook triggers
- Commits linked to issue (via branch name or commit message)
- WorkLog entry created (source: github_api)
- Progress updated

**2. CI/CD Status Update:**
- GitHub Actions runs tests
- On success: Issue marked in_review (or stays in_progress)
- On failure: Issue stays in_progress, comment with error link

**Branch Naming Convention:**
```
feature/S-03-01-issue-title
fix/S-03-02-another-issue
```

Regex: `(feature|fix|refactor)/([A-Z]-\d{2}-\d{2})-.*`

**Commit Message:**
```
git commit -m "Implement API endpoint

Closes #S-03-01
"
```

**GitHub Webhook Configuration:**
- Endpoint: `https://app.motiv.cloud/webhooks/github/push`
- Events: push, pull_request
- Secret: `GITHUB_WEBHOOK_SECRET` (env var)

**WorkLog Creation from Commits:**
```
IssueWorkLog {
  issueId: UUID,
  teamMemberId: UUID (from GitHub user match),
  source: "github_api",
  externalLogId: commit_sha,
  startedAt: commit_timestamp - 30min (estimate),
  endedAt: commit_timestamp,
  minutes: 30 (default estimate; can refine later)
}
```

**Acceptance Criteria:**
- ✅ Commits linked to issue via branch name
- ✅ WorkLog created for each commit
- ✅ Progress updated from commits
- ✅ CI/CD status reflected in issue
- ✅ Webhook signature verified

**Test Cases:**
- TC-03-10-01: Push commit to feature branch → WorkLog created
- TC-03-10-02: Pass CI/CD tests → issue marked in_review
- TC-03-10-03: Fail CI/CD tests → issue comment with error link

---

## Data Retention & Cleanup

- **Issues:** Keep indefinitely
- **IssueStatusEvent:** Keep indefinitely (audit trail)
- **IssueWorkLog:** Keep indefinitely (time tracking history)
- **Closed Issues:** Archive after 365 days (optional, keep for reporting)

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `POST /api/projects/{projectId}/issues` | POST | Create issue |
| `GET /api/projects/{projectId}/issues` | GET | List project issues |
| `GET /api/issues/{issueId}` | GET | Get issue detail |
| `PATCH /api/issues/{issueId}` | PATCH | Update issue fields (title, estimate, deadline, etc.) |
| `PATCH /api/issues/{issueId}/status` | PATCH | Update issue status |
| `POST /api/issues/{issueId}/assignees` | POST | Add assignee |
| `DELETE /api/issues/{issueId}/assignees/{teamMemberId}` | DELETE | Remove assignee |
| `GET /api/issues/{issueId}/definition-of-done` | GET | List acceptance criteria |
| `POST /api/issues/{issueId}/definition-of-done` | POST | Add acceptance criterion |
| `PATCH /api/issues/{issueId}/definition-of-done/{doneItemId}` | PATCH | Update criterion completion |
| `POST /api/issues/{parentIssueId}/subtasks` | POST | Create subtask |
| `GET /api/issues/{parentIssueId}/subtasks` | GET | List subtasks |
| `POST /api/issues/{issueId}/work-logs` | POST | Log work (manual) |
| `GET /api/issues/{issueId}/work-logs` | GET | List work logs (returns an empty collection when the issue does not exist) |
| `PATCH /api/issues/{issueId}/work-logs/{workLogId}` | PATCH | Update a work log (not owner-only) |
| `DELETE /api/issues/{issueId}/work-logs/{workLogId}` | DELETE | Delete a work log (not owner-only) |
| `GET /api/issue-templates` | GET | List active templates for issue creation |
| `GET /api/issue-templates/{templateId}` | GET | Get a selected template with item definitions |

---

## Dependencies & Ordering

**Must complete before:**
- Alert system (triggers depend on issue progress)
- Project management (issues belong to projects)

**Requires:**
- S-01 (authentication)
- S-04 (teams/members)
- S-05 (projects)

---

## Notes

- Issue IDs not user-facing in Phase 1; feature IDs (S-03-01) used for linking
- Story points optional, defaults to 5 if not set
- Subtasks inherit project/team from parent
- Issue update, status update, DoD create/update, subtask create, and work log update/delete are limited to active members of teams assigned to the issue; assigned-team managers are allowed via active membership
- Outsiders receive 403 for those issue mutations
- All timestamps in UTC
- Progress auto-updates on subtask/DoD completion
