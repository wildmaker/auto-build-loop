---
name: report-it-to-me
description: 提供 report-it-to-me 的操作流程与约束；适用于 需要将 Markdown 报告整理为 XMind 思维导图（.xmind）并用系统默认应用打开查看时使用。
version: 0.0.0
---

# report-it-to-me

## What this skill does
- 将输入的 Markdown 报告结构化为 XMind 思维导图（`.xmind`）
- 先生成一份可审查/可复用的 XMind JSON（作为单一事实来源），再自动化产出 `.xmind` 文件
- 使用系统默认应用打开 `.xmind` 进行目检（推荐）

## Inputs (required / optional)
- 必填：`<markdown-path>`：项目汇总 Markdown 文件路径
- 可选：`<xmind-path>`：输出 `.xmind` 文件路径
  - 默认：与 `<markdown-path>` 同目录，文件名取 Markdown basename，例如：
    - Markdown：`/path/to/report.md`
    - XMind（默认）：`/path/to/report.xmind`
- 可选：`<root-title>`：导图根节点标题（root topic title）
  - 默认：优先取 Markdown 的一级标题；若不存在则用 Markdown basename（如 `report`）
- 可选：`<json-path>`：中间 JSON 文件路径（便于 review / diff）
  - 默认：与 `<markdown-path>` 同目录，例如：`/path/to/report.xmind.json`

## Constraints
- 放弃使用 HTML/Reveal.js 模拟幻灯片；输出物以 `.xmind` 为准
- 不手工编辑二进制 `.xmind`；以“中间 JSON”驱动生成，便于 review / diff / 复用
- 明确说明 Markdown 来源、JSON 路径、`.xmind` 输出路径，以及主题/布局等关键选项
- 若使用 MCP XMind Server：其读写只能发生在 server 启动时配置的 allowed directories 内

## Allowed commands
- `xmind`
- `open`

## Steps
1. 输入必要参数：
   - 必填：`<markdown-path>`
   - 可选：`<xmind-path>`（默认同目录 `*.xmind`）、`<root-title>`、`<json-path>`（默认 `*.xmind.json`）
2. 按参考（MCP XMind Server / `create_xmind` schema）先创建一份 XMind JSON 文件（写入 `<json-path>`），至少包含：
   - `path`: 输出 `.xmind` 路径（使用 `<xmind-path>` 或默认值）
   - `sheets[]`: `title`、可选 `theme`/`layout`
   - `rootTopic`: `title` + `children[]`（将 Markdown 的标题层级/列表映射为 topic 树）
3. 用 xmind-skill 自动化生成 `.xmind` 文件：
   - 若走 MCP：调用 `create_xmind`，把上一步 JSON 内容作为参数生成到 `path` 指定位置
4. 用系统默认应用打开并检查（推荐）：
   - `open <xmind-path>`
5. 汇报：`<markdown-path>`、`<json-path>`、`<xmind-path>`，以及采用的主题/布局/结构映射规则。
