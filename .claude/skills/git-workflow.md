# Git Workflow Skill

---
title: "Git Workflow"
version: "2.0"
last_updated: "2026-01-06"
tags: [git, version-control, collaboration, engineering]
domains: [all]
level: beginner
estimated_time: "20min"
prerequisites: []
sources:
  - "Pro Git - Scott Chacon"
  - "Conventional Commits"
  - "GitHub Flow"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Branch from latest main/develop
2. [ ] Use descriptive branch name: type/ticket-description
3. [ ] Commit messages follow Conventional Commits
4. [ ] Keep commits small and focused
5. [ ] Create PR with clear description
```

**Red Flags:**
- Committing directly to main
- Vague commit messages ("fix stuff", "WIP")
- Large commits with many unrelated changes
- Force pushing to shared branches
- Long-lived feature branches

---

## Overview

This skill guides Git usage for effective version control and team collaboration.

**Core Principle:** "Commits should be meaningful units of change, branches should be independent units of work."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Starting new work | Blake implementing | Create feature branch |
| Completing changes | Ready to share | Create PR |
| Merge conflicts | Updating branch | Resolve properly |
| Code review | PR submitted | Respond to feedback |

---

## Inputs

- Feature/task requirements
- Team branching strategy
- Commit message convention
- Repository access

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `branch_name` | Properly named branch | Git history |
| `commit_messages` | Conventional commit format | Git log |
| `pr_description` | Clear PR summary | GitHub/GitLab |

### Acceptance Criteria

```
[ ] Branch naming follows convention
[ ] Commits are atomic and well-described
[ ] PR description explains changes
[ ] No merge conflicts
[ ] CI checks pass
```

---

## Procedure

### Step 1: Choose Branching Strategy

#### Git Flow

```
main (production)
├── develop (development trunk)
│   ├── feature/user-auth
│   ├── feature/payment
│   └── feature/...
├── release/v1.2.0
└── hotfix/critical-bug
```

**Branch Types:**
- `main` - Production code
- `develop` - Development trunk
- `feature/*` - New features
- `release/*` - Release preparation
- `hotfix/*` - Emergency fixes

#### GitHub Flow (Simpler)

```
main (production)
├── feature/user-auth
├── bugfix/login-error
└── ...
```

**Simpler:**
- Only `main` is long-lived
- All work in feature branches
- Merge via PR

### Step 2: Name Branches Properly

**Format:**
```
<type>/<ticket-id>-<short-description>

Examples:
feature/PROJ-123-user-authentication
bugfix/PROJ-456-fix-login-error
hotfix/PROJ-789-critical-security-patch
refactor/PROJ-012-improve-performance
```

**Types:**

| Type | Purpose |
|------|---------|
| feature | New functionality |
| bugfix | Bug fixes |
| hotfix | Emergency fixes |
| refactor | Code improvements |
| docs | Documentation |
| test | Tests |
| chore | Build/config |

### Step 3: Write Commit Messages

**Conventional Commits Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Example:**
```
feat(auth): add OAuth2 login support

- Add Google OAuth2 provider
- Add GitHub OAuth2 provider
- Store tokens securely in database

Closes #123
```

**Types:**

| Type | Meaning | Example |
|------|---------|---------|
| feat | New feature | Add login |
| fix | Bug fix | Fix password reset |
| docs | Documentation | Update README |
| style | Formatting | Fix indentation |
| refactor | Refactoring | Extract function |
| perf | Performance | Optimize query |
| test | Tests | Add unit tests |
| chore | Build/config | Update deps |

**Good vs Bad Messages:**
```
✅ Correct:
feat: add user registration endpoint
fix: resolve race condition in payment processing
docs: update API documentation for v2

❌ Wrong:
Fixed stuff
WIP
Update code
asdfasdf
```

### Step 4: Common Git Operations

#### Create Feature Branch

```bash
# From develop, create feature branch
git checkout develop
git pull origin develop
git checkout -b feature/PROJ-123-new-feature

# After development, push
git push -u origin feature/PROJ-123-new-feature
```

#### Keep Branch Updated

```bash
# Rebase to keep linear history
git checkout feature/my-feature
git fetch origin
git rebase origin/develop

# If conflicts occur
git rebase --continue  # After resolving
git rebase --abort     # To cancel
```

#### Merge Branch

```bash
# Squash merge (recommended - clean history)
git checkout develop
git merge --squash feature/my-feature
git commit -m "feat: add new feature (#123)"

# Or regular merge
git merge feature/my-feature
```

#### Handle Conflicts

```bash
# 1. Fetch latest
git fetch origin

# 2. Rebase onto target
git rebase origin/develop

# 3. Resolve conflicts
# Edit conflict files
git add <resolved-files>
git rebase --continue

# 4. Force push (only your own branch!)
git push --force-with-lease
```

### Step 5: Undo Operations

#### Undo Working Directory Changes

```bash
# Single file
git checkout -- <file>

# All changes
git checkout -- .

# Git 2.23+
git restore <file>
```

#### Undo Staging

```bash
git reset HEAD <file>
# or
git restore --staged <file>
```

#### Undo Commits

```bash
# Undo last commit, keep changes
git reset --soft HEAD~1

# Undo last commit, discard changes
git reset --hard HEAD~1

# Create reverse commit (if already pushed)
git revert HEAD
```

#### Amend Last Commit

```bash
# Change message
git commit --amend -m "new message"

# Add forgotten file
git add forgotten-file
git commit --amend --no-edit
```

### Step 6: Stash Operations

```bash
# Stash current changes
git stash

# Stash with name
git stash push -m "WIP: feature X"

# List stashes
git stash list

# Apply latest stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Delete stash
git stash drop stash@{0}
```

### Step 7: Create Pull Request

```bash
# Using GitHub CLI
gh pr create --title "feat: add user auth" \
  --body "## Summary
- Add login/logout functionality
- Add password reset

## Testing
- [ ] Unit tests pass
- [ ] Manual testing done"
```

---

## Checklists

### Before Committing

```
[ ] Changes are related and atomic
[ ] Tests pass locally
[ ] No debug code or console.logs
[ ] Commit message follows convention
```

### Before Creating PR

```
[ ] Branch is up to date with target
[ ] All commits are meaningful
[ ] Tests pass
[ ] Description explains changes
```

### PR Review

```
Functionality:
[ ] Code implements requirements
[ ] Edge cases handled

Quality:
[ ] Naming is clear
[ ] No duplicate code
[ ] Acceptable complexity

Testing:
[ ] Sufficient test coverage
[ ] Tests cover edge cases

Security:
[ ] No security risks
[ ] Sensitive data handled properly
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Commit to main directly | No review, risky | Use feature branches + PR |
| Vague commit messages | Hard to understand history | Follow Conventional Commits |
| Huge commits | Hard to review/revert | Small, focused commits |
| Long-lived branches | Merge conflicts | Keep branches short-lived |
| Force push shared branch | Breaks others' work | Only force push own branches |

---

## Git Hooks

### Pre-commit

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run lint
npm run lint || exit 1

# Run tests
npm test || exit 1

# Check for debug code
if git diff --cached | grep -E "console\.log|debugger"; then
  echo "Error: Debug code found"
  exit 1
fi
```

### Commit-msg

```bash
#!/bin/sh
# .git/hooks/commit-msg

# Validate conventional commit format
commit_regex='^(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .{1,72}'

if ! grep -qE "$commit_regex" "$1"; then
  echo "Error: Invalid commit message format"
  echo "Expected: type(scope): subject"
  exit 1
fi
```

---

## Tools / Commands

### Useful Aliases

```bash
# ~/.gitconfig
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  lg = log --oneline --graph --decorate
  unstage = reset HEAD --
  last = log -1 HEAD
  amend = commit --amend --no-edit
```

### GitHub CLI

```bash
# Create PR
gh pr create

# List PRs
gh pr list

# Check out PR locally
gh pr checkout 123

# View PR
gh pr view 123
```

---

## TAD Integration

### Gate Mapping

```yaml
Git_Workflow:
  skill: git-workflow.md
  enforcement: RECOMMENDED
  triggers:
    - Starting development
    - Completing work
    - Code review
  evidence_required:
    - branch_name (convention followed)
    - commit_messages (conventional commits)
    - pr_description (clear)
  acceptance:
    - Branch naming correct
    - Commits meaningful
    - PR ready for review
```

### Evidence Template

```markdown
## Git Workflow Evidence

### Branch
`feature/PROJ-123-user-authentication`

### Commits
\`\`\`
feat(auth): add login endpoint
feat(auth): add logout endpoint
test(auth): add authentication tests
docs(auth): update API documentation
\`\`\`

### PR
Title: feat(auth): implement user authentication (#123)
URL: https://github.com/org/repo/pull/123
```

---

## Best Practices

### Do

```
□ Commit frequently, each commit one logical unit
□ Write clear commit messages
□ Keep branches short-lived
□ Update to latest before merging
□ Use PRs for code review
```

### Don't

```
□ Large, mixed-purpose commits
□ Meaningless commit messages
□ Long-lived feature branches
□ Push directly to main
□ Force push to shared branches
```

---

## Related Skills

- `code-review.md` - PR review process
- `testing-strategy.md` - Tests before commit
- `verification.md` - Verify before commit
- `parallel-agents.md` - Git worktrees for parallel work

---

## References

- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials)

---

*This skill guides Claude in effective Git usage for version control and collaboration.*
