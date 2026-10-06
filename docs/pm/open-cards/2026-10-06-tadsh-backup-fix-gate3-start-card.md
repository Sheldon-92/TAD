# 开跑卡 — tad.sh 备份缺陷修复 · Gate 3 独立双审（CODE＋SAFETY 两路并行）

- 项目名：TAD 本体维护（安装器缺陷修复，GM 工单）
- Epic位置：Epic 外单开一刀 · 第四步（Gate 3 双审）
- role=Blake
- 任务名=对备份修复实施做独立双审（CODE 路／SAFETY 路，各自独立会话、互不可见）
- channel=internal-subagent
- model=Muse Spark（原生 subagent）
- env=@MuseVM（只读；fixture 复跑只许隔离面）
- prev_verdict: PASS
- prev_note: 实施完工、PM 验盘锚全等（COMPLETION 25,820 B／sha ebe93c54…；双机 fixture 14/14）
- 目的=让没参与实施的人独立复核：备份收窄不漏备、清旧不越界、回滚不伤数据面——GM 解冻全席安装要靠这个结论
