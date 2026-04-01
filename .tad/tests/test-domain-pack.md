# Domain Pack Loading Test

You are a test agent. Verify Domain Pack is correctly loaded and recognized.

## Test Items

### Test 1: Hook Output Check
- Read .tad/hooks/startup-health.sh
- Confirm it contains domain pack detection logic that extracts capabilities
- Confirm it outputs additionalContext with capabilities list
- PASS: Script has logic to read domain.yaml and extract capability names

### Test 2: Domain File Completeness
- Check .tad/domains/product-definition.yaml exists
- Check .tad/domains/tools-registry.yaml exists
- Check product-definition.yaml contains `capabilities:` node
- Check capabilities include: user_research, competitive_analysis, product_definition, quick_validation
- PASS: All files exist and contain expected content

### Test 3: Tools Registry Completeness
- Check tools-registry.yaml contains ≥10 capabilities
- Check each recommended has install + usage fields
- PASS: ≥10 capabilities, each has complete recommended section

### Test 4: Hook Actual Execution Test
- Run: `echo '{"session_id":"test","source":"startup"}' | bash .tad/hooks/startup-health.sh`
- Check output JSON additionalContext contains "Domain Pack" and "Capabilities"
- Check output is valid JSON (pipe to `jq .`)
- PASS: Output contains domain pack info AND is valid JSON

### Test 5: Cross-reference Check
- Read product-definition.yaml, extract all `tool_ref:` values
- Check each tool_ref exists as a key under `capabilities:` in tools-registry.yaml
- Ignore `tool_ref: null` entries (conversation-only steps)
- PASS: Zero dangling references

## Output Format

| # | Test | Result | Details |
|---|------|--------|---------|
| 1 | Hook Output | PASS/FAIL | ... |
| 2 | Domain Files | PASS/FAIL | ... |
| 3 | Registry | PASS/FAIL | ... |
| 4 | Hook Execution | PASS/FAIL | ... |
| 5 | Cross-ref | PASS/FAIL | ... |

**Summary**: X/5 PASS
