## Epic Workflow（Complex Change）｜总览与强约束（AI 友好版）

本文件定义一次 Epic（复杂变更）的端到端工作流：从 Blueprint/Plan 到逐条实现、价值验收、稳定化收敛，直至合并回 `main`。
它是工作流的 **Single Source of Truth**（术语、映射关系、分支/合并规则、阶段 gate）。

### TL;DR｜推荐技能编排（5 阶段）

- **Phase 1 Sprint Planning（模式决策 & 初始化）**：`sprint-planning`
- **Phase 2 Implement（逐条交付）**：对每个 backlog item 调用 `epic-sdd-loop`
- **Phase 3 Review / Demo（价值验收）**：`epic-engineering-sign-off` → `epic-review-demo`
- **Phase 4 Stabilization（Demo 后收敛）**：`epic-stabilization`
  - 子流程：`epic-issue-triage` →（Fix）`epic-fix-stabilization` /（Change）`epic-sdd-loop`
- **Phase 5 Merge（合并回主分支）**：`epic-merge-to-main`

可选一键编排：`epic-auto-build-v2`（仅在用户明确提出 auto build 时启用）

### 概念模型｜关系与映射（必须遵守）

```text
Blueprint
  ↓
Implementation Plan
  ↓
BACKLOG（Epic 分组）
  ↓
Epic（epic/<epic-name> 分支）
  ↓
Issue（backlog item）
  ↓
Spec Change（OpenSpec/changes/<spec-name>）
  ↓
Task（实现细分）
```

- **1 Epic = 1 Plan = `BACKLOG.md` 中 1 个 Epic 分组**
- **1 backlog item = 1 Issue = 1 Spec Change**
- **Spec Change 是该 Issue 的唯一设计权威（SSOT）**：实现与验收以 Spec 为准，而不是以 Task/代码为准

### 分支模型｜强约束

```text
main
 └─ epic/<epic-name>
     └─ spec/<spec-name>
```

- **base 规则**：`spec/*` 必须基于 `epic/*`（禁止直接基于 `main`）
- **merge 规则**：只允许 `spec/*` → `epic/*`；Epic 完成后 `epic/*` → `main`
- **评审基准**：以 Spec Change 定义的行为与验收条件为准

### 工件清单（你应该看到的东西）

- **Plan**：`Implementation Plan.md`
- **Backlog**：根目录唯一的 `BACKLOG.md`（含多个 Epic）
- **Issues**：与 backlog items 一一对应
- **Spec Changes**：`OpenSpec/changes/<spec-name>`（与 Issue 一一对应）
- **Branches/PRs**：`spec/*` PR 只能指向 `epic/*`；Epic PR 指向 `main`
- **Reports**：Demo/稳定化报告（Markdown；可选 `.xmind`）

### Phase Guide｜阶段说明（输入/输出/退出条件）

#### Phase 1：Sprint Planning（`sprint-planning`）

- **输入**：Blueprint/设计文档路径、`<base-branch>`（默认 `main`）
- **核心动作**：
  - 调用 `multi-agent-parallel-gate` 做交付模式决策（Single Owner vs Multi-Role Team）
  - 仅当并行效率提升达到阈值（>=30%）时允许多人力路径
- **结果路由**：
  - **结果 A（多人力）**：将需求拆分为多个 epic；每个 agent 负责一个 epic，并各自执行后续 Epic Workflow
  - **结果 B（单人力）**：保持单 epic，由单一 owner 执行后续 Epic Workflow
- **产出**：
  - Sprint Planning 决策记录（含时间评估与路由选择）
  - 对应的 Epic 分配清单（A：多 epic；B：单 epic）
  - 每个被启用 epic 的 `Implementation Plan.md` / `BACKLOG.md` 分组 / Issue 对齐 / `epic/<epic-name>` 分支（通过 `epic-breakdown` 完成）
- **退出条件**：路由明确 + Epic 分配清晰 + 所有启用 epic 的初始化产物齐备且可进入 Phase 2

#### Phase 2：Implement（`epic-sdd-loop`，一次只做一个 item）

对每个 backlog item：

- 从 `epic/<epic-name>` 创建 `spec/<spec-name>`
- 初始化 Issue + Spec Change
- 实现 + 最小本地检查
- 创建 PR：`spec/*` → `epic/*`，评审通过后合并
- 需要时归档 Spec Change

**退出条件（单条 item）**：对应 `spec/*` 已合并回 Epic，且 Issue/Spec Change 闭环（按 repo 约定归档）

#### Phase 3：Epic Review / Demo（`epic-engineering-sign-off` → `epic-review-demo`）

- **先做 gate**：`epic-engineering-sign-off`
  - Backlog Consistency / Spec Closure / Branch Integrity 全部通过
- **再做价值验收**：`epic-review-demo`
  - 以 Plan 中定义的 Demo 脚本演示核心主场景
  - 产出汇总报告（可选 `report-it-to-me` 导图化）

#### Phase 4：Epic Stabilization（`epic-stabilization`）

- **输入**：人工测试问题清单（可为空，但必须明确已测试）+ 需求上下文路径
- **分流原则**：

```text
Spec 没变 → Fix
Spec 要变 → Change（回到 Spec 驱动流程）
```

- **Fix Path**：`epic-fix-stabilization`（只修 bug/补测试/对齐既有 Spec；禁止行为扩展）
- **Change Path**：`epic-sdd-loop`（把问题转为新的 Spec Change 交付）

- **输出**：`epic_stabilization_report`（含 `ready_for_merge: true/false`）

#### Phase 5：Merge to main（`epic-merge-to-main`）

- 仅当 Stabilization 报告 `ready_for_merge: true` 时执行
- 将 `epic/<epic-name>` 合并回 `main`（按团队约定选择 merge/rebase，必要时处理冲突）

### 文档目录建议（可选）

```text
docs/
└─ epics/<module>/<epic-name>/
   ├─ blueprint.md
   ├─ requirements.md
   ├─ tech-plan.md
   └─ ux.html
```

- 这些文档用于协作与验收；**上线后的系统真相应收敛到 OpenSpec / Repo 实现**
