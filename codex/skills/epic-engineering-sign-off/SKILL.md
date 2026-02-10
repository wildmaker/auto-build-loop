---
name: epic-engineering-sign-off
description: Epic Completion Check（工程完成性核查）：在 Epic Review 前完成 Backlog/Spec/Branch 的一致性与闭环检查。
version: 0.1.0
---

# Skill: epic-engineering-sign-off

## Trigger
@epic-engineering-sign-off

## Source of truth
- `codex/skills/epic-auto-build-v2/references/epic-workflow.md`（关系模型与分支/合并约束）
- 根目录 `BACKLOG.md`（Epic 交付清单与状态）

## What this skill does
- 在进入 Epic Review 之前，对一个 Epic 做 **Epic Completion Check（工程完成性核查）**，确保交付闭环与分支健康：
  - Backlog Consistency：BACKLOG 中该 Epic 分组下的 items/Issues 状态一致且全部 Done
  - Spec Closure：每个 Issue 对应的 OpenSpec Spec Change 已完成（并已归档/闭环），对应 `spec/*` 已合并回 `epic/*`
  - Branch Integrity：Epic 分支包含所有已完成 spec 的代码；无悬挂/未合并的实现分支

## Inputs (recommended)
- `<epic-name>`：用于定位 `BACKLOG.md` 分组与 `epic/<epic-name>` 分支
- `<epic-branch>`：默认 `epic/<epic-name>`
- `<base-branch>`：默认 `main`（用于最终合并前核查差异与分支关系）

## Outputs
- 一份核查结果（Pass/Fail + 失败项清单 + 修复建议），可直接贴到 Epic PR / Review 记录中

## Allowed commands
- `git`
- `gh`
- `rg`
- `openspec`

## Checklist（必须逐项核查）

### A. Backlog Consistency
Epic 对应的根目录 `BACKLOG.md` 分组下：
- 所有 backlog items 状态为 Done（以 `BACKLOG.md` 标记为准）
- 每个 item 都能追踪到一个 Issue（编号/链接/引用信息齐全）
- 关键链接齐全：Issue / PR（如有）/ Spec Change（如有）

建议核查手段：
- 用 `rg` 定位 `<epic-name>` 分组并扫描 items 状态
- 用 `gh issue view <id>` / `gh issue list` 抽查 Issue 是否为 Closed/Done（按团队约定）

### B. Spec Closure
对该 Epic 下的每个 Issue（即每个 backlog item），必须满足：
- 对应 Spec Change 已完成闭环
  - Spec Change 目录：`OpenSpec/changes/<spec-name>`
  - 若流程要求归档：已执行 `openspec archive <spec-name> --yes` 并确认归档完成
- 对应实现分支 `spec/<spec-name>` 已合并到 `<epic-branch>`

建议核查手段：
- `git branch --merged <epic-branch>` / `git log --oneline --merges <epic-branch>`（确认 spec PR 合并痕迹）
- `openspec` 检查 change 是否已归档（按仓库 openspec 约定）

### C. Branch Integrity
必须满足：
- `<epic-branch>` 包含所有已完成 spec 的代码（即：已完成 items 对应的 `spec/*` 都已合并）
- 本 Epic 相关分支中无未合并或悬挂的实现分支
  - 例如：仍存在未合并的 `spec/*`、或存在已停止推进但未关闭的工作分支

建议核查手段：
- 列出远端 `spec/*` 并检查是否都 merged/已关闭（用 `git branch -r` + merge 检查，或结合 PR 状态）
- `gh pr list --base <epic-branch>` 检查是否仍有 open PR 指向该 Epic

## Exit criteria（允许进入 Epic Review 的条件）
- A/B/C 三组检查全部 Pass；否则必须先修复失败项再进入 Epic Review
