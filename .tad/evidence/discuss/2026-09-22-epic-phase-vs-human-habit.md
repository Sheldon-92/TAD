# Discuss: Epic/phase machinery vs the human's "approved-Epic-then-thin-PM" habit

**Date:** 2026-09-22
**Mode:** Alex `*discuss` (OpenCode / `opencode-go/deepseek-v4.1-flash`)
**Status:** discuss record only — **not** a handoff, **not** READY_FOR_BLAKE, **not** a design doc
**Channel locks (this session):** NO edits to framework/product files · NO handoff · NO Blake · NO Gate run
**Human goal:** Gap analysis (technical; plain language to the human later via PM) of the habit below against what TAD already ships.

**A) Human dependency (2026-09-22, as stated):** after a goal is named, talk it clear with the human → turn it into a detailed multi-phase Epic (often 3–5 phases) that the human personally stares at/approves → **then** hand to a thin PM for step-by-step execution. Without a human-approved Epic, later quality and direction drift.

**B) In-scope TAD machinery (read, not invented):** `.tad/templates/epic-template.md`; Alex routes that create/promote Epics (`*analyze` / `*idea-promote` / `*design`); Phase Map + Phase Details (Scope/Input/Output/AC/Files); how multi-phase execution starts (who writes Epic, when Gate 2/handoff per phase, YOLO); any rule that an Epic must exist before implementation.

**Pack pointers (not loaded):**
- `ai-agent-architecture` — agent/workflow architecture decisions. Path: `.agents/skills/ai-agent-architecture/SKILL.md`. Do not load unless escalated.
- `agent-orchestration` — dispatch/checkpoint/HITL topology. Path: `.agents/skills/agent-orchestration/SKILL.md`. Do not load unless escalated.

**Local Wiki:** no prior canon on this exact comparison; this discuss opens no notebook.

**External context read (thin PM is outside TAD, not a TAD role):** `docs/pm/{intent,auth,acceptance,status,now,ops-knowledge}.md`, `docs/pm/restates/restate-2026-09-22-epic-phase-vs-human-habit.md`, `.tad/evidence/pm/*`.

---

## Verdict (one line, for human lock)

**PARTIAL** — TAD already ships the Epic artifact, the Phase Map/Phase-Details schema, human confirmation of the plan, per-phase Gate 2 + handoff, and stepwise (manual / semi-auto / YOLO) execution control; but it makes Epic creation **opt-in**, records **no persisted human-approval event**, defines **no execution-layer (thin PM) interface**, and offers a **full-YOLO path that bypasses per-phase human approval** — so the habit's *mechanics* are largely present while its *hard-requirement and auditability* are not.

---

## 1) What TAD already has (cite paths)

### 1.1 Epic artifact + schema
- `.tad/templates/epic-template.md` — `Owner: Alex`; Objective; Success Criteria; **Phase Map** table (`# | Phase | Status | Handoff | Key Deliverable`); Phase Dependencies; **Derived Status** (computed from the Phase Map, not stored); **Phase Details** per phase with exactly `Scope / Input / Output / Acceptance Criteria / Files Likely Affected / Dependencies / Notes`; `Context for Next Phase`; `Notes`.
- Live Epics: `.tad/active/epics/EPIC-20260816-framework-health-repair.md` (uses the full Phase Detail blocks, 4 phases) and `.tad/active/epics/EPIC-20260831-capability-builder-v1.md`.

### 1.2 Who writes / promotes the Epic
- **Alex writes it**, inside the `*analyze` front door, in `adaptive_complexity_protocol` **step2b "Epic Assessment"** (`.agents/skills/alex/references/adaptive-complexity-protocol.md:86-132`): internal signal check (2+ signals) → AskUserQuestion "创建 Epic / 单个 Handoff" → on "创建 Epic" Alex creates the file from the template, fills the Phase Map **and every Phase Detail block** (AC ≥3, ≥1 concrete file path), then AskUserQuestion to confirm Epic + Phase definitions, then creates Phase 1's handoff.
- `*idea-promote` (`.agents/skills/alex/references/idea-promote-protocol.md`): choose "Start as Epic (multi-phase)" → transitions into `*analyze`; step2b then fires naturally.
- `*design` (`.agents/skills/alex/references/design-protocol.md`): starts from Socratic results and ends at `step5 → *handoff`; it does not itself author the Epic — the Epic link is added at handoff time (1.3).
- Active-count cap: `max_active_epics` (default 3), checked in step2b and in `tad-maintain` Check 7 (`.agents/skills/tad-maintain/SKILL.md:246-247`).

### 1.3 Phase Map + Phase Details mechanics (the "glue" between Epic and handoff)
- `adaptive_complexity_protocol` **step2b_phase_detail_check** (`:134-156`): when continuing an existing Epic, Alex reads the next ⬚ Planned phase, runs a **sufficiency check** on its Phase Detail block (Scope ≥2 sentences; AC ≥3 each carrying a path/command/threshold/operator; Files ≥1 concrete `CREATE/MODIFY` path). Pass → Socratic reduced to **light** (2–3 Qs); fail → full Socratic.
- `handoff_creation_protocol` **step1 `epic_linkage`** (`.agents/skills/alex/references/handoff-creation-protocol.md:157-178`): finds the next ⬚ Planned phase, pre-fills handoff AC / §5 Files from the Phase Detail block, adds `**Epic:** EPIC-… (Phase N/M)` to the handoff header, flips the Epic Phase Map phase to 🔄 Active, and **BLOCKs** if another phase is already Active (concurrency control).
- `accept-command.md` **step2b_epic_update** (`:89-139`): on `*accept`, mark phase ✅ Done, update Phase Detail Status, write `Context for Next Phase`, and when all phases are ✅ → archive the Epic to `.tad/archive/epics/`; otherwise AskUserQuestion "start next phase?".

### 1.4 How multi-phase execution starts (Gate 2 / YOLO)
- Every phase still goes through **Gate 2** before its handoff (`.agents/skills/gate/SKILL.md:78-99`: mandatory, 6 items, before handoff, BLOCKING).
- `handoff_creation_protocol` **step7_execution_mode** (`:641-654`), trigger = "handoff passed Gate 2 **AND** handoff has an Epic field": AskUserQuestion **手动 / YOLO / 半自动**. Semi-auto = `pause_between_phases: true`; full YOLO = auto design→impl→review→accept, notify at end (`yolo-execution-protocol.md`; archives the Epic on completion).
- Blake is a separate terminal/role; Gate 3 (Blake) and Gate 4 (Alex `acceptance-protocol.md`) close each phase.

### 1.5 Any rule that an Epic must exist before implementation?
- **None as a general rule.** `epic_linkage` is explicitly conditional ("If an active Epic exists…"), and step2b lets the human pick "直接用单个 Handoff" (no Epic). A large task can therefore start with no Epic.
- The **one** hard exception: modifying `.tad/project-knowledge/principles.md` requires an Epic — `handoff-creation-protocol.md:180-188` ("Modifying it requires an Epic-level TAD flow… Either create an Epic first, or reclassify as an L2 pattern").
- `tad-maintain` Epic checks (STALE / OVER_LIMIT) are *maintenance* hygiene, not creation gates.
- L1 (`.tad/project-knowledge/principles.md`): Two-Agent + Four-Gate are principles; there is **no** "Epic is mandatory" principle.

### 1.6 Human approval points that do exist
- step2b step 3 AskUserQuestion: "Epic 和 Phase 定义如下，确认后开始 Phase 1" (plan confirmation).
- `accept` step2b step h: AskUserQuestion "Phase N 完成，开始 Phase N+1?" (stepwise continuation).
- That is the full extent of *human-in-the-loop on the plan*; there is no persisted approval record.

---

## 2) What the human habit adds / requires that TAD does **not** hard-require

| # | Habit requirement | TAD today | Hard-required? |
|---|---|---|---|
| H1 | **Human-approved Epic is a precondition** before any implementation | Epic is opt-in; triggered by internal signals + one confirmation; a large task may run as a single handoff | **No** (except `principles.md` edits) |
| H2 | Human **personally stares at / approves** the detailed multi-phase plan as a discrete artifact | Plan filled by Alex; one AskUserQuestion; no approval field/date/evidence on the Epic | **No** (no auditable approval) |
| H3 | A **thin PM** runs step-by-step execution after approval | No PM role inside TAD; the human is the Alex↔Blake bridge; Alex re-enters per phase; thin PM lives outside TAD (`docs/pm/*`) | **No** interface defined |
| H4 | Phase granularity expectation (**often 3–5 phases**) | Template shows 3 sample rows; no count rule | **No** |
| H5 | Drift prevention attributed to the **approved Epic** | Drift prevention attributed to Gates 1–4 + Socratic + per-phase Gate 2 | Different mechanism, same goal |

Note: `docs/pm/acceptance.md` states the thin PM's own rule — "派活：最短 prompt（角色 + `Follow TAD` + 已确认目标）；**不写步骤清单、不取代 TAD**" and "流程轻重：只选 TAD 已有档位". So the PM layer **claims not to replace TAD** — the gap is interoperability, not doctrinal opposition.

---

## 3) Concrete gaps (overlap / conflict / missing glue — especially thin-PM vs Alex-owned Epic)

### 3.1 Overlap (already covered — do not rebuild)
- Multi-phase planning artifact + Phase Detail schema (Scope/Input/Output/AC/Files) — `epic-template.md`.
- Human confirmation of the Epic before Phase 1 — step2b step3.
- Per-phase handoff + Gate 2 + Gate 3 + Gate 4 — `handoff-creation-protocol` / `gate` / `accept-command`.
- Stepwise execution control, including "pause each phase" — step7_execution_mode 半自动.
→ The habit's *shape* is already TAD-shaped; the deltas are about enforcement, evidence, and the PM seam.

### 3.2 Missing glue
- **M1 — No enforcement that a large/multi-phase task must first produce an Epic.** Signals can be missed; the human can choose "single handoff"; nothing blocks implementation. The habit's premise ("without the approved Epic, drift") has no mechanical backstop.
- **M2 — No persisted human-approval event on the Epic.** Confirmation is transient UI, not an artifact. `epic-template.md` has no `Approved by / Approved at / Approved scope` field, so "the human personally approved this plan" is neither recorded nor auditable, and a later phase change is indistinguishable from the approved baseline.
- **M3 — No phase-count / granularity guidance.** Nothing encodes "3–5 phases" or any rule that a phase be human-checkable; phase count is emergent from Alex's step2b fill.
- **M4 — No owner for inter-phase step-by-step bookkeeping.** After `*accept`, the next phase requires Alex to be manually re-triggered (accept step2b step h → "start next phase" → Alex designs again). TAD has no execution coordinator that drives phase N+1; this is precisely the job the thin PM performs outside TAD.
- **M5 — No bridge artifact between Epic state and the thin PM.**
  - TAD's phase status lives in `.tad/active/epics/EPIC-*.md` (Phase Map, derived status) and is updated by `accept-command`.
  - The PM's state lives in `docs/pm/{now,status}.md` and its checkpoints in `.tad/evidence/pm/*`.
  - Nothing defines that the PM reads/updates the Epic Phase Map, nor that Epic phase completion is the PM's trigger. **Two status ledgers can diverge** with no reconciliation rule (the same class of "two SSOTs" risk TAD already warns about elsewhere).
- **M6 — Role ambiguity for the human-facing summary.** TAD assigns the plain-language explanation to Alex (handoff step7 `人话版` + `plain_language_rules`); the task framing says "plain language later **via PM**". No rule says which one owns the human-facing narrative.

### 3.3 Conflict
- **C1 — Human-only bridge vs automated dispatch.** TAD: "人类是 Alex 和 Blake 之间唯一的信息桥梁"; Alex must not invoke `/blake` in the same terminal (handoff step7 forbidden). The thin PM auto-dispatches roles (oc-run / `muse-gb-wake`, `started.json`/`done.json` per `docs/pm/ops-knowledge.md`). TAD neither blesses nor forbids an external dispatcher acting *as* the human bridge; no rule states whether a PM dispatcher satisfies "human-triggered role switching".
- **C2 — Full YOLO contradicts the habit's gate.** step7_execution_mode offers full YOLO (auto design→impl→review→accept, notify at end) as a first-class option for Epic phases. The habit wants "human approves, then step-by-step execution (human checks each phase)". Semi-auto matches the habit; full YOLO is the habit's anti-pattern, yet TAD offers it on equal footing.
- **C3 — Frozen plan vs living roadmap.** The habit treats the approved Epic as a contract to execute. TAD explicitly allows mid-Epic mutation: `accept-command.md` `phase_adjustment` (add ⬚ Planned / remove / reorder) and the live Epic's "Epic 范围变更（人裁定 2026-08-17）" (`EPIC-20260816-framework-health-repair.md`). Both require a human, but TAD's default is *adaptive*, the habit's default is *frozen*.

### 3.4 thin-PM vs Alex-owned Epic (the named seam)
- **TAD ownership:** `Owner: Alex` on the Epic; Alex creates it (step2b), links each handoff (epic_linkage), and updates phase status on accept (accept step2b). The Epic is Alex's planning artifact.
- **PM ownership (outside TAD):** dispatch shortest-prompt per role, record Gate 2 / Layer2 / Gate 3 evidence on disk, report verdict `PASS / PARTIAL / CHECK_REQUIRED`, keep a status ledger (`docs/pm/acceptance.md`).
- **The seam is undefined.** PM does not write the Epic; Alex does not read the PM ledger. The PM is a *dispatcher + node verifier*, Alex is the *plan author + phase designer*. Both can be true simultaneously, but with no contract (M4/M5) the failure mode is: PM advances a phase the Epic still marks ⬚ Planned (or vice-versa), and "who decides the next phase, and from which source" is ambiguous.
- **Net:** not a doctrinal conflict (PM claims "不取代 TAD"), but a **missing interface** between two owners of "what happens next".

---

## 4) Options (no recommendation decided — human picks)

**A) habit-only**
- Keep the approved-Epic + thin-PM ritual as an external human habit; change nothing in TAD or the repo.
- Leaves M1/M2/M3 unaddressed (no enforcement, no approval evidence, no granularity rule) and leaves C1/C2/C3 as-is; quality depends on human discipline holding every time.

**B) write project intent**
- Record the habit as project-level convention only (candidate homes: `docs/pm/intent.md` / `docs/pm/acceptance.md`, `PROJECT_CONTEXT.md`, or a project `AGENTS.md` note), e.g. "multi-phase upstream programs → human-approved Epic (3–5 phases) → thin PM executes stepwise; prefer semi-auto over YOLO."
- No upstream framework change, no L1/gate change, no release. Addresses human-facing expectations but not M2 (no persisted approval) or M5 (no Epic↔PM bridge artifact).

**C) change TAD upstream**
- Make Epic-before-implementation a real precondition for large/multi-phase tasks; add an `Approval` field (+ date/scope) to `epic-template.md` and a corresponding Gate 2/`accept` check; define an explicit execution-layer interface (what an external PM/coordinator may read/write, and that Epic Phase Map is the phase-state SSOT); constrain or relabel full YOLO; add phase-count guidance.
- Highest leverage and directly closes M1–M6, but touches templates/gates/possibly L1 and therefore needs its own **Epic-level TAD flow + release** (human L3 per `docs/pm/auth.md`).

**D) hybrid**
- Do B now (project intent, cheap, reversible, records the convention), plus a later **docs-only** upstream knife (C-lite): e.g. add an `Approval` field + phase-count note to `epic-template.md`, and one L2 pattern entry on the Epic↔execution-layer seam — leaving gates, roles, and YOLO behavior unchanged unless the human escalates.
- Defers the enforcement question (M1) and the YOLO conflict (C2) while fixing evidence (M2) and the PM seam (M5) cheaply.

---

## 5) Verdict line

**PARTIAL** — TAD already has the Epic/Phase-Map/Phase-Details artifact and per-phase Gate 2 + stepwise execution control, but it treats the Epic as opt-in, records no human-approval event, defines no thin-PM↔Epic interface, and offers a full-YOLO path that bypasses per-phase human approval; the habit's mechanics are mostly present while its hard-requirement, auditability, and execution-layer seam are not.

---

## Explicit non-goals (this file)

- No handoff, no `*analyze`, no design doc, no Gate run, no Blake dispatch, no NEXT.md edit.
- No edits to `epic-template.md`, alex/blake/gate SKILL bodies, `principles.md`, templates, or `docs/pm/*`.
- No decision taken; Section 4 is options only. Human lock required before any follow-up knife.
