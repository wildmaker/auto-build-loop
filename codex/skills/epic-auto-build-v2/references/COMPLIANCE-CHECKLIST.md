# epic-auto-build-v2 Compliance Checklist

> **用途**：在 AI 执行完 `epic-auto-build-v2` 全流程后，由人类或另一个 AI 逐项核验执行遵循度。
> **评分方式**：每项标记 `[x]` 通过 / `[ ]` 未通过 / `[N/A]` 不适用，最终统计通过率。

## 检查项标签说明

| 标签 | 含义 | 数据来源 | AI 评价者操作建议 |
|------|------|----------|-------------------|
| `🤖 AUTO` | AI 可通过检查仓库工件自动判定 | 文件系统、`git log`、分支拓扑、GitHub PR/Issue API | 直接执行检查并标记结果 |
| `👤 HUMAN` | 需要人类审阅会话记录或手动测试 | AI 执行时的对话记录、运行时行为、手动功能验证 | **跳过**或标记 `[N/A]`，留给人类复核 |

> **AI 评价者提示**：建议先批量完成所有 `🤖 AUTO` 项，再将 `👤 HUMAN` 项汇总输出给人类复核。计算通过率时，`👤 HUMAN` 项不纳入 AI 评分，单独统计。

---

## 0. 前置条件 & 全局约束（Global Constraints）

### 0.1 触发与模式
- [ ] `👤 HUMAN` AI 仅在用户明确提出 "epic auto build / epic-auto-build-v2"（或旧名 auto-build-v2）时才启用本技能
- [ ] `👤 HUMAN` AI 全程以 **Autonomous（无人监督）** 模式运行——未在阶段边界停下来让用户"选择下一步"或"确认要不要继续"
- [ ] `👤 HUMAN` 遇到阻塞时（缺上下文/权限/env/跑不通）：标记条目为 `Blocked` 并写明原因，继续下一个条目；未反复询问用户

### 0.2 Backlog 唯一性
- [ ] `🤖 AUTO` 仓库根目录仅存在 **一个** `BACKLOG.md`（未创建子目录或独立 backlog 文件）
  > 检查方法：`find . -name 'BACKLOG.md'` 结果应只有 `./BACKLOG.md`

### 0.3 关系模型（`references/epic-workflow.md` 强约束）
- [ ] `🤖 AUTO` 1 Epic = 1 Plan = `BACKLOG.md` 中的 1 个 Epic 分组
  > 检查方法：在 `BACKLOG.md` 中搜索 `## <epic-name>`，确认只有一个匹配的 Epic 分组
- [ ] `🤖 AUTO` 1 backlog item = 1 Issue = 1 Spec Change（`OpenSpec/changes/<spec-name>`）
  > 检查方法：对比 `BACKLOG.md` 条目数 / GitHub Issues 数 / `OpenSpec/changes/` 子目录数，三者应一致
- [ ] `👤 HUMAN` Spec Change 是每个 Issue 的唯一设计权威（SSOT）；实现与验收以 Spec 为准
  > 需判断实现是否有偏离 Spec 的自行发挥

### 0.4 分支模型（`references/epic-workflow.md` 强约束）
- [ ] `🤖 AUTO` 分支层级为：`main` → `epic/<epic-name>` → `spec/<spec-name>`
  > 检查方法：`git branch -a` 确认分支命名符合 `epic/*` 和 `spec/*` 模式
- [ ] `🤖 AUTO` 所有 `spec/*` 分支的 base 均为对应 `epic/*`（未直接基于 `main`）
  > 检查方法：检查每个 `spec/*` PR 的 base branch（`gh pr list --json baseRefName,headRefName`）
- [ ] `🤖 AUTO` 合并方向正确：`spec/*` → `epic/*`；最终 `epic/*` → `main`
  > 检查方法：检查已合并 PR 的 base/head 方向
- [ ] `🤖 AUTO` `spec/*` 分支在合并后未被删除（或被自动删除后已恢复）
  > 检查方法：从已合并 `spec/* → epic/*` PR 列表收集 `headRefName`，验证远端分支仍存在

### 0.5 不臆测缺失需求
- [ ] `👤 HUMAN` 设计/验收不清晰时，在 Plan 文档中标注了 TBD + 风险 + 获取信息建议（而非自行编造需求）
  > 需人类判断 Plan 中哪些需求是设计文档已有的、哪些是 AI 自行补充的

### 0.6 编码时序约束
- [ ] `🤖 AUTO` **未完成 Phase 1（Plan）前，没有开始任何编码工作**
  > 检查方法：`git log --oneline` 确认代码文件的首次提交晚于 `Implementation Plan.md` 和 `BACKLOG.md` 的提交

---

## 1. Phase 1: Plan（拆分 BACKLOG）

### 1.1 调用 `epic-breakdown`
- [ ] `👤 HUMAN` 调用了 `epic-breakdown` 完成 Plan 阶段
  > 需检查会话记录确认调用了该 skill
- [ ] `👤 HUMAN` `epic-breakdown` 的输入/产出/退出条件符合该 skill 自身定义
  > 需对照 `epic-breakdown` SKILL.md 逐项比对

### 1.2 产出：Implementation Plan
- [ ] `🤖 AUTO` 在 `<epic-docs-dir>`（默认 `docs/<epic-slug>/`）下存在 `Implementation Plan.md`
- [ ] `🤖 AUTO` Plan 内容包含：阶段/里程碑/依赖/风险
  > 检查方法：在文件中搜索关键词 milestone/阶段/依赖/风险 等
- [ ] `🤖 AUTO` Plan 中 **明确定义了 Demo 目标与流程**，至少包含以下子项：
  - [ ] `🤖 AUTO` Demo 价值目标（本 Epic 的核心主场景要证明什么）
  - [ ] `🤖 AUTO` Demo 前置条件（环境/依赖服务/账号与数据准备/关键环境变量清单）
  - [ ] `🤖 AUTO` 如何运行（安装依赖 + Build/启动命令，含目录、package manager、端口等）
  - [ ] `🤖 AUTO` Demo 流程（逐步操作脚本 Step-by-step + 每步期望结果）
  - [ ] `🤖 AUTO` 失败兜底方案（替代演示方式与可接受验收口径）
  > 检查方法：在 `<epic-docs-dir>/Implementation Plan.md` 中搜索 Demo 相关章节标题与内容

### 1.3 产出：BACKLOG.md
- [ ] `🤖 AUTO` 根目录 `BACKLOG.md` 中包含本 Epic 对应的分组（如 `## <epic-name>`）
- [ ] `🤖 AUTO` 该 Epic 分组头部包含 `Epic branch: epic/<epic-name>`
- [ ] `🤖 AUTO` 该 Epic 分组头部包含 `Epic branch URL: <repo_url>/tree/epic/<epic-name>`
- [ ] `👤 HUMAN` backlog items 已拆分为**原子化条目**（每条可独立交付）
  > 需人类判断拆分粒度是否合理
- [ ] `👤 HUMAN` 若头部元信息缺失，使用了 `backlog-write-back` 的 `epic_meta_update` 补齐
  > 需检查会话记录确认使用了正确的回写方式

### 1.4 产出：GitHub Issues 对齐
- [ ] `🤖 AUTO` 每个 backlog item 都有对应的 GitHub Issue（编号已回写到 `BACKLOG.md`）
  > 检查方法：解析 `BACKLOG.md` 中的 `#NNN` 引用，用 `gh issue view` 验证每个 Issue 存在

### 1.5 产出：Epic 分支
- [ ] `🤖 AUTO` `epic/<epic-name>` 分支已创建并推送到远端
  > 检查方法：`git branch -r | grep epic/`
- [ ] `🤖 AUTO` Plan 阶段产物（`Implementation Plan.md` / `BACKLOG.md` / 预检报告等）已提交并推送到 `<epic-branch>`
  > 检查方法：`git log epic/<epic-name> -- '<epic-docs-dir>/Implementation Plan.md' 'BACKLOG.md'`

### 1.6 退出条件
- [ ] `🤖 AUTO` Plan 可执行 + Backlog 可逐条交付 + Issues 对齐完成 + Epic 分支存在且正确
  > 综合以上 1.2–1.5 检查项的结果

---

## 2. Phase 2: SDD LOOP（逐条交付）

### 2.1 条目选择策略
- [ ] `👤 HUMAN` 按 `BACKLOG.md` 目标 Epic 分组内**文件出现顺序**选择第一个未完成条目（未跳过、未询问用户从哪条开始）
  > 需检查会话记录确认选择顺序与交互行为
- [ ] `🤖 AUTO` 正确跳过已完成条目（`Done` / `✅` / `- [x]`）
  > 检查方法：`BACKLOG.md` 中已完成条目不应有重复执行的 PR/分支
- [ ] `🤖 AUTO` 遇阻塞时标记 `Blocked` + 原因，继续下一个条目
  > 检查方法：在 `BACKLOG.md` 中搜索 `Blocked`，确认有阻塞原因描述

### 2.2 条目映射（对每个 backlog item 核验）
> 对 Epic 中的每一个 backlog item，逐条核验以下子项。可复制本节做 N 份。

#### Item: `____`（填入 item ID，如 BL-001）
- [ ] `🤖 AUTO` 正确解析/推导了 `<issue>`（复用已有编号或由流程创建）
  > 检查方法：`BACKLOG.md` 条目中的 `#NNN` 对应有效的 GitHub Issue
- [ ] `🤖 AUTO` 正确生成了稳定 `<spec-name>` slug
  > 检查方法：`OpenSpec/changes/<spec-name>` 目录存在，slug 格式为小写+连字符
- [ ] `🤖 AUTO` 正确提取了 `<issue-title>`（去掉前缀与状态标记）
  > 检查方法：`gh issue view <NNN> --json title` 中不含 `BL-xxx` 前缀或状态标记

### 2.3 SDD LOOP 执行（对每个 backlog item 核验）

#### Item: `____`

**分支与初始化：**
- [ ] `🤖 AUTO` 从 `epic/<epic-name>` 创建了 `spec/<spec-name>` 分支
  > 检查方法：`git log --oneline spec/<spec-name>` 的首个 commit 基于 `epic/<epic-name>`
- [ ] `🤖 AUTO` Spec Change 目录存在：`OpenSpec/changes/<spec-name>`
- [ ] `👤 HUMAN` 调用了 `openspec-init-change` 初始化 OpenSpec 变更 + Issue
  > 需检查会话记录确认调用了该 skill（目录存在可辅助判断，但不能确认是通过正确 skill 创建的）

**实现与检查：**
- [ ] `👤 HUMAN` 执行了 `openspec apply <spec-name>` 应用变更
  > 需检查会话记录确认执行了该命令
- [ ] `👤 HUMAN` 执行了本地最少检查（lint/test/build 等至少一项）
  > 需检查会话记录确认执行了检查命令

**PR 评审闭环：**
- [ ] `👤 HUMAN` 调用了 `git-pr-review`
  > 需检查会话记录确认调用了该 skill
- [ ] `🤖 AUTO` PR 的 base 为 `epic/<epic-name>`（不是 `main`）
  > 检查方法：`gh pr list --json number,baseRefName,headRefName`
- [ ] `🤖 AUTO` PR 中引用了对应的 Issue 和 OpenSpec 变更
  > 检查方法：`gh pr view <NNN> --json body` 中包含 `#Issue编号` 和 `OpenSpec/changes/<spec-name>`
- [ ] `🤖 AUTO` PR 评审通过后才合并
  > 检查方法：`gh pr view <NNN> --json reviews,mergedAt` 确认有 approved review 且在 merge 之前

**合并与回写：**
- [ ] `🤖 AUTO` `spec/<spec-name>` 已合并回 `epic/<epic-name>`
  > 检查方法：`gh pr list --state merged --json headRefName,baseRefName`
- [ ] `👤 HUMAN` 本地 `epic/<epic-name>` 已同步到远端最新
  > 会话结束后无法回溯验证本地状态
- [ ] `🤖 AUTO` 调用了 `backlog-write-back` 回写：status=Done、issue/pr/spec_change 引用
  > 检查方法：`BACKLOG.md` 对应条目包含 `Done` 状态及 issue/pr/spec_change 引用字段

**归档：**
- [ ] `🤖 AUTO` 执行了 `openspec archive <spec-name> --yes` 归档 Spec Change
  > 检查方法：`OpenSpec/changes/<spec-name>` 已移至归档目录，或目录内含归档标记

### 2.4 循环完整性
- [ ] `🤖 AUTO` 本 Epic 分组内**所有**未被 `Blocked` 的条目都已按上述流程完成
  > 检查方法：`BACKLOG.md` 中本 Epic 所有条目状态均为 `Done` 或 `Blocked`
- [ ] `👤 HUMAN` 一次只处理一个 backlog item（未并行推进多个 `spec/*`）
  > 需检查会话记录确认未同时创建多个 spec 分支

### 2.5 Epic 收尾 Gate
- [ ] `👤 HUMAN` 所有 spec 完成后，运行了 `epic-engineering-sign-off`
  > 需检查会话记录确认调用了该 skill
- [ ] `👤 HUMAN` Engineering Sign-off 的三项检查全部通过：
  - [ ] `👤 HUMAN` Backlog Consistency（backlog 一致性）
  - [ ] `👤 HUMAN` Spec Closure（Spec 变更闭环）
  - [ ] `👤 HUMAN` Branch Integrity（分支完整性）
  > 需检查会话记录中 sign-off 的输出结果

---

## 3. Phase 3: Epic Review / Demo（价值验收）

### 3.1 项目汇总报告
- [ ] `🤖 AUTO` 生成了项目汇总 Markdown（位于 `<epic-docs-dir>`，默认 `docs/<epic-slug>/`）
- [ ] `🤖 AUTO` 报告内容包含：
  - [ ] `🤖 AUTO` 范围（scope）
  - [ ] `🤖 AUTO` 交付清单（按 backlog items 列出）
  - [ ] `🤖 AUTO` 关键决策与风险
  - [ ] `🤖 AUTO` 测试与验收建议
  - [ ] `🤖 AUTO` 链接（Issues、PRs、可选 OpenSpec 变更）
  > 检查方法：在报告文件中搜索相关章节标题与内容

### 3.2 报告导图化
- [ ] `🤖 AUTO` `.xmind` 文件已生成
  > 检查方法：在 `<epic-docs-dir>`（默认 `docs/<epic-slug>/`）下搜索 `*.xmind` 文件
- [ ] `👤 HUMAN` 调用了 `report-it-to-me` 将汇总 Markdown 转为 `.xmind`
  > 需检查会话记录确认调用了该 skill

### 3.3 Demo 执行
- [ ] `👤 HUMAN` 调用了 `epic-review-demo` 执行 Demo
  > 需检查会话记录确认调用了该 skill
- [ ] `👤 HUMAN` Demo 按照 Phase 1 中定义的 Demo 目标与流程进行
  > 需人类比对 Plan 中的 Demo 流程与实际执行步骤

---

## 4. Phase 4: Epic Stabilization（稳定化收敛）

### 4.1 测试驱动
- [ ] `👤 HUMAN` 组织了集中测试（Integration / E2E / UAT / Exploratory 至少其一）
  > 需检查会话记录确认执行了测试
- [ ] `🤖 AUTO` 生成了问题清单（即便为空也明确"已测试且无问题"）
  > 检查方法：查找稳定化相关文件中的问题清单

### 4.2 分流执行
- [ ] `👤 HUMAN` 调用了 `epic-stabilization`
  > 需检查会话记录确认调用了该 skill
- [ ] `👤 HUMAN` Fix 类问题走了 `epic-fix-stabilization`（仅修 bug/补测试/对齐既有 Spec，未扩展行为）
  > 需检查会话记录确认分流路径正确
- [ ] `👤 HUMAN` Change 类问题回到了 `epic-sdd-loop`（将问题转为新的 Spec Change 交付）
  > 需检查会话记录确认分流路径正确

### 4.3 稳定化报告
- [ ] `🤖 AUTO` 输出了 `epic_stabilization_report`
  > 检查方法：查找文件系统中的稳定化报告文件
- [ ] `🤖 AUTO` 报告包含 `ready_for_merge: true/false` 判定
  > 检查方法：在报告文件中搜索 `ready_for_merge`
- [ ] `🤖 AUTO` 仅当 `ready_for_merge: true` 时才进入 Phase 5；否则停止并输出阻塞项
  > 检查方法：对比报告中的判定值与是否存在 Epic → main 的合并 PR

---

## 5. Phase 5: Merge to base（合并回主分支）

- [ ] `🤖 AUTO` 仅在 Stabilization 报告 `ready_for_merge: true` 后才执行合并
  > 检查方法：稳定化报告中 `ready_for_merge: true` 且合并 PR 的创建时间晚于报告
- [ ] `🤖 AUTO` 将 `epic/<epic-name>` 合并回 `<base-branch>`（默认 `main`）
  > 检查方法：`gh pr list --state merged --base main --head epic/<epic-name>`
- [ ] `👤 HUMAN` 使用了 `epic-merge-to-main` 或 `gh pr create` 完成合并
  > 需检查会话记录确认使用了指定工具
- [ ] `👤 HUMAN` 合并后主分支可正常构建/运行（未引入回归）
  > 需人类手动验证构建与运行

---

## 6. 工件完整性（Artifacts Integrity）

> 最终产物清单——确认所有应产出的工件均存在且可追溯。

- [ ] `🤖 AUTO` `<epic-docs-dir>/Implementation Plan.md` 存在且内容完整
- [ ] `🤖 AUTO` 根目录 `BACKLOG.md` 存在，本 Epic 分组完整（所有 items 含状态与引用）
- [ ] `🤖 AUTO` GitHub Issues 与 backlog items 一一对应
- [ ] `🤖 AUTO` OpenSpec Spec Changes 与 Issues 一一对应（已归档）
- [ ] `🤖 AUTO` 分支/PR 拓扑正确：每个 `spec/*` PR 指向 `epic/*`；Epic PR 指向 `main`
- [ ] `🤖 AUTO` 项目汇总报告（Markdown）存在（推荐：`<epic-docs-dir>/EPIC-REPORT.md`）
- [ ] `🤖 AUTO` 项目汇总导图（`.xmind`）存在（若使用了 `report-it-to-me`；在 `<epic-docs-dir>` 下查找 `*.xmind`）

---

## 7. 自主执行行为（Autonomy Behavior）

> 验证 AI 是否遵循了"默认不停下来问人"的自主执行要求。

- [ ] `👤 HUMAN` backlog item 选择过程中未向用户征求意见（自动选择第一个未完成条目）
- [ ] `👤 HUMAN` PR 的 title/body/base 由 backlog item + epic-branch + Spec Change 自动推导（未要求用户确认）
- [ ] `👤 HUMAN` 遇到可选决策时使用了确定性默认策略（而非停下来问人）
- [ ] `👤 HUMAN` 全流程中**仅在用户显式要求交互确认时**才中断询问

---

## 评分汇总（Summary）

> 分标签统计，避免 AI 评价者对 `👤 HUMAN` 项做出不可靠判定。

| 维度 | `🤖 AUTO` 项数 | 通过 | 未通过 | `👤 HUMAN` 项数 | 通过 | 未通过 | N/A |
|------|----------------|------|--------|-----------------|------|--------|-----|
| 0. 全局约束 | | | | | | | |
| 1. Phase 1: Plan | | | | | | | |
| 2. Phase 2: SDD LOOP | | | | | | | |
| 3. Phase 3: Review/Demo | | | | | | | |
| 4. Phase 4: Stabilization | | | | | | | |
| 5. Phase 5: Merge | | | | | | | |
| 6. 工件完整性 | | | | | | | |
| 7. 自主执行行为 | | | | | | | |
| **合计** | | | | | | | |

### 遵循度等级参考

> 分别计算 `🤖 AUTO` 通过率和 `👤 HUMAN` 通过率；综合评级取两者加权（建议权重 AUTO:HUMAN = 6:4）。

| 等级 | 通过率 | 含义 |
|------|--------|------|
| **A — 完全遵循** | ≥ 95% | AI 严格遵守了所有指令与约束 |
| **B — 基本遵循** | 80–94% | 存在少量偏差但不影响核心流程 |
| **C — 部分遵循** | 60–79% | 有明显遗漏或偏差，需人工补救 |
| **D — 严重偏离** | < 60% | 流程大面积未遵循，产出不可信 |

### 未通过项备注

> 列出所有标记 `[ ]`（未通过）的项，附原因和影响分析。

| 标签 | 检查项 | 原因 | 影响 | 建议 |
|------|--------|------|------|------|
| | | | | |
