# Gate ROI Measurement — Do TAD's Quality Gates Catch Real Defects?

**Date**: 2026-07-12
**Task**: TASK-20260705-001 (Epic EPHEMERAL-surplus-gate-roi-measurement, Phase 1/1)
**Spec**: `.tad/active/handoffs/HANDOFF-surplus-gate-roi-measurement.md` v3.3.0
**Analyst**: Blake (Agent B). Scope note: this report measures the BENEFIT side of gate ROI (defect-catch effectiveness) only; gate COST is explicitly unmeasured (see Limitations).

## Method

### 1. Sampling frame (FR1, catch-agnostic)

Frame rule (restated from FR1): Population = the FULL census of `.tad/archive/handoffs/COMPLETION-*.md` at implementation time, name-sorted, EXCLUDING only this Epic's own bookkeeping files. Sample = every 7th file starting at index 1 — deterministic, reproducible, and NOT conditioned on any gate event, P0 mention, or fix log existing. The Epic-bookkeeping exclusion is applied as a PRE-FILTER before sampling; **0 files matched the exclusion** (this Epic has no archived COMPLETION), so the pre-filter removed nothing. Trace `gate_result` events are used ONLY as per-row ANNOTATION (did this handoff hit a formal gate, per traces?), never as a selector. Zero-catch COMPLETIONs stay in the sample as `none` rows.

Census denominator = **189** COMPLETION files (measured at implementation time, 2026-07-12). Exact sampling command:

```
ls .tad/archive/handoffs/COMPLETION-*.md | sort | awk 'NR%7==1'
```

189 / 7 → **27 sampled files (27/189, 14.3% of census)**, assigned GR-01..GR-27 in name-sorted order. The frozen sample list (verbatim output of the command above):

```
.tad/archive/handoffs/COMPLETION-20260126-blake-ralph-fusion.md
.tad/archive/handoffs/COMPLETION-20260402-tad-v28-trace-infrastructure.md
.tad/archive/handoffs/COMPLETION-20260404-domain-pack-integration.md
.tad/archive/handoffs/COMPLETION-20260414-plain-language-after-handoffs.md
.tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
.tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md
.tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md
.tad/archive/handoffs/COMPLETION-20260505-research-capability-polish.md
.tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
.tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md
.tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
.tad/archive/handoffs/COMPLETION-20260515-capability-pack-web-testing.md
.tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md
.tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
.tad/archive/handoffs/COMPLETION-20260530-sync-directory-list-fix.md
.tad/archive/handoffs/COMPLETION-20260531-pack-collision-detection-phase2.md
.tad/archive/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase3.md
.tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
.tad/archive/handoffs/COMPLETION-20260603-declarative-constraints-v01.md
.tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
.tad/archive/handoffs/COMPLETION-20260608-skill-slim-phase1.md
.tad/archive/handoffs/COMPLETION-20260609-migration-schema-phase1.md
.tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
.tad/archive/handoffs/COMPLETION-20260610-publish-gate-phase5.md
.tad/archive/handoffs/COMPLETION-20260611-release-v2.29.1.md
.tad/archive/handoffs/COMPLETION-20260617-research-input-quality.md
.tad/archive/handoffs/COMPLETION-20260702-trajectory-eval-p2.md
```

Frame survivorship note (expanded in Limitations): the population is completed handoffs only; cancelled/abandoned work and express edits without COMPLETIONs are outside the frame.

### 2. Pre-registered decision rule (FR7, STRICT tier, human-selected 2026-07-12)

Definitions: S = sample size; NC = number of samples with >=1 caught defect whose counterfactual is broken-ship or silent-degradation; NC% = NC/S; P01 = total P0+P1 gate-caught defects across the sample; Z = none-row count / S.

Rule (restated verbatim, registered BEFORE classification): net-positive iff NC% >= 25% AND P01 >= 10; net-negative iff NC% <= 5%; net-neutral otherwise

Recommendation mapping: net-positive → GO (= proceed to revisit the 2026-04-15 mechanical-enforcement decision with these numbers, next step being cost-side measurement); anything else → NO-GO (the 2026-04-15 prior stands).

### 3. Threshold provenance (FR7 disclosure)

The rule was registered 2026-07-12 knowing the population P0-mention rate (137/184 ≈ 74% at design time) but BEFORE any per-sample counterfactual classification existed. Disclosure: given that density, the P01 >= 10 conjunct is expected-satisfied by construction — the **operative discriminator is NC%**, which rides entirely on the counterfactual axis (unknown at registration, rubric-constrained via the handoff §4.3 rubric + the FR8 independent spot-check). The reader must not be led to believe two independent gates must clear: in practice only the NC% threshold discriminates.

### 4. Trace annotation (annotation only — never a selector)

Annotation command:

```
cat .tad/evidence/traces/*.jsonl | jq -r 'select(.type=="gate_result") | [.slug,.context,.outcome] | @tsv' | sort -u
```

Coverage: traces record `gate_result` only from 2026-05-19 onward. Of the 27 sampled slugs, **9** have a matching `gate_result` event, all `Gate 3 … pass`: declarative-constraints-v01, migration-schema-phase1, pack-collision-detection-phase2, release-v2.29.1, self-deriving-release-sync-phase2, skill-slim-phase1, tad-lean-trustworthy-phase3, trajectory-eval-p2, yolo-workflow-p3. The remaining 18 rows have no trace event (11 pre-date trace coverage; 7 post-2026-05-19 rows — e.g. dual-platform-parity-fix, publish-gate-phase5, research-input-quality — show a trace-emission gap despite `gate3_verdict: pass` frontmatter). Annotation coverage is partial; all defect evidence comes from file content.

### 5. Extraction and counting rules applied

- Every sampled COMPLETION file was **read in full** (Read tool, whole file), then defect logs located with `grep -nE 'P0|P1|P2' <file>` as a cross-check. Where a COMPLETION referenced its Gate 2 Audit Trail or a review evidence file without restating content, that referenced file was read too:
  - `grep -n -A 30 -i 'audit trail' .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md` (GR-04 Gate 2 findings)
  - `.tad/evidence/reviews/blake/migration-schema-phase1/code-review.md` (GR-22 P0/P1 enumeration)
- A "gate-caught defect" = any P0/P1/P2 recorded as found by Gate 2 expert review, Gate 3 verification (Layer 1 AC-run/dogfood or Layer 2 expert review), or Gate 4 acceptance BEFORE ship. Bugs found after archive/ship do NOT count as catches (they are false negatives → Limitations).
- Dedup (handoff §4.3): the same defect recorded in both a HANDOFF Audit Trail and its COMPLETION fix log — or by two reviewers ("same fix as", "already fixed from", "CR/BA-" shared IDs) — is counted ONCE. Explicit dedups applied: GR-11 (BA P0-3 = CR P0-1/P0-2 state-machine fix), GR-20 (BA P0-3 = CR P0-2), GR-09 (CR/BA-P1-3 shared finding).
- Reviewer findings explicitly resolved as NON-defects were excluded: false positives (GR-10 BA P0-1), "acknowledged as expected behavior" (GR-13 BA P1-1), "design decision, not bug" (GR-19 P1-1/P1-2), "acceptable deviation / design choice" (GR-22 MIG-10/MIG-11), transient working-tree churn (GR-23 re-drift during verification).
- Aggregate-count-only findings: where the record states a per-reviewer severity count (e.g. "P1=3") without restating content, each such defect is counted individually with a generic description, its counterfactual is classified DOWN to `cosmetic` per tie-break 3, and it is flagged `low-confidence`. This biases NC% against the gates, never for them.
- Severity-untagged catches (e.g. dogfood-caught bugs, "I-n" findings): counted conservatively as P2 (biasing P01 downward). Noted per bullet.
- Counterfactual classification uses the handoff §4.3 rubric (broken-ship / silent-degradation / cosmetic / none) with its tie-breaks, including tie-break 2 (a cosmetic-looking defect in a VERIFICATION artifact — AC, fixture, schema, gate/audit script, judge prompt — that weakens what the verification proves is `silent-degradation`) and tie-break 3 (thin evidence → classify DOWN + flag `low-confidence`). Classification is by counterfactual AT SHIP TIME, not eventual outcome.
- Zero-catch handoffs appear as explicit `none` rows — they are the no-gate-baseline signal; dropping them would fake the ROI upward.

## Sample Table

Columns: row ID, handoff slug, gate/review stage(s) that ran, defects caught (count), max severity, counterfactual (worst across the row's defects), evidence file.

| GR-## | slug | stages | defect_count | max_severity | counterfactual | evidence_file |
|-------|------|--------|--------------|--------------|----------------|---------------|
| GR-01 | blake-ralph-fusion | Gate3-L2 | 3 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260126-blake-ralph-fusion.md |
| GR-02 | tad-v28-trace-infrastructure | Gate3-L2 | 3 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260402-tad-v28-trace-infrastructure.md |
| GR-03 | domain-pack-integration | Gate3-L2 | 3 | P1 | cosmetic | .tad/archive/handoffs/COMPLETION-20260404-domain-pack-integration.md |
| GR-04 | plain-language-after-handoffs | Gate2-review | 10 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260414-plain-language-after-handoffs.md |
| GR-05 | phase6a-process-quality-foundation | Gate2-review+Gate3-L1 | 9 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md |
| GR-06 | codex-agents-md | Gate3-L2 | 4 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md |
| GR-07 | cross-model-spike | Gate3-L2 | 4 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md |
| GR-08 | research-capability-polish | Gate3-L1 | 1 | P2 | cosmetic | .tad/archive/handoffs/COMPLETION-20260505-research-capability-polish.md |
| GR-09 | capability-pack-web-ui-design | Gate3-L2 | 23 | P0 | broken-ship | .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md |
| GR-10 | dynamic-research-strategies | Gate3-L2 | 4 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md |
| GR-11 | epic-template-enhancement | Gate3-L2 | 19 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md |
| GR-12 | capability-pack-web-testing | Gate3-L1 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260515-capability-pack-web-testing.md |
| GR-13 | academic-research-pack-phase1 | Gate3-L2 | 5 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md |
| GR-14 | academic-research-pack-phase6 | Gate3-L2 | 11 | P0 | broken-ship | .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md |
| GR-15 | sync-directory-list-fix | Gate3-L2 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260530-sync-directory-list-fix.md |
| GR-16 | pack-collision-detection-phase2 | Gate3-L1 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260531-pack-collision-detection-phase2.md |
| GR-17 | tad-lean-trustworthy-phase3 | Gate3-L1 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase3.md |
| GR-18 | self-deriving-release-sync-phase2 | Gate3-L2+dogfood | 6 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md |
| GR-19 | declarative-constraints-v01 | Gate3-L2 | 3 | P2 | cosmetic | .tad/archive/handoffs/COMPLETION-20260603-declarative-constraints-v01.md |
| GR-20 | yolo-workflow-p3 | Gate3-L2+Gate3-L1 | 8 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md |
| GR-21 | skill-slim-phase1 | Gate3-L2 | 1 | P1 | cosmetic | .tad/archive/handoffs/COMPLETION-20260608-skill-slim-phase1.md |
| GR-22 | migration-schema-phase1 | Gate3-L2 | 12 | P0 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260609-migration-schema-phase1.md |
| GR-23 | dual-platform-parity-fix | Gate3-L2+Gate3-L1 | 6 | P1 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md |
| GR-24 | publish-gate-phase5 | Gate3-L1 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260610-publish-gate-phase5.md |
| GR-25 | release-v2.29.1 | Gate3-L2 | 0 | none | none | .tad/archive/handoffs/COMPLETION-20260611-release-v2.29.1.md |
| GR-26 | research-input-quality | Gate3-L2 | 2 | P2 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260617-research-input-quality.md |
| GR-27 | trajectory-eval-p2 | Gate3-L1+Gate4 | 2 | P2 | silent-degradation | .tad/archive/handoffs/COMPLETION-20260702-trajectory-eval-p2.md |

## Defect Detail

One bullet per counted defect: (severity tag) + stage + counterfactual reasoning + evidence path. `low-confidence` marks tie-break-3 downgrades.

### GR-01 blake-ralph-fusion

- (P1) loop-config timeout schema missing `required: ["default"]` — Gate3-L2 code-reviewer. Schema is a verification artifact: invalid configs would validate green, the protection it claims is void (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260126-blake-ralph-fusion.md
- (P1) `pass_criteria` schema definition had no structure — Gate3-L2. Same verification-artifact class: arbitrary pass criteria validate → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260126-blake-ralph-fusion.md
- (P1) evidence file naming pattern non-standardized in config — Gate3-L2. Naming convention only, behavior identical → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260126-blake-ralph-fusion.md

### GR-02 tad-v28-trace-infrastructure

- (P1) JSON injection in record_trace sed fallback (unescaped `$project`) — Gate3-L2 code-reviewer. Would silently write invalid JSON into trace JSONL; downstream jq parsing breaks with no failure signal at write time → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260402-tad-v28-trace-infrastructure.md
- (P1) macOS-only `stat` call, no Linux fallback — Gate3-L2. On Linux the hook's trace recording silently fails; events lost with no user-visible failure → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260402-tad-v28-trace-infrastructure.md
- (P2) recursion guard comment too weak — Gate3-L2. Comment only → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260402-tad-v28-trace-infrastructure.md

### GR-03 domain-pack-integration

- (P1) code-reviewer P1 explicitly recorded as "cosmetic" (content not restated) — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260404-domain-pack-integration.md
- (P2) code-reviewer P2 #1 of 2, content not restated — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260404-domain-pack-integration.md
- (P2) code-reviewer P2 #2 of 2, content not restated — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260404-domain-pack-integration.md

### GR-04 plain-language-after-handoffs (Gate 2 expert review of the express handoff; 11 issues integrated per handoff v2 — 10 individually identifiable below, the 11th is not enumerable and is NOT counted)

- (P0) code-reviewer P0-1: v1 design added a new step AFTER step7's STOP gate — the step would never execute — Gate2-review. Feature ships, appears fine, plain-language block silently never fires; no failure signal → silent-degradation. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P0) code-reviewer P0-2: Blake-side edit target unspecified (needed `step8_generate_message` lines 925-963) — Gate2-review. Edit would land in the wrong block; Blake-side feature silently absent → silent-degradation. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P0) ux-expert-reviewer P0: Blake format guidance was a "same as Alex" reference, not inlined — Gate2-review. Guidance-quality issue in protocol prose → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P0) ux-expert-reviewer P0: negative example covered only vocabulary, not formulaic-compliance failure — Gate2-review. Example quality → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P1) code-reviewer P1-2: AC5 grep keyed on unstable English key name instead of stable emoji — Gate2-review. AC verification artifact that could false-report (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P1) code-reviewer P1-3: completion report risked being generated as the simplified template — Gate2-review. Report completeness → cosmetic. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P1) ux-expert-reviewer P1-1: length-scaling requirement missing from the plain-language spec — Gate2-review → cosmetic. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P1) ux-expert-reviewer P1-3: anti-theater rule missing — Gate2-review → cosmetic. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P2) ux-expert-reviewer P2-3: purpose anchor missing — Gate2-review → cosmetic. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md
- (P2) code-reviewer P2-3: knowledge entry (AC11) not yet specified — Gate2-review → cosmetic. Evidence: .tad/archive/handoffs/HANDOFF-20260414-plain-language-after-handoffs.md

### GR-05 phase6a-process-quality-foundation (Gate 2 expert-review findings integrated into the handoff design, restated in the COMPLETION; reviewer ID numbering implies additional Gate-2 findings existed that the COMPLETION does not restate — those are NOT counted)

- (P0) CR-P0-1: markdown-table pipe-escape bug in §9.1 AC rows — Gate2-review. AC commands with unescaped pipes silently break when extracted (verification artifact, tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P0) CR-P0-4: reviewer detection not BSD-portable / fork-heavy — Gate2-review. layer2-audit.sh is a verification artifact; a non-portable detector under-detects reviewers on the target platform → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P0) CR-P0-6: express-slug detection matched substrings (expression/compress/espresso) — Gate2-review. Non-express handoffs would silently receive the express reviewer-count exemption — guard bypass → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P0) BA-P0-2: KNOWN_REVIEWERS enumerated in SKILL instead of referencing the canonical list — Gate2-review. Enumeration drifts; audit silently misses new reviewers → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P1) CR-P1-1: dual columns targeted at §9.2 instead of §9.1 — Gate2-review. Template placement → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P1) CR-P1-5: no LAYER2_AUDIT_REVIEW_ROOT override for testability — Gate2-review → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P1) CR-P1-6: new distinct-reviewer check would have REPLACED the existing min-bytes filter instead of layering on top — Gate2-review. Removing an existing verification layer weakens what the audit proves (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P1) BA-P1-5: proposed new exit code 3 would break existing 0/1/2 consumers — Gate2-review. Contract change → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md
- (P2) AC-P6A-1-b self-caught during Gate-3 AC run: step1d had 4 MUST NOT items + 1 differently-worded item vs required 5 — Gate3-L1. Wording compliance → cosmetic. Severity untagged in record; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260425-phase6a-process-quality-foundation.md

### GR-06 codex-agents-md

- (P1) P1-1: only Blake-side sequential-review.md referenced; Alex (Gate 2) side missing — Gate3-L2 code-reviewer. Codex-Alex would silently run the wrong review protocol → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md
- (P1) P1-2: Default Behavior could lead Codex to read handoff content (terminal-isolation breach) — Gate3-L2. A protocol protection silently void → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md
- (P1) P1-3: only 4 trigger phrases; missed common Chinese/slash variants — Gate3-L2. Role switching fails to trigger for common phrasings; degraded UX → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md
- (P2) P2-3: no fallback-channel disclaimer in AGENTS.md — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260502-codex-agents-md.md

### GR-07 cross-model-spike

- (P1) P1-1: broken grep regex in Test 3c (missing `-E`) — Gate3-L2 code-reviewer. Defect in a test/verification command — would silently test nothing (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md
- (P1) P1-2: Limitations section missing from spike report (N=1, severity disagreement undisclosed) — Gate3-L2. Report completeness → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md
- (P1) P1-3: recommendation wrongly treated Codex stderr noise as failure signal — Gate3-L2. Wrong guidance in a research deliverable → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md
- (P1) P1-4: speculative session-header filter regex presented as ready — Gate3-L2. Demoted to deferral → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260503-cross-model-spike.md

### GR-08 research-capability-polish

- (P2) Spec keyword conflict: §4.1 label shared the AC1 routing keyword → grep would return 2 not 1; self-caught during Gate3-L1 AC dry-run, label renamed — Gate3-L1. Doc label only, behavior identical → cosmetic (low-confidence). Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260505-research-capability-polish.md

### GR-09 capability-pack-web-ui-design (round-1 review: CR P0=2/P1=5/P2=6, BA P0=1/P1=4/P2=5, spec P2=1; CR/BA-P1-3 recorded by both reviewers counted once → 3 P0 + 8 P1 + 12 P2)

- (P0) BA-P0-1: CAPABILITY.md missing YAML frontmatter — Gate3-L2. Claude Code skill silently fails to register; pack appears installed but never loads → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P0) CR-P0-1: tokens-to-css.sh emits invalid CSS for non-.value objects — Gate3-L2. Generated stylesheet visibly broken on first use → broken-ship. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P0) CR-P0-2: tokens-to-css.sh crashes mid-output — Gate3-L2. Tool crash on a normal-use path → broken-ship. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) BA-P1-1: LICENSE files not copied by install.sh — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) BA-P1-2: Phase 3 interface not actually reserved in install.sh — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) CR/BA-P1-3 (deduped, found by both): dry-run shows nonsense paths when .claude/ missing — Gate3-L2. Visible confusing dry-run output → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) CR-P1-3: installer overwrites existing files without warning — Gate3-L2. Silent user-file clobber → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) CR-P1-4: 27 sub-headers at wrong heading level — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) CR-P1-5: C4 capability had no framework-agnostic path — Gate3-L2. Content gap → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) BA-P1-4: flat-primitive token design undocumented — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P1) 1 round-1 P1 recorded by count only (content not restated) — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) spec-compliance P2: AC15 title-case wording not matched by case-sensitive grep — Gate3-L2. AC/doc mismatch, fixed by adding lowercase body text → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #1 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #2 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #3 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #4 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #5 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #6 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #7 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #8 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #9 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #10 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md
- (P2) round-1 P2 #11 of 11, recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260507-capability-pack-web-ui-design.md

### GR-10 dynamic-research-strategies (BA round-1 P0-1 "nested loops" confirmed FALSE POSITIVE — not counted)

- (P0) CR P0-1: `prev_zero_citation_rounds` saturation counter never updated — Gate3-L2. The saturation guard never fires; research chains run to max depth every time, silently → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md
- (P0) BA P0-2: chain filename collision — Gate3-L2. Chains silently overwrite each other; data lost with no signal → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md
- (P1) P1-1: saturation counter not persisted to chain file for compact recovery — Gate3-L2. Counter silently resets after compact; guard weakened → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md
- (P1) BA-P1-2: latency note missing from Alex Phase 4 — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260509-dynamic-research-strategies.md

### GR-11 epic-template-enhancement (review evidence: CR P0=2/P1=3/P2=4, BA P0=3/P1=4/P2=4; BA P0-3 duplicated the CR state-machine findings → 4 distinct P0; 2 of 7 P1 enumerated)

- (P0) CR P0-1: Detail Block Status state machine missing Planned→Active transition — Gate3-L2. Epic status silently stuck; protocol state wrong with no signal → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P0) CR P0-2: Active→Done transition without fallback — Gate3-L2 (BA P0-3 same defect, deduped). Same silent state corruption class → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P0) BA P0-1: sufficiency check placed AFTER Socratic (in epic_linkage) — Gate3-L2. The check could never influence Socratic; feature silently void → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P0) BA P0-2: "1-2 questions" violated the Socratic protocol floor — Gate3-L2. A quality-guard floor silently weakened (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) BA P1-1: forward-referencing AskUserQuestion wording — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) BA P1-2: subjective AC criterion, replaced with structural criteria — Gate3-L2. AC quality is a verification artifact (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) review P1 #1 of 5 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) review P1 #2 of 5 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) review P1 #3 of 5 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) review P1 #4 of 5 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P1) review P1 #5 of 5 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #1 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #2 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #3 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #4 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #5 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #6 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #7 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md
- (P2) review P2 #8 of 8 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260514-epic-template-enhancement.md

### GR-12 capability-pack-web-testing

- none — no reviewers or sub-agents invoked per handoff instructions; self-verification only; zero gate-caught defects recorded. Kept as a `none` row (no-gate-baseline signal). Evidence: .tad/archive/handoffs/COMPLETION-20260515-capability-pack-web-testing.md

### GR-13 academic-research-pack-phase1 (BA P1-1 "confidence distribution skew" acknowledged as EXPECTED per NFR1 — not a defect, not counted)

- (P1) CR P1-1: 3 duplicate skills in the 285-row taxonomy — Gate3-L2. Research dataset silently wrong; downstream migration planning consumes bad rows → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md
- (P1) CR P1-2: anti-slop summary misattributed L-rated skills — Gate3-L2. Analysis conclusion silently wrong → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md
- (P1) BA P1-2: anti-slop score inflation on database skills, deferred to Phase 3 — Gate3-L2. Deferred quality concern → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md
- (P1) BA P1-3: dedup notes missing from taxonomy — Gate3-L2. Fixed with 12-pair table; documentation completeness → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md
- (P1) BA P1-4: Decision 5 boundary cases unaddressed, deferred to Phase 2 — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260527-academic-research-pack-phase1.md

### GR-14 academic-research-pack-phase6

- (P0) validate_path() dead post-resolution check — Gate3-L2 code-reviewer. Path-traversal protection that never fires: green tests, void protection (tie-break 2 anchor class) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P0) validate_output_path() same dead check before mkdir — Gate3-L2. Same void-protection class → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P0) cmd_frequency division-by-zero on solid-color images — Gate3-L2. Crash on legal input (anchor: breaks on legal input) → broken-ship. Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P1) expensive `np.unique(pixels, axis=0)` before kmeans — Gate3-L2. Slow but correct → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P1) `out_path.replace(".json", ...)` misuse fixed with proper Path manipulation — Gate3-L2. Impact on shipped behavior not detailed in record → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P1) missing XML entity escaping for filenames in SVG comments — Gate3-L2. Malformed SVG only for special-char filenames → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P1) 1 of 4 P1s left unfixed, content not restated — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P2) review P2 #1 of 4 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P2) review P2 #2 of 4 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P2) review P2 #3 of 4 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md
- (P2) review P2 #4 of 4 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260528-academic-research-pack-phase6.md

### GR-15 sync-directory-list-fix

- none — Gate3-L2 code-reviewer ran and returned CLEAN (P0=0, P1=0, P2=0); zero catches. Note: the task itself repaired a previously SHIPPED omission (missing dirs in the *sync list) — evidence of an earlier false negative, recorded in Limitations, not counted as a catch here. Evidence: .tad/archive/handoffs/COMPLETION-20260530-sync-directory-list-fix.md

### GR-16 pack-collision-detection-phase2

- none — additive-only edit; all 8 ACs pass; no expert-review findings recorded; zero catches. Evidence: .tad/archive/handoffs/COMPLETION-20260531-pack-collision-detection-phase2.md

### GR-17 tad-lean-trustworthy-phase3

- none — byte-identity extraction with AC verification; no reviewer sub-agents invoked (per handoff LIMITS); zero catches. Evidence: .tad/archive/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase3.md

### GR-18 self-deriving-release-sync-phase2

- (P1) arch-P1-1: a SECOND hardcoded allow-list (extension glob `*.yaml *.md *.txt`) silently dropped `.tad/portable-extract.sh` and any future top-level `.sh`/`.json` — Gate3-L2 impl review. Silent omission in every downstream install, invisible to every existing gate → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
- (P1) arch-P1-2: post-install self-check was presence-only — a dir with 1-of-50 files passed — Gate3-L2. Verification artifact blind to partial copies (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
- (P1) cr-P1-1: deny-list drift check awk-scraped the lib's internal variable names — Gate3-L2. A benign lib refactor would silently break the drift check (tie-break 2) → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
- (P1) cr-P1-3: header comment claimed self-check failure is "non-fatal / ERR trap NOT triggered" — actually fatal with rollback — Gate3-L2. Misleading comment only; runtime behavior correct → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
- (P2) P2-1: dead `( set +euo … true )` no-op subshell — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md
- (P2) Dogfood catch: bare glob `"$src/.tad/$dir/"*` does not expand dotfiles → `.gitkeep`-only dirs installed EMPTY; caught by the new self-check during Gate-3 dogfood — Gate3-dogfood. Would have shipped silently-empty dirs to installs → silent-degradation. Severity untagged in record; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260601-self-deriving-release-sync-phase2.md

### GR-19 declarative-constraints-v01 (code-review P1-1/P1-2 explicitly resolved as "design decision, not bug" — not counted; pre-existing invalid-YAML frontmatter found incidentally during impl is a prior false negative → Limitations, not a catch)

- (P2) P2-3: provenance old_line numbers go stale after future edits — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260603-declarative-constraints-v01.md
- (P2) P2-4: parity-criterion owner-breakdown commentary stale (pin value correct) — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260603-declarative-constraints-v01.md
- (P2) P2-5: migration comment style inconsistent — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260603-declarative-constraints-v01.md

### GR-20 yolo-workflow-p3 (BA P0-3 duplicated CR P0-2 → deduped; 4 distinct P0)

- (P0) CR P0-2: design retry prompt dropped grounding/template file paths — Gate3-L2. Retry round would produce ungrounded design silently → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P0) CR P0-3: no mkdir for evidence dir in reviewer prompts — Gate3-L2. Review evidence writes fail; workflow proceeds with reviews unrecorded → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P0) BA P0-1: no circuit breaker when ALL reviewers return null — Gate3-L2. Unreviewed implementation proceeds as if reviewed — protection void → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P0) BA P0-2: implementation failure did not block impl_review stage — Gate3-L2. Broken pipeline state flows on silently → silent-degradation. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P1) `whenToUse` missing from workflow meta — Gate3-L2 → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P1) missing typeof guard for budget API — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P1) missing phase>=1 validation — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
- (P2) AC7 awk range start/end pattern overlap: the handoff's verification command returned 1 line instead of ~50 on macOS awk — self-caught during Gate3-L1 AC run and corrected. Broken verification command = check that silently measures nothing (tie-break 2) → silent-degradation. Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260603-yolo-workflow-p3.md

### GR-21 skill-slim-phase1

- (P1) code-reviewer P1 explicitly recorded as "cosmetic" (content not restated) — Gate3-L2 → cosmetic (low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260608-skill-slim-phase1.md

### GR-22 migration-schema-phase1 (code-reviewer initial: 2 P0 + 7 P1 + 5 P2; MIG-10/MIG-11 resolved as acceptable-deviation/design-choice → not counted; enumeration from the cited review evidence file)

- (P0) MIG-01: path-validator case pattern `*'\\'*` matched a two-char double-backslash, not a single backslash — Gate3-L2. The safety validator never fires on the very input class it guards (tie-break 2 anchor class) → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P0) MIG-02: `grep -qP` in the validator violates the BSD/macOS target (NFR2) — Gate3-L2. Validator unreliable on the platform it must protect → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-03: 6 missing cross-section conflict rules (rename+delete, rename+rename, delete+merge, duplicate-within-section, ...) — Gate3-L2. Conflicting manifests would validate green → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-04: ZERO_TOUCH protection did not cover rename.to — Gate3-L2. Protected user dirs could be renamed-into and clobbered silently → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-05: wrong version entry count (5 vs 6) in evidence file and DR-3 — Gate3-L2 → cosmetic. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-06: "~12 pairs" vs actual "13 pairs" in DR-1 — Gate3-L2 → cosmetic. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-07: forward-compatibility rule missing (new section types require schema_version bump) — Gate3-L2. Old engines would silently misparse future manifests → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-08: backup contract missing path-safety precondition + mkdir -p + TRANSIENT note — Gate3-L2. Backup (the user-data protection) could silently fail or write unsafely → silent-degradation. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P1) MIG-09: rename section lacked `type: file|dir` field — Gate3-L2. Spec ambiguity → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P2) MIG-12: NFR1d/FR1.5b interaction unclear (fixed as part of MIG-07) — Gate3-L2 → cosmetic. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P2) MIG-13: duplicate-path rule missing (fixed as part of MIG-03) — Gate3-L2 → cosmetic. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md
- (P2) MIG-14: TRANSIENT note missing from backup contract (fixed as part of MIG-08) — Gate3-L2 → cosmetic. Evidence: .tad/evidence/reviews/blake/migration-schema-phase1/code-review.md

### GR-23 dual-platform-parity-fix

- (P1) code-review P1 #1 of 3 (commit-scoping, resolved via scoped commit; content not itemized) — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
- (P1) code-review P1 #2 of 3 (commit-scoping) — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
- (P1) code-review P1 #3 of 3 (commit-scoping) — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
- (P2) code-review P2 recorded by count only — Gate3-L2 → cosmetic (classify-DOWN, low-confidence). Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
- (P2) 4th parity drift (blake/SKILL.md) NOT listed in the handoff, caught by the AC1 full-tree parity check — Gate3-L1. Without the AC, Codex would keep running a stale Blake protocol silently → silent-degradation. Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md
- (P2) AC script bug: `((PASS++))` exits 1 under `set -e` when PASS=0 — Gate3-L1, self-caught on first run. Fails in the false-FAIL (noisy) direction, not the blind direction → cosmetic. Evidence: .tad/archive/handoffs/COMPLETION-20260610-dual-platform-parity-fix.md

### GR-24 publish-gate-phase5

- none — 16/16 ACs pass; no expert-review findings or P0/P1 fix log recorded in the COMPLETION; zero catches. Evidence: .tad/archive/handoffs/COMPLETION-20260610-publish-gate-phase5.md

### GR-25 release-v2.29.1

- none — Gate3-L2 code-reviewer ran and returned 0 P0 / 0 P1 / 0 P2; zero catches. (The 2 stale-2.25.0 files fixed by this release were pre-existing shipped defects — prior false negatives → Limitations.) Evidence: .tad/archive/handoffs/COMPLETION-20260611-release-v2.29.1.md

### GR-26 research-input-quality (I-2 untested-CLI-combo and I-4 API-cost were advisory concerns, noted not fixed — not counted as defects)

- (P2) I-1: `-c 00000000` fresh-conversation intent undocumented — Gate3-L2, fixed with comment → cosmetic. Severity untagged ("I-n" scheme); counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260617-research-input-quality.md
- (P2) I-3: `original_research_question` fallback variable undefined in the protocol — Gate3-L2, fixed to `topic`. The saturation step would silently reference a nonexistent variable and misbehave with no failure signal → silent-degradation. Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260617-research-input-quality.md

### GR-27 trajectory-eval-p2

- (P2) judge-prompt D2 evidence-scope gap: round-1 judges counted handoff-embedded §9.2 as independent evidence, inflating D2 scores — caught by the Gate3-L1 calibration loop, fixed in round 2 before ship. An evaluation instrument that passes what it should not (tie-break 2) → silent-degradation. Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260702-trajectory-eval-p2.md
- (P2) §4.4 contrast-pair metric definition ambiguity: D4 inclusion flips the gate verdict (1.75 PASS vs 1.40 FAIL) — surfaced by Blake at Gate 3, adjudicated at Gate 4 (no metric-shopping verified). A verdict-flipping ambiguity in a GATE metric definition (tie-break 2) → silent-degradation. Severity untagged; counted conservatively as P2. Evidence: .tad/archive/handoffs/COMPLETION-20260702-trajectory-eval-p2.md

## Aggregate Metrics

### Severity distribution (per defect, summed from the Defect Detail severity tags)

| Severity | Count |
|----------|-------|
| P0 | 26 |
| P1 | 65 |
| P2 | 48 |
| Total | 139 |

P0+P1 total (P01) = 91

(P01 is recomputable mechanically: count of `(P0)` bullets = 26 plus count of `(P1)` bullets = 65 in ## Defect Detail.)

### Catching-stage distribution (per defect)

| Stage | Count |
|-------|-------|
| Gate 2 expert review (pre-implementation handoff review) | 18 |
| Gate 3 Layer 2 (post-implementation expert review) | 113 |
| Gate 3 Layer 1 / AC-run / dogfood (self-verification) | 8 |
| Gate 4 acceptance | 0 |

(GR-27's metric ambiguity was surfaced at Gate 3 and adjudicated at Gate 4; it is counted under Gate 3 Layer 1.)

### Counterfactual distribution

Per defect: broken-ship = 3, silent-degradation = 48, cosmetic = 88 (139 total).
Per sample row (worst defect in the row): broken-ship = 2, silent-degradation = 15, cosmetic = 4, none = 6 (27 rows).

### Zero-catch ratio and NC%

- Zero-catch (`none`) rows: 6 of 27 → Z = 6/27 = 0.222 (22.2%). Rows: GR-12, GR-15, GR-16, GR-17, GR-24, GR-25.
- NC (rows with >=1 caught defect whose counterfactual is broken-ship or silent-degradation) = 17 of 27 → NC% = 17/27 = 63.0%. Rows: GR-01, GR-02, GR-04, GR-05, GR-06, GR-07, GR-09, GR-10, GR-11, GR-13, GR-14, GR-18, GR-20, GR-22, GR-23, GR-26, GR-27.
- Cross-check against the frame expectation: 11/27 sampled files contain no "P0" string, and indeed the sample produced 6 genuine zero-catch rows plus 5 rows whose catches were P1/P2-only — the frame demonstrably includes the zero-catch class (the AC12 concern).

## Verdict

The three FR7 inputs, computed from the Sample Table / Defect Detail above:

NC% = 63.0% (17/27)
P0+P1 total = 91
zero-catch ratio = 22.2% (6/27)

Rule branch taken: first branch — NC% (63.0%) >= 25% AND P01 (91) >= 10 → net-positive. (Per the Method provenance disclosure, the operative discriminator was NC%; it cleared its threshold by 2.5x. Even under the low-confidence caveats — if every low-confidence classification were discarded entirely, 14 of the 17 NC rows still stand on solidly-evidenced non-cosmetic catches: only GR-03's, GR-08's and GR-21's classifications rest wholly on downgraded evidence, and those three are NOT in the NC set anyway.)

**Verdict**: net-positive

**Recommendation**: GO

Rationale — engaging the 2026-04-15 principle ("Mechanical Enforcement Rejected on Single-User CLI"): that decision rejected fail-closed PreToolUse hooks because their daily RECOVERY COST exceeded the benefit of preventing occasionally skipped steps — the hooks fail-closed on missing deps with no self-recovery, and the user's verdict was "日常恢复成本 > 防偶尔跳步骤收益" (daily recovery cost > benefit); TAD kept the "smoke alarm, not fire suppressor" posture (trace + human audit). This report measures the BENEFIT side that the 2026-04-15 decision could only assume: the gates' defect-catch effectiveness is real and large — 63.0% of a catch-agnostic sample had at least one non-cosmetic catch, 26 P0s among 91 P0+P1 catches, and the single largest counterfactual class (48 silent-degradation defects, including void path-traversal guards, guards that never fire, and silent install omissions) is exactly the class no post-ship signal would ever surface. GO here means: proceed to REVISIT the 2026-04-15 decision with these numbers — NOT to install mechanical hooks now. The 2026-04-15 cost claim (recovery cost, review OVERHEAD, blocked-ship friction) remains unmeasured by this report (see Limitations: cost unmeasured), so the standing prior cannot be overturned yet; the next step the GO mandates is cost-side measurement, after which benefit (this report) and cost can finally be compared on evidence instead of assumption. Until the cost side is measured, the smoke-alarm posture stays in place.

## Limitations

1. **Selection/survivorship bias**: the frame is completed handoffs only (`COMPLETION-*.md`). Cancelled/abandoned work, and express or small-edit work that never produced a COMPLETION report, are outside the frame; express work is under-represented. Gate effectiveness on work that never completed is unmeasured.
2. **Self-reported fix logs**: defect counts come from Blake-authored completion reports and review summaries. A gate catch that was never written down is invisible; an overstated fix log inflates. No independent re-execution of historical gates was performed (archival analysis only).
3. **Insider analyst / bias guard**: the analyst is structurally inside TAD. Mitigation: raw per-row counts, the frozen sample list, the verbatim commands, and the stated rubric let a skeptic recompute the ARITHMETIC from the Sample Table alone; classification-level audit happens via the FR8 independent 5-row spot-check at Gate 3 (agreement >=4/5 required).
4. **False negatives are unmeasurable** from this record: defects the gates MISSED and that shipped are not in fix logs by definition. The sample itself contains direct evidence such misses exist: GR-15 and GR-25 are whole tasks repairing previously shipped defects (sync-list omission; two files stuck at v2.25.0), and GR-19 incidentally found pre-existing invalid YAML frontmatter in shipped SKILL.md. The catch rate measured here is therefore a measure of what gates catch, not of what they fail to catch.
5. **COST UNMEASURED**: gate overhead time, review churn, blocked-ship friction, and the 2026-04-15 recovery-cost concern are NOT measured. The verdict speaks to defect-catch effectiveness only, NOT full ROI. A net-positive here does not by itself justify mechanical enforcement — that requires the cost side.
6. **Trace coverage is partial**: `gate_result` trace events exist only from 2026-05-19; 11 sampled rows pre-date coverage, and 7 post-coverage rows lack events despite recorded gate verdicts (trace-emission gap). Traces were used for annotation only, so this does not bias the sample, but trace-based corroboration is incomplete.
7. **Threshold provenance (restated)**: the FR7 rule was registered 2026-07-12 knowing the population P0-mention rate (137/184 ≈ 74%) but before any counterfactual classification existed; the P01 >= 10 conjunct was expected-satisfied by construction and the operative discriminator is NC% alone.
8. **Sample fraction**: 27/189 (14.3%) — a systematic every-7th sample, deterministic but still a sample; per-row idiosyncrasies (e.g. one mega-review row like GR-09) move per-defect aggregates more than row-level rates. The row-level NC% (the operative metric) is less sensitive to this than the raw defect totals.
9. **Low-confidence rows**: 13 of 27 rows contain at least one `low-confidence` classification (49 of 139 defects — mostly aggregate-count-only findings classified DOWN to cosmetic per tie-break 3). In only 3 rows (GR-03, GR-08, GR-21) does the ROW-level counterfactual itself rest on low-confidence evidence, and none of those three is in the NC set — the verdict does not depend on any low-confidence classification.
10. **Severity mapping conservatism**: untagged catches (dogfood bugs, "I-n" findings, self-caught AC bugs) were counted as P2, biasing P01 downward; unenumerated aggregate-count defects were classified cosmetic, biasing NC% downward. Both biases run AGAINST the gates, so the net-positive verdict is robust to them.
