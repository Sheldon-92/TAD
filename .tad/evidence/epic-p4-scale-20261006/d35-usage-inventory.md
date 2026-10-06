# D35 usage log 存量盘点件 — Epic Phase 4 件 4.3a（2026-10-06，Blake，AC18/AC20）

源：`.tad/evidence/knowledge-usage-log.jsonl` 全量解析（6 行逐行可解析）。口径出处：载体裁定 `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md` §20——关键件＝Gate verdict／设计件／COMPLETION／PM 裁定件四类；触发＝log 累计满 50 行后统计，任一关键件跨链引用 ≥5 次即重议。本件数字与设计锚 HANDOFF §2.3 逐值比对，全等。

## A. 存量构成

| 项 | 值 |
|---|---|
| 总行数 | 6（genesis 1＋usage 5）／4,530 B |
| 时间跨度 | 2026-10-04T22:15Z → 2026-10-05T03:27Z |
| 涉及链 | 2（TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL ×4 步、TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION ×1 步） |
| knowledge 引不同件 | 28 |
| 停摆事实 | 2026-10-05 后 P1/P2/P3 三链向 log 追加 0 行（装载点缺失为根因，修复见件 4.3a 装载点节） |

## B. 逐件计数（提及／不同链，降序；全 28 件）

| 件 | 提及 | 链 |
|---|---|---|
| `.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md` | 4 | 2 |
| `.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md` | 3 | 1 |
| `.tad/project-knowledge/principles.md` | 3 | 1 |
| `.tad/project-knowledge/patterns/_index.md` | 3 | 1 |
| `.tad/gates/research-gate-canonical-checklist.md` | 3 | 1 |
| `.tad/evidence/phase3-first-chain.md` | 2 | 1 |
| `.tad/project-knowledge/patterns/ac-verification.md` | 2 | 1 |
| `.tad/project-knowledge/patterns/release-sync.md` | 2 | 1 |
| `AGENTS.md` | 2 | 1 |
| `.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl` | 2 | 2 |
| `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` | 2 | 1 |
| 其余 17 件（activation-packages ×3、reviews ×2、pm ×4、templates ×4、TICKET、AUDIT、EPIC、research-methodology） | 各 1 | 各 1 |

（全量逐件行由 `.tad/scripts/knowledge-usage-count.sh` 一条命令可复算，输出与本表逐值一致——AC19。）

## C. 关键件四类计数（分类规则见计数脚本头注）

| 类 | 命中件 | 逐件（提及／链） |
|---|---|---|
| Gate verdict | 2 | `reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md` 1／1；`reviews/rg3-critic-maintainer-evidence-revival.md` 1／1 |
| 设计件 | 3 | HANDOFF（同上）3／1；`decision-brief.md` 2／1；`active/designs/AUDIT-20260816-framework-health.md` 1／1 |
| COMPLETION | 0 | —（log 内无 COMPLETION 件被引） |
| PM 裁定件 | 3 | `pm/2026-10-04-evidence-revival-carrier-ruling.md` 1／1；`pm/2026-10-04-evidence-recovery-17items-ruling.md` 1／1；`pm/2026-10-04-evidence-recovery-f1-ruling.md` 1／1 |

（另 `pm/2026-10-04-evidence-revival-s1-pm-verify.md` 1／1 为 PM 验文件、非裁定件，不入四类，单记于此。）

## D. 触发判读（AC18）

`TRIGGER: NOT MET (lines 6/50, max cross-chain 2/5)`——双条件均未达：行数 6＜50；关键件最高跨链 1（全 log 最高跨链为 inventory-summary 的 2，非关键件）＜5。**直读重议不触发。**

## E. 复产清单结论（AC20）

**直读重议清单＝空集。** 唯一依据为 §B–§D 计数（触发双条件未达、无任何关键件接近阈值），无凭印象列件。本件的「复产」对象据实转为记账行为本身：装载点修复（completion-report 模板 Knowledge Usage 节＋evidence-collection append 步）与计数脚本，见 Phase 3 其余步；本链收口以 dogfood 一行自证装载点（AC22）。
