# 完工说明 — S4 收口（tad-evidence-revival-s4-01）

| 项 | 内容 |
|---|---|
| chain | TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL |
| step | S4（step_id：tad-evidence-revival-s4-01） |
| 执行会话 | afe84e51-6a08-41ad-acbc-290cc499a346 |
| 日期 | 2026-10-04 |

## 产物（两件，字节数实测）

| 产物 | 路径 | 字节数 |
|---|---|---|
| RG4 记录 | `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md` | 8,991 B |
| COMPLETION | `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md` | 8,443 B |

另 append 一行：`.tad/evidence/knowledge-usage-log.jsonl` step=S4（写后自验：全 5 行逐行可解析；genesis 1／含链 ID 行 5／含 handoff 路径行 4）。

### 章节清单

- RG4 记录：§1 结论先行／§2 Quality Rubric 评分（五维＋overall）／§3 RG4 判据四项复核／§4 AC 终核表（AC1–AC12）／§5 human CHECK 记录位（CHECK 待人＋待检要点 4 条）／§6 PM 裁定位与待 PM 裁事项清单（7 项）／§7 收口件清单。
- COMPLETION：链程摘要（五步产物＋verdict 表、四锚、推荐结论引用）＋FR11 四节标题逐字在位：`## KA`（候选 3 条，各附覆盖核查与建议落点）、`## Friction`（F1–F6，含状态）、`## Evidence Checklist`（F-2 四件，件四标待 PM）、`## Provenance`（逐件生成方式表＋实际写面 AC12 对照）。

## 读取清单回执（激活包 §③，逐项已读）

- [x] HANDOFF §3.1（FR1–FR11）、§4.5、§4.6、§6 S4、§9.1 全表（AC1–AC12，含 C-T2 勘误后 AC5/AC6/AC11 行）
- [x] `.tad/templates/research-quality-rubric.md`＋`.tad/gates/research-gate-canonical-checklist.md` RG4 节
- [x] S1 summary、S2 Brief、RG3 verdict、PM 验盘四件（S1/S2/S3/C-T2）、`.tad/evidence/phase3-first-chain.md`
- [x] `.tad/project-knowledge/principles.md`＋`patterns/_index.md`；另读 COMPLETION 模板 `.tad/templates/completion-report.md`，及 KA 落点核查所需的 `patterns/ac-verification.md`、`patterns/shell-portability.md` 相关条目

## AC11 自跑输出（C-T2 勘误后逐项断言，对 COMPLETION 实跑）

```
grep -ciE 'knowledge assessment|^## KA'  → 1
grep -ci 'friction'                      → 1
grep -ci 'evidence checklist'            → 1
grep -ci 'provenance'                    → 1
链 exit = 0（四计数均 ≥1，AC11 PASS）
```

附：AC9 自验对 RG4 记录实跑——`grep -cE 'citation_accuracy|评分|rubric'`＝7、`grep -c 'CHECK'`＝4、`grep -c '待人'`＝3，均达标。

## AC 终核要点

- AC1–AC9、AC11、AC12：PASS（逐条依据见 RG4 §4；AC5 实跑 4/4/5/3、AC6 实跑 14/15/10/1/6，与 PM C-T2 验盘值逐一相等；AC4 第三次独立重算 8706/5/4355/16/13082 全等；AC2 复验分支尖仍 `8713ea4e`；AC12 `.gitignore` diff exit 0）。
- AC10：唯一悬空，按设计待 PM——锚行未写入，本步不冒充已过；PM 写入后终核（`研究轨收口:` 起首行应恰 1 行；盘上现有注释行以 `<!--` 起首不入计数）。
- AC3 复跑注记：盘侧默认管线计数 8734（设计时 8708），增量为设计后盘上新增文件（含本链自身产物）在该管线下的计入；判据（exit 0＋正整数）满足，权威口径以 S1 安全管线四锚为准，已在 RG4 §4 注明。

## 收口锚行建议稿（全文，待 PM 写入 `.tad/evidence/phase3-first-chain.md`）

```
研究轨收口: RG3=.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md（PASS）；Brief=.tad/evidence/research/maintainer-evidence-revival/decision-brief.md；RG4=.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md
```

## 待 PM 裁事项清单（复述，只列不裁）

1. 载体采纳：是否采纳案一（或改采案二/案三）。
2. 新鲜度看守三项参数：阈值、复算周期、责任人（RG3 弱点 1），并指定落盘位置。
3. 推荐前提重议触发条件（RG3 弱点 2）：usage log 攒出「主仓关键件高频直读」证据时 PM 重议推荐。
4. branch-only 16 件＋gitlink 1 件去向（RG3 弱点 3）：列后续恢复执行链设计强制首步，逐件给保留/弃置意见后才许动载体。
5. 收口锚行写入与 AC10 终核（建议稿见上）。
6. C-T3 第二算：Gate 2 两 verdict 的 sha256/字节在收口验盘复核。
7. KA 落点终定：COMPLETION KA 节三条候选（①忽略树盲视——已有覆盖，建议补实例；②quotepath 伪差集——新知识，建议 shell-portability.md 新立条目；③断言逐项化——原则已有覆盖，建议补误 PASS 方向实例）。

## 纪律自证

写入仅限激活包 §⑤ 三处＋usage log append 一行；证据日志、票、HANDOFF、上游产物一字未改；仓外零写；gm 仓只读；git 全程只读未提交；同步目录内 python 均带 `PYTHONDONTWRITEBYTECODE=1`。
