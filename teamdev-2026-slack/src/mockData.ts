// Mock data for dashboard — designed to look good in Slack Block Kit

export const MOCK_PROJECT = {
  id: "proj-demo-001",
  title: "Q2 Product Launch",
  progress: 62,
  status: "in_progress",
  dueAt: "2026-04-30T23:59:59Z",
  totalIssues: 24,
  completedIssues: 15,
  inProgressIssues: 6,
  notStartedIssues: 3,
};

export const MOCK_ALERTS = [
  {
    level: "red" as const,
    description: "3件のIssueが期限を超過しています",
    project: "Q2 Product Launch",
  },
  {
    level: "yellow" as const,
    description: "チームの作業ペースが計画より15%遅れています",
    project: "Q2 Product Launch",
  },
];

export const MOCK_TEAM_HEALTH = {
  totalMembers: 6,
  surveyResponseRate: 83,
  avgCondition: "良好",
  lastSurvey: "2026-04-03",
};
