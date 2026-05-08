# Output Format Control Reference

> Guidelines for defining, enforcing, and verifying structured output formats.
> Source: Anthropic structured output documentation + industry patterns, 2026.
> Load this file when task involves structured output (JSON/XML/CSV) — Phase 1.7.
> Also load during Phase 3 audits when format drift is suspected (FM-1).

---

## Format Type Selection Matrix

| Format | Use When | Avoid When |
|--------|----------|------------|
| **JSON** | API consumers, downstream processing, structured data | Human-facing text, conversational responses |
| **XML** | Legacy systems, document markup, hierarchical data | New greenfield systems (JSON is simpler) |
| **CSV** | Tabular data, bulk export, spreadsheet consumers | Nested data, varied row structures |
| **Markdown** | Documentation, human readers, rendering systems | API consumers parsing structure |
| **Plain text** | Human readers, single-value responses | Structured data, multi-field responses |

**Decision rule**: Choose the format that minimizes post-processing on the consumer side.
If the consumer is code, use JSON. If the consumer is a human, use Markdown or plain text.

---

## Schema Definition

Define the output schema before writing the prompt. A schema without edge cases is incomplete.

### JSON Schema Template

```json
{
  "type": "object",
  "properties": {
    "result": {
      "type": "string",
      "description": "The primary output value"
    },
    "confidence": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "description": "Confidence score between 0 and 1"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "source": {"type": "string"},
        "reasoning": {"type": "string"}
      },
      "required": ["source"]
    }
  },
  "required": ["result", "confidence"],
  "additionalProperties": false
}
```

### Edge Cases to Cover in Schema

Before finalizing the schema, answer each question:

| Edge Case | Schema Solution |
|-----------|----------------|
| Empty result (no data found) | Use `null` or a sentinel value like `""`, NOT omit the field |
| Multiple results | Use `"type": "array"` with `"minItems"` and `"maxItems"` |
| Unknown/unsure confidence | Include `"uncertain": true` flag OR `"confidence": null` convention |
| Optional fields | Use `required: []` — exclude from required array, document as optional |
| Nested objects | Define nested schemas explicitly; don't rely on "type: object" without properties |
| Enum values | Use `"enum": ["value1", "value2"]` — never leave categorical fields as free string |

---

## Output Format Instruction Patterns

### Pattern 1: Schema-first instruction

Place the schema definition before the output instruction:

```
Output format (JSON only, no preamble):
{
  "company": string,          // exact company name as stated
  "year_founded": number,     // 4-digit year, or null if not mentioned
  "ticker": string | null     // stock ticker if mentioned, null otherwise
}

Do not include any text outside the JSON object.
```

### Pattern 2: Example-grounded instruction

For complex formats, show an example:

```
Respond in this exact JSON format:
<example_output>
{"company": "Acme Corp", "year_founded": 1990, "ticker": "ACME"}
</example_output>

If a field is not present in the input, use null.
```

### Pattern 3: Constraint + schema

Combine format constraint with schema for maximum precision:

```
ONLY output a JSON object. No explanation. No markdown. No preamble.

Required schema:
- result: string (the extracted value)
- confidence: number 0.0–1.0
- uncertain: boolean (true if confidence < 0.5)
```

---

## Compliance Verification (≥95% Target)

Format compliance below 95% indicates a structural prompt issue, not a model quality issue.

### Measurement

Run format compliance check during Phase 2 testing:

```python
# promptfoo assertion for format compliance
assert:
  - type: is-json          # validates JSON parsing
  - type: javascript
    value: |
      const parsed = JSON.parse(output);
      // Check required fields
      const required = ['result', 'confidence'];
      const missing = required.filter(k => !(k in parsed));
      if (missing.length > 0) throw new Error('Missing fields: ' + missing.join(', '));
      // Check field types
      if (typeof parsed.confidence !== 'number') throw new Error('confidence must be number');
      if (parsed.confidence < 0 || parsed.confidence > 1) throw new Error('confidence out of range');
      return true;
```

### Compliance rate targets

| Compliance Rate | Status | Action |
|----------------|--------|--------|
| ≥99% | Excellent | No action |
| 95–99% | Good | Monitor; investigate failures |
| 90–95% | Marginal | Review format instructions; check edge cases |
| <90% | Failing | Immediate fix required (see diagnosis below) |

### Diagnosing low compliance

**Symptom: JSON parse failures**
→ Model is adding prose before/after JSON
→ Fix: Add "No text outside the JSON object" instruction; front-load format constraint

**Symptom: Missing required fields**
→ Model omits fields when the answer is unknown
→ Fix: Explicitly specify null/default value for each "unknown" case in the schema

**Symptom: Wrong field types**
→ Model returns string "0.95" instead of number 0.95
→ Fix: Add type annotation in format instruction: `"confidence": number (not string)`

**Symptom: Extra fields**
→ Model adds fields not in schema
→ Fix: Add `"additionalProperties": false` to JSON schema; or "Do not add fields not listed above"

---

## Format Lock Technique

For high-stakes format compliance, use format lock — a pattern that traps format violations:

```
Your response MUST be a JSON object. I will run `JSON.parse(response)` on your output.
If parsing fails, the entire downstream pipeline fails. No preamble. No explanation.
Output starts with `{` and ends with `}`.
```

**When to use**: When downstream parsing is automated and there is zero tolerance for
format failures (API responses, data pipelines, CI/CD evaluators).

**When NOT to use**: When the model might legitimately need to express uncertainty or
refusal — format lock can cause the model to fabricate valid JSON rather than refusing.
For tasks with refusal scenarios, handle the refusal case in the schema:
```json
{"result": null, "refused": true, "reason": "inappropriate content"}
```

---

## Verification Checklist (Pre-Deployment)

Run before shipping a prompt with structured output:

- [ ] Schema covers all edge cases (null, empty, multiple, unknown)
- [ ] Format instruction is in the first 30% of the system prompt
- [ ] Compliance rate ≥95% on test suite
- [ ] Assertion in promptfooconfig.yaml validates field types, not just structure
- [ ] Refusal scenario handled in schema (if applicable)
- [ ] Edge case for empty input produces valid output (not parse failure)
- [ ] Schema documented in the repository alongside the prompt
