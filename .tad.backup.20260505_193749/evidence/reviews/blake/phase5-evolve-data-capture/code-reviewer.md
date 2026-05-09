# code-reviewer — Phase 5 Evolve Data Capture (Blake-side Layer 2)

**Date**: 2026-04-25
**Reviewer**: code-reviewer (Blake's Layer 2 expert review)
**Handoff**: `.tad/active/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md`
**Review pass**: 1 (post-implementation)

---

## Summary

Phase 5 implements 8 deliverables (4 native + 4 strategic injects) building a data-capture substrate for a future `*evolve` consumer. Implementation quality is **strong overall**: the 9 P0 + 8 P1 expert findings from Alex's pre-handoff review are all integrated correctly, the strict prompt-level constraint (Anti-Epic-1) is honored, and the dogfood signal looks good (21/22 ACs PASS via spec-compliance grep, 10/10 askuser fixtures, 5/5 trace-digest fixtures, perf 46/59ms target met).

I am calling **CONDITIONAL PASS** with one P1 (multi-select selection-data loss) and four P2/P3 polish items. Nothing here is blocking for Phase 5 sign-off — the P1 is a *forward-compat* concern about data fidelity that future *evolve consumers will hit when they try to read multi-select decisions, and Phase 5's stated mission is "data capture substrate." A targeted ~6-line jq fix would close it cleanly; if you'd rather defer, document the gap explicitly in §12 Forward Compatibility Notes so *evolve doesn't silently misinterpret the data.

Acknowledging good work first:
- The slug derivation is genuinely well-engineered. Single source of truth (`HANDOFF-*.md` filename scan in cwd), strict whitelist (`^[a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_]$`) shared between askuser-capture.sh and trace-step.sh, BSD-then-GNU stat fallback for newest-mtime tiebreak, graceful degradation when 0 active handoffs exist. This pattern should be lifted into project-knowledge as a reusable template.
- Privacy boundary (NFR3) is correctly enforced: when `is_other=true`, selection is replaced with literal `"<other>"` BEFORE being handed to jq for JSONL emission. Verified via fixture-other-no-secret.json — `SECRET_OTHER_CONTENT_xyz123` does not appear anywhere in JSONL output. AC-P5.2-e PASS.
- The "consolidate 9 jq spawns into 1 single-pass jq + RS-separated read" is a textbook application of the architecture.md 2026-04-07 "Hook Performance" lesson and lands the hook at 46ms median / 59ms p95, comfortably under the 50/100ms targets.
- Symmetric forbidden_implementations on cancel_protocol (5 items, parity with *express/*experiment/skip_KA) is correctly applied per BA-P0-3 / Path Layering 2026-04-24 lesson. Step6 explicitly says "Do NOT add `## Gate 4` section to handoff" so the *cancel-vs-*accept distinction is structurally enforced (AC-P5.3-f).

---

## Three-Pass Findings

### Architecture Pass

**A1 (positive)**: The dual-sink design in `trace-step.sh` (canonical date-keyed = hard, per-handoff = best-effort) correctly applies the "preserve existing behavior, add new behavior as additive" principle. Failure on per-handoff write does not propagate to date-keyed write — explicit AC-P5.4-f satisfied. Good defensive layering.

**A2 (positive)**: The 4-layer (frontmatter / SKILL / hook / domain) data-flow handoff diagram in §4.1 is grounded in actual file paths and matches the implementation.

**A3 (P3)**: `cancel_protocol` is a top-level YAML block under SKILL.md (line 2578), siblings with `acceptance_protocol`. The handoff §6.6 Insertion Point Map said "0-space (top-level sibling)" — applied correctly. But there's a structural question: SKILL.md is a single ~2800-line file, and cancel_protocol joins ~12 other top-level protocols. Future readers may struggle to discover *cancel — the only entry points are the `commands:` block at line 189 and the *cancel rationale comment at line 2570. Consider adding a one-line cross-reference in `intent_router_protocol` step3 listing *cancel alongside *bug/*idea/etc. (Not blocking — Phase 5 scope was substrate, discovery layer is documentation polish.)

### Implementation Pass

**🟡 IMPL-P1: Multi-select misclassification — valid label combinations recorded as `is_other:true, selection:"<other>"`** (CRITICAL for *evolve fidelity)

`askuser-capture.sh:53-63` joins multi-select arrays with `", "` (line 57) producing a single string like `"P, Q"`, then computes `is_other` via `($labels | index($sel)) == null` (line 63). Since `["P","Q"]` does not contain the joined string `"P, Q"`, multi-select with all-valid labels gets classified `is_other:true` and the privacy path overwrites SELECTION with `"<other>"` (line 89-91), erasing the actual user choice.

Verified empirically:

```
$ printf '{...,"options":[{"label":"P"},{"label":"Q"}],"multiSelect":true},...,"answers":{"q3?":["P","Q"]}}' | bash askuser-capture.sh
$ cat decisions/2026-04-25.jsonl
{"...","selection":"<other>","is_other":true,"multi_select":true}
```

The fixture-multiselect test (askuser-capture-test.sh:100-103) only asserts `multi_select == true` — it never checks is_other or selection content, so the bug ships undetected.

**Why this matters for Phase 5's stated mission**: Phase 5 §12.3 states "These 4 schemas WILL be consumed verbatim by *evolve. Renaming any field or restructuring any source after Phase 5 ships is a breaking change." If multi-select rows always carry `selection:"<other>"`, *evolve cannot tell `["P","Q"]` from `["P"]` from a free-text "Hello world" — they all look the same. The point of capturing user decisions is lost on multi-select questions, which Alex *does* use (e.g., `analyze` step1 sometimes asks user to select multiple priority dimensions).

**Suggested fix** (non-blocking; ~6 lines of jq):

```jq
| (
    if ($direct | type) == "array" then
      # All array members must be in $labels for is_other:false
      (($direct | map(. as $x | ($labels | index($x)) != null) | all) | not)
    elif $sel != "" and (($labels | index($sel)) == null) then true
    else false
    end
  ) as $is_other
```

And in bash, when array selection AND is_other=false, store SELECTION as the JSON array (not joined string) so *evolve sees `["P","Q"]` not `"P, Q"`. If you want to keep SELECTION as a string for schema simplicity, store the JSON-encoded array string `"[\"P\",\"Q\"]"`.

Add fixture-multiselect-validity assertion: `is_other == false` AND `selection` is the JSON array (or the joined string of valid labels).

**Disposition**: I'd call this P1 because multi-select capture is a substantial chunk of *evolve's value (it's how Alex captures multi-dimensional preference signals). If you defer, please add an explicit note in §12.4 "Known forward-compat issues" so future-you doesn't query the data assuming it's accurate.

---

**🟡 IMPL-P2: "Atomic append via tmpfile + cat >>" comment is misleading** (askuser-capture.sh:150)

Line 166 does `cat "$TMPFILE" >> "$OUTFILE"`. This is a shell append, not an atomic file-system rename. Atomicity here comes from POSIX guarantees on `write(2)` calls smaller than PIPE_BUF (4KB on macOS, 4KB on Linux) when the file is opened with O_APPEND — which `>>` does. JSONL lines are typically 200-400 bytes, well within the safe range. So **the behavior is correct**, but the comment claims "tmpfile + atomic mv" semantics that aren't actually being delivered. The tmpfile staging here only catches the case where jq itself fails to produce output (the `[ -s "$TMPFILE" ]` guard).

**Suggested**: Replace comment with truthful description, e.g.:

```bash
# Stage jq output to tmpfile so jq parse failure (empty output) is caught
# before contaminating OUTFILE. The actual atomicity of >> append for lines
# < PIPE_BUF (~4KB) is guaranteed by POSIX O_APPEND semantics.
```

Or, if you want true atomic append-or-nothing: write the assembled JSONL line to tmpfile, then `cat tmpfile output > new && mv new output` (rename is atomic on same FS). For Phase 5's use case (best-effort capture), the current approach is fine; just fix the comment.

---

**🟡 IMPL-P3: askuser-bench.sh median/p95 indices are off-by-one** (askuser-bench.sh:56-58)

```awk
median = a[int(n*0.5)+1]   # n=100 → a[51]
p95 = a[int(n*0.95)+1]     # n=100 → a[96]
```

The textbook nearest-rank percentile for N=100 is `a[ceil(0.5*N)] = a[50]` for median and `a[ceil(0.95*N)] = a[95]` for p95. The `+1` is incorrect.

The actual gap empirically (from your TSV): a[50]=45.7, a[51]=45.9 — within 0.2ms, doesn't change the verdict. But the formula is technically wrong and will become a problem if N changes (e.g., for N=1000, off-by-one drift compounds).

**Suggested fix**:

```awk
median = a[int(n*0.5+0.5)]
p95 = a[int(n*0.95+0.5)]
```

Or use `int((n-1)*0.5)+1` for the explicit "lower median, integer index" form. Document the convention in a comment so the next person doesn't "fix" it back.

---

**🟢 IMPL-P4: trace-step.sh per-handoff `mkdir -p` race window** (trace-step.sh:113)

If two parallel trace-step.sh invocations both detect `PER_DIR` doesn't exist and both call `mkdir -p`, one will succeed silently and the other will succeed silently (idempotent semantics of `-p`). No race. Good. Just calling out for completeness — verified, not a finding.

---

**🟢 IMPL-P5: trace-digest.sh `$STATS | jq -r '.field'` is 6 jq spawns, but advisory CLI not on hot path** (trace-digest.sh:88-93)

For an advisory CLI invoked once at Gate 4, six jq spawns is fine (~600ms total). If you ever invoke trace-digest on a tight loop, consolidate to a single `jq -r '[.step_start, .step_end_completed, ...] | @tsv'` and bash `read -r`. Not worth changing now.

---

### Quality Pass

**🟢 Q1 (positive)**: All shell scripts use `set -u` (askuser-capture, trace-digest) or guard required args explicitly (trace-step). No `set -e` — appropriate given Anti-Epic-1 mandate of "always exit 0 on advisory paths". `IFS=$'\n\t'` in trace-digest is good defensive practice.

**🟢 Q2 (positive)**: BSD-then-GNU stat fallback (`stat -f%m -- "$f" 2>/dev/null || stat -c%Y -- "$f" 2>/dev/null || echo 0`) correctly handles macOS BSD as primary. Per architecture.md "Hook Shell Portability" — no `grep -P`, no `EPOCHREALTIME`, no `gdate +%s%N`. ✓

**🟢 Q3 (positive)**: `[[ "$slug" =~ ... ]]` regex match in trace-step.sh:65 and trace-digest.sh:35 is bash-3.2-compatible. Whitelist matches layer2-audit.sh exactly per BA-P0-4 lesson.

**🟡 Q4 (P3)**: `askuser-capture.sh` line 39 comment says "(perf: avoid 6+ jq spawns per architecture.md ...)" but the actual count saved is ~9 (one per field × 7 fields + is_other compute + nested selection extraction). Tighten the comment.

**🟢 Q5 (positive)**: trace-digest.sh ANSI color logic correctly checks both `$NO_COLOR` and `[ -t 2 ]` so non-TTY captures (CI logs, redirected stderr) don't get garbled escape codes.

**🟡 Q6 (P3) — handoff §9.1 AC-G2 verification command bug**: The grep regex assumes 3-field grep output (`file:line:content`) but `grep -n` on a single file produces 2-field output (`line:content`). This breaks the verification — results.tsv shows AC-G2 FAIL while the actual code is correct (5 `exit 0` lines verified manually). Document for Alex Gate 4 attention. The intent is "askuser-capture.sh contains only `exit 0`" which the implementation satisfies. Suggested fixed verification: `grep -nE '^[[:space:]]*exit [0-9]+' .tad/hooks/lib/askuser-capture.sh | grep -vE ':[[:space:]]*exit 0[[:space:]]*$' | wc -l` should return 0.

**🟢 Q7 (positive)**: `frontend-design.md` correctly mirrors security.md's foundational+accumulated structure, includes both `Grounded in:` (with comma+space-separated list, no line ranges) and `Revalidated: 2026-04-25` per Phase 2 P2.1 grammar. AC-P5.7-b PASS.

**🟢 Q8 (positive)**: project-knowledge/README.md new section is correctly placed AFTER `## Quantity Limits & Consolidation` (line 84) and BEFORE `## What NOT to Record` (line 158) per insertion-point map. Cross-references `web-backend.yaml` UUID Pub/Sub as the canonical `applies_when` reference example — concrete, helpful.

---

## Verification Re-derivation (Alex Gate 4 evidence)

I re-derived the key numbers from primary evidence per the "Verify Files, Not Claims" protocol (architecture.md 2026-04-14):

| Claim | Re-derived | Match |
|---|---|---|
| askuser-capture-test 10/10 PASS | Ran from cwd, output `10 PASS, 0 FAIL` | ✓ |
| trace-digest-test 5/5 PASS | Ran from cwd, output `5 PASS, 0 FAIL` | ✓ |
| Perf median=46 p95=59 | a[50]=45.7 a[95]=58.9 from TSV (N=100) | ✓ within rounding |
| AC-G1 permissions.deny.length=0 | `jq '.permissions.deny | length' .claude/settings.json` → 0 | ✓ |
| AC-G3 no fail-closed token | `grep -c fail-closed askuser-capture.sh trace-digest.sh` → 0:0 | ✓ |
| AC-P5.5-b homogeneity | `yq '.capabilities.api_design.quality_criteria[] | type'` → only `!!str` | ✓ |
| AC-P5.7-a Warm Palette deletion | `grep -cE 'warm_palette|Warm Palette' web-ui-design.yaml` → 0 | ✓ |
| AC-P5.3-d forbidden_implementations | 5 MUST-NOT items in cancel_protocol confirmed | ✓ |

The one FAIL on results.tsv (AC-G2) is the documented verification-command bug, not a code bug.

---

## Anti-Epic-1 Audit (Cross-Cutting)

Phase 5's hardest constraint is "no new mechanical enforcement" (architecture.md 2026-04-15 lesson). I checked:

- **No PreToolUse deny added**: `.claude/settings.json` PreToolUse is unchanged; only PostToolUse + UserPromptSubmit got new entries. ✓
- **PostToolUse askuser-capture exits 0 on every path**: 5 `exit 0` calls confirmed (lines 25, 33, 78, 147, 170). No `exit 1`, no `exit 2`. ✓
- **trace-digest.sh CLI uses 0/1/2 advisory codes**: Exit 0 PASS, Exit 1 advisory FAIL (orphans/failed > 0), Exit 2 N/A (slug invalid or dir missing). It's a CLI not a hook, so 1/2 are fine — Alex SKILL step4d explicitly treats them as advisory ("not blocked"). ✓
- **No additions to permissions.deny**: confirmed via jq verification. ✓
- **forbidden_implementations on every new path-like feature**: cancel_protocol has 5 items per BA-P0-3 symmetric defense; gate4_delta step7d has 5 items; step4d implicitly inherits step4c's "advisory only" framing. ✓

Anti-Epic-1 compliance is solid. The Phase 3.C dep-guard.sh disaster path is not reproducible here.

---

## Order Invariant Verification (P5.7)

The handoff §6.2 Stage C mandated single-sequential agent for Stage C tasks (P5.5 → P5.6 → P5.7-create → P5.7-delete → P5.8). I checked git log to verify the order was preserved:

```
$ git log --diff-filter=A -- .tad/project-knowledge/frontend-design.md
$ git log -p .tad/domains/web-ui-design.yaml | grep -E '^-.*warm_palette'
```

No frontend-design.md "create" commit exists before this review (still uncommitted), but the file exists on disk and contains the migrated content. The web-ui-design.yaml shows `# P4.11.4 demoted to ... (P5.7 2026-04-25)` comment at line 800 confirming the deletion happened with awareness of the demote. Manual verification: the content of frontend-design.md's "Warm Palette Interpretation Rule - 2026-04-25" entry is more comprehensive than what was in web-ui-design.yaml (added context about *why* this is project-knowledge, cross-references the README rule). This indicates Stage C order was honored — the create came first with proper migration intent, then the delete was clean.

If you want a hard guarantee, recommend a single commit that bundles both changes so a future bisect can't land on the broken intermediate state.

---

## Severity Summary

| Severity | Count | Items |
|---|---|---|
| 🔴 Critical (P0) | 0 | — |
| 🟡 Important (P1) | 1 | IMPL-P1 multi-select misclassification |
| 🟢 Suggestions (P2/P3) | 5 | IMPL-P2 comment, IMPL-P3 percentile off-by-one, A3 cancel discoverability, Q4 comment count, Q6 AC-G2 cmd bug |

---

## Verdict

**CONDITIONAL PASS — recommend addressing P1 (multi-select) before commit, or explicitly deferring with §12 Forward-Compat note.**

If P1 is fixed: Full PASS. If deferred with note: PASS with documented caveat.

The core Phase 5 substrate is solid. Slug derivation, privacy boundary, dual-sink trace, symmetric forbidden_implementations, ADR re-anchor, Warm Palette demote, and meta-rule documentation all land correctly. The single P1 affects data fidelity for one specific input shape (multiSelect=true) which Alex does use occasionally; deferring is a defensible call as long as it's documented so *evolve doesn't silently consume corrupt data later.

---

## Architecture.md Knowledge Entry Candidates (AC-G4)

Per AC-G4 conditional, I observed these surprises during review that warrant entries:

1. **"Multi-select capture without per-element membership check loses signal" — 2026-04-25**: Joining a multi-select array to a string before testing membership against a label list always returns "no match" → forces is_other=true → privacy-replacement erases the data. Lesson: when a privacy-boundary check is downstream of a capture transform, validate at the elementwise level not the joined level. Applies to any future capture hook handling array-shaped user input.

2. **"Per-handoff dual-sink dir creation must verify directory existence not file existence — but slug derivation must verify file pattern match before extracting"** — covered implicitly by trace-step.sh:43-44 (`-e "${matches[0]}"`) as per BA-P0-4 fix; worth a brief callout in architecture.md as the "glob-then-test" pattern that survives "no matches" gracefully on bash 3.2.

3. **"YAML inline `[applies_when: ...]` annotation preserves Pack schema homogeneity"** — covered in P5.5 design + frontend-design.md cross-reference. Not new architecture knowledge, but worth promoting to a Domain Pack authoring convention in `.tad/project-knowledge/architecture.md` so future Pack edits don't reach for dict polymorphism by default.

If Blake decides multi-select fix lands in this handoff, entry #1 should reference the fix commit. If deferred, entry #1 should reference §12.4 with the open-issue tag.

---

**Reviewer**: code-reviewer
**Date**: 2026-04-25
**Pass**: 1
**Verdict**: CONDITIONAL PASS (1 P1 + 5 P2/P3)
