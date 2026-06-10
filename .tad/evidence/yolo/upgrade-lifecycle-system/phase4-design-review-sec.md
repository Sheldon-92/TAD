# Phase 4 Design Security Review — Merge Capability

**Reviewer**: security-auditor (code-security focus)
**Date**: 2026-06-10
**Scope**: HANDOFF-20260610-merge-capability-phase4.md + phase4-grounding.md
**Focus**: Malicious manifest injection, regex injection via marker, write atomicity, source/target confusion

---

## Threat Model

The migration engine processes YAML manifests that specify merge operations on user files.
The merge operation reads a source file and a target file, splits both at a marker string,
replaces the "head" of the target with the "head" of the source, and writes back.

**Trust boundary**: The manifest is authored by TAD framework maintainers and shipped in
`$SOURCE/.tad/migrations/`. In normal operation the manifest is trusted. However, a compromised
or malicious manifest (supply-chain attack on TAD itself, or a rogue *sync source) could
craft adversarial `marker` or `path` values. We review against that threat.

---

## Findings

### P0 — Critical (must fix before implementation)

#### P0-1: Non-atomic write — crash between truncate and mv leaves target destroyed

**Location**: Handoff Section 4.5 (revised approach), lines 349-358

**Description**: The design's "revised approach" writes to a temp file then `mv`s:
```bash
{
    head -n $((source_marker_line - 1)) "$source_file"
    tail -n +"${marker_line_num}" "$target_file"
} > "$tmp_file"
mv -- "$tmp_file" "$target_file"
```
The `mv` on the same filesystem is atomic (rename(2) syscall). This part is correct.
However, the `> "$tmp_file"` redirect TRUNCATES the temp file at open time. If the shell
crashes or is killed between the `head` write and the `tail` write (or if `tail` fails
because `$target_file` was concurrently modified), `$tmp_file` will contain a PARTIAL file.
The subsequent `mv` will then atomically replace the target with a partial file.

**Actual severity**: LOW-MEDIUM in practice (the crash window is small and TAD runs locally),
but the handoff claims "atomicity" as a safety property (Section 10.1) and the design does
NOT guard the `mv` on success of the compound command.

**Remediation**: Guard the `mv` on the exit status of the compound write:
```bash
local tmp_file="${target_file}.merge-tmp"
if {
    if [ "$source_marker_line" -gt 1 ]; then
        head -n $((source_marker_line - 1)) "$source_file"
    fi
    tail -n +"${marker_line_num}" "$target_file"
} > "$tmp_file"; then
    mv -- "$tmp_file" "$target_file"
else
    rm -f -- "$tmp_file"
    report_line "merge" "error" "$m_path" "write failed, target unchanged"
    return 1
fi
```
This ensures `mv` only runs if the entire compound write succeeds. If it fails, the
temp file is cleaned up and the original target is untouched.

**Reclassification**: Downgrading from P0 to **P1** because `set -euo pipefail` at
the script level means a `head`/`tail` failure inside the compound command will trigger
ERR trap and abort before reaching the `mv`. The residual risk is the temp file left
behind. Still worth the guard for defense-in-depth.

---

### P1 — High (should fix during implementation)

#### P1-1: Marker field has no validation — a crafted marker can match unintended lines

**Location**: Parser L391-396 (existing), Handoff Section 4.2 step 3 (`grep -nF`)

**Description**: The `marker` field from the manifest YAML passes through quote-stripping
(`${field_val#\"}; ${field_val%\"}`) but receives NO further validation. The `grep -nF`
at execution time uses `-F` (fixed string), which is correct — there is no regex injection.
However, a malicious manifest could set `marker` to a very short or common string like
`#` or an empty string `""`. An empty marker would match EVERY line in the file (grep -F
with empty pattern matches all lines), causing `head -1` to return line 1. This would
mean `marker_line_num=1`, `target_tail` = entire file, `source_head` = empty (0 lines
before line 1), and the merge would effectively prepend nothing — a no-op. So an empty
marker is NOT destructive in this specific algorithm, but it is semantically wrong and
should be rejected.

A short marker like `#` would match the first line starting with `#` (probably the
title), splitting the file at the wrong boundary. This could cause the merge to replace
only the title line (if marker matches line 1 of target) or to mis-identify the boundary.

**Impact**: A crafted manifest with a short/common marker could cause the merge to split
at the wrong line, replacing more or less user content than intended. Since the manifest
is from `$SOURCE` (the TAD release), this requires a supply-chain compromise.

**Remediation**: Add marker validation in `validate_manifest()` or in `execute_merge_entry()`:
```bash
# Reject empty or too-short markers
if [ -z "$m_marker" ]; then
    report_line "merge" "error" "$m_path" "empty marker"
    return 1
fi
if [ ${#m_marker} -lt 10 ]; then
    report_line "merge" "error" "$m_path" "marker too short (min 10 chars): $m_marker"
    return 1
fi
```
A minimum length of 10 characters prevents common false-match markers. The actual
marker `<!-- TAD:PROJECT-CONTENT-BELOW -->` is 38 characters.

#### P1-2: Temp file path is predictable — .merge-tmp suffix in the target directory

**Location**: Handoff Section 4.5 revised approach, line 351

**Description**: `local tmp_file="${target_file}.merge-tmp"` creates a predictable temp
file path in the target directory. On a multi-user system, a race condition could allow
a local attacker to pre-create a symlink at `${target_file}.merge-tmp` pointing to an
arbitrary file, causing the write to go to the wrong location.

**Actual severity**: LOW — TAD is a single-user CLI tool (per principles.md: "Mechanical
Enforcement Rejected on Single-User CLI"). The target directory is the user's own project.
No privilege escalation is possible. Still, predictable temp files are a CWE-377 pattern.

**Remediation**: Use `mktemp` for the temp file:
```bash
local tmp_file
tmp_file="$(mktemp "${target_file}.merge-XXXXXX")" || return 1
```
Then `mv` and clean up as before. `mktemp` is POSIX and available on macOS.

#### P1-3: `mv --` on macOS BSD mv — double-dash supported but worth a note

**Location**: Handoff Section 4.5, line 358

**Description**: The handoff notes "Use `mv --` to handle filenames starting with dash."
BSD `mv` on macOS does support `--` as end-of-options. However, paths in the engine are
already validated to reject leading-dash paths (L67: `'-'*` case in `validate_path()`).
The `--` is pure defense-in-depth and is fine. No action needed, just confirming this is safe.

**Status**: INFORMATIONAL — no issue.

#### P1-4: Idempotency check via variable comparison is symmetric but lossy

**Location**: Handoff Section 4.2 step 6, Section 4.5 "IMPORTANT" note

**Description**: The initial design (Section 4.2) captures `current_head` and `source_head`
via `$(...)` command substitution, which strips trailing newlines. The handoff's safety-reviewer
noted this (Section 9.2) and accepted it because "stripping is symmetric" — both sides are
extracted the same way, so if the content matches modulo trailing newlines, the comparison
returns true.

However, there is an edge case: if `source_head` has 2 trailing newlines and `current_head`
has 1, both get stripped to 0, comparison returns equal, and the merge reports
`already-current` even though the files differ by one trailing newline. In practice this
means the merge would skip when it should have updated, leaving the target with one fewer
trailing newline in the head section. This is NOT data-destructive (user content below
marker is never touched), but it means the TAD head could be slightly stale.

The revised approach (Section 4.5) uses direct pipe for the WRITE path, which is correct.
The idempotency CHECK remains via variable comparison, which is acceptable given the
symmetric stripping argument. The residual risk is cosmetic trailing-newline differences
in the TAD head section only.

**Status**: Acceptable as-is. Document the known limitation.

#### P1-5: Source/target read — verify source reads from $SOURCE, not $TARGET

**Location**: Handoff Section 4.2 steps 1-4

**Description**: This was a specific focus area requested by the reviewer. Examining the
pseudocode:
- Step 1: `source_file="$SOURCE/$m_path"` — correct, reads from SOURCE
- Step 2: `target_file="$TARGET/$m_path"` — correct, reads from TARGET
- Step 3: `grep -nF "$m_marker" "$target_file"` — correct, finds marker in TARGET
- Step 4: `grep -nF "$m_marker" "$source_file"` — correct, finds marker in SOURCE
- Step 4: `head -n $((source_marker_line - 1)) "$source_file"` — correct, extracts head from SOURCE
- Step 5: `tail -n +${marker_line_num} "$target_file"` — correct, extracts tail from TARGET

All source/target references are correct. The data flow is:
- New head content: from `$SOURCE/$m_path` (lines 1 to marker-1)
- Preserved tail: from `$TARGET/$m_path` (marker line through EOF)

**However**, in the revised approach (Section 4.5, line 356), the `tail` command reads
from `$target_file` while the output goes to `$tmp_file = "${target_file}.merge-tmp"`.
Since `$tmp_file` is in the same directory as `$target_file` but has a different name,
there is NO read-after-truncate issue (the `>` redirect opens `$tmp_file`, not
`$target_file`). The target file remains readable throughout the pipe. This is correct.

**Status**: PASS — no source/target confusion found.

---

### P2 — Medium (fix before release, not blocking implementation)

#### P2-1: No validation of `strategy` field value beyond dispatch

**Location**: Handoff Section 4.3

**Description**: The merge loop dispatches on `$m_strategy != "tad-head-marker"` to
`manual-required`. This is functionally correct for forward compatibility. However, the
`strategy` field value passes through quote-stripping but no content validation. A manifest
could set strategy to a value containing shell metacharacters (though these would not be
executed since the value is only compared via `[ "$m_strategy" != "tad-head-marker" ]`).

**Impact**: None in current code — the value is only used in string comparison and
`report_line` output (which passes through `tsv_sanitize` stripping tabs/newlines).
No injection vector exists.

**Status**: INFORMATIONAL — no remediation needed.

#### P2-2: `grep -nF` with marker containing newlines would malfunction

**Location**: Handoff Section 4.2 step 3

**Description**: If a manifest's `marker` field somehow contained a literal newline
character, `grep -F` would treat the newline as an OR separator between two patterns,
matching either substring. The YAML parser reads lines with `IFS= read -r`, which
reads one line at a time, so a newline in the marker field is impossible through the
current parser (the newline would be consumed as a line boundary). This is safe by
construction of the parser, not by explicit validation.

**Status**: Safe by construction. No remediation needed unless the parser changes.

#### P2-3: Multiple markers in file — first-match semantics documented but not enforced

**Location**: Handoff Section 8.3 edge cases table

**Description**: If a target file contains the marker string on multiple lines, `grep -nF |
head -1` takes the first occurrence. The handoff documents this as intentional. However,
there is no warning emitted when multiple markers exist. A file with duplicate markers
could indicate corruption or user error, and silently picking the first one could merge
at the wrong boundary.

**Remediation**: After finding `marker_line_num`, optionally count occurrences:
```bash
local marker_count
marker_count="$(grep -cF "$m_marker" "$target_file")" || marker_count=0
if [ "$marker_count" -gt 1 ]; then
    report_line "merge" "warning" "$m_path" "multiple markers found ($marker_count), using first at line $marker_line_num"
fi
```
This is informational and helps debugging.

#### P2-4: `merged` counter increment logic unclear for non-done statuses

**Location**: Handoff Section 4.3

**Description**: The integration loop increments `merged` after every
`execute_merge_entry` call that succeeds (returns 0). But `already-current` and
`skipped-no-marker` also return 0. The implementation hint (Section 4.5, line 519)
says "Only increment for `done` status" but the pseudocode increments unconditionally
after return 0. This is a logic discrepancy, not a security issue, but could cause
misleading summary counts.

**Remediation**: Either check the last TSV line's status field, or have
`execute_merge_entry` return distinct codes (0=done, 2=already-current, 3=skipped).

---

## Summary Matrix

| ID | Severity | Title | Status |
|----|----------|-------|--------|
| P0-1 | P0 -> reclassified P1 | Non-atomic write (crash leaves partial file) | Reclassified to P1; `set -e` mitigates but guard recommended |
| P1-1 | P1 | Empty/short marker not validated | Fix: add min-length check |
| P1-2 | P1 | Predictable temp file path (CWE-377) | Fix: use mktemp |
| P1-3 | INFO | `mv --` on BSD | PASS, defense-in-depth confirmed |
| P1-4 | INFO | Idempotency lossy for trailing newlines | Acceptable, document limitation |
| P1-5 | PASS | Source/target read correctness | All references verified correct |
| P2-1 | INFO | Strategy field shell metacharacters | No vector, tsv_sanitize handles |
| P2-2 | INFO | Newline in marker | Safe by parser construction |
| P2-3 | P2 | Multiple markers — no warning | Suggested: emit warning |
| P2-4 | P2 | merged counter logic discrepancy | Fix: clarify increment condition |

## Key Security Questions Answered

1. **Can a malicious manifest use merge to inject content?**
   The manifest's `marker` field controls WHERE the split happens. A crafted short marker
   could split at the wrong line, but the merge operation's semantics only REPLACE head
   content from the SOURCE file — it cannot inject arbitrary content not present in the
   source. The source file path goes through the path validation pipeline (no traversal,
   symlink checks, prefix allow-list). The primary defense is that manifests ship from
   `$SOURCE`, which is the TAD installation itself. Risk: LOW (requires supply-chain
   compromise of TAD).

2. **Is the marker search safe (no regex injection)?**
   YES. `grep -nF` uses fixed-string matching. The `-F` flag disables all regex
   interpretation. The marker value `<!-- TAD:PROJECT-CONTENT-BELOW -->` contains `<`,
   `>`, `!`, `-` which would be regex metacharacters under `-E`/`-G`, but are literal
   under `-F`. No injection possible.

3. **Is the write atomic (no partial writes on crash)?**
   MOSTLY. The temp-file + `mv` pattern provides rename(2) atomicity. The residual risk
   is if the compound write to the temp file fails partway (unlikely under `set -e`). The
   original target is never truncated — it is only replaced by the final `mv`. This is
   the correct pattern.

4. **Is source file read from the correct location ($SOURCE not $TARGET)?**
   YES. Verified all variable assignments. `source_file="$SOURCE/$m_path"`,
   `target_file="$TARGET/$m_path"`. Head extraction uses `$source_file`, tail
   extraction uses `$target_file`. No confusion found.

---

## Verdict

**CONDITIONAL PASS** — Design is fundamentally sound. The `grep -nF` fixed-string search
prevents regex injection. The temp-file + mv pattern prevents target truncation. Source/target
variables are correctly assigned.

Two P1 items should be addressed during implementation:
1. Add marker minimum-length validation (P1-1)
2. Use `mktemp` instead of predictable temp file suffix (P1-2)
3. Guard `mv` on success of compound write (reclassified P0-1 -> P1)

P2 items are improvement suggestions, not blocking.
