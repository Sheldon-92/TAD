# 开跑卡 — tad.sh 备份缺陷修复 · Gate 2 双审（tech＋fit 两路并行）

- 项目名：TAD 本体维护（安装器缺陷修复，GM 工单）
- Epic位置：Epic 外单开一刀 · 第二步（设计双审）
- role=Alex
- 任务名=对备份修复设计做独立双审（技术路／契合路，各自独立会话、互不可见）
- channel=internal-subagent
- model=Muse Spark（原生 subagent）
- env=@MuseVM（只读；fixture 干跑只许 /tmp 隔离面）
- prev_verdict: 无
- prev_note: 设计已成件（HANDOFF 44,721 B／sha dbc7d56c…），风险卡已由 PM 按草案落盘
- 目的=让没参与设计的人独立驳验：备份只备框架这件事，既不能漏备、也不能让回滚误删各席的证据数据
