# Layered Defense Architecture Rules
<!-- capability: defense_architecture -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| DA1 | Deploy defense-in-depth — 6 layers, each mapped to an OWASP risk and a latency budget | deterministic |
| DA2 | Never connect an LLM directly to external APIs/tools — front it with an AI Gateway | deterministic |
| DA3 | Enforce token-based rate limiting (HTTP 429), not IP-based | deterministic |
| DA4 | Budget inline latency per layer — input ≤50ms, hardening <2ms, output 100–400ms | deterministic |
| DA5 | Pin defenses to the OWASP 2025 risk each mitigates (incl. LLM07 prompt leakage, LLM08 vector/embedding) so gaps are visible | deterministic |

---

## Rules

### DA1: Six-Layer Defense-in-Depth

A production GenAI pipeline deploys these layers in order from untrusted prompt to execution:

| # | Layer | Target OWASP | Core Integration | Inline Latency |
|---|-------|--------------|------------------|----------------|
| 1 | **Input Validation** | LLM01, LLM02 | Presidio PII sanitization, Prompt Guard, Lakera Guard | 15–50ms |
| 2 | **Prompt-Template Hardening** | LLM01, LLM07 | role-based delimiters, Rebuff canary injection, system-instruction anchoring | <2ms |
| 3 | **Retrieval Rail (RAG Sandbox)** | LLM01 (indirect), LLM08 | NeMo Guardrails retrieval flows, semantic cosine-distance filters; scan chunks for injection + duplicates; Spotlighting/datamarking on retrieved spans | 10–30ms |
| 4 | **Output Filtering / Moderation** | LLM02, LLM05 | Llama Guard 4, OpenAI Moderation; PII leakage block | 100–400ms |
| 5 | **Tool-Call Gating** | LLM06 (Excessive Agency) | Pydantic AI constraints, sqlglot AST parsing, allowlist endpoints | 5–15ms |
| 6 | **Execution Sandbox & Human Gating** | LLM05 / RCE | gVisor isolation, human-in-the-loop manual approval for high-risk writes | variable / manual |

**Rule**: Audit which of the 6 layers exist. A missing layer is a coverage gap tied to a specific OWASP risk — e.g. no Layer 5 means excessive agency (LLM06) is unmitigated; no Layer 3 means indirect injection through RAG is unguarded.

> Source: findings.md "Integrated Multi-Layered Security Architecture" + implementation-parameters table [8, 9, 17, 20, 21, 23, 25, 30, 34, 36, 39, 48, 50, 52]

**determinismLevel**: deterministic.

### DA2: Front the LLM With an AI Gateway

Applications must NEVER connect a language model directly to external APIs or tools. Deploy an AI Gateway layer that intercepts all LLM traffic, manages rate limiting, tracks token usage, and applies PII redaction + policy filtering before payloads reach downstream systems.

**Rule**: Direct model→tool/API wiring with no intercepting gateway is a P0 architecture finding. Insert a gateway (e.g. Lakera Guard as a Kong reverse-proxy plugin scanning SSE frames) so policy applies before downstream execution.

> Source: findings.md Strategic Recommendation #1 [8, 10, 41]; Lakera/Kong SSE scanning [25, 27]

**determinismLevel**: deterministic.

### DA3: Token-Based Rate Limiting (HTTP 429)

Traditional IP-based rate limiting is insufficient against DoS attacks that exploit high-latency inference. Implement **token-based** rate limiting on model endpoints, returning HTTP `429 Too Many Requests` when consumption thresholds are exceeded.

**Rule**: If the pipeline only rate-limits by IP/request count, add token-consumption limits returning 429. Inference cost scales with tokens, not requests — IP limiting alone lets a single connection exhaust the budget.

> Source: findings.md Strategic Recommendation #2 [8, 10]

**determinismLevel**: deterministic.

### DA4: Per-Layer Inline Latency Budgets

Each layer has a latency budget that constrains tool choice. Reference points from the architecture table and tool profiles:

- Input validation: **15–50ms** (Lakera Guard sub-50ms fits inline)
- Prompt hardening: **<2ms** (canary injection is near-free)
- Retrieval rail: **10–30ms**
- Output moderation: **100–400ms** (the heaviest inline stage)
- Tool gating: **5–15ms**
- GA Guard model lineup for runtime moderation: Core ~29ms, Lite ~16ms (edge), Thinking ~650ms (high-assurance, red-team-hardened); 256k-token context window for long agent traces

**Rule**: Pick the guardrail model/tool to fit the layer's budget. A 650ms GA Guard Thinking model does not belong inline at an input gate (50ms budget) — reserve it for async/high-assurance review. Output moderation legitimately costs 100–400ms; budget for it rather than skipping it.

> Source: findings.md implementation-parameters latency column [17, 20, 21, 23]; "General Analysis (GA) Guard" lineup + 256k context [23]

**determinismLevel**: deterministic.

### DA5: Pin Each Defense to Its OWASP Risk (OWASP Top 10 for LLM Apps **2025**)

Every layer in the table maps to a specific OWASP LLM risk. This mapping makes coverage gaps and redundancy visible across projects. Use the **2025** Top-10 — it added two entries directly relevant to this pack:
- **LLM07 System Prompt Leakage** (new in 2025) — maps to PI6 canary tokens: a leaked system prompt is detected when the Rebuff canary appears in output.
- **LLM08 Vector & Embedding Weaknesses** (new in 2025) — maps to indirect injection via poisoned RAG chunks (Layer 3 retrieval rail); embedding-store poisoning / cross-tenant leakage.

**Rule**: When reviewing an architecture, label each present control with the OWASP **2025** risk it covers (LLM01 prompt injection, LLM02 sensitive-info disclosure, LLM05 improper output, LLM06 excessive agency, **LLM07 system-prompt leakage**, **LLM08 vector & embedding weaknesses**). Map findings to LLM07/LLM08 where applicable. Any OWASP risk with zero covering controls is a P0 gap.

> Source: findings.md implementation-parameters "Target OWASP Risk" column; OWASP Top 10 for LLM Applications 2025 (LLM07 System Prompt Leakage, LLM08 Vector & Embedding Weaknesses added), https://owasp.org/www-project-top-10-for-large-language-model-applications/assets/PDF/OWASP-Top-10-for-LLMs-v2025.pdf (retrieved 2026-06-13)

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Direct model→tool wiring**: no gateway means no place to apply rate limiting, token tracking, or PII redaction.
- **IP-only rate limiting**: token-based DoS exploits high-latency inference; use token limits + HTTP 429.
- **Single-layer "guardrail"**: one input filter leaves LLM05 (output) and LLM06 (tool agency) wide open.
- **Heavy model inline at a tight gate**: a 650ms classifier blows a 50ms input budget — match model latency to layer budget.
- **Unmapped controls**: without OWASP mapping you cannot see which risks have zero coverage.
