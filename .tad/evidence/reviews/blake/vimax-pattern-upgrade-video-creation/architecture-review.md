# Architecture Review: vimax-pattern-upgrade-video-creation

**Reviewer**: backend-architect
**Date**: 2026-05-27
**Files reviewed**:
- `.claude/skills/video-creation/references/vimax-patterns.md` (309 lines)
- `.claude/skills/video-creation/SKILL.md` (Context Detection table + Quick Rule Index)
- `.claude/skills/video-creation/references/ai-asset-generation.md` (structural comparison)
- `.claude/skills/video-creation/references/storytelling.md`, `production.md`, `visual-design.md`, `audio-design.md` (cross-reference verification)

---

## Verdict: CONDITIONAL PASS

One P0 finding (internal BPM contradiction) must be fixed. Two P1 findings are recommended. The file otherwise demonstrates strong architectural integration.

---

## Findings

### P0 (Blocking)

**P0-1: Internal BPM Contradiction for "lofi" in Integration Scene**

Line 258 presents the Audio sync step with two BPM options:
```
BPM 20-80 (emotional) or 110-130 (modern lofi)
```

But line 277 in the worked example maps lofi to the Emotional range:
```
lofi -> 75 BPM (Emotional range 20-80, fits lofi aesthetic)
```

These two lines contradict each other. Line 258 says "modern lofi" is 110-130 BPM (which maps to the `Social Media Short` category in `audio-design.md`). Line 277 says lofi fits in the 20-80 Emotional range. An agent following step 5 of the workflow table would pick 110-130 for lofi; then following the example directly below, it would pick 75 BPM.

Cross-checking `audio-design.md`: the 110-130 range is "Social Media Short" with "medium-fast, lifestyle-oriented, modern pop production." The 20-80 range is "Emotional / Storytelling" with "ambient to full orchestra, sustained synths, cinematic pads." Lo-fi hip-hop / chill beats typically sit in the 70-90 BPM range, which means 75 BPM in the example is correct and the "110-130 (modern lofi)" label on line 258 is the error.

**Fix**: On line 258, change `110-130 (modern lofi)` to a label that matches the actual audio-design.md category for that BPM range. Options: (a) remove the lofi label entirely and use `110-130 (social/upbeat)`, or (b) shift "lofi" to the 20-80 range on line 258 to match the example.

---

### P1 (Should fix)

**P1-1: Routing Signal Overlap Between `ai-asset-generation.md` and `vimax-patterns.md`**

SKILL.md Context Detection table has overlapping signals:

| Row (line 44) | Signals | Target |
|---|---|---|
| Row 8 | `generate video / AI video / Seedance / video clip / animate image` | `ai-asset-generation.md` |
| Row 13 (line 49) | `Seedance / image-to-video / first-last frame / ... / AI video clip / multi-shot scene` | `vimax-patterns.md` |

Three signals appear in both rows: `Seedance`, `AI video clip`, and partially `image-to-video` (Row 8 has `animate image`). The "Multi-signal" note says "Load all matched references" -- but an agent seeing just the word "Seedance" will load both files, which is 37K + 15K = 52K tokens of reference material. This is architecturally correct (both files ARE relevant for Seedance tasks), but the overlap means `vimax-patterns.md` will ALWAYS be co-loaded with `ai-asset-generation.md` for any Seedance task, never independently.

This is not necessarily wrong -- Pattern 1 (visual decomposition) is meaningless without the Seedance API rules in ai-asset-generation.md. But the shared signals mean vimax-patterns.md can never be triggered in isolation. If that is the intent, consider making it explicit: "vimax-patterns.md is always co-loaded with ai-asset-generation.md."

If the intent is for vimax-patterns.md to also trigger independently (e.g., for planning/storyboarding without API calls), the distinguishing signals should be more specific. The current unique triggers (`first-last frame`, `multi-shot scene`) are good discriminators.

**Recommendation**: No code change required, but add a one-line note in the Context Detection section clarifying that vimax-patterns.md is expected to co-load with ai-asset-generation.md for Seedance tasks.

**P1-2: Pattern 2 (Intent Router) Claims to Sit "Above" storytelling.md But storytelling.md Has No Awareness**

Pattern 2 defines an intent routing layer (narrative/motion/montage) that sits above the Video Type Patterns in `storytelling.md`. The ASCII diagram on lines 93-98 shows a clear hierarchy:

```
User request
  -> Intent Router (this pattern): narrative / motion / montage
    -> storytelling.md Video Type: Product Demo / Social Short / Tutorial / etc.
      -> Specific pacing parameters
```

Per the handoff constraint (section 10.4), modifying other references is explicitly forbidden, so storytelling.md cannot be updated. This is architecturally acceptable because Pattern 2 is purely additive -- it adds a classification step BEFORE the agent consults storytelling.md. The agent reads vimax-patterns.md, classifies intent, then reads storytelling.md with the intent already decided.

However, the current architecture means an agent that loads ONLY storytelling.md (without vimax-patterns.md) will never see the intent routing step. This creates two valid execution paths for the same task -- one with intent routing (when vimax-patterns.md is loaded) and one without (when only storytelling.md is loaded). For now this is acceptable because intent routing is optional enhancement, not a correctness gate. But if intent routing becomes mandatory in a future version, storytelling.md would need a forward-reference.

**Recommendation**: Track this as a future consideration. If a subsequent upgrade makes intent routing mandatory, storytelling.md must gain a "Step 0: Classify intent via vimax-patterns.md" preamble.

---

### P2 (Nice to have)

**P2-1: Source Header Convention Differs Slightly from Other References**

Existing reference files use this header pattern:
```
> Source: Research notebook a62f253b (27 sources), Layer N
```

vimax-patterns.md uses:
```
> Source: NotebookLM research notebook `video-creation-vimax-research` (38 sources)
> ViMax repo: https://github.com/HKUDS/ViMax (MIT License)
> Research findings: .tad/evidence/research/video-creation-vimax/2026-05-27-deep-ask-findings.md
```

The vimax version is more informative (includes repo URL, license, and evidence path), which is actually an improvement. But the format divergence means an automated header parser would need to handle two patterns. Minor consistency issue -- not blocking.

**P2-2: Cross-References Section Could Include Section Anchors for Reverse Discovery**

The Cross-References table at the bottom (lines 292-301) is well-structured and covers all outgoing references. For reverse discovery (an agent reading ai-asset-generation.md wanting to know about vimax-patterns.md), the only path is through SKILL.md's Quick Rule Index. This is architecturally correct for a reference-based pack (the router is the discovery mechanism, not cross-references between files). No action needed -- noting for completeness.

**P2-3: Integration Scene Example Uses Hardcoded "75 BPM" Without Showing Derivation**

Line 277: `lofi -> 75 BPM (Emotional range 20-80, fits lofi aesthetic)`. The 75 BPM value appears reasonable for lofi but is presented as a fait accompli. The derivation path (what sub-genre of lofi? why 75 vs 70 or 80?) is not shown. For a judgment rule, the agent should understand that 75 is a reasonable default within the range, not the only correct answer. Consider adding "(agent picks BPM within range based on track tempo)" to make the flexibility explicit.

---

## Strengths

1. **Scope boundary is precise and well-placed** (line 9): "These patterns apply ONLY when using AI video generation... Pure GSAP/Remotion/HyperFrames 2D motion graphics do NOT need these." This prevents false-positive loading and unnecessary context consumption for the majority of video-creation tasks (which are 2D motion graphics).

2. **Each pattern has a clear Trigger + Anti-Pattern structure** consistent with existing references (e.g., ai-asset-generation.md's endpoint selection table, production.md's failure mode table). This is the correct reference-based pattern for judgment rules.

3. **Integration Scene is the standout section**. It demonstrates all 4 patterns working together with conditional application (Pattern 3 "not triggered" for different people, Pattern 4 "not triggered" for different locations). This teaches the agent WHEN NOT to apply a pattern, which is as valuable as when to apply.

4. **"Integration with Existing Pack" sub-sections per pattern** create explicit connection points to existing references without duplicating their content. This follows the "reference don't copy" principle from architecture knowledge.

5. **License attribution is properly handled** -- MIT license noted at header, per-pattern source links to specific files in the ViMax repo, and a clear "not a code port" disclaimer at the end. This is the correct approach for research-derived judgment rules.

6. **Quick Index at the top** (lines 15-22) enables rapid scanning for agents that already know which pattern they need, avoiding full-file reads for repeat visits. This is a pattern not present in other reference files -- worth adopting elsewhere.

7. **Context budget is appropriate**: 309 lines for 4 patterns + 1 integration scene + cross-references. Comparable density to `audio-design.md` (10KB / ~300 lines) and `storytelling.md` (11KB / ~300 lines). No section feels padded or could be meaningfully compressed without losing judgment value.
