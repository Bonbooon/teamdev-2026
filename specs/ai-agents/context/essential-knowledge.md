# Essential Knowledge for AI Agents

**READ THIS FIRST** - This document contains critical information every AI agent must know.

---

## Project Identity

**Name**: {{template}}  
**Type**: Full-stack web application (Long-term Hackathon project)  
**Purpose**: [TO BE FILLED - What does this application do?]

**Current Phase**: Development  
**Timeline**: [TO BE FILLED - Hackathon dates/deadlines]

---

## Architecture Overview

```
User Browser
    ↓
Next.js Frontend (localhost:3000)
    ↓ (aspida - type-safe API client)
Nginx (localhost:80)
    ↓
Laravel API (PHP-FPM)
    ↓
PostgreSQL (localhost:5432)
```

---

## Tech Stack

### Frontend

- **Framework**: Next.js 15 (React 18)
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS
- **API Client**: aspida + aspida-swr
- **Forms**: React Hook Form + Zod
- **State**: React hooks + SWR for server state

### Backend

- **Framework**: Laravel (PHP)
- **Database**: PostgreSQL 14.7
- **Auth**: Laravel Breeze
- **API**: RESTful, documented in OpenAPI

### Infrastructure

- **Containers**: Docker + Docker Compose
- **Web Server**: Nginx
- **Development**: Local containers

---

## Critical File Locations

### Source of Truth

- **API Contract**: `specs/api/openapi.json`
- **Business Rules**: `specs/business/rules.yaml`
- **Database Schema**: `specs/database/schema.md`

### Auto-Generated (DO NOT EDIT)

- **Frontend API Types**: `teamdev-2026-front/src/api/` (generated from OpenAPI)

### Key Configs

- **Laravel**: `teamdev-2026-api/web/`
- **Next.js**: `teamdev-2026-front/`
- **Docker**: `compose.yml`, `docker/`

---

## Directory Structure (Simplified)

```
{{template}}/
├── specs/              # Machine-readable specs (SOURCE OF TRUTH)
├── docs/               # Human-readable documentation
├── teamdev-2026-api/web/            # Laravel application
├── teamdev-2026-front/              # Next.js application
├── docker/             # Docker configurations
└── scripts/            # Utility scripts
```

---

## Development Workflow

### The Golden Rule

**Specs First, Code Second**

1. Update spec in `specs/`
2. Generate code (if applicable)
3. Implement feature
4. Validate against spec

### Key Commands

```bash
# Setup
make init                     # Initial setup (Mac)
docker compose up -d          # Start containers

# Development
cd teamdev-2026-front && npm run dev       # Start Next.js dev server
make codegen-openapi          # Regenerate API types

# Containers
make app                      # Access Laravel container
docker compose exec app bash  # Alternative
```

---

## Code Generation Pipeline

```
specs/api/openapi.json
    ↓ (make codegen-openapi)
teamdev-2026-front/src/api/
    ↓ (import in components)
Type-safe API calls
```

**CRITICAL**: Never manually edit `teamdev-2026-front/src/api/` - it's auto-generated!

---

## Service Ports

| Service    | Port | URL                   |
| ---------- | ---- | --------------------- |
| Frontend   | 3000 | http://localhost:3000 |
| API        | 80   | http://localhost      |
| PostgreSQL | 5432 | localhost:5432        |
| Swagger UI | 8080 | http://localhost:8080 |

---

## Quality Standards

### TypeScript

- Strict mode enabled
- No `any` types
- Use generated types from `src/api/`

### React/Next.js

- Functional components
- Custom hooks for reusable logic
- Keep components small

### Laravel

- Follow Laravel conventions
- Use FormRequests for validation
- RESTful routes

---

## Testing Strategy

- **Frontend**: [TO BE FILLED - Component tests? E2E?]
- **Backend**: Feature tests for API endpoints
- **Integration**: [TO BE FILLED]

---

## Common Pitfalls

❌ **DON'T**:

- Manually edit `teamdev-2026-front/src/api/`
- Implement without updating specs
- Use `any` in TypeScript
- Skip validation
- Make breaking API changes without version bump

✅ **DO**:

- Read specs before coding
- Follow existing patterns
- Write type-safe code
- Keep changes minimal
- Test your changes

---

## Environment Variables

### Frontend (`teamdev-2026-front/.env.local`)

```bash
[TO BE FILLED - What env vars are needed?]
```

### Backend (`teamdev-2026-api/web/.env`)

```bash
[TO BE FILLED - What env vars are needed?]
```

---

## Data Flow Example

[TO BE FILLED - Show a concrete example of how data flows through the system]

```
1. User clicks button in React component
2. Component calls API function from src/api/
3. aspida sends HTTP request to Laravel
4. Laravel controller processes request
5. Returns JSON response
6. Frontend updates UI with SWR
```

---

## Business Context

[TO BE FILLED - High-level business logic overview]

### Core Entities

- [Entity 1]
- [Entity 2]
- [Entity 3]

### Key Workflows

- [Workflow 1]
- [Workflow 2]

---

## Team Conventions

### Git

- [TO BE FILLED - Branch naming? Commit message format?]

### Code Style

- ESLint + Prettier for frontend (auto-format)
- Laravel conventions for backend
- Husky pre-commit hooks

---

## Quick Reference

### Adding a New API Endpoint

1. Update `specs/api/openapi.json`
2. Run `make codegen-openapi`
3. Implement Laravel route/controller
4. Use generated types in frontend

### Adding a Business Rule

1. Document in `specs/business/rules.yaml`
2. Implement in Laravel
3. Add frontend validation with Zod

### Database Changes

1. Update `specs/database/schema.md`
2. Create Laravel migration
3. Run migration

---

## Getting Help

**When stuck**:

1. Check relevant spec in `specs/`
2. Check documentation in `docs/`
3. Check existing code patterns
4. Ask for human clarification

**Never**:

- Guess at business logic
- Make breaking changes without approval
- Skip specs
