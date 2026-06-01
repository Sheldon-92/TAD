---
handoff: HANDOFF-20260601-codex-parity-phase3-releasegate.md
completed_by: Blake
completed_at: 2026-06-01
gate3_verdict:
---

# COMPLETION: Codex-Edition Parity — Phase 3 (Release Gate) — EPIC FINALE

## Summary

Wired the proven parity gate into the release process as a decoupled, detect-only hard block.
`*publish` reads live editions and blocks on drift (minor+); a separate human-invoked
`regen-codex-editions.sh` does the atomic regen for review+commit. Graduated the check + pin
to stable paths. Fixed P1-2 awk header self-counting, layer2-audit name drift, and mechanical
marker extraction. Three code-review P1s fixed.

## Steps Completed

1. **Graduation** — moved `codex-parity-check.sh` + `parity-criterion.md` to `.tad/hooks/lib/`. Broad-grepped + updated EPIC + regen-procedure refs. Check runs from new path.

2. **P1-2 awk fix + markers** — added `next` after header processing; recalibrated pins (alex anti_rat 6→5, blake honest_partial 4→3). Feature markers now read from `<!-- FEATURE:x -->` in pin file.

3. **regen-codex-editions.sh** — atomic: both→scratch→check→batch-mv only if BOTH pass. Uses `codex exec --full-auto` via stdin instructions. Codex-unavailable → error + escape valve.

4. **Detect-only gate** — `publish_protocol` step3b (before Confirm & Execute): reads both editions, minor+ drift → BLOCK with remediation message, patch → advisory. Never writes.

5. **Release-runbook** — augmented Codex Adapter section with parity gate + regen-command + escape valve. Existing smoke test retained.

6. **layer2-audit** — added `spec-compliance` to KNOWN_REVIEWERS. Dogfood: DISTINCT_COUNT=2 on P2 slug.

7. **Documentation** — README, portable-rules, runbook: standing mechanism + escape valve + residual touch-points.

## Dogfood Evidence (AC8)

**8a Block path:**
- Drifted live alex edition (removed cross_model_awareness section)
- Gate output: `X cross_model_awareness: codex=0 < source=1` → `LAYER 2: FAIL` → `VERDICT: DRIFT DETECTED (exit 1)`
- Gate correctly BLOCKs naming the specific (category, owner)

**8b Regen e2e (honest_partial):**
- codex CLI installed (v0.130.0) but auth token expired: `401 Unauthorized` on websocket connect
- Attempted: `bash .tad/codex/regen-codex-editions.sh` → fails at codex exec step
- The escape valve message displays correctly: "Install codex, OR hand-port per portable-rules.md"
- honest_partial: codex genuinely unavailable (auth expired), not a skip

**8c Partial-fail safety:**
- Temporarily renamed blake source → regen preflight fails → `REGEN EXIT: 1`
- Pre/post checksums: `b6807a2eebac9e03769b95f440cc73db` (alex) and `83539f2115ee3ddaf0bf71819d208da3` (blake) — identical
- `git status --porcelain .tad/codex/` = empty (both live editions byte-unchanged)

## Evidence Checklist

- [x] `.tad/evidence/reviews/blake/codex-parity-phase3-releasegate/spec-compliance.md`
- [x] `.tad/evidence/reviews/blake/codex-parity-phase3-releasegate/code-reviewer.md`
- [x] `.tad/hooks/lib/codex-parity-check.sh` (graduated)
- [x] `.tad/hooks/lib/parity-criterion.md` (graduated)
- [x] `.tad/codex/regen-codex-editions.sh` (created)
- [x] `.claude/skills/release-runbook/SKILL.md` (gate wired)
- [x] `.claude/skills/alex/SKILL.md` (publish_protocol gate)
- [x] `.tad/hooks/lib/layer2-audit.sh` (name-drift fixed)

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Category:** architecture

**Summary:** Decouple detect-from-heal at release gates — a detect-only gate (reads, blocks, never writes) + a separate human-invoked regen (writes, but only after human reviews `git diff`) keeps unreviewed LLM-generated content out of tagged releases. The detect-only gate is fast (no codex needed, just shell grep/awk) while the regen is slow (~175s per edition) and requires codex auth — separating them means the gate never fails due to codex unavailability.

## Reflexion History

无 reflexion（task_type: mixed shell/markdown — no build/test/lint/tsc applicable）。

## Epic Completion Note

This Phase 3 completes the Codex-Edition Parity Epic (EPIC-20260601-codex-edition-parity.md):
- P1 ✅ Spike: built + proved the 3-layer parity check
- P2 ✅ Catch-up: hardened gate (per-owner SAFETY), regenerated both live editions to v2.20.0
- P3 ✅ Release gate: wired detect-only gate into *publish, created regen command, graduated check

On Gate 4 acceptance, Alex should archive the Epic.
