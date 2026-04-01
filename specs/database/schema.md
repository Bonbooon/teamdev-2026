# Database Schema Documentation

**Version:** 1.1  
**Last Updated:** 2026/04/01  
**Source Spec:** Migrations in `teamdev-2026-api/web/database/migrations/`  
**Domain Models:** `docs/diagrams/domain-models/`

---

## Overview

This document provides human-readable explanation of the database schema defined via Laravel migrations. The migrations are the source of truth; this doc explains the design and relationships.

See migration files directly for exact column definitions, defaults, and constraints.

---

## Core Entities by Aggregate

### Identity & Access Context

**Users Table** (Aggregate Root)
- `id: UUID` - Primary key
- `email: String UNIQUE` - Unique email, normalized
- `email_verified_at: DateTime?` - Null until Google OAuth verification
- `created_at, updated_at: Timestamps`

**Profiles Table** (Entity)
- `user_id: UUID FK` - Links to User
- `first_name, last_name: String`
- `first_name_kana, last_name_kana: String?`
- `avatar_url: String?` - From Google
- `about_me, hobby: String?`
- `job_title, expertise: String?`
- `joined_company_at: Date?`
- `work_history: String?`
- `created_at, updated_at: Timestamps`

**ProfileExternalLinks Table** (Entity)
- `id: UUID`
- `user_id: UUID FK`
- `platform: String?` - linkedin, github, etc.
- `url: String`
- `position: Int` - Display order
- `created_at, updated_at: Timestamps`

**OAuthAccounts Table** (Entity)
- `id: UUID`
- `user_id: UUID FK`
- `provider: String` - "google"
- `provider_user_id: String` - Google's user ID
- `created_at: Timestamp`
- Unique constraint: `(provider, provider_user_id)`

**PersonalAccessTokens Table** (Infrastructure — Laravel Sanctum)
- `id: BigInt AUTO_INCREMENT` - Primary key
- `tokenable_type: String` - Polymorphic type (e.g., `App\Models\User`)
- `tokenable_id: VARCHAR(36)` - **UUID** of the owning User (changed from default bigint via migration `2026_03_07_000001`)
- `name: String` - Token label (e.g., "auth_token")
- `token: String(64) UNIQUE` - SHA-256 hash of the plain-text token
- `abilities: Text?` - JSON array of token abilities
- `last_used_at: DateTime?`
- `expires_at: DateTime?`
- `created_at, updated_at: Timestamps`
- Index: `(tokenable_type, tokenable_id)`

> **Note:** This table is managed by Laravel Sanctum's built-in migration.
> A custom migration (`2026_03_07_000001_fix_personal_access_tokens_tokenable_id_to_uuid.php`)
> changes `tokenable_id` from `bigint` to `varchar(36)` to support UUID primary keys on the `users` table.

---

### Team Context

**Teams Table** (Aggregate Root)
- `id: UUID`
- `name: String`
- `description: String?`
- `start_of_business_hour: Time?`
- `end_of_business_hour: Time?`
- `time_zone: String`
- `status: Enum(active, archived)`
- `created_at, updated_at: Timestamps`
- Unique constraint: `name`

**TeamMembers Table** (Entity)
- `id: UUID`
- `team_id: UUID FK`
- `user_id: UUID FK`
- `permission_role: Enum(manager, member)`
- `status: Enum(active, inactive)`
- `created_at, updated_at: Timestamps`
- Unique constraint: `(team_id, user_id)`

**RoleDefinitions Table** (Entity)
- `id: UUID`
- `team_id: UUID FK`
- `name: String` - "Backend Lead", "QA", etc.
- `description: String?`
- `difficulty_level: Int?` - 1-5
- `is_active: Boolean`
- `created_at, updated_at: Timestamps`
- Unique constraint: `(team_id, name)`

**TeamConditionSettings Table** (Entity)
- `team_id: UUID FK PK`
- `default_window_days: Enum(d7, d14, d30, d90)`
- `created_at, updated_at: Timestamps`

**TeamInvitations Table** (Entity)
- `id: UUID`
- `team_id: UUID FK`
- `invitee_email: String`
- `invited_by_user_id: UUID FK`
- `permission_role: Enum(manager, member)`
- `status: Enum(pending, accepted, declined)`
- `token: String` - Unique token for acceptance link
- `expires_at: DateTime`
- `created_at: Timestamp`
- Unique constraint: `(team_id, invitee_email)`

---

### Project Context

**Projects Table** (Aggregate Root)
- `id: UUID`
- `title: String`
- `description: String?`
- `due_at: DateTime?`
- `status: Enum(not_in_progress, in_progress, completed, idle)`
- `created_at, updated_at: Timestamps`

**ProjectTeams Table** (Entity)
- `project_id: UUID FK`
- `team_id: UUID FK`
- `assigned_at: DateTime`
- Primary key: `(project_id, team_id)`

**ProjectRoleAssignments Table** (Entity)
- `id: UUID`
- `project_id: UUID FK`
- `role_definition_id: UUID FK`
- `created_at, updated_at: Timestamps`
- Unique constraint: `(project_id, role_definition_id)`

**ProjectRoleAssignmentOwners Table** (Entity)
- `project_role_assignment_id: UUID FK`
- `team_member_id: UUID FK`
- Primary key: `(project_role_assignment_id, team_member_id)`

**TeamProjectPerformanceDaily Table** (Entity)
- `id: UUID or BigInt`
- `snapshot_date: Date`
- `project_id: UUID FK`
- `team_id: UUID FK`
- `closed_issue_count: Int`
- `overdue_open_issue_count: Int`
- `completed_story_points: Int`
- `estimated_minutes_closed: Int`
- `actual_minutes_logged: Int`
- `on_time_completion_rate: Decimal?`
- `avg_cycle_time_hours: Decimal?`
- `created_at: Timestamp`
- Unique constraint: `(snapshot_date, project_id, team_id)`

**TeamMemberProjectPerformanceDaily Table** (Entity)
- Similar to above, with `team_member_id` instead of `team_id`

---

### Issue Context

**IssueTemplates Table** (Entity)
- `id: UUID`
- `name: String`
- `description: String?`
- `is_active: Boolean`
- `created_at, updated_at: Timestamps with time zone`

**IssueTemplateItems Table** (Entity)
- `id: UUID`
- `issue_template_id: UUID FK`
- `item_key: String` - Form key used in `templateItemValues`
- `label: String`
- `value_type: Enum(string, integer, date, datetime, boolean, number, json)`
- `is_required: Boolean`
- `position: Int`
- Unique constraint: `(issue_template_id, item_key)`
- Unique constraint: `(issue_template_id, position)`

**Issues Table** (Aggregate Root)
- `id: UUID`
- `project_id: UUID FK`
- `parent_issue_id: UUID FK?` - Null for top-level, set for subtasks
- `issue_template_id: UUID? FK`
- `title: String`
- `story_points: Int` - 1-13
- `estimated_minutes: Int`
- `deadline: DateTime?`
- `started_at: DateTime?`
- `closed_at: DateTime?`
- `status: Enum(not_in_progress, in_progress, in_review, done)`
- `created_at, updated_at: Timestamps`

**IssueTeams Table** (Entity)
- `issue_id: UUID FK`
- `team_id: UUID FK`
- `assigned_at: DateTime`
- Primary key: `(issue_id, team_id)`

**IssueTemplateItemValues Table** (Entity)
- `issue_id: UUID FK`
- `issue_template_item_id: UUID FK`
- `value: JSONB` - Stores the submitted template item value
- `created_at, updated_at: Timestamps with time zone`
- Primary key: `(issue_id, issue_template_item_id)`

**IssueAssignees Table** (Entity)
- `issue_id: UUID FK`
- `team_member_id: UUID FK`
- Primary key: `(issue_id, team_member_id)`

**IssueDefinitionOfDones Table** (Entity)
- `id: UUID`
- `issue_id: UUID FK`
- `description: String`
- `is_completed: Boolean`
- `created_at, updated_at: Timestamps`

**IssueWorkLogs Table** (Entity)
- `id: UUID`
- `issue_id: UUID FK`
- `team_member_id: UUID FK`
- `source: Enum(manual, github_api, github_actions)`
- `external_log_id: String?` - GitHub commit SHA
- `started_at: DateTime`
- `ended_at: DateTime?`
- `minutes: Int`
- `description: Text?`
- `created_at, updated_at: Timestamps`

**IssueStatusEvents Table** (Entity)
- `id: BigInt` - Auto-increment for time-series
- `issue_id: UUID FK`
- `from_status: Enum?` - Null if first event
- `to_status: Enum(not_in_progress, in_progress, in_review, done)`
- `changed_by: UUID FK?`
- `created_at: Timestamp`

**IssueRoleAssignments Table** (Entity)
- `id: UUID`
- `issue_id: UUID FK`
- `role_definition_id: UUID FK`
- `created_at, updated_at: Timestamps`

**IssueRoleAssignmentOwners Table** (Entity)
- `issue_role_assignment_id: UUID FK`
- `team_member_id: UUID FK`
- Primary key: `(issue_role_assignment_id, team_member_id)`

---

### Alert Context

**Alerts Table** (Aggregate Root)
- `id: UUID`
- `project_id: UUID FK`
- `category: String` - Alert type (project_progress_delay, issue_progress_delay, workload_overload, etc.)
- `description: String`
- `level: Enum(yellow, red)`
- `is_resolved: Boolean`
- `created_at: Timestamp`

**AlertLogs Table** (Entity)
- `id: BigInt` - Auto-increment for sequence
- `alert_id: UUID FK`
- `triggered_at: DateTime`
- `resolved_at: DateTime?`
- `created_at: Timestamp`

**ActionPlans Table** (Entity)
- `id: UUID`
- `code: String` - "decompose-tasks", etc.
- `title: String`
- `description: String`
- `created_at, updated_at: Timestamps`

**AlertActionPlanSuggestions Table** (Entity)
- `alert_id: UUID FK`
- `action_plan_id: UUID FK`
- `priority: Int` - 1, 2, 3 (highest to lowest)
- `rationale: JSON?` - Context data
- `suggested_at: DateTime`
- Primary key: `(alert_id, action_plan_id)`

---

### Survey Context

**SurveyTemplates Table** (Aggregate Root)
- `id: UUID`
- `name: String`
- `description: String?`
- `created_at, updated_at: Timestamps`

**SurveyQuestions Table** (Entity)
- `id: UUID`
- `survey_template_id: UUID FK`
- `question: String`
- `explanation: String?`
- `position: Int`
- `created_at, updated_at: Timestamps`

**SurveyQuestionOptions Table** (Entity)
- `id: UUID`
- `survey_question_id: UUID FK`
- `label: String`
- `position: Int`
- `created_at, updated_at: Timestamps`

**SurveySettings Table** (Aggregate Root)
- `id: UUID`
- `team_id: UUID FK`
- `survey_template_id: UUID FK`
- `setter_id: UUID FK` - User who configured
- `recurring_interval_days: Int` - 1, 7, 14, 30, 90, 180, 365
- `created_at, updated_at: Timestamps`
- Unique constraint: `(team_id, survey_template_id)`

**SurveySettingTimes Table** (Entity)
- `id: UUID`
- `survey_setting_id: UUID FK`
- `delivery_time: Time` - HH:MM format
- `created_at, updated_at: Timestamps`

**Surveys Table** (Aggregate Root)
- `id: UUID`
- `survey_setting_id: UUID FK`
- `recipient_id: UUID FK` - Team member
- `delivered_at: DateTime`
- `last_answered_at: DateTime?`
- `created_at, updated_at: Timestamps`

**SurveyAnswers Table** (Entity)
- `survey_id: UUID FK`
- `survey_question_id: UUID FK`
- `selected_option_id: UUID FK`
- `answered_at: DateTime`
- Primary key: `(survey_id, survey_question_id)`

---

### Integration & Operational Tables

**TriggerDefinitions Table** (Entity)
- `id: UUID`
- `name: String` - "project_progress_yellow", etc.
- `target_type: String` - Target entity type (survey, issue, project, team_member)
- `condition_type: String` - Condition type identifier
- `condition_value: Int?` - Threshold value (nullable for complex conditions)
- `condition_params: JSON` - Additional condition parameters
- `alert_level: String` - Alert severity (yellow, red)
- `is_active: Boolean`
- `created_at: Timestamp`

**TriggerExecutionLogs Table** (Entity)
- `id: BigInt`
- `trigger_definition_id: UUID FK`
- `triggered_at: DateTime`
- `alert_id: UUID FK?` - Alert created by trigger
- `execution_status: Enum(success, failure)`
- `error_message: String?`
- `created_at: Timestamp`

---

## Key Relationships

### Foreign Key Relationships

```
User (1) ← (0..*) Profile
User (1) ← (0..*) ProfileExternalLink
User (1) ← (0..*) OAuthAccount

Team (1) ← (0..*) TeamMember
Team (1) ← (0..*) RoleDefinition
Team (1) ← (0..*) TeamInvitation
Team (1) ← (1) TeamConditionSetting

Project (1) ← (0..*) ProjectTeam
Project (1) ← (0..*) Issue
Project (1) ← (0..*) ProjectRoleAssignment
Project (1) ← (0..*) Alert

Issue (1) ← (0..*) IssueAssignee
Issue (1) ← (0..*) IssueDefinitionOfDone
Issue (1) ← (0..*) IssueWorkLog
Issue (1) ← (0..*) IssueStatusEvent
Issue (1) ← (0..*) SubtaskIssue (self-reference: parent_issue_id)

Alert (1) ← (0..*) AlertLog
Alert (1) ← (1..*) AlertActionPlanSuggestion

SurveyTemplate (1) ← (1..*) SurveyQuestion
SurveyQuestion (1) ← (1..*) SurveyQuestionOption
SurveySetting (1) ← (1..*) SurveySettingTime
SurveySetting (1) ← (0..*) Survey
Survey (1) ← (0..*) SurveyAnswer
```

---

## Indexes

**Performance-Critical Indexes:**

- `users.email` - Login lookups
- `team_members (team_id, user_id)` - Team membership checks
- `issues (project_id, status)` - Issue filtering by project and status
- `issue_work_logs (issue_id, created_at)` - Work log time-series
- `alerts (project_id, is_resolved)` - Alert listing
- `survey_answers (survey_id, survey_question_id)` - Survey response lookups
- `team_project_performance_daily (snapshot_date, project_id)` - Metrics queries

---

## Data Retention Policies

| Entity | Retention | Notes |
|--------|-----------|-------|
| User | Indefinite | Historical users (soft delete optional) |
| Team | Indefinite | Archived teams kept |
| Project | Indefinite | Completed projects kept |
| Issue | Indefinite | All issues historical |
| IssueStatusEvent | Indefinite | Audit trail |
| IssueWorkLog | Indefinite | Time tracking history |
| Alert | Indefinite | All alerts kept |
| AlertLog | Indefinite | Trigger history |
| Survey | Indefinite | Response history |
| TriggerExecutionLog | 90 days | Cleanup old execution logs |

---

## Migration Strategy

All migrations idempotent and reversible:
- `up()` method: Create/modify tables
- `down()` method: Drop/revert tables
- Run: `php artisan migrate`
- Rollback: `php artisan migrate:rollback`

Migrations in production must be:
- Zero-downtime (add columns with defaults before removing)
- Tested in staging first
- Executed during low-traffic window

---

## Notes

- All IDs are UUID (v4) unless otherwise noted
- BigInt used for sequence/auto-increment (for time-series)
- All timestamps in UTC
- Soft deletes not used in Phase 1 (consider for Phase 2)
- No denormalization in Phase 1 (normalized schema)
- Indexes added based on access patterns observed
