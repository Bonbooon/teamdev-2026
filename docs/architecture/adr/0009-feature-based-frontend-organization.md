# ADR 0009: Feature-based Frontend Organization Over Container/Presentation

- Status: Accepted
- Date: 2026-03-28

## Context

ADR 0001 specified a Container/Presentation pattern for the frontend:
- `features/[feature]/container/` — state, hooks, API invocation
- `features/[feature]/presentation/` — stateless/pure UI
- `features/[feature]/index.ts` — public feature export

During Phase 1 MVP implementation (Teams, Projects, Issues — 49 files, 28 components, 11 hooks), this separation added overhead without clear benefit at the current scale. Most components needed both state and UI logic tightly coupled via SWR hooks.

## Decision

Adopt a simpler feature-based organization for the MVP:

- `features/[feature]/components/` — all feature UI components (stateful and presentational)
- `features/[feature]/hooks/` — SWR-based data fetching hooks (one per API resource)
- `pages/` — thin route wrappers composing layout + feature component

This pattern emerged naturally during Phase 0 and Phase 1 implementation and was consistently applied across all three feature domains (teams, projects, issues).

## Consequences

### Positive

- Fewer directories and files → faster feature delivery during the MVP timeline
- Components colocated with their data hooks → easier to navigate
- Consistent pattern across all Phase 1 features
- Still maintains feature-level boundaries (teams/, projects/, issues/)

### Trade-offs

- Stateful and presentational components are mixed in the same directory
- If the project scales significantly, may need to revisit container/presentation split
- ADR 0001's frontend section is partially superseded for the `features/` pattern

## Relationship to ADR 0001

ADR 0001 remains authoritative for:
- Backend Clean Architecture + CQRS layering
- TDD workflow
- General principle of feature boundaries

This ADR supersedes ADR 0001 only for the frontend `features/` directory structure.

## Implementation Notes

- See [Directory Structure](../directory-structure.md) for the updated frontend tree.
- Data fetching uses SWR hooks (`useSWR`) with API path-based keys.
- Forms use `react-hook-form` + `zod` as planned.
- This decision can be revisited post-MVP if the codebase grows beyond the current product scope.
