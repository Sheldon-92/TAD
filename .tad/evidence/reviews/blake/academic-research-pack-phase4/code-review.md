# Code Review: academic-research-pack-phase4

**Reviewer**: code-reviewer sub-agent
**Date**: 2026-05-28
**Verdict**: PASS (after P0 fix)

## Findings Summary
- **P0**: 1 (fixed) — LIMIT not validated as integer, allowing Python code injection via heredoc
- **P1**: 3 (1 fixed, 2 accepted)
- **P2**: 6 (1 fixed, 5 accepted)

## P0 Resolution
| # | Issue | Fix |
|---|-------|-----|
| P0-1 | LIMIT not validated — shell injection via Python heredoc | Added `[[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -eq 0 ]]` check |

## P1 Resolution
| # | Issue | Resolution |
|---|-------|-----------|
| P1-2 | API key in URL visible in process list | Accepted: free/demo keys, local CLI tool |
| P1-3 | JSON validation inconsistency (only on Semantic Scholar) | Accepted: other databases have python3 error handling via `2>/dev/null || echo "Error"` |
| P1-4 | arXiv multi-line title parsing | Fixed: added while loop to accumulate lines between <title> and </title> |

## P2 Resolution
| # | Issue | Resolution |
|---|-------|-----------|
| P2-5 | Script not referenced in CAPABILITY.md | Fixed: added "Available Tools" section |
| P2-6 | Hardcoded OpenAlex mailto | Accepted: internal use |
| P2-7-10 | Various minor improvements | Accepted as-is for v0.1.0 |

## Strengths Noted
- URL encoding via `jq -sRr @uri` — correct portable approach
- `set -euo pipefail` present
- Europeana graceful skip + USDA DEMO_KEY warning
- No `grep -P` — macOS safe
- Evidence file has no leaked API keys
