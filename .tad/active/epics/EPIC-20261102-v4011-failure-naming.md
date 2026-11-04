# Epic: v4.0.11 — 安装器写失败点名＋回滚提示

**Epic ID**: EPIC-20261102-v4011-failure-naming
**Created**: 2026-11-02
**Owner**: Alex
**Conductor**: Cora
**Approved**: yes — request: "做 4.0.11"; playback confirmed: "确认全部"; stated plan, started without a second question (2026-11-02)
**Budget**: estimate 14 subagent dispatches in all: intake 1, design 1, Gate 2 2, possible spike 1, implementation 1, Gate 3 3, one rework 1, Gate 4 1, distillation 1, release 2
**Depth**: standard — Risk: reversible (until the release, which is confirmed separately); blast radius: `tad.sh` write and rollback output, and every downstream repo that upgrades afterwards

---

## Objective
让安装器失败时说得清原因和现状：写失败点名文件、步骤和系统原因，回滚提示不再自相矛盾；以 v4.0.11 发布，供下游下一次放行使用。

## Requirement
- **失败点名**: 安装器写失败时，日志写明是哪个文件、哪一步（复制、校验、换入等）失败，以及系统给的原因。
- **回滚提示**: 不再出现 `partial`、`failed=0` 和“请手工恢复”同时出现的矛盾；看完就知道项目现在是否完好、还要不要动手、从哪里恢复。
- **发布**: 以 v4.0.11 发到公开仓，发布说明写清楚这版修了什么、还没查明什么。
- **Done check**: 用注入故障分别触发复制、校验、换入失败，每种都能点名到文件和步骤，回滚提示也都明确；4.0.10 的 aw 系列和现有回归继续全绿。独立审查通过。
- **Not wanted**: 不做下一篮的其他内容，也不做回滚清扫提速、心跳进度；不做 `TICKET-20261102-migrate-rescue-atomicity`、`TICKET-20261102-hooks-json-rollback-gap` 两张票；不改发版规程；不替 GM 恢复下游放行。
playback confirmed: "确认全部"

### Q→A log
- (no questions asked: every block was clear from the request and the assessment that preceded it)

### Assumptions (not asked; Gate 4 lists them)
- 校验失败时保留暂存文件：改名保留并在日志里给出路径，方便查根因；目标目录可能多一个残留文件，日志会点名。
- 这版不承诺修好根因：4.0.10 的失败原因还没查明，这版是让下次失败能说清原因。
- 不靠 Mac 复现：现场是 VM 上的 overlayfs，Mac 上复现不出来也不算未完成。

## Result contract

What the human gets: v4.0.11 发布；下次安装失败时，日志点名文件、步骤和原因，回滚提示明确说清项目现状和该怎么办。
Not wanted: 见 `## Requirement` 的 Not wanted 行。
Premise: 4.0.10 在两个仓失败时日志没有原因行，回滚提示互相矛盾（`../阿里巴巴国际站/.tad/evidence/pm/2026-11-02-tad-410-release/apply2-rerun1.log`；`tad.sh` `atomic_install_file` 校验失败无日志）；不论根因是什么，第三次放行都需要这两件事。

### Decisions for the human (settled before "continue")
- 发版、打 tag → 到发布那一步当场问（stop list）。
- 三面回归（Claude Code、Cursor、OpenCode）未跑通时是否带着发 → 到发布那一步当场问。
- 从哪台机器发版 → 到发布那一步带建议问。

## Success Criteria
- [ ] 注入复制、校验、换入失败，日志各自点名文件、步骤和系统原因
- [ ] 每种失败下回滚提示都明确项目现状、是否要动手、从哪里恢复，无矛盾组合
- [ ] 4.0.10 aw 系列和现有回归全绿
- [ ] 独立审查通过；v4.0.11 发布（经用户当场批准）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | 失败点名与回滚提示 | 🔄 Active | .tad/active/handoffs/HANDOFF-2026-11-02-v4011-failure-naming-phase1.md | 安装器失败日志和回滚提示达到 Done check；可发布的 v4.0.11 候选 |

### Phase Dependencies
Single phase.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ Done → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: 失败点名与回滚提示

**Scope**
- 写失败点名：`tad.sh` 里每个框架写点（`atomic_install_file`、`atomic_install_tree` 的建目录与符号链接、pack meta 暂存、`.codex/hooks.json` 暂存、`atomic_stamp_version` 复核）失败时，在回滚开始前打印一行：文件、步骤、系统原因。不经这些写点的 `set -e` 退出（回滚挂在 EXIT trap 上，任何裸命令失败都会触发）也要有兜底行。
- 校验失败保留暂存件：改名保留，日志给路径（`### Assumptions`）。回滚的清扫和整目录恢复会删掉目标目录里的新文件，所以保留件要能活过回滚，日志里的路径才算数。
- 回滚提示：结论来自回滚实际结果，不靠计数拼凑。修三处已知错误：① 运行前就有的 `.tad-backup`、`.tad-migrate-backup.*` 被算进 `preserved`，把结论压成 `partial`（现场日志 `preserved-for-manual-recovery: [.tad-backup ]`）；② 快照条目恢复失败只进 kept 列表，不计入 `failed=`；③ 已消费的备份和 `failed entries: none` 仍出现在 MANUAL-RECOVERY 块里。
- 回归：`aw.*` 与现有回归保持全绿。基线实测（scratch 副本）：当前树 4.0.10 上 aw.1、aw.2、aw.2b、aw.4 均 FAIL（`armed upgrade unexpectedly succeeded`），把暂存版本改成 4.0.9 后五个 aw case 全 PASS。原因是这些 case 写死了 `4.0.10` 和 `4.0.9`；aw.3 在同版本下 PASS，等于没有走升级。`run-all.sh` 的按名列表也没有 aw.*。这些要先修。
- 发布：版本提到 4.0.11，写发布说明，按现行发版规程发到公开仓；发版、打 tag 和 `### Decisions for the human` 三项到发布那一步当场问。

**不做**：`## Requirement` 的 Not wanted 行全部成立。`.codex/hooks.json` 回滚缺口本身不修（`TICKET-20261102-hooks-json-rollback-gap` 的硬约束：不得移出 aw.4 命名集），但提示不能掩盖它（EAC8）。回滚恢复助手（`restore_dir_entry`、`restore_file_entry`）的 stderr 抓取不在范围内，它们已按条目点名。

**Acceptance Criteria**

判据都用 `/bin/bash`（3.2）在同步盘外的 scratch 副本里跑；`tad.sh` 不加任何只为测试服务的分支，故障从 PATH shim 或真实系统条件注入。shim 输出一个每个 case 独有的标记串，日志里出现这个串才算原因来自系统命令，不是写死的文字。

- [ ] EAC1 复制失败：注入 `cp` 失败，日志在 `Installation failed` 之前有一行固定前缀的失败行，含目标相对路径、步骤=复制、标记串原文；不留 `.tad-new.*`。另有一个不用 shim 的真实故障 case（只读目录，uid 0 时报 not-run），原因是系统原文。目标路径含空格和中文时，点名的路径逐字正确；多行错误输出压成一行且不丢内容。
- [ ] EAC2 校验失败：注入暂存件与源不一致，失败行含路径、步骤=校验、`cmp` 给出的差异和两侧字节数。
- [ ] EAC3 换入失败：注入 `mv` 失败，失败行含路径、步骤=换入、标记串原文。
- [ ] EAC4 其他写点：建目录、符号链接暂存或换入、pack meta 暂存、`.codex/hooks.json` 暂存、版本戳复核，这些失败用同一格式点名。建目录和符号链接有 fixture，其余可代码读，完成报告逐点列表。抓取原因不写临时文件（磁盘满时也能用）。
- [ ] EAC5 兜底：不经写点的 `set -e` 退出或信号退出，日志给出最后所处步骤和退出码，并明说没有抓到具体原因，不虚报文件名。
- [ ] EAC6 保留件：校验失败和换入失败后，回滚结束时日志最后点名的保留路径真实存在，内容就是失败的暂存字节；该路径保留失败时（比如改名也失败）日志照实说。故障撤掉后重跑同一安装成功，保留件不让自检失败，也不被当框架文件装进后续备份或校验面。
- [ ] EAC7 提示矩阵：以下场景各有 fixture 断言，每种都打印一段明确的结论：项目现状（完好／完好但有点名例外／未完好）、要不要动手、从哪个路径恢复。场景：sync 失败且预置 `.tad-backup`（现场形状）；备份条目恢复失败（aw.2、aw.2b）；快照条目恢复失败；备份路径不安全；target root 不安全（现在提前退出，没有结果行）；全新安装失败；版本戳失败（aw.4）。对所有场景的日志机械检查：`full` 时无 MANUAL-RECOVERY；有 MANUAL-RECOVERY 时 `failed≥1` 或存在点名例外；`failed=` 计入快照条目；提示给出的恢复路径在结束时都存在；已消费的备份不算恢复来源；块内不出现 `failed entries: none`。现场形状的结论是完好、不用动手，结果行不是 `partial`；aw.2、aw.2b 仍是 `ROLLBACK-RESULT: partial`。
- [ ] EAC8 不掩盖已知缺口：aw.4 的场景（`.codex/hooks.json`、`.tad/brain-index.md` 与运行前不同）下，提示不说无条件完好，而是点名这些例外；`.codex/hooks.json` 确实缺失时给出字节所在的路径。aw.4 命名集不变。
- [ ] EAC9 aw 系列：aw.1–aw.4 不再写死版本号，暂存版本改动后（含提到 4.0.11）是真实升级，当前树和提版后都全绿。除版本来源外，断言不放宽，完成报告给出 case 函数与基线的逐行差异，审查逐行确认。aw.3 不能在同版本下空过。aw.1–aw.4 和新 case 加入 `run-all.sh` 的按名列表。
- [ ] EAC10 全量回归：`TAD_TEST_FULL=1 bash .tad/tests/run-all.sh` 最后一行 `RUN-ALL: PASS`，`release-verify.sh` 的各项发布前检查通过（含 `RM-OK` 标记守卫），与改动前基线对比无新增失败。提版前后各跑一次，日志落盘。
- [ ] EAC11 发布说明：写明修了什么（失败点名、回滚提示）、还没查明什么（4.0.10 两仓失败根因未明，这版只让下次失败说得清；现场在 VM overlayfs，Mac 未复现）、仍开放的两张票。Gate 4 列出 `### Assumptions` 三条。版本号各载体一致（版本正本 `.tad/version.txt`，载体清单按现行发版规程）。
- [ ] EAC12 范围：与基线的差异只落在下面所列文件；两张票的代码路径（migrate 救援拷贝四点、`.codex/hooks.json` 的弃用与再生追踪）、回滚清扫、心跳进度、发版规程、下游放行都没动。独立审查逐项确认。

**Files Likely Affected**
- `tad.sh`（写点、兜底、`rollback_on_failure` 的结论和提示）
- `.tad/tests/installer-data-safety-fixture.sh`（shim 扩展、aw 版本来源、新 case）
- `.tad/tests/run-all.sh`（按名列表）
- 版本载体：`.tad/version.txt` 及现行发版规程列出的其余载体
- `CHANGELOG.md`（顶部仍是 `[4.0.9] - Unreleased`，没有 4.0.10 段；设计步先查明 4.0.10 的说明落在哪）
- `docs/releases/v4.0.11-release.md`（`docs/releases/` 目前到 v4.0.9，同样先核对现行做法）

---

## Run

Pointer: release | ship
Dispatched: rel-ship-1 -> .tad/evidence/yolo/v4011-failure-naming/rel-ship-1-record.md
Next: read the release record; then folder backfill check, 推送 to tad-yun, distillation, completion
Stopped: —
Owner: claude-code 2026-11-02 16:00

---

## Notes

Standing binds for every dispatch of this Epic (`同步与推送.md` outranks AGENTS.md and the protocol's git wording):
- No git command in this folder, no clone or worktree of it. Protocol wording "commit" / "the commits listed" means: the completion report lists every changed file with its sha256, and reviewers read those files.
- Scripts are changed and tested in a copy outside the sync folder (scratch), and copied in only when tested, right before the push (`同步与推送.md` §3). The push is Cora's.
- Do not read or print `.private/`, `.env` or credentials; do not touch the Muse VM, or any downstream repo beyond read-only.

Human rulings during the run (2026-11-02, answers to Cora's stop):
- Done check: the full regression is already red on 4.0.10, so it is judged by "不新增失败": every entry that passed on the baseline still passes, aw and the new cases all pass, and every entry already red is named in the completion report and the release note. This replaces "全绿" and EAC10's `RUN-ALL: PASS`. Answer: "不新增失败".
- Test tree: a throw-away clone of the public repo, outside the sync folder, overlaid with this folder, is allowed for this Epic's tests only. Nothing is committed or pushed from it, and no git runs in this folder. Answer: "这次允许". Exception to `同步与推送.md` "不另外 clone" for this Epic only.

Conductor decisions during the run:
- decided: (2026-11-03, Gate 3 r1) the `4.0.10-to-4.0.11.yaml` hop manifest is added in this phase's rework, not left to the release dispatch (overrides handoff D13). Low-stakes test: reversible file, no money, not outward, result and scope unchanged (AC14 and the "不新增失败" ruling require those 13 entries green), no check weakened.
- decided: (2026-11-03, Gate 3 r1, Up 7) the data-path P1s get one hardening pass in the same rework: the snapshot-incomplete backup label (domain P1-1) and the leftover `.tad-new` ACTION-NEEDED text, plus the open AC5/AC19/AC20 evidence and the missing Knowledge Assessment. Carried, not fixed: rollback ignores signals during a slow sweep (sweep speed is Not wanted).
- Human ruling (2026-11-03, answer to Cora's scope question): widen this release to fix the test suite itself: make the 6 entries already red on 4.0.10 pass, and add a fast mode to the regression so a change can be checked without the ~5-hour full run. Answer: "这次一起修". This replaces "不新增失败" with a green full run as the Done check, and lifts the Not wanted line for these test fixes only (rollback-sweep speed and the two named tickets stay out unless a red cannot be fixed without them; then ask).
- 2026-11-03: Gate 3 r2 run (p1-y6-r2-run) stopped by Cora: the code changes again, so its run was waste. Consistency r2 PASS p0=0 stands for rework 1. Orphan test runs from the reviewers were found still running and killed; scratch trees deleted.
- Human ruling (2026-11-04): Gate 3 r3 is a quick independent check (quick mode, the 6 formerly red entries and the 3 committed-tree entries on a committed clean clone, plus a check of Blake's full-run log); the full regression runs once more on the release tree before the tag. Answer: "快速独立验证". Disk 5.9 GiB free.
- Carried to Gate 4: `tad-update-fixture:release-gates` now runs only with TAD_TEST_RELEASE=1 (release time); full mode not re-run independently.
- Human rulings (2026-11-04, after Gate 4 PASS): release v4.0.11, tag only when the release tree passes everything ("发，全过才打 tag"); release from this Mac in a temporary release clone of the public repo outside the sync folder ("这台 Mac"; exception to "不另外 clone" for this release only); delete the 129 test rollback snapshots ("删掉", done, 655 MB freed). Approval covers public main + tag v4.0.11 only, no other ref, no force.
