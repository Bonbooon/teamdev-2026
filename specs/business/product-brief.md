# Product Brief: Propass

**Last Updated:** 2026/03/04

---

## Discovery Insights from PO Inquiries

**See also:** `docs/business-logic/prototype-strategy.md` for our prototype strategy based on PO learnings

### Key Learnings (From First 2 PO Inquiries - Completed)

- **Core Problem:** Despite having many excellent tools (GitHub, Jira, Trello, etc.), most software teams cannot complete projects on time and face delays
- **Our Differentiation:** Tools tackle productivity OR motivation, not both. We solve BOTH + prevent delays
- **Strategic Insight:** MUST features are baseline; WANT features enable teams to never miss deadlines
- **Primary User:** Project managers are the overlooked power users who need visibility and actionability

---

## 1. Company Background & Core Philosophy

### Client: Link and Motivation Group

**Mission:** To realize a meaningful society by providing opportunities for transformation to organizations and individuals through "Motivation Engineering".

**Definition of a "Good Company":** A company characterized by high **"Engagement"**.

- Engagement is the degree of "mutual love" (相思相愛) between the company and its employees
- A state where employees empathize with the company's philosophy and goals
- Employees have a proactive, voluntary desire to contribute to the company

---

## 2. The Macro Problem

### Japan's Productivity Crisis

**Labor Productivity:**

- Japan's labor productivity is currently the **lowest among the G7 nations**

**Employee Engagement Statistics:**

- Only **5%** of Japanese employees are considered "enthusiastic" (highly engaged)
- Japan ranks **145th out of 145 countries** surveyed by Gallup

**Societal Issues:**

- "Working reluctantly" has become the norm
- Prevalent issues like the "Sazae-san syndrome" (Monday blues)
- Low motivation combined with strangely low turnover rate
- Organizations stuck in prolonged state of poor productivity
- "Working is painful" has become the common societal expectation

---

## 3. Project Overview & Objective

### Application Identity

**Name:** Propass

**Objective:** To develop an application that simultaneously enhances both a team's **Productivity** and **Motivation**.

### Role Structure

- **Developers:** POSSE hackathon participants (us)
- **Client/Requester:** Link and Motivation Group
- **End-Users (Customers):** Companies and business leaders struggling with organizational and team management

---

## 4. Target Audience & Market Positioning

### Target Audience

**Primary Target:** **Software development teams**

- Teams where Engineers, Product Managers, and Designers collaborate
- Trust-building and close collaboration are extremely important
- Any company size (both in-house and contract development)

### The "Dogfooding" Concept

**CRITICAL:** The development team must treat **their own team as the core target audience**.

- Adopt a "dogfooding" mindset
- Use yourselves as guinea pigs
- Build an application that is absolutely indispensable for your own team's success

### Market Positioning

**No direct competitors** that successfully tackle _both_ productivity and motivation.

**Productivity Competitors:**

- Asana
- JIRA
- Trello
- Wrike

**Motivation Competitors:**

- 15Five
- Geppo
- Unipos

---

## 5. Specific Pain Points to Solve

When team operations fail and projects don't go as planned, the following frequent issues arise:

### Productivity Pain Points

1. **Role divisions are unclear**, causing tasks to fall through the cracks
2. **No one has a clear grasp of progress**, making it impossible to run the PDCA (Plan-Do-Check-Act) cycle
3. **Team members have too many tasks** and operations stall

### Motivation Pain Points

1. **Output drops** due to poor physical condition or declining motivation
2. **Psychological safety is low**, preventing members from focusing deeply on their work
3. **Unseen anxiety and distress** over constant delays and lack of visibility into others' workloads

---

## 6. Core Application Features

The application must be built around **four mandatory functional pillars**:

### Pillar 1: Role Design (Productivity)

**Problem Solved:** Role division becomes vague, and nobody knows who is doing what.

**MUST Requirements:**

- Ability to add and assign roles for each project/task
- A centralized list to confirm who is handling which role

**WANT Requirements:**

- Visibility into the difficulty level of each role

---

### Pillar 2: Progress Management (Productivity)

**Problem Solved:** Project/task progress isn't shared within the team, causing delays in detecting issues and taking corrective action.

**MUST Requirements:**

- Ability to list, update, and manage progress per project/task
- Visual indicators of good/bad progress to easily grasp the current situation

**WANT Requirements:**

- Clear guidance on necessary next steps/actions when a delay is detected

---

### Pillar 3: Condition Tracking (Motivation)

**Problem Solved:** Unawareness of members' motivation states hinders collaboration; delays in noticing poor physical/mental conditions lead to project delays.

**MUST Requirements:**

- Mutual visibility into the physical and psychological conditions of all team members
- Ability to understand the team's overall current state and issues

**WANT Requirements:**

- Visibility into the specific causes of poor conditions and what support is needed

---

### Pillar 4: Mutual Understanding Promotion (Motivation)

**Problem Solved:** Weak relationships make it hard to collaborate with newly joined members; remote work environments lack casual chat, preventing mutual understanding.

**MUST Requirements:**

- Features to view each other's profiles, including work experience, strong areas/skills, and hobbies

**WANT Requirements:**

- Mechanisms or features that help members share personal values and foster deeper friendships

---

## 7. Success Criteria

The application succeeds when it becomes **indispensable** to the development team using it (dogfooding validation), and demonstrates measurable improvements in:

1. **Productivity Metrics:**
   - Clearer role assignments
   - Faster issue detection and resolution
   - Improved task completion rates

2. **Motivation Metrics:**
   - Higher team psychological safety
   - Better awareness of team member conditions
   - Stronger team relationships and mutual understanding

---

## 8. Constraints & Considerations

- Must deliver all 4 pillars (MUST requirements minimum) - but WANT features differentiate us
- Application must be practical for real software development teams
- Balance between productivity features and motivation features
- Consider remote work environments
- Should integrate naturally into existing team workflows
- **MVP Strategy:** See `docs/business-logic/prototype-strategy.md` for focused first-prototype approach
