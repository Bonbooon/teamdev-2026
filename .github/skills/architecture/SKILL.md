---
name: architecture
description: Understand the system architecture, tech stack, and key directories
---

# Architecture Skill

## Quick Overview

```
Next.js Frontend (localhost:3000)
    ↓ (aspida - type-safe API)
Nginx (per worktree)
    ↓
Laravel API (PHP-FPM)
    ↓ (external Docker network: teamdev-2026-shared)
Shared PostgreSQL (compose.shared.yml, localhost:5432)
```

**Tech Stack**: 
- Frontend: Next.js 15 + TypeScript + Tailwind CSS
- Backend: Laravel + PostgreSQL
- Container: Docker Compose with per-worktree app/web/swagger services and one shared PostgreSQL service

---

## Key Rules

### API Generation Pipeline
```
Laravel Annotations → teamdev-2026-api/docs/openapi/openapi.json
                   → mise codegen-openapi
                   → teamdev-2026-front/src/api/ (generated)
```

**CRITICAL**:
- ❌ Never manually edit `teamdev-2026-front/src/api/`
- ✅ Run `mise codegen-openapi` after Laravel changes
- ✅ Always refer to `teamdev-2026-api/docs/openapi/openapi.json` for API source of truth

### Model-Code Sync
- When code changes → Update diagrams
- When diagrams change → Update code
- Include both in same commit
- Never leave them out of sync

---

## Service Ports
- Frontend: 3000
- API: 80
- Database: 5432 (shared across all worktrees)

---

## Key Directories
- `specs/` - Source of truth specs
- `docs/` - Human-readable docs
- `teamdev-2026-api/web/` - Laravel app
- `teamdev-2026-front/src/` - React app
- `docs/diagrams/domain-models/` - Domain models (KEEP IN SYNC)

---

## Commands

```bash
mise run setup          # Initial setup
mise run start          # Start current worktree services and ensure shared DB
mise run worktree-info  # Show current worktree ports and shared DB info
mise codegen-openapi    # Regenerate API types
mise app-shell          # Access Laravel container
```

---

## Get More Context

- Full architecture: `specs/ai-agents/context/essential-knowledge.md`
- Architecture guidelines: `specs/ai-agents/guidelines.md`
- Domain models: `docs/diagrams/domain-models/`
