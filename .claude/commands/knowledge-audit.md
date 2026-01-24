# /knowledge-audit Command (Knowledge Health Check)

## Purpose

Audit project knowledge files to identify gaps and ensure knowledge is being captured properly.

---

## When to Use

- After completing a major feature (check if knowledge was captured)
- During project reviews
- When onboarding new team members
- When user says "check knowledge", "audit knowledge", "knowledge status"

---

## Execution Steps

### 1. Scan Knowledge Directory

```bash
ls -la .tad/project-knowledge/*.md
```

List all knowledge files and their sizes.

### 2. Analyze Each File

For each `.md` file (excluding README.md):

```yaml
Check 1: Has Foundational Section?
  - Look for "## Foundational:" heading
  - If missing → Flag as "Needs Bootstrap"

Check 2: Has Accumulated Learnings?
  - Look for "## Accumulated Learnings" heading
  - Count entries under it (### headings with dates)
  - If 0 entries → Flag as "No learnings recorded"

Check 3: Content Quality
  - File size < 500 bytes → Likely empty/template only
  - File size > 10KB → May need consolidation
```

### 3. Generate Audit Report

Output format:

```
╔══════════════════════════════════════════════════════════════╗
║              PROJECT KNOWLEDGE AUDIT REPORT                  ║
╠══════════════════════════════════════════════════════════════╣

📊 Summary
──────────────────────────────────────────────────────────────
Total Files: 8
Healthy: 5
Needs Attention: 3

📋 File Status
──────────────────────────────────────────────────────────────
| File              | Foundational | Learnings | Status      |
|-------------------|--------------|-----------|-------------|
| ux.md             | ✅ Yes       | 4 entries | ✅ Healthy  |
| code-quality.md   | ✅ Yes       | 3 entries | ✅ Healthy  |
| security.md       | ✅ Yes       | 6 entries | ✅ Healthy  |
| testing.md        | ✅ Yes       | 2 entries | ✅ Healthy  |
| architecture.md   | ✅ Yes       | 2 entries | ✅ Healthy  |
| performance.md    | ❌ No        | 1 entry   | ⚠️ Needs Bootstrap |
| api-integration.md| ❌ No        | 0 entries | 🔴 Empty    |
| mobile-platform.md| ❌ No        | 0 entries | 🔴 Empty    |

⚠️ Issues Found
──────────────────────────────────────────────────────────────
1. [BOOTSTRAP] performance.md - Missing Foundational section
   → Run knowledge bootstrap or manually add design standards

2. [EMPTY] api-integration.md - No content recorded
   → Consider: Is this category relevant? If yes, add content.
   → If not relevant, consider removing the file.

3. [EMPTY] mobile-platform.md - No content recorded
   → Same as above

💡 Recommendations
──────────────────────────────────────────────────────────────
1. For empty files: Either populate with foundational info or
   remove if the category isn't relevant to this project.

2. Review recent Gate 3/4 executions - were Knowledge Assessments
   completed? If not, retroactively record any learnings.

3. Consider running /tad-init with bootstrap flag to populate
   missing foundational sections.

╚══════════════════════════════════════════════════════════════╝
```

### 4. Optional: Auto-Fix Mode

If user runs `/knowledge-audit --fix`:

1. For files missing Foundational section:
   - Attempt to extract info from codebase (same as bootstrap)
   - Write Foundational section

2. For completely empty files:
   - Ask user: "Remove {file}? It has no content. (y/n)"
   - If no, add placeholder with TODO

---

## Status Definitions

| Status | Meaning | Action |
|--------|---------|--------|
| ✅ Healthy | Has both Foundational and Learnings | None needed |
| ⚠️ Needs Bootstrap | Missing Foundational section | Run bootstrap |
| 🔴 Empty | No content beyond template | Populate or remove |
| 📦 Needs Consolidation | >15 entries | Consider merging entries |

---

## Integration with Gates

This command can be triggered automatically:
- After Gate 4 passes (suggest audit if >5 Gates without recording)
- When `/tad-status` is run (include summary)

---

[[LLM: This command audits project knowledge files to ensure knowledge capture is happening properly. It identifies gaps in foundational knowledge and tracks whether learnings are being recorded during development.]]
