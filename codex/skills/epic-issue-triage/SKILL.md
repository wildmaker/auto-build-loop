---
name: epic-issue-triage
description: Epic 稳定化阶段的问题分流/定性：将人工测试问题清单按 Fix（违反既有 Spec）与 Change（需要改变应有行为）强制分道扬镳。
version: 0.1.0
---

# Skill: epic-issue-triage

## Trigger
@epic-issue-triage

## Source of truth
- 根目录 `epic-workflow.md`（术语、分支/合并约束、稳定态纪律）
- 当前 Epic 的既有 Spec 与变更：`OpenSpec/changes/*`（以已合并到 `epic/*` 的 Spec 为准）
- 人工测试产生的问题清单（raw issues）

## Inputs (recommended)
- `<epic-branch>`：默认 `epic/<epic-name>`
- `<issue_list>`：raw issues（Markdown 列表/表格/Issue Tracker 导出均可）
- （可选）`<context>`：Demo/测试范围/环境信息（用于理解问题是否为环境差异）
- （可选）`<backlog_path>`：默认 repo 根目录 `BACKLOG.md`（用于回写 triage 结果）

## Outputs
```yaml
triage_result:
  fix_issues:
    - id: "<slug>"
      description
      reason: "violates_current_spec | implementation_bug | missing_test | spec_alignment"
  change_issues:
    - id: "<slug>"
      description
      reason: "desired_behavior_change"
```

说明：
- `id` 必须是**稳定且唯一的字符串标识**，优先使用 issue tracker 的 ID/URL/slug（保留原样）。
- 若没有外部 issue，**必须**使用描述型 slug（而非数字编号），例如：`login-redirect-loop`。

## Core decision rule（核心判断）
单个问题：
```text
是否违反当前 Spec？
  ├─ 是 → 修复类问题（Fix）
  └─ 否
      │
      ▼
是否需要改变“应有行为”？
  ├─ 是 → 变更类问题（Change）
  └─ 否 → 归为实现 / 测试问题（仍按 Fix 处理）
```

一句话总结：
```text
Spec 没变 → 修复
Spec 要变 → 重新走 Spec 流程
```

## Constraints（硬约束）
- 本 Skill **只做分流与定性**：禁止修改代码、禁止改 Spec、禁止创建分支/PR。
- 本 Skill **允许且仅允许**回写根目录 `BACKLOG.md`（用于记录 `triage_result` 形成可执行任务）；并且必须通过 `backlog-write-back` 完成写入，禁止手写/随意改动其他文件。
- 每个问题必须给出：
  - 唯一 `id`（若来自 issue tracker 则沿用；否则使用描述型 slug）
  - `description`（可复现描述 + 观察到的现象 + 期望/对照）
  - `reason`（为何归类为 Fix 或 Change）
- 若无法判断，默认先归入 Fix 并在 `reason` 标注为 `spec_alignment`（但必须在后续 Fix 中再次校验：一旦发现需要改变应有行为，立刻升级为 Change）。

## Allowed commands
- `backlog-write-back`
- `rg`
- `git`
- `gh`
- `openspec`

## Steps
1. 规范化问题清单
   - 将 raw issues 转为“每条一行”的结构化条目（保留原始来源与引用）
2. 为每条问题定位依据
   - 若问题涉及行为：优先在对应 Spec Change 中定位规则（验收标准、边界条件）
   - 若问题涉及实现：定位代码入口（模块/接口/测试）以确认是否为实现偏差或缺测试
3. 按 Core decision rule 分流
   - 产出 `fix_issues` 与 `change_issues`
4. 输出 `triage_result`
   - 该输出将作为 `epic-stabilization` 的唯一输入接口（后续流程不得自行重分类而不回写）
5. 回写 `BACKLOG.md`（强制）
   - 调用子 Skill：`backlog-write-back`
   - 写回目标：在该 Epic 分组下新增/更新 `Stabilization (post-demo)` 区块，将 `fix_issues` / `change_issues` 写成可执行任务（包含稳定 `id`、描述、分类与原因；并尽量保证重复运行不产生重复条目）

