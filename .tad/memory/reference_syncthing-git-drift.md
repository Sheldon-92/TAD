---
name: syncthing-git-drift
description: "TAD repo (incl. .git) lives in a Syncthing folder shared by the Mac and \"box\"; dirty or stale files in git status may be sync artifacts, not real edits"
metadata:
  node_type: memory
  type: reference
  originSessionId: 4c13d277-86e6-4341-9162-3d5116d81eb6
  modified: 2026-10-11T03:28:47.595Z
---

`云同步/` is a Syncthing folder synced between the Mac and the cloud "box" (grokbox); agents commit on both ends. As of 2026-10-10 TAD's `.git` is synced too.

Observed 2026-10-10:
- `云同步/.stignore` has credential deny patterns (`**/*token*`, `**/*secret*`, `**/.env.*` …). 20 git-tracked TAD files match by name (e.g. `secret-detection-rules.md`, `design-tokens.md`). They never sync while `.git` does, so they show up as "modified" with OLD content; committing them reverts a newer commit.
- `sync-conflict` copies appear inside `.git` (index, HEAD, refs). The TAD PM archives them under `.git/archived-sync-conflicts/`.
- Deleted directories leave husks containing only the name-matched files.

**How to apply:** before trusting or committing an unexpected modified file, compare its mtime with its last commit and `git diff <older-commit> -- <file>`; if it equals an older commit it is a stale copy, restore it instead of committing. `.stignore` belongs to grok-cloud / Infra, not TAD — recommend changes, don't edit it (see [[cross-project-tracking-boundary]]).

Direction chosen by the user on 2026-10-10: TAD stays in Syncthing (the user rejected taking the whole `/TAD` folder out); only `.git` and `.worktrees` leave it, and the two ends align git state through GitHub. Not yet executed; note for Infra at `.tad/evidence/pm/sync-git-out-of-syncthing-20261010.md`. Re-check `云同步/.stignore` for `/TAD` before assuming this still holds.
