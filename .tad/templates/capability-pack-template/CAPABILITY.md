---
name: {{pack-name}}
description: {{One paragraph describing what this pack does, what tools it uses, and when to activate it. This text appears in the skill list — make it specific enough to trigger on the right keywords.}}
keywords: ["{{keyword1}}", "{{keyword2}}", "{{中文关键词}}", "{{tool-name}}"]
type: {{reference-based | deep-skill | orchestration-router}}
---

<!-- CONSUMES/PRODUCES Interface (for multi-pack chaining) -->
<!-- consumes: {{What this pack needs as input — e.g., "User task description + optional existing codebase"}} -->
<!-- produces: {{What this pack outputs — e.g., "Applied judgment rules + quality checklist results"}} -->

# {{Pack Name}} Capability Pack

## What This Pack Does

{{Pack name}} = domain judgment rules for {{domain}}.
It is NOT a tutorial, checklist, or documentation generator.

**Pack = domain judgment.** TAD/framework = process constraint. No overlap.

**When to use:** {{2-3 specific trigger scenarios}}
**When NOT to use:** {{1-2 explicit exclusions}}

---

## Cross-Cutting Rule: {{Rule Name}}

> **{{One-sentence rule that applies across ALL capabilities in this pack.}}**
>
> {{Why this matters — 1-2 sentences with a specific number or research finding.}}

---

## Step 0: Context Detection

Read the user's task. Match against the signal table below. Load the matching reference file(s).

| Signal in User Task | Reference to Load | What It Covers |
|---------------------|-------------------|----------------|
| {{signal keywords}} | `references/{{file}}.md` | {{brief scope}} |
| {{signal keywords}} | `references/{{file}}.md` | {{brief scope}} |
| "review everything" / "audit" | Load ALL references | Full-scope review |

**If no signal matches:** Ask the user which capability they need.

## Step 1: Apply Rules

1. Read the matched reference file(s) from `references/`
2. For each rule in the Quick Rule Index, evaluate: does it apply to this task?
3. Apply applicable rules — cite the rule ID (e.g., "per {{R1}}") in your output
4. Flag any rule violations as P0 (blocking) or P1 (recommendation)

## Step 2: Output

Structure your response as:

```
## {{Domain}} Review: {{scope}}

### P0 — Blocking
- [{{R-ID}}] {{finding + specific fix}}

### P1 — Recommendations  
- [{{R-ID}}] {{finding + suggested improvement}}

### Applied Rules
{{List of rule IDs that were evaluated, with PASS/FAIL/N-A status}}
```

---

## Anti-Skip Table

| Excuse | Why It's Wrong | Counter |
|--------|---------------|---------|
| "{{common rationalization 1}}" | {{why wrong}} | {{what to do instead}} |
| "{{common rationalization 2}}" | {{why wrong}} | {{what to do instead}} |
| "{{common rationalization 3}}" | {{why wrong}} | {{what to do instead}} |

---

## Tool Quick Reference

| Tool | Install | Key Command | When to Use |
|------|---------|-------------|-------------|
| {{tool1}} | `{{install cmd}}` | `{{key cmd}}` | {{scenario}} |
| {{tool2}} | `{{install cmd}}` | `{{key cmd}}` | {{scenario}} |
