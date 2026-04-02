# Git Workflow Review Format

> Extracted from git-workflow skill - use this for Git/PR reviews

## Quick Checklist

```
1. [ ] Branch from latest main/develop
2. [ ] Descriptive branch name: type/ticket-description
3. [ ] Commit messages follow Conventional Commits
4. [ ] Commits are small and focused (atomic)
5. [ ] PR has clear description
```

## Red Flags

- Committing directly to main
- Vague commit messages ("fix stuff", "WIP", "update")
- Large commits with many unrelated changes
- Force pushing to shared branches
- Long-lived feature branches (>1 week)
- Unsigned commits on protected branches

## Branch Naming

```
Format: <type>/<ticket-id>-<short-description>

Examples:
feature/PROJ-123-user-authentication
bugfix/PROJ-456-fix-login-error
hotfix/PROJ-789-critical-security-patch
refactor/PROJ-012-improve-performance
```

## Commit Message Format (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

| Type | When to Use |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting (no code change) |
| refactor | Code restructure |
| perf | Performance improvement |
| test | Adding tests |
| chore | Build/config changes |

## Output Format

### Pre-Commit Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Changes atomic | Pass/Fail | [details] |
| Tests pass locally | Pass/Fail | [details] |
| No debug code | Pass/Fail | [console.log, debugger] |
| Message follows convention | Pass/Fail | [details] |
| No secrets in code | Pass/Fail | [gitleaks result] |
| Commit signed | Pass/Fail | [GPG/SSH] |

### Pre-PR Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Branch up to date | Pass/Fail | [commits behind] |
| All commits meaningful | Pass/Fail | [squash needed?] |
| Tests pass | Pass/Fail | [CI status] |
| Description explains changes | Pass/Fail | [summary] |
| All commits signed | Pass/Fail | [verified badge] |
| Secret scan passed | Pass/Fail | [gitleaks/trufflehog] |

### PR Review Checklist

| Category | Check | Status |
|----------|-------|--------|
| Functionality | Code implements requirements | Pass/Fail |
| Functionality | Edge cases handled | Pass/Fail |
| Quality | Naming is clear | Pass/Fail |
| Quality | No duplicate code | Pass/Fail |
| Testing | Sufficient coverage | Pass/Fail |
| Testing | Tests cover edge cases | Pass/Fail |
| Security | No security risks | Pass/Fail |
| Security | Sensitive data handled properly | Pass/Fail |

### Branch Protection Status

| Rule | Configured | Value |
|------|------------|-------|
| Required reviews | Yes/No | [count] |
| Status checks required | Yes/No | [checks] |
| Signed commits required | Yes/No | - |
| Force push disabled | Yes/No | - |
| CODEOWNERS configured | Yes/No | - |

### Recommendations

1. **Must fix**: [blocking issues]
2. **Should fix**: [quality issues]
3. **Consider**: [improvements]
