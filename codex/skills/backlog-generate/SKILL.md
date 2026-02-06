---
name: backlog-generate
description: 提供 backlog-generate 的操作流程与约束；适用于 需要从设计文档或开发计划中拆分原子化任务，并生成 `BACKLOG.md` 时使用。
version: 0.2.0
---

# backlog-generate

## What this skill does
- 将需求拆分为可独立完成的 backlog item
- 输出包含 ID、描述、预期结果、状态的 `BACKLOG.md`

## Constraints
- 每个 backlog item 必须原子化、可独立完成
- 不添加设计文档之外的新功能
- 默认以 **Autonomous / 无人监督** 模式执行：需求不明确时不要停下来询问用户；改为在 `BACKLOG.md`（或 `Implementation Plan.md`）中标注 TBD/假设/风险与后续需要补齐的信息。
- 为了便于后续 `backlog-issue-sync` 自动打 label，**每个 item 建议显式写明优先级**（例如在条目中增加 `[P0|P1|P2|P3]` 标记；若暂时无法判断，可先填 `[P?]` 并在条目 note 说明依据与待补信息）。

## Recommended `BACKLOG.md` format（最小且可追加）
> 若 repo 已有既定格式，优先沿用；但请确保 Epic 分组头部至少能承载：`Epic`、`Source`、`Epic branch`（含 GitHub URL）。

```md
## <epic-name>

Epic: <epic-name>
Source: <design-doc-path>
Epic branch: epic/<epic-name>
Epic branch URL: <repo_url>/tree/epic/<epic-name>

### <spec-name> [P0]
- github: #<issue> # 由 backlog-issue-sync 创建后回写；初始可留空/TBD
- spec: <spec-name>
- status: Todo
- title: <human readable title>
- expected: <verifiable outcome>

### <spec-name-2> [P1]
- github: #<issue>
- spec: <spec-name-2>
- status: Todo
- title: <human readable title>
- expected: <verifiable outcome>
```

> Legacy/兼容：若 repo 仍使用 `BL-001 (spec: <spec-name>) ...` 单行条目，也允许沿用；但后续 issue title 仍应只用 `<spec-name>`（不要把 `BL-xxx` 放进 issue title）。

## Allowed commands
- `rg`
- `ls`
- `cat`
- `mkdir`
- `echo`

## Steps
1. 读取设计文档与 `Implementation Plan.md`，提炼需求点与依赖。
2. 按照“以 `<spec-name>` 为稳定 ID”的格式拆分原子化任务（推荐每条一个 `### <spec-name>` 区块），并补齐：
   - 优先级 `[P0|P1|P2|P3]`（尽量显式）
   - `expected`（可验证的结果）
   - `status`（默认 `Todo`）
3. 在仓库根目录 `BACKLOG.md` 中新增一个项目分组区块，写入任务清单。
4. 如需求不明确：
   - 继续拆分，但在对应条目下标注 `TBD`（不确定点/假设/风险/依赖）
   - 给出“下一步需要补齐的信息清单”（写在条目 note 或 Plan 的 TBD 小节）
