# Backend-Architect Review — HANDOFF-20260601-codex-parity-phase2-catchup

**Reviewer:** backend-architect (blue-team architecture review)
**Date:** 2026-06-01
**Artifact:** HANDOFF-20260601-codex-parity-phase2-catchup.md (DRAFT)
**Scope reads:** handoff (whole), EPIC P2/P3 + Context-for-Next-Phase, parity-check.sh (L2 being upgraded)
**Verdict:** CONDITIONAL PASS — 2 P0 must be resolved before this gates a LIVE replacement.

---

## 1. Critical (P0)

### P0-1 — The per-category check is COUNT-based, but a count cannot prove a *specific* must-cover block survived. The load-bearing SAFETY guarantee is not actually load-bearing.

This is the central finding and it goes straight at FOCUS AREA 2 ("is the design robust enough to be load-bearing").

The §4 design defines the guarantee as:
```
source_mustcover_count[cat] = (count in source) − (count inside allowlisted protocol bodies)
require codex_count[cat] ≥ source_mustcover_count[cat]
```
`codex_count[cat]` is a `grep -c` over the WHOLE Codex edition. A grep count is position-blind. Consider `forbidden_implementations`, source must-cover = 6 (say: cross_model 2, express 2, experiment 2). The regen drops the entire express-path block (−2 real must-cover occurrences) but the regen LLM, following the new Step D "re-emit verbatim … strip only CC-tool lines" prose, ALSO emits the token `forbidden_implementations` 2 extra times in surviving sections, in a Step-D self-verify note, or in a heading. Net `codex_count` = 6 ≥ 6 → **PASS while the express must-cover block is gone.** The check ships a Codex edition missing a safety constraint — the exact failure §10.2 says is "a FAIL of this handoff."

This is the project's own most-repeated lesson applied to the gate itself: **count ≠ signal** (architecture.md YOLO audit; code-quality.md "discriminative field, not combined pattern"; "A parser feeding a human-review queue must propagate VALUE not just KEY"). The handoff is replacing a global *count* floor with a per-category *count* floor — finer-grained, but the SAME class of instrument. A finer count is still a count. It raises the bar for an accidental false-PASS, it does not *close* it, and §10.3 explicitly elevates this check from "secondary signal" to "the guarantee."

What load-bearing actually requires: **per-block presence, not per-category count.** The guarantee must be "each must-cover SAFETY *block* from the source appears in the Codex edition," verified by something position-aware:
- Enumerate the must-cover blocks by their owning protocol/section name (the handoff already names them: express, experiment, cancel, step1c, cross_model). For each, assert the *block* is present in the Codex edition (e.g. the section header survives AND a fingerprint of its constraint lines survives), not that a global token count clears a threshold.
- Equivalently: compute the must-cover set as `{(protocol, occurrence)}` and check membership per (protocol), so a drop in express cannot be masked by a surplus in cross_model.

Until the check is presence-per-block, AC1's dogfood (Step 2) gives false confidence: it deletes ONE block and confirms exit 1 — but it only proves the check fails when the count drops *below floor*. It does NOT prove the check fails when a block is deleted AND compensated by surplus elsewhere, which is the realistic LLM-condensation failure mode (the regen LLM re-distributes/paraphrases). **The dogfood must include the compensation case**, or it is itself validation theater (see P0-2).

**Required fix:** Redefine the Layer-2 SAFETY guarantee as per-must-cover-block presence (position-aware), with count kept only as a secondary signal — the inverse of the current §4/§10.3 framing. If the team insists on counts, then `source_mustcover_count` must be computed and checked *per owning protocol body* (count of cat inside express-block-in-codex ≥ count inside express-block-in-source), so surplus in section A cannot mask loss in section B. A global per-category total is insufficient.

### P0-2 — The check is being trusted to gate a LIVE replacement, but it has NO validation that its `source_mustcover_count` derivation is correct, and that derivation is the hardest part.

FOCUS AREA 2 asks: "does it need its own validation before being trusted to gate a live replacement?" Yes — and the handoff under-specifies the single most error-prone computation in the whole check.

`source_mustcover_count[cat] = (count in source) − (count inside allowlisted protocol bodies)` requires extracting "allowlisted protocol bodies" from the source — i.e., the byte range of each of the 9 expected-absent protocols (`yolo_execution_protocol` … `lsp_provision_protocol`) and 5 nested-ignore entries. That is exactly the §N.M / top-level-YAML-key boundary-extraction problem that has bitten this project repeatedly:
- code-quality.md "§9.1 Region Marker is `### 9.1` not `## 9.1`" — wrong heading depth → empty region → false-clean.
- architecture.md "Progressive Disclosure: live boundary re-derivation per block; col-0 top-level key boundary."
- code-quality.md "comm -12 CJK needs LC_ALL=C" — collation phantom.

If the body-extraction over- or under-counts the allowlisted region, `source_mustcover_count` is wrong in EITHER direction:
- Over-subtract (extract too large a yolo body, swallowing an adjacent must-cover block) → must-cover floor too LOW → false PASS → the load-bearing failure.
- Under-subtract → floor too high → false FAIL on a faithful regen → blocks the catch-up.

The Step 2 dogfood validates the *gate's reaction to a deletion*, but it does NOT validate the *`source_mustcover_count` derivation itself*. The derivation needs its own assertion before the check is trusted. **Required:** add an AC that pins `source_mustcover_count[cat]` to a hand-derived expected value for the current source (e.g. "forbidden_implementations must-cover = 6: cross_model 2 + express 2 + experiment 2 — print and assert"), so a boundary-extraction bug surfaces as a number mismatch, not as a silent floor error. This is the project's standing rule: *re-derive key pass/fail numbers from primary evidence* (architecture.md Gate-4 Verification Integrity) — applied here to the gate's *own* threshold, computed once and asserted, before the gate is allowed to bless a LIVE file.

Additionally: the current script is **fail-OPEN** ("Parse errors → WARN + continue (P1 fail-open)", lines 2-4, and the Layer-3 `WARN: could not extract … P1 fail-open` path). Fail-open is correct for a *spike* prototype but is **disqualifying for a load-bearing SAFETY gate that replaces LIVE files.** If the `source_mustcover_count` extraction hits a parse error, a fail-open Layer 2 WARNs and PASSes → ships an unverified edition. P2 elevates this script from spike-prototype to live-replacement-gate; the SAFETY layer specifically must be **fail-CLOSED** (parse error in the must-cover derivation → exit non-zero, do not PASS). The handoff does not address the open→closed transition for the upgraded layer. This must be an explicit AC.

---

## 2. Recommendations (P1)

### P1-1 — Scope: pulling P3's check forward is correct and leaves P3 clean; but P2 is now overloaded and should split the GATE work from the REGEN work into two sequential acceptance fronts.

FOCUS AREA 1. The *forward-pull is sound* — P3's remaining scope (release-runbook wiring, `*publish` reference, README/portable-rules docs, settings.json-exclusion check) is genuinely non-overlapping with what P2 absorbs; EPIC P3 AC1-AC5 do not duplicate P2's gate-hardening (P3 AC1 is "stable path + exit-code contract," AC4 is the release-time dogfood — distinct from P2's regen-time dogfood). So pulling forward does NOT strand P3 with overlap. Good.

But P2 now carries: (a) a load-bearing gate redesign + its own validation, (b) two full LIVE regens of *structurally different* surfaces (Alex AskUserQuestion-dominated, Blake Ralph-Loop/Agent-dominated), (c) procedure-hardening with a re-emit loop, (d) a headless probe, (e) a per-item trace. That is 5 deliverables of differing risk classes in one handoff. The recurring project lesson (architecture.md "Express Handoff is NOT Review-Exemption"; "budget expert review by risk not code volume") argues for treating the **gate redesign (Steps 1-3) as a hard internal milestone that is independently accepted BEFORE the regens (Steps 4-5) consume it.** Concretely: do not let Step 4 start until Step 2's dogfood (with the P0-1 compensation case added) passes AND P0-2's `source_mustcover_count` assertion passes. The handoff sequences them but does not GATE them — add an explicit "Steps 1-3 accepted → unlock Steps 4-5" checkpoint. This keeps it one handoff but prevents the gate and the thing-it-gates from being validated in the same breath (a dependency-inversion smell — see P1-4).

I do NOT recommend a full split into two handoffs: the regens are the *reason* the gate is being hardened now, and splitting would lose the tight feedback loop where a regen failure informs a procedure fix. Keep it one handoff with the internal milestone gate.

### P1-2 — Blake regen: "preserve Ralph-Loop, transform Agent-spawn" has a real conflict the handoff does not address — Ralph-Loop references Agent-spawn internally.

FOCUS AREA 3, and this is a genuine hidden risk. The handoff (§2, §4 Blake regen, §10.4) treats "preserve Ralph-Loop" and "transform the 11 Agent-spawn sites → sequential codex exec" as two *independent* transforms. They are not independent: Ralph-Loop's Layer-2 expert review and its parallel-verification priority group are *implemented by spawning Agents* (the project's own architecture.md: "Ralph Loop, 并行执行" lives in Blake; "Epic Auto-Conductor: Sub-agents have NO Agent tool"; "every review at Conductor level"). So some of the 11 `Agent` mentions are INSIDE the Ralph-Loop blocks that §10.4 says to "preserve verbatim (Preserve-NEVER-Delete)."

The two rules collide on those occurrences: "preserve verbatim" vs "transform Agent→codex exec." If Blake preserves the Ralph block verbatim, it keeps a Claude-only `Agent` spawn the Codex edition can't execute. If Blake transforms it, it has mutated a Preserve-NEVER-Delete block. The handoff gives no precedence rule. **Required:** add an explicit sub-rule — "within Ralph-Loop blocks, the LOOP STRUCTURE/gating logic is preserve-verbatim, but the *mechanism* line (`spawn Agent` → `sequential codex exec session`) is transformed; the two are separable because Ralph's quality logic is mechanism-agnostic." And add an AC that verifies BOTH: Ralph Layer-1/Layer-2 *gating logic* present AND zero un-transformed `Agent`-spawn mechanism lines remain inside the Ralph blocks. Right now AC3 says "Ralph-Loop Layer1/2 preserved" and the §4 prose says "transform the 11 Agent-spawn sites" with no statement about the *intersection*, which is precisely where a regen will either drop a constraint or leave an inexecutable spawn. This intersection is also a SAFETY surface (parallel-verification-before-blocking-gate is a quality guarantee), so it should be in the per-block must-cover set from P0-1.

### P1-3 — Headless probe measures the wrong quantity for the standing guarantee; the self-verify re-emit loop is an unbounded-cost confound.

FOCUS AREA 4. Two issues.

(a) **What's measured ≠ the ≤5min standing guarantee.** §4/Step 6 measure "recurring human-touch time (kick off + glance at parity verdict)." But the ≤5min guarantee in the EPIC Success Criteria is "per-release human cost to keep Codex in sync." Human-touch time on a *successful first-pass* headless run is a LOWER bound, not the operative cost. The operative cost is human-touch time *including the expected remediation when the gate FAILs* — because the standing guarantee must hold on the bad-path, not just the happy-path. A headless run that passes parity in one shot tells you almost nothing about the recurring cost when (as P1 proved likely) the regen condenses and a human must re-engage. **Recommend:** measure human-touch under BOTH outcomes — first-pass PASS, and PASS-after-one-gate-FAIL-remediation — and report the worst case against ≤5min. A single happy-path number will over-claim the guarantee.

(b) **The Step-D self-verify re-emit loop can make headless cost unbounded** — the focus area's stated concern is real. Step D = "if any per-category SAFETY check fails, re-emit the affected section verbatim and re-check." Nothing in §4 or Step 6 bounds the iteration count. A condensation-prone regen LLM that re-condenses on each re-emit (the P1 evidence is that it condenses *despite* the instruction) can loop. In a headless (`claude -p`, no interactive correction) context this either (i) loops until token/quota exhaustion, or (ii) the harness has no loop driver at all and Step D simply doesn't execute headlessly. **Required:** bound the re-emit loop (e.g. max 2 re-emits, then HARD-FAIL → human escalation) AND state explicitly whether Step D is even executable in a single `claude -p` shot (it implies a check→edit→re-check cycle, which a one-shot `-p` cannot self-drive without an external loop). If Step D needs an external bash driver to loop the model, the "headless" claim must measure THAT harness, not a bare `claude -p`. This directly determines whether AC6's number is meaningful.

### P1-4 — Sequencing is correct in order but has a latent dependency inversion: Step 4-5 trust a gate that Step 1-2 built, yet the gate's correctness is only proven by a single synthetic deletion.

FOCUS AREA 5. Order (upgrade gate → regen using it) is right; you cannot regen-to-trustworthy-PASS before the gate is trustworthy. No order inversion. BUT there is a *trust* inversion: the regens (Steps 4-5) are accepted *by* the gate, and the gate is accepted by a *single* dogfood (Step 2). If the gate has the P0-1 false-PASS or the P0-2 derivation bug, Steps 4-5 inherit it and AC2/AC3 PASS on a defective edition — and there is no *independent* check on the regen output besides the gate the same handoff just wrote. This is the "verifier inherits the reviewer's errors" pattern (architecture.md "Cross-Model Adversarial Review … verify the reviewer too"; "a verify stage must independently check, not trust the prior reviewer's verdict").

**Recommend** one independent cross-check on the LIVE regens that does NOT go through parity-check.sh: e.g. a direct `diff`-style spot of 2-3 named must-cover blocks (express, experiment, Ralph Layer-2) between source and Codex edition, read by a human/second tool — AC7 partially does this ("read the actual lines") but only for *feature* markers (deliverable/research_complexity/step4_5), NOT for the SAFETY must-cover blocks that P0-1 is about. Extend AC7 (or add AC) to spot-read the SAFETY must-cover blocks independently of the gate.

---

## 3. Suggestions (P2)

- **S-1 (size-vs-fidelity tension):** AC4 caps codex-alex ≤102400 B and codex-blake ≤40960 B while P0-1/Step D push toward re-emitting blocks *verbatim from source*. Verbatim re-emit inflates size; the size cap incentivizes the regen LLM to condense — the very behavior being fought. If a faithful Blake regen exceeds 40KB, which AC wins? Add an explicit precedence note (SAFETY fidelity > size cap; if they conflict, fail to human, do not silently condense). Mirrors architecture.md "AC Conflict Matrix for structural ACs" and "honest_partial for environmental deadlocks."
- **S-2 (P1 lesson reuse):** The §9.1 PIPE-ESCAPE contract and the `grep -coE` ERE/BRE split are handled well. One gap: AC4b uses `grep -coE 'MUST|MANDATORY|VIOLATION'` for the *floor* — but per P0-1 the floor is exactly the instrument being demoted. Make sure the COMPLETION reports the per-category must-cover numbers as the PRIMARY pass/fail evidence and the `-coE` floor as secondary, matching §10.3, so Gate 4 raw-recompute targets the right number.
- **S-3 (trace artifact):** `p2-constraint-trace.md` (AC5) records before/after per-category *counts*. Per P0-1, counts are the weak signal — have the trace ALSO list, per must-cover block, present/absent (a checkbox table keyed by owning protocol), so the trace itself isn't count-only theater.
- **S-4 (dogfood breadth):** Step 2 deletes ONE forbidden_implementations block. Also delete one `anti_rationalization_registry` (byte-exact-preserve category per §4) and verify the *equality* sub-rule fires — the two categories have different rules (≥ vs equality) and both need a negative test.
- **S-5 (EPIC consistency):** EPIC P2 AC1 still phrases the upgrade as "present in the kept region — NOT a global count floor," which reads as *presence* — closer to the correct P0-1 framing than the handoff §4's *count* formula. The handoff §4 is actually WEAKER than the EPIC's own AC wording. Reconcile: tighten §4 to the EPIC's presence language (which P0-1 also demands), so the handoff doesn't ship a weaker check than the Epic specified.

---

## 4. Overall

**CONDITIONAL PASS.**

The forward-pull of P3's check is the right call and leaves P3 cleanly scoped (P1-1). Sequencing order is correct (P1-4). But the handoff cannot ship as a *load-bearing LIVE-replacement SAFETY gate* until the two P0s are resolved:

- **P0-1:** the guarantee is count-based; a count cannot prove a specific must-cover block survived, and surplus elsewhere can mask a real deletion — make it per-block presence (position-aware), not per-category count. This is the project's own count≠signal lesson applied to the gate that is supposed to enforce it.
- **P0-2:** the gate's `source_mustcover_count` derivation (boundary extraction over allowlisted protocol bodies) is the most error-prone computation and has no self-validation; it must assert its threshold against a hand-derived number AND flip the SAFETY layer from fail-open to fail-closed before it blesses a LIVE file.

P1-2 (Ralph/Agent transform intersection) and P1-3 (headless measures happy-path lower-bound + unbounded re-emit loop) are strong P1s that materially affect AC3 and AC6 truthfulness. Resolve the 2 P0s and address P1-2/P1-3, then this is a coherent single handoff.
