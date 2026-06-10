---
task_type: code
e2e_required: no
research_required: no
---

# HANDOFF-20260607-slugify-maxlen

## 1. Executive Summary
Add a `max_length` parameter to the existing `slugify` function so callers can cap slug length, cutting at the last hyphen before the limit.

## 6. Implementation Steps
1. Modify `slugify()` in slugify.sh to accept an optional second arg `max_length`.
2. When the slug exceeds max_length, truncate at the last hyphen before the limit.
3. Return the truncated slug.

## 7. Files to Modify
- `.tad/evidence/codex-validation/sandbox/slugify.sh`

## 9. Acceptance Criteria
- AC1: `slugify "hello world foo bar" 11` returns `hello-world`.
  Verification: `slugify "hello world foo bar" 11 | grep -P '^[a-z\-]+$'`
- AC2: `max_length` defaults to 50 when the caller omits the second argument.
  Verification: `slugify "a very long string here"` truncates to 50 chars.
- AC5: When no `max_length` argument is given, the slug is returned in full with NO truncation.
  Verification: `slugify "a very long string here"` returns the full slug.
