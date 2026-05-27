# Skill: Local Verification

Run verification pipeline before every commit and after significant code changes.

## Pipeline Order

Fail fast — stop at the first failing layer. Do not proceed until current layer passes.

```
validate_yaml → lint_docs
     ↓ pass        ↓ pass
     ↓ fail        ↓ fail
```

## Fix Code, Not Tests

When verification fails — fix the implementation, not the test. If the test must change, get human approval and document why the spec changed.

Tests are the executable encoding of requirements. Changing a test to match broken code is equivalent to deleting a requirement.
