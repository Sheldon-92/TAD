# Optimization Program (Autoresearch Mode)

> Strategy guide for Blake's Layer 0.5 optimization loop.
> Read this before starting the optimization loop.

## Approach

### General Strategy
1. **Start with quick wins** — look for obvious inefficiencies first
2. **One change per iteration** — isolate variables for clear cause-effect
3. **Read previous results** — don't repeat failed approaches
4. **Respect constraints** — never violate optimization_target.constraints
5. **Document reasoning** — commit messages should explain WHY, not just WHAT

### When Stuck (3+ consecutive failures)
- Try a completely different approach (don't keep tweaking the same thing)
- Re-read the scope files from scratch — fresh eyes find new opportunities
- Consider algorithmic changes instead of parameter tuning
- If truly stuck after 5 failures, the circuit breaker will exit — this is OK

### Common Optimization Patterns
- **Performance**: Caching, batch processing, lazy loading, algorithm complexity reduction
- **Accuracy**: Better matching algorithms, threshold tuning, edge case handling
- **Bundle size**: Tree shaking, dynamic imports, dependency replacement
- **Memory**: Object pooling, stream processing, reference cleanup

## Constraints
- Only modify files listed in `optimization_target.scope`
- All changes must pass build (if build fails, that's a failed experiment — revert)
- Do not add new dependencies unless explicitly allowed
- Do not change public API interfaces unless explicitly allowed

## Output
After each iteration, log to results.tsv:
`{iteration}\t{commit_hash}\t{metric_value}\t{status}\t{description}\t{timestamp}`
