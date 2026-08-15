# Independent Code Review — pre-push 增量复核（D8 / AC16 / P1-1 + P1-2 修复轮）

harness/model/route: opencode / deepseek-v4-flash / independent-pre-push-reviewer（只读）

- 审查对象：LITE-20260811-1512-publish-v2410，rev8 契约，首轮 tip=`962ee9ff…`（CONDITIONAL P0=0/P1=2/P2=7），修复轮 tip=`02a94e6d3c6b29f7ce51f8b12905ae2adedc71b8`
- 范围：`git diff 962ee9f..02a94e6`（1 commit，仅 verify.sh + preflight-baseline.txt，均属 release 清单）；复核两条 P1 是否真正修复、性能声明、是否引入新问题
- 方法：A 组全量重跑（计时）、ac11/ac14/collect_targets/manifest_keys 逐函数独立提取探针、ruby 与旧 shell 实现逐键对照、manifest 键全量溯源
- 日期：2026-08-11
- ⚠️ 本报告写入 reviews 目录（第 25 项，不提交）；目录展开修复后该写入不触发 AC14 FAIL（见 P1-2 复核，写入后 A 组重跑实证 PASS）

---

## Verdict: **CONDITIONAL** — P0=0 / P1=1 / P2=8

P1-1 的内容修复与 P1-2 均确认修复（执行实证），AC14 性能 71s → 3.8s 确认；**但 P1-1 的失败类未真正闭环**：ac11 的实现对"排序基线 vs 未排序 collect_targets 输出"逐位置比较，registry 顺序与排序顺序不一致（9/14），remote/--all 模式下对一次完全正确的发布仍确定性 FAIL「目标 #1 元组变化」——与 P1-1 首轮定级同型（不可逆动作后必然 FAIL）。修复方向为一行级改动（ac11 对 collect_targets 输出排序即可，排序后与刷新基线 0 差异）。

---

## Findings

### ✅ P1-1 内容修复 — 确认修复（执行实证）

- missing 行格式：collect_targets 与基线两侧均为 `target <ph> missing backup=absent mws=n/a git=n/a`（无 dirty=/missingroots=），对齐。
- Sober Creator mws：基线已刷新为 `521dbdfd…`，与 collect_targets 现算一致；**两次独立运行输出逐字节相同**；`find -newermt 18:00` 排除 .git 元数据后无内容写入——当前无"目标自身活动"漂移（漂移属目标活动而非实现缺陷，如实标注）。
- 双侧排序比较：基线 targets 段（排序）vs collect_targets 输出（排序）**0/14 差异**；基线 14 行断言成立；`registry_shasum` 与现行 sync-registry.yaml 一致。
- 刷新范围：`git diff` 中基线改动仅 28 行且全部为 `target` 行；untracked-hashed（861 行）与 tracked-dirty（8 行）未动。

### 🔴 P1（新，未闭环）— ac11 位置比较顺序 bug：正确发布在 remote/--all 模式确定性 FAIL（执行实证）

**现象**：按 verify.sh 现文逐行复刻 ac11（baseline 段 `| LC_ALL=C sort`，collect_targets 输出**不排序**，`while read` 逐位置与 `sed -n "${n}p"` 比较），实跑输出：

```
AC11: FAIL: 目标 #1 元组变化
```

**分析**：`tmp_pre`（排序后）首行是 `target 001d7ee9…`（Sober Creator），而 collect_targets 输出首行是 `target e16ed373…`（menu-snap，registry 顺序第一位）；位置比较 9/14 行不一致（全部为顺序差异，无内容差异）。registry 顺序与 `LC_ALL=C sort` 顺序**不可能重合**（排序首键 001d7 在 registry 中排第 7），故该门在任何状态下都不可能 PASS——无论发布是否零 sync。首轮探针为"双侧排序"比较（首轮 LINE 1 是 Sober Creator；而按 ac11 真实逻辑 LINE 1 应为 menu-snap——阅读推断其探针偏离了门实现），掩盖了此问题；A 组默认运行不含 AC11（B 组 remote/--all 才跑），故 15/15 PASS 从未真正检验过该门。

**后果**：与 P1-1 首轮定级完全同型——post-publish 的 remote/`--all` 对正确发布确定性 FAIL → AC17 无 RESULT: PASS → recovery unknown → BLOCK_NO_MUTATION。P1-1 的失败类**未消除**，只是从内容差异变成顺序差异。

**修复方向（Blake）**：ac11 中 `collect_targets > "$tmp_post"` 改为 `collect_targets | LC_ALL=C sort > "$tmp_post"`（一行；排序后与刷新基线 0 差异，执行实证），或改按 target 键比较。追加 commit 更新第 21 项（verify.sh），合法通道。

### ✅ P1-2 — manifest_keys 目录级条目展开：确认修复（执行实证）

- 报告文件键 `untracked .tad/4efe2c64…` 现由目录展开产生，落在 manifest 内；`comm -23`（现状新增 − manifest）= 0。
- 报告**在场时**：全量 `verify.sh local` AC14 PASS + 独立 ac14 探针 PASS（两次）+ 本报告写入后终局重跑 PASS（见执行证据）。
- 目录内新增文件恒在清单内（展开是运行时求值），不存在"新增文件被误判清单外"；清单外判定只作用于 reviews 目录之外的新增未跟踪键——语义正确。
- 附发现（无问题）：`.tad/active/handoffs/…txn-lock` 条目实为**目录**（内含 `owner` 文件），同样命中展开分支；manifest 31 键全部可溯源至清单项（3 个 post-publish 产物按路径字符串键占位、27 个现存文件、1 个目录展开），无孤儿键，行为自洽。

### ✅ AC14 性能 — 确认（执行实证）

- 独立 ac14 两次：3.75s / 3.81s（原 71s；声明 4.4s 在负载 12 的机器上吻合）。
- 全量 `verify.sh local`：60.5s（首轮未记录全量基线；现瓶颈为 collect_targets 与 release-verify 门，不在本修复范围）。
- ruby 批量哈希与旧 shell 逐键对照：**861 键全部一致**，8 个排除项全部生效（decisions×4 等），排序稳定（输入输出均 LC_ALL=C sort）。

### P2-8（新，阅读推断）— 目录展开 `find -type f` 未含符号链接

`manifest_keys` 展开分支用 `find … -type f`，偏离仓库既有模式（collect_targets 用 `\( -type f -o -type l \)`）；若 reviews 目录未来出现符号链接文件，git status 会列出而 manifest 不覆盖 → AC14 误报。当前目录仅 .md 常规文件，契约受控目录，理论风险，P2。

### P2-1..P2-7（首轮遗留，非本单范围，未修不阻塞）

- P2-1 路径泄露仍在（基线 893 行 `derived from /path/to/…`）；P2-2 账本 run-local-acs 仍 partial；P2-3/4/6/7 文案/死代码未变。均不阻塞。

---

## 重点核查点结论

| 核查点 | 结论 | 依据 |
|---|---|---|
| P1-1 missing 行格式 | **修复确认** | collect_targets 与基线两侧逐字节一致（排序后 0/14 差异，执行实证） |
| P1-1 Sober Creator mws | **修复确认（当前稳定）** | 基线 521dbdfd = 现算值；两次独立运行相同；18:00 后无内容写入；后续若变属目标自身活动 |
| P1-1 基线刷新范围 | **符合声明** | diff 28 行全为 target 行；untracked-hashed 861 / tracked-dirty 8 未动 |
| P1-1 门实现闭环 | **未闭环 → P1** | ac11 排序 pre vs 未排序 post 位置比较，remote/--all 确定性 FAIL 目标 #1（执行实证） |
| P1-2 目录展开 | **修复确认** | 报告在场 AC14 PASS（全量 + 独立 + 写入后终局三重实证）；comm -23 = 0 |
| AC14 性能 | **确认** | 71s → 3.8s（独立计时）；ruby 与 shell 861 键逐键等价 |
| ruby 引入新问题 | **无** | 排除项等价、排序稳定、键格式一致；ruby 依赖为 collect_targets 既有依赖 |
| A 组回归 | **15/15 PASS** | tip=02a94e6 全量实跑，RESULT: PASS |
| pre-push | **PASS** | AC9pre PASS，rc=0 |
| 账本 | **一致** | 契约 tip_sha=02a94e6（覆盖写 ✓）、release 追加 02a94e6 ✓、首轮审查记录段已写回（708-709 行）✓；run-local-acs partial 未推进（P2-2） |

---

## 执行证据

以下命令全部实际运行；输出节选。

```
$ bash .tad/evidence/acceptance-tests/publish-v2410/verify.sh local && time …
AC1: PASS
AC2: PASS
AC3: PASS
AC4: PASS
AC5: PASS
…
AC14: PASS
AC15: PASS
AC18: PASS
RESULT: PASS
（time: 1:00.53 total；负载 ~12，其他会话并发）

$ ac11 独立探针（verify.sh 函数逐字提取 + REPO_ROOT/BASELINE + say/pass/fail/FAIL_COUNT）
AC11: FAIL: 目标 #1 元组变化

$ 位置比较明细（排序基线 vs collect_targets 原序，9/14）
LINE 1:  baseline=target 001d7ee9…(Sober Creator)  now=target e16ed373…(menu-snap)
LINE 4/5/7/8/9/10/12/14: 同型顺序差异（内容均一致）

$ 双侧排序内容比较
diff /tmp/ac11_pre.txt /tmp/post_sorted.txt → 0 行差异（P1-1 内容修复确认）

$ collect_targets 两次独立运行
diff /tmp/collect_targets_out.txt /tmp/collect_targets_out2.txt → STABLE
（time: ~104s/111s，负载高；输出 14 行）

$ find Sober Creator -newermt "2026-08-11 18:00:00" -not -path "*/node_modules/*" -not -path "*/.git/*"
（空 = 无内容写入，mws 稳定）

$ ac14 独立探针（manifest_keys + ac14 逐字提取），两次
AC14: PASS   （3.75s / 3.81s）

$ ruby vs 旧 shell 排除+哈希对照（同输入 869 未跟踪路径）
excluded=8 kept=861；diff → 无差异；基线 untracked-hashed 段 = 861 行

$ AC14 新增键反查
new keys (now − base) = 2：4efe2c64…(本审查报告) + 93477a8c…(results.txt)
comm -23 (new − manifest) = 0 → 均在清单内

$ manifest 键溯源：31 键全映射（27 现存文件 + 3 缺失项占位 + 1 目录展开 pre-push-reviewer.md；txn-lock 目录展开出 owner 键），无孤儿

$ bash verify.sh pre-push; echo rc=$?
AC1: PASS
AC9pre: PASS
RESULT: PASS
rc=0

$ 本报告写入后终局重跑
bash verify.sh local → AC14: PASS … RESULT: PASS（目录展开修复对新增报告文件生效）
```

---

## 备注

- 修复轮 commit 02a94e6 仅动 verify.sh + preflight-baseline.txt，路径 ⊆ 文件清单（AC15 口径），无越界。
- UNVERIFIED-BY-EXECUTION：remote/--all 的 post-publish 全量（远端动作未发生）；AC11 门以代码路径级探针复刻实现并实证 FAIL（非远端实跑）；Sober Creator mws 长期稳定性（当前稳定；基线刷新即当前真实状态的快照，后续目标自身写入会使其再次漂移——属目标活动）。
- AC16/N-6：本 verdict（CONDITIONAL，P0=0/P1=1/P2=8）须由 Blake 写回契约第 26 项；P1（ac11 排序）修复后追加 commit → tip_sha 覆盖写 → A 组重跑 → 复核通过后方可进入远端动作。
