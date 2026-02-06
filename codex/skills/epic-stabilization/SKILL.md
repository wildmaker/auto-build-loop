---
name: epic-stabilization
description: Epic 稳定化主控：基于人工测试问题清单做分流，Fix 走集中修复，Change 回到 Spec 驱动开发，最终把 Epic 收敛到可合并稳定态。
version: 0.1.0
---

# Skill: epic-stabilization

## Trigger
@epic-stabilization

## Role
- Epic 稳定化阶段的主控调度（Orchestrator）。
- 它**不解决问题本身**，而是保证每个问题走对的流程：能修的就修；要改“应有行为”的必须回到 Spec 流程。

## Preconditions（必须满足）
- 已提供人工测试问题清单（可为空，但必须明确“已测试且未发现问题”）
- 已提供包含需求上下文信息的文档或目录（建议使用与 Epic 相关的 doc 文件夹）

## Inputs
```yaml
epic:
  name: string
  branch: epic/<epic-name>

issue_list:
  source: manual_test | markdown | issue_tracker
  content: raw_issues

context:
  requirement_context_path: <path-to-doc-or-folder>
  note: "建议使用与该 Epic 相关的文档目录（如 docs/<epic-slug>/）"
```

## Outputs
```yaml
epic_stabilization_report:
  fixed_issues: list
  spec_changes: list
  unresolved_issues: list
  regression_status: pass | fail
  ready_for_merge: boolean
```

建议落盘（便于追溯与复核）：
- 将 `epic_stabilization_report` 写入 `docs/<epic-slug>/EPIC-STABILIZATION-REPORT.md`（或 `*.yml`），不要堆在 `docs/` 根目录

## Control logic（文本绘图）
```text
AI Demo 完成（可选）
      │
      ▼
人工测试（Manual / Exploratory Testing）
      │
      ▼
问题清单（Raw Issue List）
      │
      ▼
epic-stabilization（Master Skill）
      │
      ▼
问题分流（Triage Skill）
      │
      ├───────────────┐
      ▼               ▼
修复类问题          变更类问题
(Fix Issues)       (Change Issues)
      │               │
      ▼               ▼
Fix Stabilization   SDD LOOP
(Fix Skill)         (Spec 驱动开发)
      │               │
      └───────┬───────┘
              ▼
        回归测试
              │
              ▼
        Epic 稳定态
              │
              ▼
     Ready to Merge → main
```

## Constraints（硬约束）
- 建议在 Demo 与集中测试完成后运行；若未完成 Demo，必须在报告中明确说明。
- **本 Skill 不直接修改代码**：它只负责调度子流程、组织分支/PR、判断状态与输出报告。
- **不允许绕过 Spec 流程处理行为变更**：
  - Spec 没变 → Fix
  - Spec 要变 → 回到 Spec 驱动开发（Spec → Task → 实现）
- Fix Path 仅允许：bug 修复 / 测试补充 / Spec 对齐；禁止行为扩展（scope creep）。

## Allowed commands
- `epic-issue-triage`
- `epic-fix-stabilization`
- `epic-sdd-loop`
- `openspec-init-change`
- `epic-engineering-sign-off`
- `git`
- `gh`
- `rg`
- `openspec`

## Workflow（Master Control Flow）

### Step 0：校验前置条件（强制）
必须确认：
- `issue_list.content` 已提供（哪怕为空也必须明确来自人工测试）
- `context.requirement_context_path` 已提供（包含需求上下文信息的文档或目录）

若任一条件不满足：**停止并输出阻塞项清单**（不得继续）。

### Step 1：问题分流（强制）
调用子 Skill：`epic-issue-triage`

期望输出：
```yaml
triage_result:
  fix_issues:
    - id
      description
  change_issues:
    - id
      description
```

### Step 2：处理修复类问题（Fix Path）
如果存在 `fix_issues`：
- 创建/切换修复分支：`fix/<epic-name>-stabilization`（base = `epic/<epic-name>`）
- 调用子 Skill：`epic-fix-stabilization`
- 该子流程完成后，必须确保修复已合并回 `epic/<epic-name>`（PR merged）

### Step 3：处理变更类问题（Change Path）
如果存在 `change_issues`，对每一个变更类问题：
- 将该问题视为一个新的 backlog item（稳定化阶段的 Change 条目），先为其确定稳定的 `<spec-name>`（slug）
- 调用子 Skill：`epic-sdd-loop`（本质与 `epic-auto-build-v2` 中“逐条实现 spec change issue”一致）
  - 输入：`<epic-branch>=epic/<epic-name>`、`<spec-name>`、`<issue-title>`（从该问题描述生成；若 Issue 已存在则对齐/复用）
  - 产出：Issue + OpenSpec change + `spec/*` 分支（base = `epic/<epic-name>`）+ PR（`spec/*` → `epic/*`）
- Spec 完成后必须合并回 `epic/<epic-name>`（`spec/*` → `epic/*`）

### Step 4：回归测试
在 `epic/<epic-name>` 上执行回归测试（按 repo 约定的 lint/test/build/e2e）并确认：
- 修复问题不再复现
- 新 Spec 行为符合预期
- 未引入新不稳定性

### Step 5：稳定态判定（Stable Gate）
Epic 被视为 Stable 的条件：
- 所有问题都已：
  - 修复完成并合并回 epic，或
  - 转化为 Spec 变更并完成实现且合并回 epic
- 回归测试通过
- Epic 分支无未处理问题（无悬挂 PR / 无“继续修/继续改”的未闭环事项）

输出 `epic_stabilization_report`，并给出：
- `ready_for_merge: true/false`

