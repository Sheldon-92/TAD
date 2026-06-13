# Phase 5 Adversarial Review — video-creation (fact-api lens)

- **lens**: fact-api (wrong class names, deprecated/renamed APIs, wrong model ids, wrong metric types, wrong constants/versions). Every version-sensitive claim WebSearched against current primary docs.
- **meets_bar**: false
- **Reviewed**: SKILL.md + references/ai-asset-generation.md (the version-dense file) + QUALITY-BAR.md, on 2026-06-13.

## Verdict rationale

The pack's *narrative* facts verify remarkably well (most checks PASS — see fact_checks).
But the **canonical Async API code example** — the one an agent will copy verbatim to
call the model the whole pack is built around — teaches the **wrong model id**: it uses
Seedance **1.0** identifiers (`fal-ai/seedance-1-lite`, `seedance-1-pro`,
`fal-ai/seedance-1-lite/text-to-video`) while every prose claim, the decision tree, the
cost table, and the re-verification table describe Seedance **2.0**
(`bytedance/seedance-2.0/...`). This is a load-bearing API-correctness defect (the exact
failure class this lens exists to catch), so the pack does NOT clear the fact-api bar
until the code ids are corrected.

## Findings

1. **[P0 — wrong API model id / renamed endpoint]** `references/ai-asset-generation.md`
   Async API Pattern (lines ~120-156), Webhook Alternative (~178), Rate Limiting example
   (~247) all use `model_id="fal-ai/seedance-1-lite"` (comment `# or seedance-1-pro`) and
   the endpoint string `"fal-ai/seedance-1-lite/text-to-video"`. Those are **Seedance 1.0**
   ids (Seedance 1 lives at `fal-ai/bytedance/seedance/v1/...`). The pack teaches Seedance
   **2.0**, whose real fal endpoints are `bytedance/seedance-2.0/text-to-video`,
   `.../image-to-video`, `.../reference-to-video` (+ `/fast/` variants), with NO `fal-ai/`
   prefix and NO `-lite`/`-pro` suffix. An agent copying the canonical snippet would invoke
   the wrong (older, different-priced, different-capability) model. Fix: replace all three
   occurrences with the `bytedance/seedance-2.0/...` slug.

2. **[P2 — internal contradiction, resolution]** Endpoint Spec Table (lines 94-99) claims
   image-to-video & reference-to-video support **1080p (Standard)** while text-to-video is
   480p/720p only. The detailed fal model pages corroborate 1080p on the standard
   image/reference tiers, BUT the `fal.ai/seedance-2.0` landing page states only "480p and
   720p" with "no mention of 1080p." Sources conflict; the per-endpoint 1080p claim is
   plausible but should be re-confirmed against each model page's resolution dropdown and a
   source citation added, since a wrong max-resolution constant would mis-cost and mis-spec
   every final render.

3. **[P3 — minor model-label drift]** Model Lineup table (line 342) labels `gpt-image-1.5`
   "Previous generation / Existing pipelines only." Per OpenAI's deprecations page,
   `gpt-image-1.5` is itself a deprecated model (recommended replacement: gpt-image-2), not
   merely "previous generation." Recommend tagging it as deprecated alongside gpt-image-1
   so an agent doesn't start new work on it.

4. **[P3 — minor mechanism wording]** TTS Emotion Control table (line 739) describes
   ElevenLabs emotion as "natural language cues embedded in text." Eleven v3's actual
   mechanism is bracketed **audio tags** (`[excited]`, `[whispers]`, `[sighs]`). Not wrong
   enough to misfire, but the concrete tag syntax should be shown (the pack shows Fish
   Audio's `(happy)` syntax but leaves ElevenLabs vague).

5. **[note — NOT a defect]** Seedance launch date `2026-04-09`, Kling 3.0 launch
   `2026-02-04` (sources say Feb 5; ~1 day), Fish Audio S2 "5B param / 80+ languages",
   ElevenLabs `eleven_v3` / `eleven_text_to_sound_v2` loop-exclusivity, gpt-image-1
   deprecation `2026-10-23`, and the fal per-second rates all VERIFIED CURRENT. The pack's
   §Source Re-Verification 2026-06-13 table is largely trustworthy — the defect is confined
   to the code-snippet model id, which the re-verification table did not cover.

## fact_checks

- Seedance 2.0 fal endpoint slug — CLAIM `fal-ai/seedance-1-lite/text-to-video` (code) — VERDICT **WRONG**; current is `bytedance/seedance-2.0/text-to-video` (no `fal-ai/` prefix, model is `seedance-2.0`). Source: https://fal.ai/models/bytedance/seedance-2.0/fast/text-to-video + https://fal.ai/seedance-2.0 (retrieved 2026-06-13).
- Seedance 2.0 fal pricing Fast $0.2419/s, Std $0.3024/s — VERDICT **CORRECT**. Source: https://fal.ai/models/bytedance/seedance-2.0/fast/text-to-video (retrieved 2026-06-13).
- Seedance 2.0 launch date 2026-04-09 — VERDICT **CORRECT** (fal page states "April 9, 2026"). Source: https://fal.ai/seedance-2.0 (retrieved 2026-06-13).
- Seedance 2.0 reference-to-video accepts ≤9 img + ≤3 vid + ≤3 aud (≤12 total) — VERDICT **CORRECT**. Source: https://fal.ai/models/bytedance/seedance-2.0/reference-to-video (retrieved 2026-06-13).
- Seedance image/reference-to-video supports 1080p Standard — VERDICT **AMBIGUOUS** (detailed model page says 480p/720p/1080p standard; landing page says 480p/720p only). Needs per-endpoint re-confirm + citation. Source: https://fal.ai/models/bytedance/seedance-2.0/reference-to-video vs https://fal.ai/seedance-2.0 (retrieved 2026-06-13).
- Video-input discount 0.6x → ~$0.18/s — VERDICT **CORRECT** (fal lists $0.1814/s std-with-video; pack's $0.18 is the rounded form). Source: https://fal.ai/models/bytedance/seedance-2.0/reference-to-video (retrieved 2026-06-13).
- gpt-image-2 is current flagship / recommended image model — VERDICT **CORRECT**. Source: https://developers.openai.com/api/docs/models/gpt-image-2 + https://developers.openai.com/api/docs/deprecations (retrieved 2026-06-13).
- gpt-image-1 deprecates 2026-10-23 — VERDICT **CORRECT** (deprecations page entry "2026-10-23 | gpt-image-1 | gpt-image-2"). Source: https://developers.openai.com/api/docs/deprecations (retrieved 2026-06-13).
- gpt-image-1.5 status "previous generation, existing pipelines only" — VERDICT **PARTIALLY WRONG**; OpenAI lists gpt-image-1.5 as a deprecated model (replacement gpt-image-2), not just previous-gen. Source: https://developers.openai.com/api/docs/deprecations (retrieved 2026-06-13).
- Kling 3.0 native 4K @60fps, 15s max, AI-Director ≤6 shots/15s — VERDICT **CORRECT** (launch Feb 5 2026 vs pack's Feb 4 — 1-day drift, immaterial). Source: https://www.cined.com/kling-3-0-ai-video-model-introduced-native-4k-enhanced-photorealism-multi-shot-sequencing-and-integrated-audio/ (retrieved 2026-06-13).
- ElevenLabs `eleven_v3` model id + 70+ languages — VERDICT **CORRECT** (note: v3 is alpha/research-preview; pack's "70+" matches). Source: https://elevenlabs.io/docs/overview/models + https://elevenlabs.io/blog/eleven-v3 (retrieved 2026-06-13).
- ElevenLabs SFX `eleven_text_to_sound_v2`, `loop` exclusive to that model, max 30s, POST /v1/sound-generation — VERDICT **CORRECT**. Source: https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert + https://elevenlabs.io/docs/overview/capabilities/sound-effects (retrieved 2026-06-13).
- ElevenLabs emotion mechanism = "natural language cues" — VERDICT **IMPRECISE**; actual mechanism is bracketed audio tags ([excited]/[whispers]/[sighs]). Source: https://elevenlabs.io/blog/eleven-v3 (retrieved 2026-06-13).
- OpenAI tts-1 $15/1M chars, tts-1-hd $30/1M chars, gpt-4o-mini-tts newest — VERDICT **CORRECT**. Source: https://platform.openai.com/docs/pricing/ + community pricing threads (retrieved 2026-06-13).
- Fish Audio S2 Pro flagship 5B param, 80+ languages, 10-15s clone — VERDICT **CORRECT** (5B = 4B Slow-AR + 400M Fast-AR; one source says ~50 langs, another 80+; "80+" defensible). Source: https://fish.audio/s2/ + https://www.marktechpost.com/2026/03/10/fish-audio-releases-fish-audio-s2-... (retrieved 2026-06-13).
- `fal_client.subscribe()` blocks / submit-then-poll is the right async pattern — VERDICT **CORRECT** (fal docs show submit/status/result polling flow). Source: https://github.com/fal-ai/seedance-2.0-api + https://docs.fal.ai/api-reference/client-libraries (retrieved 2026-06-13).
