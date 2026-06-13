# Phase 3 Review — synthetic-data — CORRECTNESS lens

> Adversarial review of the upgraded `synthetic-data` capability pack against the
> dual-layer Quality Bar (`.tad/evidence/pack-quality/QUALITY-BAR.md`).
> Reviewer posture: default skepticism, try to REFUTE that it meets the bar.
> Date: 2026-06-13

## lens
correctness — does the upgraded SKILL.md + references actually meet the dual-layer bar; is the guidance internally consistent and actionable?

## meets_bar
**true** — both layers clear the bar decisively; the one genuine correctness defect (below) is a framing/internal-consistency flaw in the cross-cutting prose, not a bar failure.

## findings

### Layer A (structure) — 10/10 (pass line 7/10), VERIFIED by re-running §1 checks
- A1 frontmatter ✓: `name: synthetic-data` (lowercase, no anthropic/claude), third-person `description` with what+when, ≤1024 chars.
- A2 progressive disclosure ✓: 5 `references/*.md` loaded on demand via Step 0 routing table.
- A3 body discipline ✓: `wc -l SKILL.md` = **133** lines, far under the 550 buffer.
- A4 routing ✓: Step 0/1/2 workflow + signal→reference table.
- A5 contract ✓: `CONSUMES`/`PRODUCES` present (count 2).
- A6 anti-skip ✓: explicit Excuse/Counter table.
- A7 nav index ✓: every reference has a `Quick Rule Index`.
- A8 fixture ✓: `examples/synthetic-data-fixture.md`.
- A9 eval wired ✓: fixture carries `discriminative_pattern` + `min_discriminative: 4` (NOT a combined fallback).
- A10 validation script ✓: `scripts/validate-curation-config.sh` is executable (`-rwxr-xr-x`), correctly named, matches the SKILL invocation string.
- Soft constraints hold: references are one level deep (no nesting); forward-slash paths only; routing table file list is 1:1 with actual files (no dangling reference).

### Layer B (depth) — 4/5 (fail line ≤2), specN re-counted live
- `specN` recomputed with the §2.3 alternation over the pack tree = **50** → lands in the 40-59 bucket → **Layer B 4**. Well clear of the ≤2 shallow band.
- Rules carry research-landing specifics a no-pack LLM cannot recite: `R_dedup=0.75` + OPT-125M last-token embedder (DEDUP8), `num_perm=256`/5-gram/J=0.7/~20 bands (DEDUP3), LSHBloom 270%/18×/54× (DEDUP5), SemDeDup ~50%/~2× (DEDUP7), `ArmoRM-Llama3-8B-v0.1` exact id (GEN7), HelpSteer2 5-attr Likert 0-4 + RPO + Nemotron-4-340B-Reward (PA7), ConTAM `mincount 1 / skip_budget 0 / n<8` (CON4).
- Technical descriptions spot-checked for correctness — all sound: DPO pairwise loss form, RRHF length-normalized log-prob rationale (favors shorter without 1/|y|), MinHash LSH band/Jaccard mechanics, GRPO=verifiable-task routing, float32-exact-to-16,777,216 precision argument for BINARY_VECTOR.

### Discriminative gate — sound, not validation theater
- Fixture deliberately EXCLUDES well-known generic ML terms (Self-Instruct, MinHashLSH, ROUGE-L, GRPO, SQuADv2) from the discriminative pattern and counts only 19 pack-unique markers; `min_discriminative: 4`.
- Pattern is internally consistent across frontmatter `discriminative_pattern`, the `## Verification Command`, and the `Excluded from gate` note (same marker set).
- 13 unique discriminative markers appear in SKILL.md body alone (more across references), so a WITH-pack agent clears 4 easily while a no-pack control plausibly stays <4. Gate construction is defensible.

### Validation script — behaviorally correct on the load-bearing path
- Re-ran live: exact-only-dedup config → P0 (check 1); decontam-AFTER-score config → P0 (check 5 line-ordering works); fully-correct config → checks pass. Exit codes match the documented "0=no P0 / 1=P0" contract.

## CORRECTNESS DEFECT (genuine, but not bar-sinking)

### [P2] SKILL body cross-cutting rule over-attributes the SWE-bench 35pp gap to contamination — contradicts its OWN reference CON2
- SKILL.md L31 (the cross-cutting rule, the single most-read paragraph) states: "Claude Opus 4.5 dropped 35 percentage points (80.9% → 45.9%) **from SWE-bench Verified to the contamination-resistant SWE-bench Pro**" — framing the full 35pp as a contamination-resistance effect.
- The pack's OWN `references/contamination-detection-rules.md` CON2 (L34) explicitly corrects this: SWE-bench Pro is "a *different, harder suite* — not a decontaminated Verified … the Verified→Pro gap is therefore NOT pure contamination inflation — it conflates contamination, suite difficulty, and harness/eval differences," and notes Anthropic's own system card reports ~52% under its harness (not 45.9%).
- So the body presents as a clean contamination example precisely the comparison the reference flags as confounded. An agent that reads only the body (progressive disclosure means the body is what loads first / always) will propagate the over-attribution. QUALITY-BAR §6 specifically calls out version/metric-sensitive assertions like this as the class requiring nuance.
- Severity P2 not higher: the NUMBERS are factually verified correct (see fact_checks); the body does add the GSM1k "-13% on uncontaminated math" caveat and labels the 90% SQuADv2 figure "single-source"; the defect is one of framing/internal-consistency between body and reference, recoverable as soon as the reference loads.

## MINOR (non-blocking)

### [P3] validate-curation-config.sh ROUGE-L check accepts a WRONG threshold
- Check 2 does `grep -iE 'rouge' | grep -qE '0\.7|...'`. A line "ROUGE-L threshold **0.75**" false-ACCEPTS (substring `0.7` matches) — the script would green-light a too-loose threshold. Confirmed live: `echo 'rouge 0.75' | grep -qE '0\.7|...'` matches. Low impact (the documented config is exactly 0.7 and a 0.95 line correctly fails because it lacks `0.7`), but the assertion is not tight to the prescribed value.

## fact_checks
- "Claude Opus 4.5 80.9% SWE-bench Verified" → VERIFIED accurate (first model >80%; multiple 2026 leaderboard sources).
- "45.9% SWE-bench Pro" → VERIFIED accurate as the public Scale board number under standardized scaffolding.
- "SWE-bench Pro is contamination-resistant / built by Scale AI to resist contamination" → VERIFIED (Scale Labs public leaderboard).
- BUT: attributing the full 80.9→45.9 (35pp) drop to "contamination-resistance" is an over-claim — Pro is also a harder, different suite; Anthropic's own harness reports ~52% (per the pack's own CON2). The pack's reference is correct; the body's framing is the inaccurate part.
- specN live recount = 50 (QUALITY-BAR baseline ±2 drift expectation honored).
- SKILL body length = 133 lines (claim of "<500 / ≤550" satisfied).
- Routing table → 5 references map 1:1 to files on disk (no dangling/missing reference).
- Validation script is executable and its name matches every in-SKILL invocation.

## Verdict
Refutation attempt FAILED to dislodge the bar. Layer A 10/10, Layer B 4/5, discriminative gate sound and non-theatrical. The pack is internally consistent and actionable on every load-bearing path EXCEPT the body's SWE-bench contamination framing (P2), which contradicts its own reference and should be reworded to match CON2's conflation caveat before the pack is marked accepted. Bar is met; fix the P2 framing in the polish pass.
