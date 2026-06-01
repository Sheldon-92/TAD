# Backend-Architect Review — Codex-Parity Phase 3 (Release Gate) — EPIC FINALE

**Reviewer:** backend-architect (blue-team / pre-handoff architecture review)
**Artifact:** HANDOFF-20260601-codex-parity-phase3-releasegate.md (DRAFT)
**Date:** 2026-06-01
**Verdict:** CONDITIONAL PASS — 2 P0 (contract semantics + unreviewed-LLM-artifact-in-release), both fixable in-handoff before shipping.

---

## 1. Critical (P0)

### P0-1 — "Self-heal" silently changes the contract from "hard-block on drift" to "block only when parity is UNREACHABLE". The user is never NOTIFIED of drift.

The Epic objective (line 19), Success Criteria (line 20), and DR (lines 17, 63-67) all state the guarantee as **"hard-block (minor+) when the Codex edition drifts."** The handoff §4 (lines 92-94) redefines the actual runtime behavior:

> "self-heal makes drift a non-event (regen runs every release); the HARD BLOCK fires only when parity is **unreachable**."

These are **not the same contract.** Under self-heal, the steady-state outcome of *every* minor+ release is: drift is detected, silently regenerated, staged, shipped — and the human is told **nothing**. The block only ever fires in the corner case (codex missing AND drifted, or a regen that can't satisfy the gate). So the headline deliverable "release is hard-blocked when Codex drifts" is, in normal operation, **never exercised** — drift is auto-absorbed.

This is the exact pattern architecture.md flags repeatedly: a guarantee whose blocking path is structurally almost-unreachable is a guarantee that is "unproven" (cf. "A Rubric Gate Is Only Credible If It Can FAIL", 2026-05-31; "Self-heal makes drift a non-event, but the BLOCK must still be real", the handoff's own §10.1). The handoff is aware of the tension (§10.1, AC7 force-block dogfood) but resolves only the *test* concern, not the *contract* concern.

The unanswered design question — which MUST be put back to the user before this ships — is: **did the user want drift SILENTLY HEALED, or did they want to be NOTIFIED that the source moved and the editions were regenerated?** "Self-heal" was chosen (Decision #1, line 240) as "closest to ≤5min near-zero-human." But near-zero-human-cost and zero-notification are different properties. A regen that runs `codex exec` for ~175s × 2 editions (~6 min, already over the ≤5min target — see P1-1) and silently mutates two 46KB/29KB files that then enter a **tagged, pushed release** is a high-consequence event that should at minimum **announce itself** ("Codex editions drifted from source; regenerated N lines; staged into release — review diff before confirming push").

**Required fix:** Add an explicit **drift-notification + human-visible diff** step to the gate BEFORE the editions are staged into the release commit. Self-heal may proceed, but it MUST surface (a) that drift was detected, (b) the regen diff summary (files + line delta), and (c) a confirm-before-push gate. Re-confirm with the user whether silent-heal or notify-then-heal is the intended contract. Until that is resolved the handoff is changing a user-stated requirement without authorization.

### P0-2 — An unreviewed, LLM-generated 46KB/29KB artifact enters a tagged + pushed release with no review gate. (Biggest architectural risk.)

`*publish` performs git commit + tag + push (handoff §2 references `publish_protocol` → "Confirm & Execute" → "Post-Publish"; DR line 4 lists release process as a touch-point). The self-heal gate (§4 lines 82-84) does, inside that same flow:

```
regen <source> -> /tmp/<ed>.regen via codex exec --full-auto
if codex-parity-check.sh ... == 0:  mv /tmp/<ed>.regen -> live
... pass: proceed (editions staged into the release commit)
```

So the sequence is: **LLM emits a 46KB file → automated parity-check passes → `mv` over the live edition → staged → committed → tagged → pushed.** The ONLY thing standing between an LLM-generated artifact and a permanent tagged release is `codex-parity-check.sh`, which (by its own P2 design) verifies **semantic coverage + per-owner SAFETY-marker presence** — it does NOT verify the regen is *correct prose*, free of hallucinated rules, or free of subtle behavioral drift in the 80% of content that isn't a counted marker. parity-check is a **coverage** gate, not a **correctness** gate. This is precisely architecture.md "Verified ≠ factually correct" (2026-06-01 cross-model review entry): a pack/edition can pass the discriminative/coverage gate and still carry ~6 API errors.

Concretely: the regen could rename a rule, drop a nuance, or hallucinate a constraint in a non-marker paragraph, pass parity-check (markers all present), and ship in v2.X.0 — discovered only when a Codex user hits the broken behavior. There is **no diff review, no human eyeball, no second-model check** between regen and tag.

This is structurally worse than the drift it replaces: today drift is *stale-but-known-good* content; the self-heal path can ship *fresh-but-unvalidated* content under a version tag. A staged unreviewed LLM artifact in a tagged release is a one-way door (the tag is immutable; downstream `*sync` propagates it to 14 projects per the recent commit log).

**Required fix (pick one, state it in the handoff):**
- **(Preferred) Decouple regen from publish.** Make the gate **detect-only at `*publish`** (block minor+ on drift), and make **regen a separate, explicit pre-publish step the human runs and reviews** (`*publish` refuses until editions are at parity; remediation = "run the regen command, review the diff, commit, re-run publish"). This restores the user's literal "hard-block on drift" contract (P0-1) AND removes the unreviewed-artifact-in-release risk in one move. Note this is exactly what the Epic Phase-3 *Scope* originally said (Epic line 153-156: "on drift, HARD-BLOCK… with regeneration as the **remediation path**") — the handoff's self-heal is a drift FROM the Epic's own scope.
- **OR** if self-heal stays: insert a **mandatory diff-review confirm gate** (show `git diff` of the regenerated editions; require explicit human y/N) BEFORE the editions are staged, AND a **cross-model or grep-correctness second check** beyond parity-check. The regen must NOT auto-stage into a tagged commit without a human seeing the diff.

The handoff currently has neither. As drafted, P0-2 is a genuine "unreviewed LLM artifact enters a tagged release" hazard.

---

## 2. Recommendations (P1)

### P1-1 — The ≤5min standing-guarantee target is likely BLOWN by the self-heal design; the math isn't reconciled.

Epic Success Criteria line 20 + DR lines 17/30/43 pin **≤5 min per-release human cost**. P2 proved one headless `codex exec` regen = **175s**. The self-heal gate regenerates **both** editions (§4 line 82 `for ed in alex blake`) = **~350s ≈ 5.8 min of wall-clock**, every minor+ release, *plus* the parity-check runs. Two issues:

1. ≤5min was specified as *human* cost (near-zero-human), and self-heal is near-zero-human in *attention* — but if P0-1/P0-2 add the (correct) diff-review confirm, the human now must review a ~46KB diff each release, which is **not** ≤5min and **not** near-zero-human. The handoff should re-state the cost model honestly: detect-only + human-reviewed-regen is *more* human cost than the self-heal fantasy, but it's the *safe* cost. Decision #1's rationale ("closest to ≤5min near-zero-human") is the justification for the risky design — if the safe design costs more human time, the user should make that tradeoff knowingly.
2. ~5.8min of `codex exec` inside `*publish` is a long, network-dependent, non-deterministic blocking step in the release hot path. Recommend the gate **measure & print** the regen wall-time and have a timeout/abort that fails-CLOSED (block) rather than hanging the release.

### P1-2 — Carry-forward closure is mostly complete, but verify two items aren't silently dropped.

Cross-checking the Epic "Context for Next Phase → After P2" carry-forwards (lines 219-233) against the handoff:

| Carry-forward (Epic) | Handoff coverage | Status |
|---|---|---|
| 1. Wire gate into runbook + `*publish` (minor+ block / patch advisory) | §Reqs 2-3, Steps 4-5, AC4-AC5 | ✅ Covered |
| 1b. **Mechanical marker-extraction** ("already documented in parity-criterion.md; prototype was source-conditioned in P2") | **Not mentioned anywhere in handoff** | ⚠️ **DROPPED** |
| 2. codex-exec note (`claude -p` FAILs on 326KB) | §4, §10.4, Decision #3 | ✅ Covered |
| 3. layer2-audit reviewer-name drift | §Req 4, Step 6, AC6 | ✅ Covered |
| 4. P1-2 awk header self-counting | §Req 5, Step 2, AC2 | ✅ Covered |
| 5. single-user-CLI release-time-only | §Req 8, §10.2, AC8 | ✅ Covered |

**Action:** Carry-forward 1b (the mechanical marker-extraction rule — "P3 must implement the mechanical-extraction rule already documented in parity-criterion.md", Epic lines 207-208) is **not addressed** in the handoff. P2 left the marker list "source-conditioned" (i.e. the gate's marker set was derived from the specific P2 source, not mechanically extracted). If the gate ships with a hardcoded/source-conditioned marker list, then on a FUTURE release where the source SKILL adds a new must-cover owner/category, the gate will **silently not check it** — a false-PASS that re-opens drift exactly as the Epic warns. This is the "self-sustaining vs hidden manual step" question (focus area 4): a source-conditioned marker list IS the hidden manual step. Either implement mechanical extraction in P3 or **explicitly document** that the marker list must be manually updated when source owners change AND add that to portable-rules as a release checklist item. Do not let it vanish.

### P1-3 — Epic-completion self-sustainability hinges on a hardcoded marker list (see P1-2) and on the regen-procedure staying in sync with portable-rules.

DR line 71-73: "portable-rules.md transform table becomes load-bearing (the regen contract) — changes to it are semver-relevant." The standing guarantee is only self-sustaining if: (a) marker extraction is mechanical (P1-2), and (b) when someone edits the source SKILL's protocol structure, portable-rules + the regen-procedure auto-stay-correct. Neither is guaranteed. Recommend the handoff add an explicit Epic-completion statement: "the guarantee is self-sustaining EXCEPT [enumerate the manual touch-points: marker list update on owner-set change, portable-rules transform-table maintenance]." An honest enumeration of residual manual steps is better than an implied "fully automatic" that drifts in 2 months.

### P1-4 — fail-CLOSED at release is correct, but the codex-unavailable + drifted path needs a concrete remediation, not just "block."

§10.4 / AC3: codex-unavailable → check existing → block (minor+) if drifted. Good (fail-closed). But the user is then **stuck**: they can't ship a minor release and the auto-remediation (regen) is exactly the thing that's unavailable. The handoff must spell out the manual escape: "install codex, OR hand-port the missing sections per portable-rules, then re-run." Without a documented manual path this is a release deadlock. (This also feeds focus-area-5, below.)

---

## 3. Suggestions (P2)

### S-1 — codex-unavailable hard-block on minor+ is DEFENSIBLE but document the escape valve.
Focus area 5: blocking minor+ when codex is missing is **correct** for the parity guarantee (the whole Epic exists because editions silently drifted — a soft "skip if no codex" would re-introduce exactly that). The risk is a contributor without codex installed being unable to cut a minor release. Mitigation is documentation, not relaxation: (a) patch releases are unaffected (advisory), (b) document "minor+ requires codex OR a hand-verified parity-check pass" in the runbook. Keep the hard-block; add the escape doc (ties to P1-4). Do NOT downgrade to advisory — that defeats the Epic.

### S-2 — `mv /tmp/<ed>.regen -> live` should be atomic and the /tmp path collision-safe.
§4 line 83 uses `/tmp/<ed>.regen`. Use `mktemp` (per project shell-portability lessons) and confirm the `mv` is same-filesystem atomic (cross-fs `/tmp`→repo is a copy, not atomic). Minor, but a half-written edition staged into a release is a bad failure mode.

### S-3 — Step 7b honest-fallback weakens the EPIC-FINALE proof.
AC7/Step 7b allows "if codex unavailable in this env, honest fallback: show the gate logic + the codex-unavailable block path." For the **final** phase that delivers the standing guarantee, the self-heal path is the headline feature — accepting the Epic without ever having executed a real end-to-end self-heal (drift → codex regen → parity → stage) means the central mechanism ships **unproven in-environment**. Strongly recommend P3 run the real 7b at least once (codex was available in P2 at 175s, so it should be available here). If it genuinely can't run, the Epic should close as "self-heal mechanism wired but not e2e-proven" — an honest-partial, not a clean accept.

### S-4 — Decision Summary should record the P0-1 contract question as an explicit user decision.
Decision #1 (line 240) records "self-heal" as chosen but frames it purely as a cost optimization. It does not record that self-heal *changes the drift-block semantics to drift-silently-healed*. Whatever the resolution of P0-1, capture it as a first-class decision with the notify-vs-silent tradeoff stated.

---

## 4. Overall: CONDITIONAL PASS

The wiring design is sound, the carry-forward coverage is ~90% complete, fail-CLOSED-at-release is correct, single-user-CLI compliance is faithfully preserved (AC8, §10.2 — the DR's critical constraint is respected, no settings.json hook), and the anti-theater dogfood instinct (§10.1, AC7) is right. The layer2-audit and P1-2 carry-forwards are cleanly folded in.

But two P0s block a clean accept:
- **P0-1**: "self-heal" quietly converts the user's "hard-block on drift" into "silently heal drift," and never notifies. This changes a user-stated contract — must be re-confirmed, and a drift-notification step added.
- **P0-2**: the self-heal path stages an **unreviewed LLM-generated 46KB/29KB artifact into a tagged, pushed release** with only a coverage-gate (not a correctness gate) in between. This is the single biggest architectural risk. Preferred resolution — and the one that ALSO fixes P0-1 and matches the Epic's own original scope ("regeneration as the **remediation path**", not auto-heal) — is to **decouple regen from publish**: detect-only hard-block at `*publish`, regen as a separate human-reviewed pre-publish step.

Plus P1-2 (mechanical-marker-extraction carry-forward 1b appears DROPPED — the gate may ship with a source-conditioned marker list that silently re-opens drift on future owner-set changes) must be addressed or explicitly documented before the Epic can honestly claim a *self-sustaining* guarantee.

Resolve P0-1 + P0-2 (recommend the decouple-regen option, which collapses both), close or document P1-2, and this is a clean PASS and a sound Epic finale.
