# 定性 — 技术研究席 3.0.2 刷新两点（2026-10-06，GM 转交，TAD PM 判读）

输入：`tech-radar/.tad/evidence/install-checks/2026-10-06-refresh-302-report.md`；判读依据：Phase 1 HANDOFF §4.6（件 1.6）与 tad.sh／migration-engine 现行实现。

## 一、迁移 skipped 与 Pack「1 migrated」并存

**定性：不矛盾，两行是两个计数面。** Pack status 的 migrated 是 pack 层计数（本轮一个 pack 在同步时做了结构迁移）；`Migration skipped` 是版本链迁移引擎的判读（3.0.1→3.0.2 的 hop 链）。链引擎跳过的原因有两段，均为已知形态：

1. 该仓是 genesis 机制之前的老装机、无创世锚——按 Phase 1 已成文的存量口径，这不构成故障：全量文件同步刷新（本轮 307 件）本身已把框架面带到 3.0.2，链迁移是增量变换的冗余保险，跳过不丢东西（3.0.2 本版无 delete/rename 类变更）。
2. 源侧 hop 集至今只到 2.43.0→2.43.1，3.x 的 hop 文件从未出厂——hop 义务是 Phase 1 才立的（publish-protocol step3d）。

**老装机处置**：不需要急补 genesis 锚。补登口径已成文（只许凭在盘初装证据，该仓历轮 install-checks 报告即属此类证据），执行属下游刷新面、由 GM 排期；补与不补都不阻塞后续刷新。tad.sh 对引擎 exit 2 记 WARN 跳过、整体 exit 0 的形态，与上述口径一致，属预期行为、不是假绿。

**连带自首（本席收口漏件）**：v3.0.2 发版未按新立的 step3d 义务随船 `3.0.1-to-3.0.2.yaml`（空操作形态即可）。Gate 4 未拦、本席收口未核。处置：并入 Phase 2 为**件 2.9**——补船该 hop 文件，并把「hop 文件在船」做成发版清单的断言步（与件 2.4 活体回归入清单同批落），防再漏。

## 二、装后 brain-index.md 仍不存在、自检 PASS

**定性：PASS 属实（断言辖区内无假绿），现象属待补件，且就此坐实 A1 的最后一个未证假设。**

- Phase 1 件 1.9 的目标侧生成步只加在**初装**路径；该仓走的是老装机**刷新**路径，生成步不在该路径上，故装后仍无 brain-index。发布源的读单断言（check6/check7）是发布源仓自己的 state-surface 检查，不构成下游安装检查；下游自检的 88 路径集不含 brain-index——PASS 在其辖区内成立。
- 但实质缺口在：该仓 AGENTS.md 路由行指向一个不存在的文件，席位开工读单会扑空——这正是技术研究席当初 A1 sighting（「brain-index 不存在」）的真实出处（下游刷新面副本），Phase 1 判断附记的未证假设至此证实。
- 处置：刷新路径补生成步（或与再生成机制合并设计），归 **Epic Phase 4 件 4.2**（brain-index 再生成机制与周期）的辖区注记，Phase 4 立票时注入；在那之前，下游刷新面无 brain-index 属已知预期形态，各席自检 PASS 判读不变。
