# Install-Smoke-v2410 独立审查报告（首轮 + 增量复核）

## 首轮（2026-08-11）
Reviewer: opencode/deepseek-v4-flash 独立只读 reviewer
Verdict: **CONDITIONAL** — P0=0, P1=2, P2=4
- P1-1（执行实证）：findings.md 不存在（契约文件清单创建项 + AC19 判据指向）→ 已补齐
- P1-2（执行实证）：AC17 正控 (a)(b) 未落盘（契约要求两次正控，缺一不算验证过）→ 正控 (a) 已补跑
- P2-1: AC18 前值 984M 无原始 du 输出行（存在于 scope-baseline.txt）
- P2-2: AC14/AC15 在 U2 执行（契约指定 U）——F1 下合理替代，已如实注明
- P2-3: AC10 real-missing-lines=1 为单空行（od -c 实证），非真实路径
- P2-4: F1 范围声明不足（实测 2.40.0 亦无 probe_remote_version）→ findings.md 已扩
- 独立实证：F1 机理成立（2.30.0 tad.sh L961 detect_state 先于 L1073 下载/L1079 derive；2.41.0 L1436 probe 前置）；`git show v2.40.0:tad.sh | grep -c probe_remote_version` = 0 → **2.30.0–2.40.x 全受影响**；AC9/AC10/AC10b/AC11/AC14/AC15/AC16 判据全部重跑成立；recovery_policy partial 语义检查通过

## 增量复核（2026-08-11）
Reviewer: 同上（只审处置）
Verdict: **PASS** — 两个 P1 + 三项新增处置全部实证成立，无残留条件
- 盲区探针：篡改 gate-design.md（基线有摘要）→ fence-audit 报 VIOLATION-DIGEST；恢复 → CLEAN。NEW-PATH 分支仅命中基线无摘要路径，无盲区
- fence-fresh 的 VIOLATION-NEW-TRACKED 与 fence-audit 的 VIOLATION-DIGEST 两机制配对闭合
- findings.md 覆盖 P1-1/P2-4 要求；AC16/AC17 记录与实跑一致
- 备注（不阻塞）：正控 (b) 归档后执行，为待办而非遗漏
