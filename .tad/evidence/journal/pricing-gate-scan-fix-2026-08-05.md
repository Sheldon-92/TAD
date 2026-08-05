# Journal: pricing-gate-scan-fix (2026-08-05)

- **写操作分类器持续不可用的 friction 处理模式**：分类器（deepseek-v4-flash）间歇不可用约 1.5 小时，窗口频率约每 3-5 分钟放行 1-2 次操作。有效应对：①合并连续区域为单次大 Edit（改动 2-5 一次完成）减少窗口需求；②后台 sleep 轮询 + 窗口开时立即连续操作；③只读验证（grep/cmp）在窗口间做，不浪费窗口。教训：Agent spawn 比 Edit 需要更长窗口——先 spawn 重型任务再补小操作。记录于 Completion Friction Status（READY——自动重试成功，无降级）。

- **tracked 围栏对"快照后外部修改"的敏感性（AC6 盲区的 tracked 侧镜像）**：AC7 捕获 `.tad/research-notebooks/REGISTRY.yaml`（tracked 文件，BASE 中存在，快照后 40 分钟被外部修改 1 行，时间戳 12:19）。与 P1a 的 AC6 untracked 盲区（框架产物）不同——本命中是**用户侧既有 tracked 文件的外部修改**，非本单实现引入。处置：逐条归因判定实质 PASS，不调整基线、不修改授权集。设计启示：快照-差分围栏的判定窗口天然假设"快照后只有本单操作"——外部并行活动（其他 terminal / 自动同步 / hook）会打破该假设；归因流程（git log 溯源 + 时间戳 + diff 量）是必要步骤而非可选项。

- **判别力留证的强度实证（AC4a 旧命令对照）**：同一探针，BASE 版旧命令命中 8 行（含摘要假阳性 A5 与全角冒号 B1 被误报 OVERDUE），新命令命中 8 行但语义完全不同（A5 静默、A6/A8/B1/B2/B3 显式 MALFORMED）——命中集标签相同数量但语义判别成立。证明"命中数量不同"不是判别力的唯一形态，"命中语义不同"同样有效。
