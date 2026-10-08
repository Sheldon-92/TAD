# Gate 3 CODE 评审 — R3 补落（re-land）独立重算

- 评审人：Alex（Solution Lead 激活壳，Gate 3 CODE 独立评审会话；未参与补落实施）
- 日期：2026-10-08
- 被审对象：补落提交 `2d0929f2`（实现笔）＋`124b5533`（链务笔）＋`834ff199`（卡笔）
  与补落记录 `.tad/evidence/self-review-r3-20261006/reland-closeout-note.md`
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 3 节（7 项）＋任务书四项重算清单
- 方法纪律：被审方自报值一律不采信，全部亲跑重算后比对（Canonical 证据否决口径：
  自报与重算不符即该行 FAIL 且整体不得 PASS——本审无此情形）

## Verdict：PASS

四项重算逐项全等，无 CONDITIONAL 条件、无 FAIL 行。gate4_delta 基准：自报＝重算，差量 0。

## 激活自报

- 激活壳：`~/workspace/skills/tad-alex/SKILL.md` 全文，按其激活协议在目标仓
  `/home/hatch/workspace/yun-sync/TAD` 执行。
- 实读原件（逐件路径）：
  - `/home/hatch/workspace/yun-sync/TAD/AGENTS.md`
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/principles.md`
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/_index.md`
  - `/home/hatch/workspace/yun-sync/TAD/.tad/brain-index.md`（路由段）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/tasks/gate-execution.md`（Gate 3 节，L150–221）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/gates/gate-canonical-checklist.md`（Gate 3 节，L37–60）
- patterns 选中 3 条（≤3 上限）：Release & Sync（全文）、Gate Design
  （Claims Need Carriers／Gate 4 Verification Integrity／YOLO Worktree Grounding 段）、
  AC Verification（Commit-Contents AC／Count-Based AC／Snapshot Fence 段）。
- brain-index 路由命中：Patterns 表 Gate Design／AC Verification／Release & Sync 三行；
  Active Epics 行 EPIC-20261006。任务性质（补落＝丢失谱系内容的 parity 重落）与
  Release & Sync 的镜像/parity 危害面直接对应。
- 与任务书冲突：无。Step 0 断言：reland 记录绝对路径实存；四提交对象
  （`2d0929f2`／`124b5533`／`834ff199`／`0099fbc0`）`git cat-file -t` 均为 commit；
  HEAD＝`834ff199`，谱系 `fec93f33 → 2d0929f2 → 124b5533 → 834ff199`。

## 逐项重算

### 项 1 身份（原评审版 ↔ 现行 HEAD 版）——PASS

- `git show 0099fbc0:.tad/hooks/lib/state-surface-check.sh | sha256sum`
  ＝ `d1ac0d7cadefe6c6b0f349974553772f5094f99742578ab800a443a5a111a676`
- `git show HEAD:.tad/hooks/lib/state-surface-check.sh | sha256sum`
  ＝ 同上；工作区同路径文件 `sha256sum` ＝ 同上。三方全等，且与 reland 记录 §2
  自报值逐字一致。
- 字节级 `diff`（0099fbc0 版 vs HEAD 版）输出 0 行。
- `git show --numstat 2d0929f2`：恰 1 文件
  `.tad/hooks/lib/state-surface-check.sh`，`95 0`（+95/−0）✓；
  原笔 `git show --numstat 0099fbc0` 同为该文件 `95 0`，写集形态一致。
- `2d0929f2` 提交信息含 re-land 归因与身份哈希（`git log -1 --format=%B` 核），
  哈希与重算值一致。

### 项 2 复验重跑（亲跑，与 reland-* 日志比对）——PASS

- 组 1 fixture：为守只读纪律，证据目录复制至 `/tmp/r3-g3code/` 后在副本运行
  `g1-fixture-runner.sh <仓内现行脚本绝对路径>`。runner 退出码 **0**，
  五树全 ASSERT-OK（pos exit 0／neg exit 1 恰一条 FAIL check8 指名
  'no lifecycle hooks'／exempt exit 0／outside exit 0／undecidable exit 1
  FAIL check8 指名 'fact-source anchor missing'），尾行 `ALL TREES OK (5/5)`。
  副本 summary 与在盘 `reland-g1-fixture-run.log` **逐字节相同**（diff 空）。
  分树日志与在盘原件 diff 每树恰 1 行——总结行的 repo 路径（副本 /tmp 路径 vs
  原证据路径），系评审运行位置所致，非内容差异；check 行全等。
- 活仓 state-surface：仓根 `bash .tad/hooks/lib/state-surface-check.sh --repo .`
  退出码 **0**；`PASS check8: PAIR-1 governed block carries no stale pattern
  contradicting the fact source` 在场；总结行 `state-surface: PASS (repo: .,
  version 3.2.0)`。全输出与 `reland-live-state-surface.log` **逐字节相同**。
- freshness：`bash .tad/hooks/lib/runtime-freshness-verify.sh . <日期>` 两跑——
  钉死 2026-10-06 与活日期 2026-10-08 均退出码 **1**（BLOCK 在册时的设计值），
  终值行同为 `Total: 31 entries | PASS: 29 | WARN: 1 | BLOCK: 1`；两跑全输出与
  `reland-freshness-pinned-20261006.log`／`reland-freshness-live-20261008.log`
  分别**逐字节相同**。残差集＝codex 两条：`context_compaction`（BLOCK）、
  `trace_evidence_capture`（WARN），台账日期未动。

### 项 3 写集审计——PASS

- `git show --name-status 124b5533`：恰 **16 件**，与任务书清单逐件相符——
  票 1：`M .tad/active/TICKET-20261006-self-review-r3.md`（其 124b5533 版含
  「状态：**CLOSED**」收口节，grep 在册）；
  归档删除 2：`D .tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md`、
  `D .tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3-SUPPLEMENT-1.md`；
  卡 13（全 `A docs/pm/open-cards/`）：done 7（completion-fix-blake／gate3-code／
  gate3-safety／gate4-alex／impl-blake-resume／impl-blake-stop／supp2-alex）
  ＋open 6（completion-fix-blake／gate3-code／gate3-safety／gate4-alex／
  impl-blake-resume／supp2-alex）。与 reland 记录 §4 自报（票 1＋删除 2＋卡 13，
  done 7／open 6）逐项一致。
- `git show --name-status 834ff199`：恰 **2 件**——
  `A docs/pm/open-cards/open-20261008-r3-reland-blake.md`、
  `A docs/pm/open-cards/done-20261008-r3-reland-blake.md` ✓。
- 补落记录本体：`reland-closeout-note.md` ＝ **4,488 B**；章节 §1–§6 齐
  （grep `^## ` 六行在册）；`grep -c 'truncated'` ＝ **0**，无截断标记。
  记录内数值（sha、+95/−0、16 件构成、33 件、6,174 B、freshness 终值）
  经本审逐项重算全部相符，无一虚报。
- 附带核对：评审全程未改动被审面——收口时 `git status --porcelain` 仍仅
  `M docs/pm/status.md`（reland 记录 §5 已定性为非 R3 链内、留 PM 处置，
  非本两笔写集）与两张未跟踪 Gate 3 派发卡（本审与 SAFETY 审的开跑卡），
  与被审方 §4 尾述一致。

### 项 4 组 2 点名复核（只点名）——PASS

- `find g2-borrow4-trial -type f | wc -l` ＝ **33 件**；
  `experiment-report.md` 在册 ＝ **6,174 B**。与 reland 记录 §3.4 自报逐值一致。

## Canonical Gate 3 七项映射

- Code/deliverable complete ✓（项 1＋项 3：实现与链务记录全落现行线）
- §9.1 Spec Compliance ✓（任务书四项即本审规格行，逐行附证据指针如上）
- Evidence files exist ✓（reland-* 日志 5 件＋fixture 日志组＋g2 试验集在盘）
- Evidence replayable（advisory）✓——三项复验由评审亲跑重放，除 fixture 分树
  日志的路径打印行外逐字节复现（见项 2 注记），证据管道确定性成立
- Git commit done ✓（`2d0929f2`／`124b5533`／`834ff199`，哈希已记）
- Knowledge Assessment ✓（reland 记录 §1/§5 即事故与定性知识载体；本审无新发现，
  仅确认：丢失谱系内容的恢复正道是「原对象 sha 身份复核＋逐字节重落」，
  已由被审件完整承载，不另立条目）
- Provenance（advisory）✓（两笔提交信息均含 re-land 归因与来源指针）

## Regression Replay

不触发：被审写集为 `.tad/hooks/lib/state-surface-check.sh`、`.tad/active/**`、
`docs/pm/open-cards/**`，不命中 gate-execution.md 的触发类
（`.agents/skills/**`／`.tad/tasks/**`／`.tad/gates/**`／`.tad/templates/**`／
模型与路由口径文件），故无 scores.md 引用义务。

## 结论

补落的代码与原评审版逐字节同一、四项复验数字经独立重跑全部真实、
两笔（＋卡笔）写集干净且与清单逐件相符。**Gate 3 CODE：PASS。**
余下动作（推送＋证据分支同步）不在本审范围，归 PM。
