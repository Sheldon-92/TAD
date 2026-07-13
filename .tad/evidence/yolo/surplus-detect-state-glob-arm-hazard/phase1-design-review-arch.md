# Phase 1 Design Review — Backend/Infra Architecture Lens

**Handoff:** HANDOFF-surplus-detect-state-glob-arm-hazard.md (full-template v3.1.0, 2026-07-05)
**Reviewer:** backend-architect (installer routing / shell regression fixture)
**Domain auto-detect:** Files to Modify = `.tad/tests/detect-state-fixture.sh` (bash) + tad.sh (installer routing, read-only). No frontend, no auth. → **backend/infra architecture review**.
**Date:** 2026-07-05
**Supersedes:** the 2026-07-02 content previously at this path (that reviewed the now-abandoned dot-bounded-glob fix; the live task is fixture-creation with zero tad.sh change).
**Verdict:** CONDITIONAL PASS — 0 P0, 2 P1, 3 P2. Design is sound and low-blast-radius (tad.sh zero-change, extraction approach correct, all 6 case expectations trace correctly against live code). But the fixture as specified does **not** exercise the code region the task exists to protect.

---

## Verification performed

1. Read tad.sh L1320-1480: `_tad_ver_cmp` (L1330-1341), `detect_state` (L1343-1373), `case $STATE` consumer (L1427-1464), `TARGET_VERSION="2.33.0"` (L22).
2. Re-ran AC1: `grep -cE '^[[:space:]]*2\.[0-9]+\*\)' tad.sh` → **0**. FR1 ground truth holds; tad.sh zero-change is correct.
3. Reproduced the FR3 matrix against live bodies — all 6 expectations correct (2.19.1/2.20.0→upgrade, 2.33.0→current, 9.9.9→current, abc→old, fresh→fresh).
4. **Instrumented `detect_state` to record which branch each case takes.** Result drives P1-1:

```
2.19.1  -> upgrade[samemaj]        <- numeric path, glob block NOT reached
2.20.0  -> upgrade[samemaj]        <- numeric path, glob block NOT reached
2.33.0  -> current[eq]             <- exact match, glob block NOT reached
9.9.9   -> current[newer]          <- ver-cmp path, glob block NOT reached
abc     -> old[unparse]            <- fail-safe, glob block NOT reached
1.9.0   -> CROSSMAJOR-BLOCK-REACHED:old   <- only vmaj<tmaj reaches the glob block
1.8.0   -> CROSSMAJOR-BLOCK-REACHED:v1.8
```

---

## P0 — Blocking

**None.** Core design decisions are correct: zero tad.sh intrusion, runtime sed-extraction over copied bodies (single source of truth, MQ5), bash-enforcement guard (NFR2), `|| true` on assertion greps (lesson 1), fail-safe `abc→old` case (lesson 2). All case expectations are empirically correct. Nothing blocks implementation on correctness grounds.

---

## P1 — Should fix before acceptance

### P1-1 — The runtime fixture never reaches the glob-case block it claims to lock (validation-theater risk)

The task's stated value (§1.2, §1.3, §6 "Human審查問題") is: *"any future edit that reverts `detect_state` to order-sensitive glob would be caught red by the fixture."* My branch-trace proves this is **false under the current major-2 target**. All six matrix inputs resolve on the exact-match / numeric-compare / fail-safe paths **before** the cross-major `case "$ver"` block (tad.sh L1359-1367) — the exact region where a reintroduced `2.1*)`/`2.2*)` arm would live. That block is only reachable when `vmaj < tmaj`, which no 2.x input can satisfy while the target is 2.x.

Consequence: the runtime fixture's protection against the *glob hazard specifically* is **zero**. The only artifact that actually guards the hazard is the **AC1 grep** (`grep -cE '^[[:space:]]*2\.[0-9]+\*\)' == 0`) — a structural check, not the behavioral fixture. This is precisely the project's own **"Validation Theater"** failure mode (principles.md, YOLO Epic audit 2026-05-15): a green fixture confirms the numeric path works but does not prove the anti-hazard property the task exists to establish.

Two holes this creates:
- AC1's grep matches only the *literal* `2.<digits>*)` at line start. A reintroduced arm written as `2.1[0-9]*)`, `2.19*|2.2*)`, or a structural revert that drops the `_tad_ver_cmp` guard entirely would evade **both** the grep (pattern miss) **and** the fixture (block unreached). No layer catches it.
- A future maintainer could delete the AC1 grep believing "the fixture covers the glob behavior" — the fixture's framing invites that mistake.

**Recommendation (do at least one; ideally a+b):**
- (a) Add ≥1 cross-major case that actually executes the glob block so it is live-tested, not dead-tested — e.g. `1.9.0 → old` (falls to `*)`) and `1.8.0 → v1.8`. This does NOT reopen out-of-scope v1.x *routing* work; it just gives the fixture a live assertion inside the block so a broken/injected arm turns it red. The FR4 negative assertion only has teeth once a case reaches that block.
- (b) Reframe the fixture's stated purpose honestly in the completion report: it locks the **numeric-routing behavior of the refactor**; the **anti-2.x-glob property** is guarded by AC1's grep. Record the split so nobody removes the grep.
- (c) Strengthen AC1 to also assert the structural invariant that the `_tad_ver_cmp` numeric guard precedes any `case "$ver"` glob, so a guard-removal revert is caught.

### P1-2 — Extraction-integrity preflight (FR5) verifies text, not that the functions are actually defined

FR5/§4.1 preflight asserts the sed output is non-empty and *contains both function names* (a text grep). That does not prove extraction produced **callable** functions. The extraction contract is fragile by design (§11.1 admits it depends on "function ends with a column-0 `}`"). If someone reformats `detect_state` to introduce a column-0 `}` mid-body (nested heredoc terminator, a reflowed brace), the sed range `/^detect_state() {/,/^}/` truncates at the first column-0 `}` — yielding text that still *contains the name* (passes the grep preflight) but is a broken partial body. Sourcing may then error (caught by `set -e`) **or**, depending on truncation point, define a wrong-behaving function that passes silently.

**Recommendation:** After sourcing the extracted file, assert both functions are actually defined before running any case:
`declare -F _tad_ver_cmp >/dev/null && declare -F detect_state >/dev/null || { echo "FAIL: extraction did not yield callable functions"; exit 1; }`
This is a stronger and cheaper integrity gate than a text grep and is the true "extraction is the integration test between fixture and tad.sh" contract §8.2 claims.

---

## P2 — Note explicitly

### P2-1 — Business-value chain is only half-covered (string asserted; string→ACTION mapping is not)
§1.2's risk is *"wrong migration path → wrong upgrade action for every downstream project."* The fixture asserts the `detect_state` **string**, but the string→`ACTION` mapping in `main()`'s `case $STATE` (L1427-1464) — the half that actually selects install/upgrade/migrate/none — is verified only on paper (MQ3 table). If someone remapped e.g. `upgrade → ACTION=migrate`, the fixture stays green. Legitimate scope boundary (fixture targets `detect_state`), but state it as a **known coverage limit** in the completion report so "installer routing is protected" isn't over-read.

### P2-2 — `elif [ -d ".tad" ] → old` branch (L1368) untested
Two distinct routes to `old`: unparseable major (tested via `abc`) and `.tad` dir present but no `version.txt` (L1368, untested — a real interrupted/legacy install state). Cheap 7th case (sandbox with empty `.tad/`, no `version.txt` → `old`) exercises a different branch than `abc`. Optional per §10.2, but worth noting.

### P2-3 — Cleanup-trap robustness under `set -eu`
`trap 'rm -rf "$WORK"' EXIT` (§4.2): if `mktemp -d` fails, `set -e` exits before `$WORK` is assigned; the EXIT trap then dereferences an unbound `$WORK` under `set -u`, masking the real mktemp failure with a confusing unbound-variable error. Initialize `WORK=""` at top and guard: `trap '[ -n "$WORK" ] && rm -rf "$WORK"' EXIT`. Never a data-loss risk (`rm -rf ""` is a no-op) — purely diagnostic clarity.

---

## Blast radius assessment

**Minimal and well-bounded.** New file only; tad.sh untouched (AC1/AC8 confirm). All execution inside `mktemp -d` sandboxes with an EXIT-trap cleanup; no network, no shared state, no global installs. The one coupling to production code — the sed extraction contract — is the correct trade (single source of truth over a drifting copy, per MQ5); its only failure mode is a loud fixture break, further hardened by P1-2. FR6's evergreen expectation (`upgrade` iff tmaj==2 else `old`) correctly anticipates a future major bump — I verified `1.9.0→old` under a hypothetical 3.x target matches the formula.

## Bottom line
Solid, low-risk, honest handoff (it self-documents the extraction fragility and the major-bump degradation). The single material gap is P1-1: the behavioral fixture and the structural grep protect **different** things, yet the handoff frames the fixture as protecting the glob hazard when only the grep does. Add a cross-major live case + record the guard split (P1-1), tighten the preflight to `declare -F` (P1-2), and this is a clean Gate.
