# Dogfood Judgment — ai-prompt-engineering pack

**Task**: "My RAG system prompt started hallucinating facts and drifting from its JSON output format right after we upgraded the model. Help me fix it."

**Judged**: 2026-06-13. Independent merit judging; one answer used the `ai-prompt-engineering` skill, one did not (not disclosed to judge a priori). Verified key specifics via WebSearch against current Anthropic/OpenAI primary docs.

---

## Which used the skill

Answer 1 used the pack (explicitly cites SKILL.md, failure-catalog FM-1/2/3/6, claude.md Rules 2/3/4, output-format.md, prompt-lint.sh). Answer 2 answered from general knowledge.

## WebSearch verification of load-bearing specifics

### Answer 1 (all VERIFIED TRUE)
- temperature/top_p/top_k return **HTTP 400 on Opus 4.7+** — CONFIRMED (migration guide, May 19 2026). Anthropic recommends steering via prompting/effort. ✓
- Prefill (last-assistant-turn) **removed → 400** on Opus 4.8 / Fable 5 — CONFIRMED. ✓
- `thinking:{type:enabled,budget_tokens:N}` **removed → 400**; adaptive thinking + `effort` — CONFIRMED. (Minor nuance: docs say effort is an *output-level* control, NOT literally a thinking-budget replacement; Answer 1's framing is slightly loose but the pack's own claude.md acknowledges this.) ✓
- Model id `claude-opus-4-8`, GA 2026-05-28, **1M context / 128K output** — CONFIRMED. ✓
- Structured outputs via `output_config.format` json_schema, `additionalProperties:false`, `messages.parse()` — CONFIRMED (supported Opus 4.8/Sonnet 4.6/Haiku 4.5/Fable 5 + legacy 4.5/4.1). ✓
- `xhigh` effort added in 4.7 — CONFIRMED. ✓
- **Structured outputs incompatible with citations → 400** (Phase 3.4 tradeoff) — CONFIRMED as a documented 400-level incompatibility (citations interleave blocks; incompatible with strict schema). This is a genuinely hard-to-know specific the user would hit if their RAG uses Anthropic citations. ✓
- MUST/CRITICAL over-triggering on Claude 4.6+ — matches migration-guide prompt-behavior table. ✓

**No wrong specifics found in Answer 1.**

### Answer 2 (general claims sound; OpenAI specific correct)
- OpenAI `response_format:{type:"json_schema", strict:true}` → 100% schema reliability — CONFIRMED. ✓
- Claude tool-use/function-calling for guaranteed schema — valid general approach. ✓
- Delimiters, citation-requirement-suppresses-fabrication, parse-and-repair, regression set, CI gate, one-change-at-a-time — all sound, none wrong.
- **Liability**: recommends "Lower temperature (0–0.2)" and "Re-pin temperature (low)" as a fix. On the user's *actual* model (Opus 4.7/4.8) this **returns a 400** — temperature is removed. Answer 2 explicitly hedges ("I answered from general principles… confirm the specific model's structured-output API and migration notes"), so it is a CONDITIONAL general statement, not a confident wrong specific — but it is the one piece of advice that would actively fail on the real model, and the answer never lands the actual fix.

## Wrong-claims ledger
- (Answer 2, soft) "Lower/re-pin temperature 0–0.2" — would 400 on Opus 4.7/4.8 (temperature removed). Mitigated by explicit provider/model hedge. Not a confident specific, so does not tank correctness, but it is a substantive miss vs. the real environment.
- (Answer 1, minor framing) effort described as the lever that replaces budget_tokens for "thinking depth"; docs note effort is output-level and budget_tokens has *no direct* thinking replacement. Pack text is slightly loose; net guidance (use adaptive + effort, stop using budget_tokens) is correct. Negligible.

## Scoring (1–5)

| Dimension | A1 | A2 |
|---|---|---|
| Correctness | 5 | 4 |
| Actionability | 5 | 4 |
| Specificity | 5 | 3 |
| Completeness | 5 | 4 |

## Winner: Answer 1 — DECISIVE

Answer 1 wins on **correct, verified, hard-to-know specifics directly tied to the upgrade trigger**, not on verbosity. It correctly identifies the actual mechanism the other answer misses: the upgrade didn't worsen the prompt — it *removed the crutches* (temperature=0 determinism, prefill `{` JSON-forcing) that were silently propping it up, and several old params now 400 (possibly via a silently-degraded fallback). That single diagnostic insight — backed by 8 independently-verified API facts including the citations-vs-structured-outputs 400 incompatibility that a RAG builder would actually trip on — is the difference between "here is a generic playbook" and "here is exactly what your upgrade broke and the current-API way to fix it."

Answer 2 is a competent, well-structured generic prompt-debugging playbook (separate the two failures, native structured output, grounding+citation, regression set + CI gate) and would meaningfully help. But it (a) never names the actual breaking changes, (b) gives one fix (lower temperature) that would 400 on the user's real model, and (c) repeatedly defers the concrete answer ("share the prompt and I'll…"). Honest, but it leaves the user without the resolution the skill-backed answer delivers.

Margin: decisive. The win is substantive (correct specifics + correct root-cause mechanism), not stylistic.
