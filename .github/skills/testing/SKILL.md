---
name: testing
description: Test requirements, mock policies, and testing strategies
---

# Testing Skill

## Core Rule

**Specs MUST include test cases**

When defining features: include test cases in the spec  
When implementing: use spec test cases as guidance  
When validating: verify against spec test cases

---

## Mock Policy

### When to Mock (Only For):
- External APIs (payment gateways, third-party services)
- Time/date dependencies (time-sensitive logic)
- Random number generation (specific scenarios)

### When to Use Real Implementations:
- Database interactions
- Business logic
- Service collaborations
- Domain models

**Why**: Real tests catch more issues and validate actual behavior

---

## Test Organization

**Frontend**:
- Unit: Component behavior, helpers, hooks
- Integration: Multi-component workflows
- Location: `__tests__/` directory

**Backend**:
- Feature: Complete API endpoint flows (preferred)
- Unit: Individual methods
- Location: `tests/` directory

---

## Coverage Expectations

- Critical business logic: 80%+
- API endpoints: 100% happy path + error cases
- Validation logic: 100%
- Helpers/utilities: 70%+

---

## Running Tests

```bash
# Frontend
pnpm run test                    # Run tests
pnpm run test:watch             # Watch mode

# Backend
mise ft               # Run all tests
```

---

## Alert Testing

Since alerts are core to the product:
- Test each trigger condition
- Test alert generation logic
- Test suggested actions logic
- Test email delivery (can mock SendGrid)
- Use real database for progress calculations

**Reference alert test cases**: `docs/business-logic/prototype-strategy.md`

---

## Get More Details

- Full testing policy: `specs/ai-agents/guidelines.md` (Testing section)
- Alert examples: `docs/business-logic/prototype-strategy.md`
