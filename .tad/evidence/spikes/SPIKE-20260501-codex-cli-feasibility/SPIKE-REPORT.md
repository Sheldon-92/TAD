# SPIKE-REPORT: Codex CLI TAD Feasibility
Date: 2026-05-01
Epic: EPIC-20260427-codex-cli-adaptation (Phase 0)
Codex Version: 0.125.0
Time Budget: 4h | Actual: ~40 minutes (P0.1-pre ~15min + P0.2-P0.7 ~25min)

---

## Pre-Flight Discoveries (P0.1-pre — Unscored)

Critical environment findings before scoring:

| Discovery | Detail |
|-----------|--------|
| Model | `o4-mini` NOT supported on ChatGPT account. Default `gpt-5.5` works. |
| File read | ✅ Codex can read project files via shell tools (rg, cat, etc.) |
| File write | ❌ Sandbox is `read-only` — CANNOT be overridden via `sandbox_permissions` config |
| Invocation | `codex exec "prompt"` from TAD project root |
| Session resume | `codex exec resume --last "next prompt"` continues same session |
| Skills | 8 Codex-native skill files have `missing field 'description'` — non-fatal |
| Tokens | ~20-100K per exec call depending on injected context |

---

## Test Results

| Test | Mode | Result | Key Finding |
|------|------|--------|-------------|
| P0.2 | Blake | **PASS** | Correctly identified 7 files, main change (Linear removal + hook passive), first 3 ACs verbatim. Noticed gate4_delta discrepancy (7 vs 10 actual). Token: 48K. |
| P0.3 | Blake | **FAIL** | (a) File creation BLOCKED — read-only sandbox. (b) Script execution PASS — ran layer2-audit.sh, interpreted exit codes with correct TAD terminology. Per handoff: both required, (a) failed → FAIL. |
| P0.4 | Blake | **PASS** | 100% template alignment (13/13 sections), perfect context retention of P0.2/P0.3 results, no fabrication, honest about inability to write files. Session ID: 019de44c-cc7a-76a1-a9b4-57bd9d8eb243 — same for all 3. |
| P0.5 | Alex  | **PASS (Strong)** | 3 rounds, 8 questions total (4+4). Progressive follow-up adapting to answers. Never proposed solution prematurely. Summary covered 6 required dimensions. |
| P0.6 | Alex  | **PASS** | 100% handoff template filled (11/11 sections). Requirements correctly derived from Socratic dialog. Architecture.md knowledge correctly cited (hook portability, PascalCase events). |
| P0.7 | Alex  | **PASS** | Method A viable (persona switch in same session). 11 structured findings (3 P0, 4 P1, 4 P2) with specific section refs. Actual file reads (settings.json, IDEA file) rather than hallucination. |

**Score: 5/6**

---

## Blake-Axis Verdict
**PARTIAL GO** (2/3 PASS)

- P0.2 ✅ Handoff reading and understanding
- P0.3 ❌ File creation blocked (read-only sandbox) / Script execution ✅
- P0.4 ✅ Structured document generation with context retention

**Root cause of FAIL**: ChatGPT account sandbox is `read-only` — Codex cannot create or modify files. This is a platform-level constraint, not a capability/intelligence gap. Codex demonstrated correct understanding and executed the script successfully.

**Implication for Phase 1**: Blake operations requiring file writes (creating evidence files, writing code, updating configs) CANNOT be done with Codex on ChatGPT account. Phase 1 must address this before Blake-mode Codex is viable.

**Workaround options**:
1. OpenAI API key with write-enabled sandbox
2. Blake describes changes in text → human applies them (manual collaboration mode)
3. Codex writes output to stdout → Blake script captures and writes

---

## Alex-Axis Verdict
**GO** (3/3 PASS)

- P0.5 ✅ Socratic dialog (multi-round clarification, 3 rounds)
- P0.6 ✅ Handoff draft from dialog output
- P0.7 ✅ Sub-agent review (Method A: persona switch in same session)

Alex operations are read-heavy (read files, reason, output text). The read-only sandbox does NOT block Alex's core workflow. The key finding is that Alex CAN work effectively with Codex on ChatGPT account.

---

## Pivot Decision

Primary rule: CONTINUE requires Blake-axis ≥2/3 AND Alex-axis ≥2/3.
Blake-axis: 2/3 PASS (≥2/3 ✅) — PARTIAL GO
Alex-axis: 3/3 PASS (≥2/3 ✅) — GO
Aggregate 5/6 is informational only.

**Decision: CONTINUE to Phase 1 — with scope qualification**

Because Blake-axis is PARTIAL (not full GO), Phase 1 design must address the file-write constraint before Blake-mode is viable. Options:

1. **API key mode** (preferred): Use OpenAI API key instead of ChatGPT account → write sandbox available
2. **Alex-first Phase 1** (safe start): Build Codex adapter for Alex operations only (design, Socratic, handoff) since Alex-axis is GO
3. **Human-as-file-bridge** (workaround): Codex describes changes → human applies → viable for light Blake use

This is NOT a "STOP" — the constraint is account-level, not capability-level.

---

## Key Discoveries

1. **gpt-5.5 default, not o4-mini**: ChatGPT account provides gpt-5.5 (not o4-mini). The handoff's model specification was incorrect. All tests completed with gpt-5.5.

2. **Read-only sandbox is permanent on ChatGPT account**: `sandbox_permissions` config override is IGNORED. This is the single biggest blocker for Blake operations. If user has OpenAI API key, write access may be available.

3. **Session resume works for multi-turn**: `codex exec resume --last "next prompt"` continues the same session with full context. This enables multi-turn Socratic dialogs and sequential test scenarios. Critical for TAD workflow continuity.

4. **SKILL injection via stdin works for Blake (76KB)**: Full Blake SKILL piped via stdin was accepted and correctly applied by gpt-5.5. Codex adopted the Blake persona and used TAD terminology accurately.

5. **Codex sub-agent review = persona switch, not separate process**: P0.7 showed that Codex switches reviewer persona within the same session. This is not true multi-agent parallelism — it's sequential role-playing. For independent review perspective, Method B (separate sessions with different system prompts) would be needed.

6. **Token accumulation across session**: Blake session accumulated 48K (P0.2) → 52K (P0.3) → 97K (P0.4) tokens across 3 task turns. Alex session similar. Long TAD workflows may hit token limits in one session.

7. **Codex reads actual project files during review**: P0.7 found real evidence — `"timeout": 10` in settings.json — proving Codex uses the filesystem, not just training data, during review. Architecture.md lessons were cited accurately.

---

## Recommendations for Phase 1 (if CONTINUE)

1. **Resolve write-access constraint first (P0 for Phase 1)**: Test with OpenAI API key before building adapter. All Blake operations depend on file creation.

2. **Alex adapter first**: Since Alex-axis is full GO, start Phase 1 with Codex-Alex adapter. This delivers immediate value (TAD design workflow) while write-access is resolved.

3. **SKILL injection strategy**: Keep SKILL injection via stdin (76KB works). Consider a condensed "Codex-edition" SKILL that strips non-applicable sections (no hooks, no git worktree, no AskUserQuestion) to reduce token usage.

4. **session resume as TAD protocol**: Document `codex exec resume --last` as the standard multi-turn invocation pattern for TAD-Codex. Include in adapter design.

5. **gpt-5.5 as the target model**: Update Epic to use gpt-5.5 (the actual ChatGPT account default) instead of o4-mini. No model override needed.

6. **Token budget planning**: Budget ~100K tokens per TAD workflow session (Blake 3-task or Alex full Socratic+handoff). Monitor for session length limits.

7. **Method B sub-agent review needed for independence**: Phase 1 Blake adapter should implement Method B (separate Codex invocation with reviewer system prompt) rather than Method A (persona switch) for genuine Layer 2 expert independence.
