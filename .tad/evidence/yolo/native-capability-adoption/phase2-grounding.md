# Phase 2 Grounding — subagent frontmatter upgrades (Conductor-written, 2026-07-13)

## Scope (from Epic Phase 2)
Two ideas, one file surface: (a) persistent `memory` for standing reviewer subagents with a
content-boundary rule (patterns only, never verdicts — anti-anchoring); (b) `skills` frontmatter
preload of capability packs replacing handoff-text transcription. Compose with pack≤2 guardrail.

## Actual state (verified by Conductor)

### Where subagent definitions live — CRITICAL constraint
- Agent defs are USER-LEVEL: `~/.claude/agents/*.md` (code-reviewer.md, security-auditor.md,
  backend-architect.md, ux-expert-reviewer.md, etc. — 30 files). Frontmatter today: name,
  description, model. NO memory/skills fields anywhere yet.
- The TAD repo has NO `.claude/agents/` directory. User-level files are NOT git-tracked in this
  repo and are shared across ALL projects on this machine.
- `spec-compliance-reviewer` (used in Blake Layer 2 language) has NO definition file — it is
  invoked as a prompt persona, not a registered agent type.

### Design tension the handoff MUST resolve (do not gloss)
1. Editing `~/.claude/agents/` = out-of-repo, machine-global, un-reviewable by git → conflicts
   with TAD evidence discipline. Creating PROJECT-LEVEL `.claude/agents/<name>.md` is git-tracked
   and project-scoped, BUT same-name shadowing/precedence semantics vs user-level MUST be verified
   by a spike (T1) before committing to the approach. Also verify: does a project-level def with
   the same name replace tools/model config of the user-level one entirely?
2. `memory` field semantics (value shape: boolean? path? scope?) and whether CLI 2.1.172 supports
   it — UNKNOWN. T1 spike: create a minimal project-level test agent with `memory` frontmatter,
   spawn it via Agent tool, have it write+read its memory dir, inspect where files land.
   Research base (yesterday, doc-level, NOT verified): subagent `memory` gives a persistent
   per-agent directory across sessions; `skills` preloads full skill content into agent context.
   Notebook b07a6598 re-askable but implementation must trust ONLY the local spike.
3. `skills` preload is STATIC per agent definition, but TAD's pack≤2 rule is per-TASK dynamic.
   Static mapping only fits stable pairs (e.g. security-auditor ← code-security). The dynamic
   case (implementation agents) may need per-handoff thin agent defs OR stay with handoff
   transcription — the design must choose explicitly and record the reasoning; "preload
   everything" violates pack≤2 and context budget.

### Memory content boundary (Epic requirement, human-decided)
- Reviewer memory stores: recurring defect PATTERNS, project-specific conventions, environment
  facts (e.g. "this repo: BSD grep, bash 3.2, no npm Layer 1").
- Reviewer memory MUST NOT store: past verdicts (PASS/FAIL), scores, per-handoff conclusions —
  anchoring/Rubber-Stamp guard (principles.md 2026-07-03 AI/Human domain entry).
- Boundary must be written INTO the agent definition body (system-prompt level), not just docs.
- Memory dir should be gitignored if it contains session-derived content (public repo).

### Where current pack-transcription happens (for (b))
- Handoff template §"Capability Pack References" + Blake SKILL step (grep for exact section
  name in .claude/skills/blake/SKILL.md and .tad/templates/handoff-a-to-b.md before designing).

### Layer 1 for this repo
No npm/tsc. Substitute: bash -n for scripts; for agent-def .md files — frontmatter YAML parse
check (python3 yaml.safe_load on the frontmatter block) + spawn-test via Agent tool where possible.

### Evidence dir
`.tad/evidence/yolo/native-capability-adoption/` (phase2-*). Spike evidence:
`.tad/evidence/spikes/subagent-frontmatter-2026-07/` (create).

## Worktree note
`.claude/agents/` (project-level, if created) is inside the repo → normal git flow in worktree.
Do NOT edit `~/.claude/agents/` from the worktree — anything machine-global belongs in the
completion report §Escalations for human decision.
