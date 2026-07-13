---
name: Verify Content Before Deleting "Duplicates"
description: Never delete files based on format/naming patterns alone — always verify which version has the latest content
type: feedback
---

When two files appear to be duplicates (e.g., commands/ vs skills/ with similar names), NEVER assume the "newer format" is the correct one to keep.

**Why:** In TAD v2.7→v2.8 transition, skills/ had the newer format (frontmatter) but OLDER content (v2.7 slim versions missing Quality Chain fixes). Commands/ had the older format but NEWER content (v2.8 fixes). Keeping skills and deleting commands would have reverted 4 phases of critical quality chain repairs.

**How to apply:**
1. Always check git log dates for BOTH files before deciding which to keep
2. When sizes differ significantly (570 vs 3056 lines), investigate WHY — don't assume the smaller one is "refined"
3. Read handoff history to understand the evolution chain before making destructive changes
4. "Looks like a duplicate" ≠ "is a duplicate". Verify content, not just names.
