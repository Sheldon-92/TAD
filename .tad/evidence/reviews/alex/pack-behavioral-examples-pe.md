# Product Expert Review: Capability Pack Behavioral Examples Framework

**Reviewer**: Product Expert
**Date**: 2026-05-27
**Handoff**: HANDOFF-20260527-pack-behavioral-examples.md v1.0
**Reviewed Against**: IDEA-20260527-pack-behavioral-examples.md + deep-ask-findings.md

---

## P0 (Blocking) — 2 issues

### P0-1: Marker grep proves word presence, not behavioral change

The core claim is "prove pack rules change agent behavior." But the verification method (grep for keyword presence in agent output) has a fundamental gap: **an agent can mention pack-specific terminology without actually applying the rule**.

Example from the video-creation fixture: the marker `first.frame` would match if the agent wrote "I would consider a first frame plan" (mention without application) just as easily as if it produced an actual first_frame/last_frame decomposition table. Keyword grep cannot distinguish between:
- (A) Agent saw the rule and applied it (behavioral change)
- (B) Agent saw the rule, echoed the term, but produced generic output around it (cargo-cult compliance)
- (C) Agent coincidentally used the same phrase from training data

The handoff itself acknowledges this risk in anti-slop (case C), but completely ignores case B, which is the more likely failure mode for agents that have been prompted with pack rules. When an agent loads a SKILL.md full of terms like "Camera Tree Rule" and "Visual Decomposition," it will parrot those terms whether or not its actual output reflects the decomposition.

**Fix required**: Add a "structural marker" category alongside keyword markers. A structural marker asserts output structure, not vocabulary. For example:
- Keyword marker: `first.frame` (word grep -- current)
- Structural marker: output contains a per-photo table with columns first_frame and last_frame (requires a section-level grep or line-count check within a section)

At minimum, the fixture format spec (section 4.2) MUST require that at least 1 of the min_marker_count markers is structural (asserts output shape/format), not just lexical (asserts word presence). Otherwise we are building exactly the "validation theater" the YOLO audit warned about, just with pack-specific vocabulary instead of generic vocabulary.

### P0-2: Single fixture is insufficient to validate the framework format

The handoff scope is "1 pack, 1 fixture" for dogfood. The IDEA file originally said "2-3 scenario input + expected output pairs." The handoff Decision 2 says "only require new packs to have fixtures," but the immediate validation of whether the fixture FORMAT itself works requires at least 2 fixtures testing different things:

1. One fixture for a task where the pack adds clear value (photo-to-beat-sync: montage scenario where multiple rules fire)
2. One fixture for a boundary case where fewer rules fire (e.g., a simple single-clip narration task where only 1-2 rules are relevant)

With only 1 fixture, you prove the format can be written -- you do not prove it discriminates. A format that always passes (because the single fixture was designed for the best-case scenario) is not validated. The ViMax pre-upgrade output already showed marker count = 0 for the same scenario, which provides the discrimination signal, but the handoff does not carry that requirement forward -- it only tests post-upgrade.

**Fix required**: Add a second fixture (can be minimal, 20-30 lines) that tests a different scenario from the same pack. If two fixtures both pass with reasonable marker counts, the format is validated. If only one passes, you still learn something about format robustness. One fixture proves nothing about the format -- it only proves that specific scenario works.

---

## P1 (Should Fix) — 4 issues

### P1-1: No staleness detection between fixture markers and pack rules

The fixture spec links markers to "Quick Rule Index entry name" in the `tests_rules` frontmatter field. But there is no mechanism to detect when:
- A rule is renamed in the pack (fixture silently tests a non-existent rule)
- A rule is removed from the pack (fixture passes/fails for wrong reasons)
- A new rule is added to the pack (no fixture coverage, no warning)

The `tests_rules` field is advisory only -- nothing validates that those rule names still exist in the pack's SKILL.md Quick Rule Index.

**Fix**: Add an AC or a note in the fixture format spec that says: "When modifying a pack's Quick Rule Index, Blake MUST grep examples/*.md for any tests_rules referencing the modified/removed rule name and update or flag the fixture." This is a process rule, not automation, consistent with the MVP approach. Alternatively, add a validation command to the fixture template:
```bash
# Staleness check: verify all tests_rules exist in SKILL.md
for rule in $(awk '/^tests_rules:/,/^[^ ]/' fixture.md | grep '^ *- ' | sed 's/^ *- "//;s/"$//'); do
  grep -q "$rule" SKILL.md || echo "STALE: $rule not found in SKILL.md"
done
```

### P1-2: Blake SKILL.md should mention examples/ existence

The handoff says "不改 Blake SKILL" -- but this creates an asymmetry: Blake will be modifying pack files (install.sh, potentially SKILL.md rules) without knowing that examples/ exist and might need updating. This is exactly the staleness problem from P1-1, but at the awareness level.

The fix is minimal and does not change Ralph Loop or Layer 1: add one line to Blake's SKILL.md in the pack-modification section (or the nearest relevant location) stating:
```
Note: capability packs may contain an examples/ directory with behavioral
fixtures. When modifying pack rules, check if examples/ fixtures reference
the modified rules (tests_rules field in frontmatter).
```

This is awareness, not automation. It costs 3 lines and prevents the "invisible coupling" anti-pattern.

### P1-3: Anti-slop check is advisory, not enforceable

The "Anti-Slop Check" section in the fixture format (section 4.2) shows examples of good vs bad markers but provides no verification mechanism. Blake could write a fixture with generic markers and the AC would still pass (AC3-AC6 check structure, not content quality). The anti-slop section is documentation, not a gate.

**Fix**: Add one AC that performs a basic anti-slop validation:
```
AC11: Anti-slop markers validated
Verification: Each marker's grep pattern must be ≥2 words or contain a
pack-specific concept (not single common English words like "video",
"audio", "design", "animation", "create")
```

This is imperfect but raises the bar above zero enforcement. A human reviewer in Gate 4 can catch subtle slop; AC11 catches obvious violations.

### P1-4: Missing "when to add a new fixture" guideline

The handoff establishes the format but says nothing about when future fixtures should be created. Decision 2 says "only require new packs," but even that is ambiguous -- does "new pack" mean "new capability within an existing pack" or "entirely new pack"? The YOLO audit said "3-5 before/after task comparisons" -- this handoff settles for 1.

**Fix**: Add a brief subsection to section 4.3 (Fixture design rules) or section 10 (Important Notes):
```
### When to add fixtures
- New capability pack: MUST have >= 1 fixture before Gate 4 acceptance
- New capability added to existing pack: SHOULD have >= 1 fixture
- Pack rule modification: SHOULD verify existing fixtures still pass
- Existing packs without fixtures: no mandatory backfill (opt-in)
```

This gives Alex a basis for writing fixture-related ACs in future handoffs.

---

## P2 (Nice to Have) — 3 issues

### P2-1: Fixture output location is implicit

Step 5 says "capture output" but does not specify where the subagent output should be saved. The Evidence Manifest lists `dogfood-output.md` but the fixture format itself has no `output_path` convention. For future fixtures, each handoff would need to re-invent where to save the output.

**Suggestion**: Add an optional `output_path` field to the fixture frontmatter, defaulting to `.tad/evidence/handoffs/{task-id}/fixture-{scenario-slug}-output.md`.

### P2-2: No negative fixture concept

The current design only tests "does the pack produce expected markers?" It does not test "does the agent produce something different WITHOUT the pack?" The ViMax upgrade had both pre- and post-upgrade outputs, which is exactly this comparison. The fixture format could optionally support a `## Baseline (No Pack)` section describing what generic output looks like, so future reviewers can see the delta.

This is explicitly out of scope for MVP (acknowledged in Intent Statement), but worth noting for v2.

### P2-3: Template file should include the staleness check command

If P1-1 is accepted, the template file (`pack-example-fixture.md`) should include the staleness validation command as a comment block, so future pack authors get it for free.

---

## Overall Assessment

**Verdict: CONDITIONAL PASS**

Conditions for PASS:
1. **P0-1**: Add structural marker requirement (at least 1 of min_marker_count markers must assert output structure, not just vocabulary). Update section 4.2 format and section 4.3 design rules.
2. **P0-2**: Add a second fixture for video-creation (different scenario, can be minimal). Update Files to Modify table and Evidence Manifest accordingly.

The handoff demonstrates strong grounding (research evidence, prior audit findings, existing ViMax precedent) and appropriate MVP scoping. The fixture format is well-designed for its purpose. The two P0s are about ensuring the mechanism actually proves what it claims to prove -- without them, we risk building a more sophisticated version of the same validation theater the YOLO audit flagged.

The P1 issues are all about lifecycle durability -- making sure fixtures remain valuable as packs evolve, rather than becoming stale assertions that pass for the wrong reasons.

---

**Reviewed by**: Product Expert
**Review method**: Full handoff read + cross-reference against idea file, research findings, existing ViMax fixture, install.sh source, and Blake/Alex SKILL.md
