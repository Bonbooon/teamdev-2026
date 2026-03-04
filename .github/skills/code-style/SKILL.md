---
name: code-style
description: Coding conventions, patterns, and quality standards for this project
---

# Code Style Skill

## Read First

**ALL** code style rules are defined in:
- `specs/ai-agents/guidelines.md` - Complete code quality standards
- Check "Quality Standards" and "Role-Specific Guidelines" sections

---

## Key Rules

### TypeScript (Frontend)
- ✅ Strict mode ALWAYS
- ✅ Use generated types from `src/api/`
- ❌ NO `any` types - enforce strictly
- ✅ Type all parameters and returns

### React/Next.js
- ✅ Functional components only
- ✅ Custom hooks for reusable logic
- ✅ React Hook Form + Zod for validation
- ✅ SWR for server state

### Laravel (Backend)
- ✅ RESTful routes
- ✅ FormRequest for validation
- ✅ Business logic in services/models
- ✅ Never skip validation

---

## Pre-commit Requirements

- ✅ ESLint + Prettier (frontend) - auto-format
- ✅ Laravel Pint (backend) - auto-format
- ✅ Husky pre-commit hooks run automatically
- ❌ Don't bypass checks

---

## Naming Conventions

**Frontend**:
- Components: `PascalCase` (e.g., `AlertCard.tsx`)
- Functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

**Backend**:
- Controllers: `SingularController`
- Models: `Singular`
- Tables: `plural_snake_case`

---

## Common Anti-Patterns to Avoid

- ❌ Using `any` type
- ❌ Business logic in controllers
- ❌ Deep component nesting
- ❌ Global state for local concerns
- ❌ Manual string concatenation for URLs

---

## Get More Details

- Full style guide: `specs/ai-agents/guidelines.md` (Quality Standards section)
- Code examples: Check `teamdev-2026-front/src/` and `teamdev-2026-api/web/app/` in repo
