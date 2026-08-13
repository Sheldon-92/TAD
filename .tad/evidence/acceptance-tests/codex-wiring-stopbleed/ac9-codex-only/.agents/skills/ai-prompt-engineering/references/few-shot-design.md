# Few-Shot Example Design Reference

> Guidelines for designing high-quality few-shot examples that improve model performance.
> Source: Anthropic prompt engineering documentation + few-shot learning research, 2026.
> Load this file when task involves examples or demonstrations (Phase 1.7).

---

## 5-Question Quality Assessment

Before adding any few-shot example, answer all 5 questions. A "No" to any question
means the example needs revision before inclusion.

**Q1: Is this example representative of production inputs?**
- Does it reflect real user phrasing, not idealized phrasing?
- Could you find a similar input in your production logs?
- "No" → Replace with a real example from logs

**Q2: Does this example demonstrate the correct reasoning process?**
- For reasoning-native models (Claude 4.x): include `<thinking>` blocks showing the reasoning
- The model learns reasoning patterns from examples, not from instructions
- "No" → Add explicit reasoning trace

**Q3: Is the expected output achievable by a capable model?**
- Is the output complete (not truncated at an artificial limit)?
- Is the output format exactly what you expect in production?
- "No" → Fix the example output

**Q4: Does this example add diversity to the set?**
- Is this example sufficiently different from others already in the set?
- Does it cover a different output category or edge case?
- "No" → Replace with a more diverse example

**Q5: Would a new engineer understand this example without context?**
- Is the input–output pair self-explanatory?
- Does the `<thinking>` block explain the non-obvious reasoning steps?
- "No" → Add clarifying comments or rework

---

## Selection Strategy

### Quality over quantity

Research finding: 3 high-quality examples outperform 10 mediocre examples.
Apply the 5-question assessment rigorously; don't pad.

### Coverage categories

Include examples from each output category, not just the majority class:
```
If your task produces 5 output types:
  → Include ≥1 example per type
  → Even if type E is rare (2% of production traffic), include it
  → Models learn output boundaries from examples, not just from instructions
```

### Gradient rule (for classification tasks)

Include boundary examples — inputs that are close to classification thresholds:
```
Easy positive: clearly in category
Hard positive: barely in category (near boundary)
Hard negative: barely not in category (near boundary)
Easy negative: clearly not in category

Hard cases teach the model where the boundaries are.
```

### Example count by task type

| Task Type | Minimum Examples | Notes |
|-----------|-----------------|-------|
| Simple extraction | 3 | 1 easy + 1 edge + 1 negative |
| Classification (binary) | 4 | 2 per class, with hard cases |
| Classification (multi-class) | N+2 | ≥1 per class, 2 extra for edge cases |
| Generation (open-ended) | 5 | Diversity is critical |
| Multi-step reasoning | 3 | Each with full `<thinking>` trace |

---

## Reasoning Trace Format (Claude 4.x)

Claude 4.x learns reasoning patterns from `<thinking>` blocks in examples.
For tasks requiring multi-step reasoning, include explicit reasoning traces.

**Template**:
```
<example>
<input>
[The task input here]
</input>
<thinking>
[Step-by-step reasoning — not a summary, but the actual thought process]
[Include: what information I noticed, what I rejected and why, what I decided and why]
</thinking>
<output>
[The final output — must be what you'd want in production]
</output>
</example>
```

**Anti-pattern** (don't do this):
```
<thinking>
I need to extract the company name and year. I'll look for those.
</thinking>
```

**Good pattern**:
```
<thinking>
Looking at "Acme Corp (founded 1990, ticker ACME)":
- Company name: "Acme Corp" — ignoring the ticker since it's a symbol not a name
- Year: 1990 — this is the founding year, not a financial year
- Ticker: "ACME" — explicit label "(ticker)" makes this unambiguous
Output: {"company": "Acme Corp", "year": 1990, "ticker": "ACME"}
</thinking>
```

---

## Token Budget Rules

Few-shot examples compete with the task context for attention. Budget carefully:

**Hard limit**: Examples must not exceed 40% of the available context window.

**Token estimation** (rough):
- 1 token ≈ 4 characters (English)
- Short example (extraction): ~100–300 tokens
- Medium example (with reasoning): ~300–700 tokens
- Long example (complex generation): ~700–1500 tokens

**Optimization checklist**:
- [ ] Remove examples that overlap in coverage
- [ ] Trim reasoning traces to essential steps (remove redundant observations)
- [ ] Use the smallest examples that demonstrate the behavior
- [ ] If over budget: reduce diversity set before reducing quality

**When to use dynamic few-shot selection**:
If your example pool is large (>20 examples), use embedding similarity to select
the most relevant examples for each input at inference time. This maximizes relevance
while staying within token budget.

```python
# Example: dynamic few-shot selection
from anthropic import Anthropic

def select_examples(user_input: str, example_pool: list, n: int = 3) -> list:
    """Select top-n examples most similar to user_input."""
    # Use embedding similarity to rank examples
    # Implementation depends on your embedding provider
    similarities = [(embed_similarity(user_input, ex['input']), ex) for ex in example_pool]
    return [ex for _, ex in sorted(similarities, reverse=True)[:n]]
```

---

## Diversity and Gradient Rules

**Diversity checklist** (for the complete example set):
- [ ] Different sentence structures (question, statement, imperative)
- [ ] Different input lengths (short, medium, long)
- [ ] Different domains (if task is domain-agnostic)
- [ ] Different output categories (see coverage categories above)
- [ ] At least 2 boundary/hard cases per category

**Gradient rule example** (sentiment classification):

```yaml
# Easy positive
- input: "This product is fantastic! I love it."
  output: {"sentiment": "positive", "confidence": 0.99}

# Hard positive (ambiguous positive)
- input: "It's okay I guess. Does what it says."
  output: {"sentiment": "positive", "confidence": 0.52}

# Hard negative (ambiguous negative)  
- input: "Not the worst I've seen."
  output: {"sentiment": "negative", "confidence": 0.55}

# Easy negative
- input: "Terrible experience. Complete waste of money."
  output: {"sentiment": "negative", "confidence": 0.98}
```

The hard cases teach the model where the decision boundary is — without these,
the model will have high accuracy on easy cases but fail on production edge cases.
