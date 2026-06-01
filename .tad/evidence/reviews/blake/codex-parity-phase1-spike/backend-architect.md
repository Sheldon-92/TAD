# Backend Architect Review: Codex-Edition Parity Phase 1 Spike

**Reviewer:** backend-architect
**Date:** 2026-06-01
**Artifacts Reviewed:**
- `.tad/evidence/spikes/codex-parity/parity-check.sh`
- `.tad/evidence/spikes/codex-parity/parity-criterion.md`
- `.tad/evidence/spikes/codex-parity/spike-report.md`
- `.tad/evidence/spikes/codex-parity/regen-procedure.md`
- `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md` (the output artifact)
- `.tad/portable-rules.md`

**Verdict:** CONDITIONAL PASS (2 P0, 5 P1, 4 P2)

---

## Review Methodology

This review focuses on architectural soundness, edge-case correctness, and honest representation. Where the code-reviewer examines line-level bugs, this review examines whether the design's invariants actually hold when tested against the spike's own output artifacts.

---

## P0 Findings (Blocking)

### P0-1: The Parity Check Measures Structural PRESENCE, Not Content FIDELITY -- the Regen Proves the Gap

The 3-layer check verifies:
- Layer 1: protocol KEY names exist (substring grep)
- Layer 2: constraint keyword count above a ratio floor
- Layer 3: feature-marker tokens appear somewhere

This means a protocol section can be condensed to a single sentence containing the key name and still PASS all 3 layers. The regen artifact proves this is not hypothetical:

| Metric | Source (5873 lines / 326KB) | Stripped protocols (~1862 lines) | Expected post-strip | Regen actual | Retention |
|--------|-------|-------|-------|-------|-------|
| Lines  | 5873 | ~1862 | ~4011 | 1335 | 33% |
| Bytes  | 326KB | ~98KB | ~228KB | 49KB | 21% |

67% of the non-stripped content was condensed away. The regen procedure (Step B) explicitly states: "The transform is LINE-LOCAL strip/replace, NOT summarization. Do not condense protocol prose." Yet the output is 21% of the expected post-strip size.

Concrete evidence of content loss (not inside any stripped protocol):
- **Ralph Loop**: source has 3 references in non-stripped sections (lines 58, 5678, 5745) -- regen has 0. The Preserve list in portable-rules.md says "Ralph Loop protocol logic" must NEVER be deleted. No layer catches this.
- **"Writing implementation code" forbidden action**: source line 5679 -- absent from regen. No layer catches this.
- **"Blake Executes" workflow step**: source line 5745 -- absent from regen.

The fundamental problem: the `<=100KB` size target in portable-rules.md structurally contradicts the "NOT summarization" transform rule. A line-local transform of ~228KB post-strip content CANNOT produce <=100KB. The size target implicitly mandates the very condensation the regen procedure forbids.

**Fix:** This is an architectural decision, not a code fix. Three options:
1. **Raise the size target** to ~250KB (full-fidelity transform). Codex can handle it -- the 100KB ceiling was a guess, not a measured limit.
2. **Add a line-ratio or byte-ratio check** as Layer 1.5: `codex_lines / (source_lines - stripped_lines) >= 0.60`. This would catch the current 33% while allowing legitimate whitespace trimming.
3. **Acknowledge controlled condensation is acceptable** and rewrite the regen procedure to define what condensation is permitted (e.g., "YAML comments may be stripped; numbered step prose must be preserved verbatim"). The current contradictory state is the worst outcome.

### P0-2: `printf "$missing_list"` Is a Format-String Bug (parity-check.sh:81)

Line 81:
```bash
printf "$missing_list"
```

The variable `missing_list` is used as a printf format string. If any content in the variable contains `%s`, `%d`, `%n`, etc., printf interprets them as format specifiers. A `%s` would consume the next argument (empty = empty output); `%n` on some systems writes the byte count to memory.

Current protocol names are `[a-z_]+` (no `%` possible), so this is not exploitable TODAY. However:
1. The pattern is objectively wrong -- a variable should never be a format string unless intentionally.
2. The script is designed for reuse; future source SKILLs may contain annotations that flow into `$proto`.
3. The `marker_list` variable (line 171) follows the same pattern but is never printed (dead code).

**Fix:** Replace line 81:
```bash
printf '%b' "$missing_list"
```
`%b` interprets `\n` escape sequences (which the variable contains as literal backslash-n) while treating all other content as literal text.

---

## P1 Findings (Important)

### P1-1: Constraint Floor Formula Disagrees Across 3 Files

| File | Formula | Result for source=150 |
|------|---------|----------------------|
| parity-check.sh line 106 | `source / 10` (10%), min 10 | floor = 15 |
| parity-criterion.md line 37 | `source / 10` (10%), min 10 | floor = 15 |
| regen-procedure.md Step F | `source * 0.07` (7%), min 10 | floor = 10.5 -> 10 |

The 10% vs 7% discrepancy produces different floors once the source count exceeds 142 (where 7% of 143 = 10.01 > 10 min, but 10% of 143 = 14.3). With the current source count of 150, the parity check uses floor=15 while the regen self-check uses floor=10. The regen could pass its own self-check but fail the parity check if the count lands between 10 and 15.

**Fix:** Align all three files to a single formula. Recommendation: parity-check.sh's `source / 10` is the canonical gate; update regen-procedure.md Step F.

### P1-2: Spike Report Contains Internally Inconsistent Numbers

Within the same spike-report.md:

| Location | Constraint count | Floor |
|----------|-----------------|-------|
| Test 2 narrative (line 61) | 57 | 13 |
| Regen Guard table (line 75) | 59 | >= 10 |

Actual measurement (2026-06-01): regen has 59 constraint occurrences, source has 150, floor = 150/10 = 15.

The narrative's "57" and "floor=13" (implying source=130) appear to be from an earlier run against a different source version. The guard table's "59" matches the current artifact. The report presents two contradictory measurements of the same file without noting the discrepancy.

**Fix:** Re-run the parity check against the committed artifacts and update all numbers in the spike report to be self-consistent.

### P1-3: portable-rules.md Nested-Ignore List Is Missing `archive_protocol`

parity-check.sh `NESTED_IGNORE` contains 5 entries. portable-rules.md's nested list contains only 4 -- it omits `archive_protocol`. parity-criterion.md correctly includes all 5 with the note "archive_protocol (nested inside test_review_protocol)".

Verified: `archive_protocol:` appears at source line 418, indented inside `test_review_protocol:` which starts at line 405. It is genuinely nested.

The discrepancy means portable-rules.md (the stated "single source of truth") disagrees with both the script and the criterion doc.

**Fix:** Add `archive_protocol` to portable-rules.md line 83:
```
`per_phase_protocol`, `blocking_in_alex_protocol`, `fallback_protocol`,
`honest_partial_protocol`, `archive_protocol`
```

### P1-4: Layer 2 Covers Only 4 of 17 Preserve-List Items

portable-rules.md "Preserve -- NEVER Delete" lists 17 categories of content that must survive the transform. Layer 2 of parity-check.sh verifies only 4:
- AskUserQuestion = 0 (strip check, not preserve)
- MUST/MANDATORY/VIOLATION keyword floor
- `anti_rationalization_registry` present
- `forbidden_implementations` present

The remaining 13 are unchecked:
- `honest_partial_protocol` (benign in this case: all 4 source refs are inside the stripped yolo_execution_protocol)
- **Ralph Loop protocol logic** (NOT benign: 3 source refs in non-stripped sections, 0 in regen)
- Gate 3 v2 checklist structure
- Knowledge Assessment protocol
- Completion report protocol
- Handoff reading/paraphrasing protocol
- Socratic inquiry protocol / Adaptive complexity protocol
- Intent router protocol routing logic
- Handoff creation protocol / Acceptance protocol
- All `path_transitions` / `forbidden` rules
- Evidence directory structure and slug contract

The Ralph Loop gap is concrete and proven by the regen artifact.

**Fix:** Add high-value Preserve items as Layer 2 grep guards. Minimum set (~6 lines of script):
```bash
for marker in "Ralph" "honest_partial" "path_transitions" "Knowledge Assessment" "Gate 3" "Socratic"; do
  count=$(grep -c "$marker" "$CODEX_EDITION" 2>/dev/null) || true
  count=${count:-0}
  echo "  Preserve marker '$marker': $count"
  if [ "$count" -eq 0 ]; then
    echo "  FAIL: Preserve marker '$marker' absent"
    DRIFT=1
  fi
done
```

### P1-5: Regen References Claude Code Paths That Do Not Exist on Codex

The regen edition preserves reference stubs like:
```yaml
reference: ".claude/skills/alex/references/bug-path-protocol.md"
```

On a Codex installation, `.claude/skills/alex/references/` does not exist. 9 protocols use this pattern. The Codex agent would encounter dead references -- it cannot auto-load them (no Read-on-reference mechanism), so the referenced protocol content is simply unavailable.

This is a deployment-level gap, not a parity-check bug. But it means 9 of the 22 "must-cover" protocols are structurally hollow in the Codex edition: the key name exists (Layer 1 passes) but the content is unreachable.

**Fix for P2 scope:** Either (a) inline the referenced protocol content during regen (increases size but provides fidelity), or (b) copy the reference files into `.tad/codex/references/` and remap paths.

---

## P2 Findings (Minor)

### P2-1: Layer 1 Uses Substring grep, Not Exact-Key Match (parity-check.sh:66)

`grep -q "$proto" "$CODEX_EDITION"` is a substring match. `exit_protocol` would match inside a hypothetical `yolo_exit_protocol_handler`. Current names make collisions unlikely, but the check could be tightened.

**Fix for P3:** `grep -qF "${proto}:"` (match key with colon) or `grep -qw "$proto"` (word boundary -- `_` is a word char, so this works for `[a-z_]+_protocol`).

### P2-2: `marker_list` Variable Is Built But Never Used (parity-check.sh:146,171)

`marker_list` accumulates MISSING markers but is never printed or consumed. Dead code.

**Fix:** Remove lines 146 and 171.

### P2-3: `grep -coE` Semantics Are Non-Obvious and Undocumented

Lines 102-104 use `grep -coE` which, on BSD macOS, counts each match occurrence (not matching lines). This is correct and produces the intended constraint count. But `-co` together is unusual -- most developers expect `-c` to count lines. The behavior was empirically verified to be correct on macOS, but a comment would prevent future confusion during maintenance or Gate 4 recompute.

**Fix:** Add inline comment:
```bash
# -coE on BSD: -o makes each match a separate "line", -c counts those = per-occurrence count
```

### P2-4: No Reverse-Direction Check (Codex-Only Additions)

The parity check verifies "everything required from source IS in Codex" but not "nothing extra was hallucinated INTO Codex." During LLM-based regen, the model could invent protocol blocks that don't exist in the source. This is acceptable for P1 but should be a P3 hardening item.

---

## Positive Observations

1. **Exit-code contract is clean and pinned** -- 0 (parity) / 1 (drift) / 2 (usage error), explicitly carried to P3. This is a well-designed CLI interface.

2. **Expected-absent allowlist is well-reasoned** -- all 9 protocols are genuinely Conductor/automation-only. No user-facing protocol is incorrectly listed. Verified each entry.

3. **Anti-theater discrimination is genuine** -- the live drifted edition correctly FAILS on both Layer 1 (8 missing protocols) and Layer 3 (4 missing markers) before the regen PASSES. The check is not rubber-stamping.

4. **Headless probe is honestly marked UNPROVEN** -- the report does not claim a capability it did not demonstrate. The pivot decision explicitly carries this as a P2 residual.

5. **BSD/macOS safety is maintained throughout** -- no `grep -P`, `LC_ALL=C` on sort operations, `set -euo pipefail`, proper quoting of file paths with spaces. The script handles the TAD project path (which contains spaces) correctly.

6. **Nested-ignore classification is correct** -- all 5 entries are genuinely indented sub-keys or inline prose, verified against source indentation.

7. **Blake residual risk section is honest** -- the report quantifies the Blake-vs-Alex difference (Agent refs 24 vs AskUserQuestion 82) and explicitly states the alex regen does not prove Blake works.

---

## Summary Table

| ID | Severity | Finding | Location |
|----|----------|---------|----------|
| P0-1 | P0 | Parity check measures presence not fidelity; regen is 21% of expected size; Ralph Loop dropped; size target contradicts no-summarization rule | parity-check.sh (architectural), portable-rules.md size target, regen artifact |
| P0-2 | P0 | printf format-string bug: variable used as format string | parity-check.sh:81 |
| P1-1 | P1 | Constraint floor formula disagrees: 10% (script+criterion) vs 7% (regen-procedure) | parity-check.sh:106, regen-procedure.md Step F |
| P1-2 | P1 | Spike report has internally inconsistent numbers (57 vs 59 constraints, floor=13 vs actual 15) | spike-report.md:61,75 |
| P1-3 | P1 | portable-rules.md nested list missing `archive_protocol` (script has it, criterion has it) | portable-rules.md:82-84 |
| P1-4 | P1 | Layer 2 checks 4 of 17 Preserve items; Ralph Loop (3 non-stripped refs) is concretely dropped | parity-check.sh Layer 2, regen artifact |
| P1-5 | P1 | Regen references `.claude/skills/alex/references/` paths unreachable on Codex | codex-alex-skill.regen.md (9 protocol stubs) |
| P2-1 | P2 | Layer 1 substring grep could false-match on comments | parity-check.sh:66 |
| P2-2 | P2 | `marker_list` variable built but never used (dead code) | parity-check.sh:146,171 |
| P2-3 | P2 | `grep -coE` semantics non-obvious, should be documented | parity-check.sh:102-104 |
| P2-4 | P2 | No reverse-direction check for hallucinated Codex-only additions | parity-check.sh (architectural) |

---

## Recommended Fix Priority for P2 Handoff

1. **Resolve the size-target vs fidelity contradiction** (P0-1 + P1-5) -- this is a design decision, not a code fix. Choose one of the three options in P0-1.
2. **Fix printf format-string** (P0-2) -- 1-line change, `printf '%b' "$missing_list"`.
3. **Align floor formula** (P1-1) -- update regen-procedure.md to match `source / 10`.
4. **Add `archive_protocol` to portable-rules.md** (P1-3) -- 1-line addition.
5. **Add Preserve-item grep guards** (P1-4) -- ~10 lines of script.
6. **Re-run check and fix spike report numbers** (P1-2) -- re-measure and update.
7. **Remove dead `marker_list` code** (P2-2) -- delete 2 lines.
