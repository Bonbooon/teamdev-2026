# Alert System Specification

**Last Updated:** 2026/03/04

---

## 8 Alert Categories

The app monitors teams and sends alerts across these categories:

1. **Project Progress Delays** - Overall project timeline threats
2. **Individual Task Delays** - Single task falling behind
3. **Workload Overload** - Too much work for available capacity
4. **Communication Gaps** - Information/decision stalls
5. **Key Person Absence** - Critical person unavailable
6. **Task Dependency Blocking** - Work waiting on upstream
7. **Decision Paralysis** - Decisions not being made
8. **Buffer Depletion** - Schedule flexibility running out

---

## Alert Severity Levels

### 🟡 Yellow Alert
- **Intent**: Early warning, allows preventive action
- **User Experience**: Email notification with context
- **Suggested Actions**: Prioritization, decomposition, resource adjustment
- **When**: Early signs of potential delay

### 🔴 Red Alert
- **Intent**: Critical, immediate action needed
- **User Experience**: Urgent email with recovery options
- **Suggested Actions**: Emergency meetings, scope reduction, deadline renegotiation
- **When**: Delay is now inevitable without action

---

## Implementation Pattern

1. **Collect Data** - Progress, timeline, workload, dependencies
2. **Check Trigger Conditions** - Match against defined rules
3. **Determine Severity** - Yellow or Red based on conditions
4. **Generate Suggested Actions** - 2-3 relevant next steps
5. **Send Alert** - Email via SendGrid with context and actions

---

## Configuration

- ✅ Dev team configures all triggers (not PM customizable in Phase 1)
- ✅ Triggers are configuration-driven based on specific conditions
- ✅ Alerts include supporting data to justify the alert
- ✅ Each alert includes 2-3 actionable suggestions
- ❌ No alert spam - only send when trigger conditions genuinely met

---

## Key Principles

- Alerts should **prevent** delays, not react to them
- Yellow alerts give PMs time to take **preventive action**
- Red alerts focus on **recovery** and damage control
- Suggested actions must be **context-specific** and **actionable**
- Alerts include **data evidence** supporting the alert

---

## Detailed Trigger & Action Definitions

See `docs/business-logic/prototype-strategy.md` for complete specifications including:
- Specific trigger conditions for each of the 8 categories
- Precise suggested actions for each severity level
- Implementation examples
- Business logic rationale

---

## Testing Alerts

All alerts must be tested with:
- [ ] Each trigger condition verified
- [ ] Alert generation logic validated
- [ ] Suggested actions assignment verified
- [ ] Email content tested (can mock SendGrid)
- [ ] Yellow/Red transition logic verified
- [ ] No false positives

---

## Notes

- Alerts are core to Phase 1 MVP - they differentiate us from other tools
- Alert accuracy directly impacts PM trust and usefulness
- Alert triggers should evolve based on actual team feedback
- Phase 2 may include PM customization based on Phase 1 learnings
