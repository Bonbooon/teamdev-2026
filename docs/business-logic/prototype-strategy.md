# Prototype Strategy: Motivation Cloud Teamwork

**Last Updated:** 2026/03/04

---

## Discovery Insights from PO Inquiries

### First 2 PO Inquiries (Completed)

Through our first 2 inquiries to the Product Owner, we discovered:

#### Core Insight: Preventing Project Delays

- **The Real Problem:** Despite having many excellent tools available (GitHub, Jira, Trello, etc.), most software teams cannot complete projects on time and face delays
- **Competitive Opportunity:** Most existing tools focus on *productivity* or *motivation*, not both
- **Our Unique Value:** MCT must help teams stay on schedule when other tools fail to

#### Paradigm: WANT Features are the Difference

- **MUST Features** = Bare minimum baseline features
- **WANT Features** = What actually enables teams to never miss deadlines
- **Strategic Focus:** WANT features are where we differentiate and solve the real problem

---

## First Prototype: MVP Strategy

### Primary User Focus: Project Managers

**Why Project Managers?**
- They have the most context over managing projects' progress
- They have interest/discretion in preventing delays
- They make the decisions on what to do next
- They are typically overlooked by existing tools that focus on individual contributors

**Supporting Roles:**
- **Team Members:** Use app to create issues, track progress, answer surveys
- **Project Manager/Managers:** Use app as their command center to track status and progress

### What Project Managers Need

**Core Problem We Solve for PMs:**
1. **Visibility:** Know if a project is about to delay
2. **Actionability:** Know what to do next when issues arise

---

## Prototype Features

### Feature 1: Alert & Next-Action System (WANT Feature)

**Purpose:** Enable project managers to respond proactively before delays become critical.

**Implementation Approach:**
- Set triggers for certain events
- Send alerts via mail delivery service (e.g., SendGrid)

**Alert Types:**

1. **Yellow Alert:** "Project might get delay at this rate"
   - Early warning system
   - Allows preventive action
   - Time for course correction

2. **Red Alert:** "Project is in delay and we need to do something now"
   - Critical status
   - Requires immediate action
   - Paired with suggested next steps

**User Experience:**
- PMs receive email notifications
- Alerts include context and suggested actions
- System helps PMs decide what to do next

---

### Feature 2: SMART-Style Issue Templates (WANT Feature)

**Purpose:** Enable team members to precisely track the progress of their work so that PMs can accurately predict delays.

**Implementation Approach:**
- Provide issue templates following SMART principles
- Ensure clarity and measurability in task definitions

**SMART Criteria Applied:**
- **Specific:** Clear description of what needs to be done
- **Measurable:** Defined completion criteria
- **Achievable:** Realistic scope
- **Relevant:** Aligned with project goals
- **Time-bound:** Clear deadline and milestones

**Benefits:**
- Reduces ambiguity in task definitions
- Enables accurate progress tracking
- Helps PMs predict delays based on actual progress vs. timeline

---

### Feature 3: GitHub Actions Integration (WANT Feature)

**Purpose:** Automatically link issue progress to actual development work for real-time visibility.

**Implementation Approach:**
- Connect MCT to GitHub Actions
- Sync issue progress with commit logs from branches

**Integration Flow:**
1. Issue created with SMART template in MCT
2. Developer works on feature branch in GitHub
3. Commits to branch automatically update issue status
4. Commit logs reflect progress
5. PMs see real-time progress without manual updates

**Benefits:**
- Eliminates manual progress updates
- Reduces friction for developers
- Gives PMs accurate, real-time progress data
- Enables more accurate delay prediction

---

## Prototype Scope & Priorities

### What We're Building (MVP)

**Priority 1 (Core):**
- SMART-style issue templates
- Basic progress tracking
- GitHub Actions integration for commit-based updates (deferred to Phase 2 per ADR 0008)

**Priority 2 (Alert System):**
- Yellow/Red alert triggers
- Email notifications via SendGrid
- Suggested next actions for project managers

**Priority 3 (Nice-to-Have):**
- Advanced analytics
- Historical trend analysis
- Team motivation features (Phase 2)

### What We're NOT Building Yet

- Full team motivation/engagement features (Phase 2)
- Advanced condition tracking
- Detailed profile/relationship features
- Role design features (Phase 2)

---

## Validation & Success Metrics

### Success for First Prototype

**For Project Managers:**
1. Can see at-a-glance if project is on track
2. Receives early alerts before delays occur
3. Gets suggested actions for how to recover

**For Team Members:**
1. Can quickly create well-formed issues using templates
2. Progress tracking is mostly automatic (via GitHub)
3. Minimal additional overhead vs. current workflow

**For Product Owner:**
1. Demonstrates understanding of the real problem (delays despite tools)
2. Shows focus on WANT features (alerts & automation) vs. MUST features (templates alone)
3. Proves value by helping our own team stay on schedule

---

## PO Inquiry Responses (Questions 3-4)

### Question 1: How should alert triggers be configured?

**Answer:** 
- **Initial Phase:** Development team configures all triggers and alerts
- **No customization for PMs yet** - All thresholds and rules are set by the dev team
- **Iterative approach:** This will change based on user feedback and insights from dogfooding
- **Future consideration:** After understanding actual usage patterns, we may allow PM customization

---

### Question 2: What should "suggested next actions" look like?

**Answer:** See detailed examples below. Actions vary by alert type and severity:

**Key principles for next actions:**
- **For Yellow Alerts:** Preventive/corrective suggestions (prioritization, task decomposition, resource adjustment)
- **For Red Alerts:** Immediate recovery suggestions (emergency meetings, scope reduction, deadline negotiation)
- **Actions should be:**
  - Context-aware (based on specific trigger)
  - Actionable (clear steps PMs can take)
  - Ranked by priority and feasibility
  - Include both quick fixes and medium-term solutions

**Example action categories:**
- Prioritization adjustments
- Task decomposition/restructuring
- Resource reallocation suggestions
- Scope reduction simulations
- Deadline negotiation proposals
- Escalation/meeting setup
- Dependency resolution strategies

See detailed alert examples in "Alert Trigger & Action Examples" section below.

---

### Question 3: Should the system predict delays based on velocity?

**Answer:** Yes, incorporated into trigger logic

**Prediction approach:**
- Use historical velocity (actual completion rate vs. planned rate)
- Compare current progress timeline against remaining work
- Yellow alert when: At 50% of timeline but less than 50% of work complete
- Red alert when: Completion projected beyond deadline

See specific trigger examples in "Alert Trigger & Action Examples" section.

---

### Question 4: Phase 2 Roadmap - When should motivation features be introduced?

**Answer:** Phase 2 (After prototype validation)

**Phase 2 Approach:**
- **Focus:** Pulse surveys to measure team motivation and psychological safety
- **Metrics collected:**
  - "How comfortable do you feel asking your team questions?" (Psychological safety)
  - "What career path do you envision?" (Career motivation)
  - "Do you feel hesitant to ask for help?" (Team support perception)
  - And other team health metrics

**Answer Types:**
1. **Numeric Scale:** 1-5 rating system
2. **Multiple Choice:** Select from options like ["Never", "Sometimes", "Always"]

**Timing:** Introduce after prototype validation demonstrates delay-prevention value

---

### Question 5: Integration priorities - GitHub vs. other tools?

**Answer:** GitHub Actions priority, but lower priority overall

**Approach:**
- **Primary focus:** Test GitHub Actions integration with real team usage
- **Observe user reactions:** Gather feedback on how developers react to automatic progress updates
- **Not rushing:** This feature is at lower priority - focus first on alerts and issue templates
- **Future:** Based on Phase 1 learnings, may expand to other tools (GitLab, Bitbucket, etc.)

---

## Alert Trigger & Action Examples

Reference guide for alert trigger configuration and suggested actions. All alerts follow this pattern:

**🟡 Yellow Alert (Yellow):** Early warning - allows preventive action  
**🔴 Red Alert (Red):** Critical - requires immediate action

---

### Category 1: Project Progress Delay Alerts (Overall Project)

#### 🟡 Yellow - Project might get delay at this rate

**Triggers:**
- At 50% of timeline but less than 50% of tasks completed
- Planned completion lagging for 3+ consecutive days
- Critical path tasks (dependencies) starting to delay

**Suggested Actions:**
- Propose revised estimates
- Auto-display top 3 delayed tasks
- Suggest task decomposition options
- Recalculate schedule buffer
- Show scope reduction simulation

---

#### 🔴 Red - Project is in delay, immediate action needed

**Triggers:**
- Velocity analysis predicts deadline will be missed
- Remaining work exceeds remaining days

**Suggested Actions:**
- Simulate adding additional resources
- Propose new deadline options
- Rebuild priority structure
- Identify tasks to stop/defer immediately

---

### Category 2: Individual Task Progress Alerts

#### 🟡 Yellow - Task progress concerning

**Triggers:**
- More than 50% of planned time spent but less than 50% of task complete
- No progress updates for 3+ days
- One person has too many simultaneous tasks (3+)

**Suggested Actions:**
- Suggest task decomposition
- Auto-ask: "Are you facing any blockers?"
- Light notification to PM

---

#### 🔴 Red - Task delay will block others

**Triggers:**
- Planned time exceeded but task still incomplete
- Other team members waiting on this task
- Multiple rework cycles happening

**Suggested Actions:**
- Suggest reassigning task to another person
- Propose deadline adjustment
- Suggest 1-on-1 meeting to understand blockers

---

### Category 3: Workload Overload Alerts

#### 🟡 Yellow - Workload capacity concern

**Triggers:**
- Weekly planned work exceeds person's available capacity
- Person assigned to multiple simultaneous projects
- New urgent task added

**Suggested Actions:**
- Help prioritize tasks
- Show tasks that can be reassigned
- Suggest work that can be deferred

---

#### 🔴 Red - Overload will definitely cause delays

**Triggers:**
- Clearly impossible to complete workload in available time
- Work concentrating on core team members
- Overtime becoming necessary

**Suggested Actions:**
- Simulate adding team members
- Propose scope reduction
- Suggest deadline adjustment

---

### Category 4: Communication/Information Gaps

#### 🟡 Yellow - Communication stalling

**Triggers:**
- Important documentation not updated recently
- Comments/decisions left unresolved for 2+ days
- Specification not finalized

**Suggested Actions:**
- Reminder: "Let's finalize this decision"
- Clarify who should decide
- Display list of unresolved issues

---

#### 🔴 Red - Information gap blocking work

**Triggers:**
- Work stopped due to missing information
- Rework happening due to miscommunication
- Decision maker unavailable

**Suggested Actions:**
- Propose emergency decision-making meeting
- Suggest proceeding with temporary rules

---

### Category 5: Key Person Absence Impact

#### 🟡 Yellow - Key person absence may cause issues

**Triggers:**
- Key person taking time off soon
- Tasks dependent on this person exist
- No backup person identified

**Suggested Actions:**
- Set backup person
- Promote knowledge transfer
- Front-load related task deadlines

---

#### 🔴 Red - Key person absence risks complete stoppage

**Triggers:**
- Critical person unavailable near deadline
- Multiple tasks waiting on this person
- No disaster recovery plan in place

**Suggested Actions:**
- Immediately assign backup
- Propose releasing postponed features
- Establish emergency procedures

---

### Category 6: Task Dependency Blocking

#### 🟡 Yellow - Dependency causing delays

**Triggers:**
- Critical path task blocked on upstream completion
- Task in "waiting" state for 2+ days
- Downstream person idle due to waiting

**Suggested Actions:**
- Show alternative tasks that can start
- Raise priority of blocking task
- Suggest task decomposition

---

#### 🔴 Red - Dependency causing cascading delays

**Triggers:**
- Critical workflow component blocked
- 2+ people in waiting state
- Deadline-critical task stopped

**Suggested Actions:**
- Escalate blocking task to highest priority
- Suggest person reassignment
- Propose temporary scope simplification

---

### Category 7: Decision Paralysis

#### 🟡 Yellow - Decision delayed

**Triggers:**
- Items "awaiting approval" for several days
- Work proceeding with ambiguous requirements

**Suggested Actions:**
- Clarify decision owner
- Display unresolved items

---

#### 🔴 Red - Lack of decision blocking work

**Triggers:**
- Work completely stopped waiting for decision
- Miscommunication causing rework
- Decision maker unavailable

**Suggested Actions:**
- Propose emergency decision meeting
- Provide temporary rules for proceeding

---

### Category 8: Buffer Depletion

#### 🟡 Yellow - Schedule buffer running low

**Triggers:**
- Behind schedule but adjustments still possible
- More than 50% of buffer consumed

**Suggested Actions:**
- Propose lightweight scope reduction
- Reorder priority list

---

#### 🔴 Red - Zero buffer remaining

**Triggers:**
- No schedule flexibility left
- One day delay = deadline miss

**Suggested Actions:**
- Negotiate new deadline
- Begin resource increase planning

---

## Notes

- This prototype focuses on solving the **delay prevention problem** that most tools miss
- WANT features are what differentiate us - focus on alerts and automation
- Project managers are the primary power users - all other features support them
- Real-time data from GitHub reduces manual overhead on teams
- Success = helping our own team (dogfooding) stay on schedule
- Alert triggers are based on actual team experience and Japanese project management best practices
