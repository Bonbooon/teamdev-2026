# Directory Structure

This document defines layer responsibilities for Clean Architecture + CQRS and the frontend Presentation/Container pattern.

## Backend (Laravel)

Base: `teamdev-2026-api/web/app/`

```text
app/
├── Domain/
│   └── [Context]/
│       ├── Entities/
│       ├── ValueObjects/
│       ├── Services/
│       ├── Events/
│       └── Repositories/           # interfaces only
├── Application/
│   └── [Context]/
│       ├── Commands/
│       ├── CommandHandlers/
│       ├── Queries/
│       ├── QueryHandlers/
│       ├── DTOs/
│       └── UseCases/
├── Infrastructure/
│   ├── Persistence/
│   ├── ReadModel/
│   ├── External/
│   └── Notifications/
├── Interfaces/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Requests/
│   │   └── Resources/
│   └── Console/
└── Shared/
    ├── Contracts/
    ├── Exceptions/
    └── Support/
```

### Responsibility by layer

- `Domain`: business rules and invariants, independent of frameworks
- `Application`: use-case orchestration (CQRS handlers)
- `Infrastructure`: concrete implementations (DB, mail, external APIs)
- `Interfaces`: delivery mechanisms (HTTP/CLI)
- `Shared`: reusable cross-cutting utilities and contracts

## Frontend (Next.js + Presentation/Container pattern)

Base: `teamdev-2026-front/src/`

```text
src/
├── pages/
│   └── ...                         # each page only receives feature component
├── features/
│   └── [feature]/
│       ├── container/
│       ├── presentation/
│       └── index.ts
├── application/
│   ├── commands/
│   ├── queries/
│   └── usecases/
├── domain/
│   ├── models/
│   └── value-objects/
├── infrastructure/
│   ├── api/
│   └── repositories/
└── shared/
    ├── types/
    ├── utils/
    └── constants/
```

### Responsibility by layer

- `pages`: route entry points only
- `features/*/container`: state, hooks, API/query invocation
- `features/*/presentation`: stateless/pure UI
- `features/*/index.ts`: public feature export
- `application`: CQRS-oriented UI use-cases
- `domain`: frontend domain models and validation logic
- `infrastructure`: API client adapters (wrap generated client)
- `shared`: common helpers

## CQRS placement rules

- Write operation: `Commands` + `CommandHandlers`
- Read operation: `Queries` + `QueryHandlers` / read models
- Do not mix write-side mutation logic into query handlers
- Do not call infrastructure directly from presentation components

## TDD test placement

Backend:

- `tests/Unit/Domain/`
- `tests/Unit/Application/`
- `tests/Integration/Infrastructure/`
- `tests/Feature/Interfaces/Http/`

Frontend:

- `teamdev-2026-front/__tests__/features/[feature]/container/`
- `teamdev-2026-front/__tests__/features/[feature]/presentation/`
- `teamdev-2026-front/__tests__/application/`

## Adoption guidance

When adding new class/entity:

1. Decide if it is domain, application, infrastructure, or interface concern
2. Place write/read logic in CQRS-specific directories
3. Add tests first (TDD)
4. Keep docs and ADR updated when structure rules evolve

## Transition status (2026-03-05)

- Clean Architecture/CQRS target directories are scaffolded under [teamdev-2026-api/web/app](teamdev-2026-api/web/app):
    - [teamdev-2026-api/web/app/Domain](teamdev-2026-api/web/app/Domain)
    - [teamdev-2026-api/web/app/Application](teamdev-2026-api/web/app/Application)
    - [teamdev-2026-api/web/app/Infrastructure](teamdev-2026-api/web/app/Infrastructure)
    - [teamdev-2026-api/web/app/Interfaces](teamdev-2026-api/web/app/Interfaces)
    - [teamdev-2026-api/web/app/Shared](teamdev-2026-api/web/app/Shared)
- Test target directories are scaffolded under [teamdev-2026-api/web/tests](teamdev-2026-api/web/tests):
    - [teamdev-2026-api/web/tests/Unit/Domain](teamdev-2026-api/web/tests/Unit/Domain)
    - [teamdev-2026-api/web/tests/Unit/Application](teamdev-2026-api/web/tests/Unit/Application)
    - [teamdev-2026-api/web/tests/Integration/Infrastructure](teamdev-2026-api/web/tests/Integration/Infrastructure)
    - [teamdev-2026-api/web/tests/Feature/Interfaces/Http](teamdev-2026-api/web/tests/Feature/Interfaces/Http)
- Existing Laravel default folders (e.g. `Http`, `Models`, `Services`) remain temporarily and should be migrated incrementally by feature to avoid broad breakage.