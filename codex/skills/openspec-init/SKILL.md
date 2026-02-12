---
name: openspec-init
description: Initialize OpenSpec in a project repo, install the CLI if needed, run openspec init, and add the bootstrap prompt to AGENTS.md. Use when setting up OpenSpec for a new project repository.
version: 0.1.1
---

# Skill: openspec-init

## Trigger
@openspec-init

## What this skill does
- Install OpenSpec CLI if missing
- Run `openspec init` inside the project repo (interactive)
- Add the OpenSpec bootstrap prompt to `AGENTS.md` only

## Inputs
- `<repo>`: target project repo path (default: current repo)

## Constraints
- Do not modify `CLAUDE.md`
- `openspec init` is interactive; user must pick the AI tool
- Append bootstrap prompt only once (avoid duplicates)

## Allowed commands
- `npm`
- `openspec`
- `git`

## Steps
### 1) Enter the repo
- If `<repo>` is provided, `cd <repo>`
- Otherwise, use the current repo root (`git rev-parse --show-toplevel`)

### 2) Install OpenSpec CLI (if missing)
- Check: `openspec --version`
- If missing, install: `npm install -g @fission-ai/openspec@latest`

### 3) Initialize OpenSpec
- Run: `openspec init`
- Follow the prompts to select your AI tool

### 4) Update `AGENTS.md` (only)
- Append this block if `AGENTS.md` does not already contain it:

```markdown
## OpenSpec bootstrap

1. Populate your project context:
   "Please read openspec/project.md and help me fill it out
    with details about my project, tech stack, and conventions"

2. Create your first change proposal:
   "I want to add [YOUR FEATURE HERE]. Please create an
    OpenSpec change proposal for this feature"

3. Learn the OpenSpec workflow:
   "Please explain the OpenSpec workflow from openspec/AGENTS.md
    and how I should work with you on this project"
```

## Script (recommended)
Use `scripts/openspec_init.sh` to perform steps 1-4.
