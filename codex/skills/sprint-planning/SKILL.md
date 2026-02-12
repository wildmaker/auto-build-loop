---
name: sprint-planning
description: 在 Epic 工作流开始前执行 Sprint Planning：先调用 `multi-agent-parallel-gate` 判断采用单人单 epic 还是多 agent 多 epic，再输出对应的执行路由。适用于需要在需求文档或技术设计文档基础上决定交付模式与 Epic 拆分策略的场景。
---

# Skill: sprint-planning

## What this skill does
- 作为 Epic 工作流的统一入口，先做交付模式决策，再进入后续执行。
- 调用 `multi-agent-parallel-gate` 输出 `Single Owner` 或 `Multi-Role Team`。
- 基于决策给出两条固定路径：
  - 结果 A：多人力，多 epic 并行
  - 结果 B：单人力，单 epic 串行

## Inputs
- `doc_path`: 需求文档或技术设计文档
- `base_branch` (optional): 默认 `main`
- `scope_note` (optional): 补充边界/约束

## Hard constraints
- 必须先调用 `multi-agent-parallel-gate`，再决定路径。
- 仅当满足其一时允许进入结果 A：gate 输出满足并行阈值（效率提升 >=30%）或用户显式要求 `multi-agent delivery mode`。
- 结果 A 中每个 agent 负责一个 epic，不得跨 epic 直接互改实现。
- 结果 B 中保持单人单 epic，不强行拆分多个 epic。
- Sprint Planning 不是终点：完成路由判定后必须立即进入后续执行，不允许停在“等待用户选择下一步”。
- 若用户未显式要求暂停/仅输出计划，默认继续执行到至少触发对应 epic 的 `epic-breakdown`。

## Steps
1. 调用 `multi-agent-parallel-gate`，获得 `Delivery Mode` 与时间评估。
2. 若 `Delivery Mode = Multi-Role Team`，执行结果 A：
   - 将需求拆分为多个可独立交付的 epic（每个 epic 必须有清晰边界与可单独验收目标）。
   - 为每个 epic 指定一个 owner agent。
   - 每个 agent 按同一套后续流程执行：`epic-breakdown` -> `epic-sdd-loop` -> `epic-engineering-sign-off` -> `epic-review-demo` -> `epic-stabilization` -> `epic-merge-to-main`。
3. 若 `Delivery Mode = Single Owner`，执行结果 B：
   - 仅建立一个 epic。
   - 由单一 owner 按标准 Epic 流程串行执行后续阶段。
4. 输出 Sprint Planning 决策记录与执行矩阵。
5. 输出后立刻继续执行（不可停顿）：
   - 结果 A：先调用 `multi-agent-workflow-kickoff` 实际派生并启动并行 agent（每个 epic 一个），再由各 agent 各自进入 `epic-breakdown`。
   - 结果 B：直接对该单一 epic 调用 `epic-breakdown`。

## Output format (must follow)
```md
Sprint Planning Decision
- Delivery Mode: Single Owner | Multi-Role Team
- Reason: <top 3 points>
- Time Estimate: T_single=<...>, T_multi=<...>, Gain=<...>

Execution Route
- Result A (Multi-Role Team): <enabled|disabled>
- Result B (Single Owner): <enabled|disabled>

Epic Assignment
- Epic 1: <epic-name> -> Agent <name/id>
- Epic 2: <epic-name> -> Agent <name/id>
- Epic 3: <epic-name> -> Agent <name/id>

Next Actions
- Each epic owner starts from: epic-breakdown
- Workflow per epic: epic-workflow phases 2-5
- Executor mode: Continue immediately after route decision (no pause for route confirmation)
```

## Allowed commands
- `rg`
- `cat`
- `git`
- `gh`
