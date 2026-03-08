# Aggregate Dependency Order

This document defines the implementation order for domain aggregates based on their dependency relationships.

---

## Dependency Levels

### Level 0 — No Dependencies (implement first, in parallel)

| Aggregate | Description |
|-----------|-------------|
| **User** | Foundation for all team/project operations |
| **ActionPlan** | Reference data for alert suggested actions |
| **SurveyTemplate** | Reusable survey template library |
| **TriggerDefinition** | Configuration for alert trigger evaluation |

### Level 1 — Depends on Level 0

| Aggregate | Dependencies |
|-----------|-------------|
| **Team** (+ TeamMember, RoleDefinition, TeamConditionSetting) | User |
| **TeamInvitation** | Team, User |

### Level 2 — Depends on Levels 0–1

| Aggregate | Dependencies |
|-----------|-------------|
| **Project** (+ ProjectTeam, ProjectRoleAssignment, ProjectRoleAssignmentOwner) | Team, RoleDefinition, TeamMember |
| **SurveySetting** (+ SurveySettingTime) | Team, SurveyTemplate, TeamMember |

### Level 3 — Depends on Levels 0–2

| Aggregate | Dependencies |
|-----------|-------------|
| **IssueTemplate** (+ IssueTemplateItem, IssueTemplateItemValue) | Project |
| **Alert** (+ AlertLog, AlertActionPlanSuggestion) | Project, ActionPlan |
| **Survey** (+ SurveyAnswer) | SurveySetting, User |

### Level 4 — Most Complex, Depends on Many

| Aggregate | Dependencies |
|-----------|-------------|
| **Issue** (+ IssueTeam, IssueAssignee, IssueDefinitionOfDone, IssueWorkLog, IssueStatusEvent, IssueRoleAssignment, IssueRoleAssignmentOwner) | Project, IssueTemplate, Team, TeamMember, RoleDefinition, User |

---

## Dependency Graph

```
Level 0 (No Dependencies)
├── User
├── ActionPlan
├── SurveyTemplate
└── TriggerDefinition

Level 1
├── Team  ←  User
└── TeamInvitation  ←  Team, User

Level 2
├── Project  ←  Team, RoleDefinition, TeamMember
└── SurveySetting  ←  Team, SurveyTemplate

Level 3
├── IssueTemplate  ←  Project
├── Alert  ←  Project, ActionPlan
└── Survey  ←  SurveySetting, User

Level 4
└── Issue  ←  Project, IssueTemplate, Team, TeamMember, RoleDefinition, User
```

---

## Critical Path (MVP Alert System)

```
User → Team → Project → Issue → Alert
                 ↑                  ↑
          RoleDefinition      ActionPlan, TriggerDefinition
```

---

## Recommended Implementation Order

| Priority | Aggregate | Reason |
|----------|-----------|--------|
| 1 | **User** | Foundation for everything |
| 2 | **Team** (+ TeamMember, RoleDefinition) | Org structure; required by Project & Issue |
| 3 | **Project** (+ ProjectTeam) | Work container; required by Issue & Alert |
| 4 | **ActionPlan** + **TriggerDefinition** | Independent roots needed by Alert |
| 5 | **IssueTemplate** | SMART issue enforcement; needed by Issue |
| 6 | **Issue** | Core work unit (most complex — 8 entities) |
| 7 | **Alert** | Core MVP feature — project delay detection |
| 8 | **SurveyTemplate** → **SurveySetting** → **Survey** | Team health tracking (can defer to Phase 2) |
| 9 | **TeamInvitation** | Membership flow (can defer) |

---

Generated: 2026/03/08
