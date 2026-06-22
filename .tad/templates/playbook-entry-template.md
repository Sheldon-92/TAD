# Playbook Entry Template

> Fill in each field below. See `playbook-entry-schema.md` for field semantics
> and `knowledge-writing-rules.md` for writing guidance.

---

```
label: {kebab-case-slug — stable identity, used as filename and anchor}

selector: >
  Triggers when: {enumerate trigger conditions, keywords, synonyms, and a catch-all}.
  Near-miss exclusion: does NOT trigger for {conditions that share keywords but should not activate this entry}.

value: >
  {Bounded body — imperative voice, self-contained, no pronouns.
   Preserve invariant literals; variabilize project-specific values as {descriptive-slot}.
   Character budget: {declare limit or note "to be set in P2".}

failure_mode: >
  {REQUIRED — the naive default this entry corrects.
   "Without this knowledge, an agent would do X because Y, which fails because Z."}

validator: >
  {How to verify correct application — executable check (grep, script, assertion)
   for objective criteria, or human-judgment criterion for subjective ones.}

read_only: {false (default) | true (SAFETY/load-bearing — maintenance must not touch)}
```
