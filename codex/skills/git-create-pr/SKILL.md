---
name: git-create-pr
description: 提供 git-create-pr 的操作流程与约束；适用于 需要基于当前改动创建分支并提交 PR 时使用。
version: 0.1.0
---

# git-create-pr

## What this skill does
- 确保本地变更已提交
- 创建新分支并推送到远端
- 使用 GitHub CLI 创建 PR 并返回 PR 信息

## Inputs (recommended)
- `<base-branch>`：PR 目标分支（例如：`epic/<epic-name>` / `main` / `project/<name>`）
- （可选）`<head-branch>`：PR 源分支（默认当前分支；若当前在 base 上则必须创建新分支）
- （可选）`<title>`：PR 标题（若缺省则自动生成）
- （可选）`<body>`：PR 描述（若缺省则自动生成；必须引用 Issue/Spec Change 等链接）

## Constraints
- 默认以 **Autonomous / 无人监督** 模式执行：不要为了“确认 base/标题/描述”而停下来询问。
- 若未显式提供，则按上下文自动推导（base 来自 `<base-branch>`；title/body 由当前分支与变更内容生成，且必须包含 Issue/Spec Change 引用）。
- 未经确认不执行 `--amend`

## Allowed commands
- `git-commit`
- `git`
- `gh`

## Steps
1. 确定 PR 关键字段（自动）
   - base：使用 `<base-branch>`
   - head：默认当前分支；若当前分支等于 base，则创建新分支（禁止直接在 base 上提 PR）
   - title/body：若未提供则自动生成；body 必须引用关联 Issue 与（如有）Spec Change
2. 确保本地变更已提交（自动）
   - 若存在未提交改动：执行 `git add` + `git commit`（提交信息需真实反映改动；不要 `--amend`）
3. 推送 head 分支到远端（必要时加 `-u` 建立 upstream）
4. 使用 `gh` 创建 PR 并输出链接与编号（base 必须为 `<base-branch>`）
