# Frontend ↔ API Gap Backlog

> Generated: 2026-03-26
> Purpose: Track missing/incomplete API endpoints needed before each frontend phase can be fully implemented.

---

## Phase Readiness Summary

| Phase | Title | Readiness | Blocker Count |
|-------|-------|-----------|---------------|
| 0A | Design System | ✅ Ready | 0 |
| 0B | Layout System | ✅ Ready | 0 |
| 1A | Teams | ⚠️ Partial (~70%) | 3 missing endpoints |
| 1B | Projects | ⚠️ Partial (~90%) | 1 missing endpoint + 1 filter gap |
| 1C | Issues | ✅ Ready | 0 (minor path differences, see notes) |
| 2A | Dashboard | ⚠️ Partial (~40%) | 4 missing endpoints/filters |
| 2B | Alerts | ⚠️ Partial (~60%) | 2 missing endpoints |
| 2C | Progress Board | ✅ Ready | 0 |
| 3A | Surveys | ⚠️ Partial (~70%) | 1 missing endpoint |
| 3B | Profile View | ❌ Not Ready | 2 missing endpoints |

---

## Missing API Endpoints (Ordered by Priority)

### Priority 1 — Blocks multiple phases

#### 1. `GET /teams/{teamId}/condition-summary`
- **Needed by**: Phase 1A (ConditionBadge), Phase 2A (TeamManagementTab FlaggedMembers)
- **Expected response**: `{ averageScore: number, status: "good"|"caution"|"warning", flaggedMembers: [{userId, name, score}] }`
- **Notes**: Aggregates survey answer data into team health indicator. May need survey data to be populated first.

#### 2. `GET /teams/{teamId}/member-workloads`
- **Needed by**: Phase 1A (WorkloadTable)
- **Expected response**: `{ members: [{ userId, name, avatar, assignedPoints, capacityPoints, indicator: "green"|"yellow"|"red" }] }`
- **Notes**: Aggregates assigned story points per member. Threshold: 40pt/week; green ≤80%, yellow 80-100%, red >100%.

#### 3. `GET /alerts` (global, with query params)
- **Needed by**: Phase 2A (AlertsTab on dashboard), Phase 2B (Alerts list page)
- **Expected query params**: `status` (active/resolved), `level` (yellow/red), `category`, `project_id`, `team_id`, `page`, `per_page`
- **Current state**: Only `GET /projects/{projectId}/alerts` exists (scoped to one project)
- **Notes**: The dashboard and alerts list page need a cross-project view of all alerts.

### Priority 2 — Blocks one phase each

#### 4. `GET /surveys/my/pending`
- **Needed by**: Phase 2A (SurveyAnswerTab), Phase 3A (survey answer flow)
- **Expected response**: `{ surveys: [{ id, title, teamName, dueDate, questions: [...] }] }`
- **Expected query params**: `team_id`
- **Current state**: `GET /surveys` exists but unclear if it filters to pending/unanswered only for current user.

#### 5. `POST /alerts/{alertId}/reopen`
- **Needed by**: Phase 2B (alert lifecycle management)
- **Current state**: Only `PATCH /alerts/{alertId}/resolve` exists. No way to reopen.

#### 6. `GET /users/{userId}/profile`
- **Needed by**: Phase 3B (profile view page)
- **Current state**: Only `POST /users/me/profile` exists (create own profile). No read endpoint for other users.

#### 7. `PATCH /users/me/profile`
- **Needed by**: Phase 3B (profile edit), also Profile Setup page (currently only POST exists)
- **Current state**: Only `POST /users/me/profile` exists. Specs expect ability to update profile after initial creation.

#### 8. `DELETE /projects/{projectId}/teams/{teamId}`
- **Needed by**: Phase 1B (SettingsTab — unassign team from project)
- **Current state**: `PATCH /projects/{projectId}/teams` exists for assigning teams but no un-assign/remove endpoint.

### Priority 3 — Nice-to-have / workaround possible

#### 9. `GET /projects` — missing `team_id` query filter
- **Needed by**: Phase 2A (ProjectProgressTab — show projects for current team)
- **Current state**: `GET /projects` has no query params at all. Frontend needs `team_id`, `status` filters.
- **Workaround**: Client-side filtering, but not ideal for pagination.

#### 10. `POST /teams/{teamId}/members`
- **Needed by**: Phase 1A (add existing user to team)
- **Current state**: Only `POST /teams/{teamId}/invitations` exists (email invite flow).
- **Workaround**: Use invitation flow for all member additions.

#### 11. `GET /issues?assignee=me`
- **Needed by**: Phase 2A (MyWorkTab — member's assigned issues across projects)
- **Current state**: `GET /projects/{projectId}/issues?assignee=...` exists per-project, but no global issues endpoint.
- **Notes**: Dashboard needs cross-project "my work" view.

---

## Existing Endpoint Adjustments Needed

### A. `GET /projects/{projectId}/issues` — response too slim
- **Current fields**: `id`, `title`, `status`, `storyPoints` (4 fields only)
- **Frontend needs**: `assignees`, `dueDate`, `priority`, `progress`, `estimatedMinutes`, `teamTag` for kanban/gantt views
- **Impact**: Phase 1B, 1C, 2C

### B. `GET /projects` — missing response fields
- **Frontend needs**: `progressPercent`, `alertCount` per project for the projects list cards
- **Impact**: Phase 1B

### C. `PATCH /projects/{projectId}/teams` — verb mismatch
- **Spec expects**: `POST /projects/{projectId}/teams` for assigning, `DELETE` for unassigning
- **Current**: Single `PATCH` endpoint for team assignment
- **Impact**: Phase 1B (may just need frontend to adapt to PATCH)

### D. Issue subtask endpoints — path mismatch
- **Spec references**: `/issues/{issueId}/sub-issues`
- **API implements**: `/issues/{issueId}/subtasks`
- **Impact**: Phase 1C — specs should be updated to match API paths, or vice versa

### E. DoD endpoint — path mismatch
- **Spec references**: `/issues/{issueId}/definition-of-dones`
- **API implements**: `/issues/{issueId}/definition-of-done`
- **Impact**: Phase 1C — minor naming difference, frontend uses generated client so this is fine

---

## OpenAPI Client Status

| Metric | Before Regen | After Regen |
|--------|-------------|-------------|
| Endpoints | 11 | **56** |
| TS client files | ~12 | **43** |
| Coverage | Auth, Profile, Teams only | **All implemented routes** |

**Status**: ✅ Client is now up-to-date with all implemented API routes.

---

## Recommended Implementation Order

### Can start frontend NOW (no API blockers):
1. **Phase 0A** — Design System (no API)
2. **Phase 0B** — Layout System (auth only)
3. **Phase 1C** — Issues (all endpoints exist)
4. **Phase 2C** — Progress Board (reuses existing endpoints)

### Need minor API work first:
5. **Phase 1B** — Projects (need: team unassign, richer response schemas)
6. **Phase 1A** — Teams (need: workloads + condition endpoints)
7. **Phase 3A** — Surveys (need: pending surveys filter)

### Need significant API work first:
8. **Phase 2A** — Dashboard (need: global alerts, my issues, condition, project filters)
9. **Phase 2B** — Alerts (need: global alerts list, reopen)
10. **Phase 3B** — Profile View (need: profile read endpoints)