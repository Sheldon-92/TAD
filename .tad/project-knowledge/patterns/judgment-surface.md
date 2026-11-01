# Judgment Surface Patterns

### The Judgment-Surface Reflex: No Auto-Evaluator → Build the Interface, Don't Ask in Prose — 2026-10-31

- **Context**: In domains with no automatic evaluator — voice, music, video,
  hardware feel, visual design — "good" lives in human perception and taste,
  not in any metric the agent can run. The naive move is to ask the human in
  chat: "what do you think?" That question is low-bandwidth (one prose reply),
  unanchored (nothing side-by-side to react to), and produces a verification
  question, which the human rubber-stamps (principles: AI/Human Judgment
  Domain Awareness — Rubber Stamp Effect, Preview Anchoring). The judgment
  still has to happen; the only question is whether it happens on a surface
  built for it or in a chat scrollback where it evaporates.
- **Discovery**: The one lever a CLI agent has that a chat AI does not is
  programming against the real environment. Used on the judgment itself, that
  lever builds a throwaway **judgment surface**: a one-off HTML page that
  puts the candidates side by side (A/B players, direction cards, scoring
  grids), captures the human's picks as structured data, and persists that
  data as a project fossil. Two fossils prove the shape:
  1. **Visual (in-repo)**: `/playground` —
     `.tad/templates/playground-template.html`. The human does not describe
     a design direction in prose; they walk 2–3 assembled directions,
     compare palette/typography per dimension in tabs, and click
     "Choose This Direction". The judgment is a selection among rendered
     candidates, not an opinion about described ones.
  2. **Audio (Colin podcast project)**: voice/music candidates were judged
     through a generated A/B player page; the human's votes were compiled
     into `ab_votes.json` — taste turned into a structured, re-readable
     artifact the next session could consume without re-asking.
  In both, the surface did three things prose cannot: it **rendered the
  candidates in their native medium** (you hear audio, you see design), it
  **forced comparison** (nothing is judged in isolation), and it
  **compiled the verdict into data** (JSON on disk, not adjectives in a
  transcript).
- **Action**: Run this reflex whenever BOTH conditions hold:
  1. **No automatic evaluator** exists for the quality in question (no
     test, metric, or spec decides it — a human's perception does), AND
  2. You are about to ask the human for a judgment ("你觉得怎么样",
     "which sounds better", "does this look right").
  Then, instead of asking:
  1. **Generate the surface** from `.tad/templates/judgment-surface-template.html`:
     one page, candidates embedded in their native medium (audio/video/img
     tags or rendered components), reachable by the human in one click.
  2. **Structure the capture** per candidate: a verdict
     (ok / modify / delete / replace — the Feedback JSON v1.0 enum),
     scores on the 2–4 dimensions that actually discriminate in this
     domain (name them; generic "quality" is not a dimension), free-text
     for what the grid cannot say, and a priority. Scores export in the
     additive per-element `scores` field; `structured_feedback` stays
     the schema's typed modification-instruction object
     ({text, style, position}) and is never reused for scores. A
     priority the human did not set exports as null — pre-fill nothing
     the human is meant to judge (Preview Anchoring).
  3. **Export as data**: the page's Export button emits Feedback JSON
     Schema v1.0 (`.tad/templates/feedback-json-schema.md`) — that JSON,
     filed in the project, is the judgment. The agent's next step consumes
     the JSON, never a paraphrase of the conversation about it.
  4. **Sediment**: keep the exported JSON with the artifact it judged
     (it is the fossil layer — the next session's prior). Recurring
     dimensions or verdict patterns across ≥3 uses are distillation
     candidates for project knowledge; one-off surfaces stay fossils.
  - **When NOT to build one**: an automatic evaluator exists (run it —
    judgment surfaces are for the evaluator-shaped hole, not a ritual);
    the decision is a genuine one-bit direction choice with no candidates
    to render (use a plain choice question, recommendation first, per the
    principles amendment); the human is not the judge of this quality
    (AI-domain judgment — self-judge or cross-review).
  - **Rule of three (recorded, not yet due)**: `/playground` is currently
    the visual instance of this reflex and the audio page was the second.
    Generalizing `/playground` into the shared thin mechanism waits for a
    third domain to need it (IDEA-20260609 converged section) — this entry
    fossilizes the reflex and the craft; it does not extract the code.
- **failure_mode**: Naive default A: ask "what do you think?" in chat →
  low-bandwidth prose, rubber-stamped verification, judgment evaporates
  with the session and is re-asked (and re-answered differently) next
  time. Naive default B: the agent judges taste itself → confidently
  wrong in the perception domain (the 200 ms edit-point class of error),
  discovered only when the human finally hears/sees the result. Naive
  default C: build the surface but keep the verdict in conversation →
  the fossil is the page nobody can re-read; the data export is the
  deliverable, the page is scaffolding.
- **Grounded in**: IDEA-20260609-repositioning-capability-acquisition.md
  (converged section, 2026-06-09: positioning = human-AI OS for domains
  without automatic evaluators; judgment surface named the highest-value
  mechanism; human-confirmed next step = fossilize this reflex);
  `.tad/evidence/research/repositioning-3-walls/` (depth-axis findings);
  `.tad/templates/playground-template.html` (fossil 1);
  Colin project `ab_votes.json` as reported in IDEA-20260609 (fossil 2);
  principles entry "AI/Human Judgment Domain Awareness" (domain split,
  choice-not-verification, Rubber Stamp Effect).
