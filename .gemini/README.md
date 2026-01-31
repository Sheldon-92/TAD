# TAD for Gemini CLI

This project uses TAD Framework.

## Quick Start
- `/tad-alex` - Activate Alex (Solution Lead)
- `/tad-blake` - Activate Blake (Execution Master)
- `/tad-gate` - Run quality gate

See GEMINI.md for full rules.

## Command Reference

| TAD Command | Gemini Command |
|-------------|----------------|
| /alex | /tad-alex |
| /blake | /tad-blake |
| /gate | /tad-gate |
| /tad-init | /tad-init |
| /tad-status | /tad-status |
| /tad-help | /tad-help |

## Context Syntax

| Syntax | Purpose | Example |
|--------|---------|---------|
| `@{path}` | Include file content | `@{GEMINI.md}` |
| `@{dir/}` | List directory | `@{.tad/skills/}` |
| `!{cmd}` | Shell output | `!{git status}` |
| `{{args}}` | User arguments | Command input |
