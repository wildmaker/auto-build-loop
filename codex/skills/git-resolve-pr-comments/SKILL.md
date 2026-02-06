---
name: git-resolve-pr-comments
description: 提供 git-resolve-pr-comments 的操作流程与约束；适用于 需要拉取 PR 评论并处理高/中优先级意见时使用。
version: 0.2.0
---

# git-resolve-pr-comments

## What this skill does
- 切换到 PR 分支并拉取最新代码
- 使用 GitHub CLI 等待远程 review（含自动 reviewer，如 gemini-code-assist），拉取评论并轮询
- 解决高/中优先级评论并给出汇总

## Constraints
- 每次轮询间隔 1 分钟，最多 15 次（默认最多等待约 15 分钟，避免“提完 PR 就合并”错过自动 review）
- 默认以 **Autonomous / 无人监督** 模式执行：产生修复时应自动 `git add` / `git commit` / `git push`（不要等待用户确认）。
- 若用户显式要求交互式处理（interactive），才允许在提交前暂停询问。
- **必须覆盖 review 的三种信号源**（否则会漏掉自动 reviewer 的意见）：
  - PR reviews（可能是 CHANGES_REQUESTED/APPROVED）
  - PR review comments（inline）
  - PR conversation comments（普通评论）
- **优先级判定采用确定性规则（不臆测）**：
  - High：review state 为 `CHANGES_REQUESTED`；或评论文本包含显式标记（如 `High`/`P0`/`blocker`/`必须`/`阻塞`/`security`/`crash`/`data loss`）
  - Medium：评论文本包含显式标记（如 `Medium`/`P1`/`should`/`建议`/`推荐`/`needs`）
  - Low：其余（例如纯风格/拼写/nit），可选处理但不作为 merge gate

## Allowed commands
- `git`
- `gh`
- `sleep`

## Steps
1. 切换并拉取 PR 分支。
   - 默认假设当前分支就是 PR 分支；若不是，则用 `gh` 自动定位对应 PR（例如按当前分支的 headRefName 查找）。
   - 若仍无法确定目标 PR/分支：停止并输出阻塞项清单（不要询问用户“是哪一个”）。
2. 等待远程 review/评论出现（避免错过自动 reviewer，如 gemini-code-assist）。
   - 轮询策略：每 1 分钟检查一次，最多 15 次；若已出现任意 reviews 或 review comments，则可提前进入处理阶段。
   - 必须同时查看：
     - reviews（含 state）
     - review comments（inline）
     - conversation comments
3. 汇总并分流评论优先级（High/Medium/Low），并只对 High/Medium 做强制闭环：
   - High/Medium：必须给出“已修复”或“无法修复的明确理由 + 替代方案/后续动作”
   - Low：可选处理；不处理也需在汇总里标注为 Low（避免漏看）
4. 处理 High/Medium 评论：
   - 逐条落实到代码改动或文档/说明
   - 对应的回复策略：简短说明“如何修/为何不修/如何验证”
5. 若产生代码改动：直接执行 `git add`、`git commit`、`git push` 推送到 PR 原分支。
   - 提交信息建议：`fix(review): address PR comments`（或包含 backlog/spec id 以便追踪）
6. 复查（最多 2 轮）：
   - 推送后再次拉取 PR 评论/状态，确认 High/Medium 已清零或已被明确处置
   - 若仍存在新的 High/Medium（例如自动 reviewer 在你 push 后再次给出意见），继续处理直到满足退出条件或达到复查上限并输出阻塞项
