# 开跑卡 — 自查批 R2 · 回归重放补跑（Gate 4 条件销账）

- 项目名：TAD 本体维护（自查批 R2）
- Epic位置：无 Epic · 自查批 R2 收口步（Gate 4 唯一条件的销账动作）
- role=Blake
- 任务名=在含 R2 改动的当前树上补跑一轮回归重放（三案洁净对照＋被测＋机械判分）
- channel=internal-subagent
- model=Muse Spark（原生 subagent，被测/对照捕获走 grokbox OpenCode deepseek-v4.1-flash，与基线同通道同模型）
- env=@MuseVM＋@grokbox（捕获在 grokbox 隔离面）
- prev_verdict: CONDITIONAL
- prev_note: Gate 4 七组全 PASS，唯一条件＝模板面改动触发 Regression Replay、最近一轮早于本链改动，须在含改动的树上补跑一轮、整轮 PASS 即自动销账
- 目的=证明这批模板与规程改动没把框架既有行为弄退化
