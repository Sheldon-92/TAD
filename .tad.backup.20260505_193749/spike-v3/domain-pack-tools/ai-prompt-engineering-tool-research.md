# AI Prompt Engineering — Tool Research

**Date**: 2026-04-02
**Tested**: 2 new tools (promptfoo, json-schema-validation)

---

## Tool Mapping by Capability

| Capability | Need | Tool | Registry Status |
|-----------|------|------|----------------|
| system_prompt_design | Search best practices | web_scraping (jina-reader) | ✅ Existing |
| system_prompt_design | Generate prompt doc | pdf_generation (typst) | ✅ Existing |
| few_shot_design | Search examples | web_scraping | ✅ Existing |
| few_shot_design | Generate example set doc | pdf_generation | ✅ Existing |
| prompt_testing | Run evaluations | **prompt_evaluation (promptfoo)** | 🆕 New |
| prompt_testing | Compare results | data_chart (matplotlib) | ✅ Existing |
| prompt_optimization | Diagnostic scan | null (conversation) | N/A |
| prompt_optimization | Before/after comparison | **prompt_evaluation (promptfoo)** | 🆕 New |
| output_format_control | Validate JSON schema | **json_schema_validation (python3)** | 🆕 New |
| output_format_control | Generate template doc | pdf_generation | ✅ Existing |
| context_management | Token counting | python3 (tiktoken/len) | ✅ Built-in |
| context_management | Visualization | data_chart (matplotlib) | ✅ Existing |
| prompt_versioning | Diff tracking | git (built-in) | ✅ Built-in |
| prompt_versioning | Regression testing | **prompt_evaluation (promptfoo)** | 🆕 New |

---

## New Tool 1: promptfoo (Prompt Evaluation CLI)

**Test Date**: 2026-04-02
**Test Result**: ✅ PASS

### What It Does
CLI tool for testing prompts against test cases with automated assertions. Used by OpenAI and Anthropic.

### Install & Verify
```bash
npx promptfoo --version  # 0.121.3 (auto-downloads)
```

### Test Performed
Created promptfooconfig.yaml with:
- 2 prompt variants (plain vs structured)
- 3 test cases (noodles, salmon, pizza)
- `contains` assertions

Result: 6 test cases executed, assertion mechanism verified (4 PASS, 2 expected FAIL with echo provider).

### Key Features for Domain Pack
- YAML-based config (prompts + providers + tests + assertions)
- Multiple assertion types: contains, icontains, llm-rubric, cost, latency, javascript
- Side-by-side comparison of prompt variants
- CI/CD integration via GitHub Actions
- Web UI for result review (`promptfoo view`)

---

## New Tool 2: JSON Schema Validation (python3)

**Test Date**: 2026-04-02
**Test Result**: ✅ PASS

### What It Does
Validates LLM JSON output against defined schemas. Uses built-in python3 (no extra install).

### Test Performed
Validated a dish recognition schema with required fields (dish_name, cuisine, ingredients).
- Valid input: correctly validated
- Invalid input: correctly caught missing field + type mismatch

### Key for Domain Pack
- Zero install (python3 built-in)
- Can validate any JSON output against any schema
- Catches missing fields, type mismatches, constraint violations

---

## Tools NOT Selected (and Why)

| Tool | Reason Not Selected |
|------|-------------------|
| LangSmith | Cloud-only, requires LangChain ecosystem, not CLI-first |
| PromptLayer | SaaS platform, requires account + API key |
| Langfuse | Self-hosted or cloud, overkill for single-developer use |
| deepeval | Good but promptfoo has better CLI workflow and wider adoption |
