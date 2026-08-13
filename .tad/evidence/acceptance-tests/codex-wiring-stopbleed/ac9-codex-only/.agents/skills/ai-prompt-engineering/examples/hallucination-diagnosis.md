---
name: hallucination-diagnosis
description: "Tests failure-taxonomy diagnosis (46/25/29 split) + FM-codes + U-shaped attention + model pinning on a drifting-prompt audit"
pack: ai-prompt-engineering
tests_rules:
  - "Phase 3 Escalation Gate — failure taxonomy 46% env / 25% config / 29% wording"
  - "Failure catalog FM-1..FM-6"
  - "Phase 1.4 U-shaped attention / cache_control"
  - "Phase 4.2 model version pinning"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "hallucination"/"improve
# the prompt". FM-codes, U-shaped attention, cache_control, and the 46/25/29 failure-taxonomy
# split are the pack's named catalog + specific research numbers a no-pack agent does not emit.
discriminative_pattern: "FM-[1-6]|U-shaped|cache_control|46%|25%|29%"
min_discriminative: 3
---

# Fixture: Prompt Hallucination Diagnosis

## Input Scenario

"My RAG system prompt started hallucinating facts and drifting from its JSON output format right after we upgraded the model. Help me fix it."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-prompt-engineering pack loaded,
the output MUST contain these markers:

1. **Failure-taxonomy root-cause split** [structural]: before rewriting the prompt, the agent checks the taxonomy (46% env / 25% config / 29% wording) rather than immediately editing wording
   grep pattern: `46%|25%|29%|env(ironment)?/infra|config(uration)? fault|before blaming the prompt`
2. **FM failure-mode codes**: the pack's named failure catalog (FM-1 format drift, FM-2 RAG hallucination, FM-3 silent regression …)
   grep pattern: `FM-[1-6]|[Ff]ormat [Dd]rift|RAG [Hh]allucination|[Ss]ilent [Rr]egression`
2b. **Model version pinning**: the pack's rule against alias model names (regression after model update)
   grep pattern: `pin (the )?(exact|model) version|claude-sonnet-4|alias|canary (5%|rollout)`
3. **U-shaped attention / grounding constraints**: placement + anti-hallucination rules the pack introduces
   grep pattern: `U.?shaped|first 30%|cache_control|capability declaration|do not extrapolate`

## Verification Command

```bash
grep -oE '46%|25%|29%|environment/infra|config fault|before blaming the prompt|FM-[1-6]|format drift|RAG hallucination|silent regression|pin the exact version|claude-sonnet-4|U.?shaped|first 30%|cache_control|capability declaration' hallucination-diagnosis-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "46% env / 25% config / 29% wording" (the pack's specific failure-taxonomy numbers — no-pack agent jumps straight to rewriting)
- ✅ "FM-1..FM-6" failure-mode codes (the pack's named catalog)
- ✅ "U-shaped attention / first 30% / cache_control" (the pack's placement rules)
- ✅ "pin the exact model version, not an alias" (the pack's FM-3 silent-regression fix)
- ❌ "improve the prompt" (generic — any agent says this)
- ❌ "add more instructions" (generic, non-discriminative)
- ❌ "hallucination" alone (in the input)
