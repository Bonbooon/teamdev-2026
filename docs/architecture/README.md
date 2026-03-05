# Architecture Documentation

This directory defines how responsibilities are separated across layers and where to place code.

## Documents

- [Directory Structure](./directory-structure.md)
- [Architecture Decision Records (ADR)](./adr/)

## Quick Start

When adding a new class or entity, check in this order:

1. [Directory Structure](./directory-structure.md) to find the correct layer
2. [ADR 0001](./adr/0001-adopt-clean-architecture-cqrs-tdd.md) to verify the architectural intent
3. Existing code in corresponding layer and feature directories

## CQRS Example (Where each class belongs)

Example use case: `CreateIssue`

- Write flow (Command side)
  - `Domain/Issue/Issue.php` (entity)
  - `Application/Issue/Commands/CreateIssueCommand.php`
  - `Application/Issue/CommandHandlers/CreateIssueHandler.php`
  - `Infrastructure/Persistence/EloquentIssueRepository.php`
  - `Interfaces/Http/Controllers/Issue/CreateIssueController.php`

- Read flow (Query side)
  - `Application/Issue/Queries/ListIssuesQuery.php`
  - `Application/Issue/QueryHandlers/ListIssuesHandler.php`
  - `Infrastructure/ReadModel/Issue/IssueListReadModel.php`
  - `Interfaces/Http/Controllers/Issue/ListIssuesController.php`

Frontend mapping for the same feature:

- `src/features/issue/container/IssueListContainer.tsx` (fetch + orchestration)
- `src/features/issue/presentation/IssueListPresentation.tsx` (pure UI)
- `src/features/issue/index.ts` (feature export)
- `src/pages/issues/index.tsx` (page receives feature component)

## Notes

- Keep write and read models separated in CQRS.
- Keep framework concerns in interface/infrastructure layers.
- Run TDD by writing tests at the target layer first.