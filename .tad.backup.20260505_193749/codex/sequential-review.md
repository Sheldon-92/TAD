# Sequential Expert Review Guide (Codex Edition)

Replaces parallel sub-agent spawning with sequential `codex exec` sessions.

---

## Overview

On Claude Code, Blake spawns multiple reviewer sub-agents in parallel.
On Codex, each reviewer is a **separate `codex exec` session**, run sequentially.

**Minimum requirement**: ≥2 distinct reviewers (code-reviewer REQUIRED + ≥1 domain expert).

---

## Step-by-Step: Layer 2 Expert Review

### Preparation

1. Note the handoff slug (filename without date + `.md`):
   `HANDOFF-20260501-codex-phase1-build.md` → slug = `codex-phase1-build`

2. Create evidence directory:
   ```bash
   mkdir -p .tad/evidence/reviews/blake/codex-phase1-build/
   ```

3. Get the diff of your implementation:
   ```bash
   git diff HEAD~1 > /tmp/impl-diff.txt
   # or: git diff main..HEAD
   ```

---

### Session 1: Spec Compliance (Group 0 — BLOCKING)

```bash
codex exec "You are a spec-compliance reviewer. Review whether all acceptance criteria in the handoff are satisfied.

Read: .tad/active/handoffs/HANDOFF-<slug>.md (especially §9 Acceptance Criteria)
Read: .tad/evidence/ for relevant evidence files

For each AC, report:
- AC#: SATISFIED / PARTIALLY_SATISFIED / NOT_SATISFIED
- Brief rationale

Overall: PASS if NOT_SATISFIED=0 and PARTIALLY_SATISFIED≤3, else FAIL."
```

Save output to: `.tad/evidence/reviews/blake/<slug>/spec-compliance.md`

**If FAIL**: Fix implementation gaps, then re-run from Layer 1.

---

### Session 2: Code Reviewer (Group 1 — BLOCKING)

```bash
codex exec "You are a senior code reviewer. Review the implementation diff for quality issues.

Read: the diff between before and after implementation
Read: .tad/active/handoffs/HANDOFF-<slug>.md §6 (Implementation Steps) and §9 (Acceptance Criteria)

Report findings as:
- P0: Critical bug or security issue (BLOCKING — must fix before Gate 3)
- P1: Important quality issue (BLOCKING — must fix before Gate 3)
- P2: Minor improvement (advisory, not blocking)

Overall verdict: PASS if P0=0 and P1=0, else FAIL."
```

Save output to: `.tad/evidence/reviews/blake/<slug>/code-reviewer.md`

**If P0/P1 found**: Fix all blocking issues, re-run from Layer 1.

---

### Session 3: Domain Expert (Group 2 — choose by task type)

**Backend/Architecture review** (for backend, API, or system design changes):
```bash
codex exec "You are a backend architect. Review the implementation for:
1. Architectural soundness
2. Cross-file reference integrity (are there stale references after deletions?)
3. API design correctness
4. Data flow and state management

Read: git diff of implementation
Read: .tad/active/handoffs/HANDOFF-<slug>.md §6 and §10

Report P0/P1/P2 findings with specific file:line references."
```

Save to: `.tad/evidence/reviews/blake/<slug>/backend-architect.md`

---

**Security review** (if task touches auth/tokens/passwords/credentials/API keys):
```bash
codex exec "You are a security auditor. Review the implementation for security issues:
1. Authentication and authorization gaps
2. Secrets or credentials exposure
3. Injection vulnerabilities
4. Insecure data handling

Read: git diff of implementation

Report: critical/high/medium/low severity findings."
```

Save to: `.tad/evidence/reviews/blake/<slug>/security-auditor.md`

---

**Performance review** (if task touches database/queries/cache/batch/loops):
```bash
codex exec "You are a performance optimizer. Review for performance issues:
1. N+1 queries
2. Missing indexes
3. Inefficient algorithms
4. Memory leaks or unbounded growth

Read: git diff of implementation

Report: blocking patterns and optimization suggestions."
```

Save to: `.tad/evidence/reviews/blake/<slug>/performance-optimizer.md`

---

**UX review** (if task touches user-facing UI):
```bash
codex exec "You are a UX expert reviewer. Review the UI changes for:
1. Accessibility (WCAG AA compliance)
2. User flow clarity
3. Error handling and feedback
4. Mobile responsiveness

Read: git diff of implementation

Report: UX issues with severity (blocking/advisory)."
```

Save to: `.tad/evidence/reviews/blake/<slug>/ux-expert-reviewer.md`

---

### Run Audit After All Sessions

```bash
bash .tad/hooks/lib/layer2-audit.sh <slug>
# Must exit 0 (≥2 distinct reviewer artifacts found)
```

---

## Method B: Independent Reviewer Sessions

For genuine review independence (different perspective), start each reviewer session as a completely fresh invocation (not resumed from previous session):

```bash
# Session 1 (fresh)
codex exec "You are a code reviewer. [prompt]"

# Session 2 (fresh — do NOT use resume --last from session 1)
codex exec "You are a backend architect. [prompt]"
```

**Why**: `codex exec resume --last` maintains context from the previous session, which can cause the second reviewer to be influenced by the first reviewer's findings. Independent sessions = independent perspectives.

---

## Multi-Turn Review (for complex tasks)

If a review session needs multiple rounds (reviewer requests more context):

```bash
# Start review
codex exec "You are a code reviewer. [initial prompt]"
# reviewer responds, requests to see file X

# Continue in same session
codex exec resume --last "Here is the content of file X: [paste content]"

# Continue until reviewer gives final verdict
codex exec resume --last "Given all context, please give your final P0/P1/P2 verdict."
```

Save the final verdict message to the evidence file.
