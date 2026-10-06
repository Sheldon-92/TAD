# step3f 字段核对表 — 2026-10-06 三家 transcript（AC14）

判读正本：publish-protocol step3f（6 字段缺一不算；执行日期 ≥ 上一版发布日＝v3.1.0 发布日 2026-10-06）。

| # | 字段 | codex-20261006.md | opencode-20261006.md | cursor-20261006.md |
|---|---|---|---|---|
| 1 | runtime | ✔ codex | ✔ opencode | ✔ cursor |
| 2 | harness 名＋版本（＝OC-6 复测值） | ✔ Codex CLI 0.159.3 | ✔ OpenCode CLI 1.18.33 | ✔ Cursor Agent 2026.10.01-e373342 |
| 3 | 执行日期（≥2026-10-06 本周期） | ✔ 2026-10-06 | ✔ 2026-10-06 | ✔ 2026-10-06 |
| 4 | 链路类型 | ✔ 全链尝试、阻塞段位已点名 | ✔ 全链 | ✔ 全链 |
| 5 | 结果＋一句定性（含逐点位触发归属） | ✔ FAIL＋配额归属 | ✔ PASS＋逐点位 | ✔ PASS＋逐点位 |
| 6 | 原始输出指针（仓内路径，test -f 已核） | ✔ raw/p2-codex-session.log | ✔ raw/p2-opencode-session.log＋trigger-traces＋install log | ✔ raw/p2-cursor-session.log＋trigger-traces＋install log |

判读：三份字段齐（AC14 形态达成）。结果面：opencode/cursor PASS；codex FAIL（归属＝provider 账号配额，厂商消息原文在 raw 日志，建议重试日 2026-10-10 后）——按 HANDOFF §4.3 第 5 步，FAIL 已写明失败段与归属，不以整件含糊 PASS 充数；v3.2.0 收口时 step3f 对 codex 的 HARD 判读以本份 FAIL transcript 为在盘基线，PASS 基线待配额恢复后补跑（归属记 PM 收口材料）。
