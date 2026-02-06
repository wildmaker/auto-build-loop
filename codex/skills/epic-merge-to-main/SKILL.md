---
name: epic-merge-to-main
description: Merge an Epic branch into main with rebase/merge decision and conflict resolution.
version: 0.0.0
---

# Skill: epic-merge-to-main

## Trigger
@epic-merge-to-main

## What this skill does
- Merges a specified branch into `main`
- Checks whether a rebase onto `main` is required
- Resolves conflicts and pushes `main`

## Constraints
- Must ensure working tree is clean before merge
- Must resolve conflicts if they arise
- Must end on `main`

## Allowed commands
- `git`

## Steps
1. Check `git status -sb` for a clean working tree.
2. Fetch and update `main` from origin.
3. Compare branch with `main`:
   - If branch can be merged cleanly, merge directly.
   - If branch is behind or diverged in a way requiring rebase, rebase the branch onto `main` and resolve conflicts.
4. Merge the branch into `main` (no direct commits to `main` beyond merge).
5. Push `main` to origin.
6. Ensure current branch is `main` at the end.
