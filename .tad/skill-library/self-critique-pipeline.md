# self-critique-pipeline

**Source project**: TAD
**Date**: 2026-10-31
**Type**: protocol + runnable filter tool (`self_critique_filter.py`, same directory)
**Origin**: IDEA-20260703-self-critique-generation-pipeline (AI Tinkerers #33 — nightly batch generation + model self-critique filter)

## Pattern

Batch generation → per-item self-critique against a fixed rubric → ship only the
passing items → log the keep ratio and every drop finding. Applied first to
skill drafts; the same shape fits any batch-produced content (flashcard art,
research findings, handoff drafts) whose quality varies per item and whose
review cost must not scale linearly with batch size.

**What this is not**: self-critique is a *producer-side* filter. It does not
replace independent review — TAD's rule stands (principles: no one judges
their own work; verdicts come from a party that did not do the work). Items
this pipeline "ships" enter their target collection as **drafts**; promotion
to accepted knowledge still follows the normal path (KA distillation by a
structural stranger, Gate review where the collection requires it). The
pipeline's job is to keep obvious failures from consuming reviewer attention,
and to make the failure mix visible as data.

## Stages

0. **Brief** — one file per run: target collection, item format, batch size N,
   topic list or generation prompt. No brief, no run (an unbriefed batch
   cannot be critiqued against intent).
1. **Generate** — the producing model writes N candidate items as separate
   files under `candidates/`. Generation and critique are separate passes:
   finish all generation before opening the rubric, so a candidate is never
   edited mid-critique to sneak past a finding.
2. **Critique** — the model scores every candidate against the rubric below,
   one verdict + one-line finding per criterion, into `critiques.json`.
   Findings must name the concrete defect ("no failure_mode section",
   "restates principles entry X"), never a vibe ("weak", "meh").
3. **Filter** — `self_critique_filter.py` validates the batch mechanically
   (every candidate critiqued, every criterion scored, verdicts well-formed),
   applies the pass rule, copies passing items to the ship directory, and
   writes the run log. The script is the only ship path: a candidate the
   script has not passed does not enter the collection.
4. **Ship + log** — passing items land in the target collection (for skill
   drafts: this library, registered in `_index.md`), the run log stays in the
   run's evidence directory. Dropped items stay in `candidates/` with their
   findings — they are the rubric's training data, not trash.

## Rubric v1 (skill drafts)

| ID | Criterion | Fail looks like |
|----|-----------|-----------------|
| C1 | Trigger clarity — a selector says when this applies, with a near-miss that should NOT trigger it | "use when things go wrong" |
| C2 | Actionability — concrete steps a zero-context reader can execute | slogans, aspirations, no verbs with objects |
| C3 | failure_mode present — names how the naive default goes wrong | entry reads as pure upside |
| C4 | Non-duplication — does not restate an existing principles / patterns / library entry (check the indexes) | same rule, new words |
| C5 | Variabilizable — episode-specific values can be swapped for another project's (the repo reusability test) | names, dates, counts that cannot be lifted out |
| C6 | Evidence grounding — factual claims cite a file/event, or are labeled proposal | invented mechanisms, uncited "studies show" |

**Pass rule**: all six criteria pass → ship. Any fail → drop, finding logged.
No partial credit and no "fix it in critique": a fixable candidate goes back
to a later batch as a new candidate, so the log keeps an honest before/after.

## Run log (written by the filter script, every run)

`run-log.json` + `run-log.md` in the run directory: batch id, rubric version,
generated N, shipped M, **keep ratio M/N**, per-candidate per-criterion
verdicts and findings, ship list. The log is the audit surface — a run whose
log is missing did not happen.

## Reading the keep ratio (the IDEA's open N/M question)

The keep ratio is a measured output, not a target. Working bands from the
pattern's origin use (image batches) and this repo's first run:

- **> 0.9** — suspect: rubric too lax, or generation too timid (only safe
  topics attempted). Tighten a criterion or widen the brief.
- **0.3 – 0.7** — healthy for a first batch on new territory.
- **< 0.2** — the brief is wrong more often than the rubric is strict; fix
  the brief before generating more.

Cost note: generation cost scales with N, critique cost with N, human cost
with M. The pipeline pays when M ≪ N and per-item human review is the
bottleneck; for N ≤ 3, skip the pipeline and review directly.

## Extension point (not implemented here): transcript mining

The IDEA pairs this pipeline with transcript mining — extracting a user's
recurring error patterns from session transcripts and feeding them back as
personalization. In pipeline terms that is a Stage 5: mine run logs +
transcripts for repeated drop findings and repeated human corrections, and
let them propose *rubric revisions* (a criterion that keeps failing the same
way is a generation-brief problem; a correction the rubric never catches is
a missing criterion). The run-log format above already carries the fields
Stage 5 would consume (per-criterion findings, verbatim). Building Stage 5
is separate work; this entry deliberately does not claim it.

## First run

Demo batch 2026-10-31 (6 skill drafts, keep ratio 3/6) — brief, candidates,
critiques, filter output and run log filed at
`.tad/evidence/surplus-phase2-20261031/self-critique-generation-pipeline/demo-run-20261031/`.
