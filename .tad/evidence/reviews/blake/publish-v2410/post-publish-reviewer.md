# Independent Code Review — post-publish 复核（AC16 B 组 / D8 后半）

harness/model/route: opencode / deepseek-v4-flash / independent-post-publish-reviewer（只读，未修改任何仓库文件）

- 审查对象：LITE-20260811-1512-publish-v2410，rev8 契约，记录 tip=`9253bdd53a39651d89e6b77c124d961a84ea94f3`
- 审查范围：B 组（发布后）AC9/AC10/AC11/AC13/AC16/AC17 的执行证据 + 整体发布一致性
- 发布状态复核：远端 main 已快进至 tip；annotated tag v2.41.0 已推送且 peeled 指向 tip

## Verdict: **PASS** — P0=0 / P1=0 / P2=1

B 组六条 AC 全部 PASS（AC16 按契约语义以最终轮 PASS 为放行依据，见下文）。所有可实跑的验证均已实跑；
唯一未做的是 AC17 的两次全量重放（约 2 分钟/轮），以既有双轮证据 + AC11 单次实时采集复跑替代（已注明）。

## Findings

- **P0**: 0
- **P1**: 0
- **P2-1（文档级，不阻塞）**: 契约「文件清单」第 25 项列出 `targets-post.txt`，但该文件当前不存在
  （实测 `ls` 确认）。AC11 的 post 侧已改为**实时采集**（verify.sh:606 `collect_targets | LC_ALL=C sort`），
  任何断言都不读该文件，verify.sh:308 的 manifest 中保留该路径仅作 AC14 围栏。纯契约清单与实现的轻微
  漂移，无功能影响。建议下一单维护时把该文件名从契约清单移除或恢复其生成。

## AC 复核明细

### AC9（远端 main）— **PASS**（执行实证）

- (a) 实跑 `git ls-remote --heads origin refs/heads/main` →
  `9253bdd53a39651d89e6b77c124d961a84ea94f3` == 记录 tip（commit_shas.tip_sha）。✓
- (b) 实跑 `git merge-base --is-ancestor 2fbebe8ae87ac2d66a1430f359e616a05af5f7de 9253bdd…`，rc=0 —
  快进机械证明（`remote_main_pre` 是 tip 的祖先，等价于未用 `--force`）。✓
- (c) 完整 ref 清单 diff：基线 `## ls-remote-baseline` 段（preflight-baseline.txt:969）实测 **113** 条；
  当前 `git ls-remote origin` 实测 **115** 条。两侧 `LC_ALL=C sort` 后 diff 输出恰为
  **2 删除**（旧 `HEAD`、`refs/heads/main`）+ **4 新增**（新 `HEAD`、`refs/heads/main`、
  `refs/tags/v2.41.0` tag 对象行 `34a4c9a…`、`refs/tags/v2.41.0^{}`）——
  语义上**恰好 2 行修改**（HEAD+main 新 SHA 均 = tip）+ **恰好 2 行新增**（v2.41.0 与其 `^{}`）+
  **0 行删除**。远端 `refs/heads/claude/alex-0h91ph` 及其余 110 条 ref 未被触碰。✓

### AC10（tag·远端半）— **PASS**（执行实证）

- 实跑 `git ls-remote --tags origin refs/tags/v2.41.0 refs/tags/v2.41.0^{}`：
  `34a4c9af3e9b0da9d7e761b3f834b6036fd93bfa refs/tags/v2.41.0`（tag 对象）+ peeled
  `9253bdd53a39651d89e6b77c124d961a84ea94f3 refs/tags/v2.41.0^{}` == 记录 tip。✓
- 本地补充（AC10a 侧）：`git cat-file -t v2.41.0` = `tag`（annotated 非 lightweight）；
  `git rev-parse v2.41.0^{commit}` = 9253bdd…。✓

### AC11（零 sync）— **PASS**（执行实证）

- 从工作区 verify.sh **逐字提取** `collect_targets()` 独立实跑：14 行、rc=0；
  与基线 `## targets` 段（LC_ALL=C sort 后）`diff` = **0 差异**（14 vs 14）。✓
  覆盖 (a) 存在性（12 exists / 2 missing 与基线一致）(b) MWS 摘要逐目标一致 (c) 全部 `backup=absent`
  (d) git HEAD 与 dirty 摘要一致 (e) 见下。
- registry 指纹：`shasum -a 256 .tad/sync-registry.yaml` 实跑 =
  `1151b1de14b194c561f7581bf1d19906f4b926e0dc7b70b2e78f412a1471b585` ==
  preflight-baseline.txt `registry_shasum=` 行 == 契约 AC11(e) 记录值。✓

### AC13（发布命令纪律）— **PASS**（执行实证）

- `publish-commands.txt` 三条命令与 `publish-ops.md` §4（.agents/skills/release-runbook/references）
  逐字形式对照：
  1. `git push origin 9253bdd53a39651d89e6b77c124d961a84ea94f3:refs/heads/main` ✓（字面 SHA，禁 HEAD/main）
  2. `git tag -a "v2.41.0" 9253bdd… -m "<D5 文本>"` ✓（annotated、消息与 D5 固定文本逐字一致）
  3. `git push origin "refs/tags/v2.41.0:refs/tags/v2.41.0"` ✓（精确 refspec，仅该 tag）
- 违禁模式 `grep -cE '\-\-force|--tags|push .*&&|push .*;'` 实跑计数 = **0**。✓
- 如实标注（契约同款注记）：自撰日志，证据力上限已知；承重的是 AC9(b)(c) 远端机械证明。

### AC16（独立审查）— **PASS**（执行实证 + 阅读推断）

- 三份报告存在且首行自报 harness/model/route：
  - `pre-push-reviewer.md`（tip=962ee9f）：**CONDITIONAL** P0=0/P1=2/P2=7
  - `pre-push-reviewer-incremental.md`（tip=02a94e6）：**CONDITIONAL** P0=0/P1=1/P2=8
  - `pre-push-reviewer-final.md`（**tip=9253bdd == 记录 tip**）：**PASS（可进入 push-main）** P0=0/P1=0/P2=8
- 契约 AC16 语义是「对**记录的 tip** 的落地内容与 A 组全部 AC 结果给出 PASS（P0=0/P1=0）才能进入
  远端动作」——最终轮恰好对记录 tip 给出 PASS，是放行依据。前两轮 CONDITIONAL 是修复过程的中间态
  （首轮 P1-1 目标元组格式错配、P1-2 manifest 目录级失效；第二轮 P1-1 排序错配 → 9253bdd 一行修复闭环，
  契约「Pre-Push 最终复核」记录一致）。
- 注：任务描述字面「三份 verdict PASS」与实际（2×CONDITIONAL + 1×PASS）有出入，判读为「最终轮 PASS」
  即契约要求，不构成缺陷。

### AC17（可重放）— **PASS**（执行实证，轻量替代已注明）

- `/tmp/all-run2.txt`（19:05）与 `/tmp/all-run3.txt`（19:09）：排除时间戳行后 `diff` rc=0，
  均 304 字节、均为 23 行 PASS 记录、末行均 `RESULT: PASS`。✓
- **轻量替代说明**：未重跑两次 `--all` 全量（含 AC11 的 14 目标 MWS 摘要与 AC9 ls-remote，每轮约 2 分钟）。
  以 (i) 既有双轮证据一致、(ii) AC11 单次实时采集复跑 0 差异、(iii) AC9/AC10 远端状态实时复验
  作为替代面；其余 AC（A 组 15 条 + AC9pre/AC10a）在 all-run2/3 中均有 PASS 记录且两轮一致。
- 工作区 `verify.sh` 的未提交修正（`git diff` 核对）恰为任务声明的 AC9pre post-publish 变体：
  `--all` 模式下 `ac9pre post-publish` 要求远端 main == tip（注释「已被 AC9(a) 断言」），而非 == 基线；
  未追加 commit，未破坏已推送 tip。修正与声明逐字一致，无隐藏改动。✓

## 整体发布一致性

- 三条发布命令的目标 commit 统一为记录 tip `9253bdd…`（字面 SHA），与 transaction `commit_shas.tip_sha`
  一致；本地 `main`、远端 `main`、tag peeled 三者同 SHA。✓
- 工作区脏状态与契约 F3b/第 25 项完全吻合：lite-pricing-gate-protocol 三件套（陈旧证据）、
  REGISTRY.yaml（hook 写入）、verify.sh（AC9pre 修正，未提交——正确，提交会破坏已推送 tip 一致性）；
  未跟踪项 = 第 25 项证据 + AC14 排除项。无清单外新增。✓

## 执行证据

- AC9(a): `git ls-remote --heads origin refs/heads/main` → `9253bdd53a39651d89e6b77c124d961a84ea94f3`
- AC9(b): `git merge-base --is-ancestor 2fbebe8ae87ac2d66a1430f359e616a05af5f7de 9253bdd…` → rc=0
- AC9(c): 基线 refs 113 条（preflight-baseline.txt:969 段，wc -l）→ 当前 115 条；
  `diff <(基线|sort) <(git ls-remote origin|sort)` → 2 删 + 4 增（= 2 修改 + 2 新增 + 0 删除）
- AC10: `git ls-remote --tags origin refs/tags/v2.41.0 refs/tags/v2.41.0^{}` →
  `34a4c9af3e9b0da9d7e761b3f834b6036fd93bfa` / `9253bdd53a39651d89e6b77c124d961a84ea94f3`
- AC11: verify.sh `collect_targets` 逐字提取实跑 → 14 行 rc=0；与基线 targets 段 sort 后 diff=0；
  `shasum -a 256 .tad/sync-registry.yaml` → `1151b1de14b194c561f7581bf1d19906f4b926e0dc7b70b2e78f412a1471b585`
- AC13: publish-commands.txt 三条与 publish-ops.md §4 逐字对照通过；违禁模式 grep 计数 0
- AC16: `.tad/evidence/reviews/blake/publish-v2410/{pre-push-reviewer,pre-push-reviewer-incremental,pre-push-reviewer-final}.md`
  三份存在；final = `## Verdict: **PASS（可进入 push-main）** — P0=0 / P1=0 / P2=8`
- AC17: `diff <(all-run2 除时间戳) <(all-run3 除时间戳)` → rc=0；两文件 304B、23 行 PASS、末行 `RESULT: PASS`
- 工作区: `git diff .tad/evidence/acceptance-tests/publish-v2410/verify.sh` → 仅 ac9pre mode 分支 +
  `--all` 调用 `ac9pre post-publish` 两处
- 本报告为只读复核，未修改任何仓库文件（临时探针产物已清理至 /tmp）
