[P0] “OpenAI Moderation is an 8-category closed classifier”
Why wrong: current OpenAI `omni-moderation-latest` returns more than 8 categories, including `illicit`, `illicit/violent`, and `self-harm/instructions`, and supports image inputs for some categories. Source: https://developers.openai.com/api/docs/guides/moderation  
Fix: replace “8 fixed categories” with the current category list, or say “closed, provider-defined taxonomy; verify current categories against OpenAI docs.”

[P0] `vuln_agent = Agent('openai:gpt-4o', result_type=CriticalVulnerability)`
Why wrong: current Pydantic AI docs use `output_type`, not `result_type`; examples written with `result_type` are stale and may fail on current versions. Source: https://pydantic.dev/docs/ai/core-concepts/output/  
Fix: `vuln_agent = Agent('openai:gpt-5-mini', output_type=CriticalVulnerability)` and update the Union example similarly.

[P0] `from rebuff import Rebuff` / `rb = Rebuff(api_token="REBUFF_API_KEY")`
Why wrong: Rebuff’s published Python package documents `from rebuff import RebuffSdk` and a constructor requiring OpenAI/Pinecone parameters; this snippet will not match the documented API. Source: https://pypi.org/project/rebuff/  
Fix: use the documented `RebuffSdk(...)` example or remove the runnable snippet and describe Rebuff conceptually.

[P0] “Encrypt + DeanonymizerEngine”
Why wrong: Presidio’s importable class is `DeanonymizeEngine`, not `DeanonymizerEngine`; code using this name would error. Source: https://microsoft.github.io/presidio/anonymizer/  
Fix: rename to `DeanonymizeEngine` everywhere code/API names are meant.

[P0] “Hash | Deterministic SHA-256 / SHA-512 of the value”
Why wrong: Presidio hash uses random salt by default since 2.2.361, so the same value will not hash consistently unless a stable salt is supplied. Source: https://microsoft.github.io/presidio/anonymizer/  
Fix: “Hash: salted SHA-256/SHA-512; provide and securely manage a consistent salt when referential integrity is required.”

[P1] “F2 score (β=2), weighting recall twice as heavily as precision”
Why wrong: in the F-beta formula, β=2 weights recall four times as much as precision, not twice.  
Fix: say “β=2 weights recall 4x in the squared term” or avoid the informal weighting claim.

[P1] “a false negative is a compliance breach”
Why wrong: this is overbroad. A missed PII entity can create compliance risk, but whether it is a breach depends on data type, jurisdiction, contractual controls, model provider terms, consent, and downstream exposure.  
Fix: “a false negative can create regulatory or contractual exposure; tune toward recall for high-risk PII.”

[P1] “Llama Guard's 13+ customizable categories and lower FPR (0.016 response-classification) catch what it misses”
Why wrong: the 0.016 FPR figure is from Llama Guard 3 Vision response classification on Meta’s/internal benchmark, not a head-to-head proof against OpenAI Moderation. Lower FPR also does not imply higher recall on the user’s policy.  
Fix: present the number as benchmark-specific and require local evals for FPR/recall before tool choice.

[P1] “response-stage classification can ignore direct image-based prompt injections”
Why wrong: dangerous for agent pipelines. If an image prompt injection causes a tool call, data exfiltration, or state change before final text is produced, output moderation is too late.  
Fix: “response classification complements input and tool-call gating; multimodal inputs still require pre-action screening.”

[P1] “Any OWASP risk with zero covering controls is a P0 gap.”
Why wrong: not every OWASP LLM risk is in scope for every system. A non-agentic offline summarizer may not need the same LLM06 controls as an autonomous tool-using agent.  
Fix: severity should depend on threat model, exposed capability, data sensitivity, and deployment context.

[P1] “All three are mandatory for autonomous tool execution.”
Why wrong: requiring human approval for every autonomous tool call is too blunt. Low-risk read-only calls can be governed by schemas, allowlists, auth scopes, rate limits, and audit logs without human review.  
Fix: make HITL mandatory only for high-impact state changes, privileged operations, irreversible writes, money movement, external sends, or sensitive-data disclosure.

[P1] “parse SQL with sqlglot AST → allow read-only SELECT only”
Why wrong: “SELECT only” is not sufficient across SQL dialects; SELECT can invoke unsafe functions, access sensitive tables, create side effects in some environments, or exfiltrate via extensions.  
Fix: add DB-level read-only credentials, table/column allowlists, function deny/allowlists, row limits, timeouts, and dialect-specific policy checks.

[P1] “Applications must NEVER connect a language model directly to external APIs or tools. Deploy an AI Gateway layer…”
Why wrong: “AI Gateway” is treated as mandatory architecture, but equivalent controls can be enforced in-process by the orchestrator/tool broker. A gateway also does not by itself validate semantic tool intent.  
Fix: require an intercepting policy enforcement point, which may be an AI gateway, tool broker, middleware, or orchestrator guard.

[P1] “Decode candidate encodings, then run detection”
Why wrong: missing operational caveats. Recursive decoding can create false positives, resource abuse, or ambiguous transformations; blindly decoding every candidate string is not a safe algorithm.  
Fix: bound decode depth/size/time, decode only high-confidence candidates, preserve raw and normalized forms, and log which canonicalization path triggered blocking.

[P1] “The model decodes Base64/ROT13/homoglyphs during inference and executes the payload”
Why wrong: overclaims model behavior. Some models decode some encodings; homoglyph handling and “execution” are inconsistent and context-dependent.  
Fix: “models may decode or infer obfuscated instructions often enough that raw-string filters are not a sufficient control.”

[P2] “determinismLevel: deterministic” on tool/model selection and latency-budget rules
Why wrong: these are policy and architecture heuristics, not deterministic checks. Tool choice depends on traffic shape, thresholds, language mix, deployment region, and acceptable false positives.  
Fix: mark as “semi-deterministic” and require local calibration.

VERDICT: FIX-FIRST
