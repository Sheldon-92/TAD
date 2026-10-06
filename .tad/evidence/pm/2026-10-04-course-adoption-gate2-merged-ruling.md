# Gate 2 合并裁定 — 课程判断落地链设计

- 日期：2026-10-04
- 裁定人：📐 TAD PM
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（46,329 B）
- 输入：tech 路 verdict（CONDITIONAL，P0=0／P1=1／P2=3）`.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md`；fit 路 verdict（CONDITIONAL，P0=0／P1=1／P2=3）`.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md`。两件 PM 已盘上复算在册。

## 裁定

**CONDITIONAL PASS。** 设计主干与四项贴合成立（两路一致）；条件收敛为一次设计增补（清单 B1–B7），Alex 增补后 PM 定点核销转 PASS，不重审全件。

## 逐项裁定

1. **C1 触发集（fit P1-1，PM 逐字拍板）**：**对齐提案原件适用面＋兜底句**。触发集定为六面：L3 动作、跨仓/跨席位写、引入新连接器/MCP/依赖、不可逆动作、涉及金额、对外动作；末加兜底「及 PM 判断为高风险者」。设计自拟的「删除／密钥／公网／生产」并入 L3 项下作例示、不单列。增补时回填 FR1 与 §4.2 三处同串，三处逐字一致。
2. **gate skill 同步面（tech P1，C-T1 照准）**：§2.2 装载面盘点补 `.agents/skills/gate/SKILL.md` 一行；Phase 1 增「同步遍」（Canonical 改后按其自带纪律同步内嵌清单与计数，计数行在 AC14 设点名例外）；新增双在册 AC（Canonical 与 gate skill 两面条文同在）。此条正是 C4 要防的失效形态在设计自身的实例，增补须在落点表显式回指。
3. **CF-1**：照设计，裁定边界句写死——「Gate 清单只许增**存在性检查项**、不许增**格式强制项**」；C1 入清单属前者，与「拒四元组入清单」（后者）不冲突。
4. **CF-2**：照设计——E 维以判据子款形态入 Gate 3，不增维、不改 Why CE 行；本裁定明示此为有意保留，留痕在此。
5. **CF-3**：照设计——两行入 Alex 义务块首部。
6. **CF-4**：照设计——权威顺序短文落仓根 AGENTS.md；本裁定明示：知悉该面随发布同步传播下游，短文为普适顺序、传播属预期效果，有意接受。
7. **CF-5**：照设计——不新建 WS-0 文件。本席回填解释：票面「并入 WS-0/装载层口径」在本仓的执行解释为**并入 Canonical SSOT 装载面**，Gate 3 不许以「无 WS-0 文件」字面误判。

## 增补清单（B1–B7，逐项销账）

| # | 内容 | 出处 |
|---|---|---|
| B1 | 触发集按本裁定 1 回填 FR1 与 §4.2 三处同串（逐字一致） | fit P1-1 |
| B2 | §2.2 盘点补 gate skill 行；Phase 1 增同步遍；新增双在册 AC；AC14 计数行点名例外 | tech P1（C-T1） |
| B3 | 风险卡路径大小写全文统一（`RISK-<task_id>.md` 与 `risk-TASK-…` 二选一全文一致） | tech P2（C-T2） |
| B4 | C3 草案行数自述改准（实测 15 行；AC9 上限口径随之对齐） | tech P2（C-T3） |
| B5 | AC2 负控词表补被裁原件 §1/§2/§6 三节名 | fit P2 |
| B6 | Phase 2 dogfood 卡改如实声明（本链未命中触发项、为演练件），删比附勾注 | fit P2 |
| B7 | AC13 注记与 AC15 合取判读 | fit P2 |

## 关闭方式

Alex 增补完工说明逐项回指 B1–B7 落点；PM 定点核（读段＋grep＋触发集三处同串比对）全销后在本件追加 PASS 销账行，再派 Blake 实施。

## 销账（2026-10-04，PM 定点核）

**Gate 2 PASS。** Alex 增补已落（HANDOFF 修订后 54,120 B／675 行／sha256 `2446ea78…7983`，与完工说明自报全等）。PM 逐项核：B1 触发集定串（含「及 PM 判断为高风险者」）四处同串命中、旧串残留 0 ✓；B2 gate skill 盘点行＋同步遍＋AC16 双在册＋AC14 例外 ✓；B3 路径大小写统一、大写残留 0 ✓；B4 行数改准 15 行 ✓；B5 AC2 词表补三节名 ✓；B6 dogfood 改如实演练声明 ✓；B7 AC13 与 AC15 合取注记 ✓；裁定 3 边界句与裁定 7 WS-0 执行解释均已回填 ✓。附记：完工说明自报 6,466 B、盘上实测 6,448 B，差 18 B 为自报测量时点差，不影响落点，记录在案不阻塞。下一步：Blake 按 HANDOFF 实施（写集＋同步遍＋dogfood 演练件）。
