# Synthetic Generation Rules
<!-- capability: synthetic_generation -->

## Quick Rule Index

| # | Rule | stage |
|---|------|-------|
| GEN1 | Self-Instruct: ROUGE-L > 0.7 rejection + blacklist + character checks | post-training |
| GEN2 | Self-Instruct sampling mix: 6 human + 2 machine tasks per few-shot prompt | post-training |
| GEN3 | Classification tasks: use Output-First prompting to prevent label bias | post-training |
| GEN4 | Evol-Instruct: In-Depth (5 mutations) + In-Breadth + Elimination Evolving | post-training |
| GEN5 | distilabel DAG: load → expand → generate → combine → ultrafeedback → to_argilla | post-training |
| GEN6 | Bonito for zero-shot task adaptation on private data without external APIs | post-training |
| GEN7 | Magpie: pre-query-template self-synthesis + ArmoRM reward filter (no seed, no prompt eng) | post-training |
| GEN8 | Persona-driven synthesis: condition on PersonaHub / Census-grounded Nemotron-Personas, don't raise temperature | post-training |

---

## Rules

### GEN1: Self-Instruct Post-Processing — ROUGE-L > 0.7 Rejection

In Self-Instruct's Step 4 (Post-Processing and Deduplication), apply strict heuristic filters to every newly generated task. **Reject a task if**:

- its **ROUGE-L overlap with any existing pool instruction exceeds 0.7** (prevents semantic redundancy), OR
- it contains blacklisted keywords (e.g. *image*, *graph*, *file* — things the model cannot actually do), OR
- it starts with punctuation or non-English characters.

**Rule**: A Self-Instruct loop with no ROUGE-L > 0.7 filter collapses into near-duplicate instructions. This filter is mandatory, not optional.

> Source: findings.md "Self-Instruct Framework — Step 4 Post-Processing" [16,21] — ROUGE-L > 0.7 rejection, blacklist (image/graph/file), punctuation/non-English start checks.

**stage**: post-training.

### GEN2: Self-Instruct Sampling Mix — 6 Human + 2 Machine

Self-Instruct is seeded with **175 human-written tasks** (a balanced **25 classification + 150 non-classification**), each an (Instruction, Input, Output) tuple with a classification flag. For instruction generation it samples **8 instructions per few-shot prompt: 6 human-written + 2 previously machine-generated** — the 2 machine tasks promote diversity while the 6 human tasks anchor quality.

**Rule**: Do not seed few-shot prompts from machine generations alone (diversity drift) or human-only (no novelty). The 6:2 human:machine ratio is the documented mix.

> Source: findings.md "Self-Instruct — Task Seeding + Instruction Generation" [16,21] — 175 seed tasks (25 cls / 150 non-cls), sample 8 = 6 human + 2 machine.

**stage**: post-training.

### GEN3: Classification Tasks Use Output-First Prompting

Models have severe label bias on classification tasks. Self-Instruct first identifies task type via a few-shot classifier prompt (**12 classification + 19 non-classification exemplars**), then branches:

- **Input-First (non-classification)**: generate the input context first, then the output.
- **Output-First (classification)**: generate the target **label first**, then an input conditioned on that label — this prevents the model from skewing toward majority labels.

**Rule**: For any classification-style synthetic data, generate the label before the input. Input-first prompting on classification tasks bakes in label bias.

> Source: findings.md "Classification Task Identification + Instance Generation" [16,21] — 12 cls / 19 non-cls classifier exemplars; Output-First for classification, Input-First otherwise.

**stage**: post-training.

### GEN4: Evol-Instruct — In-Depth + In-Breadth + Elimination

Flat Self-Instruct produces simple instructions. Evol-Instruct (WizardLM) evolves seeds via an LLM:

- **In-Depth Evolution** — five mutations that raise difficulty: adding constraints, deepening, concretizing, complicating input, augmenting logical steps.
- **In-Breadth Evolution** — generate a completely new, diverse instruction to expand topical coverage.
- **Elimination Evolving** — a dedicated eliminator model filters out corrupted/unsolvable evolutions (LLM-driven evolution sometimes yields broken tasks).

Applying this to Alpaca seed data produced the **250k-sample WizardLM dataset**, which significantly outperforms models fine-tuned on standard Self-Instruct data.

**Rule**: If you only run Self-Instruct, you are leaving measured performance on the table. Add Evol-Instruct evolution AND the Elimination step — evolution without elimination ships broken tasks.

> Source: findings.md "Evol-Instruct and WizardLM" [15,17,22] — 5 In-Depth mutations, In-Breadth, Elimination Evolving, 250k WizardLM dataset.

**stage**: post-training.

### GEN5: distilabel DAG Step Order

In production, manage programmatic generation as a Directed Acyclic Graph. The standard distilabel retrieval-pipeline sequence:

1. `load_dataset` — load raw blocks, rename source columns (e.g. `page_content` → `anchor`).
2. `self_instruct_open_mistral` — generate raw queries (e.g. via `open-mistral-7b`).
3. `expand_columns` — unroll instruction lists into distinct rows.
4. Parallel generation (`generate_open-mistral-7b` & `generate_open-mixtral-8x7b`) — dispatch to multiple endpoints, capturing diverse candidates.
5. `combine_generations` — merge parallel candidates into one evaluation format.
6. `ultrafeedback_mistral-large-latest` — a strong judge model rates candidates with justifications.
7. `to_argilla` — push to an Argilla workspace for human inspection.

distilabel's caching pairs with ZenML step caching to cut API costs when iterating.

**Rule**: Generation needs an `ultrafeedback` judge step before human review — raw parallel candidates without a rating step give annotators no signal to triage.

> Source: findings.md "ZenML and Distilabel Pipeline Execution" [13,24] — 7-step DAG: load → self_instruct → expand → parallel generate → combine → ultrafeedback → to_argilla.

**stage**: post-training.

### GEN6: Bonito for Zero-Shot Task Adaptation on Private Data

When you cannot send private/domain data to external commercial APIs, use **Bonito** — an open-source model fine-tuned on a **1.65M-example meta-template corpus** that converts raw unannotated text + a target task attribute into an (instruction, response) pair. This enables zero-shot task adaptation directly on private databases.

**Rule**: For domain-specific synthetic data under data-residency constraints, prefer Bonito over prompting a general-purpose commercial engine — it keeps raw text in-house.

> Source: findings.md "Conditional Task Generation with Bonito" [25] — 1.65M meta-template corpus, raw text + task attribute → instruction/response, no external APIs.

**stage**: post-training.

### GEN7: Magpie — Pre-Query-Template Self-Synthesis + ArmoRM Reward Filter

To extract instruction data directly from an aligned model **without any seed task and without prompt engineering**, use the Magpie trick: prompt the model with **ONLY the pre-query chat template** — the left-side template up to the user-message slot (e.g. everything up to and including `<|start_header_id|>user<|end_header_id|>` with nothing after it). The autoregressive model, conditioned on that prefix alone, **emits a user instruction**; you then feed that instruction back to generate the response. This harvests the instruction distribution baked into the alignment, no human seed pool required.

- Magpie extracted **4M instructions from Llama-3-Instruct**, distilled to a **300K high-quality SFT subset** (Magpie-Pro / Magpie-Air).
- SFT on Magpie alone can **match Llama-3-8B-Instruct** that was trained on ~10M proprietary supervised + preference points.
- **Filter** the raw 4M with: a reward score from **`RLHFlow/ArmoRM-Llama3-8B-v0.1`**, an **instruction-quality** label (very poor → excellent), a **difficulty** label (very easy → very hard), plus **FAISS min-neighbor-distance** near-dup removal (drop instructions whose nearest-neighbor embedding distance is below a threshold).

**Rule**: When you have an aligned model but no seed pool, do not hand-write seeds — prefill the pre-query template and let the model self-synthesize, then filter with the `ArmoRM-Llama3-8B-v0.1` reward score + quality/difficulty labels + FAISS min-neighbor-distance dedup. Naming a generic "reward model" instead of the exact `ArmoRM-Llama3-8B-v0.1` id loses the reproducibility this rule exists to give.

> Source: Magpie (arxiv.org/html/2406.08464v2, retrieved 2026-06-13) — pre-query-template self-synthesis, 4M→300K, match Llama-3-8B-Instruct on ~10M points, ArmoRM-Llama3-8B-v0.1 + quality/difficulty + FAISS min-neighbor-distance filters; magpie-align/magpie repo (filtering signals: quality/difficulty/task-category/safety/reward/language).

**stage**: post-training.

### GEN8: Persona-Driven Synthesis — Condition on a Persona Set, Don't Raise Temperature

When a flat Self-Instruct / Evol loop **collapses topical coverage** (generations cluster on a few topics), the wrong fix is raising temperature (it adds noise, not coverage). The right fix is to **embed a persona into the generation prompt** so each persona acts as a distributed carrier of world knowledge, forcing perspective/topic diversity:

- **PersonaHub** — **~1B personas** curated from web data (estimated to cover ~13% of the world's population), usable for math / logic / instruction / knowledge-text / NPC / tool synthesis. Use it for **web-scale breadth**.
- **NVIDIA Nemotron-Personas** — **100K personas** instead grounded in **real U.S. Census demographic / geographic / personality statistics**. Use it when you need **distribution alignment** to a real population, not just raw breadth.

**Rule**: When topical coverage collapses, condition generation on a persona set (PersonaHub for breadth, Census-grounded Nemotron-Personas for distribution alignment) — do NOT just raise temperature. Choosing between the two is a real decision: breadth (web-scale, uncontrolled distribution) vs distribution-fidelity (Census-grounded, 100K).

> Source: Scaling Synthetic Data Creation with 1,000,000,000 Personas / PersonaHub (arxiv.org/abs/2406.20094, retrieved 2026-06-13) — 1B personas, ~13% world pop; NVIDIA Nemotron-Personas (huggingface.co/blog/nvidia/nemotron-personas, retrieved 2026-06-13) — 100K Census-grounded personas, distribution alignment.

**stage**: post-training.

---

## Anti-Patterns

- **No ROUGE-L filter**: Self-Instruct loop degenerates into near-duplicate instructions (GEN1).
- **Machine-only or human-only few-shot seeds**: breaks the 6:2 diversity/quality balance (GEN2).
- **Input-first on classification tasks**: bakes in label bias — use Output-First (GEN3).
- **Evolution without Elimination**: ships corrupted/unsolvable evolved tasks (GEN4).
- **No judge step before human review**: annotators triage blind without ultrafeedback ratings (GEN5).
- **Sending private data to commercial APIs**: avoidable with Bonito's in-house generation (GEN6).
- **Hand-writing seed tasks when an aligned model is available**: prefill the pre-query template instead (Magpie self-synthesis), then ArmoRM-filter (GEN7).
- **Raising temperature to fix collapsed topical coverage**: adds noise, not coverage — condition on a persona set instead (GEN8).
