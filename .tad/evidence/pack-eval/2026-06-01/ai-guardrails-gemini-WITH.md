## Guardrail Review: Customer Support AI Agent

### Rule-of-Two Audit
| Condition | Met? | Context |
| :--- | :---: | :--- |
| **(A) Untrustworthy Input** | **YES** | Processes free-form customer emails and parses third-party web links. |
| **(B) Sensitive Data Access** | **YES** | Full access to the Orders Database and customer PII (cards, addresses). |
| **(C) External State Change** | **YES** | Writes follow-up data to the DB and sends external emails to customers. |

**Verdict:** **VIOLATION.** The agent satisfies all three conditions of the Agentic Rule of Two. A single prompt injection (direct via email or indirect via web link) provides an attacker with direct SQL access and external email spoofing capabilities. A human-in-the-loop approval gate is **strictly required** before executing DB writes or sending emails.

### P0 — Blocking (exploitable now; block deployment)

- **[P0] Rule PI2 (Agentic Rule of Two): Agent possesses unconstrained agency.**
  → The agent reads untrusted web links (A) and executes DB writes / emails (B+C). An attacker can embed an invisible instruction in a linked website to make unauthorized DB modifications or send phishing emails. Fix: Insert a human-in-the-loop gate (Layer 3 of Tool-Call Gating) for all state-changing actions. Maps to OWASP LLM06 (Excessive Agency).
- **[P0] Rule OV1 & OV3 (Improper Output Handling): Generated SQL executed directly.**
  → The agent is generating SQL queries from untrusted input and executing them natively. Fix: Implement Three-Layer Tool-Call Gating. Parse the generated SQL with the `sqlglot` AST. Restrict the database user to read-only, and programmatically reject any AST containing `DELETE`, `DROP`, `UPDATE`, or `INSERT` before reaching the DB engine. Maps to OWASP LLM05 (Improper Output Handling).
- **[P0] Rule PII1 & PII3 (PII Leakage): Raw PII sent to external model.**
  → Sending unredacted names, addresses, and credit card numbers to an LLM is a compliance breach. Fix: Implement Microsoft Presidio. Run the `AnalyzerEngine` followed by the `AnonymizerEngine` using the **Encrypt** operator. Since the agent must email the customer back with context, use the `DeanonymizeEngine` to restore the true values securely on the outbound response. Optimize tuning for the F2 score (β=2) to minimize false negatives. Maps to OWASP LLM02 (Sensitive Information Disclosure).
- **[P0] Rule OV2 & OV4 (Output Validation): Trusting raw JSON output.**
  → Valid JSON ≠ safe content (e.g., `{"action": "sql", "query": "DROP TABLE orders"}`). Fix: Do not blindly parse JSON. Enforce a Strict `output_type` utilizing Pydantic AI's `BaseModel` with typed fields and explicit `field_validator` constraints. Reject on `ValidationError`. Maps to OWASP LLM05.
- **[P0] Rule PI1 (Indirect Prompt Injection): Unfiltered summarization of web links.**
  → External web links represent untrusted data and can carry indirect injections. Fix: Apply an inline validation gate such as Lakera Guard (sub-50ms latency) to scan the retrieved web chunk for malicious payloads before appending it to the model's context window. Maps to OWASP LLM01 (Prompt Injection).

### P1 — Required (fix before production)

- **[P1] Rule DA2 (Defense Architecture): Direct model-to-tool wiring.**
  → The system connects the LLM directly to external APIs (email, DB) without interception. Fix: Deploy an AI Gateway layer to intercept all traffic, manage token-based rate limiting (HTTP 429), and ensure PII redaction and policy filtering occur systematically before upstream/downstream transmission.
- **[P1] Rule PII5 (PII Performance): Inline heavy NER blocking latency.**
  → Presidio's transformer NER models will impact latency. Fix: Offload the NER extraction to a `RemoteRecognizer` running in an isolated GPU container so the main conversational loop remains fast.
- **[P1] Rule OV5 & OV6 (Output Failure Handling): Missing retry loop and refusal paths.**
  → The agent will hallucinate if forced to output strict SQL/JSON when an email is ambiguous. Fix: Use `pydantic-ai-guardrails` to implement a structured-feedback retry loop (capped `max_retries`) and define a `Union[OutputResponse, UnableToAssess]` so the model has a graceful refusal path.

### Layered Defense Coverage

| Layer | Status | Budget | Findings |
| :--- | :--- | :--- | :--- |
| 1. Input Validation | **MISSING** | 15–50ms | Missing Lakera Guard / PII Redaction for emails. |
| 2. Prompt Hardening | **MISSING** | <2ms | Needs structural delimiters for the web link content. |
| 3. Retrieval/Context Rail | **MISSING** | 10–30ms | Web pages are appended blindly without NeMo/Lakera screening. |
| 4. Output Filtering | **MISSING** | 100–400ms | Needs DeanonymizeEngine and Llama Guard / OpenAI Moderation. |
| 5. Tool-Call Gating | **MISSING** | 5–15ms | Needs Pydantic AI validation + `sqlglot` AST gating. |
| 6. Execution Sandbox | **MISSING** | Manual | Needs Human-in-the-Loop gating for DB writes / sending emails. |

### Tool Recommendation
1. **Microsoft Presidio**: Use `presidio-analyzer` + `presidio-anonymizer` with the `Encrypt` operator for PII round-tripping.
2. **Pydantic AI + sqlglot**: Use to enforce explicit JSON schema boundaries and gate SQL generation at the AST level (allowlist SELECT only).
3. **Lakera Guard**: Utilize inline (sub-50ms budget) to intercept indirect prompt injections originating from user-supplied web links.
