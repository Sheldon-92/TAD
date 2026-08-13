# Zero-Hallucination Rules — Citation Integrity Protocol

> Extracted from ScienceClaw SCIENCE.md lines 51-67. This is the HIGHEST PRIORITY rule — absolute, non-negotiable. Every other rule in this pack is subordinate to this one.

---

## The Core Rule

**ALL citations must come from tool results in the CURRENT conversation.**

If a tool did not return it, you cannot cite it. No exceptions.

> Source: SCIENCE.md line 55

---

## What Must NEVER Be Fabricated

These items must ONLY come from tool results — never from training data:

| Item | Why It's Dangerous |
|------|-------------------|
| Paper titles | Plausible-sounding titles for non-existent papers are undetectable by users |
| Author names | LLMs generate realistic author lists that cannot be verified without tools |
| DOIs | Fabricated DOIs (10.xxxx/xxxxx patterns) look valid but resolve to nothing |
| PMIDs | Numeric IDs that appear real but reference no actual paper |
| Journal names | Training data contains journal names that get recombined incorrectly |
| Publication years | Off-by-one or completely wrong years undermine temporal analysis |
| Impact factors | Numeric values that sound authoritative but are invented |
| Citation counts | Estimates from training data diverge from actual counts by 50-500% |

> Source: SCIENCE.md lines 56-58

---

## The 4-Point Self-Check

Before EVERY response containing citations, verify ALL four points:

1. **Does every paper title come from a tool result in this conversation?** If no → remove it.
2. **Does every DOI/PMID come from a tool result?** If no → remove it.
3. **Does every author list come from a tool result?** If no → remove it.
4. **Does every citation count come from a tool result?** If no → remove it.

> Source: SCIENCE.md "Self-check before every response containing citations" lines 63-67

---

## Empty-Result Handling

When a search returns no results:

1. **Say so explicitly**: "Semantic Scholar returned no results for this query."
2. **Do NOT fall back to training data.** Report the empty result and suggest alternative search terms.
3. **When you cannot verify a claim through tools**, say: "I cannot verify this through my tools" — do not state it as fact.

> Source: SCIENCE.md lines 59-61

---

## Partial Metadata Handling

When a tool returns **partial metadata** (e.g., title but no DOI):

- Report ONLY what the tool returned
- Do NOT "fill in" missing fields from training knowledge
- Mark missing fields explicitly: "DOI: not available in API response"

> Source: SCIENCE.md line 59: "NEVER substitute or 'fill in' details from training knowledge"

---

## The Training Data Prohibition

This is the most subtle and most violated rule:

**If asked about a topic and your search tools return nothing, do NOT fall back to training data.**

The correct response is:
- Report the empty result
- Suggest alternative search terms
- Try an alternative database (see fallback-chains.md)
- If all databases return nothing: state that explicitly

The WRONG response is:
- "Based on my knowledge, the key papers in this area are..."
- Presenting a list of papers that "should exist" in the field
- Citing papers you "remember" from training

> Source: SCIENCE.md lines 60-61

---

## Integration with TAD Workflow

### In Handoff ACs
Alex should include an AC: "Every citation in the report traces to a tool result. Verification: grep for DOIs/PMIDs and cross-check each against the tool call log."

### In Gate 3
Blake's spec-compliance reviewer checks citation integrity as part of AC verification.

### In Gate 4
Alex verifies a random sample of 3-5 citations from the report against the conversation's tool call history.

---

## Common Violation Patterns

| Pattern | Why It Happens | How to Catch |
|---------|---------------|-------------|
| "Seminal paper by Smith et al. (2019)" without tool call | Agent synthesizes from training data | Check: was there a search API call returning this paper? |
| "Impact factor: 42.7" without source | Agent recalls approximate IF from training | Check: did any tool return impact factor data? |
| "Cited by 1,234 papers" without API response | Agent estimates from training data | Check: does the citation count match an API field? |
| Presenting 10+ papers from a single search that returned 5 | Agent supplements real results with training data | Count: do the papers exceed the API's `limit` parameter? |
| DOI that starts with correct prefix but wrong suffix | Agent fabricates plausible-looking DOI | Verify: does the DOI resolve via doi.org? |
