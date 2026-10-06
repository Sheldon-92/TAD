# Run Trace — R3 Group 2 Borrow-4 Trial Run

- Routing freeze: `trial-index/routing.md` sha256 =
  `c755465a1cfba4a6de22f16978344563a284bd4107b7ee8ae97baa34821387eb`
  (frozen 2026-10-06 before the runner sub-session was spawned; any
  post-run mismatch invalidates the run)
- Runner: independent sub-session (spawned after the freeze; brief
  contained only the question-subset path, the three surface paths in
  order, the top-3 protocol, and the forbidden list — no expected
  answers, no criteria values, no build-record)
- Run start (UTC): 2026-10-06 22:10 +0000 (spawn time)
- Run end (UTC): 2026-10-06 22:11 +0000 (runner report received)
- Freeze re-verified at scoring time: routing.md sha256 still
  `c755465a1cfba4a6de22f16978344563a284bd4107b7ee8ae97baa34821387eb` — match.

## Runner reading self-sign (verbatim from runner report)

Files the runner reports it actually opened:

- `/home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/questions-subset-13.md`
- `/home/hatch/workspace/yun-sync/TAD/AGENTS.md` (opened per the runtime house-rules note, not used as a retrieval surface)
- `/home/hatch/workspace/yun-sync/TAD/.tad/brain-index.md` (Surface 1)
- `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/_index.md` (Surface 2)
- `/home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/trial-index/routing.md` (Surface 3)

Runner declaration (verbatim): "I explicitly declare that I did not
open, read, grep, or list the contents of any forbidden path: nothing
under .tad/project-knowledge/incidents/, nothing under the
trial-index/drawers/ directory, expected-subset-13.md, build-record.md,
anything under .tad/evidence/self-review-r2-20261006/, and
HANDOFF-2026-10-06-self-review-r3.md or its SUPPLEMENT files. No files
were written or modified."

Scoring note (Blake): the AGENTS.md open is outside the forbidden list
and outside the three retrieval surfaces; it is recorded here for full
transparency and does not breach the §4.2.3 blind protocol (the file
contains no expected answers).

## Returned candidate sequences (verbatim from runner report)

```
Q33: academic-research-pack-pilot
Q34: claude-md-routing-label-conflicts
Q35: gemini-cli-constraints
Q36: pack-collision-detection
Q37: scienceclaw-skill-decoupling
Q38: alex-role-decay-direct-execution
Q39: cross-agent-parity-check
Q40: pack-value-cross-vendor
Q41: (none)
Q42: (none)
Q43: (none)
Q44: (none)
Q45: (none)
```

Observation for scoring: the runner returned exactly one candidate for
each of Q33–Q40 and empty lists for Q41–Q45. The protocol permits
returning fewer than 3; scoring proceeds mechanically on the returned
sequences as filed here.
