# Discuss: pstack / Lauren Tan verify-delta vs TAD (2026-09-10)

**Mode:** Alex `*discuss` / light research · **Status:** NOT READY_FOR_BLAKE  
**Sources:** this note vs `云同步/agent-workshop/docs/research/lauren-tan-pstack-trust-agents.md` (read-only) + current TAD Gate/handoff/AC conventions.  
**Aligned so far (human + GM + TAD PM; still partially pending human lock):** landing-tier runnable `verify:`; optional `*eval` as intent-shell later (Workshop); trust curve as method principle; do not borrow auto-merge / thick GM-PM / Dune-Grok / wholesale parallelism; extract only superior deltas.

**Verdict:** Take **one** TAD-native tightening — landing work cannot go Gate 3/4 green without a runnable `verify:` (command / path / fixture). Skip the rest of pstack’s orchestration/eval/product surface. We already have thin PM + serial Alex/Blake gates; the missing delta is **fail-closed verification on the cheap landing paths**, not a new manager layer.

---

## Take (do) — later, after human lock + `*analyze`

Concrete delta we lack: **prose AC still lands green on *bug, and §9.1 “must be a command” is protocol prose + advisory linter, not a Gate fail-close.** Formal handoffs already execute §9.1; empty §9.1 already BLOCKS Gate 3. The pstack-shaped win is to make “how do we know it worked?” a **typed, runnable field** on every landing that can ship.

| Landing | Current TAD | Take |
|---------|-------------|------|
| Formal `HANDOFF-*` / `*analyze` | §9.1 is Gate 3 PRIMARY source; empty → BLOCK. Template says Verification Method must be a runnable command. `step1d` dry-run is required in Alex protocol but **must not be a blocking hook**. `verify-ac-commands.sh` is **advisory, never blocks**. Dev-floor (missing tsc/test row) is **WARN not BLOCK**. | Add a **runnable `verify:` grammar** for every §9.1 row (command, evidence path, or fixture). Missing / prose-only → **cannot go green at Gate 3 and Gate 4**. Keep step1d + linter as smoke alarms; do not register hooks (Mechanical Enforcement Rejected). |
| `*express` | Uses full handoff + §9.1; may skip e2e; **must not** skip expert review (AR-001). | Same `verify:` as formal. Express may skip e2e **only if** a cheaper runnable check remains (grep / fixture / targeted test). |
| `*bug` mini-handoff | Template AC is checkbox prose: “bug no longer reproduces”. Explicitly skips Socratic **and** expert review (conflicts with express/AR-001 — separate known issue, not this delta). | **Highest-value take.** Mini-handoff must carry `verify:` (repro command, fixture, or failing-then-passing test). No `verify:` → not a shippable bugfix. |
| Light: `*discuss` / `*idea` / `*learn` | No Gate 3/4. This note itself is light. | May mark **`verify: N/A`**. Do not invent fake commands. |

**Later file/protocol surfaces (do not edit in this discuss):**

- `.tad/templates/handoff-a-to-b.md` §9.1 column contract + example rows
- `.claude/skills/alex/references/handoff-creation-protocol.md` `step1_ac_generation` + `step1d` (grammar of a legal Verification Method; still not a hook)
- `.claude/skills/alex/references/{bug,express}-path-protocol.md` (bug template is the hole)
- `.claude/skills/gate/SKILL.md` `Spec_Compliance_Verification` + empty guard; **extend** from “table non-empty” → “each landing row has runnable `verify:` or explicit N/A on light-only work”
- `.tad/gates/gate-canonical-checklist.md` Gate 1 “AC verifiable” + Gate 3 §9.1 + Gate 4 functional acceptance (same fail-close; Gate 4 must not accept on Blake summary if `verify:` never ran)
- `.tad/templates/acceptance-verification-guide.md` (Blake already: each AC needs a runnable verification)
- Dual-platform mirrors under `.agents/skills/` if those files change
- Optional later: one L2 line in `.tad/project-knowledge/patterns/ac-verification.md` once dogfooded — **not** a new L1 principle unless human wants trust-curve there

**Trust curve (take as METHOD PRINCIPLE, not a Gate):** do not expand parallelism / extra bots / unverified capability until the evidence chain for that capability has actually run. Encode later as judgment in Alex/Blake (and maybe `principles.md` if human wants L1). **Do not** add a mechanical Gate item, hook, or parallelism quota.

---

## Skip / rest

| Item | Why skip |
|------|----------|
| Auto-merge PRs / Benny night shift | Explicit anti-pattern: fake-green + skips human outcome acceptance. |
| Thicken GM/PM into chief-of-staff | Wrong layer. TAD already has thin PM + serial Alex→Blake→Alex. |
| Chase Dune / Grok Bot / Glass source | Not public SSOT; not our product. |
| Wholesale multi-agent parallelism copy | Conflicts with trust curve + existing serial gates. Outer PM may still run **multiple projects**; one TAD repo stays serial. |
| pstack `eval.md` / `create-verification-skill` / blind-eval harness | **Workshop later.** TAD may add optional `*eval` as **intent-shell only** (route, no tools). Pack-eval / judge bundles already exist for packs — do not duplicate into core Gates. |
| AI-friendly repo rewrite (Dune principles) | Workshop/docs later; not a TAD core patch. |
| pstack playbooks as a second orchestrator | We already have `*bug` / `*express` / Ralph / Gates. Do not clone playbook runtime. |
| Pretext / Electron virtualization | Irrelevant until we build that UI. |
| Making `verify-ac-commands.sh` or step1d a PreToolUse block | Violates “Mechanical Enforcement Rejected on Single-User CLI”. Fail-close belongs in **Gate 3/4 judgment**, not a deny-hook. |
| New `*eval` implementation in this discuss | Out of scope; Workshop. |

**Already covered (do not re-implement as “pstack features”):** AC-driven Gate 3, empty-§9.1 BLOCK, paper-acceptance VIOLATION, claims-need-carriers, Gate 4 independent recompute, dry-run discipline, honest_partial, serial two-agent + four gates.

---

## Open questions for human (max 5)

1. **Carrier:** Is `verify:` a **new frontmatter/one-liner** on every landing, or a **stricter grammar of existing §9.1 Verification Method** (no new field)?
2. ***bug vs AR-001:** When we add `verify:` to mini-handoffs, do we also **require ≥1 fresh reviewer** (align with `*express`), or keep bugfix review-light and only fail-close on the runnable check?
3. **Express + skip e2e:** Is a **grep/fixture** enough `verify:`, or must every express still have **one behavioral command** (test or repro)?
4. **Fail-close height:** Missing `verify:` = Gate 3 BLOCK only, or **also Gate 4** even if Blake marked PARTIAL with a story? (Aligned draft: both cannot go green.)
5. **Trust-curve home:** Judgment-only in skills, or a short L1 line in `principles.md` (Epic-level if L1)?

---

## Optional demand-draft outline (NOT READY_FOR_BLAKE)

- Outcome: landing tiers cannot Gate-3/4 green without runnable `verify:`; light tiers may `N/A`.
- Non-goals: no `*eval` tools, no auto-merge, no GM/PM thicken, no parallelism Gate, no hook enforcement, no version bump in that patch unless human later bundles it.
- Likely slices: (1) bug mini-handoff template + bug-path protocol; (2) §9.1/gate prose → “prose method = FAIL”; (3) express note that skip-e2e still needs a cheaper runnable; (4) dual-platform mirror; (5) one fixture that a prose-only AC cannot pass.
- Success: a planted prose-only bugfix handoff **fails** Gate 3; a grep/fixture `verify:` **passes**; `*discuss` with `N/A` unchanged.
- Status: **discuss only** — needs human lock on the five questions, then `*analyze` if we implement.

---

## Health (this activation, not part of the delta)

TAD Health: 3 active `HANDOFF-*` (none >14d zombie). Knowledge layered. `*publish` v2.44.4 handoff exists as READY_FOR_GATE2 (unrelated; do not absorb). Local Wiki: no pstack/verify-delta canon hit. Notebooks: 0 active. GitHub Registry scan 2026-09-04 still has pending candidates (not this discuss).
