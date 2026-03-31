# OpenAPI Contract Specification

**Version:** 1.0  
**Last Updated:** 2026/03/06  
**Human Documentation:** `docs/api/endpoints.md`  
**Generated File:** `teamdev-2026-api/docs/openapi/openapi.json`

---

## Overview

This spec defines the OpenAPI (v3.0) contract for all API endpoints. The contract is:
1. **Source of truth** for API structure
2. **Generated from Laravel annotations** (OpenAPI PHP library)
3. **Used to generate frontend types** via `mise codegen-openapi`

Never manually edit the generated `openapi.json`. Edit Laravel controller annotations instead.

---

## OpenAPI Generation Workflow

### Step 1: Write Laravel Controller with Annotations

```php
<?php

namespace App\Http\Controllers;

use OpenApi\Annotations as OA;

class UserController {
    /**
     * @OA\Get(
     *     path="/api/users/{userId}",
     *     summary="Get user profile",
     *     tags={"Users"},
     *     @OA\Parameter(
     *         name="userId",
     *         in="path",
     *         required=true,
     *         schema={"type": "string", "format": "uuid"}
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="User profile",
     *         @OA\JsonContent(ref="#/components/schemas/User")
     *     )
     * )
     */
    public function show($userId) {
        // ...
    }
}
```

### Step 2: Run Code Generation

```bash
mise codegen-openapi
```

This:
- Scans all Laravel controllers for `@OA\*` annotations
- Generates `teamdev-2026-api/docs/openapi/openapi.json`
- Triggers frontend code generation (aspida)

### Step 3: Generated Frontend Types

Frontend auto-generates from OpenAPI:
- TypeScript request/response types
- API client methods (via aspida)
- Stored in `teamdev-2026-front/src/api/`

---

## Schema Organization

### Components Section

All reusable schemas defined in `#/components/schemas/`:

**Entity Schemas:**
- `User`
- `Profile`
- `Team`
- `TeamMember`
- `Project`
- `Issue`
- `Alert`
- `Survey`
- etc.

**Request Schemas:**
- `CreateProjectRequest`
- `UpdateIssueStatusRequest`
- `CreateTeamInvitationRequest`
- etc.

**Response Schemas:**
- `PaginatedIssueList`
- `AlertWithSuggestions`
- `ProjectProgressResponse`
- etc.

**Common Schemas:**
- `Error` - Standard error response
- `ValidationError` - 422 response with field-level errors
- `Pagination` - Cursor/offset pagination metadata

---

## Authentication

**Security Scheme:**
```yaml
components:
  securitySchemes:
    sanctumAuth:
      type: http
      scheme: bearer
      bearerFormat: "sanctum token"
```

**Usage:**
```yaml
security:
  - sanctumAuth: []  # Add to endpoint that requires auth
```

---

## Standard Responses

### Success (2xx)

```yaml
responses:
  200OK:
    description: "Success"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/SomeEntity"
```

### Errors

**400 - Bad Request (missing/invalid parameters)**
```yaml
400BadRequest:
  description: "Bad request"
  content:
    application/json:
      schema:
        $ref: "#/components/schemas/Error"
```

**401 - Unauthorized (invalid/missing token)**
```yaml
401Unauthorized:
  description: "Unauthorized"
  content:
    application/json:
      schema:
        $ref: "#/components/schemas/Error"
```

**403 - Forbidden (permission denied)**
```yaml
403Forbidden:
  description: "Forbidden"
  content:
    application/json:
      schema:
        $ref: "#/components/schemas/Error"
```

**404 - Not Found (resource not found)**
```yaml
404NotFound:
  description: "Not found"
  content:
    application/json:
      schema:
        $ref: "#/components/schemas/Error"
```

**422 - Unprocessable Entity (validation error)**
```yaml
422UnprocessableEntity:
  description: "Validation error"
  content:
    application/json:
      schema:
        $ref: "#/components/schemas/ValidationError"
```

---

## Endpoint Categories

### Authentication Endpoints

**POST /api/login**
- Google OAuth login (S-01-01)

**POST /api/logout**
- Revoke session (S-01-04, requires auth)

**GET /api/current-user**
- Get authenticated user (requires auth)

**POST /api/users/{userId}/profile**
- Create profile (S-01-02, requires auth)

### Team Endpoints

**GET /api/teams**
- List teams (S-04-01, S-04-02, requires auth)

**GET /api/teams/{teamId}**
- Get team detail (S-04-03, requires auth)

**POST /api/teams**
- Create team (S-04-04, requires auth)

**PATCH /api/teams/{teamId}**
- Update team (requires auth, manager only)

**GET /api/teams/{teamId}/members**
- List team members (S-04-03, requires auth)

**POST /api/teams/{teamId}/invitations**
- Send invitation (S-04-05, requires auth, manager only)

**POST /api/invitations/{token}/accept**
- Accept invitation (requires auth — identity derived from signed-in user)

**POST /api/invitations/{token}/decline**
- Decline invitation (no auth, token-based)

### Project Endpoints

**GET /api/projects**
- List projects (S-05, requires auth)

**POST /api/projects**
- Create project (S-05-01, requires auth, manager only)

**GET /api/projects/{projectId}**
- Get project detail (S-05-04, requires auth)

**PATCH /api/projects/{projectId}**
- Update project (S-05-05, requires auth, manager only)

**PATCH /api/projects/{projectId}/status**
- Update project status (S-05-06, requires auth, manager only)

**GET /api/projects/{projectId}/progress**
- Get Gantt data (S-05-02, requires auth)

**GET /api/projects/{projectId}/issues**
- List project issues (requires auth)

**GET /api/projects/{projectId}/alerts**
- List project alerts (requires auth)

**GET /api/projects/{projectId}/board**
- Get Kanban board (S-07-02, requires auth)

### Issue Endpoints

**POST /api/projects/{projectId}/issues**
- Create issue (S-03-01, requires auth)

**GET /api/issues/{issueId}**
- Get issue detail (requires auth)

**PATCH /api/issues/{issueId}**
- Update issue fields: title, story_points, estimated_minutes, deadline (S-03-01, requires auth)

**PATCH /api/issues/{issueId}/status**
- Update issue status with transition validation (S-03-05, requires auth)

**POST /api/issues/{issueId}/assignees**
- Add assignee (S-03-02, requires auth)

**DELETE /api/issues/{issueId}/assignees/{teamMemberId}**
- Remove assignee (S-03-02, requires auth)

**GET /api/issues/{issueId}/definition-of-done**
- List DoD items (S-03-04, requires auth)

**PATCH /api/issues/{issueId}/definition-of-done/{doneItemId}**
- Update DoD item (S-03-04, requires auth)

**POST /api/issues/{parentIssueId}/subtasks**
- Create subtask (S-03-06, requires auth)

**GET /api/issues/{parentIssueId}/subtasks**
- List subtasks (S-03-06, requires auth)

**POST /api/issues/{issueId}/work-logs**
- Log work (requires auth)

**GET /api/issues/{issueId}/work-logs**
- List work logs (requires auth, returns an empty `workLogs` array when the issue does not exist)

### Issue Template Endpoints

**GET /api/issue-templates**
- List active templates with embedded item definitions (requires auth)

**POST /api/issue-templates**
- Create template (requires auth)

**GET /api/issue-templates/{templateId}**
- Get template with items (requires auth)

**PATCH /api/issue-templates/{templateId}**
- Update template (requires auth)

**DELETE /api/issue-templates/{templateId}**
- Delete template (requires auth)

**POST /api/issue-templates/{templateId}/items**
- Add template item (requires auth)

**PATCH /api/issue-templates/{templateId}/items/{itemId}**
- Update template item (requires auth)

**DELETE /api/issue-templates/{templateId}/items/{itemId}**
- Delete template item (requires auth)

### Alert Endpoints

**GET /api/projects/{projectId}/alerts**
- List alerts (requires auth)

**GET /api/alerts**
- List all alerts (cross-project, manager view, requires auth)

**PATCH /api/projects/{projectId}/alerts/{alertId}/resolve**
- Resolve alert (S-02, requires auth)

### Survey Endpoints

**POST /api/teams/{teamId}/surveys/answer**
- Answer survey (S-05-02, requires auth)

**GET /api/teams/{teamId}/surveys/pending**
- List pending surveys (requires auth)

### Profile Endpoints

**GET /api/users/{userId}/profile**
- Get user profile (S-06-02, requires auth)

**PUT /api/users/{userId}/profile**
- Update own profile (S-06-02, requires auth)

**POST /api/users/{userId}/profile/avatar**
- Upload avatar (requires auth)

### Workload Visualization

**GET /api/teams/{teamId}/member-workload**
- Get member workload (S-07-01, requires auth)

---

## Pagination

All list endpoints support pagination:

**Query Parameters:**
- `page=1` - Page number (1-indexed)
- `per_page=20` - Items per page (default: 20, max: 100)
- `sort=name` - Sort field
- `sort_dir=asc|desc` - Sort direction

**Response Metadata:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "last_page": 8
  }
}
```

---

## Filtering

Query parameters for filtering (as applicable):

**Issues:**
- `status=not_in_progress,in_progress,in_review,done`
- `assignee_id=uuid`
- `team_id=uuid`

**Projects:**
- `status=not_in_progress,in_progress,completed,idle`
- `team_id=uuid`

**Teams:**
- `role=manager,member` - Filter by user's role in teams

---

## Rate Limiting

Global rate limits (to be configured):

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1615854000
```

Limits:
- 1000 requests per hour per user (authenticated)
- 100 requests per hour per IP (unauthenticated)

---

## Versioning

API version:
- Current: `v1` (in paths: `/api/v1/...`)
- Phase 2: Consider `v2` if breaking changes

No breaking changes in minor versions.

---

## CORS

**Allowed Origins:**
- `http://localhost:3000` (dev)
- `https://app.motiv.cloud` (production)
- `https://*.motiv.cloud` (subdomains)

**Allowed Methods:** GET, POST, PATCH, DELETE, OPTIONS

**Allowed Headers:** Content-Type, Authorization

---

## Documentation

Generated OpenAPI docs available at:
- **Swagger UI:** `/api/docs` (if enabled)
- **ReDoc:** `/api/redoc` (if enabled)

Endpoints accessible:
- `GET /api/openapi.json` - Raw OpenAPI spec

---

## Testing Endpoints

All endpoints tested via:
1. **Unit Tests** - Business logic
2. **Feature Tests** - Full request/response cycle
3. **Integration Tests** - Database interactions

Test structure:
```
tests/Feature/
  Auth/
    LoginTest.php
    LogoutTest.php
  Teams/
    CreateTeamTest.php
  Issues/
    CreateIssueTest.php
  ...
```

---

## Webhooks (Not in Phase 1)

Reserved paths for future webhooks:

```
POST /webhooks/github/push
POST /webhooks/sendgrid/events
POST /webhooks/github/pull-request
```

---

## Dependency Notes

- All endpoints validated against TypeScript during code generation
- Frontend types auto-update when OpenAPI changes
- Breaking changes flagged during generation (if configured)

---

## Generation Command

```bash
# Regenerate OpenAPI + frontend types
mise codegen-openapi

# Or manually:
cd teamdev-2026-api
php artisan openapi:generate

cd ../teamdev-2026-front
pnpm run codegen:api
```

---

## Notes

- All timestamps in UTC (ISO 8601 format)
- All IDs are UUIDs (v4) unless noted
- All monetary values in cents (integer)
- All errors follow standard error schema
- All responses are JSON (application/json)
- CORS enabled for frontend development
