---
name: epic-auto-build-v2-repo-init
description: 初始化一个新仓库以便使用 epic-auto-build-v2 全流程自动化开发：先调用 openspec-init，再把 Autonomous 连续执行约束写入目标仓库 Agent.md 的执行清单。
version: 0.1.0
---

# Skill: epic-auto-build-v2-repo-init

## Trigger
@epic-auto-build-v2-repo-init

## What this skill does
- 为目标仓库完成 epic-auto-build-v2 自动化开发的初始化准备。
- 强制串联两个动作：
  1. 调用 `openspec-init` 完成 OpenSpec 初始化。
  2. 将“路由后不中断”的执行约束写入目标仓库 `Agent.md` 的执行清单，降低模型偏航概率。

## Inputs
- `<repo>`: 目标仓库路径（默认：当前仓库）

## Hard constraints
- 必须先执行 `openspec-init`，再更新 `Agent.md`。
- `Agent.md` 更新必须幂等：同一约束不得重复追加。
- 若 `Agent.md` 不存在，必须创建并写入“执行清单”段落后再追加约束。
- 未经用户明确要求，不修改 `CLAUDE.md`、`AGENTS.md` 或其他流程文件。

## Required policy block (must be inserted verbatim)
```md
请按 epic-auto-build-v2 全流程自动执行。
要求：Autonomous 模式，不要在路由选择后暂停或等待确认。
路由判定后立即进入对应后续阶段并持续推进，直到遇到真正阻塞（按 Blocked 规则处理并继续下一项）。
```

## Allowed commands
- `rg`
- `cat`
- `sed`
- `git`

## Steps
1. 定位目标仓库
- 若提供 `<repo>`：进入该目录。
- 否则使用当前仓库根目录（可用 `git rev-parse --show-toplevel` 确认）。

2. 调用 `openspec-init`
- 按 `codex/skills/openspec-init/SKILL.md` 完整执行初始化流程。
- 若 OpenSpec CLI 缺失，先安装后再执行 `openspec init`。

3. 更新目标仓库 `Agent.md` 执行清单
- 目标文件：`<repo>/Agent.md`。
- 若不存在：创建最小结构并包含 `## 执行清单` 段落。
- 在“执行清单”中加入 `Required policy block`（逐字一致）。
- 若文件中已包含该 block 的任意一行（建议用第一行作为锚点）：
  - 视为已配置，禁止重复追加。

4. 最小校验
- 校验 `Agent.md` 中能检索到以下三行：
  - `请按 epic-auto-build-v2 全流程自动执行。`
  - `要求：Autonomous 模式，不要在路由选择后暂停或等待确认。`
  - `路由判定后立即进入对应后续阶段并持续推进，直到遇到真正阻塞（按 Blocked 规则处理并继续下一项）。`

## Exit criteria
- `openspec-init` 已在目标仓库执行完成。
- `Agent.md` 执行清单已包含且仅包含一份 `Required policy block`。
