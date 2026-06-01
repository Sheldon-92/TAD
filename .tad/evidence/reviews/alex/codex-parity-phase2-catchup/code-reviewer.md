# Code Review — HANDOFF-20260601-codex-parity-phase2-catchup (DRAFT / design spec)

**Reviewer:** code-reviewer (blue-team, internal tooling)
**Artifact:** Alex handoff DRAFT for Codex-parity Phase 2
**Scope:** design-spec review against the 4 named reads. No edits proposed to live editions.
**Verdict:** **CONDITIONAL PASS** — sound direction, but 2 P0 design defects make AC1/AC3 mechanically unsatisfiable as written. Fixable in the handoff before Blake implements.

All findings are grounded in actual greps of the source SKILLs (run during review), not mental simulation.

---

## 1. Critical (P0)

### P0-1 — The must-cover body delimiter, if implemented as "next `_protocol:` key", swallows the anti_rationalization_registry block and computes its must-cover count as ~0

The whole point of P2 (Decision #1, §10.3) is that the per-category check is the SAFETY *guarantee*. That guarantee collapses for `anti_rationalization_registry` under the most natural reading of §4.

Ground truth in `.claude/skills/alex/SKILL.md`:
- `dream_protocol:` (allowlisted) starts at **L5502**.
- The `anti_rationalization_registry:` block lives at **L5811–5874**, at the END of the file, AFTER dream.
- Between them are col-0 keys `forbidden:` (L5679), `interaction:` (L5691), `success_patterns:` (L5698), `on_start:` (L5716).

If the script delimits a protocol body as "from the `_protocol:` key to the next **`_protocol:`** key" (which §4's prose "YAML key to next top-level key" does NOT disambiguate, and which is the obvious bash implementation), then `dream_protocol`'s body = **[5502, EOF)** and **engulfs the entire anti_rationalization_registry block**. Result: all 6 anti_rat occurrences get classified as "inside an allowlisted body" → `source_mustcover_count[anti_rat] ≈ 0` → the check requires `codex_count ≥ 0`, i.e. it requires NOTHING. The byte-exact-preserve category the handoff most wants to protect (§4: "for byte-exact-preserve categories like anti_rationalization_registry, require equality") becomes unenforced — silent validation theater, exactly the failure class this Epic exists to kill.

The fix is a one-line semantic correction the handoff MUST state explicitly:

> A protocol body runs from its `_protocol:` key to the **next col-0 key of ANY kind** (`^[A-Za-z_<]`), NOT to the next `_protocol:` key.

Verified this is correct: with "next col-0 key of any kind", dream's body = [5502, 5679), the anti_rat registry (own col-0 key + HTML BEGIN/END comments at col-0) is its own block, NOT in any allowlisted body, and must_cover counts it. Same trap exists for `evolve_protocol` (L4727) whose body, under the naive reading, would swallow `project_context_update`/`next_md_rules`/`knowledge_bootstrap`/`mandatory_review` (L4919–5020) before `publish_protocol` (L5155).

**Required handoff change:** Step 1 must pin the delimiter as "next col-0 key, any kind" and AC1 must add a dogfood asserting `source_mustcover_count[anti_rationalization_registry] == (full source count)` for alex (no anti_rat occurrence is legitimately inside an allowlisted body — verified: the 6 occurrences are at L557, L2820, L5806, L5811, L5818-region, L5874, none inside yolo/optimize/evolve/dream/publish/sync bodies).

### P0-2 — Per-category check requires all 4 SAFETY categories uniformly, but Blake source has anti_rationalization_registry = 0 and NOT_via_alex_auto = 0 → AC3 (blake PASS) is unsatisfiable, and the CURRENT check already FAILS blake

Ground truth:
- `.claude/skills/blake/SKILL.md`: `grep -c anti_rationalization_registry` = **0**; `grep -c NOT_via_alex_auto` = **0** (both are Alex-only categories).
- `.tad/codex/codex-blake-skill.md` (live): `anti_rationalization_registry` = **0**.
- The CURRENT `parity-check.sh` Layer 2 (L116–122) hardcodes `if [ "$has_ar" -eq 0 ]; then ... DRIFT=1`. **That means the current check already returns DRIFT=1 on blake unconditionally** — AC3 ("upgraded parity-check = PASS … exit 0") cannot pass without removing this hardcoded requirement.

§4 says the right thing in one place (`require codex_count[cat] ≥ source_mustcover_count[cat]`, which for a 0-source category trivially holds), but AC1 and AC3 enumerate "anti_rationalization_registry / forbidden_implementations / honest_partial / NOT_via_alex_auto" as if each is universally required, and the existing code contradicts §4. Blake will hit a direct AC-vs-code conflict.

**Required handoff change:** State explicitly: "A category with `source_mustcover_count == 0` is SKIPPED, not failed. Delete the hardcoded `has_ar > 0` / `has_fi > 0` bare-presence gates (L116–130) — they are subsumed by the per-category must-cover comparison and would false-FAIL Alex-only categories on the Blake edition." Without this, Step 5/AC3 deadlocks.

---

## 2. Recommendations (P1)

### P1-1 — Step 2 dogfood is sound, but pick the deletion target to defeat the count-floor masking
"Delete one must-cover `forbidden_implementations` block → must exit 1" is a *runnable, sound* anti-theater test (verified: alex has 12 must-cover forbidden_impl, all outside allowlisted bodies, so dropping one yields 11 < 12 → category FAIL). **But** if the upgraded check still keeps the old `forbidden_implementations > 0` bare-presence test as the gate (P0-2), deleting ONE block leaves 11 > 0 and the bare test still PASSes — the only thing that must catch it is the new per-category count comparison. The handoff should require the dogfood to assert the failure comes from the **per-category count line** ("forbidden_implementations: codex 11 < must-cover 12"), not merely "exit 1", so a residual bare-presence pass can't masquerade as success. Also delete a block that is NOT duplicated on the same line region (L3977 vs L4025 are distinct blocks) so the count genuinely drops.

### P1-2 — Pin the regen self-verify loop as bounded (max N rounds → honest_partial), not "re-emit then re-check"
Step D / Step 4 say "re-emit affected section verbatim then re-check" with no iteration bound. Blake is an LLM doing the regen; if its re-emit still condenses (the exact P1 failure — "procedure SAID strip-not-summarize and the LLM still condensed", §10.6), the loop can oscillate. Make it terminating and Blake-executable: "max 2 re-emit rounds per category; if still failing, STOP and honest_partial + pause for human (do NOT fake PASS)." This mirrors the project's Ralph-Loop circuit-breaker (3-same-error → escalate) and the honest_partial_protocol the handoff already preserves. As written it is a real loop only because Blake will eventually give up; spell out the give-up so it isn't an infinite-correction trap.

### P1-3 — Byte-safety of LIVE-edition replace is unspecified (§10.1 says "commit" but not "atomic write")
P2 overwrites `.tad/codex/codex-alex-skill.md` and `codex-blake-skill.md` in place. If Blake writes via a streamed regen that fails mid-way (quota cutoff, headless probe interruption in Step 6), the live file is left half-written and the launcher `--dry-run` (AC8) could pass on a truncated file or the repo is committed broken. Recommend the handoff mandate: regen to a scratch path → run upgraded parity-check on the scratch → only `mv` over the live path on exit 0 (atomic on same filesystem) → then commit. This is the project's standard "write to scratch, promote on gate approval" pattern and removes the half-written-live-file risk the focus area flagged.

### P1-4 — Headless probe (Step 6) measures the wrong thing if it reuses the same model that condensed in P1
AC6 accepts "regen-headless produced + parity result + recurring time". But a headless `claude -p`/`codex exec` with NO interactive correction is precisely the path that produced the 59-vs-150 condensation in P1. If the headless run FAILS the upgraded parity-check, that is a *legitimate and valuable* result (it proves headless-without-correction is not yet safe), not an AC6 failure. The handoff should state that AC6 is satisfied by recording the parity *verdict* (pass OR fail) + time, and that a headless FAIL is an honest finding, not a blocker — otherwise Blake may be pressured to fake a pass.

---

## 3. Suggestions (P2)

### P2-1 — §9.1 RUNNABLE FORMS block is correct; no grep bugs found
Verified against the two known project bugs:
- No `grep -c … | sort -u | wc -l` (=1) pipeline anywhere in §9.1.
- AC4b runnable form `grep -coE 'MUST|MANDATORY|VIOLATION'` uses **bare** pipe (ERE) — runs clean, returned `54` on live codex-alex during review.
- AC7 runnable form `grep -ci 'step4_5\|Pack Awareness'` uses **escaped** pipe (BRE, no `-E`) — correct, returned `0` (the drift P2 closes).
- The table-escaped row at L194 (`grep -coE 'MUST\|MANDATORY\|VIOLATION'`) is the rendering-escaped form; the PIPE-ESCAPE CONTRACT note correctly tells Blake to run the bare-pipe RUNNABLE FORMS instead. Good.
The only nit: add a RUNNABLE FORM line for the **new** per-category dogfood (Step 2) so AC1's "both runs pasted" has a copy-paste command, not just prose.

### P2-2 — Layer 1 already has the col-0 logic the must-cover computation needs — reuse it
The current Layer 1 extracts `[a-z_]+_protocol:` via `grep -oE` (L54) but does NOT bound bodies. The must-cover computation needs body bounds. Suggest computing all col-0 anchor line numbers once (`grep -nE '^[A-Za-z_<]'`) and deriving every protocol body's `[start, next-anchor)` from that single list — keeps Layer 1 and Layer 2 using one consistent delimiter definition and prevents the two layers from disagreeing on what "a protocol body" is.

### P2-3 — AC5 trace should record the must-cover denominator, not just before/after
AC5 records P1/P2/source-must-cover counts. Add the explicit per-category `source_mustcover = source_total − in_allowlisted_bodies` arithmetic in the trace (e.g. "forbidden_implementations: source 12, in-allowlisted 0, must-cover 12, P2 codex 12 ✅") so a future reader can audit the denominator, which is the whole correctness hinge (P0-1).

---

## 4. Overall

**CONDITIONAL PASS.**

The handoff's direction is correct and the anti-theater instinct (§10.2, Step 2 dogfood) is exactly right. The must-cover computation IS mechanically implementable in bash — but only with the delimiter pinned as "next col-0 key of ANY kind" (P0-1); the naive "next `_protocol:` key" reading silently zeroes out the anti_rationalization_registry guarantee, defeating the entire phase. Separately, the per-category check must treat 0-source categories as SKIP not FAIL, and the legacy hardcoded `has_ar>0`/`has_fi>0` gates must be removed, or AC3 (Blake PASS) is unsatisfiable and contradicts the current code (P0-2).

Blocking before implementation:
- **P0-1**: pin body delimiter = next col-0 key (any kind); add dogfood that anti_rat must-cover == full alex source count.
- **P0-2**: 0-source categories SKIP not FAIL; delete bare-presence `>0` gates; reconcile AC1/AC3 enumeration with §4.

Recommended before implementation: P1-1 (dogfood asserts the per-category count line), P1-2 (bound the re-emit loop → honest_partial), P1-3 (scratch→mv atomic promote of live editions), P1-4 (headless FAIL is an honest result).

Once P0-1 and P0-2 are written into Step 1/AC1/AC3, this is a clean, implementable handoff.
