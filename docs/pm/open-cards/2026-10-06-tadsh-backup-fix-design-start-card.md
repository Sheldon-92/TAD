# 开跑卡 — tad.sh 备份缺陷修复 · 设计步（Alex）

- 项目名：TAD 本体维护（安装器缺陷修复，GM 工单）
- Epic位置：Epic 外单开一刀（与 Phase 4 并行，互不重叠）
- role=Alex
- 任务名=备份面收窄＋落点迁移＋保留策略＋rollback 对齐的设计与 HANDOFF
- channel=internal-subagent
- model=Muse Spark（原生 subagent）
- env=@MuseVM
- prev_verdict: 无
- prev_note: GM 工单定性已坐实（根因在案），PM 已立票 TICKET-20261006-tadsh-backup-fix、处置决定单开一刀
- 目的=让安装/升级的备份只备框架、落本机、只留两份，止住它撑爆各席同步盘
