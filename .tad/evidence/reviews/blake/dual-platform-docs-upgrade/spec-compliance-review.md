# Spec Compliance Review: Phase 3 Dual-Platform Docs Upgrade

**Reviewer**: TAD spec-compliance reviewer (subagent)
**Date**: 2026-06-09
**Handoff**: HANDOFF-20260609-dual-platform-docs-upgrade.md, Section 9.1
**Files reviewed**:
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `AGENTS.md`
- `.tad/evidence/designs/dual-platform-docs-upgrade.md`

---

## AC Compliance Table

| AC# | Criterion | Verdict | Evidence |
|-----|-----------|---------|----------|
| 1 | `docs/MULTI-PLATFORM.md` rewritten as dual-platform runtime guide | SATISFIED | Title changed from "TAD Specialized Tools Guide" to "TAD Multi-Platform Runtime Guide". Version updated from 2.8.0 to 2.27.0. Contains 12 sections: Status, Runtime Model, Shared Protocol, Claude Code Adapter, Codex Adapter, Draft Policy, Activation Criteria, Runtime Freshness, External Tools, Workflow Matrix, Current Limitations, Source Artifacts. |
| 2 | No longer frames Codex as specialized executor | SATISFIED | Opening line: "TAD runs on **two first-class runtimes**: Claude Code and Codex." Old "Specialized Executor" role column removed. `rg "Specialized Executor"` returns 0 matches. Gemini remains "external specialized tool" (correct — it IS a specialized tool, not a runtime). |
| 3 | Documents shared protocol vs Claude Code adapter vs Codex adapter | SATISFIED | Three dedicated sections: "Shared TAD Protocol" (L50-64) lists 8 invariant elements; "Claude Code Adapter" (L68-81) with 8-row implementation table; "Codex Adapter" (L85-98) with 9-row implementation table. Runtime Model ASCII diagram (L22-46) shows the three-layer architecture visually. |
| 4 | Documents draft-only config/agents and activation criteria | SATISFIED | "Draft Codex Native Runtime Policy" section (L116-137) lists 4 draft files with Active?=No. "Activation Criteria" subsection lists all 6 prerequisites. "What Is NOT Active" subsection (L109-113) explicitly names `.codex/config.toml` and `.codex/agents/*.toml` as not active with draft locations. |
| 5 | `codex/README.md` documents active and draft-only files | SATISFIED | "Active Codex Files" section (L22-28) lists 5 active items. "Draft-Only Files" section (L33-49) lists 4 draft files in a table with location and purpose. Activation criteria (6 items) repeated. |
| 6 | `codex/README.md` preserves v2.26 migration history | SATISFIED | "Migration History" section (L92-104) with "### v2.26.0 (2026-06-08)" header. Lists all 6 categories of removed files (compressed editions, launchers, regen, tournament, adapter guides, parity check). |
| 7 | `AGENTS.md` stale note updated/removed | SATISFIED | Old lines "Some features (parallel reviewers, auto-hooks) are sequential / manual on Codex" and "See `.tad/codex/README.md` for migration history" replaced with accurate statements about native subagents/hooks, draft-only custom agents, and "adapter details and activation status". `rg "sequential / manual"` returns 0 matches. L67 updated from "Parallel expert review: run sequential sessions" to "Layer 2 expert review: run via explicit subagent prompting or sequential sessions; TAD custom agents draft-only". |
| 8 | Docs mention runtime freshness and Phase 4/5 pending | SATISFIED | MULTI-PLATFORM.md: "Runtime Freshness" section (L140-149) with Phase 4 pending items. "Current Limitations" table (L179-188) mentions Phase 4 (ledger) and Phase 5 (regression) explicitly. Runtime Model diagram includes "Runtime Freshness Layer (Phase 4 -- pending)". codex/README.md: "Runtime freshness: Pending Phase 4" in status table (L16) and "Runtime freshness ledger missing" in Known Gaps (L87). |
| 9 | Docs mention unresolved `ask_user_question` hook | SATISFIED | MULTI-PLATFORM.md L175: "`ask_user_question` hook: unknown on Codex (Phase 5)" in Workflow Matrix. MULTI-PLATFORM.md L185: "`ask_user_question` hook unknown on Codex" in Current Limitations with resolution "Phase 5 must verify and resolve". codex/README.md L85: same gap in Known Gaps table. Total: 3 mentions across 2 files. |
| 10 | Gemini not promoted to first-class | SATISFIED | MULTI-PLATFORM.md L155: "Gemini CLI can serve as an external specialized tool via the handoff mechanism. It is **not** a first-class TAD runtime." L161: "Gemini does not receive TAD SKILL files, hooks, or config." The word "first-class" is used ONLY for Claude Code and Codex. |
| 11 | Evidence artifact exists | SATISFIED | File exists at `.tad/evidence/designs/dual-platform-docs-upgrade.md` (41 lines). Documents files changed (3), stale claims removed (8 items), active-vs-draft status, and Phase 4/5 carry-forward items (5 items). |
| 12 | No active `.codex/config.toml` or `.codex/agents/` created | SATISFIED | `test ! -e .codex/config.toml` = PASS. `test ! -d .codex/agents` = PASS. |
| 13 | No SKILL or hook files modified | SATISFIED | `git diff HEAD -- .claude/skills/` = empty (no changes). `git diff HEAD -- .tad/hooks/` = empty (no changes). `git diff HEAD -- .codex/hooks.json` = empty (no changes). Only docs and evidence files appear in the diff. |
| 14 | Stale phrase grep returns no matches | SATISFIED | `rg "Specialized Executor|specialized execution tools|Claude Code primary|TAD Specialized Tools Guide|v2\.8\.0|20 Domain Packs|78 tools" docs/MULTI-PLATFORM.md` = exit code 1 (no matches). `rg "sequential / manual|specialized executor" AGENTS.md` = exit code 1 (no matches). |
| 15 | Layer 2 review P0=0 P1=0 | N/A | Self-referential criterion (this IS the Layer 2 spec-compliance review). Cannot self-verify. |

---

## Summary Counts

| Verdict | Count |
|---------|-------|
| SATISFIED | 14 |
| PARTIALLY_SATISFIED | 0 |
| NOT_SATISFIED | 0 |
| N/A | 1 |

---

## Verification Commands Run

```
rg -n "Specialized Executor|specialized execution tools|Claude Code primary|TAD Specialized Tools Guide|v2\.8\.0|20 Domain Packs|78 tools" docs/MULTI-PLATFORM.md
  → exit code 1 (no matches) ✓

rg -n "sequential / manual|specialized executor" AGENTS.md
  → exit code 1 (no matches) ✓

test ! -e .codex/config.toml && echo PASS
  → PASS ✓

test ! -d .codex/agents && echo PASS
  → PASS ✓

git diff HEAD -- .claude/skills/ .tad/hooks/ .codex/hooks.json --name-only
  → empty (no SKILL/hook modifications) ✓

test -f .tad/evidence/designs/dual-platform-docs-upgrade.md
  → exists ✓
```

---

## Verdict

**PASS** — 14 of 14 applicable ACs are SATISFIED. 1 AC is N/A (self-referential). No NOT_SATISFIED or PARTIALLY_SATISFIED findings.

The Phase 3 docs upgrade correctly:
- Rewrites the obsolete v2.8 "Specialized Tools Guide" into a current dual-platform runtime guide
- Removes all stale "specialized executor" framing
- Clearly separates shared protocol from platform-specific adapters
- Documents draft-only config with activation gates
- Preserves migration history
- Calls out Phase 4/5 pending work and the unresolved `ask_user_question` hook
- Does not touch any SKILL, hook, or active config files
- Correctly positions Gemini as external tool, not first-class runtime
