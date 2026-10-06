# TICKET-20261006 — Epic Phase 1 · 本体清账批

- 状态：OPEN（2026-10-06 立票；Epic EPIC-20261006-tad-self-optimization Phase 1）
- task_id：TASK-20261006-EPIC-P1-CLEARANCE
- 性质：一链一 Phase、完整 TAD 链；一张总 HANDOFF 统辖 12 件、逐件 AC 化，不拆子链。发版衔接：本 Phase 收口后提议升 patch v3.0.2（口径提议，PM 收口定）。

## 范围（12 件，逐件出处见 Epic Phase 1 件目表）

1. 校验器漂移定案（改校验器口径或改投影契约二选一，设计内裁断、Gate 2 收口；A2「校验器对发布源自检入发版清单」并入本件）
2. 版本口径恒久修订（改面以 Must-Version Registry＋发布前例为准，落 publish-protocol／模板措辞）
3. minor/major 史述面口径（168 件历史叙述在 minor/major 硬拦下的处置规则先行定案——**跨 Phase 硬约束：必须先于任何 minor 升版**）
4. session-state 索引旧引用清理（state-surface check5 四项）
5. AC11 计数口径订正（登记面 25 对口径，HANDOFF 方法文与相关模板措辞）
6. 初装 genesis manifest（GM 输入：初装落创世清单，消 REJECT 噪声；先盘 migration engine 的 manifest 消费面）
7. hooks.json 排版收敛＋语义比对口径（GM 输入）——**[Gate 2 裁断注记（2026-10-06）：方向以 HANDOFF §4.7 为准：heredoc 向存档件对齐（生成器产出经实测为非法 JSON），非存档件向生成器收敛；见 `.tad/evidence/pm/2026-10-06-epic-p1-gate2-merged-ruling.md`]**

8. driftcheck (r) 形态单列（GM 输入：registry-only 与真缺件 (c) 区分；与 scan-packs 断言口径对齐、不许一面红一面绿）
9. 路由实存＋索引新鲜度断言（A1 变形：激活读单路径全实存＋brain-index 年龄可读、超阈分级判读；只立断言不做复产）
10. B1 负证据纪律（判据补强入证据规程：依赖「未发生」的结论须附正向探针或标注证据强度）
11. D3 根因三段式模板（定因/定界/验证；新增模板＋规程指针）

（件目以 Epic 表 11 行为准，其中第 1 行含 A2 并入、共 12 个点名件。）

## 红线

- 只改本票点名面；仓外禁写；同名文件绝对路径＋Step 0 断言。
- 不动 `.gitignore`、不动 SC3；版本字面量只许权威面。
- 批外发现只登记报 PM；件 3 口径未定案前，本链不做任何 minor 升版动作。
