# Module: .harness/

**Purpose:** This project's own harness machinery. Used to dogfood the template — every constraint, doc convention, and metric defined in `template/` should be applied here first.

## Structure

```
.harness/
├── config.yaml                  # Harness configuration
├── constraints.yaml             # Architecture invariants for this project
├── docs/
│   ├── L1_INDEX.md              # Topic navigation
│   ├── L2_MODULES/              # Module entries (template, harness)
│   ├── L3_FACTS/                # Stable facts
│   └── L4_SKILLS/               # Skill definitions
├── execplan/
│   ├── template.md              # ExecPlan template
│   ├── proposal/                # ExecPlan drafts (awaiting approval)
│   ├── active/                  # Approved ExecPlans in progress
│   └── completed/               # Finished ExecPlans
├── recordings/                  # Protocol cassettes
├── scripts/                     # Validation and utility scripts
└──
```

## Cross-references

- `.harness/` is the consumer; `template/` is the product
- Changes to `template/.harness/` should be reflected in `.harness/` and vice versa
- This project uses the harness template itself — it's the first validation target
