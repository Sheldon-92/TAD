# Distillation Loop Protocol

## Precondition
- Blake's completion report indicates a journal path (evidence/journal/{slug}-{date}.md)
- If journal does not exist or Q1=No → skip distillation, KA writes "No journal material to distill"
- If journal exists but content is too short (<3 lines) → skip distillation, leave journal

## Step 1: Read journal
Read evidence/journal/{slug}-{date}.md. Alex at this point has NO Blake session context —
this is the de-cursing mechanism (principles.md "Knowledge Is Forged at Distill, Not Captured").

## Step 2: Variabilize test
Apply the variabilize test (knowledge-writing-rules.md rule 1) to journal content:
- Replace every project-specific value with {slot} → does a coherent skeleton survive?
- Guard (a): source is Gate-passed work? (Yes — already passed Gate 3)
- Guard (b): if the draft still contains source-episode literal values → abstraction failed

If test fails (everything dissolves into slots / nothing can be extracted) → knowledge stays
in journal, do not distill. KA writes "Journal exists but material is one-off (variabilize test: FAIL)". End.

## Step 3: Draft typed entry
Use playbook-entry-template.md to fill the 6 fields:
- label: generate from journal keywords
- selector: enumerate trigger keywords + near-miss exclusion
- value: imperative voice, self-contained, no relative time
- failure_mode: what would a naive agent do wrong (**if unfillable → this field becomes a question**)
- validator: how to verify the entry was followed correctly
- read_only: default false

## Step 4: Gap detection
Self-check each field of the draft:
- "Can I fully fill this field from the journal content alone?"
- Yes → keep
- No (information not in journal / uncertain about specific parameters / unclear why this choice was made) →
  **this field becomes a precise question**

## Step 5: Gap questioning (if any)
If ≥1 field is unfillable:
- Generate gap question list:
  ```
  ## 🔍 Knowledge Distillation — Questions for Blake

  The following fields I cannot fill from the journal alone — Blake's execution context is needed:

  1. [failure_mode] — the journal says "swell shouldn't be too high" but not what the naive default
     would be or why that value is wrong.
     **Question: Blake, if a newcomer doesn't read this entry, what would they default swell to? Why is that wrong?**
  2. [validator] — the journal doesn't mention how to verify this was done correctly.
     **Question: how to verify BGM swell is set correctly — listening check or quantitative metric?**
  ```
- Present to user; user relays to Blake (Terminal 2)
- Blake answers (appends to journal or replies directly)
- Alex fills the answer into the draft
- **Capped at 2 rounds**. After 2 rounds if gaps remain → annotate "[INCOMPLETE — field needs future verification]" and write to disk, do not block

## Step 6: Finalize
- Apply knowledge-writing-rules.md 5 rules as a final check
- Leak detection: if the finished entry still contains source-episode literal values → fix or annotate
- Write to project-knowledge/{category}.md (using playbook-entry-schema.md format)
- KA writes "Playbook entry created: {label} in {category}.md"

## Step 7: Codex upgrade (optional)
Trigger conditions (any):
- Entry will be marked read_only: true (SAFETY)
- Entry is expected to be reused cross-project (synced downstream)
- New L1 principle level

Execution: spawn Codex CLI, give it only this one entry + "attempt to execute a task following
this entry; list every point of uncertainty." Codex's questions = a stricter stranger test
(different model prior).

## Anti-Theater
- If user decides to skip distillation → legitimate (soft, not blocking); KA writes "User skipped distillation"
- If Blake wrote no journal (Q1=No) → legitimate; KA writes "No discoveries"
- The entire loop is advisory/human-gated; no hooks registered (L1 reject-mechanical-enforcement)
