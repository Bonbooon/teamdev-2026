# Team Management Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/business-logic/workflows/team-management.md`  
**Domain Model:** `docs/diagrams/domain-models/team-aggregate.puml`

---

## Purpose

Define the complete team management system including:
- Team creation and configuration
- Member invitation and management
- Role definition (task roles, not permission roles)
- Team condition window settings for surveys

---

## Scope

**MUST Features (Phase 1):**
- S-04-01: Team List (Managers view)
- S-04-02: Team List (Members view)
- S-04-03: Team Detail & Member Overview
- S-04-04: Team Creation
- S-04-05: Member Invitation

---

## Domain Entities

### Team (Aggregate Root)
- `id: UUID`
- `name: String` - Unique team name
- `description: String?` - Team purpose/context
- `startOfBusinessHour: Time?` - e.g., 09:00
- `endOfBusinessHour: Time?` - e.g., 18:00
- `timeZone: String` - e.g., Asia/Tokyo
- `status: TeamStatus` - active, archived
- `createdAt: DateTime`
- `updatedAt: DateTime`

### TeamStatus Enum
```
active   - Team is active
archived - Team is inactive (historical)
```

### TeamMember (Entity)
- `id: UUID`
- `teamId: UUID`
- `userId: UUID`
- `permissionRole: TeamMemberPermissionRole` - manager, member
- `status: MembershipStatus` - active, inactive
- `createdAt: DateTime`
- `updatedAt: DateTime`

### TeamMemberPermissionRole Enum
```
manager - Can create/edit team, manage members, view all projects
member  - Can view team/projects, create issues, answer surveys
```

### MembershipStatus Enum
```
active   - Member is active
inactive - Member is inactive (on leave, etc.)
```

### RoleDefinition (Entity)
- `id: UUID`
- `teamId: UUID`
- `name: String` - e.g., "Backend Lead", "QA"
- `description: String?`
- `difficultyLevel: Int?` - 1-5 (optional, for feature visibility)
- `isActive: Boolean` - Can only assign active roles
- `createdAt: DateTime`
- `updatedAt: DateTime`

### TeamConditionSetting (Entity)
- `teamId: UUID`
- `defaultWindowDays: ConditionWindowDays` - Survey response window
- `createdAt: DateTime`
- `updatedAt: DateTime`

### ConditionWindowDays Enum
```
d7   - Last 7 days
d14  - Last 14 days
d30  - Last 30 days
d90  - Last 90 days
```

---

## Requirements

### S-04-01: Team List (Managers)

**Requirement ID:** S-04-01  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** User authenticated, has manager role in teams  

**Main Flow:**
1. Manager opens app
2. "Team Management" tab visible (role-based)
3. List of all teams user manages displayed as cards
4. Each card shows:
   - Team name
   - Member count
   - Project count
   - Last activity date
5. Click card to open Team Detail (S-04-03)
6. "Create Team" button visible (floating or top)

**Card Display:**
```
[Team Name]
Members: 5 | Projects: 3 | Last Update: 2 hours ago
[View] [Edit]
```

**Business Rules:**
- Only teams where user has `permissionRole = manager` shown
- Teams can be archived (exclude from list by default, show toggle)
- Card click opens Team Detail page

**Filtering/Sorting:**
- Sort by: name, member count, project count, last activity (default: name)
- Filter by: status (active/archived)

**Error Cases:**
- No teams managed → Show empty state with "Create Team" CTA
- Permission denied (not manager) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Manager sees only managed teams
- ✅ Cards display team summary info
- ✅ Click card opens detail
- ✅ "Create Team" button accessible
- ✅ Empty state shown if no teams

**Test Cases:**
- TC-04-01-01: Manager with 3 teams → all 3 listed
- TC-04-01-02: Click team card → detail page opens
- TC-04-01-03: No teams managed → empty state + CTA
- TC-04-01-04: Non-manager user → 403 or hidden tab

**API Endpoint:**
```
GET /api/teams?role=manager
Authorization: Bearer {token}

Response (200 OK):
{
  "teams": [
    {
      "id": "uuid",
      "name": "Backend Team",
      "memberCount": 5,
      "projectCount": 3,
      "status": "active",
      "updatedAt": "2026-03-06T12:00:00Z"
    }
  ]
}
```

---

### S-04-02: Team List (Members)

**Requirement ID:** S-04-02  
**Type:** MUST (Phase 1)  
**Actor:** Team Member  
**Precondition:** User authenticated, is member of teams  

**Main Flow:**
1. Member opens app
2. "Team Management" tab visible (role-based)
3. List of all teams user belongs to displayed as cards
4. Same card display as S-04-01
5. Click card to open Team Detail (S-04-03)

**Business Rules:**
- Only teams where user has `status = active` shown
- Members cannot create teams
- Members see "View" option only (no edit/manage)
- Information read-only for members

**Acceptance Criteria:**
- ✅ Member sees all teams they belong to
- ✅ Card information visible
- ✅ Cannot create/edit teams
- ✅ Click card opens detail (read-only)

**Test Cases:**
- TC-04-02-01: Member of 2 teams → both listed
- TC-04-02-02: Click team → detail page opens
- TC-04-02-03: No "Create Team" button visible
- TC-04-02-04: Cannot edit team info

**API Endpoint:**
```
GET /api/teams?role=member
Authorization: Bearer {token}

Response (200 OK):
{
  "teams": [
    {
      "id": "uuid",
      "name": "Frontend Team",
      "memberCount": 4,
      "projectCount": 2,
      "status": "active",
      "updatedAt": "2026-03-05T15:30:00Z"
    }
  ]
}
```

---

### S-04-03: Team Detail

**Requirement ID:** S-04-03  
**Type:** MUST (Phase 1)  
**Actor:** Manager, Team Member  
**Precondition:** Team exists, user is member or manager  

**Main Flow:**
1. User opens Team Detail page
2. Two tabs visible: "Projects" and "Members"
3. **Projects Tab (default):**
   - List of projects assigned to team
   - Card view (same as project list)
   - Shows: project name, status, progress, deadline
4. **Members Tab:**
   - List of all team members
   - Table with columns: Name, Role, Status, Issues Assigned, Story Points (assigned/completed)
   - Shows workload overview per member

**Projects Tab Display:**
```
[Project Name]
Status: in_progress | Due: 2026-03-20
Progress: ████░░░░░░ 40%
[View Project]
```

**Members Tab Display:**
```
| Name          | Role     | Status | Issues | Story Pts (Assigned/Completed) |
|---|---|---|---|---|
| Alice Smith   | manager  | active | 3      | 13/8 (Behind) |
| Bob Johnson   | member   | active | 2      | 8/4 (Behind) |
| Carol Lee     | member   | active | 1      | 5/5 (Ahead) |
```

**Member Indicators:**
- "Behind": Completed points < Assigned points
- "Ahead": Completed points ≥ Assigned points
- Icons/colors for visual clarity

**Business Rules:**
- Team Detail is read-only view (for both managers and members)
- Edit operations via modal or separate page (manager only)
- Only active projects shown
- Only active members shown (toggle for inactive)

**Error Cases:**
- Team not found → 404 Not Found
- Permission denied (not member/manager) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Team overview displayed
- ✅ Projects listed with status
- ✅ Members listed with workload
- ✅ Tab switching works
- ✅ Read-only for members

**Test Cases:**
- TC-04-03-01: Open team detail → projects/members tabs visible
- TC-04-03-02: View members tab → all members listed with workload
- TC-04-03-03: Member behind → visual indicator shown
- TC-04-03-04: Non-member tries access → 403 error

**API Endpoints:**
```
GET /api/teams/{teamId}
Authorization: Bearer {token}

GET /api/teams/{teamId}/projects

GET /api/teams/{teamId}/members
```

---

### S-04-04: Team Creation

**Requirement ID:** S-04-04  
**Type:** MUST (Phase 1)  
**Actor:** Project Manager  
**Precondition:** User has manager role (or will become manager of new team)  

**Main Flow:**
1. Manager clicks "Create Team" button
2. Modal/form opens with fields:
   - Team name (required)
   - Description (optional)
   - Business hours (optional)
   - Timezone (optional)
3. Manager optionally selects members to invite
4. Manager optionally assigns projects
5. Click "Create"
6. Team created, members invited, redirect to Team Detail

**Form Fields:**
- `name`: max 100 chars, non-empty
- `description`: max 500 chars
- `startOfBusinessHour`: time picker (default: 09:00)
- `endOfBusinessHour`: time picker (default: 18:00)
- `timeZone`: timezone dropdown (default: device timezone)
- `memberInvitations`: multi-select user list
- `projectAssignments`: multi-select project list

**Business Rules:**
- Team name must be unique within company (per subdomain)
- Creator becomes manager of the team
- Initial members set via invitation (S-04-05)
- Projects can be assigned later
- At least 1 member (the creator) required

**RoleDefinition Setup:**
After team creation, default role definitions created:
- "Project Manager"
- "Developer"
- "Designer"
- "QA Engineer"

These can be edited later (not in Phase 1 scope).

**Error Cases:**
- Team name already exists → 422 Unprocessable Entity
- Invalid timezone → 422 error
- User lacks permission to create team → 403 Forbidden

**Acceptance Criteria:**
- ✅ Team created with valid data
- ✅ Creator becomes manager
- ✅ Members invited (if selected)
- ✅ Default role definitions created
- ✅ Success toast shown
- ✅ Redirect to Team Detail

**Test Cases:**
- TC-04-04-01: Create team with name only → team created
- TC-04-04-02: Create with members → invitations sent
- TC-04-04-03: Duplicate team name → validation error
- TC-04-04-04: Invalid timezone → validation error

**API Endpoint:**
```
POST /api/teams
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "name": "string",
  "description": "string?",
  "startOfBusinessHour": "HH:mm",
  "endOfBusinessHour": "HH:mm",
  "timeZone": "string",
  "memberInvitations": ["uuid", ...],
  "projectAssignments": ["uuid", ...]
}

Response (201 Created):
{
  "team": { ...Team object... }
}
```

---

### S-04-05: Member Invitation

**Requirement ID:** S-04-05  
**Type:** MUST (Phase 1)  
**Actor:** Team Manager  
**Precondition:** Team exists, user is manager  

**Main Flow:**
1. Manager opens Team Detail
2. Click "Invite Member" button (Members tab)
3. Modal opens with user search
4. Manager searches/selects users to invite
5. Click "Send Invite"
6. Invitation created, email sent to invitee

**User Search:**
- Search by name, email
- Show user profile preview (avatar, title, expertise)
- Multi-select (invite multiple at once)

**Invitation Entity:**
```
TeamInvitation {
  id: UUID
  teamId: UUID
  invitedUserId: UUID
  invitedByUserId: UUID
  permissionRole: TeamMemberPermissionRole (default: member)
  status: InvitationStatus (pending, accepted, declined)
  expiresAt: DateTime (14 days from creation)
  createdAt: DateTime
}
```

**Email Sent to Invitee:**
```
Subject: You're invited to join [Team Name]

Body:
Hi [Name],

[Manager Name] has invited you to join the team "[Team Name]".

Expertise: [Team context from description]

Accept Invite: [Link with token]
Decline: [Link with token]

Invite expires in 14 days.
```

**Acceptance Flow (Invitee):**
1. Invitee clicks "Accept Invite" link in email
2. Logged in (if not)
3. Invitation accepted, user becomes team member
4. Redirected to Team Detail

**Rejection Flow (Invitee):**
1. Invitee clicks "Decline" link
2. Invitation marked declined
3. No team membership created

**Business Rules:**
- Invitations expire after 14 days
- Cannot invite users already in team
- Manager can set permission role (manager or member)
- Invitation unique per (team, user)

**Error Cases:**
- User already in team → 422 Unprocessable Entity
- User not found → 404 Not Found
- Invalid permission role → 422 error
- Permission denied (not manager) → 403 Forbidden

**Acceptance Criteria:**
- ✅ Invite sent to user
- ✅ Email notification delivered
- ✅ Invitee can accept/decline
- ✅ Accepted invitation creates TeamMember
- ✅ Expired invitations handled

**Test Cases:**
- TC-04-05-01: Send invitation → email delivered
- TC-04-05-02: Invitee accepts → member created
- TC-04-05-03: Invitee declines → member not created
- TC-04-05-04: Duplicate invitation → 422 error
- TC-04-05-05: Expired invitation → invalid/expired message

**API Endpoints:**
```
POST /api/teams/{teamId}/invitations
Authorization: Bearer {token}
Request:
{
  "invitedUserId": "uuid",
  "permissionRole": "manager|member"
}

GET /api/invitations/{invitationToken}
// Accept invitation (no auth)
POST /api/invitations/{invitationToken}/accept

// Decline invitation (no auth)
POST /api/invitations/{invitationToken}/decline
```

---

## Team Lifecycle & Archival

**Active Team:** `status = active`, members receive surveys, projects assigned

**Archived Team:** `status = archived`, can be unarchived later, no active surveys

Archive operation:
```
PATCH /api/teams/{teamId}
Request:
{
  "status": "archived"
}
```

Only manager can archive. Manager can unarchive.

---

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `GET /api/teams` | GET | List teams (manager/member filtered) |
| `GET /api/teams/{teamId}` | GET | Get team detail |
| `GET /api/teams/{teamId}/projects` | GET | List team projects |
| `GET /api/teams/{teamId}/members` | GET | List team members |
| `POST /api/teams` | POST | Create team |
| `PATCH /api/teams/{teamId}` | PATCH | Update team (manager only) |
| `POST /api/teams/{teamId}/invitations` | POST | Send invitation |
| `POST /api/invitations/{token}/accept` | POST | Accept invitation |
| `POST /api/invitations/{token}/decline` | POST | Decline invitation |

---

## Dependencies & Ordering

**Must complete before:**
- Project management (projects assigned to teams)
- Issue management (assignees from team members)
- Alert system (alerts scoped to projects/teams)

**Requires:**
- S-01 (authentication, users exist)

---

## Notes

- Teams are the core organizational unit (projects → teams → members)
- RoleDefinitions are task roles, not permission roles
- PermissionRoles are limited to manager/member in Phase 1
- Team hierarchy not supported (single-level teams only)
- All timestamps in UTC
