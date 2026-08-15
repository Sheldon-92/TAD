Not ready for a `2.40.1` patch release.

Evidence:

- Source guard passed: physical root is `/path/to/TAD`; origin is `https://github.com/Sheldon-92/TAD.git`.
- `.tad/version.txt` contains `2.40.0`, making the next patch `2.40.1`.
- `rg -n '^##[[:space:]]+\[?2\.40\.1\]?' '/path/to/TAD/CHANGELOG.md'` exited `1`: no `2.40.1` changelog entry.
- `git -C '/path/to/TAD' status --short` exited `0`, reporting 6 modified and 29 untracked paths without an explicit release scope.
- `git -C '/path/to/TAD' log --oneline origin/main..HEAD` exited `0`, reporting three commits ahead of the locally recorded `origin/main`.
- `git -C '/path/to/TAD' diff --stat` exited `0`: 6 tracked files changed, with 239 insertions and 917 deletions.

Per [publish-ops.md](/path/to/01-on%20progress%20programs/TAD/.claude/skills/release-runbook/references/publish-ops.md), the missing changelog entry and unexplained dirty/unpushed scope are preflight blockers. I therefore stopped before parity, version, version-sweep, migration, and supporting checks.

No prohibited files were opened, no healing was attempted, and no writes, commits, tags, pushes, publishing, or sync actions were performed.