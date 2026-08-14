# COMPLETION — 把 29 条义务祈使句移到 Read 截断线以内（express）

**Handoff**: `HANDOFF-20260814-obligations-above-cap.md`（rev5）｜**Blake**: 2026-08-18
**T1**: `837d9a3`（Step 0 记录于 `t1-obl.txt`）｜**Evidence**: `.tad/evidence/acceptance-tests/lazy-by-floor/`

## 改动（唯一一件事）

`alex/SKILL.md`（两镜像）L1757-1789（33 行：2 前导空行 + 标题 + 空行 + 29 条祈使句）
**整块移动**到 L197 `ACTIVATION-NOTICE:` 之后 —— 新位置：标题 L200、29 条 L202-230。
逐字移动，一个字未改、未重排、未改缩进。

| 事实 | T1 | 移动后 |
|---|---|---|
| 祈使句起点 | L1761（截断线 981 之外） | **L202**（余量 779 行） |
| 单次 Read 可达 | 否（0/4 回读） | **是（3/3 回读全中）** |
| 字节 | 98,752 | 98,752（恒等） |
| 行集 | — | diff 零 |

## AC 结果（11 条全过）

| AC | 判定 | 实测 |
|---|---|---|
| AC1（承重，rev5 命令） | MAXLINE≤981 且 SPAN==28 且载体=SKILL.md | **MAXLINE=230 MINLINE=202 SPAN=28 exit=0** |
| AC2 | P7 AC1 仍 29/29 | RESULT=PASS |
| AC3 | `git show T1` 行集 diff 零 | 零输出 |
| AC4 | 字节恒等（git show T1 vs 现，两侧） | 98,752 == 98,752 |
| AC5 | P7 verify.sh all | RESULT=PASS |
| AC5.5(a) | 八份冻结基线未动（白名单内仅 3 个漂移文件） | 越界 0 |
| AC5.5(b) | fence-baseline 只多 §6 写死两行、无删除 | 恰好两行 + |
| AC6 | parity `diff -r` | 零输出 |
| AC6.5 | 围栏总数不变 + 标题前围栏偶数 | 10→10；标题前 2（偶数） |
| AC7 | measure T1-obl exit 0 + STATIC 两侧相等 | exit 0；STATIC 250,924 恒等 |
| AC8 | 3 fresh agent × 一次 Read × 禁工具旁路，≥2 次四键全中 | **3/3 全中**（原始作答 3 份 + 判定落盘 `readback-obl/`） |

## Step 0（六步全跑，结果 Alex 确认保留有效）

1. T1=837d9a3 → `t1-obl.txt` ✓
2. measure T1-obl：STATIC 250,924 PASS ✓
3. AC1 T1 必红（rev4 命令实测 MAXLINE=1789 MINLINE=空 SPAN=1789）——**在此停下退回 Alex**：冻结命令 awk 漏 `n` 赋值，移动后 AC1 必红。rev5 修正（`else {if(...)m=...; if(n==0||...<n)n=...}`）后重跑：T1 `MAXLINE=1789 MINLINE=1761 SPAN=28 exit=1`（红因 m>981，方向正确）✓
4. fence-baseline 追加本单两路径（AC5 前置）✓
5. AC8 四键零旁路证明（仅移动前一次）：桶/鉴权/公开/支付 12 常驻文件块外全 0；抗改写四条（删存储桶/移除鉴权/把私有资源转为公开/改支付相关逻辑）块外零命中 ✓
6. verify.sh all → RESULT=PASS ✓

## 过程记录

- **第 5 个 rev 由 Blake 抓到，且是在 Step 0 老老实实跑冻结命令时抓到的**：rev4 的 AC1 awk 只有 `m` 赋值、`n` 恒空 → SPAN 恒=MAXLINE → 正确移动后必然 `SPAN=230≠28` 红。退回后 Alex 出 rev5 修判定器，其余五步结果保留有效。**五次 rev 全是尺子的问题，改动本身一次没出过错。**
- 三个 AC8 agent 的 Read 都报 1-898 行截断（50KB 策略），祈使句块 L202-230 全部落在截断线之上 —— 行为鉴别直接验证了移动的效力（对照：移动前审查员 0/4）。
- 三份作答**全部落盘**（含未通过假设的完整原始文本），无只留通过样本。

## 未做（§3）

未改任何祈使句文字｜未动 P7 配套/基线｜未动 blake/gate/blake-lite/AGENTS.md/config-*/principles.md/CLAUDE.md｜未外置｜未发布、未 push。

## 遗留

1. 本单 commit 与否由用户定（工作树已含移动 + 本报告；handoff 文件仍为 Alex 侧未 commit 状态）。
2. P7 Gate 4 重判与归档（Alex 侧；报告 `.tad/evidence/acceptance-tests/lazy-by-floor/gate4-alex-recompute.md`）。
3. 契约 §7.4 后续单：拆 L201-1615 假 ```yaml 围栏（含 `*product:` 语法，非合法 YAML，最难验证的一块）。
4. §7.6 四笔账（净省打折 25% / P7 AC8 无效 / Q4 定位 / express 口径）随后续单清。
