Model: harness=other | model=cursor-grok-4.6-medium | route=host

---
gate: 2
handoff: HANDOFF-20260913-skill-authoring-habits.md
reviewer: Reviewer A — Spec & Pathspec (independent; not Alex, not Blake)
date: 2026-09-13
verdict: PASS
counts:
  P0: 0
  P1: 0
  P2: 1
delta_recheck: true
---

# Gate 2 Review A — Spec / Pathspec / AC realism (delta recheck)

**Handoff:** `.tad/active/handoffs/HANDOFF-20260913-skill-authoring-habits.md`  
**Prior report:** same path; first pass **FAIL P0-1**. This overwrite is delta-only.  
**NO Gemini.** No implement of the three authoring files. No commit/push.

HEAD still `86c89917` `docs(p2-sc4): wire process-tax-cut…` (not this knife). Authoring targets still unmodified.

---

## P0-1 status: CLOSED

Prior P0-1: AC12/AC13 HEAD-relative, AC13 inverted (`exit 1` = good), unix-PASS on unmodified HEAD.

**Integration on disk (handoff §9.1 rows 12–13, FR7, §5 step 6, Blake-done line):**

- Identity: `ok_id = 'SKILL-AUTHORING-HABITS' in HEAD subject`
- Known-GOOD polarity: `SystemExit(0 if ok_id and … else 1)` — same as AC7–11
- AC12: nonempty `names` ⊆ four §6.2 paths **and** `ok_id`
- AC13: `ok_id and not hits`; without `ok_id` fails as not-this-knife even if `hits` is nonempty
- FR7 / step 6 / “Blake is done” cite **§6.2**, not §7 evidence manifest
- AC10: `found=False` + trailing `raise SystemExit(1)` if bullet missing

**This-reviewer raw replay of table Methods (cwd repo root):**

```
AC12: SUBJ=docs(p2-sc4): … TASK-20260912-P2-SC4-TAX-CUT-WIRE
      12 names (not ⊆ §6.2); exit 1
AC13: SUBJ=…TAX-CUT-WIRE
      ok_id false; HITS=[four process-tax-cut* paths]; exit 1
```

Matches Alex dry-run (HEAD `86c89917`, both exit 1, right fail: **not this knife**). Known-GOOD is exit 0 only after a commit whose subject contains `SKILL-AUTHORING-HABITS` and whose names ⊆ §6.2 / have no forbidden classes.

Vacuous check: unmodified repo does **not** unix-PASS AC12 or AC13.

---

## 1. Critical Issues (P0)

None. P0-1 CLOSED.

---

## 2. Major (P1)

Prior P1-1 (§7.2 vs §6.2) and P1-2 (AC12/13 not in dry-run) **closed** by the same amend.

---

## 3. Minor (P2)

### P2-1 — §5 step 1 still says `git status` vs §7

Step 6 / FR7 / AC12 are §6.2. Step 1 still points at §7 (evidence manifest). Does not restore inverted ACs. Blake should treat step 1 as status vs **§6.2**. Non-blocking.

---

## 4. Per-check table C1–C5 (delta)

| Check | Result | Note |
|-------|--------|------|
| **C1** | **PASS** | Methods still legal commands. AC12/13 now fail unmodified for identity (`ok_id` false), exit 1. AC10 fail-closed if bullet missing. |
| **C2** | **PASS** | Unchanged: one-line `_index` hunk, four skillify bullets, append-only `###`. Pathspec §6.2 aligned with FR7. |
| **C3** | **PASS** | AC8/9 regex unchanged; last-heading still OK. |
| **C4** | **PASS** | AC12/13 no longer unix-PASS on `86c89917`. |
| **C5** | **PASS** | Live AC12/13 match the rewritten dry-run log. |

---

## 5. Dirty-tree adjudication (brief)

Contract has no whole-tree clean fence. Dirt outside §6.2 = **FALSE_POSITIVE** (pre-existing).

| path class | label | pointer |
|------------|--------|---------|
| `NEXT.md`, `PROJECT_CONTEXT.md`, `docs/pm/now.md`, `.tad/brain-index.md` | FALSE_POSITIVE | §6.3 / §10 |
| leftover publish twins v2443/4/5, knowledge-seam / verify-delta / p2-sc4 D+M | FALSE_POSITIVE | leftover twins; do not absorb v2.44.5 |
| `.tad/eval/judge/bundles/*` | FALSE_POSITIVE | §6.3 judge bundles |
| `?? HANDOFF-20260913-skill-authoring-habits.md` | in-delta untracked | expected; not a cleanliness P0 |
| three authoring files | unmodified | expected pre-Blake |

---

## 6. Overall verdict

**PASS** — **P0=0**, P1=0, P2=1 (step 1 §7 leftover).

**P0-1 CLOSED** with replay evidence: AC12 exit 1, AC13 exit 1, `ok_id` false on HEAD `86c89917`.

Process Gate 2 still needs Reviewer B on disk as well; this file is Reviewer A only.
