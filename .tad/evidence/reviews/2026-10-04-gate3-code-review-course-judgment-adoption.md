# Gate 3 CODE 路评审 — 课程判断落地链（TASK-20261004-COURSE-JUDGMENT-ADOPTION）

- 评审者：独立会话 Gate 3 CODE 路评审者（与实施 Blake 不同会话、不同样本）
- 日期：2026-10-04
- 对象：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（v1.1，增补后口径）§9.1 AC1–AC16
- 方法：AC 逐条**原样实跑**（不引用实施者自验表作判据）；写集五件增补条文与 §4 草案代码块逐字比对；dogfood 卡独立复核。git 只读，全程未写仓内他件。

## 结论：**PASS**

P0=0／P1=0／P2=2（均为方法注记，不阻塞）。AC1–AC14、AC16 独立重跑全过且与实施自报逐值全等（无自报不符）；AC13 与 AC15 合取成立（见 dogfood 节）。

## AC 逐条结果（独立重跑值）

| AC | 期望 | 重跑值 | 结果 |
|---|---|---|---|
| AC1 模板三节在册 | ≥1 且 ≥3 | 2 / 3 | PASS |
| AC2 不采部件负控（新词表，末项「MCP 审查节」） | 0 | 0 | PASS |
| AC3 Canonical 风险卡项 | 1 | 1 | PASS |
| AC4 Alex C1 义务行＋位置 | 恰 1 行且 ≤120 | 行号 94 | PASS |
| AC5 Gate 3 E 维子款＋证据否决 | ≥1 且 ≥1 | 1 / 1 | PASS |
| AC6 Gate 4 自报不符句 | 1 | 1 | PASS |
| AC7 Alex C2 义务行＋位置 | 恰 1 行且 ≤120 | 行号 95 | PASS |
| AC8 权威顺序四顺位升序 | ORDER_OK | ORDER_OK | PASS |
| AC9 AGENTS.md 行数上限 | ≤188 | 184 | PASS |
| AC10 卷首装载纪律句 | ≥1 | 1 | PASS |
| AC11 Gate 2 装载点位常查项 | 1 | 1 | PASS |
| AC12 Gate 3 位置断言子款 | 1 | 1 | PASS |
| AC13 dogfood 卡在册＋「假设」计数 | exit 0 且 ≥3，须与 AC15 合取 | 在册，9 | PASS（合取见下） |
| AC14 纯增补（两段） | 0 ／ 0 | 0 ／ 0 | PASS |
| AC15 dogfood 可证伪性（独立判读） | PASS | PASS | PASS |
| AC16 gate skill 双在册 | ≥1 且 ≥1 | 1 / 1 | PASS |

AC14 证据方法复核（非空转）：写集四件 tracked MODIFY 的 `git diff --stat` 实测非空（alex +2／gate +6−1／Canonical +11／AGENTS.md +16，共 34 增 1 删）；逐行枚举全部删除行——唯一删除行＝gate skill 的 `-Critical Check (6 items):`，即 AC14 点名例外，替换行 `+Critical Check (8 items):` 在册。其余四件删除行枚举为 0，「只增不删」由枚举坐实、非计数凑数。

## 条文逐字性（与 §4 草案代码块全文比对，抽 5 处）

1. **模板全文**（`.tad/templates/dispatch-risk-card.md`）与 §4.2 (a) 草案：逐行比对全等（含触发集定串、表头、证伪表说明段）。
2. **C3 短文**（AGENTS.md）与 §4.4 草案：15 行全等；落点在「Memory authority」之后、「Interaction decisions」之前，合 §4.4 ③ 锚点。
3. **Canonical 六处增补**（C4 (a) 卷首句、C1 (b) 风险卡项、C4 (b) 装载项、C2 (a) E 维子款 4 行、C4 (c) 位置断言子款、C2 (b) Gate 4 句）与 §4.2/4.3/4.5 草案：全等（增补行数 11 与 diff 实测一致）；`Why CE` 行未动（CF-2 裁定守住）。
4. **Alex 义务块两行**（C1 (c)、C2 (c)，L94/L95）与 §4.2 (c)/§4.3 (c) 草案：全等；两行在义务块内、≤120 行号上限内。
5. **gate skill inline 副本**与 Canonical 对应条文：归一化（去结构缩进）diff 为空，文字逐字一致；计数行 6→8 改准。inline 副本带该文件固有的 2 空格列表缩进，属嵌入格式、非措辞漂移。

触发集定串四处（模板头、Canonical 项、Alex 义务行、FR1）同串复核：均含「L3 动作（含删除、密钥、公网、生产）／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作，以及 PM 判断为高风险者」，全等。

## dogfood 演练卡独立复核（AC13∧AC15 与如实声明）

对象 `.tad/evidence/risk-cards/risk-TASK-20261004-COURSE-JUDGMENT-ADOPTION.md`：

- **如实声明成立**：触发项栏明写「未命中（本卡为新模板的演练件 dogfood）」，无「同类」比附勾注（B6 口径守住）。
- **触发集逐项核对成立**：卡内对触发集 7 个要素（L3 动作／跨仓或跨席位写／引入新连接器、MCP 或依赖／不可逆动作／涉及金额／对外动作／PM 判断兜底）逐项给出未命中结论与事实依据（本仓内纯文本增补、零 git 写、可完全回滚、无金额无外发）；与本链盘面实况（写集全在仓内、diff 为纯文本增补）逐项相符，无虚报。
- **AC15 可证伪性判读 PASS**：3 条 ASM 逐条核——
  - ASM1（删除行数 = 0／gate skill 恰计数行一处）：可证伪陈述句；证伪信号＝AC14 任一输出非 0，可观察；动作列「停步报 PM」非空。且经本路重跑实测为真。
  - ASM2（两义务行行号 94／95 ≤120）：可证伪；信号＝AC4/AC7 行号越界或命中数 ≠1，可观察；动作非空。重跑实测为真。
  - ASM3（落盘条文与 §4 草案逐字一致）：可证伪；信号＝任一比对 False 或 grep 计数不符，可观察；动作非空。本路逐字比对实测为真。
  - §1 三条 REQ（利害关系人／最坏损失具体事件／对应需求）齐备，非空话。

## 自报核查（C2 新条文的本链首例适用）

Blake 在 HANDOFF §9.1 Verified Output 与 COMPLETION「测试证据」节的全部自报值（AC1 2/3、AC2 0、AC3 1、AC4 94、AC5 1/1、AC6 1、AC7 95、AC8 ORDER_OK、AC9 184、AC10–AC12 各 1、AC13 9、AC14 0/0、AC16 1/1）与本路独立重跑逐值全等，**无自报不符行**，证据否决不触发。COMPLETION 的 gate3_verdict 标记位留空未自填，合规程。

## P2 注记（不阻塞，供 Gate 4 与后续链参考）

- **P2-1 AC14 方法盲区**：AC14 第一段命令含 `.tad/active/session-state.md`，但该文件被 `.gitignore:35` 忽略，`git diff` 对其增删均不可见——该文件「纯增补」无法由此方法证明（本路以直接读盘核对：索引行在 L11、内容完整）。后续链涉 gitignored 文件的纯增补断言宜换方法（如基线 sha 登记）。
- **P2-2 计数行字面**：gate skill 计数行替换后为「Critical Check (8 items)」，与 Canonical Gate 2 现行 8 项一致（复核实数：原 6＋C1＋C4 两项）；无问题，仅留痕。

## 边界声明

本路只判 CODE 面（AC 实跑、逐字性、dogfood 判读）；不采项全仓 diff 复核与条文越权面归 SAFETY 路；本结论不替代 Gate 4。

---
自报行（本行追加前实算）：verdict 正文 6,490 B／sha256 `fa9f979727f20205d868de494721837dc371e356019505ddeed8d6e1a981edc4`；reviewed_at 2026-10-04（Gate 3 CODE 路）。
