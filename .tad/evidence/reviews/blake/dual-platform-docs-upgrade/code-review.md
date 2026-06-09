# Code Review: Dual-Platform Docs Upgrade (Phase 3)

**Reviewer**: code-reviewer (Layer 2)
**Date**: 2026-06-09
**Handoff**: TASK-20260609-005
**Files reviewed**: `docs/MULTI-PLATFORM.md`, `.tad/codex/README.md`, `AGENTS.md`, `.tad/evidence/designs/dual-platform-docs-upgrade.md`
**Cross-checked against**: Phase 1 architecture artifact, Phase 2 runtime policy artifact, handoff sections 6 and 9

---

## Findings Table

| # | Severity | File | Line(s) | Finding | Recommendation |
|---|----------|------|---------|---------|----------------|
| F1 | **P1** | `docs/MULTI-PLATFORM.md` | L3 | **Version over-claim**: Doc says `Version: 2.27.0` but `.tad/version.txt` is `2.26.0`. This handoff (section 10, note 6) says "version/changelog can be left to release handoff." Writing `v2.27.0` before a release bump implies a release that has not happened. | Change to `Version: 2.26.0 (Phase 3 — Dual-Platform Architecture)` or remove version number entirely and note "pending next release." |
| F2 | **P1** | `docs/MULTI-PLATFORM.md` | L69 | **Claude Code "primary" subordination language**: Phase 1 executive decision says "Neither platform is subordinate." Phase 1 D9 explicitly says "Minor: remove 'primary' subordination language." Line 69 reads: "Claude Code is the primary development platform with the deepest TAD integration." This directly contradicts the accepted architecture. | Rewrite to: "Claude Code has the deepest current TAD integration." or "Claude Code is a mature TAD runtime with extensive integration." Remove "primary." |
| F3 | **P1** | `docs/MULTI-PLATFORM.md` | L204 | **Footer repeats version over-claim**: `*TAD v2.27 -- ...` uses unreleased version. | Change to `*TAD v2.26 -- ...` or remove version from footer. |
| F4 | **P2** | `docs/MULTI-PLATFORM.md` | L14 | **"since v2.25.0" claim lacks source verification**: All three docs (MULTI-PLATFORM L14, codex/README L3, AGENTS.md L9) agree on v2.25.0. Phase 1 architecture doc cites this from existing AGENTS.md (L81). However, no git tag or changelog entry was cross-checked for v2.25.0. If this version is correct, fine. If not, all three docs propagate the same error. | Verify v2.25.0 claim against CHANGELOG.md or git history. Low risk since this was pre-existing in AGENTS.md before this handoff. |
| F5 | **P2** | `docs/MULTI-PLATFORM.md` | L35 | **Codex adapter line mentions `$skill invocation`**: The ASCII diagram line says `$skill invocation` but the Codex manual (V1) and AGENTS.md use `$alex` / `$blake` for role invocation and `$skill-name` for explicit skill invocation. The generic `$skill` is slightly ambiguous. | Consider: `$skill-name or implicit matching` to match the more precise Codex terminology. |
| F6 | **P2** | `docs/MULTI-PLATFORM.md` | L174 | **Release/sync row says "Release always runs from Claude Code"**: This is factually accurate today but stated as permanent fact. Phase 1 D10 defers but does not preclude Codex-originated release. | Add qualifier: "Currently, release always runs from Claude Code." |
| F7 | **P2** | `.tad/codex/README.md` | L92 | **Migration history section has no "## " marker for subsection consistency**: The `### v2.26.0` header is fine, but if future versions are added, the section could benefit from a brief intro sentence before the first version entry. | Minor style: add "Key migration events:" before the version subsection. |
| F8 | **P2** | `.tad/codex/README.md` | L94 | **v2.26.0 date says "2026-06-08"**: The recent release commit `785e0fb` message is "chore: sync TAD v2.26.0 to 14 projects (platform: both)" and `2c13b54` is "release: TAD v2.26.0". These are from git history. If the actual release date differs, this should be verified. | Verify against git log timestamp. Low risk. |
| F9 | **P2** | `docs/MULTI-PLATFORM.md` | L92-93 | **Codex hook events list includes 10 events**: "10 events (PreToolUse, PostToolUse, SessionStart, PreCompact, PostCompact, UserPromptSubmit, SubagentStart, SubagentStop, PermissionRequest, Stop)". Phase 1 V3 confirms exactly these 10. Accurate. | No action needed. Noted as verified. |
| F10 | **P2** | `.tad/evidence/designs/dual-platform-docs-upgrade.md` | L11 | **Evidence file says AGENTS.md "L9-12" and "L66-71" updated**: These are the OLD line numbers from before the update. They should reference the CURRENT line numbers or describe the content rather than cite stale line numbers. | Describe by content ("Codex first-class note block" / "Codex-specific notes section") rather than old line numbers, or verify new line numbers. |

---

## Section Completeness Check

### docs/MULTI-PLATFORM.md vs Handoff section 4.1

| Required Section | Present? | Notes |
|-----------------|----------|-------|
| TAD Multi-Platform Runtime Guide (title) | Yes (L1) | |
| Current Status | Yes (L9) | |
| Runtime Model | Yes (L20) | |
| Shared TAD Protocol | Yes (L50) | |
| Claude Code Adapter | Yes (L67) | |
| Codex Adapter | Yes (L84) | |
| Draft Codex Native Runtime Policy | Yes (L116) | |
| Runtime Freshness | Yes (L140) | |
| External Specialized Tools | Yes (L153) | |
| Workflow Matrix | Yes (L165) | |
| Current Limitations | Yes (L179) | |
| Source Artifacts | Yes (L192) | |

All 12 sections present. **PASS**.

### .tad/codex/README.md vs Handoff section 4.2

| Required Section | Present? | Notes |
|-----------------|----------|-------|
| TAD Codex Adapter (title) | Yes (L1) | |
| Current Status | Yes (L7) | |
| Active Codex Files | Yes (L20) | |
| Draft-Only Files | Yes (L32) | |
| Shared Protocol Boundary | Yes (L53) | |
| Codex Adapter Responsibilities | Yes (L68) | |
| Known Gaps Before Activation | Yes (L81) | |
| Migration History | Yes (L92) | |

All 8 sections present. **PASS**.

---

## AC Spot-Check

| AC | Status | Evidence |
|----|--------|----------|
| Stale "specialized executor" removed | PASS | `rg` returns no matches in any of the 3 docs |
| Draft-only config/agents documented | PASS | Both MULTI-PLATFORM.md and codex/README.md have explicit tables |
| `ask_user_question` hook documented as Phase 5 | PASS | 3 mentions across 2 files |
| Gemini not promoted | PASS | Gemini appears only in "External Specialized Tools" section, explicitly marked not first-class |
| No active `.codex/config.toml` or `.codex/agents/` | PASS | `test ! -e` confirms both absent |
| v2.26 migration history preserved | PASS | `.tad/codex/README.md` L94-104 |
| Phase 5 regression not over-claimed | PASS | All mentions are "not yet run" / "pending" / "Phase 5 runs" |
| Activation criteria carried forward | PASS | 6-item list in both MULTI-PLATFORM.md L129-136 and codex/README.md L44-49 |
| No SKILL or hook files modified | PASS | `git status` shows only the 3 target files + 1 new evidence file |

---

## Cross-Consistency Check

| Claim | MULTI-PLATFORM.md | codex/README.md | AGENTS.md | Consistent? |
|-------|-------------------|-----------------|-----------|-------------|
| Codex first-class since v2.25.0 | L14 | L3 | L9 | Yes |
| `.codex/hooks.json` only active config | L14 | L12 | L72 | Yes |
| Draft at codex-runtime-candidates/ | L16, L110-111 | L34-41 | L72 | Yes |
| Custom agents not yet activated | L93, L109, L184 | L14, L34 | L11, L69, L72 | Yes |
| `ask_user_question` unknown | L175, L185 | L85 | Not mentioned | Yes (AGENTS.md doesn't need it) |
| Activation requires Phase 5 + Human | L129-136 | L43-49 | Not detailed | Yes |

---

## Summary

| Severity | Count | Blocking? |
|----------|-------|-----------|
| P0 | 0 | -- |
| P1 | 3 (F1, F2, F3) | Yes |
| P2 | 7 (F4-F10) | No |

**Verdict**: **FAIL** (P0=0, P1=3)

### P1 Fixes Required

1. **F1 + F3**: Change version from `2.27.0` to `2.26.0` in MULTI-PLATFORM.md line 3 and footer line 204. The version.txt is `2.26.0`; this handoff is not a release handoff.
2. **F2**: Remove "primary" from MULTI-PLATFORM.md line 69. Phase 1 architecture explicitly declared "co-equal" / "Neither platform is subordinate" and D9 explicitly said "remove 'primary' subordination language."

All three P1 fixes are single-word or single-number edits. After fixing, re-run this review's checks; expected result: PASS.
