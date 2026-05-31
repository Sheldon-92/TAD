# Backend-Architect Review (POST-IMPL / Round 2) — research-gate-phase6

Blue-team architecture review of the IMPLEMENTATION (commit 7d41768) on worktree
`agent-a1f27b5a3c27bcf16`. Round-1 P0 was the 4-site double-prompt; this round
verifies the `declined_research_domains` shared-set fix actually closes it.

Reviewer: backend-architect
Date: 2026-05-31
Artifact: `.claude/skills/alex/SKILL.md` @ 7d41768
Sites: research-gate (L2730-2774), STEP 3.8 append (L212-214),
research_notebook_awareness step4c (L921-924), read sites (L2753-2758),
step2_5_notebook_check (L2798-2810).

(Round-1 PART A pre-impl review preserved at `backend-architect.md`.)

---

## Verification of the 4 review questions

**Q1 — Does the gate READ the declined-list AND check the prior-surface, and do
the OTHER sites WRITE the same-named set?**
- READ: research-gate check #1 (L2753) reads `declined_research_domains`
  membership; check #2 (L2754-2755) reads the STEP 3.8 / awareness prior-surface.
  Both reads present, both run BEFORE the AskUserQuestion fires (L2760-2762).
- WRITE: STEP 3.8 step6 (L213) appends on decline; awareness step4c (L922)
  appends on decline; research-gate's own two non-create options (L2765-2766)
  append. All three write the **same-named** set. Read key == write key.
  Cross-`*discuss→*analyze` dedup for the DECLINE path is real. PASS.

**Q2 — Decidability classification default-safe (ambiguous → silent)?**
- L2743-2747: "YES, **or AMBIGUOUS** → stay silent (NO gate)," anchored to the
  Phase 4 "default to the lower tier" precedent. Only a provable external-fact
  dependency (L2748-2750) is ELIGIBLE. Default-safe. PASS.

**Q3 — Reuse step2_5's REGISTRY result, or sneak a second lookup?**
- L2756-2758 explicitly says "REUSE step2_5_notebook_check's REGISTRY lookup
  result (do NOT run a second independent REGISTRY scan)." Intent correct — but
  the reused result does not exist at gate-execution time (see P1-1).

**Q4 — Architectural inconsistency (read-without-write / key / granularity)?**
- `declined_research_domains` itself is symmetric (read==write). But the gate's
  SECOND read predicate (prior-surface) has no backing written set (P1-2), and
  the REGISTRY-reuse is temporally inverted (P1-1).

---

## P0 (blocking)

**None.** The round-1 P0 — three independent nudge sites double-prompting the
same domain — is genuinely closed for the *declined* path: all three sites
append to one shared, identically-named, same-session set, and the gate reads
that set before prompting. Dedup is real, symmetric, conversation-scoped.

---

## P1 (should fix)

**P1-1 — REGISTRY-reuse references a result that doesn't exist yet (temporal
ordering bug).** Research-gate runs at the TAIL of `step1_identify_decisions`
(L2732: "before step2_research"). Protocol order is `step1 → [research-gate] →
step2_research (L2777) → step2_5_notebook_check (L2798)`. step2_5 is the step
that performs the REGISTRY lookup (L2803), and it runs AFTER the gate. So check
#3's "REUSE step2_5's REGISTRY lookup result" (L2756-2758) consumes an output
that has not been produced. Likely runtime behavior: the agent performs the
REGISTRY scan itself at gate time — exactly the "second independent REGISTRY
scan" the line forbids. Intent (single lookup) is right; the wiring points
backward in time. Fix: reword check #3 to "perform the REGISTRY lookup HERE and
have step2_5 reuse THIS result," or introduce a one-time `notebook_lookup_cache`
populated at first touch and consumed by both. Cross-ref project-knowledge
"Sufficiency Check Must Precede the Step It Influences" (2026-05-14).

**P1-2 — Prior-surface read (check #2) has no backing written set — asymmetric
read.** Check #2 (L2754-2755) asks whether STEP 3.8 / awareness already
**surfaced** a notebook-gap for this domain this session. "Surface" is distinct
from "decline." The other two sites write to `declined_research_domains` only
**on decline** (L213, L922) — they never record domains they merely surfaced
(prompted) but the user has not yet answered. grep confirms no
`surfaced_research_domains` set exists. So check #2 has no authoritative state to
read beyond what check #1 already covers, plus unstructured conversational
recall. Residual window: if STEP 3.8 surfaces domain X and the gate reaches X
before the user answers, check #2 can re-prompt X — a narrower instance of the
very double-prompt this Epic targets. This is the read-without-matching-write
inconsistency from Q4. Fix: either add a sibling `surfaced_research_domains`
written at every nudge-EMISSION point (not just on decline), or drop check #2
and reword L2754-2755 to not imply a backing set.

---

## P2 (nice to have)

**P2-1 — "four nudge sites" comment vs three writers.** L2738-2739 claims the
set is shared so "the **four** nudge sites never double-prompt," but only three
sites append (L213, L922, L2765-2766). The round-1 review counted four
SURFACING sites (STEP 3.8 landscape vs objective-alignment sub-paths), but only
one append exists for STEP 3.8. Reconcile the number or name the four sites, to
avoid the count-vs-reality drift flagged in the 2026-05-31 `grep -c` SAFETY
lesson.

**P2-2 — Set lifetime / reset semantics undefined.** Declared "conversation-
scoped, lives for this *discuss→*analyze session" (L2736-2737) with no statement
of WHEN it resets (new *analyze? compaction? day boundary?). A session spanning
a compact may lose the set and silently re-prompt. Acceptable (suggestion-only)
but should be stated. Pairs with "Two-Layer Compact Recovery."

**P2-3 — "domain" granularity undefined.** Dedup keys on "this decision's
domain" / "this topic's domain" but "domain" is never defined and matching is
LLM-semantic, so two sites may label the same concern differently and still
double-prompt. One-line definition or examples would make dedup deterministic.

---

## Overall

**ACCEPT WITH FOLLOW-UPS (no P0).** Round-1 P0 (4-site double-prompt) is
substantively closed for the decline path: one shared, same-named set written by
all three nudge writers and read by the gate before prompting; classification is
correctly default-safe (ambiguous → silent). Two P1s remain, both correctness-
of-dedup (not safety) and neither stops the flow (gate is suggestion-only):
P1-1 the REGISTRY-reuse instruction points at a later-running step, so the
single-lookup guarantee isn't wired and may regress to a second scan; P1-2 the
prior-surface read predicate has no backing set written at surface-time, leaving
a narrow pre-answer re-prompt window. Recommend fixing P1-1 (reorder/cache the
lookup) and P1-2 (add surfaced-set or drop check #2) before merge; P2s are
cleanup.
