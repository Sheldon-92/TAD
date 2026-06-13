# Phase 5 Review — video-creation pack — Anti-Slop Lens

**Lens**: anti-slop (are Layer B "specifics" genuinely research-grounded numbers/thresholds an LLM could NOT emit from training, or generic rules dressed up?)
**Reviewer**: adversarial subagent
**Date**: 2026-06-13
**Verdict (meets_bar)**: **true** — clears the anti-slop bar, BUT with one material fact-check defect that should be fixed (does not sink the lens because it is a wrong-value, not a fabricated-category, and the dominant mass of Layer B specifics fact-check as accurate post-cutoff numbers).

---

## Scope reviewed
- SKILL.md (router + quick rule index + anti-skip table)
- references/: ai-asset-generation.md (the upgraded file, +70 lines), storytelling.md, visual-design.md, audio-design.md, quality.md (+32 lines), tool-selection.md (+19 lines), vimax-patterns.md (read), production.md (indexed)
- examples/: photo-to-beat-sync.md, single-clip-narration.md (discriminative fixtures)
- scripts/: failure-mode-precheck.sh, verify-prereqs.sh (untracked — present)
- QUALITY-BAR.md (Layer B 0/2/5 anchors + specN counter + §6 version-verify mandate)

## specN (counted sub-dimension)
specN = **113** (pack-anchored DISC alternation, UTF-8 locale, dedup). ≥60 → Layer B bucket **5**. Far above the gold web-backend (27). High raw density, but per QUALITY-BAR §2.3 specN is ONE input — anti-slop requires the numbers to be GENUINE, not just present. Most of the mass survives that test (see fact_checks).

---

## Findings

### F1 (POSITIVE) — The headline Layer B numbers are real post-cutoff facts, not training-emittable
Seedance 2.0 fal.ai rates ($0.3024/s Std, $0.2419/s Fast, $0.18/s with video ref; 10s = $2.42 Fast vs $3.03 Std), Atlas Cloud $0.10/$0.08, and the "≤6 shots per 15s clip" Kling 3.0 AI-Director threshold all fact-check EXACTLY against current vendor/coverage pages (Seedance launched ~Apr 2026, Kling 3.0 launched 2026-02-04, gpt-image-2 launched Apr 2026). These are post-Jan-2026-cutoff products — a frontier LLM CANNOT emit these from training. This is the core anti-slop win: the discriminative anchors ($0.61/10s Fast-vs-Std delta, ≤6 shots/15s) are carriers of real research, not decoration.

### F2 (DEFECT — unsourced/likely-wrong number) — gpt-image-1 "DEPRECATES 2026-10-23"
The pack asserts gpt-image-1 deprecates **2026-10-23** (Model Lineup table + hard-date anti-pattern callout + Source Re-Verification row), sourced only to a third-party aggregator `evolink.ai/collections/gpt-image`, NOT OpenAI's own deprecations page. Independent check of OpenAI's actual announcement (June 2, 2026): the image-model shutdown date is **December 1, 2026**, and the deprecated SKUs are gpt-image-1-mini, gpt-image-1.5, chatgpt-image-latest (DALL·E 2/3 shut down May 12, 2026). No authoritative source corroborates an "October 23, 2026" date for gpt-image-1. This is precisely the version-sensitive assertion QUALITY-BAR §6 says MUST be checked against the authoritative vendor doc before trusting — the pack cited a weak aggregator and landed a wrong specific number dressed up with a ✓ "re-verified 2026-06-13" stamp. A wrong hard-date is worse than a vague rule because it reads as authoritative.

### F3 (DEFECT — internal contradiction compounding F2) — Lineup advice contradicts the real deprecation
The Model Lineup table recommends `gpt-image-1-mini` as "Cheapest — bulk drafts" and `gpt-image-1.5` as "Previous generation — existing pipelines only" (i.e. safe to keep). But OpenAI's actual Dec-1-2026 shutdown deprecates BOTH gpt-image-1-mini AND gpt-image-1.5. The pack's own escape-hatch ("or gpt-image-1-mini for cheap drafts") steers the agent toward a SKU that is itself being retired. Self-inconsistent guidance.

### F4 (MINOR — date inconsistency) — Seedance launch date stated two ways
Source Re-Verification table row says "Seedance 2.0 launched 2026-04-09"; this is internally fine but the decision-tree prose elsewhere is undated. Low impact, but the file carries two different precision levels for the same product family. Cosmetic — flag for cleanup, not a bar-sink.

### F5 (POSITIVE) — Genuine domain depth beyond raw numbers
Several rules are NOT restatable by a no-research LLM and are NOT mere numbers either: (a) "strip the query string before hashing presigned S3/R2 URLs or dedup silently fails" — a real failure mode with a concrete fix; (b) "TTS is synchronous, do NOT copy the Seedance submit-then-poll pattern" with the ❌ wrong-code snippet — operationalized anti-pattern; (c) sidechaincompress attack/release are in MILLISECONDS not seconds, fractional <1 = harsh gain jumps — a real FFmpeg gotcha; (d) Remotion staticFile() resolves only from public/ vs HyperFrames from assets/ — the "Path Split Rule" is a concrete tool-contract fact. These are Layer B "5" by the operationalized-criteria definition, independent of specN.

### F6 (POSITIVE) — Honest source labeling, mostly
The pack consistently tags WebSearch-approximate vs notebook-sourced material (audio-design SFX timing flagged "[WebSearch — approximate]"; tool-selection Motion Canvas/Manim flagged "not in notebook"). The 10-20ms audio-lead-visual claim is correctly hedged as approximate. This is the opposite of slop — it tells the agent which numbers to trust how much. The ONLY place this discipline broke is F2 (a blog-aggregator number stamped as ✓ verified).

### F7 (NEUTRAL) — A few "rules" sit in the 0-2 restatable band
Not everything is deep. E.g. storytelling "vary shot duration / don't be a metronome", visual-design "test contrast at brightest+darkest frame", quality "always add -movflags +faststart" are restatable by any frontier LLM. These are fine as scaffolding but should not be counted toward depth. They are a minority; the file does not pretend they are the discriminative core (the Quick Rule Index correctly foregrounds the concrete-parameter rules). No bar-sink, but note: specN=113 over-credits density relative to how much of it is genuinely non-restatable.

---

## Why meets_bar = true despite F2/F3
The anti-slop lens asks: are the specifics genuinely research-grounded, or generic rules dressed up? The DOMINANT mass (Seedance/Kling/Atlas pricing, endpoint specs, ms-unit FFmpeg gotchas, async-vs-sync TTS, path-split contract, request-hash/presigned-URL failure mode) fact-checks as real, post-cutoff, non-training-emittable content with correct vendor citations. That is a genuine pass. F2 is ONE wrong hard-date from a weak aggregator (a fixable fact error, not a fabricated-category masquerade) and F3 is its downstream contradiction — these are P1 corrections, not evidence the pack is slop. Recommend: fix the gpt-image-1 date to Dec 1 2026 + re-source to developers.openai.com/api/docs/deprecations, and correct the lineup table so it does not recommend now-deprecated SKUs.

---

## fact_checks
1. Seedance 2.0 fal.ai pricing ($0.3024/s Std, $0.2419/s Fast, 10s=$2.42 vs $3.03) — VERIFIED accurate against fal.ai model pages (2026-06-13). Genuinely non-training-emittable.
2. gpt-image-2 = OpenAI current flagship image model (released Apr 2026, ~99% text accuracy incl. CJK/Arabic) — VERIFIED accurate; post-cutoff fact.
3. Kling 3.0 AI Director "up to 6 shots per 15s clip", native 4K@60fps, launched 2026-02-04 — VERIFIED accurate against multiple Kling 3.0 coverage sources.
4. gpt-image-1 "DEPRECATES 2026-10-23" — **FAILED**: OpenAI's actual announcement (June 2 2026) sets image-model shutdown at Dec 1 2026 (gpt-image-1-mini/1.5/chatgpt-image-latest); DALL·E 2/3 shut down May 12 2026. No source supports Oct 23 2026. Sourced to weak aggregator evolink.ai, not OpenAI deprecations page. Wrong number dressed up with a ✓ "re-verified" stamp.
5. Lineup advice to keep using gpt-image-1-mini (drafts) / gpt-image-1.5 (existing pipelines) — **CONTRADICTED**: both are in the Dec-1-2026 deprecation set. Self-inconsistent guidance.
6. sidechaincompress attack/release = milliseconds, fractional<1 = harsh gain jump — VERIFIED plausible FFmpeg behavior; a real non-restatable gotcha (depth win).
