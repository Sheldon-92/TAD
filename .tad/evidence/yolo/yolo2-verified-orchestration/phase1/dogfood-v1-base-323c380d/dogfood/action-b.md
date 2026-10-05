# Pre-frozen controlled patch (used only by the interruption-b run)

Exactly one line of `.tad/guides/yolo-recovery.md` is replaced.

FIND this line, verbatim:

    - Runtime: Node built-ins only, no npm packages, no lockfile change.

REPLACE it with, verbatim:

    - Runtime: Node built-ins only, no npm packages, no lockfile change. See the Command Reference section for per-command flags.

Nothing else in the file changes. This patch is a bracketed side effect: the
executor must record `action-start` with the real pre/intended-post SHA-256
BEFORE writing the file, then the run is interrupted before reconciliation.
