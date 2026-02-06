---
name: git-pr-review
description: 将“创建 PR -> 拉取并处理评审评论”封装成可复用流程。
version: 0.1.0
---

# git-pr-review

## What this skill does
- 创建并打开 Pull Request（PR），并确保 PR 正确关联对应 Issue / OpenSpec change
- 等待远程评审，拉取评论并处理高/中优先级问题（按规则轮询）

## Inputs
- `<base-branch>`: PR 目标分支（例如：`project` / `main`）
- `<issue>`: 关联的 Issue（例如：`#123` 或 issue URL）
- `<openspec-change-id>`: 关联的 OpenSpec change ID（例如：`add-user-search`；若无可省略）

## Constraints
- 默认以 **Autonomous / 无人监督** 模式执行：不要为了“确认 PR base/标题/描述”而停下来询问。
- 若未显式提供，则按上下文自动推导（PR base 来自 `<base-branch>`；标题/描述由当前分支、`<issue>` 与（如有）`<openspec-change-id>` 组合生成）。
- 只有在无法推导且可能导致错误 base 分支时，才允许停止并输出阻塞项清单（不要反复询问）。
- 解决评论产生代码改动时，应**自动**完成 `git add` / `git commit` / `git push` 推送到 PR 原分支（不要等待人工确认）

## Allowed commands
- `git-create-pr`
- `git-resolve-pr-comments`
- `git`
- `gh`
- `sleep`

## Steps
1. 运行 `git-create-pr` 创建 PR：
   - PR 描述中必须引用 `<issue>` 与（如有）`<openspec-change-id>`。
2. 处理远程评审的评论：
   - 使用 `git-resolve-pr-comments` 拉取评论并处理高/中优先级问题（按其轮询约束执行）。
   - 如需提交修复，直接 `git add` / `git commit` / `git push` 推送到 PR 原分支。
