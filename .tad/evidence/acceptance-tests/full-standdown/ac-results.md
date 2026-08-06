# AC Results — LITE-20260806-1200-full-standdown (Epic P6)

**Date**: 2026-08-06
**Executor**: Blake-Lite | harness=claude-code | model=deepseek-v4-flash
**Verdict**: AC7/AC8/AC1–AC6 全部 PASS（8 条 AC）

---

## AC7 — 成品全文 md5（PASS，最强判据）
```
md5:   3f3e7e393674bbc08430d31c4be10042 (期望 3f3e7e393674bbc08430d31c4be10042) ✓
行数:  123 (期望 123) ✓
bytes: 6877 (期望 6877) ✓
chars: 4486 (期望 4486) ✓
```

## AC8 — change-shape 三断言（PASS）
```
git diff HEAD --numstat -- CLAUDE.md  → 17	4	CLAUDE.md（逐字制表符分隔）✓
git diff HEAD -U0 -- CLAUDE.md | grep -c '^@@'  → 4 ✓（-U0 必需：默认 -U3 因 context 连锁只得 2）
wc -l < CLAUDE.md  → 123 ✓
```

## AC1 — 四个旧串全行精确（PASS，各期望 0）
```
grep -Fxc '> 路由层：…/tad-maintain。'  → 0 ✓
grep -Fxc '读取 `.tad/active/handoffs/` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。' → 0 ✓
grep -Fxc '## 2. 使用场景'  → 0 ✓（必须 -x：新标题包含旧串为前缀，-F 子串匹配下改后仍得 1）
grep -Fxc '| 苏格拉底、专家审查、Epic、配对测试 | `/alex` |'  → 0 ✓
（改前基线实测各为 1）
```

## AC2 — 四个新串首行全行精确（PASS，各期望 1）
```
grep -Fxc '> 路由层：…full（`/alex`, `/blake`, `/gate`）'  → 1 ✓
grep -Fxc '⚠️ 本节只管 full 的 `HANDOFF-*.md`。…'  → 1 ✓
grep -Fxc '## 2. 使用场景（full —— 保留通道）'  → 1 ✓
grep -Fxc '| **lite 全流程（默认通道）** | **`/alex-lite`, `/blake-lite`** |'  → 1 ✓
（改前基线实测各为 0）
```

## AC3 — §7 之后一字节不动（PASS）
```
§7 起始行 = 103；sed -n "103,$p" CLAUDE.md | md5 -q → ccf18298b96e2b6348c1346d39bff38e ✓（21 行）
（改前实测同值；@import 链与 §7.5 不受影响）
```

## AC4 — 章节结构不变（PASS）
```
grep -c '^## ' CLAUDE.md → 9 ✓（v1 凭记忆写 11，L2.25 空跑实测更正为 9）
grep -c '^### ' CLAUDE.md → 1 ✓
```

## AC5 — 未改内容存活 9 条诊断锚（PASS，各 ≥1）
```
9 条锚全部命中 1（§1 禁止条款 / §2 命令表 / §2.5 标题 / §2.5 方向互斥 / 规则 0 / 规则 0-5 /
Terminal 隔离 / Layer 0 机械快照 / §6 文档维护行）——含 v2 补的 4 条正文锚（堵 §1、§2 表、§2.5 正文、§4.5）
★ 前缀残留: 0 ✓（v2 初版在 block 内加 ★ 导致 4 条新锚 grep 全 0，已删前缀）
```

## AC6 — 零越权（PASS）
```
HEAD: 3f4732c（期望 3f4732c）✓
相对附录 A 基线（23 行，实跑 LC_ALL=C sort）的新增项（comm -13）：恰好 1 项
  M CLAUDE.md  ← 精确命中白名单 ✓
黑名单（.claude/skills/、.agents/、hooks、settings.json、agents/、config、.gitignore、
sync-registry、logs、README/INSTALLATION_GUIDE/tad.sh/ROADMAP/CHANGELOG、
.tad/project-knowledge/）：零命中（退出码 1）✓
本单执行期间零 git 写操作（无 add/commit/push/checkout/stash）✓
⚠️ 时点性注记（L3 P2-3 采纳）：「恰好 1 项」为 AC6 快照时点的输出（traces 时间戳实证）；
此后 trace/evidence 自增项（traces/2026-08-06.jsonl、full-standdown/ 目录）均在白名单内，
replay 复核时应按「增量集 3 项全白名单」判读而非「恰好 1 项」。
```

## 实现方式
四处 Edit 精确替换（old→new 逐字，§「四处改动」）：
1. 第 3 行路由层说明（1→2 行）
2. 第 7 行 Handoff 读取规则（1→2 行）
3. 第 12 行 `## 2. 使用场景` 标题（1→11 行，full 保留通道说明）
4. 第 85 行协议位置表（1→2 行，lite 默认行 + alex 保留通道行）

## L0.5 机械计数
已审 AC 条数声明 8 == 机械计数 8（awk `/^## AC/,/^## Contract Review/` + grep -cE '^- ?AC[0-9]'）
