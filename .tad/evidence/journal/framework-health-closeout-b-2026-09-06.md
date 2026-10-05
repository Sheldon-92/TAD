# Journal — Framework-Health Close-out B (2026-09-06)

## Findings

- After `git rm --cached` of `.tad/evidence/` and `.tad/archive/` on `main`, Gate 3
  artifacts for this task still write to those directories on disk, but they are no
  longer on the `main` tree. Alex Gate 4 must read the working-tree paths or
  `git show maintainer-evidence:<path>`, not `git show HEAD:<path>`.
- `git archive --format=tar HEAD | gzip -9 | wc -c` on `98b7e396` printed
  `tarball:  8704939` (macOS `wc -c` pads the number). That is the raw AC8 carrier.

## Knowledge Assessment

- Q1: Yes — retrieval path for post-untrack evidence, plus the measured tarball byte count.
- Q2: No skill candidate; the comm -23 / `git add -f` / no-pathspec rules were already in the handoff.
- Q3: No new workflow pattern; worktree sync followed the designed isolation path.
