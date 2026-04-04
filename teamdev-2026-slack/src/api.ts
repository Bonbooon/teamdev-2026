import axios from "axios";

const client = axios.create({
  baseURL: process.env.API_BASE_URL || "http://localhost:80/api",
  headers: { "Content-Type": "application/json" },
  timeout: 10000,
});

// --- Types ---

export interface Issue {
  id: string;
  title: string;
  status: string;
  storyPoints: number;
  estimatedMinutes: number;
  deadline: string | null;
  startedAt: string | null;
  assignees: { teamMemberId: string; userId: string; userName: string }[];
}

export interface Project {
  id: string;
  title: string;
  description: string | null;
  dueAt: string | null;
  status: string;
  progress: number;
  canManage: boolean;
  teams: { id: string; name: string }[];
}

export interface CreateIssuePayload {
  issue_template_id: string;
  title: string;
  story_points: number;
  estimated_minutes: number;
  deadline: string;
  status: string;
  assigneeIds: string[];
  teamIds: string[];
  definitionOfDoneItems: string[];
}

// --- API calls ---

export async function listIssues(
  projectId: string,
  token: string,
  status?: string
): Promise<{ issues: Issue[]; pagination: { total: number } }> {
  const params: Record<string, string> = {};
  if (status) params.status = status;
  const res = await client.get(`/projects/${projectId}/issues`, {
    params,
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
}

export async function createIssue(
  projectId: string,
  payload: CreateIssuePayload,
  token: string
): Promise<{ issue: { id: string; title: string; status: string } }> {
  const res = await client.post(`/projects/${projectId}/issues`, payload, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
}

export async function getProject(
  projectId: string,
  token: string
): Promise<{ project: Project }> {
  const res = await client.get(`/projects/${projectId}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
}
