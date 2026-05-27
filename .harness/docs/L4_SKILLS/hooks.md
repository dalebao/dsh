# Skill: Pre-commit Hook Design

Three-layer defense system. Each layer is configured in `.harness/config.yaml`.

## L0 — General Hygiene

| Check | Implementation |
|---|---|
| File size limit | `find . -size +1M` |
| Merge conflict markers | `rg '<<<<<<<\|=======\|>>>>>>>'` |
| Secret/key leakage | `trufflehog` or `gitleaks` |
| Large binary files | `git diff --cached --name-only` + extension filter |

## L2 — AI-Specific

| Check | Implementation |
|---|---|
| Placeholder detection | `rg 'TODO\|FIXME\|HACK\|\[placeholder\]'` |
| ExecPlan completeness | Check acceptance criteria filled |

## Error message format

```
[HOOK L0] [FAIL] <check-name>: <file>:<line>
  → Exact issue
  → Suggested fix command
```

## Philosophy

- 报错即指导 — Every rejection includes the fix command
- Self-healing — Agent reads error, fixes code, re-runs without human
- No silent passing — Every hook produces visible output
