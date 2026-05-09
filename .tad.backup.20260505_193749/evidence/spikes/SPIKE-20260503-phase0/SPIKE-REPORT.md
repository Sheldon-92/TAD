# SPIKE-REPORT: Cross-Model Orchestration Phase 0

**Date**: 2026-05-03
**Blake**: TAD v2.8.5
**Total wall-clock**: ~15 minutes (3 spikes, within 3-hour budget)
**Handoff**: HANDOFF-20260503-cross-model-phase0-spikes.md

---

## Per-Spike Verdict Matrix

| Spike | Capability | Verdict | Key Evidence |
|-------|-----------|---------|-------------|
| A | Codex Code Review | **SKIP** | Claude (generic) found 11 findings (6 P1, 5 P2); Codex found 5 (2 P1, 3 P2). No Codex-unique P0/P1. Production code-reviewer would find more → real gap is larger. Multi-language retest needed before permanent exclusion. |
| B | Gemini Deep Research | **DEFER** | Asymmetric prompts (Claude: open-ended discovery; Gemini: explicit structured-tables request). Gemini `(?!.*WHERE)` regex fails in BSD grep -E (POSIX ERE, no lookahead). Re-run with symmetric prompts + regex validation before INTEGRATE. |
| C | Image Generation | **INTEGRATE (narrowly scoped)** | Codex generated production-quality PNG (1774×887) in ~120s. Scoped to `*publish` documentation only (≤20 diagrams/month). Single-rater quality assessment — no human blind review. |

---

## Latency Comparison

| Spike | Claude-side | External-model-side | Delta |
|-------|-----------|-------------------|-------|
| A | 44s (Agent tool, general-purpose) | 28s (Codex CLI stdin fallback) | Codex 37% faster |
| B | 97s (6× WebSearch iterative) | 61s (Gemini 1 call + retry) | Gemini 37% faster |
| C | N/A | ~120s (Codex), ~197s (Gemini—no image) | N/A |

---

## Spike A: Codex Code Review

### Test Setup
- **Target**: commit 95b154b (71 lines bash: 2 files, passive-mode migration)
- **Both reviewers**: Identical generic prompt (no code-reviewer persona on either side — fair comparison)
- **Claude side**: `Agent` tool with general-purpose subagent
- **Codex side**: stdin fallback (diff piped to `codex exec --full-auto`)
  - Note: `codex exec review --commit 95b154b --full-auto [PROMPT]` failed — args incompatible. Fallback per handoff §2.3.

### Results Comparison (Blinded: A=Claude, B=Codex, then revealed)

| Finding | Reviewer A (Claude) | Reviewer B (Codex) | Overlap? |
|---------|--------------------|--------------------|----------|
| Race condition on .router.log | ✅ P1 | ✅ P1 | **Consensus** |
| TOCTOU on log file (open twice) | ✅ P1 | ❌ Not found | Claude-only |
| `ratio == "0"` fragility | ✅ P1 | ✅ P2 | Consensus (different severity) |
| `import os` inside function | ✅ P1 | ❌ Not found | Claude-only |
| Async flush / log not-yet-written | ✅ P1 | ❌ Not found | Claude-only |
| `wc -l` platform variation | ✅ P1 | ✅ P2 (partial) | Partial overlap |
| `os.path.dirname` without abspath | ❌ Not found | ✅ P2 | **Codex-only** |
| `tail -1 \| awk` empty output | ✅ P2 | ❌ Not found | Claude-only |
| List repr in LOG_PARSE_ERR | ✅ P2 | ❌ Not found | Claude-only |
| No timeout on `_invoke_hook` | ✅ P2 | ❌ Not found | Claude-only |
| `readlines()` full load | ✅ P2 | ❌ Not found | Claude-only |
| File existence guard suggestion | ❌ Not found | ✅ P2 | Codex-only |

**Summary**:
- Claude: 11 findings (0 P0, 6 P1, 5 P2)
- Codex: 5 findings (0 P0, 2 P1, 3 P2)
- Claude-only P1: 4 (TOCTOU, import os, async flush, wc -l variation)
- Codex-only: 2 P2 (abspath normalization, file existence guard)
- No Codex-unique P0 or P1

### Three-Way Comparison (after backend-architect P0 fix — production baseline added)

| Reviewer | P0 | P1 | P2 | Total | Unique P0/P1 not found by others |
|---------|----|----|-----|-------|----------------------------------|
| **Production code-reviewer** (TAD incumbent) | **1** | **3** | 4 | **8** | P0: `_assert_skip` no-op in passive mode; P1: CONTRACT block missing, FileNotFoundError gap |
| Generic Claude (general-purpose Agent) | 0 | 6 | 5 | 11 | P1: TOCTOU, async flush, `import os`, wc-l variation, list repr, timeout |
| Codex CLI (stdin fallback) | 0 | 2 | 3 | 5 | P2: dirname abspath, file existence guard |

**Critical finding**: Production code-reviewer found a **P0 that neither generic Claude nor Codex caught** — `_assert_skip` is a test-quality regression (skip assertions are now no-ops in passive mode, silently disabling 5 of 7 regression guards). This shows the production reviewer adds genuine value over generic Claude on this codebase.

**Codex vs production baseline**: Codex found **0 P0, 2 P1** vs production's **1 P0, 3 P1**. No Codex-unique P0/P1 findings.

### Verdict: SKIP (bash domain, pending multi-language retest)

Codex did NOT find any P0 or P1 that the production code-reviewer missed. The production baseline found a P0 (skip no-op) that Codex missed. SKIP verdict holds and is strengthened vs the generic Claude baseline.

**Multi-language caveat**: Only 1 commit tested (bash + embedded Python). Codex reputation is stronger for Python/TypeScript. SKIP verdict applies to bash domain. Needs ≥3 pre-registered commits across bash/Python/TS before extension or permanent exclusion in other domains.

---

## Spike B: Gemini Deep Research

### Test Setup
- **Topic**: "AI CLI agent bash command deny patterns for PreToolUse hook"
- **Claude**: 6 iterative WebSearch rounds (start query → adapt based on results) — 97s total
- **Gemini**: 1 `gemini -p` call (single prompt, no iteration) — 61s total

### Coverage Comparison

| Topic | Claude WebSearch | Gemini | Winner |
|-------|----------------|--------|--------|
| File system ops (rm -rf) | ✅ Named DCG 34+16 pattern system | ✅ Specific regex table | Tie |
| Git ops (reset --hard, push --force) | ✅ Named DCG safe-exceptions (checkout -b OK) | ✅ Specific regex table | Tie |
| Database ops (DROP, TRUNCATE) | ✅ Real incidents (PocketOS 9s, drizzle-kit) | ✅ More specific: `DELETE FROM ... WHERE` detection | **Gemini** |
| Network ops (curl internal) | ✅ 169.254.169.254 specifically | ✅ Same + private IP ranges (10., 192.168., 172.) | Tie |
| Reverse shells | ❌ Not mentioned | ✅ `/dev/tcp/IP/` pattern | **Gemini** |
| find -delete pattern | ❌ Not mentioned | ✅ `\bfind\b.*\b-delete\b` | **Gemini** |
| Obfuscation detection (eval, xargs, base64) | ❌ Mentioned bypass but no detection patterns | ✅ Specific detection patterns | **Gemini** |
| Bypass techniques (>50 subcommands) | ✅ Critical vulnerability found (adversa.ai) | ❌ Not mentioned | **Claude** |
| Real-world incidents | ✅ PocketOS, drizzle-kit, specific dates | ❌ Not mentioned | **Claude** |
| Specific tools (DCG, Omamori) | ✅ Named tools, GitHub links | ❌ Not mentioned | **Claude** |
| Framework comparison table | ❌ Narrative only | ✅ Structured comparison | **Gemini** |
| Verifiable citations | ✅ Real GitHub URLs, real incidents | ⚠️ Some may be hallucinated | **Claude** |

### Depth Assessment
- **Citations**: Claude 7 verifiable sources, Gemini 3 cited (1-2 possibly hallucinated — not verified)
- **Regex patterns**: Gemini wins on volume — 20+ regex examples in structured tables vs Claude's narrative
- **Usability for hook implementation**: Gemini output appears "copy-paste ready" but see critical caveat below
- **Truly novel findings (after correcting P1-4)**: Gemini found **2 genuinely unique patterns**: reverse shells (`/dev/tcp/`), `find -delete`. "Obfuscation" was in Claude's output as "bypass techniques." WHERE-less DELETE was mentioned by Claude as "hard to detect via regex" — Gemini's regex attempt uses negative lookahead which is POSIX-ERE-incompatible.

### ⚠️ Critical Regex Portability Issue (P1-2 from code-reviewer)

Gemini's `DELETE FROM` regex: `\bDELETE\s+FROM\s+\w+\b(?!.*\bWHERE\b)` uses **negative lookahead `(?!...)`** which is NOT supported by POSIX ERE. macOS BSD `grep -E` will silently fail on this pattern (matches nothing or errors). TAD hooks use `grep -E` per architecture.md "No grep -P on macOS" rule. **Gemini's regex output CANNOT be used in TAD hooks without explicit `grep -E` smoke testing.**

### Verdict: DEFER (pending prompt-symmetry retest + regex validation)

**Why DEFER not INTEGRATE:**
1. **Asymmetric prompts** (P0-1): Claude received open-ended discovery prompts; Gemini received an explicit instruction to "produce structured regex tables with sections for each category." Gemini's structured output is at least partially an artifact of being asked to produce structured output. Cannot attribute output format difference to model capability.
2. **Regex portability failure** (P1-2): At least 1 of 4 claimed "novel patterns" uses POSIX-incompatible regex. Without validation, INTEGRATE puts broken regexes in TAD hooks.
3. **Novel-pattern count corrected**: 4 → 2 genuinely unique (reverse shells, find-delete). Obfuscation and WHERE-less DELETE were already in Claude's research (under different labels).

**What IS directionally supported** (for Phase 2 retest design):
- Gemini can produce structured tables when explicitly asked; Claude's WebSearch produces narrative
- Complementarity hypothesis is plausible: Claude for evidence/incidents, Gemini for pattern catalogs
- Retest with identical prompts to both models (both asked for structured regex AND for evidence)

**Required before re-proposing INTEGRATE:**
1. Re-run Spike B with symmetric prompts (give Claude same "structured regex" instruction; give Gemini same "find evidence" instruction)
2. Validate each Gemini-emitted regex against `grep -E` on macOS with a positive + negative fixture
3. If both survive retest: INTEGRATE with mandatory regex-validation gate in Phase 1 protocol

---

## Spike C: Image Generation

### Codex GPT Image-2
- **Result**: ✅ Production-quality PNG generated (1774×887, 852KB)
- **Time**: ~120s including Codex skill loading and file copy to workspace
- **Quality**: All 5 spec elements correct (colors, labels, flow, gates, arrows)
- **Path**: `assets/tad-architecture-diagram.png`

### Gemini CLI
- **Result**: ❌ Cannot generate images
- **Time**: 197s (no usable output)
- **What happened**: Gemini interpreted "generate diagram" as "create Mermaid code"; then failed because its `-p` mode is read-only (no write_file/run_shell_command tools)
- **Gemini did produce**: Well-styled Mermaid code in text output (with colors), but couldn't save or render it

### Mermaid Baseline Comparison
The Codex-generated PNG is substantially superior to Mermaid:
- Professional typography, rounded corners, color gradients
- Two-row layout (top: agent nodes, bottom: flow) vs Mermaid's auto-layout
- Human bridge as distinct colored node vs Mermaid's implied edge
- No Mermaid renderer dependency

### Verdict: INTEGRATE — narrowly scoped to `*publish` documentation (Codex only; Gemini SKIP)

Codex image generation produces a technically correct, professional PNG. Mermaid baseline is functional but aesthetically inferior.

**Scope constraints (P0-3 from code-reviewer):**
- Trigger: `*publish` skill only — NOT open to any handoff requesting a diagram
- Budget: ≤20 images/month (per Codex ChatGPT-account quota model)
- Quality assessment: single-rater (Blake), no human blind comparison — treat as directional, not validated preference
- Frequency validation needed: count diagrams in last 6 months of TAD workflow; if N < 5, revisit INTEGRATE

**New discovery**: Gemini CLI `-p` is read-only (research/analysis only). Cannot create files or execute commands. This constrains Gemini to pure text-output tasks in TAD context.

---

## Phase 1 Scope Recommendation

Based on verdicts:

**INTEGRATE (narrowly scoped) → Phase 1 协议设计范围:**
- **Codex for diagram/image generation** (`*publish` only): `codex exec --full-auto` image_gen produces production-quality PNG. Scope: documentation diagrams at `*publish` time. Budget cap: ≤20/month. Trigger is `*publish` skill flag, NOT "any handoff requesting visual asset."

**SKIP verdicts → Phase 1 Anti-Scope:**
- **Codex as mandatory code reviewer** (bash domain): No incremental P0/P1 value on bash code over Claude code-reviewer. DEFER multi-language retest (Python/TS/Go) to Phase 2 follow-up.

**DEFER verdicts → 条件重测 (before Phase 1 can include):**
- **Gemini for structured research synthesis**: Blocked on prompt-symmetry retest + BSD grep regex validation. Retest conditions:
  1. Run symmetric prompts to both models (both asked for structured output AND for evidence gathering)
  2. Validate all Gemini regex output against `grep -E` on macOS fixture set
  3. If both pass: INTEGRATE with mandatory regex-validation gate in Phase 1 protocol

**Revised architectural model (post code-review + backend-architect):**
```
Phase 1 scope (INTEGRATE only):
  Documentation:   Codex image_gen at *publish time
    - Trigger: *publish skill flag ONLY
    - Budget: ≤20/month, counter in .tad/state/codex-image-budget.json
    - Reset: calendar month boundary
    - Enforcement: release-runbook pre-flight check (warn at 18, fallback at 20)
    - Auth failure: detect non-zero exit → log + Mermaid fallback → non-blocking warning
    - Stderr: use exit code, not stderr, as success signal (codex benign noise)
  Code review:     Claude code-reviewer only (Codex SKIP for bash)

Phase 2 candidates (pending retest):
  Research:        Gemini for structured patterns
    - DEFER — needs symmetric prompt retest + BSD grep-E regex validation
    - Retest spec: (1) identical prompts to both models; (2) each Gemini regex tested
      via `echo test | grep -E 'PATTERN'` on macOS before Phase 2 handoff
    - Prompt requirement: "output POSIX ERE compatible with BSD grep -E, no lookahead"
  Code review:     Codex for Python/TS/Go domains
    - DEFER — needs ≥3 pre-registered commits (selected BEFORE review runs)
    - Each commit must contain ≥1 seeded/known bug to measure recall
    - Blind scoring by third-party (not Blake who ran both reviews)

Fallback for all external model calls:
  Codex quota exhausted → skip image gen, use Mermaid (non-blocking)
  Codex auth failure → detect non-zero exit → log error → Mermaid fallback
  Gemini error → Claude-only research (skip Gemini leg)
```

---

## Time Log

| Spike | Claude-side | External-model-side | Total |
|-------|------------|-------------------|-------|
| A | 44s (Agent) | 28s (Codex) | ~5 min (parallel) |
| B | 97s (6× WebSearch) | 61s (Gemini) | ~6 min (sequential) |
| C | N/A | ~120s Codex + ~197s Gemini | ~7 min |
| **Total** | | | **~15 min** (wall-clock, within 3h budget) |

---

## Key New Discoveries (For Project Knowledge)

1. **`codex exec review --commit SHA --full-auto [PROMPT]`** fails — `--commit` and positional prompt are mutually exclusive. Must use stdin fallback: pipe diff to `codex exec --full-auto`.
2. **Gemini CLI `-p` is read-only**: No write_file, run_shell_command, or invoke_agent tools available. Suitable ONLY for text-output research tasks. Cannot save files or generate bitmaps.
3. **Gemini regex output requires BSD grep validation**: Gemini emits PCRE-style patterns (negative lookahead `(?!...)`) that fail silently in macOS `grep -E` (POSIX ERE). Never ship Gemini regex to TAD hooks without `grep -E` smoke test.
4. **Codex GPT Image-2 is production-quality**: Correctly follows multi-element prompts (colors, layout, labels). File auto-saved to `$CODEX_HOME/generated_images/` then copied to workspace. Requires separate quota from text calls.
5. **Cross-model spike methodology**: Prompt symmetry is load-bearing — asymmetric prompt shapes produce asymmetric output formats, which is not a model capability difference. Always use equivalent prompts for capability comparison.

---

## Code Reviewer Findings Summary (Layer 2 Group 1)

**P0s addressed in this report:**
- P0-1 (code-reviewer): Spike B verdict changed INTEGRATE → DEFER (asymmetric prompts)
- P0-2 (code-reviewer): Spike A production baseline added (code-reviewer ran on same commit: 1 P0, 3 P1, 8 total). SKIP verdict strengthened.
- P0-3 (code-reviewer): Spike C scoped to `*publish` only with budget cap
- P0-BA (backend-architect): No null hypothesis → FIXED by running production code-reviewer above; three-way comparison table added

**P1s acknowledged:**
- P1-1 (code-reviewer): Single-rater — future cross-model spikes need second rater or explicit rubric
- P1-2 (code-reviewer): Gemini regex lookahead fails BSD grep — documented in Key Discoveries #3 + Phase 2 retest spec requires regex-flavor pinning
- P1-3 (code-reviewer): Latency comparison has different overhead profiles — noted in Latency table
- P1-4 (code-reviewer): "4 novel patterns" corrected to 2 genuinely unique
- P1-5 (code-reviewer): Cost envelope added to Spike C; Phase 1 architecture has quota spec
- P1-6 (code-reviewer): AC4 thin but technically met
- P1-BA-1 (backend-architect): Quota accounting spec added to Phase 1 architecture
- P1-BA-2 (backend-architect): Auth failure fallback added to Phase 1 architecture
- P1-BA-3 (backend-architect): Regex flavor pinning added to Spike B retest conditions
- P1-BA-4 (backend-architect): Multi-language retest plan strengthened (pre-registration, seeded bugs, blind scoring)
