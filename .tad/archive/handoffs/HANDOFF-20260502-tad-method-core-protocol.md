---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 1 — TAD Method Core Protocol (Production Quality)

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-05-02
**Priority:** P1
**Epic:** EPIC-20260502-tad-universal-method.md (Phase 1/5)

---

## 1. Task Overview

Build the production-quality TAD Method repo from the Phase 0 spike. Create a proper repo at `~/tad-method/` with:
1. Upgraded protocol.md (expand spike's 300 lines to ~400-500, all sections hardened)
2. Updated platform entry files (AGENTS.md + CLAUDE.md)
3. README.md (product documentation — enough for a friend to understand and start using)
4. Proper repo structure with git init

Phase 0 validated the concept (3/3 axes GO). Phase 1 makes it production-ready.

## 2. Background

Phase 0 spike findings that MUST be incorporated:
1. **State-machine transitions must be explicit** — every section needs "→ next section" arrows (P0-2 fix)
2. **Bootstrapping path** — create dirs if missing (P0-1 fix, already in spike)
3. **Sequential question format** — named Q1/Q2/Q3 blocks with inter-step gates, NOT numbered lists (P0-3 fix)
4. **Confirmation gate before file writes** — Step 4b (P0-4 fix, already in spike)
5. **ASCII-only handoff format** — no emoji/box-drawing chars for cross-platform safety (P1-5 fix)
6. **`--skip-git-repo-check` for Codex** — needed for non-git dirs, but Phase 1 repo WILL have git init
7. **Protocol constraint adherence is strong** — Codex refused to skip Step 4, so protocol text creates real behavioral constraints

## 3. Requirements

### FR1: New Repo Setup
Create `~/tad-method/` with git init. This is the actual product repo, not a test directory.

### FR2: Production protocol.md (~400-600 lines)
Take spike's protocol.md as starting point. Upgrade ALL sections.

⚠️ **Spike Markdown Bug**: Spike protocol has unbalanced code fences in Sections 6 and 7 (handoff format and self-check template code blocks are not properly closed). Fix fence balance when upgrading — ensure every ``` has a matching ```.

**Section 1 — State Detection**: Keep spike logic (create dirs, read state.yaml, route to Init/Work). If state.yaml is missing or malformed → treat as `initialized: false`. If roles/ is empty but state=initialized:true → treat as corrupted, restart init. Remove the `initialized: partial` concept — spike worked fine without it, and specifying when to write `partial` adds design ambiguity.

**Section 2 — Init Mode**: Strengthen the Socratic conversation:
- Add Q4: "What's the biggest risk — what could make this project fail or go wrong?" (before role derivation starts, feeds into Step 4)
- Add quality self-check for AI: after deriving each role, verify against 3 criteria (name not generic, responsibilities reference the domain, forbidden actions are domain-relevant) before showing to user
- Keep sequential question format (Q1→wait→Q2→wait→Q3→wait→Q4)
- Keep confirmation gate (Step 4b) before file writes
- Improve post-init instruction (spike Finding #4): instead of "Close this session and reopen", use platform-aware instruction: "Setup complete! To start working, open a new terminal in this folder and start your AI tool again. It will detect the setup and ask which role you want." (clearer for non-technical users)

**Section 3 — Role Selection**: Keep spike logic. Add: if roles/ files are missing but state=initialized:true → warn user, offer to re-run init.

**Section 4 — Alex (Planner)**: Strengthen:
- Add explicit instruction: "Before producing handoff, verify your plan is actionable — would Blake know exactly what to produce without asking you another question?"
- Add: "If the task is ambiguous, ask 2-3 targeted questions. Do NOT start planning with unclear scope."
- Add: Alex can break large tasks into multiple handoffs (one at a time)

**Section 5 — Blake (Executor)**: Strengthen:
- Add: "Before executing, restate the task and AC in your own words to confirm understanding"
- Add: "If any AC is impossible to satisfy, report it as BLOCKED with reason — do not silently skip"
- Add: Blake flags when the task scope seems too large ("This handoff covers too many things — suggest Alex split it")

**Section 6 — Handoff Format**: Keep spike's ASCII format. Add:
- Optional "Priority" field (P0=urgent, P1=important, P2=nice-to-have)
- Optional "References" field (links, files, or context Blake should read)
- Add explicit instruction: "DO NOT use emoji, Unicode box-drawing characters (─ ═ │), or decorative symbols in handoff messages. Use ASCII only (=== --- etc.) for cross-platform safety." (spike Test 3 showed AI still used emoji despite protocol fix — stronger language needed)
- If Alex produces multiple handoffs for a large task, number them (Handoff 1/3, 2/3, 3/3)

**Section 7 — Self-Check Protocol**: Keep spike format. Add:
- BLOCKED status (AC can't be evaluated — needs Alex input)
- "Open Questions" field in report (things Blake noticed that Alex should know)

**Section 8 — Terminal Isolation**: Keep spike rules. Add:
- Platform-specific note: "On Codex, open a separate `codex` session. On Claude Code, open a separate `claude` session. On any platform, the key is: two independent AI sessions, same project folder."
- Note: "If your AI tool doesn't support two simultaneous sessions, you can use one session at a time — switch between Alex and Blake by re-entering the project folder. Less ideal but workable."

**Section 9 — Domain References**: Keep spike's 3 examples (视频制作, 数据分析, 内容营销). Clean up formatting if needed. Phase 2 will expand to 5-8.

**New Section 10 — Troubleshooting**:
- "state.yaml says initialized but roles/ is empty" → re-run init
- "AI doesn't enter init mode" → check entry file (AGENTS.md/CLAUDE.md) references protocol.md correctly
- "AI gives generic roles" → provide more specific project description, mention target audience and output format
- "Codex says 'not inside a trusted directory'" → add --skip-git-repo-check flag

### FR3: Platform Entry Files
- `AGENTS.md`: Same pattern as spike but updated for production. Include note about --skip-git-repo-check if no git init.
- `CLAUDE.md`: Same pattern, Claude Code format.

### FR4: README.md
Write a product README (~100-150 lines) covering:
- What is TAD Method (1 paragraph)
- How it works (2-agent model, visual diagram)
- Quick Start (3 steps: install, init, use)
- Platform Support (Claude Code + Codex, more coming)
- FAQ (3-5 common questions)
- Comparison with "just using AI directly" (why this is better)
- License (MIT)

Style: Written for non-technical users. No jargon. Short sentences. The README should make someone WANT to try it.

**DO NOT include in README**: gates, layers, hooks, evidence directories, domain packs, YAML configuration details, Ralph Loop, Socratic Inquiry Protocol, or any TAD-internal terminology. The reader has never heard of TAD.

### FR5: Validation
After all files created, run 3 tests. Record in `~/tad-method/VALIDATION.md`.

**Test 1 (Codex — Blake runs)**:
```bash
cd ~/tad-method
echo "initialized: false" > .tad-lite/state.yaml
rm -f .tad-lite/roles/*.md
codex exec --full-auto --skip-git-repo-check "Per AGENTS.md, this project is a 10-minute B站科普视频 about sleep science for 18-25 year olds. Run through the full init."
```
Verify: AI enters init, derives roles, writes files. Check role quality per AC12 rubric.

**Test 2 (Claude Code — simulation within Blake session)**:
Blake simulates the Claude Code test by reading CLAUDE.md → protocol.md → following Init Mode steps manually (same method as Phase 0 Test 2). This is a simulation, not a real Claude Code session — Blake cannot launch Claude Code from within Claude Code. Record in VALIDATION.md with note: "Simulated — real Claude Code session validation deferred to Phase 4 dogfood."

**State Reset** between Test 1 and Test 2:
```bash
echo "initialized: false" > .tad-lite/state.yaml && rm -f .tad-lite/roles/*.md
```

**Test 3 (Dual-terminal — Codex or simulation)**:
After a successful init, test Alex→handoff→human relay→Blake execute→self-check flow.
Use the same project scenario (科普视频). Verify handoff uses ASCII-only format.

## 4. Technical Design

### Directory Structure
```
~/tad-method/
├── .git/                        ← git init
├── AGENTS.md                    ← Codex entry
├── CLAUDE.md                    ← Claude Code entry
├── README.md                    ← Product documentation
├── LICENSE                      ← MIT license
├── VALIDATION.md                ← Phase 1 test results
└── .tad-lite/
    ├── protocol.md              ← Core protocol (production, ~400-500 lines)
    ├── state.yaml               ← {initialized: false}
    └── roles/                   ← Empty, filled after init
```

### Upgrade Strategy
1. Copy spike protocol.md from `~/tad-universal-spike/.tad-lite/protocol.md` as starting point (effective content ~280 clean lines — spike has Markdown fence bugs in Sections 6-7 that inflate the count)
2. Fix code fence balance first (Sections 6 and 7 have unclosed ``` blocks)
3. Apply all upgrades listed in FR2
4. Do NOT start from scratch — the spike version has been validated and code-reviewed (5 P0 fixed, 2-platform GO)

## 5. Acceptance Criteria

All commands assume `cwd = ~/tad-method/`.

| AC | Description | Verification |
|----|-------------|-------------|
| AC1 | Repo created with git init | `git -C ~/tad-method rev-parse --git-dir` exits 0 |
| AC2 | protocol.md exists, 400-600 lines, ≥10 sections | `wc -l .tad-lite/protocol.md` (400-600) + `grep -cE '^## [0-9]+\.' .tad-lite/protocol.md` (≥10) |
| AC3 | All spike P0 fixes preserved (state-machine transitions, bootstrapping, sequential Qs, confirmation gate, ASCII format) | Manual review of protocol.md |
| AC4 | New Section 10 (Troubleshooting) exists with ≥4 entries | `sed -n '/^## 10\./,$p' .tad-lite/protocol.md \| grep -c '^###'` ≥ 4 |
| AC5 | README.md exists, 100-200 lines, written for non-technical users | `wc -l README.md` (100-200) |
| AC6 | AGENTS.md + CLAUDE.md exist, each <1000 bytes, reference protocol.md | `wc -c` + `grep -q protocol.md` |
| AC7 | LICENSE file exists (MIT) | `head -1 LICENSE` |
| AC8 | state.yaml = initialized: false | `cat .tad-lite/state.yaml` |
| AC9 | Codex test: init → role derivation with quality rubric pass | VALIDATION.md §Codex |
| AC10 | Claude Code test (simulation): init flow followed, roles derived | VALIDATION.md §Claude (note: simulated, real test in Phase 4) |
| AC11 | Dual-terminal test: handoff → relay → execute → self-check | VALIDATION.md §Dual-Terminal |
| AC12 | Role derivation quality rubric: name not generic, domain refs, domain-relevant forbidden actions | VALIDATION.md §Quality |
| AC13 | No unintended TAD repo modifications | `git -C "$HOME/01-on progress programs/TAD" diff --name-only` shows only expected files (handoff, epic, NEXT.md) |

### AC12 Quality Rubric (same as Phase 0 AC11)
- Role name is NOT "Planner"/"Executor"/"规划者"/"执行者"
- At least 1 responsibility references the specific domain
- Forbidden actions are domain-relevant

## 6. Files to Create/Modify

| # | File | Action | Location |
|---|------|--------|----------|
| 1 | protocol.md | CREATE (from spike upgrade) | ~/tad-method/.tad-lite/ |
| 2 | state.yaml | CREATE | ~/tad-method/.tad-lite/ |
| 3 | AGENTS.md | CREATE | ~/tad-method/ |
| 4 | CLAUDE.md | CREATE | ~/tad-method/ |
| 5 | README.md | CREATE | ~/tad-method/ |
| 6 | LICENSE | CREATE | ~/tad-method/ |
| 7 | VALIDATION.md | CREATE | ~/tad-method/ |
| 8 | roles/ | CREATE DIR | ~/tad-method/.tad-lite/ |

**Grounded Against**: ~/tad-universal-spike/.tad-lite/protocol.md (spike source, 300 lines — read by Alex at 2026-05-02)

## 7. Important Notes

### 7.1 This is OUTSIDE the TAD repo
All files go to `~/tad-method/`. Do not modify TAD repo files.

### 7.2 Start from spike, don't rewrite from scratch
Copy spike protocol.md as starting point. The spike version was code-reviewed (5 P0 fixed) and validated on 2 platforms. Build on it, don't throw it away.

### 7.3 README is for non-technical users
Write as if explaining to a friend who uses Codex but has never heard of TAD. No developer jargon. No YAML config explanations. Just "what it does, how to start, why it's better."

### 7.4 Time budget
3-hour hard cap. Protocol upgrade is the priority — if time runs short, README can be minimal.

### 7.5 State reset between tests
Reset state.yaml to `initialized: false` and clear roles/ between Test 1 and Test 2 (same as Phase 0).

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| BA + CR | P0: Spike Markdown fence bug in Sections 6-7 | Added warning to FR2 + Upgrade Strategy step 2 | Resolved |
| CR | P0: Spike Finding #4 "exit and re-enter" UX not addressed | Added to FR2 Section 2 Init Mode upgrades | Resolved |
| BA | P0: Validation tests — Blake can't launch Claude Code from Claude Code | AC10 marked as simulation, real test deferred to Phase 4 dogfood | Resolved |
| BA | P0: No AC for TAD repo safety | AC13 added — git diff on TAD repo | Resolved |
| CR | P0: AC4 grep '###' matches entire file, not Section 10 | Replaced with `sed -n '/^## 10\./,$p' \| grep -c '^###'` | Resolved |
| BA | P1: AC2 line range 400-500 too tight | Widened to 400-600 | Resolved |
| BA | P1: README 100-150 too tight | Widened to 100-200 | Resolved |
| CR | P1: `initialized: partial` under-specified | Removed — spike worked without it, adds design ambiguity | Resolved |
| CR | P1: ASCII-only handoff needs stronger language | Added explicit "DO NOT use emoji/Unicode" instruction to FR2 Section 6 | Resolved |
| CR | P2: README "what NOT to include" | Added negative constraint list to FR4 | Resolved |
| BA | P1: Entry files <500 bytes too tight | Raised to <1000 bytes | Resolved |
| BA | P1: Epic Phase Map missing GitHub publish step | Noted — not a Phase 1 issue, track in gate4_delta | Deferred |

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

1. **Protocol State-Machine Design (2026-05-02)** — architecture.md. Three mandatory patterns: explicit state-machine transitions, bootstrapping path for missing resources, named question blocks (not numbered lists). All already in spike — PRESERVE them.

2. **`codex exec --skip-git-repo-check` (2026-05-02)** — architecture.md. Required for non-git dirs. Phase 1 repo WILL have git init, but AGENTS.md should still document this for users who clone without git.

3. **Codex AGENTS.md Auto-Load (2026-05-02)** — architecture.md. "Read file then follow protocol" reference pattern works. Keep AGENTS.md slim, protocol in separate file.

## 8. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Repo location | ~/tad-universal-spike / ~/tad-method / GitHub | ~/tad-method/ local with git init | Production repo, not spike. GitHub push is Phase 5. |
| 2 | protocol.md size | Keep 300 / Expand to 400-500 / Expand to 600+ | 400-500 lines | Enough room for all upgrades without bloat |
| 3 | README audience | Developers / Non-tech users / Both | Non-tech users | MVP target audience is non-technical friends |
| 4 | Domain examples | Keep 3 / Expand to 5-8 | Keep 3 (Phase 2 expands) | Phase 1 = core protocol, Phase 2 = domain templates |
| 5 | Upgrade strategy | Rewrite from scratch / Iterate from spike | Iterate from spike | Spike was validated + code-reviewed, don't throw away |
