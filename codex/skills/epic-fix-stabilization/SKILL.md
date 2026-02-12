---
name: epic-fix-stabilization
description: Epic Stabilization 的 Fix-only 集中修复流程：仅修 bug / 补测试 / 对齐既有 Spec，不允许行为扩展；输出可合并回 epic/* 的修复 PR。
version: 0.1.0
---

# Skill: epic-fix-stabilization

## Trigger
@epic-fix-stabilization

## Source of truth
- `BACKLOG.md` 中该 Epic 的 fix 任务清单
- 当前 Epic 的既有 Spec 与变更：`OpenSpec/changes/*`（Spec 不允许在本流程中改变）
- `codex/skills/epic-auto-build-v2/references/epic-workflow.md`（分支/合并约束）

## Inputs (recommended)
- `<epic-branch>`：默认 `epic/<epic-name>`
- `<fix-branch>`：默认 `fix/<epic-name>-stabilization`（base = `<epic-branch>`）
- `<fix_issues>`：来自 `BACKLOG.md` 中该 Epic 的 fix 任务清单

## Outputs
- 修复分支与 PR：`<fix-branch>` → `<epic-branch>`
- `fix_stabilization_report`（可贴到 PR / Epic 记录中）

建议报告格式：
```yaml
fix_stabilization_report:
  fixed_issues: list
  added_or_updated_tests: list
  regression_status: pass | fail
  notes: list
```

## Constraints（硬约束）
- **Fix-only**：只允许
  - bug 修复
  - 测试补充/修复（含回归测试）
  - 与既有 Spec 对齐（实现纠偏）
- **禁止**：
  - 引入新功能
  - 改变“应有行为”（若发现必须改行为：立即停止并将该问题升级为 Change，交回 Change Path：`epic-sdd-loop`）
  - 混入重构/风格清理等非必要改动（除非是修复所必需的最小改动）
- 每个修复类问题必须补上最小可回归验证（测试/断言/可复现脚本三选一，按 repo 约定）

## Allowed commands
- `fix-bug`
- `git-pr-review`
- `git`
- `rg`
- `openspec`
- `gh`
- （按 repo 现状）`npm` / `pnpm` / `yarn` / `make` / `python` / `go` / `cargo` 等用于运行测试与构建

## Workflow
1. 从 `<epic-branch>` 创建并切换到 `<fix-branch>`
2. 逐条处理 `<fix_issues>`（建议一次只推进一个，保持可回滚）
   - 复现问题 → 定位根因 → 实施最小修复 → 增补最小回归验证
  - 若发现需要改变 Spec 才能“正确”：立即停止该条修复，将其重新分类为 Change（回到 Change Path：`epic-sdd-loop`）
3. 完成实现，并在 `<fix-branch>` 上运行最小本地检查/回归（lint/test/build/e2e 按 repo 约定）
4. 运行 `git-pr-review` 创建 PR 并处理评审闭环：`<fix-branch>` → `<epic-branch>`（base 必须是 `<epic-branch>`；PR 中引用 `<fix_issues>`；不需要 Spec Change），并确保：
   - PR 描述逐条列出已修复的 issues（含复现与验证方式）
   - CI 全绿后合并回 `<epic-branch>`
5. 输出 `fix_stabilization_report`
