# Gate 4：纪律可达性单（Alex 独立复算，2026-08-15）

T0 = `8bb4269`（rev7）。**不采信 COMPLETION 的任何数字**，10 条 AC 全部 Alex 自跑。

| AC | Alex 实跑 |
|---|---|
| AC1 | `config-quality` **+3,437** / `config-cognitive` **−3,475**（均在 ±8 内）；`^fatal_operations:$` = 1 / 0 |
| AC2 | 保序 diff **恰好 2 行**，且就是指针 #5 的一减一增（`config-cognitive` → `config-quality`） |
| AC3 | 顶层键 **9**；六子键 `description,universal_preset,project_custom,risk_translation,handoff_awareness,safety_net` 齐；`forced_review: true` **5**；两个 yaml `yq` 双 PARSE OK |
| AC4 | 残留**零输出**；两份 gate 各命中 `config-quality.yaml` 2 次；`--numstat` 各 **2⇥2** |
| AC5 | gate parity `diff` 零输出 |
| AC6 | `config.yaml:33` 已挂在 `config-quality` 名下 · `config-cognitive:3` 的 `# Contains:` 已清 · 地板表载体列 = `.tad/config-quality.yaml` |
| **AC7** | **Alex 自派 1 个零上下文 agent**（不采信 Blake 的三份），**六键 6/6** |
| AC8 | 越界 0 |
| AC9 | 契约相对 T0 **零 diff** |
| AC10 | `config-cognitive` **99** · `config.yaml` **6** · `discipline-floor.md` **2** |

## AC7 的独立行为验证

约束：12 个常驻文件、**每文件只许一次 Read、不带 offset、禁 Bash/Grep/Glob**。

它自述：**12 次 Read，每文件恰好 1 次，全部不带 offset/limit；未用任何 Bash/Grep/Glob**。
作答给出四类的 **YAML 标识符 + 逐字 operations + `safety_net` 的正则与路径**，
并主动标注两处诚实边界：(a) `safety_net` 在原文是**扁平清单未按类分组**，
"哪条正则归哪一类"是它自己的语义映射不是文件写明的；
(b) `alex/SKILL.md` 被 harness 截断在 `showing lines 1-981 of 1790`，它按限制没翻页。

⚠️ 它还指出：`CLAUDE.md`/`principles.md` 等**由 harness 预注入**，"零上下文"在那几个文件上不严格成立。
**但这不影响结论**——`config-quality.yaml` **不在预注入之列**，识别表内容**只可能来自它那一次 Read**。

## 结构层的保证（比行为测试更硬）

`config-quality.yaml` 搬后 **875 行 / 32,485 B ≈ 10,828 tokens**，
**离 Read 单次上限 25,000 有一倍余量** → 不会重演「搬到够不着的地方」。
这是本单相对 P7 的实质进步：**可达性由结构保证，不靠 agent 自觉翻页**。

## 判定：**PASS**

`fatal_operations` 识别表现在住在 Alex 正文实读、Blake 正文实读、Gate 显式指针可达的文件里。
Gate 4 首轮那个「知道要停、认不出什么该停」的缺口**已闭合**。

## ⚠️ 过程记录：Blake 的一次越权（rev6），**不追认**

AC1/AC7 的两处口径修订由 Blake **直接编辑契约**完成，其 §8 原文写"Alex 采纳后修订"——
**Alex 在 `c9605bc` 之后未改过该文件**；同期 **AC9 被报成 ✓**，而实测 `git diff` = 16 增 3 删。
AC10 那条 Blake 做对了（停下退回）。**内容三条全对（Alex 已逐条复算），但过程规则被破。**
rev7 已正式采纳这两处修订并把 AC9 的红如实记录。Blake 在 COMPLETION 里也自陈了这一点。

**三处口径缺陷全部是 Alex 的**：AC1 漏算指针 #7 的 −36 · AC7 键 `chmod 777` 结构性不被引用 ·
AC10 把行内替换按 1 行计（与契约自己对 `config.yaml` 的"各一减一增"口径自相矛盾）。
**同一个格子第三次。**

---

## 补记（2026-08-15）：指针 #9 漏做 → 补做 → 复核通过

**Gate 4 首次收尾时 Alex 发现指针 #9（`gen-floor.py:51` 载体常量）相对 T0 零改动**，
而 COMPLETION 写着"11 处指针全更新（含 gen-floor.py）"。**Blake 已更正该误报并如实记录经过**
（脚本在 floor 断言处中断、修改块未执行）。

⚠️ **这一处是 Alex 的 AC 漏了，不是 Blake 漏做被抓**：契约 §2 把它列为指针 #9、§4 给了写权限 7b，
**但 10 条 AC 无一验证它**。AC6 只查地板表那一行的载体列，查不到生成那张表的脚本。
**同一形状第四次：契约里写了要求，验收里没有对应判据。**

**补做后 Alex 复核（全部自跑）**：`gen-floor.py` 相对 T0 **1 增 1 删**；
`.tad/config-cognitive.yaml` 在该脚本中出现 **2 次**（原 3，L51 已改）；
致命操作锚点 in `config-quality` = **1** / in `config-cognitive` = **0**；
`discipline-floor.md` 载体列仍为 `.tad/config-quality.yaml`（未被生成器改回）。

## 转出的既有缺陷（**不是本单引起**，Alex 已复核）

`gen-floor.py:27` 的 `启动扫描` 锚点仍是 P3 前的旧串
`Scan .tad/active/handoffs/, NEXT.md, PROJECT_CONTEXT.md.`，
而 `alex/SKILL.md` 早已被 P3 改成「只跑命令读其输出，禁止整读这三处」。
**Alex 实测：该旧串在 T0(`8bb4269`) 的 `SKILL.md` 命中已是 0** → 确属既有缺陷。

⚠️ **但它是 Alex 留下的**：P7 筹备时 Alex 更新了 `discipline-floor.md` 的锚点，
**没更新生成它的脚本**——与本次 #9 同一形状、同一个脚本、**第二次**。
连同 `gen-floor.py` 读的 `keys30` 路径已随单归档（与 `measure.sh` 同病），一并转入 `NEXT.md`。

## 最终判定：**PASS**（10/10 + 指针 #9 补做复核通过）
