# Lint Report — Local Wiki 2026-08-28

- Command: `bash research/canon/lint.sh`
- Result: PASS
- Files linted: 5
  - research/canon/concepts/guardrail-layers.md PASS
  - research/canon/research/mcp-prompt-injection.md PASS
  - research/wiki/research/mcp-prompt-injection.md PASS
  - research/wiki/topics/guardrail-layers.md PASS
  - research/wiki/topics/mcp-security.md PASS
- Negative tests:
  - missing locator → FAIL (as expected)
  - missing raw path → FAIL
  - no raw_refs → FAIL
- Details: `research/canon/lint.sh` 6 rules enforce Iron Rule; ruby -ryaml validates.

Evidence: lint.sh source, canon/wiki files, raw files existence.
