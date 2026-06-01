# Codex-Edition Regeneration Procedure

> Reusable procedure: given the current Claude `alex/SKILL.md` source + `.tad/portable-rules.md`,
> produce a Codex-edition Alex SKILL. This procedure is designed to be run by an LLM agent
> (Claude or Codex) at release time.

## Prerequisites

- Access to `.claude/skills/alex/SKILL.md` (the Claude source — read-only)
- Access to `.tad/portable-rules.md` (the transform rules — read-only)
- Write access to the output path (scratch or live edition)

## Procedure

### Step A: Read inputs

1. Read the full `.claude/skills/alex/SKILL.md` (source).
2. Read `.tad/portable-rules.md` (transform rules).

### Step B: Apply Strip → Replace transforms (line-local, NOT summarization)

Apply each row of the `Strip → Replace` table in `portable-rules.md`:

- `AskUserQuestion` tool calls → "List options as numbered text (1. ... / 2. ... / 3. ...). User types number or free text to respond."
- `Agent` tool / sub-agent parallel spawning → "Start a new `codex exec` session with the reviewer persona prompt. Run sessions sequentially."
- `Skill` tool / `/command` syntax → "Read the relevant file and follow its protocol."
- `ToolSearch` references → Remove
- `Monitor` references → Remove
- `SendMessage` references → Remove
- `EnterPlanMode` → Keep prohibition text, remove "(Claude Code tool)" explanation
- Hook references (`PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`) → "Run bash script manually when needed: `bash .tad/hooks/lib/{script}.sh`"
- `settings.json` configuration → Remove
- "Run in background" → "Run sequentially (Codex has no background agents)"
- Session state auto-update by hook → "Update manually or launcher script appends"

**CRITICAL: The transform is LINE-LOCAL strip/replace, NOT summarization or paraphrase.**
Do not condense protocol prose. Do not merge separate protocol sections. Do not drop
constraint lines to save space. Every protocol step, every numbered instruction, every
YAML key in a must-cover protocol MUST be preserved with only the tool-reference replaced.

### Step C: Strip whole Conductor/automation protocols

Remove the following protocol blocks entirely (per the Expected-Absent-in-Codex allowlist):
- `yolo_execution_protocol`
- `optimize_protocol`
- `evolve_protocol`
- `dream_protocol`
- `publish_protocol`
- `sync_protocol`
- `sync_add_protocol`
- `sync_list_protocol`
- `lsp_provision_protocol`

### Step D: Preserve all NEVER-Delete categories

Verify the output preserves (byte-exact where noted):
- All lines containing: `MUST`, `MANDATORY`, `VIOLATION`, `forbidden`, `BLOCKING`
- `anti_rationalization_registry` (all entries — byte-exact)
- `honest_partial_protocol` reference
- `forbidden_implementations` lists (all items)
- Ralph Loop protocol logic references (Layer 1 + Layer 2)
- Gate 3/4 checklist structure
- Evidence directory structure and slug contract
- Knowledge Assessment protocol
- Completion report protocol
- Handoff reading protocol
- Socratic inquiry protocol
- Adaptive complexity protocol
- Intent router protocol routing logic
- Handoff creation protocol
- Acceptance protocol
- All `path_transitions` / `forbidden` rules

### Step E: Update header + emit

1. Set the header comment:
   ```
   <!-- Codex-edition: Claude Code-only mechanisms stripped per .tad/portable-rules.md -->
   <!-- Source: .claude/skills/alex/SKILL.md | Generated: {YYYY-MM-DD} | TAD vX.Y.Z -->
   ```
2. Write the output to the target path.

### Step F: Post-emit self-check (MANDATORY)

Run these guard checks on the output — reject and re-run if any fail:

```bash
# Guard: no AskUserQuestion calls remain
grep -c AskUserQuestion <output>   # MUST be 0

# Guard: constraint keywords preserved (floor = source count * 0.07, minimum 10)
grep -coE 'MUST|MANDATORY|VIOLATION' <output>   # MUST be ≥10

# Guard: size within targets
wc -c < <output>   # MUST be ≤102400 AND ≥25600 (sub-25KB = truncation tell)

# Drift closure: new features present
grep -c 'deliverable' <output>   # MUST be ≥5
grep -c 'research_complexity' <output>   # MUST be ≥1
grep -ci 'step4_5\|Pack Awareness' <output>   # MUST be ≥1
```

If the output is under ~25KB, it was truncated/summarized — reject and re-run with
explicit instruction to preserve all protocol prose verbatim.

## Headless Invocation (for P3 release gate)

```bash
claude -p "$(cat .tad/evidence/spikes/codex-parity/regen-procedure.md)" \
  < .claude/skills/alex/SKILL.md \
  > .tad/codex/codex-alex-skill.md
```

Or via Codex:
```bash
cat .tad/evidence/spikes/codex-parity/regen-procedure.md | \
  codex exec --full-auto "Follow this procedure to regenerate the Codex edition"
```

## Time Budget

- Authoring this procedure: one-time (~30 min)
- Executing the regen: ≤5 min (target for recurring per-release)
- Human touch at release: near-zero (run procedure + verify guards)
