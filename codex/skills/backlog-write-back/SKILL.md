---
name: backlog-write-back
description: 将结构化更新写回仓库根目录 BACKLOG.md（追加/更新条目、回写 Issue/PR/状态），保持最小 diff。
version: 0.1.1
---

# Skill: backlog-write-back

## Trigger
@backlog-write-back

## What this skill does
- 单一职责：**只**对仓库根目录 `BACKLOG.md` 做写入/更新（write-back）。
- 适用场景：
  - `epic-issue-triage` 产出 `triage_result` 后，将 Fix/Change 任务写回 `BACKLOG.md`
  - backlog item 完成后回写状态为 Done，并补齐 Issue/PR/Spec Change 引用
  - Issue 创建/对齐后，把 Issue 编号/链接回写到对应 backlog 条目
  - 补齐 Epic 分组头部元信息（例如 `Epic branch URL`）

## What this skill does NOT do
- 不做需求拆分（不生成新的 backlog 方案）：这属于 `backlog-generate` / `epic-breakdown`
- 不做问题分流/定性：这属于 `epic-issue-triage`
- 不创建 Issue / 不创建分支 / 不创建 PR / 不改代码 / 不改 Spec

## Inputs (recommended)
```yaml
backlog_write_back:
  backlog_path: BACKLOG.md # 可选；默认必须为 repo 根目录 BACKLOG.md
  epic:
    name: string           # 推荐显式提供；可由 epic/<epic-name> 推导
    branch: epic/<epic-name> # 可选

  # 多种写回操作可以组合使用；一次只修改 BACKLOG.md
  operations:
    # 0) 更新 Epic 分组头部元信息（例如：补齐 Epic branch URL）
    - type: epic_meta_update
      epic_meta:
        branch: epic/<epic-name>          # optional
        branch_url: https://.../tree/...  # optional

    # A) 写回 triage 结果（用于稳定化阶段）
    - type: triage_result
      triage_result:
        fix_issues:
          - id: string
            description: string
            reason: string # optional
        change_issues:
          - id: string
            description: string
            reason: string # optional

    # B) 更新既有 backlog item 的状态/引用（用于交付闭环）
    - type: item_update
      item:
        id: string
        status: Todo | InProgress | Done | Blocked # 按 repo 既有用词/样式更新
        issue: string # optional, e.g. "#123" or "https://..."
        pr: string    # optional, e.g. "https://..."
        spec_change: string # optional, e.g. "OpenSpec/changes/<spec-name>"
        note: string  # optional
```

## Outputs
- `BACKLOG.md` 被更新（最小 diff、尽量不改动无关内容）

## Constraints（硬约束）
- 一个 repo **只允许存在一个**根目录 `BACKLOG.md`；不得创建 `docs/BACKLOG.md`、`backlog.md` 等副本文件。
- 只允许修改 `BACKLOG.md`；不得顺带修改其他文件。
- **保持最小 diff**：优先“就地更新条目”，避免重排、重写整个分组或全文件格式化。
- **不臆测缺失信息**：如果缺少 Epic 分组定位信息或条目无法可靠匹配，必须：
  - 在对应 Epic 分组下新增一个 “Unmapped / Needs manual mapping” 小节暂存，或
  - 停止并输出阻塞原因（不要瞎写到别的 Epic 分组）

## Recommended write-back format（当需要新增区块时）
当 `BACKLOG.md` 中不存在目标 Epic 分组或稳定化区块时，可按如下最小结构追加（但若 repo 已有固定格式，必须优先沿用既有格式）：

```md
## <epic-name>

Epic: <epic-name>
Epic branch: epic/<epic-name>
Epic branch URL: <repo_url>/tree/epic/<epic-name>

### Stabilization (post-demo)

#### Fix
- [ ] <id> — <description>
  - Triage: Fix
  - Reason: <reason>
  - Next: epic-fix-stabilization

#### Change
- [ ] <id> — <description>
  - Triage: Change
  - Reason: <reason>
  - Next: epic-sdd-loop
```

## Allowed commands
- `rg`
- `git`

## Steps
1. 定位根目录 `BACKLOG.md`
   - 必须以 repo root 为基准定位；若找不到则停止并输出阻塞项（不要创建同名副本文件）。
2. 读取并识别目标 Epic 分组
   - 通过 `<epic-name>` 优先定位；若仅给了 `epic/<epic-name>` 分支名，则从中推导 `<epic-name>`。
   - 匹配策略：优先寻找以 `<epic-name>` 为标题的二级标题分组（例如 `## <epic-name>` / `## Epic: <epic-name>`）。
3. 执行 `operations`（按顺序）
   - 对 `epic_meta_update`：
     - 在目标 Epic 分组头部（紧随 `## ...` 之后的若干行）就地补齐/更新：
       - `Epic branch: ...`
       - `Epic branch URL: ...`
     - 若已存在同名字段：仅替换该行的值（保持最小 diff；不重排其它字段）。
     - 若不存在：追加到 Epic 分组头部（优先放在 `Epic:` / `Source:` 之后；若不存在这些字段则放在标题后面）。
   - 对 `triage_result`：
     - 在该 Epic 分组下确保存在 `### Stabilization (post-demo)` 区块（不存在则创建）。
     - 对每条 `id`：
       - 若已存在同 `id` 条目：更新其 Triage 类型与描述/原因（尽量保留既有状态、Issue/PR 引用与已完成标记）。
       - 若不存在：新增为未完成条目（Todo），并写入 `Triage` / `Reason` / `Next`。
     - 目标：**可追踪、可执行、可复跑**，且重复运行不会产生重复条目。
   - 对 `item_update`：
     - 精确定位 `item.id` 对应条目并更新其状态/引用信息。
     - 若无法定位：追加到该 Epic 分组下的 “Unmapped / Needs manual mapping” 小节，并在 `note` 标注原因与建议人工调整的位置。
4. 交付前自检
   - 确保没有改动非目标 Epic 分组的内容。
   - 确保每个新增条目都带有稳定 `id`，且不会与既有条目冲突。

