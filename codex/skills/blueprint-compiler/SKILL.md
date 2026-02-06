---
name: blueprint-compiler
description: Compile a Design Blueprint into a concrete, repo-aware Implementation Plan.
version: 0.1.0
---

# Skill: blueprint-compiler

## Trigger
@blueprint-compiler

## What this skill does
- 将整体技术方案（Blueprint）“编译”为一份**可执行、可落地、与当前代码库强相关**的 Implementation Plan
- 产出的执行方案必须**保持与 Blueprint 一致的核心思路/架构方向**，但具体任务拆分、落地路径、改动位置与依赖梳理必须以 repo 现状为准
- 在 `Implementation Plan.md` 中明确：要改哪些模块/文件（尽量给出路径线索）、怎么分阶段推进、每阶段验收与风险/依赖/TBD
- 在 `Implementation Plan.md` 中**直接拆分出 backlog 任务列表草案**（原子化 items + 建议 ID/验收点/依赖），可直接用于后续写入根目录 `BACKLOG.md`

## Inputs (recommended)
- `<blueprint-doc-path>`：Blueprint 文档在仓库内的路径（可多个；也可沿用既有命名 `<design-doc-path>`）
- `<base-branch>`：用于理解当前实现基线（默认 `main`）
- （可选）`<constraints>`：如时间/范围限制、性能/兼容性目标、不可改动区域等
- （可选）`<output-dir>`：`Implementation Plan.md` 输出目录（推荐在 Epic 工作流中使用：`docs/<epic-slug>/`）

## Outputs
- `Implementation Plan.md`：repo-aware 的 Implementation Plan（**包含已拆分的 backlog items 列表草案**，可直接用于生成/更新根目录 `BACKLOG.md` 并进入实现）
- 存储位置规则：
  - 若提供了 `<output-dir>`：输出到 `<output-dir>/Implementation Plan.md`
  - 否则：与 `<blueprint-doc-path>` 放在同一个父目录下存储

## Constraints
- 不做实现编码、不直接写入根目录 `BACKLOG.md`、不创建 Issue/分支（但必须在 `Implementation Plan.md` 中产出可落盘的 backlog items 列表）。
- 不臆测缺失需求：信息不足时，必须在 `Implementation Plan.md` 标注 TBD 与需要补充的资料清单。
- 计划必须**可执行**：避免停留在抽象架构口号；需要给出明确的执行路径与拆分策略。
- 计划必须**不背离 Blueprint**：任何偏离都必须在 `Implementation Plan.md` 明确“为何偏离 + 影响 + 替代方案”。

## Allowed commands
- `rg`
- `ls`
- `git`

## Steps
1. 阅读 Blueprint 文档
   - 提炼：目标/范围/非目标、核心架构思路、关键约束、验收标准与风险假设。
2. 扫描 repo 现状（repo-aware）
   - 用 `rg`/目录结构定位与 Blueprint 相关的模块、边界、关键入口（API、路由、服务层、数据模型、构建/部署等）。
   - 识别：可复用能力、现存约束（技术栈、模块边界、约定、测试框架）、潜在冲突点与迁移成本。
3. 将 Blueprint 映射到可落地的执行路径
   - 为每个 Blueprint 的关键构件/流程，给出“在 repo 中对应/落点在哪里（模块/文件/接口层级）”。
   - 给出分阶段交付策略，确保每阶段都可独立验证与回滚。
4. 运行 standing-on-giants-preflight（找捷径/复用）
   - 调用 `standing-on-giants-preflight` skill，检索是否已有现成方案/最佳实践/可复用代码/现成工具链可直接套用。
   - 输出结论：哪些部分可以走捷径（或必须自行实现）+ 采用/不采用的理由 + 对后续分阶段交付的影响。
5. 生成 `Implementation Plan.md`（建议结构）
   - Background / Goals / Non-goals
   - Blueprint alignment（核心思路对齐点）
   - Repo reality（当前实现概览 + 关键限制）
   - Implementation strategy（分阶段路径）
   - Work breakdown（模块级拆分 + 任务颗粒度建议 + 依赖）
   - Backlog draft（**直接可落盘到根目录 `BACKLOG.md` 的 items 列表**：建议使用稳定的 `<spec-name>` slug 作为 item ID，附：描述/验收点/依赖/风险）
   - Risks & TBD（缺失上下文、决策点、风险与缓解）
   - Test plan / Validation（每阶段验证方式）

