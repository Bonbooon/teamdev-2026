# Specifications Directory

This directory contains the **machine-readable source of truth** for the project.

## Structure

```
specs/
├── api/              # API contracts (OpenAPI)
├── business/         # Business logic rules & workflows
├── database/         # Database schemas
└── ai-agents/        # AI agent configurations & context
```

## Spec-Driven Development Workflow

1. **Define** - Update specs FIRST before coding
2. **Generate** - Generate types/code from specs
3. **Implement** - Build features matching specs
4. **Validate** - Ensure implementation matches specs

## Important Rules

- ✅ Specs are the single source of truth
- ✅ Update specs before implementation
- ✅ Keep specs machine-readable when possible
- ❌ Never manually edit generated code
- ❌ Don't let implementation drift from specs

## For AI Agents

If you're an AI agent working on this project:
1. **Read** `specs/ai-agents/context/essential-knowledge.md` first
2. **Follow** guidelines in `specs/ai-agents/guidelines.md`
3. **Use** your role-specific prompt from `specs/ai-agents/prompts/`
4. **Respect** all specs as source of truth

## Spec-to-Doc Relationship

Every spec should have corresponding human documentation in `docs/`.

**See**: `SPEC_DOC_MAPPING.md` for the complete mapping between specs and docs.

**Rule**: When updating a spec, always update its corresponding doc.
