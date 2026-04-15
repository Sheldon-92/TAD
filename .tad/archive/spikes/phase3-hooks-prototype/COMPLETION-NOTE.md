# Phase 3 — Interrupted Completion Note

**Date:** 2026-04-15
**Session:** Blake `/blake *develop phase3-hooks-skill-impl`
**Handoff:** `.tad/active/handoffs/HANDOFF-20260415-phase3-hooks-skill-impl.md` (19 ACs)
**Status:** INTERRUPTED — archived for future phase

---

## What shipped (retained in main branch)

**Phase 3.A — SKILL hardening** — commit `4e4d581`, retained
- `.claude/skills/alex/SKILL.md`: `anti_rationalization_registry` byte-exact (v2 §4.1.1) + 3 anchors
  (AC Conflict Matrix / Required Evidence Manifest / raw-TSV recompute)
- `.claude/skills/blake/SKILL.md`: `honest_partial_protocol` byte-exact (v2 §4.2.1) + 3 anchors
  (evidence ls-check / raw-metric quote / express-not-exempt)
- AC4/AC5 verification: byte-exact diff empty × 2, all 6 anchors grep ≥1 ✅

## What was archived (this directory)

**Phase 3.B — hook code + schemas** — originally commit `3d9baab`, moved here
- 8 shell scripts (dispatchers + 6 libs): `bash -n` all pass, `chmod +x` all set
- 3 YAML schemas: `yq` parse all OK
- `state/.gitkeep` directory marker

All 11 Phase 3.B artifacts preserved byte-identical under `.tad/archive/spikes/phase3-hooks-prototype/`:
```
hooks/quality-enforcement.sh
hooks/userprompt-override.sh
hooks/lib/{dep-guard,quality-checker,sentinel-detect,path-guard,content-scanner,evidence-validator,override-verify}.sh
schemas/{evidence-manifest,sentinel-patterns,protected-paths}.yaml
state/.gitkeep
```

## Why interrupted

Phase 3.C (hook activation) triggered a **real dogfood paradox**:
1. Registered `quality-enforcement.sh` as PreToolUse matcher `Write|Edit|MultiEdit|NotebookEdit|Bash|Task`
2. Hook fired on very next Blake tool use
3. `lib/dep-guard.sh::require_dep jq` failed — pinned `PATH=/usr/bin:/bin:/usr/local/bin` excludes Apple Silicon Homebrew (`/opt/homebrew/bin`)
4. `command -v jq` returned 1 → hardcoded deny JSON → every Edit/Bash/Write/Task tool call blocked
5. No in-session escape: dep-guard exits BEFORE stdin parse / OV-1 check / anything
6. Required manual user intervention (either fix `dep-guard.sh` PATH pin or revert settings.json)

User chose to revert `.claude/settings.json` and archive the prototype. Phase 3.B code is correct in its own logic; the PATH-pin defect is a known issue inherited from Phase 1c spike that never surfaced because spike ran only on CI/Linux.

## Findings to carry forward into next Phase 3 attempt

1. **dep-guard PATH pin needs macOS Apple Silicon path** — add `/opt/homebrew/bin` before the existing pinned set, OR detect OS + branch. This must be fixed BEFORE any hook activation on Apple Silicon dev machines.

2. **Dogfood paradox remediation requires an in-hook escape pre-dep-guard** — OR — a documented "if hook self-locks, manually edit `.claude/settings.json` to disable matcher" recovery step in the activation runbook. Right now the only escape is running `claude --permission-mode bypassPermissions` or manual settings.json edit, which contradicts Epic decision #3 (override is human's last key via OV-1). Consider: (a) add a bootstrap allowlist that includes `.tad/hooks/**` self-edit for the first N minutes after hook installation, OR (b) add a pre-dep-guard "repo-root sanity check" that silently-allows if the hook is trying to run on a system without its own deps (this is the opposite of fail-closed, so needs a threat-model revisit).

3. **Handoff scope was too large for a single Blake session** — 19 ACs, 8 shell scripts, 3 schemas, 10+ fixtures, CI workflow, 3 expert reviews, dogfood trace = realistically 9–14h of careful work. This session completed 3.A (30min) + 3.B code (90min) before the dogfood halt. Future attempt should split Phase 3 into 3.A (SKILL), 3.B (hooks+schemas), 3.C (activate+bootstrap), 3.D (fixtures+perf), 3.E (review+completion) as separate handoffs with individual Gate 2/3/4 cycles, or at least checkpoint between each phase. Matches Blake's `honest_partial_protocol` trigger: "Ralph Loop Layer 2 review concludes the AC as-worded is impossible [in one session]".

4. **AC4/AC5 literal verification command (`yq '.registry' SKILL.md`) has a contract bug** — SKILL.md is mixed markdown + frontmatter, yq cannot parse directly. Phase 3.A resolution: injected content into fenced yaml code block with HTML BEGIN/END markers, and `diff -u extract <(awk BEGIN/END + sed '1d;$d')` verifies byte-exact. Future handoff should specify this extraction pattern upfront rather than `yq '.key' file.md`.

5. **Settings.json is itself a protected path once hook is active (C7 in handoff §3.1)** — but if hook is broken and settings.json needs revert, user cannot revert through Claude (Edit is blocked). The manual-revert path works but should be documented in the activation runbook as "expected recovery action, not a framework bug".

## Status matrix

| AC | Status |
|----|--------|
| AC1 (8 scripts bash -n + chmod +x) | ✅ prototype shipped to archive |
| AC2 (3 schemas yq parse) | ✅ prototype shipped to archive |
| AC3 (settings.json hook registration) | ⏸️ registered then reverted — paradox trigger |
| AC4 (Alex SKILL byte-exact + 3 anchors) | ✅ PASS — retained in main (`4e4d581`) |
| AC5 (Blake SKILL byte-exact + 3 anchors) | ✅ PASS — retained in main (`4e4d581`) |
| AC6 (bootstrap atomic a→b→c→d) | ⏸️ not reached — hook died in dep-guard before bootstrap |
| AC7–AC17 | ⏸️ not attempted |
| AC18 (KG-002 knowledge entry) | ⏸️ not written |
| AC19 (check_write env-var signature) | ✅ implemented in archived `quality-checker.sh` |

## Recommendation for Alex (next session)

Re-open Phase 3 handoff as 5 smaller Phases (A already done; B code is in archive, needs dep-guard fix + activation runbook update before re-promotion). Write this as a new Phase 3-reopened handoff that explicitly inherits 4e4d581 (SKILL edits committed) and references the archived prototype as implementation starting point.

---
*Archived by Blake on 2026-04-15 at user request ("结束 Blake session").*
