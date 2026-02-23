# Spec-to-Doc Mapping & Sync Strategy

This document defines the relationship between machine-readable specs and human-readable documentation.

## Principle: Single Source of Truth with Human Translation

**Specs** = Machine-readable source of truth (WHAT)  
**Docs** = Human-readable explanations (WHY & HOW)

Every spec should have corresponding human documentation that explains it.

---

## 📋 Spec-to-Doc Mapping Table

| Spec File | Doc File | Purpose | Sync Frequency |
|-----------|----------|---------|----------------|
| `specs/ai-agents/context/essential-knowledge.md` | `docs/00-START-HERE.md` | Project onboarding | When project fundamentals change |
| `specs/ai-agents/context/project-context.md` | `docs/project/overview.md` | Project overview | When project goals/scope changes |
| `specs/ai-agents/context/technical-context.md` | `docs/architecture/system-design.md` + `docs/project/tech-stack.md` | Technical architecture | When tech stack or architecture changes |
| `specs/ai-agents/context/business-context.md` | `docs/business-logic/core-concepts.md` | Business concepts | When business rules change |
| `specs/ai-agents/guidelines.md` | `docs/development/workflow.md` | Development process | When workflow changes |
| `specs/ai-agents/prompts/*.md` | `docs/development/coding-standards.md` | Coding standards per role | When standards change |
| `specs/api/openapi.json` | `docs/api/guide.md` | API usage guide | After API changes |
| `specs/business/rules.yaml` | `docs/business-logic/validation-rules.md` | Business validation | When rules change |
| `specs/business/workflows.yaml` | `docs/business-logic/workflows/*.md` | Business workflows | When workflows change |
| `specs/database/schema.md` | `docs/architecture/data-model.md` | Database structure | After schema changes |

---

## 🔄 Sync Workflow

### When Creating New Specs

1. **Create spec file** in `specs/` (machine-readable)
2. **Create corresponding doc** in `docs/` (human-readable)
3. **Add mapping** to this file
4. **Cross-reference** both files to each other

### When Updating Existing Specs

1. **Update spec file** FIRST
2. **Update corresponding doc** to match
3. **Verify consistency** between spec and doc
4. **Note changes** in commit message

### Example Workflow
```bash
# 1. Update spec
vim specs/business/rules.yaml

# 2. Update corresponding doc
vim docs/business-logic/validation-rules.md

# 3. Commit both together
git add specs/business/rules.yaml docs/business-logic/validation-rules.md
git commit -m "feat: add email validation rule

- Added email uniqueness rule to specs/business/rules.yaml
- Documented rule explanation in docs/business-logic/validation-rules.md"
```

---

## 📝 Documentation Standards

### Specs (Machine-Readable)
- **Format**: YAML, JSON, or structured Markdown
- **Content**: Definitions, contracts, rules
- **Style**: Precise, unambiguous, parseable
- **Audience**: AI agents, code generators

**Example Spec** (`specs/business/rules.yaml`):
```yaml
validation:
  email:
    type: string
    format: email
    unique: true
    max_length: 255
    required: true
```

### Docs (Human-Readable)
- **Format**: Markdown with examples
- **Content**: Explanations, rationale, examples
- **Style**: Clear, teaching-oriented, contextual
- **Audience**: Developers, stakeholders

**Example Doc** (`docs/business-logic/validation-rules.md`):
```markdown
## Email Validation

User emails must be unique across the system to prevent duplicate accounts.

**Rules**:
- Must be valid email format (e.g., user@example.com)
- Maximum 255 characters
- Required field
- Must be unique in database

**Why**: Emails are used for login and password recovery...
**Implementation**: See `specs/business/rules.yaml` for exact spec...
```

---

## ✅ Checklist for Keeping Specs & Docs in Sync

### Before Committing Changes

- [ ] Spec file updated with new rules/definitions
- [ ] Corresponding doc file updated with explanations
- [ ] Cross-references added (spec → doc, doc → spec)
- [ ] Examples in docs match spec definitions
- [ ] Both files committed together
- [ ] Commit message mentions both files

### Code Review Checklist

- [ ] Spec changes have matching doc updates
- [ ] Docs accurately explain the specs
- [ ] No orphaned specs (spec without doc)
- [ ] No contradictions between spec and doc

---

## 🔗 Cross-Referencing Format

### In Spec Files
Add reference to human docs at the top:

```markdown
# Business Rules Spec

**Human Documentation**: See `docs/business-logic/validation-rules.md` for explanations.

---
[spec content]
```

### In Doc Files
Add reference to spec at the top:

```markdown
# Business Validation Rules

**Source Spec**: `specs/business/rules.yaml`

This document explains the business validation rules defined in the spec.

---
[doc content]
```

---

## 🚨 What to Do When Specs & Docs Diverge

### If You Notice Divergence
1. Determine which is correct (usually the spec)
2. Update the incorrect one
3. Document why divergence occurred
4. Consider process improvement

### Prevention
- Always update both together
- Include both in PR reviews
- Use automation where possible (see below)

---

## 🤖 Automation Ideas (Future)

### Spec → Doc Generation Helpers
```bash
# Script to check if spec has corresponding doc
make check-spec-doc-sync

# Script to create doc stub from spec
make create-doc-from-spec SPEC=specs/business/rules.yaml

# Script to validate cross-references
make validate-cross-refs
```

### Git Hooks
```bash
# Pre-commit hook to warn about orphaned specs
# Pre-commit hook to check cross-references exist
```

---

## 📚 File Templates

### Spec File Template
```markdown
# [Feature Name] Specification

**Version**: 1.0  
**Last Updated**: YYYY-MM-DD  
**Human Documentation**: `docs/[category]/[name].md`

## Purpose
[What this spec defines]

## Specification
[Machine-readable content]
```

### Doc File Template
```markdown
# [Feature Name] Documentation

**Source Spec**: `specs/[category]/[name].{yaml|json|md}`  
**Last Updated**: YYYY-MM-DD

## Overview
[Human-friendly explanation]

## Details
[Detailed explanation with examples]

## See Also
- Related specs
- Related docs
```

---

## 🎯 Quick Reference

### Creating New Feature Specs

1. **Create spec** in `specs/[category]/`
2. **Create doc** in `docs/[category]/`
3. **Add mapping** to this file
4. **Cross-reference** in both files
5. **Commit together**

### Updating Existing Specs

1. **Update spec** first
2. **Update doc** to match
3. **Verify cross-references** still accurate
4. **Commit together**

---

## 📊 Current Mappings Status

| Category | Specs Created | Docs Created | Synced |
|----------|---------------|--------------|--------|
| AI Agents | ✅ | ⏳ Partial | ⏳ |
| API | ⏳ | ⏳ | ⏳ |
| Business Logic | ⏳ | ⏳ | ⏳ |
| Database | ⏳ | ⏳ | ⏳ |

Legend: ✅ Complete | ⏳ In Progress | ❌ Not Started

---

Last updated: 2025-11-14
