# Phase 5 Review — video-creation — CORRECTNESS lens

- **Lens**: correctness (internal consistency + actionability of guidance vs the dual-layer QUALITY-BAR)
- **meets_bar**: false
- **Reviewer stance**: adversarial / refute-first
- **Date**: 2026-06-13

---

## Verdict

The pack **clears Layer A (structure) and Layer B (depth) by wide margins**, and its
discriminative eval is genuinely discriminative. But the **correctness lens** specifically
tests whether the guidance is internally consistent and actionable, and here the pack has
**three reproducible, load-bearing contradictions** — all concentrated in the most
copy-paste-prone reference (`references/ai-asset-generation.md`). An agent that copies the
executable code produces behavior that contradicts the pack's own prose. That is a
correctness failure, not a cosmetic one, so `meets_bar=false` on THIS lens.

What is fine (so the verdict is scoped, not a blanket fail):
- Layer A: SKILL body 191 lines (<550); valid frontmatter (name+desc, 3rd person);
  8 references + 2 executable scripts + 2 fixtures; Step 0/1/2 routing table;
  CONSUMES/PRODUCES; anti-skip table; Quick Rule Index; both fixtures carry
  `discriminative_pattern`+`min_discriminative`. ~9-10/10.
- Layer B: specN = **113** (bucket ≥60 → 5). Real research-grounded thresholds
  (poll 5s/10s/120s, CRF +6≈half-size doubling rule, -14 LUFS, SNR>30 dB,
  BPM ranges, sidechaincompress ms-not-seconds gotcha, ViMax ≤6 shots/15s).
- discriminative: fixture A (photo-to-beat-sync) scores 4/4 ≥ min 4; CONTROL scores 1
  (< threshold → FAIL). Gate is genuinely discriminative, not theater.
- failure-mode-precheck.sh + verify-prereqs.sh both execute correctly (tested:
  dirty file → exit 1 flagging all 6 patterns; clean file → exit 0).
- Async (Seedance submit-then-poll) vs synchronous (TTS no-poll) split is internally
  coherent and explicitly anti-confused in the anti-pattern table.

---

## Findings (correctness defects — each is a refutation)

### F1 (HIGH) — "Seedance 2.0" branding vs `seedance-1-lite` model IDs in every code block
The pack brands the tool **"Seedance 2.0"** everywhere prose-side: SKILL Step 0 prereq
(`FAL_KEY … for Seedance 2.0`), SKILL routing row (`§Seedance 2.0 Rules`), Quick Rule Index
(`Video clips → Seedance 2.0`), the decision tree (`→ Seedance 2.0 (default)`), the section
header (`## Seedance 2.0 Rules`), the cost table caption, and the 2026-06-13 source-verification
table (which cites `https://fal.ai/seedance-2.0`). **But every executable code example uses the
1.x model IDs**: `model_id="fal-ai/seedance-1-lite"  # or seedance-1-pro` and the endpoint string
`"fal-ai/seedance-1-lite/text-to-video"` (ai-asset-generation.md L120, L132, L145, L177).
An agent that copies the submit-then-poll snippet — the pack's flagship pattern — calls the
**older Seedance 1.x model** while believing (per all prose) it invoked 2.0. The pack contradicts
its own stated intent in its most-copied code. This is the clearest correctness refutation.

### F2 (MEDIUM) — Resolution: text-to-video capped at 720p, but Tiered workflow prescribes 1080p "final"
The Endpoint Specification Table (L94) lists **text-to-video resolution = `480p / 720p`** (1080p
appears ONLY for image-to-video and reference-to-video). The source re-verification row (L1081)
reinforces "Seedance 2.0 … 480p/720p". Yet the Cost Control "Tiered Generation Strategy" gives a
blanket rule — Final → **1080p / Standard** — and the code does
`final_params = {**params, "resolution": "1080p", ...}` (L573) with no carve-out for the
text-to-video path. An agent following the cost workflow on a text-only prompt submits `1080p`
to an endpoint the pack's own spec table says tops out at 720p → rejected request or silent
downscale. The "Final → 1080p" rule is unconditioned where it must be endpoint-conditioned.

### F3 (MEDIUM) — Fast/Standard modeled two incompatible ways (param vs endpoint variant)
The cited authoritative URL is `…/seedance-2.0/fast/image-to-video` — i.e. **Fast vs Standard is a
separate endpoint/model variant** (speed tier lives in the model path). But the Tiered Generation
code passes it as a request **parameter**: `{"resolution":"480p","quality":"Fast"}` /
`{"quality":"Standard"}` (L570, L573). The submit code (L120/L132) hardcodes
`fal-ai/seedance-1-lite/text-to-video` with no `/fast/` segment and no `quality` field in `params`.
So copying `draft_params` would NOT actually route to the Fast endpoint — the `quality` key is
invented and inconsistent with how the pack's own source says the API is structured. Either the
endpoint string must vary (`…/fast/…`) or the param contract must be documented; right now the two
representations disagree.

### F4 (LOW / labeling drift, NOT load-bearing) — "6 banned patterns" vs 7 script rules
SKILL says "the **6** banned timeline anti-patterns" and the Output Format checklist has 5 bullets
covering 6 names. The precheck script has **7** `RULE_LABEL` entries (it splits/labels
setInterval+setTimeout and treats each construct as a rule). The script is correct and is the source
of truth (verified: catches all on dirty input, exit 1; clean input exit 0). This is harmless prose
drift, listed only for completeness — does not affect actionability.

---

## Fact-checks performed (verifier-side, this lens)

- `specN` recomputed live with `LC_ALL=en_US.UTF-8` per QUALITY-BAR §2.3 → **113** (bucket 5). ✓
- Layer A grep checks all pass: frontmatter, aux≥1 (12), body 191≤550, Step routing (3),
  CONSUMES/PRODUCES (1), anti-skip (3), rule index (1), fixtures (2), `discriminative_pattern`
  in both fixtures, 2 executable scripts. ✓
- `failure-mode-precheck.sh` executed on a synthetic dirty .tsx (Date.now, repeat:-1,
  Math.random, async/await, visibility, inline opacity:0) → exit 1, all flagged; clean file → exit 0. ✓
- Discriminative gate: fixture-A markers vs `dogfood-output-A.md` → 4 (≥ min 4 = PASS);
  vs `dogfood-output-control.md` → 1 (< threshold = FAIL). Gate is discriminative. ✓
- Seedance model-id grep: prose "Seedance 2.0" ×8 vs code `seedance-1-lite`/`-pro` ×4 → **mismatch confirmed** (F1).
- Resolution grep: text-to-video row = `480p / 720p`; tiered code = `1080p` final → **conflict confirmed** (F2).
- Fast/Standard: cited URL has `/fast/` path segment; code uses `"quality":"Fast"` param → **representation conflict confirmed** (F3).
- TTS-synchronous vs Seedance-async split: internally consistent, explicitly anti-confused in anti-pattern table (L675). No defect.
- Negative-control evidence present: `.tad/evidence/pack-quality/negative-controls/{bad-structure-SKILL.md,shallow-depth.md}`. ✓

---

## Recommendation

Two-line fix clears the correctness lens (depth/structure already pass — do NOT re-touch those):
1. **F1**: replace `fal-ai/seedance-1-lite`/`seedance-1-pro` with the actual Seedance 2.0
   model IDs in all 4 code locations, OR (if 1-lite/pro IS the real 2.0 fal slug) add one
   sentence reconciling the slug naming so prose and code stop contradicting.
2. **F2**: condition the "Final → 1080p" tier rule on endpoint
   (text-to-video → 720p max; image/reference-to-video → 1080p), matching the spec table.
3. **F3**: make Fast/Standard one consistent mechanism — either vary the endpoint string
   (`…/fast/…`) or document the real param name; remove the invented `"quality"` key if it isn't real.

Until F1-F3 are reconciled, the pack does not clear the **correctness** bar on this lens,
even though it would comfortably pass structure-only and depth-only lenses.

---

## FIX applied (validated)

Date: 2026-06-13. Scope: edits confined to `.claude/skills/video-creation/`
(`references/ai-asset-generation.md` + `SKILL.md`). Structure (Layer A 191-line body,
2 scripts) and depth (Layer B specN) untouched — `failure-mode-precheck.sh` re-run = exit 0,
SKILL body still 191 lines.

Each finding validated before fixing: API/version claims checked against current primary docs
(fal.ai model pages, developers.openai.com/api/docs/deprecations, ElevenLabs v3 audio-tags help).

**F1 (HIGH / fact-api P0 — wrong model id) — FIXED.**
Validated against fal: the real Seedance 2.0 slug is `bytedance/seedance-2.0/text-to-video`
(no `fal-ai/` prefix, no `-lite`/`-pro` suffix; those are Seedance 1.x). Replaced all 4 code
locations (submit-then-poll submit + status, Webhook submit, plus the `params` model_id/route
keys) with an `ENDPOINT = "bytedance/seedance-2.0/text-to-video"` constant carrying an explicit
"NOT fal-ai/seedance-1-*" comment. Updated the request-hash to key off `endpoint` and rewrote
`compute_request_hash(model_id, route, …)` → `compute_request_hash(endpoint, …)` so prose and
the most-copied code now agree on 2.0.

**F2 (MEDIUM / fact-api P2 — resolution contradiction) — FIXED.**
Validated against fal model page: text-to-video `resolution` param = `"480p" | "720p"` (default
720p); 1080p does NOT exist on that route (image/reference-to-video do support 1080p). The
unconditioned `final_params = {…"resolution": "1080p"}` was a real defect. Replaced the Tiered
Generation table + steps + code with an **endpoint-conditioned** rule: text-to-video final caps
at 720p; image/reference-to-video final → 1080p. Code now computes
`final_res = "1080p" if "text-to-video" not in final_endpoint else "720p"`. The Endpoint Spec
Table (L94) was already correct and was left intact.

**F3 (MEDIUM / correctness — Fast/Standard mechanism) — FIXED.**
Validated against fal: Fast vs Standard is a **separate endpoint path** (`bytedance/seedance-2.0/fast/<route>`
vs the plain path), confirmed by both the model pages and the API docs; there is no `quality`
request field. Removed the invented `"quality": "Fast"`/`"quality": "Standard"` keys; draft now
uses the `/fast/` endpoint path, final uses the plain path. Tier table rewritten to show the path
as the selector. The anti-pattern row "Start with 1080p/Standard drafts" was rewritten to
"Draft on the Standard endpoint" with a correct ~25%/s cost rationale (Fast $0.2419 vs Std $0.3024).

**F4 (LOW — "6 vs 7" label drift) — SKIPPED (false positive, as the reviewer flagged).**
The reviewer itself classified this NOT load-bearing: the precheck script (7 RULE_LABEL entries)
is the verified source of truth and exits correctly; "6 banned patterns" is harmless prose. No
behavioral impact on actionability, so per the lens (internal consistency + actionability of
copy-paste guidance) it does not warrant a body edit. Left as-is.

**Anti-slop F2 (P1 — wrong gpt-image-1 deprecation date) — FIXED.**
Validated against OpenAI: the "2026-10-23" hard date is unsupported (it came from a third-party
aggregator, evolink.ai). Real schedule: `gpt-image-1-mini`, `gpt-image-1.5`, and
`chatgpt-image-latest` shut down **2026-12-01** (→ gpt-image-2); DALL·E 2/3 shut down 2026-05-12.
Corrected the Model Lineup table dates, the hard-date warning prose, the SKILL Quick-Rule-Index
"gpt-image Model Guard" line, and re-sourced the §Source Re-Verification row from evolink.ai →
`https://developers.openai.com/api/docs/deprecations` with an explicit "prior date was wrong"
note (fixing exactly the version-sensitive failure QUALITY-BAR §6 warns about).

**Anti-slop F3 (P1 — lineup recommends deprecated SKUs) — FIXED (same edits as above).**
The escape hatch "or gpt-image-1-mini for cheap drafts" steered toward a Dec-1-2026-deprecated
SKU. Removed it from both the §Model Lineup prose and the SKILL Model-Guard line; cheap drafts now
route to `gpt-image-2` with `quality="low"` instead. gpt-image-1.5 retagged from "Previous
generation / existing pipelines only" to "SHUTS DOWN 2026-12-01 — do NOT start new work"
(addresses fact-api P3 model-label drift too).

**fact-api P3 (ElevenLabs emotion mechanism imprecise) — FIXED.**
Validated against ElevenLabs v3 audio-tags help: the mechanism is **bracketed audio tags**
(`[excited]`/`[whispers]`/`[sighs]`, layerable), NOT "natural language cues in text". Updated both
the TTS Tool-Comparison table row and the Emotion-Control table row with concrete tag syntax and a
layered example, matching the concreteness the pack already gives Fish Audio's `(happy)` syntax.

**Anti-slop F1 / F4-F7 and the fact-api Positive — no action (confirmed accurate / out of scope).**
Seedance/Kling/Atlas pricing, ms-unit FFmpeg gotcha, async-vs-sync TTS split, path-split contract,
and presigned-URL hash rule were all verified correct by the reviewers and left untouched. F4
(launch-date precision) is cosmetic and not a bar-sink.

**Net:** F1, F2, F3 (correctness lens) + anti-slop F2/F3 + the two fact-api P3 imprecisions are
reconciled. The pack's most-copied reference no longer contradicts its own prose or the current
vendor APIs. Structure and depth lenses unaffected.
