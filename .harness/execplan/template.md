# ExecPlan: [Title]

## Metadata

- **Phase:** [0-7]
- **Phase Selection:** [bug | medium | large]
- **Self-contained:** [yes | no]
- **Plan location:** [proposal/ | active/ | completed/]
- **Created:** [date]
- **Last updated:** [date]

---

## Phase 0-2: Plan

> **谁写:** Agent | **位置:** `proposal/` | **完成后进入 Phase 3**

### Goal Alignment

#### Task Goal
The immediate objective of this specific task.

#### Relationship to Core Goal
How this task relates to the project-level Core Goal (from AGENTS.md):
- **directly-serves**: Directly advances the core goal.
- **enables**: Creates conditions the core goal depends on.
- **prerequisite**: Must be done before core-goal work can proceed.
- **maintenance**: Keeping existing systems healthy.
- **exploration**: Investigative — outcome may or may not serve.
- **other**: (explain)

#### Core Goal
Reference only — from AGENTS.md:

### Discussion Trace

| Turn | Topic | Analysis | Conclusion | Rejected Alternatives |
|---|---|---|---|---|
| 1 | | | | |

Add a row for every analysis turn that produces a conclusion or rejects an alternative. Each row records what was discussed, the reasoning, the decision, and what was ruled out. Do not merge multiple turns into a single row. This is the reasoning trail: new agents read this to understand how decisions were reached without re-reading conversation history.

### Scope

- **In scope:**
- **Out of scope:**
- **Success criteria** (observable, binary):

### Execution Milestones

Steps grouped by milestone. Each step MUST be atomic — one command, one expected outcome, one verification.

#### Milestone [letter]: [title]

1. [step description]
   - Command: [shell command(s) to execute]
   - Expected outcome: [what success looks like]
   - Verification: [MUST produce machine-checkable pass/fail. exit 0 = pass, non-zero = fail.]

2. ...

---

## Phase 3: Review Gate

> **硬性暂停区。** 禁止越过此门进入 Phase 4。提案与实施必须在不同 agent 轮次中。

### Human Approval

- **Presented to:** [human name]
- **Presenter's recommendation:** [why this plan should be approved]
- **Approval status:** [pending | approved | rejected]
- **Approved at:** [timestamp]
- **Approver notes:** [feedback, concerns, modifications requested]

---

## Phase 4: Execution

> **谁做:** Agent | **位置:** `active/` | **完成后进入 Phase 4.5**

### Evidence Log

| Step | Status | Evidence | Checkpoint | Notes |
|---|---|---|---|---|
| M1 | [pending/done/failed] | [link/file] | [ref] | |
| M2 | | | | |

Every step MUST have a verification that exits 0 on pass and non-zero on fail. Run verification before marking the step done. Turn numbers in Notes link back to Discussion Trace.

### Checkpoints & Context

- **Git branch:**
- **Modified files:**
- **Running processes / pending tests:**
- **Session summary:** Dense paragraph for agent handoff — what was completed, key assumptions validated, trickiest remaining issue, failed approaches not to repeat.
- **Last checkpoint at:**

> Checkpoints are created at significant boundaries and before session end. Named checkpoints referenceable from Evidence Log.

---

## Phase 4.5: Audit

> **谁做:** Independent reviewer (agent or human) | **不跳过**

### Audit Findings

- **Auditor:** [agent-id / human name]
- **Findings:**
- **Recommendations:**
- **Blocking issues:** (if any, prevents Phase 5-7)

---

## Phase 5-7: Close

> **谁做:** Agent | **位置:** `completed/` | **终态**

### Decisions

- **DR-XXX:** [one-line title — trace via `grep "DR-XXX" . -r`]
- **Doc update required:** Yes/No — if Yes, list affected files and sync status.

Full Decision Records live in `.harness/recordings/decisions/DR-*.md` — created only for significant trade-offs, failed attempts, or human judgment calls.

### Completion Summary

- **Summary of achievements:**
- **Known risks / unresolved:**
- **Next recommended action:**
- **For resuming agent:** Start from step [N], re-run verification for step [M] first, then proceed.

### Acceptance

- [ ] Task Goal achieved
- [ ] Relationship to Core Goal still valid (re-check if execution changed scope)
- [ ] All milestones completed
- [ ] All evidence recorded with verification results
- [ ] Docs updated to reflect changes
- [ ] All required quality gates pass (see config.yaml → quality_gates)
- [ ] This ExecPlan updated with final evidence and decisions
- [ ] Completion Report generated (see `.harness/docs/L4_SKILLS/report.md`)
- [ ] Final human review requested
- [ ] Phase-specific criteria:
  - [bug] — (N/A or per-project)
  - [medium] — proposal/ → active/ → completed/ cycle complete
  - [large] — Audit performed, DRs recorded, full verification pipeline passed
