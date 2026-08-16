# Idea: Dream Scanner Auto-Scope Detection

**ID:** IDEA-20260527-dream-auto-scope
**Date:** 2026-05-27
**Status:** captured
**Scope:** medium

---

## Summary & Problem

TAD's dream scanner currently relies on manual `scope_tag: project/framework` classification in candidates. ECC's continuous-learning-v2 solves this automatically: hash the git remote URL to create a project ID, then auto-promote patterns to "global" when the same pattern appears in 2+ projects. TAD could adopt this for `*dream` and `*optimize` — auto-detect scope via git remote hash, and auto-suggest `scope_tag: framework` when a candidate's signal appears across multiple registered projects in sync-registry.yaml.

## Open Questions

- Should auto-scope detection run inside dream-scanner.sh or as a separate post-scan step?
- ECC uses `${XDG_DATA_HOME}/ecc-homunculus/projects/<hash>/` — should TAD use a similar external storage or keep project-knowledge files in .tad/?
- Confidence scoring (0.3-0.9) vs TAD's binary pending/accepted — worth adding numeric confidence?
- How to handle projects without git remote (local-only repos)?

## Notes

- Reference: ECC `skills/continuous-learning-v2/SKILL.md` — project detection via git remote hash
- ECC auto-promotes when seen in 2+ projects — matches TAD's existing Domain Pack threshold rule
- TAD's `*evolve` already does cross-project aggregation but manually — this would automate the scope classification step

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
