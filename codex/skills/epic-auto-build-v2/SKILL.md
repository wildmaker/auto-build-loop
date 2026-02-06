---
name: epic-auto-build-v2
description: Epic auto build v2 编排器：严格执行 epic-workflow.md 的 Complex-Change Workflow（Plan -> SDD LOOP -> Epic Review/Demo -> Epic Stabilization -> Merge）。
version: 0.6.1
---

# Skill: epic-auto-build-v2

## Trigger
@epic-auto-build-v2

## What this skill does
- 将一次“从设计到交付”的复杂变更工作流收敛为五个阶段，并**严格遵循本技能内置的 `references/epic-workflow.md` 关系模型与分支约束**（若仓库根目录存在 `epic-workflow.md`，可视为同等权威参考）：
  - Plan：产出 `Implementation Plan.md`，并把设计拆分为根目录 `BACKLOG.md` 中的一个 Epic（含 Issue 对齐）
  - SDD LOOP：按 `references/SDD-LOOP.md` 的标准流程逐条完成 backlog item（一次只做一个；若仓库根目录存在 `SDD-LOOP.md`，可视为同等权威参考）
  - Epic Review / Demo（价值验收）：按 Plan 阶段定义的 Demo 目标与流程进行核心主场景演示，并汇总为报告（可选导图化）
  - Epic Stabilization（稳定化收敛）：基于人工测试问题清单做分流，Fix 走集中修复，Change 回到 Spec 驱动开发，回归后达到可合并稳定态
  - Merge to base：将 `<epic-branch>` 合并回 `<base-branch>`（默认 `main`）

## Source of truth
- `references/epic-workflow.md`：关系模型（Doc -> Backlog -> Epic -> Issue -> Spec Change -> Task）与分支/合并强约束
- `references/SDD-LOOP.md`：每个 backlog item 的标准循环（本技能按 `epic-workflow.md` 的术语直接执行）

## Inputs (recommended)
- `<design-doc-path>`：设计/产品/技术方案文档在仓库内的路径（可多个）
- `<epic-name>`：该次复杂变更的 Epic 标识（用于 backlog 分组与 epic 分支命名，如 `user-search`）
- `<epic-docs-dir>`：本 Epic 相关文档目录（默认：`docs/<epic-name>`）
- `<base-branch>`：默认 `main`
- `<epic-branch>`：默认 `epic/<epic-name>`

## Outputs
- `Implementation Plan.md`：开发计划（阶段/里程碑/依赖/风险；推荐路径：`<epic-docs-dir>/Implementation Plan.md`）
- `BACKLOG.md`：根目录 backlog（包含多个 Epic；本次变更对应其中一个 Epic）
- `BACKLOG.md` 的本 Epic 分组头部包含 `Epic branch` 与 `Epic branch URL`（GitHub 可点击跳转）
- GitHub Issues：与本 Epic 下的 backlog items 一一对应（必要时通过 `backlog-write-back` 回写到 `BACKLOG.md`）
- Branches & PRs：遵循 `main -> epic/<epic-name> -> spec/<spec-name>`；每个 item 通过 `spec/*` PR 合并回 `epic/*`；Epic 完成后再由 `epic/*` 合并回 `main`
- 项目汇总报告（Markdown + 可选生成 `.xmind`；默认位于 `<epic-docs-dir>`）

## Constraints
- 仅在用户明确提出 “epic auto build / epic-auto-build-v2”（旧名：auto-build-v2）时启用本技能。
- **未完成 Plan 阶段（至少包含：`Implementation Plan.md` + `BACKLOG.md` + issues 对齐）前不得开始编码。**
- 一个 repo **只允许存在一个**根目录 `BACKLOG.md`；不要为 Epic 新建子目录或独立 backlog 文件。
- **关系模型强约束（来自 `epic-workflow.md`）：**
  - 一个 Tech Implementation Plan（或等价设计文档集合）对应 `BACKLOG.md` 中的一个 Epic
  - 一个 backlog item（本技能中）= 一个 Issue = 一个 Spec Change（OpenSpec 变更目录）
  - Spec Change 是该 Issue 的唯一设计权威（single source of truth），内部再拆 Task
- **分支模型强约束（来自 `epic-workflow.md`）：**
  - `main` → `epic/<epic-name>` → `spec/<spec-name>`
  - `spec/*` 的 base 必须是对应 `epic/*`；禁止直接基于 `main`
  - 合并只能：`spec/*` → `epic/*`；Epic 完成后：`epic/*` → `main`
- **PR 评审闭环强约束（防止“提交→秒合并”错过自动 review）**：
  - 合并任何 PR（包括归档 OpenSpec change 的 PR）前，必须完成 `git-pr-review` → `git-resolve-pr-comments` 的 High/Medium 评论闭环
  - 必须等待远程 reviewer（含自动 reviewer，例如 gemini-code-assist）产生 review/comments 后再做 merge 决策（按 `git-resolve-pr-comments` 的轮询约束执行）
- **Spec 分支保留强约束（禁止自动删除）**：
  - 合并 `spec/*` PR 时**不得**使用 `--delete-branch`
  - 若 repo 设置导致 merged 后自动删除 `spec/*`：必须按 `git-merge-recent-pr` 的规则从 PR head SHA 恢复远端 `spec/*`（用于 Epic 完成后的统一清理）
  - 只有在 Epic 完成且用户明确确认后，才允许批量删除本 Epic 的 `spec/*` 分支
- **文档落盘强约束（目录规范）**：
  - 本 Epic 新生成的文档/报告（Plan 附属文档、Demo 记录、Review 报告、Stabilization 问题清单等）必须放在 `<epic-docs-dir>`（默认 `docs/<epic-name>`）
  - **禁止**将新生成文档直接写在 `docs/` 根目录
- **Phase 3 产物强约束（不得跳过）**：
  - 必须生成项目汇总 Markdown（推荐：`<epic-docs-dir>/EPIC-REPORT.md`）
  - 必须运行 `report-it-to-me` 产出导图化产物（至少 `*.xmind.json`；`.xmind` 可选）
  - 以上产物必须提交并推送到 `<epic-branch>`；否则不得进入 Phase 5（Merge to base）
- SDD LOOP 阶段必须遵循 `references/SDD-LOOP.md`（或仓库根目录同名文件）；每次只处理一个 backlog item（一次只推进一个 `spec/*`）。
- 不臆测缺失需求：设计/验收不清晰时，先在 Plan 阶段标注 TBD + 风险 + 获取信息的建议；**默认不因“需要人类决策”而中断询问**（除非用户显式要求交互确认）。

## Autonomy defaults（默认无人监督 / 不要停下来问人）
- 本技能默认以 **Autonomous / 无人监督** 模式执行：不要在阶段边界停下来让用户“选择下一步/选择从哪个 item 开始”。
- 所有可选决策采用确定性默认策略（除非用户显式覆盖）：
  - Backlog item 选择：从 `BACKLOG.md` 的目标 Epic 分组内，按文件出现顺序选择**第一个未完成条目**（通常就是该分组内第一条未完成条目）。
  - 遇到阻塞（缺上下文/缺权限/缺 env/跑不通）：将该条目标记为 `Blocked` 并写明原因，继续下一个条目；不要反复询问。
  - PR 默认：title/body/base 都可由 backlog item + `<epic-branch>` + Spec Change 推导，不需要“确认后再做”。

## Allowed commands
- `blueprint-compiler`
- `backlog-generate`
- `backlog-issue-sync`
- `backlog-write-back`
- `epic-breakdown`
- `epic-sdd-loop`
- `epic-engineering-sign-off`
- `epic-review-demo`
- `epic-stabilization`
- `epic-issue-triage`
- `epic-fix-stabilization`
- `openspec-init-change`
- `backlog-item-execute`
- `git-pr-review`
- `git-merge-recent-pr`
- `report-it-to-me`
- `epic-merge-to-main`
- `git`
- `gh`
- `openspec`
- `rg`

## Workflow (5 phases)

### Phase 1: Plan（拆分 BACKLOG）
1. 运行 `epic-breakdown` 完成 Plan 阶段（输入/产出/退出条件以该 skill 定义为准）。
   - 自检：`BACKLOG.md` 的目标 Epic 分组头部必须包含：
     - `Epic branch: epic/<epic-name>`
     - `Epic branch URL: <repo_url>/tree/epic/<epic-name>`
   - 若缺失：用 `backlog-write-back` 的 `epic_meta_update` 补齐（保持最小 diff）。
2. 若 Plan 阶段产物（`Implementation Plan.md` / `BACKLOG.md` / 预检报告等）仍处于未提交状态：将其**提交并推送到 `<epic-branch>`**，确保后续 `spec/*` 都能以该基座为准。
3. 在 Plan 文档中**明确 Demo 的目标与流程**（必须可执行、可复用），至少补充到 `Implementation Plan.md`：
   - Demo 的价值目标（本 Epic 的核心主场景要证明什么）
   - Demo 前置条件：环境/依赖服务/账号与数据准备/关键环境变量清单
   - 如何运行：安装依赖 + Build 或启动项目的命令（含目录、package manager、端口等）
   - Demo 流程：逐步操作脚本（Step-by-step）+ 每步期望看到的结果
   - 失败兜底：若无法启动/构建，替代演示方式（截图/录屏/日志/CLI 输出）与可接受的验收口径（TBD 可标注）

### Phase 2: SDD LOOP（逐条交付）
目标：按标准循环逐条完成 backlog item，确保可评审、可合并、可追踪，且**全程无需人工选择“从哪个 item 开始”。**

#### 2.1 选择下一个 backlog item（自动）
1. 读取根目录 `BACKLOG.md`，定位本次 Epic 分组：
   - 优先匹配 `## <epic-name>`（或 `## Epic: <epic-name>` 等同义标题）
   - 若 `<epic-name>` 缺失：从 `<epic-branch>`（如 `epic/<epic-name>`）推导
2. 在该 Epic 分组下收集 backlog items，并过滤已完成条目（如 `Done` / `✅` / `- [x]` 等）。
3. 选择**第一个未完成条目**作为 `next_item`（默认即分组内第一条未完成条目）。**不要询问用户要从哪条开始。**

#### 2.2 将 backlog item 映射为 SDD LOOP 输入（自动）
对 `next_item` 解析/推导：
- `<issue>`：若条目里已有 `#123` / issue URL，则复用；否则允许后续流程创建。
- `<spec-name>`（稳定 slug）：
  - 若条目是块级标题形式（例如 `### <spec-name>`）：直接使用标题文本作为 `<spec-name>`；
  - 若 item ID 本身是 slug（如 `timelogger-tab-wireup`），直接使用；
  - 若条目为 `BL-xxx <slug>` 形式，使用 `<slug>`；
  - 否则从标题生成 slug（小写 + `-` 连接），确保稳定且唯一。
- `<issue-title>`：**默认使用 `<spec-name>`**（只用 spec slug；不得包含 `BL-xxx` 前缀）。人类可读的描述请放在 issue body / backlog 描述中。
- `<priority>`：若条目包含 `[P0|P1|P2|P3]`，解析并传入（用于 issue labels）；否则留空由下游默认。

#### 2.3 执行并回写（循环）
1. 调用 `epic-sdd-loop` 完成交付（一次只做一个）。
2. 合并完成后，调用 `backlog-write-back` 回写该条目的：
   - `status: Done`
   - `issue` / `pr` / `spec_change`（如 `OpenSpec/changes/<spec-name>`）等引用
3. 重复 2.1–2.3，直到本 Epic 分组内无未完成条目。

#### Epic 收尾（所有 spec 完成后）
- 运行 `epic-engineering-sign-off` 完成 Epic Completion Check（Backlog Consistency / Spec Closure / Branch Integrity），通过后才允许进入 Epic Review

### Phase 3: Epic Review / Demo（价值验收）
目标：按 Plan 阶段定义的 Demo 目标与流程完成价值验收；并把“做了什么、交付了什么、怎么验证”汇总给人类快速审阅（可选导图化 `.xmind`）。

1. 在 `<epic-docs-dir>` 下生成项目汇总 Markdown（禁止写在 `docs/` 根目录）
   - 推荐路径：`<epic-docs-dir>/EPIC-REPORT.md`
   - 必须包含：范围 / 交付清单（按 backlog items）/ 关键决策与风险 / 测试与验收建议 / 链接（Issues、PRs、可选 OpenSpec 变更）
2. 运行 `report-it-to-me`
   - 输入（必填）：项目汇总 Markdown 的路径（`<markdown-path>`，建议即上一步的 `.../EPIC-REPORT.md`）
   - 输入（可选）：`<xmind-path>`（默认与 Markdown 同目录、同名 `.xmind`）、`<root-title>`、`<json-path>`（默认同目录 `*.xmind.json`）
   - 输出：单个 `.xmind` 文件（建议 `open <xmind-path>` 用系统默认应用打开检查）
3. 运行 `epic-review-demo` 按 Plan 阶段文档定义进行 Demo（输入/产出/约束以该 skill 定义为准）
4. 将 Phase 3 的产物提交并推送到 `<epic-branch>`（至少提交 Markdown；`.xmind` 若不适合入库可只提交 `*.xmind.json`）

### Phase 4: Epic Stabilization（Demo 后稳定化收敛）
目标：在 Demo 之后，通过人工测试驱动的问题收敛，使 Epic 达到稳定态与可合并条件。

1. 组织并完成集中测试（Integration / E2E / UAT / Exploratory），生成问题清单（即便为空也需明确“已测试且无问题”）
2. 运行 `epic-stabilization`（仅在 demo 之后）
   - 该流程会调度：`epic-issue-triage` →（Fix）`epic-fix-stabilization` /（Change）`epic-sdd-loop`
3. 只有当 `ready_for_merge: true` 时，才进入合并阶段；否则停止并输出阻塞项/未闭环问题清单

### Phase 5: Merge to base（合并回主分支）
1. 将 `<epic-branch>` 合并回 `<base-branch>`（默认 `main`）
   - 推荐使用 `epic-merge-to-main` 来创建/评审/合并该 Epic PR（或使用 `gh pr create` 手动完成）

### Post Phase: Spec branches cleanup（需要用户确认）
目标：在 Epic 全部完成后，统一清理本 Epic 的 `spec/*` 分支；**默认保留，不自动删除**。

1. 汇总本 Epic 涉及的 `spec/*` 分支候选列表：
   - 优先从 `BACKLOG.md` 的条目映射得到 `<spec-name>` 列表
   - 兜底：从 GitHub 已合并的 `spec/* → <epic-branch>` PR 列表中收集 `headRefName`
2. 输出候选列表并询问用户一次（Yes/No）：是否批量删除这些**已合并**的远端 `spec/*` 分支？
3. 仅当用户明确确认后才执行删除；否则跳过并保留全部分支。

