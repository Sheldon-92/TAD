# mikefarah yq -i Normalizes Once Then Is Idempotent

**Date:** 2026-05-31
**Linked to:** L2 shell-portability "Hook Shell Portability Rules"

---

### mikefarah yq `-i` Normalizes Once Then Is Idempotent — Plan the One-Time Reformat — 2026-05-31
- **Context**: research-engine-wire-phase4 §4.2/§4.3 mandated structure-aware REGISTRY.yaml edits via `yq -i` (per-entry, atomic temp+mv) with an AC4.6 requirement that all non-edited entries stay byte-identical. First `yq -i` touch produced a 43-45 line diff (stripped blank lines, normalized inline-comment spacing, re-folded long multiline strings) — NOT the single targeted status line.
- **Discovery**: mikefarah yq v4 reformats the WHOLE file on its first write, then is byte-stable: every subsequent `yq -i` edit changes ONLY the targeted node. There is no reliable blank-line/comment-preservation flag in yq v4. So a byte-identical-others AC is satisfiable ONLY relative to an already-yq-normalized file. The clean resolution: perform the one-time normalization as part of a mandated edit (here, the §4.3 archive edit), after which any recurring automated editor (the SessionStart dormant hook) produces byte-surgical diffs forever. Verify idempotency explicitly: normalize a temp copy, snapshot, run a second edit, `diff` must show only the one line.
- **Action**: When a handoff mandates yq for recurring structure-aware edits AND requires byte-identity of untouched entries, (1) expect+accept a one-time whole-file normalization, (2) trigger it via a single mandated edit up front, (3) prove idempotency with a normalize→snapshot→edit→diff test, (4) run the AC4.6-style byte test against a copy of the NORMALIZED file, not the raw original. Never reach for line-based sed to dodge the reformat — that reintroduces the multi-entry corruption risk the yq mandate exists to prevent.
- **Grounded in**: .tad/hooks/lib/notebook-lifecycle.sh, .tad/evidence/acceptance-tests/research-engine-wire-phase4/dormant-recompute-smoke.md
