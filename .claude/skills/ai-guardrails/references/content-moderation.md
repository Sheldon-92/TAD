# Content Moderation Rules
<!-- capability: content_moderation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CM1 | Moderate BOTH input and output — use current Llama Guard 4 12B benchmark (Eng recall 69%/FPR 11%) | deterministic |
| CM2 | Tool selection: OpenAI Moderation (closed, ~13 categories) vs Llama Guard 4 12B (14 categories: S1–S13 + S14) | deterministic |
| CM3 | Measure FPR before trusting a single classifier — closed APIs struggle with context-dependent toxicity | semi-deterministic |
| CM4 | Multimodal inputs need a vision safety classifier — text filters miss image-embedded instructions | deterministic |
| CM5 | Llama Guard taxonomy is customizable via zero/few-shot prompting — no retraining | deterministic |

---

## Rules

### CM1: Moderate Both Input and Output — Use the Current Llama Guard 4 Benchmark

Content moderation scans both user inputs and generated responses against a safety taxonomy. Moderating only the input is incomplete: because the classifier checks the *generated* text in context, response/output-stage classification can ignore direct image-based prompt injections and block violations at output.

**Current model — Llama Guard 4 12B** (released 2025; a dense model pruned from Llama 4 Scout, early-fusion multimodal — it replaces **both** Llama Guard 3-8B and 3-11B-vision in one classifier). Published **output-filtering** benchmark (Meta in-house test set):

| Llama Guard 4 12B (output filtering) | Recall | FPR | F1 |
|--------------------------------------|:---:|:---:|:---:|
| English | **69%** | **11%** | **61%** |
| Multilingual | **43%** | **3%** | — |

These are *vendor internal* numbers, **not** head-to-head. **69% English recall means ~31% of unsafe content still passes** — directly reinforcing PII4's recall-first F2 framing: measure recall on YOUR own data.

> Old patterns (superseded — kept for historical comparison only; do NOT cite as current): Llama Guard 3 Vision internal benchmark reported response-classification FPR 0.016 / recall 0.916. Llama Guard 4 supersedes Llama Guard 3 (both 8B and 11B-vision); use the Llama Guard 4 numbers above.

**Rule**: Moderate both input and output. Quote the **Llama Guard 4 12B** benchmark (English recall 69% / FPR 11% / F1 61%; multilingual recall 43% / FPR 3%) as vendor-internal, and treat the ~31% English miss-rate as the residual risk you must measure on your own content.

> Source: Meta Llama Guard 4 12B MODEL_CARD, https://github.com/meta-llama/PurpleLlama/blob/main/Llama-Guard4/12B/MODEL_CARD.md (retrieved 2026-06-13); https://huggingface.co/meta-llama/Llama-Guard-4-12B

**determinismLevel**: deterministic — the placement decision is architectural.

### CM2: OpenAI Moderation vs Meta Llama Guard

| Dimension | OpenAI Moderation API | Meta Llama Guard |
|-----------|----------------------|------------------|
| Type | Hosted closed classifier | Open-weight, **Llama Guard 4 12B** (dense, pruned from Llama 4 Scout, early-fusion multimodal; replaces Llama Guard 3-8B + 3-11B-vision) |
| Taxonomy | **Closed, provider-defined taxonomy** — `omni-moderation-latest` currently exposes ~13 categories (sexual, sexual/minors, harassment, harassment/threatening, hate, hate/threatening, illicit, illicit/violent, self-harm, self-harm/intent, self-harm/instructions, violence, violence/graphic) with partial image-input support. Verify the current list against OpenAI docs — it has grown over time and is not user-extensible. | **14 categories** = 13 MLCommons hazards (S1 Violent Crimes … S13) + **S14 Code Interpreter Abuse** for text-only tool-call use |
| Customization | Closed — limited | Adaptable via zero/few-shot prompting, no retraining |
| Best for | Simple out-of-the-box chat pipelines | Granular enterprise rules, customizable taxonomy, multimodal |

**Rule**: Choose OpenAI Moderation for fast, standard chat moderation. Choose Llama Guard when you need a custom taxonomy (e.g. code-interpreter abuse, IP theft), multimodal coverage, or self-hosting. Do NOT default to OpenAI Moderation for security-sensitive agents — its closed taxonomy can't be extended to your threat model.

> Source: findings.md "Taxonomic Alignment and Capabilities"; Llama Guard 4 12B MODEL_CARD (14 categories = S1–S13 MLCommons + S14 Code Interpreter Abuse), https://github.com/meta-llama/PurpleLlama/blob/main/Llama-Guard4/12B/MODEL_CARD.md (retrieved 2026-06-13)

**determinismLevel**: deterministic.

### CM3: Measure False-Positive Rate Before Trusting One Classifier

OpenAI Moderation's closed nature limits customization and it "can struggle with subtle, context-dependent toxic content or indirect prompt injections." Generic baselines (GPT-4o, GPT-4o mini) show very high FPRs at prompt classification (0.485, 0.681).

**Rule**: Never deploy a single moderation classifier without measuring its recall AND FPR on your own content. Even the current open SOTA leaves a large residual gap — **Llama Guard 4 12B's English output-filtering recall is only 69% (FPR 11%)**, i.e. ~31% of unsafe English content passes; multilingual recall is 43% (FPR 3%). Vendor benchmarks are a starting point, not a guarantee — measure on your distribution.

> Source: findings.md OpenAI limitations; Llama Guard 4 12B MODEL_CARD output-filtering recall/FPR (Eng 69%/11%, multilingual 43%/3%), https://github.com/meta-llama/PurpleLlama/blob/main/Llama-Guard4/12B/MODEL_CARD.md (retrieved 2026-06-13)

**determinismLevel**: semi-deterministic — FPR depends on your content distribution.

### CM4: Multimodal Inputs Require a Vision Safety Classifier

Attackers embed instructions inside images — invisible text overlays or adversarial pixel data — to bypass text-only filters.

**Rule**: If the pipeline accepts images, a text-only moderation filter is insufficient. Use a multimodal classifier — **Llama Guard 4 12B** (early-fusion multimodal, the single model that replaced Llama Guard 3-11B-vision) processes image and text together.

> Source: findings.md "Multimodal Moderation Capabilities" [8, 19, 22, 38]

**determinismLevel**: deterministic.

### CM5: Customize the Llama Guard Taxonomy Without Retraining

Because Llama Guard is instruction-tuned, developers adapt its taxonomy for enterprise rules using zero-shot or few-shot prompting — no retraining of core weights. Categories S6–S13 are explicitly customizable.

**Rule**: When the user's policy needs categories outside OpenAI Moderation's closed, provider-defined taxonomy (e.g. competitor mentions, domain-specific harms, code-interpreter abuse S14), extend Llama Guard's taxonomy via prompting rather than building a bespoke classifier.

> Source: findings.md Llama Guard instruction-tuned customization [34, 36, 37]; category taxonomy S1–S14

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Input-only moderation**: output-stage classification catches image-injection and in-context violations at the response; moderate both.
- **Citing stale Llama Guard 3 numbers**: Llama Guard 4 12B supersedes both 3-8B and 3-11B-vision — use Eng recall 69%/FPR 11%, not the old 0.916/0.016 figures.
- **Single unmeasured classifier**: deploying a moderation API without measuring recall + FPR on your own content distribution (vendor 69% recall ≠ your recall).
- **Text-only filter on a multimodal pipeline**: image-embedded instructions bypass it.
- **Defaulting to a closed-taxonomy API for a custom threat model**: you cannot extend OpenAI Moderation's provider-defined categories.
