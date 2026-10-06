# Anchorless .tad/ sed Strips Inconsistently on Relative ls -d Paths

**Date:** 2026-06-01
**Linked to:** L2 shell-portability "Shell Dispatcher Patterns"

---

### Anchorless `.tad/` sed Strips Inconsistently on Relative `ls -d` Paths — Glob With a Leading Slash — 2026-06-01
- **Context**: self-deriving-release-sync P1. `derive-sync-set.sh --dirs` normalizes `ls -d <root>/.tad/*/` basenames. The handoff's SC1 *reference recompute* used `ls -d .tad/*/ | sed 's,.tad/,,;s,/,,'`. On a relative path, `ls -d .tad/*/` emits `.tad/active/` with NO slash before `.tad`, and the regex `.tad/` (`.` = any char, no anchor) matched inconsistently → output like `.tadactive/` instead of `active`. The lib itself was correct.
- **Discovery**: A `sed 's,.tad/,,'` (or `s|.tad/||`) that means "strip the `.tad/` path component" is fragile two ways: (1) the leading `.` is an unanchored regex wildcard, and (2) without a `/` BEFORE `.tad` the intended "directory boundary" anchor doesn't exist. The robust form is to (a) glob with a guaranteed leading slash — `ls -d "$ROOT"/.tad/*/` yields `./.tad/active/` (a `/` precedes `.tad`), and (b) normalize with `sed 's|.*/\.tad/||;s|/$||'` (escape the dot, anchor on `.../​.tad/`, strip only a trailing slash). This makes basename extraction independent of whether the caller passed `.` or an absolute root. When a set-equality `diff <(lib) <(reference)` fails, suspect the REFERENCE command's path normalization before the lib — re-run the reference with the SAME glob form the lib uses (`ls -d ./.tad/*/`) or just use the lib's own `--dirs` as the canonical reference.
- **Action**: For "strip a path component" sed, escape literal dots (`\.`) and anchor on a preceding `/` (`.*/\.tad/`); glob with a leading `./` or absolute root so the anchor exists. Prefer the tool's own output as the comparison baseline over a hand-rewritten recompute that can drift from the tool's normalization.
- **Grounded in**: .tad/hooks/lib/derive-sync-set.sh (emit_dirs), COMPLETION-20260601-self-deriving-release-sync-phase1.md §5 note
