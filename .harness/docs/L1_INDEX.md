# L1 Index — Topic Navigation

| Topic | Location | What you'll find |
|---|---|---|
| Core Goal | `AGENTS.md` (root, top) | Project mission, output, "why this matters" |
| Constraints | `.harness/constraints.yaml` | Architecture invariants, guardrails |
| Quality Gates | `.harness/config.yaml` → quality_gates | Required gates for "done", escalation thresholds |
| Template Design | `.harness/docs/L2_MODULES/template.md` | Template/ module: structure, conventions, constraints |
| Harness Config | `.harness/docs/L2_MODULES/harness.md` | This project's `.harness/` directory conventions |
| Build & Test | `.harness/docs/L3_FACTS/build_test.md` | Verification commands, CI pipeline |
| Configuration | `.harness/docs/L3_FACTS/config.md` | Harness config files, env vars |
| Decision Record | `.harness/docs/L4_SKILLS/decision-log.md` | Lightweight DR format, when to create, tracing |
| Completion Report | `.harness/docs/L4_SKILLS/report.md` | Quality gates, escalation, report template |
| Pre-commit Hooks | `.harness/docs/L4_SKILLS/hooks.md` | L0/L1/L2 hook design, error format, setup |
| Local Verify | `.harness/docs/L4_SKILLS/verify.md` | Verification pipeline: how to run and interpret |
| Checkpoint & Resume | `.harness/docs/L4_SKILLS/checkpoint.md` | Checkpoint creation, resume protocol for agent handoff |
| ExecPlan Creation | `.harness/docs/L4_SKILLS/execplan-create.md` | How to create an ExecPlan when user triggers /plan |
| ExecPlan Template | `.harness/execplan/template.md` | Phase-Annotated ExecPlan document format |
| Session Start | `.harness/docs/L4_SKILLS/session-start.md` | Mandatory pre-analysis checklist for every new session |

**Navigation principle:** Start here, then drill into the layer you need.
