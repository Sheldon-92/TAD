# Independent Code Review — pre-push 最终复核（第二轮增量 / D8 / AC16 / P1-1 闭环确认）

harness/model/route: opencode / deepseek-v4-flash / independent-pre-push-reviewer（只读，未修改任何仓库文件）

- 审查对象：LITE-20260811-1512-publish-v2410，rev8 契约；首轮 tip=`962ee9ff…`（CONDITIONAL P0=0/P1=2/P2=7）→ 修复轮 tip=`02a94e6`（CONDITIONAL P0=0/P1=1/P2=8，剩余 P1-1 ac11 排序错配）→ 本轮 tip=`9253bdd53a39651d89e6b77c124d961a84ea94f3`
- 范围：`git diff 02a94e6..9253bdd`（1 commit，仅 verify.sh 一行，release 清单内）
- 方法：A 组全量重跑、pre-push 实跑、ac11 逐字复刻探针（修复后）、排序双侧一致性 diff、账本 tip_sha 对账
- 日期：2026-08-11
- ⚠️ 本报告写入 reviews 目录（第 25 项，不提交）；目录展开修复（P1-2）已实证该写入不触发 AC14 FAIL

---

## Verdict: **PASS（可进入 push-main）** — P0=0 / P1=0 / P2=8

**AC16 pre-push 审查通过，可进入远端动作。**

上一轮唯一剩余 P1（P1-1 失败类：ac11 排序 pre vs 未排序 post 逐位置比较，remote/--all 确定性 FAIL「目标 #1 元组变化」）已由 commit 9253bdd 一行修复闭环：`collect_targets | LC_ALL=C sort > "$tmp_post"`（verify.sh:600）。修复后逐字复刻 ac11 实跑 **AC11: PASS**；排序后 collect_targets 输出与基线 targets 段（去 idx）**0 差异**。P1-2 上一轮已确认修复，本轮 A 组重跑未回归。无未处理 P0/P1。P2-1..P2-8 均为不阻塞项（非本单范围，未修）。

---

## Findings

### ✅ P1-1（唯一剩余 P1）— ac11 排序错配：修复闭环确认（执行实证）

- **修复形态**：`git diff 02a94e6..9253bdd` = 1 commit、1 文件（verify.sh）、1 行改动（`+1/-1`）：ac11 中 `collect_targets > "$tmp_post"` → `collect_targets | LC_ALL=C sort > "$tmp_post"`。路径 ⊆ 文件清单（AC15 口径），无越界。
- **门实现复核**（verify.sh:596-617）：基线段 `awk … | LC_ALL=C sort`（599 行）与 post 段 `collect_targets | LC_ALL=C sort`（600 行）**双侧均排序**；位置比较（`while read` + `sed -n "${n}p"`）现在两侧序一致，registry 顺序不再干扰；`idx=` 后缀仅基线侧剥离（609 行），两侧格式对齐。
- **逐字复刻实证**：从 verify.sh 逐字提取 collect_targets + ac11 + say/pass/fail，独立脚本实跑 → `AC11: PASS`（PASS_COUNT=1 FAIL_COUNT=0）。
- **排序双侧一致性**：基线 targets 段（14 行，去 idx、排序）vs collect_targets | sort（14 行）→ `diff` **0 行差异**（上次 9/14 位置错配全部消失）。
- **失败类消除论证**：上一轮失败根因是「registry 顺序 ≠ LC_ALL=C sort 顺序」（排序首键 001d7 在 registry 排第 7）；修复后两路输出同为 `LC_ALL=C sort` 序列，位置比较与键比较等价 → 该门不再依赖 registry 顺序，对完全正确的发布必 PASS。

### ✅ A 组 / pre-push — 全绿（执行实证）

- `verify.sh local`：**15/15 PASS**（AC1-AC8, AC5b, AC5c, AC6, AC7, AC7b, AC12, AC14, AC15, AC18），RESULT: PASS，rc=0。
- `verify.sh pre-push`：**AC1 PASS + AC9pre PASS**，RESULT: PASS，rc=0。
- P1-2（manifest 目录展开）无回归：AC14 PASS（A 组全量内含，且本报告写入后见终局重跑）。

### ✅ 账本 — 一致

- 契约 line 502：`commit_shas: {…, release: […, 02a94e6…, 9253bdd…], tip_sha: 9253bdd53a39651d89e6b77c124d961a84ea94f3}`
- `git rev-parse HEAD` = `9253bdd53a39651d89e6b77c124d961a84ea94f3` == `tip_sha` ✓（覆盖写语义正确，无陈旧 tip 镜像风险）
- release 集合已含修复 commit 9253bdd（追加），closeout 未动。

### P2 遗留（8 项，均不阻塞，非本单范围）

- P2-1 路径泄露（基线 `derived from /Users/sheldonzhao/…`）；P2-2 run-local-acs partial；P2-3/4/6/7 文案/死代码；P2-8 目录展开 `find -type f` 未含符号链接（本轮复核未见 reviews 目录出现符号链接文件，契约受控）。

---

## 重点核查点结论

| 核查点 | 结论 | 依据 |
|---|---|---|
| P1-1 ac11 排序修复 | **闭环确认** | 一行修复（verify.sh:600）；逐字复刻 AC11: PASS；双侧排序 diff 0 差异 |
| 上一轮 P1-2 目录展开 | **无回归** | A 组全量 AC14 PASS；本报告写入后终局重跑 PASS |
| A 组回归 | **15/15 PASS** | tip=9253bdd 全量实跑，RESULT: PASS，rc=0 |
| pre-push | **PASS** | AC1 + AC9pre PASS，rc=0 |
| 账本 | **一致** | 契约 tip_sha=9253bdd == git rev-parse HEAD；release 含 9253bdd |
| 未处理 P0/P1 | **无** | 唯一剩余 P1-1 已闭环；P2×8 均不阻塞 |
| 改动集边界 | **合规** | 02a94e6..9253bdd 仅 verify.sh 一行，⊆ 文件清单 |

---

## 执行证据

以下命令全部实际运行；输出节选（原始输出前 10 行）。

```
$ git rev-parse HEAD
9253bdd53a39651d89e6b77c124d961a84ea94f3

$ git diff 02a94e6..9253bdd --stat
 .tad/evidence/acceptance-tests/publish-v2410/verify.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

$ git diff 02a94e6..9253bdd   （唯一改动行）
-  collect_targets > "$tmp_post" 2>/dev/null
+  collect_targets | LC_ALL=C sort > "$tmp_post" 2>/dev/null

$ bash .tad/evidence/acceptance-tests/publish-v2410/verify.sh local
AC1: PASS
AC2: PASS
AC3: PASS
AC4: PASS
AC5: PASS
AC5b: PASS
AC5c: PASS
AC8: PASS
AC6: PASS
AC7: PASS
…（AC7b/AC12/AC14/AC15/AC18 全部 PASS）RESULT: PASS  rc=0

$ bash .tad/evidence/acceptance-tests/publish-v2410/verify.sh pre-push
AC1: PASS
AC9pre: PASS
RESULT: PASS
rc=0

$ ac11 逐字复刻探针（sed 提取 verify.sh 原函数 + 独立执行）
=== 探针 1: ac11 逐字复刻（修复后）===
AC11: PASS
PASS_COUNT=1 FAIL_COUNT=0

$ 排序双侧一致性（基线 targets 段去 idx+排序 vs collect_targets | sort）
pre_lines=14 post_lines=14
diff → 0 行差异（DIFF=0 一致）

$ 账本对账（契约 line 502）
tip_sha: 9253bdd53a39651d89e6b77c124d961a84ea94f3 == git rev-parse HEAD ✓
```

---

## 备注

- UNVERIFIED-BY-EXECUTION：remote/--all 的 post-publish 全量（远端动作未发生）；AC11 以代码路径级逐字复刻实证（修复后 PASS，非远端实跑）。此为本审查协议既定边界，不构成阻塞。
- 本 verdict（PASS）须由 Blake 写回契约第 26 项后方可执行 push-main（AC9pre 已实证通过，可紧接远端动作）。
