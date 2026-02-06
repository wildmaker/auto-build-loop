---
name: xmind
description: Read, search, extract, and create XMind (.xmind) mind maps using the MCP XMind server (mcp-xmind). Use when you need to parse an existing mind map, find nodes by fuzzy path/query, or generate a new multi-sheet XMind plan (including todo + planned tasks/Gantt fields).
---

# XMind (via MCP)

## Prerequisites

- MCP server `xmind` is configured and your client has been restarted to load it.
- The server can only read/write inside its allowed directories (configured at server start).

## What to use (tool selection)

- `list_xmind_directory`: scan folders for `.xmind`
- `read_xmind`: parse full structure (multi-sheet)
- `search_xmind_files`: search by file name / content
- `extract_node`: fuzzy path matching to locate a topic quickly
- `extract_node_by_id`: fetch a node by id (exact)
- `search_nodes`: query across titles/notes/labels/callouts/tasks
- `create_xmind`: generate a new `.xmind` from structured JSON

## Common workflows

### Explore an existing map

1. `list_xmind_directory` on a folder
2. `read_xmind` the chosen file
3. Use `extract_node` (fuzzy path) or `search_nodes` (keywords) to zoom in
4. Summarize findings by sheet → branch → key nodes, and cite exact node ids / paths for follow-ups

### Find “where is X in this mind map?”

- Prefer `search_nodes` with `searchIn: ["title", "notes"]`
- If you know the branch path roughly, use `extract_node` to avoid noisy keyword matches

### Create a new plan map (optionally with tasks/Gantt)

- Use `create_xmind` with:
  - `sheets[]`: title + optional theme/layout
  - `rootTopic`: nested `children`
  - Optional task fields on topics: checkbox todo/done, or planned task fields (dates/progress/priority/duration/dependencies)
- Choose a new output path (avoid overwriting unless you intentionally update an existing file).

