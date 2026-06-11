# Code Review: Pack System Unification Phase 2

**Reviewer**: Code Review Agent (shell correctness, portability, security)
**Commit**: 554aef6
**Date**: 2026-06-11
**Scope**: 8 installer shell scripts + 7 prebuilt SKILL.md files + evidence artifacts

---

## Summary

Phase 2 converts seven pack installers from `CAPABILITY.md -> SKILL.md` synthesis to prebuilt `SKILL.md` copy, adds `--agent=codex` support writing to `.agents/skills/`, and fixes two flag-handling outliers. The core intent is achieved: all seven target packs now have byte-identical SKILL.md files across `.tad/capability-packs/`, `.claude/skills/`, and `.agents/skills/` (verified). However, the review found **1 P0**, **5 P1**, and **4 P2** issues, mostly concerning residual stale references and inconsistent codex-path handling in the flag-only pack.

---

## P0: Critical / Blocking

### P0-1: `research-methodology/install.sh` still copies `CAPABILITY.md` as `SKILL.md` (line 121)

**File**: `.tad/capability-packs/research-methodology/install.sh`, lines 120-121

```bash
# Copy CAPABILITY.md -> SKILL.md
cp "${SCRIPT_DIR}/CAPABILITY.md" "${SKILL_DEST}"
```

The handoff scopes research-methodology as "flag-only" (FR6: accept `--force`), and the `--force` no-op was correctly added (line 47-48). However, the installer still performs the exact operation that AC6 is designed to prevent: it copies `CAPABILITY.md` as the installed `SKILL.md`. While AC6's regex only searches the seven TARGET_PACKS and research-methodology is excluded from that grep, this is the last remaining installer that maps `CAPABILITY.md -> SKILL.md` in production use. If Phase 3 extends scope to all packs, this will be a silent regression source.

**Severity rationale**: P0 because the handoff explicitly says "no target installer copies CAPABILITY.md directly as SKILL.md" (AC6 title) yet the comment on line 69 says `both install to .claude/skills/ -- handled below` treating codex as an alias, which means the pack actively performs the anti-pattern Phase 2 was designed to eliminate. The AC passes only because the AC6 grep excludes this file.

**Recommendation**: Either (a) add a prebuilt `SKILL.md` for research-methodology and update the copy, or (b) document explicitly in the completion report that research-methodology retains `CAPABILITY.md -> SKILL.md` and is deferred to Phase 3, downgrading this to P1. If (b), add a Friction Status entry.

---

## P1: Should Fix

### P1-1: `research-methodology/install.sh` codex path writes to `.claude/skills/` not `.agents/skills/` (lines 68-69, 86)

**File**: `.tad/capability-packs/research-methodology/install.sh`

```bash
  claude-code|codex)
    : # both install to .claude/skills/ -- handled below
```

Line 86: `TARGET_DIR=".claude/skills/${PACK_NAME}"` is unconditional.

When `--agent=codex` is passed, the installer writes to `.claude/skills/research-methodology/` instead of `.agents/skills/research-methodology/`. The comment explicitly says "both install to .claude/skills/" which contradicts Phase 2's FR4 requirement that codex writes to `.agents/skills/`. While research-methodology is "flag-only" in Phase 2, accepting `--agent=codex` without routing to the correct path is misleading. A user passing `--agent=codex` expects `.agents/skills/` output.

**Recommendation**: Either route codex to `.agents/skills/` (consistent with all seven target packs), or reject `--agent=codex` with exit 2 ("not yet implemented") until Phase 3 adds proper support. Do not silently route codex to `.claude/`.

### P1-2: `web-frontend/install.sh` prints stale `CAPABILITY.md` reference in success message (line 144)

**File**: `.tad/capability-packs/web-frontend/install.sh`, line 144

```bash
  echo "  head -5 $TARGET_DIR/CAPABILITY.md"
```

After the install, the user is told to verify with `head -5 $TARGET_DIR/CAPABILITY.md` but the installed file is now `SKILL.md`. This will confuse users who follow the instruction and get "file not found".

**Recommendation**: Change to `echo "  head -5 $TARGET_DIR/SKILL.md"`.

### P1-3: `ai-voice-production/install.sh` and `video-creation/install.sh` print stale `CAPABILITY.md` reference in next-steps (line 196-197)

**Files**:
- `.tad/capability-packs/ai-voice-production/install.sh`, line 196
- `.tad/capability-packs/video-creation/install.sh`, line 197

```bash
  echo "  3. Use CAPABILITY.md Step 1 to detect context -> load the right reference"
```

Both installers print a next-step instruction referencing "CAPABILITY.md Step 1" which no longer exists in the installed output. Should say "SKILL.md Step 1".

**Recommendation**: Replace `CAPABILITY.md` with `SKILL.md` in both echo lines.

### P1-4: `ai-agent-architecture/install.sh` hardcodes "Agent: claude-code" for codex installs (line 65)

**File**: `.tad/capability-packs/ai-agent-architecture/install.sh`, line 65

```bash
  echo "Agent:      claude-code"
```

When running with `--agent=codex`, the install_pack function receives `"codex"` as `$PLATFORM` and correctly computes the target directory, but the status output always says "Agent: claude-code" regardless of the actual agent. This is cosmetically wrong and could mislead debugging.

**Recommendation**: Change to `echo "Agent:      $PLATFORM"`.

### P1-5: `ai-agent-architecture/install.sh` and `ai-voice-production/install.sh` and `video-creation/install.sh` accept `--force` but never check it

**Files**:
- `ai-agent-architecture/install.sh`: `FORCE=true` parsed (line 28) but never referenced in any conditional
- `ai-voice-production/install.sh`: `--force` parsed as shift-only (line 55-56), no `FORCE` variable at all
- `video-creation/install.sh`: `--force` parsed as shift-only (line 55-56), no `FORCE` variable at all

These three installers always overwrite without checking `--force`. While accepting `--force` as a no-op is documented as acceptable behavior in the handoff (section 4.2: "if an existing script's semantics are already 'always overwrite', accepting `--force` as a no-op is acceptable"), the inconsistency with `academic-research` and `web-frontend` (which block overwrites without `--force`) creates confusion.

**Recommendation**: This is acceptable per handoff, but document explicitly which installers are "always overwrite" vs "require --force" in the installer-matrix.tsv or completion report, so Phase 3 can standardize.

---

## P2: Nice to Have

### P2-1: Five installers only support `--agent=value` form, not `--agent value` (space-separated)

**Files**: `ai-agent-architecture`, `web-frontend`, `web-ui-design`, `ml-training`, `research-methodology`

These five use `for arg in "$@"` parsing which cannot handle space-separated `--agent value` because it processes one argument at a time. In contrast, `academic-research`, `ai-voice-production`, and `video-creation` use `while [[ $# -gt 0 ]]` with `shift 2` and support both forms.

The handoff mentions "Preserve backward compatibility where practical" and `academic-research`'s help text documents both forms. This is an inconsistency but not a bug if only `--agent=value` is documented for those five packs.

**Recommendation**: Standardize on one parsing style in Phase 3 if a shared helper is introduced. Not blocking.

### P2-2: `ai-voice-production/install.sh` and `video-creation/install.sh` shift 2 on `--agent` when `$2` may be empty

**Files**: Both at line 45-46:

```bash
    --agent)
      AGENT="${2:-}"
      shift 2
```

If `--agent` is the last argument with no value, `shift 2` under `set -euo pipefail` will fail because there is only 1 argument left to shift. The `${2:-}` prevents an unbound variable error, but `shift 2` with only 1 remaining arg exits non-zero under `set -e`.

**Recommendation**: Guard with `[[ $# -ge 2 ]] || { echo "Missing value for --agent" >&2; exit 1; }` before `shift 2`, as `academic-research` does.

### P2-3: `.claude/scheduled_tasks.lock` deletion is outside handoff scope

**File**: `.claude/scheduled_tasks.lock` (deleted)

This file deletion is unrelated to Phase 2. It appears to be cleanup of a stale lock file from a previous scheduled task session. While harmless, it adds noise to the commit diff and is outside the handoff's section 4.3 scope.

**Recommendation**: Should have been a separate commit for clean history. Not actionable post-commit.

### P2-4: `web-ui-design/install.sh` default agent is `claude` not `claude-code`

**File**: `.tad/capability-packs/web-ui-design/install.sh`, line 14

```bash
AGENT="claude"
```

The case statement (line 48) accepts both `claude` and `claude-code`, so this works. But it is inconsistent with all other installers that default to `"claude-code"`. If Phase 3 standardizes the agent enum, this will need attention.

**Recommendation**: Normalize to `claude-code` for consistency. The case statement already accepts it.

---

## Positive Observations

1. **Dry-run safety is correctly implemented** across all target packs. Every installer exits or returns before any `mkdir`/`cp` when `--dry-run` is true. The `web-ui-design` and `ml-training` installers correctly exit before the pre-flight write-test block.

2. **Codex path routing** in the seven target packs is correct: `--agent=codex` produces `.agents/skills/{pack}/` as the target directory in all seven.

3. **Byte equality is verified**: All seven packs have identical SKILL.md across source, `.claude/`, and `.agents/`. The evidence in `ac-outputs.txt` and `installer-matrix.tsv` supports this.

4. **No GNU-only constructs** in the changed code. All scripts use `#!/usr/bin/env bash` and stick to POSIX-compatible bash features. `BASH_SOURCE[0]` is bash-specific but the shebang guarantees bash. No `grep -P`, no GNU `readlink -f`, no `sed -i` without backup arg.

5. **No SKILL.md content was unexpectedly modified**: The prebuilt SKILL.md files are new files created from current accepted content. No existing SKILL.md content files in other packs were touched.

6. **Blast radius is well-contained**: All changed files are within the handoff section 4.3 scope except for the `.claude/scheduled_tasks.lock` deletion (P2-3) and the `IDEA-*.md` status update, `NEXT.md`, `PROJECT_CONTEXT.md`, and evidence files which are standard housekeeping.

---

## Verdict

**Conditional PASS** -- 1 P0 requires disposition (fix or explicit deferral-with-documentation), 5 P1s are actionable fixes (4 are one-line echo corrections). After P0 disposition and P1-2/P1-3/P1-4 echo fixes, the implementation satisfies the handoff requirements.
