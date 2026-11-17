---
dispatch_id: p1-y3-1
task_type: code
# rubric_ac: the §9.1 rows graded by an independent judge against a rubric (gate skill Rubric Evaluation Protocol), e.g. [AC14], or none; cora-check.sh judge-first reads this line; the Gate 2 consistency lens checks it against §9.1 (review contract §5)
rubric_ac: None
---

# Handoff jf fixture

The rubric and the judge are mentioned in prose here.

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Method |
|---|---|---|
| AC1 | grep finds the word judge in the rubric file | grep -c judge rubric.md |

rubric_ref: rubric.md (below the first ## heading: not front matter)
