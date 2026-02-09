# TAD Test Brief Command

Generate or update a pair testing brief (TEST_BRIEF.md) for E2E pair testing with Claude Desktop.

## When to Use

- Manual invocation outside the Gate flow for ad-hoc testing needs
- Regenerating a test brief after significant changes
- Creating a test brief for a project that didn't go through full TAD flow

## Execution Steps

### Step 1: Session Management

1. Read `.tad/pair-testing/SESSIONS.yaml` (if exists)
   - If not exists → create with empty sessions, total_sessions: 0, start with S01
   - If YAML parse error (corruption detected):
     a. Rename to `SESSIONS.yaml.corrupt.{timestamp}`
     b. Scan `S*/` directories to rebuild manifest
     c. Infer status: has `PAIR_TEST_REPORT.md` → "reviewed", no report → "active"
     d. Write rebuilt `SESSIONS.yaml`
     e. Log: "Recovered SESSIONS.yaml from directory scan"
2. Determine next session ID:
   - Count existing S{NN} directories → next = S{NN+1} (zero-padded: S01, S02, ..., S99, S100+)
3. Check active session guard:
   - If any session has status "active" → Use AskUserQuestion:
     "Session {id} ({scope}) is still active. What would you like to do?"
     Options: "Resume existing session", "Archive it and start new", "Cancel"
4. Check for inheritable context:
   - Find most recent session with status "reviewed" or "archived"
   - If found → ask whether to inherit previous findings
5. Create directory: `.tad/pair-testing/{session_id}/` and `.tad/pair-testing/{session_id}/screenshots/`

### Step 2: Read Template

Read `.tad/templates/test-brief-template.md` as the base.

### Step 3: Gather Project Info

Auto-fill from project context:
1. **Section 1** (Product): Read from `package.json`, `README.md`, `PROJECT_CONTEXT.md`
2. **Section 2** (Scope): Ask user what pages/features to test, or detect from recent changes
3. **Section 3** (Test data): Ask user for test accounts/data info
4. **Section 4** (Known issues): Read from `NEXT.md` Blocked section, or ask user
5. **Section 4b** (Previous Session Context): If inheriting, populate from previous session's report
6. **Section 5** (Design intent): Fill with design decisions, UX expectations, E2E scenarios
7. **Section 8** (Technical): Auto-detect tech stack and fill appropriate tips

### Step 4: Generate

Write completed `TEST_BRIEF.md` to `.tad/pair-testing/{session_id}/TEST_BRIEF.md`.
Update `SESSIONS.yaml`: add new session entry, set as active_session.
Backup `SESSIONS.yaml` to `SESSIONS.yaml.bak` before any write.

### Step 5: Output

```
.tad/pair-testing/{session_id}/TEST_BRIEF.md generated successfully.
Session ID: {session_id} | Inherits from: {prev_session or 'None'}

Sections filled:
  [OK] 1. Product overview
  [OK] 2. Test scope
  [OK] 3. Test accounts/data
  [OK] 4. Known issues
  [OK] 4b. Previous session context (if inheriting)
  [OK] 5. Focus areas & UX expectations
  [OK] 6. Collaboration guide (Round-by-Round protocol)
  [OK] 7. Output requirements
  [OK] 8. Technical notes

Next: Drag .tad/pair-testing/{session_id}/TEST_BRIEF.md into Claude Desktop Cowork to start pair E2E testing.
```
