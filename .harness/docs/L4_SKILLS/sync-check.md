# Skill: Cross-Reference Sync

When `template/.harness/` or `.harness/` structure changes, the other must be updated to match.

## What to check

- Does `template/.harness/config.yaml` still mirror the schema of `.harness/config.yaml`?
- Does `template/.harness/constraints.yaml` have the same structure as `.harness/constraints.yaml`? (Values will differ, but sections must match)
- Are there files in one but not the other? (e.g., a new doc layer, a new metric category)

## Principles

- `.harness/` is always the "live" version — it validates the template design
- `template/` is the "clean" version — it should be the minimal, well-documented abstraction
- When adding a feature to `.harness/`, first add a generalized version to `template/`, then specialize in `.harness/`
