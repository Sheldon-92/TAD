# Backend-Architect Review — HANDOFF-20260601-codex-parity-phase1-spike

**Reviewer:** backend-architect (blue-team architecture review of internal tooling)
**Artifact:** HANDOFF-20260601-codex-parity-phase1-spike.md (DRAFT design spec)
**Cross-read:** DR-20260601, EPIC-20260601 (Phase Map + 3 Phase Details), portable-rules.md
**Date:** 2026-06-01
**Verdict:** CONDITIONAL PASS

---

## 1. Critical Issues (P0)

### P0-1 — The spike measures regen RELIABILITY with n=1 and calls it "viable" — but the architecture's whole bet is on REPEATABLE regen, and a single manual run cannot prove repeatability or the ≤5min claim

The DR's Decision rationale (DR §"Rationale for spike-first") names unknown #1 precisely: "can an LLM-driven regen **reliably** pass all guards + semantic coverage at near-zero human cost?" The operative word is *reliably*. The spike (Step 3, AC1/AC2) executes the regen **exactly once**, by a human-supervised agent, and AC5 records "measured human-time on the ≤5min path."

A single successful regen proves *feasibility* (it CAN be done once), not *reliability* (it will pass on each future release headlessly). These are different claims, and the Epic depends on the second:
- P3 invokes the regen headlessly at release time (`claude -p` / `codex exec`, per §4 "invoked headlessly … as the ≤5min release step"). A first manual run in an interactive session, with the reviewer watching and able to nudge, does **not** characterize headless behavior.
- The ≤5min number from a single run has no variance estimate. The pivot threshold is "can't hit parity at ≤5min" (Req 5, §1, Epic AC dependency). One sample cannot falsify or confirm a time budget that must hold on every future release.
- "Measured human-time" is also under-defined: does it include the prompt-authoring (one-time, P1) or only the per-release invocation (recurring, the number that actually matters for the ≤5min gate)? The handoff conflates them. The ≤5min budget is a **per-release recurring** cost; P1 must isolate that from the one-time procedure-authoring cost or the verdict measures the wrong thing.

**Required before this de-risks the right unknown:** Step 3 must run the regen at least **twice** (ideally once interactive to author the procedure, then once **headless from the frozen procedure** — `claude -p` reading regen-procedure.md, zero human edits) and report BOTH the headless pass/fail and the headless-only wall-clock as the ≤5min number. If only the interactive run is feasible in P1, the spike report MUST explicitly downgrade its verdict from "regen is reliable" to "regen is feasible once; reliability/headless unproven" and forward that as a residual risk to P2 — otherwise P2/P3 inherit an unvalidated reliability assumption.

### P0-2 — Decision #3 ("alex only … proving it generalizes to Blake") is an unsupported generalization the spike never tests, and it is load-bearing for P2

Decision #3 (§11) justifies regenerating Alex only with: "Alex is the larger/harder (319KB, 82 subs); **proving it generalizes to Blake**." This is a logical gap. Proving the regen works on the *harder* artifact does not prove it works on Blake — it proves it works on Alex. Blake differs on axes the Alex spike does not exercise:
- **Different transform surface.** DR §"Measured facts": Blake = 102KB / **3** AskUserQuestion mentions; Alex = 319KB / **82**. Alex stresses the `AskUserQuestion`→numbered-text rule heavily; Blake barely touches it. Blake instead is dominated by Ralph-Loop two-layer logic, `Agent`/sub-agent parallel-spawn (the `Agent`→sequential `codex exec` transform), and Gate-3-v2 structure — rules the Alex regen exercises *lightly*. A regen procedure tuned/validated on Alex's transform mix can silently mis-handle Blake's.
- **Different size headroom.** Alex 319KB→≤100KB is a 3.2× strip; Blake 102KB→≤40KB is 2.5× — but Blake's preserve-heavy Ralph-Loop content may compress *less*, putting it closer to its ceiling. The Alex run gives no signal on Blake's size margin.

The "harder ⇒ generalizes" claim is the kind of cross-artifact generalization the project's own expert-review-blind-spots lesson warns about. **Either** (a) add a *lightweight* Blake transform-surface check to P1 (not a full regen — just run the regen procedure's Strip→Replace table mentally/dry against Blake's `Agent`-spawn and Ralph-Loop sections and confirm the rules have a defined replacement for each), **or** (b) rewrite Decision #3's rationale to honestly state "Alex validates the procedure on the largest/most-substitution-heavy artifact; **Blake's distinct transform mix (Agent-spawn, Ralph-Loop) is a residual risk carried into P2**" and add it to P2's risk list. As written, Decision #3 asserts a generalization the spike's evidence cannot support.

---

## 2. Recommendations (P1)

### P1-1 — Parity criterion: capability-marker auto-extraction is unspecified, yet it is the layer that catches the EXACT drift this Epic exists to fix

§4 layer 3 ("Capability-marker coverage: a source-derived checklist of must-have feature tokens, **auto-extracted**, e.g. `deliverable`, `research_complexity`, `step4_5`…") is where false-negatives will live, and the auto-extraction mechanism is left undefined. The danger is concrete:
- If the marker list is **hand-curated** (the §4 examples look hand-picked), then the gate only catches drift in features someone remembered to enumerate. The next feature added to Claude Alex *after* P1 — exactly the future-drift case the Epic promises to prevent (Epic Objective: "every future release keeps Codex in sync") — has no marker, so the gate passes a Codex edition missing it. This is a structural false-negative that defeats the standing guarantee.
- If "auto-extracted" means "diff the source's top-level YAML keys / `*_protocol:` keys", say so and specify the extraction rule, because that determines what the gate can never miss.

**Recommend:** parity-criterion.md MUST specify the capability-marker derivation as a *mechanical rule applied to the source at gate time* (e.g., "every top-level `*_protocol:` YAML key and every `### PHASE`/`step\d` heading in the current source becomes a required marker; the gate fails if the Codex edition lacks a corresponding section"), NOT a frozen hand-list. A frozen list is a smoke alarm with the battery removed — it will pass tomorrow's drift. This is the difference between the gate being load-bearing and being theater.

### P1-2 — "Section coverage" by name-match has a known false-NEGATIVE class the criterion must declare: the transform legitimately RENAMES/MERGES sections

§4 layer 1 enumerates source protocol sections and requires "name-match, or an explicit mapping entry for renamed/merged ones." But the whole point of the transform (portable-rules.md Strip→Replace) is that some sections are *deliberately altered* — `AskUserQuestion`-driven sections become numbered-text, hook-driven sections become "run bash manually." A naive name-match will:
- **False-positive (flag non-drift):** report a renamed-by-transform section as "missing" when it's legitimately present under a transformed form → gate blocks a *correct* regen → forces a human to maintain a growing mapping table by hand every release. That mapping table is itself a drift surface and a maintenance tax — the exact "maintenance-tax collapse" risk the DR's user requirement (§Context) says B must defend against.
- The criterion says renamed/merged need "an explicit mapping entry" but **doesn't say who maintains it or how it stays in sync** when the source renames a section in a future release. If the mapping is hand-maintained, P3's gate inherits a hand-maintained artifact — reintroducing the manual-diligence failure mode that got architecture A rejected.

**Recommend:** parity-criterion.md must (a) state the mapping table's maintenance owner and sync trigger, and (b) prefer a transform that does NOT rename (keep source section names verbatim in the Codex edition wherever possible, only changing the *body*) so name-match works without a mapping table. Minimize the mapping table; every entry is a manual-drift liability.

### P1-3 — Interface gap between P1 output and P3 consumer: path graduation + exit-code contract is asserted but not pinned in P1

Forward-compat check (focus area 2): P1 produces `parity-check.sh` at `.tad/evidence/spikes/codex-parity/parity-check.sh`; P3 AC1 expects it "at a stable path with documented exit-code contract" and P3 Files-Affected names `.tad/hooks/lib/codex-parity-check.sh`. The graduation is a path move + a rename. Two gaps:
- **Exit-code contract is stated twice, slightly differently.** P1 §6 Step 4: "Exit 0=parity, 1=drift, **2=usage/NA**." P3 AC1: "0=parity, 1=drift→block, **2=advisory/NA**." "usage/NA" vs "advisory/NA" for exit 2 is a real semantic difference: P3 wants exit 2 to mean *advisory* (patch-release soft pass), but P1 defines exit 2 as *usage error / not-applicable*. If P3 maps "patch = advisory" onto exit 2 but P1's script emits exit 2 on **parse error / bad args**, then a broken invocation at release time reads as "advisory pass" and silently ships drift on a patch. **Pin the exit-code contract identically in parity-criterion.md now**, and separate "parse/usage error" (should be a distinct nonzero, e.g. 3, that NEVER reads as pass) from "advisory."
- **`.tad/codex/` is classified CC-only-source in portable-rules.md**, but P3's gate output (`.tad/hooks/lib/codex-parity-check.sh`) is classified **Portable** ("run manually on Codex"). Confirm the parity-check.sh itself is portable (it should be — it's BSD-safe bash per §6). No change needed, just verify the graduated script lands in `hooks/lib/` (Portable) not `hooks/` root (CC-only). P1 should note this target classification so P3 doesn't misfile it.

### P1-4 — `fail-open WARN on parse error` (§6, §10.4) directly contradicts the gate's purpose and must be scoped to P1-only

§6 and §10.4 mandate "fail-open on parse errors with a WARN (never crash the gate)." For a *spike prototype* this is fine. But this instruction is forwarded toward P3's release gate, and a **fail-open hard-block gate is a contradiction**: a parse error → WARN → exit non-1 → release proceeds → drift ships. The single-user-CLI lesson (correctly cited) says don't fail-CLOSED on *daily-work* hooks; it does NOT say a *release-time hard block* should fail-open. A release gate that can't parse the source should **fail-CLOSED (block the release)** and make the human investigate — that's the safe direction at release time, and it's consistent with "minor+ = hard block."

**Recommend:** explicitly scope "fail-open WARN" to the P1 prototype only, and add a forward-note: "P3's release gate MUST fail-CLOSED on parse error (block + escalate), opposite of the prototype's fail-open." Otherwise P3 inherits a gate that can be defeated by a parse error — the worst kind of false-negative for a guarantee-critical gate.

---

## 3. Suggestions (P2)

### P2-1 — AC2 threshold `grep -c 'deliverable' ≥5` undercounts the known source signal and weakens the discrimination proof

DR §Context states Claude Alex has **17** `deliverable` mentions; the live drifted edition has 0. AC2 sets the regen floor at `≥5`. A regen that emits only 5–6 `deliverable` mentions would pass AC2 while carrying only ~⅓ of the source's deliverable content — a partial port that the count-based AC blesses. Since the whole Epic is anti-validation-theater (§10.1, count≠signal is a recurring project lesson), tie the floor to the source: `grep -c 'deliverable' <regen>` should be `≥` some fraction of the *current source count* (re-derived at run time, e.g. ≥ 0.7× source), not a frozen `5`. Same applies to the `research_complexity` floor (`≥1` is very weak when source has 5).

### P2-2 — Pivot threshold is concrete on the WHAT but soft on the WHO/WHEN — add a forcing function so it can't be rationalized past

Focus area 4: the STOP condition ("can't hit parity at ≤5min → reconvene") names a measurable trigger (good — better than most). The rationalization risk (a documented recurring project pattern: "Express = exempt," "small edit = low risk") is that a *nearly* passing run — say 6 min, or parity-at-92% with 2 sections needing a human touch — gets waved through as "close enough, proceed to P2." Harden it: spike-report.md should require an explicit **boolean** "≤5min headless: PASS/FAIL" and "parity exit 0 with zero human edits: PASS/FAIL", and state that **any FAIL ⇒ pivot, no partial-credit proceed**. Also require the DR-append line (Step 6) to record the *actual measured number*, not just "viable," so a 6-min result can't be laundered into "B viable." Make the threshold a gate the report must answer yes/no, not a sentence it can paraphrase.

### P2-3 — "Semantic-level content coverage" (user req) vs the 3-layer proxy — name the residual false-negative class explicitly in parity-criterion.md

Focus area 3: section + constraint + capability-marker coverage is a *sound and pragmatic* proxy for "semantic coverage" — it is mechanizable, which the user requires, and it catches the demonstrated drift (whole tracks absent). Its honest limitation: it verifies **presence**, not **fidelity**. A regen could contain a `deliverable` section heading + the marker token + a MUST line, passing all three layers, while the section's *body* paraphrases the protocol incorrectly or drops a sub-rule that isn't a MUST/marker. That is a real semantic false-negative the layers cannot catch. §4 already gestures at this ("'Semantic' correspondence that can't be reduced to the above is flagged for human spot-check"). Strengthen it: parity-criterion.md should *name* this class ("presence-not-fidelity: layers prove a section EXISTS, not that its body is a faithful transform") and define the human spot-check as a **required** step in P2/P3, not an optional flag. The criterion is sound as a *drift-presence* gate; it should not be oversold as a *fidelity* gate.

### P2-4 — Minor: §5 ("Pivot decision") references and AC numbering are clean; one doc nit

The handoff is missing a §5 header (jumps §4 → §6) — §5 content ("pivot decision") is folded into §1/Req-5. Not load-bearing, but if a downstream tool greps for `## 5`, it won't find it. Cosmetic; flag only because the AC/section discipline elsewhere is tight.

---

## 4. Overall Assessment

**CONDITIONAL PASS.**

The spike de-risks the *named* unknowns (regen feasibility + a mechanizable parity criterion) and is well-grounded, anti-theater-conscious, and correctly propagates the single-user-CLI constraint into P3 AC5 (focus area 5: **yes, correctly propagated** — Epic P3 AC5 verifies `grep -c 'parity' .claude/settings.json` = 0, and DR §"Critical constraint" + handoff §10.2 both anchor it). The phase interfaces are mostly clean.

But two P0s must be resolved before this de-risks the *right* unknowns:
- **P0-1**: n=1 manual regen proves feasibility, not the *reliability* the DR explicitly names as unknown #1, and cannot establish the recurring ≤5min budget the pivot threshold depends on. Add a headless run + isolate the recurring cost, or honestly downgrade the verdict to "feasible, reliability unproven."
- **P0-2**: Decision #3's "proves it generalizes to Blake" is an unsupported generalization across a genuinely different transform surface (82 vs 3 AskUserQuestion; Ralph-Loop/Agent-spawn dominate Blake). Either add a lightweight Blake transform-surface check or rewrite the rationale to carry Blake as an explicit P2 residual risk.

The biggest *hidden* risk in architecture B that the spike under-touches is **P1-1 + P1-4 together**: a capability-marker list that's secretly hand-curated plus a fail-open gate would together produce a P3 release gate that *looks* like a hard-block but silently passes future drift — the exact "validation theater" failure the YOLO audit flagged. Fixing the marker-derivation to be mechanical-on-current-source and scoping fail-open to P1-only closes that hole. Resolve P0-1 and P0-2 (and fold P1-1/P1-4 into the parity-criterion spec) and this is a PASS.
