---
name: no-sync-pull-based
description: "*publish 后不再 *sync 到下游项目；下游各自用 GitHub 安装命令 (npx/curl) 拉取更新"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d0ae1b3c-6314-4115-a55a-f791b8d92f44
---

*publish 后不再提供 *sync 选项，不再批量同步到 14 个下游项目。

**Why:** 用户不想再维护推送式同步流程。下游项目按需自己拉取更新更灵活，也避免了 v2.30.0 sync 中 install.sh 导致 21 包降级的类风险。

**How to apply:** *publish 完成后只报告 "tag pushed to GitHub"，不再问"需要 *sync 吗？"。如果用户在下游项目需要更新 TAD，建议用 `npx github:Sheldon-92/TAD` 或 `curl -sSL ... | bash` 从 GitHub 安装。*sync 命令本身保留（用户可以显式调用），但 Alex 不主动推荐。
