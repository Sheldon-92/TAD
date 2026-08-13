---
name: save-skill
description: "Capture a reusable pattern from the current conversation into a local skill file under .claude/skills/local/ — LLM-draft + user-confirm, local-only, never synced. Use when the user says *save-skill, 'save this as a skill', '把这个存成 skill', or wants to keep a just-validated pattern."
trigger: "*save-skill [optional name/topic hint]"
---

# *save-skill — Local Skill Capture

## Purpose

Bottom-up, in-the-moment capture: when a conversation just validated a small reusable
pattern, `*save-skill` turns it into a persistent, discoverable local skill file under
`.claude/skills/local/` — zero ceremony, no framework release. This COMPLEMENTS the Gate 4
Knowledge Assessment / distill loop (framework-level knowledge); it does not replace it.
Local skills are project-local tactical patterns, isolated from the TAD distribution chain.

## Flow

Execute these steps in order. Steps 3 and 4 are BLOCKING — never skip them.

### Step 1 — Scan

Identify the ONE reusable pattern in the current conversation:

- What problem does it solve?
- What is the solution?
- When to apply it?
- When NOT to apply it?

If the user gave a hint (`*save-skill <hint>`), scope the scan to that hint.
If nothing capturable exists in the conversation, say so and STOP — do not invent a pattern.

### Step 2 — Draft

Fill the Local Skill Template (below). Naming rules:

- Name MUST be kebab-case matching `[a-z0-9-]+`.
- Derive the name from the pattern's TRIGGER (what future situation should recall it),
  not from the session topic.
- Target file: `.claude/skills/local/<name>.md`.
- `description` is one line containing the trigger keywords a future keyword-match will hit.

### Step 3 — Confirm [BLOCKING]

Show the FULL draft as a fenced markdown block.

🔒 MUST NOT write any file before the user confirms the draft

Offer the user (via AskUserQuestion or equivalent):

1. **Confirm write** — proceed to Step 4
2. **Edit draft** — user renames / trims / rewrites any part (taste and direction are
   human-domain judgments); apply the edits and loop back to showing the full draft
3. **Abort** — stop with zero file writes

Loop on edits until the user confirms or aborts.

### Step 4 — 🔒 OVERWRITE GUARD [BLOCKING]

If `.claude/skills/local/<name>.md` already exists, ask the user:

- **Overwrite** the existing file
- **Rename** the new skill (back to Step 3 with the new name)
- **Abort**

Never silently clobber an existing local skill.

### Step 5 — Write

1. `mkdir -p .claude/skills/local` (idempotent, on-demand — the directory is created at
   first write, never committed ahead of time).
2. Write `.claude/skills/local/<name>.md` per the confirmed draft.
3. If `.claude/skills/local/_index.md` does not exist, create it with this header:

   ```markdown
   # Local Skills Index

   > One line per local skill. Load path: read this index → match keywords → Read the file.
   > Format: `- [Title](<name>.md) — hook (max 120 chars)`

   ---
   ```

4. Append (or update in place, if the skill already has a line) the skill's index line:
   `- [Title](<name>.md) — hook (max 120 chars)`

File body and index line are written in the same Step 5 pass (file first, then index).
If an index line is ever found missing, re-running Step 5 repairs it idempotently.

### Step 6 — Report

Tell the user:

- The file path written (`.claude/skills/local/<name>.md`)
- The index line added to `_index.md`
- Reminder: the file is local-only — never synced, published, or distributed by TAD.

## Local Skill Template

```markdown
---
name: <kebab-case-name>
description: "<one line: what + trigger keywords>"
local: true
created: YYYY-MM-DD
source: save-skill
---

# <Title>

## When to use

## When NOT to use

## Steps

## Example

## Gotchas
```

## Using local skills

Load path for any agent in this project:

1. Read `.claude/skills/local/_index.md`
2. Keyword-match the task against the one-line hooks
3. Read the matched `.claude/skills/local/<name>.md` file(s)

## Constraints

- 🔒 MUST NOT write any file before the user confirms the draft
- 🔒 MUST only write under .claude/skills/local/ (plus `_index.md` in the same dir)
- 🔒 MUST NOT be auto-invoked — user-explicit command only (respects the blake skillify
  forbidden_implementations boundary: unattended skill materialization is forbidden; this
  flow only ever runs because the user explicitly asked for it)
- 🔒 local skills are never synced, published, or overwritten by TAD install
- Names MUST be kebab-case `[a-z0-9-]+`; every file MUST carry `local: true` frontmatter
- TAD-repo note: in the TAD framework repo itself `.claude/skills/local/` is gitignored
  (framework-repo-saved local skills never enter git → never enter the distribution clone →
  never get copied by tad.sh). In downstream projects, committing local skills is the
  project's own choice — tad.sh does not copy `.gitignore` and never touches
  `.claude/skills/local/` on install or update.
