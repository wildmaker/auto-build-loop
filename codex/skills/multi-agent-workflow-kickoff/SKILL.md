---
name: multi-agent-workflow-kickoff
description: 在已确定 Multi-Role Team 后，实际创建并启动多个并行 agent 执行各自 epic；禁止仅生成 kickoff 文本。适用于 Sprint Planning 已完成且已有 Epic Assignment 的场景。
---

# Skill: multi-agent-workflow-kickoff

## What this skill does
- 将 Sprint Planning 的 `Epic Assignment` 转为真实并行执行。
- 强制创建多个独立 agent/session（每个 epic 一个），并立即启动各自流程。
- 回传每个 agent 的启动凭据与首个执行状态，作为“已启动”证据。

## Input
- `team_channel` (optional): 发送渠道或目标会话
- `context` (optional): 本次需求上下文摘要
- `epic_assignments` (required): Sprint Planning 产出的 Epic 与 owner 对应关系

## Hard constraints
- 仅在已确定 `Delivery Mode = Multi-Role Team` 时使用。
- 禁止“只发 kickoff 消息不执行”；必须发生真实 agent 派生/并行启动。
- 每个 agent 仅绑定一个 epic，且不得跨 epic 修改实现。
- kickoff 阶段必须直接触发该 agent 的第一步执行（至少进入 `epic-breakdown`）。
- 若运行环境不支持 agent 派生能力，必须立即返回 `Kickoff Failed`，并要求调用方降级为 `Single Owner`（不得伪装成已多 agent 启动）。

## Execution protocol (must follow)
1. 读取 `epic_assignments`，按 epic 数量创建等量并行 agent/session。
2. 给每个 agent 下发其专属上下文（epic 名称、边界、输入文档、base/epic 分支）。
3. 立即在每个 agent 内启动执行：`epic-breakdown`。
4. 收集每个 agent 的启动证据：
   - `agent_id` / `session_id`
   - 绑定 epic
   - 首个状态（如 `epic-breakdown started`）
5. 将状态回传给调用方；调用方随后继续调度该 agent 的后续 phases。

## Output format
```md
Kickoff Execution
- Mode: Multi-Role Team
- Spawned Agents: <N>
- Agent Registry:
  - Agent <id>: Epic <epic-name>, Status <started|failed>, Session <session-id>
  - Agent <id>: Epic <epic-name>, Status <started|failed>, Session <session-id>
- Next Step:
  - started agents: continue epic workflow from `epic-breakdown`
  - failed to spawn: fallback to `Single Owner` and reroute in sprint-planning
```
