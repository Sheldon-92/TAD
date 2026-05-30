# Code Review — tad.sh `--yes`/`-y` flag (Layer 2, blue-team defensive)

- Reviewer: code-reviewer (defensive review)
- Artifact: `tad.sh` (TAD installer), express handoff `tadsh-yes-flag`
- Scope: arg-parsing correctness, `set -u`/`set -e` safety, interactive-path regression, shell injection
- Date: 2026-05-30
- Verdict: **PASS — no blocking findings.** One P-two (cosmetic/optional) noted below.

The diff was checked against the live file (lines 26-34 arg loop, lines 436-450 prompt block). It matches the handoff diff exactly. `bash -n tad.sh` is clean on bash 5.3.3 (macOS aarch64). I independently re-ran isolated harnesses under `set -euo pipefail` covering every branch (results inline below) rather than relying on the completion report.

---

## Per-question findings

**(a) `for arg in "$@"` loop — `set -u`-safe with zero args, and arg consumption.**
Safe. Under `set -u`, `"$@"` expands to zero words when no args are passed, so the `for` body never runs and no unbound variable is referenced. Verified: `bash harness < /dev/null` (zero args) runs clean. On the consumption question — the installer uses NO other positional arguments anywhere. A grep for `$1/$2/$@/$*/shift/getopts` shows every `$1`/`$2` is a function-local parameter (`log_*`, `copy_framework_files`, `apply_deprecations`, `version_le`); `main` is invoked as bare `main` (line 733) with no args. The loop therefore cannot consume or shadow anything the installer needs. The "does it forward other args" concern is structurally moot: there is nothing downstream to forward to.

**(b) `${REPLY:-}` correct on BOTH branches.**
Correct. `--yes` branch sets `REPLY="y"` explicitly (line 437). Else branch runs `read ... || REPLY=""` (line 442), so `REPLY` is always assigned — set by `read` on success, or forced to empty string on `read` failure (EOF / `/dev/tty` unavailable). The `${REPLY:-}` default at line 447 is a belt-and-suspenders guard that costs nothing and protects against any future code path that skips both assignments. No unbound-variable risk under `set -u` on either branch. Verified: empty-stdin and missing-`/dev/tty` cases both reach a clean "Cancelled." exit 0, no `set -u` abort.

**(c) `--yes` branch bypasses `read` without breaking the subsequent regex check.**
Correct. The `if [ "$AUTO_YES" = "1" ]` branch assigns `REPLY="y"` and never calls `read`. Control then reaches `[[ ! ${REPLY:-} =~ ^[Yy]$ ]]` (line 447) with `REPLY=y`, which matches `^[Yy]$`, so the negation is false and the script proceeds. Verified: both `--yes` and `-y` print the confirmation echo and reach PROCEED with no `read` invoked.

**(d) Injection / word-splitting risk in the arg loop.**
None. `for arg in "$@"` and `case "$arg" in` both quote their expansions, so each argument is treated as a single literal token — no word-splitting, no glob expansion, no command substitution of arg content. The `case` patterns are fixed literals (`--yes|-y`, `--help|-h`); arg values are never `eval`'d or interpolated into a command. Verified: passing `'--yes; rm -rf /tmp/SHOULD_NOT'` as a single quoted arg does NOT match, does NOT execute the embedded command, and leaves no artifact. No injection vector.

**(e) `--help` early-exit before side effects, and is exit 0 right.**
Correct. The arg loop (lines 29-34) runs at top level BEFORE `main` is called and BEFORE the `trap ... ERR` is installed (line 293). `--help`/`-h` hits `exit 0` (line 32) before `validate_environment`, `backup_existing`, any download, or any filesystem mutation. exit 0 is the right convention for an explicitly-requested usage message. Note the help text also exits before the ERR trap is set, so a help request can never accidentally trigger rollback. Verified: `--help` and `-h` print usage and exit 0 with no side effects.

**(f) Interactive-path regression vs original.**
No regression — strict improvement. The original interactive path was `read -p ... -n 1 -r < /dev/tty` + `echo ""` + `[[ ! $REPLY =~ ^[Yy]$ ]]`. The new else-branch is byte-equivalent for all real-keystroke cases and adds two safety guards: `|| REPLY=""` (EOF guard) and `${REPLY:-}` (unbound guard). Verified behavior-preservation: feeding `y`/`Y` proceeds; `n`/empty-line/EOF cancels — identical to original semantics. The ONLY behavioral delta is the EOF/no-`/dev/tty` case, which previously would `set -e`-abort (opaque failure, the bug this change fixes) and now degrades to a clean "Cancelled." exit 0. That is the intended fix, not a regression.

---

#### P-two-1 — Unknown args are silently ignored (no validation arm)

The `case` has no `*)` default arm, so an unrecognized flag (e.g. a typo `--yse`) is silently swallowed and the script falls through to the interactive prompt. In a TTY this is harmless (user just answers the prompt); in a non-TTY context a typo'd `--yes` would NOT skip the prompt and the run would land on "Cancelled." rather than proceeding. This is a usability nicety, not a correctness or safety defect — the documented flags work exactly as specified. Optional hardening: add `*) echo "Unknown option: $arg" >&2; exit 2 ;;` for fail-fast feedback on typos. Defer-able; not blocking for an express fix.

---

## Re-derived evidence (recomputed, not read from completion report)

- `bash -n tad.sh` → clean (bash 5.3.3).
- Zero args, no `/dev/tty` → `read` fails, `|| REPLY=""`, clean "Cancelled." exit 0 (no hang, no `set -e` abort).
- `--yes` / `-y` → REPLY=y, confirmation echo, PROCEED, no `read` reached.
- `--help` / `-h` → usage, exit 0, before all side effects and before ERR trap.
- Unknown arg `--foo` → ignored, falls through to interactive (P-two-1).
- Quoted injection arg → single literal token, no match, no execution, no artifact.
- Interactive: `y`/`Y` proceed; `n`/empty/EOF cancel — matches original.

## Summary

The change is correct, `set -euo pipefail`-safe on every branch, injection-free, and preserves the interactive path while fixing the non-TTY hang. Appropriate scope for an express handoff. Recommend acceptance. The single P-two is an optional usability improvement that need not block this change.
