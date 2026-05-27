# Skill: Checkpoint & Resume Protocol

## 何时创建 Checkpoint

| 触发条件 | 优先级 |
|---|---|
| 每个 ExecPlan step 执行完成后 | must |
| 发现重要决策或方案变更时 | should |
| 会话即将被中断/结束时 | must |

每完成一个 ExecPlan step（Evidence Log 标记为 done）后，MUST 在该 step 的 Evidence Log 行记录 checkpoint 引用编号。

## Checkpoint 格式

写入 ExecPlan 的 Checkpoints 表格。完整快照写入 `.harness/recordings/checkpoints/checkpoint-N.md`。

```
Checkpoint N — [timestamp]
├── Agent: [agent-id]
├── Step completed: [last done]
├── Files modified: [list]
├── Key decisions: [what and why]
├── Failed approaches: [don't retry]
├── Remaining steps: [not yet started]
├── Session summary: [compressed paragraph]
└── Next action: [the very next thing]
```
