# Dale's Harness (dsh)

> A file-based infrastructure that makes AI agent behavior in software projects **observable, verifiable, and systematically improvable** — without any runtime, plugin, or platform dependency.

---

## The Problem

An AI agent receives a prompt → thinks → produces code. What happened in between?

- **Which decisions were made?** The agent chose A over B — why?
- **Was the problem analyzed before coding?** Or did it jump straight to implementation?
- **Was the output verified?** Or assumed correct because it "looks right"?
- **Can the next agent pick up where this one left off?** Or does everything restart from scratch?

Without structure, AI coding is a black box. You see input and output; everything inside is guesswork.

Harness Engineering is the answer: **a state machine, not a prompt; a constraint system, not a guideline; an evidence trail, not a chat log.**

---

## Core Philosophy

### 1. State Machines Over Prompts

A prompt is advice. The agent can follow it, ignore it, or reinterpret it. A state machine is **structure** — it defines what actions are permitted at each point, and violations are detectable.

dsh defines seven states:

```
IDLE → ANALYZE → PLAN → PENDING → EXECUTE → COMPLETE
                ↑         ↓         ↓
                └──退回修改──┘     BLOCKED
```

Every agent response begins with `[STATE: <state>]`. This isn't decorative — it makes the workflow machine-parsable. A compliance check can scan an entire session transcript and verify that every transition was legal.

**Key transitions that prevent common failure modes:**

- `EXECUTE → ANALYZE` — execution reveals the problem was misunderstood. Go back and re-analyze.
- `EXECUTE → PLAN` — the plan needs adjustment, but understanding is correct. Go back and re-plan.
- `COMPLETE → EXECUTE` — the Completion Report was rejected or verification failed. Not done yet.
- `BLOCKED → ANALYZE` — after a human decision, try again with a new approach.

Without these feedback paths, the agent would have to either proceed with a flawed plan or artificially trigger BLOCKED. Both are wrong. (This was found and fixed as Problem 3 in the self-validation loop — see below.)

### 2. Constraints Must Be Machine-Checkable

Every constraint in `.harness/constraints.yaml` has a `check` field — a concrete instruction that an agent can execute:

```yaml
- id: human-gate
  check: "ExecPlan MUST include a 'Human Approval' section with approver name and timestamp"

- id: session-start-mandatory
  check: "First response MUST contain 6 specific output lines, not just the summary"
```

A constraint without a checkpoint is a guideline. A guideline is optional. dsh does not ship optional rules.

### 3. Proposals Must Be Separate From Execution

This is the most frequently violated rule in practice, and the most important one.

An agent must not write a plan and execute it in the same response. Why? Because a plan that "looks reasonable" will be executed automatically — and the human never gets to say "wait, that's wrong."

The separation forces a **human gate**: proposal → presented → approved/rejected → execution. This extends the timeline by exactly one approval round. The cost is minor. The cost of skipping it is an agent committing to a flawed approach without oversight.

### 4. Every Human Request Is an ExecPlan

The original rule said "write an ExecPlan if the task is ambiguous." This was a mistake — it gave the agent the authority to decide what counts as "ambiguous." The agent always chose "not ambiguous" and skipped the plan.

The corrected rule: **every human request is an ExecPlan.** There are exactly two paths:

```
request → no active EP → create new EP → PENDING → approved → EXECUTE
request → active EP (approved) in scope → resume EXECUTE
```

No third path. No "this task is small enough to skip." No judgment call.

### 5. Defense in Depth

dsh operates at three layers because any single layer will fail:

| Layer | What catches | Failure mode |
|-------|-------------|--------------|
| Agent protocol (`AGENTS.md`) | Agent behavior during a session | Agent can skip/ignore |
| Pre-commit hook (`hooks.md`) | Code committed without an approved plan | Only catches at commit time |
| CI check (GitHub Actions) | PRs merged without compliance | Only runs in CI |

The hook is the most important — it's the only layer the agent cannot bypass. When `git commit` fails because no ExecPlan exists, the agent has no choice but to create one.

---

## How the Template Embodies Each Pillar

| Pillar | File | Mechanism |
|--------|------|-----------|
| State machine | `AGENTS.md` | 17 MUST constraints + state transition table + `[STATE]` header |
| Checkable constraints | `.harness/constraints.yaml` | 22 invariants + 2 guardrails, each with a `check` field |
| Proposal/execution split | `AGENTS.md` constraint 8 | "A single response MUST NOT contain both a novel proposal and its implementation" |
| Every request = EP | `AGENTS.md` constraint 5 | Four-branch decision tree (new/resume/pending/out-of-scope) |
| Defense in depth | `.harness/docs/L4_SKILLS/hooks.md` | Pre-commit hook script + CI workflow template |

---

## Architecture

```
your-project/
├── AGENTS.md              ← Entrypoint (must read first)
└── .harness/
    ├── config.yaml        ← Verification pipeline, quality gates
    ├── constraints.yaml   ← Machine-checkable invariants
    │
    ├── execplan/
    │   ├── template.md    ← ExecPlan structure + step granularity spec
    │   └── active/        ← One ExecPlan per active task
    │
    ├── docs/
    │   ├── L1_INDEX.md    ← Topic navigation (start here)
    │   ├── L2_MODULES/    ← Module-level docs
    │   ├── L3_FACTS/      ← Stable facts: build, test, config
    │   └── L4_SKILLS/     ← Executable skill definitions
    │
    ├── recordings/
    │   ├── decisions/     ← Decision Records (DR-*.md)
    │   └── checkpoints/   ← State snapshots
    │
    ├── metrics/           ← Project health definitions
    └── taxonomy.yaml      ← Issue classification
```

### The Three Architecture Layers

```
┌──────────────────────────────────────────┐
│           STATE MACHINE LAYER             │
│   AGENTS.md — what state, what's allowed  │
│   Output: [STATE: <state>] per response   │
├──────────────────────────────────────────┤
│           CONSTRAINT LAYER                │
│   constraints.yaml — what's never allowed │
│   Each rule has a machine-checkable check │
├──────────────────────────────────────────┤
│           VERIFICATION LAYER              │
│   config.yaml — what must pass before done│
│   quality_gates — acceptance conditions   │
│   escalation — 3 failures → BLOCKED      │
└──────────────────────────────────────────┘
```

The three layers are independent but interact: the state machine controls *what you can do*, constraints control *what you can't do*, and verification controls *what "done" means*.

---

## The Self-Validation Story

dsh was built by applying itself to its own development. This is not optional — it's constraint 7 ("MUST validate template content by applying it here first").

The validation loop ran as follows:

```
EP-003: Fix 6 workflow problems in the harness
  └─ EP-004: Build a Go CLI tool using a sub-agent, following the harness workflow
       └─ Audit found 5 compliance gaps in the sub-agent:
            • Session Start skipped entirely
            • 9 steps shared a single checkpoint
            • Evidence Log filled after implementation, not before
            • State transitions jumped from ANALYZE directly to COMPLETE
            • Discussion Trace had only 3 rows
            └─ EP-005: All 5 gaps fixed in the template
```

Each gap found in EP-004 was real — the sub-agent was using the same template that dsh ships today. The fixes made the template stricter, which made future agents harder to bypass.

**The problems dsh solves were discovered by using dsh on itself.**

---

## Quick Start

```bash
# 1. Copy dsh into your project
cp -r dsh/* your-project/
cd your-project

# 2. Define core goal in AGENTS.md
# 3. Configure verification pipeline in .harness/config.yaml
# 4. Set build/test commands in .harness/docs/L3_FACTS/build_test.md
# 5. Install the pre-commit hook (see hooks.md)
# 6. Open with a Kilo-compatible agent
```

Your agent will run **Session Start** automatically on first load, then proceed through ANALYZE → PLAN → wait for your approval → EXECUTE → COMPLETE.

---

## The dsh Guarantee

Projects using dsh get three things that ad-hoc agent workflows cannot provide:

1. **Traceability** — Every decision, rejection, and trade-off is recorded in a structured format (Decision Records + Discussion Trace). Any agent can reconstruct the reasoning without re-reading the conversation.

2. **Resumability** — After any interruption, a new agent reads the ExecPlan's Evidence Log and Context Summary, and continues from the last verified step. No context loss, no repeated work.

3. **Verifiable correctness** — Every step has a machine-checkable verification. The Completion Report proves that all quality gates passed. "It's done" is not a claim — it's a set of passing checks.

---

*Dale's Harness v0.1.0 — Built via self-validation. No runtime required. Everything is readable markdown and YAML.*
