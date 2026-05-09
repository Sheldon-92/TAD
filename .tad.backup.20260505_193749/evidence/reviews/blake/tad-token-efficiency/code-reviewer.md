# Code Review — HANDOFF-20260427-tad-token-efficiency

**Reviewer**: code-reviewer (sub-agent invocation)
**Date**: 2026-04-27
**Handoff**: `.tad/active/handoffs/HANDOFF-20260427-tad-token-efficiency.md`
**Scope**: Prose-edit correctness, BSD/macOS portability, YAML indent preservation, constraint preservation
**Mode**: REVIEW only — no implementation, no handoff modification

---

## Summary

Pure-prose handoff installing 3 token-saving levers (L1 tiered Layer 2 / L2 lazy knowledge / L4 *express ≤5) across 4 edit regions in 2 SKILL files. Self-referential dogfood: respects current ≥2 reviewer rule before installing the relaxation.

I verified each cited line number against the actual SKILL files, executed the BSD-portability-sensitive grep commands on stock `/usr/bin/grep` (BSD grep 2.6.0-FreeBSD), and ran the `awk` command from §4.2 File 4 against the handoff itself. Findings are real but mostly P1 — the design is sound; the issues are AC-precision and one self-contradiction the edit list misses.

**Verdict**: CONDITIONAL PASS — must fix the self-contradiction at Alex SKILL line 996 (P0) before Blake commits, plus tighten 3 AC verification commands (P1) ideally before Blake starts so the AC-Drift-4-Phases pattern doesn't recur for a 5th time.

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1: L4 widening misses a contradicting `>3 files` reference at Alex SKILL line 996

**Issue**: The handoff §4.2 File 3 specifies edits to `file_count_max: 3` (line 949) and 3 occurrences of `≤3` / `>3` inside `over_limit_action` (lines 951-955). However, `grep -n "≤3\|>3 file"` against the current Alex SKILL returns ANOTHER occurrence the handoff does NOT cover:

```
996:    - "Anything affecting >3 files (use over_limit_action AskUserQuestion)"
```

This sits inside `express_path_protocol.when_NOT_appropriate`. After L4 lands, the SKILL becomes self-contradictory:
- `scope_constraints.file_count_max: 5` says "≤5 files OK"
- `when_NOT_appropriate: "Anything affecting >3 files (use over_limit_action ...)"` says "anything >3 is forbidden"

A Blake (or the model itself) reading both could reasonably conclude that `*express` is now still effectively capped at 3 — defeating the L4 lever entirely.

**There is also a 3rd reference at line 3** (the SKILL's `description:` frontmatter): `Use for new features (>3 files), architecture changes, ...`. This is the cutoff for entering Standard `*analyze` mode (i.e., the threshold above which Alex shouldn't use *express's parent), and is conceptually separate from the *express limit. **Probably leave line 3 alone** — Standard TAD's lower bound for "you should use Alex" is independent of the *express upper bound. But document this distinction, because Blake might "tidy up" line 3 reflexively.

**Fix recommendation**:
- In handoff §4.2 File 3, add a 3rd Edit step:
  > Replace line 996 `"Anything affecting >3 files (use over_limit_action AskUserQuestion)"` with `"Anything affecting >5 files (use over_limit_action AskUserQuestion)"`.
- Add to §6 Phase 4 verification:
  > `grep -c '>3 files' .claude/skills/alex/SKILL.md` should return 1 after L4 (only the line-3 description remains, which is intentionally about Standard TAD entry threshold not *express limit).
- Add to §10.4 Anti-Patterns:
  > ❌ "顺手把 line 3 description '>3 files' 也改成 '>5 files'" — line 3 is about Standard TAD entry threshold (when to use `/alex` at all), separate from *express ≤5 limit. Leave it.

This is the single most important fix. Without it, L4 silently doesn't work.

---

## Recommendations (P1 — should address)

### P1-1: §6 Phase 1 baseline assertion "AR-001 anchor count = 1" is wrong; actual = 2

**Evidence**:
```
$ /usr/bin/grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md | /usr/bin/grep -c 'expert review.*code-reviewer'
2
```

Both matches are within the 30-line window:
- Line 31 of grep output: comment `# The literal phrase "expert review" + "code-reviewer" must remain on consecutive`
- Line 36 of grep output: `- "step2 expert review with ≥1 expert (code-reviewer 必选; ≥1 expert; 视场景可加第 2 个)"`

§6 Phase 1 step 3 says "AR-001 grep anchor count must be ≥1 (currently 1)". AC10 says ≥1. AC10 won't fail on this regardless, but the floor isn't tight: if Blake accidentally damages BOTH lines 962 (the comment) AND 967 (the required_step), AC10 with floor ≥1 still passes if even one survives.

**Fix recommendation**: Change Phase 1 step 3 to "currently 2" and tighten AC10 to `≥ 2` (the actual baseline) so a single accidental deletion is caught.

### P1-2: AC11 + Phase 6 Step 1 baseline check has no truthy floor — Phase 1 must record the number

AC11: `grep -c "MANDATORY\|VIOLATION\|forbidden" ... ≥ Phase 1 baseline 数 (NFR2)`.

I confirmed the alternation works on stock BSD grep (`/usr/bin/grep` version 2.6.0-FreeBSD does support `\|` BRE alternation, contradicting the common myth). Today's baseline:
```
.claude/skills/alex/SKILL.md:64
.claude/skills/blake/SKILL.md:32
```

But "Phase 1 baseline 数" is referenced in AC11 as a side-band value Blake must record then re-compare in Phase 6. There is NO explicit slot in the handoff for Blake to write the recorded number — Phase 1 §6 just says "粘贴输出到 completion §AC verification table" without specifying a structured location. If Blake forgets to record + paste, AC11 verification has nothing to compare against.

**Fix recommendation**: Add to §6 Phase 1 a structured record block:
```
Phase 1 Baseline (Blake fills):
- alex SKILL constraint count: ___
- blake SKILL constraint count: ___
- AR-001 anchor count: ___
```
And reference these slots from AC10/AC11.

### P1-3: AC13 file-count check is fragile — background hook writes pollute `git diff --name-only`

AC13: `git diff --name-only \| grep -v "^\.tad/evidence/reviews/blake/tad-token-efficiency/" \| wc -l = 2`

I just ran `git diff --name-only` and got:
```
.tad/evidence/traces/2026-04-27.jsonl
.tad/sync-registry.yaml
```

These are background hook writes (trace events, sync-registry mtime touch), unrelated to Blake's SKILL edits. After Blake's 2 SKILL edits + commit, if the trace file has been touched again since the last commit, AC13 will count: 2 (SKILL files) + N (background-modified files) ≠ 2.

**Fix recommendation**: Either (a) move the AC13 check to "git status against HEAD AFTER commit, only staged diff matters" — `git diff --name-only HEAD~1 HEAD | grep -v ...`; OR (b) make the filter explicit-include rather than explicit-exclude:
```
git diff --name-only | grep -E '^\.claude/skills/(alex|blake)/SKILL\.md$' | wc -l  # = 2
```
The latter is more deterministic — it counts ONLY the 2 expected files and ignores everything else.

### P1-4: Phase 6 step 1 anti-regression checks have wrong expected values

Phase 6 §6 has these anti-regression assertions:
```
grep -c "step1 draft creation" .claude/skills/alex/SKILL.md  # = 1 (unchanged)
grep -c "NOT_via_alex_suggestion" .claude/skills/alex/SKILL.md  # = 1 (unchanged)
```

Actual baseline:
```
$ /usr/bin/grep -c "step1 draft creation" .claude/skills/alex/SKILL.md
2
$ /usr/bin/grep -c "NOT_via_alex_suggestion" .claude/skills/alex/SKILL.md
2
```

Both phrases occur twice (once in `*express required_steps` and once in `intent_router_protocol` or comment block). Asserted `= 1` will always FAIL even on a correct edit.

**Fix recommendation**: Update Phase 6 step 1 to `= 2` for both. Or just say `≥ 1` — it's an anti-regression check, the floor matters not the exact count.

### P1-5: §4.2 File 4 step 3.5 awk path may be wrong during step4c execution

Step 3.5's awk command targets `.tad/archive/handoffs/HANDOFF-{date}-{slug}.md`. But step4c runs during **Gate 4 acceptance**, when the handoff is still in `.tad/active/handoffs/` and has NOT been archived yet. The handoff line 320 has a parenthetical note:
```
(or current active path if not yet archived)
```
But this is prose, not a Bash fallback. Blake implementing this literally will only check the archive path → awk will print nothing → falls through to "empty / unrecognized → tier_threshold=2 (NFR1+NFR4 safe default)". Lucky safe-default save, but the semantic intent is broken: every active-state handoff hits the safe-default branch instead of reading the actual task_type.

**Fix recommendation**: Change the prose to specify the active path FIRST, with archive as fallback:
```yaml
3.5. **Read task_type** from handoff frontmatter (L1 tier rule, 2026-04-27):
     Run (try active first, then archive):
       awk '/^---$/{c++; if(c>=2)exit; next} c==1 && /^task_type:/{print $2}' \
         .tad/active/handoffs/HANDOFF-{date}-{slug}.md \
         .tad/archive/handoffs/HANDOFF-{date}-{slug}.md 2>/dev/null | head -1
```
The two-arg awk reads both files in order; the first match wins via `head -1`. `2>/dev/null` swallows the "not found" stderr from whichever path doesn't exist.

### P1-6: L2 lazy-load preserves prose that contradicts the new sequence

The handoff §4.2 File 2 "After" block ends at step 7 ("Brief output"). The §4.2 File 2 footnote says steps 5-9 of the original (knowledge matching scan + stale-check) are "保留 unchanged" and Blake renumbers them to 8-12. But the ORIGINAL step 5 prose starts with:
> "After reading all knowledge files, scan each entry..."

After L2 lazy-load lands, we are NOT reading all knowledge files — only matched ones. The prose "After reading all knowledge files" becomes factually wrong. Blake renumbering without rewording leaves a self-contradicting paragraph: step 4 says "skip non-matched" + step 8 (renumbered) says "After reading all knowledge files".

**Fix recommendation**: In §4.2 File 2, add an explicit instruction:
> Also reword the existing step 5 (which becomes step 8 after renumbering): change "After reading all knowledge files" → "After reading the matched knowledge files (per step 4)".

Or alternatively, fold the keyword-scan from old-step-5 into the new step 1 (since the new step 1 already does keyword identification, the entry-level scan can ride along in the same pass). That's a deeper rewrite; the simpler fix is just the reword.

### P1-7: AC10 anchor regex — `expert review.*code-reviewer` won't match cross-line

AC10 verification: `grep -A 30 'express_path_protocol:' .claude/skills/alex/SKILL.md | grep -c 'expert review.*code-reviewer'`

`grep -c` counts matching LINES. The pattern `expert review.*code-reviewer` requires both phrases on the same line. I confirmed both current matches are single-line. But future SKILL edits might split the literal phrase across lines (e.g., a YAML multiline scalar where "expert review" ends one line and "code-reviewer" starts the next). The regex would silently miss this — the anchor mechanically asserts presence-on-same-line, not presence-anywhere-in-window.

This is a known weakness of the AR-001 anchor design (precedes this handoff), not introduced by L4. But the handoff doesn't mention it. Worth a tiny note in §10.1 so a future contributor doesn't refactor the line break thinking the anchor still holds.

**Fix recommendation** (low priority, documentation-only):
> Add to §10.1: ⚠️ AR-001 anchor mechanically requires "expert review" and "code-reviewer" on the SAME line within the 30-line window. Do NOT split this phrase across lines or YAML multiline boundaries.

---

## Suggestions (P2 — nice to have)

### P2-1: YAML indent of new step 3.5 nested bullets uses 11-space hanging indent

The handoff §4.2 File 4 inserts step 3.5 at:
```yaml
      3.5. **Read task_type** from handoff frontmatter (L1 tier rule, 2026-04-27):
           Run: `awk ...`
           - If output is `code` OR `mixed` → tier_threshold=2
           ...
```

The leading "3.5." starts at column 6 (matches existing step 1, 2, 3 prefixes). The nested content (`Run:`, `- If output ...`) sits at column 11, hanging-indented under "Read task_type". Existing step 1 uses 9-space hanging (column 9, e.g. line 2304 `         ^(HANDOFF...`). Different indent style.

This won't break YAML parsing because the entire block is content of the `action: |` literal scalar, where indent is preserved verbatim and only the column-6 base must be ≥ the scalar's indent indicator. But it's stylistically inconsistent with the surrounding step prose. Minor.

**Fix recommendation**: Re-indent the nested bullets to 9-space hanging to match step 1's style. Cosmetic only.

### P2-2: §5.MQ2 "AR-001 grep anchor target ~line 970+" is approximate; actual line is 962+967

Line ~970 is approximately right (Section 5 MQ2 says "required `expert review.*code-reviewer` ≤30 lines after `express_path_protocol:` header"). Actual matches: line 962 (comment) and line 967 (required_step). Within tolerance, but tighter line refs would help a future grep-based reviewer.

### P2-3: `grep -c` exit code 1 on zero matches can confuse downstream `set -e` / `&&` chains

AC12: `git diff --name-only \| grep -c "layer2-audit.sh" = 0`. When grep finds 0 matches, exit code is 1 (not 0). If Blake naively chains via `&& echo "AC12 PASS"`, the echo never fires even though the count is correct. Use `grep -c ... || true` or `[ "$(... grep -c ...)" -eq 0 ]` to be safe.

This is a general gotcha for any "expected zero" grep AC (here AC5, AC7, AC12, AC13 partial). Worth a one-line note in §9.1 footer.

---

## Spot-Check Results (Verified)

| Check | Result |
|-------|--------|
| Blake SKILL `hard_requirement_distinct_reviewers.rule` location | ✅ at line 918 (handoff says 918+) |
| Blake SKILL `rule: |` content indent | ✅ 10 spaces (handoff append uses 8 spaces — see P1 below) |
| Alex SKILL `step0_5` location | ✅ at line 1655 (handoff says 1655+) |
| Alex SKILL `step0_5.action` content indent | ✅ 8 spaces (handoff "After" uses 8 spaces — match) |
| Alex SKILL `express_path_protocol.scope_constraints.file_count_max` location | ✅ at line 949 (handoff says 949) |
| Alex SKILL `step4c` location | ✅ at line 2295 (handoff says 2295+) |
| `awk '/^---$/{c++; ...}' ... HANDOFF.md` | ✅ Returns "yaml" — works on BSD awk |
| `/usr/bin/grep -c "MANDATORY\|VIOLATION\|forbidden"` | ✅ Returns 64+32 — BSD grep DOES support `\|` BRE alternation (myth busted) |
| AR-001 anchor baseline `grep -A 30 'express_path_protocol:' \| grep -c 'expert review.*code-reviewer'` | ✅ Returns 2 (handoff says "currently 1" — see P1-1) |
| `grep -c "self-review.md does NOT count" blake/SKILL.md` | ✅ Returns 1 (matches AC2 expectation) |

### Constraint preservation footprint (NFR2 baseline)

```
.claude/skills/alex/SKILL.md   MANDATORY=19  VIOLATION=25  forbidden=21  total=64
.claude/skills/blake/SKILL.md  total=32
```

Blake should record these in Phase 1 and re-verify ≥ baseline in Phase 6 (per AC11).

### Indent of Blake SKILL `rule: |` content vs handoff append

Looking at line 919-927 of `.claude/skills/blake/SKILL.md`:
- `rule: |` is at column 8
- Content lines are at column 10 (e.g., line 920 `          Layer 2 MUST invoke ≥2 DISTINCT sub-agents:`)

Handoff §4.2 File 1 append:
```yaml
        # P6-A.2 v2 (2026-04-27): tier rule by handoff frontmatter task_type
```
The handoff shows 8-space prefix in the markdown code block.

**Indent verification**:
- Existing content at column 10
- Handoff append at column 8

This is a 2-space mismatch. Is this YAML-valid? In a `|` literal block scalar, the indentation indicator is the smallest indent of any non-empty line. If the existing content is at column 10 and we add lines at column 8, the YAML parser will read those as OUTSIDE the literal block (because they have less indent than the established baseline) — meaning they get parsed as YAML structure, NOT as content of `rule:`.

**Verification needed**: The handoff should specify the append at column 10 (matching existing `Layer 2 MUST invoke ≥2 DISTINCT sub-agents:`), not column 8.

**Re-verifying my read of the handoff**: §4.2 File 1 lines 209-216 show the tier comment block with leading 8 spaces. But the surrounding `Choose by task fit ...` line (which the append targets to follow) is at column 12 actually (deeper because it's a continuation of the previous bullet `- PLUS ≥1 from layer2-audit.sh's KNOWN_REVIEWERS whitelist...`). Let me examine this more carefully.

Actually, looking at the actual file:
```
918:      hard_requirement_distinct_reviewers:
919:        rule: |
920:          Layer 2 MUST invoke ≥2 DISTINCT sub-agents:
921:          - code-reviewer (REQUIRED — every Layer 2 round)
922:          - PLUS ≥1 from layer2-audit.sh's KNOWN_REVIEWERS whitelist (canonical
923:            single source of truth — see `.tad/hooks/lib/layer2-audit.sh`
924:            top-of-file array). Choose by task fit (e.g., backend-architect for
925:            architecture handoffs; security-auditor for auth/secrets;
926:            performance-optimizer for hot-path; ux-expert-reviewer for UI; etc.).
```

`rule: |` is at column 9 (the `:` is at col 12, but `rule` starts at col 9). Content lines (920+) are at column 11 (`Layer 2`). Continuation indent (line 923 `single source`) is at column 13.

The handoff §4.2 File 1's append uses 8-space prefix. **This will break the YAML literal block** — the appended comment lines are LESS indented than the established 11-space baseline, so YAML parser will treat them as siblings of `rule:`, not content of `rule:`.

**P0-2 fix**: §4.2 File 1's append must use 11-space leading indent (matching `Layer 2 MUST invoke...`), not 8 spaces. Either fix the handoff's "新追加内容" code block, or add explicit instruction "preserve 11-space indent matching the existing rule content".

(Filing this as P0 because it changes from CONDITIONAL PASS to FAIL if Blake copies the handoff's 8-space indent verbatim.)

---

## Constraint Preservation Re-Verified (NFR2 — must hold post-edit)

Forbidden/VIOLATION/MANDATORY anchor words present in CURRENT files (must persist):

```
alex/SKILL.md:
  MANDATORY: 19 occurrences
  VIOLATION: 25 occurrences
  forbidden: 21 occurrences

blake/SKILL.md:
  Total (sum of MANDATORY|VIOLATION|forbidden): 32 occurrences
  Specific tokens not separately counted but include:
    - hard_requirement_distinct_reviewers (anchor)
    - self-review.md does NOT count (1 occurrence per AC2)
    - rationale_single_source (anchor)
    - exception_express, forbidden, forbidden_implementations
```

L1 (Phase 2): pure append, no deletion — should preserve all.
L2 (Phase 3): replaces step 1-4 of action — must verify steps 5-9 prose constraints survive.
L4 (Phase 4): pure number replace — preserves all.
L1 step4c (Phase 5): pure step insertion + step 4 replace — must verify step 5 prose constraints survive.

**No constraint violations identified in the design** — the prose-only nature of the changes is correctly bounded.

---

## Overall Assessment

**CONDITIONAL PASS — must fix P0-1 (line 996 contradiction) and P0-2 (Blake SKILL indent mismatch) before Blake starts implementation.** Design is sound; the failures are in AC precision and one missed contradiction-source the edit list overlooked.

After P0 fixes + P1 fixes (especially P1-3 AC13 fragility, P1-5 awk path order, P1-6 step 5 prose contradiction): clean PASS.

**Reviewer's note on the AC-Drift-4-Phases-In-A-Row pattern**: This handoff's §9.1 verification commands suffer the same "spec'd in head, not dry-run" failure mode the architecture.md entry warns about. The 4 P1 issues I found (P1-1, P1-2, P1-3, P1-4) all stem from no per-AC dry-run during drafting. The Phase 7+ Epic mentioned in §📚 history-lesson #4 needs to land — until then, this handoff joins the streak as 5-in-a-row.
