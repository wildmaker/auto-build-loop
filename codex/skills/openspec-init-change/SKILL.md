---
name: openspec-init-change
description: 将 SDD Loop 中 “初始化 OpenSpec 变更 + 严格校验 + 创建 GitHub Issue + 新建分支并应用变更” 封装成可复用流程。
version: 0.2.1
---

# Skill: openspec-init-change

## Trigger
@openspec-init-change

## What this skill does
- 初始化一个 OpenSpec 变更（change）
- 严格校验该变更（strict validate）
- 创建或对齐对应的 GitHub Issue，并写清 scope 与验收标准
- 确保实现分支就绪（`spec/<id>`）：为后续 `/openspec:apply <id>` 与编码准备（是否执行 apply 由调用方决定）

## Inputs
- `<id>`: OpenSpec change ID（例如：`add-user-search`）
- `<issue-title>`: GitHub Issue 标题（建议与 `<id>` 对齐）
- `<branch>`: spec 开头的 Git 分支名（默认建议：`spec/<id>`）
- （可选）`<issue>`：若 Issue 已存在（例如 `#123` 或 issue URL），必须复用并禁止创建重复 Issue
- （可选）`<priority>`：用于 issue label 的优先级（`P0|P1|P2|P3`；默认 `P1`）

## Constraints
- change 内容必须最小化且聚焦（只包含本次需求的 spec deltas）
- 必须通过 `openspec validate <id> --strict` 后，才进入实现分支开始写代码
- GitHub Issue 必须包含：变更范围（scope）与验收标准（acceptance criteria）
- 若 `<issue>` 已提供：只允许对齐/引用，不得新建 Issue（避免与 Plan 阶段 backlog-issue-sync 重复）
  - 允许补齐缺失 labels（不改标题/正文）：至少 `type/spec` + `priority/Px`

## Allowed commands
- `openspec`
- `git`
- `gh`

## Steps
### 0) 准备实现分支（必须）
- 确保当前在 `<branch>`（建议 `spec/<id>`）：
  - 若分支不存在：从正确的基座分支创建（由调用方保证 base，例如 `epic/<epic-name>`）
  - 若分支存在：切换到该分支并拉取最新

### 1) 创建或复用 OpenSpec 变更
- 若 `OpenSpec/changes/<id>` 已存在：复用（不要重复创建）
- 否则执行：
  - `openspec new change <id>`
- 在变更目录内补全最小内容（先保证可校验，可在实现过程中迭代完善）：
  - `proposal.md`：变更动机 / 范围 / 非目标 / 风险
  - `tasks.md`：实现子任务拆分（允许先写骨架）
  - `OpenSpec/changes/<id>/specs/`：本次 spec deltas（只写与该变更相关的最小差异）

### 2) 严格校验 OpenSpec 变更（强制）
- 执行：
  - `openspec validate <id> --strict`
- 若失败：修正 change 内容直到 strict validate 通过（不得跳过）

### 3) 创建或对齐 GitHub Issue（强制）
- 若已提供 `<issue>`：对齐并复用
  - 用 `gh issue view` 验证其存在，并记录 issue 编号/链接用于后续 PR 引用
  - 若缺少 labels：补齐 `type/spec` 与 `priority/Px`（默认 `priority/P1`；用 `gh label list/create` 确保 labels 存在，再用 `gh issue edit --add-label` 添加）
- 若未提供 `<issue>`：创建新 Issue
  - title：使用 `<issue-title>`（建议与 `<id>` 对齐）
  - body 必须包含：
    - Scope（本变更覆盖哪些能力/模块；不包含什么）
    - Acceptance criteria（可验证的验收标准，条目化）
    - Links：指向 `OpenSpec/changes/<id>`（如 repo 约定使用相对路径引用）
  - labels（必选）：
    - `type/spec`
    - `priority/Px`（默认 `priority/P1`；若提供 `<priority>` 则用之）
    - 创建 issue 前：先确保 labels 存在（`gh label list` / `gh label create`）

### 4) 输出对齐结果（供调用方继续）
- 返回/记录：
  - `<id>`（change ID）
  - `<branch>`（实现分支）
  - `<issue>`（issue 编号/链接）
- 说明：是否执行 `/openspec:apply <id>` 由调用方决定（例如 `epic-sdd-loop` 的下一步）
