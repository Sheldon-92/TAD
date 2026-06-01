# Output Validation & Tool-Call Gating Rules
<!-- capability: output_validation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| OV1 | Improper Output Handling (LLM05) — never pass raw LLM output downstream without validation/encoding | deterministic |
| OV2 | Structured ≠ validated — valid JSON can carry `rm -rf /`; enforce typed constraints | deterministic |
| OV3 | Three-layer tool-call gating: Schema → AST/Allowlist → Human-in-the-Loop | deterministic |
| OV4 | Pydantic AI: typed BaseModel + field_validator; ValidationError blocks bad output | deterministic |
| OV5 | Structured-feedback retry loop (pydantic-ai-guardrails) — re-inject errors, cap max_retries | semi-deterministic |
| OV6 | Union types for graceful refusal — prevent hallucinated structured output | deterministic |

---

## Rules

### OV1: Improper Output Handling (OWASP LLM05) — "The New XSS"

LLM05 occurs when an application processes LLM output as trusted data without validation, sanitization, or encoding before passing it downstream. Result: XSS, SQL injection, path traversal, RCE, privilege escalation, dynamic email injection.

| Downstream Vuln | Mechanism | Mitigation |
|-----------------|-----------|------------|
| XSS | LLM JS / unescaped Markdown rendered in browser | Context-aware output encoding — use `.textContent`, not `.innerHTML` |
| SQL Injection | model SQL executed un-parameterized | SQL AST parsing, parameterized queries, read-only DB user |
| RCE | LLM code/commands passed to `eval()` / shell | restrict command generation, containerized sandbox, gVisor isolation |
| Path Traversal | output builds file paths unchecked | lock file ops to a sandboxed root directory, validate path vars |
| Dynamic Email Injection | unsanitized output into email templates | HTML/dynamic context escaping before template compilation |

**Rule**: Any place LLM output flows into a browser, DB, shell, file path, or email template without encoding/validation is a P0 LLM05 finding.

> Source: findings.md "Improper Output Handling (OWASP LLM05)" + downstream-exploit table [10, 11, 12, 13, 14, 15]

**determinismLevel**: deterministic.

### OV2: Structured ≠ Validated

A model can return technically valid JSON that contains dangerous instructions:

```json
{"action": "execute_command", "parameter": "rm -rf /"}
```

Relying on the model's native JSON capability does NOT verify the safety of the content. Validation must enforce strict typing, range limits, and value constraints before any downstream utility processes the payload.

**Rule**: "The model returns valid JSON" is not a security control. Enforce a schema with explicit type + range + value constraints. Reject on violation.

> Source: findings.md "Validated Schemas vs. Raw Structured Output" [13]

**determinismLevel**: deterministic.

### OV3: Three-Layer Tool-Call Gating

For agents that execute generated actions, gate every tool call through three layers in order:

```
Layer 1: Structural Schema Validation   → ValidationError?  → reject
   (JSON shape matches the Pydantic model: types, parameter formats)
Layer 2: Content Allowlist & AST Gating → policy violation? → reject
   (parse SQL with sqlglot AST → allow read-only SELECT only, reject DELETE/DROP;
    lock file ops to a sandboxed root; tool requests must match an allowed registry)
Layer 3: Human-in-the-Loop Confirmation → disapproved?      → abort
   (high-risk state-mutating / write actions are logged and require manual approval)
```

**Rule**: Schema validation alone is Layer 1 only. A schema-valid `DROP TABLE` still needs Layer 2 AST gating; a schema-valid + read-only-but-destructive-by-intent action still needs Layer 3 for state mutation. All three are mandatory for autonomous tool execution.

> Source: findings.md "Three-Layer Tool-Call Gating System" + diagram [1, 4, 13]

**determinismLevel**: deterministic.

### OV4: Pydantic AI Type Safety

Define output structures inheriting from `BaseModel` with Python type hints + constraints + `field_validator`. If the model violates a constraint, the layer raises `ValidationError`, preventing unvalidated data from propagating.

```python
from pydantic import BaseModel, Field, field_validator
from pydantic_ai import Agent

class CriticalVulnerability(BaseModel):
    cve_id: str = Field(description="CVE-YYYY-NNNNN format")
    cvss_score: float = Field(description="0.0 to 10.0")

    @field_validator('cvss_score')
    def validate_cvss(cls, v: float) -> float:
        if not (0.0 <= v <= 10.0):
            raise ValueError("CVSS score out of allowed bounds")
        return v

vuln_agent = Agent('openai:gpt-4o', result_type=CriticalVulnerability)
```

**Rule**: Constrain the agent's `result_type` to a validated schema with `field_validator` range checks — don't accept free-form output and validate later.

> Source: findings.md "Type Safety via Pydantic AI" + code [47, 48, 49]

**determinismLevel**: deterministic.

### OV5: Structured-Feedback Retry Loop

The `pydantic-ai-guardrails` package adds an automated loop: (1) detect type/constraint violation, (2) compile the specific errors into a structured context block, (3) re-inject that context as a new system message instructing correction, (4) re-evaluate — repeating up to a configured `max_retries` before raising.

**Rule**: On validation failure, re-inject the structured error and retry up to `max_retries` rather than failing hard or silently accepting. Always cap retries — an uncapped loop is a DoS surface.

> Source: findings.md "Retry Loops with Structured Feedback" [50]

**determinismLevel**: semi-deterministic — regeneration output varies.

### OV6: Union Types for Graceful Refusal

Forcing a model to emit complex structured data when it lacks context causes hallucinations. Use a Union output type to give a structured refusal path:

```python
from typing import Union
class UnableToAssess(BaseModel):
    justification: str = Field(description="why the context is insufficient")

Agent('openai:gpt-4', result_type=Union[list[CriticalVulnerability], UnableToAssess])
```

**Rule**: For high-stakes structured extraction, add a `Union[Result, UnableToAssess]` refusal class so the agent can decline instead of fabricating, while staying programmatically compatible.

> Source: findings.md "Union Types for Graceful Refusal" + code [49]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Trusting valid JSON**: `{"action":"execute_command","parameter":"rm -rf /"}` is valid JSON and lethal.
- **Schema-only gating**: a schema-valid `DROP TABLE` passes Layer 1; you still need AST (Layer 2) + human gate (Layer 3).
- **`.innerHTML` for LLM output**: stored XSS; use `.textContent` / context-aware encoding.
- **Un-parameterized model SQL**: parse with sqlglot AST and allow read-only SELECT only.
- **Uncapped retry loop**: re-injecting errors without `max_retries` is a DoS / cost surface.
- **Forcing structured output without a refusal Union**: drives hallucination when context is thin.
