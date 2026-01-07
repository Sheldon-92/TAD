# Git Workflow Skill

---
title: "Git Workflow"
version: "3.0"
last_updated: "2026-01-06"
tags: [git, version-control, collaboration, signed-commits, protected-branches, engineering]
domains: [all]
level: beginner
estimated_time: "25min"
prerequisites: []
sources:
  - "Pro Git - Scott Chacon"
  - "Conventional Commits"
  - "GitHub Flow"
  - "Gitleaks - Secret Detection"
enforcement: recommended
tad_gates: [Gate4_Review]
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
[ ] Changes are related and atomic (micro-commit)
[ ] Tests pass locally
[ ] No debug code or console.logs
[ ] Commit message follows convention
[ ] No secrets in code (gitleaks check)
[ ] Commit is signed (if required)
```

### Before Creating PR

```
[ ] Branch is up to date with target
[ ] All commits are meaningful
[ ] Tests pass
[ ] Description explains changes
[ ] All commits signed and verified
[ ] Secret scan passed
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
[ ] No secrets in code
[ ] Commits are signed
```

### Branch Protection

```
[ ] Main branch protected
[ ] Required reviews configured (≥2)
[ ] Required status checks enabled
[ ] Signed commits required
[ ] Force push disabled
[ ] CODEOWNERS file exists
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

## Protected Branches

### GitHub Branch Protection Rules

```yaml
# Branch protection configuration (GitHub Actions)
# Settings > Branches > Branch protection rules

main:
  require_pull_request:
    required_approving_reviews: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
    require_last_push_approval: true
  require_status_checks:
    strict: true  # Require branches to be up to date
    contexts:
      - "ci/test"
      - "ci/lint"
      - "ci/security-scan"
  require_conversation_resolution: true
  require_signed_commits: true  # GPG signing required
  enforce_admins: true          # Rules apply to admins too
  restrict_pushes:
    allow_force_pushes: false
    allow_deletions: false
```

### GitHub CLI Protection Setup

```bash
# Enable branch protection via CLI
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/test","ci/lint"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":2}' \
  --field restrictions=null

# Require signed commits
gh api repos/{owner}/{repo}/branches/main/protection/required_signatures \
  --method POST
```

### CODEOWNERS File

```
# .github/CODEOWNERS
# Default owners for everything
*       @team-leads

# Frontend ownership
/src/components/    @frontend-team
/src/pages/         @frontend-team

# Backend ownership
/src/api/           @backend-team
/src/services/      @backend-team

# Infrastructure
/terraform/         @devops-team
/.github/workflows/ @devops-team

# Security-sensitive files require security team
/src/auth/          @security-team @backend-team
/.env.example       @security-team
```

---

## Signed Commits

### Why Sign Commits?

```
Benefits:
□ Verify commit author identity
□ Required for protected branches
□ Proves commit hasn't been tampered with
□ Required for compliance (SOC2, HIPAA)
```

### GPG Key Setup

```bash
# 1. Generate GPG key
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits, key does not expire

# 2. List keys
gpg --list-secret-keys --keyid-format=long
# Output: sec   rsa4096/3AA5C34371567BD2 2026-01-06 [SC]

# 3. Export public key
gpg --armor --export 3AA5C34371567BD2

# 4. Add to GitHub: Settings > SSH and GPG keys > New GPG key

# 5. Configure Git
git config --global user.signingkey 3AA5C34371567BD2
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# 6. Tell GPG to use TTY (for passphrase prompt)
export GPG_TTY=$(tty)
# Add to ~/.bashrc or ~/.zshrc
```

### SSH Key Signing (Alternative)

```bash
# Git 2.34+ supports SSH key signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

# Add to GitHub: Settings > SSH and GPG keys > New SSH key (Signing Key)
```

### Verify Signed Commits

```bash
# Verify commit signature
git log --show-signature -1

# Verify in GitHub UI
# Commits show "Verified" badge

# Require verification in CI
- name: Verify commit signature
  run: |
    COMMIT_STATUS=$(gh api repos/${{ github.repository }}/commits/${{ github.sha }} --jq '.commit.verification.verified')
    if [ "$COMMIT_STATUS" != "true" ]; then
      echo "Commit is not signed or signature is invalid"
      exit 1
    fi
```

---

## Secret Detection and Pre-push Hooks

### Gitleaks Setup

```yaml
# .gitleaks.toml
title = "Gitleaks config"

[allowlist]
description = "Allowlist for false positives"
paths = [
  '''\.test\.ts$''',
  '''\.spec\.ts$''',
  '''__mocks__''',
]

[[rules]]
id = "aws-access-key"
description = "AWS Access Key"
regex = '''AKIA[0-9A-Z]{16}'''
tags = ["key", "aws"]

[[rules]]
id = "generic-api-key"
description = "Generic API Key"
regex = '''(?i)(api[_-]?key|apikey|secret[_-]?key)['"]?\s*[:=]\s*['"]?([a-zA-Z0-9_-]{20,})'''
tags = ["key", "api"]

[[rules]]
id = "private-key"
description = "Private Key"
regex = '''-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----'''
tags = ["key", "private"]
```

### Pre-push Hook

```bash
#!/bin/sh
# .git/hooks/pre-push

echo "Running pre-push checks..."

# 1. Secret detection
if command -v gitleaks &> /dev/null; then
  echo "Checking for secrets..."
  gitleaks protect --staged --verbose
  if [ $? -ne 0 ]; then
    echo "❌ Secrets detected! Push blocked."
    exit 1
  fi
  echo "✅ No secrets found"
fi

# 2. Run full test suite
echo "Running tests..."
npm test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed! Push blocked."
  exit 1
fi
echo "✅ Tests passed"

# 3. Check for unsigned commits (if signing required)
echo "Checking commit signatures..."
for commit in $(git rev-list @{push}..HEAD); do
  if ! git verify-commit $commit 2>/dev/null; then
    echo "❌ Unsigned commit detected: $commit"
    echo "Sign your commits with: git commit -S"
    exit 1
  fi
done
echo "✅ All commits signed"

echo "✅ Pre-push checks passed"
exit 0
```

### GitHub Actions Secret Scanning

```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Gitleaks Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITLEAKS_LICENSE: ${{ secrets.GITLEAKS_LICENSE }}

  trufflehog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: TruffleHog Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.pull_request.base.sha }}
          head: ${{ github.sha }}
```

---

## Micro-Commits Strategy

### What are Micro-Commits?

```
Micro-commits are small, focused commits that:
□ Change ONE thing at a time
□ Are easy to review
□ Are easy to revert
□ Tell a clear story in history
□ Enable bisect for debugging
```

### Micro-Commit Pattern

```bash
# Example: Adding a new feature

# Commit 1: Add interface/types
git add src/types/user.ts
git commit -m "feat(types): add User interface for authentication"

# Commit 2: Add stub implementation
git add src/services/auth.ts
git commit -m "feat(auth): add AuthService stub with login method"

# Commit 3: Add tests (TDD RED)
git add src/__tests__/auth.test.ts
git commit -m "test(auth): add failing tests for login flow"

# Commit 4: Implement (TDD GREEN)
git add src/services/auth.ts
git commit -m "feat(auth): implement login method"

# Commit 5: Refactor
git add src/services/auth.ts
git commit -m "refactor(auth): extract token generation to helper"

# Commit 6: Add documentation
git add docs/auth.md
git commit -m "docs(auth): add authentication API documentation"
```

### Interactive Rebase for Clean History

```bash
# Clean up commits before PR
git rebase -i HEAD~5

# In editor:
pick abc123 feat(types): add User interface
squash def456 fix: typo in User interface  # Squash into previous
pick ghi789 feat(auth): add AuthService stub
fixup jkl012 fix: missing import  # Fixup into previous (no message)
pick mno345 test(auth): add failing tests

# Result: Clean, meaningful commits
```

### Commit Atomicity Guidelines

```
Each commit should:
✅ Compile/build successfully
✅ Pass all tests
✅ Be a complete, logical unit
✅ Not depend on later commits

Each commit should NOT:
❌ Break the build
❌ Leave tests failing
❌ Include "WIP" or incomplete work
❌ Mix unrelated changes
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
