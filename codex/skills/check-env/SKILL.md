---
name: check-env
description: 提供 check-env 的操作流程与约束；适用于 需要检查某个 `.env` 文件中的环境变量是否配置完整时使用。
version: 0.0.0
---

# check-env

## What this skill does
- 运行 `./tools/check-env.sh` 检查指定变量是否存在且有值
- 输出缺失或空值变量的结果

## Constraints
- 不修改 `.env` 文件内容
- 不自行猜测变量名

## Allowed commands
- `./tools/check-env.sh`

## Steps
1. 获取 `.env` 文件路径与要检查的变量名列表。
2. 运行 `./tools/check-env.sh <env_file_path> <var1> [var2] ...`。
3. 汇总检查结果与失败项。
