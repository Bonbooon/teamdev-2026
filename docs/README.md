# Documentation

Human-readable documentation for the {{template}} project.

## 📚 Documentation Map

### For New Team Members

👉 Start here: [`00-START-HERE.md`](./00-START-HERE.md)

### Quick Links

#### Project Information

- [Project Overview](./project/overview.md) - What we're building
- [Tech Stack](./project/tech-stack.md) - Technologies used
- [Glossary](./project/glossary.md) - Terms and definitions

#### Architecture

- [Architecture Overview](./architecture/README.md) - Layer responsibilities and decision navigation
- [Directory Structure](./architecture/directory-structure.md) - Clean Architecture + CQRS + frontend feature pattern
- [ADRs](./architecture/adr/) - Architecture Decision Records

#### Business Logic

- [Core Concepts](./business-logic/core-concepts.md) - Key business concepts
- [Validation Rules](./business-logic/validation-rules.md) - Data validation
- [Workflows](./business-logic/workflows/) - Business process flows

#### Development

- [Setup Guide](./development/setup.md) - Getting started
- [Development Workflow](./development/workflow.md) - Daily development process
- [Coding Standards](./development/coding-standards.md) - Code quality guidelines
- [Troubleshooting](./development/troubleshooting.md) - Common issues & solutions

#### API

- [API Guide](./api/guide.md) - How to use the API
- [Authentication](./api/authentication.md) - Auth flow & tokens

---

## 🤖 For AI Agents

**If you're an AI agent**, you should be reading from `specs/` directory instead:

- Start with: `../specs/ai-agents/context/essential-knowledge.md`
- Follow: `../specs/ai-agents/guidelines.md`
- Use your role prompt: `../specs/ai-agents/prompts/[your-role].md`

---

## 📖 How to Use This Documentation

### For Developers

1. Read `00-START-HERE.md` first
2. Set up your environment with `development/setup.md`
3. Understand the architecture from `architecture/` docs
4. Reference business logic in `business-logic/` when implementing features

### For Stakeholders

1. Read `project/overview.md` for project goals
2. Check `business-logic/core-concepts.md` for business rules
3. Review workflows in `business-logic/workflows/`

---

## 🔄 Documentation vs Specs

This `docs/` folder contains **human-readable explanations**.

The `specs/` folder contains **machine-readable source of truth**.

| Docs (Human)        | Specs (Machine)               |
| ------------------- | ----------------------------- |
| Explain WHY         | Define WHAT                   |
| Provide context     | Provide contracts             |
| Guide understanding | Enable code generation        |
| Written in prose    | Written in structured formats |

**Key principle**: Specs are authoritative. Docs explain the specs.

**Important**: Every spec should have a corresponding doc. See `../specs/SPEC_DOC_MAPPING.md` for the complete mapping.

---

## ✏️ Contributing to Documentation

### When to Update Docs

- Adding new features → Update relevant docs
- Changing architecture → Update architecture docs + add ADR
- New setup steps → Update development/setup.md
- Business rules change → Update business-logic docs

### Documentation Standards

- Use clear, simple language
- Include examples where helpful
- Keep docs in sync with specs
- Use diagrams for complex concepts
- Link to related docs

### File Naming

- Use kebab-case: `my-document.md`
- Be descriptive: `user-registration-workflow.md` not `flow1.md`
- Use folders for grouping related docs

---

## 📁 Documentation Structure

```
docs/
├── README.md                    # This file - documentation index
├── 00-START-HERE.md            # New team member onboarding
│
├── project/                     # Project overview & context
│   ├── overview.md
│   ├── tech-stack.md
│   └── glossary.md
│
├── architecture/                # System architecture
│   ├── system-design.md
│   ├── data-flow.md
│   ├── directory-structure.md
│   └── adr/                    # Architecture Decision Records
│       └── template.md
│
├── business-logic/              # Business rules & workflows
│   ├── core-concepts.md
│   ├── validation-rules.md
│   └── workflows/
│       └── [workflow-name].md
│
├── development/                 # Development guides
│   ├── setup.md
│   ├── workflow.md
│   ├── coding-standards.md
│   └── troubleshooting.md
│
└── api/                        # API documentation
    ├── guide.md
    └── authentication.md
```

---

## 🔍 Finding What You Need

### I want to...

**Understand the project**
→ Read `project/overview.md`

**Set up my environment**
→ Follow `development/setup.md`

**Add a new feature**
→ Check `specs/api/openapi.json`, then `development/workflow.md`

**Understand how data flows**
→ Read `architecture/data-flow.md`

**Fix a bug**
→ Check `development/troubleshooting.md`

**Understand business rules**
→ Read `business-logic/core-concepts.md`

**Work with the API**
→ Read `api/guide.md` and check `specs/api/openapi.json`

---

## 🆘 Need Help?

1. Search this documentation
2. Check `development/troubleshooting.md`
3. Review relevant specs in `../specs/`
4. Ask the team

---

Last updated: 2026-03-05
