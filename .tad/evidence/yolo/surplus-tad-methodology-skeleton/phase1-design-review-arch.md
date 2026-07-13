# Phase 1 Design Review — Architecture Lens

**Handoff:** HANDOFF-surplus-tad-methodology-skeleton.md (v3.1.0)
**Reviewer:** Architecture (default; auto-detect found 0 frontend / 0 API-DB / 0 auth files → backend-architecture lens, adapted to a doc-only verification-design review)
**Date:** 2026-07-06
**Scope:** architecture quality, blast radius, design completeness
**Verdict:** CONDITIONAL PASS — design is sound and blast radius is minimal; the weaknesses are all in the **verification layer** (the AC suite under-enforces its own FRs), not in the design. None block a P2 doc-only task, but two are worth fixing before Gate 3 to prevent a false-PASS.

---

## Blast radius assessment — LOW (good)

- Single new file `docs/tad-methodology.md`; zero framework/skill/CLAUDE.md/README changes (NFR4).
- No code, no scripts, no network, no deps. AC8 (`git status --porcelain` minus allow-list) mechanically fences change scope.
- Grounding sources are read-only; MQ5 correctly shows single-store (no dual-write / sync surface).
- Handoff claim "docs/ = 43 git-tracked files" VERIFIED (`git ls-files docs/ | wc -l` = 43). Target file confirmed ABSENT (no collision).

This is a well-contained deliverable. The design itself (§4.1 structure, §4.2 source-to-section map, §5 MQ coverage) is complete and traceable.

---

## Findings

### P1-1 — AC3 vocabulary sweep does NOT enforce FR1's substitution mandate (verification gap)
FR1 explicitly requires replacing `code review → deliverable review`, `codebase → body of work`, `tests pass → acceptance evidence`. But AC3's forbidden regex is only `source code|pull request|unit test|compile|repositor|git |CI/CD` — it does **not** include `codebase`, `code review`, or `code-specific`.

Empirically verified: a core section containing "codebase", "code review", and "tests pass" returns **AC3 = 0 (PASS)**.

```
core text: "This uses the codebase and code review heavily. tests pass here."
AC3 output: 0   ← passes, yet violates FR1
```

The domain-agnostic core is the entire point of the deliverable (FR1/FR4/NFR2). Gate 3 executes each §9.1 row as PRIMARY verification, so a document that violates the deliverable's core promise can pass Gate 3 mechanically. This is precisely the project's own documented failure class ("A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover Loss" / verification scoped wider than the must-cover property).
**Fix:** extend the AC3 regex to the full FR1 term list (`codebase|code[- ]?review|code-specific` etc.), OR add a positive check that the FR1 generic substitutes appear. Keep the judgment-level "reads like it's for non-developers" check at impl-review, but do not let the mechanical AC claim to cover FR1 when it does not.

### P1-2 — The self-identified highest-omission-risk concept has NO mechanical guard
AC2 greps for `Solution Lead, Execution Master, Gate 1, Gate 4, handoff, knowledge`. It does **not** verify:
- FR2.6 **Judgment Domain Awareness** — which the handoff's own Project Knowledge section (lesson #2) flags as "最新的 L1 原则，容易被漏掉" and names as the empirical basis for the whole non-dev extension;
- FR2.2 **Human Bridge**;
- the **Capture/Distill** separation (FR2.5).

A document that omits the judgment-domain section entirely passes AC1–AC8. The handoff explicitly identifies this concept as the top drop-risk, then leaves it unverified. That is an inconsistency between the risk register and the acceptance suite.
**Fix:** add AC2 terms `Judgment` / `human-domain` / `choice` (verification not rubber-stamp) and `Human Bridge` / `Capture` / `Distill`, each `grep -ci ≥ 1`. Cheap and closes the gap the handoff itself raised.

### P2-1 — AC3 gives a FALSE-PASS on heading-anchor drift
When the exact heading `## Worked Example: Voice/Podcast Production` is reworded, `awk` never hits its exit pattern and prints the **whole** document; since audio-domain terms aren't in AC3's forbidden list, AC3 still returns 0. Verified:
```
anchor reworded → AC3 output: 0   ← false PASS on the exact drift §10.1 warns about
```
Cross-AC coverage saves it: AC6 (`grep -cx '## Worked Example...'`) independently catches drift. So the SUITE is sound, but **AC3's output alone is not trustworthy** — a reviewer reading AC3=0 in isolation would be misled. Note this dependency explicitly (AC3 is only meaningful when AC6 = 1).

### P2-2 — AC4 verifies gate *mentions*, not FR3's mapping *structure* or the AI/human split
AC4 checks `gates:4` + `brief:≥1`. A single prose paragraph naming the four gates once each satisfies it. FR3's load-bearing requirements — **≥5 mapping rows** (table/list) and the **"Who judges (AI/human)" column** demonstrating Gate 3 = AI-domain vs Gate 4 = human-domain choice-questions — are unverified by any AC. The judgment-domain demonstration is the pedagogical payload of the worked example, and nothing mechanical guards it.
**Fix:** add a row-count check (e.g. count table rows after the anchor, `≥5`) and a `grep -ci 'human'`/`'AI'` presence check inside `/tmp/we.md`.

### P2-3 — Grounding-file absence is a mitigated process deviation
The yolo-epic Conductor contract expected `.tad/evidence/yolo/surplus-tad-methodology-skeleton/phase1-grounding.md`; it was absent and Alex substituted direct reads (§7.3) + dry-runs. This is handled transparently with a STOP-and-flag instruction (§10.1), so it is not a blocker — but the design stage ran without the intended grounding artifact, a latent workflow gap that can recur silently on future surplus-generated phases. Worth a one-line note to the Conductor to confirm whether the grounding step was skipped by design or by omission.

---

## What is solid (no action)
- §4.2 gives a clean 1:1 source→section distillation map; §5 MQ3 coverage table is honest about what's OUT (repo implementation details).
- AC6/AC7/AC8 are correctly written and runnable (verified: awk anchor, `grep -cx`, scope grep all execute as written under the pipe-unescaping rule).
- Distill-not-copy constraint (NFR3) correctly anchored to the "Knowledge Is Forged at Distill" principle; the curse-of-knowledge risk of rewriting TAD-OVERVIEW is correctly rejected in §11.
- Change isolation and single-store data model leave essentially no integration risk.

## Bottom line
Design and blast radius: PASS. The AC suite is where the design is incomplete — AC3 under-enforces FR1 (P1-1) and the highest-flagged concept is unguarded (P1-2). Both are 1–2 line regex additions. Recommend Blake (or the Conductor review stage) tighten AC3's term list and add the judgment-domain/human-bridge greps to AC2 before Gate 3 runs, so Gate 3's PASS actually means the deliverable met FR1/FR2.6.
