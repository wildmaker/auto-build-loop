# auto-build-loop

```text
                  .-========================-.
              .-==                            ==-.
           .-==      __                __        ==-.
         .==        /  \____    ____/  \          ==.
        ==         /  /\___ \__/ ___/\  \          ==
       ==         /__/    \  ____  /  \__\          ==
       ==         \  \__  / /    \ \  /  /          ==
        ==         \____\/_/  /\  \_\/__/          ==
         .==                 /  \                 ==.
           .-==             / /\ \             ==-.
              .-==         /_/  \_\         ==-.
                  '-========================-'

                     auto-build-loop
```

## Quick Start

先完成以下 2 步，再触发自动化流程：

1. 使用 GPT PRO 产出整体设计思路，并将文档保存到项目内（例如 `docs/blueprint.md`）。
2. 在 CLI 中使用 `@auto-build-v2` 并附上文档路径。

```bash
@auto-build-v2 docs/blueprint.md
```

这个目录用于分发 Epic 自动化开发流程（Plan -> SDD Loop -> Review/Demo -> Stabilization -> Merge）。

## Prerequisites

在运行本 Skill Pack 前，请先完成以下准备工作。

### 1) 基础环境

- 安装 `git`、`gh`（GitHub CLI）、`node`（若你的项目依赖前端工具链）、`python`（若你的项目依赖 Python 工具链）。
- 完成 `gh auth login`，确保当前仓库可创建/查看 Issue 与 PR。

### 2) 安装并初始化 OpenSpec

- 安装 OpenSpec CLI（按你团队的标准安装方式）。
- 在仓库根目录初始化 OpenSpec（只需一次）：
  - 若你已安装本仓库 skill：使用 `openspec-init` skill 执行初始化。
  - 或直接使用 OpenSpec CLI 完成 init，并确认 `OpenSpec/` 目录已生成。
- 初始化后建议先跑一次校验命令（例如 validate/lint）确认环境可用。

### 3) 初始化 Codex 技能环境（推荐）

- 将本仓库技能链接到本地 `~/.codex/skills`：
  - `bash codex/skills/sync-codex-skills-to-cloud/scripts/link_repo_skills_to_codex.sh`
- 验证关键技能可见：`epic-auto-build-v2`、`epic-sdd-loop`、`openspec-init-change`、`git-pr-review`。

### 4) 使用 Codex 或 Claude 初始化项目上下文

- Codex 路径（推荐）：
  - 在仓库根目录准备 `AGENTS.md`（项目约束、分支策略、测试命令、文档路径约定）。
  - 如需 OpenSpec 引导内容，可执行 `openspec-init` 并按提示把 bootstrap 规则写入 `AGENTS.md`。
- Claude 路径（可选）：
  - 在 Claude Code 中打开同一仓库，补齐等价的项目约束文档（例如 `AGENTS.md`/`CLAUDE.md`）。
  - 确保与本 README 的流程约束一致：`main -> epic/* -> spec/*`，以及 `spec/* -> epic/*` 的 PR 方向。

### 5) 启动 Epic 流程前检查清单

- 已有明确设计文档（Blueprint/PRD/Tech Plan）。
- 已确定 `<epic-name>`，并约定 `epic/<epic-name>` 分支名。
- 仓库根目录将使用唯一 `BACKLOG.md` 作为执行源。
- 团队已同意 Review Gate：等待远端 review + 处理 High/Medium + CI 全绿后合并。
- 已为 AI Agent 提供足够权限（permission）：至少允许读取/修改仓库文件、创建分支、执行 `git`/`gh`/`openspec` 命令；若权限不足，`epic-auto-build-v2` 会在中途阻塞。

## Included workflow entry points
- epic-auto-build-v2
- epic-stabilization
- codex/skills/epic-auto-build-v2/references/epic-workflow.md

## Included dependent skills
- epic-breakdown
- epic-sdd-loop
- epic-engineering-sign-off
- epic-review-demo
- epic-issue-triage
- epic-fix-stabilization
- epic-merge-to-main
- blueprint-compiler
- backlog-generate
- backlog-issue-sync
- backlog-write-back
- openspec-init-change
- git-pr-review
- git-merge-recent-pr
- git-create-pr
- git-resolve-pr-comments
- check-env
- report-it-to-me
- xmind

## Simple workflow overview

```mermaid
flowchart TD
    A["1. Planning & Scope Lock<br/>- 明确目标与交付边界<br/>- 拆分可独立完成的工作项<br/>- 建立统一工作基线"] --> B["2. Iterative Delivery Loop（一次一个工作项）<br/>- 选择一个未完成任务<br/>- 在隔离环境中实现<br/>- 本地校验 + 自动化检查<br/>- 提交审查（PR / CI）<br/>- 合并到集成分支"]
    B --> C{"是否还有未完成项"}
    C -- 是 --> B
    C -- 否 --> D["3. Integrated Review / Demo<br/>- 全量功能可运行<br/>- 与最初目标对齐<br/>- 工程层面完成确认"]
    D --> E["4. Stabilization & Triage<br/>- 集中测试<br/>- 问题分类与分流"]
    E --> F["Implementation Bugs / Gaps<br/>- 修复实现<br/>- 补测试"]
    E --> G["Requirement / Behavior Change<br/>- 回到迭代流程<br/>- 重新定义目标"]
    F --> H["重新进入 2 或 4"]
    G --> H
    H --> I["5. Release / Merge to Main<br/>- 明确发布条件满足<br/>- 合并至主线<br/>- 标记交付完成"]
    I --> J["6. Post-Completion Cleanup（可选）<br/>- 归档过程产物<br/>- 清理临时分支 / 资源<br/>- 必须显式确认"]
```

## Flow canvas

> 目标：用一张图快速说明 `epic-auto-build-v2` 的执行阶段、强约束与回路。

```mermaid
flowchart TD
    A[Start: User explicitly triggers epic-auto-build-v2] --> B[Phase 1 Plan\nepic-breakdown]
    B --> B1[Output:\nImplementation Plan.md\nBACKLOG.md Epic section\nIssues aligned\nepic/<epic-name> branch]
    B1 --> G1{Plan gate passed?}
    G1 -- No --> BX[Stop: complete Plan artifacts first]
    G1 -- Yes --> C[Phase 2 SDD LOOP\nPick first unfinished backlog item]

    C --> C1[Map item -> Issue + spec-name\nCreate spec/<spec-name> from epic branch]
    C1 --> C2[openspec-init-change + apply\nImplement + local checks]
    C2 --> C3[Create PR: spec/* -> epic/*\nReview loop + CI green]
    C3 --> C4[Merge to epic/*\nArchive spec change via archive PR]
    C4 --> D{More unfinished items?}
    D -- Yes --> C
    D -- No --> E[Phase 3 Review/Demo\nengineering-sign-off -> review-demo\nGenerate EPIC-REPORT]

    E --> F[Phase 4 Stabilization\ntriage issues from testing]
    F --> F1{Issue type?}
    F1 -- Fix --> F2[epic-fix-stabilization\nFix-only: bug/test/spec-alignment]
    F1 -- Change --> F3[Back to SDD LOOP via epic-sdd-loop]
    F2 --> F4{ready_for_merge = true?}
    F3 --> F4
    F4 -- No --> F
    F4 -- Yes --> H[Phase 5 Merge\nepic/* -> main]

    H --> I[Post phase\nOptional: delete merged spec/* branches\nonly with explicit user confirmation]
    I --> J[Done]
```

### Reading Guide

- `Phase 1` 是硬门禁：没有 `Plan + Backlog + Issues + epic branch`，后续全部不允许开始。
- `Phase 2` 是单条循环：一次只做一个 backlog item，且必须走 `spec/* -> epic/*`，不能直连 `main`。
- `PR Gate` 是必经点：必须等远端 review 出现并闭环 High/Medium，且 CI 全绿后才可合并。
- `Phase 4` 是收敛分流：Fix 留在稳定化链路，Change 回流到 `SDD LOOP` 重新走 Spec 驱动交付。
- 只有 `ready_for_merge: true` 才能进入 `epic/* -> main`。
- `spec/*` 分支默认保留，只有在 Epic 完成后且用户明确确认才批量清理。
