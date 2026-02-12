---
name: multi-agent-parallel-gate
description: 在需求文档或技术设计文档进入任务拆分前，先做交付模式决策：判断应由单一负责人端到端完成（Single Owner），还是由多职能协同并行完成（Multi-Role Team）。当且仅当任务具备清晰可并行边界且协同收益显著时选择多角色并行，否则默认单人串行，以最小复杂度达成目标并避免过度工程化。
---

# Skill: multi-agent-parallel-gate

## What this skill does
- 在执行前做一个决策：`Single Owner` 或 `Multi-Role Team`
- 若选择 `Multi-Role Team`，只允许两种固定模板：
  - `module-isolated`（新模块开发）
  - `cross-layer`（同一功能跨层协同）
- 输出固定格式，避免自由发挥导致复杂度上升

## Hard constraints
- 只做交付模式决策，不做额外架构设计。
- 本技能输出仅作为“路由门禁”结果，不是工作流终点；调用方在拿到结果后必须继续执行对应后续阶段。
- 禁止引入复杂前置产物（例如 Module Map、任务 DAG、冻结面等）。
- 任何不确定场景默认 `Single Owner`。
- 若需求无法映射到至少 2 个可独立推进的 role，强制 `Single Owner`。
- 只有在 `Multi-Role Team` 相比 `Single Owner` 能显著提升效率时，才允许并行。
- “显著提升”的默认阈值为：`Efficiency Gain >= 30%`（用户显式要求 `multi-agent delivery mode` 时可跳过）。
- `cross-layer` 模式下保持单 backlog item，不得拆成多个功能目标。
- 默认最小团队为 2-3 角色；无明确需要不得扩张角色数量。

## Inputs
- `doc_path`: 需求文档或技术设计文档路径
- `scope_note` (optional): 用户补充范围/目标（若有）
- `delivery_mode_override` (optional): 用户显式指定交付模式（支持 `multi-agent`）

## Role catalog (lightweight)
- `frontend`
  - owns: UI、交互、状态流、API 调用接入
  - outputs: 页面/组件变更、接口调用适配、交互验收点
- `backend`
  - owns: 接口、业务逻辑、domain 模型、错误模型
  - outputs: API 变更、服务逻辑、错误码/契约说明
- `database`
  - owns: schema、migration、索引与数据约束
  - outputs: DDL/migration、回滚策略、数据兼容说明
- `qa`
  - owns: 测试用例、边界条件、回归与契约测试
  - outputs: test cases、contract checks、回归结果
- `security` (optional)
  - owns: 鉴权、输入校验、敏感数据与风险检查
  - outputs: 安全检查结论、必要修复项

## Decision workflow (binary gate)
0. 先检查短路条件（用户显式要求优先）：
  - 若用户明确要求 `multi-agent delivery mode`（或等价表述），直接输出 `Delivery Mode = Multi-Role Team`。
  - 此时跳过 Gate A / Gate B / 效率阈值判断，但仍需输出固定模板与角色映射。
1. 若未命中短路：读取文档，提炼功能目标、影响范围、涉及层级、接口依赖、测试要求。
2. 做本质选择：选择交付模式（`Single Owner` vs `Multi-Role Team`）。
  - 目标：在满足质量前提下最小化总交付时间与协作复杂度；仅当并行效率提升 `>=30%` 时选择 `Multi-Role Team`。
  - Gate A: `module-isolated`
   - 是否存在天然模块边界（前端组件 / 后端 service / DB schema / 子系统）
   - 是否主要是新增或局部修改（不是大范围重构）
   - 模块间是否通过明确接口交互
  - Gate B: `cross-layer`（仅当 Gate A 不满足时判断）
   - 是否是同一个功能目标
   - 是否天然包含 UI / 业务逻辑 / 测试 三类关注点
   - 这些关注点是否可在接口未完全完成时先行推进（mock、contract、用例先写）
3. 决策输出：
  - Gate A 或 Gate B 满足 => 进入效率评估
  - 都不满足 => `Single Owner`
4. 效率评估（必做）：
  - 估算路径 S（`Single Owner`）总时长：`T_single`
  - 估算路径 M（`Multi-Role Team`）总时长：`T_multi`
  - `T_multi` 需包含并行协作开销（对齐、接口协商、集成、review 往返）
  - 仅当 `T_multi` 相比 `T_single` 的效率提升达到 `>=30%`，才输出 `Multi-Role Team`
  - 若收益不显著或估算不确定，输出 `Single Owner`

## Fixed mapping (when Multi-Role Team)
- `module-isolated`:
  - Agent A: `frontend`
  - Agent B: `backend`
  - Agent C: `database` (if needed)
- `cross-layer`:
  - Agent A: `frontend`
  - Agent B: `backend`
  - Agent C: `qa`
- `user-forced-multi-agent` (short-circuit):
  - Agent A: `frontend`
  - Agent B: `backend`
  - Agent C: `qa` (default) / `database` (if schema-driven)

## Collaboration constraints
- 各 agent 只修改自己负责目录或文件域。
- 接口协商只通过 PR/review 与契约文档，不直接互改实现。
- 若出现强串行依赖或边界不清，立即降级为 `Single Owner`。

## Anti-patterns (force Single Owner)
- 需求核心是重构或跨模块大改，边界不清晰。
- 依赖链强串行（后一步无法在前一步未完成时开展）。
- 接口尚未成形且短期内无法定义稳定契约。
- 团队当前目标是快速验证单点价值，不需要协同成本。

## Output format (must follow)
使用以下固定格式输出判定结果（简版）：

```md
Delivery Mode: Single Owner | Multi-Role Team
Template: module-isolated | cross-layer | user-forced-multi-agent | none
Why:
- <最多 3 条，直接对应检查项>

Time Estimate:
- T_single: <value>
- T_multi: <value, include coordination overhead>
- Efficiency Gain: <percentage, must be >=30% for Multi-Role Team; if user-forced, write "user override">

Assignments:
- Agent A: ...
- Agent B: ...
- Agent C: ... (if needed)

Next step:
- Multi-Role Team: 按固定模板执行并保持角色边界
- Single Owner: 立即回到单 item auto-build loop
- 执行要求: Gate 输出后立即由调用方进入下一阶段，不等待额外“是否继续”确认
```

## Optional extension
- 仅当用户明确要求时，才评估额外并行场景（研究审查 / 竞争假设调试 / 并行代码审查）。
