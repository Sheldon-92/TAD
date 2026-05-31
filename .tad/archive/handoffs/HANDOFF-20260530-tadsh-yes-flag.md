---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff (Express): tad.sh --yes non-interactive flag

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2)
**Date:** 2026-05-30 | **Priority:** P1
**Slug:** tadsh-yes-flag
**Type:** Express (skip Socratic; KEEP ≥1 expert review — code-reviewer required)

## Why
`*sync` to 14 projects is blocked: `tad.sh` has an interactive `read -p "Continue? (y/n)" < /dev/tty`
(line 426) that hangs in non-TTY (Claude Code Bash, CI). No bypass flag exists. This is the exact
fix the project-knowledge ⚠️SAFETY entry "Never Hand-Write What An Existing Tool Already Does"
recommended ("fix the tool — add --yes flag to tad.sh"). After this, Alex syncs via the tested tool
non-interactively (`curl … | bash -s -- --yes`).

## Root Cause
- `tad.sh` has NO arg parsing. `set -euo pipefail` is active (line 7) → unbound `$1` errors; use `${1:-}`.
- Line 426: `read -p "Continue? (y/n): " -n 1 -r < /dev/tty` → blocks without a TTY.

## Proposed Fix (tad.sh only — 1 file)
1. Add arg parsing near top (after vars, ~line 24). BSD/`set -u`-safe:
   ```bash
   AUTO_YES=0
   for arg in "$@"; do
     case "$arg" in
       --yes|-y) AUTO_YES=1 ;;
       --help|-h) echo "Usage: tad.sh [--yes|-y]"; exit 0 ;;
     esac
   done
   ```
2. At line ~426, gate the prompt on AUTO_YES:
   ```bash
   if [ "$AUTO_YES" = "1" ]; then
     REPLY="y"
     echo "Continue? (y/n): y  [--yes]"
   else
     read -p "Continue? (y/n): " -n 1 -r < /dev/tty
     echo ""
   fi
   if [[ ! ${REPLY:-} =~ ^[Yy]$ ]]; then echo "Cancelled."; exit 0; fi
   ```
   (P1-2: harden shared check to `${REPLY:-}` — `set -u`-safe on both paths regardless of branch assignment.
   Also in the interactive branch, guard EOF: `read -p "Continue? (y/n): " -n 1 -r < /dev/tty || REPLY=""`
   so a non-TTY run WITHOUT --yes degrades to clean "Cancelled." instead of a `set -e` opaque abort.)

## Affected Files
- `tad.sh` (only)

## Acceptance Criteria
| AC# | Requirement | Verification |
|-----|-------------|--------------|
| AC1 | `--yes` flag skips the prompt | `bash -n tad.sh` PASS; code path: AUTO_YES=1 → no `read < /dev/tty` reached |
| AC2 | No regression for interactive run | without `--yes`, the `read` prompt path unchanged |
| AC3 | `set -u`-safe on ALL paths (P1: strengthened) | `bash -n tad.sh` PASS; `bash tad.sh --help` exits 0; AND trace zero-arg path (`printf '' \| bash tad.sh` reaches prompt with no unbound-var) + `--yes` path (REPLY="y", no `read`). `--help`-only is insufficient — must cover empty-`$@` + REPLY paths |
| AC4 | `-y` alias works | grep shows `--yes\|-y) AUTO_YES=1` |
| AC5 | Version bumped to 2.19.1 — ⚠️ scheme-aware (P1-3) | tad.sh `TARGET_VERSION` is **MAJOR.MINOR only** ("2.19") — it does NOT carry patch, so it **STAYS "2.19"** (do NOT sed to 2.19.1). Bump ONLY: version.txt 2.19.0→2.19.1, config.yaml version→2.19.1, CHANGELOG [2.19.1]. Verify: `grep TARGET_VERSION tad.sh` = "2.19" (unchanged); `cat .tad/version.txt` = 2.19.1 |

## Expert Review Audit Trail (Express — code-reviewer)
| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P1-3 version-scheme mismatch (tad.sh=2.19 MAJOR.MINOR, not 2.19.0) | AC5 rewritten: tad.sh STAYS "2.19"; only version.txt/config/CHANGELOG → 2.19.1 | Resolved |
| code-reviewer | P1-2 cancel check fragile under set -u | proposed fix: `${REPLY:-}` + EOF guard `\|\| REPLY=""` | Resolved |
| code-reviewer | AC3 insufficient (--help-only misses empty-$@ + REPLY paths) | AC3 strengthened: zero-arg + --yes trace | Resolved |
| code-reviewer | Overall | CONDITIONAL PASS, no P0; safe as express | Resolved |

**Gate 2**: ✅ Expert review (code-reviewer, express ≥1) done; all P1 integrated; no P0; impl detail sufficient.

## Blake Instructions (Express)
- Express: skip Socratic. Layer 1 = `bash -n tad.sh` + manual trace of both paths (--yes and interactive).
- Layer 2 = code-reviewer (≥1, REQUIRED even for express — shell injection/`set -u`/arg-parse correctness).
- This is also a **patch release 2.19.1** (the --yes fix ships): bump version per release-runbook patch flow
  (version.txt 2.19.0→2.19.1, config.yaml, tad.sh TARGET_VERSION, CHANGELOG [2.19.1]). Commit. STOP before push.
- Alex then: *publish (push + tag v2.19.1) → *sync via `curl … | bash -s -- --yes` across 14 projects.
- If fix is more complex than described (e.g. ACTION-specific prompts elsewhere), escalate.
