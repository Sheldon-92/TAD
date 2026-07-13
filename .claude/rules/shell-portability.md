---
paths:
  - ".tad/hooks/**"
---
# Shell Portability — hard constraints for .tad/hooks/** edits

> THIN EXCERPT. Source of truth: .tad/project-knowledge/patterns/shell-portability.md
> Sync note: to change a constraint, edit the source pattern file — this file only
> mirrors excerpts and must follow the source, never fork from it.

1. No `grep -P` on macOS — use `grep -o` + `sed` instead. (source entry 2026-04-03)
2. Search-style `grep` inside `$(...)` under `set -e`: a no-match exit 1 fires the
   ERR trap before any if-branch runs — always append `|| true`. (source entry 2026-06-17)
3. `comm`/`sort` set operations over text that may contain CJK/non-ASCII must force
   `LC_ALL=C` on the `comm` AND both feeding `sort`s, or phantom intersections appear.
   (source entry 2026-05-31)
4. Never `exit` inside a helper called via `$(...)` — it kills only the subshell and
   the captured stdout swallows GATE markers. Emit markers and `exit` at the call
   site in the main script context. (source entry 2026-06-09)
5. Never use `\b` for hyphenated-slug matching — BSD grep treats `-` as a word
   boundary. Use the bracket class `(^|[^A-Za-z0-9_-])PATTERN([^A-Za-z0-9_-]|$)`.
   (source entry 2026-04-24)

Note: path-scoped rules load when a matching file is READ (not on write/creation of
new files) — read the target hook file before editing it.
