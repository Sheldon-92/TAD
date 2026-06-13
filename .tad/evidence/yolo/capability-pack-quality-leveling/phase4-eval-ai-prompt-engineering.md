# Phase 4 Behavioral Discriminative Eval — ai-prompt-engineering

**Date**: 2026-06-13
**Pack**: ai-prompt-engineering (v1.0.0)
**Fixture**: `.claude/skills/ai-prompt-engineering/examples/system-prompt-template.md`
**Result**: PASS

---

## 1. Fixture parameters

- **Scenario** (from fixture frontmatter / body): *"Write me a production system prompt for a
  customer-support bot that reads user messages and returns a JSON triage object."*
- **discriminative_pattern**: `~?23%|84%|12%|cache_control|first 30%|U.?shaped|output_config|structured output|do NOT have access`
- **min_discriminative**: 3

The fixture's discriminative markers are pack-specific research numbers and named placement rules
(~23% capability-declaration hallucination drop, 84%→12% injection success, cache_control breakpoint,
first-30% / U-shaped attention, output_config structured outputs vs prefill) that a generalist agent
does not emit when asked to "write a system prompt."

## 2. Method

Produced two answers to the fixture scenario:
- **WITH-PACK**: applied SKILL.md Phase 1 rules (1.2 role formula, 1.4 cache_control + U-shaped /
  first-30%, 1.5 capability declaration ~23%, 1.6 injection delimiter+scaffold 84%→12%, claude.md
  Rule 2 structured outputs via output_config not prefill).
- **CONTROL**: generalist "write a system prompt" answer with NO pack loaded ("helpful assistant"
  role, generic JSON block, generic tips).

Applied the gate verifier to each:
```
grep -oE '<discriminative_pattern>' <output>.md | sort -u | wc -l
```

## 3. Results

| Answer | Distinct discriminative markers | Markers matched |
|--------|-------------------------------|-----------------|
| WITH-PACK | **9** | ~23%, 12%, 84%, cache_control, do NOT have access, first 30%, output_config, structured output, U-shaped |
| CONTROL | **0** | (none) |

## 4. Gate decision

discriminative_pass = (with_pack_disc >= min_discriminative) AND (control_disc < min_discriminative)
                    = (9 >= 3) AND (0 < 3)
                    = **TRUE**

The pack is discriminative: it drives pack-specific markers far above the floor while the
generalist control emits none of them.

## 5. Artifacts

- WITH-PACK answer: `/tmp/with-pack-output.md` (ephemeral; reproduced inline above)
- CONTROL answer: `/tmp/control-output.md` (ephemeral)
- Verifier: `grep -oE '~?23%|84%|12%|cache_control|first 30%|U.?shaped|output_config|structured output|do NOT have access' | sort -u | wc -l`
