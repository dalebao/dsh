# Skill: Decision Record

## When to create a DR

| Condition | Create DR? |
|---|---|
| Obvious choice, single right answer | No |
| Trade-off between two valid options | Yes — record rationale |
| Failed attempt (tried X, hit blocker, switched to Y) | Yes — prevent repeat |
| Human judgment call | Yes — record context |
| Trivial choice (naming, minor refactor) | No |

## DR format (`.harness/recordings/decisions/DR-NNN.md`)

```
# DR-NNN: [title]

## Context
What triggered this decision?

## Decision
What was chosen?

## Alternatives
What else was considered and why rejected?

## Rationale
Why this is right given the constraints.

## Trace
- ExecPlan: [link]
- Outcome: [validated / pending / superseded]
```

## How to trace

```bash
grep "DR-NNN" .harness/execplan/ -r      # find all references
cat .harness/recordings/decisions/DR-NNN.md  # read full DR
```
