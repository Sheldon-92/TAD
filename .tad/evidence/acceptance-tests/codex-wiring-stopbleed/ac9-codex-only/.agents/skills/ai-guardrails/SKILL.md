---
name: ai-guardrails
description: AI guardrails & LLM I/O security capability pack. Gives AI agents the judgment rules for defending LLM and agent pipelines against prompt injection (OWASP LLM01), improper output handling (OWASP LLM05), excessive agency, PII leakage, and unsafe content. Research-grounded rules from OWASP Gen AI Security, Microsoft Presidio, NVIDIA NeMo Guardrails, Meta Llama Guard, Lakera Guard, Rebuff, and Pydantic AI. Use for any guardrail design, prompt-injection defense, PII de-identification, output/tool-call validation, content-moderation, or LLM security review task.
keywords: ["护栏", "guardrails", "ai security", "提示注入", "prompt injection", "越狱", "jailbreak", "OWASP LLM", "PII", "脱敏", "de-identification", "内容审核", "content moderation", "输出校验", "output validation", "Presidio", "Llama Guard", "NeMo Guardrails", "Lakera", "Rebuff", "LLM05", "excessive agency", "rule of two"]
type: reference-based
---

**CONSUMES**: User LLM/agent pipeline description + optional existing guardrail configs + the inputs/outputs/tools the agent touches
**PRODUCES**: Applied guardrail judgment rules + layered defense architecture + prompt-injection mitigations + PII de-identification config + output/tool-call validation gates + content-moderation tool selection + OWASP-mapped findings

# AI Guardrails & LLM I/O Security Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents wire an LLM straight to a database, a shell, or an email API and trust whatever it returns. They "sanitize" prompt injection with a keyword blocklist that any Base64 or typoglycemia payload walks straight past. They moderate content with a single API and never measure its false-positive rate. They send raw enterprise text — names, emails, card numbers — to a third-party model with no PII redaction. They accept a syntactically valid JSON tool call (`{"action":"execute_command","parameter":"rm -rf /"}`) as if valid JSON meant safe content.

This pack embeds the judgment rules that LLM security engineers apply automatically — rules from OWASP Gen AI Security guidance, real guardrail tooling documentation (Presidio, NeMo Guardrails, Llama Guard, Lakera, Rebuff, Pydantic AI), and published red-team benchmarks.

**Pack = LLM security judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: The Agentic Rule of Two (a.k.a. the Lethal Trifecta)

> **An autonomous agent must NEVER satisfy more than TWO of these three conditions simultaneously: (A) processes untrustworthy input, (B) has access to sensitive data/systems, (C) can change state externally (write/send/execute).** Any workflow that requires all three MUST insert a human-in-the-loop approval gate before the state-changing action.

**Datable, named provenance (pin these — the rule must be verifiable, not "Meta design guidelines"):**
- **Meta — "Agents Rule of Two"** (published Oct/Nov 2025): an agent should hold at most 2 of {A processes untrustworthy input, B accesses sensitive/private data, C can change state or communicate externally}. Explicitly inspired by **Chromium's "Rule of 2."**
- **Simon Willison — "Lethal Trifecta"** (June 2025): the foundational model the Rule of Two derives from. The trifecta = **access to private data + exposure to untrusted content + ability to externally communicate**. It explains *every* public agent data-exfiltration breach: untrusted content plants instructions → rides existing private-data access → exfiltrates via an external channel. "Lethal trifecta" is the more widely-used term — recognize it as a synonym.
  - Source: https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/ (originating post, retrieved 2026-06-13); Meta/Oso writeup: https://www.osohq.com/learn/agents-rule-of-two-a-practical-approach-to-ai-agent-security

This is the single rule that bounds the blast radius of every prompt injection. A model summarizing untrusted web pages (A) that also holds an e-commerce/email tool (B+C) is a single indirect injection away from unauthorized purchases or RCE — and cascading worms like Morris II propagate exactly through agents that violate it. Surface it here because burying it in one reference file causes agents to wire all three together by default.

---

## Step 0: Context Detection

When the user mentions LLM/agent security work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "prompt injection", "jailbreak", "DAN", "indirect injection", "lethal trifecta", "obfuscation", "Base64/ROT13", "Spotlighting", "datamarking", "payload splitting", "Rebuff", "Lakera", "NeMo", "AgentDojo", "InjecAgent", "提示注入", "越狱" | `references/prompt-injection-defense.md` |
| "content moderation", "toxicity", "safety classifier", "Llama Guard", "OpenAI Moderation", "harmful content", "内容审核", "审核" | `references/content-moderation.md` |
| "PII", "redaction", "anonymize", "de-identify", "Presidio", "mask", "encrypt PII", "脱敏", "数据脱敏", "隐私" | `references/pii-deidentification.md` |
| "output handling", "LLM05", "validate output", "tool call", "SQL injection", "XSS", "Pydantic", "schema validation", "AST", "sqlglot", "输出校验" | `references/output-validation.md` |
| "guardrail architecture", "defense in depth", "AI gateway", "rate limit", "latency budget", "layered", "护栏架构", "纵深防御" | `references/defense-architecture.md` |
| "full guardrail review", "secure my LLM app", "audit my agent security", "everything" | Load **all references** sequentially |

---

## Rule Index

One-glance map of every capability area → reference file → rule IDs. See full coverage without opening each reference (progressive-disclosure entry point).

| Capability Area | Reference File | Rule IDs |
|-----------------|----------------|----------|
| **Prompt-injection defense** (direct/indirect, obfuscation, Spotlighting, multi-turn, ReAct, attack-success-rate baselines) | `references/prompt-injection-defense.md` | PI1 PI2 PI3 PI4 PI5 PI6 PI7 PI8 |
| **Output validation & tool-call gating** (LLM05, structured≠validated, 3-layer gate, Pydantic AI, retry loop, Union refusal) | `references/output-validation.md` | OV1 OV2 OV3 OV4 OV5 OV6 |
| **PII de-identification** (Presidio two-engine, operators, round-trip, F2 recall, RemoteRecognizer) | `references/pii-deidentification.md` | PII1 PII2 PII3 PII4 PII5 |
| **Content moderation** (in+out moderation, OpenAI vs Llama Guard 4, FPR measurement, multimodal, taxonomy) | `references/content-moderation.md` | CM1 CM2 CM3 CM4 CM5 |
| **Layered defense architecture** (6-layer defense-in-depth, AI gateway, token rate-limit, latency budgets, OWASP 2025 mapping) | `references/defense-architecture.md` | DA1 DA2 DA3 DA4 DA5 |
| **Cross-cutting** | this SKILL.md body | Agentic Rule of Two / Lethal Trifecta |

**Deterministic validator**: `scripts/check-guardrail-config.sh <config>` flags the four highest-signal anti-patterns (Rule-of-Two/lethal-trifecta violation, blocklist-only injection defense, raw SQL/shell sink without sqlglot/AST gate, external LLM call without Presidio de-id). Exit 0 = pass, 1 = findings — wire into CI. Self-test: `--self-test`.

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's pipeline, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix with the named tool/operator/threshold
4. **Enforce the Rule of Two** on every agent that touches tools — count A/B/C conditions explicitly
5. **Map every finding to its OWASP LLM risk** (LLM01 Prompt Injection, LLM05 Improper Output Handling, LLM06 Excessive Agency, LLM02 Sensitive Information Disclosure) so findings compare across projects
6. **Prefer recall over precision for safety-critical detection** — for PII and harmful-content classifiers, a false negative is a compliance breach; use the F2 score (β=2), not F1

Output format per finding:
```
[P0] Rule PI4 (prompt-injection): Defense is a keyword blocklist only.
→ A Base64/typoglycemia payload bypasses it. Add a post-decode validation layer + a semantic LLM classifier or Lakera Guard (<50ms). Maps to OWASP LLM01.

[P0] Rule OV3 (output-validation): Model-generated SQL executed directly.
→ Parse with sqlglot AST, allow read-only SELECT only, reject DELETE/DROP before the DB engine. Maps to OWASP LLM05.
```

---

## Step 2: Output

Produce a structured guardrail review:

```
## Guardrail Review: [pipeline/area reviewed]

### Rule-of-Two Audit
[A/B/C condition table for each agent + whether human gate is required]

### P0 — Blocking (exploitable now; block deployment)
- [finding + specific fix + OWASP mapping]

### P1 — Required (fix before production)
- [finding + specific fix + OWASP mapping]

### P2 — Advisory (hardening)
- [finding + specific fix]

### Layered Defense Coverage
[which of the 6 architecture layers are present/missing + inline latency budget]

### Tool Recommendation
[Presidio / Llama Guard / NeMo / Lakera / Rebuff / Pydantic AI based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We sanitize injection with a blocklist" | Typoglycemia (`ignroe all prevoius systme instructions`) and Base64/ROT13 encoding bypass keyword filters while remaining executable by the model. You need post-decode validation + a semantic classifier, not a wordlist. |
| "The model returns valid JSON, so it's safe" | `{"action":"execute_command","parameter":"rm -rf /"}` is valid JSON. Structured ≠ validated. Enforce a Pydantic schema with range/value constraints, then AST-gate the content. |
| "We only test single-turn injections" | Multi-turn jailbreaks and payload splitting recombine across the attention window. Each input passes alone; the attack assembles in context. Use stateful dialogue tracking (NeMo/Colang). |
| "It's just an internal agent, skip PII redaction" | Sending raw names/emails/card numbers to an external model is a compliance breach. Run Presidio AnalyzerEngine→AnonymizerEngine; use Encrypt operator if you must restore values from the response. |
| "Our agent has all the tools it needs" | Untrusted input + sensitive data + external state-change = all three legs of the Rule of Two (a.k.a. the **lethal trifecta**, Simon Willison 2025). That is a single injection from RCE. Drop one leg or add a human approval gate. Run `scripts/check-guardrail-config.sh` on the agent config to flag it deterministically. |
| "We added an injection detector, so we're safe" | A detector reduces but does not eliminate residual risk — quantify it. On **AgentDojo**, attacks succeed against the best agents in <25% of cases with no defense; most models sit ~20% targeted ASR (Llama-4 17B ~40%), and a secondary attack-detector defense brings targeted ASR down to **~8%**. (These cuts are reported across different model populations, not one paired before/after cohort — treat ~8% as the with-detector ballpark, not a fixed delta off any single model.) **InjecAgent** (arXiv 2403.02691, Table 3) on ReAct GPT-4 — **base/no-defense**: Direct-Harm **14.7%** / Data-Stealing **32.7%** (aggregate 23.6%); **enhanced** (hacking prompt): Direct-Harm **33.3%** / Data-Stealing **61.0%** (aggregate 47.0%). Measure your pipeline's actual robustness on AgentDojo / InjecAgent, don't assert "we added guardrails." |
| "One moderation API is enough" | OpenAI Moderation is a closed, provider-defined classifier (omni-moderation-latest exposes ~13 non-extensible categories) that struggles with context-dependent toxicity; Llama Guard's customizable categories let you cover threat-model-specific harms. **Llama Guard 4 12B** output-filtering benchmark: English recall **69%** / FPR **11%** / F1 **61%**; Multilingual recall **43%** / FPR **3%** — these are *Meta in-house test-set* numbers, not head-to-head. 69% English recall means ~31% of unsafe content passes → measure FPR/recall on your own content before trusting either. |

---

## Tool Quick Reference

| Tool | Install / Endpoint | Primary Use |
|------|--------------------|-------------|
| Microsoft Presidio | `pip install presidio-analyzer presidio-anonymizer` | PII detection (AnalyzerEngine) + de-identification (AnonymizerEngine: replace/redact/hash/mask/encrypt) |
| Meta Llama Guard 4 12B | Purple Llama (open-weight; dense model pruned from Llama 4 Scout, early-fusion multimodal) | Input+output safety classification; **replaces both Llama Guard 3-8B and 3-11B-vision** in one classifier; **14 categories** = 13 MLCommons hazards (S1–S13) + S14 Code Interpreter Abuse |
| OpenAI Moderation API | hosted classifier | Fast text+image moderation over a closed, provider-defined taxonomy (omni-moderation-latest, ~13 categories), out-of-the-box |
| NVIDIA NeMo Guardrails | `pip install nemoguardrails` (Colang) | Stateful dialog/input/output/retrieval/execution rails |
| Lakera Guard | single endpoint `POST /v2/guard` (OpenAI chat-completions message format; SaaS or self-hosted) | Inline injection/jailbreak/PII detection. *Vendor* numbers: 98%+ detection / sub-50ms / FPR <0.5% — but independent evals report ~53% malicious accuracy + higher latency. Benchmark neutrally with the open **PINT** suite (`lakeraai/pint-benchmark`). |
| Rebuff | `from rebuff import RebuffSdk` (needs OpenAI + Pinecone creds) | Heuristic + LLM-judge + vector-DB + canary-token injection detection |
| Pydantic AI / pydantic-ai-guardrails | `pip install pydantic-ai` | Typed output schema validation + structured-feedback retry loop |
| sqlglot | `pip install sqlglot` | SQL AST parsing to gate read-only SELECT before DB execution |
