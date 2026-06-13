# Dogfood Judgment: ai-guardrails capability pack

**Task**: Security review of a support-agent pipeline (email → link summarize → LLM → SQL gen+run → DB write → email back; raw PII incl. card numbers passed to model; JSON trusted).
**Date**: 2026-06-13
**Judge**: independent, blind to which answer used the skill.

## Which answer used the skill?
Answer 1 — it cites the pack's exact rule IDs (PI2, OV3, PII1, DA1, the Rule-of-Two audit table, the 6-layer coverage table, `check-guardrail-config.sh`). Answer 2 is a strong general security review with no pack scaffolding.

## WebSearch verification of specific claims

### Answer 1 — ALL specifics verified CORRECT
- **Meta "Agents Rule of Two" (Oct/Nov 2025), inspired by Chromium's Rule of 2, derived from Willison's lethal trifecta (Jun 2025)** — CONFIRMED (ai.meta.com/blog/practical-ai-agent-security, simonwillison.net 2025-06-16).
- **Llama Guard 4 12B: English recall 69% / FPR 11% / F1 61%; multilingual recall 43% / FPR 3%** — CONFIRMED exactly against PurpleLlama MODEL_CARD.md.
- **Llama Guard 4 = 14 categories (S1–S13 MLCommons + S14 Code Interpreter Abuse)** — CONFIRMED.
- **InjecAgent (arXiv 2403.02691) ReAct GPT-4: base Direct-Harm 14.7% / Data-Stealing 32.7% / agg 23.6%; enhanced 33.3% / 61.0% / 47.0%** — CONFIRMED exactly against Table 3.
- sqlglot AST read-only-SELECT gate, Presidio Analyzer→Anonymizer + Encrypt/DeanonymizeEngine, F2 (β=2) recall preference, Rebuff canary — all standard/correct.

### Answer 2 — no wrong specifics
- **SSRF via link summarizer: 169.254.169.254 cloud metadata → IAM credential theft, file://, internal hosts** — CONFIRMED (real, high-severity; AWS IMDS link-local endpoint). This is a genuine vuln in THIS pipeline.
- PCI-DSS scope expansion from card numbers in prompt/logs, GDPR/CCPA, Presidio, parameterized templates, read-only role, verified envelope sender — all correct.

### Wrong/imprecise claims
- **Answer 1, minor**: maps the indirect-injection-via-links finding and "retrieval rail" to **OWASP LLM08**. In the 2025 list LLM08 = "Vector and Embedding Weaknesses" (RAG/embedding-store specific). There is no vector store here; indirect injection should stay LLM01. Mislabel, does not corrupt the fix. The moderation row's LLM02/LLM05 tagging is loose but defensible.
- No fabricated numbers in either answer.

## The decisive content gap
**Answer 1 MISSES SSRF entirely.** It treats the link fetcher only as an indirect-injection text channel. But "summarizes any web links they send" = the system fetches attacker-controlled URLs → textbook SSRF against cloud metadata / internal services / credential theft. Answer 2 catches this as its finding #3 with the correct endpoint and fix (egress isolation + scheme/IP deny-list). For a real pipeline this is a P0-class hole.

**Answer 2 also has two concrete fixes Answer 1 lacks:**
- **Authorization on verified session identity, never a customer_id the model/email supplied** + tenant scoping in code (`WHERE customer_id = :authenticated_id`). Answer 1's SQL fix stops at "read-only SELECT + parameterize" and never addresses cross-customer data access (an injected valid SELECT can read *other* customers' rows — Answer 1's own DROP/DELETE framing doesn't cover this).
- **Reply recipient must be the verified envelope sender, never an address the model chose** — closes the exfiltration channel directly.
- Answer 2 also correctly argues the stronger architecture: model should emit **structured intent params, never raw SQL**, vs Answer 1's "validate the SQL the model wrote."

## Where Answer 1 is clearly stronger
- Rule-of-Two / lethal-trifecta framing with named, datable provenance — the single best mental model for bounding this exact pipeline's blast radius, and Answer 1 nails the A/B/C audit.
- Breadth + OWASP mapping + priority tiers + 6-layer coverage table + latency budgets — far more complete checklist; surfaces output moderation, refusal path (`Union[Result, UnableToAssess]`), system-prompt canary, retry caps, token-based rate limiting, eval-on-AgentDojo/InjecAgent — all real and useful.
- Every hard number it cites is correct and primary-source-verifiable, which is the expensive part to get right.

## Scoring (1–5)

| Dim | A1 (skill) | A2 (no skill) | Note |
|-----|-----------|---------------|------|
| Correctness | 4.5 | 4.5 | A1: all numbers right, one OWASP-LLM08 mislabel. A2: no errors but lighter on verifiable specifics. |
| Actionability | 4.5 | 4.5 | A1 names exact tools/operators/thresholds. A2 gives code-side fixes (envelope recipient, session-id authz) that are more directly implementable for the actual holes. |
| Specificity | 5 | 4 | A1 denser in correct named specifics. |
| Completeness | 4 | 4.5 | A1 broader checklist but MISSES SSRF + tenant-scoping + recipient-spoofing. A2 covers all five core sinks incl. SSRF; lighter on moderation/observability. |

## Verdict
**Tie, slight edge worth noting.** Both are genuinely strong and largely complementary. Answer 1 wins on breadth, verified specificity, and the Rule-of-Two framing — clear evidence the pack adds real value (every cited number checks out, which an unaided general reviewer rarely achieves). Answer 2 wins on the highest-severity concrete vuln (SSRF) and the two authorization fixes (tenant scoping, verified recipient) that the pack-driven answer structurally missed by treating the link fetcher only as an injection channel.

Critically, Answer 1 did NOT win merely on verbosity — its specifics are correct and load-bearing. But the pack also induced a blind spot: it routed the URL-fetch finding entirely through its injection rules and never asked the orthogonal "what does fetching an attacker URL do to my network?" question. That is the gap a non-pack, first-principles reviewer caught.

**Winner: tie (slight).** If forced to pick for THIS pipeline's real-world safety, Answer 2's SSRF + authorization catches edge it slightly, but Answer 1's verified-specific breadth offsets. Net: tie.
