# Spec & Doc Sync Checklist Template

Use this checklist when creating or updating specs to ensure documentation stays in sync.

---

## 📝 Creating New Spec

When creating a new specification:

- [ ] **Create spec file** in appropriate `specs/` subdirectory
- [ ] **Create corresponding doc** in appropriate `docs/` subdirectory
- [ ] **Add mapping** to `specs/SPEC_DOC_MAPPING.md`
- [ ] **Add cross-reference** in spec file pointing to doc
- [ ] **Add cross-reference** in doc file pointing to spec
- [ ] **Update parent README** if needed (e.g., `specs/ai-agents/README.md`)
- [ ] **Commit both files together** with descriptive message

### Example:
```bash
# Created files:
specs/business/payment-rules.yaml
docs/business-logic/payment-processing.md

# Updated files:
specs/SPEC_DOC_MAPPING.md

# Commit message:
feat: add payment validation rules

- Added payment rules spec in specs/business/payment-rules.yaml
- Documented rules in docs/business-logic/payment-processing.md
- Added mapping to SPEC_DOC_MAPPING.md
```

---

## 🔄 Updating Existing Spec

When modifying an existing specification:

- [ ] **Identify corresponding doc** (check `specs/SPEC_DOC_MAPPING.md`)
- [ ] **Update spec file** with changes
- [ ] **Update doc file** to match spec changes
- [ ] **Verify cross-references** are still accurate
- [ ] **Update "Last Updated"** dates in both files
- [ ] **Regenerate code** if applicable (e.g., `make codegen-openapi`)
- [ ] **Commit both files together** with descriptive message

### Example:
```bash
# Modified files:
specs/api/openapi.json
docs/api/guide.md

# Commit message:
feat: add pagination to user list endpoint

- Updated OpenAPI spec with pagination parameters
- Updated API guide with pagination examples
- Regenerated frontend API types
```

---

## 🗑️ Removing Spec

When removing a specification:

- [ ] **Identify corresponding doc** (check `specs/SPEC_DOC_MAPPING.md`)
- [ ] **Remove or archive spec file**
- [ ] **Remove or archive doc file**
- [ ] **Remove mapping** from `specs/SPEC_DOC_MAPPING.md`
- [ ] **Update parent READMEs** if needed
- [ ] **Add ADR** if removing significant spec (in `docs/architecture/adr/`)
- [ ] **Commit all changes together** with explanation

---

## ✅ Pre-Commit Review

Before committing changes involving specs:

- [ ] Spec file is accurate and complete
- [ ] Doc file explains the spec clearly
- [ ] Both files reference each other
- [ ] No contradictions between spec and doc
- [ ] Examples in doc match spec definitions
- [ ] Mapping table updated if needed
- [ ] Related files updated (READMEs, etc.)

---

## 🔍 Periodic Sync Check

Periodically verify specs and docs are in sync:

- [ ] Review `specs/SPEC_DOC_MAPPING.md` for completeness
- [ ] Check for orphaned specs (spec without doc)
- [ ] Check for orphaned docs (doc without spec)
- [ ] Verify cross-references are not broken
- [ ] Update "Last Updated" dates
- [ ] Fix any inconsistencies found

---

## 🤖 For AI Agents

When you're an AI agent updating specs:

- [ ] Read `specs/SPEC_DOC_MAPPING.md` to find corresponding doc
- [ ] Update **both** spec and doc in the same response
- [ ] Maintain consistent terminology between spec and doc
- [ ] Add examples in doc that match spec definitions
- [ ] Mention both files in your summary

---

## 📋 Quick Templates

### Cross-Reference in Spec
```markdown
# [Spec Name]

**Human Documentation**: `docs/[category]/[filename].md`

[spec content]
```

### Cross-Reference in Doc
```markdown
# [Doc Name]

**Source Spec**: `specs/[category]/[filename].{yaml|json|md}`

[doc content]
```

### Commit Message Format
```
<type>: <short description>

- Spec changes: specs/[path]
- Doc changes: docs/[path]
- [Additional details]
```

---

Save this checklist and use it as a template for maintaining spec-doc sync!
