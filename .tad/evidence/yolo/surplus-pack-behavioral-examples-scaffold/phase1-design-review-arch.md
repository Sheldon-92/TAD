# Phase 1 Design Review — Backend/Architecture Lens

**Handoff:** HANDOFF-surplus-pack-behavioral-examples-scaffold.md
**Reviewer:** backend-architect (auto-detected: no frontend/API/auth files; deliverable is a bash CLI + fixture docs + gate-doc edit → default backend/architecture review)
**Date:** 2026-07-05
**Grounded against:** `.tad/scripts/pack-eval-runner.sh` (full, L1-330), `.claude/skills/ai-agent-architecture/examples/multi-agent-design-decisions.md` (full), handoff §§1-12.

**Verdict:** CONDITIONAL PASS — architecture is sound (thin-wrapper, reuse-not-rewrite, SSOT propagation, low blast radius), but two design-completeness gaps should be resolved before Blake starts.

---

## What is well-designed (no action needed)

- **Delegation contract is real, not assumed.** I verified the runner's single-mode: `main()` calls `assert_one` then `return 0` (always exit 0 — advisory). `assert_one` prints exactly one verdict line containing `→ PASS`, `→ FAIL`, or `→ SKIP` on every path (primary, backward-compat WARN, and both SKIP branches). The `--check` mapping (`→ PASS`→0 / `→ FAIL`→1 / else→2) is correct against all six printf paths, including the backward-compat `→ PASS  [WARN…]` line which still contains the `→ PASS` substring. Order-independence holds (a verdict line contains exactly one of the three tokens).
- **Reuse discipline** is correct per the L1 "Never Hand-Write" principle: `--check` shells out to the runner, does not re-parse markers (row 8 guards this).
- **Blast radius is contained.** New script lives in `.tad/hooks/lib/` but NFR3 forbids settings.json wiring; gate edit is additive-only with a SAFETY-count backstop (B4=32/1); runner + status side-file explicitly untouched (row 12). SSOT propagation (canonical FIRST → inline) is correctly ordered.
- **Grounding delta (§1.3)** is exemplary: the surplus-generated Epic text was reconciled against live repo state and the deviations are auditable.

---

## P0 — Blocking

None.

---

## P1 — Should fix before Blake starts

### P1-1: NFR2 (`set -euo pipefail`) directly contradicts §4.2.1 rule 6 and rule 8 — the validator as specified aborts on VALID fixtures

NFR2 mandates `--validate` run under `set -euo pipefail`. But two of the rules it must implement rely on capturing a **non-zero exit from a command that legitimately returns 1**:

- **Rule 6 (regex sanity):** the specified idiom is `printf 'x' | grep -oE "$pat" >/dev/null 2>&1; [ $? -le 1 ]`. A well-formed `discriminative_pattern` (e.g. `D(10|[1-9])…|Architecture Decision Document|Incident #|dual-agent` from the real ai-agent-architecture fixture) does **not** match the literal probe string `x`, so `grep` returns **1 (no match)**. Under `set -e` + `pipefail`, that bare pipeline statement aborts the script **before** `[ $? -le 1 ]` ever runs. Result: `--validate` exits non-zero on essentially every real fixture → §9.1 row 4 ("6 fixtures PASS") fails.
- **Rule 8 ("exit 0 iff zero FAIL lines")** requires the validator to **continue after a rule fails** so it can print *all* `FAIL:` lines (FR1: "printing each failed rule on its own `FAIL:` line"). Under `set -e`, the first failing check aborts and the multi-failure report is impossible.

These are not nitpicks — the handoff mandates two mutually exclusive things (strict-abort mode + accumulate-and-report-all-failures + probe-a-grep-that-returns-1). Blake will hit this immediately and may "fix" it by silently dropping `set -e`, losing the unbound-var protection NFR2 actually wants.

**Fix (specify in handoff):** keep `set -uo pipefail` for unbound-var/pipe safety, but drop bare `set -e`, OR wrap every probe in an rc-capturing idiom that neutralizes it, e.g.:
```
rc=0; printf 'x' | grep -oE "$pat" >/dev/null 2>&1 || rc=$?; [ "$rc" -le 1 ] || fail "bad regex"
```
and drive rule evaluation through an accumulator (`fails=0; check_x || fails=$((fails+1))`). The precedent cited by the handoff itself — `skill-body-verify.sh` — should be inspected for exactly which of `-e`/`-u`/`-o pipefail` it actually uses before copying "set -euo pipefail" verbatim.

### P1-2: The recurring Gate 3 item validates STRUCTURE only — the gate wording over-claims "behavioral quality" and re-opens a narrow validation-theater gap

The task exists to kill the "13/13 installed proves file ops, not quality" theater. The `--check` + synthetic PASS/control-FAIL evidence (rows 6/7) **does** produce genuine discrimination evidence — but **only as a one-time artifact for the 3 pilot fixtures during this task**. The thing wired into Gate 3 for *all future pack handoffs* (§4.2.3) invokes only `--validate`, which checks structure (fields present, sections present, regex compiles). It never verifies that `discriminative_pattern` actually **discriminates**.

This matters because the runner's own SAFETY header documents the exact failure mode: a fixture whose markers are generic lets a no-pack output score `3/3 combined but 0 discriminative` (the ai-evaluation CONTROL case). A structurally-valid fixture with a generically-worded `discriminative_pattern` passes `--validate` yet discriminates nothing. So the new Gate 3 item's intent claim ("markers 可判别 becomes mechanically checkable", §1.3) is not actually delivered by the mechanism — `--validate` proves discrimination *structure*, not *efficacy*.

**Fix (pick one):**
- (a) Narrow the gate wording so it does not claim behavioral quality — e.g. "examples/ fixtures **structurally valid** (frontmatter/sections/regex parse)", explicitly NOT "passing behavioral eval"; or
- (b) Add a lightweight discriminability heuristic to `--validate` (e.g. require the `## Anti-Slop Check` section to contain ≥2 `❌ generic-exclusion` lines, mirroring the real fixtures), so a purely-generic pattern is at least flagged; or
- (c) Commit the pilot control-FAIL outputs as fixtures and have the gate re-run `--check` against them. (a) is the cheapest and removes the over-claim without scope creep.

---

## P2 — Nice to have

### P2-1: §4.2.1 validate rules do not enforce the full fixture structure that FR3 mandates
FR3 lists the required body as `# Fixture:`, `## Input Scenario`, `## Expected Markers`, `## Verification Command`, **and `## Anti-Slop Check`**. But validate rule 4 only checks the middle three. A fixture missing the `# Fixture:` H1 or the `## Anti-Slop Check` section passes `--validate` while violating FR3. Either add them to rule 4 or note the intentional omission. (Ties into P1-2 option (b): the Anti-Slop section is where discriminability is justified.)

### P2-2: `→` is a multibyte (U+2192) token — make the `--check` mapping locale-robust
The verdict match keys on `→ PASS` / `→ FAIL`. Under a C/POSIX locale, multibyte matching in `grep`/`case` can misbehave (the global CLAUDE.md even flags CJK/UTF-8 CLI bugs). Recommend matching on the ASCII-safe suffix (`case "$verdict" in *"→ PASS"*) …` is fine in bash `case` with `LC_ALL` set, but a belt-and-suspenders `case "$verdict" in *" PASS"*)` keyed on the trailing ` PASS`/` FAIL`/` SKIP` word avoids any dependence on the arrow byte-sequence). Low risk since the runner emits the same bytes, but worth a one-line hardening.

### P2-3: The new Gate 3 item couples every future pack handoff's acceptance to `pack-eval.sh` correctness
Once §4.2.3 lands, every pack-touching Gate 3 depends on this validator being present and correct on the operator's machine. Combined with P1-1, a mis-ported `set -e` would fail-close legitimate handoffs. This is acceptable (it is a checklist item run by a human/subagent, not a fail-closed hook per NFR3), but the completion report should note the new operational dependency and confirm the validator is idempotent + self-contained (no repo-root assumptions beyond those the runner already makes).

---

## Coverage notes for the Conductor
- Design completeness (Gate 2 dimension): the delegation contract, data flow (MQ3), and SSOT sync (MQ5) are fully specified and verified against source. The gap is the `set -e`/rule-6 internal contradiction (P1-1) and the FR3-vs-rule-4 structure mismatch (P2-1).
- No security/secrets surface. No DB/API surface. Portability rules (NFR1) are correct and match the runner's own conventions (`grep -oE | sort -u | wc -l`, no `grep -P`).
