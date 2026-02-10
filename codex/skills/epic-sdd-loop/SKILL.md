---
name: epic-sdd-loop
description: Epic 工作流的 SDD Loop：将根目录 `SDD-LOOP.md` 封装为可复用的单条 backlog item 交付流程（Issue ↔ Spec Change ↔ spec/* PR）。
version: 0.3.0
---

# Skill: epic-sdd-loop

## Trigger
@epic-sdd-loop

## Source of truth
- 根目录 `SDD-LOOP.md`
- `codex/skills/epic-auto-build-v2/references/epic-workflow.md`（术语与分支/合并约束）

## What this skill does
- 对**一个 backlog item**执行一次完整的 SDD Loop：从 `epic/<epic-name>` 创建 `spec/<spec-name>`，初始化 Issue + Spec Change，应用变更并实现，通过本地最小检查后创建/评审 PR，CI 全绿后合并回 Epic 分支，最后归档 Spec Change

## Inputs (recommended)
- `<epic-branch>`：默认 `epic/<epic-name>`（该 spec PR 的 base）
- `<spec-name>`：稳定 slug（同时作为 Spec Change 目录名与 change ID：`OpenSpec/changes/<spec-name>`）
- `<issue-title>`：用于创建/对齐 Issue（交给 `openspec-init-change`）
- （可选）`<issue>`：若 Issue 已存在，传入编号/链接供 PR 引用
- （可选）`<priority>`：用于 issue label 的优先级（`P0|P1|P2|P3`；建议从 backlog 条目的 `[Px]` 标记解析）

## Outputs
- 分支：`spec/<spec-name>`（合并回 `<epic-branch>`）
- Issue：与该 spec 一一对应
- Spec Change：`OpenSpec/changes/<spec-name>`
- PR：`spec/<spec-name>` → `<epic-branch>`

## Constraints
- 一次只处理一个 backlog item。
- `spec/*` 分支必须基于且只能合并回 `<epic-branch>`；禁止直接面向 `main`。
- 以 Spec Change 为评审权威（single source of truth）。

## Allowed commands
- `openspec-init-change`
- `git-pr-review`
- `git-merge-recent-pr`
- `openspec`
- `git`
- `rg`
- `gh`
- `sleep`

## Steps (mirrors `SDD-LOOP.md`)
1. 理解需求：阅读 backlog 条目与相关 spec/变更目标
2. 从 `<epic-branch>` 创建并切换到 `spec/<spec-name>`
3. 运行 `openspec-init-change` 初始化 Spec Change + Issue（inputs: `<spec-name>`, `<issue-title>`, `<branch>`；若 Issue 已存在则传入 `<issue>`；若可得则传入 `<priority>` 用于 labels）
4. 应用变更：`/openspec:apply <spec-name>`
5. 完成实现，并跑最小本地检查（lint/test/build 等，按仓库约定）
6. 运行 `git-pr-review` 创建 PR 并处理评审闭环（base 必须是 `<epic-branch>`；PR 中引用 Issue 与 Spec Change）
7. 合并 gate（强制）：在合并前再次确认
   - PR 的 High/Medium 评论已闭环（含自动 reviewer，例如 gemini-code-assist）
   - CI checks 全绿（CI is green）
8. 合并 PR 回 `<epic-branch>`（推荐使用 `git-merge-recent-pr`，它会执行评论闭环 gate 且默认不删除 head 分支）
   - **禁止删除 `spec/*` 分支**：不要使用 `gh pr merge --delete-branch`
   - 若 repo 开启了“自动删除已合并分支”，导致 `spec/*` 被自动删除：应按 `git-merge-recent-pr` 的规则从 PR head SHA 恢复该分支并推送回远端
9. 同步本地 `<epic-branch>` 到远端最新（fetch + fast-forward）
10. 通过单独 PR 归档该 OpenSpec 变更（同样必须走评审闭环；不要“提交→秒合并”错过自动 reviewer）：
   - 从 `<epic-branch>` 创建归档分支（建议）：`chore/archive-<spec-name>`
   - 执行：`openspec archive <spec-name> --yes`
   - 提交归档变更
   - 运行 `git-pr-review` 创建 PR（base 必须是 `<epic-branch>`；PR 中引用同一个 Issue 与 `<spec-name>`）
   - 按 `git-pr-review` / `git-resolve-pr-comments` 处理 High/Medium 评论后，再用 `git-merge-recent-pr` 合并（默认不删除 head 分支）
