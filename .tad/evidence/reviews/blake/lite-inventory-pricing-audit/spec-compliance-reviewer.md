# Spec Compliance Review — HANDOFF-20260805-lite-inventory-pricing-audit.md (v4)

**model**: deepseek-v4-flash（自报模型 ID；harness = Claude Code CLI，Bash tool 实际 shell = zsh 5.9）
**role**: TAD Layer 2 Group 0 blocking reviewer (spec-compliance-reviewer)
**date**: 2026-08-05 | **HEAD**: 910ab6cd4ea1765cbd4f64b69f4e015a5eac3dbc
**method**: 逐字实跑 handoff §4 三条 AC（zsh 直接执行，未包 bash -c）+ 额外核验。全部判定为执行实证。

---

## 逐条 AC 结果

### AC1 — 四份文件「约束准入」节逐字节等于目标 — **PASS**

实跑输出（verbatim）：

```
OK   .claude/skills/alex-lite/SKILL.md  (70 行, md5 一致)
OK   .claude/skills/blake-lite/SKILL.md  (70 行, md5 一致)
OK   .agents/skills/alex-lite/SKILL.md  (70 行, md5 一致)
OK   .agents/skills/blake-lite/SKILL.md  (70 行, md5 一致)
OK   .tad/evidence/audits/lite-constraint-ledger.md  (10 行, 0 数据行, md5 一致)
AC1 PASS
```

四节 md5 均 = `47fd564853125c418195b5713c57b1e6`（70 行/节）；台账整文件 md5 = `a81fde7d53829dc1b91b987fd4a6add9`、10 行、0 数据行。与 Expected Evidence 完全一致。

### AC2 — 改动形状：4 文件各恰 1 增 1 删 — **PASS**

实跑输出（verbatim）：

```
1	1	.agents/skills/alex-lite/SKILL.md
1	1	.agents/skills/blake-lite/SKILL.md
1	1	.claude/skills/alex-lite/SKILL.md
1	1	.claude/skills/blake-lite/SKILL.md
2	1	.tad/evidence/audits/lite-constraint-ledger.md
AC2 PASS
```

4 个 skill 文件均 1 增 1 删；台账 2 增 1 删。节外零改动（numstat 对每文件限死全文件净变化）。

### AC3 — 改动围栏（HEAD 锚，无快照） — **PASS**（含一条已裁定契约常量漂移，见下）

实跑 verbatim 结果：`(a)` HEAD 未移动（`910ab6cd…` 一致）、`(b)` `git ls-files -v` 全 `H `（无 assume-unchanged/skip-worktree）、`(c)` `git diff --name-only HEAD` 输出恰为允许清单 17 个文件（12 起草时 dirty + 5 本单授权），`grep -vxF -f` 后零残留——均无输出即通过。

**(d) 偏离记录（用户已裁定，非缺陷）**：verbatim 跑 (d1) 时 `md5 -q .tad/active/epics/EPIC-20260804-lite-as-tad-body.md` = `67c977e5b5c7469cf1e195612fb3afc1` ≠ 契约常量 `1acdc51e…`，脚本报 `AC3 FAIL Epic 文件被改`。经用户裁定：该 md5 常量在 handoff 定稿后被 Alex 侧更新，契约常量过期，非实现方改动；验证锚 = 当前实际 md5 `67c977e5b5c7469cf1e195612fb3afc1`。以裁定锚复跑：`(d1) Epic md5 == 67c977e5b5c7469cf1e195612fb3afc1 → OK`；`(d2) P1b-deep-verdicts.md md5 == 9da84175c709586056ac20da26aae79f（契约常量）→ OK`。Epic 文件头部内容健全（标题/owner/status/Objective 正常）。**AC3 总判定 PASS**；契约常量过期这一项建议 Gate 4 知悉并在归档时更新 handoff 常量。

---

## 额外核验（全部执行实证）

| # | 核验项 | 结果 |
|---|---|---|
| E1 | 4 文件新正则行逐字节 = §3.1 目标行（含 4 空格缩进），每文件恰 1 处 | PASS（`grep -Fxf` + `diff -q` 逐字节：4/4 文件 byte-identical，各 1 处） |
| E2 | 旧正则行在 4 文件中已不存在 | PASS（4/4 文件 0 处） |
| E3 | 全仓旧正则活副本范围复核 | PASS（`grep -rlF` 全仓：仅冻结文档——本 handoff 自身文本、`.tad/archive/handoffs/` 归档、`.tad/evidence/acceptance-tests/pricing-gate-scan-fix/` 与 `lite-inventory-pricing-audit/apply-changes.py` 证据产物；无第 5 处活扫描器） |
| E4 | 不变量 1：`substr($0, RSTART+23, 10)` +23 偏移 | PASS（4/4 文件 `grep -Fc 'RSTART+23'` = 1；实际行 373 逐字节含 `substr($0, RSTART+23, 10)`）。注：初查用 BRE `grep -c 'substr($0, …)'` 返回 0 系 BSD grep 把中缀 `$` 当行尾锚所致，`grep -F` 确认字节在位；AC1 整节 md5 为权威保证（§3.1.1 声明） |
| E5 | 不变量 2：前置过滤行（大小写不敏感 + 全/半角冒号） | PASS（4/4 文件 `grep -Fc '/[Pp]…[Ll][:：]?/'` = 1；实际行 371） |
| E6 | 不变量 3：`else` MALFORMED 分支 | PASS（4/4 文件 `grep -Fc 'MALFORMED(须人工处置)'` = 1；实际行 374） |
| E7 | 台账前言替换为 §3.0 目标两行（逐字节） | PASS（两目标行 `grep -Fxc` 各 = 1；旧行「存量 34 节…」= 0；`cat -e` 全文 10 行） |
| E8 | 台账 0 数据行、表头未动 | PASS（日期锚定第 2 列计数 = 0；表头/分隔行原样；整文件 md5 由 AC1 钉死） |
| E9 | .claude ↔ .agents 镜像 parity | PASS（`cmp -s` 两对均 IDENTICAL；官方 `release-verify.sh parity` → `VERDICT: parity PASS (exit 0)`） |
| E10 | git diff 内容形态 | PASS（alex-lite diff 仅 1 行 `-`旧正则/`+`新正则，行 371/373/374 不变量行未动；台账 diff 仅 `-`旧前言/`+`两新行，表头未动） |

---

## 附：审查过程中的环境事实（供后续 reviewer 参考）

- 本机 zsh 5.9；AC 脚本直接跑（未包 `bash -c`），§5 陷阱逐一规避（字面量词表、`mktemp`、`LC_ALL=C`、无数组）。
- BSD grep BRE 中 `$0` 的中缀 `$` 被当作行尾锚导致 `grep -c` 失配——含 `$` 的锚点检查一律用 `grep -F`。
- BSD `cat -A` 不存在，用 `cat -e`。
- 手写 heredoc 期望行（UTF-8 含全角标点）经 Bash tool 传输后字节完好（grep -Fxc 精确命中验证）。

## verdict: PASS

三条 AC 全部满足（AC3 (d) 按用户裁定的现行锚判定；契约 md5 常量过期属文档漂移，不构成实现缺陷）；5 个授权文件整体逐字节受控；无越权改动；parity 完好。无 FAIL 项阻塞。
