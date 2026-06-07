# Podcast Quality Rubric (ai-podcast-production)

> Weighted 6-dimension rubric derived from the "85-to-95 Point Gap" cross-cutting rule.
> Used by Gate 3 Deliverable Branch when task_type=deliverable and pack=ai-podcast-production.
>
> **Dimension lineage**: The source material (SS12 script-writing.md) defines an 8-dimension
> 100-point scale. This rubric consolidates to 6 dimensions: "Source Quotation" and "Author
> Context" are merged into Dimension 1 (Original Text Quotation — quoting without attribution
> context is incomplete); "Structural Architecture" is assessed structurally during outline
> review (pre-script), not during script quality scoring. "Thematic Courage" maps to
> Dimension 5 (Non-Resolution Thesis). "Oral Naturalness" is retained as Dimension 6 because
> it is the most podcast-specific quality (distinguishes scripts from written essays).

## Scoring Guide

Each dimension scored 0.0–1.0:
- **1.0**: Exemplary — meets the "95-point" standard with concrete evidence
- **0.5**: Adequate — present but generic or lacking specificity
- **0.0**: Missing or fundamentally wrong

## Dimensions

| # | Dimension | Weight | 0.0 (Missing) | 0.5 (Adequate) | 1.0 (Exemplary) |
|---|-----------|--------|---------------|-----------------|------------------|
| 1 | Original Text Quotation | 0.17 | Paraphrases only, no direct quotes | Some quotes but without translator attribution | Direct quotes with translator name, page/chapter ref |
| 2 | Technique Analysis | 0.17 | Plot summary only | Identifies technique but doesn't explain WHY it works | Names technique + explains mechanism + compares to alternatives |
| 3 | Personal Memory Specificity | 0.17 | Generic reflection ("this moved me") | Personal anecdote but could apply to anyone | Specific sensory detail (time, place, smell, sound) unique to speaker |
| 4 | Factual Precision | 0.17 | Unchecked claims, dates/names wrong | Facts present but not adversarially verified | All claims independently verifiable; dates, names, editions match authoritative sources; corrections from any review process documented |
| 5 | Non-Resolution Thesis | 0.17 | Picks a winner ("A is better than B") | Acknowledges tension but resolves it neatly | Holds contradictions in tension, refuses tidy resolution |
| 6 | Oral Naturalness | 0.15 | Reads like a written essay; no spoken-language markers | Some conversational phrasing but rhythm is uneven; breath-pause placement missing | Sentence length varies for vocal rhythm; breath pauses marked; contractions and spoken idioms used naturally; sounds like speech, not prose |

## Pass Criteria

- **PASS**: weighted_score >= 0.75
- **PARTIAL**: weighted_score >= 0.60
- **FAIL**: weighted_score < 0.60

## Notes

- **Factual verification method**: Codex review or equivalent adversarial fact-checking is the
  recommended verification process, but the rubric scores the OUTCOME (verifiability and
  accuracy of claims), not whether a specific tool was used.
- **Weight distribution**: Dimensions 1–5 carry equal weight (0.17 each = 0.85). Oral
  Naturalness carries 0.15, reflecting that it is essential for podcast quality but slightly
  less discriminating than content-depth dimensions at the script-draft stage (final oral
  quality also depends on TTS/voice performance parameters outside the script).
