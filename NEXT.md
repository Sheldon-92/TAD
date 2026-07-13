# Next Steps

- [x] **PUBLISHED v2.34.0 — 2026-07-13 (Native Capability Adoption + Session Continuity)** — 45 commits pushed to origin/main + annotated tag v2.34.0. Pre-publish gates ALL CLEARED: parity PASS (after shipping the queued local/-exclusion fix, code-reviewer MERGE 0 P0/P1), version + version-sweep + migration PASS, 84-file sensitivity scan CLEAN-TO-COMMIT, pack registry regenerated (25 packs). Distribution decision recorded: `.claude/agents/` + `.claude/rules/` = **main-repo-only** (invisible to both distribution channels by decision; revisit when pilots mature). Downstream projects pull via install command (no *sync — pull-based policy). Remaining small queue: /advisor degraded-tier wiring; parity concurrency guard (local/ part shipped); yolo-execution-protocol.md L33 args-claim fix; P2-b comment nit (parity "never mirrored" wording, cosmetic); driftcheck advisory: 11 installed packs lack .tad/capability-packs source (pack-factory class, pre-existing).

## In Progress

- [x] **EPIC: Native Capability Adoption Wave ✅ COMPLETE 4/4 + ARCHIVED 2026-07-13 (full YOLO, single session; audit-yolo PASS 50/50)** — merges abca584(P1)→bf51be4(P2)→0f14d18(P3)→0b947a5(P4), NOT pushed. Scoreboard: 4 ideas LANDED (PreCompact snapshot hook + post-compact reminder; headless weekly-scan capability incl CRON-FIRE-VERIFY PASS; .claude/rules pilot LOADED — shell-portability.md live; preview_usage_rule in *design protocol) + 2 BLOCKED-UNTIL CLI upgrade (reviewer memory / skills preload — spike proved both frontmatter fields INERT on 2.1.172; byproduct shipped: spec-compliance-reviewer as first project-level registered agent + fm-lint.sh). 6 native-runtime ground truths established, 3 falsified doc-level research (memory/skills inert; durable cron not honored; GH #17204 wrong — paths: works). 2 new L2 patterns (ac-verification: dry-run every AC on live host — 2/3 designed phases had P0 AC-runnability defects; research-methodology: doc-research is hypothesis, spike is ground truth). Report: `.tad/evidence/yolo/native-capability-adoption/EPIC-COMPLETION.md`. **Human follow-ups:** (a) ~~AC2a real-compact evidence~~ ✅ CLOSED 2026-07-13 11:50 — real /compact fired hook on 2.1.207: stdin spellings confirmed (+bonus `prompt_id`), session_id STABLE across boundary, post-compact reminder delivered live, snapshot fields true (T1-answers.md closure addendum); Phase 1 has ZERO pending items; (b) *publish 前裁决 `.claude/agents/` + `.claude/rules/` 分发策略（两者对 derive-sync-set 和 tad.sh 拷贝都不可见,推荐 main-repo-only）; (c) ~~CLI 升级 re-spike + skills-preload delivery~~ ✅ **DONE 2026-07-13 (full arc: PASS-provisional → REFUTED-headless → AC1b decisive PASS-harness)**: `memory` STILL INERT (BLOCKED unchanged). `skills` FINAL VERDICT = **harness-path-only capability on 2.1.207**: WORKS via interactive Agent-tool spawn (pack arrives as command block at spawn; discriminative pair w/ no-skills negative control), INERT via headless `claude -p --agent` (6/6 FAIL) and ≤2.1.172. HANDOFF-20260713-skills-preload-delivery DONE + archived: `.claude/agents/security-auditor.md` MERGED (`skills: [code-security]` static preload, byte-copy body, budget note). GATE3-SPEC PASS 9/9 (spec-compliance-reviewer first production run). Probe-design lessons locked in spike-report ADDENDUM #2+#3: ban `Skill` tool in preload probes; `--disallowedTools` comma-form mis-parses (use space-separated + stdin); spawn PATH is a mandatory dimension of native-capability verdicts. durable cron NOT re-tested (low value, watchdog in place); (d) 周扫描:会话 cron 随会话死,靠 STEP 3.9 staleness 警告或用 cron-prompt.md 重注册。
- [x] **memory-redirect-capture-layer ✅ ACCEPTED + ARCHIVED 2026-07-12** (commits 7fbe24e + c7682e2 NOT pushed; Gate 3 PASS 3 distinct reviewers; Gate 4: all quantitative ACs independently recomputed by Alex — identical; trajectory judge advisory 5/5/5/5/4 avg 4.8; D1 amendment CONFIRMED by user: selective-git, 7 SENSITIVE gitignored, all classifications approved) — auto-memory now writes to `.tad/memory/` (Capture layer); **first full distillation sweep DONE same session: 42 items → 9 new L2 entries** (gate-design +1, ac-verification +2, memory-and-learning +2, handoff-design +1, pack-build-rules +2, NEW patterns/release-sync.md +1), sweep report `.tad/evidence/research/memory-distill-sweep-2026-07-12.md`. **Pending follow-ups:** (a) ~~AC8~~ ✅ VERIFIED 2026-07-13 post-restart (system-prompt memory path = .tad/memory/, old dir frozen at 36, settings in place — conditional accept now unconditional); (b) global parity re-run MUST PASS before *publish (concurrent-terminal friction); (c) bugfix handoff: release-verify.sh parity --fix exclude local/ + concurrency guard (journal Q3 + E6); (d) yolo-execution-protocol.md L33 still claims Workflow args injection works — contradicts E2, needs protocol fix; (e) user may prune 3 STALE memories via /memory (auto-evolve-epic, domain-pack-design, quality-chain-failure P0 flag) + 1 dead MEMORY.md index row (conductor-architecture) — TAD side is read-only on memory dir by contract; (f) brain-index regen OK on inspection (22:38 stamp, Release & Sync row present) — script exit code misleadingly non-zero, minor script hygiene item. Handoff+COMPLETION archived. Implements DR-20260712 verdict 1.
- [ ] **Native Capability Overlap ROUND 2 — 4 more verdicts + 6 ideas captured 2026-07-12 evening** — DR-20260712 amended with round-2 section: A1 keep session-state (PreCompact hook pilot first, then revisit §4.5 slimming); A2 **/advisor adopted as degraded tier** of adversarial challenge, priority Codex/Gemini > /advisor > auto-PASS (NEEDS small handoff: research-plan-protocol.md Phase 0c/4c/5b UNAVAILABLE branch); A3 /verify pilot at next runnable-artifact handoff (same observation batch as /code-review pilot); A4 native tasks vs NEXT.md = zero-action (division already natural). B-group captured as `.tad/active/ideas/IDEA-20260712-*.md` ×6 — **ALL 6 PROMOTED 2026-07-12 into EPIC-20260712-native-capability-adoption (see In Progress top entry)**. Research gaps remain: Codex-side memory, skill-creator comparison (re-ask notebook b07a6598).
- [ ] **Native Capability Overlap — RESEARCH + VERDICTS DONE 2026-07-12, 5 follow-up actions queued** — Deep research (*research --deep, complex tier): notebook `claude-native-capabilities` (b07a6598, 23 sources incl first-party Fable 5 harness introspection) + TAD 112-mechanism inventory + factual overlap matrix (`.tad/evidence/research/claude-native-capabilities/2026-07-12-overlap-matrix.md`). Verdict discussion (*discuss) → DR-20260712-native-capability-overlap-verdicts.md: ① memory redirect into TAD as Capture layer (autoMemoryDirectory → .tad/memory/, distillation loop gains 2nd source) → NEEDS HANDOFF; ② /code-review pilot as one Layer-2 distinct-reviewer vote in next 2-3 code handoffs (deep-research/plan-mode bans stay); ③ agent teams: no migration, document TAD's increment in value-proposition (feeds O1); ④ keep Pack≤2 guardrail + adopt disable-model-invocation for low-freq packs + fold agent-verifier hooks into gate-roi considerations. Caveat: matrix NOT adversarially challenged (Codex auth expired + Gemini no key) — verify facts during implementation. Known gaps: Codex-side memory, skill-creator plugin comparison (notebook can be re-asked).

- [x] **Surplus Burn wind-down — ✅ FULLY CLOSED 2026-07-12 (user-directed final closure; active/ handoffs+epics now EMPTY)** — Full record: `.tad/active/session-state.md`. DONE 2026-07-12: 4 deliverables merged (repositioning 7d03d96 + save-workflow e62c7b4 + save-skill 259b0e6 + .agents mirror b12e518; tad.sh glob-arm fix salvaged from forgotten 07-02 dogfood worktree — closes Deferred item); 4 completed handoff sets archived; 3 handoffs cancelled with taxonomy (o1-landscape pivoted / tad-self-test scope-change / session-health-check obsolete); 6 worktrees removed. NEW PRIORITY ORDER: ① gate-roi-measurement — ✅ ACCEPTED + ARCHIVED 2026-07-12 (commit ca66e85, Gate 4 human-confirmed): **net-positive → GO** — 27-sample catch-agnostic frame, STRICT pre-registered rule cleared at NC%=63% (bar 25%) / P01=91; 6/27 zero-catch rows; dual-blind FR8 9/10; cost side unmeasured by design → follow-on = cost-side measurement then revisit 2026-04-15 mechanical-enforcement; report `.tad/evidence/research/gate-roi-measurement-2026-07.md`; new L2 pattern Dual-Blind Disjoint-Row Spot-Check → ② skill-body-reference-boundary ✅ CLOSED 2026-07-12 (3dbaa5f — re-audit found 0 circular-trigger regressions across 31 refs, 3 must-body confirmed inlined; real gap was verifier coverage → skill-body-verify.sh extended to alex, mutation-tested) → ③ small real-debt fixes ✅ 4/5 CLOSED 2026-07-12 (deprecate → 9 packs migrated 8b986db; detect-state fixture c42fa2f; multi-table-parser c42fa2f; classify-scope CLOSED-STALE — function retired with dream-scanner; REMAINING: express-frontmatter marker) → ④ ready-shelf handoffs when picked (tad-methodology-skeleton [re-read vs new O1 first] > pack-behavioral-examples-scaffold [staleness-check first — pack-dogfood may cover 80%] > codex-adapter-yaml [+9 new packs if run]). Dropped: 18-casualty batch relaunch (synth filler). System lessons: yolo-epic worktree-visibility ✅ FIXED d834c4d (implRoot-aware reviewers + UNVERIFIABLE-not-absent fallback, review PASS 0 P0/P1); Workflow args quirk → close as external-documented (platform bug, workaround stable in memory); surplus-execute p0-count threading → dormant until surplus mode revived. FINAL CLOSURE 2026-07-12 (user-directed): 3 ready-shelf handoffs CANCELLED with taxonomy (codex-adapter-yaml pivoted / pack-behavioral-examples superseded by pack-dogfood+eval-gates / tad-methodology-skeleton pivoted — redesign vs new O1 if universal-method direction activates); cost-side measurement DECIDED-NOT-TO-DO (number feeds no live decision — 2026-04-15 rejection was hook-lockout reliability, not review token cost; escape-rate accumulates automatically via gate-roi-report.sh; revisit only if escape data shows gate-SKIPPING or TAD goes multi-user); plan artifacts relocated to .tad/evidence/surplus-plans/ + surplus-burn-20260705/plans/. Sole surviving micro-item: express-frontmatter marker (Deferred, cheap hygiene).

- [x] **EPIC: Surplus Burn Mode ✅ COMPLETE 2026-07-02 (Phase 1 scan + Phase 1.1 fix + Phase 2 execute, all Gate 4 PASS)** — `*surplus --plan` scans 53 backlog candidates → `*surplus +<budget>` auto-executes top safe-to-YOLO tasks within budget envelope (250K reserve, circuit breaker 3x, SAFETY → needs-you). Dogfood: detect-state-glob-arm-hazard executed end-to-end (7 agents, ~50K tokens, 4 review files). Key design fixes from expert review: yolo-epic 7-key args contract (not throws), strict === safety filter, sidecar schema validation fail-closed, ephemeral Epic synthesis. KA: workflow args string serialization + nesting 1-level limit. Epic archived: `.tad/archive/epics/EPIC-20260607-surplus-burn-mode.md`. Report: `.tad/active/SURPLUS-REPORT-2026-07-02.md`
- [x] **EPIC: Trajectory Eval Harness ✅ COMPLETE 2026-07-02 (3/3 phases, all Gate 4 PASS)** — TAD's first quantitative quality measurement infrastructure. Phase 1: data audit (24 trajectories) + 5-dim rubric + 12-entry golden set (blind-label confirmed via subagent raters, DEGRADED_WITH_APPROVAL). Phase 2: Sonnet judge calibrated (within-1 94.1%, contrast 1.75, anti-anchor 3.75, stability Δ≤1; calibration_verdict: PASS). Phase 3: acceptance-protocol step4d_trajectory_judge (advisory auto-run) + gate-roi-report.sh (5-section: gates/caught/escaped+rate/trend/attribution). 4 new L2 patterns (gate-design + ac-verification + shell-portability ×2). Epic-level insight: Gates caught 15 P0s + 22 P1s across 3 phases that the implementations would have shipped uncaught — itself evidence for the gate-ROI question this Epic answers. Epic archived: `.tad/archive/epics/EPIC-20260701-trajectory-eval-harness.md`. Post-Epic carry: GS-07.D3 label review; judge-prompt frozen; contrast margin thin (0.25). **Next strategic step**: run `gate-roi-report.sh --days 30` after 5+ new acceptances to accumulate judge data, then revisit the mechanical-enforcement decision (roadmap item ④) with real numbers.
- [x] **EPIC: Trajectory Eval Harness — Phase 1/3 ✅ ACCEPTED 2026-07-02** (commit 7b9232b, Gate 3 PASS + Gate 4 PASS, all 12 ACs independently recomputed by Alex) — Delivered: data audit (24 trajectories sampled) + 5-dim rubric (`.tad/eval/rubric.md`, D2 scoring-basis clarified at Gate 4) + golden set (12 entries: 4 known-bad incl 1 silent-bad, per-dim >=3 levels verified). **Protocol pivot at Gate 4**: human blind-labeling found infeasible (user cannot do trajectory forensics) → substituted 2 independent blind subagent raters + Alex adjudication (user-approved, DEGRADED_WITH_APPROVAL; 3 divergences >=2 adjudicated, 2 draft scores overturned where drafter anchored on outcome — the exact anchoring risk the golden set tests). New L2 pattern: "Human-in-the-Loop Gate Step Must Verify the Human CAN Perform the Judgment" (gate-design.md 2026-07-02). Gate 4 report: `.tad/evidence/acceptance-tests/trajectory-eval-p1/gate4-acceptance-report.md`. Handoff archived. **Phase 2 next (judge spike + calibration; kill switch: within-1 <80% → Epic stops)** — Epic Context-for-Next-Phase has 5 carry-forward items (D4 data-poor, calibration weighting, anchoring test cases, cross-model backstop, AC11 concurrent-epic allowlist). Epic: `.tad/active/epics/EPIC-20260701-trajectory-eval-harness.md`
- [x] **EPIC: LDR Research Backend ✅ CLOSED 2026-07-02 (NEGATIVE-RESULT)** — Phase 1 POC done (Gate 3 PASS + Gate 4 PASS), POC Verdict FAIL: Library-scoped citation-resolution 16.7% (Alex provenance-corrected from Blake's 23%; judge Q3 label swap) << 80% gate; NotebookLM baseline 0% on same rubric. Phase 2 (wire into *research) NOT started. Root cause: LDR synthesis layer does not constrain citations to collection sources + persistent KB bleeds across runs + model format factor. Narrow reopen conditions in archived Epic. Key methodology lessons distilled to patterns/pack-evaluation.md (blind-judge provenance check / sanitization of tool-native markers / stateful-system round contamination / incumbent-on-same-rubric). Epic: .tad/archive/epics/EPIC-20260701-ldr-research-backend.md. Evidence: .tad/evidence/research/ldr-poc/. .mcp.json removed from repo root (archived copy in evidence). Cleanup optional: ~/.tad-ldr-venv + ~/.tad-ldr-data (repo 外, user may delete).
- [x] **EPIC: AI-Native Reading Companion — Phase 3/4 (Live Co-Read Bridge) ✅ ACCEPTED 2026-06-14** (Gate 4 PASS) — localhost stdlib bridge (`bridge-server.py` 426L + `bridge-client.py` + `test_bridge.py`) + `reader.html` bridge-mode chat panel + `render.py --bridge` + SKILL co-read protocol (least-agency + EPUB-as-DATA injection envelope). Alex **independently re-ran `test_bridge.py` → 34/34 PASS** (not paper). Gate 3 fix round (independent security-auditor + code-reviewer ran live attacks) caught 9 defects the 15 ACs + browser claim missed — incl. **P0: strict CSP blocked the reader's OWN inline script** (would be dead in an enforcing browser) → fixed with per-response CSP nonce; + keep-alive framing desync, SSE no-cap, /close body-drain (P1) — all fixed/re-verified. Evidence: `.tad/evidence/yolo/ai-native-reading-companion/phase3-completion.md`. Handoff archived. Epic 3/4, Phase 4 (sinks + PDF/TXT/URL) ⬚ Planned. **⚠️ Carry to first real use:** real-browser *visual* co-read (send→reply renders, enforcing-CSP inline load) still UNVERIFIED — confirm on first real-book session. Deliverable code is UNCOMMITTED (untracked `.claude/skills/reading-companion/`).
- [x] **EPIC: Capability Pack Quality Leveling ✅ COMPLETE + ARCHIVED 2026-06-13** (6/6 phases, YOLO via Workflow, no Codex; commits f2addac→05bd150, ~200 agents, 172 files/+7664). 21 packs upgraded to dual-layer bar (Layer A 结构<500+fixture+验证脚本; Layer B 研究落地深度+来源); 3 golds (web-backend/frontend/ui-design) = reference; QUALITY-BAR 固化进 capability-upgrade Gate 2; `.agents` Codex 镜像 parity PASS (release-verify.sh parity --fix). Conductor 独立验证每批 + 抓出并修真 P0/P1(product-thinking fixture 教错判断、llm-obs 2 个捏造 API、ai-guardrails 引错源论文、rag Faithfulness 阈值错)。No-Codex = Workflow 3-lens + WebSearch fact-check 替代,验证有效(fact-api 抓到同模型会漏的事实错)。中途撞账号限额→resumeFromRunId 无损接上。规则修正: ≥2-refute→fix 太松改为 any-refute→validate-then-fix + findings 落盘。Epic: `.tad/archive/epics/EPIC-20260613-capability-pack-quality-leveling.md`. EPIC-COMPLETION + 各 phase gate report: `.tad/evidence/yolo/capability-pack-quality-leveling/`. Aligns O2/KR1.

- [x] **EPIC: Pack System Unification — Phase 1 ✅ ACCEPTED 2026-06-11** (commits 0d965bb + 0f6a7d7, Gate 4 PASS 12/12 AC) — Retired 9 YAML Domain Packs + 2 guides to archive; removed SessionStart injection + post-write-sync handler + domain_pack_trace protocol; added domains to sync deny-list; rewrote Alex/Blake/runbook/capability-upgrade/research-notebook protocols to Capability Pack only (11 .claude/.agents counterpart pairs byte-identical); created 2 T2 skill-library references; added deprecation.yaml v2.30.0 entry. Layer 2: spec-compliance + code-reviewer PASS (4 P1 fixed). Gate 4 report: `.tad/evidence/acceptance-tests/pack-system-unification-phase1/gate4-acceptance-report.md`. Handoff archived. Epic archived: `.tad/archive/epics/EPIC-20260611-pack-system-unification.md`.

- [x] **EPIC: Pack System Unification — Phase 2 ✅ ACCEPTED 2026-06-11** (commits 554aef6 + 5210d32, Gate 4 PASS 10/10 AC) — Created prebuilt SKILL.md for 7 target packs; updated 7 installers from CAPABILITY→SKILL synthesis to deterministic copy; added --agent=codex writing to .agents/skills/; added --dry-run/--force where missing; fixed research-methodology --force; ml-training first-ever installed SKILL.md. Layer 2: spec-compliance PASS; code-reviewer P0 dispositioned as documented deferral, 4 P1 fixed. Gate 4 report: `.tad/evidence/acceptance-tests/pack-system-unification-phase2/gate4-acceptance-report.md`. Handoff archived. Epic archived.

- [x] **EPIC: Pack System Unification — Phase 3 ✅ ACCEPTED 2026-06-11 / EPIC COMPLETE** (commits 4c64e19 + c87efb4, Gate 4 PASS) — Added `release-verify.sh platform-skills` mode: framework-owned skill symmetry verifier (46 skills, derived ownership, source precondition, local-skill INFO). Wired into sync-protocol + release-runbook. Updated MULTI-PLATFORM.md + codex/README.md: SKILL.md Capability Packs are the only active pack system. Fixtures: drift-fail + local-info + missing-fail all independently rerun at Gate 4. Gate 4 report: `.tad/evidence/acceptance-tests/pack-system-unification-phase3/gate4-acceptance-report.md`. Epic archived.

- [x] **EPIC: Self-Evolution Pruning ✅ COMPLETE + ARCHIVED 2026-06-10** (3/3 phases, commits 89b20b0 + 4a779fa + 260041d, Gate 4 PASS ×3) — Self-evolution noise generators retired by measurement (18→1 yield documented in NEGATIVE-RESULT.md); replaced with 3-tier skill formalization: T1 in-session ceremony (live, dogfooded — smart-interval materialized in Colin), T2 skill-library shelf (2 references), T3 ≥2-project promotion via *harvest collision detection. Alex SKILL -1872 lines + 2 startup taxes gone; *harvest added. SAFETY: zero illegitimate constraint losses across all 3 phases (line-set classification each time); layer2-audit now fail-closed. New L2 pattern: Claims Need Carriers. Gate 4 reports: `.tad/evidence/acceptance-tests/sep-phase{1,2,3}/`. Epic archived: `.tad/archive/epics/EPIC-20260610-self-evolution-pruning.md`
  - Carry-forward (small, next docs pass): stale mentions in intent-router-protocol.md L150/L198 + accept-command.md L251 + handoff-a-to-b.md L24; alex SKILL header references missing AR-extract fixture path
- [x] **EPIC: Self-Evolution Pruning — Phase 2/3 ✅ ACCEPTED 2026-06-10** (commit 4a779fa, Gate 3 PASS + Gate 4 PASS 21 checks, gate4_delta empty) — T1 ceremony live (blake SKILL step 5 + UNATTENDED carve-out, AR-002 old→new documented) + harvest-scan.sh + release-verify FR7 (local-skill = INFO) + template tier field + Colin dogfood real (smart-interval→T1 materialized in Colin, eval-page+colab→T2 skill-library, 3 SCANDs truthful). Gate 4 PARTIAL once (Layer 2 artifacts missing → supplied; rider: layer2-audit fail-open → FAIL exit1, closes distinct-reviewer false-PASS backlog item). KA: NEW L2 pattern "Claims Need Carriers" → patterns/gate-design.md. Gate 4 report: `.tad/evidence/acceptance-tests/sep-phase2/gate4-report.md`. Handoff archived. **Phase 3 next (UNBLOCKED, parity 0)**: Alex/Gate SKILL surgery + *harvest + trace-digest removal. Epic: `.tad/active/epics/EPIC-20260610-self-evolution-pruning.md`
- [x] **EPIC: Self-Evolution Pruning — Phase 1/3 ✅ ACCEPTED 2026-06-10** (commit 89b20b0, Gate 3 PASS + Gate 4 PASS 16/16 AC, gate4_delta empty) — T2 skill-library shelf + dual deny-list (14 entries, --verify-denylist PASS) + SCAND template hardened (draft + constraint) + NEGATIVE-RESULT.md (yield 18→1, 5.6%). Archival pre-landed in f84c8fb. Gate 4 was PARTIAL once (completion file missing → Blake supplied; rider: layer2-audit KNOWN_REVIEWERS fixed). Gate 4 report: `.tad/evidence/acceptance-tests/sep-phase1/gate4-partial-report.md`. Handoff archived. Phase 2 next: Blake-side T1 ceremony. Phase 3: verify skills parity first. Epic: `.tad/active/epics/EPIC-20260610-self-evolution-pruning.md`
- [x] **EPIC: Feedback Collector ✅ COMPLETE 2026-06-10** (3 phases, commits da9cabb + 5306964 + 9446efb) — Universal structured feedback for non-code artifacts. P1: Blake protocol + JSON schema + handoff §8.5. P2: Alex reader + Gate 4 check + E2E dogfood (discovered overlay needed). P3: Overlay model for spatial artifacts + /playground deprecated + Gate4 BLOCKING. Epic archived: `.tad/archive/epics/EPIC-20260610-feedback-collector.md`.
- [x] **EPIC: Feedback Collector — Phase 1/3 ✅ ACCEPTED 2026-06-10** (commit da9cabb, Gate 4 PASS 11/11 AC) — Blake SKILL.md `feedback_collector_protocol` (~78 lines body), handoff template §8.5 Feedback Collection, feedback-json-schema.md (213 lines, v1.0), config-workflow.yaml `feedback_collector` section (6 artifact types + default dimensions). Expert review: 4 P0 + 9 P1 resolved. Handoff archived.
- [x] **Dual-Platform Parity Fix ✅ ACCEPTED 2026-06-10** (commit f428d70, Gate 3 PASS + Gate 4 PASS) — Synced 4 drifted skill files (3 Alex references + blake/SKILL.md) from `.claude/skills` to `.agents/skills`, updated stale Phase 4/5 status in `docs/MULTI-PLATFORM.md` and `.tad/codex/README.md` to reflect completed runtime freshness (21/21 PASS) and regression (CONDITIONAL_GO). Full skills-tree parity restored (`diff -qr` exit 0). Gate 4 report: `.tad/evidence/acceptance-tests/dual-platform-parity-fix/gate4-acceptance-report.md`. Handoff archived.
- [x] **EPIC: TAD Friction Protocol — Phase 2/2 ✅ ACCEPTED 2026-06-10** (commit b30d1ef, Gate 3 PASS + Gate 4 PASS) — Added manual advisory checker `.tad/hooks/lib/friction-status-check.sh`, 4 fixtures + harness, and Gate 3/4 advisory invocation text. Catches blocked-as-pass, missing Friction Status, and `gate3_verdict: pass` vs pending prose/checklist drift. Epic complete and archived. Gate 4 report: `.tad/evidence/acceptance-tests/friction-protocol-phase2/gate4-acceptance-report.md`.
- [x] **EPIC: TAD Friction Protocol — Phase 1/2 ✅ ACCEPTED 2026-06-10** (commit 0b1b9e5, Gate 3 PASS + Gate 4 PASS) — Core protocol + templates to stop Alex/Blake from skipping TAD steps when dependencies, approvals, auth, reviewer availability, or setup create friction. Added body-level protocol to Alex/Blake, Gate 3/4 friction checks, handoff `§8.4 Friction Preflight`, and completion-report Friction Status table. Epic: `.tad/archive/epics/EPIC-20260610-friction-protocol.md`. Gate 4 report: `.tad/evidence/acceptance-tests/friction-protocol-phase1/gate4-acceptance-report.md`. Handoff archived.
- [x] **EPIC: Upgrade Lifecycle System — Phase 1/6 ✅ ACCEPTED 2026-06-09** (commit eab1fd8, Gate 3 PASS + Gate 4 PASS 15/15 AC, gate4_delta empty) — Migration Manifest Schema v1 + 3 DRs (backfill v2.19.0, always-backup detection, deprecation absorb) + example manifest 2.26.0-to-2.27.0.yaml + research evidence. Code review: 2 P0 fixed (validator backslash + grep -P), 7 P1 fixed. KA: ac-verification.md (shell case-glob backslash). Handoff archived. Epic: `.tad/active/epics/EPIC-20260609-upgrade-lifecycle-system.md`
- [x] **EPIC: Upgrade Lifecycle System — Phase 2/6 ✅ ACCEPTED 2026-06-10** (commits fe11b95 + 7e2a945, Gate 4 PASS 19/19 AC) — migration-engine.sh (~450 lines) + 14-fixture harness. Code review: 1 P0 + 6 P1 fixed. KA: shell-portability.md (APFS pwd -P). Phase 3 carry-forwards: `.tad-backup/` sync exclusion; tad.sh:721 comment. Archived.

## Ideas (from SkillOpt deep research 2026-06-16)

- [x] IDEA-20260616-skillopt-tad-methodology-impact: SkillOpt-informed TAD methodology improvements (promoted → handoff → ✅ ACCEPTED 2026-06-17, commit c4fbeb2)
- [x] IDEA-20260616-agent-skill-evolution-pack: New capability pack — agent-skill-evolution (promoted → handoff → ✅ ACCEPTED 2026-06-17, commit f232261)

## Ideas (from AI Tinkerers #33 research 2026-07-03)

- [ ] IDEA-20260703-single-loop-agent-no-framework: PostHog — single-loop agent rejects LangChain, direct API + switch-mode tool
- [ ] IDEA-20260703-traces-hour-practice: PostHog — weekly team trace review > eval datasets
- [x] IDEA-20260703-saveable-skills-from-conversation: Linear — ✅ 已有等价实现 (P2 description matching + P3 Pipeline Capture + Gate 4 KA triple-question)
- [ ] IDEA-20260703-rubber-stamp-effect-human-ai: HitL Judges — rubber stamp effect in human-AI review, separate annotation from judgment
- [x] IDEA-20260703-cheap-loop-expensive-llm: petri — ❌ 已是直觉实践，无额外价值
- [x] IDEA-20260703-deterministic-rules-over-llm: Daria's Desk — ❌ 暂无意义
- [x] IDEA-20260703-claude-code-reverse-engineering: Originlab — ❌ 与我们方向无直接关联
- [x] IDEA-20260703-crdt-agent-realtime-collab: Jam — ❌ TAD Gate 已是安全切换点，CRDT 无需求
- [ ] IDEA-20260703-jax-extreme-parallelism: Jaxpot — JAX vmap extreme parallelism on consumer GPU
- [x] IDEA-20260703-self-critique-generation-pipeline: Voice Tutor — ❌ 暂无帮助
- [x] IDEA-20260703-state-machine-multistream-sync: Simer — 📌 存档备查（暂不行动）
- [x] IDEA-20260703-webrtc-agent-transport: WebRTC Agents — 📌 存档备查（暂不行动）
- [x] IDEA-20260703-imitation-learning-domain-bridge: LeRobot — ✅ 已在 Pokémon 项目实践（search + BC/AWR）

## Recently Completed (2026-06-17)

- [x] **Agent-Computer Interface Capability Pack (TAD #25) ✅ ACCEPTED 2026-06-17** (commit ff8de66, Gate 4 PASS) — New capability pack teaching AI agents systematic tool detection and selection across 5 layers (engine/data/hybrid/agent/desktop). SKILL.md (3 cross-cutting rules: two-tier capability detection + layer match + security-aware fallback) + 6 reference files (35+ judgment rules) + capability-detect.sh (CLI+process scan, JSON output) + tool-health-check.sh (90d freshness + 24h cache) + behavioral fixture (10 discriminative markers). Expert review: 4 P0 fixed (ToolSearch/shell split, install.sh path, pgrep user-scoping, L5 security rules) + 13 P1 fixed. Research: NotebookLM notebook c0143736 (14 sources). Handoff archived. Born from user-observed pain point: Claude spent 10+ min failing to find Claude in Chrome.

## Priority (Next Session)

- [x] **⚠️ P0: SKILL Body vs Reference 边界重新审视 — ✅ CLOSED 2026-07-12 (commit 3dbaa5f: 31-ref re-audit found 0 circular-trigger regressions — the 2026-06-09 fix held; real gap was verifier coverage, skill-body-verify.sh extended to alex with 7 body anchors + re-extraction guards + load_when non-circularity smoke test, mutation-tested 2/2; the estimated +200-300 lines back to body turned out to be 0)** — 原始问题描述： v2.26.0 SKILL 瘦身后 Codex 真实测试暴露根本问题：Blake 跳过 Layer 2 / completion report，因为这些规则在 references/ 里没被加载。核心洞察："如果 agent 不主动读 reference，会不会不知不觉违反流程？会 → 必须留 body。" 需要对 36 个 reference 文件逐个判断，把"执行纪律类"（Gate 3 checklist、Layer 2 要求、completion 格式）inline 回 body。两个平台都验证。详见：`.tad/active/ideas/IDEA-20260609-skill-body-reference-boundary.md`。预计 +200-300 行回 body，不影响 references/ 里的"显式触发类"协议。

- [x] **v2.29.0 RELEASED + SYNCED to 14/14 projects ✅ 2026-06-10** — tag v2.29.0 pushed; sync one-shot script (`.tad/evidence/releases/sync-v2.29.0.sh` + log): all 14 SYNCED, structural gate PASS ×14 (run pre-pack-install per gate's verbatim-copy scope), packs 25/25 everywhere, all version.txt = 2.29.0, downstream commits done. **FR7 first real-world validation PASS**: Colin smart-interval survived sync; pre-existing ml-training extras correctly reported as `ℹ️ local-skill` INFO, zero false blocks. 8 version-gate historical exceptions documented (`evidence/releases/v2.29.0-version-gate-exceptions.md`).

- [x] **Pack install layer is platform-blind (quantified 2026-06-10, supersedes old item (a)) — promoted 2026-06-11** — Absorbed into `IDEA-20260610-pack-system-unification` / Pack System Unification Epic scope. Original issue: `install.sh` writes only `.claude/skills`; `.agents` keeps verbatim master copy. Measured downstream impact: 6 transformed packs plus `ml-training` missing from `.agents`. Fix direction is now handled as Epic Phase 2/3: install single-sourcing + platform symmetry verification.
  - (b) **2 installers reject `--force`** (academic-research, research-methodology) — sync script patched to detect+fallback to no-arg form (25/0 everywhere), but add a `--force` no-op to those 2 install.sh.
  - (c) **3 merge-strategy projects lack the marker** (my-openclaw-agents / toy / 内存管理) — CLAUDE.md head NOT synced (left untouched, documented warn). Add `<!-- TAD:PROJECT-CONTENT-BELOW -->` or switch to `overwrite` if their TAD head should track releases.

- [x] **Triple-Question KA Evolution — ✅ COMPLETE 2026-06-03** (commit b6911a7) — Gate KA expanded from 2Q to 3Q (knowledge + skill + workflow). Blake Gate 3 + Alex *accept triggers. Skillify Step 5 routes judgment→SKILL.md / orchestration→.workflow.js. Alex .workflow.js authoring carve-out added. Idea: `.tad/active/ideas/IDEA-20260603-triple-question-ka-evolution.md`

## Recently Completed

- [x] **EPIC Phase 1: Dual-Platform Native Runtime Architecture — ✅ COMPLETE 2026-06-09** (commit 892ace6, Gate 3 PASS) — Architecture decision document with 14-surface capability matrix, 10 decisions (D1-D10), Runtime Freshness Loop design, 20 Codex claims verified against codex-cli 0.137.0. Awaiting Alex Gate 4. Epic: `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`

- [x] **EPIC Phase 2: Codex Native Runtime Policy — ✅ COMPLETE 2026-06-09** (commit 4f03d7e, Gate 3 PASS) — Policy doc (15 sections) + config.toml.draft + 3 agent TOML drafts. 8 role decisions (3 migrate_draft, 3 defer, 2 keep_skill_only). 6-point activation criteria. No active runtime files created. Awaiting Alex Gate 4. Epic: `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`

- [x] **EPIC Phase 3: Dual-Platform Adapter & Docs Upgrade — ✅ COMPLETE 2026-06-09** (commit 862bf1e, Gate 3 PASS) — Rewrote docs/MULTI-PLATFORM.md (58→204 lines), expanded .tad/codex/README.md (28→95 lines), updated AGENTS.md. Removed all "specialized executor" framing. Documented shared protocol / adapters / draft-only config / activation criteria / runtime freshness / limitations. Awaiting Alex Gate 4. Epic: `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`

- [x] **EPIC Phase 4: Runtime Freshness Loop — ✅ COMPLETE 2026-06-09** (commit 23f4604, Gate 3 PASS) — Codex ledger (12 surfaces) + Claude Code ledger (9 surfaces) + runtime-freshness-verify.sh + release-verify.sh freshness mode. Fixture-tested: stale→exit 1, malformed→exit 2, current→exit 0. ask_user_question_hook = accepted_limitation. Gate 4 PASS. Epic: `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md`

- [x] **EPIC Phase 5: Regression & Acceptance — ✅ COMPLETE 2026-06-09, Gate 4 CONDITIONAL_GO** — T1 Codex full-cycle PASS (v0.138.0, to_upper carrier). T2 Claude Code compat PASS (6 surfaces + 2 behavioral spot-checks). T3 carry-forward PASS (CF1 ask_user_question = adapter_bug, CF6 model_provider = accepted_limitation). T4 freshness PASS (21/21). 8/8 AC independent recompute match. CONDITIONAL_GO: ask_user_question adapter gap open. **Epic COMPLETE — archived to `.tad/archive/epics/`**

## In Progress

- [x] **EPIC: Surplus Burn Mode — Phase 1 ✅ COMPLETE 2026-06-08** (commits d3dbc32, 6776d85; YOLO Conductor) — `*surplus --plan` scans backlog + OBJECTIVES generator → value-first ranked plan + JSON sidecar. Epic: `.tad/active/epics/EPIC-20260607-surplus-burn-mode.md`. Live run: **53 ranked candidates** (24 auto-eligible / 19 needs-human / 0 vacuous) → `.tad/active/SURPLUS-PLAN-2026-06-08.md` + `.json`. 2 design + 2 impl reviewers; live run caught 2 real bugs review missed (top-level-array schema 400; stale `{name:}` workflow copy). KA → `patterns/ac-verification.md`.
  - **Phase 1.1 (quick-fix, before Phase 2)**: `undated` filename bug — `date`/`output_path` args didn't propagate; robust fix = SKILL owns output filename. Also AC1 `node --check` verifier invalid for all workflows (+ epic-audit.workflow.js:80 latent top-level-array schema).
  - **Phase 2 (pending)**: budget-loop auto-execution + safety routing + dogfood. JSON sidecar contract ready.

- [x] **TAD Universal Gate (AC-Driven Verification) — ✅ COMPLETE 2026-06-07** (commit 210f34b, Gate 4 PASS + archived) — Gate 3/4 从硬编码 tsc/test/lint 改为执行 handoff §9.1 逐行验证；2 个 task_type:deliverable 路由分支移除，judge≠producer SAFETY 机器 byte-exact 迁移到通用 Rubric Evaluation Protocol。Alex 新增 step1_ac_generation（task-scoped AC 自动生成）。16/16 AC pass; raw-recompute all match; Layer 2 三审 PASS。KA: `patterns/gate-design.md`
  - **Residual**: 无 dogfood — 真实非 dev handoff（Colin声音播客）端到端未跑。建议下次在 Colin 项目做第一个非 dev Handoff 时验证 Gate 新行为。


- [x] **npx 跨平台安装器 — ✅ COMPLETE 2026-06-07** (commit 18a7e80) — `npx github:Sheldon-92/TAD` selects platform (Codex/Claude) + packs with descriptions. Codex gets 13K slimmed install (no 86K alex/blake SKILL). 13/13 AC pass. Gate 3 PASS. Expert review: 2 P0 fixed (regex injection), 2 P1 fixed (prefix boundary + POSIX ERE). KA: shell-portability → copy-after-deprecation ordering.
  - Residual: `IDEA-20260607-tad-unified-auth-layer.md` (auth persistence); B context progressive loading (separate direction); Codex adapter validated `.tad/evidence/codex-validation/REPORT-2026-06-07.md`.

- [x] **EPIC: Non-Dev verdict_shapes (categorical + checklist) — ✅ COMPLETE 2026-06-06 (YOLO, branch `epic/nondev-verdict-shapes`)** — Made the non-dev deliverable lane runnable for non-`weighted` packs. Epic: `.tad/archive/epics/EPIC-20260606-nondev-verdict-shapes.md` · report: `.tad/evidence/yolo/nondev-verdict-shapes/EPIC-COMPLETION.md` · DR: `.tad/decisions/DR-20260606-checklist-shape-dogfood-deferral.md`
  - **Why**: `verdict_shape_guard` HARD-BLOCKed all non-weighted packs → product-thinking/voice/video had registered rubric slots but couldn't pass a gate. User-picked highest-value generative direction ("make non-dev packs runnable").
  - **P1 (864e64e)**: gate/SKILL.md Gate 3/4 deliverable branches support categorical (rigor band, decoupled from BUILD/PIVOT/KILL via order-of-emission firewall + swap test) + checklist (required/optional, ≥1-required guard). weighted byte-unchanged (62/4, all sanctioned). 2 design + 2 impl reviewers 0 P0.
  - **P2 (cd065ee)**: product-thinking categorical rubric (5 rigor dims, per-type differentiator table for D5 self-containment) authored + registered active; citations verbatim-traced. 2 reviewers 0 P0.
  - **P3**: dogfood PROVED it — PalateBox, 4 distinct agents (judge≠producer): rigorous→`KILL`→**PASS**, thin control→`BUILD`→**FAIL** (inverse of naive mapping = decoupling proven). Checklist synthetic fixture PASS+FAIL (no hardware). Guide updated. KA → patterns/gate-design.md.
  - **Residual**: voice/video checklist real-content dogfood pending hardware (DR-20260606). Branch NOT merged — awaiting human merge decision.

- [x] **Tournament Design Workflow (Epic P2/5) — COMPLETE 2026-06-03** (commit 2292e04) — Reusable tournament-design.workflow.js: N competitors + pairwise judges + synthesizer merge. Integrated as Alex *design step1_5c + standalone *tournament. Standard (4 agents, ~200K) and deep (7 agents, ~320K) modes. Experiment: `.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md`

- [x] **Declarative Constraints v0.1 — COMPLETE 2026-06-03, Gate 4 PASS + archived 2026-06-10** (commit df006b5) — Migrated 11 forbidden_implementations blocks from alex/SKILL.md body into structured YAML frontmatter constraints block. Mechanical deny deduped (22→2 lines), judgment items stay in body. SAFETY grep 19→20 at df006b5 (HEAD now 5 — legit dilution by progressive-loading Epic, load-bearing items survive). AC5/NFR3 manual-test gap closed by 6 days of live /alex usage. Idea: `.tad/active/ideas/IDEA-20260528-declarative-agent-constraints.md`

- [x] **Skillify at Knowledge Assessment — ✅ COMPLETE 2026-06-03** (commit 7aa92c0) — Blake KA now evaluates reusable working patterns (4-gate: Reusable/Non-trivial/Verified/Not-duplicate) + Alex *skillify command + STEP 3.57 candidate detection at startup. Inspired by Garry Tan "Stop building Foxconn factories" article + GBrain/Hermes/Claudeception research. Idea: `.tad/active/ideas/IDEA-20260603-skillify-at-knowledge-assessment.md`

- [x] **EPIC: Self-Deriving + Self-Verifying Release/Sync (2 phases, YOLO) — ✅ COMPLETE + ARCHIVED 2026-06-01** — Epic: `.tad/archive/epics/EPIC-20260601-self-deriving-release-sync.md` · DR: `.tad/decisions/DR-20260601-self-deriving-release-sync.md`
  - **Why**: publish/sync/install kept silently missing files (codex frozen a month, tad.sh stuck at 2.19.1) — root cause: hardcoded lists go stale when structure evolves. User: "make it a standard operation that checks itself, not a stale reused script."
  - **Solution (skill upgrade, not a pack)**: replaced hardcoded lists with **structure-derived rules + structure-agnostic verification gates**. `.tad/hooks/lib/derive-sync-set.sh` (deny-list, single source of truth) + `release-verify.sh` (`structural` diff-r / `version` grep-stale scoped to `git ls-files`, exit 0/1/2, `TAD_RELEASE_GATE=warn` shadow). Release-time HARD-BLOCK gate wired into `*publish`/`*sync` (NOT settings.json). Runbook tables demoted to non-authoritative. **P2**: tad.sh installer self-derives (deny-list copy-set incl. top-level files, version-from-source, diff self-check, `--verify-denylist` drift check).
  - **YOLO Conductor**: P1 (2 design reviewers→4 P0 fixed v2; 2 impl reviewers→0 P0, version-noise 62→5 fixed) + P2 (2 impl reviewers→0 P0; arch caught surviving top-level extension-glob disease→fixed). Both Gate 3+4 Conductor-verified (exclusion=0 no-clobber; codex auto-included; drift-check real). Commits 16dbe1a/904cec2 (P1) + f053f50/a24a166 (P2). KA: architecture.md "Deny-List Beats Allow-List…".
  - **Residual (P3-tier)**: (a) `release-verify.sh structural` covers dirs+.claude/skills, not yet top-level .tad/ files (tad.sh self-check does); (b) version-scope over-reports ~5 NEXT.md historical lines; (c) first real release MUST use `TAD_RELEASE_GATE=warn` shadow before hard-block.

- [x] **EPIC: Codex-Edition Parity Mechanism (3 phases) — ✅ COMPLETE + ARCHIVED 2026-06-01** — Epic: `.tad/archive/epics/EPIC-20260601-codex-edition-parity.md` · DR: `.tad/decisions/DR-20260601-codex-edition-parity-architecture.md`
  - **Outcome**: Codex-CLI edition (Alex+Blake) brought to v2.20.0 parity + a **standing release-time gate** so every future `*publish` stays in sync. Was drifted a month (`Generated: 2026-05-04`, missing deliverable track/research-engine/pack-collision). Commits 1b74dec (P1) + 4881bc1 (P2) + e09d443 (P3).
  - **Design (DR-20260601, Architecture B + decouple)**: `*publish` runs a **detect-only** `codex-parity-check.sh` (per-must-cover-owner-body presence, compensation-resistant, fail-CLOSED) → drift minor+ = HARD BLOCK; a **separate human-invoked** `regen-codex-editions.sh` (atomic codex-exec regen, human reviews git diff + commits) is the remediation — keeps unreviewed LLM content out of tagged releases (backend-architect P0 caught self-heal risk → user re-decided to decouple).
  - **⚠️ One environmental residual**: `regen-codex-editions.sh` LIVE happy-path run unproven — **codex auth token_revoked (401, Alex-confirmed)**. Regen mechanism is P2-proven (codex exec 175s). **CLOSE**: re-auth codex → `bash .tad/codex/regen-codex-editions.sh` once → review diff.
  - **Side fixes**: layer2-audit now recognizes `spec-compliance` (recurring name-drift root-fixed); marker-extraction source-derived (self-sustaining). KA: architecture.md "Coverage gate global-floor" + "Release gate on derived artifacts: detect-only + separate regen".
  - **Why**: Codex-CLI edition drifted — `Generated: 2026-05-04`, missing entire deliverable track / research_complexity / step4_5. Release only bumps version string, never re-ports content. Architecture **B** (automated regen + release-time hard-block parity gate); user wants full parity + ≤5min/release + every future release stays in sync.
  - **P1 Spike ✅ (1b74dec)**: proved regen feasible + built discriminating `parity-check.sh`; `regen-procedure.md`, `parity-criterion.md`, expected-absent allowlist (9 Conductor protocols).
  - **P2 Catch-up ✅ (4881bc1 +4, Gate 4 ACCEPT)**: BOTH live editions regenerated to v2.20.0 parity (codex-alex 46KB, codex-blake 29KB). Layer-2 redesigned global-floor→**per-must-cover-owner-body presence**, **proven compensation-resistant** (Alex Gate-4 re-ran: delete express block + add surplus → still exit 1; a count-gate would pass). P1 #1 constraint-fidelity **RESOLVED** (per-owner trace 12/12 forbidden_impl + 6/6 anti_rat, source-body==codex-body each owner). Headless **≤5min PROVEN** via `codex exec` 175s (claude -p FAILs on 326KB — analysis not raw file).
  - **P3 = release-wiring (gate logic DONE)**: add `parity-check.sh` (per-owner, fail-CLOSED, pin-validated) to `release-runbook` Codex Adapter + `*publish` as **minor+ HARD block / patch advisory**; runbook notes "use codex exec for regen". Small carry-forwards: layer2-audit reviewer-name drift (spec-compliance not in KNOWN_REVIEWERS, recurring 2026-05-27); P1-2 awk header self-count; single-user-CLI (gate release-time only, never settings.json).
  - **Next**: P3 (wire gate into release process). Then Epic complete.

- [x] **EPIC: Agent-Adjacent Pack Factory (8 packs) — ✅ COMPLETE 2026-06-01** — Epic: `.tad/active/epics/EPIC-20260531-agent-adjacent-pack-factory.md` · research: `.tad/evidence/research/agent-pack-factory/` · eval: `.tad/evidence/pack-eval/2026-06-01/`
  - Mass-produced 8 agent-adjacent capability packs via NotebookLM deep research (Conductor seq, ~401 sources/~370KB cited) → parallel build Workflow (32 agents) → adversarial review+fix → real spot-eval. Registry **16→24 packs**. "用满 usage" generative direction.
  - Packs: **rag-retrieval · agent-memory · llm-observability · ai-guardrails · data-engineering · agent-orchestration · synthetic-data · knowledge-graph**. All 0 P0 remaining; valid frontmatter; 5-6 refs + fixture + install.sh each; SKILL==CAP byte-identical.
  - Anti-theater proof: review loop caught 4 real P0 (2 fixture-theater, 1 fabricated-number, 1 wrong-OWASP-code). **REAL spot-eval on all 8** (WITH-pack vs knowledgeable-no-pack CONTROL, discriminative gate): **7/8 verified** (rag 13/2, agent-memory 9/1, llm-obs 4/0, ai-guardrails 9/2, agent-orch 5/0, synth 9/0, kg 10/2 — all clean WITH»CONTROL deltas). **data-engineering honestly `pending`** — CONTROL also scored 5/4 PASS (markers train-serve-skew/RRF/SCD2/pre-filter are common senior-DE knowledge, not pack-unique) → fixture needs tightening like web-backend.
  - **PUBLISHED v2.20.0 + SYNCED to 14 projects (2026-06-01):** *publish pushed main + tag v2.20.0 (rebase hit knowledge-file conflicts → switched to one-shot merge, clean). *sync full-refresh to all 14: every project verified 2.20.0 / 8/8 packs / registry 24 / dormant-sync hook present. 13/14 committed; my-openclaw-agents files synced but its own pre-commit hook blocked auto-commit (left for manual). Registry → 2.20.0 (commit 2ac5bad).
  - **Codex cross-model review (2026-06-01, commit 6c79a3d):** ran codex adversarial review on all 8 → 8/8 FIX-FIRST, ~44 Cat-A/C concrete factual+API errors the all-Claude build+review loop MISSED (wrong class names, deprecated APIs, OTel Histogram-not-Counter, F2 β=2 math, etc.). Fixed ~44 (verified each, NOT blind-trust); **3 codex claims SKIPPED — codex itself was wrong** (GraphRAG Leiden level direction + LangChain HITL 4-decisions, both confirmed via WebSearch primary docs → pack was right). All 8 byte-identical. Lesson in architecture.md "Cross-Model Adversarial Review...". Remaining Cat-B (over-absolute claims ~20) deliberately NOT touched — optional softening pass.
  - **P1 follow-ups (non-blocking):** (a) **citation-pointer audit** — findings.md reports carry a top source-list AND a report-body reference list with DIFFERENT [N] numbering; pack `> Source: [N]` tags may point to wrong URLs (claims are correct, pointers ambiguous) — audit + pin URLs; (b) **keyword-overlap collision signatures** — add scan-collisions signatures for GraphRAG (rag-retrieval↔knowledge-graph, boundary note already added) + checkpoint/durable (agent-memory↔agent-orchestration); (c) **real-eval the 5 remaining packs** (agent-memory/ai-guardrails/data-engineering/agent-orchestration/knowledge-graph) to flip pending→verified; (d) agent-memory missing Anthropic prompt-caching min-prefix length (1024 Sonnet/Opus, 2048 Haiku); (e) sibling **ai-evaluation** has same OWASP stale-numbering bug (adversarial-rules.md:127) — pre-existing, fix in a sweep; (f) Phase 3 optional: install 8 packs to downstream projects via *sync.

- [x] **EPIC: Non-Dev Execution Track (4 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-nondev-execution-track.md` · report: `.tad/evidence/yolo/nondev-execution-track/EPIC-COMPLETION.md`
  - Gave TAD a NON-CODE delivery lane: `task_type: deliverable` routes Gate 3/4 to additive sibling sections that score a content artifact against a pack rubric via an INDEPENDENT judge sub-agent (judge≠producer) instead of `tsc/test/lint`. Turns the orphaned non-dev packs (academic/voice/video/product) into a runnable pipeline. "TAD beyond software dev."
  - P1 contract v2.1 (4 P0+6 P1 caught/fixed) · P2 gate Gate3/Gate4 sibling branches byte-safe (originals IDENTICAL vs 9fc6c50; 1 P0 dead-telemetry + 4 P1 fixed) · P3 **real dogfood: 0.737 PARTIAL → revise → fresh judge 0.7725 PASS** (3 distinct agents — gate discriminated, not theater) · P4 track guide + KA. Commits 23339a9, 897bed9, 9986de8, 179556d.
  - **Follow-ups (tracked, non-blocking):** (a) implement categorical (product BUILD/PIVOT/KILL) + checklist (voice/video) `verdict_shape` so those 3 packs become runnable (currently registered rubric-tbd + guarded/BLOCKed by verdict_shape_guard); (b) author product-thinking rubric (no hardware barrier) + real dogfood; (c) voice/video real dogfood needs hardware (deferred by design); (d) harmonize product-thinking `dogfood_capable` wording (registry "yes" hardware-axis vs guide "no" rubric-ready-axis).

- [x] **EPIC: Pack Collision Detection (2 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-pack-collision-detection.md` · report: `.tad/evidence/yolo/pack-collision-detection/EPIC-COMPLETION.md` *(parallel Alex — zero lean-trustworthy file overlap)*
  - P1 ✅ Done (d296374 + 1b714f4): cross-pack collision detector. `scan-collisions.sh` (grep-seed over `.claude/skills/` canonical tree, 2.2s, LC_ALL=C CJK-safe pre-filter, atomic write) + `collision-signatures.txt` + `pack-collisions.yaml` (3 confirmed: Inter→auto perf>style, APCA-vs-WCAG→escalate a11y, pyramid→escalate correctness) + `pack-collision-detection.md` guide (precedence engine + LLM-confirm contract + anti-theater rule) + 3 fixtures. Gate 3+4 PASS; 4 reviewers (2 design+2 impl) 0 P0; all 6 collision refs hand-re-derived live. Anti-theater spot-check caught its OWN false positive (video-creation CJK comm bug → fixed).
  - P2 ✅ Done (5d41c20): wired `pack-collisions.yaml` into Alex `step4_5` (additive `5b`) + Blake `1_5a` (additive `2.5`). Purely additive (4 files, 144 insertions, 0 deletions); constraint-token counts held (alex 132, blake 49); structure intact. AC8 fixture traced live (web-ui-design + web-frontend → Inter ⚙️ resolved line). Gate 3 PASS. Loser-quote carry-forward (architect P2-B) included in the alex 5b auto template.
  - P2 carry-forward: surfacing one-liner should also carry the loser's quote (architect P2-B) for the human spot-check.

- [x] **EPIC: Lean & Trustworthy TAD (5 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-tad-lean-trustworthy.md` (other Alex, parallel session)
  - P1 ✅ Done (85fe0a9): trace §11 parser header-aware (4-col column-shift fixed) + 6 dead dream candidates purged. Gate 3+4 PASS; 2+2 reviewers raw-recomputed.
  - P2 ✅ Done (b95a577 + 35b5a60): ai-voice-production full source-dir-ification (now Tier1+Tier2 sync-portable) + registry 14→16 + advisory type-probe drift-check (`.tad/hooks/lib/pack-registry-driftcheck.sh`, no allowlist rot) + all 16 packs now have real consumes/produces. Gate 3+4 PASS; 2+2 reviewers.
  - P3 ✅ Done (7c5a59f + 1216bac): OPTION A progressive disclosure — 9 token-free path protocols → `.claude/skills/alex/references/`, 6441→5825 (~9.6%), constraint count 131 UNCHANGED (byte-identity SAFETY held). honest_partial correctly surfaced AC3.1(≤3500)×AC3.2(byte-identity) conflict → user chose safe Option A. 2 impl reviewers raw-recomputed all 9 diffs.
  - P4 ✅ Done (eb53ee7 + fd6e1a5): advisory §9.1 AC-command linter (`.tad/hooks/lib/verify-ac-commands.sh`) wired at step1d, never blocks. Rule A 100% precision; Rule B surfaced **34 latent literal-pipe-in-ERE bugs across already-shipped handoffs**; calibration removed Rule C 218-hit noise. 2 impl reviewers ran it on 14+ handoffs.
  - P5 ✅ Done (68c85a1 + 2311f9e + 4e88bff): pack behavioral eval runner + fixtures; discriminative gate (gates on pack-specific markers, not contaminated combined count); 2 packs verified via discriminative delta, web-backend honestly held pending. 8448c7d Epic bookkeeping.
  - P4 follow-ups: sweep the 34 Rule-B latent bugs in shipped handoffs; KA "advisory INFO rules need real-volume calibration (a rule firing 218× on correct commands trains the user to ignore all output)".
  - P3 follow-ups: (a) stub↔reference drift-check (advisory, mirror pack-registry-driftcheck.sh); (b) dogfood-monitor that direct `*bug`-typed entry triggers the reference Read (load_when reliability); (c) OPTION B (reframe AC3.2 to moved-not-deleted + inline router constraint summary) available for a deeper progressive-disclosure pass on research_plan(724)/express/experiment — needs SAFETY-AC sign-off; would reach the original ~45% target.
  - P2 follow-ups: add `type:` to product-thinking/research-methodology installed SKILLs (drift-check type-probe symmetry); drift-check SKILLS_DIR layout note + optional SessionStart wiring; pack-build checklist must require `.tad/capability-packs/{name}/` source dir from the start (ai-voice was built skipping it).

- [x] **Debt Bundle 1/2: Release Hygiene + Conventions** — YOLO Gate 4 PASS + ARCHIVED 2026-05-31 (commit ae387ef)
  - doc-drift→2.19.1 (README:354 history preserved) + tad.sh 3-part + `*)` arm + line 171 fallback + runbook codex-greeting rows 17/18 + express-slug convention (alex/blake SKILL)
  - Design review: code-reviewer + backend-architect (P0: version-scheme rationale wrong consumer → detect_state line 303; fixed). Impl review (YOLO Y6): both PASS 0 P0. Gate 4 raw-recompute: AC1/AC3/AC9 verified.
- [x] **Debt Bundle 2/2: Hook Code Hardening** — YOLO Gate 4 PASS + ARCHIVED 2026-05-31 (commit b37d41b)
  - dream-scanner fromjson try-guard(a) + classify_scope TAD-keywords(b) + expert_finding heading-only(d). bug(c) dedup DROPPED (validation theater, 0/31 real match).
  - Impl review: code-reviewer PASS 0 P0; backend-architect CONDITIONAL PASS 0 P0 + 1 P1 (slug substring over-classify). Gate 4: malformed→0 junk, sync→project, heading-only=1 verified.

- [x] **Research Engine Upgrade (Epic goal-driven-research Phase 4+5+6A)** — Gate 4 PASS 2026-05-31
  - Triggered by *discuss audit: NotebookLM advanced flow "built-not-wired" (seed_origin 0 uses, challenge 2/25; 3/14 adoption)
  - **P4** effort-scaling + dormant hook + AR-001 carve-out (DR-20260531) + dogfood seed_origin 0→2: 92bbfc3→4c84b09→58c9cac
  - **P5** persona-seeding + 5-dim rubric (rides existing 4c, no new invocation): 5456afb→09de56c. ux-expert 3 methodology P0→resolved
  - **P6A** research-gate (right-moment nudge + declined-domains dedup): 7d41768→7c08f37. backend-architect 2 dedup P1→resolved
  - All 3 phases: worktree Blake impl + 2-round expert review + Gate 4 raw-recompute. SAFETY guards held throughout (DR=9, codex/gemini 3/3)
  - ⏭️ **P6 AC6.3 *sync to 14 projects DEFERRED** — pending explicit authorization (outward-facing)
  - ⏭️ **P3 Research-Decision Loop** still ⬚ Planned (director-layer)
  - 💡 AKU governance-as-code (14.5% of 2303 agent files) → capability-pack gap candidate; optional full tad-evolution refresh
  - 💡 Optional: full tad-evolution landscape refresh (dogfood was bounded to prove wiring)

- [x] **Bugfix: dream-scanner Pass C weaves override chosen/rationale** — Gate 4 PASS + ARCHIVED 2026-05-31
  - Pass C now extracts .chosen/.rationale (newline-flattened in jq, stderr-quiet) → content-rich candidates; fallback intact
  - Layer 2 code-reviewer PASS (raised P0 heredoc-injection → empirically refuted → withdrawn); test-runner PASS
  - Commit ecf912e + 7e1e54b (Gate 3 artifacts); KA(Blake) → code-quality "Heredoc injection depends on the SINK"
  - Gate 4: Alex raw-recompute AC2/AC3/AC4 from real trace events (✅); Layer2 audit 2 reviewers tier MET; KA(Alex) → architecture "Parser feeding review queue must propagate VALUE not just key"
  - Trigger: 6 empty `human_override` dream candidates (2026-05-30) all rejected → root cause = Pass C dropped captured rationale

- [x] **Release v2.19.0 + v2.19.1 PUBLISHED + SYNCED to 14 projects** — DONE 2026-05-30
  - *publish: pushed main + tags v2.19.0 (87665e0) & v2.19.1 (40989f2); rebased through remote dream-state churn
  - *sync: all 14 projects got V2 trace hooks (6 emit fns each, verified); 6 V1-stuck projects upgraded
  - merge projects (toy/my-openclaw-agents/内存管理): CLAUDE.md backed-up + restored (toy marker preserved)
  - tad.sh --yes flag (commit 4767901) unblocked non-TTY sync; registry → 2.19.1 (commit e6ca251)
  - Codex Phase 7 smoke test PASS before sync push

## Deferred (surfaced 2026-05-31 debt-bundle expert review)
- [x] **Multi-table §11 decision parser re-bind — CLOSED 2026-07-12**: emit_decision_points rewritten as table-boundary state machine (Decision+Chosen header re-binds; other headers suppress whole table; mid-table literal `| Decision | Chosen |` cannot spuriously bind). Independent reviewer ran 14 adversarial fixtures on native BSD awk — all pass; hot-path unchanged; no other §11 consumers exist. Accepted limitation: two tables with NO separating line merge (invalid markdown).
- [x] **classify_scope word-boundary slug matching — CLOSED-STALE 2026-07-12**: function no longer exists in live tree (lived in dream-scanner.sh, deleted at Self-Evolution Pruning f84c8fb; *evolve fan-out blast radius retired with it). Bracket-class patch was still built + fixture-verified against the retired copy (webhook-handler→project etc., 6/6) for future restoration. Item's "architecture.md 2026-04-24" citation was itself stale — lesson lives at patterns/shell-portability.md.
- [ ] **tad.sh:165 stale comment** (H1 impl review): comment still says "MAJOR.MINOR" after 3-part switch — cosmetic, fold into next tad.sh touch.
- [ ] **Semantic dedup for dream-scanner candidates** — grep-on-`.decision`/`.chosen` is inert (0/31 real values match; backend-architect). Needs title/discovery match or embedding-based semantic dedup. bug(c) dropped from hook-hardening handoff pending this design.
- [x] **detect_state glob-arm hazard — CLOSED 2026-07-12** — `2.x` arms eliminated by 06-14 semver rewrite (numeric `_tad_ver_cmp` + same-major→upgrade); residual cross-major `1.8*`-style prefix globs dot-bounded (`1.8|1.8.*`) by 07-02 dogfood fix, salvaged from unmerged worktree + merged + functionally verified (`1.80.0→old` not `v1.8`) 2026-07-12.
- [x] **Express tier: durable frontmatter marker — CLOSED 2026-07-12**: `express: true` frontmatter is now the load-bearing marker (layer2-audit two-tier detection, slug token = legacy fallback). Review caught a real spoof in round 1 (glob-substring collision let non-express inherit a sibling's exception) — fixed with anchored glob + exact-slug filter + multi-match fail-strict; Alex re-verified spoof→WARN / legit→PASS independently.

## Cancelled
- [c] surplus-o1-landscape-refresh-2026q3 (2026-07-12) — pivoted: O1 rewritten by repositioning; task designed against old framework-benchmark framing
- [c] surplus-tad-self-test-agent (2026-07-12) — scope-change: design not converging (round-2 added 4 new P0s); revive as formal Epic if wanted
- [c] surplus-session-health-check (2026-07-12) — obsolete: synthesized to burn expiring quota, never executed, surplus premise gone

## Follow-ups (from this release cycle)
- [ ] **Doc-drift sweep to 2.19.1**: README/INSTALL/tad-help/codex skills still say 2.19.0 (cosmetic; fold into next minor)
- [ ] **Version-scheme inconsistency**: tad.sh stamps downstream version.txt = "2.19" (MAJOR.MINOR via TARGET_VERSION:537) while source = 3-part "2.19.1". Decide unified scheme.
- [ ] **runbook gap**: add codex greeting lines (855/632) to release-runbook Phase 2 version table
- [ ] **expert_finding parser**: tighten count to heading-form-only (prose "P0" self-trigger — trace-fix follow-up)
- [ ] **dream-scanner Pass C dedup + scope** (deferred from bugfix-dream-scanner-override-content): (a) dedup new candidates against existing project-knowledge before emit; (b) `file=null` → override candidates mis-classify as `project` even when framework-scoped; (c) line ~183 `fromjson`-error on malformed context → `""` not `"unknown"` → guard leaks junk candidate. Bundle into one Pass C hardening handoff.
- [ ] tad.sh `*)` default arm for unknown flags (code-reviewer P2, non-blocking)
- [ ] **dream-scanner Pass C dedup + scope**: (a) dedup override candidates vs existing project-knowledge; (b) classify_scope mis-tags framework overrides as `project` (file=null on decision_point); (c) line 183 `(.context|fromjson|.decision)//"unknown"` doesn't catch fromjson *errors* → malformed context yields junk candidate. Bundle into one Pass C follow-up handoff.
- [ ] **express slug convention**: express handoffs should encode "express" in the slug so layer2-audit detects the Tier (bugfix-... slug + task_type=code → false ≥2-reviewer WARN)

- [x] **Release TAD v2.19.0** — Gate 3 PASS 2026-05-30 (awaiting Alex *publish)
  - Bumped 18 version strings (7 files) + fixed tad.sh TARGET_VERSION drift (2.15→2.19)
  - CHANGELOG [2.19.0]: trace v2 / sync-fix / ML pack / cloud compute
  - Commits: 7e1bd86 (release) + dfb9740 (framework state + lifecycle + evidence)
  - Blake STOPPED before push/tag — ⏭️ Alex: *publish (push+tag v2.19.0) → *sync (14 projects)
  - ⚠️ Alex: run Codex adapter smoke test (runbook Phase 7) before sync push
  - 📝 Runbook gap: add codex greeting lines (855/632) to Phase 2 table

- [x] **Fix v2 Trace Instrumentation** — Gate 4 PASS + ARCHIVED 2026-05-30
  - Gate 4: raw-recompute verified AC8 (real gate_result event), Layer 2 audit 3 reviewers, dream-scanner exit 0
  - gate4_delta: 1 (expert_finding parser self-triggered on review prose → false P0); Alex KA: dead-code-audit=validation-theater
  - Observational emission: hook parses HANDOFF §11 / COMPLETION gate3_verdict marker / Reflexion blocks / review files
  - FR1-6 + NFR1-4 + P1 fix (detail=full); hook never fail-closed (fault-injection verified)
  - Layer 2: code-reviewer + backend-architect (P1 resolved) + test-runner (PASS)
  - **AC8 dogfood**: first non-synthetic gate_result event emitted into real trace
  - Commit: b0e1c78
  - ⏭️ After Gate 4: run *evolve — it now has real decision-level data for the first time
  - Follow-up (out-of-scope): tighten expert_finding count to heading-only; dream-scanner try/catch hardening

- [x] **Fix *sync Directory List** — Gate 3 PASS 2026-05-30 (awaiting Alex Gate 4)
  - Added .tad/domains/ + .tad/hooks/ to alex/SKILL.md sync list (12 → 14 entries, mirrors tad.sh:115)
  - SYNC-MIRROR drift-prevention comment added
  - Commit: d94e956
  - ⏭️ After Gate 4: Alex runs *sync to push V2 trace hooks to 16 projects (6 stuck on V1)

- [x] **video-creation Pack ViMax Upgrade** — Gate 4 PASS + ARCHIVED 2026-05-27
  - 4 ViMax patterns + Photo-to-Beat-Sync (309 lines, ≤400 cap)
  - Pre/post behavioral comparison: AI correctly applies montage intent + first/last frame decomposition
  - Research notebook `79b4c4a9` (38 sources)
  - Commit: 0cc4d8b
  - gate4_delta: 3 entries (AC grep-count + verification cmd bug + Layer 2 reviewer naming drift)
  - Alex architecture knowledge: 2 new entries (AC cmd bug pattern, Layer 2 reviewer convention)

- [x] **TAD Lifecycle Health Improvements** — Gate 4 PASS + ARCHIVED 2026-05-19
  - *accept --quick, YOLO auto-archive, zombie detection (STEP 3.5+3.55), *optimize redesign
  - Commit: 816449f

- [x] **EPIC: Auto-Evolve** — 4/4 Phases COMPLETE ✅ (archived 2026-05-20)
  - Epic: `.tad/archive/epics/EPIC-20260518-auto-evolve.md`
  - Phase 1: Trace v2 schema + writer (4740def)
  - Phase 2: Blake Reflexion mode (f5489e4)
  - Phase 3: Dream scanner + auto-trigger (9b51e1b)
  - Phase 4: Optimize/Evolve v2 (b904c9c)

- [x] **Capability Pack Auto-Awareness + Sync Install** — Gate 4 PASS + ARCHIVED 2026-05-14
  - *sync step b2 installs all 8 packs to downstream projects
  - Alex step4_5 pack awareness scan across 6 modes
  - Blake 1_5a auto-detection in *develop
  - Commit: baf5618 + e28acbf

- [x] **Domain Pack Freeze + Cleanup** — Gate 4 PASS + ARCHIVED 2026-05-20
  - Archived 12 YAML, kept 9 (hw/mobile/supply-chain), deleted 6 router ecosystem files
  - startup-health.sh SKILL.md-first guard, Alex 10 refs updated, deprecation.yaml v2.17.0
  - Commit: 27a0bc6

- [x] **EPIC: Knowledge Lifecycle System (3 phases, YOLO) — ✅ COMPLETE + ARCHIVED 2026-06-02** — Epic: `.tad/archive/epics/EPIC-20260602-knowledge-layering.md`
  - TAD's 4th core subsystem (alongside Gates, Ralph Loop, Trace+Optimize)
  - P1: Sense engine in STEP 3.5 + three-layer schema + 116 entries classified (6491d73)
  - P2: Organize — 116 entries migrated to principles(13)/patterns(75,9 files)/incidents(25). CLAUDE.md @import rewired (be0cb9b)
  - P3: Maintain — Gate 4 KA auto-classify + *dream graduation(≥2) + 90-day expiration + L1 Epic protection + blame scope fix (e6bc342)
  - Token savings: CLAUDE.md now loads principles.md (~3KB) + patterns index (~1KB) instead of architecture.md (~40KB)

- [x] **knowledge-blame.sh In-Session Provenance Tool** — Gate 4 PASS + ARCHIVED 2026-06-02
  - Git-blame wrapper for querying knowledge rule provenance during implementation
  - Blake SKILL protocol (1_5_knowledge_provenance) + Layer 1 retry hint
  - Scope: project-knowledge + SKILL.md + hooks/lib (3 allowed path patterns)
  - 5 P0s fixed (pipefail crash, out-of-range, zero hash, path traversal, absolute path)
  - Commits: 9363ca6 (impl) + 5936ee3 (gate3 verdict)

- [x] **codebase-memory-mcp Integration** — Gate 4 PASS + ARCHIVED 2026-06-02
  - Persistent code knowledge graph as graph→LSP→grep three-tier fallback
  - step0_graph + step1c_lsp graph branch + expert_prompt_template hint + tad.sh install hint + integration guide
  - 5 Blake P0s fixed (unsafe examples, missing migrate path, injection defense, projects[0] assumption)
  - Commits: 11952f6 (impl) + 7a09b65 (gate3 verdict)

- [ ] **EPIC: Agent Capability Packs** — 6/9 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260507-agent-capability-packs.md`
  - 8 packs built (web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology)
  - Phase 2: Real project validation (use packs in menu-snap, measure quality delta)
  - Phase 3: Cross-agent validation (same pack on Codex)
  - Phase 4: Template extraction (CONSUMES/PRODUCES standard)

- [x] **\*dream Knowledge Consolidation** — Gate 4 PASS + PROMOTED 2026-05-14
  - architecture.md: 1125→262 lines (76% reduction), 120→60 entries
  - Safety keywords: 15→15 preserved. Foundational section byte-identical.
  - Snapshot: `.tad/archive/knowledge-snapshots/2026-05-14/`

- [ ] **EPIC: Goal-Driven Research Director** — 3/4 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260504-goal-driven-research.md`
  - Phase 3: Research-Decision Loop (decision traceability + --caller flag)

- [ ] **EPIC: Security Domain Pack Chain** — 2/5 Phases Done (paused)
  - Epic: `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md`
  - Phase 2-4: Paused — run real-project security audit first to validate value

## Pending

- [x] **Distribute pack-quality upgrades: v2.30.0 published + synced ✅ 2026-06-15** — v2.30.0 on GitHub (tag pushed) + synced to all 14 projects (registry → 2.30.0). Bundles pack-quality 21-pack upgrades + AI-Native Reading Companion Epic + Tier-1 workflows + detect_state/workflow-schema fixes. Sync evidence: `.tad/evidence/releases/sync-v2.30.0.{sh,log}` + repair. **⚠️ Sync caught a real bug (fixed this round):** the sync ran `install.sh --force` AFTER the skills mirror, and install.sh regenerated stale SKILL.md from the un-updated `.tad/capability-packs/` source → DOWNGRADED 21 packs' `.claude/skills` in all 14 projects (`.agents` was correct). Caught by the platform-skills symmetry gate; repaired via re-mirror (`sync-v2.30.0-repair.sh`, all 14 → platform-skills PASS). KA → patterns/pack-build-rules.md.
- [x] **P1 root-cause fix: pack install.sh single-source + sync ordering ✅ 2026-06-15** — Two compounding bugs surfaced by the v2.30.0 sync (see KA pack-build-rules 2026-06-15): (1) `.tad/capability-packs/{pack}/` is a SECOND source-of-truth for pack content that the pack-quality Epic never updated (it edited `.claude/skills/{pack}` directly) → install.sh regenerates stale SKILL.md; (2) the sync script runs install.sh AFTER the authoritative mirror, letting the stale regen clobber it. Fix: make install.sh COPY from the gold `.claude/skills/{pack}` (single-source), OR drop the redundant install.sh step from sync (the `cp -R` mirror already carries everything), OR re-sync `.tad/capability-packs/` during pack upgrades. Until fixed, every future sync re-introduces the downgrade unless the repair re-mirror runs after.
- [ ] Run *optimize on menu-snap (14 trace files) to analyze execution patterns
- [ ] Run *evolve cross-project (5 projects with traces, 50+ trace files total)
- [ ] Test Agent Teams on next Full or Standard TAD task
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.)

## Ideas (16 active — 8 archived 2026-05-14)

- [ ] IDEA-20260613-tad-opt-in-mode-posture: TAD as opt-in mode (CLAUDE.md posture flip) — PARKED (concern: loosening default may erode explicit-invoke strictness)

Domain Pack related (input for Freeze + Rebuild):
- [ ] IDEA-20260508-deprecate-domain-pack-yaml: Deprecate YAML format entirely
- [ ] IDEA-20260427-domain-pack-taxonomy-reorg: Horizontal vs vertical reorganization
- [ ] IDEA-20260402-domain-pack-monthly-refresh: Monthly tool freshness refresh
- [ ] IDEA-20260402-self-evolving-domain-pack: Auto-improvement from traces

Framework infrastructure:
- [ ] IDEA-20260401-tad-self-test-agent: Automated TAD behavior validation
- [ ] IDEA-20260402-deerflow-patterns: Borrow patterns from DeerFlow 2.0
- [ ] IDEA-20260403-config-env-override: Environment variable config override
- [ ] IDEA-20260403-hook-timeout-config: Hook timeout control
- [ ] IDEA-20260403-session-health-check: Framework component integrity check

Skill ecosystem:
- [ ] IDEA-20260407-local-skill-capture: Local skill capture mechanism
- [ ] IDEA-20260407-cross-project-skill-harvest: Cross-project skill promotion

From ECC research (2026-05-27):
- [ ] IDEA-20260527-dream-auto-scope: Dream scanner auto-scope via git remote hash + 2-project promotion
- [ ] IDEA-20260527-codex-adapter-yaml: Capability pack Codex YAML adapter (6-line openai.yaml)
- [ ] IDEA-20260527-tad-methodology-skeleton: TAD universal methodology skeleton (domain-agnostic process)

From OpenCode research (2026-05-28):
- [ ] IDEA-20260528-declarative-agent-constraints: Declarative agent constraints — separate config from judgment (OpenCode pattern)

From Perplexity SaC research (2026-06-02):
- [ ] IDEA-20260602-sac-thin-protocol-thick-tools: Thin protocol + thick tools evolution — revisit when SaC SDK/benchmarks open-source

Human-AI feedback loop (2026-06-10):
- [ ] IDEA-20260610-structured-feedback-collector: Structured Feedback Collector — HTML-based human judgment interface for non-code artifacts (frontend pages, audio, video, brands). AI generates artifact + review interface; human gives structured feedback via HTML; JSON flows back to AI. Proven in Colin voice project (3 working prototypes).

From html-anything research (2026-05-27):
- [x] IDEA-20260527-pack-behavioral-examples: Promoted → Handoff 2026-05-27
- [ ] IDEA-20260527-agent-adapter-pattern: Unified agent detection + invocation protocol (TAD 跨 agent 运行基础设施)
- [x] **Pack Behavioral Examples Framework** — Gate 4 PASS + ARCHIVED 2026-05-27
  - Fixture format spec + install.sh examples/ copy + 2 video-creation dogfood fixtures
  - Dogfood: Fixture A 9/4 markers, Fixture B 8/3 markers (raw-TSV recompute matched)
  - Commit: 9993ce7

## Recently Completed

- [x] **AI Voice Production Capability Pack** — Gate 4 PASS + ARCHIVED 2026-05-28
  - 7 files, 966 lines (SKILL.md router + 6 references), 13 TTS tools covered
  - Research: NotebookLM e2f862c7 (26 sources, 5 ask rounds)
  - Expert review: 2 pre-handoff (code-reviewer + backend-architect, 6 P0 fixed) + 3 post-impl (Blake Layer 2)
  - Commit: c119d1f
  - Reference-based pack: SKILL.md + 6 references (966 lines total)
  - 13 TTS tools (9 Tier A benchmarked + 7 Tier B notable), 26 NotebookLM sources
  - 3 P0 fixed (fabricated durations, non-research terminology, missing research tools)
  - Awaiting Alex Gate 4

- [x] **Research Adversarial Challenge Layer** — Gate 4 PASS 2026-05-14, commit 8ea1eed
  - 3 challenge points (0c plan / 4c findings / 5b actions) with Codex+Gemini dual-model review
  - AskUserQuestion gate per challenge, CHALLENGE_INSTRUCTION constant, fail-closed rating extraction
  - Experiment mode: first 3 runs compare both models

### 2026-05-14 cleanup

- [x] **EPIC: Cross-Model Orchestration — ALL 4/4 PHASES COMPLETE** — Archived 2026-05-14 (validated via menu-snap 4 notebooks, 646 sources)
- [x] **v2.14.0 released + synced to 14 projects** — YOLO Mode + LSP Code Understanding (2026-05-14)
- [x] **EPIC: YOLO Mode — ALL 3 PHASES COMPLETE** — Dogfood 39/39 PASS on menu-snap
- [x] **LSP Code Understanding Integration** — 12-language plugin map, auto-provision
- [x] **NotebookLM Research Upgrade (5 tasks)** — add-smart, dynamic research, methodology upgrade
- [x] **8 Capability Packs built** — web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology
- [x] **Pack Integration & Migration** — 7 packs to .tad/capability-packs/ + pack-registry.yaml
- [x] **EPIC: Codex CLI Adaptation — ALL 3 PHASES** — launchers + AGENTS.md + dogfood
- [x] **EPIC: GitHub Knowledge Integration — ALL 3 PHASES** — 24 domains, 50 awesome-lists, weekly scan
- [x] **EPIC: NotebookLM Research Director — ALL 4 PHASES** — 19 commands, E2E 6/6 PASS
- [x] **EPIC: TAD Self-Upgrade from Cross-Project Learning — ALL 6 PHASES**
- [x] Earlier: see [docs/HISTORY.md](docs/HISTORY.md)

## Blocked

(none)

---

> 8 Ideas archived 2026-05-14: linear-auto-sync, linear-kanban, domain-pack-framework, tad-universal-method (promoted), cross-model-orchestration (promoted), goal-driven-research-director (promoted), research-methodology-upgrade (done), epic-auto-conductor (done as YOLO)
> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
