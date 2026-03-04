---
name: quick-start-guide
description: Step-by-step guidance for common development tasks
---

# Quick Start Guide Skill

## Before Any Task

1. ✅ Read relevant spec (check navigation in copilot-instructions.md)
2. ✅ Read `specs/ai-agents/guidelines.md` - ALL rules apply
3. ✅ Check if similar code exists in repo
4. ✅ Ask: "Does this align with product vision?" (dogfooding)

---

## Common Tasks

### Adding an API Endpoint

1. Define in spec → Update `specs/business/` with test cases
2. Create migration (if DB change): `mise app-shell php artisan make:migration`
3. Create model (if new entity): `mise app-shell php artisan make:model`
4. Create controller: `mise app-shell php artisan make:controller`
5. Add route with OpenAPI annotations
6. Create FormRequest for validation
7. Implement business logic
8. Generate types: `mise codegen-openapi`
9. Write tests (use spec test cases)
10. Update docs if new learnings
11. Commit with conventional format: `feat(entity): add endpoint description`

---

### Creating a React Component

1. Understand requirements (check specs)
2. Design component props (with TypeScript interfaces)
3. Create: `teamdev-2026-front/src/components/ComponentName.tsx`
4. Use functional component + React hooks
5. Use generated types from `src/api/`
6. Write tests
7. Ensure no `any` types, TypeScript strict
8. Commit with conventional format

---

### Setting Up Database Migration

1. Update spec: `specs/database/schema.md`
2. Create migration: `mise app-shell php artisan make:migration`
3. Write up() and down() methods
4. Run: `mise app-shell php artisan migrate`
5. Update model relationships and fillables
6. **UPDATE DIAGRAMS**: `docs/diagrams/domain-models/`
7. Write tests
8. Commit code + diagram changes together

---

### Implementing an Alert Trigger

1. Review: `specs/business/alert-system.md` for alert specifications
2. Reference: `docs/business-logic/prototype-strategy.md` for trigger definitions and examples
3. Create service in: `teamdev-2026-api/web/app/Services/`
4. Implement trigger check logic
5. Create job (if periodic): `php artisan make:job`
6. Create notification: `php artisan make:notification`
7. Write tests for trigger conditions
8. Update docs if logic differs from spec
9. Commit with: `feat(alerts): implement [alert-category] trigger`

---

### Writing Tests

1. Review spec test cases
2. Setup test data with factories/seeders
3. Write: happy path, error cases, edge cases
4. Run: `npm run test` (frontend) or `php artisan test` (backend)
5. Aim for 80%+ coverage on business logic

---

### Updating Documentation

1. Identify what changed (requirement, architecture, business logic)
2. Find relevant doc:
   - Product: `specs/business/product-brief.md`
   - Architecture: `docs/` or `specs/`
   - Process: `specs/ai-agents/`
3. Update the doc
4. Update timestamp if major change
5. Commit: `docs(filename): what changed`

---

## Getting Unstuck

**In this order**:
1. Check relevant skill file in `.github/skills/`
2. Check `specs/ai-agents/guidelines.md` for rules
3. Check actual code for patterns
4. Check `docs/` for examples
5. Ask team or escalate to PO session

---

## Key Files to Read First

- **Guidelines** (ALL RULES): `specs/ai-agents/guidelines.md`
- **Product Context**: `specs/business/product-brief.md`
- **Prototype Strategy**: `docs/business-logic/prototype-strategy.md`
- **Architecture**: `specs/ai-agents/context/essential-knowledge.md`
