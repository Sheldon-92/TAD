# 完工说明 — C-T2 勘误：§9.1 AC5／AC6／AC11 改逐项断言

- step_id：`tad-evidence-revival-ct2-01`
- 角色：Alex（Solution Lead，设计方勘误）
- 日期：2026-10-04
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md` §9.1 的 AC5（567 行）、AC6（568 行）、AC11（573 行）
- 依据：Gate 2 tech verdict 条件 C-T2（P1-2）——「Gate 4 执行前，AC5／AC6／AC11 改为逐项断言（每个锚词单独计数 ≥1，不许合并 grep -cE 一把计总数）。关闭标准：修订后命令对本 verdict 所附三条反例（仅估计×4／仅案一×3／KAGGLE 行）不再误 PASS。」

## 读取清单打勾回执

- [x] 1. tech verdict 的 C-T2 条件全文（头部 conditions 第 2 条）与正文 P1-2 反例构造节（判据 3，含 P1-2a／P1-2b／P1-2c 三条亲跑反例）——已读。
- [x] 2. HANDOFF §9.1 全表 AC1–AC12（556–574 行）行号与形态——已读；本次只动 AC5／AC6／AC11 三行，表格行数不变。
- [x] 3. 真实产物两件：S1 summary（`.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`，14,450 B）与 S2 Brief（同目录 `decision-brief.md`，18,774 B）——已核读结构与锚词在位。

## 改前／改后全文对照

### AC5（567 行）

改前：

| AC5 | summary 方法与口径齐备（复跑命令、as_of、sha 样本、估计对照在位） | post-impl-verifiable | `grep -cE 'as_of\|复跑\|hash-object\|估计' /home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md` | 计数 ≥4（四类锚词各至少命中一行） | (post-impl)；基线：文件不存在，grep exit 2（正确理由失败） |

改后：

| AC5 | summary 方法与口径齐备（复跑命令、as_of、sha 样本、估计对照在位） | post-impl-verifiable | `grep -c 'as_of' <summary> && grep -c '复跑' <summary> && grep -c 'hash-object' <summary> && grep -c '估计' <summary>`，其中 `<summary>`＝`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md` | 四计数依次均 ≥1（as_of／复跑／hash-object／估计逐项断言、合取判定；任一锚词零命中时对应 grep 以 exit 1 中断整条命令、整体判 FAIL；不许以合并计数替代） | (post-impl)；基线：文件不存在，grep exit 2（正确理由失败）；**勘误后（C-T2，2026-10-04）**：合并计数改逐项断言，见完工说明 `2026-10-04-tad-evidence-revival-ct2-note.md` |

### AC6（568 行）

改前：

| AC6 | Brief 三案同维度＋SOURCES＋推荐齐 | post-impl-verifiable | `grep -cE '案一\|案二\|案三' <brief> && grep -c '^## SOURCES' <brief> && grep -c '推荐' <brief>`，其中 `<brief>`＝`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` | 三计数依次 ≥3、＝1、≥1 | (post-impl)；基线：文件不存在（正确理由失败） |

改后：

| AC6 | Brief 三案同维度＋SOURCES＋推荐齐 | post-impl-verifiable | `grep -c '案一' <brief> && grep -c '案二' <brief> && grep -c '案三' <brief> && grep -c '^## SOURCES' <brief> && grep -c '推荐' <brief>`，其中 `<brief>`＝`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` | 五计数依次 ≥1、≥1、≥1、＝1、≥1（案一／案二／案三逐项断言、合取判定；任一案零命中时对应 grep 以 exit 1 中断整条命令、整体判 FAIL；不许以合并计数替代） | (post-impl)；基线：文件不存在（正确理由失败）；**勘误后（C-T2，2026-10-04）**：三案合并计数改逐项断言，见完工说明 `2026-10-04-tad-evidence-revival-ct2-note.md` |

### AC11（573 行）

改前：

| AC11 | COMPLETION 强制节齐 | post-impl-verifiable | `grep -ciE 'knowledge assessment\|## KA\|KA' <completion> && grep -ci 'friction' <completion> && grep -ci 'evidence checklist' <completion> && grep -ci 'provenance' <completion>`，`<completion>`＝`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md` | 四计数均 ≥1 | (post-impl)；基线：文件不存在（正确理由失败） |

改后：

| AC11 | COMPLETION 强制节齐 | post-impl-verifiable | `grep -ciE 'knowledge assessment\|^## KA' <completion> && grep -ci 'friction' <completion> && grep -ci 'evidence checklist' <completion> && grep -ci 'provenance' <completion>`，`<completion>`＝`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md` | 四计数均 ≥1（合取判定；第一项 KA 为锚定断言——只计 `knowledge assessment` 字面或行首 `## KA` 标题行，裸串 `KA` 不计，如 `KAGGLE` 判 0；任一项零命中时对应 grep 以 exit 1 中断、整体判 FAIL） | (post-impl)；基线：文件不存在（正确理由失败）；**勘误后（C-T2，2026-10-04）**：KA 裸串改锚定断言，见完工说明 `2026-10-04-tad-evidence-revival-ct2-note.md` |

改动列：仅 Verification 列与 Expected 列；三行的 AC 描述、Verification Type 不变；基线注记原文全保留，仅在末尾追加「勘误后（C-T2…）」标记。

## 自证实跑（命令与原始输出）

临时文件均在 `/tmp`，未入仓。判定规则：新命令链 exit 0 且各计数满足逐项阈值＝PASS；任一 grep 计数 0 触发 exit 1 中断＝FAIL。

### 反例 1（C-T2 指定）：仅「估计」×4 对 AC5 → 必须 FAIL

```bash
printf '估计\n估计\n估计\n估计\n' > /tmp/ct2-ce1.txt
grep -c 'as_of' /tmp/ct2-ce1.txt && grep -c '复跑' /tmp/ct2-ce1.txt && grep -c 'hash-object' /tmp/ct2-ce1.txt && grep -c '估计' /tmp/ct2-ce1.txt
```

输出：

```text
0
chain_exit=1
```

判定：**FAIL**（首个 grep 计数 0、exit 1 中断）。旧合并断言对此文件计数 4，会误 PASS——已堵。✔

### 反例 1b（P1-2a 附带误 FAIL 场景）：四锚同行对 AC5 → 应 PASS

```bash
printf 'as_of 复跑 hash-object 估计\n' > /tmp/ct2-ce1b.txt
grep -c 'as_of' /tmp/ct2-ce1b.txt && grep -c '复跑' /tmp/ct2-ce1b.txt && grep -c 'hash-object' /tmp/ct2-ce1b.txt && grep -c '估计' /tmp/ct2-ce1b.txt
```

输出：

```text
1
1
1
1
chain_exit=0
```

判定：**PASS**。旧合并断言对此文件计数 1＜4 会误 FAIL——逐项断言一并修掉。✔

### 反例 2（C-T2 指定）：仅「案一」×3、无 SOURCES 对 AC6 → 必须 FAIL

```bash
printf '案一\n案一\n案一\n' > /tmp/ct2-ce2.txt
grep -c '案一' /tmp/ct2-ce2.txt && grep -c '案二' /tmp/ct2-ce2.txt && grep -c '案三' /tmp/ct2-ce2.txt && grep -c '^## SOURCES' /tmp/ct2-ce2.txt && grep -c '推荐' /tmp/ct2-ce2.txt
```

输出：

```text
3
0
chain_exit=1
```

判定：**FAIL**（案二计数 0 中断）。旧合并断言计数 3 会误 PASS——已堵。✔

### 反例 3（C-T2 指定）：一行 `KAGGLE` 对 AC11 的 KA 断言 → 必须 FAIL

```bash
printf 'KAGGLE benchmark note\n' > /tmp/ct2-ce3.txt
grep -ciE 'knowledge assessment|^## KA' /tmp/ct2-ce3.txt
```

输出：

```text
0
grep_exit=1
```

判定：**FAIL**（锚定断言计数 0）。旧裸串 `KA` 对此行计数 1 会误 PASS——已堵。✔

### 合成正例：`## KA` 标题行对 AC11 的 KA 断言 → 应命中

```bash
printf '## KA\n正文\n' > /tmp/ct2-pos3.txt
grep -ciE 'knowledge assessment|^## KA' /tmp/ct2-pos3.txt
```

输出：

```text
1
grep_exit=0
```

判定：**命中 1 ≥1**，锚定形态可用。✔（AC11 的目标 COMPLETION 尚不存在，其余三项计数待 S4 产物落盘后按断言执行。）

### 正例 1：新 AC5 对真实 S1 summary → PASS

```bash
S=/home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md
grep -c 'as_of' $S && grep -c '复跑' $S && grep -c 'hash-object' $S && grep -c '估计' $S
```

输出：

```text
4
4
5
3
chain_exit=0
```

判定：**PASS**（四锚逐项 4／4／5／3，均 ≥1）。✔

### 正例 2：新 AC6 对真实 S2 Brief → PASS

```bash
B=/home/hatch/workspace/yun-sync/TAD/.tad/evidence/research/maintainer-evidence-revival/decision-brief.md
grep -c '案一' $B && grep -c '案二' $B && grep -c '案三' $B && grep -c '^## SOURCES' $B && grep -c '推荐' $B
```

输出：

```text
14
15
10
1
6
chain_exit=0
```

判定：**PASS**（五计数 14／15／10／1／6，依次满足 ≥1／≥1／≥1／＝1／≥1）。✔

## 范围核验

- `diff`（改前快照 `/tmp/handoff-before-ct2.md` vs 改后）：变更行恰 6 行（旧 3＋新 3），行首分别为 `| AC5`、`| AC6`、`| AC11`——diff 只触三行，其余章节与 AC 行一字未动。
- git 只读，未提交；除 HANDOFF 三行与本完工说明外未写任何文件（临时文件仅 `/tmp`）。
- HANDOFF 字节数：改前 53,396 B → **改后 54,505 B**（+1,109 B）。

## 结论

C-T2 关闭标准全达：三条指定反例修订后命令均不再误 PASS（另附同行误 FAIL 场景亦已修复并实跑为证），两件真实产物正例 PASS。本席判断 **C-T2 可关闭**，待 PM 验盘复跑核对。
