## Guardrail Review: Support agent (email-in → web-link summarize → SQL-on-orders-DB → DB write + email-out)

Reviewed against the `ai-guardrails` pack (OWASP Gen AI Security mapping; Presidio / Llama Guard / NeMo / Lakera / Rebuff / Pydantic AI / sqlglot). Scenario routed through Step 0 as a **full guardrail review** — all five reference files applied (prompt-injection-defense, output-validation, pii-deidentification, content-moderation, defense-architecture).

---

### Rule-of-Two Audit (Cross-Cutting Rule / PI2)

The Agentic Rule of Two: an autonomous agent must **NEVER** satisfy more than TWO of (A) processes untrustworthy input, (B) has access to sensitive data/systems, (C) can change state externally. This single agent satisfies **all three**.

| Condition | Satisfied? | Evidence in the pipeline |
|-----------|:---:|---|
| **(A) Untrustworthy input** | ✅ YES | Customer's free-form incoming email (attacker-controlled) **+** web links the customer sends, which the agent fetches and summarizes — classic **indirect injection** vector (PI1). The fetched page content is untrusted even though your own tool retrieved it. |
| **(B) Sensitive data / systems access** | ✅ YES | Reads/queries the **orders database** (customer PII, order history); full email text contains names, addresses, **card numbers**. |
| **(C) External state change** | ✅ YES | Writes a follow-up **to the orders database** AND **emails the customer back** — two independent state-mutating, externally-visible actions. |

**Verdict: A + B + C = all three legs → single indirect injection away from RCE / unauthorized DB mutation / data exfiltration via outbound email.** A malicious instruction hidden in a customer-supplied web page (or in the email body) can drive the agent to dump the orders table into the reply email, or write attacker-chosen rows. This is the exact Morris-II-class cascade configuration the rule exists to prevent.

**Required remediation (PI2):** Drop one leg OR insert a **human-in-the-loop approval gate before every state-changing action** (the DB write and the outbound email). Recommended minimum: gate (C) — no autonomous DB write and no autonomous send; queue for human approval. This is **non-negotiable and blocks deployment**.

---

### P0 — Blocking (exploitable now; block deployment)

**[P0] Rule PI2 (prompt-injection): Agent violates the Rule of Two (A+B+C, no human gate).**
→ See audit above. The summarize-untrusted-web-link capability (A) combined with orders-DB access (B) and DB-write + email-send (C) is a single indirect injection from unauthorized purchase/mutation/exfil. **Fix:** mandate Layer-6 human approval before any DB write or outbound email, OR remove the web-link-summarization leg from the agent that holds the DB/email tools. **Maps to OWASP LLM01 + LLM06 (Excessive Agency).**

**[P0] Rule OV1 + OV3 (output-validation): Model-generated SQL run directly against the orders DB.**
→ "The model generates a SQL query and runs it against the orders DB" is textbook Improper Output Handling — "the new XSS." A schema-valid model response can carry `DROP TABLE orders` or `DELETE FROM orders` or a blind-`UNION` exfil. **Fix (three-layer gating, all mandatory):** Layer 1 — Pydantic schema on the query-intent object; Layer 2 — parse the generated SQL with **sqlglot AST**, allow **read-only `SELECT` only**, reject `DELETE`/`DROP`/`UPDATE`/`INSERT`/multi-statement, and run under a **read-only DB user** scoped to the orders schema; Layer 3 — human gate for any write. Never execute model SQL un-parameterized. **Maps to OWASP LLM05.**

**[P0] Rule OV2 (output-validation): "The model returns JSON and we trust it."**
→ Structured ≠ validated. `{"action":"execute_command","parameter":"rm -rf /"}` is valid JSON. The follow-up written to the DB and the email body are both downstream sinks fed by trusted-but-unvalidated model output. **Fix:** enforce a typed **Pydantic `BaseModel`** with explicit type + range + value constraints and `field_validator`; reject on `ValidationError`. Constrain the agent's `result_type` to the validated schema (OV4) rather than accepting free-form JSON and trusting it. **Maps to OWASP LLM05.**

**[P0] Rule PII1 + PII Anti-Pattern (pii-deidentification): Full email text — names, addresses, card numbers — passed straight to the external model.**
→ "We pass the customer's full email text (names, addresses, card numbers) straight to the model… no filtering" is a compliance breach. The "it's internal" excuse does not apply — any external model call requires redaction first, and **card numbers (PAN) are PCI-DSS scope** regardless. **Fix:** run **Presidio `AnalyzerEngine` → `AnonymizerEngine`** before the model call. Because the agent must email a coherent reply referencing real order details, use the **Encrypt operator + `DeanonymizerEngine`** (PII3) for round-trip restore — NOT Replace/Redact, which are lossy and irreversible. Card numbers should additionally be hard-redacted/masked (PII2 `mask`, last-4 only); they should never be needed by the model at all. **Maps to OWASP LLM02 (Sensitive Information Disclosure).**

**[P0] Rule DA2 (defense-architecture): LLM wired directly to the DB and the email API — no AI Gateway.**
→ Applications must NEVER connect a model directly to external APIs/tools. There is no interception point to apply PII redaction, token tracking, rate limiting, or policy before the DB write / email send fires. **Fix:** front the model with an **AI Gateway** (e.g. Lakera Guard as a Kong reverse-proxy plugin scanning SSE frames) so policy applies before any downstream execution. **Maps to OWASP LLM01/LLM02/LLM06 (architecture-level).**

**[P0] Rule PI3 + PI4 + Anti-Skip "we sanitize with a blocklist" (prompt-injection): "No filtering" = zero injection defense.**
→ Even a keyword blocklist would be insufficient (PI3: typoglycemia `ignroe all prevoius systme instructions`, Base64/ROT13, payload splitting, `</user><system>` boundary confusion all bypass string matching) — and you have *none*. **Fix:** add an input-screening layer with **decode-then-validate** (PI4: decode candidate Base64/ROT13/homoglyphs, THEN screen the post-decoded payload) plus a semantic classifier or **Lakera Guard (sub-50ms inline)** / **Rebuff** (heuristic + LLM-judge + vector-DB + canary token). Enforce system/user/tool **role separation as a schema**, not prose. **Maps to OWASP LLM01.**

---

### P1 — Required (fix before production)

**[P1] Rule PI1 (prompt-injection): Indirect injection through the summarized web links is unguarded (no Retrieval Rail).**
→ The fetched/summarized page is untrusted external data that flows into the prompt. **Fix:** scan fetched link content for indirect injection BEFORE it populates the prompt (DA1 Layer 3 — **NeMo Guardrails retrieval flows** / semantic filters). Treat link-preview content as hostile by default. **Maps to OWASP LLM01 (indirect).**

**[P1] Rule CM1 (content-moderation): No output moderation on the customer-facing email or the DB write.**
→ Moderate **both input and output**; response classification is more robust than prompt classification. The agent currently emits to a customer with zero output check. **Fix:** add **Llama Guard** output-stage moderation (its response-classification FPR is **0.016**, ~15× lower than GPT-4o's 0.243) plus a PII-leakage block at output so decrypted/real PII is never echoed beyond what's necessary. **Maps to OWASP LLM02/LLM05.**

**[P1] Rule PI5 (prompt-injection): Single-turn-only screening misses payload splitting / multi-turn.**
→ An email thread is multi-turn; a split payload (benign per message, recombines in context) defeats per-turn screening. **Fix:** stateful dialogue tracking (**NeMo Guardrails + Colang**) enforcing predefined interaction flows. **Maps to OWASP LLM01.**

**[P1] Rule OV5 + OV6 (output-validation): No capped retry loop and no graceful-refusal path.**
→ On validation failure the design has no defined behavior; forcing structured output when context is thin drives hallucinated DB writes/emails. **Fix:** structured-feedback retry with a capped `max_retries` (uncapped = DoS/cost surface), and a `Union[Result, UnableToAssess]` refusal class so the agent declines instead of fabricating an order answer. **Maps to OWASP LLM05.**

**[P1] Rule DA3 (defense-architecture): No token-based rate limiting on the model endpoint.**
→ IP/request-count limiting is insufficient against high-latency-inference DoS. **Fix:** token-consumption limits returning **HTTP 429**. **Maps to OWASP LLM10/Unbounded Consumption (cost).**

---

### P2 — Advisory (hardening)

**[P2] Rule PI6 (prompt-injection): Add Rebuff canary tokens.** Prefix a high-entropy canary to the system prompt; if it appears in any output (DB write or email), the system prompt leaked → block + log. Near-free Layer-2 hardening (DA4 <2ms budget).

**[P2] Rule PII4 (pii-deidentification): Tune the PII detector on F2 (β=2), not F1.** A missed entity (false negative) is a compliance breach; weight recall twice as heavily as precision. Report F2.

**[P2] Rule CM2/CM3/CM5 (content-moderation): Measure FPR on your own traffic before trusting one classifier, and prefer Llama Guard's 13+ customizable categories** (S14 Code-Interpreter Abuse is directly relevant to the SQL-execution path) over the closed 8-category OpenAI Moderation API. Customize the taxonomy via few-shot prompting — no retraining.

**[P2] Rule PII5 (pii-deidentification): Offload transformer NER to a `RemoteRecognizer`** (GPU container) so Presidio doesn't blow the input-validation latency budget.

---

### Layered Defense Coverage (DA1 — 6 layers; DA5 OWASP pinning)

| # | Layer | Target OWASP | Present? | Latency budget |
|---|-------|--------------|:---:|---|
| 1 | Input Validation (Presidio PII + Lakera/Prompt Guard) | LLM01, LLM02 | ❌ MISSING (P0) | 15–50ms |
| 2 | Prompt-Template Hardening (role delimiters, Rebuff canary) | LLM01, LLM07 | ❌ MISSING | <2ms |
| 3 | Retrieval Rail / RAG Sandbox (scan summarized links) | LLM01 indirect | ❌ MISSING (P1) | 10–30ms |
| 4 | Output Filtering / Moderation (Llama Guard + PII-leak block) | LLM02, LLM05 | ❌ MISSING (P1) | 100–400ms |
| 5 | Tool-Call Gating (Pydantic + sqlglot AST + allowlist) | LLM06 | ❌ MISSING (P0) | 5–15ms |
| 6 | Execution Sandbox & Human Gating (DB write + email send) | LLM05 / RCE | ❌ MISSING (P0) | manual |

**0 of 6 layers present.** Every OWASP risk in scope (LLM01 injection, LLM02 sensitive-info disclosure, LLM05 improper output, LLM06 excessive agency) has **zero covering controls** — each is a P0 gap per DA5. There is no AI Gateway (DA2) to host these layers.

---

### Tool Recommendation

| Need | Tool | Where |
|------|------|-------|
| PII detect + round-trip restore (names/addresses/cards) | **Microsoft Presidio** AnalyzerEngine → AnonymizerEngine, **Encrypt** operator + DeanonymizerEngine; `mask` card PAN | Layer 1 (before model) / Layer 4 (after) |
| Inline injection screening (sub-50ms) | **Lakera Guard** (`POST /v2/guard`), also as Kong gateway plugin | Layer 1 / DA2 gateway |
| Self-hardening detection + canary | **Rebuff** | Layer 1–2 |
| Stateful dialog + retrieval rail (multi-turn email threads, link scanning) | **NVIDIA NeMo Guardrails** (Colang) | Layer 3 / dialog |
| Output safety, custom taxonomy incl. S14 code-interpreter abuse | **Meta Llama Guard 3/4** (response-class FPR 0.016) | Layer 4 |
| Typed output schema + capped retry + Union refusal | **Pydantic AI** (`field_validator`, `result_type`) | Layer 5 |
| Gate model-generated SQL to read-only SELECT | **sqlglot** AST parsing + read-only DB user | Layer 5 |

**Bottom line:** Ship-blocking. The pipeline violates the Rule of Two and exposes 6 distinct P0s across LLM01/LLM02/LLM05/LLM06 with zero of the six defense layers in place. Minimum to unblock: AI Gateway (DA2) + Presidio Encrypt round-trip on the email text (drop card numbers from the model entirely) + sqlglot read-only SELECT gating + Pydantic-validated output + a human approval gate on the DB write and the outbound email.
