# Security Audit: HANDOFF-20260617-installer-audit-fixes

**Reviewer**: security-auditor
**Date**: 2026-06-17
**Handoff**: `.tad/active/handoffs/HANDOFF-20260617-installer-audit-fixes.md`
**Verdict**: CONDITIONAL PASS

---

## Scope

Reviewed from the security-auditor lens: injection vulnerabilities, data integrity risks, file overwrite / data loss vectors, command-injection via user-controlled input, and supply-chain considerations in the installer and npx wrapper.

Read: Handoff sections 2 (Bug Details), 3 (Implementation Order), 9 (ACs), 11 (Decision Summary); `tad.sh` (argument parsing L1-69, detect_state L887-917, main L922-1022, copy_framework_files L388-470, download flow L1070-1080); `bin/tad-install.mjs` (full file); `package.json` (full file).

---

## P0 - Critical Issues (must fix before implementation)

### P0-1: `sed` regex injection in `merge_claude_md` via marker string containing regex metacharacters

The proposed `merge_claude_md` function (handoff line 106) uses:
```bash
project_content=$(sed -n "/${marker}/,\$p" "CLAUDE.md" | tail -n +2)
```

Where `marker="<!-- TAD:FRAMEWORK-END"`. The `<` and `!` characters are regex metacharacters in some sed implementations (BRE/ERE behavior varies across BSD sed on macOS vs GNU sed). More critically, this pattern uses **double-quoted variable interpolation inside a sed address**, which means if the marker value ever changes to contain `/` (slash), `&`, or other sed special characters, the sed command will break or behave unexpectedly. Additionally, on macOS (BSD sed), the `!` inside `<!--` may be interpreted as a negation operator depending on quoting context.

**Recommendation**: Use `grep -nF` (fixed-string matching) + `tail` instead of sed to find the marker line number and extract content below it. Example:
```bash
local marker_line
marker_line=$(grep -nF "$marker" "CLAUDE.md" | head -1 | cut -d: -f1)
if [ -n "$marker_line" ]; then
    project_content=$(tail -n +"$((marker_line + 1))" "CLAUDE.md")
fi
```
The `-F` flag treats the pattern as a fixed string, eliminating regex injection entirely. This also aligns with the project's own shell-portability pattern (patterns/shell-portability.md) for macOS/BSD compatibility.

### P0-2: TOCTOU data loss window in merge_claude_md on the marker-present path (no backup before destructive cp)

The proposed merge logic (handoff lines 103-110) reads project content from `CLAUDE.md` into a shell variable, then immediately overwrites the file with `cp "$src/CLAUDE.md" ./`, then appends the saved content. If the process is interrupted (SIGKILL, disk-full, OOM) between the `cp` (which destroys the original) and the `printf >> CLAUDE.md` (which restores project content), the user's project-specific content is permanently lost.

The legacy (no-marker) path at line 113 correctly creates `CLAUDE.md.bak` before overwriting. But the **marker-present path** -- which is the steady-state happy path for all users after their first upgrade -- creates NO backup before the destructive `cp`. This means the most common upgrade scenario has weaker data protection than the one-time legacy path.

**Recommendation**: Either (a) always create a backup before the destructive `cp` on the marker path, or (b) use atomic write via a temp file:
```bash
cp "$src/CLAUDE.md" "CLAUDE.md.tmp"
if [ -n "$project_content" ]; then
    printf '\n%s\n' "$project_content" >> "CLAUDE.md.tmp"
fi
mv "CLAUDE.md.tmp" "CLAUDE.md"  # atomic on same filesystem
```
Option (b) is preferred because `mv` is atomic on the same filesystem (POSIX guarantee), so no intermediate state exists where data is lost. The existing `backup_existing()` at L115 backs up `.tad/` but does NOT back up root-level `CLAUDE.md`, so there is no safety net from the broader backup mechanism.

---

## P1 - Recommendations (should address)

### P1-1: `--force` flag bypasses version safety check without audit trail or scope limitation

The proposed `--force` flag (handoff line 151-161) sets `ACTION="upgrade"` when `detect_state` returns `"current"`. This silently re-runs the full upgrade path including `copy_framework_files` (which overwrites ALL framework files) and `call_migration_engine`. There is no log entry distinguishing a force-reinstall from a genuine version upgrade, making post-incident diagnosis difficult.

Additionally, `--force` has no guard against accidental use with `curl | bash` (where a user might copy-paste a command with `--force` from outdated documentation without understanding the implications).

**Recommendation**: (a) Add `log_info "Force reinstall requested (v${TARGET_VERSION} -> v${TARGET_VERSION})"` so the upgrade log trail is distinguishable. (b) Consider whether `--force` should be restricted to local invocation only (not via `curl | bash`), though this may be overly restrictive given the single-user context.

### P1-2: npx installer execFileSync is safe but parseArgs allows unknown-option confusion

The existing `tad-install.mjs` parseArgs (line 125-128) has a `default` case that exits on unknown options, which is good. The handoff correctly proposes adding `--force` as a boolean. However, the current parseArgs has no `--` (end-of-options) support. If a future option takes a value that starts with `--` (e.g., `--packs --force-pack`), it would be misinterpreted. This is not a current vulnerability but is a defense-in-depth gap.

**Recommendation**: During implementation, verify the `--force` addition follows the existing safe pattern (boolean flag, no value parsing, array-based `execFileSync` avoiding shell expansion). The current design is acceptable.

### P1-3: Pre-existing: `curl -sSL "$DOWNLOAD_URL" | tar -xz` has no integrity verification (elevated risk now)

This is a pre-existing issue (not introduced by this handoff), but the handoff explicitly states that `*sync` is deprecated and the installer is now the ONLY distribution channel. This elevation of the installer's role increases the blast radius of a supply-chain compromise. The download uses HTTPS (good) but has no checksum verification, no GPG signature, and no pinned commit/tag.

**Recommendation**: Not blocking for this handoff, but flag as a P1 follow-up item: add SHA-256 checksum verification or pin to a specific git tag rather than `main` branch HEAD, especially since this is now the sole distribution path for 14+ downstream projects.

---

## P2 - Suggestions (nice to have)

### P2-1: CLAUDE.md `.bak` files accumulate without cleanup

The legacy merge path creates `CLAUDE.md.bak` on every upgrade where no marker is found. Over multiple upgrades before a user adds the marker, these `.bak` files accumulate. Consider using timestamped backup names (`CLAUDE.md.bak.$(date +%Y%m%d_%H%M%S)`) consistent with the existing `backup_existing()` pattern at L116, or noting in the warning that the user should add the marker to prevent repeated backups.

### P2-2: `package.json` `files` array uses `"*.md"` glob -- overly broad for npm distribution

The existing `package.json` `files` array contains `"*.md"` which includes ALL top-level markdown files in npm packages (including `NEXT.md` visible in git status, which may contain internal planning notes). The handoff adds `".agents/"` which is correct, but the pre-existing `"*.md"` pattern could inadvertently distribute sensitive planning documents. This is out of scope for this handoff but worth noting for a follow-up.

### P2-3: Document that `--force` still runs `backup_existing()` for safety

The handoff specifies `--force` sets `ACTION="upgrade"`, which runs the full upgrade path including `backup_existing()`. This is correct (safe) behavior, but it is not documented in the `--help` output. Adding "Note: --force still creates a backup before reinstalling" to the help text would reassure users and prevent future maintainers from accidentally removing the backup step.

---

## Overall Assessment

The handoff addresses 5 real bugs with reasonable fix designs. The two P0 findings are both in the `merge_claude_md` function (Bug 2 fix):

1. **P0-1**: Using `sed` with regex-interpreted marker strings when `grep -F` + `tail` would be safer and more portable (directly relevant to the project's shell-portability pattern).
2. **P0-2**: Missing backup or atomic-write on the marker-present merge path, creating a data-loss window during the most common upgrade scenario.

Both P0s are straightforward to address during implementation without changing the overall design. The `--force` flag (Bug 3) and npx passthrough are designed safely. The version bump (Bug 1), docs update (Bug 4), and files array fix (Bug 5) have no security implications.

**Verdict: CONDITIONAL PASS** -- Fix P0-1 (replace sed regex with grep -F fixed-string matching) and P0-2 (add atomic write or backup on marker-present merge path) during implementation.
