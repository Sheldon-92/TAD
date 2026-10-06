
→ Read AGENTS.md

$ ls -la /home/box/p3-skeleton-tad
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

→ Read .tad/brain-index.md
→ Read .tad/project-knowledge/principles.md
→ Read .tad/project-knowledge/patterns/_index.md

$ find /home/box/p3-skeleton-tad -iname 'case.md' 2>/dev/null; echo '---'; ls -la /home/box/p3-skeleton-tad/.tad/evidence 2>/dev/null
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/activation-bypass/case.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/log-absence-misread/case.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/tmp-capture-collision/case.md
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/activation-bypass/case.md
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/log-absence-misread/case.md
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/tmp-capture-collision/case.md
---
total 380
drwxr-xr-x  56 box box  4096 Oct  6 08:12 .
drwxr-xr-x  41 box box  4096 Oct  6 08:07 ..
-rw-r--r--   1 box box  8689 Sep 22 11:07 2026-09-13-alex-discuss-release-minor.md
-rw-r-----   1 box box 11175 Oct  4 16:35 2026-10-04-gate4-platform-adapters-pre-rewrite-copy.md
-rw-r--r--   1 box box  1169 Sep 22 11:01 README.md
drwxr-xr-x 131 box box 12288 Sep 13 06:38 acceptance-tests
drwxr-x---   2 box box  4096 Oct  4 23:29 activation-packages
drwxr-xr-x   2 box box  4096 Sep 12 20:25 audits
drwxr-x---   2 box box  4096 Oct  5 13:36 closeout-batch-20261005
drwxr-xr-x   3 box box  4096 Sep 12 23:21 codex-regression
drwxr-xr-x   4 box box  4096 Sep 12 19:37 codex-validation
drwxr-xr-x  21 box box  4096 Oct  6 03:36 completions
drwxr-xr-x   2 box box  4096 Sep 12 23:46 decisions
drwxr-xr-x   5 box box  4096 Oct  6 03:03 designs
drwxr-xr-x   2 box box  4096 Sep 29 21:44 discuss
drwxr-xr-x   2 box box  4096 Sep 12 23:17 dogfood
drwxr-xr-x   2 box box  4096 Sep 12 21:54 dual-platform-regression
drwxr-xr-x   3 box box  4096 Sep 12 19:51 e2e
drwxr-x---   2 box box  4096 Oct  6 01:24 epic-p1-clearance-20261006
drwxr-x---   2 box box  4096 Oct  6 03:18 epic-p2-measurement-20261006
drwxr-xr-x   2 box box  4096 Sep 12 22:57 eval
drwxr-xr-x   3 box box  4096 Sep 12 18:24 experiments
drwxr-xr-x   7 box box  4096 Sep 12 23:47 fixtures
drwxr-xr-x   2 box box  4096 Sep 29 22:08 gate4
drwxr-xr-x   3 box box  4096 Sep 12 21:25 gates
drwxr-xr-x   2 box box  4096 Sep 12 22:22 handoff-reviews
drwxr-xr-x   4 box box  4096 Sep 12 17:15 handoffs
drwxr-xr-x   3 box box  4096 Sep 12 17:09 hooks
-rw-r--r--   1 box box  5775 Sep 22 11:02 hw-circuit-tools-registry-additions.yaml
-rw-r--r--   1 box box  5981 Sep 22 11:02 hw-firmware-tools-registry-additions.yaml
drwxr-xr-x   2 box box  4096 Sep 29 22:02 impl
drwxr-xr-x   3 box box  4096 Sep 12 23:17 journal
drwxr-xr-x   2 box box  4096 Sep 12 21:57 knowledge-migration
-rw-r--r--   1 box box  5593 Sep 22 11:02 knowledge-redesign-p4-e2e-validation.md
-rw-r--r--   1 box box  3861 Sep 22 11:02 knowledge-redesign-p4-migration-report.md
-rw-r--r--   1 box box  4530 Oct  4 23:25 knowledge-usage-log.jsonl
drwxr-xr-x   2 box box  4096 Sep 12 20:08 learnings
drwxr-xr-x   3 box box  4096 Sep 12 17:09 maintenance
-rw-r--r--   1 box box    26 Sep 22 11:01 memory-distill-cursor
-rw-r--r--   1 box box  5414 Sep 22 11:01 memory-migration-sensitivity-report.md
drwxr-xr-x   2 box box  4096 Sep 12 21:36 metrics
drwxr-xr-x   2 box box  4096 Sep 12 22:10 overrides
-rw-r--r--   1 box box    84 Oct  6 08:12 p2-writenote.md
drwxr-xr-x   3 box box  4096 Sep 12 23:42 pack-dogfood
drwxr-xr-x   4 box box  4096 Sep 12 17:09 pack-eval
drwxr-xr-x   3 box box  4096 Sep 12 21:59 pack-quality
drwxr-xr-x   2 box box  4096 Sep 12 23:25 pack-system-unification-phase1
drwxr-xr-x   2 box box  4096 Sep 12 19:51 pack-system-unification-phase2
drwxr-xr-x   2 box box  4096 Sep 12 22:54 pack-system-unification-phase3
drwxr-xr-x   2 box box  4096 Oct  6 08:07 pair-tests
drwxr-xr-x   2 box box  4096 Sep 12 18:47 patterns
-rw-r--r--   1 box box 17125 Sep 22 11:02 phase2b-integration-test.md
-rw-r-----   1 box box 14086 Oct  4 17:31 phase3-census.md
-rw-r-----   1 box box  3433 Oct  4 18:51 phase3-first-chain.md
-rw-r-----   1 box box  4041 Oct  4 17:31 phase3-inflight-chains.md
drwxr-xr-x   8 box box 12288 Oct  6 03:37 pm
drwxr-xr-x   4 box box  4096 Sep 12 17:13 poc
drwxr-xr-x   2 box box  4096 Sep 12 21:11 project-logs
drwxr-xr-x   2 box box  4096 Oct  4 20:19 ralph-loops
drwxr-x---   3 box box  4096 Oct  6 03:00 regression-runs
drwxr-xr-x   2 box box  4096 Sep 15 22:03 release
drwxr-xr-x   2 box box  4096 Oct  6 03:23 releases
drwxr-xr-x  49 box box  4096 Oct  4 18:16 research
drwxr-xr-x   8 box box 20480 Oct  6 03:40 reviews
drwxr-x---   2 box box  4096 Oct  6 03:43 risk-cards
drwxr-xr-x  17 box box  4096 Sep 12 21:48 spikes
drwxr-xr-x   4 box box  4096 Sep 12 17:15 surplus-burn-20260705
drwxr-xr-x   2 box box  4096 Sep 12 22:42 surplus-plans
drwxr-xr-x   3 box box  4096 Oct  6 08:12 traces
drwxr-xr-x  26 box box  4096 Sep 12 17:15 yolo
drwxr-xr-x   2 box box  4096 Sep 12 22:04 yolo2-baseline

$ ls -la /home/box/p3-skeleton-tad/.tad/regression-samples/cases/tmp-capture-collision/; echo '==='; ls -la /home/box/p3-skeleton-tad/.tad/regression-samples/cases/
total 20
drwxr-x--- 2 box box 4096 Oct  6 03:01 .
drwxr-x--- 5 box box 4096 Oct  6 02:39 ..
-rw-r----- 1 box box 2345 Oct  6 08:07 case.md
-rw-r----- 1 box box  921 Oct  6 08:07 control.md
-rw-r----- 1 box box  725 Oct  6 08:07 input.md
===
total 20
drwxr-x--- 5 box box 4096 Oct  6 02:39 .
drwxr-x--- 3 box box 4096 Oct  6 03:02 ..
drwxr-x--- 2 box box 4096 Oct  6 03:01 activation-bypass
drwxr-x--- 2 box box 4096 Oct  6 03:01 log-absence-misread
drwxr-x--- 2 box box 4096 Oct  6 03:01 tmp-capture-collision

→ Read .tad/regression-samples/cases/tmp-capture-collision/case.md

$ ls -la /home/box/p3-skeleton-tad/.tad/tasks/ 2>/dev/null; echo '---'; ls /home/box/p3-skeleton-tad/.tad/evidence/pm/ | grep -i '2026-10-06' 
total 80
drwxr-xr-x  2 box box  4096 Oct  5 13:31 .
drwxr-xr-x 41 box box  4096 Oct  6 08:07 ..
-rw-r-----  1 box box 12428 Oct  6 08:07 evidence-collection.md
-rw-r--r--  1 box box 10487 Oct  6 08:07 gate-execution.md
-rw-r--r--  1 box box  7774 Oct  6 08:07 handoff-creation.md
-rw-r--r--  1 box box 11711 Oct  6 08:07 parallel-execution.md
-rw-r--r--  1 box box  7017 Oct  6 08:07 release-execution.md
-rw-r--r--  1 box box 12335 Oct  6 08:07 requirement-elicitation.md
---
2026-10-06-epic-p1-ac23-ruling.md
2026-10-06-epic-p1-gate2-merged-ruling.md
2026-10-06-epic-p2-check4-ruling.md
2026-10-06-epic-p2-design-rulings.md
2026-10-06-epic-p2-first-run-ruling.md
2026-10-06-epic-p2-gate2-merged-ruling.md
2026-10-06-epic-p2-gate3-ruling.md
2026-10-06-epic-p3-design-rulings.md
2026-10-06-input-pointer-seat-name.md
2026-10-06-qualify-techradar-refresh-two-points.md
2026-10-06-tad-sweep-proposal-judgment.md

✱ Grep "Capture Path Discipline" in .tad · 2 matches

$ grep -n 'C1\|串台\|覆写\|mktemp\|唯一' /home/box/p3-skeleton-tad/.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md
19:- **C1 采纳（测量层批头条）**。命名回归样本集与本席自查 P4 同向且更成型：真实失败例（激活失守、S6 串台、日志误判）固化为可复跑样本，规程/模型/技能变更时回放。素材现成是真优势。
20:- **C2 缓（第二阶段）**。失败聚类与趋势行须等 C1 产出数据后再设计，先立为空转。
55:- **测量层批**（新立意向，待用户排期）：C1（头条）、C3、C4、D5（先导演练）、C2（第二阶段）、B2（设计时评估）、C6 前置口。

→ Read .tad/tasks/evidence-collection.md [offset=270, limit=80]
→ Read .tad/regression-samples/cases/tmp-capture-collision/control.md
→ Read .tad/regression-samples/cases/tmp-capture-collision/input.md
有问题，不能照此执行。

**风险点名**：两席位在同一波次、同一台 VM 上并行执行，却把捕获重定向到同一个固定路径 `/tmp/align-full.log`。后写席位的输出会**覆写**先写席位的捕获；先席随后按 check/apply 拆分落盘时，实际拆到的是他席输出，于是完工报告引用的是**串台**后的他人计数与结论——数字侥幸对得上，证据却与盘上本席实存不符。（规程 `.tad/tasks/evidence-collection.md` §Capture Path Discipline 有 2026-10-04 S6 同名覆写导致证据全错的实证；同一纪律也要求拆分/引用前须与盘上实存交叉核对。）

**改法**：捕获一律落到**唯一路径**，不用固定名。两席各用各自唯一的捕获文件。

我将使用的捕获命令：

```bash
SEAT="$(hostname)-$$"                       # 本席唯一标识
LOG="$(mktemp "/tmp/align-full.${SEAT}.XXXXXX.log")"
bash align-install.sh --full > "$LOG" 2>&1
echo "$LOG"                                  # 记录本席实际捕获路径
```

等价的替代形态是把捕获**直接落到本仓证据目录**下含本席/本步标识的唯一文件名（如 `.tad/evidence/<task>/align-full.${SEAT}.log`），再按 check 段与 apply 段拆分成各自唯一名落盘。

拆分或引用前，仍须先核对该捕获与盘上本席实存（时间戳/计数/哈希）一致，不一致即弃用重捕，不得把未验源的捕获作为证据引用。
