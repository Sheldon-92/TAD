# TAD Test Brief Command

Generate or update a pair testing brief (TEST_BRIEF.md) for E2E pair testing with Claude Desktop.

## When to Use

- Manual invocation outside the Gate flow for ad-hoc testing needs
- Regenerating a test brief after significant changes
- Creating a test brief for a project that didn't go through full TAD flow

## Execution Steps

### Step 1: Check Existing Brief

Check if `TEST_BRIEF.md` exists in project root.

- **If exists**: Use AskUserQuestion to ask:
  - "TEST_BRIEF.md already exists. What would you like to do?"
  - Options: "Regenerate from scratch", "Supplement missing sections", "View current brief"
- **If not exists**: Proceed to Step 2

### Step 2: Read Template

Read `.tad/templates/test-brief-template.md` as the base.

### Step 3: Gather Project Info

Auto-fill from project context:
1. **Section 1** (Product): Read from `package.json`, `README.md`, `PROJECT_CONTEXT.md`
2. **Section 2** (Scope): Ask user what pages/features to test, or detect from recent changes
3. **Section 3** (Test data): Ask user for test accounts/data info
4. **Section 4** (Known issues): Read from `NEXT.md` Blocked section, or ask user
5. **Section 5** (Design intent): Fill with design decisions, UX expectations, E2E scenarios
6. **Section 8** (Technical): Auto-detect tech stack and fill appropriate tips

### Step 4: Generate

Write completed `TEST_BRIEF.md` to project root.

### Step 5: Output

```
TEST_BRIEF.md generated successfully.

Sections filled:
  [OK] 1. Product overview
  [OK] 2. Test scope
  [OK] 3. Test accounts/data
  [OK] 4. Known issues
  [OK] 5. Design intent & UX expectations
  [OK] 6. Collaboration guide (template default)
  [OK] 7. Output requirements (template default)
  [OK] 8. Technical notes

Next: Drag TEST_BRIEF.md into Claude Desktop to start pair E2E testing.
```
