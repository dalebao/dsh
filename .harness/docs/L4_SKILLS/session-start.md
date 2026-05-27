# Skill: Session Start

**MUST run once at the beginning of every new agent session before entering ANALYZE.**

## Execution Steps

Each step below is a concrete action, not a suggestion. Run every step in order.

### Step 1 — Read Core Goal

Read `AGENTS.md` → CORE GOAL section.

**Output:** Restate the core goal in one sentence.
```
Core goal: [one-sentence restatement]
```

### Step 2 — Read Constraints

Read `.harness/constraints.yaml` — all invariants and guardrails.

**Output:** Count and list invariant IDs.
```
Constraints loaded: [N] invariants, [M] guardrails
Key invariants for this session: [ids most relevant to current task]
```

### Step 3 — Read Config

Read `.harness/config.yaml` — harness configuration.

**Output:**
```
Config loaded: verification layers = [...]
```

### Step 4 — Check for Active ExecPlans

```
ls .harness/execplan/active/
```

**Decision:**
- If files exist with approval_status=approved → **this session MUST resume the active ExecPlan**. Do NOT create a new one unless explicitly instructed.
- If no files → proceed to ANALYZE for new task analysis.

**Output:**
```
Active ExecPlans: [none / EP-XXX (approved/pending/rejected)]
Action: [resume / create new / wait for human]
```

### Step 5 — Run Doc-Code Consistency Scan (if applicable)

Only if: entering from a previous session, human requested, or agent suspects drift.

**Command:**
```
Run config.yaml verification.layers → lint_docs
```

**Output:**
```
Doc-code scan: [passed / N inconsistencies found]
```

### Step 6 — Enter ANALYZE

## Verification

After completing all steps, the session MUST produce ALL of these lines in the first agent response (each corresponds to a Step 1-5 output):

```
Core goal: [one-sentence restatement]
Constraints loaded: [N] invariants, [M] guardrails
Config loaded: verification layers = [...]
Active ExecPlans: [none / EP-XXX (approved/pending/rejected)]
Doc-code scan: [passed / N inconsistencies found]
[SESSION START] Goal: ... | Active ExecPlan: ... | Doc scan: ...
```

If any of these lines are absent, the constraint `session-start-mandatory` is violated. The summary line alone is insufficient — all five intermediate outputs plus the final summary are required.

## What Not to Do

- Do NOT skip steps because "I already know this project."
- Do NOT combine Step 4 into a generic "I checked" — you must run the actual `ls` command.
- Do NOT enter ANALYZE before Step 6.
