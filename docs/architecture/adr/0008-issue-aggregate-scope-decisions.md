# ADR 0008: Issue Aggregate Implementation Scope Decisions

**Status:** Accepted  
**Date:** 2026-03-14  
**Deciders:** Development Team  
**Related:** S-03-01 through S-03-08 (Issue Management Spec)

---

## Context

Implementing Issue Management per `specs/business/issue-management.md` requires decisions on:
1. Which features to implement in Phase 1 vs defer
2. Template management scope
3. Work logging implementation approach
4. Progress calculation strategy
5. Role assignment features

The spec defines MUST features (S-03-01 through S-03-08) and WANT features (S-03-09, S-03-10). Database schema already exists for all entities including advanced features like IssueRoleAssignment.

---

## Decision

### 1. Role Assignment Models & Endpoints
**Decision:** Implement IssueRoleAssignment and IssueRoleAssignmentOwner models with full CRUD endpoints in Phase 1.

**Rationale:**
- Database schema already exists (migrations 2026_03_05_000032, 000033)
- Domain model references role assignment methods (`assignIssueRole`, `setIssueRoleOwners`)
- Complete model layer prevents future refactoring
- Minimal overhead to add alongside other models

**Implementation:** Phase 1 includes IssueRoleAssignment and IssueRoleAssignmentOwner models with relationships. Additional phase for role endpoints if needed.

### 2. Template CRUD Endpoints
**Decision:** Include template management endpoints (list, create, update, delete) in implementation.

**Rationale:**
- S-03-03 spec mentions templates are "pre-configured per project by PM"
- PM needs UI to configure templates before creating issues
- IssueTemplate and IssueTemplateItem tables exist
- Lightweight implementation enables complete issue creation flow

**Implementation:** Add Phase 1.5 or extend Phase 2 to include:
- GET /api/projects/{projectId}/issue-templates
- POST /api/projects/{projectId}/issue-templates
- PATCH /api/issue-templates/{templateId}
- DELETE /api/issue-templates/{templateId}
- POST /api/issue-templates/{templateId}/items (template field management)

### 3. Manual Work Log Entry
**Decision:** Include manual work log creation in Phase 7 (Progress Calculation).

**Rationale:**
- Work logs are input to progress calculation (Priority 3: work log-based)
- S-03-08 spec references work logs: `sum(work_log.minutes)`
- Manual entry is simpler than GitHub integration (no webhook)
- Natural fit with progress calculation testing

**Implementation:** Phase 7 introduced the manual work log flow with `POST /api/issues/{issueId}/work-logs`. The current API contract also includes `GET /api/issues/{issueId}/work-logs` plus `PATCH/DELETE /api/issues/{issueId}/work-logs/{workLogId}` for manual work log maintenance.

### 4. Email Notifications
**Decision:** Defer email notifications to later phase (outside Issue aggregate scope).

**Rationale:**
- Notifications are cross-cutting concern (SendGrid integration)
- S-03-02 mentions "notification sent to assignee" but not blocking requirement
- Alert system will handle notifications systematically
- Avoids coupling Issue aggregate to external services prematurely
- Focus on core domain logic first

**Implementation:** Issue aggregate methods (addAssignee, removeAssignee) emit domain events. Notification handler subscribes to events in separate Alert/Notification bounded context.

### 5. Progress Calculation Strategy
**Decision:** Strict on-demand calculation, no caching in Phase 1.

**Rationale:**
- Spec explicitly states: "Progress calculated on-demand when displayed (not cached)"
- Premature optimization without performance data
- Simpler implementation and testing
- Easier to reason about correctness
- Can add caching layer later if performance issues identified

**Implementation:** ProgressCalculationService computes every time called. GET /api/issues/{issueId} calculates progress in response generation. Future: Add Redis cache if latency > 100ms under load.

### 6. WANT Features (S-03-09, S-03-10)
**Decision:** Exclude S-03-09 (Unexpected Work Registration) and S-03-10 (GitHub Integration) from Phase 1.

**Rationale:**
- User explicitly requested skip GitHub integration (C: Skip entirely)
- S-03-09 can be simulated with manual work log entry
- Focus on MUST features for solid foundation
- GitHub integration requires webhook infrastructure (separate concern)

**Implementation:** Deferred to Phase 2 or separate feature branch.

---

## Consequences

### Positive
- ✅ Complete model layer prevents future breaking changes
- ✅ Template management enables end-to-end issue creation workflow
- ✅ Manual work logs enable progress calculation testing
- ✅ On-demand calculation ensures accuracy and correctness
- ✅ Decoupling notifications enables clean architecture

### Negative
- ⚠️ Slightly larger Phase 1 scope (7 models instead of 5)
- ⚠️ Template CRUD adds ~4 endpoints to implementation
- ⚠️ No caching means potential performance concerns at scale (mitigated by future optimization)

### Neutral
- 🔵 Email notifications deferred but infrastructure exists (SendGrid integration in external-services spec)
- 🔵 GitHub integration punted to future phase (clear webhook contract in spec)

---

## Implementation Notes

**Phase Adjustments:**
- Phase 1: Add IssueRoleAssignment, IssueRoleAssignmentOwner models
- Phase 2 or 1.5: Add template CRUD endpoints (GET, POST, PATCH, DELETE for templates and template items)
- Phase 7: Include manual work log endpoints, starting with `POST /api/issues/{issueId}/work-logs` and now covering `GET/POST/PATCH/DELETE`
- Phase 7: Strict on-demand progress calculation (no Redis/cache)

**Future Enhancements:**
- Phase 2: Redis caching for progress calculation if latency > 100ms
- Phase 2: Email notification queue (SendGrid) for assignee changes
- Phase 2: S-03-09 unexpected work registration UI
- Phase 3: S-03-10 GitHub webhook integration for CI/CD

---

## References

- [specs/business/issue-management.md](../../../specs/business/issue-management.md) - Requirements S-03-01 through S-03-08
- [specs/api/external-services.md](../../../specs/api/external-services.md) - SendGrid and GitHub integration contracts
- [docs/diagrams/domain-models/issue-aggregate.puml](../../diagrams/domain-models/issue-aggregate.puml) - Domain model with role assignments
- Migration files: 2026_03_05_000032 (issue_role_assignments), 000033 (issue_role_assignment_owners)
