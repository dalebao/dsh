# Skill: Completion Report

Generate when ExecPlan completes (COMPLETED), blocks (BLOCKED), or is interrupted (PARTIAL).

## Report Template

```
## Completion Report: [Title]

### Summary
- Status: COMPLETED / BLOCKED / PARTIAL
- Task Goal: [from ExecPlan]
- Relationship to Core Goal: [from ExecPlan]

### Quality Gates
| Gate | Status |
|---|---|
| All verification layers pass | PASS/FAIL |
| No placeholder/todo content | PASS/FAIL |
| Docs updated to reflect changes | PASS/FAIL/SKIP |
| Architecture invariants satisfied | PASS/FAIL |
| ExecPlan acceptance criteria all met | PASS/FAIL |
| ExecPlan evidence log complete | PASS/FAIL |
| Task Goal achieved | PASS/FAIL |

### Changes
| File | Action | Summary |
|---|---|---|
| [path] | [add/modify/delete] | [what and why] |

### Risk Assessment
- Severity: LOW / MEDIUM / HIGH
- Known issues:
- Recommendation: APPROVE / NEEDS_FIX / REDESIGN

### Handoff
- Next step:
- Follow-up needed:
```

## Output

Write report to `.harness/execplan/active/[plan]-report.md`. Present as message to human.
