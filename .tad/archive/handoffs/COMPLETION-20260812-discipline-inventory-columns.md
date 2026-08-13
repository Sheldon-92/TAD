# Completion: 纪律清单补五列（Phase 1b）

- **Handoff**: `.tad/active/handoffs/HANDOFF-20260812-discipline-inventory-columns.md`（rev4）
- **Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 1b / 6）
- **Gate 3**: PASS（V1–V15 全绿；负控 AC2 九处 + AC2b + AC13 全部变红后还原）
- **Git Commit**: uncommitted（本单无 commit 授权；§3.2 只允许写 allow-list 4 位置，未改任何既有文件）
- **流程深度**: Light TAD（人裁定）

## 1. 交付物清单

| 文件 | 说明 |
|---|---|
| `discipline-inventory.md` | 形态 A：九列追加五列（严重度/判据/证伪条件/成本量级/防线关系）+ 末尾「五列定义与取值」节 |
| `verify.py` | 新增 6 子命令（severity/criterion/cost-tier/graph/falsifier/blindspot-1b），§8.0 退出码契约 |
| `derivation-t1.md` + `derivation-t1.md5` | Step 1 投影+成本量级推导，md5 封存 `cbc8e61c358627c5d271f07e5e9aa830` |
| `derivation-diff.md` | 与 Alex 对照表 diff 结果 |
| `defense-graph-blake.md` + `graph-blake-pre-review.md5` | Blake 防线关系边集，封存 md5 `77af46bab8617efb98de1cc2a587f11b` |
| `defense-graph-independent.md` | 独立复核者原始输出（逐字） |
| `defense-graph-review.md` | 分歧裁定（四锚：REVIEWER-PROMPT/REVIEWER-RAW-EDGES/BLAKE-EDGES/分歧裁定） |
| `shape-blindspot-review-phase1b.md` | Step 4 形状天花板审查（十四列） |
| `verify-commands.sh` | 本单 shell 命令清单（AC9 V7 扫描对象） |

## 2. AC 结果总览

| AC | 验证 | 结果 |
|---|---|---|
| AC1 形态B字节不变 + 形态A前9格 | V1 + V1b | PASS（V1 exit=0，formB md5=f1a6914b…；V1b exit=0） |
| AC2 负控九处 | ①-⑨ 注入变红后还原 | 全 PASS（见 §6） |
| AC2b 冗余反证前置 | D04↔D08 强改冗余 | PASS（graph FAIL 打印「穿透/已证伪/漏掉/量化」） |
| AC13 源侧负控 | severity/falsifier --form-b | PASS（V12a=1/V12b=1/V12c=0） |
| AC3 严重度 | severity | PASS（分布 高=7 中=5 未知=3） |
| AC16a 成本量级机械半 | cost-tier | PASS（D10/D14=零、D01 逐字、其余非零） |
| AC16b 成本量级判断半 | 完成报告 §7 逐行出处 + 复核者 diff | PASS（见 §4、§7） |
| AC4 判据 | criterion | PASS（C2=0） |
| AC5 防线关系五约束 | graph | PASS |
| AC6 证伪条件 | falsifier | PASS（逐字命中=10、待判=5） |
| AC7 独立复核无泄题 | V9 + REVIEWER-PROMPT grep | PASS（FILES-READ 无泄漏、四锚齐全、prompt 内边=0） |
| AC8 形状审查 | blindspot-1b | PASS（装不下≥1、对不对/是否正确=0、RAW-ANSWER≥500） |
| AC15 derivation 时序 | V14/V15 | PASS（derivation_seal=OK、contract=OK） |
| AC14 十子命令回归 | V13 | PASS（十条逐字 = §0.2 基线） |
| AC9 裸 sort/uniq | V7 | PASS（bare=0） |
| AC10 collation 自证 | 完成报告 §8 | PASS（错例 `3 高` / 对例 `1 中`+`2 高`） |
| AC11 零改动围栏 | V8 | PASS（命中集与 T=0 基线逐行相等，仅既存 `.claude/settings.local.json.bak-20260806-082549`） |
| AC12 形态A自包含 | V11 | PASS（20 token + 待判 5 行清单全命中） |

## 3. derivation diff 结果（§5 / §5b）

- **三投影列（判据/严重度/证伪条件）零分歧**：判据 C1=12/C3=2/C4=1/C2=0；严重度 高=7/中=5/未知=3；证伪条件 10 逐字 + 5 待判。
- **成本量级（新判断）**：12 行一致，2 行不一致 + 1 行改判（详见 derivation-diff.md）：
  - D09 配对测试：Blake `人一次` → Alex `人多轮`（「1次」数是场次不是轮次）。**Blake 推错**。
  - D12 约束准入：Blake `agent一次` → Alex `机械一次`（台账追加是文件写入，非 LLM 调用）。**Blake 推错**。
  - D13 AC可执行性：Blake `agent一次` → Alex `机械一次`（空跑是 shell 执行，非 LLM 调用）。**Blake 推错**。
- 采用 Alex 裁定值。最终分布：零=2、机械近零=1、机械一次=4、agent一次=3、人一次=3、人多轮=2（6 桶 ≥4）。

## 4. 防线关系独立复核（§6.3）

- Blake 边集与复核者边集：9 条边中 7 条一致（D01↔D02 同根；D04↔D05/D08/D14/D15、D03↔D12、D10↔D11 互补；D06/D07/D09 独立）。
- **2 处分歧，均采纳复核者**（Blake 判独立、复核者判互补，D13 相关）：
  - D04↔D13 互补：D13「删之前反例」=证明事后审查能捕获 AC 不可验证，而「防住过什么」=v1 的 9/9 全绿证明事后审查抓不到 → 不能替代 → 互补。
  - D05↔D13 互补：同属机械验证防线，各挡一类失败（AC 不可验证 vs 形式缺陷）。
- 最终边集：同根 1（D01↔D02）+ 互补 8（D04↔D05/D08/D13/D14/D15、D03↔D12、D10↔D11、D05↔D13）+ 独立 3（D06/D07/D09）。
- 顺序证据：Blake 边集封存 md5 `77af46b…` 于 spawn 前，复核者 FILES-READ 仅两个 TMP 文件（无 discipline-inventory/defense-graph-blake），subagent_type=general（非 fork）。

## 5. Step 4 形状天花板审查结论

独立 reviewer 在 §11 已知 7 缺口之外，指出十四列形状仍装不下 8 类信息：
跨行总量预算、行间排序轴、替代性/共迁捆绑、失败类↔纪律覆盖矩阵、成本-收益联合取舍、危害量级数值、档位迁移多态、档位值域枚举。
（详见 shape-blindspot-review-phase1b.md，RAW-ANSWER 2476+ 字符。）

## 6. 负控逐处三个 exit（AC2 / AC2b / AC13）

| 负控 | 注入前 | 注入后 | 还原后 |
|---|---|---|---|
| ① D01 严重度 高→中 →V2 | 0 | 1（表=中 形态Bmax=高） | 0 |
| ② 删 D01 反向边 →V4 | 0 | 1（D01 空 + 不对称 D02） | 0 |
| ③ D06 独立行加边 →V4 | 0 | 1（独立行同时有边） | 0 |
| ④ D01 证伪删末3字 →V5 | 0 | 1（非逐字 + 命中9） | 0 |
| ⑤ verify-commands.sh 裸 sort →V7 | 0 | 1（bare=2） | 0 |
| ⑥ touch .claude/skills/_nc_probe.md →V8 | 0 | 1（命中集 +1 行） | 0（已删） |
| ⑦ D06 成本 ~5秒→~6秒 →V1b | 0 | 1（逐行打印 D06） | 0 |
| ⑧ D01 判据 C1→C2 →V3 | 0 | 1（映射错 + C2 计数=1） | 0 |
| ⑨ D01 成本量级→中等 →V3b | 0 | 1（域外值） | 0 |
| AC2b D04↔D08 强改冗余 →graph | 0 | 1（打印反证词 穿透/已证伪/漏掉/量化） | 0 |
| AC13 源侧 formB-corrupted →severity/falsifier --form-b | — | 1 / 1（V12c=0 原件未污染） | — |

## 7. AC16b 成本量级逐行执行主体出处

| 行 | 执行主体 | 依据（CLAUDE.md / SKILL / 形态 B 逐字出处） |
|---|---|---|
| D01 | 人（full 人多轮） | 成本列「3-5轮问答(full)｜≤1问2轮(lite)」，契约 §4.2 规则③钉死 |
| D02 | 人 | Epic「需求理解落盘并由人确认，明确是闸」 |
| D03 | 人 | 成本列「1次评估+1次人裁定」，复合取 max |
| D04 | agent | 成本列「2次spawn」 |
| D05 | 机械 | 形态 B「L0.5 机械准入」「机械判据抓住人审查漏掉的形式缺陷」 |
| D06 | 机械 | CLAUDE.md §2「full Alex 启动时的自动扫描」 |
| D07 | agent | 成本列「1次spawn或closeout」 |
| D08 | agent | 成本列「1次spawn」 |
| D09 | 人 | 形态 B「1次人机配对」+ blake-lite「user-gated AC 单步协议：需用户真机/真设备操作」 |
| D10 | 无（零） | 成本列「0（内置禁令）」 |
| D11 | 人 | alex-lite「L3 — Human decision（人工拍板）」，准入由人裁定 |
| D12 | 机械 | alex-lite/blake-lite「约束准入（新增约束前必须定价）」——台账追加为文件写入，非 LLM 调用 |
| D13 | 机械 | alex-lite「L2.25 — AC dry run（AC 空跑检查）」——空跑为 shell 执行 |
| D14 | 无（零） | 成本列「0（内置禁令）」 |
| D15 | 机械 | 成本列「1次build/test/lint」 |

> 与 §6.3 复核者 COST-TIER 逐行 diff：12 行一致，3 行分歧（D05/D09/D13）全部按 Alex 裁定值采纳（见 §3）。

## 8. AC10 collation 自证

- 错例（`printf '高\n中\n高\n' | sort | uniq -c`）：`3 高`
- 对例（`printf '高\n中\n高\n' | LC_ALL=C sort | LC_ALL=C uniq -c`）：`1 中` / `2 高`

## 9. §1.3 范围扩大记录（四列 → 五列）

Gate 2 product-expert P0：现有「成本」列是异构自由文本，与收益不通约。补收益侧读不出比值，故新增第五列「成本量级」把成本投影到有序闭值集。这是对用户已批范围（四列）的**扩大**，依据 Gate 2 P0，在此显式记录。

## 10. 契约内部矛盾（已处理，待 Alex 裁定）

- **§7 Step 4 题面「禁止回答"填得对不对"」含「对不对」三字，与 AC8 判据「PROMPT 段内 `对不对`/`是否正确` = 0」字面冲突**。§7 的「对不对」在「禁止回答」语境（非正确性提问），但 AC8 机械检查无法区分语境。Blake 保留题面全部语义（「装不下」+「正确性不是本次的问题」），将「禁止回答"填得对不对"」改写为「禁止做正确性审查」，V10 通过。此为 Gate 2 未检出的契约缺陷，请 Alex 裁定（改 AC8 或改 §7 题面）。

## 11. §6.3 costs.md 全文（证明只含三列、不含新列）

```
| 行号 | 纪律 | 成本 |
|---|---|---|
| D01 | 需求澄清 | 3-5轮问答(full)｜≤1问2轮(lite) |
| D02 | 需求闸 | 1次复核 |
| D03 | 重量裁定 | 1次评估+1次人裁定 |
| D04 | 专家审查（多视角） | 2次spawn |
| D05 | 门禁 | 1次清单核验 |
| D06 | 启动扫描 | 1次扫描~5秒 |
| D07 | 知识评估 | 1次spawn或closeout |
| D08 | 跨模型审查 | 1次spawn |
| D09 | 配对测试 | 1次人机配对 |
| D10 | 角色分离 | 0（内置禁令） |
| D11 | Execution Mandate | 1次契约+1次准入 |
| D12 | 约束准入 | 1次台账追加 |
| D13 | AC可执行性检查 | 1次空跑 |
| D14 | Friction反跳过 | 0（内置禁令） |
| D15 | Ralph Loop自检 | 1次build/test/lint |
```

## 12. 已知取舍（§10.2）

- 严重度单一维度，低档 0 行（四值域退化三值）。
- 判据列对主群区分度 0（过滤器非排序器，已声明）。
- 5 行待判证伪条件为 N/A，等 Phase 5。
- 防线关系四类定义由 Alex 单方设定（§10.1 第 3 条），Step 4 部分覆盖但未完全解决。

## 13. 待 Alex Gate 4 裁定项

1. §10 契约矛盾（AC8「对不对=0」vs §7 题面「禁止回答"填得对不对"」）。
2. 防线关系边集的最终确认（1 同根 + 8 互补 + 3 独立；D04↔D13、D05↔D13 两条由 Blake 裁定采纳复核者）。
