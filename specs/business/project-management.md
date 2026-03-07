# Project Management Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/business-logic/workflows/project-management.md`  
**Domain Model:** `docs/diagrams/domain-models/project-aggregate.puml`

---

## Purpose

Define the complete project management system including:
- Project creation and configuration
- Team assignment to projects
- Progress tracking and visualization
- Role assignment within projects
- Performance metrics and snapshots

---

## Scope

**MUST Features (Phase 1):**
- S-05-01: Project Creation
- S-05-02: Project Progress List (Gantt-style)
- S-05-03: Team Assignment to Project
- S-05-04: Project Detail
- S-05-05: Project Edit
- S-05-06: Project Status Update

**Additional MUST Feature:**
- S-05-02: Pulse Survey (in this spec, part of condition tracking)

---

## Domain Entities

### Project (Aggregate Root)
- `id: UUID`
- `title: String` - Project name
- `description: String?` - Project context
- `dueAt: DateTime?` - Project deadline
- `status: ProjectStatus` - not_in_progress, in_progress, completed, idle
- `createdAt: DateTime`
- `updatedAt: DateTime`

### ProjectStatus Enum
```
not_in_progress - Created but not started
in_progress     - Active work
completed       - Finished
idle            - Paused/on hold
```

### ProjectTeam (Entity)
- `projectId: UUID`
- `teamId: UUID`
- `assignedAt: DateTime`

### ProjectRoleAssignment (Entity)
- `id: UUID`
- `projectId: UUID`
- `roleDefinitionId: UUID` - Reference to RoleDefinition in Team
- `createdAt: DateTime`

### ProjectRoleAssignmentOwner (Entity)
- `projectRoleAssignmentId: UUID`
- `teamMemberId: UUID`

**Purpose:** Links task roles to team members within project context.

### TeamProjectPerformanceDaily (Entity)
- `snapshotDate: Date`
- `projectId: UUID`
- `teamId: UUID`
- `closedIssueCount: Int`
- `overdueOpenIssueCount: Int`
- `completedStoryPoints: Int`
- `estimatedMinutesClosed: Int`
- `actualMinutesLogged: Int`
- `onTimeCompletionRate: Decimal?` - % of issues completed by deadline
- `avgCycleTimeHours: Decimal?` - Average time issue takes to complete
- `createdAt: DateTime`

### TeamMemberProjectPerformanceDaily (Entity)
- Similar to TeamProjectPerformanceDaily, but scoped to individual team member
- Includes same metrics rolled up to member level

---

## Requirements

### S-05-01: Project Creation

**Requirement ID:** S-05-01  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** User is manager in at least one team  

**Main Flow:**
1. Manager clicks "Create Project" button
2. Form opens with fields:
   - Project title (required)
   - Description (optional)
   - Due date (required)
   - Team assignment (required, 1+ teams)
   - Initial role definitions (optional)
3. Fill form
4. Click "Create"
5. Project created, teams assigned, redirect to Project Detail

**Form Fields:**
- `title`: max 200 chars, non-empty
- `description`: max 2000 chars
- `dueAt`: future date/datetime (required)
- `teamIds`: multi-select (required, 1+)
- `roleDefinitionIds`: multi-select from team's role definitions (optional)

**Status Defaults:**
- New project: `status = not_in_progress`
- Start project → `status = in_progress` (via S-05-06)

**Business Rules:**
- Project must be assigned to at least 1 team
- Teams must be managed by creator
- Duplicate project names allowed (different teams might have same project name)
- Project visible only to members of assigned teams

**Error Cases:**
- Missing required field → 422 Unprocessable Entity
- Due date in past → 422 error
- No teams selected → 422 error
- Permission denied (not manager) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Project created with required data
- ✅ Teams assigned
- ✅ Status set to not_in_progress
- ✅ Role definitions assigned (if provided)
- ✅ Redirect to Project Detail
- ✅ Success toast

**Test Cases:**
- TC-05-01-01: Create project with valid data → project created
- TC-05-01-02: No team selected → validation error
- TC-05-01-03: Due date in past → validation error
- TC-05-01-04: Project visible to team members

**API Endpoint:**
```
POST /api/projects
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "title": "string",
  "description": "string?",
  "dueAt": "2026-04-15T17:00:00Z",
  "teamIds": ["uuid", ...],
  "roleDefinitionIds": ["uuid", ...]
}

Response (201 Created):
{
  "project": { ...Project object... }
}
```

---

### S-05-02: Project Progress List (Gantt-style)

**Requirement ID:** S-05-02  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Project exists, user is member of assigned team  

**Main Flow:**
1. User opens Project Detail page
2. "Progress" tab shows Gantt-style chart
3. Y-axis: Issues (or team members)
4. X-axis: Timeline (today to project deadline)
5. Each issue shown as bar with alert-level-coded progress:
   - 🟢 Green: On track (alertLevel = null)
   - 🟡 Yellow: At risk (alertLevel = yellow)
   - 🔴 Red: Behind (alertLevel = red)
6. Bar width represents task duration
7. Click bar to open issue detail

**Gantt Display Options:**
- **View by Team:** X-axis tasks grouped by team
- **View by Status:** X-axis tasks grouped by TODO/WIP/DONE
- **View by Member:** Horizontal bars per team member

**AlertLevel Logic:**
```
expectedProgress = (daysElapsed / daysDue) * 100

IF actualProgress >= expectedProgress:
  alertLevel = null        (UI: green)
ELSE IF actualProgress >= (expectedProgress * 0.8):
  alertLevel = yellow
ELSE:
  alertLevel = red
```
See: `docs/diagrams/domain-models/visualization-read-models.puml`

**Progress Calculation:**
- See S-03-08 (issue auto-progress calculation)
- Aggregated from subtasks or Definition of Done completion

**Timeline:**
- Start date: project created or first issue start
- End date: project due date
- Today line: vertical indicator
- Weekends/holidays optional (not required Phase 1)

**Filtering:**
- Show issues: Select status (not started, in progress, done)
- Show teams: Multi-select team filter
- Show members: Multi-select member filter

**Business Rules:**
- Only active issues shown
- Completed issues shown below current work (can toggle)
- Overdue issues highlighted
- Hovering bar shows issue title, progress %, deadline

**Acceptance Criteria:**
- ✅ Gantt chart renders correctly
- ✅ AlertLevel reflects progress
- ✅ Click bar opens issue
- ✅ Timeline accurate
- ✅ Filtering works

**Test Cases:**
- TC-05-02-01: View project progress → Gantt chart displays
- TC-05-02-02: On-time task → alertLevel null, green bar
- TC-05-02-03: Behind task → alertLevel red, red bar
- TC-05-02-04: Click bar → issue detail opens
- TC-05-02-05: Filter by team → only that team's issues shown

**API Endpoint:**
```
GET /api/projects/{projectId}/progress
Authorization: Bearer {token}

Response (200 OK):
{
  "issues": [
    {
      "id": "uuid",
      "title": "string",
      "startDate": "2026-03-06",
      "dueDate": "2026-03-15",
      "progress": 45,
      "status": "in_progress",
      "alertLevel": "yellow",
      "teamId": "uuid",
      "assigneeIds": ["uuid", ...]
    }
  ]
}
```

---

### S-05-03: Team Assignment to Project

**Requirement ID:** S-05-03  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** Project exists, manager created it or assigned  

**Main Flow:**
1. Manager opens Project Detail
2. Click "Edit Teams" button (or manage teams modal)
3. Multi-select shows current + available teams
4. Add/remove teams as needed
5. Click "Save"
6. Teams updated, members notified

**Business Rules:**
- Project must have at least 1 team assigned
- Cannot remove last team
- Members of newly assigned team gain access to project
- Issues from project visible to newly assigned team

**Error Cases:**
- No teams selected → 422 Unprocessable Entity
- Permission denied (not manager) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Assign team to project
- ✅ Cannot remove last team
- ✅ Members of assigned team see project

**Test Cases:**
- TC-05-03-01: Assign new team → team members gain access
- TC-05-03-02: Remove team → team members lose access
- TC-05-03-03: Cannot remove last team → validation error

**API Endpoint:**
```
PATCH /api/projects/{projectId}/teams
Authorization: Bearer {token}
Request:
{
  "teamIds": ["uuid", ...]
}
```

---

### S-05-04: Project Detail

**Requirement ID:** S-05-04  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Project exists, user is member of assigned team  

**Main Flow:**
1. User opens Project Detail page
2. Overview section displays:
   - Project title
   - Description
   - Status
   - Due date
   - Progress % (overall)
   - Assigned teams
   - Member count
3. Tabs:
   - "Progress" → Gantt chart (S-05-02)
   - "Issues" → Issue list
   - "Alerts" → Alert list (S-02)
   - "Teams" → Team assignment (managers only)

**Overview Section:**
```
[Project Title]
Description: [text]

Status: in_progress | Due: 2026-04-15
Progress: ████░░░░░░ 40%

Teams: Backend, Frontend
Members: 8

Overall Completion: 40/100 issues
On Time: 35/40 completed issues
```

**Alert Section (if alerts exist):**
```
🟡 Yellow Alerts: 2
   - Project at risk of delay
   - Workload overload detected

🔴 Red Alerts: 1
   - Critical path issue behind
```

**Business Rules:**
- Read-only for team members
- Managers can edit (via Edit modal)
- Progress = overall completion across all issues
- Alerts show unresolved only

**Error Cases:**
- Project not found → 404 Not Found
- Permission denied (not member) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Project overview displayed
- ✅ Progress calculated correctly
- ✅ Alerts shown if present
- ✅ Tabs accessible
- ✅ Edit button visible (managers only)

**Test Cases:**
- TC-05-04-01: Open project detail → overview visible
- TC-05-04-02: 40 issues complete, 60 total → 40% shown
- TC-05-04-03: Unresolved alerts displayed
- TC-05-04-04: Member can view, manager can edit

**API Endpoint:**
```
GET /api/projects/{projectId}
Authorization: Bearer {token}

Response (200 OK):
{
  "project": { ...Project object... },
  "overview": {
    "progress": 40,
    "totalIssues": 100,
    "completedIssues": 40,
    "onTimeCompletionRate": 87.5,
    "alerts": [
      { "level": "yellow", "description": "..." }
    ]
  }
}
```

---

### S-05-05: Project Edit

**Requirement ID:** S-05-05  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** Project exists, user is manager of assigned teams  

**Main Flow:**
1. Manager clicks "Edit" on Project Detail
2. Modal/form opens with fields:
   - Title (editable)
   - Description (editable)
   - Due date (editable)
   - Team assignments (editable, via S-05-03)
3. Make changes
4. Click "Save"
5. Project updated

**Fields:**
- Title, Description, Due date (same validation as S-05-01)
- Teams (same rules as S-05-03)

**Business Rules:**
- Cannot change project after completed (immutable)
- Due date can be extended or shortened
- Title/description can be updated anytime

**Error Cases:**
- Invalid data → 422 Unprocessable Entity
- Permission denied (not manager) → 403 Forbidden
- Project completed → 422 error

**Acceptance Criteria:**
- ✅ Project fields editable
- ✅ Changes saved correctly
- ✅ Cannot edit completed projects
- ✅ Success toast

**Test Cases:**
- TC-05-05-01: Edit title → saved
- TC-05-05-02: Extend deadline → saved
- TC-05-05-03: Attempt to edit completed → error

**API Endpoint:**
```
PATCH /api/projects/{projectId}
Authorization: Bearer {token}
Request:
{
  "title": "string?",
  "description": "string?",
  "dueAt": "datetime?"
}
```

---

### S-05-06: Project Status Update

**Requirement ID:** S-05-06  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** Project exists, user is manager  

**Main Flow:**
1. Manager clicks status dropdown on Project Detail
2. Options:
   - "Start" (not_in_progress → in_progress)
   - "Pause" (in_progress → idle)
   - "Resume" (idle → in_progress)
   - "Complete" (in_progress → completed)
   - "Cancel" (any → idle, alternative to complete)
3. Click action
4. Status updated, teams notified

**Status Transitions:**
```
not_in_progress
    ↓ (Start)
    in_progress ←→ idle (Pause/Resume)
         ↓ (Complete)
    completed
```

**Completion Logic:**
- Manager can mark complete at any time
- Suggested: All issues done, but not enforced
- No issues can be added after completed
- Historical data preserved

**Business Rules:**
- Only managers can change status
- Completed projects are archived (no new issues)
- Idle projects can be resumed
- Status changes logged in audit trail

**Error Cases:**
- Invalid transition → 422 Unprocessable Entity
- Permission denied → 403 Forbidden
- Project completed (cannot change) → 422 error

**Acceptance Criteria:**
- ✅ Status transitions work correctly
- ✅ Invalid transitions blocked
- ✅ Teams notified of status change
- ✅ Completed projects immutable
- ✅ Success toast

**Test Cases:**
- TC-05-06-01: Start project → status = in_progress
- TC-05-06-02: Complete project → status = completed
- TC-05-06-03: Cannot add issues to completed project
- TC-05-06-04: Invalid transition → error

**API Endpoint:**
```
PATCH /api/projects/{projectId}/status
Authorization: Bearer {token}
Request:
{
  "action": "start" | "pause" | "resume" | "complete" | "cancel"
}

Response (200 OK):
{
  "project": { ...updated project... }
}
```

---

### Pulse Survey Integration (S-05-02 - Condition Tracking)

**Requirement ID:** S-05-02 (Condition Tracking)  
**Type:** MUST (Phase 1)  
**Actor:** Team Member (answerer), Manager (viewer)  
**Precondition:** Team has survey configured, member active  

**Purpose:** Regularly collect team condition data to understand motivation/psychological safety.

**Survey Frequency:**
- Configured per team (see S-04 team condition settings)
- Default: 1x per week, delivery time: 09:00

**Survey Questions (Template):**
Pre-defined survey template with questions like:
1. "How confident do you feel asking your team questions?" (1-5)
2. "Do you feel comfortable sharing concerns?" (Yes/No)
3. "How is your energy level today?" (Low/Medium/High)
4. "Any blockers preventing your work?" (Open text)

**Delivery:**
- Email sent on schedule with survey link
- Mobile/responsive form
- Takes ~2-3 minutes

**Response Tracking:**
```
Survey {
  id: UUID
  surveySettingId: UUID
  recipientId: UUID
  deliveredAt: DateTime
  lastAnsweredAt: DateTime?
}

SurveyAnswer {
  surveyId: UUID
  surveyQuestionId: UUID
  selectedOptionId: UUID
  answeredAt: DateTime
}
```

**Manager View:**
- Team condition summary: avg score, response rate
- Member condition history: trend over time
- Trigger alerts if member score drops significantly (future phase)

**Acceptance Criteria:**
- ✅ Survey sent on schedule
- ✅ Member can answer
- ✅ Responses recorded
- ✅ Manager can view team condition
- ✅ Condition data used in alerts (future)

---

## Performance Metrics & Snapshots

**Daily Snapshot Service:**
Every night (UTC midnight), create `TeamProjectPerformanceDaily` snapshot:

1. For each active project:
   - Calculate daily metrics:
     - Closed issues count
     - Overdue open issue count
     - Completed story points
     - Estimated minutes closed
     - Actual minutes logged
     - On-time completion rate
     - Average cycle time
   - Store in `TeamProjectPerformanceDaily`
2. Same for individual team members (`TeamMemberProjectPerformanceDaily`)

**On-Time Completion Rate:**
```
onTimeCompletionRate = (issueDateCompletedBefore / totalIssuesCompleted) * 100
```

**Average Cycle Time:**
```
avgCycleTime = AVG(closedAt - startedAt) for closed issues
```

**Use Cases:**
- Alert triggers use daily metrics (velocity)
- Manager reports (Phase 2)
- Team health dashboard (Phase 2)

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `GET /api/projects` | GET | List projects (role-filtered) |
| `GET /api/projects/{projectId}` | GET | Get project detail |
| `POST /api/projects` | POST | Create project |
| `PATCH /api/projects/{projectId}` | PATCH | Update project |
| `PATCH /api/projects/{projectId}/status` | PATCH | Change status |
| `PATCH /api/projects/{projectId}/teams` | PATCH | Assign teams |
| `GET /api/projects/{projectId}/progress` | GET | Gantt data |
| `GET /api/projects/{projectId}/issues` | GET | List project issues |
| `GET /api/projects/{projectId}/alerts` | GET | List unresolved alerts |

---

## Dependencies & Ordering

**Must complete before:**
- Alert system (alerts scoped to projects)
- Issue management implementation (issues belong to projects)

**Requires:**
- S-01 (authentication)
- S-04 (teams)

---

## Notes

- Projects are the container for issues and alerts
- Status lifecycle clear: not_in_progress → in_progress → completed
- Metrics captured daily for trending (future reporting)
- Gantt visualization is key for PM visibility
- All timestamps in UTC
