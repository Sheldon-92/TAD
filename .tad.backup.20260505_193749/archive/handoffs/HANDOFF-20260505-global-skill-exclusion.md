---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: yes
---

# Mini-Handoff: Global Skill Exclusion Declarations

**From:** Alex | **To:** Blake | **Date:** 2026-05-05
**Type:** Express (skip Socratic — diagnostic completed in *discuss)
**Priority:** P1

## Problem Statement

TAD's research methods (NotebookLM CLI, *research-plan, *research-notebook) are being bypassed because global skills with broader trigger conditions shadow them. Proven in menu-snap project: Alex spawned 4 generic WebSearch agents instead of running NotebookLM CLI.

Root cause: naming/semantic collision between TAD-specific methods and global skills (`/deep-research`, `/code-review`, `/review`, `/consulting-analysis`, `/frontend-design:frontend-design`).

## What Was Already Done (Alex, this session)

Archived 4 conflicting project-level skills to `.claude/skills/_archived/`:
- `research/SKILL.md` → `_archived/deep-research.md`
- `code-review/SKILL.md` → `_archived/code-review-standalone.md`
- `code-review/reference.md` → `_archived/code-review-reference.md`
- `coordinator/SKILL.md` → `_archived/coordinator-wrapper.md`
- `product/SKILL.md` → `_archived/product-wrapper.md`

## What Blake Needs To Do

### Task 1: Add Global Skill Exclusion Declaration to Alex SKILL

**File:** `.claude/skills/alex/SKILL.md`
**Anchor:** Find `core_principles:` block (around line 209-214). Insert AFTER the last `core_principles` list item and BEFORE the `# All commands require * prefix` line (~line 216). Add a blank line separator above the new block.

Add this YAML block:

```yaml

# ⚠️ GLOBAL SKILL EXCLUSION (TAD v2.10.1 — prevents cognitive shadowing)
global_skill_exclusion:
  description: |
    When Alex is active, the following global/user-level skills MUST NOT be invoked
    even if their trigger conditions match. TAD has its own methods for these tasks.
    DO NOT invoke the Skill tool for any of these. DO NOT spawn Agent tools as
    a substitute for TAD's CLI-based research workflows.
  excluded_skills:
    - name: "deep-research / research"
      reason: "TAD uses *research-notebook research --mode deep (NotebookLM CLI), not WebSearch multi-phase"
      tad_replacement: "*research-notebook research / *research-plan"
    - name: "code-review"
      reason: "TAD uses code-reviewer sub-agent with narrow-scope prompt template (expert_prompt_template)"
      tad_replacement: "Agent tool with subagent_type=code-reviewer + TAD prompt template"
    - name: "review"
      reason: "Alex *review = Gate 4 business acceptance, not PR review"
      tad_replacement: "*review / *accept (acceptance_protocol)"
    - name: "consulting-analysis"
      reason: "Alex *discuss + Domain Pack awareness provides structured analysis with pack-specific frameworks"
      tad_replacement: "*discuss with domain_pack_awareness"
    - name: "frontend-design:frontend-design"
      reason: "TAD uses /playground (standalone Design Explorer with DESIGN-SPEC.md → handoff integration)"
      tad_replacement: "/playground"
    - name: "security-review"
      reason: "TAD uses security-auditor sub-agent with narrow-scope TAD prompt template"
      tad_replacement: "Agent tool with subagent_type=security-auditor + TAD prompt template"
  enforcement: |
    If you catch yourself about to invoke any excluded skill or spawn a generic
    Agent for research: STOP. Read the tad_replacement path instead.
    For research specifically: Read .claude/skills/research-notebook/SKILL.md
    and follow the CLI steps using Bash tool. Sequential, not parallel.
```

### Task 2: Add Execution Mechanism to *research-plan step4

**File:** `.claude/skills/alex/SKILL.md`
**Location:** Line ~966 (research_plan_protocol → step4 → action)
**Anchor:** Find `For each confirmed research item:` inside `step4.action: |` block (~line 969).
**Insert BEFORE that line, at the same 8-space indentation as the surrounding content.**
**IMPORTANT:** This is inside a YAML `action: |` literal block scalar — all lines must use exactly 8 spaces base indentation to match surrounding content.

```
        ⚠️ EXECUTION MECHANISM (CRITICAL — prevents WebSearch fallback):
        *research-notebook commands run IN THIS SESSION using Bash tool.
        DO NOT delegate to background Agent tools.
        DO NOT invoke /deep-research or /research skill.
        
        To execute *research-notebook X:
        1. Read .claude/skills/research-notebook/SKILL.md (if not already in context)
        2. Run preflight: test -x ~/.tad-notebooklm-venv/bin/notebooklm
        3. If preflight PASS → follow sub-command steps using Bash tool (sequential)
        4. If preflight FAIL → announce to user:
           "⚠️ NotebookLM CLI not available. Falling back to WebSearch-based research.
            To enable NotebookLM: bash .tad/cross-model/setup-notebooklm.sh"
           Then SKIP the *research-notebook commands below entirely.
           Instead, use WebSearch/WebFetch IN THIS SESSION (not Agent tools)
           for each research item. Keep results in conversation context.
        
        NotebookLM is STATEFUL — cannot be parallelized across agents.
        Execute research items SEQUENTIALLY in this session.

```

### Task 3: Add Exclusion Declaration to Blake SKILL

**File:** `.claude/skills/blake/SKILL.md`
**Insert at:** Line 44 (after "有 Handoff → 必须用 Blake" line, before the `---` separator)

```yaml

# ⚠️ GLOBAL SKILL EXCLUSION (TAD v2.10.1)
# When Blake is active, DO NOT invoke these global skills:
# - /code-review → Use Layer 2 code-reviewer sub-agent with TAD prompt template
# - /review → Blake does not do PR review; Layer 2 handles code review
# - /security-review → Use security-auditor sub-agent with TAD prompt template
# - /deep-research → If research needed, escalate to user (Blake doesn't research)
# TAD sub-agents use NARROW-SCOPE prompts (§6/§9 only). Global skills do unfocused review.
```

### Task 4: Create Tool Quick Reference (Alex)

**File:** `.tad/guides/tool-quick-reference-alex.md` (NEW)

Create this file with the following content. This is a compact reference card that Alex loads at activation to know how to invoke all TAD tools without reading separate SKILL files.

```markdown
# Alex Tool Quick Reference
> Loaded at activation. Contains invocation methods only. Full workflows in referenced SKILLs.

## External CLI Tools

### NotebookLM
- **Path:** `~/.tad-notebooklm-venv/bin/notebooklm`
- **Preflight:** `test -x ~/.tad-notebooklm-venv/bin/notebooklm`
- **Setup:** `bash .tad/cross-model/setup-notebooklm.sh`
- **Key commands:**
  - Create notebook: `~/.tad-notebooklm-venv/bin/notebooklm create "<topic>"`
  - Auto-research (fast): `~/.tad-notebooklm-venv/bin/notebooklm source add-research "<topic>" --mode fast --import-all -n <id>`
  - Auto-research (deep): `~/.tad-notebooklm-venv/bin/notebooklm source add-research "<topic>" --mode deep --no-wait -n <id>` then `~/.tad-notebooklm-venv/bin/notebooklm research wait -n <id> --timeout 600 --import-all`
  - Ask (cross-source): `~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n <id>`
  - Add source: `~/.tad-notebooklm-venv/bin/notebooklm source add <url> -n <id>`
  - Summary: `~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>`
  - Generate report: `~/.tad-notebooklm-venv/bin/notebooklm generate report "<description>" -n <id>`
  - Ingest local file: `~/.tad-notebooklm-venv/bin/notebooklm source add <local_path> -n <id>`
- **Registry:** `.tad/research-notebooks/REGISTRY.yaml` (update after every create/add/research)
- **Full workflow:** `.claude/skills/research-notebook/SKILL.md`

### Codex CLI
- **Path:** `codex` (Homebrew global)
- **Preflight:** `command -v codex >/dev/null 2>&1`
- **Key commands:**
  - Execute: `echo "$prompt" | codex exec --full-auto "instructions"`
  - Code review: `{ echo "Review:"; cat diff.txt; } | codex exec --full-auto "P0/P1/P2 findings"`
  - SKILL inject: `cat SKILL.md | codex exec --full-auto "follow the protocol"`
  - Resume session: `codex exec resume --last`
  - Non-git dir: add `--skip-git-repo-check`
- **Constraints:** Sandbox workspace-write; stderr noise is benign; use exit code for success
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### Gemini CLI
- **Path:** `gemini` (`/opt/homebrew/bin/gemini`)
- **Preflight:** `command -v gemini >/dev/null 2>&1`
- **Key commands:**
  - Research: `gemini -p "<question>"`
  - With model: `gemini -m "gemini-2.5-flash" -p "<question>"`
  - Stdin: `cat file.txt | gemini -p "analyze"`
- **Constraints:** READ-ONLY (no writes, no shell commands). Must use `-p` or hangs forever.
  Regex output needs BSD grep-E validation before use in hooks.
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### GitHub CLI (gh)
- **Path:** `gh` (Homebrew global)
- **Key commands:**
  - Repo info: `gh api repos/{owner}/{repo}` (snake_case: `.full_name`, `.stargazers_count`)
  - Search repos: `gh search repos "query" --json fullName,stargazersCount` (camelCase)
  - Full tree: `gh api repos/{owner}/{repo}/git/trees/{branch}?recursive=1`
  - Repo contents: `gh api repos/{owner}/{repo}/contents/` (root only — use git/trees for full)
- **Full workflow:** `.claude/skills/research-github/SKILL.md`

## TAD Research Commands (Alex-domain)

### *research-notebook (19 commands — top 6 for daily use)
| Command | What it does | When to use |
|---------|-------------|-------------|
| `*research-notebook create "<topic>"` | Create notebook + add sources | New research topic |
| `*research-notebook research "<topic>" --mode deep` | Auto-discover 50+ sources | Deep dive |
| `*research-notebook ask "<question>"` | Cross-source Q&A with citations | During *discuss or *design |
| `*research-notebook report "<desc>"` | Generate structured report | Before handoff creation |
| `*research-notebook ingest <file_path>` | Feed local findings back into notebook | After writing research notes |
| `*research-notebook list` | Show all notebooks with status | Portfolio check |

Execution: Read `.claude/skills/research-notebook/SKILL.md` for the sub-command, then run CLI via Bash tool. SEQUENTIAL, not parallel Agent tools.

### *research-github (6 commands — top 3)
| Command | What it does | When to use |
|---------|-------------|-------------|
| `*research-github explore <domain>` | Browse awesome-lists in a domain | Tech discovery |
| `*research-github notebook <domain>` | Create NotebookLM notebook from registry entries | Deep study |
| `*research-github scan` | Weekly scan for new awesome-lists | Automated via /schedule |

Execution: Read `.claude/skills/research-github/SKILL.md` for the sub-command.

## TAD Hook Scripts (Alex invokes directly)

| Script | Purpose | Invocation |
|--------|---------|------------|
| `layer2-audit.sh` | Verify Blake's expert review artifacts | `bash .tad/hooks/lib/layer2-audit.sh <slug>` |
| `stale-knowledge-check.sh` | Advisory: flag possibly-stale knowledge entries | `bash .tad/hooks/lib/stale-knowledge-check.sh --json` |
| `trace-digest.sh` | Advisory: detect skipped Domain Pack steps | `bash .tad/hooks/lib/trace-digest.sh <slug>` |

## Domain Packs (20 packs)
- **Location:** `.tad/domains/{pack-name}.yaml`
- **How to load:** Read the YAML file during *design step1_5 or *discuss domain_pack_awareness
- **Matching:** SessionStart hook provides pack list via additionalContext; LLM matches task keywords
- **Registry:** `.tad/domains/tools-registry.yaml` for cross-pack tool index
```

### Task 5: Create Tool Quick Reference (Blake)

**File:** `.tad/guides/tool-quick-reference-blake.md` (NEW)

```markdown
# Blake Tool Quick Reference
> Loaded at activation. Contains invocation methods only. Full workflows in referenced SKILLs.

## External CLI Tools

### Codex CLI (for independent review)
- **Path:** `codex` (Homebrew global)
- **Preflight:** `command -v codex >/dev/null 2>&1`
- **Key commands:**
  - Code review from diff: `{ echo "Review:"; git diff HEAD~1..HEAD; } | codex exec --full-auto "P0/P1/P2 findings"`
  - SKILL-aware review: `cat .claude/skills/blake/SKILL.md | codex exec --full-auto "Review handoff implementation"`
  - Non-git dir: add `--skip-git-repo-check`
- **Constraints:** Sandbox workspace-write; stderr noise benign; exit code = truth
- **NOT a substitute for** Layer 2 code-reviewer sub-agent (independent second opinion only)
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### Gemini CLI (for read-only research)
- **Path:** `gemini -p "<question>"`
- **Constraints:** READ-ONLY. Use only when handoff explicitly calls for Gemini research.
- **Full guide:** `.tad/guides/cross-model-invocation.md`

## TAD Hook Scripts (Blake invokes directly)

| Script | Purpose | Invocation |
|--------|---------|------------|
| `gate3-git-tracked-check.sh` | Verify git-tracked dirs in handoff | `bash .tad/hooks/lib/gate3-git-tracked-check.sh` |
| `layer2-audit.sh` | Self-check: do my review artifacts exist? | `bash .tad/hooks/lib/layer2-audit.sh <slug>` |
| `trace-step.sh` | Record Domain Pack step execution trace | `bash .tad/hooks/trace-step.sh <event_type> <capability> <step> <pack>` |

## TAD Templates (Blake uses during completion)

| Template | When | Path |
|----------|------|------|
| Completion report | After Gate 3 pass | `.tad/templates/completion-report.md` |
| Session state | Init + completion | `.tad/templates/session-state-template.md` |
| Handoff B→A | Message to Alex | `.tad/templates/handoff-b-to-a.md` |

## NotebookLM (Blake-limited)
- Blake MAY use `*research-notebook ingest <file>` to feed implementation findings back
- **Path:** `~/.tad-notebooklm-venv/bin/notebooklm source add <file> -n <id>`
- Blake does NOT create notebooks or run research — that's Alex domain
```

### Task 6: Add Quick Reference loading to Alex activation protocol

**File:** `.claude/skills/alex/SKILL.md`
**Anchor:** Find `STEP 3.4: Load roadmap context` (~line 61). Insert a new step BEFORE it:

```yaml
  - STEP 3.3: Load tool quick reference
    action: |
      Read `.tad/guides/tool-quick-reference-alex.md` (if exists).
      This provides CLI paths, preflight checks, and key commands for all TAD tools.
      Without this file, Alex cannot invoke NotebookLM, Codex, Gemini, or research commands.
    blocking: false
    suppress_if: "File not found - skip silently (project may not have research tools installed)"
```

### Task 7: Add Quick Reference loading to Blake activation protocol

**File:** `.claude/skills/blake/SKILL.md`
**Anchor:** Find the `---` separator after "有 Handoff → 必须用 Blake" (~line 46). Insert BEFORE the `---`:

```yaml

# STEP 0.5: Load tool quick reference
# On activation, Read .tad/guides/tool-quick-reference-blake.md (if exists).
# Provides CLI paths and key commands for Codex, hooks, templates.
# Skip silently if file not found.
```

## Acceptance Criteria

- [ ] AC1: `grep -c "global_skill_exclusion:" .claude/skills/alex/SKILL.md` returns ≥ 1
- [ ] AC2: `grep -c "EXECUTION MECHANISM" .claude/skills/alex/SKILL.md` returns ≥ 1
- [ ] AC3: `grep -c "GLOBAL SKILL EXCLUSION" .claude/skills/blake/SKILL.md` returns ≥ 1
- [ ] AC4: `grep -c "security-review" .claude/skills/alex/SKILL.md` returns ≥ 1 (within exclusion block)
- [ ] AC5: `test -f .tad/guides/tool-quick-reference-alex.md && echo PASS` returns PASS
- [ ] AC6: `test -f .tad/guides/tool-quick-reference-blake.md && echo PASS` returns PASS
- [ ] AC7: `grep -c "tool-quick-reference-alex" .claude/skills/alex/SKILL.md` returns ≥ 1
- [ ] AC8: `grep -c "tool-quick-reference-blake" .claude/skills/blake/SKILL.md` returns ≥ 1
- [ ] AC9: Alex quick reference contains all 4 CLI tools: `grep -cE "Preflight|Path:" .tad/guides/tool-quick-reference-alex.md` returns ≥ 6

## Blake Instructions

- Tasks 1-3: Text insertion into existing SKILL files (find by anchor text, not line number)
- Tasks 4-5: Create NEW files (tool quick references) — content is fully specified above
- Tasks 6-7: Insert activation steps into SKILL files
- Apply all → run Layer 1 (grep ACs) → verify → done

## §6 Files to Modify / Create

| File | Change |
|------|--------|
| `.claude/skills/alex/SKILL.md` | Insert exclusion block + execution mechanism + STEP 3.3 |
| `.claude/skills/blake/SKILL.md` | Insert exclusion comment + STEP 0.5 |
| `.tad/guides/tool-quick-reference-alex.md` | NEW — Alex tool reference card |
| `.tad/guides/tool-quick-reference-blake.md` | NEW — Blake tool reference card |

**Grounded Against** (Alex step1c):
- .claude/skills/alex/SKILL.md (lines 193-207, read at 2026-05-05)
- .claude/skills/alex/SKILL.md (lines 966-980, read at 2026-05-05)
- .claude/skills/blake/SKILL.md (lines 1-50, read at 2026-05-05)
- .tad/guides/cross-model-invocation.md (lines 1-148, read at 2026-05-05)
- .claude/skills/research-notebook/SKILL.md (lines 1-80, 335-387, read at 2026-05-05)
- .claude/skills/research-github/SKILL.md (structure scan, read at 2026-05-05)
