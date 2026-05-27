# Skill: ExecPlan 创建

## 触发方式

用户明确要求创建 ExecPlan 时触发。触发形式可以是：
- "让我们创建一个 ExecPlan"
- `/plan` 或 `/dsh_exec_plan`
- "为这个任务创建一个 ExecPlan"
- 其他明确表达"需要 ExecPlan"的请求

**不要主动猜测用户是否需要 ExecPlan。** 除非用户明确要求，否则默认使用轻量讨论模式处理。

## 工作流

### Phase 0: 需求对齐

向用户提出至少以下澄清问题，根据任务复杂度可增减：

1. **任务目标** — 这次要做什么？
2. **与 Core Goal 的关系** — directly-serves / enables / prerequisite / maintenance / exploration / other？
3. **范围边界** — 做什么、不做什么？
4. **验收标准** — 可观察、可二值判断的成功条件？
5. **任务裁剪** — bug / medium / large？（决定走哪些 Phase）

记录用户的回答，作为后续 Discussion Trace 和 Scope 的输入。

### Phase 2: 方案撰写

按 `.harness/execplan/template.md`（Phase-Annotated 版本）创建 ExecPlan 文档：

1. 生成 EP 编号：检查 `.harness/execplan/completed/` 中最大 EP 编号，+1
2. 写入 `.harness/execplan/proposal/EP-NNN-title.md`
3. 内容包含：
   - Metadata（Phase: 2, Phase Selection, Self-contained）
   - Goal Alignment
   - Discussion Trace（至少包含此轮需求对齐的推理记录）
   - Scope
   - Execution Milestones（按里程碑分组的具体步骤）
4. Human Approval 区块的 Approval status 设为 pending

### Phase 3: Review Gate

**硬性暂停。** 向用户展示 ExecPlan 摘要（目标、范围、里程碑数、关键步骤），等待用户明确批准。在批准之前：

- 不得进入 Phase 4 实施
- 不得修改 ExecPlan 之外的任何文件
- Agent 可以回答关于 ExecPlan 的澄清问题

### Phase 4+: 执行

用户批准后，ExecPlan 从 `proposal/` 移到 `active/`，开始按里程碑执行。执行规则见 AGENTS.md → EXECUTE Step Protocol。

## 约束

- 必须使用 Phase-Annotated 模板格式（`.harness/execplan/template.md`）
- 必须写入 `proposal/` 目录
- 必须经过 Phase 3 硬性暂停，收到明确批准后方可实施
- 必须记录 Discussion Trace（至少需求对齐轮的记录）
- 提案与实施必须在不同 agent 轮次中
