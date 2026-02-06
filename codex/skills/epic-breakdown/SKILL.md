---
name: epic-breakdown
description: 将复杂变更的 Phase 1（Blueprint -> Implementation Plan -> Backlog -> Issue 对齐 -> 建立 Epic 分支）模块化封装为可复用流程。
version: 0.2.1
---

# Skill: epic-breakdown

## Trigger
@epic-breakdown

## What this skill does
- 调用 `blueprint-compiler` 将 Blueprint（设计/方案）编译为 repo-aware 的 `Implementation Plan.md`
- 将计划拆分为根目录 `BACKLOG.md` 中一个以 `<epic-name>` 命名的 Epic 分组（items 原子化）
- 为每个 backlog item 创建/对齐 GitHub Issue，并在需要时回写到 `BACKLOG.md`
- 从 `<base-branch>` 创建并推送 `<epic-branch>`（默认 `epic/<epic-name>`），为后续 `spec/*` 工作流提供稳定基座

## Inputs (recommended)
- `<blueprint-doc-path>`：Blueprint（设计/产品/技术方案）文档在仓库内的路径（可多个；也可沿用既有命名 `<design-doc-path>`）
- `<epic-name>`：Epic 标识（用于 `BACKLOG.md` 分组与 epic 分支命名，如 `user-search`）
- `<epic-docs-dir>`：本 Epic 相关文档目录（默认：`docs/<epic-name>`）
- `<base-branch>`：默认 `main`
- `<epic-branch>`：默认 `epic/<epic-name>`

## Outputs
- `Implementation Plan.md`（推荐路径：`<epic-docs-dir>/Implementation Plan.md`）
- 根目录 `BACKLOG.md`（新增/更新本次 `<epic-name>` Epic 分组与原子化 items）
- GitHub Issues（与 backlog items 一一对应；必要时回写编号到 `BACKLOG.md`）
- 远端分支 `<epic-branch>`（默认 `epic/<epic-name>`）
- `BACKLOG.md` 的 Epic 分组头部包含 `Epic branch` 与其 GitHub URL（便于追溯与跳转）

## Constraints
- 仅负责 Epic 的拆解与初始化（Plan/Backlog/Issue/Epic branch）；**不进入编码与实现阶段**。
- 一个 repo **只允许存在一个**根目录 `BACKLOG.md`；不得为 Epic 创建独立 backlog 文件。
- 不臆测缺失需求：设计/验收不清晰时，必须在 `Implementation Plan.md` 或 `BACKLOG.md` 中标注 TBD/风险/依赖。
- 本阶段产物（`Implementation Plan.md`、`BACKLOG.md`、以及 Plan 阶段生成的辅助文档如 preflight 报告）**必须提交并推送到 `<epic-branch>`**；不要把 Plan 停留在 “uncommitted changes” 状态。
- **分支强约束**：
  - `main` → `epic/<epic-name>` → `spec/<spec-name>`
  - 后续所有 `spec/*` 分支必须基于 `<epic-branch>` 创建；禁止直接基于 `main`。

## Allowed commands
- `blueprint-compiler`
- `backlog-generate`
- `backlog-issue-sync`
- `git`
- `gh`
- `rg`

## Steps
0. 准备文档目录（必须先做）
   - 确保 `<epic-docs-dir>` 存在（默认 `docs/<epic-name>`）
   - 本阶段新生成的文档（Plan、预检报告等）必须写入该目录（不要直接堆在 `docs/` 根目录）
1. 准备分支基座（必须先做）
   - 确保工作区干净（无未提交改动），并确保 `<base-branch>` 已更新（fetch + pull/fast-forward）
   - 从 `<base-branch>` 创建/切换到 `<epic-branch>`（默认 `epic/<epic-name>`）
   - 若 `<epic-branch>` 不存在远端：推送并建立上游（`-u`）
   - 若 `<epic-branch>` 已存在：校验它是否符合预期（存在于远端、且作为后续 `spec/*` 的唯一基座）
   - 记录 Epic 分支的 GitHub URL（后续要写入 `BACKLOG.md` 的 Epic 头部）：
     - `repo_url`：`gh repo view --json url --jq .url`
     - `epic_branch_url`：`<repo_url>/tree/<epic-branch>`
2. 运行 `blueprint-compiler`
   - 输入：`<blueprint-doc-path>`
   - 输入（可选但推荐）：`<output-dir> = <epic-docs-dir>`
   - 产出：`<epic-docs-dir>/Implementation Plan.md`（或按 blueprint-compiler 的输出规则）
3. 运行 `backlog-generate`
   - 输入：`<epic-docs-dir>/Implementation Plan.md` + `<blueprint-doc-path>`
   - 产出：在根目录 `BACKLOG.md` 中追加/更新一个以 `<epic-name>` 命名的 Epic 分组，写入原子化 items
   - item 命名建议：优先让 item ID 可映射为稳定的 `<spec-name>` slug（因为它会同时作为分支名与后续 OpenSpec change/spec ID）
   - **必须**在该 Epic 分组头部补齐/更新（若 repo 已有格式则就地融入，保持最小 diff）：
     - `Epic branch: <epic-branch>`
     - `Epic branch URL: <epic_branch_url>`
4. 运行 `backlog-issue-sync`
   - 为每个 backlog item 创建/对齐 GitHub Issue
   - 将 issue 编号回写到 `BACKLOG.md`
5. 提交并推送 Plan 产物（必须）
   - 将 `<epic-docs-dir>/Implementation Plan.md`、`BACKLOG.md`、以及本阶段生成的辅助文档（如 preflight 报告）提交到 `<epic-branch>`
   - 提交信息建议：`chore(plan): add implementation plan & backlog for <epic-name>`
   - 推送 `<epic-branch>` 到远端，确保后续 `spec/*` 基于已提交的 Plan 基座开展

## Exit criteria（进入实现阶段前必须满足）
- `Implementation Plan.md` 已存在且能指导执行
- `BACKLOG.md` 已包含本 Epic 分组，且 items 原子化、可独立交付
- backlog items 与 issues 已完成对齐（至少每个 item 可追踪到一个 issue）
- 本地与远端已存在 `<epic-branch>`（默认 `epic/<epic-name>`），且 Plan 产物已提交并推送在该分支上

