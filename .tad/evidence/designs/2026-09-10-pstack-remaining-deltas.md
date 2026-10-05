# Discuss: remaining pstack→TAD deltas after verify-delta (2026-09-10)

**Mode:** Alex `*discuss` only · **Status:** NOT READY_FOR_BLAKE · **No *analyze** · **No skill/gate edits**  
**Prior:** `.tad/evidence/designs/2026-09-10-pstack-verify-delta-discuss.md`  
**Landed:** TASK-20260910-VERIFY-DELTA · commit `7048b835` · archived `{HANDOFF,COMPLETION}-20260910-verify-delta` · Gate 4 PASS (23/23 Methods from disk)  
**Workshop (read-only):** `../agent-workshop/docs/research/lauren-tan-pstack-trust-agents.md` + `docs/research/workshop-next-after-dogfood.md` (packs = thin / on-demand / freeze; principles stay upstream TAD; Workshop only pilots loading)

**Verdict:** After verify-delta, the **only remaining TAD-core take** that is still superior and not already protocol is **pack thin / on-demand / freeze** as an **upstream-principle candidate** (loader policy, not a new Gate). Skip wholesale parallelism / auto-merge / thick PM / Dune. Eval, AI-friendly repo, and playbook clones stay Workshop or already-covered. Do not ship another landing patch until a human locks the five questions — then `*analyze` if we implement.

---

## Already-covered (do not re-extract as “pstack”)

Landed in `7048b835` (grammar of §9.1, not a new `verify:` field):

| Delta from 09-10 discuss | Where it now lives |
|---|---|
| Landing cannot Gate 3/4 green on prose-only Methods | Gate SKILL `Spec_Compliance_Verification` + canonical + acceptance-protocol (`prose-only Verification Method = FAIL`; classify-before-execute; Gate 4 recompute from disk; Blake summary is not evidence) |
| `*bug` mini-handoff must carry a legal Method | bug-path: one-row `## 9.1`; skip Socratic + skip expert review **kept** (lock 2) |
| `*express` skip-e2e still needs a cheaper runnable | express-path `verification_floor` |
| Light `*discuss`/`*idea`/`*learn` may N/A | one-line notes; this file is light (`verify: N/A` — discuss inventory, no fake command) |
| Trust curve as **judgment**, not a checklist/L1 | `Trust_Curve_Judgment` in gate SKILL |
| `*eval` not in TAD core this patch | `EVAL_STUB_DEFERRED` (no `eval:` in alex SKILL) |
| No hook / no `principles.md` edit / no new frontmatter `verify:` | AC9/AC10/AC7–AC8 of that task |

Pre-existing TAD (not pstack, do not clone): serial Alex/Blake + four Gates; empty-§9.1 BLOCK; paper-accept VIOLATION; claims-need-carriers; Gate 4 independent recompute; dry-run; honest_partial; step4_5 max-2 pack load; YOLO L1 Rule Soup + behavioral-eval **action** (unenforced); knowledge-maintain retire signal.

---

## Take-later (TAD, after human lock + `*analyze`)

| Item | Why still a delta | Shape (not this discuss) |
|---|---|---|
| **Pack thin / on-demand / freeze** | Workshop 2026-09-10 lock: packs are **judgment docs that go stale**; strong models often already know; **upstream TAD owns the principle**; Workshop only pilots **loading**. TAD today has max-2 load + Rule Soup + retire **signals**, not a freeze/default-thin policy. | Candidate **L1** (Epic if L1) or **L2** in pack-build-rules + loader text. Freeze = rarely used / failed eval / “model already knows” — **human names the trigger**. Do **not** Cordis-ize pack prose; do **not** add a Gate item or hook. |
| **Optional `*eval` intent-shell** | FR9 deferred. pstack eval.md / create-verification-skill / blind-eval stay **Workshop**. | ≤20-line router: “send eval work to Workshop; TAD core runs no eval tools.” Or leave deferred. |
| **Trust-curve L1** | Method principle still only in gate SKILL. Prior Q5 unanswered as L1. | Promote to `principles.md` **only** if human wants Epic-level L1; otherwise leave judgment-only. |

Not a second verify-delta. Do not thicken Gates to “prove packs are thin.”

---

## Skip (reaffirm)

| Item | Why |
|---|---|
| Wholesale multi-agent parallelism | Conflicts with trust curve + serial repo gates. Outer PM may still run **multiple projects**. |
| Auto-merge / Benny night shift | Fake-green; skips human outcome acceptance. |
| Thick GM/PM / chief-of-staff | Wrong layer. Thin PM + serial TAD stays. |
| Dune / Grok Bot / Glass / Pretext | Not public SSOT; not TAD product. AI-friendly **repo conventions** = Workshop docs later, not a core patch. |
| pstack playbooks as second orchestrator | We already have `*bug` / `*express` / Ralph / Gates. |
| Blocking `verify-ac-commands.sh` / step1d as PreToolUse | Mechanical Enforcement Rejected. Fail-close stays Gate judgment. |
| Duplicating pack-eval / judge bundles into core Gates | Packs already have eval runners. |
| Reopening verify-delta locks (new `verify:` column; *bug ≥1 reviewer; hook enforcement) | Landed; do not unwind in this inventory. |

---

## Open questions for human (max 5)

1. **Pack principle home:** L1 in `principles.md` (Epic), L2 in `pack-build-rules.md` + loader, or **loader-only** (tighten step4_5 / freeze list, no new principle)?
2. **Freeze trigger:** usage-retire (`*knowledge-maintain`), human-named freeze list, or “strong model already knows” via a **Workshop** eval pilot — TAD does not invent a new eval harness?
3. **`*eval`:** leave `EVAL_STUB_DEFERRED`, or add the cheap intent-shell on a later slice (still no tools in TAD)?
4. **Trust-curve L1:** stay gate-SKILL judgment, or promote now that verification fail-close exists?
5. **Next TAD slice at all?** Pack-policy `*analyze` vs **stop extracting pstack** and let Workshop own eval + repo-friendly docs?

---

## Demand-draft (NOT a handoff)

- Outcome if Q1–Q2 lock “take packs”: one principle/pattern + loader freeze policy; Workshop remains the loading pilot, not a second pack SSOT.
- Non-goals: no parallelism Gate, no auto-merge, no PM thicken, no Dune, no skill/gate rewrite in this discuss, no absorb into v2.44.4 publish.
- Success: a reader can see **verify-delta closed the verification hole**; remaining superior delta is **pack lifecycle**, not another Method grammar.

**`verify:` N/A** — discuss inventory; no runnable landing.
