# Socratic Fallback Guide (Codex Edition)

Replaces `AskUserQuestion` structured prompts with numbered-choice text format.

---

## Overview

On Claude Code, Alex uses the `AskUserQuestion` tool to present structured options in a formatted dialog.
On Codex, Alex presents options as numbered text and asks the user to type a number.

---

## Option Presentation Format

Instead of a tool dialog, write:
```
I have 3 options to consider:

1. [Option A name]: [brief description]
2. [Option B name]: [brief description]
3. [Option C name]: [brief description]

Which do you prefer? Type a number (1-3), or describe your preference in free text.
```

For yes/no decisions:
```
Quick check: Should we [decision]?
1. Yes — [consequence]
2. No — [alternative]

Type 1 or 2.
```

---

## Socratic Inquiry Flow

Alex's Socratic Inquiry requires 2-3 rounds of structured questioning before designing.
On Codex, use multi-turn sessions via `codex exec resume --last`.

### Round 1: Problem Discovery

**Start session**:
```bash
cat .tad/codex/codex-alex-skill.md | codex exec --full-auto \
  "You are Alex (Solution Lead). User request: [paste user request here]. 
   Start Socratic Inquiry Round 1."
```

Alex will ask ~3-5 clarifying questions in numbered format. User types answers.

### Round 2: Constraint Exploration

```bash
codex exec resume --last "My answers: 
1. [answer to Q1]
2. [answer to Q2]
3. [answer to Q3]
Continue to Round 2."
```

### Round 3: Design Confirmation

```bash
codex exec resume --last "Continue to Round 3 and propose a design."
```

---

## Full Example: Feature Request Socratic Dialog

**User request**: "Add a dark mode toggle to the app"

**Round 1** (Alex asks):
```
To design the dark mode toggle, I need to clarify:

1. Is this a global setting (persisted across sessions) or per-page?
2. Should it respect the OS system preference (prefers-color-scheme)?
3. What's the tech stack — CSS variables, Tailwind, or styled-components?
4. Is there an existing theme system I should integrate with?

Please answer 1-4.
```

**User types**: 
```
1. Global, persisted in localStorage
2. Yes, respect OS preference as default
3. Tailwind with CSS variables
4. No existing theme system
```

**Round 2** (Alex clarifies):
```
Follow-up questions:

1. For persistence: localStorage only, or also synced to user account if logged in?
2. Toggle placement: header nav, floating button, or settings page?
3. Are there any brand colors that must stay consistent across both modes?

Type answers or say "no more questions, design now".
```

---

## Socratic Inquiry Completion

After 2-3 rounds, Alex should have enough context to proceed with design.

```bash
codex exec resume --last "I have enough context. Please proceed to create the handoff."
```

Alex will then create `HANDOFF-{date}-{slug}.md` in `.tad/active/handoffs/`.

---

## Tips for Codex Socratic Dialog

1. **Keep answers concise** — Codex context window is limited (~100K tokens per session)
2. **Paste relevant context explicitly** — Codex cannot browse files unless asked
3. **Use `resume --last` for continuity** — same session preserves all prior context
4. **End rounds explicitly** — say "continue to Round 2" or "proceed to design"
5. **One session per Socratic dialog** — don't start fresh sessions mid-inquiry
