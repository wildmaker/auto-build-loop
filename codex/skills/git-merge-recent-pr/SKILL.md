---
name: git-merge-recent-pr
description: 提供 git-merge-recent-pr 的操作流程与约束；适用于 需要合并最近的 PR 并同步本地主分支时使用。
version: 0.1.0
---

# git-merge-recent-pr

## What this skill does
- 查找最近 PR 的 ID
- 在合并前确保：远程评审意见（高/中优先级）已闭环 + CI checks 全绿
- 处理冲突并通过 GitHub CLI 合并（默认不删除 head 分支）
- 更新本地 base 分支与远端保持一致

## Constraints
- 有冲突时必须先解决再合并
- **必须先处理 PR 中高优先级评论**：合并前调用 `git-resolve-pr-comments`
- **必须等 CI checks 全绿**：checks 未通过不得合并
- **默认不得删除 head 分支**（不要使用 `gh pr merge --delete-branch`）
  - 特别是 `spec/*`：即使 repo 开启了“自动删除已合并分支”，也应在合并后检查并必要时恢复该分支（用于 Epic 完成后的统一清理）

## Allowed commands
- `gh`
- `git`
- `sleep`
- `git-resolve-pr-comments`

## Steps
1. 从近期对话或上下文中确定 PR ID。
   - 若无法确定：用 `gh pr list` 在当前 repo 内按“最近更新”列出候选 PR，并选择与当前工作分支/目标分支最匹配的一条。
2. 合并前 gate（强制）：
   - 运行 `git-resolve-pr-comments`，等待远程 review（含自动 reviewer）并处理 High/Medium 评论
   - 确认 PR 的 checks 全绿（CI is green）
   - 若 review 明确为 `CHANGES_REQUESTED` 且仍存在 High/Medium 未闭环：停止合并并输出阻塞项清单
3. 检查是否存在冲突：
   - 若存在冲突：先解决冲突并 push（必要时更新 PR），再回到第 2 步重新 gate
4. 使用 `gh` 合并 PR（默认 merge commit 或按 repo 约定选择 squash/rebase）：
   - **不要**带 `--delete-branch`
5. 合并后检查 head 分支是否被删除（重点：`spec/*`）：
   - 若 headRefName 以 `spec/` 开头且远端分支不存在：从 PR head SHA 恢复该分支并推送回远端（用于后续 Epic 完成后的统一清理）
6. 更新本地 base 分支到远端最新状态：
   - 切换到该 PR 的 base 分支（例如 `main` / `epic/<epic-name>` / `project/<name>`）
   - pull/fast-forward 到远端最新
