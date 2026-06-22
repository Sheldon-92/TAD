# Knowledge Writing Rules

> 5 rules for writing reusable playbook entries.
> Grounded in: AWM, Letta, Anthropic Skills, Mem0.
> Source: `.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`

---

## Rules

1. **Variabilize test (what to record)**: Replace every project-specific value in the entry with a `{descriptive-slot}`. If a coherent reusable skeleton survives, the entry qualifies as a playbook entry. If the entire content dissolves into slots, it was a log — do not record. If nothing can be extracted as a variable, it was a one-time fix — do not record.
   - **Guard (a) — success-only**: Only harvest from Gate-passed / accepted work. Never induce a pattern from a failed or partial trajectory.
   - **Guard (b) — leak detection**: If the finished entry still contains literal values from the source episode (project names, filenames, timestamps that should have been variabilized), the abstraction failed — reject the entry.
   - *Why*: AWM's `filter_workflows` applies exactly these two guards — success-only filter prevents learning from broken trajectories, and the leak detector catches abstractions that look general but carry source-specific literals (research §1).

2. **Keep invariant values literal (symmetric rule)**: Values that do NOT change across instances — fixed button labels, stable identifiers, constant thresholds — stay as literal text. Do NOT variabilize them. Over-abstraction is as wrong as under-abstraction.
   - *Why*: AWM's instruction pair: "`Seattle` → `{origin-city}` but `One Way` stays `One Way`." The symmetric discipline prevents entries from becoming so abstract they lose actionable specifics (research §1).

3. **No relative time**: Do not write "today", "recently", "last week", "yesterday", or "this session." Write absolute dates (e.g., 2026-06-22). Knowledge persists indefinitely; relative references decay the moment the entry leaves the session.
   - *Why*: Letta sleeptime prompt, verbatim: "do not write 'today' or 'recently', instead write specific dates and times, because the memory is persisted indefinitely" (research §2).

4. **Non-SAFETY entries: explain reasoning, do not stack imperative MUSTs**: When you find yourself writing ALWAYS, NEVER, or MUST in all caps, treat that as a yellow flag. Restate the rule by explaining the reasoning so the model can generalize to edge cases the rule didn't anticipate.
   - **Exception: SAFETY / `read_only` entries are exempt from this rule.** Their MUST/MANDATORY/VIOLATION keywords are load-bearing constraint anchors — mechanical enforcement depends on their exact phrasing. Do not weaken, rephrase, or remove these keywords from SAFETY entries. This exception is grounded in the L1 principle "Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical" (principles.md, 2026-04-04).
   - *Why*: Anthropic skill-creator: "If you find yourself writing ALWAYS or NEVER in all caps… that's a yellow flag — reframe and explain the reasoning so the model understands why" (research §2). The SAFETY exception exists because TAD's SAFETY entries serve as grep-countable mechanical anchors (principles.md, 2026-05-31) — removing their keywords breaks verification infrastructure.

5. **Imperative voice, self-contained**: Write in imperative mood ("do X", "avoid Y"). Eliminate pronouns — use concrete nouns, tool names, and dates instead. The entry must be fully understandable by a reader with zero context beyond the entry itself.
   - *Why*: Anthropic imperative style; Mem0 self-contained principle — "completeness beats brevity" (research §2).

---

## Variabilize Before/After Exemplar

### Before (raw journal — doer's diary)

> Today I learned that when you loop background music in the audio production pipeline,
> you get an audible seam at the loop point. I tried crossfading but the BGM track for
> Colin's voice-studio project was only 30 seconds and the crossfade ate too much.
> The fix was to use a longer BGM track (2+ minutes) so the episode ends before the loop
> point. Also the swell should be 40% not 80% — 80% drowns out the voice.

Problems: relative time ("today"), project-specific names ("Colin's voice-studio"),
no failure_mode stated, no validator, a reader without this session's context cannot
reproduce the lesson.

### After (typed playbook entry, variabilized)

```
label: bgm-loop-seam-avoidance
selector: >
  Triggers when: arranging background music for any audio/podcast production,
  looping a BGM track, setting BGM swell/duck levels.
  Synonyms: background music, underscore, bed music, music loop, BGM ducking.
  Near-miss exclusion: does NOT trigger for sound-effect loops or one-shot stingers
  (those have different loop-point handling).
value: >
  Select a BGM track whose duration exceeds {episode-duration} so the episode
  ends before the loop point — avoid looping short tracks entirely. If looping
  is unavoidable, apply a crossfade of {crossfade-duration} at the loop boundary.
  Set BGM swell level to {swell-percentage} (not higher) during voice segments
  to preserve voice intelligibility.
  [char budget: 500 — to be enforced in P2]
failure_mode: >
  Naive default: loop a short BGM track directly and set swell to 80%.
  Why wrong: direct looping produces an audible seam at the splice point;
  80% swell drowns out the voice track, making speech unintelligible.
validator: >
  Listen to the final mix at the loop point — no audible click or volume jump.
  Play a voice segment over BGM — speech remains clearly intelligible without
  straining. (Subjective, human judgment.)
read_only: false
```

**What changed**:
- "Colin's voice-studio project" → removed (project-specific, variabilized away)
- "30 seconds" → `{episode-duration}` context (the concrete number was episode-specific)
- "40%" → `{swell-percentage}` (the optimal value depends on the voice/BGM pair)
- "today" → removed (no relative time, rule 3)
- `failure_mode` explicitly states the naive default ("loop directly + 80% swell") and why it fails
- `One Way`-style invariants: "loop point", "crossfade", "swell" stay literal (these are domain-stable terms, rule 2)
- Leak check: no remaining literals from the original "Colin" / "voice-studio" / "30 seconds" episode
