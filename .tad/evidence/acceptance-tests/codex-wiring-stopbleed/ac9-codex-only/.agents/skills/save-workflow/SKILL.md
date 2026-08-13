---
name: save-workflow
description: "Capture the workflow (ordered steps + concrete commands) just executed in the current conversation into a reusable local skill file at .claude/skills/local/<workflow-name>.md, with auto-detected trigger keywords. Use when the user says 'save the workflow / steps we just did'. NOT for reusable patterns or judgment rules — that is *save-skill (if present)."
trigger: "*save-workflow, or the user asks to save/capture/record the workflow, steps, or procedure just performed so it can be repeated later."
---

# *save-workflow — Capture the Workflow We Just Ran

## Purpose

Workflows (ordered multi-step procedures) evaporate faster than patterns. This
skill captures the workflow just executed in the current conversation — goal,
ordered steps with the exact commands used, gotchas — into a structured, reusable
local file at `.claude/skills/local/<workflow-name>.md`, while step order and
command details are still hot in context.

## Boundary: workflow capture vs pattern capture

| Command | Captures | Shape of output |
|---------|----------|-----------------|
| `*save-workflow` (this skill) | A WORKFLOW: an ordered multi-step procedure with concrete commands, preconditions, and outputs | Replayable step list |
| `*save-skill` (NOT yet implemented; route there only if present) | A PATTERN: a reusable judgment rule or heuristic, not step-ordered | Rule + rationale |

If the user wants to save a rule/insight rather than a procedure, say so and
point at `*save-skill` (if present) instead of forcing it into workflow shape.

## When to use — and when to refuse

- Use at the end of (or right after) a conversation segment where a multi-step
  procedure was actually performed: commands run, files produced, a repeatable
  sequence completed.
- **MUST refuse honestly**: if the conversation contains no discernible executed
  workflow (pure discussion, brainstorming, a single trivial command), say so
  explicitly and stop. Do NOT fabricate steps that were never performed.

## The 5-Step Capture Flow

### Step 1 — Extract

Reconstruct from the recent conversation context the workflow that was ACTUALLY
performed (not an idealized version):

1. **Goal** — what the workflow accomplishes, in one sentence.
2. **Ordered steps** — each step with the concrete command/tool invocation used
   (real flags, real sub-commands), in the order they must run.
3. **Inputs / preconditions** — what must exist or be true before step 1.
4. **Outputs** — what the workflow produces when it succeeds.
5. **Gotchas** — every failure, retry, surprise, or workaround hit during the
   actual run. These are the highest-value content; do not drop them.

### Step 2 — Auto-detect trigger keywords

Derive **3-6 trigger keywords/phrases** from the workflow's goal and step
vocabulary — the words a user would naturally say when they want this workflow
again (e.g. "publish the podcast", "cut episode audio", "release sync").
Embed these trigger keywords in the generated file's `description` field using
the template's `Triggers:` clause. Prefer phrases the user actually used in
this conversation over invented synonyms.

### Step 3 — Draft (render the template)

Render the captured workflow into EXACTLY this file template (frontmatter keys
and body section headings are fixed; content is per-workflow):

    ---
    name: {workflow-name}
    description: "{one-line what it does}. Triggers: {kw1}, {kw2}, {kw3}[, kw4-6]."
    local: true
    created: {YYYY-MM-DD}
    source: save-workflow
    ---

    # {Workflow Title}

    ## Purpose
    {what this workflow accomplishes and why}

    ## When to use
    {situations/preconditions; when NOT to use}

    ## Steps
    1. {step — concrete command/tool with placeholders}
    2. {step}
    ...

    ## Usage instructions
    {how to invoke/adapt: what to substitute into placeholders, expected outputs}

    ## Gotchas
    - {failure modes, workarounds, ordering traps observed in the real run}

Propose a **kebab-case workflow name** (e.g. `podcast-episode-publish`) derived
from the goal; it becomes both `name:` and the filename `<workflow-name>.md`.

### Step 4 — Confirm (MUST happen before any write)

You **MUST show the user the full draft and the proposed kebab-case filename
for approval BEFORE any write**. Present this as a set of choices, not a
yes/no verification question ("对不对?" invites rubber-stamping). Offer
explicitly:

- **save** — write as shown
- **rename** — change the workflow name / filename
- **edit** — revise specific sections (steps, triggers, gotchas)
- **discard** — save nothing

Naming and keep/reject are human-domain judgments — the human decides. If the
user renames or requests edits, apply them and **re-display the updated draft**
for approval again before writing.

### Step 5 — Write (overwrite-guarded)

Only after explicit approval:

1. If `.claude/skills/local/` does not exist in the current project, create it
   at runtime, and create a `README.md` inside it with this content (3-5
   lines): files here are LOCAL-ONLY captured workflows (`local: true`); they
   are never synced, installed, or published by any framework tooling; they are
   created by `*save-workflow`; delete freely.
2. **Overwrite guard (MUST)**: if `.claude/skills/local/<workflow-name>.md`
   already exists, STOP and ask the user — never silently overwrite. REFUSE to
   overwrite without explicit user confirmation; offer rename as the default
   alternative.
3. Write the approved draft to `.claude/skills/local/<workflow-name>.md`.
4. Tell the user the saved path and how to use it later (see Known behavior
   below).

## Variabilize Rule (MUST)

Episode-specific values — paths, project names, dates, IDs, episode numbers —
**MUST be replaced with `{placeholder}` values** before the draft is shown.
A workflow that can only replay one specific session is a diary, not a skill.

Before/after mini-example:

- Diary (wrong): `ffmpeg -i podcasts/EP04-colin/final/mix.wav -b:a 192k out.mp3`
- Skill (right): `ffmpeg -i {project_output_dir}/mix.wav -b:a 192k {episode_name}.mp3`

Each placeholder should be self-describing (`{project_output_dir}`, not `{x}`).
List what to substitute for each placeholder in the `Usage instructions`
section of the generated file.

## Constraints (MUST)

- Generated files **MUST carry `local: true`** in frontmatter — this is the
  never-synced promise.
- **MUST NOT create or modify any framework file**: alex/blake SKILL.md,
  CLAUDE.md, tad.sh, derive-sync-set.sh, anything under `.tad/`. The ONLY
  writes this skill performs are under `.claude/skills/local/`.
- **MUST NOT write executable scripts or hooks** — output is instruction
  markdown only.
- **MUST NOT call Linear MCP** (or any external API). Linear Agent Skills were
  UX inspiration only.
- **MUST NOT skip Step 4** — no write without a shown draft and explicit
  approval.

## Known behavior and limits

- Files under `.claude/skills/local/` are NOT auto-registered as callable
  skills by the harness (they are not `dir/SKILL.md` form). v1 usage: when the
  user later mentions the workflow name or one of its trigger keywords, Read
  the file from `.claude/skills/local/` and follow its steps.
- Promotion (local workflow → framework skill / capability pack) is out of
  scope for this skill.

## Edge cases

| Situation | Required behavior |
|-----------|-------------------|
| Target file already exists | Stop; ask (overwrite guard, Step 5.2) — never silently overwrite |
| No discernible workflow in conversation | Refuse explicitly with a one-line reason; do not fabricate |
| User renames / requests edits at Confirm | Apply, re-display updated draft, get approval again, then write |
| `.claude/skills/local/` missing | Create directory + README first, then write the workflow file |
