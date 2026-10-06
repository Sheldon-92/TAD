# 本体输入登记 — 初装仓 migration manifest 缺失（GM 上报，2026-10-05）

- 来源：GM 上报（3.0.1 刷新批实测）：以 `--source` 全新初装的仓不留 migration manifest，升级时 migration engine 恒报「REJECT: chain gap at 3.0.0 — no manifest from 3.0.0. Suggest clean reinstall.」并跳过迁移步。实测两席同形态：外刊阅读、Menu Tales；两仓同步与自检 PASS、无 handoffs 存量待迁。GM 本批已裁不重装、按补验/自检口径验收。
- 证据：两席 `.tad/evidence/install-checks/2026-10-05-*-report.md`（各仓）。
- 本席登记：列入**下个本体批候选清单**，不急、随批处理。
- 初步倾向（未定案，待下批设计核）：风险点在噪声掩盖真 chain gap。genesis manifest（初装时落一份创世清单）方向更治本——让每个仓从初装起就有完整迁移链锚；自检豁免方向会把真 gap 一并豁免，只宜作过渡口径。下批设计时先盘 migration engine 的 manifest 消费面再定案。
