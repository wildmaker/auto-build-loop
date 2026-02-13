---
name: visualize-it
description: Generate Mermaid or JSON Canvas diagrams to explain specific code, modules, or implementation logic. Use when a user asks for visualized logic, architecture flow, code behavior diagrams, or Obsidian Canvas output.
---

# visualize-it

## What this skill does
- Choose Mermaid or JSON Canvas based on the user’s intent and target format
- Use Mermaid to visualize implementation logic of code/modules
- Use JSON Canvas when a spatial layout or `.canvas` file is needed
- Structure the explanation flow, then render diagrams that answer the user’s question

## Constraints
- Confirm the exact scope to describe before drawing (file/module/feature/function)
- Use the smallest set of diagrams needed to answer the question
- Prefer one primary diagram; add a second only if it clarifies a different layer
- Keep Mermaid code concise and valid
- Keep JSON Canvas output valid (`nodes`/`edges`, unique IDs, readable layout)

## Allowed commands
- `cat`
- `rg`
- `ls`

## Workflow
1. Clarify scope: what code/module/function and what question to answer.
2. Decide output format:
   - Mermaid for logical flows, interactions, and compact diagrams
   - JSON Canvas for Obsidian Canvas, spatial layouts, or `.canvas` files
3. If Mermaid, choose the best diagram type:
   - flowchart: control flow, data flow, module relationships
   - sequence: request/response or call ordering
   - class: object model / type relationships
   - state: lifecycle/state transitions
   - erDiagram: data model
4. If JSON Canvas, define nodes/edges/groups and a readable layout.
5. Decide the narration order (e.g., entry point → key components → exit/side-effects).
6. Generate the diagram(s) aligned with the narration.
7. Provide a short textual walkthrough tied to the diagram nodes.

## Output
- Mermaid: a `mermaid` fenced code block.
- JSON Canvas: a `.canvas` JSON block (fenced as `json`).
- 3–6 bullet explanation mapping to nodes/edges.

