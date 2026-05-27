# Module: template/

**Purpose:** The primary output artifact. A reusable harness directory structure that can be copied into any target project to bootstrap harness engineering.

## Structure

```
template/
├── AGENTS.md                    # L0 entrypoint for target projects
└── .harness/
    ├── config.yaml              # Harness configuration (target project edits)
    ├── constraints.yaml         # Architecture invariants (target project edits)
    ├── docs/
    │   ├── L1_INDEX.md          # Topic navigation template
    │   ├── L2_MODULES/          # Module entrypoints (target project fills)
    │   ├── L3_FACTS/            # Stable facts (target project fills)
    │   └── L4_SKILLS/           # Reusable skill definitions
    ├── execplan/
    │   ├── template.md          # ExecPlan template (stable)
    │   ├── proposal/            # ExecPlan drafts
    │   ├── active/              # Approved ExecPlans in progress
    │   └── completed/           # Finished ExecPlans
    ├── recordings/              # Protocol cassette storage
    └── scripts/                 # Validation and utility scripts
```

## Conventions

- All files use platform-agnostic paths (no `.kilo/`, `.cursor/`, `.vscode/`)
- `template/AGENTS.md` is the thin routing entrypoint — no knowledge depth
- ExecPlan template in `template/.harness/execplan/template.md` is the canonical form
- Metrics and taxonomy in template/ are stable baselines — target projects extend, not fork

## Constraints

- No file in template/ may reference paths that escape `template/`
- No platform-specific config directories inside template/
- template/AGENTS.md must remain thin — deeper knowledge lives in `.harness/docs/`
