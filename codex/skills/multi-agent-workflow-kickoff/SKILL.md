---
name: multi-agent-workflow-kickoff
description: 发送标准化消息以启动多 agent 工作流。适用于已经完成 Sprint Planning 且确定采用多 agent 模式后，向各 Teammate 下发统一任务说明并触发协作执行。
---

# Skill: multi-agent-workflow-kickoff

## What this skill does
- 生成并发送一条标准 kickoff 消息，启动多 agent 协作。
- 使用固定提示词模板，降低沟通歧义。
- 要求 Teammate 完成后先讨论发现，再给优先级建议。

## Input
- `team_channel` (optional): 发送渠道或目标会话
- `context` (optional): 本次需求上下文摘要

## Hard constraints
- 仅在已确定 `Delivery Mode = Multi-Role Team` 时使用。
- 消息中必须包含角色职责、检查点和收敛产出。
- 不在 kickoff 消息中追加与当前目标无关的额外要求。

## Prompt template
```md
创建团队审查：
- Teammate 1 负责代码质量：检查命名规范、函数长度、注释完整性
- Teammate 2 负责 Bug 排查：关注边界条件、错误处理、资源泄漏
完成后讨论发现，给出优先级建议
```

## Output format
```md
Kickoff Sent
- Mode: Multi-Role Team
- Message Template: review-team-default
- Target: <team_channel or default>
- Context Attached: <yes|no>
```
