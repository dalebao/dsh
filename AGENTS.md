# AGENTS.md — Harness Entrypoint

## CORE GOAL

*[Describe your project's core goal here. Example:]*
*This project builds a [system/platform/tool] that [solves problem].*

**Output:** *[What this project produces.]*

**Why this matters:** *[The problem it solves and why it matters.]*

> This is the **project-level** core goal. Individual tasks may have their own **Task Goal** — the relationship between them must be explicit (see `.harness/execplan/template.md`).

## WORKFLOW

Every response MUST start with `[STATE: <state>]`. Allowed operations are determined by current state:

```
                       ┌─────────────────┐
                       │     IDLE        │ ← 等待用户输入
                       └────────┬────────┘
                                │ 收到需求
                                ↓
                       ┌─────────────────┐
                       │   ANALYZE       │ ← 轻量分析：读约束 + 检查 active plan
                       └────┬───────┬────┘
                            │       │
                ┌───────────┘       └────────────┐
                ↓                                 ↓
        用户显式要求 ExecPlan               无需 ExecPlan
        (/plan, /dsh_exec_plan)            (讨论/小改动/咨询)
                ↓                                 ↓
       ┌────────────────┐               ┌─────────────────┐
       │ 加载 execplan- │               │   INLINE        │
       │ create skill   │               │   轻量处理      │
       └───────┬────────┘               └────────┬────────┘
               ↓                                 ↓
       ┌──────────────┐                  ┌──────────────┐
       │    PLAN      │                  │    IDLE      │
       └──────┬───────┘                  └──────────────┘
               ↓
       ┌──────────────┐
       │  PENDING     │
       └──────┬───────┘
               ↓
       ┌──────────────┐
       │   EXECUTE    │
       └──────┬───────┘
               ↓
       ┌──────────────┐
       │  COMPLETE    │
       └──────┬───────┘
               ↓
       ┌──────────────┐
       │    IDLE      │
       └──────────────┘
  (BLOCKED / 退回修改 分支与原流程一致)
```

### State transitions

| Current State | Transition | Next State |
|---|---|---|---|
| IDLE | 收到新需求 | ANALYZE |
| ANALYZE | 用户显式要求 ExecPlan (/plan, /dsh_exec_plan) | PLAN |
| ANALYZE | 无需 ExecPlan（讨论/小改动/咨询） | IDLE |
| ANALYZE | 已有 approved ExecPlan 可恢复 | EXECUTE |
| PLAN | ExecPlan 写完，呈交人类 | PENDING |
| PENDING | 人类批准 (approval_status=approved) | EXECUTE |
| PENDING | 人类退回修改 | PLAN |
| EXECUTE | 所有步骤完成 | COMPLETE |
| EXECUTE | 同一验证失败 3 次 / 超出范围 / 安全问题 | BLOCKED |
| EXECUTE | 执行中发现新信息需要重新分析 | ANALYZE |
| EXECUTE | 执行中发现需要修改执行计划 | PLAN |
| COMPLETE | Completion Report 已生成并呈交 | IDLE |
| COMPLETE | 验证失败或报告被退回 | EXECUTE |
| BLOCKED | 报告已生成，待人类决策 | IDLE |
| BLOCKED | 人类决定重试 | ANALYZE |
| 任何状态 | 用户输入新指令 | 重新 ANALYZE |

### Permitted actions per state

| State | Allowed | Forbidden |
|---|---|---|
| IDLE | 分析需求、提问澄清 | 写 ExecPlan、修改文件 |
| ANALYZE | 阅读文档（.harness/docs/）、分析需求、读取 constraints.yaml + config.yaml、检查 active plan 状态 | 修改文件、写 ExecPlan |
| PLAN | 写 ExecPlan、阅读文档 | 修改文件（ExecPlan 本身除外）|
| PENDING | 等待审批、回答关于 ExecPlan 的问题 | 修改文件、执行步骤 |
| EXECUTE | 按 ExecPlan 步骤执行（见下方 EXECUTE Step Protocol）、更新 Evidence Log、创建 checkpoint | 新增未经审批的行动 |
| COMPLETE | 生成 Completion Report、呈交人类 | 继续修改文件 |
| BLOCKED | 生成 BLOCKED 报告、解释原因、请求人类介入 | 自动重试 |
| 任何状态 | 用户输入新指令 | 重新 ANALYZE |

## EXECUTE Step Protocol

Each ExecPlan step MUST follow this loop:

```
1. EXECUTE: Run the step's command(s)
2. VERIFY: Run the step's Verification check
   - If PASS → proceed to step 3
   - If FAIL → retry (same verification failure count +1)
     - If count < 3 → go back to step 1 (re-execute)
     - If count >= 3 → transition to BLOCKED
3. RECORD: Update Evidence Log (status, evidence, checkpoint ref) and Environment State
4. ADVANCE: Move to next step
```

Rules:
- Step MUST NOT be marked "done" before verification passes.
- Verification MUST produce a machine-checkable pass/fail (exit 0 = pass).
- Evidence Log MUST be updated before moving to next step.
- Verification failure count resets per step (3 attempts max, then BLOCKED).
- If execution reveals wrong assumptions → ANALYZE. If plan needs adjustment → PLAN.
- Before executing, MUST write Command/Expected/Verification into Evidence Log.

## Core Constraints

All constraints below are **MUST** rules. Violation is a workflow error.

1. **MUST** start every response with `[STATE: <state>]`.
2. **MUST** read AGENTS.md first — it is the only guaranteed entrypoint.
3. **MUST NOT** modify files outside the task scope.
4. **MUST NOT** skip hooks, skip tests, or force-push to protected branches.
5. **ExecPlan discipline** — See `.harness/constraints.yaml` → `execplan-skill-gated`, `human-gate`, `checkpoint-discipline`, `step-discipline`.
6. **MUST NOT** assume intent from filenames — read `.harness/docs/` before making structural changes.
7. **MUST** obtain human approval before any ExecPlan enters execution phase. The ExecPlan is a PROPOSAL until approved.
8. **MUST** separate proposal and implementation into different turns. A single response MUST NOT contain both a novel proposal and its implementation.
9. **Workflow discipline** — See `.harness/constraints.yaml` → `workflow-discipline`, `session-start-mandatory`.
10. **Code quality** — See `.harness/constraints.yaml` → `fix-implementation-not-tests`.
11. **Doc hygiene** — See `.harness/constraints.yaml` → `doc-reference-freshness`, `discussion-trace`, `goal-granularity`.

The complete list of invariants with machine-checkable verifications is in `.harness/constraints.yaml`. This section is a quick-reference summary only.

## Documentation Routing

| Layer | Location | What it contains |
|---|---|---|
| L1 Index | `.harness/docs/L1_INDEX.md` | Topic navigation |
| L2 Module | `.harness/docs/L2_MODULES/` | Module-level structural docs |
| L3 Facts | `.harness/docs/L3_FACTS/` | Stable project facts (build, test, config, conventions) |
| L4 Skills | `.harness/docs/L4_SKILLS/` | Reusable operation definitions |

## Session Start (MUST run before entering ANALYZE)

**Invoke session-start skill before any analysis. Do not skip.**

```
Execute: .harness/docs/L4_SKILLS/session-start.md
```

The skill enforces: goal restatement → constraint read → config read → active ExecPlan check → doc scan → enter ANALYZE. Output a summary line in the format `[SESSION START] Goal: ... | Active ExecPlan: ... | Doc scan: ...`.
