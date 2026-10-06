# Phase 0 基线冻结 — Epic P2 测量层（2026-10-06，Blake 实施步）

Step 0 路径断言：`pwd`＝/home/hatch（shell 起点），全部写集路径以仓根绝对路径 `/home/hatch/workspace/yun-sync/TAD` 为准；仓外同名文件禁写。HANDOFF 对锚：78,569 B／sha256 `e680d83ad8d22d9ee08eb3cfc8bbdf044428c0861f4d8bc1733d78736554de2d`，与派发锚全等。

## §2 锚值逐项复算

| 锚 | 设计值（§2/MQ） | 复算值 | 判读 |
|---|---|---|---|
| MQ-1 version.txt | 3.0.2 | `3.0.2` | ✓ 一致，本链不改 |
| MQ-1 POINTER 首行 | `# TAD 常驻指针 — 📐 TAD` | 逐字一致 | ✓（AC23 基线） |
| MQ-2 NOCARRIER | 147 | 155 | 漂移 +8，全归因本链自产件：completions 22→24（+2）、pm 18→22（+4）、reviews 18→20（+2）；§4.0 步骤 1 明文「实施时以复算值为准」 |
| MQ-2 STALE | 2 | 2（`.tad/evidence/knowledge-usage-log.jsonl`、`.tad/evidence/pm/downstream-versions.md`） | ✓ 点名逐一对上 |
| MQ-2 CARRIED | 13072 | 13072 | ✓ |
| MQ-2 BRANCH_ONLY | 9 | 9 | ✓ |
| MQ-2 分支尖 | `459ab78f…` | `459ab78f5aa54dc1056522780607dcfeb473c647` | ✓ 未动 |
| MQ-2 TIP_AGE_DAYS | 1 | 1（尖提交 2026-10-05T00:39Z） | ✓ |
| MQ-3 清单行数 | 13,130 | 13,130 | ✓ |
| MQ-3 类别×outcome | nc/synced 8714、carried/pending 4355、nc/embedded 40、branch-only/kept 9、branch-only/dropped 7、stale/synced 5 | 逐项全等 | ✓ 队列（class∈{no-carrier,stale-content}∧outcome=pending）＝0 |
| MQ-3 谱系断言 | `459ab78f` 为 `8713ea4e` 后代、区间 1 笔脚本自产提交 | 设计步已验，本步尖未动、沿用 | ✓ 默认调用形态成立 |
| MQ-4 publish 步序 | 3→3b→3c→3c2→3c3→3d→3e→step4 | publish-protocol 行号：step3 L75、3b L84、3c L98、3c2 L144、3c3 L164、3d L178、3e L211 | ✓ 3e 为 step4 前最后阻塞步 |
| MQ-4 publish-ops 落点 | §2.5 supporting、§5 L163 | §2.5 L88、§5 标题 L163 `## 5. Ambiguous result and replay recovery` | ✓ |
| MQ-5 minor detect-only | 25 hits／20 文件 | 25 hits／20 文件（`phase0-minor-detect.txt`，exit 1 为预期） | ✓ |
| MQ-6 三案指针 | 判断正本＋notes-02 第 1 条、notes-05 第 7 条、proposal B1/C1/C4/D5 | 判断正本在盘；`tech-radar/consult/tad-sweep/{notes-02-evaluation.md, notes-05-orchestration-models.md, proposal-package-v1.md}` 均在盘 | ✓ |
| MQ-7 📐 种子扫描 | 跟踪面仅 POINTER 本体＋`.agents/skills/tad/SKILL.md:159` | 复跑：`.tad/templates|.tad/tasks|.tad/gates|.agents/skills` 跟踪面命中仅 `.agents/skills/tad/SKILL.md`（L159「📐 **Adaptive**」合法符号用例）＋POINTER 本体 L1 | ✓ |
| MQ-8 gate-execution Gate 3 节 | L150 起 | 实施 Phase 2 时复核 | 记录 |
| MQ-10 对象链件 | HANDOFF archive／COMPLETION／reviews gate2-3-4 | Phase 1 时逐件在盘核对 | 记录 |
| MQ-11 hop 集 | 止于 `2.43.0-to-2.43.1.yaml` | Phase 3 时复核 | 记录 |

## 件 2.0 测算（§4.0 步骤 1–2）

- 盘面集 A（freshness 同口径：`.tad/evidence`＋`.tad/archive`，剔 EXCL 两件与 embedded/gitlink 前缀件）：与分支集 B 差集（增量集，**再明文剔除账本两件** execution-manifest.jsonl／branch-disposition.tsv——两件均在差集中、按 B3 裁定不入增量集）＝ **153 件**；陈旧集＝2 件（上表点名）。
- 增量集构成：epic-p1-clearance-20261006 59、completions 24、pm 22、reviews 20、closeout-batch-20261005 11、activation-packages 10、archive/handoffs 4、ralph-loops 1、releases 1、risk-cards 1（合计 153）。
- 追加前断言：153 件路径与清单现有 13,130 行 path **零重复**（脚本复算，dup=0）。
- 增补行草案：`2.0-append-draft.jsonl`（155 行＝153 增量 no-carrier/pending＋2 supersede stale-content/pending，字段照 §4.0 步骤 2/3，`appended_at_epic_p2: true`）。
- D-2 裁断已落盘（`.tad/evidence/pm/2026-10-06-epic-p2-design-rulings.md`：认主案，Blake 在脚本围栏内执行）→ 本 Phase 直接正式写清单并执行 §4.0 步骤 4–6。
