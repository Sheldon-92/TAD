# Dogfood Judgment — ml-training skill

Task: Fine-tune Qwen-8B to mimic writing style. 350 chat messages, 8GB MacBook, ~$20, maybe preference tuning later. What config / platform / tool?

Answer 1 = no-skill (general knowledge). Answer 2 = used ml-training skill (cites lora-finetune.md, data-preparation.md, platform-selection.md, cost-estimation.md, vram-fit.sh/cost-estimate.sh/dataset-check.sh).

## WebSearch / source verification

| Claim | Answer | Verdict | Evidence |
|---|---|---|---|
| 8B QLoRA needs ~10-12GB VRAM | A1 | Slightly conservative but fine | Unsloth: 8B QLoRA fits <10GB (batch1, short seq); their advertised table cites ~24GB headroom figure for comfort. A1's 10-12GB is reasonable. |
| 8GB Mac can't fine-tune 8B | A1, A2 | CORRECT | Unified memory shared with OS; MPS not Unsloth's supported path. Both correct. |
| RunPod 4090 ~$0.34-0.70/hr, Vast ~$0.29-0.50 | A1 | CORRECT | RunPod community from $0.34/hr; Vast from $0.29, ~$0.39 typical (Apr 2026). |
| Colab Pro $10/mo, T4 16GB / L4 handles 8B QLoRA | A1 | CORRECT | Canonical Unsloth free-T4 use case. |
| Qwen2.5-7B = 7B; "no official Qwen-8B base, 8B is Qwen3" | A1 | MOSTLY CORRECT | Qwen3-8B (8.2B) exists in BOTH base + instruct. A1's phrasing "8B size is Qwen3" is right; recommending battle-tested Qwen2.5-7B-Instruct is sound. Minor: Qwen3 naming uses thinking/non-thinking, not a separate "-Instruct" suffix the way A1 implies, but A1 hedged to Qwen2.5 so no material error. |
| r=16, alpha=32 (2x rank) | A1 | DEFENSIBLE / literature default | arXiv + rule-of-thumb favor alpha=2r as optimal; alpha=r "marginally worse." A1 aligns with general consensus. |
| QLoRA 4-bit, lr 2e-4, 3 epochs, eff batch 8, adamw_8bit | A1 | CORRECT | Standard Unsloth SFT defaults. |
| DPO via synthesizing rejected side, SFT-first | A1 | CORRECT (qualitative) | Sound; A1 gives no DPO hyperparams (gap). |
| vram-fit.sh 8 unsloth-qlora4 → 4.5GB | A2 | Faithful to tool, optimistic | Script PER=0.56/B → 4.5GB. Skill's own ref says "8B <10GB"; real T4 peak ~7-9GB. 4.5GB is the checkpointing-best-case, low but the CONCLUSION (fits T4 w/ headroom) is correct. Not answer-changing. |
| cost ~$0.04-0.05 for 350-500 ex, 3 epoch | A2 | CORRECT | cost-estimate.sh: 500ex/2ep/batch8=125 steps≈0.1hr×$0.34=$0.04. Grounded. |
| 100 floor / 500 sweet spot; quality>quantity (500 clean>5000 noisy) | A2 | CORRECT | sitepoint 2026 + Colin dogfood 117>248. Grounded. |
| ShareGPT JSONL schema + dataset-check.sh validation | A2 | CORRECT | Matches data-preparation.md schema + real script exists. |
| DPO needs triples, beta=0.1, lr 5e-6 (~40x lower, do NOT reuse 2e-4) | A2 | CORRECT | Unsloth RL guide: lr 5e-6, beta 0.1 example. The "do not reuse SFT lr" warning is a genuinely high-value, correct rule A1 omitted. |
| alpha=16 (=r) stable for tiny dataset | A2 | DEFENSIBLE, arguably better here | alpha=r is anti-overfit; for 350-sample tiny data, conservative scaling is well-reasoned. |
| Colab quota ~22hr/wk, 12hr session, .edu→Colab Pro free for students | A2 | CORRECT/grounded | Quotas match cost-estimation.md tree; .edu detail is a nice personalized touch (user IS zhaos948@newschool.edu). |
| Qwen3.5 caveat: QLoRA not recommended (use bf16 LoRA) | NEITHER | Both miss it | Unsloth now warns QLoRA degrades on Qwen3.5 specifically. Neither answer flags this — but user said Qwen-8B (=Qwen3-8B), where QLoRA is fine, so not a defect for either. |

## No specific-but-WRONG claims found in either answer

Both answers are unusually clean factually. No fabricated numbers, no wrong tool names, no hallucinated APIs. Answer 2's 4.5GB is optimistically low vs ~7-9GB real-world, but it is faithfully reported from the skill's own grounded tool and the conclusion is correct — flagged as imprecise, not wrong.

## Merit comparison

Both reach the SAME correct core: cloud not Mac, Unsloth, QLoRA r=16 4-bit, SFT-then-DPO, data is the real bottleneck.

Where Answer 2 (skill) wins decisively:
1. **Correctly reframes the question.** User asked "what config/platform/tool" but the real blocker is 350 < 500 sweet-spot. A2 leads with the AI-bootstrap-to-500 technique — actionable, specific, sourced. A1 mentions "quality>quantity, maybe 200 good ones" but treats data as a footnote and never tells the user how to GET to a workable dataset.
2. **Platform call is sharper and cheaper.** A2 says Colab FREE T4 (~$0.05), proves it with vram-fit + cost-estimate, and explicitly tells the user "$20 budget is a non-issue." A1 recommends paid RunPod/Colab Pro ($1-3 / $10), which works but over-spends and under-analyzes — A2's "you don't need to pay at all" is both correct and higher-value given the explicit $20 constraint.
3. **DPO section is concretely superior.** A2 gives the exact triple schema, beta=0.1, lr 5e-6, AND the high-value anti-footgun rule "do NOT reuse 2e-4 — it diverges (~40x lower)." A1 only says "you'll need pairs, do SFT first" with zero hyperparameters. The user explicitly asked about preference tuning later.
4. **Personalization**: A2 caught the .edu email → Colab Pro free for students.
5. **Validation tooling**: A2 points to dataset-check.sh (real, exists) for schema validation before burning GPU time.

Where Answer 1 is competitive or better:
- alpha=2r (A1) is the literature-default-optimal; A2's alpha=r is "marginally worse" generically (though arguably better for this tiny-data case). A wash to slight-A1 on this single knob.
- A1's loss-masking tip (train only on user replies, not prompts) is a genuinely important detail A2 does NOT mention. Real value-add.
- A1's prose is cleaner; A2 opens with awkward meta ("The scripts confirm the skill's rules deterministically") that leaks its scaffolding.

## Verdict

**Winner: Answer 2 (the skill). Margin: clear (not decisive).**

Both are factually clean and correct on the core. Answer 2 wins on CORRECT specifics, not verbosity: it (a) reframes to the actual blocker with a sourced remediation path, (b) gives a cheaper+correct platform call that respects the stated budget, (c) delivers complete, correct, footgun-aware DPO hyperparameters the user explicitly asked about, and (d) backs claims with grounded numbers + executable validators. Answer 1 is a strong, well-written general answer with one unique gem (loss masking) and a marginally-more-standard alpha, but it over-spends on platform, under-serves the data problem, and gives no DPO config. Not decisive because A1 has no wrong claims and contributes the loss-masking insight A2 lacks.

Scores (1-5):
- A1: correctness 5, actionability 4, specificity 4, completeness 3
- A2: correctness 5 (4.5GB imprecise but conclusion-safe), actionability 5, specificity 5, completeness 5
