# Epic: Lean & Trustworthy TAD

**Epic ID**: EPIC-20260531-tad-lean-trustworthy
**Created**: 2026-05-31
**Owner**: Alex

---

## Objective
Make TAD leaner (lower fixed session/compact cost) and its data layer trustworthy, by fixing two confirmed silent-corruption/desync bugs, applying progressive disclosure to the always-loaded protocol, hardening the recurring AC-verification failure, and proving each capability pack actually changes agent behavior. Grounded in 5 internal audits + a NotebookLM agent-framework-landscape re-query (2026-05-31) that converge on: "frameworks that get out of the way survive."

## Success Criteria
- [ ] Trace decision corpus is no longer silently corrupted (4-col handoff tables parse correctly).
- [ ] No installed capability pack is invisible to Alex/Blake auto-detection; a drift-check prevents recurrence.
- [ ] alex/SKILL.md always-loaded body reduced ≥40% (≤~3,500 lines) with ZERO constraint-rule loss (byte-identity verified).
- [ ] Recurring AC-verification-drift subset is caught by an advisory linter at step1d.
- [ ] All 16 installed packs have ≥1 behavioral fixture and a runner that proves marker coverage.
- [ ] Every phase passes Gate 3 + Gate 4; SAFETY guards (AR registry, forbidden_implementations, MUST/VIOLATION lines) held throughout.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Trace producer §11 fix + dead-candidate purge | ✅ Done | HANDOFF-20260531-tad-lean-trustworthy-phase1.md (85fe0a9) | column-name-aware decision parser; 6 dead shells purged |
| 2 | Pack registry desync fix + drift-check | ✅ Done | HANDOFF-...phase2.md (b95a577 + 35b5a60) | ai-voice source-dir-ified; registry 14→16; drift-check; all 16 packs real consumes/produces |
| 3 | alex/SKILL.md progressive disclosure (path protocols) | ✅ Done | HANDOFF-...phase3.md (7c5a59f + 1216bac) | OPTION A: 9 token-free protocols → references; 6441→5825 (~9.6%); constraint count 131 unchanged; byte-identical |
| 4 | §9.1 AC-command linter | ✅ Done | HANDOFF-...phase4.md (eb53ee7 + fd6e1a5) | advisory verify-ac-commands.sh @ step1d; Rule A/B precise; revealed 34 latent bugs in shipped handoffs |
| 5 | Capability pack behavioral eval runner + 16-pack fixtures | ✅ Done | HANDOFF-...phase5.md (68c85a1 + 2311f9e + 4e88bff) | runner + 16 fixtures + DISCRIMINATIVE gate; 2 packs verified via WITH-vs-CONTROL delta; theater caught + killed |

### Phase Dependencies
P1, P2 independent (either order). P3 independent. P4 after P3 (both touch alex/SKILL.md; sequential avoids conflict — P4 modifies step1d which P3 leaves inline). P5 after P2 (writes behaviorally_verified flag into the registry P2 just regenerated). Executed sequentially P1→P2→P3→P4→P5 via full-auto YOLO.

### Derived Status
- **Status**: Planning (all ⬚)
- **Progress**: 0/5

---

## Phase Details

### Phase 1: Trace producer §11 fix + dead-candidate purge

**Status:** ✅ Done (85fe0a9)
**Execution:** YOLO (full-auto) — Gate 3+4 PASS; 2 design + 2 impl reviewers, all raw-recomputed
**Follow-up (Y8 KA):** multi-table §11 only parses first table (pre-existing, not regression) — per-table havehdr re-bind = future fix (also fixes §11.3 disposition over-emit + contrived spurious-bind). → NEXT.md Deferred.

#### Scope
Make `emit_decision_points()` in `.tad/hooks/post-write-sync.sh` column-NAME-aware: parse the Decision Summary table header row, locate the `Decision`/`Chosen`/`Rationale` columns by name, and map dynamically — replacing the hardcoded positional `d=a[3]; c=a[5]; r=a[6]` (line 188) which silently corrupts every variable-column (e.g. 4-col) handoff table. Also purge the 6 rejected content-free dream-candidate shells. NOT in scope: re-emitting/repairing historical corrupted trace events (append-only — annotate a cutoff date only); changing the trace JSON schema; touching the dream-scanner Pass C consumer (it already reads chosen/rationale correctly — the bug is upstream in the producer).

#### Input
Verified bug at `post-write-sync.sh:173` (comment) + `:188` (hardcoded indices). Two archived handoffs as test corpus: `HANDOFF-20260531-research-engine-wire-phase4.md` (4-col table → currently corrupted) and `HANDOFF-20260530-trace-instrumentation-fix.md` (5-col → currently correct). 6 dead candidates `.tad/active/dream-candidates/CAND-2026-05-30-16115*.md` (all status: rejected).

#### Output
A header-aware `emit_decision_points()`; 6 dead candidate files removed; dream-state counts reconciled.

#### Acceptance Criteria
- [ ] AC1.1: `emit_decision_points()` reads the header row, finds `Decision`/`Chosen`/`Rationale` column indices by name (case-insensitive trim), maps dynamically; falls back gracefully (skip, no junk emit) if a required column name is absent.
- [ ] AC1.2: Dry-run on the 4-col handoff (`research-engine-wire-phase4`) emits a decision_point with NON-empty `chosen` AND `rationale` matching the actual table cells (was: rationale empty + chosen=wrong column). Dry-run on the 5-col handoff still parses correctly (no regression). Paste both raw outputs.
- [ ] AC1.3: 6 rejected `CAND-2026-05-30-16115*.md` deleted; dream-state.yaml total_rejected/counts reconciled; zero pending candidate touched.
- [ ] AC1.4 (SAFETY): hook never fail-closed — every parse path keeps `|| true`; malformed/missing header → graceful skip with no junk decision_point event (verify with a fault-injected malformed table).

#### Files Likely Affected
- `.tad/hooks/post-write-sync.sh` (MODIFY — emit_decision_points + header parse)
- `.tad/active/dream-candidates/CAND-2026-05-30-16115201..06.md` (DELETE — 6 files)
- `.tad/hooks/lib/dream-state.yaml` or equivalent (MODIFY — count reconcile, if present)

#### Dependencies
None (can execute independently).

#### Notes
Highest data-integrity leverage; cheapest fix. Re-derive AC1.2 from real trace events (Gate 4 raw-recompute). This recurs the project's own ".router.log 5-Tuple load-bearing contract" + "Parser must propagate VALUE fields" lessons — the contract moved from scanner to producer.

### Phase 2: Pack registry desync fix + drift-check

**Status:** ✅ Done (b95a577 + 35b5a60)
**Execution:** YOLO — Gate 3+4 PASS; 2 design + 2 impl reviewers. ai-voice full source-dir-ified (Tier1+Tier2), registry 14→16, advisory type-probe drift-check (no allowlist rot), all 16 packs now have real consumes/produces.
**Follow-up (→NEXT.md):** add `type:` to product-thinking/research-methodology installed SKILLs (type-probe symmetry); drift-check SKILLS_DIR layout note + optional SessionStart wiring; pack-build checklist must require source-dir from start.

#### Scope
Regenerate `.tad/capability-packs/pack-registry.yaml` (via `.tad/scripts/scan-packs.sh`) so `ai-voice-production` (installed at `.claude/skills/ai-voice-production/SKILL.md` but ABSENT from registry → invisible to Alex step4_5 / Blake 1_5a) becomes discoverable with proper keywords. Resolve `ml-training` (source dir without a `.claude/skills/ml-training/SKILL.md` → must not be advertised as activatable). Add a bidirectional drift-check script (installed-SKILL-set ⇄ registry-names) and wire it into a SessionStart advisory + release-runbook. NOT in scope: authoring ml-training's content; behavioral verification (Phase 5); collision detection.

#### Input
Confirmed: registry lists 14 packs, ai-voice-production missing; ml-training has no SKILL.md; `scan-packs.sh` exists at `.tad/scripts/scan-packs.sh`; registry `last_scanned: 2026-05-15`.

#### Output
Regenerated registry including ai-voice-production; ml-training resolved (entry removed or flagged source-only); a `pack-registry-driftcheck.sh`; runbook + SessionStart wiring.

#### Acceptance Criteria
- [ ] AC2.1: `ai-voice-production` appears in pack-registry.yaml with non-empty keywords; an LLM-semantic match on a voice/TTS task would now surface it (sanity-grep the entry).
- [ ] AC2.2: No registry entry advertises a pack lacking a `.claude/skills/{name}/SKILL.md` (ml-training removed from advertised set or explicitly marked `installable: false`).
- [ ] AC2.3: `pack-registry-driftcheck.sh` exits 0 when registry-names == installed-SKILL set (both directions); exits 1 + prints the offending names when mismatched — verify by injecting a temp fake mismatch then reverting.
- [ ] AC2.4: registry `last_scanned` bumped to 2026-05-31; drift-check is advisory (never blocks a session).

#### Files Likely Affected
- `.tad/capability-packs/pack-registry.yaml` (MODIFY — via scan-packs)
- `.tad/scripts/scan-packs.sh` (MODIFY — only if it misses ai-voice-production)
- `.tad/hooks/lib/pack-registry-driftcheck.sh` (CREATE)
- `.claude/skills/release-runbook/SKILL.md` (MODIFY — add drift-check to pre-flight)

#### Dependencies
None (can execute independently).

#### Notes
A pack is silently dead today. Cheap correctness win. Drift-check follows the "smoke alarm not fire suppressor" + drift-detector-allowlist patterns.

### Phase 3: alex/SKILL.md progressive disclosure (path protocols only)

**Status:** ✅ Done (7c5a59f + 1216bac) — OPTION A (user-chosen after honest_partial surfaced AC3.1×AC3.2 conflict)
**Execution:** YOLO — Gate 3+4 PASS; 2 impl reviewers raw-recomputed all 9 byte-identity diffs. 9 token-free protocols → references/, 6441→5825 (~9.6%), constraint count 131 UNCHANGED. research_plan/express/experiment left INLINE (constraint-bearing; ≤3500 needs OPTION B reframe — deferred to NEXT.md).

#### Scope
Extract the mutually-exclusive, intent-gated PATH PROTOCOLS from `alex/SKILL.md` into self-contained `.claude/skills/alex/references/path-*.md` files, loaded on-demand when `intent_router_protocol` step4 routes to that mode. Targets (verified line ranges): bug_path_protocol (754), discuss_path_protocol (838), idea_path_protocol (1887), learn_path_protocol (2036), express_path_protocol (2133), experiment_path_protocol (2223), plus research_plan_protocol + research_review_protocol. The always-loaded core stays INLINE: activation, intent_router, adaptive_complexity, socratic_inquiry, research_decision, design, handoff_creation, acceptance, YOLO, **anti_rationalization_registry, all forbidden_implementations, every MUST/VIOLATION/MANDATORY constraint line**. NOT in scope (HARD): touching/moving/rewording ANY constraint rule, AR registry, or forbidden_implementations block (v2.7 quality-chain-failure SAFETY); merging the 18 forbidden_impl blocks (the rejected aggressive option); any semantic change to a protocol body (extraction must be byte-preserving).

#### Input
alex/SKILL.md = 6,441 lines; ~1,576 lines are path protocols (754→2330). references/ convention already exists. The anti_rationalization_registry has an awk-extractable BEGIN/END contract + an extract-file fixture (AC4 in its own doc).

#### Output
8 `references/path-*.md` files (byte-preserved protocol bodies); alex/SKILL.md with path-protocol bodies replaced by a pointer + an intent_router step4 "Read the reference" instruction; always-loaded body ≤~3,500 lines.

#### Acceptance Criteria
- [ ] AC3.1: always-loaded alex/SKILL.md ≤ 3,500 lines (from 6,441; target ~3,000), and the removed content is byte-preserved in references (concat of extracted bodies == original bodies; diff empty).
- [ ] AC3.2 (SAFETY, BLOCKING): the anti_rationalization_registry awk-extract still byte-matches its extract-file fixture; `grep -c` of `MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|NOT_via_alex_auto` in the always-loaded SKILL.md is UNCHANGED before vs after (these all live in always-loaded sections, not in extracted path protocols) — paste both counts.
- [ ] AC3.3: intent_router_protocol step4 routing to each of {bug,discuss,idea,learn,express,experiment} (and research-plan/review entrypoints) includes an explicit `Read .claude/skills/alex/references/path-{mode}.md` instruction; each reference file is self-contained (full protocol body, no dangling cross-refs).
- [ ] AC3.4: round-trip per mode — `diff <(extracted reference body) <(original block from git HEAD)` == identical for all 8 protocols.
- [ ] AC3.5 (SAFETY): no path protocol that CONTAINS a constraint rule (e.g. express_path_protocol's AR-001 hard-guarantee at ~2160, forbidden_implementations) is extracted in a way that removes that constraint from a session that uses *express — the express/experiment forbidden_implementations + required_steps travel WITH the reference AND a 1-line constraint summary stays inline at the router.

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — replace 8 path-protocol bodies with pointers; add step4 load instructions)
- `.claude/skills/alex/references/path-bug.md`, `path-discuss.md`, `path-idea.md`, `path-learn.md`, `path-express.md`, `path-experiment.md`, `path-research-plan.md`, `path-research-review.md` (CREATE)

#### Dependencies
None for execution, but is the SAFETY-sensitive phase — heaviest ACs. Even under full-auto YOLO, the Y4/Y6 reviewers MUST enforce AC3.2/AC3.4/AC3.5 byte-identity; a constraint-rule count delta = Gate FAIL.

#### Notes
v2.7 trap is the live risk. Conservative scope chosen by user. Byte-identity is the mechanical guard substituting for the "human pause" that full-auto skips. Blake side: Codex-edition alex skill (.tad/codex/) follows strip-only rule — if it mirrors path protocols, update consistently or note divergence.

### Phase 4: §9.1 AC-command linter

**Status:** ✅ Done (eb53ee7 + fd6e1a5)
**Execution:** YOLO — Gate 3+4 PASS; 2 impl reviewers ran the linter on 14+ real handoffs. Rule A 100% precision (caught real vimax bug); Rule B surfaced 34 latent literal-pipe-in-ERE bugs across already-shipped handoffs. Calibration removed Rule C 218-hit noise. Advisory, never blocks.
**Follow-up (→NEXT.md):** 34 Rule-B latent bugs in shipped handoffs could be swept; "advisory INFO rules need real-volume calibration" KA candidate.

#### Scope
Build `.tad/hooks/lib/verify-ac-commands.sh`: scan a handoff's §9.1 Spec Compliance verification commands for the FINITE, evidence-grounded set of recurring dangerous patterns and warn (advisory only). Seed rules ONLY from patterns that actually recurred ≥2× in handoff/trace history: (a) `grep -c` combined with `sort -u | wc -l` (2026-05-27 grep-ocE bug — always returns 1); (b) literal `\|` inside `grep -E` (markdown-pipe-escape leak); (c) single-file `grep -n` output-shape assumptions; (d) sentinel/marker substring self-leak. Wire as the LAST action of Alex step1d, warn-and-continue. NOT in scope (HARD): blocking ANY tool call or returning a deny exit (single-user CLI lesson — forbidden); generic/speculative lint rules; auto-fixing commands; registering as a settings.json hook.

#### Input
The recurring AC-verification-drift pattern (code-quality.md 2026-05-27 entry); step1d already exists in handoff_creation_protocol; "smoke alarm not fire suppressor" doctrine; "ad-hoc audit tools are themselves validation theater" lesson (rules must cite real recurrences).

#### Output
`verify-ac-commands.sh` (advisory linter); step1d wiring (warn, continue); each rule cites its motivating handoff.

#### Acceptance Criteria
- [ ] AC4.1: linter flags the `grep -ocE 'a|b|c' file | sort -u | wc -l` pattern on a fixture handoff and prints the corrected form (`grep -oE ... | sort -u | wc -l`), citing HANDOFF-20260527-vimax... as the recurrence source.
- [ ] AC4.2: linter is advisory — its exit code never blocks; step1d wiring is explicitly "warn, continue"; contains a forbidden_implementations block (MUST NOT register as hook / settings.json / deny exit) symmetric to step1c/step1d.
- [ ] AC4.3: each lint rule embeds a comment citing a handoff where the pattern recurred ≥2× — no speculative rules (verify by reading the script).
- [ ] AC4.4: false-positive guard — a correct `grep -oE 'a|b|c' file | sort -u | wc -l` does NOT trip the grep-c rule; a correct table-escaped `\|` inside a markdown cell (not a grep -E arg) is not flagged.

#### Files Likely Affected
- `.tad/hooks/lib/verify-ac-commands.sh` (CREATE)
- `.claude/skills/alex/SKILL.md` (MODIFY — step1d adds advisory invocation at end)

#### Dependencies
Phase 3 (both touch alex/SKILL.md; P3 leaves step1d inline, so P4's step1d edit is conflict-free after P3 lands).

#### Notes
Catches only the lintable recurring SUBSET; the general AC-drift case stays inherent (that's why step1d dry-run exists). BSD-safe regex (no grep -P). Must itself be dry-run on a representative §9.1 before shipping (don't recurse the very bug it lints).

### Phase 5: Capability pack behavioral eval runner + 16-pack fixtures

**Status:** ✅ Done (68c85a1 + 2311f9e + 4e88bff)
**Execution:** YOLO — Gate 3+4 PASS; 2 impl reviewers caught the v1 runner reproducing validation theater (no-pack CONTROL passed the combined-marker gate 3/3). Fix: DISCRIMINATIVE gate (pack-specific markers only). Proof: ai-evaluation CONTROL now FAILS disc 0/3. 2 packs (ai-evaluation, code-security) verified via clean WITH-vs-CONTROL delta; web-backend honestly held pending (markers too common). 16 fixtures + runner + side-file status tracker.
**Follow-ups (→NEXT.md):** run remaining 12 packs' WITH+CONTROL eval; tighten web-backend (+others) discriminative_pattern to pack-unique terms; bake control-run requirement into runner --all.

#### Scope
Build the missing fixture RUNNER and author behavioral fixtures for ALL 16 installed packs. Runner: feed each fixture's Input Scenario to a sub-agent WITH the pack loaded, run the fixture's grep verification command, assert `min_marker_count`, report pass/fail. Fixtures: ≥1 per installed pack (target 2 for high-value packs), using the existing `.tad/templates/pack-example-fixture.md` format with DISCRIMINATIVE ❌-markers (anti-gaming). Add a `behaviorally_verified` flag per pack to the registry. NOT in scope: LLM-judge Spearman calibration (future); CI/CD integration beyond a manually-run script; collision detection; rewriting pack content (only measuring it).

#### Input
Fixture format spec `.tad/templates/pack-example-fixture.md`; 2 existing real fixtures in `.claude/skills/video-creation/examples/`; NotebookLM evidence that behavioral eval = LLM-judge + CI pass@k is the proven shape; user chose ALL 16 packs + full-auto (usage-heavy phase, accepted).

#### Output
`pack-eval-runner.sh`; ≥16 new fixtures across all installed packs; per-pack `behaviorally_verified` flag in registry; raw runner output saved as evidence.

#### Acceptance Criteria
- [ ] AC5.1: `pack-eval-runner.sh` — given a fixture path, spawns a sub-agent with the pack loaded, runs the fixture's grep verification command against the sub-agent output, asserts `min_marker_count`, emits PASS/FAIL + marker count. Demonstrated on the 2 existing video-creation fixtures (reproduce their stated 9/4 and 8/3 marker counts, raw-recompute).
- [ ] AC5.2: every installed pack (the full set from `ls .claude/skills/*/SKILL.md`, ~16) has ≥1 behavioral fixture with discriminative ❌-markers; count fixtures == count packs (no pack skipped).
- [ ] AC5.3: runner executed across all fixtures; results table saved to `.tad/evidence/pack-eval/{date}/results.md`; failures surfaced explicitly (not hidden); a defined pass threshold stated and the actual pass rate reported.
- [ ] AC5.4: `pack-registry.yaml` gains a `behaviorally_verified: true|false` field per pack set from the runner result; raw runner stdout saved as evidence (count ≠ signal — the raw output is the proof).

#### Files Likely Affected
- `.tad/scripts/pack-eval-runner.sh` (CREATE)
- `.claude/skills/{pack}/examples/*.md` (CREATE — ~16+ fixtures across all packs)
- `.tad/capability-packs/pack-registry.yaml` (MODIFY — behaviorally_verified flag; depends on P2's regenerated registry)
- `.tad/evidence/pack-eval/2026-05-31/results.md` (CREATE)

#### Dependencies
Phase 2 (writes behaviorally_verified into the registry P2 regenerated). Highest usage-cost phase (sub-agent per fixture × 16+).

#### Notes
Anti-gaming is the real risk: fixtures whose markers a frontier LLM produces WITHOUT the pack are theater. Discriminative ❌-markers + an honest pass threshold mitigate. Watch "Parser Self-Trigger" — fixture prose must not quote the marker patterns the grep counts.

---

## Context for Next Phase
(Alex updates after each phase via YOLO step_Y7/Y8.)

### Completed Work Summary
- (none yet)

### Decisions Made So Far
- Scope: all 5 phases, leverage order P1→P5 (user, 2026-05-31).
- YOLO autonomy: FULL AUTO (user override of Alex's semi-auto recommendation; P3 risk mitigated by mandatory byte-identity ACs instead of a human pause).
- P3 aggressiveness: CONSERVATIVE — path protocols only; constraint rules / AR registry / forbidden_impl untouched (user, SAFETY).
- P5 coverage: ALL 16 packs (user; usage-heavy accepted).
- Epic cap: created under override (3 active Epics already at max; the 3 are stalled/paused — addressed separately).

### Known Issues / Carry-forward
- Deferred items from 2026-05-31 debt bundle (classify_scope word-boundary, version-scheme, semantic dedup, detect_state glob, express frontmatter marker) are NOT in this Epic — separate backlog.
- *sync to 14 projects is OUT of this Epic (outward-facing; needs explicit authorization).

### Next Phase Scope
Phase 1 — trace producer §11 column-contract fix + dead-candidate purge.

---

## Notes
Grounded in 5 internal audits (self-evolution / capability-packs / research-engine / core-workflow / generalization) + NotebookLM tad-evolution-research re-query 2026-05-31 (findings: `.tad/evidence/research/tad-evolution-refresh/2026-05-31-optimization-requery-findings.md`). External + internal converge: lean the always-loaded protocol, fix data integrity before building more, prove packs behaviorally, don't spin a 2nd product yet.
