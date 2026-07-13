# Phase 1 Design Review — Backend / Systems Architecture

**Handoff:** HANDOFF-surplus-tad-self-test-agent.md (v3.1.0)
**Reviewer domain (auto-detected):** Files to Modify = 1 Workflow JS orchestrator + 1 bash verifier + text/jsonl fixtures. No `.tsx/.jsx/.css`, no auth/secrets → **default: backend / systems architecture review** (orchestration, verifier logic, data contract, blast radius).
**Date:** 2026-07-06
**Verdict:** CONDITIONAL — 2 P0 integrity gaps in the verification chain must be fixed before implementation.

> Note: the prior-round review at this path flagged spoon-fed agent prompts. That P0 has been
> **integrated** — the current handoff's FR2 is now "SKILL-driven, not spoon-fed" (prompts contain only
> a role pointer + fixture + runDir; AC15 forbids step enumeration). This review is against v3.1.0 as
> written and finds that the P0-1 *fix itself* introduced a new non-executable proof (P0-2 below).

**Grounding performed (not paper review):**

| Handoff claim | Verified against | Result |
|---|---|---|
| Harness globals meta/args/phase/agent/log/budget | `loop-discover.workflow.js` (full 149 lines) | CONFIRMED (L22-34 Object.keys, L96-97 budget guard) |
| Live trace vocabulary reused | `grep -ho '"type"' .tad/evidence/traces/*.jsonl` | CONFIRMED: gate_result(73) expert_review_finding(79) evidence_created(1275) handoff_created(968) task_completed(163) |
| Workflow JS can write files directly | grep fs/require/appendFile across all `*.workflow.js` | ABSENT — harness exposes NO fs/shell to workflow JS; all I/O forced through `agent()` (bears on P0-1) |
| AC14 RED `sed` target | `grep -nE socratic .claude/skills/alex/SKILL.md` | **DEFECT** — `target: socratic_inquiry` at L44 & L63 sit outside the sed range (starts L1064) → P0-2 |
| Greenfield / no collision | `ls .tad/eval/self-test` (absent), workflow file absent | CONFIRMED |

---

## P0 — Must fix before implementation

### P0-1: The deterministic verifier never inspects the artifact carriers — "evidence-based, not self-report" is not actually achieved.

The design promises (Intent §1.3, §10.1, R3) verification is *evidence-based* — trace events written
only when the agent return says a step happened **AND** `test -f` confirms the artifact. But the
deterministic layer, `verify-protocol-trace.sh` (§4.2 C), reads **only** `observed-trace.jsonl`. It
never independently `test -f`s the runDir carriers (`socratic-qa.md`, `synthetic-handoff.md`,
`review-*.md`, `completion-report.md`, the deliverable). Meanwhile the trace is **assembled by an LLM
haiku append-agent** (§4.2 A; harness constraint confirmed — workflow JS has no direct file I/O).

Net trust path: `LLM append-agent → trace file → deterministic grep`. If the append agent hallucinates
a `gate_3` line, or skips its `test -f`, the verifier prints a **false PASS**; if it drops a real
event, a **false FAIL**. The one mechanical stage validates the *claim file*, not the *carrier files* —
a direct violation of the project's `claims-need-carriers` principle. For a tool whose entire value
is trustworthy verification, putting an LLM inside the evidence-assembly boundary and never
cross-checking is the core architectural weakness. The harness constraint (agent-forced append) makes
an independent carrier re-check *more* necessary, not excusable.

**Fix:** give the verifier a carrier-based cross-check. For each expected step that has a carrier,
`test -f "$runDir/<carrier>"` directly and require BOTH trace line present AND carrier present — or
have the verifier re-derive the expected events from `ls "$runDir"` and diff that against the
LLM-written trace (any divergence = FAIL). Do not let an LLM-authored file be the sole ground truth.

### P0-2: The AC14 red/green drift proof — the very anti–Validation-Theater test added by the prior P0-1 fix — is non-executable as specified.

AC14 / FR2b is THE proof this tool can fail on injected drift. As written it cannot be demonstrated:

1. **`grep -c socratic = 0` is unachievable.** The prescribed mutation
   `sed '/socratic_inquiry_protocol/,/^# /d' alex/SKILL.md` deletes L1064→next `^# `. But
   `target: socratic_inquiry` (lowercase) appears at **L44 and L63** — routing targets far outside
   that range. After the sed, `grep -c socratic` still returns ≥2. Blake literally cannot meet the
   stated acceptance threshold with the stated command.
2. **The mutation may be ineffective (false GREEN).** The sed strips the protocol *body* but leaves
   the L44/L63 routing targets that point the agent at socratic_inquiry. A SKILL-driven agent (FR2's
   whole premise) may still run Socratic from surviving routing → socratic event still emitted →
   `SELF-TEST: PASS` on the RED run → drift NOT demonstrated → Validation Theater not disproven.
3. **Over-deletion.** The range also swallows `research_and_decision_protocol` (L1072) up to the next
   top-level heading, broadly crippling the RED agent — if it then produces nothing, *every* step is
   MISSING and "MISSING: socratic appears" passes for the wrong reason.

**Fix:** (a) Copy the SKILL and remove BOTH the protocol block AND neutralize the L44/L63 routing
targets; assert the mutation *semantically* (agent-facing socratic instruction absent), not via
`grep -c socratic = 0` which is polluted by unrelated tokens. (b) Re-anchor the RED assertion to the
behavioral *delta*: GREEN run dir has a socratic `evidence_created` line, RED run dir does not, and RED
verdict = `SELF-TEST: FAIL` + `MISSING: socratic`. Prove the delta, not a token count.

---

## P1 — Should fix (before Gate 3)

### P1-1: `evidence_created` conflation — implementation-drift is undetectable.

The contract (§4.2 B) maps `implementation → "type":"evidence_created" min 1`, but §4.3 emits **two**
`evidence_created` events: socratic (`"context":"socratic"`) AND the deliverable. `grep -cF
'"type":"evidence_created"'` counts both, so if the implement agent writes **no deliverable** but
socratic exists, `implementation` still counts 1 ≥ 1 → **false PASS**. AC14 only strips socratic, so
this masked-drift direction is never exercised. The single most important "work happened" step cannot
discriminate its own failure. **Fix:** give the deliverable a distinct discriminator (e.g.
`"context":"deliverable"`) and match on it, so socratic and deliverable count independently.

### P1-2: TAB-delimited contract has spaces inside fields; design never mandates `IFS=$'\t'`.

`expected-trace.txt` is `step_id<TAB>pattern<TAB>min_count`, but the pattern cell contains spaces
(`"context":"Gate 1`). §4.2 C never states the field split. A naïve `while read step pat cnt` uses
default IFS (space+tab) → `"context":"Gate` and `1` split apart → **every gate pattern** silently
mis-parsed and mincount mis-assigned. **Fix:** mandate `while IFS=$'\t' read -r step_id pattern
min_count` in §4.2 C, plus an AC that a space-containing pattern still matches.

### P1-3: The 9-step contract omits Knowledge Assessment — an explicitly BLOCKING gate step.

`CLAUDE.md` §3 规则5: "Gate 必须含 Knowledge Assessment (⚠️ BLOCKING)"; this handoff's own frontmatter
sets `skip_knowledge_assessment: no`. A tool whose intent (§1.3) is "assert **every mandatory TAD
step** happened" that silently drops a BLOCKING step has a hole exactly where drift is most dangerous.
**Fix:** add a `knowledge_assessment` row to `expected-trace.txt` (it is data, cheap), or document in
the contract why it is excluded from v1.

### P1-4: `SKILL_PATH_ALEX` / `SKILL_PATH_BLAKE` overridability is uncovered by any structural AC, yet AC14 depends on it.

FR2 adds these CONSTs; AC14 RED requires `SKILL_PATH_ALEX=<mutated copy>` to override. But AC2 only
asserts FIXTURE_PATH/EXPECTED_TRACE_PATH/RUN_ID as CONSTs + a bare `Object.keys(args)`. Nothing
verifies SKILL_PATH_ALEX is a CONST wired into the override loop. If Blake omits it from the loop, all
structural ACs pass and only the live AC14 fails — after implementation. **Fix:** extend AC2 to assert
`grep -cE "^const SKILL_PATH_(ALEX|BLAKE)"` ≥2 and that both appear inside the args override loop.

---

## P2 — Nice to have

### P2-1: `UNEXPECTED: gate_result` fires on every PASS run (noise that trains operators to ignore the channel).

`gate_result` carries 4 expected steps, but the contract references it only via `"context":"Gate N"`,
never the token `gate_result`. §4.2 C's UNEXPECTED rule ("observed type not in any expected pattern")
therefore flags `gate_result` as UNEXPECTED on every clean run — the single most-expected event
mislabeled. principles.md (2026-06-01) warns an 88%-noise gate trains the operator to ignore it.
**Fix:** build the "known types" set from the types the contract actually expects (add the underlying
`type` token to the gate/socratic rows).

### P2-2: Budget guard under-specified; NFR4 graceful-degrade untested.

AC7 only greps the substring `budget.remaining()`. In `loop-discover.workflow.js` (L96) the call is
guarded `typeof budget !== 'undefined' && budget && budget.total && budget.remaining() < 30000`; a
bare `budget.remaining()` throws when `budget` is undefined. Replicate the full `typeof` guard.
Separately NFR4's "partial result with `stopped_reason:'budget'`" has **no AC** (claims-need-carriers)
— add a structural AC (grep `stopped_reason`) or drop the NFR.

### P2-3: RED-test mutated SKILL lands in tracked `fixtures/`; expert-review distinctness + LLM-reported exit code are soft spots.

(a) AC14 writes `.tad/eval/self-test/fixtures/mutated-alex-SKILL.md`; `fixtures/` is NOT under the
`runs/*` gitignore → a stale mutated snapshot of a live protocol file gets committed. Generate it into
`runs/<run-id>/` or `/tmp` instead. (b) The verifier counts `expert_review_finding` events, not
distinct `"reviewer":` values (§8.3 documents it) — for a drift tool, two findings by one reviewer
would pass "min 2 experts" undetected; consider `sort -u` on reviewer names. (c) FR5 has a haiku agent
report the verifier `exit_code`/`stdout` — an LLM in a mechanical loop; acceptable only because the
persisted trace is re-run deterministically by Conductor (AC13/AC14), so ensure the Report verdict is
derived from that deterministic re-run, not the LLM stdout parse.

---

## What is well designed (keep)

- **Three-layer split** (workflow orchestrates / bash verifier is the testable core / fixtures discriminate) is the right architecture and lets Blake e2e-test the core today despite the sub-agent-can't-invoke-Workflow constraint. §11.1 rationale is sound.
- **Blast radius is excellent and contained**: new files only, sandboxed `runs/`, `.gitignore` for run artifacts, dual isolation defense (AC8 text-grep + AC13 runtime before/after `git status` diff), deliberate refusal to call `trace-writer.sh`. Exactly right.
- **`grep -F` fixed-string matching** + every capture `|| true` under `set -euo pipefail` is the correct macOS/BSD-portable, escaping-trap-free approach.
- **Contract-as-data** (min_count=2 on expert_review encoded as a data row, not code) lets the protocol contract evolve without touching the verifier.
- **Trace vocabulary reuse** verified accurate against live traces — good grounding discipline.

---

## Summary

Architecture and blast radius are strong (three-layer split, excellent sandbox containment). The two
P0s are not structural — they are **integrity gaps in the verification chain itself**, fatal for a tool
whose whole value is trustworthy verification: (P0-1) the deterministic layer never checks the real
carriers, so its PASS rests on LLM honesty in trace assembly; (P0-2) the one discriminative drift proof
(AC14, added by the prior P0-1 fix) is non-executable as written and may produce a false GREEN,
reopening the Validation-Theater risk. Fix both plus P1-1 (evidence_created conflation) and P1-2 (IFS
parsing) before implementation; P1-3/P1-4 are cheap contract/AC additions; P2s are polish.
