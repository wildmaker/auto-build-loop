---
name: epic-review-demo
description: Epic Review / Demo（价值验收）执行流程：安装依赖、检查 env、Build/启动、生成并按文档进行核心主场景演示。
version: 0.2.0
---

# epic-review-demo

## Trigger
@epic-review-demo

## What this skill does
- 按 Plan 阶段文档中定义的 Demo 目标与流程，完成本 Epic 的价值验收演示
- 在 Demo 前确保：依赖已安装、环境变量就位、项目可 Build 或可启动
- 生成可复用的“真实演示脚本”（step-by-step），并尽可能用自动化工具执行/演示

## Inputs (recommended)
- `<demo-doc-path>`：包含 Demo 目标/前置条件/运行方式/Demo 流程的文档路径（推荐：`Implementation Plan.md` 中的 `## Demo` 章节；或独立 `DEMO.md`）
- `<repo-root>`：仓库根目录（默认当前 repo）
- `<run-mode>`：`dev`（启动）或 `build`（构建）或 `both`
- `<env-file-path>`：用于 Demo 的 `.env` 文件路径（如 `.env.local`、`.env.development`）
- `<required-env-vars>`：必须存在且非空的环境变量名列表（来自 `<demo-doc-path>`）
- `<start-command>` / `<build-command>`：来自 `<demo-doc-path>` 的命令（不要凭空猜测）
- `<demo-scenarios>`：核心主场景列表（来自 `<demo-doc-path>`）

## Outputs
- Demo 就绪结论（是否可开始演示 + 阻塞项清单）
- Demo 演示脚本（可直接照读/照做的 step-by-step，含每步期望结果）
- Demo 过程记录（可选）：命令输出/日志片段/截图路径/录屏路径（如仓库已有约定则遵循）

## Constraints
- 默认以 **Autonomous / 无人监督** 模式执行：Demo 就绪后应直接开始演示；不要等待用户确认。
- 若用户**显式要求暂停/不执行 Demo**，才允许停止在 “Demo 就绪” 阶段。
- 不臆测 Demo 流程与环境变量：缺失信息必须在 `<demo-doc-path>` 中补齐或标注 TBD（再回到 Plan 补文档）。
- 优先遵循 repo 的既有启动方式：先读 `README` / `package.json` scripts / `Makefile` / `docker-compose.yml` 等再执行命令。
- 环境变量检查必须使用 `check-env`，且不得修改 `.env` 文件内容。

## Allowed commands
- `check-env`
- `git`
- `rg`
- `gh`
- `npm` / `pnpm` / `yarn`
- `make`
- `docker` / `docker compose`
- `python`
- `go`
- `cargo`
- `bundle`
- `open`

## Steps
### 0) Load Demo spec（以文档为准）
1. 打开并解析 `<demo-doc-path>`，提取并明确以下字段（若缺失则回到 Plan 补齐）：
   - Demo 价值目标（要证明什么）
   - 前置条件：依赖服务、账号/数据准备、`<env-file-path>`、`<required-env-vars>`
   - 如何运行：安装依赖命令、`<start-command>` / `<build-command>`、端口/访问方式
   - Demo 流程：`<demo-scenarios>`（逐步操作 + 期望结果）

### 1) Prepare runtime（安装依赖 + 检查 env）
1. 选择并执行正确的依赖安装方式（以 repo 现状为准）：
   - Node：`pnpm install` / `npm ci` / `yarn install`
   - 其他：按 `README`/脚本说明执行（如 `make setup`、`bundle install`、`pip install -r requirements.txt` 等）
2. 运行 `check-env` 检查环境变量是否齐全：
   - `./tools/check-env.sh <env-file-path> <var1> [var2] ...`
3. 若存在缺失/空值变量，停止并输出阻塞项清单（不得继续 Demo）。

### 2) Build or Start（构建或启动）
1. 按 `<run-mode>` 执行：
   - `build`：运行 `<build-command>`，确保产物生成且无报错
   - `dev`：运行 `<start-command>`，确保服务启动成功、端口可访问、无致命报错
   - `both`：先 build 后 start（或按 `<demo-doc-path>` 约定顺序）
2. 记录关键信息以便演示与复盘：
   - 启动端口/访问地址
   - 关键日志（成功提示、健康检查、迁移完成等）

### 3) Generate demo script（生成“真实演示步骤”）
1. 基于 `<demo-doc-path>` 的 `<demo-scenarios>`，生成一份可照做的演示脚本，格式建议：
   - 场景名（价值点）
   - 前置状态（用户/数据/开关）
   - 操作步骤（编号）
   - 每步期望结果（可观察信号：UI、日志、返回值、数据库/队列变化等）
2. **尽可能自动化演示**（以不破坏现有系统为前提）：
   - CLI 可演示：提供可直接运行的命令序列，并解释输出应该长什么样
   - Web 可演示：提供“打开地址 -> 登录/进入页面 -> 点击/输入 -> 观察结果”的严格步骤；若 repo 已有 e2e（Playwright/Cypress），优先通过其命令跑出可视/可复现结果

### 4) Start demo（开始演示）
1. 按“演示脚本”逐步执行，并在每个关键步骤输出：
   - 当前步骤
   - 采取的动作（命令/点击/输入）
   - 观察到的结果（与期望结果对照）
2. 若出现偏差或失败：
   - 先给出最小诊断信息（错误日志/复现路径）
   - 标注为阻塞项，并给出下一步排查/修复建议（必要时回到 SDD LOOP 修复后再重试 Demo）

