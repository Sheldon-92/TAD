# AC Results — LITE-20260807-1050-tadsh-version-authority

**Date**: 2026-08-07
**Executor**: Blake-Lite | harness=claude-code | model=deepseek-v4-flash
**Verdict**: AC1–AC12 全部 PASS（11 条执行；AC4 已退役不执行；repair_round=0）

---

## AC1 — 探测调用早于状态闸、且落在 main() 之后（PASS）

```
MN=1401  P=1440  S=1441
AC1-PASS
```
`MN < P < S`：调用行 `    probe_remote_version`（L1440）在 `main() {`（L1401）之后、`STATE=$(detect_state)`（L1441）之前。
改前基线：`grep -c '^    probe_remote_version'` = 0 → FAIL（有区分度 ✓）。

## AC2 — 根因修复块位置（PASS）

```
D=1578  R=1581  X=1592  N=2
AC2-PASS
```
`derive_target_version "$TAD_SRC"`（1578）< `# ROOT FIX`（1581）< `# Execute based on action`（1592）；
`case $ACTION in` 仍恰两处（展示块 + 执行分派），不变量未破坏。改前 `R` 为空 → FAIL ✓。

## AC3 — 探测函数行为（PASS，三载荷全过）

```
AC3a-PASS   正常载荷 2.99.0 → 覆盖 TARGET_VERSION 并置 PROBE_OK=1
AC3b-PASS   网络失败 (curl 返 7) → 两者均不动
AC3c-PASS   404 HTML 载荷 → 被正则 ^[0-9]+\.[0-9]+\.[0-9]+$ 挡下（不采信）
```
shim 抽取自 `^probe_remote_version() {` 至 `^}`，桩 curl 覆盖真命令，零网络请求。

## AC5 — 既有路由测试不回归（PASS）

```
bash .tad/hooks/lib/detect-state-test.sh | tail -2
TALLY: PASS=12 FAIL=0（退出码 0）
```
`detect_state` 形状与两处 sed 抽取锚点未破坏。

## AC6 — 误导性注释清零 + 正向锚点（PASS）

```
N6=0  （can never go stale 清零：L19/L1548 两处均改写）
M6=2  （state gate 正向锚点 ≥1，注释被改写而非删除）
AC6a-PASS  AC6b-PASS
```
改前基线 N=2 / M=0 —— 双向有区分度 ✓。

## AC7 — 字面量与发布闸锚点存活（PASS）

```
L=1  （^TARGET_VERSION="2.40.0"$ 仍在，版本号未变——本单不发版）
AC7-PASS
```
release-verify.sh 的 `MUST_VERSION_PATTERNS` 锚点保住。

## AC8 — 语法与改动形状（PASS）

```
bash -n tad.sh → 退出码 0（AC8a-PASS）
git diff --numstat -- tad.sh → 43	3	tad.sh
```
numstat 按结果文件计（43 插入 / 3 删除——M6 三分支 + M3 函数 + M7 块 + 注释；新旧公共行匹配成 context，与「替换了几行」的直觉不同）。Alex 复核以再跑同一命令为准，不与预估比对。

## AC9 — 工作区未越界（PASS，当场快照 + comm 集合差）

```
before 快照 23 行（动文件前实跑，sort -c OK）
after 快照  24 行（sort -c OK）
comm -13 →  M tad.sh     ← 唯一新增项 ✓
comm -23 →  （空）        ← 无条目消失 ✓
AC9-PASS
```
未用任何硬编码计数；23 项历史脏项被集合差自动扣除。判据按「只有一行且指向 tad.sh」（` M` 前缀标记不参与比对——staged/unstaged 字节不同）。

## AC10 — --force 不降级保护存活 + 探测失败分支生效（PASS，bash harness）

```
A: WARN:Installed v2.41.0 is NEWER than target v2.40.0. --force does not downgrade.
B: ACTION=upgrade
C: ✅ Nothing to do. TAD v2.40.0 is already installed.
D: WARN:Installed v2.42.0 is NEWER than target v2.41.0. --force does not downgrade.
```
- **AC10a（P0-2 守卫，回归）**：A 含 `does not downgrade` 且不含 `ACTION=upgrade` → PASS（改前已 PASS，钉住没弄坏）
- **AC10b（区分性）**：B 含 `ACTION=upgrade` → PASS（改前为 Nothing to do → FAIL，改后 PASS）
- **AC10c（快速退出存活，回归）**：C 含 `Nothing to do` → PASS
- **AC10d（回归数据点）**：D 含 `does not downgrade` → PASS（与 A 同路径换数值；不声称验证探测值来源）

## AC11 — PROBE_OK 读取位置不变量（PASS）

```
TOTAL=1  INSIDE=1
AC11-PASS
```
全文件唯一一处 `[ "$PROBE_OK"` 读取落在 `ACTION == "none"` 块内——「逻辑全部在被抽取块内」假设由结构不变量钉住（防 P0-4 变体 B）。

## AC12 — M7 根因修复行为性验证（PASS，bash harness）

```
eq_noforce   : ✅ Nothing to do. TAD v2.40.0 is already installed.   （相等 → 无事可做）
newer_noforce: ✅ Nothing to do. TAD v2.40.0 is already installed.   （已装更新 → 不降级退出）
older_noforce: PROCEEDED                                            （已装更旧 → 继续升级）
eq_force     : PROCEEDED                                            （FORCE=1 → 跳过本块）
fresh_none   : PROCEEDED                                            （无本地版本 → 跳过本块）
```
三向判据全中：`eq_noforce`/`newer_noforce` 含 `Nothing to do`；`older_noforce`/`eq_force`/`fresh_none` 含 `PROCEEDED` 且不含 `Nothing to do`。`TAD_SRC` 指向不存在路径使 `rm -rf` 为无害 no-op。

---

## 实现方式

8 处 Edit 精确替换（M1-M8，逐字规格）：
- **M1**（L17-21 注释）：改写，去 "can never go stale"，写明状态闸不依赖字面量（误导两次修复的措辞消除），保留 banner/fallback 语义
- **M2**（L24 后）：新增 `VERSION_URL`（raw.githubusercontent.com）
- **M3**（L37 后）：新增 `PROBE_OK=0` + `probe_remote_version()`（逐字照抄契约；含 `|| true` 防 set -e + ERR trap、正则采信前验证）
- **M4**（L1440）：`probe_remote_version` 调用于 `STATE=$(detect_state)` 前一行
- **M5**（L1423 后）：`CURRENT_VERSION` 补 CRLF/空白裁剪（`${CURRENT_VERSION//[$'\r\n ']/}`，与 detect_state L1349 对齐）——契约范围外既有缺陷的有益修复，显式记录
- **M6**（L1472-1492）：`ACTION == "none"` 三分支——`--force` 分支**排最前**（原样保留含 L1480 不降级保护），`elif PROBE_OK != 1` 兜底 `ACTION="upgrade"`，`else` 原「Nothing to do」原样保留
- **M8**（L1547-1548 注释）：去 "can never go stale"，写明仅下载后路径成立
- **M7**（L1551 后）：ROOT FIX 权威复判块（`FORCE != 1` && `CURRENT_VERSION != none` && `_tad_ver_cmp != -1` → 清理 TAD_SRC + Nothing to do + exit 0），紧接 `log_info "  → Source version..."` 之后、`# Execute based on action` 之前

零 git 写操作；黑名单（hooks/settings/CLAUDE.md/agents 等）零触碰。
