---
name: backlog-issue-sync
description: 提供 backlog-issue-sync 的操作流程与约束；适用于 需要根据 `BACKLOG.md` 在 GitHub 上创建对应 issues 时使用。
version: 0.2.0
---

# backlog-issue-sync

## What this skill does
- 为每个 backlog item 创建 GitHub Issue
- 必要时将 issue 编号回写到 `BACKLOG.md`
- 为每个 issue 自动补齐 labels（至少：类型、优先级；可选：epic）

## Constraints
- 不能重复创建已存在的 issue
- **issue 标题必须遵循稳定 slug 规范（默认用 spec name）**：
  - 默认：`<issue-title> = <spec-name>`（只用 spec slug；不得包含 `BL-xxx` 前缀）
  - 允许在 issue body 中保留 backlog 原始条目（含 `BL-xxx`）用于追溯，但**不要**把 `BL-xxx` 放进 issue title
- **labels 必须可追溯且可复用**：同一套 label 命名应在同一 repo 内保持一致；缺失时先创建再使用
- 若 issue 已存在：允许**补齐缺失 labels**；但不得覆盖/移除人类已有 labels

## Default label scheme（建议）
- **Type（必选）**
  - `type/spec`：Spec Change / 需求实现（通常对应 backlog item 含 `(spec: ...)` 或 `OpenSpec/changes/...` 引用）
  - `type/bug`：Bug/Fix（通常来自 Stabilization/Fix，或条目语义为修复缺陷）
  - `type/chore`：其它工程性任务（无法可靠归类时兜底）
- **Priority（必选）**：`priority/P0`、`priority/P1`、`priority/P2`、`priority/P3`
  - **Spec 的优先级**取决于它对 Epic 的重要程度（是否阻塞 Demo/MVP/核心主场景）
  - **Bug 的优先级**取决于严重程度（崩溃/数据错误/安全/阻塞核心流程等）
- **Epic（可选但推荐）**：`epic/<epic-name>`（用于跨 issue 维度聚合）

## How to choose priority（确定性规则）
1. **优先使用显式标记**：若 backlog 条目里有 `[P0|P1|P2|P3]`，直接映射到 `priority/Px`
2. 若无显式标记：
   - **Spec（type/spec）**：
     - P0：阻塞 Epic Demo/MVP/核心主场景（不做就无法“交付/验收”）
     - P1：强相关主流程/关键依赖（可验收但会显著降级）
     - P2：次要流程/体验增强
     - P3：纯优化/低价值/可延期
   - **Bug（type/bug）**：
     - P0：崩溃、数据丢失/错账、安全风险、阻塞启动或阻塞核心主流程/演示
     - P1：核心流程明显错误/严重回归
     - P2：非核心功能错误、存在绕过方案
     - P3：纯 UI/文案/轻微瑕疵

## Allowed commands
- `rg`
- `gh issue list`
- `gh issue view`
- `gh issue create`
- `gh issue edit`
- `gh label list`
- `gh label create`

## Steps
1. 读取根目录 `BACKLOG.md`，定位目标 Epic 分组，并整理需要同步的 backlog items
   - 若条目已包含 issue 引用（`#123` / issue URL）：记录为“复用已有 issue”（不要重复创建）；仍需要补齐 labels
   - 对每条 item 提取/推导：
     - `id`（稳定标识；推荐直接使用 `<spec-name>`；兼容 legacy 的 `BL-001`）
     - `spec_name`（稳定 slug；优先从条目里的 `(spec: <spec-name>)` 或类似字段提取；否则从标题 slugify 得到）
     - `title`（去掉状态/前缀后的简洁标题）
     - `issue_title`（默认等于 `spec_name`；仅当无法得到 `spec_name` 时才退回 `title`）
     - `type`：优先用 `(spec: ...)` / `OpenSpec/changes/...` 推断为 `type/spec`；其次用 “Fix/Bug/回归/崩溃”等语义推断 `type/bug`；否则 `type/chore`
     - `priority`：按上面的规则得到 `priority/Px`（优先使用 `[Px]` 显式标记）
2. 确保 labels 存在（先建再用）
   - 用 `gh label list` 检查缺失的 labels
   - 缺失则用 `gh label create` 创建（可附带 description；颜色可按团队习惯，缺省也可）
3. 对每个 backlog item 同步 issue
   - 若 backlog 条目已给出 issue 编号/链接：用 `gh issue view` 验证并读取其编号（作为唯一目标）
   - 否则用 `gh issue list` / `gh issue view` 查重（优先用 `issue_title` / `spec_name` 搜索；不要依赖 `BL-xxx` 作为标题前缀）
   - 若 issue 已存在（包含“从 backlog 复用”的情形）：
     - 用 `gh issue edit <num> --add-label ...` 补齐缺失 labels（`type/*`、`priority/*`、可选 `epic/<epic-name>`）
     - 必要时将 issue 编号回写到 `BACKLOG.md`
   - 若 issue 不存在：
     - 创建 issue（标题建议：`<issue_title>`，默认即 `<spec_name>`）
     - body 至少包含：
       - `Source: BACKLOG.md`
       - `Epic: <epic-name>`
       - `Backlog item: <id> — <full item text>`（用于追溯；允许含 `BL-xxx`）
     - 创建时直接带 labels：`type/*` + `priority/*`（可选 `epic/<epic-name>`）
4. 将新建/对齐后的 issue 编号回写到 `BACKLOG.md`（保持最小 diff）
   - 若条目采用块结构（推荐）：在条目下方记录：
     - `- github: #<num>`
     - `- spec: <spec_name>`
   - 若条目为单行/旧格式：就地追加 `[#<num>]` 或等价引用即可（避免大改格式）
