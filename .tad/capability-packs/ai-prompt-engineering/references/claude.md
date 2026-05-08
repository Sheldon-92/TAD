# Claude 4.x Prompt Engineering Rules

> Source: Anthropic documentation (Claude 4.x release notes + API reference), retrieved 2026-05-07.
> These rules apply specifically to Claude claude-opus-4-7, claude-sonnet-4-6, claude-haiku-4-5.
> Model-agnostic rules live in the main CAPABILITY.md.

---

### Rule 1: Extended Thinking (`budget_tokens`) Replaces Manual CoT Instructions

**What changed**: Claude 4.x with extended thinking enabled handles multi-step reasoning internally.
The `thinking.budget_tokens` field controls reasoning depth. Manual Chain-of-Thought instructions
in the system prompt compete with — and often degrade — the model's own reasoning process.

**Extended thinking API** (current Anthropic API):
```python
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000  # reasoning token budget — increase for harder tasks
    },
    messages=[{"role": "user", "content": user_message}]
)
```

**In your prompt**: Do NOT write "Think step by step" or "Reason through this carefully" — when
extended thinking is enabled, Claude reasons internally before generating a response. Manual
CoT instructions are redundant and add tokens without adding value.

**Wrong** (with extended thinking enabled):
```
Think carefully through each step before answering.
First, identify the relevant facts.
Then, reason through each option.
Finally, state your conclusion.
```

**Right** (with extended thinking enabled):
```
[No CoT instructions — just the task description and constraints]
```

**Exception**: Keep CoT reasoning traces in few-shot examples. Claude learns reasoning patterns
from demonstrated examples:
```
<thinking>
Step 1: Looking at the input...
Step 2: The ambiguous case is...
Step 3: I'll choose X because Y...
</thinking>
```

**Without extended thinking**: Keep manual CoT instructions for low-reasoning-budget scenarios
where `thinking` is disabled.

---

### Rule 2: Prefilling Conflicts with Extended Thinking — Use Format Constraints Instead

**What changed**: When extended thinking is enabled, prefilling the assistant message
(`messages=[..., {"role": "assistant", "content": "..."}]`) conflicts with the thinking
block that Claude generates before its response. The thinking block and the prefill attempt
to occupy the same position in the response, producing unexpected behavior.

**When extended thinking is disabled**: Prefilling still works and is supported by the
Anthropic API. Prefilling is particularly useful for format enforcement (e.g., starting with `{`
to force JSON output, or `<answer>` to anchor structured responses).

**Extended thinking enabled — use format constraints instead**:
```python
# With extended thinking: use system prompt format constraints
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=16000,
    system="Respond only with a valid JSON object. No preamble, no markdown.",
    thinking={"type": "enabled", "budget_tokens": 8000},
    messages=[{"role": "user", "content": "Extract the company name from: Acme Corp was founded in 1990."}]
)
```

**Extended thinking disabled — prefilling still works**:
```python
# Without extended thinking: prefilling is supported and reliable
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Extract the company name."},
        {"role": "assistant", "content": "{"}  # Forces JSON output
    ]
)
```

**Recommendation**: For production prompts that may enable extended thinking, use system-prompt
format constraints rather than prefilling. See `references/output-format.md` for schema definition
patterns.

---

### Rule 3: Claude 4.7 Follows Instructions More Literally — Specify Scope Explicitly

**What changed**: Claude 4.7 applies formatting and style rules more literally than 4.6.
An instruction like "Use bullet points" will be applied to every output element, including
cases where prose would be more appropriate.

**Impact**: Instructions that were previously interpreted contextually are now followed strictly.

**Fix**: Be explicit about scope:
```
❌ "Use bullet points for your response."
✅ "Use bullet points when listing 3+ items. Use prose for single statements and explanations."

❌ "Keep responses concise."
✅ "Keep responses under 150 words unless the user explicitly requests more detail."
```

**Test for literal interpretation**: Ask Claude to respond to an edge case and check whether
your instructions were over-applied.

---

### Rule 4: Avoid "MUST USE" Aggressive Language on Claude 4.6+

**What changed**: Emphatic directives like "MUST USE", "ALWAYS INCLUDE", "NEVER EVER" cause
over-triggering on Claude 4.6+ — the model applies these with excessive frequency, even in
contexts where the constraint was not intended to apply.

**Examples of over-triggering**:
- "ALWAYS cite your sources" → cites sources even for general knowledge statements where citations are meaningless
- "MUST include a summary" → adds a summary even to single-sentence responses

**Migration**:
```
❌ "MUST USE: ALWAYS include a JSON object in your response."
✅ "Respond with a JSON object containing your analysis."

❌ "NEVER EVER make assumptions about the user's intent."
✅ "When the user's intent is ambiguous, ask a clarifying question before proceeding."
```

**Rule**: Direct, clear language > emphatic language. The model follows clear instructions reliably.

---

### Rule 5: Provide Requirements Upfront — Multi-Turn Drains Reasoning Tokens

**What changed**: Claude 4.x extended thinking sessions accumulate reasoning context across turns.
Piecemeal requirements delivered across multiple turns drain the reasoning token budget without
producing new information.

**Wrong** (reasoning token drain):
```
Turn 1: "Write a function to parse JSON."
Turn 2: "Oh, make it handle errors."
Turn 3: "Also, it should handle nested objects."
Turn 4: "And add TypeScript types."
```

**Right** (upfront):
```
Turn 1: "Write a TypeScript function to parse JSON with:
- Full error handling (malformed JSON, null inputs)
- Support for arbitrarily nested objects
- Explicit TypeScript types for all parameters and return values"
```

**In your system prompt**: Include the complete task specification in the first user message.
Use the system prompt to set the context and constraints; use the first user message to provide
the complete task.

---

### Rule 6: Prompt Caching Architecture — Stable Prefix + Dynamic Suffix

**What changed**: Claude API supports prompt caching via `cache_control` breakpoints.
Cached tokens are ~10× cheaper on repeated calls.

**Architecture**:
```
System Prompt (cached):
  ├── Role definition
  ├── Core constraints (stable, never changes)
  ├── Tool definitions (stable)
  ├── Reference documents
  └── cache_control breakpoint ← place here

Dynamic suffix (NOT cached):
  └── User query + task-specific context
```

**Implementation**:
```python
system=[
    {
        "type": "text",
        "text": "You are a [role]...[full stable system prompt]",
        "cache_control": {"type": "ephemeral"}
    }
]
```

**Critical**: The stable prefix must be byte-identical across requests. Even a single character
change (including whitespace) invalidates the cache. Do not include timestamps, request IDs,
or any variable data in the cached section.

**Cache hit rate target**: ≥80% for production systems with repeated system prompts.

---

### Rule 7: Claude 4.7 Reasons More, Uses Tools Less — Raise `budget_tokens` for Tool-Heavy Tasks

**What changed**: Claude 4.7 tends to reason through problems internally before reaching for
external tools. This produces more thoughtful responses but reduces tool call frequency.

**Impact**:
- Good: higher quality reasoning, fewer unnecessary tool calls
- Bad: tasks that require tool use (web search, code execution, file operations) may see
  fewer invocations than expected

**Fix for tool-heavy workflows**:
```python
# Raise budget_tokens for tasks requiring frequent tool use
"thinking": {"type": "enabled", "budget_tokens": 16000}  # higher budget = more reasoning + tool use

# Or prompt-level guidance:
"For each step of this task, use the available tools to gather information
 rather than relying on your training knowledge."
```

**Testing**: If you observe that Claude 4.7 is reasoning without calling tools when tools
would be appropriate, raise the `budget_tokens` value or add explicit tool-use guidance.
