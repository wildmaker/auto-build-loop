## Standard Workflow（每个 backlog item）

1. 理解需求：**阅读 backlog 条目和相关规范（spec），理解需求目标。**
2. 基于 **Epic 分支** `epic/<epic-name>` 创建 `spec/<spec-name>` 分支，并切换到该分支

3. 使用 `@openspec-init-change` 初始化 OpenSpec 变更、Issue（inputs: `<spec-name>`, `<issue-title>`, `<branch>`；`<spec-name>` 同时作为 spec name 与 change ID，对应目录 `OpenSpec/changes/<spec-name>`）

4. 应用 OpenSpec 变更到新创建的 `spec/<spec-name>` 分支:
  - `/openspec:apply <spec-name>`

5. **本地检查（最少必跑）：**
按照本地 CheckList 运行最少检查项（如 lint/test/build 等），本地通过后再提 PR。

6. **PR 评审闭环（创建 PR -> 处理评论）：**
运行 `git-pr-review`（inputs: `<base-branch>`, `<issue>`, `<spec-name>`；其中 `<base-branch>` 应为 `epic/<epic-name>`；在 PR 中引用对应的 Issue 和 OpenSpec 变更）。

7. **远端 CI 全绿后合并：**
在合并前必须确认：
- PR 的 High/Medium 评论已闭环（含自动 reviewer，例如 gemini-code-assist；按 `git-resolve-pr-comments` 的轮询约束等待 review/comments 出现）
- PR 的远端 CI checks 全绿（CI is green）

合并时的分支策略：
- **不要删除 `spec/*` 分支**（禁止 `gh pr merge --delete-branch`）
- 若 repo 设置导致 merged 后自动删除 `spec/*`：从 PR head SHA 恢复该分支并推送回远端（用于 Epic 完成后的统一清理）

完成合并后，将本地 `epic/<epic-name>` 同步到远端最新。

8. **通过单独 PR 归档该 OpenSpec 变更：**
   - 从 `epic/<epic-name>` 创建归档分支（建议）：`chore/archive-<spec-name>`
   - 执行命令：`openspec archive <spec-name> --yes`
   - 提交归档变更后，**同样必须**运行 `git-pr-review` 等待并处理 High/Medium 评论，再合并归档 PR（不要“提交→秒合并”）

