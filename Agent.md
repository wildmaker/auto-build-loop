# Agent Guide: epic-auto-build-v2

本文件用于指导其他 AI 在本目录内正确使用 Epic 自动化开发流程资产。

## 1. 何时启用
只在用户**明确提出**以下意图时启用本流程：
- `epic auto build`
- `epic-auto-build-v2`
- `auto-build-v2`（兼容旧名）

若用户未明确提出，不应自动进入本编排流程。

## 2. 核心入口与权威文档
- 主编排 Skill：`codex/skills/epic-auto-build-v2/SKILL.md`
- 稳定化主控 Skill：`codex/skills/epic-stabilization/SKILL.md`
- 工作流权威文档：`codex/skills/epic-auto-build-v2/references/epic-workflow.md`
- 参考流程细节：
  - `codex/skills/epic-auto-build-v2/references/epic-workflow.md`
  - `codex/skills/epic-auto-build-v2/references/SDD-LOOP.md`
  - `codex/skills/epic-auto-build-v2/references/COMPLIANCE-CHECKLIST.md`

执行时优先遵循以上文件；冲突时以 `epic-auto-build-v2` 与 `codex/skills/epic-auto-build-v2/references/epic-workflow.md` 的强约束为准。

## 3. 总体工作流（当前版本）
按五阶段执行：

1. Sprint Planning（`sprint-planning`）
- 先调用 `multi-agent-parallel-gate` 做交付模式决策（Single Owner / Multi-Role Team）。
- 若为多人力：拆分多个 epic，每个 agent 负责一个 epic 并独立进入后续流程。
- 若为单人力：保持单 epic，进入标准后续流程。
- 每个启用 epic 的初始化由 `epic-breakdown` 完成（Plan/Backlog/Issue/epic 分支）。

2. Implement（循环执行 `epic-sdd-loop`，一次一个 item）
- 从 `epic/<epic-name>` 创建 `spec/<spec-name>`。
- 执行 OpenSpec 变更初始化与严格校验。
- 编码、建 PR（`spec/* -> epic/*`）、处理评审高/中优先级评论、合并。
- 回写 `BACKLOG.md`（状态、Issue、PR、Spec Change）。

3. Review / Demo（`epic-engineering-sign-off` -> `epic-review-demo`）
- 先做工程完成性 gate（Backlog/Spec/Branch 完整性）。
- 生成 Epic 汇总报告（建议 `docs/<epic>/EPIC-REPORT.md`）。
- 用 `report-it-to-me` 产出 `.xmind`（可选但推荐）。
- 按 Plan 中 Demo 脚本执行价值验收。

4. Stabilization（`epic-stabilization`）
- 对人工测试问题清单做分流：
  - Fix：走 `epic-fix-stabilization`
  - Change：走 `epic-sdd-loop`（回到 Spec 驱动）
- 回归测试通过后，输出 `ready_for_merge: true/false`。

5. Merge（`epic-merge-to-main`）
- 仅当稳定化通过后，将 `epic/<epic-name>` 合并回 `main`（或指定 base）。

## 4. 必须遵守的流程约束
- 分支模型：`main -> epic/<epic-name> -> spec/<spec-name>`。
- `spec/*` 只能合并回对应 `epic/*`，禁止直接指向 `main`。
- 一个 backlog item 对应一个 Issue + 一个 Spec Change（1:1:1）。
- 所有 PR 合并前必须完成评论闭环（至少高/中优先级）并确保 CI 通过。
- 默认不删除 `spec/*` 分支；仅在 Epic 完成且用户明确同意后统一清理。
- 新文档应写入 Epic 文档目录（如 `docs/<epic-name>/`），不要堆在 `docs/` 根目录。

## 5. 资产使用建议（执行顺序）
1. 读取 `codex/skills/epic-auto-build-v2/references/epic-workflow.md`，确认阶段目标与分支关系。
2. 读取 `epic-auto-build-v2/SKILL.md`，按其 5 Phase 编排执行。
3. 进入具体阶段时再读取对应子 skill：
- Sprint Planning：`sprint-planning`（内部路由到 `multi-agent-parallel-gate` 与 `epic-breakdown`）
- Implement：`epic-sdd-loop` + `openspec-init-change` + PR 相关 skills
- Review/Demo：`epic-engineering-sign-off`、`epic-review-demo`、`report-it-to-me`
- Stabilization：`epic-stabilization`、`epic-issue-triage`、`epic-fix-stabilization`
- Merge：`epic-merge-to-main`
4. 每完成一个 item 或阶段，及时回写 `BACKLOG.md` 与产物文档。

## 6. 给 AI 的默认执行策略
- 默认 Autonomous：不要在每个阶段结束后等待用户“确认下一步”。
- 选 item 规则：从目标 Epic 分组中选择**第一个未完成**条目。
- 遇阻塞（权限/环境/上下文缺失）：
  - 记录为 Blocked 并写明原因；
  - 继续下一个可执行条目；
  - 在阶段汇总中输出阻塞清单。

## 7. 交付物最小清单
至少应有：
- `BACKLOG.md`（含 Epic 分组、Issue/PR/状态回写）
- `docs/<epic-name>/Implementation Plan.md`
- `docs/<epic-name>/EPIC-REPORT.md`
- 稳定化报告（如 `docs/<epic-name>/EPIC-STABILIZATION-REPORT.md`）
- 相关 PR / Issue / Spec Change 可追溯链接
