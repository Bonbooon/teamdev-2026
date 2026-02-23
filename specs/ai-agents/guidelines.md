# AI Agent Guidelines

Guidelines for AI agents working on this project.

## Core Principles

### 1. Spec-First Development

- **ALWAYS** read relevant specs before making changes
- **NEVER** implement features without spec definition
- Specs in `specs/` are the single source of truth
- If specs are unclear, ask for clarification

### 2. Context Awareness

- Read `context/essential-knowledge.md` FIRST
- Understand the project architecture before coding
- Reference business context for logic decisions
- Stay within your role boundaries

### 3. Code Generation

- Use `specs/api/openapi.json` for API contracts
- Run `make codegen-openapi` after OpenAPI changes
- **NEVER** manually edit `teamdev-2026-front/src/api/` (auto-generated)
- Respect generated types in TypeScript

### 4. Quality Standards

- Follow existing code patterns in the project
- Use TypeScript strictly (no `any` types)
- Write meaningful commit messages
- Keep changes surgical and minimal

## Working with Specs

### When to Update Specs

- Adding new API endpoints → Update `specs/api/openapi.json`
- Adding business rules → Update `specs/business/rules.yaml`
- Changing workflows → Update `specs/business/workflows.yaml`
- Database changes → Update `specs/database/schema.md`

### Spec Update Process

1. Modify relevant spec file
2. **Update corresponding doc** in `docs/` (see `specs/SPEC_DOC_MAPPING.md`)
3. Regenerate code if needed (e.g., `make codegen-openapi`)
4. Implement feature matching spec
5. Verify implementation against spec

### Keeping Specs & Docs in Sync

- **ALWAYS** update both spec and its corresponding doc together
- Check `specs/SPEC_DOC_MAPPING.md` for spec-to-doc relationships
- Commit both files in the same commit
- Add cross-references between spec and doc files

## Role-Specific Guidelines

### Backend Developer

- Implement Laravel controllers matching OpenAPI spec
- Follow Laravel conventions and best practices
- Write migrations for database changes
- Add appropriate validation using FormRequest

### Frontend Developer

- Use generated API types from `src/api/`
- Follow React/Next.js best practices
- Use Zod for form validation
- Keep components small and reusable

### Code Reviewer

- Verify implementation matches specs
- Check for code quality issues
- Ensure tests are adequate
- Validate TypeScript typing

### Feature Builder

- Define spec before implementation
- Coordinate frontend + backend changes
- Ensure end-to-end consistency
- Update relevant documentation

## Communication

### When to Ask for Help

- Specs are ambiguous or conflicting
- Business logic is unclear
- Architecture decision needed
- Breaking changes required

### What NOT to Do

- ❌ Implement without specs
- ❌ Manually edit generated code
- ❌ Ignore TypeScript errors
- ❌ Skip testing
- ❌ Make breaking changes without discussion
- ❌ Add dependencies without justification

## Testing

- Run existing tests before making changes
- Add tests for new features
- Frontend: Component tests where appropriate
- Backend: Feature tests for API endpoints

## Git Workflow

- Create feature branches
- Keep commits atomic
- Write descriptive commit messages
- Follow conventional commits if established
