# TAD Codex Adapter

Enables TAD workflows on Codex CLI — a fallback channel when Claude Code quota runs out.

## Recommended Entry Point

If you're using Codex CLI interactively (not via launcher scripts), the easiest way is:

```bash
codex  # AGENTS.md in the project root auto-loads on startup
       # Then say "当 Alex" or "当 Blake" to activate a role
```

`AGENTS.md` (project root) tells Codex about both roles and handles switching automatically.
The launcher scripts below are for non-interactive / scripted use.

## Quick Start

```bash
# Start Blake (Execution Master)
bash .tad/codex/codex-tad-blake.sh

# Start Alex (Solution Lead)
bash .tad/codex/codex-tad-alex.sh

# Dry-run (verify without launching)
bash .tad/codex/codex-tad-blake.sh --dry-run
bash .tad/codex/codex-tad-alex.sh --dry-run
```

## Contents

| File | Purpose |
|------|---------|
| `codex-tad-blake.sh` | Blake launcher (pipes static SKILL to Codex) |
| `codex-tad-alex.sh` | Alex launcher |
| `codex-blake-skill.md` | Static Codex-edition Blake SKILL (AskUserQuestion stripped) |
| `codex-alex-skill.md` | Static Codex-edition Alex SKILL |
| `manual-gates.md` | Gate 3 manual steps (replaces Claude Code hooks) |
| `sequential-review.md` | Layer 2 reviewer sessions guide (Blake-side) |
| `socratic-fallback.md` | Socratic dialog without AskUserQuestion (Alex-side) |
| `expert-review-sequential.md` | Gate 2 expert review guide (Alex-side) |

## Key Differences from Claude Code

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Structured options | `AskUserQuestion` tool | Numbered text list |
| Parallel reviewers | `Agent` tool (parallel) | Sequential `codex exec` sessions |
| Background tasks | Background agents | Sequential (one at a time) |
| Auto-hooks | `settings.json` (auto-triggered) | Manual bash scripts |
| File writes | Auto-approved | Interactive mode or manual approval |

## Multi-Turn Sessions

TAD workflows require multiple turns. Use `codex exec resume --last`:

```bash
# Turn 1: Start Alex session
cat .tad/codex/codex-alex-skill.md | codex exec --full-auto "You are Alex. Start Socratic Inquiry for: [describe task]"

# Turn 2: Answer questions, continue
codex exec resume --last "My answers: 1. [answer1] 2. [answer2] 3. [answer3]. Continue to Round 2."

# Turn 3: Design confirmation
codex exec resume --last "Continue to design and create handoff."
```

## Troubleshooting

**Codex can't write files**
```
⚠️  Codex sandbox may be read-only.
```
Use interactive mode (remove `--full-auto`) or approve writes manually.

**SKILL not found**
```
ERROR: SKILL file not found: /path/.tad/codex/codex-blake-skill.md
```
Run from project root (where `.tad/` exists).

**Session context lost**
Use `codex exec resume --last` to continue in the same session.

**Model selection**
Default model is gpt-5.5. Do NOT specify `-m o4-mini` — ChatGPT accounts may not support it.

## Updating Codex-Edition SKILLs

When `.claude/skills/blake/SKILL.md` or `.claude/skills/alex/SKILL.md` changes:
1. Review the changes
2. Update `codex-blake-skill.md` or `codex-alex-skill.md` following rules in `.tad/portable-rules.md`
3. Verify: `grep -c AskUserQuestion .tad/codex/codex-blake-skill.md` must equal 0
4. Verify: `grep -c 'MUST\|MANDATORY\|VIOLATION' .tad/codex/codex-blake-skill.md` must be ≥ 10

## Related Files

- `.tad/portable-rules.md` — Classification of portable vs CC-only files
- `.tad/portable-extract.sh` — Export helper to create `codex-tad-bundle/`
- `.tad/hooks/lib/` — Bash scripts for manual gate checks
