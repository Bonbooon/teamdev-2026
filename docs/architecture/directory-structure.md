# Directory Structure

This document defines layer responsibilities for Clean Architecture + CQRS and the frontend feature-based pattern.

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

## Frontend (Next.js + Feature-based pattern)

> **Note:** The original plan used a Container/Presentation pattern. During Phase 1 MVP implementation, a simpler feature-based organization (components + hooks) was adopted. See ADR `docs/architecture/adr/0008-feature-based-frontend-organization.md` for rationale.

Base: `teamdev-2026-front/src/`

```text
src/
├── pages/
│   ├── login/
│   │   └── index.tsx              # AuthLayout → GoogleLoginButton
│   ├── profile/
│   │   └── setup.tsx              # SetupLayout → ProfileSetup
│   ├── teams/
│   │   ├── index.tsx              # AppLayout → TeamListPage
│   │   └── [teamId].tsx           # AppLayout → TeamDetailPage
│   ├── projects/
│   │   ├── index.tsx              # AppLayout → ProjectListPage
│   │   └── [projectId]/
│   │       ├── index.tsx          # AppLayout → ProjectDetailPage
│   │       └── issues/
│   │           └── new.tsx        # AppLayout → IssueCreatePage
│   ├── issues/
│   │   └── [issueId].tsx          # AppLayout → IssueDetailPage
│   └── index.tsx                  # AppLayout → Dashboard
├── features/
│   ├── teams/
│   │   ├── components/            # TeamListPage, TeamCard, TeamHeader, etc.
│   │   └── hooks/                 # useTeams, useTeam, useTeamMembers
│   ├── projects/
│   │   ├── components/            # ProjectListPage, ProjectCard, FilterBar, etc.
│   │   └── hooks/                 # useProjects, useProject, useProjectIssues, useProjectAlerts
│   └── issues/
│       ├── components/            # IssueCreatePage, IssueDetailPage, IssueForm, etc.
│       └── hooks/                 # useIssue, useIssueSubtasks, useIssueDod, useIssueTemplates
├── components/
│   ├── ui/                        # Design system (Button, Input, Modal, Card, Badge, etc.)
│   └── common/                    # AuthGuard, GoogleLoginButton, Loading
├── layouts/
│   ├── AppLayout.tsx              # Sidebar + Header + content
│   ├── AuthLayout.tsx             # Centered card layout
│   ├── SetupLayout.tsx            # Minimal layout for profile setup
│   ├── Header/                    # Header with TabNav
│   └── Sidebar/                   # QuickActions + UserSection
├── hooks/
│   └── useAuth.ts                 # Authentication hook
├── styles/
│   └── globals.css                # Tailwind + Google Fonts
└── utils/
    └── cn.ts                      # clsx + twMerge utility
```

### Responsibility by layer

- `pages`: route entry points only — thin wrappers that compose layout + feature component
- `features/*/components`: feature-specific UI components (both stateful and presentational)
- `features/*/hooks`: SWR-based data fetching hooks (one hook per API resource)
- `components/ui`: shared design system components (stateless, reusable)
- `components/common`: shared app-level components (auth, loading)
- `layouts`: page layout shells (AppLayout, AuthLayout, SetupLayout)
- `hooks`: shared application hooks
- `styles`: global CSS and Tailwind config
- `utils`: utility functions

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

- `teamdev-2026-front/__tests__/features/[feature]/components/`
- `teamdev-2026-front/__tests__/features/[feature]/hooks/`
- `teamdev-2026-front/__tests__/components/ui/`

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
