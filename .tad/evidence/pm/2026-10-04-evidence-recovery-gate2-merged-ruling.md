# Gate 2 合并裁定 — 证据载体恢复执行链设计

- 日期：2026-10-04
- 裁定人：📐 TAD PM
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（56,104 B）
- 输入：tech 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-tech-review-evidence-carrier-recovery.md`（CONDITIONAL，P0=0／P1=4／P2=5；盘上复算 12,702 B）；fit 路 verdict `.tad/evidence/reviews/2026-10-04-gate2-fit-review-evidence-carrier-recovery.md`（CONDITIONAL，P0=0／P1=2／P2=3；盘上复算 10,493 B）。两件字节/sha 已由 PM 盘上复算，自报差异仅为自报行追加所致，属实。

## 裁定

**CONDITIONAL PASS。** 设计主干成立（两路一致确认）；全部条件收敛为**一次设计增补**，由设计者 Alex 在新会话按下列清单逐项落进 HANDOFF，PM 逐项定点核销后 Gate 2 转 PASS，不重审全件、不进 Phase 0。

两路独立命中同一缺口（PM 三点裁定的裁定 2／3 未落进设计），互为印证，按合并项处理。

## 增补清单（逐项销账，落点以增补完工说明回指为准）

| # | 内容 | 出处 |
|---|---|---|
| A1 | **裁定 2 对照行落点**：C2 处置表增 `origin_path`／`origin_sha256` 两列，drop 行必填；写明「找不到在册原件自动转保留并报 PM」的判定与留痕位置；AC3 增断言（drop 行两列非空且 sha 与原件当场重算一致）；Phase 3 对账回指该对照 | tech P1-4 ＝ fit F-1（C-F1） |
| A2 | **裁定 3 备案件产物化**：备案件列为 Phase 1 正式交付物（路径形态 `.tad/evidence/pm/<执行日>-termination-secret-isolation-check.md` 或执行步定名并在 Phase 1 定稿记录回指）；§7 CREATE 增列；新增一条 AC（备案件在盘、含核查人/方法/结论三项、不引疑似凭据原文）；Phase 1 步骤 1 停步措辞改齐「该件悬置、其余 16 件照常推进」，并明示「PM 另行裁定前不入任何载体（分支、主仓、同步清单均不许）」 | tech P1-3 ＝ fit F-2（C-F2） |
| A3 | **EXCL 归属写死（PM 定案取 EXCL 路）**：Phase 0 差集计算与执行版清单追加同样适用 S1 的 EXCL（盘点产物 2 件不入清单、不入队列，仅在锚比对中按 summary 口径处理）；AC6 期望式的盘上集明确同一 EXCL 口径 | tech P1-1 |
| A4 | **C3 尖前置自检参数化**：改为对本次运行期望基线断言（如 `--expect-base <sha>`，首跑取 Phase 0 记录、再跑取上轮产出尖），或断言「当前尖为 Phase 0 记录尖或其在本链围栏内的后继」；回改 C3 受影响句，保证 Phase 2 自测三态（正常／NO-OP／失败中止）可达、NFR4 幂等不被自检破坏 | tech P1-2 |
| A5 | **C1 冻结 carve-out**：冻结句后增一句——§4.7 同名改写件追加为唯一例外，追加行带 `appended_at_phase3: true` 标记；注明 AC1 计数口径不受 Phase 3 追加行污染 | tech P2-1 |
| A6 | **FR5 措辞改齐 AC6**：「keep 的 blob 行数，gitlink 不计」 | tech P2-2 |
| A7 | **AC8/AC10 基线时点声明**：增补一句——两条基线以 Phase 0 完工记录中复算时点登记值为准（Phase 0 记录即基线源），非设计时点钉值 | tech P2-3 |
| A8 | **阈值形态定案（PM 定案取 C5 写明路）**：C5 写明看守阈值判定须以 bash `[ … -gt 100 ]`／`[ … -gt 21 ]` 形态落地，AC14 维持原文 | tech P2-4 |
| A9 | **AC5 断言面补齐**：正项增 `read-tree`、`write-tree` 两词逐项断言；负项 `git add` 改为只对非注释行判定 | tech P2-5 |
| A10 | **AC6 表注修正**：§9.1 表下注记改为「本表除 AC6 外均为 command 文法；AC6 以首轮报告所附断言脚本为执行形态」 | fit F-3 |
| A11 | **AC9 合取注记**：§9 完成判据处注记「AC9 须与 AC8 合取判读，单独 PASS 不构成推送完成证据」；Gate 3 按此执行（本裁定同时作为 Gate 3 判读指令） | fit F-4 |
| A12 | **usage log 衔接（PM 点明口径：写）**：设计增补一句——本链在 Phase 5 收口时按 `.tad/evidence/knowledge-usage-log.jsonl` 既有格式追加一行，记本链对 S1 盘点产物与载体裁定的引用（该文件是 D35 计数与重议触发的计数基础，本链为载体恢复链，留行与上游链惯例一致） | fit F-5 |

## 关闭方式

Alex 增补完工说明逐项回指 A1–A12 的落点（章节＋行号）；PM 逐项定点核（读段＋grep），全销后在本件追加「Gate 2 PASS」销账行并播报，随后按链推进 Phase 0。任一项未落位，只补该项，不重开全审。

## 销账（2026-10-04，PM 定点核）

**Gate 2 PASS。** Alex 增补已落（HANDOFF 修订后 61,816 B／634 行／sha256 `4c45cac5…eaa2b`，与完工说明自报全等；完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-design-amend-note.md`，5,933 B）。PM 逐项读段＋grep 定点核：A1（C2 两列＋自动转保留＋Phase 1 回填／Phase 3 对账回指）✓；A2（AC16 新增＋悬置措辞＋不入任何载体）✓；A3（AC6 同一 EXCL 口径）✓；A4（C3 `--expect-base` 参数化）✓；A5（C1 carve-out＋`appended_at_phase3`＋AC1 计数口径）✓；A6（「keep 的 blob 行数，gitlink 不计」四处齐）✓；A7（基线时点声明）✓；A8（C5 写明 `-gt` 形态、AC14 原文未动）✓；A9（AC5 正项增 read-tree/write-tree、负项非注释行判定）✓；A10（表注改齐）✓；A11（§9 合取判读注记）✓；A12（Phase 5＋§7 usage log 追加一行）✓。**A1–A12 全销，Gate 2 关闭条件清零。** 下一步：Blake 实施第一段（Phase 0 复算冻结＋Phase 1 十七件定稿），定稿经 PM 核准文件后才许动载体。
