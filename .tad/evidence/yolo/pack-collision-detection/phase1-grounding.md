# Phase 1 Grounding — Pack Collision Detection
> Conductor (Alex) grounding pass. Read at 2026-05-31. Source of truth for the P1 handoff.

## Target architecture to MIRROR
- `.tad/scripts/scan-packs.sh` (184 lines) — the SIBLING this work mirrors. Key patterns:
  - `set -euo pipefail` (it is a CLI TOOL invoked by SKILL workflows, NOT a registered hook → fail-fast is correct; this matches layer2-audit/trace-digest/dream-validator convention).
  - `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` → `TAD_DIR` → `PACKS_DIR="$TAD_DIR/capability-packs"`.
  - Arg parse loop BEFORE deriving OUTPUT (P0-1 fix lesson — OUTPUT depends on final PACKS_DIR).
  - `extract_frontmatter_field()` uses `awk '/^---$/{if(++n==2) exit} n==1 && /^field: /'` — BSD-safe, anchored `^field: ` to avoid substring matches (P2-2 hardening).
  - Keywords are single-line flow form only: `keywords: ["a","b","c"]`.
- `.tad/capability-packs/pack-registry.yaml` — auto-generated; has `packs:` list, each with name/description/path/consumes/produces/keywords/type. ⚠️ READ-ONLY for us. P5 (other Alex) WRITES `behaviorally_verified` into THIS file → we MUST NOT write it (write-conflict avoidance). We emit a SEPARATE `pack-collisions.yaml`.
- `.tad/scripts/` currently holds: scan-packs.sh, sync-v2.8.4.sh. New `scan-collisions.sh` lives here.

## File-collision avoidance vs the OTHER Alex (lean-trustworthy P4/P5)
- P4 = `verify-ac-commands.sh` (NEW file, different name) wired at alex/SKILL.md step1d. No conflict (different file; we touch NO alex/SKILL.md in P1).
- P5 = pack behavioral eval runner; WRITES `behaviorally_verified` flag into pack-registry.yaml. We only READ pack-registry.yaml; we WRITE pack-collisions.yaml. No write-conflict.
- P1 creates ONLY new files. Zero shared-file edits. Safe to build concurrently.

## VERIFIED contradiction fixtures (file:line confirmed live 2026-05-31)
### Fixture 1 — Inter font (CROSS-category → precedence auto-resolves)
- BAN: `.claude/skills/web-ui-design/SKILL.md:93` — "NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface." (category: STYLE / anti-AI-slop) [grep check at :98]
- ENDORSE: `.claude/skills/web-frontend/references/performance.md:215` — `import { Inter } from 'next/font/google'` as the ✅ font-loading optimization (also :207 `@import ...family=Inter`). (category: PERFORMANCE)
- Resolution: precedence performance(4) > style(5) → web-frontend's Inter-loading WINS; web-ui-design ban LOSES. Visible log REQUIRED (this is the dangerous case — a legit next/font use must not be silently killed; log lets human verify Inter isn't actually the primary typeface).

### Fixture 2 — Contrast standard (SAME-category a11y → ESCALATE, precedence tie)
- APCA: `.claude/skills/web-ui-design/SKILL.md:454` "Validate contrast with APCA", :476 "APCA LC ≥60 for body text, ≥45 for large text". (category: A11Y)
- WCAG: `.claude/skills/web-frontend/references/accessibility.md:45` "Minimum 4.5:1 (normal text), 3:1 (large text/UI)" (WCAG 2.2 SC 1.4.3). (category: A11Y)
- ALSO: `.claude/skills/web-testing/references/accessibility-testing-rules.md:12` "Contrast ratio >= 4.5:1", :26 "ratio < 4.5:1". (category: A11Y)
- Resolution: both sides category=A11Y → precedence CANNOT break the tie → ESCALATE to human (APCA vs WCAG2.x give different pass/fail on the same color pair; a human/project must choose the standard).

### Fixture 3 — Testing pyramid ratios (SAME-category testing → ESCALATE / soft-divergence)
- web-frontend: `.claude/skills/web-frontend/references/testing.md:15` "Unit ~60%", :17 "E2E ~10%", :19 "If E2E >20% — cut". (category: TESTING/correctness)
- web-testing: `.claude/skills/web-testing/references/test-strategy-rules.md:25` "Unit ... 70%", :27 "E2E ... 10%", :31 "UI-heavy app: More E2E tests". (category: TESTING/correctness)
- Tension: web-testing pushes E2E UP for UI-heavy apps exactly where web-frontend says cut E2E. Both category=TESTING → ESCALATE (soft-divergence: differing base numbers 60 vs 70 + opposing conditional).

## Resolution engine semantics (derived from grounding)
- Categories (precedence order, highest→lowest): security/safety/compliance/data-integrity (1, non-overridable) > correctness (2) > accessibility (3) > performance (4) > style/aesthetic (5).
- CROSS-category collision → auto-resolve: lower-number category wins. Record winner/loser + file:line + category + the precedence rule that fired.
- SAME-category collision → precedence tie → ESCALATE to human (no silent pick). Record both sides as `unresolved: true, reason: same-category`.
- ALL resolutions (auto + escalated) are LOGGED visibly (TAD no-silent-caps rule). Consumers (Alex step4_5 / Blake 1_5a) surface a one-liner: cross-cat → "⚙️ resolved: X over Y (perf>style)"; same-cat → "⚠️ unresolved: X vs Y — human decides".

## Hybrid detection (anti-validation-theater)
- `scan-collisions.sh` = GREP-SEED only: for each pack pair sharing ≥1 keyword, grep curated opposing-directive signatures → emits CANDIDATE collisions to a staging file (pack-collisions.candidates.yaml). Deterministic, fast.
- LLM-CONFIRM pass (Alex/sub-agent, run when regenerating): reads each candidate, confirms it is a TRUE opposing directive (not a co-mention), assigns category per side, computes resolution → writes final `pack-collisions.yaml`. Drops false positives.
- Acceptance MUST hand-re-derive each flagged collision's file:line (NOT "N collisions found" — count≠signal, per 2026-05-30 dead-code-scanner-is-theater lesson).

## Anti-AI-slop / project-knowledge lessons that apply
- "Ad-hoc audit tools are themselves validation theater" (2026-05-30) → spot-verify every flagged item; check git status for in-flight work before interpreting a static scan.
- "Never combine grep -c with sort -u | wc -l" (2026-05-27) → for unique-match counts use grep -oE | sort -u | wc -l.
- BSD-safe regex only (macOS): no grep -P, no \d, no .*?, no readlink -f. Use grep -E / -o + sed.
- scan-collisions.sh is a CLI tool (set -euo pipefail OK), NOT a registered hook (so the no-fail-closed rule does not apply — but it MUST NOT be added to settings.json).
