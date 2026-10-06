
[0m$ [0mpwd && ls -la && echo "---NEXT---" && cat NEXT.md 2>/dev/null | head -50
/home/box/p3-skeleton-tad
total 572
-rw-r--r--  1 box box     94 Sep 22 11:01 -guard-tmp.log
drwxr-xr-x 23 box box   4096 Oct  6 08:13 .
drwx------  1 box box   4096 Oct  6 08:05 ..
drwxr-xr-x  3 box box   4096 Sep 12 17:07 .agents
drwxr-xr-x  4 box box   4096 Sep 16 21:03 .claude
drwxr-xr-x  2 box box   4096 Oct  6 08:07 .codex
drwxr-xr-x  2 box box   4096 Oct  6 08:07 .cursor
drwxr-xr-x  8 box box   4096 Oct  6 08:12 .git
-rw-r--r--  1 box box   4838 Sep 22 11:02 .gitignore
-rw-r--r--  1 box box    856 Sep 22 11:02 .npmignore
drwxr-xr-x  5 box box   4096 Oct  6 08:07 .opencode
drwxr-xr-x  4 box box   4096 Sep 12 17:16 .reading
drwxr-xr-x  3 box box   4096 Sep 12 17:08 .research
drwxr-xr-x 41 box box   4096 Oct  6 08:07 .tad
drwxr-xr-x  3 box box   4096 Oct  6 08:07 .tad-backup
drwxr-xr-x 40 box box   4096 Oct  6 08:07 .tad.backup.20261006_080747
drwxr-xr-x  2 box box   4096 Sep 12 21:45 .vscode
-rw-r-----  1 box box  12779 Oct  6 08:07 AGENTS.md
-rw-r--r--  1 box box 133495 Sep 22 11:02 CHANGELOG.md
-rw-r--r--  1 box box   7784 Oct  6 03:21 INSTALLATION_GUIDE.md
-rw-r--r--  1 box box   1068 Sep 22 11:01 LICENSE
-rw-r--r--  1 box box  50805 Oct  6 03:21 NEXT.md
-rw-r--r--  1 box box   5029 Sep 22 11:02 OBJECTIVES.md
-rw-r--r--  1 box box  19161 Oct  6 03:21 PROJECT_CONTEXT.md
-rw-r--r--  1 box box  32327 Oct  6 03:21 README.md
-rw-r--r--  1 box box   4043 Oct  6 03:21 ROADMAP.md
drwxr-xr-x  2 box box   4096 Sep 12 22:37 assets
drwxr-xr-x  2 box box   4096 Sep 15 20:58 bin
drwxr-xr-x  3 box box   4096 Sep 12 17:08 codex-tad-bundle
drwxr-xr-x  6 box box   4096 Oct  6 03:21 docs
drwxr-xr-x  3 box box   4096 Sep 12 18:25 experiments
-rw-r--r--  1 box box    448 Oct  6 08:13 p2-closeout.md
-rw-r--r--  1 box box    431 Oct  6 08:13 p2-review-record.md
-rw-r--r--  1 box box      5 Oct  6 08:12 p2-write-target.txt
-rw-r--r--  1 box box   1681 Oct  6 03:21 package.json
drwxr-xr-x  9 box box   4096 Sep 16 21:03 research
drwxr-xr-x  3 box box   4096 Sep 12 17:10 scripts
drwxr-xr-x  3 box box   4096 Sep 12 22:51 supabase
-rwxr-xr-x  1 box box   6298 Sep 22 11:02 tad
-rw-r--r--  1 box box  21533 Sep 22 11:01 tad-intro-feedback.html
-rw-r--r--  1 box box   7426 Sep 22 11:02 tad-intro.html
drwxr-xr-x  7 box box   4096 Sep 12 18:53 tad-work
-rwxr-xr-x  1 box box 130897 Oct  6 03:21 tad.sh
---NEXT---
# Next Steps

> **本文件只放"还没做的"。** 已完成条目一律迁进
> `.tad/archive/next/NEXT-completed-through-YYYYMMDD.md`（逐字保留，可回查）。
> 规矩：**动手前先验一遍条目是否还成立**——2026-08-14 清账时发现
> ②a/②d/②e 三条标着「最高优先级」的待办**早已修复**，清单挂了两周没人划掉，
> 照它找活等于被误导。**清单不准 = 清单有害。**
> 补充（2026-10-04，TASK-20261004 机制 4）：每轮自查以 `git log`/`git status` 对账本文件，条目与 git 现实不符即当场纠偏。

**当前版本**：3.1.0（Epic Phase 2 持续测量层，见完事卡 done-20261006-epic-p2-measurement）→ next：Epic Phase 3 运行时适配补全（提议 v3.2.0） ｜ **默认通道**：full（`/alex` `/blake` `/gate`）｜ lite 🧊 冻结于 2026-08-13

---

## 🔴 优先队列

### 🟡 OPEN 2026-09-16. Codex ledger 高波动面真实重验（Gate 3 R3/C-4 另单，不进 v3.0.0 移除批）

- Task ID: `TASK-20260916-CODEX-LEDGER-REVERIFY` (owner Blake)
- Ticket: `.tad/active/TICKET-20260916-codex-ledger-reverification.md`
- Waiver: `.tad/evidence/reviews/2026-09-16-gate3-rework-r3-waiver.md` (AC21 本批 WAIVED，仅"日期陈旧"子句)
- Scope: codex ledger 12 条（≥6 BLOCK）真实 re-verification（live codex-cli + 官方文档）后刷新日期，恢复 freshness `exit 0`。禁止空 bump；本单动作不进移除批 commit/AC 证据。

### 🟡 PENDING HUMAN CHECK 2026-09-15. TAD Research 机制 (RG1–RG4 wrapper) — Gate 2/3/4 PASS

- Task ID: `TASK-20260915-TAD-RESEARCH-MECHANISM`
- Handoff (tracked): `.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md`
- Completion: `.tad/active/handoffs/COMPLETION-20260915-tad-research-mechanism.md`
- Commit: `f92cbc73` (12 files; 已 push（在 origin/main）)
- Gate 4 PASS: `.tad/evidence/reviews/2026-09-15-gate4-acceptance-tad-research-mechanism.md` (fuse-not-fork; 3人决策点; 14/14 AC; 双平台 cmp=0)
- Human next: CHECK（设计方向 / 三个待定问题 / 是否记为正式机制）→ 通过后 `*accept` 归档。

### ✅ DONE 2026-09-14. OCR K1–K5 optional paste — Gate 4 PASS, archived

- Task ID: `TASK-20260914-OCR-REVIEW-HABITS`
- Handoff & Completion & Gate4: `.tad/archive/handoffs/{HANDOFF,COMPLETION,GATE4}-20260914-ocr-review-habits.md`
- Commit: `c48e5620` (4 §6.2 files; local; do not push/tag/release)
- Gate 4 Evidence: `.tad/evidence/reviews/2026-09-14-gate4-ocr-review-habits.md` (Verdict: PASS; AC1–AC13 recomputed from HEAD; pathspec set-equal; short intent lens holds)
- Human lock held: KEEP K1–K5 optional; REJECT CLI/npm, rule.json SSOT, replacing Gate2/3/Layer2, AACR-Bench KPI. Dual Gate 2 on disk. `layer2-audit.sh` missing `blake/{slug}/` (smoke alarm; not blocking).
- Do not absorb into v2.44.5. No tad.sh change.

### ✅ DISCUSS LANDED 2026-09-14. Thin user story vs AC / Gate3·4 (*research + *discuss, no Blake)

- Evidence: `.tad/evidence/research/2026-09-14-thin-user-story-vs-ac-gate34.md`
- Verdict: **recommend-practice only** for thin slices (who / situation / outcome / non-goals). **Reject** mandatory story format and dual SSOT. Gate3=AC/spec/evidence **consistent**. Gate4 = **AC recompute stays** + optional short intent lens (not intent-only).
- Teeth held: Gate 2 dual; Alex≠Blake. No charter/gate rewrite as locked policy.
- Human next: **lock** before any handoff/Blake. Do not absorb into v2.44.5.

### ✅ DONE 2026-09-13. Skill authoring habits (docs-only L2 + skillify) — Gate 4 PASS, archived

- Task ID: `TASK-20260913-SKILL-AUTHORING-HABITS`

[0m$ [0mfind . -iname "case.md" -not -path "*/node_modules/*" 2>/dev/null; echo "---"; ls .tad/active/ 2>/dev/null; echo "---handoffs---"; ls .tad/active/handoffs/ 2>/dev/null
./.tad.backup.20261006_080747/regression-samples/cases/activation-bypass/case.md
./.tad.backup.20261006_080747/regression-samples/cases/log-absence-misread/case.md
./.tad.backup.20261006_080747/regression-samples/cases/tmp-capture-collision/case.md
./.tad/regression-samples/cases/activation-bypass/case.md
./.tad/regression-samples/cases/log-absence-misread/case.md
./.tad/regression-samples/cases/tmp-capture-collision/case.md
---
TICKET-20260916-codex-ledger-reverification.md
TICKET-20261004-course-judgment-adoption.md
TICKET-20261004-evidence-carrier-recovery-execution.md
TICKET-20261004-maintainer-evidence-branch-revival.md
TICKET-20261005-tad-closeout-batch.md
TICKET-20261006-epic-p1-clearance.md
TICKET-20261006-epic-p2-measurement.md
TICKET-20261006-epic-p3-runtime.md
designs
epics
handoffs
ideas
linear-seed-issues.md
playground
precompact
research
session-state.md
---handoffs---
HANDOFF-2026-10-06-epic-p3-runtime.md

[0m$ [0mls -la /home/box/p3-skeleton-tad/.tad/regression-samples/cases/activation-bypass/; echo "---README/other---"; find /home/box/p3-skeleton-tad/.tad/regression-samples -maxdepth 2 -type f | head -50
total 20
drwxr-x--- 2 box box 4096 Oct  6 03:01 .
drwxr-x--- 5 box box 4096 Oct  6 02:39 ..
-rw-r----- 1 box box 2790 Oct  6 08:07 case.md
-rw-r----- 1 box box 1915 Oct  6 08:07 control.md
-rw-r----- 1 box box  911 Oct  6 08:07 input.md
---README/other---
/home/box/p3-skeleton-tad/.tad/regression-samples/README.md

[0m→ [0mRead .tad/regression-samples/cases/activation-bypass/case.md
→ Read .tad/regression-samples/README.md
→ Read .tad/regression-samples/cases/activation-bypass/input.md
→ Read .tad/regression-samples/cases/activation-bypass/control.md

[0m$ [0mcd /home/box/p3-skeleton-tad && grep -rl "muse-spawn-lint\|开跑卡\|激活自报\|分档声明" .tad --include="*.md" 2>/dev/null | head -30
.tad/archive/handoffs/HANDOFF-2026-10-06-epic-p2-measurement.md
.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md
.tad/regression-samples/cases/activation-bypass/case.md
.tad/regression-samples/cases/activation-bypass/control.md
.tad/evidence/research/2026-09-15-tad-research-mechanism-v01-draft.md
.tad/evidence/reviews/2026-10-05-gate3-safety-review-closeout-batch.md
.tad/evidence/reviews/2026-10-05-gate3-code-review-closeout-batch.md
.tad/evidence/reviews/2026-10-06-gate3-code-review-epic-p2.md
.tad/evidence/reviews/2026-10-06-gate3-code-review-epic-p1.md
.tad/evidence/reviews/2026-10-04-gate3-code-review-state-surface-closeout.md
.tad/evidence/regression-runs/20261006-first-run/outputs/activation-bypass.md
.tad/evidence/regression-runs/20261006-first-run/control-attempt1-fork-contaminated.md
.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md
.tad/evidence/discuss/2026-09-29-agent-eval-vehicle-choice.md
.tad/evidence/completions/COMPLETION-2026-10-06-epic-p1-clearance.md
.tad/evidence/completions/2026-10-06-tad-epic-p3-design-note.md
.tad/evidence/completions/2026-10-06-tad-epic-p2-design-note.md
.tad/evidence/completions/COMPLETION-2026-10-05-tad-closeout-batch.md
.tad/evidence/completions/COMPLETION-2026-10-06-epic-p2-measurement.md
.tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md
.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md
.tad/evidence/epic-p2-measurement-20261006/state-graph-gate-chain.md
.tad/evidence/releases/3.0.2-version-triage.md
.tad/evidence/pm/2026-10-04-tad-self-review-r1.md
.tad/evidence/pm/2026-10-01-mech-absorb-scan/GAPS.md

[0m$ [0mcd /home/box/p3-skeleton-tad && grep -rl "tad_alex\|skill 壳\|薄壳\|目标仓" .tad .agents --include="*.md" 2>/dev/null | head -30
.tad/archive/handoffs/HANDOFF-20260126-multi-platform-init.md
.tad/archive/handoffs/20260126-agent-agnostic-architecture.md
.tad/archive/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md
.tad/archive/handoffs/HANDOFF-2026-10-06-epic-p2-measurement.md
.tad/archive/handoffs/HANDOFF-2026-10-06-epic-p1-clearance.md
.tad/active/epics/EPIC-20261006-tad-self-optimization.md
.tad/eval/judge/bundles/multi-platform-init.md
.tad/decisions/DR-20260712-native-capability-overlap-verdicts.md
.tad/regression-samples/cases/activation-bypass/case.md
.tad/regression-samples/cases/activation-bypass/control.md
.tad/evidence/reviews/2026-10-06-gate3-safety-review-epic-p1.md
.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md
.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md
.tad/evidence/reviews/2026-10-04-gate3-safety-review-course-judgment-adoption.md
.tad/evidence/reviews/2026-10-06-gate2-tech-review-epic-p1.md
.tad/evidence/reviews/2026-10-04-gate4-acceptance-course-judgment-adoption.md
.tad/evidence/regression-runs/20261006-first-run/outputs/activation-bypass.md
.tad/evidence/regression-runs/20261006-first-run/scores.md
.tad/evidence/regression-runs/20261006-first-run/control-attempt1-fork-contaminated.md
.tad/evidence/completions/2026-10-04-tad-phase3-anchor-gate2-fit-note.md
.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-push-note.md
.tad/evidence/completions/2026-10-04-tad-evidence-recovery-impl-resume-note.md
.tad/evidence/completions/2026-10-06-tad-self-optimization-epic-design-note.md
.tad/evidence/completions/2026-10-06-tad-epic-p3-design-note.md
.tad/evidence/completions/2026-10-06-tad-epic-p2-design-note.md
.tad/evidence/completions/2026-10-06-tad-epic-p1-design-note.md
.tad/evidence/pm/2026-10-05-gm-input-driftcheck-registry-only.md

[0m$ [0mcd /home/box/p3-skeleton-tad && grep -n "开跑卡\|激活自报\|分档\|spawn-lint\|薄壳\|目标仓" .tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md | head -40
230:2. 脚本化全链会话（无头、非交互、单条命令可复跑）：给运行时一条固定任务书（文件头写死逐字文本，落 raw/）：在骨架仓内 (a) 完成激活动作（读 AGENTS.md 并输出激活自报行）；(b) 执行一个有界写任务（新建一文件＋改一文件，触发写点位）；(c) 产出一份 Gate 证据形态件（对 (b) 的 diff 写一份评审记录）；(d) 写一份收口形态件（完工说明骨架）。命令面：Codex `codex exec`、OpenCode `opencode run`、Cursor `agent -p`（均在 grokbox 以二进制绝对路径或仓内包装等价面执行，命令原文逐字记入 transcript 的原始输出指针件）。
512:- **设计时基线（2026-10-06 只读 detect-only 亲测）**：对现行树跑 `bash .tad/hooks/lib/release-verify.sh version "$PWD" 3.2.0 3.1.0` → **56 hits／31 文件**（Phase 2 设计时同口径为 25 hits／20 文件；增量主因＝docs/legacy 与 archive 面的 3.1 字面量随时间累积入检面，以及 P2 链自产开跑卡/完事卡入面）。分类预估：
514:  - **H/D 类约 28 hits**（已发生事件陈述/归档面，预估豁免，仍须逐行落分诊依据）：docs/legacy×17（5 文件）、tad-work/archive×2、scripts/archive×2、P2 链开跑卡/完事卡×4、docs/legacy 内旧升级脚本与报告余项。

[0m$ [0mcd /home/box/p3-skeleton-tad && cat .tad/evidence/regression-runs/20261006-first-run/scores.md 2>/dev/null | head -60
# scores — regression run .tad/evidence/regression-runs/20261006-first-run

- 执行通道： internal-subagent
- 模型： Muse Spark 1.3 (Muse Spark)
- 耗时： 同会话实施内完成，未单独计量

case: activation-bypass
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 4 (max 1)
verdict: INVALID (control 4 > 1)
---
case: tmp-capture-collision
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 5 (max 1)
verdict: INVALID (control 5 > 1)
---
case: log-absence-misread
discriminative_hits: 4 (min 3)
must_not_hits: 0
control_hits: 3 (max 1)
verdict: INVALID (control 3 > 1)
---
整轮 verdict: FAIL（失效案： activation-bypass tmp-capture-collision log-absence-misread）

## 失败原因与对照通道实况（执行者附注，不改上方机械值）

- 三案 INVALID 的同一原因：对照（control.md）并非裸捕获。首选通道为 fork 型原生 subagent（只给三段 input 材料），其回答引用了 input 之外的上下文事实——案一答出薄壳 skill 名、激活闸工具名与九项口径；案三答出配对交换端点、假令牌实测回码与一次性链接 TTL 数值——皆不在所给材料内。该通道继承派发方会话上下文（含席位常驻文件），结构上不提供上下文隔离；原捕获整件留存为同目录 control-attempt1-fork-contaminated.md，冻结入样本集的即此件，来源不隐瞒。
- 备援通道核查（同日）：VM 侧 opencode 直跑最小探针 90 秒超时（RC=124，后端 stall，与本机 egress 抖动旧况一致）；codex 包装拒绝仓外目录、其仓内目录又落入席位文件祖先链。两路未产出可用裸答；同环节多次失败即停，未再重试。
- 被测侧三案自身：判别命中 5/5/4（≥3）、must_not 命中全 0——除对照项外均满足 PASS 条件。
- 处置呈交 Gate 3/PM 裁断：本轮 INVALID 的归因是捕获通道而非样本判别力；§4.1 的定式补救（换更判别性的标记）针对的是真裸对照下的失效，套用于污染对照会反过来腐蚀样本，故本席不自行改标记。建议第二跑以真隔离通道（grokbox 侧裸跑或后端恢复后重捕）重建对照基线后复评三案。

**不可直接派发。** 这是一份以 PM 手选文件清单冒充激活包的任务书，缺项如下：

1. **未走 skill 壳激活**：任务书没要求加载 `tad_alex` 角色 skill 并按其激活协议进入目标仓（gm 仓）读原件。「加载 skill＋目标仓 `$REPO`＋激活自报」三件缺一，激活不成立。
2. **手选清单替代原件装载（结构性错误）**：第 1–5 项是 PM 预先筛好的阅读清单，还要求「读完后直接开始评估」。规程原件必须由 Alex 按 skill 激活协议**进目标仓自行读取**——转述/摘要/手选包再长也与薄指令同病，不能替代原件装载。
3. **无激活自报要求**：未要求 Alex 开工前回报激活自报，收口验收无自报可查。
4. **无分档声明**：缺 `tad_scope`、`tad_basis`、`step_kind` 三行。
5. **无开跑卡**：缺项目名、Epic 位置、role、任务名、channel、model、env、目的等字段；原生通道 channel 应填 `internal-subagent`，model 与 env 须给完整明确值。开跑卡须先发属主对话再 spawn，任务书未写。
6. **未过激活闸**：任务书未落成文件并跑 `muse-spawn-lint.sh` 校验 PASS；未 PASS 不许 spawn。
7. **判据不完整**：未指明本步对应哪个 Gate、由谁判、通过标准是什么。「评估维度：故障模式、承载量、替代结构」＋「须含结论与建议」≠ Gate 判据。
8. **证据落盘路径不具体**：只写「落盘到 gm 仓证据目录」，未给明确的证据落盘路径。
9. **纪律件缺失**：未写角色分离与禁止事项、状态自检恢复、记忆权威边界；「字节数自报」不能替代盘上验收，自报须经 PM 盘验核对。

补齐上述项、任务书按模板落盘并通过 spawn lint 后方可派发。
