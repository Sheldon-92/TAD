# Code Review: Cross-Platform Adapter P4

**Reviewer:** Code Review Agent (Gate 3)
**Date:** 2026-06-03
**Scope:** 6 files (2 new shell scripts, 3 new JSON schemas, 1 modified SKILL.md)

---

## Summary

The implementation is a well-structured cross-platform adapter that ports TAD's tournament workflow from Claude Code's Workflow tool to Codex CLI's `codex exec` subagent pipeline. The code is clean, shellcheck-clean, and correctly handles the core flow. Three findings require attention: one P0 (TMPDIR variable shadowing), one P1 (missing error handling on codex exec failures), and several P2 suggestions.

---

## P0 Critical Issues (Must Fix)

### P0-1: TMPDIR variable shadows system environment variable

**File:** `.tad/codex/tournament-codex.sh`, line 70
**Severity:** P0 -- potential data loss / incorrect behavior

```bash
TMPDIR=$(mktemp -d -t tad-tournament.XXXXXX)
trap 'rm -rf "$TMPDIR"' EXIT
```

`TMPDIR` is a standard POSIX environment variable that tells `mktemp` (and other tools) where to create temporary files. On macOS, it is typically set to `/private/var/folders/.../T/` or (in Claude Code) `/tmp/claude-501`. By reassigning `TMPDIR`, the script:

1. **Overwrites the system temp directory pointer** for all subsequent commands in the process, including any child processes spawned by `codex exec`. If Codex or its child processes use `$TMPDIR` to create their own temp files, they will write into the tournament's temp directory.
2. **The EXIT trap `rm -rf "$TMPDIR"` deletes the reassigned directory** -- which is the tournament temp dir, so that's correct. But if the original system `TMPDIR` value is needed later (or by `codex exec` subprocesses), it is lost.
3. **On macOS, `mktemp -d -t` uses `TMPDIR` as the base directory.** If this script is called twice in the same shell session (unlikely but possible), the second call's `mktemp` would use the first call's tournament dir as the base -- though the EXIT trap should have cleaned it.

**Fix:** Rename the variable to something that does not collide with POSIX standard names:

```bash
TAD_TMPDIR=$(mktemp -d -t tad-tournament.XXXXXX)
trap 'rm -rf "$TAD_TMPDIR"' EXIT
```

Then replace all `$TMPDIR` references (22 occurrences) with `$TAD_TMPDIR`.

---

## P1 Important Issues (Should Fix)

### P1-1: No error handling on `codex exec` failures

**File:** `.tad/codex/tournament-codex.sh`, lines 83-100, 110-128, 138-157, 187-212
**Severity:** P1 -- silent failure cascade

The script uses `set -euo pipefail` (line 9), so a failed `codex exec` will abort the script. However:

1. The abort produces no diagnostic message beyond the raw `codex exec` error output.
2. The `--output-schema` flag with `codex exec` may produce a validation error if the LLM output does not match the schema. The error message from Codex may be cryptic.
3. The Claude Code workflow.js has explicit `validDesigns.filter(Boolean)` and fallback logic (line 154-158) for when competitors fail. The Codex version has no equivalent.

**Recommended fix:** Wrap each `codex exec` call with error checking:

```bash
if ! codex exec \
    --sandbox workspace-write \
    --output-last-message "$TAD_TMPDIR/design-a.txt" \
    --output-schema "$SCHEMA_DIR/design.json" \
    -o "$TAD_TMPDIR/design-a.json" \
    "...prompt..."; then
  echo "ERROR: Competitor A failed. Aborting tournament." >&2
  exit 1
fi

# Verify output file exists and is valid JSON
if [[ ! -s "$TAD_TMPDIR/design-a.json" ]]; then
  echo "ERROR: Competitor A produced empty output." >&2
  exit 1
fi
```

### P1-2: python3 dependency not checked

**File:** `.tad/codex/tournament-codex.sh`, lines 162-177
**Severity:** P1 -- silent failure on systems without python3

The script uses `python3` for JSON parsing (5 calls). Line 162 has `|| echo "A"` fallback, but lines 165, 168, 171-177 do not. With `set -e`, if python3 is not installed, lines 165/168 will abort the script with an unhelpful error.

**Options:**
1. Add `command -v python3 >/dev/null || { echo "ERROR: python3 required"; exit 1; }` near the top
2. Replace python3 calls with `jq` (already available on most systems with developer tools):
   ```bash
   WINNER_LABEL=$(jq -r '.winner // "A"' "$TAD_TMPDIR/judge.json")
   ```

`jq` is more idiomatic for shell JSON parsing and avoids the python3 dependency. However, `jq` availability should also be checked.

### P1-3: python3 inline code injection surface (low practical risk)

**File:** `.tad/codex/tournament-codex.sh`, lines 162-177
**Severity:** P1 (theoretical) / P2 (practical)

The `$TMPDIR` value is interpolated directly into python3 `-c` strings via shell expansion:

```bash
python3 -c "import json,sys; d=json.load(open('$TMPDIR/judge.json')); ..."
```

Since `TMPDIR` comes from `mktemp` output, the path is safe (alphanumeric + dots + slashes). But this is a fragile pattern -- if the script were ever modified to accept user-provided paths, single quotes in the path would break the python3 string and could enable code injection.

**Safer pattern:**

```bash
WINNER_LABEL=$(python3 -c "
import json, sys, os
d = json.load(open(os.path.join(sys.argv[1], 'judge.json')))
print(d.get('winner', 'A'))
" "$TAD_TMPDIR" 2>/dev/null || echo "A")
```

This passes the path as an argument rather than interpolating it into code.

---

## P2 Suggestions (Consider)

### P2-1: detect-platform.sh PPID heuristic may false-positive

**File:** `.tad/hooks/lib/detect-platform.sh`, line 10
**Severity:** P2 -- correctness edge case

```bash
if ps -o comm= -p "$PPID" 2>/dev/null | grep -qi "claude"; then
```

This checks if the parent process name contains "claude". If a user has a process named "claudebot" or any other unrelated process with "claude" in the name, this would false-positive and claim the Workflow tool is available. In practice, this is unlikely, and the handoff design explicitly includes this as a fallback heuristic. The env-var check (line 6) is the primary mechanism.

**No action required** unless false positives are observed in practice.

### P2-2: Prior art limited to exactly 2 files

**File:** `.tad/codex/tournament-codex.sh`, lines 54-57, 81, 109
**Severity:** P2 -- intentional limitation, but could be more flexible

The script requires `--prior-art` with at least 2 files, then uses only `PRIOR_ART[0]` and `PRIOR_ART[1]`. Additional prior art files are silently ignored. This matches FR5 (standard mode only, 2 competitors), but a user passing 3 files gets no warning.

**Suggestion:** Add a warning if more than 2 prior art files are provided:

```bash
if [[ ${#PRIOR_ART[@]} -gt 2 ]]; then
  echo "WARNING: Standard mode uses 2 prior art sources. Ignoring ${#PRIOR_ART[@]} - 2 extra file(s)." >&2
fi
```

### P2-3: No --rubric file validation

**File:** `.tad/codex/tournament-codex.sh`, lines 63-66
**Severity:** P2 -- error handling gap

```bash
if [[ -n "$RUBRIC_FILE" && -f "$RUBRIC_FILE" ]]; then
  RUBRIC_DIMS=$(cat "$RUBRIC_FILE")
fi
```

If `--rubric` is specified but the file does not exist (`-n` true, `-f` false), the script silently uses the default rubric with no warning. The user may not realize their custom rubric was ignored.

**Suggestion:** Warn when the file is specified but missing:

```bash
if [[ -n "$RUBRIC_FILE" ]]; then
  if [[ -f "$RUBRIC_FILE" ]]; then
    RUBRIC_DIMS=$(cat "$RUBRIC_FILE")
  else
    echo "WARNING: Rubric file not found: $RUBRIC_FILE (using defaults)" >&2
  fi
fi
```

### P2-4: Prompt content passed as command-line argument (ARG_MAX risk)

**File:** `.tad/codex/tournament-codex.sh`, lines 83-100, 110-128, 138-157, 187-212
**Severity:** P2 -- edge case for very large designs

The entire prompt (including task content, prior art content, and in later steps, full JSON designs) is passed as a positional argument to `codex exec`. On macOS, `ARG_MAX` is ~262144 bytes. A very large design task + prior art could exceed this.

The Claude Code workflow.js passes prompts as function arguments (no ARG_MAX limit). The Codex version may want to write prompts to files and use `--prompt-file` or stdin if available. However, for the PoC scope this is acceptable -- tournament tasks are typically under 10KB.

### P2-5: No `--output-schema` flag listed in the design section for `-o`

**File:** `.tad/codex/tournament-codex.sh`
**Severity:** P2 -- documentation clarity

The handoff Section 3 says `--output-last-message <file>` for output capture, but the implementation uses both `--output-last-message` AND `-o` (output file). The `-o` flag appears to be the structured output file while `--output-last-message` captures the raw text. This is correct behavior but not documented in the handoff. The implementation is right; the handoff is slightly incomplete.

---

## Good Practices Observed

1. **Clean shellcheck compliance** -- both scripts pass shellcheck with zero warnings at `--severity=warning`
2. **Proper quoting throughout** -- all variable expansions are double-quoted, including array expansions and file paths
3. **set -euo pipefail** -- strict mode correctly applied in tournament-codex.sh
4. **Schema field parity** -- all three Codex schemas exactly match the Claude Code workflow.js schemas (verified programmatically)
5. **SAFETY count preserved** -- SKILL.md modification does not touch any SAFETY constraints (count == 20)
6. **No hardcoded models, paths, or forbidden strings** -- checked and confirmed clean
7. **Executable permissions set** -- both scripts have `chmod +x`
8. **Graceful degradation design** -- three tiers (workflow/codex/none) with clear routing
9. **File-as-source-of-truth** -- args are file paths, not inline strings; consistent with TAD patterns
10. **additionalProperties:false correctly applied** -- including correct handling of dynamic-key objects (judge scores) vs fixed-property objects

---

## Findings Summary

| ID | Severity | File | Issue |
|----|----------|------|-------|
| P0-1 | CRITICAL | tournament-codex.sh:70 | TMPDIR variable shadows POSIX system env var |
| P1-1 | IMPORTANT | tournament-codex.sh:83+ | No error handling on codex exec failures |
| P1-2 | IMPORTANT | tournament-codex.sh:162+ | python3 dependency not checked |
| P1-3 | IMPORTANT | tournament-codex.sh:162+ | python3 inline code uses shell interpolation (fragile pattern) |
| P2-1 | SUGGESTION | detect-platform.sh:10 | PPID heuristic may false-positive on "claude"-named processes |
| P2-2 | SUGGESTION | tournament-codex.sh:54 | Extra prior art files silently ignored |
| P2-3 | SUGGESTION | tournament-codex.sh:63 | Missing rubric file silently falls back to defaults |
| P2-4 | SUGGESTION | tournament-codex.sh:83+ | Large prompts as CLI args may hit ARG_MAX |
| P2-5 | SUGGESTION | (handoff) | `-o` flag usage not documented in handoff design |

---

## Recommended Next Steps

1. **Must fix (P0-1):** Rename `TMPDIR` to `TAD_TMPDIR` across all 22 occurrences in tournament-codex.sh
2. **Should fix (P1-1):** Add explicit error check + diagnostic message after each `codex exec` call
3. **Should fix (P1-2):** Add `command -v python3` guard at script top, or convert to `jq`
4. **Consider (P1-3):** Pass TMPDIR as argv instead of interpolating into python3 -c strings
