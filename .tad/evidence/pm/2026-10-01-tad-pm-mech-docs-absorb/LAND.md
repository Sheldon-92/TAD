# LAND — TASK-20261001-TAD-PM-MECH-DOCS-ABSORB

## Paths and changes

- `docs/pm/intent.md` — replaced the stale current-default model wording with four resolvable shared pointers: model routing, PM charter, human operating rules, and the GM’s dated Codex lock. Recast the 2026-09-13 model list as historical. No local model table or `docs/model-routing.md` was added. The working tree already contained the v2.44.5 intent update; it was retained.
- `docs/pm/auth.md` — added light pointers to HO §§3.7b/3.7d/3.10 and shared `open-run-card.md` / `restate.md`; states the disk + same-body 1:1 + stamp order, non-empty restate with human “understood correctly” trace, and discuss-not-Blake-basis boundary. No checker script was added.
- `docs/pm/acceptance.md` — added pointers to HO §§3.8b/3.9/3.12 and shared `exit-human-card.md` / `gate4-pm-closeout.md`; states candidate-or-HOLD closeout, 1:1-only finish/ask/look, explicit KA, and both dual-write ticks or “本刀无项目记忆”.
- `docs/pm/now.md` — closed this task in two lines and recorded a HOLD reason plus GM unlocker.
- `docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md` — synchronized status, verdict, continue flag, evidence pointer, and next-candidate HOLD with STATUS.
- `.tad/evidence/pm/2026-10-01-tad-pm-mech-docs-absorb/STATUS.md` — task status, model override, scope, and limits.
- `.tad/evidence/pm/2026-10-01-tad-pm-mech-docs-absorb/ACCEPTANCE.md` — checklist against every FILTER yes row.
- `.tad/evidence/pm/2026-10-01-tad-pm-mech-docs-absorb/REVIEW.md` — independent doc-only review evidence.
- `.tad/evidence/pm/2026-10-01-tad-pm-mech-docs-absorb/LAND.md` — this path and diff summary.

No local template wrapper was needed: the PM docs can point directly to the shared templates. The hygiene draft was read as reference only.

## Boundaries

No writes were made under `gm/` or `grok-cloud/`. No `.tad/templates`, `NEXT.md`, session-state, skill, hook, or configuration files were edited for this task. No release, tag, push, Publish, or commit was run; changes remain uncommitted.

The requested evidence files are present on disk. `.tad/evidence/` is ignored by the repository, so these files do not appear in normal `git status`; they were left in place and were not force-added.

The worktree also reports unrelated dirty/deleted paths outside this knife. Their origin is not attributed here; none were written by this task.
