## Guardrail Review: Support Agent Email + Web + SQL + Orders DB + Email Reply

### Rule-of-Two Audit

| Agent/workflow | A: untrusted input | B: sensitive data/systems | C: external state change | Gate required |
|---|---:|---:|---:|---|
| Support agent | Yes: free-form customer email, web links, retrieved pages | Yes: orders DB, names, addresses, card numbers | Yes: DB write + customer email send | **Yes, mandatory** |

This agent satisfies all three legs of the **Agentic Rule of Two**. It must drop one capability or add human approval before DB writes and outgoing email.

### P0 — Blocking

- **[P0] Rule PI2 / DA2 / LLM06: Agent violates the Agentic Rule of Two and has direct tool/API access.**  
  → It processes untrusted email and web content, accesses sensitive order data, and changes external state by writing to the orders DB and emailing customers. Insert an **AI Gateway** in front of all model/tool traffic, and require **human-in-the-loop approval** before DB writes or outbound email. Maps to **OWASP LLM01, LLM06**.

- **[P0] Rule OV1 / OV3: Model-generated SQL is executed directly.**  
  → This is immediate **LLM05 Improper Output Handling**. Parse SQL with **sqlglot AST**, allow **read-only SELECT only**, reject `DELETE`, `DROP`, `UPDATE`, multi-statements, comments, unsafe joins, and run with a read-only DB user. Use parameterized queries. Maps to **OWASP LLM05**.

- **[P0] Rule OV2: “Model returns JSON” is treated as safety validation.**  
  → Valid JSON can still contain dangerous actions like `{"action":"execute_command","parameter":"rm -rf /"}` or destructive SQL. Add **Pydantic AI** `BaseModel` schemas with field constraints, then Layer 2 content allowlists/AST gates, then Layer 3 human approval for state-changing actions. Maps to **OWASP LLM05, LLM06**.

- **[P0] Rule PII1: Raw names, addresses, and card numbers are sent straight to the model.**  
  → Run **Microsoft Presidio AnalyzerEngine → AnonymizerEngine** before model calls. For card numbers use redact/mask; for customer identity that must round-trip, use **Encrypt + DeanonymizeEngine**. Tune/report **F2 score, β=2**, not F1, because false negatives are compliance failures. Maps to **OWASP LLM02**.

- **[P0] Rule PI1 / PI3 / PI4: No prompt-injection defense for email or summarized web links.**  
  → Customer emails and linked web pages are untrusted. Scan email and fetched web/RAG content before it enters the prompt. Do **decode-then-validate** for Base64/ROT13/homoglyph payloads, and use semantic detection such as **Lakera Guard sub-50ms** or **Rebuff** with canary tokens. Maps to **OWASP LLM01**.

### P1 — Required

- **[P1] Rule PI5: Single-turn/no filtering misses multi-turn and payload-splitting attacks.**  
  → Use **NeMo Guardrails with Colang** for stateful Input/Dialog/Retrieval/Execution/Output rails. This is especially important because customer emails and linked pages can split instructions across messages and retrieved content. Maps to **OWASP LLM01**.

- **[P1] Rule PI7: Tool outputs and web summaries re-enter the reasoning loop untrusted.**  
  → Validate fetched page content, link previews, SQL results, and tool metadata before injecting them back into the model context. Enforce explicit trace boundaries so `Thought:` / `Observation:` text in external content cannot hijack a ReAct loop. Maps to **OWASP LLM01, LLM05**.

- **[P1] Rule CM1: Moderate both input and output, not just user email.**  
  → Add input and response-stage moderation. For standard support content, OpenAI Moderation can work; for custom business harms or tool-abuse categories, prefer **Llama Guard 3/4** with a custom taxonomy. Response classification is materially stronger; Llama Guard 3 Vision response-stage benchmark shows **recall 0.916, FPR 0.016**. Maps to **OWASP LLM02, LLM05**.

- **[P1] Rule DA3: Add token-based rate limiting.**  
  → IP/request limits are insufficient for inference DoS. Enforce token-consumption limits at the gateway and return **HTTP 429** when exceeded. Maps to **OWASP LLM04/availability risk**.

### P2 — Advisory

- **[P2] Rule PII2: Choose anonymization operators by downstream need.**  
  → Use `mask` for partial card display, `hash` with fixed managed salt for stable joins, `encrypt` for reversible customer fields, and `replace` only where irreversible placeholders are acceptable.

- **[P2] Rule OV5 / OV6: Add safe structured-output ergonomics.**  
  → Use `pydantic-ai-guardrails` structured-feedback retries with capped `max_retries`, and define `Union[Result, UnableToAssess]` so the model can refuse instead of hallucinating structured order answers.

### Layered Defense Coverage

| Layer | Status | Required control | Latency budget |
|---|---|---|---:|
| 1. Input validation | Missing | Presidio + Lakera Guard | 15-50ms |
| 2. Prompt hardening | Missing | role delimiters + Rebuff canary | <2ms |
| 3. Retrieval/web rail | Missing | NeMo retrieval rails; scan linked pages | 10-30ms |
| 4. Output filtering | Missing | Llama Guard/OpenAI Moderation + PII leakage block | 100-400ms |
| 5. Tool-call gating | Missing | Pydantic AI + sqlglot AST + allowlist | 5-15ms |
| 6. Execution sandbox/human gate | Missing | human approval for DB writes/email send | manual |

### Tool Recommendation

Use **Presidio** for PII redaction, **Lakera Guard** for sub-50ms prompt-injection screening, **NeMo Guardrails** for stateful dialog/retrieval/execution rails, **Pydantic AI** for typed JSON validation, **sqlglot** for SQL AST gating, and **Llama Guard 3/4** for customizable input/output moderation.
