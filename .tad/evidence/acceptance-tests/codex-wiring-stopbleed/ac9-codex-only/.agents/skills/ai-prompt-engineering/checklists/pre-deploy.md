# Pre-Deployment Checklist

> Run before deploying any prompt to production.
> All items must be checked. Unchecked items = do not deploy.

---

## Format and Syntax

- [ ] **Tool syntax valid**: All CLI commands in the prompt are syntactically correct (verified by running a test call)
- [ ] **Output schema complete**: Schema covers all edge cases — null values, empty arrays, optional fields
- [ ] **Format compliance ≥95%**: Verified against test suite with ≥18 test cases

## Constraint Quality

- [ ] **Critical weight correct**: Most important constraint is in the first 30% of the system prompt
- [ ] **Signal strength clear**: Constraints use direct language, not hedged language ("never" not "try to avoid")
- [ ] **Constraint count ≤10**: Fewer than 10 MUST/NEVER constraints (additional constraints compete and reduce effectiveness)
- [ ] **No conflicting constraints**: No two constraints that can both apply and contradict each other

## Grounding and Accuracy

- [ ] **Fabrication audit passed**: No facts stated without source, grounding reference, or explicit caveat
- [ ] **Role anchored**: Role definition has domain + value anchoring, not generic "helpful assistant"
- [ ] **Hallucination constraints present** (if RAG): Explicit "only state what's in the context" instruction + capability declaration

## Token Efficiency

- [ ] **Token efficiency verified**: No redundant instructions (search for duplicated ideas with different wording)
- [ ] **Token budget checked**: System prompt token count is within budget (≤40% of context window)
- [ ] **Cache architecture set**: Stable prefix correctly identified; `cache_control` breakpoint placed if using Claude prompt caching

## Test Coverage

- [ ] **First-pass success test**: A capable model would succeed on the first try without clarification
- [ ] **Golden dataset regression passed**: All ≥18 test cases passing in promptfoo (100% pass rate)
- [ ] **Adversarial cases pass**: At minimum A-01 (injection), A-02 (jailbreak), A-03 (extraction) from starter template

## Versioning and Documentation

- [ ] **Model version pinned**: Using exact version ID (e.g., `claude-sonnet-4-6`) not alias
- [ ] **CHANGELOG entry written**: Version entry with: what changed + why + test results link
- [ ] **Test results committed**: promptfoo results JSON committed to repo alongside the prompt
- [ ] **Schema documented**: Output schema documented in README or alongside the prompt file

## Security (for user-facing or multi-agent prompts)

- [ ] **Delimiter isolation in place**: User-provided content wrapped in distinct XML tags
- [ ] **Reasoning scaffold present**: Model verifies scope before responding (for injection-sensitive tasks)
- [ ] **Red team passed**: If security-critical, promptfoo red team scan completed (Tier 3)
