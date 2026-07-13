---
name: project_surplus-burn-mode
description: "*surplus mode — finds + ranks highest value-density backlog work to consume surplus Claude usage; Phase 1 done, Phase 2 (auto-exec) pending"
metadata: 
  node_type: memory
  type: project
  originSessionId: 99e32f50-0a54-4935-9d1d-8574fc6c2c40
---

`*surplus` mode (EPIC-20260607-surplus-burn-mode) — turns unused weekly Claude usage into reviewed deliverables by finding the highest **value-density** backlog work. User's own request 2026-06-07 (surplus usage, wants Alex to auto-find + auto-burn on valuable work, YOLO).

**Design locked (Socratic):** value-first (NOT token-burn theater); sources = backlog + Alex-generated directions + research/self-evolution (NOT cross-project); full-auto batch → digest; budget = invocation-time param (`*surplus +2M`).

**Phase 1 DONE 2026-06-08** (commits d3dbc32, 6776d85, b51bc54; YOLO Conductor build):
- `.claude/workflows/surplus-scan.workflow.js` (scan parallel readers → generate downstream → rank plain-JS), `surplus` SKILL (`--plan` scan-only), `surplus-plan-template.md`, `*surplus` in alex commands.
- Ranking: expected_value = value×confidence, sort exp_val DESC then density tiebreak; auto_eligible = safe AND value≥3 AND source≠generated; mechanical SAFETY path-match OR agent flag; JSON sidecar = Phase-2 contract.
- Live run: 53 ranked candidates (24 auto-eligible / 19 needs-human / 0 vacuous) → `.tad/active/SURPLUS-PLAN-2026-06-08.md` + `.json`.

**Phase 1.1 (quick-fix, before Phase 2):** `undated` filename bug — `date`/`output_path` args didn't propagate to workflow; robust fix = SKILL owns output filename. AC1 `node --check` invalid for all workflows.

**Phase 2 (pending):** `surplus-execute.workflow.js` budget loop (budget.remaining()) + safety routing + yolo-epic per-task + dogfood. JSON sidecar ready.

**Key lesson:** 4 expert reviews passed but live run caught 2 real bugs (top-level-array schema→API 400; `Workflow({name:})` loads STALE cached copy, must use `scriptPath` to test fresh edits). Validation theater — only live workflow run is ground truth. See [[feedback_pick-generative-directions]].

**2026-07-05/06 大规模实战 (8 workflow runs, ~6M tokens, 撞限额×2):** 5 真交付 + 4 个 P0 拦停。
**Why:** 三个结构性发现，未修前每次 burn 都会踩:
1. **yolo-epic worktree false-FAIL**（踩 3 次）: implement 在 worktree 里跑，impl reviewer 看主 repo → 每个 worktree 隔离任务都被误判 "implementation absent"。交付物要去 `.claude/worktrees/wf_*-N/` 找。
2. **surplus-execute "executed" ≠ review PASS**: yolo-epic 无 error 即计 executed，无视 impl_review_p0_count → Conductor 必须亲验 verdict。
3. **P0 修复也会被 round-2 review 抓出新缺陷**（AC13 单位错配、sed 配方 bug）——2 reviewer 独立收敛 = 真缺陷非通胀；修 AC 前先实测 baseline 判别力。
**How to apply:** 续跑照 `.tad/active/session-state.md` QUEUE（暂停于 2026-07-06，新计费周期）；脚本存 `.tad/evidence/surplus-burn-20260705/scripts/`（resumeFromRunId 跨 session 无效，从脚本重拉）；先合并 4 个 worktree 交付物再跑新任务。
