# Design: P2 SC4 — wire process-tax-cut into agent-loaded surfaces

**Date**: 2026-09-12  
**Author**: Alex (Cursor Grok 4.6 medium). NO Gemini. NO Blake this design turn.  
**Epic**: `.tad/active/epics/EPIC-20260912-p2-process-tax-cut.md`  
**Human mandate**: full-authorize close-out of P2 Phase 2 / SC4. Docs-only land by Alex; Blake pathspec commit only.

## Problem

Checklists live in `docs/process-tax-cut.md`. Agents do not load that path unless a human hands it. Vacuous ACs, dirty-tree false P0s, and “wait for human `/gate 2`” therefore recur.

## Design (thin)

Do **not** rewrite the guide. Add **pointers + short paste blocks** on surfaces agents already load:

| Surface | Why it loads |
|---------|----------------|
| `patterns/_index.md` + new `patterns/process-tax-cut.md` | Blake 1_5_context_refresh / CLAUDE.md @import |
| `patterns/ac-verification.md` | already matched for AC work |
| `templates/handoff-a-to-b.md` Gate 2 + §9.1/§9.2 | Alex writes every full handoff from this |
| `templates/acceptance-verification-guide.md` | Blake step3b |
| `templates/output-formats/spec-compliance-format.md` | Layer 2 Group 0 |
| `templates/output-formats/git-workflow-format.md` | pathspec vs dirty-tree P0 |
| `templates/release-handoff.md` | publish dispatch |
| `.tad/tasks/handoff-creation.md` | Alex handoff-creation task |

**SSOT** for the three paste blocks remains `docs/process-tax-cut.md`. Pattern file copies the blocks for load-without-path; docs win on drift.

## Out of scope

GM P0/P1; KEEP11; publish/bump/tag; SKILL/hooks; L1 `principles.md`; historical completed handoffs wholesale; absorbing pre-existing dirty NEXT / brain-index / 2026-09-10 ac-verification entries.

## Teeth

Gate 2 dual independent review stays. Alex ≠ Blake stays. Layer 2 review stays; tax is adjudication not skip.

## Blake (this knife)

Alex already landed the doc edits. Blake: **pathspec-only commit**, hunk-stage mixed files (`_index.md`, `ac-verification.md`). No push/tag/release.
