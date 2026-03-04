# Essential Knowledge for AI Agents

**READ THIS FIRST** - This document contains critical information every AI agent must know.

---

## Project Identity

**Name**: Motivation Cloud Teamwork  
**Type**: Full-stack web application (Long-term Hackathon project)  
**Client**: Link and Motivation Group  
**Purpose**: An application that simultaneously enhances both a team's **Productivity** and **Motivation**

**Target Audience**: Software development teams (Engineers, Product Managers, Designers collaborating)

**Core Concept**: "Dogfooding" - We are building this for our own team first. It must be indispensable for our own success.

**Current Phase**: Development  
**Timeline**:
- **Kickoff**: 2026/02/14
- **Development Start**: 2026/03/01
- **Code Freeze**: 2026/04/05 23:59:00
- **Presentations**:
  - Elimination Round (Engineering Judges): 2026/04/11 (10 min presentation + 7 min Q&A)
  - Final Round (Product Owner): 2026/04/12 (10 min presentation + 7 min Q&A)

**See Also**: `specs/business/product-brief.md` for complete product requirements and business context

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

- **API Contract**: `teamdev-2026-api/docs/openapi/openapi.json` (generated from Laravel API)
- **Business Rules**: `specs/business/rules.yaml`
- **Database Schema**: `specs/database/schema.md`
- **Domain Models**: `docs/diagrams/domain-models/` (PlantUML - CRITICAL for understanding architecture)
- **System Context**: `docs/diagrams/system-context.puml`
- **Use Cases**: `docs/diagrams/use-cases.puml`
- **Object Examples**: `docs/diagrams/object-example.puml`

### Auto-Generated (DO NOT EDIT)

- **Frontend API Types**: `teamdev-2026-front/src/api/` (generated from OpenAPI)
- **OpenAPI Spec**: `teamdev-2026-api/docs/openapi/openapi.json` (generated from Laravel annotations)

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
mise setup                    # Initial setup
docker compose up -d          # Start containers

# Development
cd teamdev-2026-front && npm run dev       # Start Next.js dev server
mise codegen-openapi                       # Regenerate API types

# Containers
mise app-shell                      # Access Laravel container
docker compose exec app bash        # Alternative
```

---

## Code Generation Pipeline

```
Laravel API Annotations
    ↓ (Laravel generates)
teamdev-2026-api/docs/openapi/openapi.json
    ↓ (mise codegen-openapi)
teamdev-2026-front/src/api/
    ↓ (import in components)
Type-safe API calls
```

**CRITICAL**: 
- Never manually edit `teamdev-2026-front/src/api/` - it's auto-generated from the Laravel API!
- Always refer to `teamdev-2026-api/docs/openapi/openapi.json` for the source of truth on API contracts

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

### Testing

**IMPORTANT**: Specs MUST include test cases. Minimize mocking - only use mocks for external APIs.

- **Frontend**: Component tests, integration tests
- **Backend**: Feature tests for API endpoints with real database interactions
- **Integration**: End-to-end tests validating complete data flow

---

## Common Pitfalls

❌ **DON'T**:

- Manually edit `teamdev-2026-front/src/api/`
- Implement without updating specs
- Use `any` in TypeScript
- Skip validation
- Make breaking API changes without version bump
- Forget the "dogfooding" mindset - we are the primary users!
- Implement features that don't serve ALL 4 core pillars

✅ **DO**:

- Read specs (especially `specs/business/product-brief.md`) before coding
- Follow existing patterns
- Write type-safe code
- Keep changes minimal
- Test your changes
- Keep the team productivity AND motivation balance

---

## Environment Variables

### Frontend (`teamdev-2026-front/.env.local`)

See `.env.example` in the frontend directory

### Backend (`teamdev-2026-api/web/.env`)

See `.env.example` in the Laravel directory

---

## Data Flow Example

Typical feature flow:

```
1. User clicks button in Next.js component
2. Component calls API function from src/api/ (generated types)
3. aspida sends type-safe HTTP request to Laravel
4. Laravel controller processes request, validates with FormRequest
5. Business logic executed (models, services, repositories)
6. Returns JSON response (OpenAPI-documented)
7. Frontend receives response via SWR
8. UI updates with new data
```

---

## Business Context

**Client**: Link and Motivation Group - A company focused on "Motivation Engineering" to create a meaningful society.

**The Problem We're Solving**:
- Japan has the lowest labor productivity among G7 nations
- Only 5% of Japanese employees are highly engaged (ranked 145/145 globally)
- "Working reluctantly" is the norm, causing widespread burnout and low productivity

**Our Solution**: Motivation Cloud Teamwork - An app tackling BOTH productivity AND motivation simultaneously.

**Required Reading**: `specs/business/product-brief.md` for complete details

### Four Core Pillars (All MUST be implemented)

1. **Role Design (Productivity)** - Clear role assignments and visibility
2. **Progress Management (Productivity)** - Shared progress tracking with visual indicators
3. **Condition Tracking (Motivation)** - Team member physical/psychological state visibility
4. **Mutual Understanding (Motivation)** - Profiles and relationship-building features

See `specs/business/product-brief.md` for detailed requirements, pain points, and success criteria.

### Core Entities

See `docs/diagrams/domain-models/` for:
- Team Aggregate
- User Aggregate
- And other domain entities

### Key Workflows

Documented in `specs/business/workflows/`

---

## Team Conventions

### Git

- Follow feature branch workflow
- Meaningful commit messages describing changes

### Code Style

- ESLint + Prettier for frontend (auto-format)
- Laravel conventions for backend
- Husky pre-commit hooks

## Model-Code Synchronization

**CRITICAL REQUIREMENT**: Models and code must maintain a 1-to-1 relationship.

- Any changes to domain models (`docs/diagrams/domain-models/`) MUST be reflected in code
- Any changes to code structures MUST be reflected in domain models
- Always update both diagrams and implementation together in the same commit
- This ensures diagrams remain the source of truth for architecture

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

## Q&A Sessions with Product Owner

We have 2 remaining opportunities to clarify requirements:
- **Next Session**: 2026/03/12 19:00
- **Final Session**: 2026/03/19 19:00

Use these strategically to validate understanding and get feedback on product direction.

## Deliverables

Due by code freeze (2026/04/05 23:59:00):

1. **Working Application**
   - Implements all "must" features specified by Product Owner
   - No critical bugs blocking core workflows
   - Clean, maintainable codebase

2. **Documentation**
   - README.md with clear project setup instructions
   - Deployment guide (if applicable)
   - Architecture overview

3. **Presentation Materials** (for both elimination and final rounds)
   - Product overview slides
   - Why Product Owner should choose this solution
   - Team introduction
   - **Live demonstration** (most important!)

## Getting Help

**When stuck**:

1. Check relevant spec in `specs/`
2. Check diagrams in `docs/diagrams/` for domain understanding
3. Check documentation in `docs/`
4. Check existing code patterns
5. Escalate to team during Q&A sessions with Product Owner

**Never**:

- Guess at business logic
- Make breaking changes without discussion
- Implement features not in specs
- Skip model-code synchronization
