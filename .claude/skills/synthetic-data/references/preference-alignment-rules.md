# Preference Alignment & Chat-Template Rules
<!-- capability: preference_alignment -->

## Quick Rule Index

| # | Rule | stage |
|---|------|-------|
| PA1 | DPO is structurally pairwise — use RRHF for >2 candidates, GRPO for verifiable tasks | post-training |
| PA2 | RRHF: length-normalized log-prob + ranking loss with margin | post-training |
| PA3 | Pick the dataset format by turn count: Alpaca (single-turn) vs ShareGPT (multi-turn) | post-training |
| PA4 | Map the exact Jinja2 chat template — wrong control tokens cause role confusion | post-training |
| PA5 | Axolotl: roles_to_train=["assistant"], train_on_eos=last, eot_tokens for Tekken | post-training |
| PA6 | Reward-model training: diverse preference sets, avoid single-source feedback loops | post-training |

---

## Rules

### PA1: DPO Is Pairwise — Match the Method to the Candidate Count

Direct Preference Optimization reparameterizes the reward to optimize the policy directly, eliminating a separate reward model and improving training stability. Its loss compares preferred `y_w` vs rejected `y_l`:

`L_DPO = -E[(x,y_w,y_l)] log σ( β log(π_θ(y_w|x)/π_ref(y_w|x)) − β log(π_θ(y_l|x)/π_ref(y_l|x)) )`

But DPO is **structurally limited to pairwise comparisons and lacks exploration**. Choose by structure:

| Situation | Method |
|-----------|--------|
| Two responses per prompt | DPO |
| `k > 2` diverse candidates from mixed sources | RRHF (ranking loss) |
| Verifiable math/logic answers | GRPO (compares candidate groups directly, lower on-policy RL overhead) |

**Rule**: Defaulting to DPO for a >2-candidate or verifiable-answer setup leaves capability unused. Note `β`-scaling sensitivity for PPO-style updates.

> Source: findings.md "Direct Preference Optimization (DPO) and Alternatives" [26,27,30,31] — DPO loss, pairwise limitation; RRHF for multi-candidate; GRPO for verifiable tasks.

**stage**: post-training.

### PA2: RRHF Ranking Loss

RRHF (Rank Responses to align Human Feedback) handles `k` candidates:

1. **Candidate sampling** — collect `k` diverse responses `y₁…y_k` (target model, external APIs, human refs).
2. **Probability scoring** — length-normalized log-prob: `pᵢ = (1/|yᵢ|) Σ_t log p_θ(y_{i,t} | x, y_{i,<t})`.
3. **Ranking optimization** — `L_rank = Σ_{r_j > r_i} max(0, pᵢ − p_j + margin)` penalizes the model when its probability order contradicts the true preference ranking.

This ranking loss is combined with standard SFT cross-entropy on the top-ranked response to stabilize convergence.

**Rule**: Use **length-normalized** log-probs (the `1/|yᵢ|` term) — without normalization, RRHF biases toward longer responses. Combine with SFT CE on the top response.

> Source: findings.md "RRHF" [31] — length-normalized log-prob pᵢ, ranking loss with margin, combined with SFT CE.

**stage**: post-training.

### PA3: Pick the Dataset Format by Turn Count

Two standard fine-tune formats:

- **Alpaca** — flat list of JSON objects with `instruction` / `input` / `output`; ideal for **single-turn** instructions.
- **ShareGPT** — nested `conversations` array of `{from, value}` turns (human/gpt); ideal for **multi-turn** dialogues.

**Rule**: Using Alpaca format for a multi-turn task flattens dialogue structure and loses role boundaries. Match the format to the turn count.

> Source: findings.md "Jinja2 Chat Templates" — Alpaca (single-turn) vs ShareGPT (multi-turn) JSON examples [34,35].

**stage**: post-training.

### PA4: Map the Exact Jinja2 Chat Template

To preserve role boundaries and multi-turn context during SFT, conversation data must be mapped to the model's exact token template. The Llama 3 Jinja2 template compiles conversations into a rigid sequence of reserved control tokens — `<|start_header_id|>`, `<|end_header_id|>`, `<|eot_id|>`, `bos_token` — mapped directly to reserved embedding IDs. This prevents role confusion and maintains structural integrity across training AND inference.

**Rule**: Do not hand-format role markers. A mis-mapped template (wrong EOT/BOS/header tokens) silently corrupts role boundaries and causes the model to confuse speaker turns. Adapting a model like Mistral v7 Tekken — which uses different end-of-turn vs end-of-sequence tokens — requires explicit token mapping.

> Source: findings.md "Jinja2 Chat Templates and Fine-Tuning Orchestration" [28,33] — Llama 3 control tokens (start_header_id/eot_id/bos), reserved embedding IDs, role confusion prevention.

**stage**: post-training.

### PA5: Axolotl / Unsloth Token-Mapping Config

Fine-tuning libraries automate template tokenization, but the config is load-bearing:

**Axolotl**:
- `roles_to_train: ["assistant"]` — isolates gradients to target (assistant) tokens.
- `train_on_eos: last` — prevents premature generation cutoff.
- `eot_tokens` — critical when end-of-turn ≠ end-of-sequence (e.g. Mistral v7 Tekken).

**Unsloth**:
- `standardize_sharegpt` — maps raw dialogue arrays into standard role-content structures.
- `map_eos_token` — maps EOS tokens to **prevent training on pad tokens**.

**Rule**: Without `roles_to_train: ["assistant"]` you train gradients on the user's turns too; without `map_eos_token` / `train_on_eos: last` you train on pad tokens or cut generation early. These are not defaults to ignore.

> Source: findings.md "Fine-Tuning Orchestration" + Conclusion #3 [29,35] — Axolotl roles_to_train / train_on_eos / eot_tokens; Unsloth standardize_sharegpt / map_eos_token.

**stage**: post-training.

### PA6: Reward-Model Training — Diverse Preference Sets

Reward-model (RM) training is computationally intensive and prone to **reward hacking, poor generalization, and proxy-model drift**. The operational mitigation is to use **diverse preference sets and avoid single-source feedback loops**. PPO policy updates additionally require strict KL-divergence constraints to anchor the policy and are extremely sensitive to `β` scaling.

**Rule**: A preference dataset sourced from a single model/annotator invites reward hacking. Diversify the preference sources before RM training.

> Source: findings.md "Post-Training Phases and Cost Dispersal" table [26,27,30,31] — RM failure modes (reward hacking, drift); diverse preference sets, avoid single-source loops; PPO KL constraints + β sensitivity.

**stage**: post-training.

---

## Anti-Patterns

- **DPO for everything**: pairwise-only — use RRHF (>2 candidates) or GRPO (verifiable) (PA1).
- **Un-normalized RRHF scores**: biases toward longer responses (PA2).
- **Alpaca format for multi-turn**: flattens dialogue, loses role boundaries (PA3).
- **Hand-formatting chat markers**: mis-mapped control tokens cause role confusion (PA4).
- **Ignoring roles_to_train / map_eos_token**: trains on user turns and pad tokens (PA5).
- **Single-source preference data**: invites reward hacking and proxy drift (PA6).
