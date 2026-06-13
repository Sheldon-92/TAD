# Phase 4 Review — ai-guardrails — fact-api lens

- **Lens**: fact-api (factual / API / version correctness; replaces cross-model review)
- **Reviewer**: Claude Opus 4.8 (1M), 2026-06-13
- **meets_bar**: true (clears the fact-api bar after one P1 citation fix; no fabricated APIs, no wrong class names, no wrong metric types found)

---

## Verdict

The pack is unusually disciplined on version-sensitive claims: nearly every specific number, class name, endpoint, and version threshold checks out against current primary documentation, and the authors already pre-empted the most common LLM-security factual traps (Pydantic AI rename, Llama Guard 3→4 supersession, vendor-vs-independent Lakera numbers, Presidio random-salt default). One genuine P1 factual defect found: a wrong arXiv citation URL for InjecAgent plus a "no defense" mislabel of the 32.2%/59.7% ASR figures. Everything else verified clean. This is well above the fact-api bar.

---

## Findings

1. **[P1 — WRONG CITATION URL] InjecAgent cited as `arxiv.org/pdf/2510.08829`.** That arXiv ID is "CommandSans: Securing AI Agents with Surgical Precision Prompt Sanitization" (a Nov 2025 *defense* paper that merely *uses* InjecAgent), NOT the InjecAgent benchmark. The real InjecAgent paper is `arxiv.org/abs/2403.02691` (ACL 2024 Findings, aclanthology.org/2024.findings-acl.624). Appears in `references/prompt-injection-defense.md` PI8 source line. Fix the URL.

2. **[P1 — MISLABELED SETTING] InjecAgent "GPT-4 no-defense Direct-Harm 32.2% ASR, Data-Stealing 59.7% ASR".** Accessible InjecAgent sources consistently report GPT-4 (ReAct) **base-setting** aggregate ASR ≈ 23.6–24%, rising to ≈47% in the **enhanced setting** (attacker instructions reinforced with a hacking prompt). A 59.7% data-stealing rate far exceeds the ~24% base aggregate, so these per-category figures are the *enhanced/hacking-prompt* setting, not "no defense." The pack labels them "no defense" in both SKILL.md anti-skip table and PI8. Either re-label as the enhanced setting or recompute against the base setting. (The 32.2%/59.7% values themselves were not contradicted by primary docs — only their "no defense" attribution is.)

3. **[P2 — minor, no change required] Rebuff `openai_model` default.** Pack shows `openai_model="gpt-4o-mini"` as an optional override; the upstream README documents the default as `gpt-3.5-turbo`. The pack does not *claim* gpt-4o-mini is the default (it is shown as an explicit optional arg), so this is accurate, but a reader could misread it as the default. The constructor signature (positional `openai_apikey, pinecone_apikey, pinecone_index, openai_model`; NOT a single `api_token`) is otherwise correct, including the explicit "NOT a single api_token" note.

4. **[OK] Meta "Agents Rule of Two" framing.** A/B/C conditions, Oct/Nov 2025 publication, Chromium "Rule of 2" inspiration, and the Simon Willison lethal-trifecta derivation all match the cited osohq.com canonical statement. (Note: a minority of secondary sources group the conditions as A=untrusted / B=sensitive-OR-state-change / C=external-comm; the pack uses the Oso canonical grouping that matches its own cited source — consistent, not an error.)

5. **[OK] No fabricated APIs / wrong class names anywhere.** AnalyzerEngine/AnonymizerEngine/DeanonymizeEngine/OperatorConfig (Presidio), RebuffSdk.detect_injection, Pydantic AI Agent/output_type/field_validator/ValidationError, sqlglot AST — all real and correctly named. Latency budgets, 6-layer table, HTTP 429 token-rate-limit, gVisor isolation are all internally consistent and non-version-fragile.

---

## fact_checks (each version-sensitive claim vs CURRENT primary docs)

1. **Pydantic AI `result_type`→`output_type`, `result_type` removed in current versions** — CONFIRMED. pydantic/pydantic-ai PR #2441 (BREAKING CHANGE) removed `result_type`/`result_tool_name`/`result_tool_description`/`result_retries`; use `output_type`/`output_retries`. Pack's parenthetical in OV4 is accurate. (ai.pydantic.dev/changelog, github.com/pydantic/pydantic-ai/pull/2441)

2. **Llama Guard 4 12B output-filtering: English recall 69% / FPR 11% / F1 61%; multilingual recall 43% / FPR 3%** — CONFIRMED EXACT against meta-llama/PurpleLlama Llama-Guard4/12B MODEL_CARD.md. Averaged over S1–S13, equal weighting, output-filtering. (github.com/meta-llama/PurpleLlama/blob/main/Llama-Guard4/12B/MODEL_CARD.md)

3. **Llama Guard 4 = 14 categories (S1–S13 MLCommons + S14 Code Interpreter Abuse, text-only); dense model pruned from Llama 4 Scout; replaces 3-8B + 3-11B-vision** — CONFIRMED. Model card: 14 hazards S1–S14, S14 = Code Interpreter Abuse (text-only), pruned from Llama 4 Scout, single GPU 24GB. (model card + huggingface.co/blog/llama-guard-4)

4. **OpenAI omni-moderation-latest ~13 categories (exact list)** — CONFIRMED EXACT. sexual, sexual/minors, harassment, harassment/threatening, hate, hate/threatening, illicit, illicit/violent, self-harm, self-harm/intent, self-harm/instructions, violence, violence/graphic = 13. Pack's list matches verbatim. (OpenAI moderation docs / openai.com upgrade announcement)

5. **Lakera Guard `POST /v2/guard`, OpenAI chat-completions message format, SaaS or self-hosted** — CONFIRMED. docs.lakera.ai: current version is v2, single endpoint POST https://api.lakera.ai/v2/guard, OpenAI chat-completions message format. (docs.lakera.ai/docs/api/guard)

6. **Presidio Hash operator uses random salt by default since 2.2.361; supply consistent salt for stable output** — CONFIRMED EXACT, including the version number. (microsoft/presidio issue #1845, presidio docs/PyPI: random salt default from 2.2.361, breaks referential integrity unless salt provided)

7. **Rebuff `RebuffSdk(openai_apikey, pinecone_apikey, pinecone_index, openai_model)`; needs OpenAI + Pinecone creds; `detect_injection`; NOT a single api_token** — CONFIRMED. protectai/rebuff README shows exactly this constructor and `rb.detect_injection(user_input)`; openai_model optional (README default gpt-3.5-turbo). (github.com/protectai/rebuff/blob/main/README.md)

8. **Meta "Agents Rule of Two" published Oct/Nov 2025, inspired by Chromium "Rule of 2", derives from Willison lethal trifecta** — CONFIRMED. Meta published Oct 2025; A/B/C = untrusted inputs / sensitive data / state-change-or-external-comm; explicitly inspired by Chromium and Willison's lethal trifecta. (osohq.com/learn/agents-rule-of-two..., mbgsec.com)

9. **OWASP Top 10 for LLM 2025: LLM07 System Prompt Leakage + LLM08 Vector & Embedding Weaknesses both new in 2025** — CONFIRMED. Both are 2025 additions; descriptions (system-prompt-not-a-secret; RAG poisoned embeddings/cross-tenant/inversion) match pack usage. (owasp.org Top-10-for-LLMs-2025, indusface LLM08 page)

10. **Spotlighting/datamarking: ASR ~50%→<3% GPT-3.5-Turbo; ~40%→0.00% text-davinci-003; datamarking interleaves `^`; shipped Azure AI Foundry Build 2025** — CONFIRMED EXACT. Microsoft Research Spotlighting paper (arxiv 2403.14720): >50%→<2% overall; GPT-3.5 ~50%→<3%, Text-003 40%→0.00%; datamarking inserts `^` between words. Azure AI Foundry Spotlighting GA confirmed. (microsoft.com/research + techcommunity Azure AI Foundry blog)

11. **AgentDojo: no-defense attacks succeed <25% against best agents; attack-detector drops targeted ASR to ~8%; OpenReview id m1YYAQjO3w** — CONFIRMED. AgentDojo (arxiv 2406.13352 / OpenReview m1YYAQjO3w): "<25% with no defense, drops to 8% with secondary attack detector." URL id correct. (The "~20% baseline most models / Llama-4 17B ~40%" sub-figures are plausible per-model results not independently re-verified here, but the headline 25%→8% — the load-bearing number — is exact.)

12. **InjecAgent benchmark citation `arxiv.org/pdf/2510.08829`** — FALSE. 2510.08829 = "CommandSans" (Nov 2025 defense paper). Correct InjecAgent = arxiv 2403.02691 / aclanthology 2024.findings-acl.624. (Finding #1.)

13. **InjecAgent "GPT-4 no-defense Direct-Harm 32.2% / Data-Stealing 59.7% ASR"** — SETTING MISLABELED. Primary sources give GPT-4 ReAct base-setting aggregate ≈23.6–24%, enhanced (hacking-prompt) ≈47%; 59.7% data-stealing is the enhanced setting, not "no defense." (Finding #2; medium/@danieldkang, aclanthology 2024.findings-acl.624)
