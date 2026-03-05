# ADR 0001: Adopt Clean Architecture + CQRS + TDD

- Status: Accepted
- Date: 2026-03-05

## Context

The project needs clear ownership of responsibilities across layers, better long-term maintainability, and explicit separation between write and read flows.

The frontend also needs stronger feature boundaries so page files remain minimal and reusable UI can be tested independently.

## Decision

We adopt:

1. Clean Architecture layering for backend and frontend
2. CQRS separation for use-cases (write side vs read side)
3. TDD as implementation workflow
4. Frontend Presentation/Container pattern per feature:
   - `features/[feature]/container`
   - `features/[feature]/presentation`
   - `features/[feature]/index.ts`
   - `pages/*` only receives feature component

## Consequences

### Positive

- Better separation of concerns and lower coupling
- Safer refactoring and easier onboarding
- Clearer test boundaries by layer
- Easier to scale business logic and read models

### Trade-offs

- More files/directories and initial setup cost
- Requires team discipline for placement rules

## Implementation Notes

- See [Directory Structure](../directory-structure.md) for exact placement rules.
- Keep generated API code untouched; wrap it in infrastructure adapters.
- Keep write/read paths separated for each feature.

## Example (CQRS)

- Command: create issue
  - `CreateIssueCommand` -> `CreateIssueHandler`
- Query: list issues
  - `ListIssuesQuery` -> `ListIssuesHandler`

## Related

- [Architecture README](../README.md)
- [Guidelines](../../../specs/ai-agents/guidelines.md)