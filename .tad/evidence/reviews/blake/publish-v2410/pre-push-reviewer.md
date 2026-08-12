# Independent Code Review — pre-push（D8 / AC16）

harness/model/route: opencode / deepseek-v4-flash / independent-pre-push-reviewer（只读）

- 审查对象：LITE 发布单 LITE-20260811-1512-publish-v2410，rev8 契约，tip=`962ee9ff4fd0d8c081e566319ff57b816e35d56f`
- 范围：记录的 tip 的落地内容 + A 组全部 AC 结果（`independent-review-pre-push`）
- 方法：逐 commit 路径核对、A 组 AC 全量重跑（`verify.sh local`）、独立命令抽查、scratch 探针复现/证伪
- 日期：2026-08-11
- ⚠️ 备注：本报告文件自身的写入触发了 AC14 FAIL（P1-2，实测）——这是审查发现，不是审查动作失当；报告按契约 AC16 要求保留在 reviews 目录（第 25 项，不提交）。

---

## Verdict: **CONDITIONAL** — P0=0 / P1=2 / P2=7

A 组 15 条 AC 在**报告写入前**全部 PASS（执行实证）；但发现 2 条 P1：
- P1-1：verify.sh 的 B 组 AC11 与基线 `preflight-baseline.txt` 的 targets 段存在确定性
  不一致，post-publish 时一次完全正确的发布会在 AC11 上必然 FAIL（与 rev2 已修的 N-1
  同型失败类）；
- P1-2：verify.sh 的 AC14 manifest_keys 对**目录级清单项**按路径字符串 hash，不能覆盖
  目录内文件——本审查报告（契约 AC16 明确要求的产物，第 25 项）写入后实测 AC14 FAIL，
  且会阻塞 P1-1 修复轮的 A 组重跑。

按 AC16「P0=0、P1=0 才能进入远端动作」，两条 P1 修复（追加 commit 更新第 20/21 项）+
A 组重跑 + 复核后，方可进入远端动作。

---

## Findings

### P1-1 — AC11（B 组）基线 targets 段与 verify.sh collect_targets 输出不一致，post-publish 必然 FAIL（执行实证）
**现象**：用 verify.sh 的 `collect_targets` 函数原样提取并实跑（2 次），对比基线
`## targets` 段（剥离 `idx=` 后缀后按 AC11 的逐行比较逻辑），**3/14 行不匹配**：

```
LINE 1  Sober Creator mws 差异
        baseline: mws=f3af8944a5520a54ac77e8f0b1177d57f753440ec7a1b6aa8df86605f91e6bb7
        now:      mws=521dbdfd1bc5c4a10e0e40f898911e58e36de60fc7ea648fa9e6a439b3169c41
        （git= 与 dirty= 两侧相同；missingroots=[ AGENTS.md.bak] 相同）
LINE 5  missing 目标格式差异
        baseline: target 51bdebf218f62d0d missing backup=absent mws=n/a git=n/a
        now:      target 51bdebf218f62d0d missing backup=absent mws=n/a git=n/a dirty=n/a missingroots=[]
LINE 9  missing 目标格式差异（同上，b54e85379749313f，idx=04）
```

**根因分析（已逐项排除）**：
1. missing 行格式（LINE 5/9）：基线 snapshot 工具输出 `mws=n/a git=n/a`（无 `dirty=`、
   无 `missingroots=[]`），而 `collect_targets`（verify.sh:560-562 的 missing 分支）输出
   `dirty=n/a missingroots=[]`——**两个实现不一致**。
2. Sober Creator mws（LINE 1）：`find -newermt "2026-08-11 20:07:00"` 对 4 根 9908 个文件
   无任何修改（内容未变）；`collect_targets` 现算稳定复现 `521dbdfd…`；模拟多种范围变体
   （4 根+具名 / 3 根+具名 / 4 根无具名 / 全部 sort 后聚合）均 ≠ 基线 `f3af8944…`——
   证明**基线 snapshot 时的收集算法/范围与 verify.sh 不是同一实现**（基线 20:07:13Z 生成，
   早于 verify.sh 落盘 commit B；契约 AC11(b) 只描述了算法，未强制 snapshot 工具与
   verify.sh 为同一实现）。

**后果**：AC11 在 post-publish 时对 3/14 行必然 FAIL（无论发布是否真的零 sync）。这与
rev2 修的 N-1（AC9c 会让正确发布 FAIL，当时定级 P1）是同一失败类：正确发布在**不可逆
动作之后**触发 FAIL，而 recovery_policy 无「AC 失败但发布本身是对的」分支 → 落入
unknown → BLOCK_NO_MUTATION。D8 的整个结构设计就是消灭这一类。

**修复方向（Blake）**：追加 commit 更新 `preflight-baseline.txt`（第 20 项）的 `## targets`
段——用 verify.sh 的 `collect_targets` 同款逻辑重新生成（含 missing 行带
`dirty=n/a missingroots=[]`），或改 `collect_targets` missing 分支输出与基线对齐。
两案均落在文件清单内（release 集合），符合 rev5 的追加修正通道；修正后 tip_sha 覆盖写、
A 组重跑、复核。禁止在 push 后才发现。

### P1-2 — AC14 manifest_keys 目录级清单项失效：审查报告写入后 AC14 必然 FAIL（执行实证）

**现象**：本审查按契约 AC16/N-6 将报告写入 `.tad/evidence/reviews/blake/publish-v2410/
pre-push-reviewer.md`（第 25 项，明确不提交）后，重跑 `verify.sh local` 实测：

```
AC14: 清单外新增路径键: untracked .tad/4efe2c6494c853ca30cd604f8baebf2649ae633398f468114fc6a8780ea0c46b
AC14: FAIL: 存在清单外新增未跟踪路径（见上）
```

反查确认 4efe2c64 = `.tad/evidence/reviews/blake/publish-v2410/pre-push-reviewer.md`。

**根因**：契约第 25 项以**目录级**路径列出 `.tad/evidence/reviews/blake/publish-v2410/`
（意图：该目录下一切新增皆在清单内），但 verify.sh 的 `manifest_keys`（:312）把该条目
当作**单一路径字符串**做 sha256（`untracked .tad/3e1f5aa9…`），只匹配"恰好叫这个名字的
文件"，不匹配目录内文件。目录级清单项在 AC14 的实现中结构性失效。

**后果链**：
1. 契约 AC16 自己要求审查报告落该目录（N-6：pre-push 审查结论须写回，报告为第 25 项
   工作区证据）——该产物一产生，AC14 必然 FAIL；
2. P1-1 修复轮若重跑 A 组（契约要求），此时报告已在目录中 → AC14 FAIL，修复轮被自己
   的审查证据卡死（除非先修 verify.sh）；
3. post-publish 的 AC17（`--all` 连续两次一致 + RESULT: PASS）时 reviews 目录已有
   pre-push 报告 → `--all` 的 AC14 必然 FAIL → AC17 必然 FAIL。
这是契约条款之间的结构性冲突，与 rev2 的 N-2（隐私改动打断围栏集合运算，定 P1）同型。

**修复方向（Blake）**：`manifest_keys` 对目录级条目（第 25 项的 reviews 目录）做展开——
列出该目录内现有文件的路径字符串 hash（或 AC14 比较时按目录前缀匹配），使报告文件落在
清单内。追加 commit 落在第 21 项（verify.sh），属 release 集合，合法通道。禁止以"删掉
报告再跑"规避（报告是契约要求的审查证据）。

### P2-1 — 隐私残留：基线泄露本地绝对路径（执行实证）

`preflight-baseline.txt`（进 commit 8b0c40a 并推送公开仓库）第 893 行：
`syncset | === RELEASE SYNC SET (derived from /Users/sheldonzhao/01-on progress programs/TAD/.tad/ — bias-to-sync, REPORTED each run) ===`
—— F9 rev3 方案只把 `## untracked-hashed` 段摘要化（该段已合规：`<顶层目录>/<sha256>`），
但 `## derive-sync-set-pre` 段第一行原样保留了 `derive-sync-set.sh --report` 的完整本地
绝对路径（用户名 + 目录结构）。F9 定级「仅文件名无内容，严重度低但无必要」，按同尺度记
P2。建议修复轮顺手把该行改写为相对路径/去路径化（README 式）后再推送。

### P2-2 — 执行账本陈旧：run-local-acs 仍为 partial（阅读推断）

契约 `Execution Transactions`（:512）记 `run-local-acs, state: partial`（注释「第一轮 15
PASS / 2 FAIL」），而 Lite Progress（:701）已记录修复轮 `verify.sh local 15/15 PASS
(tip=962ee9f)`。rev7 刚修过「账本与实际执行状态严重不符」（当时定 P1），本单修复轮后
账本未推进到 completed，属同类记账滞后的轻度复发。不阻塞（本次审查即独立复验），P2。

### P2-3 — verify.sh:118 AC8 fail 文案残留「commit B 时刻」（阅读推断）

契约 rev6 已把 AC8(b) 表述从「commit B 时刻」改为「记录的 tip 落盘时刻」，verify.sh 的
ac8 fail 消息仍写 `fail AC8 "commit B 时刻 gate=$g rc=$r"`。纯文案（仅在 FAIL 时输出），
不承重，P2。

### P2-4 — verify.sh:504 未使用变量 bmap/amap（阅读推断）

`local bkeys akeys bmap amap` 中 bmap/amap 声明后从未使用，无害残留，P2。

### P2-5 — results.txt layer2_hits 重复 5 行（执行实证）

`layer2_hits=20` 在 results.txt 中出现 5 次（`verify.sh local` 每次运行 ac3 都会 append
一行，契约 AC3 要求「写入 results.txt」，未断言次数）。当前值 20 与契约空跑日志的 Layer 2
基线 478 不同——空跑是 bump 前的旧口径，且 advisory 不承重，无断言冲突；重复行是记账
噪音。另注：verify.sh:157 的 `grep -cF '⚠️'` 计数口径与 478 的口径不同，建议在 results.txt
注明计数口径，P2。

### P2-6 — AC5c 的 derive 豁免与契约文本分歧（阅读推断）

verify.sh:103-107 把 `derive` 与 `driftcheck` 同列豁免为不构成 blocker（
`case "$g:$r" in driftcheck:*) ;; derive:*) ;;`），契约 AC5c 只把
`pack-registry-driftcheck.sh` 标为 advisory，未豁免 derive。严格读契约，derive rc=1 应算
blocker。当前 derive rc=0（执行实证），无实际影响；且 AC8 承重列表（parity/version/
version-sweep/migration/denylist）本就不含 derive。记 P2 备忘，不阻塞。

### P2-7 — AC14「清单内跳过」分支是死代码（阅读推断）

verify.sh:359 `grep -Fq -e "$p" "$tmp_manifest"` 用裸路径在**摘要键清单**
（`untracked <top>/<sha256>` 格式）中检索，永远不命中——「在清单内 → 跳过」分支不可达。
当前无清单内已脏 tracked 路径（第 1-24 项均已提交），不影响本次 AC14 PASS（执行实证）；
但若未来修复轮在未提交状态下修改 verify.sh 再跑 local，该分支本应放行清单内路径却会走
摘要比较而误报 FAIL。契约语义正确、实现分支失效，P2。

---

## 重点核查点结论

| 核查点 | 结论 | 依据 |
|---|---|---|
| AC7b 大小写不敏感 + 附录表格 | **通过** | verify.sh:241-254 全部 `grep -Fqi -e`；6 个代表串与附录表格逐字一致（installer/tad.sh、lite-first lifecycle、inventory/能力提取、release-runbook、逐命令审批、Layer 1）；CHANGELOG 含 `**Lite-first lifecycle**`（大写）实测命中；AC7b PASS |
| AC14 范围围栏 | **条件通过 → P1-2** | 报告写入前：独立重算新增键仅 1 个 = results.txt（第 25 项，清单内），AC14 PASS；报告写入后：目录级清单项失效，AC14 实测 FAIL（P1-2） |
| AC15 逐 commit 纪律 | **通过** | base..tip=3 个 commit（8fda2ac/8b0c40a/962ee9f），无 merge；逐 commit 路径 ⊆ 清单（git 实测）；closeout/release 路径 `comm -12` 为空；AC15 PASS |
| verify.sh 读记录 tip | **通过** | verify.sh:30 从契约 `commit_shas.tip_sha` 具名字段 sed 提取（`tail -1` 防多行），值为 962ee9f=HEAD=本地 main；AC15/AC9pre 双实证 |
| AC9pre 前置闸 | **通过** | `verify.sh pre-push` 实测 PASS：远端 main=2fbebe8=基线 remote_main_pre、merge-base 快进、本地 main=tip_sha |
| 版本落地 AC6 三处 | **通过** | `.tad/version.txt`=2.41.0、package.json `"version": "2.41.0"`、tad.sh:26 `TARGET_VERSION="2.41.0"` |
| CHANGELOG 实质 AC7/AC7b | **通过** | 2.41.0 区块存在；`### 行为变更` 小节；点名「逐命令审批」「Layer 1」；6 代表串全命中 |
| Epic 修订 AC12 四条 | **通过** | (a) Phase Map 3c 行无 sync；(b) `Phase 3c owns` 行含 publish-only 无 publish+sync；(c) SC5 行同；(d) feedback_no-sync-pull-based 决策段存在。Pre-3c 新增段属契约第 19 项授权（「上一单 follow-up 段」），其中「3c 的 sync 是扇出动作」为历史叙述保留，符合契约「不得改写归档历史」指令（与 publish-only 的张力为契约明示豁免） |
| verify.sh 脚本质量 | **通过（含 P2 残留）** | 无进程替换（grep 实证 rc=1）；find 复合条件带括号（:570 `\( -type f -o -type l \) -print0`）；grep -F -e + 显式 rc 大体遵守；每门 0/1/2 三分支（AC8(d) 字符串存在性，rev3 已降级提示性）；AC5c 行首锚定 `^gate=${g} rc=` 无前缀碰撞；P2-3/4/6/7 见上 |
| 路径泄露 | **部分通过 → P2-1** | untracked 段已摘要化（F9 rev3 方案落实）；derive-sync-set-pre 段第一行泄露本地绝对路径（P2-1） |
| 执行账本 | **基本一致（P2-2）** | commit_shas{closeout=8fda2ac, release=[8b0c40a,962ee9f], tip_sha=962ee9f} 与 git 实测逐字一致；state_version=1；9 action completed；run-local-acs partial 滞后（P2-2） |

---

## 执行证据

以下命令全部实际运行；输出节选前 10 行。

```
$ git status --short   （仓库只读，未做任何写操作）
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
 M .tad/research-notebooks/REGISTRY.yaml
?? .claude/settings.local.json.bak-20260806-082549
?? .tad/active/handoffs/
…（其余为 F3 既有未跟踪项）

$ git rev-list --count 2efe3d7..HEAD
3

$ git log --oneline origin/main..HEAD   （14 = 11 积压 + 3 本单）
962ee9f fix(verify): align AC7b case-insensitive + AC14 mktemp + recorded-tip semantics (rev8)
8b0c40a release: v2.41.0 — Lite authority model v2 (contract mandate) + Layer 1 AC-driven self-check
8fda2ac closeout: archive LITE-20260810-1820-layer1-ac-driven-compat + distill …
2efe3d7 docs(lite): layer1 AC-driven compat completion + final AC16 result
…

$ git rev-list --merges 2efe3d7..HEAD   （空 = 无 merge）

$ comm -12 <(git diff --name-only 2efe3d7..8fda2ac) <(git diff --name-only 8fda2ac..962ee9f)
（空 = closeout/release 互斥）

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
AC7b: PASS
AC12: PASS
AC14: PASS
AC15: PASS
AC18: PASS
RESULT: PASS

$ bash .tad/evidence/acceptance-tests/publish-v2410/verify.sh pre-push
AC1: PASS
AC9pre: PASS
RESULT: PASS

$ bash tad.sh --verify-denylist; echo rc=$?
✓ --verify-denylist: tad.sh inlined DENY_LIST == derive-sync-set.sh (17 entries)
denylist rc=0

$ bash .tad/hooks/lib/release-verify.sh parity "$(pwd -P)"; echo rc=$?
PARITY VERIFY (.claude/skills <-> .agents/skills byte-identity)
  ✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0) / parity rc=0

$ bash .tad/hooks/lib/release-verify.sh version "$(pwd -P)" 2.41.0 2.40.0 >/dev/null 2>&1; echo rc=$?
version rc=0

$ bash .tad/hooks/lib/release-verify.sh migration "$(pwd -P)" >/dev/null 2>&1; echo rc=$?
migration rc=0

$ bash .tad/hooks/lib/release-verify.sh version-sweep "$(pwd -P)" 2.41.0 2>/dev/null | grep -cF '⚠️'
20

$ wc -c .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md
24126 alex-lite / 28072 blake-lite / sum=52198 ≤ 52200

$ awk '/^collect_targets\(\)/,/^}/' verify.sh > /tmp/collect_targets_probe.sh … && bash /tmp/collect_targets_probe.sh（2 次，稳定）
target 001d7ee9669a47a8 exists backup=absent mws=521dbdfd1bc5c4a10e0e40f898911e58e36de60fc7ea648fa9e6a439b3169c41 git=856056faaddc3dd9f14951629f5775832eb36af6 dirty=c4ab78fb… missingroots=[ AGENTS.md.bak]

$ AC11 逐行比较探针（基线 idx 剥离 vs collect_targets 输出）
LINE 1 DIFF:  Sober Creator mws（f3af8944 vs 521dbdfd）
LINE 5 DIFF:  missing 行格式（缺 dirty=/missingroots=）
LINE 9 DIFF:  missing 行格式（同）
total mismatched lines: 3 / 14

$ find "…/Sober Creator"/{.tad,.claude,.agents,.codex} \( -type f -o -type l \) -newermt "2026-08-11 20:07:00"
（空 = snapshot 后无文件修改）

$ git show 8b0c40a:.tad/evidence/acceptance-tests/publish-v2410/preflight-baseline.txt | grep -n 'Users/'
893:syncset | === RELEASE SYNC SET (derived from /Users/sheldonzhao/01-on progress programs/TAD/.tad/ …) ===

$ AC14 独立重算（comm -13 基线键 现状键）
new keys count: 1
untracked .tad/93477a8c03d6f48a800eda51d828aeafcc8bfb9311b3ea51c7d42eec7c52fc61
（sha256 反查 = .tad/evidence/acceptance-tests/publish-v2410/results.txt，第 25 项，清单内）

$ bash .tad/evidence/acceptance-tests/publish-v2410/verify.sh local   （报告写入后重跑）
AC14: 清单外新增路径键: untracked .tad/4efe2c6494c853ca30cd604f8baebf2649ae633398f468114fc6a8780ea0c46b
AC14: FAIL: 存在清单外新增未跟踪路径（见上）
AC18: PASS
RESULT: FAIL
（4efe2c64 = .tad/evidence/reviews/blake/publish-v2410/pre-push-reviewer.md → P1-2）
```

---

## 备注

- 本报告写入 `.tad/evidence/reviews/blake/publish-v2410/pre-push-reviewer.md`（第 25 项，
  不提交）；其写入本身触发了 P1-2 的 AC14 必然 FAIL（见 P1-2，实测）。
- AC16/N-6：Blake 须把本 verdict、reviewer 身份（opencode / deepseek-v4-flash /
  independent-pre-push-reviewer）、报告文件摘要写回契约（第 26 项），并待 P1-1 + P1-2
  修复后追加 commit → tip_sha 覆盖写 → A 组重跑 → 复核通过后方可进入 push-main。
  注意：修复 P1-2 之前不要重跑 A 组（报告已在目录中，AC14 必然 FAIL）。
- UNVERIFIED-BY-EXECUTION 项：AC10a（tag 未创建，本地无 v2.41.0 可查，属发布后阶段，
  pre-push 不适用）；AC11 的 post-publish 全量（远端动作未发生）；AC9/AC10（远端半）。
  AC11 的**比较逻辑**已用本地探针完整模拟（3/14 FAIL 为确定性结论）。
