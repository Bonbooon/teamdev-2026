CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE EXTENSION IF NOT EXISTS "citext";

CREATE TYPE project_status AS ENUM (
  'not_in_progress',
  'in_progress',
  'completed',
  'idle'
);

CREATE TYPE issue_status AS ENUM (
  'not_in_progress',
  'in_progress',
  'in_review',
  'done'
);

CREATE TYPE alert_level AS ENUM (
  'red',
  'yellow'
);

CREATE TYPE alert_category AS ENUM (
    'project_progress_delay',
    'issue_progress_delay',
    'workload_overload',
    'communication_gap',
    'key_person_absence',
    'task_dependency_blocking',
    'decision_paralysis',
    'buffer_depletion'
);

CREATE TYPE team_status AS ENUM (
  'active',
  'archived'
);

CREATE TYPE membership_status AS ENUM (
  'active',
  'inactive'
);

CREATE TYPE team_member_permission_role AS ENUM (
    'manager',
    'member'
);

CREATE TYPE invitation_status AS ENUM (
  'pending',
  'accepted',
    'expired',
    'revoked'
);

CREATE TYPE condition_window_days AS ENUM (
    '7',
    '14',
    '30',
    '90'
);

CREATE TYPE survey_recurring_interval_days AS ENUM (
    '1',
    '7',
    '14',
    '30',
    '90',
    '180',
    '365'
);

CREATE TYPE issue_template_item_value_type AS ENUM (
    'string',
    'integer',
    'date',
    'datetime',
    'boolean',
    'number',
    'json'
);

CREATE TYPE work_log_source AS ENUM (
    'manual',
    'github_api',
    'github_actions'
);

CREATE TYPE trigger_condition_type AS ENUM (
    'not_answered_within',
    'progress_gap_exceeds',
    'workload_below_required',
    'document_stale_days',
    'assignee_missing_duration',
    'absence_impact_detected'
);

CREATE TYPE trigger_execution_status AS ENUM (
    'queued',
    'evaluated',
    'triggered',
    'skipped',
    'failed'
);

-- Identity & Access
-- UUID policy: IDs are generated as UUIDv7 in application layer.
-- Database-side UUID defaults may remain temporarily during transition.

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    email CITEXT NOT NULL UNIQUE,
    email_verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE profiles (
    user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    first_name_kana TEXT,
    last_name_kana TEXT,
    avatar_url TEXT,
    about_me TEXT,
    hobby TEXT,
    job_title TEXT,
    expertise TEXT,
    joined_company_at DATE,
    work_history TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE profile_external_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID NOT NULL REFERENCES profiles (user_id) ON DELETE CASCADE,
    platform TEXT,
    url TEXT NOT NULL,
    position INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, url)
);

CREATE INDEX idx_profile_external_links_user_id ON profile_external_links (user_id);

CREATE TABLE oauth_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    provider TEXT NOT NULL,
    provider_user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (provider, provider_user_id)
);

CREATE INDEX idx_oauth_accounts_user_id ON oauth_accounts (user_id);

-- Team
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name TEXT NOT NULL,
    description TEXT,
    start_of_business_hour TIME,
    end_of_business_hour TIME,
    time_zone TEXT NOT NULL,
    status team_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users (id),
    permission_role team_member_permission_role NOT NULL,
    status membership_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, user_id)
);

CREATE INDEX idx_team_members_team_id ON team_members (team_id);

CREATE INDEX idx_team_members_user_id ON team_members (user_id);

CREATE TABLE role_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    difficulty_level SMALLINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, name)
);

CREATE TABLE team_condition_settings (
    team_id UUID PRIMARY KEY REFERENCES teams (id) ON DELETE CASCADE,
    default_window_days condition_window_days NOT NULL DEFAULT '14',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE team_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    inviter_user_id UUID NOT NULL REFERENCES users (id),
    invitee_email CITEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    status invitation_status NOT NULL DEFAULT 'pending',
    expires_at TIMESTAMPTZ NOT NULL,
    accepted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uq_team_invitations_pending_email ON team_invitations (team_id, invitee_email)
WHERE
    status = 'pending';

ALTER TABLE team_invitations
ADD CONSTRAINT chk_team_invitations_status_timestamps CHECK (
    (
        status <> 'accepted'
        OR accepted_at IS NOT NULL
    )
    AND (
        status <> 'revoked'
        OR revoked_at IS NOT NULL
    )
);

CREATE INDEX idx_team_invitations_team_id ON team_invitations (team_id);

CREATE INDEX idx_team_invitations_inviter_id ON team_invitations (inviter_user_id);

-- Survey
CREATE TABLE survey_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE survey_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    survey_template_id UUID NOT NULL REFERENCES survey_templates (id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    explanation TEXT,
    position INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_survey_questions_template_id ON survey_questions (survey_template_id);

CREATE TABLE survey_question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    survey_question_id UUID NOT NULL REFERENCES survey_questions (id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    position INTEGER NOT NULL,
    score NUMERIC(5, 2) NOT NULL
);

CREATE INDEX idx_survey_question_options_question_id ON survey_question_options (survey_question_id);

CREATE TABLE survey_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    team_id UUID NOT NULL REFERENCES teams (id),
    survey_template_id UUID NOT NULL REFERENCES survey_templates (id),
    setter_id UUID NOT NULL REFERENCES team_members (id),
    recurring_interval_days survey_recurring_interval_days NOT NULL,
    UNIQUE (team_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_survey_settings_team_id ON survey_settings (team_id);

CREATE TABLE survey_setting_times (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    survey_setting_id UUID NOT NULL REFERENCES survey_settings (id) ON DELETE CASCADE,
    delivery_time TIME NOT NULL
);

CREATE INDEX idx_survey_setting_times_setting_id ON survey_setting_times (survey_setting_id);

CREATE TABLE surveys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    survey_setting_id UUID NOT NULL REFERENCES survey_settings (id),
    recipient_id UUID NOT NULL REFERENCES users (id),
    delivered_at TIMESTAMPTZ NOT NULL,
    last_answered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_surveys_setting_id ON surveys (survey_setting_id);

CREATE INDEX idx_surveys_recipient_id ON surveys (recipient_id);

CREATE TABLE survey_answers (
    survey_id UUID NOT NULL REFERENCES surveys (id) ON DELETE CASCADE,
    survey_question_id UUID NOT NULL REFERENCES survey_questions (id),
    selected_option_id UUID NOT NULL REFERENCES survey_question_options (id),
    answered_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (survey_id, survey_question_id)
);

-- Project
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    title TEXT NOT NULL,
    description TEXT,
    due_at TIMESTAMPTZ,
    status project_status NOT NULL DEFAULT 'not_in_progress',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE project_teams (
    project_id UUID NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (project_id, team_id)
);

CREATE INDEX idx_project_teams_team_id ON project_teams (team_id);

CREATE TABLE project_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    project_id UUID NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    role_definition_id UUID NOT NULL REFERENCES role_definitions (id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (
        project_id,
        role_definition_id
    )
);

CREATE TABLE project_role_assignment_owners (
    project_role_assignment_id UUID NOT NULL REFERENCES project_role_assignments (id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members (id),
    PRIMARY KEY (
        project_role_assignment_id,
        team_member_id
    )
);

CREATE TABLE issue_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE issue_template_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    issue_template_id UUID NOT NULL REFERENCES issue_templates (id) ON DELETE CASCADE,
    item_key TEXT NOT NULL,
    label TEXT NOT NULL,
    position INTEGER NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT true,
    value_type issue_template_item_value_type NOT NULL,
    UNIQUE (issue_template_id, item_key),
    UNIQUE (issue_template_id, position)
);

CREATE INDEX idx_issue_template_items_template_id ON issue_template_items (issue_template_id);

CREATE TABLE issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    project_id UUID NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    parent_issue_id UUID REFERENCES issues (id),
    issue_template_id UUID NOT NULL REFERENCES issue_templates (id),
    title TEXT NOT NULL,
    story_points INTEGER NOT NULL DEFAULT 0,
    estimated_minutes INTEGER NOT NULL DEFAULT 0,
    deadline TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    status issue_status NOT NULL DEFAULT 'not_in_progress',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE issues
ADD CONSTRAINT chk_issues_non_negative_points_minutes CHECK (
    story_points >= 0
    AND estimated_minutes >= 0
);

ALTER TABLE issues
ADD CONSTRAINT chk_issues_timestamps CHECK (
    (
        started_at IS NULL
        OR started_at >= created_at
    )
    AND (
        closed_at IS NULL
        OR closed_at >= created_at
    )
    AND (
        started_at IS NULL
        OR closed_at IS NULL
        OR closed_at >= started_at
    )
);

CREATE INDEX idx_issues_project_id ON issues (project_id);

CREATE INDEX idx_issues_parent_id ON issues (parent_issue_id);

CREATE INDEX idx_issues_template_id ON issues (issue_template_id);

CREATE TABLE issue_teams (
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (issue_id, team_id)
);

CREATE INDEX idx_issue_teams_team_id ON issue_teams (team_id);

CREATE TABLE issue_template_item_values (
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    issue_template_item_id UUID NOT NULL REFERENCES issue_template_items (id) ON DELETE CASCADE,
    value JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (
        issue_id,
        issue_template_item_id
    )
);

CREATE TABLE issue_assignees (
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members (id),
    PRIMARY KEY (issue_id, team_member_id)
);

CREATE TABLE issue_work_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members (id),
    source work_log_source NOT NULL,
    external_log_id TEXT,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    minutes INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX uq_issue_work_logs_source_external_non_null ON issue_work_logs (source, external_log_id)
WHERE
    external_log_id IS NOT NULL;

ALTER TABLE issue_work_logs
ADD CONSTRAINT chk_issue_work_logs_minutes CHECK (minutes >= 0);

ALTER TABLE issue_work_logs
ADD CONSTRAINT chk_issue_work_logs_time_range CHECK (
    ended_at IS NULL
    OR ended_at >= started_at
);

CREATE INDEX idx_issue_work_logs_issue_id ON issue_work_logs (issue_id);

CREATE INDEX idx_issue_work_logs_member_id ON issue_work_logs (team_member_id);

CREATE INDEX idx_issue_work_logs_started_at ON issue_work_logs (started_at);

CREATE TABLE issue_status_events (
    id BIGSERIAL PRIMARY KEY,
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    from_status issue_status,
    to_status issue_status NOT NULL,
    changed_by_team_member_id UUID REFERENCES team_members (id),
    is_initial BOOLEAN NOT NULL DEFAULT false,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_issue_status_events_issue_id ON issue_status_events (issue_id);

CREATE INDEX idx_issue_status_events_changed_at ON issue_status_events (changed_at);

CREATE TABLE team_project_performance_daily (
    snapshot_date DATE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    closed_issue_count INTEGER NOT NULL DEFAULT 0,
    overdue_open_issue_count INTEGER NOT NULL DEFAULT 0,
    completed_story_points INTEGER NOT NULL DEFAULT 0,
    estimated_minutes_closed INTEGER NOT NULL DEFAULT 0,
    actual_minutes_logged INTEGER NOT NULL DEFAULT 0,
    on_time_completion_rate NUMERIC(5, 4),
    avg_cycle_time_hours NUMERIC(10, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (
        snapshot_date,
        project_id,
        team_id
    )
);

CREATE TABLE team_member_project_performance_daily (
    snapshot_date DATE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members (id) ON DELETE CASCADE,
    closed_issue_count INTEGER NOT NULL DEFAULT 0,
    completed_story_points INTEGER NOT NULL DEFAULT 0,
    estimated_minutes_closed INTEGER NOT NULL DEFAULT 0,
    actual_minutes_logged INTEGER NOT NULL DEFAULT 0,
    on_time_completion_rate NUMERIC(5, 4),
    avg_cycle_time_hours NUMERIC(10, 2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (
        snapshot_date,
        project_id,
        team_id,
        team_member_id
    )
);

CREATE TABLE issue_definition_of_dones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    description TEXT NOT NULL
);

CREATE INDEX idx_issue_dods_issue_id ON issue_definition_of_dones (issue_id);

CREATE TABLE issue_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    issue_id UUID NOT NULL REFERENCES issues (id) ON DELETE CASCADE,
    role_definition_id UUID NOT NULL REFERENCES role_definitions (id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (issue_id, role_definition_id)
);

CREATE TABLE issue_role_assignment_owners (
    issue_role_assignment_id UUID NOT NULL REFERENCES issue_role_assignments (id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members (id),
    PRIMARY KEY (
        issue_role_assignment_id,
        team_member_id
    )
);

-- Alert
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    project_id UUID NOT NULL REFERENCES projects (id),
    category alert_category NOT NULL,
    description TEXT NOT NULL,
    level alert_level NOT NULL,
    is_resolved BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_alerts_project_id ON alerts (project_id);

CREATE TABLE alert_logs (
    id BIGSERIAL PRIMARY KEY,
    alert_id UUID NOT NULL REFERENCES alerts (id) ON DELETE CASCADE,
    triggered_at TIMESTAMPTZ NOT NULL,
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_alert_logs_alert_id ON alert_logs (alert_id);

CREATE TABLE action_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE alert_action_plan_suggestions (
    alert_id UUID NOT NULL REFERENCES alerts (id) ON DELETE CASCADE,
    action_plan_id UUID NOT NULL REFERENCES action_plans (id),
    priority SMALLINT NOT NULL,
    rationale JSONB,
    suggested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (alert_id, action_plan_id)
);

CREATE INDEX idx_alert_action_plan_suggestions_action_plan_id ON alert_action_plan_suggestions (action_plan_id);

-- Automation/Policy context

CREATE TYPE trigger_target_type AS ENUM (
  'survey',
  'issue',
  'project',
  'team_member'
);

CREATE TABLE trigger_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    name TEXT NOT NULL,
    target_type trigger_target_type NOT NULL,
    condition_type trigger_condition_type NOT NULL,
    condition_value INTEGER, -- optional numeric threshold
    condition_params JSONB NOT NULL DEFAULT '{}'::jsonb, -- extensible params (hybrid)
    alert_level alert_level NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE trigger_execution_logs (
    id BIGSERIAL PRIMARY KEY,
    trigger_definition_id UUID NOT NULL REFERENCES trigger_definitions (id) ON DELETE CASCADE,
    target_entity_id UUID NOT NULL,
    triggered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    status trigger_execution_status NOT NULL,
    metadata JSONB
);

CREATE INDEX idx_trigger_execution_target ON trigger_execution_logs (target_entity_id);