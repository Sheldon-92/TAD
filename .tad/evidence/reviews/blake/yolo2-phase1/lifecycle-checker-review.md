# Narrow Review — AC10 lifecycle checker delta (commit 9d89eedf)

Reviewer model: opencode-go/ox-alpha-free
date: 2026-08-25

Scope: narrow independent review of `9d89eedf` (touches ONLY `.tad/scripts/yolo-recovery.test.mjs`, verified via `git show --stat`) against the Gate 4 lifecycle amendment round 2 in `276f6ac9`. Reviewer did not write the delta and did not repair anything.

Evidence gathered:
- `git show 9d89eedf` (full delta), `git show 276f6ac9 -- <handoff>` (amendment contract)
- Suite runs: plain `node .tad/scripts/yolo-recovery.test.mjs` → all 10 cases PASS; `--case required-evidence` PASS; `YOLO2_LIFECYCLE_SIM=archive ... --case required-evidence` PASS
- Independent audit harness (temp dir, no repo mutations): extracted the shipped `checkLifecyclePair` / `offAllowlist` source text verbatim from the committed file and re-derived all 16 combinations from the contract independently of the fixture table; plus 11 smuggling probes against `offAllowlist`
- Working tree clean at HEAD = 9d89eedf (reviewed file == commit)

## Q1 state machine completeness

**Complete.** The four boolean slots (handoff_active, handoff_archived, completion_active, completion_archived) yield exactly 16 combinations. The fixture table `LIFECYCLE_COMBOS` contains exactly 16 distinct entries covering all of them: 0000 absent · 1000/0100/0010/0001 incomplete · 1100/0011/1110/1101/1011/0111/1111 duplicate · 1001/0110 split · 1010 active · 0101 archived.

**Correct.** I re-derived the expected classification from the amendment text alone ("exactly one matching Handoff/COMPLETION pair valid: both-active or both-archived; missing/split/duplicate must fail") and drove the actual shipped `checkLifecyclePair` through all 16 inputs: **zero mismatches**. The two valid shapes return `{state:'active'|'archived', errors:[]}`; every other shape fails with exactly one error whose code is one of `lifecycle_absent|_incomplete|_duplicate|_split` (machine-readable, asserted with `startsWith`). The fixture asserts stricter than the contract (exact code per combo) and its expectations match the implementation everywhere.

Attempted mislabel construction: none exists — the input domain is closed at 16 states, all enumerated, all verified against an independent derivation. Two benign observations, neither contract-violating:
- Failure-code priority: e.g. `1100` (handoff duplicated, completion wholly missing) reports `lifecycle_duplicate` without also mentioning incompleteness. Contract requires failure with *a* machine-readable code; satisfied. Single-code-per-shape is deterministic and fixture-pinned.
- The pure function coerces `exists()` results through `!!` and queries only the four known paths (the fixture even throws on unknown paths), so truthy/falsy injection cannot alter classification.

## Q2 dual-copy bypass

**No bypass in the classifier or the default (production) code path.** All seven dual-copy shapes (any doc present in BOTH directories: 1100, 0011, 1110, 1101, 1011, 0111, 1111) fail with `lifecycle_duplicate`, and the main-case gate (`expect(lifecycle.errors.length === 0, ...)`) turns any error into exit 1. In a plain run `lifecycleExists` reads the real filesystem, so a genuine on-disk duplicate is rejected.

**Sim mode (`YOLO2_LIFECYCLE_SIM=archive`) — precisely stated:**
- What it does: overrides existence answers only for the four lifecycle paths (active→false, archive→true), fabricating shape 0101 so the post-move layout can be proven before the move, without touching real files. It does NOT bypass the machine itself — the machine still classifies 0101 as the sole valid archived shape.
- What it masks: because existence answers are overridden, a **real** on-disk dual-copy state would go undetected under sim, and the archive paths need not appear in the committed diff. This masking requires deliberate env-var opt-in; the default run remains authoritative and rejects duplicates/absent/split against reality.
- What it cannot mask: a genuinely **missing pair**. Under sim the resolved pair paths fall back to checking that the REAL active counterparts exist and are non-empty (`ACTIVE_PAIR` map, size>0). If neither active nor archived files exist, sim mode FAILS the required-evidence assertion. Corollary quirk: sim mode cannot validate a truly post-archive repo either (it demands the moved-away active copies) — it is strictly a pre-archive proving device; the authoritative post-archive check is the plain run, which reads disk directly and was proven correct by the Q1 enumeration.
- What sim proves / does not prove: it proves the shipped CODE (machine + allowlist membership + pair-resolution plumbing) accepts the archive state once real; it does NOT prove the repository currently is in that state, nor that archived content equals active content (it assumes move semantics by construction).

Residual risk (recommendation, not a defect): the Gate 4 final-head acceptance rerun must be executed as a **plain run (env unset)** after the real archive move; running acceptance with the sim var set would make the lifecycle assertion vacuous w.r.t. reality. Nothing in the delta prevents this, but the amendment's "two-state rerun" language already implies it.

## Q3 scope fence

**(a) Negative controls present — and strengthened.** `.claude/workflows/yolo-epic.workflow.js` and `.tad/hooks/precompact-session-snapshot.sh` retained; the delta ADDED two more red controls: `.agents/skills/alex/references/yolo-execution-protocol.md` and `.tad/config.yaml`. My harness confirms all four probe RED through `offAllowlist`.

**(b) Archive paths cannot smuggle arbitrary files.** `ALLOW_LIFECYCLE_ARCHIVE` holds exactly two literal entries matched by array `.includes(p)` (exact string equality) inside `offAllowlist`; no wildcards/prefixes. They are deliberately NOT in `ALLOW_EXACT`, so they carry no must-appear assertion — enforced by a new self-test (`expect(ALLOW_EXACT.includes(archive path) === false)`). Smuggle probes all RED: sibling files (`.bak`, `EVIL.md`), the directory itself, path-suffix and child-path variants, plus `PROJECT_CONTEXT.md.bak` variants and `src/product.js`. Observation (pre-existing, NOT introduced by this delta): `ALLOW_PREFIX` already contained the active COMPLETION path as a prefix entry, so a hypothetical sibling sharing that stem would slip through; unchanged by 9d89eedf, noted for completeness only.

**(c) PROJECT_CONTEXT.md expansion — ACCEPTED as lifecycle-class.** Verified facts: (i) Alex's own amendment commit 276f6ac9 modifies PROJECT_CONTEXT.md (+3/−1) as part of the same task's gate flow — the disclosure claim is factually accurate; (ii) PROJECT_CONTEXT.md appears in the frozen-base diff (`git diff --name-only bfce27f3..HEAD`), consistent with its placement in ALLOW_EXACT which carries a must-appear assertion (the suite passing confirms this is coherent); (iii) it is a root project-status/context document — neither product/runtime code (`.tad/scripts/*.mjs`), workflow (`.claude/workflows/`), hooks, nor config — so it does not violate the fence's stated invariant ("must never grow into a product/runtime scope expansion"). The addition is disclosed inline in the source and was flagged for exactly this independent review. Accept.

**(d) Runtime untouched.** `git show 9d89eedf --stat`: only `.tad/scripts/yolo-recovery.test.mjs` changed; `.tad/scripts/yolo-recovery.mjs` is untouched by the delta. The `offAllowlist` change is additive (third exact-list disjunct) and cannot widen acceptance beyond the two exact archive paths.

verdict: PASS

Basis: Q1 complete (16/16) and correct against an independent contract re-derivation; Q2 finds no bypass — duplicates fail on every default path, sim mode is explicit opt-in, still requires real active-pair content, and cannot mask a genuinely missing pair (with the plain-run recommendation recorded above); Q3 finds no weakening beyond the disclosed PROJECT_CONTEXT.md lifecycle addition, which is explicitly accepted in (c).
