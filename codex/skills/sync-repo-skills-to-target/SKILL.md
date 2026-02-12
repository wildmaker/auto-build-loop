---
name: sync-repo-skills-to-target
description: 将当前仓库的 `codex/skills` 全量同步到用户指定目录；覆盖同名技能文件/目录，不删除目标目录中额外存在的其他文件。适用于发布本 repo 技能最新版本到任意用户技能仓库时使用。
version: 0.0.0
---

# sync-repo-skills-to-target

## What this skill does
- 将当前仓库 `codex/skills` 同步到用户指定目录。
- 覆盖同名文件/目录。
- 保留目标目录中源目录不存在的其他文件（不删除）。

## Constraints
- 必须要求用户提供目标目录绝对路径。
- 默认不删除目标目录任何已有文件。
- 只同步技能目录，不改动仓库其他内容。

## Allowed commands
- `./scripts/sync_skills_to_target.sh`

## Steps
1. 确认目标目录绝对路径（例如：`/Users/<name>/Documents/Projects/skills-sync/codex/skills`）。
2. 执行：
   `./scripts/sync_skills_to_target.sh --target <ABS_TARGET_DIR>`
3. 读取脚本输出中的统计与校验结果，向用户汇报。

## Optional
- 预览变更（不落盘）：
  `./scripts/sync_skills_to_target.sh --target <ABS_TARGET_DIR> --dry-run`
