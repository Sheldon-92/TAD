---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/codex", ".tad/hooks/lib", ".claude/workflows"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260603-dynamic-workflow-integration.md (Phase 4/5)

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | Adapter interface + Codex tournament PoC + runtime detection |
| Components Specified | OK | 1 adapter script + 1 Codex tournament script + SKILL.md detection |
| Functions Verified | OK | Codex auth confirmed working (gpt-5.5, ChatGPT account mode) |
| Data Flow Mapped | OK | Same judgment rules → platform-specific orchestration → same structured output |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Create a cross-platform adapter that lets TAD's tournament workflow run on both Claude Code (via Workflow tool) and Codex CLI (via `codex exec` subagents). Design a runtime detection mechanism so TAD automatically selects the right orchestration backend. Prove the concept with the tournament-design workflow as PoC.

**Why now:** P0-P3 built 4 workflows on Claude Code. Codex CLI has subagents (2026-03 GA) with `codex exec --output-last-message` for structured output capture. TAD should work on both platforms — same judgment, different orchestration.

---

## 2. Requirements

### Functional
- FR1: Create `.tad/codex/tournament-codex.sh` — Bash script that runs the tournament pattern using `codex exec` subagents instead of Workflow tool (co-located with existing .tad/codex/ Codex scripts)
- FR2: Create `.tad/hooks/lib/detect-platform.sh` — Runtime detection: which orchestration backend is available (cross-platform utility, belongs in hooks/lib)
- FR3: Integrate detection into alex/SKILL.md: when user picks *tournament, detect platform and route to correct backend
- FR4: Codex tournament must produce the same MERGED_DESIGN_SCHEMA output as the Claude Code version
- FR5: Codex tournament supports standard mode (2 competitors + 1 judge) only (deep mode deferred — cost on Codex is different)

### Non-Functional
- NFR1: Codex runs with ChatGPT account (current state) — model selection limited to gpt-5.5 default
- NFR2: `codex exec` uses `--output-last-message <file>` AND `--output-schema <file>` for mechanical JSON schema validation (confirmed on this machine — NOT prompt-dependent)
- NFR3: No dependency on Codex team/MCP features — use simple `codex exec` pipeline (proven, reliable)
- NFR4: Graceful degradation: if neither Workflow tool nor Codex available → fall back to single-agent design (no tournament)
- NFR5: Temp dir: use `mktemp -d -t tad-tournament.XXXXXX` with `trap 'rm -rf "$TMPDIR"' EXIT` — no fixed paths, no collision, no stale files
- NFR6: Schema files: write DESIGN_SCHEMA, JUDGE_SCHEMA, MERGED_DESIGN_SCHEMA to `.tad/codex/schemas/*.json` with `additionalProperties: false` on all objects (OpenAI structured output requirement)

---

## 3. Technical Design

### Platform detection (`detect-platform.sh`)

```bash
#!/bin/bash
# Returns: "workflow" | "codex" | "none"

# Tier 1a: Claude Code with Workflow tool
# CAPABILITY CHECK, not file-system check (P0 fix from expert review).
# The Workflow tool is a session-level Claude Code capability.
# Check for Claude Code environment markers first.
if [ -n "${CLAUDE_CODE_SESSION:-}" ] || [ -n "${CC_SESSION:-}" ]; then
  # Inside Claude Code — Workflow tool is available
  echo "workflow"
  exit 0
fi
# Fallback heuristic: if no env var, check parent process name
if ps -o comm= -p "$PPID" 2>/dev/null | grep -qi "claude"; then
  echo "workflow"
  exit 0
fi

# Tier 1b: Codex CLI available
if command -v codex >/dev/null 2>&1; then
  # Zero-cost auth check: version command confirms binary + auth (no LLM call)
  if codex --version >/dev/null 2>&1; then
    echo "codex"
    exit 0
  fi
fi

# Tier 3: No orchestration available
echo "none"
exit 0
```

### Codex tournament (`tournament-codex.sh`)

Architecture: sequential `codex exec` calls with `--output-schema` for mechanical JSON validation. Each call gets a clean context (independent session). Uses `mktemp -d` for isolation.

```
Input: task (via stdin/file), prior_art[] (file paths), rubric (JSON file)
Temp: TMPDIR=$(mktemp -d -t tad-tournament.XXXXXX); trap 'rm -rf "$TMPDIR"' EXIT
Schemas: .tad/codex/schemas/{design,judge,merged}.json (with additionalProperties:false)

Step 1: Competitor A — codex exec --output-schema schemas/design.json -o $TMPDIR/design-a.json
Step 2: Competitor B — codex exec --output-schema schemas/design.json -o $TMPDIR/design-b.json
  ↓
Step 3: Judge — codex exec reads both designs, --output-schema schemas/judge.json -o $TMPDIR/judge.json
  ↓
Step 4: Synthesizer — codex exec reads winner + judge, --output-schema schemas/merged.json -o $TMPDIR/merged.json
  ↓
Output: merged-design.json (same schema as Claude Code tournament)
```

Each `codex exec` call uses:
- `--output-last-message /tmp/tournament/{step}.txt` to capture result
- Prompt instructs agent to output JSON matching the schema
- `--sandbox=allow` (or appropriate sandbox policy for file read/write)

### SKILL.md integration

In alex/SKILL.md, the `*tournament` command and `step1_5c` should:
1. Call `bash .tad/adapters/detect-platform.sh`
2. If "workflow" → invoke Workflow({name: 'tournament-design', args: {...}})
3. If "codex" → invoke `bash .tad/adapters/tournament-codex.sh "{task}" "{prior_art_json}" "{rubric_json}"`
4. If "none" → announce "No multi-agent backend available. Running single-agent design."

### Degradation tiers (formalized)

| Tier | Platform | Mechanism | Quality |
|------|---------|-----------|---------|
| 1a | Claude Code + Workflow | tournament-design.workflow.js (parallel, schema-validated) | Highest |
| 1b | Codex CLI | tournament-codex.sh (sequential codex exec, --output-schema validated) | Good (serial but schema-validated — quality delta is parallelism only) |
| 2 | Claude Code no Workflow | Agent tool parallel spawn | Medium (deferred — not implemented in P4) |
| 3 | None | Single-agent design | Baseline |

Note: Tier 2 is listed for completeness but NOT implemented in this handoff. Routing skips from 1a → 1b → 3.

---

## 4. Files to Create / Modify

| File | Action | Scope |
|------|--------|-------|
| `.tad/hooks/lib/detect-platform.sh` | CREATE | ~25 lines: runtime platform detection (env var + process check) |
| `.tad/codex/tournament-codex.sh` | CREATE | ~150-200 lines: Codex tournament pipeline with --output-schema |
| `.tad/codex/schemas/design.json` | CREATE | DESIGN_SCHEMA with additionalProperties:false |
| `.tad/codex/schemas/judge.json` | CREATE | JUDGE_SCHEMA with additionalProperties:false |
| `.tad/codex/schemas/merged.json` | CREATE | MERGED_DESIGN_SCHEMA with additionalProperties:false |
| `.claude/skills/alex/SKILL.md` | MODIFY | *tournament command: add platform detection + routing (3 branches) |

**Grounded Against** (Alex step1c, read 2026-06-03):
- Codex CLI `codex exec --help` (confirmed: --output-last-message, --sandbox, --model flags)
- Codex auth test: `echo "reply with just the word working" | codex exec` → "working" (gpt-5.5, ChatGPT account)
- .claude/workflows/tournament-design.workflow.js (389 lines — the Claude Code version being ported)
- .claude/skills/alex/SKILL.md step1_5c (tournament integration point)

---

## 5. Acceptance Criteria

| AC | Requirement | Verification Method | Expected Evidence |
|----|------------|--------------------|--------------------|
| AC1 | detect-platform.sh works | `bash .tad/adapters/detect-platform.sh` | Returns "workflow" or "codex" (depending on env) |
| AC2 | Codex tournament runs | `bash .tad/adapters/tournament-codex.sh` with test args | Produces merged-design JSON file |
| AC3 | Output schema matches | Compare Codex output fields against MERGED_DESIGN_SCHEMA from tournament-design.workflow.js | Same required fields present |
| AC4 | Platform routing in SKILL.md | `grep 'detect-platform' .claude/skills/alex/SKILL.md` and `grep -c 'workflow\|codex\|none' .claude/skills/alex/SKILL.md` in *tournament section | >= 1 detect-platform + 3 routing branches |
| AC5 | Degradation works | With codex unavailable: `PATH="" bash .tad/hooks/lib/detect-platform.sh` | Returns "none" |
| AC6 | SAFETY unchanged | `grep -c 'NOT_via_alex_auto\|forbidden_implementations' .claude/skills/alex/SKILL.md` | == 20 |
| AC7 | Codex uses --output-schema | `grep -c 'output-schema' .tad/codex/tournament-codex.sh` | >= 4 (one per step: 2 competitors + judge + synthesizer) |
| AC8 | Schema files exist | `ls .tad/codex/schemas/{design,judge,merged}.json` | All 3 exist with additionalProperties:false |
| AC9 | Temp dir isolated | `grep 'mktemp -d' .tad/codex/tournament-codex.sh` and `grep 'trap.*rm.*EXIT' .tad/codex/tournament-codex.sh` | Both match |
| AC10 | Detection is runtime-based | `grep -v 'workflow.js' .tad/hooks/lib/detect-platform.sh` should still contain the workflow detection logic (env var based, not file based) | No .workflow.js file check in detection |

---

## 6. Important Notes

### 6.1 Codex limitations and capabilities (current state)
- ChatGPT account mode: model locked to gpt-5.5, cannot specify gpt-4.1-mini
- No parallel execution: competitors run sequentially (adds ~2-3 min vs Claude Code parallel)
- HAS schema validation: `--output-schema <file>` provides mechanical JSON validation (CR P0-1 discovery). Requires `additionalProperties: false` on all objects per OpenAI structured output spec
- HAS output capture: `--output-last-message <file>` captures agent's last message to file
- No `--quiet` flag: output includes headers, use `-o` for clean output
- Sandbox: use `--sandbox workspace-write` for temp dir write access (not `allow` — that flag doesn't exist)

### 6.2 What NOT to do
- DO NOT require Codex team/MCP features (complex, fragile, not needed for tournament)
- DO NOT modify the Claude Code tournament-design.workflow.js (the adapter wraps, not replaces)
- DO NOT hardcode model names (ChatGPT account may change available models)
- DO NOT use `forbidden_implementations` or `NOT_via_alex_auto` strings in adapter scripts

### 6.3 Testing strategy
Blake should test by actually running the Codex tournament on a small task (e.g., "Design a naming convention for TAD workflow files" with 2 prior art sources). This validates both the Codex pipeline and the output schema compatibility.

---

## 7. Project Knowledge

### Blake must note:
- **Codex subagents** (2026-03 GA): TOML agent definitions in `~/.codex/agents/`, but we use simple `codex exec` (more reliable, less setup)
- **Dual-platform idea** (IDEA-20260603): judgment stays in SKILL.md, orchestration is platform-specific
- **Codex auth**: currently ChatGPT account (not API key), which limits model selection

---

## 8. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Codex orchestration | codex exec pipeline / TOML agents / MCP server | codex exec pipeline | Simplest, most reliable. TOML agents + MCP adds complexity for minimal gain in tournament scenario |
| 2 | PoC workflow | gate-review / tournament / epic-audit | tournament | User chose. Most complex PoC proves the most. |
| 3 | Standard only on Codex | Standard + deep / Standard only | Standard only | Codex is sequential (no parallel), deep mode would be very slow. Defer deep to future. |
| 4 | Output capture | Parse stdout / --output-last-message | --output-last-message | Reliable, file-based, no stdout parsing needed |

---

## 9. Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/blake/cross-platform-adapter-p4/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/cross-platform-adapter-p4/spec-compliance.md
    required: true
gate_verdicts:
  - path: .tad/evidence/reviews/blake/cross-platform-adapter-p4/gate3-verdict.md
    required: true
completion:
  - path: .tad/active/handoffs/COMPLETION-20260603-cross-platform-adapter-p4.md
    required: true
```
