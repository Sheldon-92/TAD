# 开跑卡 — tad.sh 备份缺陷修复 · 实施（Blake）

- 项目名：TAD 本体维护（安装器缺陷修复，GM 工单）
- Epic位置：Epic 外单开一刀 · 第三步（实施）
- role=Blake
- 任务名=照 HANDOFF＋增补改 tad.sh：备份面收窄、落点迁移、保留两份、清单域回滚
- channel=internal-subagent
- model=Muse Spark（原生 subagent）
- env=@MuseVM（验证全走隔离 fixture，严禁碰真实项目仓）
- prev_verdict: PASS
- prev_note: Gate 2 双审 CONDITIONAL 经 PM 合并裁定＋增补 S1–S4 核销转 PASS；风险卡已落盘
- 目的=把撑爆各席盘的备份缺陷修掉，让 GM 能解冻全席安装/升级
