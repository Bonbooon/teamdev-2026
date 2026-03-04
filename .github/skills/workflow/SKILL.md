---
name: workflow
description: Development workflow, git conventions, and spec-first approach
---

# Workflow Skill

## The Golden Rule

**Spec-First Development**

1. Read spec first (ALWAYS)
2. Plan your approach
3. Update specs if needed
4. Generate code (if applicable)
5. Implement
6. Validate against spec
7. Write tests from spec test cases
8. Update docs if new learnings

---

## Git Conventions

**Commit Format**: Conventional Commits

```
type(scope): description

Example:
feat(alerts): implement yellow alert triggers for project delays
docs(product-brief): add discovery insights
fix(api): correct task progress calculation
```

**Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `style`

---

## Code Generation

### When to Generate
- After updating Laravel API annotations
- After changing database schema
- After modifying OpenAPI contracts

### How to Generate
```bash
mise codegen-openapi  # After Laravel API changes
```

**CRITICAL**: 
- ❌ Never manually edit generated files
- ✅ Code generation is part of spec-first workflow

---

## Model-Code Synchronization

**MANDATORY**: Keep models and code in sync (1-to-1 relationship)

- Code structure changes → Update diagrams
- Diagram changes → Update code
- Include both changes in same commit
- Never leave them out of sync

---

## Documentation Maintenance

**When learning new info**: Update docs immediately

- Product changes → Update `specs/business/product-brief.md`
- Architecture changes → Update `docs/`
- Learnings → Update relevant `docs/` or `specs/`
- Never let docs get stale

---

## MUST vs WANT Features

**Important distinction**:
- **MUST**: Bare minimum baseline
- **WANT**: What actually solves the problem

**Phase 1 focus**: WANT features (alerts, SMART templates, GitHub integration)

---

## Get More Details

- Full workflow: `specs/ai-agents/guidelines.md` (Working with Specs section)
- Commit examples: Check git log with `git log --oneline | head -20`
- Branch naming: Use `feature/`, `fix/`, `docs/` prefixes
