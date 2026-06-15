# Documentation

Human-readable documentation for the `teamdev-2026` workspace.

## Documentation Map

### Start Here

- [Repository README](../README.md) - environment setup, `mise` tasks, Docker workflow, and worktree basics
- [UI Specification](./ui-specification.md) - the broadest UI-level view of routes, layouts, and page requirements

### Architecture

- [Architecture Overview](./architecture/README.md) - architecture entry point and layer responsibilities
- [Directory Structure](./architecture/directory-structure.md) - code placement conventions for API and frontend
- [Alert Trigger Architecture](./architecture/alert-trigger-architecture.md) - current alert pipeline design in the API
- [ADR 0001](./architecture/adr/0001-adopt-clean-architecture-cqrs-tdd.md) - Clean Architecture + CQRS + TDD baseline
- [ADR 0006](./architecture/adr/0006-openapi-l5-swagger.md) - OpenAPI generation workflow
- [ADR 0009](./architecture/adr/0009-feature-based-frontend-organization.md) - frontend feature organization

### Business Logic

- [Prototype Strategy](./business-logic/prototype-strategy.md) - MVP direction and product-level tradeoffs
- [Prototype Strategy (Japanese)](./business-logic/prototype-strategy-ja.md) - Japanese version of the prototype strategy
- [Issue Management Workflow](./business-logic/workflows/issue-management.md) - issue handling workflow details

### Development

- [Repository README](../README.md) - practical setup and day-to-day developer commands
- [Mise Cross-Platform Research](./development/mise-cross-platform-research.md) - host OS handling and task portability review

### UI Documentation

- [UI Pages Index](./ui-pages/README.md) - page-by-page UI documents
- [Library Comparison](./ui-references/library-comparison.md) - UI library notes
- [Gantt Chart Reference](./ui-references/gantt-chart/README.md) - gantt reference material

### Diagrams

- `docs/diagrams/` - source PlantUML files
- `docs/generated-diagrams/` - rendered SVG output

---

## For AI Agents

If you're an AI agent, read from `specs/` first:

- Start with: `../specs/ai-agents/context/essential-knowledge.md`
- Follow: `../specs/ai-agents/guidelines.md`
- Use the appropriate role prompt under `../specs/ai-agents/prompts/`

---

## How to Use This Documentation

### For Developers

1. Start with [Repository README](../README.md) for setup and daily commands.
2. Read [Architecture Overview](./architecture/README.md) and [Directory Structure](./architecture/directory-structure.md) before placing code.
3. Use [Prototype Strategy](./business-logic/prototype-strategy.md) for business context and MVP intent.
4. Use [UI Specification](./ui-specification.md) and [UI Pages Index](./ui-pages/README.md) when changing frontend flows.
5. Use [Mise Cross-Platform Research](./development/mise-cross-platform-research.md) when changing task wiring or host-specific tooling.

### For Stakeholders

1. Read [UI Specification](./ui-specification.md) for product surface and route coverage.
2. Read [Prototype Strategy](./business-logic/prototype-strategy.md) for product direction.
3. Review the relevant [UI page docs](./ui-pages/README.md) for screen-level detail.

---

## Documentation vs Specs

This `docs/` folder contains human-readable explanations.

The `specs/` folder contains the machine-readable source of truth.

| Docs (Human)        | Specs (Machine)               |
| ------------------- | ----------------------------- |
| Explain WHY         | Define WHAT                   |
| Provide context     | Provide contracts             |
| Guide understanding | Enable code generation        |
| Written in prose    | Written in structured formats |

Key principle: specs are authoritative, docs explain the specs and current implementation.

---

## Contributing to Documentation

### When to Update Docs

- Setup or task workflow changes: update [Repository README](../README.md) and any relevant development note
- Architecture changes: update `docs/architecture/` and add or revise ADRs
- Business rule changes: update `docs/business-logic/`
- UI changes: update [UI Specification](./ui-specification.md) or the relevant `docs/ui-pages/` file
- Tooling or host-OS learnings: update [Mise Cross-Platform Research](./development/mise-cross-platform-research.md) or the root README

### Documentation Standards

- Use clear, concrete language
- Prefer links to existing docs over placeholder paths
- Keep docs aligned with current repository contents
- Update diagrams when they materially improve understanding

### File Naming

- Use kebab-case
- Prefer descriptive names
- Group related documents under a folder when the topic has multiple pages

---

## Documentation Structure

```
docs/
├── README.md
├── architecture/
│   ├── README.md
│   ├── alert-trigger-architecture.md
│   ├── directory-structure.md
│   └── adr/
│       └── 0001-*.md, 0005-*.md, 0006-*.md, ...
├── business-logic/
│   ├── prototype-strategy.md
│   ├── prototype-strategy-ja.md
│   └── workflows/
│       └── issue-management.md
├── development/
│   └── mise-cross-platform-research.md
├── diagrams/
├── generated-diagrams/
├── ui-pages/
│   ├── README.md
│   └── [page-docs].md
├── ui-references/
│   ├── library-comparison.md
│   └── gantt-chart/
│       └── README.md
└── ui-specification.md
```

---

## Finding What You Need

### I want to...

Understand repository setup and daily commands:
[Repository README](../README.md)

Understand architecture and code placement:
[Architecture Overview](./architecture/README.md) and [Directory Structure](./architecture/directory-structure.md)

Understand product direction and business intent:
[Prototype Strategy](./business-logic/prototype-strategy.md)

Understand UI flows and page expectations:
[UI Specification](./ui-specification.md) and [UI Pages Index](./ui-pages/README.md)

Investigate `mise`, worktree, or host-OS behavior:
[Mise Cross-Platform Research](./development/mise-cross-platform-research.md)

Review architecture decisions:
`docs/architecture/adr/`

---

## Need Help?

1. Search the existing docs under `docs/`
2. Check the root [Repository README](../README.md)
3. Review the relevant source-of-truth material under `specs/`
4. Ask the team when implementation and docs disagree

---

Last updated: 2026-04-02
