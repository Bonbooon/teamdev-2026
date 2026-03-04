# AI Agent Guidelines

Guidelines for AI agents working on this project.

## Core Principles

### 1. Spec-First Development

- **ALWAYS** read relevant specs before making changes
- **NEVER** implement features without spec definition
- Specs in `specs/` are the single source of truth
- If specs are unclear, ask for clarification
- **CRITICAL**: Read `specs/business/product-brief.md` to understand the product vision and requirements

### 1.1 Documentation Maintenance

- **ALWAYS** update documentation when you learn new information about the project or application
- If any conversation, decision, or clarification reveals project details, update the relevant docs immediately
- Keep `specs/business/product-brief.md` updated with any new product requirements or clarifications
- Keep `docs/` in sync with any architectural or design decisions
- Documentation must reflect the current state of understanding - never let it become stale

### 2. Context Awareness

- Read `context/essential-knowledge.md` FIRST
- Consult `docs/diagrams/` for domain understanding and architecture context
- Understand domain models in `docs/diagrams/domain-models/` before coding
- Reference business context for logic decisions
- Stay within your role boundaries

### 3. Code Generation

- Use `teamdev-2026-api/docs/openapi/openapi.json` for API contracts (generated from Laravel API)
- Run `mise codegen-openapi` after OpenAPI changes
- **NEVER** manually edit `teamdev-2026-front/src/api/` (auto-generated)
- Respect generated types in TypeScript
- Never refer to `specs/api/openapi.json` - it's not the canonical source

### 4. Quality Standards

- Follow existing code patterns in the project
- Use TypeScript strictly (no `any` types)
- Write meaningful commit messages
- Keep changes surgical and minimal
- Always consider the "dogfooding" principle: would this feature help our own team?

### 5. Product Alignment

- Every feature must align with at least one of the 4 core pillars (see `specs/business/product-brief.md`)
- Balance productivity features with motivation features
- Remember: we're solving BOTH productivity AND motivation problems simultaneously
- Validate features against real team pain points (we are the target users)

## Working with Specs

### When to Update Specs

- Adding new API endpoints → Update OpenAPI in Laravel annotations (generates to `teamdev-2026-api/docs/openapi/openapi.json`)
- Adding business rules → Update `specs/business/rules.yaml`
- Changing workflows → Update `specs/business/workflows.yaml`
- Database changes → Update `specs/database/schema.md`
- Model/entity changes → Update corresponding diagram in `docs/diagrams/domain-models/`

### Spec Update Process

1. Modify relevant spec file
2. **Update corresponding doc** in `docs/` (see `specs/SPEC_DOC_MAPPING.md`)
3. Update diagrams if models/entities changed (maintain 1-to-1 model-code relationship)
4. Regenerate code if needed (e.g., `mise codegen-openapi` for API types)
5. Implement feature matching spec
6. Verify implementation against spec
7. Include test cases in spec (avoid mocking except for external APIs)

### Keeping Specs & Docs in Sync

- **ALWAYS** update both spec and its corresponding doc together
- Check `specs/SPEC_DOC_MAPPING.md` for spec-to-doc relationships
- Commit both files in the same commit
- Add cross-references between spec and doc files

## Domain Understanding

### Diagrams as Source of Truth

AI agents MUST consult `docs/diagrams/` for domain understanding:

- `domain-models/` - Entity relationships and aggregates
- `system-context.puml` - System boundaries and external systems
- `use-cases.puml` - User interactions and workflows
- `object-example.puml` - Example data structures

These diagrams are critical for understanding the problem domain before implementation.

## Model-Code Synchronization

**MANDATORY**: Maintain strict 1-to-1 relationship between models and code.

- When code structure changes, update the corresponding diagram immediately
- When diagrams are updated, implement matching code changes
- Never leave diagrams and code out of sync
- Include both in the same commit for accountability

## Role-Specific Guidelines

### Backend Developer

- Implement Laravel controllers matching OpenAPI spec (generated at `teamdev-2026-api/docs/openapi/openapi.json`)
- Update diagrams in `docs/diagrams/` when entity structures change
- Follow Laravel conventions and best practices
- Write migrations for database changes
- Add appropriate validation using FormRequest
- Include test cases in specs (minimize mocking)

### Frontend Developer

- Use generated API types from `src/api/` (generated from Laravel API)
- Consult domain models in `docs/diagrams/domain-models/` for entity understanding
- Follow React/Next.js best practices
- Use Zod for form validation
- Keep components small and reusable
- Update diagrams if component structure reflects domain changes

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
- Uncertain if a feature aligns with the 4 core pillars
- Product requirements need clarification (save for Q&A sessions with PO)

### What NOT to Do

- ❌ Implement without specs
- ❌ Manually edit generated code
- ❌ Ignore TypeScript errors
- ❌ Skip testing
- ❌ Make breaking changes without discussion
- ❌ Add dependencies without justification
- ❌ Leave models and code out of sync
- ❌ Leave documentation outdated when you learn new project information
- ❌ Build features that don't serve the 4 core pillars

## Testing

**MANDATORY**: Specs must include test cases.

**Mock Policy**: Minimize mocking - only use mocks for:

- External APIs (payment gateways, third-party services)
- Time/date dependencies when testing time-sensitive logic
- Random number generation in specific test scenarios

Prefer real implementations over mocks for:

- Database interactions
- Business logic
- Service collaborations
- Domain models

**Test Coverage**:

- Run existing tests before making changes
- Add tests for new features
- Frontend: Component tests, integration tests
- Backend: Feature tests for API endpoints (use real database)
- Integration: End-to-end tests validating data flow

## Git Workflow

- Create feature branches
- Keep commits atomic
- Write descriptive commit messages
- Follow conventional commits if established
