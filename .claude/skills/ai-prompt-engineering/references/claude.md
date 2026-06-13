# Claude Prompt Engineering Rules (current API)

> Source: Anthropic `claude-api` skill (in-context `shared/model-migration.md` + `shared/models.md`),
> platform.claude.com/docs/en/about-claude/models/migration-guide.md — retrieved 2026-06-13.
> Model-agnostic rules live in SKILL.md. ⚠️ This file was corrected 2026-06-13 — the prior
> version taught `thinking: {type:"enabled", budget_tokens: N}`, which is REMOVED on Opus 4.7+
> and returns HTTP 400. See the "Old patterns (do NOT use)" section at the bottom.

---

## Contents

- Model-pinning table (exact IDs)
- Rule 1: Adaptive thinking replaces manual CoT (`budget_tokens` REMOVED on 4.7+)
- Rule 2: Prefill REMOVED — use structured outputs (`output_config.format`)
- Rule 3: 4.7+ follows instructions literally — scope explicitly
- Rule 4: Avoid "MUST USE" aggressive language on 4.6+
- Rule 5: Provide requirements upfront (one well-specified turn)
- Rule 6: Prompt caching architecture (prefix match, min cacheable prefix)
- Rule 7: Opus 4.8 under-reaches for tools — triggering instruction + effort, NOT `budget_tokens`
- Rule 8 (Fable 5): always-on thinking, new tokenizer, `refusal` handling
- Old patterns (do NOT use) — corrected 2026-06-13

---

## Model-pinning table (use exact IDs — never aliases, never date suffixes)

| Model ID | Context | Max output | Thinking API | `budget_tokens`? | Notes |
|----------|---------|-----------|--------------|------------------|-------|
| `claude-opus-4-8` | 1M | 128K | adaptive only | **REMOVED (400)** | Current default Opus. Under-reaches for tools by default. |
| `claude-opus-4-7` | 1M | 128K | adaptive only | **REMOVED (400)** | Added `xhigh` effort; high-res vision (2576px). |
| `claude-opus-4-6` | 1M | 128K | adaptive (rec.) | deprecated, still works | Transitional escape hatch only. |
| `claude-sonnet-4-6` | 1M | 64K | adaptive (rec.) | deprecated, still works | Best speed/intelligence balance. |
| `claude-haiku-4-5` | 200K | 64K | adaptive | n/a (effort errors) | Fastest/cheapest. No `max`/`effort`. |
| `claude-fable-5` | 1M | 128K | always-on | **REMOVED (400)** | New tokenizer (~30% more tokens). `{type:"disabled"}` also 400s — omit `thinking`. Needs 30-day retention. |

**Pin the exact ID, not an alias.** `claude-sonnet` points at different weights over time → silent
regression (FM-3). Do NOT append date suffixes to aliases (`claude-opus-4-8`, never `...-20251114`).

---

### Rule 1: Adaptive Thinking Replaces Manual CoT — `budget_tokens` is REMOVED on Opus 4.7+

**What changed**: Manual extended thinking (`thinking: {type:"enabled", budget_tokens: N}`) is
**removed on Opus 4.7, Opus 4.8, and Fable 5** and returns **HTTP 400**. It is only
*deprecated-but-functional* on Opus 4.6 / Sonnet 4.6. The current API is **adaptive thinking**:
the model decides when and how much to think; depth is controlled by the `effort` parameter, not a
token budget.

**Current API** (Opus 4.6 / 4.7 / 4.8, Sonnet 4.6):
```python
response = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=16000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},  # low | medium | high | xhigh | max
    messages=[{"role": "user", "content": user_message}],
)
```

**effort levels** (inside `output_config`, GA — no beta header):
- `xhigh` — best for coding/agentic work (added on Opus 4.7; default in Claude Code). Use `high`+ for intelligence-sensitive work.
- `max` — Opus-tier only (Opus 4.6+, Sonnet 4.6); errors on Sonnet 4.5 / Haiku 4.5. Use when correctness > cost.
- `low`/`medium` — latency- or cost-sensitive routine work.
- Default is `high` (equivalent to omitting it).

**In your prompt**: Do NOT write "Think step by step" — adaptive thinking handles internal reasoning.
Keep CoT reasoning traces only in few-shot `<thinking>` examples (Claude learns the pattern).

**Note**: adaptive thinking is **off by default when `thinking` is omitted** on Opus 4.7/4.8 — set
`thinking: {type:"adaptive"}` explicitly to enable it.

---

### Rule 2: Prefill is REMOVED on the 4.6/4.7/4.8 family + Fable 5 — Use Structured Outputs

**What changed**: Last-assistant-turn prefilling (`messages` ending with `{"role":"assistant",...}`)
returns **HTTP 400** on Opus 4.6, 4.7, 4.8, Sonnet 4.6, and Fable 5 — **regardless of thinking
mode**. The old "prefill `{` to force JSON" trick no longer works. Use `output_config.format`
(structured outputs) instead.

**Current API — structured outputs (replaces prefill)**:
```python
response = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=1024,
    output_config={"format": {"type": "json_schema", "schema": {
        "type": "object",
        "properties": {"company": {"type": "string"}},
        "required": ["company"],
        "additionalProperties": False,
    }}},
    messages=[{"role": "user", "content": "Extract the company name from: Acme Corp, founded 1990."}],
)
```

Prefill → replacement map:
| Prefill was forcing | Use instead |
|---------------------|-------------|
| JSON/YAML shape | `output_config.format` json_schema (above) |
| A classification label | tool with an `enum` field, or structured outputs |
| Skipping preamble ("Here is…") | system instruction: "Respond directly without preamble." |

Structured outputs supported on Opus 4.8 / Sonnet 4.6 / Haiku 4.5 / Fable 5 (+ legacy Opus 4.5/4.1).
Incompatible with citations and prefilling. Use `client.messages.parse()` for auto-validation.

---

### Rule 3: Claude 4.7+ Follows Instructions More Literally — Specify Scope Explicitly

**What changed**: Opus 4.7/4.8 apply formatting and style rules more literally than 4.6. It will
NOT silently generalize an instruction from one item to another. "Use bullet points" gets applied
everywhere, including where prose fits better.

**Fix**: be explicit about scope:
```
❌ "Use bullet points for your response."
✅ "Use bullet points when listing 3+ items. Use prose for single statements and explanations."

❌ "Keep responses concise."
✅ "Keep responses under 150 words unless the user requests more detail."
```

4.7+ also calibrates verbosity to task complexity — test existing "be concise" instructions before
changing them rather than assuming a direction. Positive examples of desired concision beat negative
"don't do X" instructions.

---

### Rule 4: Avoid "MUST USE" Aggressive Language on Claude 4.6+

**What changed**: Emphatic directives ("MUST USE", "ALWAYS INCLUDE", "NEVER EVER", "CRITICAL:")
**over-trigger** on Claude 4.6+ — the model follows the system prompt much more closely than older
models, so prompts written to overcome the *old* reluctance are now too aggressive.

**Migration** (from the migration guide's prompt-behavior table):
```
❌ "CRITICAL: You MUST use this tool when..."   ✅ "Use this tool when..."
❌ "Default to using [tool]"                     ✅ "Use [tool] when it would improve X"
❌ "If in doubt, use [tool]"                      ✅ (delete — no longer needed)
❌ "MUST USE: ALWAYS include a JSON object."     ✅ "Respond with a JSON object containing your analysis."
```

**Rule**: Direct, clear language > emphatic language. If the model over-triggers a tool, dial back
the language — don't add more guardrails.

---

### Rule 5: Provide Requirements Upfront — Long-Horizon Work Wants One Well-Specified Turn

**What changed**: Opus 4.7/4.8 are state-of-the-art at long-horizon autonomous work and reason more
at each step. Give the **full task specification in a single well-specified first turn** and run at
`high`/`xhigh` effort — piecemeal multi-turn requirements reduce token efficiency and sometimes
performance.

**Wrong** (drip-feed): Turn 1 "parse JSON" → Turn 2 "handle errors" → Turn 3 "nested objects".
**Right** (upfront): "Write a TypeScript JSON parser with full error handling (malformed/null
inputs), arbitrarily-nested object support, and explicit types for all params and return values."

In Claude Code this maps to `/goal`; with Managed Agents, state "done" via an Outcome
(`user.define_outcome` + a gradeable rubric).

---

### Rule 6: Prompt Caching Architecture — Stable Prefix + Frozen, Deterministic

**What changed**: Caching is a **prefix match** — any byte change anywhere in the prefix invalidates
everything after it. Render order is `tools` → `system` → `messages`. Cache reads cost ~0.1× base
input; writes cost 1.25× (5-min TTL) or 2× (1h TTL).

**Architecture**: stable role + constraints + tool defs + reference docs → `cache_control` breakpoint
→ dynamic user query (NOT cached).

```python
system=[{
    "type": "text",
    "text": "You are a [role]...[full stable system prompt]",
    "cache_control": {"type": "ephemeral"},   # or {"type":"ephemeral","ttl":"1h"}
}]
```

**Minimum cacheable prefix is model-dependent** — shorter silently won't cache (`cache_creation_input_tokens: 0`):
- Opus 4.8 / 4.7 / 4.6 / Haiku 4.5: **4096 tokens**
- Fable 5 / Sonnet 4.6: **2048 tokens**

A 3K-token prompt caches on Sonnet 4.6 but silently won't on Opus 4.8.

**Silent invalidators** (grep the prefix-building code): `datetime.now()`/`Date.now()` in system
prompt, `uuid4()` early in content, `json.dumps()` without `sort_keys=True`, per-user IDs in system,
conditional system sections, `tools=build_tools(user)`. Max **4** breakpoints. Verify with
`usage.cache_read_input_tokens` — zero across identical-prefix requests means a silent invalidator.

**Mid-session operator instructions** (Opus 4.8, beta `mid-conversation-system-2026-04-07`): append
`{"role":"system",...}` to `messages[]` instead of editing top-level `system` — preserves the cached
prefix and is the injection-safe operator channel.

---

### Rule 7: Opus 4.8 Under-Reaches for Tools — Fix with a Triggering Instruction + Higher effort, NOT `budget_tokens`

**What changed**: Opus 4.8 is **conservative about reaching for tools** (web search, subagents,
file-based memory, custom tools) — high-precision/low-recall by default. The old fix ("raise
`budget_tokens`") is **doubly wrong**: `budget_tokens` returns a 400 on 4.7+, AND a token budget was
never the right lever for tool-use rate.

**Correct fix — two levers:**

1. **A search-first / triggering instruction** in the system prompt:
```
<search_first>
For questions where current information would change the answer (recent events, current prices,
version-specific behavior, or anything the user flags as time-sensitive), search before answering
rather than answering from memory. For open-ended research, begin searching immediately.
</search_first>
```

2. **Higher effort** — `high`/`xhigh` show substantially more tool usage in agentic search/coding.

The same lever works at the **tool-description** level: a prescriptive description that states *when*
to call a tool ("Call this when the user asks about current prices or recent events") gives
measurable lift on 4.8 over one that only states what the tool does. Make the trigger condition part
of each tool's own `description`.

For subagents/memory, say *when* each applies: "When a task fans out across independent items,
delegate to subagents rather than iterating serially."

---

### Rule 8 (Fable 5 only): Always-On Thinking, New Tokenizer, `refusal` Handling

If targeting `claude-fable-5`:
- **Omit `thinking` entirely** — thinking is always on. Both `{type:"disabled"}` and
  `{type:"enabled",budget_tokens:N}` return 400. Control depth with `output_config.effort`.
- **New tokenizer**: same content tokenizes ~30% higher than Opus-tier. Re-baseline `max_tokens`
  and cost with `count_tokens(model="claude-fable-5")` (returns counts under both tokenizers).
- **`refusal` stop reason**: safety classifiers may decline (HTTP 200, `stop_reason:"refusal"`).
  Check `stop_reason` before reading `response.content[0]`. Retry on `claude-opus-4-8` via the
  server-side `fallbacks` param (beta `server-side-fallback-2026-06-01`) or client-side middleware.
- **30-day data retention required** — ZDR orgs get 400 on every request.

---

## Old patterns (do NOT use) — corrected 2026-06-13

These were taught by the prior version of this file and are now wrong:

| Old (wrong) | Why it fails | Use instead |
|-------------|--------------|-------------|
| `thinking={"type":"enabled","budget_tokens":N}` | 400 on Opus 4.7/4.8/Fable 5 | `thinking={"type":"adaptive"}` + `output_config.effort` |
| "Raise `budget_tokens` for tool-heavy tasks" | 400, AND wrong lever | search-first instruction + higher effort (Rule 7) |
| Prefill `{"role":"assistant","content":"{"}` | 400 on 4.6/4.7/4.8/Fable 5 | `output_config.format` structured outputs (Rule 2) |
| top-level `output_format=` | deprecated API-wide | `output_config={"format":{...}}` |
| `temperature`/`top_p`/`top_k` on Opus 4.7+ | 400 (removed) | steer via prompting + effort |
