# Alex Expert Review Guide (Codex Edition)

Replaces parallel sub-agent expert review with sequential `codex exec` sessions.
For Blake's Layer 2 guide, see `.tad/codex/sequential-review.md`.

---

## When Alex Runs Expert Review

Alex runs expert review at **Gate 2** (pre-handoff review, before passing work to Blake).
The goal: catch spec issues, ambiguous ACs, and architectural flaws before implementation begins.

---

## Preparation

1. Draft the handoff at `.tad/active/handoffs/HANDOFF-{date}-{slug}.md`
2. Get the handoff content ready to paste into review sessions
3. Note the task type and key risks from the handoff

---

## Session 1: Code Reviewer (Gate 2 Pre-Handoff)

```bash
codex exec "You are a senior code reviewer reviewing a DESIGN specification (not code).

Read this handoff draft:
---
[paste full handoff content here]
---

Review for:
1. AC completeness — are all acceptance criteria specific and verifiable?
2. Implementation steps — are §6 steps actionable (no ambiguous steps)?
3. File scope — are all files to be modified listed in §7?
4. AC verification commands — run each command mentally, will it actually verify what it claims?

Report:
- P0: Must fix before handoff ships (blocking)
- P1: Should fix (important)
- P2: Nice to have (advisory)"
```

Save to: `.tad/evidence/reviews/blake/<slug>/code-reviewer.md` (use slug as if Blake wrote it)

Wait for: P0=0 before shipping handoff. Fix all P0s in the handoff, then re-review if needed.

---

## Session 2: Architecture Reviewer (Gate 2 Pre-Handoff)

```bash
codex exec "You are a backend architect reviewing a DESIGN specification.

Read this handoff draft:
---
[paste full handoff content here]
---

Review for:
1. Architecture soundness — is the chosen approach the right one?
2. Blast radius — will this change affect other files/systems not listed in §7?
3. Downstream consumers — are there consumers of APIs/functions being modified?
4. Constraint conflicts — do any ACs contradict each other?

Report P0/P1/P2 findings with specific §section references."
```

Save to: `.tad/evidence/reviews/blake/<slug>/backend-architect.md`

---

## Integrating Feedback

After both sessions:

1. List all P0 findings
2. For each P0, decide: fix in handoff or defer to future handoff?
3. Update handoff with fixes
4. Add resolved P0s to handoff §9.2 Expert Review Audit Trail

Example audit trail entry:
```
| code-reviewer | CR-P0-1: AC3 verification command uses wrong grep flags | §9 AC3 updated | Resolved |
| backend-architect | BA-P0-1: consumers of deleted API not listed | §7 added 3 files | Resolved |
```

---

## Domain-Specific Expert Prompts

**Security expert** (for auth/secrets/API changes):
```bash
codex exec "You are a security expert reviewing a design spec. Look for:
1. Authentication gaps in the design
2. Secret or credential exposure risks
3. Missing input validation
4. Trust boundary violations

[paste handoff]

Report critical/high/medium findings."
```

**UX expert** (for UI changes):
```bash
codex exec "You are a UX expert reviewing a design spec. Look for:
1. Accessibility requirements missing from ACs
2. Edge cases in user flows not covered
3. Error states not designed
4. Mobile/responsive concerns

[paste handoff]

Report UX gaps as P0/P1/P2."
```

---

## Minimum Review Requirements

- **MUST** run ≥2 distinct expert sessions before shipping a handoff (Gate 2 requirement)
- **MUST** resolve all P0 findings (or explicitly defer with rationale)
- **MUST** add resolved P0s to handoff §9.2 Audit Trail
- Express handoffs may justify single reviewer, but MUST document rationale in handoff

---

## Tips for Codex Expert Review

1. **Paste the full handoff** — reviewers need complete context to find issues
2. **Reviewer sessions are independent** — do NOT use `resume --last` across different reviewers
3. **Save outputs immediately** — don't let context disappear without saving
4. **Run second reviewer AFTER fixing P0s from first** — compound fixes reduce revision cycles
5. **AC verification commands are critical** — ask reviewer to mentally run each one

---

## Expert Prompt Template (narrow-scope version)

For efficiency, provide reviewers with focused context per Layer 2 narrow-scope rule:

**Required reads for reviewer**:
- Git diff of implementation changes (paste or file reference)
- Handoff §6 (Implementation Steps)
- Handoff §9 (Acceptance Criteria)

**Optional reads** (only if required reads insufficient):
- Specific changed files
- Related architecture.md entries

Do NOT send the full handoff for every review — §6 + §9 + diff is usually sufficient.
