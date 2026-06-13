# Phase 4 Adversarial Review — ai-prompt-engineering — CORRECTNESS lens

- **Lens**: correctness (does the upgraded SKILL.md meet the dual-layer bar; is guidance internally consistent + actionable; can I refute it?)
- **Reviewer posture**: default skepticism, tried to REFUTE meets_bar.
- **meets_bar**: TRUE (clears the bar on the correctness lens, with documented minor defects that do not breach it)

## What was read
- `.claude/skills/ai-prompt-engineering/SKILL.md` (493 lines)
- `references/claude.md` (253), `phase1-write.md` (117), `selection-matrix.md` tool, `promptfoo-starter.yaml`, `prompt-lint.sh`, `examples/system-prompt-template.md`
- `.tad/evidence/pack-quality/QUALITY-BAR.md`
- Authoritative cross-check: `claude-api` skill (model-migration.md, models.md, error-codes.md, prompt-caching.md, structured-outputs/tool-use-concepts) — loaded live to fact-check version-sensitive API claims (QUALITY-BAR §6 mandate).

## Layer A (structure) — PASS, ~10/10
- A1 frontmatter: `name` present, `description` third-person + what/when. PASS.
- A2 progressive disclosure: references/ + tools/ + examples/ + checklists/ present. PASS.
- A3 body discipline: SKILL.md = 493 lines (< 500 hard cap, < 550 buffer). PASS but tight — any future addition risks the 500 threshold.
- A4 routing: Step 0 Context Detection Router table + signal→reference. PASS.
- A5 CONSUMES/PRODUCES present (line 8-9). PASS.
- A6 anti-skip: full Anti-Skip Table with per-excuse counters. PASS (strong).
- A7 nav index: Contents/Navigation Index table. PASS.
- A8 fixture: 2 examples (system-prompt-template.md, hallucination-diagnosis.md). PASS.
- A9 eval-ready: `discriminative_pattern:` + `min_discriminative:` present in system-prompt-template.md frontmatter. PASS.
- A10 validation script: `tools/prompt-lint.sh` (executable, ran clean — exit 0 on starter). PASS.
- Soft constraints: references one level deep (no nesting). claude.md/ci-cd-templates/failure-catalog all have a Contents TOC (>100 lines). Paths use forward slashes. No obvious voodoo constants in prompt-lint.sh.

## Layer B (depth) — PASS, ~4/5
- specN (specific-threshold count, UTF-8 locale) = **87** → bucket ≥60 → Layer B 5 on the counted sub-dimension. Reading-adjust to ~4 (some entries are generic lifecycle prose, e.g. SemVer rules).
- B1 rule specificity: carries research thresholds — 84%→12% injection, ~23% hallucination reduction, 46%/25%/29% failure taxonomy, 4096/2048 min cacheable prefix, GEPA +10pp / ~35× fewer rollouts / 32%→89% ARC-AGI, min_discriminative counts. Strong.
- B2 tool freshness: named CLIs + install + usage (promptfoo, DSPy `pip install -U dspy` with the dspy-ai→dspy rename note, DeepEval). Teaches HOW, not just names. Strong.
- B3 operationalized criteria: Tier 1/2/3 CI pipeline, 6-point pre-delivery check, escalation gate. Good.
- B4 anti-pattern coverage: FM-1..FM-6 failure catalog from real failure modes + Anti-Skip table. Strong.

## Fact-checks against authoritative claude-api skill (version-sensitive claims)
All HIGH-RISK API assertions were checked against the live claude-api skill rather than trusted:
1. `budget_tokens` 400 on Opus 4.7/4.8/Fable 5; deprecated-but-works on 4.6/Sonnet 4.6 — **CORRECT** (matches model-migration.md + Thinking & Effort quick ref).
2. Last-assistant prefill 400 on 4.6/4.7/4.8/Fable 5 — **CORRECT**.
3. `temperature`/`top_p`/`top_k` removed (400) on Opus 4.7+ (NOT Sonnet 4.6) — **CORRECT** (error-codes.md scopes the 400 to "Fable 5 / Opus 4.8 / 4.7"; Sonnet 4.6 excluded). Therefore `temperature: 0.0` on `claude-sonnet-4-6` in promptfoo-starter.yaml is **VALID**, not a bug.
4. Min cacheable prefix 4096 (Opus 4.8/4.7/4.6/Haiku 4.5) / 2048 (Sonnet 4.6/Fable 5) — **CORRECT** (matches prompt-caching.md table; Fable 5 = 2048).
5. Haiku 4.5 effort errors / no `max`/`effort` — **CORRECT** ("Will error on Sonnet 4.5 / Haiku 4.5").
6. Fable 5: omit `thinking` (disabled also 400s), ~30% tokenizer, refusal stop_reason, 30-day retention — **CORRECT** on all four.
7. structured outputs via `output_config.format` not prefill; supported on Opus 4.8/Sonnet 4.6/Haiku 4.5/Fable 5 — **CORRECT**.
8. mid-conversation system message beta `mid-conversation-system-2026-04-07` — **CORRECT**.
9. effort levels low/medium/high/xhigh/max, xhigh added on 4.7, default high — **CORRECT**.
10. count_tokens not tiktoken; tiktoken undercounts — **CORRECT** (token-counting.md).
No fabricated API surface found. This is the failure class that historically broke this pack (claude.md was corrected 2026-06-13 to remove the old budget_tokens teaching) — the correction holds.

## Defects found (none breach the correctness bar)
- **P2 — DSPy MIPROv2 example passes BOTH `auto="medium"` AND `num_trials=25` (selection-matrix.md L127-135).** In DSPy these are competing controls — `auto` presets the trial budget; passing `num_trials` alongside `auto` is at best redundant and in current DSPy raises/ignores. SKILL.md's own MIPROv2 snippet (L331-337) uses only `auto="medium"` — so the two copies disagree. Actionable fix: drop `num_trials` from the matrix copy or set `auto=None` when specifying `num_trials`. Not a meets_bar breach (it's a tool reference example, runs degraded not wrong), but it is an internal inconsistency between SKILL body and tool ref.
- **P2 — GEPA `reflection_lm="openai/gpt-4.1"` hardcodes a non-Claude model in a Claude-targeted pack.** Defensible (GEPA wants a separate, often stronger reflection model and this is a real DSPy idiom) and the text flags it as REQUIRED, but a Claude-pack reader gets an OpenAI dependency with no Claude alternative shown. Minor; actionable: note `anthropic/claude-opus-4-8` is a valid reflection_lm too.
- **P3 — Escalation-gate threshold ambiguity (SKILL §3.1).** Header says "score on 6 dimensions (1–10, ≤4 = needs fix)" but the escalation rule fires at "≥2 dimensions score ≤2". Two different cut points (≤4 vs ≤2) are presented without reconciling "needs fix" (per-dimension) vs "full redesign" (aggregate). Readable as a two-tier system but not stated as such — mildly under-actionable.
- **P3 — Model-ID drift across files (cosmetic).** SKILL §3.6 dspy.LM uses `claude-opus-4-8`; selection-matrix.md uses `claude-sonnet-4-6`; promptfoo-starter and config examples use `claude-sonnet-4-6`. All are valid pinned IDs, so no correctness error, but the pack isn't consistent about its example target model.
- **P3 — A3 body size 493/500.** Clears the cap with 7 lines of headroom; flag for future edits.

## Why meets_bar = TRUE despite defects
The correctness bar is: dual-layer pass + internally-consistent + actionable + factually sound on version-sensitive claims. Layer A ~10/10, Layer B ~4/5, all 10 high-risk API assertions verified CORRECT against the authoritative source (the historical failure class is fixed), and the lint script actually runs and gates. The defects are two P2 tool-example inconsistencies (DSPy param redundancy, OpenAI reflection_lm) and three P3 cosmetic/ambiguity items — none produce wrong agent behavior on the core lifecycle, none are fabricated API surface. I could not refute meets_bar on the correctness lens; the residual items are fix-on-next-pass, not blockers.

---

## ADDENDUM — second correctness pass (merge, 2026-06-13)
A second independent correctness review confirms meets_bar=TRUE and the fact-check table above (all 10 high-risk API claims re-verified CORRECT against the live claude-api skill). It adds/sharpens these findings; where it disagrees with the first pass, the disagreement is noted explicitly.

- **ADD F1 (P1, sharpens the temperature item): the two `temperature: 0.0` templates are a latent 400 because they collide with the pack's OWN pinning advice.** First pass (L37) is correct that `temperature` is accepted on `claude-sonnet-4-6`, so the template as literally written does not 400. BUT the pack repeatedly pushes users to pin `claude-opus-4-8` (DSPy example SKILL §3.6; claude.md model table "Current default Opus"; structured-output examples). A user who follows "pin opus-4-8" and keeps the copy-paste `temperature: 0.0` from `promptfoo-starter.yaml:22` / `ci-cd-templates.md:349` gets an HTTP 400 — and neither template carries a "delete temperature for Opus 4.7+/Fable 5" warning, despite claude.md:253 stating exactly that removal. This is an internal-consistency defect (one part of the pack hands you a config another part of the pack says will 400). One-line fix ×2: drop `temperature` or add the inline warning. Treated as P1 fix-before-accepted; first pass under-weighted it as "VALID, not a bug" by only considering the Sonnet-4.6 literal case, not the opus-pinning interaction the pack itself steers toward.
- **ADD F2 (P2): FM-6 + pre-deploy checklist still teach temperature tuning as a live config lever** (`failure-catalog.md:255,266,282`: "Is temperature appropriate? creative 0.7–1.0 / precise 0.0–0.3"; echoed SKILL.md:256). On the pack's target family (Opus 4.7/4.8, Fable 5) `temperature` does not exist (400s) — the reasoning-native steer is `effort` + prompting, per the pack's own claude.md Rule 1. The taxonomy (46/25/29) is fine; the concrete remedy it points at is dead on current Claude. Scope the temperature advice to "providers that still expose sampling params."
- **ADD F3 (P2, instrument caveat for Gate 3): the LITERAL QUALITY-BAR specN command scores this pack 0, not 87.** QUALITY-BAR §2.3's path-set is `SKILL.md / references/ / skills/ / checklists/ / adapters/` — it does NOT include `tools/`. The pack's specific-number depth (GEPA numbers, 4096/2048 prefixes, promptfoo config) lives in `tools/selection-matrix.md` + `tools/promptfoo-starter.yaml`. Running the exact §2.3 command → specN=0 → bucket 1 → Layer B FAIL; only by adding `tools/*.md` (what the first pass did to get 87/88) does it score bucket 5. Content is genuinely deep (reading-based Layer B ~4 stands), but a naive Gate-3 re-run of the literal command will FALSELY fail Layer B. Fix: relocate selection-matrix.md to `references/`, or add `tools/` to the specN path-set for this pack. (First pass reported 87 without flagging that the literal command path-set excludes tools/.)
- **CONFIRM** the first pass's P2 DSPy findings (MIPROv2 `auto`+`num_trials` redundancy at selection-matrix L127-135 vs SKILL §3.6 using only `auto`; GEPA `reflection_lm="openai/gpt-4.1"` with no Claude alternative shown) and P3 items (escalation-gate ≤4 vs ≤2 cut-point ambiguity; example model-ID drift; 493/500 body headroom). All valid, all non-blocking.
- **CONFIRM** Layer A ~10/10 and the full fact-check table. No fabricated API surface. claude.md's 2026-06-13 correction (removing the old `budget_tokens` teaching) holds.

**Net verdict (merged): meets_bar = TRUE.** I could not refute it on the correctness lens — every version-sensitive Claude API claim is accurate, the dual layers pass on reading, and the validator runs. The must-fix-before-"accepted" item is F1 (the temperature/opus-pinning collision, one-line ×2); F2/F3 are strongly recommended; the rest are fix-on-next-pass.
