# Code Review: vimax-pattern-upgrade-video-creation

**Reviewer**: code-reviewer
**Date**: 2026-05-27
**Files Reviewed**:
- `.claude/skills/video-creation/references/vimax-patterns.md` (NEW, 309 lines)
- `.claude/skills/video-creation/SKILL.md` (MODIFIED, lines 49 + 120-124)
- `.tad/capability-packs/video-creation/CAPABILITY.md` (MODIFIED, mirror)
- `.tad/capability-packs/video-creation/references/vimax-patterns.md` (byte-identical mirror)

**Handoff Reference**: `.tad/active/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md`

---

## Verdict: CONDITIONAL PASS

One P1 accuracy issue in the integration example, plus minor suggestions. No blocking P0 issues found.

---

## Findings

### P0 (Blocking)

None.

### P1 (Should fix)

**P1-1: BPM value in Photo-to-Beat-Sync example falls outside all defined ranges**

File: `vimax-patterns.md`, lines 277-278

The example states:
```
Step 5 -- Audio: lofi -> 90 BPM (between Emotional 20-80 and Social 110-130)
```

90 BPM falls in a gap between the Emotional range (20-80) and the Social Media Short range (110-130) per `audio-design.md` line 14-18. The parenthetical even acknowledges it is "between" the two ranges, which means it matches NEITHER. This is exactly the kind of ambiguous middle-ground the BPM-to-Video-Type table is designed to prevent.

Additionally, at line 258, the pattern table says montage intent maps to "BPM 20-80 (emotional) or 110-130 (modern lofi)" -- but the example then picks 90, which is neither.

**Fix**: Either pick a BPM within the Emotional range (e.g., 75 BPM for chill lofi, which fits 20-80) or within the Social range (e.g., 115 BPM for upbeat lofi, which fits 110-130). Lofi is typically 70-90 BPM in practice, so 75 BPM within the Emotional range is the most defensible choice. Update the cut interval math accordingly (60/75 = 0.8s beats, cuts on every ~2.5th beat = 2.0s per photo still works).

**P1-2: Pattern 2 intent table implies BPM ranges not present in audio-design.md**

File: `vimax-patterns.md`, line 118

The anti-pattern example says:
```
-> Select Emotional/Storytelling pacing (3-5s shots, BPM 20-80)
-> NOT Product Demo pacing (1-2s fast cuts, BPM 130-200)
```

Product Demo in `audio-design.md` is 130-200. The contrast of "BPM 20-80" for montage is consistent with the Emotional/Storytelling row. This is technically correct but the "1-2s fast cuts" duration for Product Demo is not directly from `storytelling.md` -- it is Pattern 2's own inference. This is acceptable as a judgment rule, but worth noting for accuracy.

Severity: Low P1 (not blocking, but the BPM 20-80 vs actual-lofi-is-90 inconsistency in the worked example is confusing).

### P2 (Nice to have)

**P2-1: Missing scope boundary restatement in SKILL.md Context Detection signal**

File: `SKILL.md`, line 49

The Context Detection table row for vimax-patterns.md lists signals like "Seedance / image-to-video / first-last frame / ..." but does not include a parenthetical like "(AI video generation only)" the way the reference file itself does (line 9). This is consistent with how all other rows in the table are formatted (none have scope notes), so it follows convention. However, since the handoff explicitly flagged context-detection false-positive risk as the user's top concern, adding a brief inline scope note would be extra protection.

**Suggestion**: No change required -- the narrow signal keywords themselves are sufficient (verified via Step 7.6 negative routing test). Mentioning for completeness.

**P2-2: Cross-References table lists `production.md` section reference as "compose" phase**

File: `vimax-patterns.md`, line 239 and 301

The reference says: `production.md` Render Pipeline: camera tree analysis happens BEFORE individual shot generation (during "compose" phase).

Verified that `production.md` line 96 has `## Render Pipeline` as a heading. The "compose" phase is referenced there. This cross-reference is valid, but the section is `§Render Pipeline`, not `§compose` -- Blake correctly used the heading-level reference. No issue.

**P2-3: Integration Scene example could note Pattern 3 non-trigger more prominently**

File: `vimax-patterns.md`, lines 271-272

Per handoff Decision 6, the product-expert noted Pattern 3 may not trigger in the user's first batch (5 independent subjects, not the same character from different angles). The example does correctly show "3 different people -> Pattern 3 not triggered" on line 271, which is good. A slightly more prominent note that this is expected for the initial use case would help -- but the current treatment is adequate.

**P2-4: Schema name `IntentRouterResponse` not verified against ViMax source**

File: `vimax-patterns.md`, line 75

Pattern 2 cites `IntentRouterResponse` with `Literal["narrative", "motion", "montage"]`. The handoff spec also states this. Since the NotebookLM probe focused on Pattern 3 (BestImageSelector), this schema name for Pattern 2 may be Alex's interpretation. Low risk since it is used for context (not executable code), but worth noting as unverified.

---

## Criterion-by-Criterion Assessment

### 1. Anti-Slop

**PASS** -- Strong. Each pattern contains:
- Specific class.method citations (e.g., `StoryboardArtist.decompose_visual_description`)
- Exact file paths (e.g., `agents/storyboard_artist.py`)
- Direct prompt excerpts in blockquotes (copied from ViMax source)
- Concrete trigger thresholds (shot >= 2s, character in >= 2 shots, >= 2 consecutive shots)
- Specific anti-patterns with before/after examples
- Concrete values in examples (0.5m/s pace, 60% of clip duration, 10% zoom)

No generic "best practice" filler detected. The anti-slop quality bar is high -- these rules contain information an LLM would NOT generate from training data alone.

### 2. Accuracy (Source Citations)

**PASS** -- All 4 patterns match the handoff section 4 specifications:
- Pattern 1: `StoryboardArtist.decompose_visual_description` in `agents/storyboard_artist.py` -- matches
- Pattern 2: `ScriptPlanner.plan_script` in `agents/script_planner.py` -- matches
- Pattern 3: `ReferenceImageSelector.select_reference_images_and_generate_prompt` in `agents/reference_image_selector.py` -- matches
- Pattern 4: `CameraImageGenerator.construct_camera_tree` in `agents/camera_image_generator.py` -- matches

Each pattern also includes a prompt excerpt blockquote that matches the handoff spec's quoted prompt text.

### 3. Cross-Reference Validity

**PASS** -- All 6 cross-references in the Cross-References table (lines 296-301) point to real sections verified by grep:
- `ai-asset-generation.md` Seedance Endpoint Selection -- exists at line 71
- `ai-asset-generation.md` Visual Consistency Rules -- exists at line 578
- `storytelling.md` Video Type Patterns -- exists at line 92
- `audio-design.md` BPM-to-Video-Type -- exists at line 8
- `visual-design.md` GSAP Easing -- exists at line 7
- `production.md` Render Pipeline -- exists at line 96

### 4. Scope Boundary

**PASS** -- Line 9 explicitly states: "These patterns apply ONLY when using AI video generation (Seedance image-to-video, text-to-video). Pure GSAP/Remotion/HyperFrames 2D motion graphics do NOT need these -- visual elements are programmatically defined."

Pattern 4 (Camera Tree) additionally restates the boundary at line 220-221: "NOT needed for pure GSAP/Remotion 2D (programmatic elements don't hallucinate)."

### 5. Context Detection Signal Quality

**PASS** -- The signal keywords at SKILL.md line 49 are narrow and AI-video-specific:
- "Seedance" -- tool name, cannot false-positive for GSAP
- "image-to-video" -- endpoint type, GSAP tasks never mention this
- "first-last frame" -- ViMax-specific concept
- "photo-to-video" / "AI video clip" -- clearly AI generation context
- "multi-shot scene" -- this is the broadest keyword but still unlikely to trigger for a GSAP button animation

No overlap with existing GSAP/Remotion signals ("animation / motion / easing / transition / GSAP" at line 38).

### 6. 400-Line Hard Cap

**PASS** -- File is 309 lines, well within the 400-line limit. 91 lines of headroom remaining.

### 7. License Attribution

**PASS** -- MIT license is attributed in three places:
- Header (line 4): "ViMax repo: https://github.com/HKUDS/ViMax (MIT License)"
- Each pattern's "Grounded in" line (lines 68, 122, 179, 242): "ViMax MIT License"
- Dedicated section (lines 307-309): "Patterns derived from HKUDS/ViMax (MIT License)"

### 8. Pattern 5 Exclusion

**PASS** -- Zero mentions of "Global Character Merge", "Pattern 5", or "GlobalCharacterMerge" in vimax-patterns.md (verified by grep, count = 0). The handoff's section 10.3 exclusion is fully respected.

---

## Strengths

1. **Exemplary anti-slop quality**: Every pattern includes a real class.method path, a direct prompt excerpt from ViMax source code, and concrete numerical thresholds. This is exactly the "specific threshold from research > generic principle from training data" standard from the Capability Pack Quality Bar entry.

2. **Clear scope containment**: The scope boundary is stated once at the top (line 9) and reinforced at each relevant pattern, preventing misapplication to GSAP/Remotion tasks.

3. **Integration Scene is well-constructed**: The Photo-to-Beat-Sync scene (lines 246-288) demonstrates all 4 patterns working together in a realistic workflow, including correctly showing when patterns do NOT trigger (Pattern 3 skipped for different people, Pattern 4 skipped for different locations). This is valuable for agent comprehension.

4. **Compact at 309 lines**: The file delivers 4 patterns + 1 integration scene + cross-references + license attribution in 309 lines, leaving 91 lines of headroom under the 400-line cap.

5. **Cross-references are genuine links, not duplicated content**: Each pattern links to existing reference sections rather than restating rules, following the "cross-reference don't migrate" principle from architecture.md.

6. **Fallback logic preserved**: Pattern 3 (line 177) retains the ViMax `BestImageSelector` idx=0 fallback behavior as a graceful degradation rule, which was specifically verified via the NotebookLM quality probe.

7. **Mirror sync is byte-identical**: `diff -q` between `.claude/skills/` and `.tad/capability-packs/` copies produces empty output. CAPABILITY.md has both the Context Detection signal and Quick Rule Index entries.

---

## Next Steps

1. **Fix P1-1**: Change the Photo-to-Beat-Sync example BPM from 90 to 75 (fits within Emotional 20-80 range for lofi) and update the cut interval math. This is a 2-line change.

2. **Sync the fix**: After fixing in `.claude/skills/...`, copy to `.tad/capability-packs/...` to maintain byte-identical mirror.

3. Remaining items are P2 suggestions -- no action required for gate passage.
