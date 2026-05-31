# Dogfood Runbook — Re-run tad-evolution-research through wired *research-plan (AC4.4)

**Handoff:** HANDOFF-20260531-research-engine-wire-phase4
**Date drafted:** 2026-05-31
**Operator:** ALEX (Terminal 1). Blake does NOT run `*research-plan` (terminal isolation).
**Target notebook:** `tad-evolution-research` (notebook_id `37cfefa5-52b3-4a8a-a8e3-a83f32150759`)
**Goal:** prove the now-wired effort-scaling ladder actually fires dynamic seeds (trace
`seed_origin >= 1`) + adversarial challenge, and produces output at least as good as the
2026-05-05 baseline.

---

## Pre-flight (all dry-run-verified by Blake on 2026-05-31)

| # | Check | Command | Verified result |
|---|-------|---------|-----------------|
| 1 | notebook-id resolves | `yq -r '.notebooks[] \| select(.id=="tad-evolution-research") \| .notebook_id' .tad/research-notebooks/REGISTRY.yaml` | `37cfefa5-52b3-4a8a-a8e3-a83f32150759` |
| 2 | baseline findings present | `test -f .tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md` | EXISTS |
| 3 | NotebookLM CLI present | `test -x ~/.tad-notebooklm-venv/bin/notebooklm` | EXISTS+EXEC |
| 4 | Phase 0class wired | `grep -c 'PHASE 0class' .claude/skills/alex/SKILL.md` | 1 |
| 5 | OBJECTIVES.md present | `test -f OBJECTIVES.md` | EXISTS (so Phase 4-5 run, not skipped) |
| 6 | challenge template present | `test -f .tad/templates/research-challenge-prompt.md` | EXISTS |
| 7 | baseline seed_origin count | `grep -rl 'seed_origin' .tad/evidence/research/ \| wc -l` | **0** (this is the bug Phase 4 fixes) |
| 8 | codex / gemini available | `command -v codex; command -v gemini` | both **yes** (complex-tier challenge can fire) |

All preflight commands were syntax-checked (`bash -n`) and path-verified by Blake.
Do NOT run any of the `notebooklm ask` / `codex exec` / `gemini -p` invocations during
preflight — they consume quota; they fire only inside the live `*research-plan` run below.

---

## Steps for Alex

1. **Activate Alex** in Terminal 1: `/alex`, then invoke `*research-plan`.

2. **Provide the research item** (a COMPLEX-tier item, to exercise BOTH dynamic seeds and
   the adversarial challenge):
   > "Survey the 2026 AI-agent framework landscape for TAD upgrade directions across the
   >  retrieval / evaluation / cost-observability KRs (all incomplete) — refresh tad-evolution-research."

   This phrasing matches the **complex** trigger (>=3 incomplete KRs + explicit landscape scope),
   so the ladder should set `run_dynamic_seeds=on`, `run_adversarial_challenge=on`.

3. **Phase 0class (NEW) — confirm the classification display.** Alex shows:
   ```
   Effort classification: complex
     -> dynamic adaptive seeds: on
     -> adversarial challenge (Codex+Gemini): on
   ```
   Pick "采用 (Recommended)" to accept (or override down to verify the off-paths). The
   display+override here is the DR-20260531 human-confirmation mechanism (replaces the old keystroke).

4. **Phase 0c -> Phase 1-3 -> Phase 4.** Let it run. With OBJECTIVES.md present, the Phase 4
   baseline seed tree runs (always, all tiers), and because `run_dynamic_seeds=on` the per-seed
   `step3_5` dynamic deepening + Step 2.5 adaptive seed generation fire. Target notebook resolves
   via `-n 37cfefa5-52b3-4a8a-a8e3-a83f32150759`.

5. **Phase 4c adversarial challenge** fires automatically (no keystroke) because
   `run_adversarial_challenge=on`. Codex + Gemini are both available (preflight #8).

6. **Findings saved** to `.tad/evidence/research/{slug}/{date}-ask-findings.md` with
   `research_complexity: complex` in the frontmatter (persisted for Phase 5).

---

## Gate-4 acceptance checks (Alex runs these AFTER the dogfood)

```bash
# (A) seed_origin fired at least once (the anti-paper-machine criterion)
grep -rl 'seed_origin' .tad/evidence/research/ | wc -l        # expect >= 1 (baseline was 0)

# (B) dynamic seeds specifically recorded
grep -rl 'seed_origin: dynamic' .tad/evidence/research/ | wc -l  # expect >= 1 if a sub-topic surfaced

# (C) adversarial challenge artifacts produced for this run
ls .tad/evidence/research/*/challenge-findings-r*-{codex,gemini}.md

# (D) complexity persisted in findings frontmatter
grep -r 'research_complexity:' .tad/evidence/research/ | tail -3

# (E) output quality vs baseline (manual read)
#     compare new findings file against:
#     .tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md
```

PASS = (A) returns >= 1 AND (C) lists challenge artifacts AND (E) is at least as rich as baseline.
If `seed_origin` still won't fire, the wiring failed -> Gate 4 FAIL (do NOT ship anyway — §10 anti-paper-machine).

---

## Notes

- Blake's portion (classification smoke + this dry-run-verified runbook) is COMPLETE.
  The live `*research-plan` execution + criteria (A)-(E) are **Gate-4-deferred** to Alex
  (validates user-facing behavior = Gate 4 v2 business acceptance). This is why the
  COMPLETION gate3_verdict marks AC4.4 as PARTIAL-by-construction.
- The dogfood doubles as a refresh of the 26-day-stale tad-evolution-research meta-notebook.
