# Dale's Harness (dsh)

> 一套纯文件结构的 AI Coding 工作流基础设施，让 agent 的行为 **可观察、可验证、可系统改进**——无需任何运行时、插件或平台依赖。

---

## 问题

AI agent 收到 prompt → 思考 → 输出代码。中间发生了什么？

- **做了哪些决策？** 为什么选 A 不选 B？
- **分析过再写代码吗？** 还是直接跳进了实现？
- **输出验证过吗？** 还是因为"看起来对"就默认正确？
- **下一个 agent 能接着干吗？** 还是每次都得从头来？

没有结构，AI Coding 就是一个黑盒。你看到输入和输出，里面全靠猜。

Harness Engineering 的答案：**用状态机，不是用提示词；用可检查的约束，不是用建议；用证据链，不是用聊天记录。**

---

## 核心理念

### 1. 状态机优于提示词

提示词只是建议。agent 可以遵循、忽略、或重新解释。**状态机是结构**——它定义每个时刻允许什么操作，违规可以被检测。

dsh 定义了七个状态：

```
IDLE → ANALYZE → PLAN → PENDING → EXECUTE → COMPLETE
                ↑         ↓         ↓
                └──退回修改──┘     BLOCKED
```

每个 agent 回复必须以 `[STATE: <state>]` 开头。这不是装饰——它让工作流可被机器解析。合规检查可以扫描整个会话记录，验证每次状态跳转是否合法。

**防止常见失败模式的关键路径：**

- `EXECUTE → ANALYZE` — 执行发现问题理解错了。回去重新分析。
- `EXECUTE → PLAN` — 理解正确但计划需要调整。回去重新计划。
- `COMPLETE → EXECUTE` — 完成报告被退回或验证失败。还没完。
- `BLOCKED → ANALYZE` — 人类决定后，换个方法重试。

没有这些反馈路径，agent 只能要么用错误计划继续，要么人为触发 BLOCKED。两者都不对。（这来自自验证中发现的问题 3——见下方。）

### 2. 约束必须可检查

`.harness/constraints.yaml` 中的每个约束都有 `check` 字段——一条 agent 可以执行的具体指令：

```yaml
- id: human-gate
  check: "ExecPlan 必须有 'Human Approval' 段落，包含批准人名称和时间戳"

- id: session-start-mandatory
  check: "首轮回复必须包含 6 行特定输出，仅摘要行不够"
```

没有 check 字段的约束只是建议。建议是可选的。dsh 不发布可选规则。

### 3. 提案和执行必须分离

这是实践中违反最多的规则，也是最重要的。

agent 不得在同一个回复中写计划并执行它。为什么？因为一个"看起来合理"的计划会被自动执行——而人类根本没机会说"等等，这不对"。

分离强制了一个**人类审批关口**：提案 → 呈交 → 批准/退回 → 执行。这增加了一个审批回合的时间成本。代价很小。跳过它的代价是一个 agent 在没有监督的情况下按错误方案执行。

### 4. 每个人类请求都是 ExecPlan

原始规则是"如果任务模糊才写 ExecPlan"。这是个错误——它把判断权交给了 agent。agent 永远选择"不模糊"然后跳过计划。

修正后的规则：**每个人类请求都是 ExecPlan。** 只有两条路：

```
请求 → 无活跃 EP → 新建 EP → PENDING → 批准 → EXECUTE
请求 → 存在已批准 EP（范围内）→ 继续 EXECUTE
```

没有第三条路。没有"这事太小不用计划"。没有判断空间。

### 5. 纵深防御

dsh 在三个层面运作，因为任何单一层都会失效：

| 层 | 捕获什么 | 失效模式 |
|---|---------|---------|
| Agent 协议 (`AGENTS.md`) | 会话中的 agent 行为 | agent 可能跳过/忽略 |
| 预提交钩子 (`hooks.md`) | 未经批准计划提交的代码 | 仅在提交时捕获 |
| CI 检查 (GitHub Actions) | 未经合规通过的 PR 合并 | 仅在 CI 中运行 |

预提交钩子最重要——它是 agent 无法绕过的唯一防线。当 `git commit` 因为不存在 ExecPlan 而失败时，agent 别无选择，只能创建一个。

---

## 理念到文件的映射

| 理念 | 文件 | 实现机制 |
|------|------|---------|
| 状态机 | `AGENTS.md` | 17 条 MUST 约束 + 状态转移表 + `[STATE]` 头 |
| 可检查约束 | `.harness/constraints.yaml` | 22 个不变量 + 2 个防护栏，每个有 `check` 字段 |
| 提案/执行分离 | `AGENTS.md` 约束 8 | "单个回复不得同时包含新提案和它的实现" |
| 每请求=EP | `AGENTS.md` 约束 5 | 四分支决策树（新建/继续/待审批/超范围） |
| 纵深防御 | `.harness/docs/L4_SKILLS/hooks.md` | 预提交钩子脚本 + CI 工作流模板 |

---

## 架构

```
your-project/
├── AGENTS.md              ← 入口（必须先读）
└── .harness/
    ├── config.yaml        ← 验证流水线、质量门禁
    ├── constraints.yaml   ← 机器可检查的架构不变量
    │
    ├── execplan/
    │   ├── template.md    ← ExecPlan 结构 + 步骤粒度规范
    │   └── active/        ← 每个活跃任务一个 ExecPlan
    │
    ├── docs/
    │   ├── L1_INDEX.md    ← 主题导航（从这开始）
    │   ├── L2_MODULES/    ← 模块文档
    │   ├── L3_FACTS/      ← 稳定事实：构建、测试、配置
    │   └── L4_SKILLS/     ← 可执行的技能定义
    │
    ├── recordings/
    │   ├── decisions/     ← 决策记录（DR-*.md）
    │   └── checkpoints/   ← 状态快照
    │
    ├── metrics/           ← 项目健康度定义
    └── taxonomy.yaml      ← 问题分类
```

### 三层架构

```
┌──────────────────────────────────────────┐
│           状态机层                        │
│   AGENTS.md — 什么状态，允许做什么       │
│   输出：[STATE: <state>] 每轮回复         │
├──────────────────────────────────────────┤
│           约束层                          │
│   constraints.yaml — 永远不许做什么       │
│   每条规则有机器可执行的检查              │
├──────────────────────────────────────────┤
│           验证层                          │
│   config.yaml — 做完前必须通过什么        │
│   quality_gates — 完成的接受条件          │
│   escalation — 3 次失败 → BLOCKED       │
└──────────────────────────────────────────┘
```

三层独立但联动：状态机控制"能做什么"，约束控制"不能做什么"，验证控制"什么算做完"。

---

## 自验证故事

dsh 是通过将自身应用于自己的开发过程构建的。这不是可选的——这是约束 7（"必须先在本项目上验证模板内容"）。

验证循环如下：

```
EP-003: 修复 harness 中的 6 个工作流问题
  └─ EP-004: 用 sub-agent 按 harness 工作流构建一个 Go CLI 工具
       └─ 审计发现 sub-agent 的 5 个合规缺口：
            • Session Start 完全跳过
            • 9 个步骤共享一个 checkpoint
            • Evidence Log 在实现后填写，而非之前
            • 状态从 ANALYZE 直接跳到 COMPLETE
            • Discussion Trace 只有 3 行
            └─ EP-005: 5 个缺口全部修复到模板中
```

EP-004 中发现的每个缺口都是真实的——sub-agent 使用的是和今天 dsh 发布的相同的模板。修复让模板更严格，让未来的 agent 更难绕过。

**dsh 解决的问题，是在用 dsh 解决自身问题的过程中发现的。**

---

## 快速开始

```bash
# 1. 复制 dsh 到你的项目
cp -r dsh/* your-project/
cd your-project

# 2. 在 AGENTS.md 定义核心目标
# 3. 在 .harness/config.yaml 配置验证流水线
# 4. 在 .harness/docs/L3_FACTS/build_test.md 设置构建/测试命令
# 5. 安装预提交钩子（见 hooks.md）
# 6. 用 Kilo 兼容的 agent 打开项目
```

你的 agent 会在首次加载时自动运行 **Session Start**，然后依次经过 ANALYZE → PLAN → 等待你批准 → EXECUTE → COMPLETE。

---

## dsh 的保证

使用 dsh 的项目获得三种临时 ad-hoc 工作流无法提供的能力：

1. **可追溯** — 每个决策、排除方案和权衡都以结构化格式记录（决策记录 + Discussion Trace）。任何 agent 都可以重建推理过程，无需重读对话历史。

2. **可恢复** — 在任何中断后，新 agent 读取 ExecPlan 的 Evidence Log 和 Context Summary，从最后一个验证通过的步骤继续。无上下文丢失，无重复工作。

3. **可验证的正确性** — 每个步骤都有机器可检查的验证。完成报告证明所有质量门禁已通过。"做完了"不是一个宣称——是一组通过的检查项。

---

*Dale's Harness v0.1.0 — 通过自验证构建。无需运行时。一切都是可读的 markdown 和 YAML。*
