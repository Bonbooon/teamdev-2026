# Layout & Navigation Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/business-logic/workflows/layout-navigation.md`

---

## Purpose

Define the overall layout and navigation structure of the application, including role-based views and tab organization.

---

## Scope

**WANT Features (Phase 1):**
- S-08-01: Top Page Layout (Manager)
- S-08-02: Top Page Layout (Member)

---

## Top-Level Layout Structure

### Header
- Logo/home link
- Current user name + avatar
- Logout button

### Main Navigation (Tab Bar)

Tabs change based on user role:

---

## S-08-01: Top Page Layout (Manager)

**Requirement ID:** S-08-01  
**Type:** WANT (Phase 1)  
**Actor:** Project Manager  
**Precondition:** User has manager role in at least one team  

**Tab Structure:**
```
[Logo] Home | Alerts | Teams | Projects | Surveys | [Profile] [Logout]
```

**Tab Descriptions:**

1. **Alerts** (default on first load)
   - Display: Alert list board (S-02-01)
   - Shows: All unresolved alerts across managed projects
   - Color-coded: Yellow/Red

2. **Teams**
   - Display: Team management view (S-04-01)
   - Shows: Teams managed by user
   - Actions: Create team, invite members, manage roles

3. **Projects**
   - Display: Project list + progress overview (S-05-02)
   - Shows: All projects assigned to managed teams
   - Actions: Create project, manage teams, view progress

4. **Surveys**
   - Display: Survey settings/configuration (Phase 2 detail, basic config in Phase 1)
   - Shows: Survey schedule, response rates
   - Actions: Configure survey template, manage frequency

### Alert Board Display (Default Tab)

```
Alerts                                [Resolved] [Active]
─────────────────────────────────────────────────────

[Project 1]
🟡 Yellow - Project at risk of delay (2 days)
   [View] [Resolve]

🔴 Red - Critical path issue behind
   [View] [Resolve]

[Project 2]
🟡 Yellow - Workload overload detected
   [View] [Resolve]

─────────────────────────────────────────────────────
Summary: 3 Yellow | 1 Red | Last updated: 5 mins ago
```

### Layout Elements

**Header Bar:**
```
┌──────────────────────────────────────────────────────────┐
│ [Logo] Home                     [Alice Smith] [Logout]   │
└──────────────────────────────────────────────────────────┘
```

**Tab Navigation:**
```
┌──────────────────────────────────────────────────────────┐
│ Alerts | Teams | Projects | Surveys                      │
└──────────────────────────────────────────────────────────┘
```

**Content Area:**
- Full width, responsive
- Sidebar optional (future navigation refinement)

---

## S-08-02: Top Page Layout (Member)

**Requirement ID:** S-08-02  
**Type:** WANT (Phase 1)  
**Actor:** Team Member  
**Precondition:** User is member of at least one team  

**Tab Structure:**
```
[Logo] Home | My Work | Teams | Projects | Surveys | [Profile] [Logout]
```

**Tab Descriptions:**

1. **My Work** (default on first load)
   - Display: Member's assigned issues (project progress board for own projects)
   - Shows: Issues assigned to user across all teams
   - Grouped by: Project and status
   - Actions: Update issue status, log work

2. **Teams**
   - Display: Team list (S-04-02)
   - Shows: All teams user belongs to
   - Actions: View team detail

3. **Projects**
   - Display: Project list (read-only)
   - Shows: All projects for assigned teams
   - Actions: View project progress

4. **Surveys**
   - Display: Survey response interface
   - Shows: Pending surveys to answer
   - Actions: Answer survey, view history

### My Work Tab Display

```
My Work
─────────────────────────────────────────────────────

[Project 1: Backend API]
├ Not Started:  3 issues
├ In Progress:  2 issues
├ In Review:    1 issue
├ Done:         4 issues
└ Progress: ████████░░ 60%

[Project 2: Frontend UI]
├ Not Started:  1 issue
├ In Progress:  2 issues
├ In Review:    0 issues
├ Done:         2 issues
└ Progress: ████░░░░░░ 40%

─────────────────────────────────────────────────────

My Issues Summary:
- Unstarted: 4
- In Progress: 4
- In Review: 1
- Complete: 6
```

Can click on project to see Kanban board or full project view.

---

## Layout Differences by Role

| Feature | Manager | Member |
|---------|---------|--------|
| Create Project | ✅ | ❌ |
| Create Team | ✅ | ❌ |
| Manage Members | ✅ | ❌ |
| Configure Surveys | ✅ | ❌ |
| View Alerts | ✅ (all) | ❌ (team only, future) |
| View Team Workload | ✅ | ✅ (view only) |
| Drag Issues on Board | ✅ (own) | ✅ (own) |
| Answer Surveys | ✅ | ✅ |
| View Profiles | ✅ | ✅ |

---

## Responsive Design

### Desktop (1200px+)
- Full tab bar visible
- Sidebar optional
- Multi-column layouts (e.g., Kanban)

### Tablet (768px - 1200px)
- Stacked layout
- Horizontal scroll for tables/Kanban
- Collapsible sidebar

### Mobile (< 768px)
- Hamburger menu for tabs
- Single-column layout
- Stack all elements vertically

---

## Navigation Flow Examples

### Manager Starting App
1. Login → Dashboard (Alerts tab)
2. See unresolved alerts
3. Click "View" → Project detail
4. Drag issue on board → Update status
5. Click "Teams" → Create new team
6. Click "Projects" → Create new project

### Member Starting App
1. Login → Dashboard (My Work tab)
2. See assigned issues
3. Click issue → Detail page
4. Update status or log work
5. Click "Surveys" → Answer pending survey

---

## Business Rules

- Default tab based on role (Alerts for manager, My Work for member)
- All tabs accessible based on role
- Navigation state preserved (last tab remembers selection)
- Logout clears all session state

---

## Acceptance Criteria

- ✅ Role-based tabs displayed correctly
- ✅ Default tab loads on entry
- ✅ Tab switching works
- ✅ Content appropriate to tab
- ✅ Manager sees all features
- ✅ Member sees limited features

---

## Test Cases

- TC-08-01-01: Manager logs in → Alerts tab default
- TC-08-01-02: Member logs in → My Work tab default
- TC-08-01-03: Switch tabs → content updates
- TC-08-01-04: Tab state persists after refresh
- TC-08-02-01: Member cannot see "Create Project" button
- TC-08-02-02: Manager sees all tabs

---

## Future Enhancements (Phase 2+)

- Collapsible sidebar with quick access
- Customizable dashboard widgets
- Dark mode
- Notification center
- Search across projects/issues

---

## Dependencies & Ordering

**Must complete before:**
- App is launched (foundational)

**Requires:**
- S-01 (authentication, roles defined)

---

## Notes

- Tab bar is primary navigation method
- Alerts default for managers (they focus on risk)
- My Work default for members (they focus on tasks)
- All timestamps in UTC
- Responsive design essential for mobile/tablet usage
