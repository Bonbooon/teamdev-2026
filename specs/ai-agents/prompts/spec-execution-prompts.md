# Spec Execution Prompts

**Purpose:** Minimal execution prompts for each spec. Each prompt points to the smallest set of files that should be treated as the single source of truth when implementing that spec.

---

## Mandatory Pre-Execution Workflow (Applies to All Prompts)

Before implementing any spec, the AI agent must follow this sequence:

1. **Ask clarifying questions first**
	- Ask the user any required questions about scope, assumptions, priorities, or ambiguities before making changes.
2. **Create an implementation plan**
	- Provide a clear step-by-step plan that maps directly to the target spec and listed source-of-truth files.
3. **Get explicit user confirmation**
	- Wait for user approval of the plan.
	- Do not start implementation until the user confirms.
4. **Then execute**
	- After confirmation, implement the spec exactly as instructed.

Use this control phrase at the top of each execution session:

"Before I execute, I will ask clarifying questions, propose an implementation plan, and wait for your explicit confirmation before commencing."

---

## 1. Authentication Spec Prompt

**Target Spec:** `specs/business/authentication.md`

**Prompt:**
Implement the authentication spec exactly as defined in `specs/business/authentication.md`.

Single source of truth:
1. `specs/business/authentication.md`
2. `docs/diagrams/domain-models/user-aggregate.puml`
3. `specs/api/openapi-contracts.md`

Constraints:
- Use Google login flow exactly as specified.
- Keep `User`, `Profile`, and `OAuthAccount` aligned with the user aggregate.
- Add or update OpenAPI annotations instead of editing generated API code.
- Include feature tests for happy path, validation, and auth failure cases.

Do not read beyond these files unless implementation reveals a contradiction.

---

## 2. Alert System Spec Prompt

**Target Spec:** `specs/business/alert-system-implementation.md`

**Prompt:**
Implement the alert system exactly as defined in `specs/business/alert-system-implementation.md`.

Single source of truth:
1. `specs/business/alert-system-implementation.md`
2. `specs/business/alert-system.md`
3. `docs/business-logic/prototype-strategy.md`
4. `docs/diagrams/domain-models/alert-aggregate.puml`
5. `specs/api/external-services.md`

Constraints:
- Treat trigger rules and yellow/red severity logic in the spec as authoritative.
- Use SendGrid integration rules only from the external services spec.
- Keep `Alert`, `AlertLog`, `ActionPlan`, and suggestion relationships aligned with the diagram.
- Include tests for trigger logic, deduplication, resolution, and email dispatch behavior.

---

## 3. Issue Management Spec Prompt

**Target Spec:** `specs/business/issue-management.md`

**Prompt:**
Implement issue management exactly as defined in `specs/business/issue-management.md`.

Single source of truth:
1. `specs/business/issue-management.md`
2. `docs/diagrams/domain-models/issue-aggregate.puml`
3. `specs/api/openapi-contracts.md`
4. `specs/api/external-services.md` (only for GitHub integration parts)

Constraints:
- Preserve SMART template behavior, Definition of Done rules, subtask rules, and progress calculation exactly.
- Keep issue status transitions and work log sources aligned with the spec.
- Use GitHub integration rules only for S-03-10.
- Add tests for creation, validation, status transitions, progress calculation, and subtask behavior.

---

## 4. Team Management Spec Prompt

**Target Spec:** `specs/business/team-management.md`

**Prompt:**
Implement team management exactly as defined in `specs/business/team-management.md`.

Single source of truth:
1. `specs/business/team-management.md`
2. `docs/diagrams/domain-models/team-aggregate.puml`
3. `specs/api/openapi-contracts.md`
4. `specs/api/external-services.md` (only for invitation email behavior)

Constraints:
- Keep manager/member permission roles and membership statuses exactly as specified.
- Keep `RoleDefinition` and `TeamConditionSetting` aligned with the team aggregate.
- Use invitation rules from the team spec; use delivery rules from the external services spec.
- Add tests for creation, invitation, access control, and membership constraints.

---

## 5. Project Management Spec Prompt

**Target Spec:** `specs/business/project-management.md`

**Prompt:**
Implement project management exactly as defined in `specs/business/project-management.md`.

Single source of truth:
1. `specs/business/project-management.md`
2. `docs/diagrams/domain-models/project-aggregate.puml`
3. `specs/api/openapi-contracts.md`
4. `specs/business/issue-management.md` (only for issue-derived progress)

Constraints:
- Keep project lifecycle, team assignment, and progress calculations aligned with the spec.
- Keep daily performance snapshot entities aligned with the project aggregate.
- Use issue progress as defined by the issue spec; do not invent a second progress model.
- Add tests for project creation, team assignment, status transitions, and visibility rules.

---

## 6. Profile & Visibility Spec Prompt

**Target Spec:** `specs/business/profile-visibility.md`

**Prompt:**
Implement profile visibility exactly as defined in `specs/business/profile-visibility.md`.

Single source of truth:
1. `specs/business/profile-visibility.md`
2. `specs/business/authentication.md`
3. `docs/diagrams/domain-models/user-aggregate.puml`
4. `specs/api/openapi-contracts.md`

Constraints:
- Keep profile ownership strict: users can edit only their own profile.
- Use the user aggregate for all profile fields and external links.
- Do not add additional profile fields beyond the spec without updating the spec first.
- Add tests for profile viewing, editing, access control, and link validation.

---

## 7. Visualization Spec Prompt

**Target Spec:** `specs/business/visualization.md`

**Prompt:**
Implement visualization features exactly as defined in `specs/business/visualization.md`.

Single source of truth:
1. `specs/business/visualization.md`
2. `specs/business/issue-management.md`
3. `specs/business/project-management.md`
4. `specs/business/team-management.md`

Constraints:
- Reuse existing issue/project/team calculations from their specs.
- Do not create new business rules for workload or board state outside the spec.
- Keep UI states and status colors aligned with the visualization spec.
- Add tests for board grouping, workload calculation, and filtering behavior.

---

## 8. Layout & Navigation Spec Prompt

**Target Spec:** `specs/business/layout-navigation.md`

**Prompt:**
Implement layout and navigation exactly as defined in `specs/business/layout-navigation.md`.

Single source of truth:
1. `specs/business/layout-navigation.md`
2. `specs/business/team-management.md`
3. `specs/business/project-management.md`
4. `specs/business/visualization.md`

Constraints:
- Use role-based navigation exactly as defined.
- Keep default tabs different for managers and members.
- Do not introduce navigation items not described in the layout spec.
- Add tests for role-based rendering and default landing states.

---

## 9. External Services Spec Prompt

**Target Spec:** `specs/api/external-services.md`

**Prompt:**
Implement external service integration exactly as defined in `specs/api/external-services.md`.

Single source of truth:
1. `specs/api/external-services.md`
2. `specs/business/alert-system-implementation.md`
3. `specs/business/issue-management.md`
4. `specs/business/team-management.md`

Constraints:
- Use SendGrid only as specified for email templates, retry rules, and rate limiting.
- Use GitHub integration only as specified for webhook validation, branch parsing, and work logging.
- Keep secrets in env vars only.
- Add tests for signature validation, queue behavior, and failure handling.

---

## 10. Database Schema Prompt

**Target Spec:** `specs/database/schema.md`

**Prompt:**
Implement or validate persistence against `specs/database/schema.md`.

Single source of truth:
1. `specs/database/schema.md`
2. `docs/diagrams/domain-models/`
3. `teamdev-2026-api/web/database/migrations/`

Constraints:
- Treat migrations as executable truth for column-level details.
- Treat schema doc and domain diagrams as relationship and intent truth.
- If a mismatch is found, update schema docs/diagrams and code together.
- Add tests for critical constraints, uniqueness, and foreign keys where applicable.

---

## 11. OpenAPI Contracts Prompt

**Target Spec:** `specs/api/openapi-contracts.md`

**Prompt:**
Implement API contracts exactly as defined in `specs/api/openapi-contracts.md`.

Single source of truth:
1. `specs/api/openapi-contracts.md`
2. Relevant business spec for the endpoint being implemented
3. `teamdev-2026-api/docs/openapi/openapi.json` after generation

Constraints:
- Never edit generated frontend API files manually.
- Add or update Laravel OpenAPI annotations first, then regenerate.
- Match request/response payloads to the owning business spec.
- Add feature tests to validate contract shape and status codes.

---

## 12. General Rule for Any Spec

If implementing any spec, keep the read set minimal:
1. The target spec
2. Its linked domain model, if one exists
3. `specs/api/openapi-contracts.md` if an API is involved
4. `specs/api/external-services.md` only if an external provider is involved

If the code, spec, and diagram disagree, stop and update the source-of-truth documents first.
