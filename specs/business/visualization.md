# Visualization & Dashboards Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/business-logic/workflows/visualization.md`

---

## Purpose

Define visualization features that give managers and team members visibility into workload and project progress.

---

## Scope

**MUST Features (Phase 1):**
- S-07-01: Member Workload Visualization
- S-07-02: Project Progress Management Board

---

## Requirements

### S-07-01: Member Workload Visualization

**Requirement ID:** S-07-01  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Team exists with members and assigned issues  

**Main Flow:**
1. Manager/member opens workload dashboard
2. Table/grid displayed showing per-member metrics:
   - Member name
   - Avatar
   - Number of issues assigned
   - Story points (total assigned)
   - Story points (completed)
   - Story points (in progress)
   - Story points (not started)
   - Workload indicator (visual bar)
3. Color-coded:
   - 🟢 Green: Under capacity
   - 🟡 Yellow: At capacity
   - 🔴 Red: Over capacity
4. Click member row to see assigned issues

**Workload Calculation:**
```
assignedPoints = SUM(issue.storyPoints) for issues where member is assignee
completedPoints = SUM(issue.storyPoints) for completed issues
capacityPoints = estimatedCapacityPerWeek (configurable, default: 40)

workloadPercent = assignedPoints / capacityPoints * 100

IF workloadPercent <= 100%:
  status = green
ELSE IF workloadPercent <= 150%:
  status = yellow
ELSE:
  status = red
```

**Table Display:**
```
| Member          | Issues | Points (Assigned/Completed/In Progress) | Workload     |
|---|---|---|---|
| Alice Smith     | 3      | 13 (8 / 5 / 0)                        | ████░░░░░░ 80% 🟢 |
| Bob Johnson     | 2      | 16 (4 / 10 / 2)                        | ████████░░ 160% 🔴 |
| Carol Lee       | 1      | 5 (5 / 0 / 0)                          | ██░░░░░░░░ 50% 🟢 |
```

**Filtering:**
- Filter by team
- Filter by project
- Show inactive members (toggle)

**Business Rules:**
- Workload scoped to selected project (or all projects if team view)
- Members from multiple teams might appear multiple times
- Red workload triggers alert (S-02-05)

**Acceptance Criteria:**
- ✅ Member workload displayed
- ✅ Color coding reflects capacity
- ✅ Points rolled up correctly
- ✅ Click member shows issues
- ✅ Filtering works

**Test Cases:**
- TC-07-01-01: View member workload → metrics calculated
- TC-07-01-02: Over capacity → red indicator
- TC-07-01-03: Click member → assigned issues listed
- TC-07-01-04: Filter by project → only that project's issues

**API Endpoint:**
```
GET /api/teams/{teamId}/member-workload?projectId={projectId}
Authorization: Bearer {token}

Response (200 OK):
{
  "members": [
    {
      "id": "uuid",
      "name": "string",
      "issueCount": 3,
      "assignedPoints": 13,
      "completedPoints": 8,
      "inProgressPoints": 5,
      "notStartedPoints": 0,
      "workloadPercent": 80,
      "status": "green"
    }
  ]
}
```

---

### S-07-02: Project Progress Management Board

**Requirement ID:** S-07-02  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Project exists with issues  

**Main Flow:**
1. User opens project board
2. Kanban-style board displayed with columns:
   - "Not Started" (not_in_progress)
   - "In Progress" (in_progress)
   - "In Review" (in_review)
   - "Done" (done)
3. Issues displayed as cards in columns
4. Card shows:
   - Issue title
   - Assignees (avatars)
   - Deadline
   - Progress bar (if subtasks/DoD)
   - Priority/status indicator
5. Drag-and-drop to update status (or click card to open detail)
6. Progress summary at top (overall % complete)

**Card Display:**
```
┌─ [Not Started] [In Progress] [In Review] [Done] ─┐
│                                                    │
│ Overall Progress: ████░░░░░░ 40%                  │
│                                                    │
│ ┌─────────────────┐ ┌────────────────┐            │
│ │ API Endpoint    │ │ Fix Query Perf │            │
│ │ Build auth      │ │ Database       │            │
│ │ 🔴 2 days left  │ │ ⏱️ In review   │            │
│ │ @alice @bob     │ │ @carol         │            │
│ │ ██████░░░░ 60% │ │ ████████░░ 80%│            │
│ └─────────────────┘ └────────────────┘            │
│                                                    │
└────────────────────────────────────────────────────┘
```

**Status Indicators:**
- 🟢 Green: On track
- 🟡 Yellow: At risk
- 🔴 Red: Behind (see S-02-04 for trigger logic)
- ⏱️ Time warning: < 2 days to deadline

**Drag & Drop:**
- Drag card between columns to update status
- Status updated immediately
- IssueStatusEvent created

**Alternative View:**
Users can toggle to Gantt view (S-05-02) or list view from same page.

**Business Rules:**
- Read-only for members, editable for assignees
- Can drag only own issues (or all for managers)
- Progress bar calculated from subtasks/DoD (S-03-08)
- Completed issues stay on board but grouped at bottom

**Filtering:**
- Filter by assignee
- Filter by team
- Filter by status
- Show completed (toggle)

**Acceptance Criteria:**
- ✅ Kanban board renders correctly
- ✅ Drag-and-drop updates status
- ✅ Progress bar accurate
- ✅ Color coding reflects status
- ✅ Overall progress calculated

**Test Cases:**
- TC-07-02-01: View project board → issues in correct columns
- TC-07-02-02: Drag issue to "In Progress" → status updated
- TC-07-02-03: All issues done → 100% progress shown
- TC-07-02-04: Behind issue → red indicator
- TC-07-02-05: Filter by assignee → only their issues shown

**API Endpoint:**
```
GET /api/projects/{projectId}/board?status=not_in_progress,in_progress,in_review,done
Authorization: Bearer {token}

Response (200 OK):
{
  "progress": 40,
  "columns": {
    "not_in_progress": [
      {
        "id": "uuid",
        "title": "string",
        "deadline": "2026-03-10",
        "progress": 60,
        "status": "yellow",
        "assignees": [{ "id": "uuid", "name": "..." }]
      }
    ],
    "in_progress": [...],
    "in_review": [...],
    "done": [...]
  }
}
```

---

## Dashboard Types

### Manager Dashboard (Top-Level)

View across all teams/projects:
- Project list with status (S-05-02)
- Team workload summary
- Alert summary (unresolved counts)
- Recent activities

### Team Dashboard

View team's projects and members:
- Team projects progress
- Member workload
- Team alerts
- Team condition (from surveys)

### Member Dashboard

View own and team assignments:
- My issues (grouped by project)
- Team's projects
- Team workload
- Team condition

---

## Dependencies & Ordering

**Must complete before:**
- None (support feature)

**Requires:**
- S-01 (authentication)
- S-03 (issues exist)
- S-04 (teams exist)
- S-05 (projects exist)

---

## Notes

- Visualizations are key for PM success (visibility)
- Kanban board preferred over list for quick status updates
- Gantt view (S-05-02) for timeline understanding
- All timestamps in UTC
- Real-time updates preferred (WebSocket, future enhancement)
