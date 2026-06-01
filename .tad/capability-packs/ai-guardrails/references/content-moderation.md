# Content Moderation Rules
<!-- capability: content_moderation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CM1 | Moderate BOTH input and output — response classification is more robust than prompt classification | deterministic |
| CM2 | Tool selection: OpenAI Moderation (closed provider-defined taxonomy, ~13 categories) vs Llama Guard (13+ customizable) | deterministic |
| CM3 | Measure FPR before trusting a single classifier — closed APIs struggle with context-dependent toxicity | semi-deterministic |
| CM4 | Multimodal inputs need a vision safety classifier — text filters miss image-embedded instructions | deterministic |
| CM5 | Llama Guard taxonomy is customizable via zero/few-shot prompting — no retraining | deterministic |

---

## Rules

### CM1: Moderate Both Input and Output — Prefer Response Classification

Content moderation scans both user inputs and generated responses against a safety taxonomy. Benchmarks show **response classification is substantially more robust than prompt classification**.

Llama Guard 3 Vision vs baselines (internal safety benchmark):

| Model | Task | Precision | Recall | F1 | FPR |
|-------|------|:---:|:---:|:---:|:---:|
| Llama Guard 3 Vision | Prompt Classification | 0.891 | 0.623 | 0.733 | 0.052 |
| GPT-4o | Prompt Classification | 0.544 | 0.843 | 0.661 | 0.485 |
| GPT-4o mini | Prompt Classification | 0.488 | 0.943 | 0.643 | 0.681 |
| Llama Guard 3 Vision | Response Classification | 0.961 | 0.916 | 0.938 | **0.016** |
| GPT-4o | Response Classification | 0.579 | 0.788 | 0.667 | 0.243 |
| GPT-4o mini | Response Classification | 0.526 | 0.820 | 0.641 | 0.313 |

**Rule**: Moderating only the input is incomplete. Because the classifier checks the generated text in context, response-stage classification can ignore direct image-based prompt injections and block violations at output. Llama Guard 3 Vision's response-classification FPR (0.016) is ~15x lower than GPT-4o's (0.243).

> Source: findings.md "Multimodal Moderation Capabilities" + performance table [19, 22]

**determinismLevel**: deterministic — the placement decision is architectural.

### CM2: OpenAI Moderation vs Meta Llama Guard

| Dimension | OpenAI Moderation API | Meta Llama Guard |
|-----------|----------------------|------------------|
| Type | Hosted closed classifier | Open-weight instruction-tuned (Llama 3 8B / 3.1 11B-12B) |
| Taxonomy | **Closed, provider-defined taxonomy** — `omni-moderation-latest` currently exposes ~13 categories (sexual, sexual/minors, harassment, harassment/threatening, hate, hate/threatening, illicit, illicit/violent, self-harm, self-harm/intent, self-harm/instructions, violence, violence/graphic) with partial image-input support. Verify the current list against OpenAI docs — it has grown over time and is not user-extensible. | **13+ customizable categories** (S1 Violent Crimes … S14 Code Interpreter Abuse) |
| Customization | Closed — limited | Adaptable via zero/few-shot prompting, no retraining |
| Best for | Simple out-of-the-box chat pipelines | Granular enterprise rules, customizable taxonomy, multimodal |

**Rule**: Choose OpenAI Moderation for fast, standard chat moderation. Choose Llama Guard when you need a custom taxonomy (e.g. code-interpreter abuse, IP theft), multimodal coverage, or self-hosting. Do NOT default to OpenAI Moderation for security-sensitive agents — its closed taxonomy can't be extended to your threat model.

> Source: findings.md "Taxonomic Alignment and Capabilities" [17, 19, 34, 35, 36, 37]; taxonomy diagram

**determinismLevel**: deterministic.

### CM3: Measure False-Positive Rate Before Trusting One Classifier

OpenAI Moderation's closed nature limits customization and it "can struggle with subtle, context-dependent toxic content or indirect prompt injections." Generic baselines (GPT-4o, GPT-4o mini) show very high FPRs at prompt classification (0.485, 0.681).

**Rule**: Never deploy a single moderation classifier without measuring its FPR on your own content. A high-recall/high-FPR classifier blocks legitimate traffic; for safety you want high recall AND controlled FPR (Llama Guard 3 Vision: recall 0.916, FPR 0.016 at response stage).

> Source: findings.md OpenAI limitations [17]; performance table FPR column [19, 22]

**determinismLevel**: semi-deterministic — FPR depends on your content distribution.

### CM4: Multimodal Inputs Require a Vision Safety Classifier

Attackers embed instructions inside images — invisible text overlays or adversarial pixel data — to bypass text-only filters.

**Rule**: If the pipeline accepts images, a text-only moderation filter is insufficient. Use a multimodal classifier (Llama Guard 3 Vision / Llama Guard 4) that processes image and text together.

> Source: findings.md "Multimodal Moderation Capabilities" [8, 19, 22, 38]

**determinismLevel**: deterministic.

### CM5: Customize the Llama Guard Taxonomy Without Retraining

Because Llama Guard is instruction-tuned, developers adapt its taxonomy for enterprise rules using zero-shot or few-shot prompting — no retraining of core weights. Categories S6–S13 are explicitly customizable.

**Rule**: When the user's policy needs categories outside OpenAI Moderation's closed, provider-defined taxonomy (e.g. competitor mentions, domain-specific harms, code-interpreter abuse S14), extend Llama Guard's taxonomy via prompting rather than building a bespoke classifier.

> Source: findings.md Llama Guard instruction-tuned customization [34, 36, 37]; category taxonomy S1–S14

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Input-only moderation**: response classification is more robust (FPR 0.016 vs 0.052 for Llama Guard 3 Vision) and catches image-injection at output.
- **Single unmeasured classifier**: deploying a moderation API without measuring FPR on your own content distribution.
- **Text-only filter on a multimodal pipeline**: image-embedded instructions bypass it.
- **Defaulting to a closed-taxonomy API for a custom threat model**: you cannot extend OpenAI Moderation's provider-defined categories.
