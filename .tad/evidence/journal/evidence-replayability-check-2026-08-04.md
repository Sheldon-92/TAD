# Journal — evidence-replayability-check (2026-08-04)

- [2026-08-04] [commit-blood-path] AC6「commit 血径」口径下，step3c 若用 `git add -A`（opt-out 策略）
  会把并发写入的 NEXT.md 带进 commit → M 集 4 行 → AC6 FAIL。修复：commit 前显式钉死路径
  （`git add <3 个 M 文件> <证据 A 路径>`）。另：AC6 证据（AC6.txt）生成于 commit 之后，
  **不可再补 commit**——任何后续 commit 都会把 HEAD 换成 M 集=空的新 commit，AC6 重算即 FAIL。
  post-commit 证据留在工作区作为载体即可（A 文件不影响 AC6 的 M 判据）。
- [2026-08-04] [reviewer-tier] alias-mapped（DeepSeek 中转）下 Agent tool 显式指定 model=opus
  实际仍映射到 v4-flash（reviewer env 自报实证）——model 覆盖在聚合路由下无效；用户裁定：
  撤掉 model 指定，降级记录以 reviewer 实际自报 Model 行为准（REVIEWER-TIER-DEGRADED）。
- [2026-08-04] [ac-design] Gate-2-R1 补集断言（`(5 items)==0` + `(4 items)==1`）被独立 reviewer
  探针实证可杀掉「`(6 items):` 误改到 Gate 4 块」假 PASS 变体——AC 判别力设计获 post-impl 复核。
