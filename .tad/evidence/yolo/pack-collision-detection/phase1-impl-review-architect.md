# Phase 1 Implementation Review — Pack Collision Detection (backend-architect, blue-team, post-impl design-fidelity)

**Reviewer**: backend-architect (blue-team / defensive design-fidelity gate)
**Date**: 2026-05-31
**Artifacts reviewed**: `.tad/scripts/scan-collisions.sh`, `.tad/scripts/collision-signatures.txt`, `.tad/capability-packs/pack-collisions.yaml`, `.tad/guides/pack-collision-detection.md`, COMPLETION/HANDOFF phase1, live `.claude/skills/` files (hand-re-derived).
**Contract**: HANDOFF §4 (design) + §9.1 (AC4–AC7), §4.2C (LLM-confirm), §4.4 (precedence), §4.5 (one-liners).

---

## Verdict: CONDITIONAL PASS — P0: 0

The guide IS the LLM-confirm + precedence contract and it is correct, internally consistent with `pack-collisions.yaml`, and design-faithful to §4. All seven schema refs hand-re-derive against live files. No design drift on the load-bearing contract. The CONDITIONAL is driven by one semantic-correctness gap (P1-A: the `testing` category is used in data + guide §8 but is NOT a member of the precedence list the engine resolves against) plus a scanner-performance concern that undercuts the AC2 "run it and hand-re-derive candidates" evidence path. None of these are P0; the guide's contract holds.

---

## FOCUS-ITEM FINDINGS

### 1. Precedence engine doc (AC4) — PASS

Guide §3 ("Precedence Engine Semantics") specifies the ordered list exactly as §4.4 mandates:
`1 security/safety/compliance/data-integrity (non-overridable) > 2 correctness > 3 a11y > 4 performance > 5 style`.
- CROSS-category → `resolution: auto`, "lower category NUMBER wins", record winner/loser/both categories/rule + visible log. ✅ (guide §3 bullet 1)
- SAME-category → "precedence tie → `resolution: escalate` … no silent pick", record `reason: same-category`. ✅
- Uncategorizable → escalate: guide §3 "Uncategorizable → ESCALATE (P1-4 fallback)" + "list … CLOSED for P1, EXTENSIBLE in P2" + names the known-missing classes (licensing/legal, cost/economic). ✅
- No-silent-caps: "**EVERY resolution (auto AND escalated) is logged visibly.** There is no silent auto-resolve and no silent escalation." ✅ (guide §3)
- Internal consistency with `pack-collisions.yaml`: inter-font → `resolution: auto / winner: web-frontend / rule: "performance>style" / logged: true` matches "performance(4) outranks style(5)". contrast → `escalate / reason: same-category / logged: true`. pyramid → `escalate / reason: same-category`. All three resolution values match the engine the guide documents. ✅
- `grep -c 'performance'` = 7 (AC4 needs >0). ✅

### 2. LLM-confirm contract (AC4 / §4.2C) — PASS (with one toothing observation, P2-A)

Guide §4 gives the numbered 1–5 procedure (read candidates → open BOTH refs → assign category per side → compute resolution → write/DROP). It carries the **required `confirmed_by` + `drop_rationale` fields** (§4 "Required fields per candidate") AND a **MANDATORY co-mention false-positive worked example** (§4 "MANDATORY worked example — a co-mention false positive (drop)") that shows a concrete candidate, the agent opening both refs, and a real `drop_rationale`. Key teeth: "a shared TOKEN … is **not** a collision. Only a shared **prescription with opposing intent** is." — this is exactly the grep-theater defense the audit gap demanded.

The three real rows in `pack-collisions.yaml` each carry a populated `confirmed_by` naming the two refs opened (e.g. `opened web-ui-design/SKILL.md:93 (style ban) + web-frontend/references/performance.md:215 (next/font perf endorse)`). So the contract is **fillable, not toothless prose** — it is demonstrated, not just described.

> P2-A (toothing limit, not a defect against contract): the contract is procedurally strong but remains agent-honesty-dependent (no mechanical gate forces `confirmed_by` to be non-empty before a row lands — consistent with TAD's "Mechanical Enforcement Rejected on Single-User CLI" stance). The worked example is the right mitigation; flagging only so P2 consumers know the field is advisory, not enforced.

### 3. Surfacing one-liners (AC5) — PASS

Guide §5 carries BOTH formats verbatim and exact:
- `⚙️ resolved: {winner} over {loser} ({rule})`
- `⚠️ unresolved: {a} vs {b} — human decides ({topic})`
`grep -cF '⚙️ resolved:'` = 2, `grep -cF '⚠️ unresolved:'` = 2 (template line + worked example each). Byte-exact match to §4.5 including the em-dash and emoji. ✅

### 4. Anti-theater rule (AC6) + not-a-hook (AC7) — PASS

- AC6: guide §6 ("Anti-Validation-Theater Acceptance Rule (LOAD-BEARING)") states **"'N collisions found' is NOT acceptance."** and "Acceptance **MUST hand-re-derive every flagged collision's two `file:line`**", plus the bonus `git status` in-flight-work check (lifted from the 2026-05-30 dead-code-scanner lesson). `grep -niE 'not (acceptance|sufficient)|count.{0,4}signal|hand-re-derive'` ≥1. ✅
- AC7: guide §1 "`scan-collisions.sh` is a CLI tool, NOT a hook" + "MUST NOT be added to `.claude/settings.json`". `grep -ni 'not a hook'` = 2. There is no `.claude/settings.json` in the tree → `grep -c 'scan-collisions'` = 0 trivially holds (AC7 satisfied; note settings.json absence below). ✅

### 5. Inter resolution semantic check — PASS (residual risk adequately mitigated, P2-B)

`pack-collisions.yaml` resolves inter-font on category number (performance(4) > style(5) → web-frontend wins). The §4.4/guide concern is that this auto-resolve could silently kill a legit `next/font` use OR silently bless Inter-as-primary-typeface, because the precedence number can't see the primary-vs-loading semantic distinction. Mitigation present and sufficient for a human spot-check:
- The **loser's quote is carried** in `a_says.quote` = "NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface." and the **winner's quote** in `b_says.quote` = "import { Inter } from 'next/font/google'". A human reading the row sees BOTH the ban text and the loading text → can verify the win is a *font-loading optimization*, not a primary-typeface install.
- The row's inline NOTE makes the semantic explicit: "the visible log lets a human verify web-frontend is loading Inter as an OPTIMIZED webfont, NOT installing it as the PRIMARY typeface (which the style ban targets)." Guide §3 repeats the same caveat.
So the residual risk (precedence resolves on category-number, not the primary-vs-loading semantic) is surfaced for human verification rather than buried. The escalation-on-doubt path exists via the §3 uncategorizable→escalate fallback if an agent judges the semantics genuinely ambiguous. Adequate for P1.

> P2-B (forward note): the auto-resolve is correct ONLY because the loser quote + NOTE are present. If a P2 surfacing consumer emits ONLY the §5 one-liner (`⚙️ resolved: web-frontend over web-ui-design (performance>style)`) WITHOUT the loser quote, the human loses the primary-vs-loading distinction. P2 must surface the quotes alongside the one-liner, not the one-liner alone. Recommend the guide §5 add an explicit "surface with both quotes for auto rows" sentence in P2.

### 6. Schema VALUE-field propagation — PASS

`pack-collisions.yaml` carries per side `ref` + `quote` + `category` (nested under `a_says`/`b_says`), not just keys — directly honoring the 2026-05-31 "Parser Feeding a Human-Review Queue Must Propagate VALUE Fields" lesson. The scanner (`scan-collisions.sh` lines 222–240) likewise propagates `a_ref/a_quote/b_ref/b_quote` per candidate (key AND value). No content-loss. ✅

### 7. Implementation vs §4 design — PASS (matches; no drift)

- Canonical tree: scanner `SKILLS_DIR="$REPO_ROOT/.claude/skills"` (lines 30–35) and every schema `ref` anchored to `.claude/skills/` — matches §4.3 P0-2 invariant; guide §2 states it. ✅
- File-set enumeration: `pack_files()` (lines 102–108) = `find -name '*.md'` minus CHANGELOG/LICENSE*/README — matches §6 step 3 / P1-1. ✅
- grep-seed/LLM-confirm split: scanner has NO LLM call; STAGE 2 is doc-only — matches §4.1. ✅
- BSD-safe + grep-c trap: shared-keyword pre-filter uses `comm -12` not `grep -c|sort -u|wc -l` (lines 198–200, with the correct warning comment). file-write heredoc + `flatten()` (lines 129–132) for newline safety — matches the 2026-05-31 heredoc-sink lesson; not interpreter-exec. ✅
- AC8: `git status --short` for alex/SKILL.md, blake/SKILL.md, pack-registry.yaml = empty (verified live). ✅

---

## ISSUES

### P0 — none

### P1-A (semantic-correctness): `testing` category is not a member of the precedence list it is resolved against
`pack-collisions.yaml` pyramid row uses `category: testing` for both sides and `reason: same-category`. Guide §8's summary table also prints `a category = testing / b category = testing`. But the precedence list (guide §3, §4.4) has NO `testing` entry — §3 annotates it as "the `testing` directives sit in this band" under `correctness`. Consequences:
1. An agent applying the §4 contract literally ("Assign a `category` per side from the closed list (§3)") cannot assign `testing` — it is not in the closed list. Strictly, `testing` is *uncategorizable* against the literal list → the §3 fallback would (wrongly) classify it. The intended mapping is `testing → correctness(2)`, but that mapping lives only in a parenthetical, not in the list.
2. The same-category escalate verdict is still CORRECT (both sides map to correctness → tie → escalate), so no wrong resolution ships. But the data records a category name that is not a precedence member, which a P2 consumer comparing category numbers cannot rank.
**Fix (cheap, P1)**: either (a) record `category: correctness` for both pyramid sides (with a `subdomain: testing` note), OR (b) add `testing` explicitly to the §3 list as an alias of `correctness(2)` so the closed list literally contains every category the data uses. Prefer (a) — keeps the precedence list to the 5 canonical bands and makes category values rankable by P2. This is the inverse of the "VALUE-field propagation" hygiene: here a value (`testing`) is propagated that the consumer's ranking engine can't interpret.

### P1-B (AC2 evidence path / performance): scanner does not complete in a practical acceptance window
Running `bash .tad/scripts/scan-collisions.sh` did not finish within 90s on this machine (perl-alarm killed it, exit 142) and the candidates file held only the header (`candidates:` with zero `- pack_a:` entries) after partial runs. The COMPLETION's "5 candidates across 3 topics" output is plausible (the inner logic is correct on inspection) but I could NOT reproduce a completed candidates emission to independently hand-re-derive AC2 against fresh scanner output. The cost is `O(packs² × signatures)` with a `find` + per-file `grep -nE` inside `first_match()` for every pair×signature×orientation; ~35 packs × pairwise (~600 pairs) × 3 sigs × 2 orientations × N files is the slow path.
- This does NOT break the contract (the guide, schema, fixtures, and the 3 confirmed rows all hand-re-derive correctly from `pack-collisions.yaml`, which is the load-bearing artifact). But AC2's acceptance method ("run scanner → read candidates.yaml → hand-re-derive") is impractical at current speed, and a Gate-4 re-derivation against live scanner output (the proper anti-theater check) is gated on a run that times out.
**Fix (P1)**: (a) short-circuit `first_match()` across files with a single `grep -rnE --include='*.md'` per pattern over the pack dir instead of looping files in shell; (b) hoist the keyword pre-filter so non-overlapping pairs skip the find entirely (already done via `comm`, but the dominant cost is the inner per-file loop, not the pre-filter); (c) document expected runtime in the guide/`--help` so an acceptor knows to allow minutes, not seconds. At minimum, capture a completed `candidates.yaml` as committed evidence so Gate 4 can diff against it without a live run.

### P2-A — `confirmed_by`/`drop_rationale` are advisory, not mechanically gated (see Focus 2). Acceptable per TAD single-user enforcement stance; noted for P2.
### P2-B — P2 surfacing must carry loser quote alongside the §5 auto-resolve one-liner, else the Inter primary-vs-loading distinction is lost (see Focus 5).
### P2-C — no `.claude/settings.json` exists in the tree, so AC7's `grep -c 'scan-collisions' .claude/settings.json` = 0 passes vacuously. The guide's "not a hook" declaration is the real defense and is present; just note the AC's grep is trivially satisfied by file-absence, not by an inspected-and-clean settings file.

---

## Evidence (live, this session)
- 7/7 schema refs hand-re-derived: SKILL.md:93 / performance.md:215 / SKILL.md:454+:476 / accessibility.md:45 / testing.md:15+:19 / test-strategy-rules.md:25+:31 — all quoted text present at stated lines. ✅
- AC4 `grep -c performance`=7; AC5 `⚙️`=2 / `⚠️`=2; AC6 anti-theater present; AC7 `not a hook`=2, settings grep=0 (file absent); AC8 SKILL/registry git status empty.
- Scanner: `bash -n` exit 0, `--help` exit 0, `set -euo pipefail` count=1; full run did NOT complete in 90s (P1-B).

---
**Overall: CONDITIONAL PASS · P0 = 0 · 2×P1 (P1-A category-list membership, P1-B scanner runtime/AC2 evidence) · 3×P2.**
The load-bearing guide contract (precedence + LLM-confirm + one-liners + anti-theater + not-a-hook) is correct, internally consistent with the data, and design-faithful to §4. Recommend clearing P1-A before P2 consumes category numbers, and capturing a committed completed `candidates.yaml` for P1-B.
