---
gate: 2
round: 2
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
handoff_status: Ready-for-Gate2-rereview
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
prior_round1:
  scope: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-scope.md
  spec: .tad/evidence/reviews/2026-09-08-gate2-review-knowledge-seam-spec.md
reviewer: Independent Gate 2 Round2 scope reviewer (not the handoff author)
date: 2026-09-08
channel: opencode
model: opencode-go/muse-spark-1.3-contributor
scope: prior-P0 closure verification, human-lock preservation, new-P0 scan
counts: {P0_closed: 6, P0_new: 1, P1: 3, P2: 2}
verdict: FAIL
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only, no auto quarantine on update"]
---

# Gate 2 Round2 Independent Scope Review — HANDOFF-20260908-knowledge-seam-isolation

## Independence & method

- Independent reviewer; no handoff authorship. Read-only review except writing this file. No implementation.
- Read: handoff (362 lines, full), design note (220 lines, full), `principles.md` (L1, full),
  `patterns/_index.md` + three pattern files (`release-sync.md`, `ac-verification.md`,
  `shell-portability.md`), both Round1 reviews (scope FAIL 3 P0, spec FAIL 5 P0).
- Executed (all read-only): `grep -n TOP_DENY` (both files + consumers), full `grep -m1`
  site census in `brain-index-gen.sh`, `grep -A 52` window probe on `.tad/brain-index.md`,
  `awk '/## Step 6: Finalize/,/## [A-Z0-9]/'` range probe on the live protocol file,
  `tad.sh` anchor spot-checks (CLI parser, install/upgrade/migrate README lines,
  `copy_framework_files` loop), mirror existence + `release-verify.sh parity` baseline.
- Human locks respected as constraints, not re-opened: ①A pure isolation, ②quarantine
  opt-in only. Findings tighten handoff text only; no redesign proposed.

## Gate 2 checklist mapping (canonical)

| Item | Status | Note |
|------|--------|------|
| Expert review complete (min 2) | ⚠️ Partial | Round1 had 2 (scope + spec). This is Round2 review #1; a spec re-review is still needed before Blake start |
| All P0 resolved | ❌ Fail | All 6 unique prior P0 CLOSED, but 1 NEW P0 open (NEW-P0-1, AC6.1 unsatisfiable) |
| Architecture complete | ✅ Pass | Design §3.1–3.4 intact; locks preserved |
| Components specified | ✅ Pass | §1 Target Files now enumerates 11 files incl. both trees + CLI + tad-maintain (P1-1 closed) |
| Functions verified | ❌ Fail | NEW-P0-1: AC6.1 verifier is a structural false-FAIL (see below) |
| Data flow mapped | ✅ Pass | Unchanged from Round1 |

## Prior-P0 closure (all 6 unique P0 CLOSED — verified against handoff text)

| # | Prior P0 | Resolution in amended handoff | Evidence | Status |
|---|----------|-------------------------------|----------|--------|
| 1 | Scope P0-1: AC1 vacuous (`--verify-denylist` never reads TOP_DENY) | §3 Task 1 + §9.1 AC1.1–1.4: representation greps in BOTH files + behavioral `derive_framework_top_files` probe (excludes `brain-index.md`, still excludes `sync-registry.yaml`, includes `version.txt`); `--verify-denylist` demoted to companion (AC1.5) | Handoff L98–120, L298–302 | **CLOSED** |
| 2 | Scope P0-2 / Spec P0-2: `TAD_TOP_DENY` scalar-equality trap | Multiline deny mandated in both files + set-membership consumer `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn" && continue` + `tad.sh:592` comment fix + sibling-pin ACs | Handoff L98–115, L300–301; live baseline confirms trap exists (`tad.sh:566/599`, `derive-sync-set.sh:77`) so the fix targets real code | **CLOSED** |
| 3 | Scope P0-3 / Spec P0-3: quarantine clobbers sanctioned `README.md` | Task 5 NEVER-move-README + strict `project-knowledge/` scope; §4 AC4(a); §9.1 AC4.3 asserts README byte-identical | Handoff L191, L204–209, L227, L309 | **CLOSED** |
| 4 | Spec P0-1: missing §9.1 (Gate 3 Empty Guard hard block) | Full 6-column §9.1 table present: AC1.1–AC8.3 with Verification Type / Method / Expected Evidence / step1d baselines | Handoff L294–316 | **CLOSED** |
| 5 | Spec P0-4: no `tad.sh --quarantine-pk` CLI wiring | Task 4 CLI parser + `show_help` + dispatch; §4 AC4(e); §9.1 AC4.1–4.2, AC4.4 | Handoff L152–161, L231, L306–310; live `grep -n quarantine tad.sh` = 0 hits confirms greenfield wiring | **CLOSED** |
| 6 | Spec P0-5: missing Required Evidence Manifest | §7 YAML manifest with 2 evidence files + required_sections | Handoff L263–280 | **CLOSED** |

Human-lock preservation: Option A + opt-in encoded in §1 Out of Scope (L53–55),
Forbidden (L56–61), §4 AC8 (L235–238), §9.1 AC8.1–8.3 (L314–316), §6 Decision Log
(L256–259). Provenance machinery explicitly out-of-scoped (Round1 P1-6 closed).
No lock re-opened. ✅

## NEW P0 findings (blocking — handoff-text fix, then re-run Gate 2)

### NEW-P0-1 — §9.1 AC6.1 verifier is a structural false-FAIL (end pattern matches start line)

- **Claim in handoff (§9.1 AC6.1):**
  `awk '/## Step 6: Finalize/,/## [A-Z0-9]/' ... | grep -F "brain-index-gen.sh"`
- **Evidence (executed on live host, read-only):**
  - `awk '/## Step 6: Finalize/,/## [A-Z0-9]/' .claude/skills/alex/references/distillation-loop-protocol.md | wc -l` → **1**
    (only the heading line itself; trigger lines 57–61 never in range).
  - Root cause: the end pattern `/## [A-Z0-9]/` ALSO matches the start line
    (`## Step 6: Finalize` — `S` ∈ `[A-Z0-9]`), so the awk range collapses to a
    single line. This is the exact failure class Round1 P1-8 warned against
    ("range expressions whose end pattern can match the start line … never
    `/start/,/end/` where end can match start", `ac-verification.md` 2026-08-03 entry).
    The amend implemented the forbidden form.
- **Consequence:** AC6.1 can NEVER pass: a correct Blake implementation (trigger between
  `## Step 6` and `## Step 7`) still FAILs the extractor, because the extractor only
  ever sees the heading. Gate 3 would BLOCK good work — an unsatisfiable AC, the
  `node --check`-on-workflow false-gate class (2026-06-07/06-14 entries).
- **Required fix (handoff-text only, one line):** replace with the stateful form
  Round1 P1-8 already prescribed — start AFTER the heading, stop at the next heading:
  `awk 'f&&/^## /{exit} /^## Step 6: Finalize/{f=1;next} f' <file> | grep -F "brain-index-gen.sh"`,
  mirrored for both trees. Dry-run it post-fix: must FAIL at baseline (no trigger yet —
  verified: `grep -n brain-index` on both protocol files = 0 hits) and PASS on a
  simulated correct insertion.

## P1 findings (advisory — fix alongside NEW-P0-1; re-check at Gate 3)

### P1-1 — §9.1 AC3.2 count pattern matches every line + content half unverified

- `grep -A 52 "## Archived Handoffs" .tad/brain-index.md | grep -c "^\| HANDOFF-"` → **22**,
  equal to total window lines (22): in BRE, `\|` is alternation, so `^` matches every line
  (+3 header/separator inflation). The `≥50` threshold still discriminates on this host
  (stale 22 → fresh ~53), so this is NOT a new P0 — but (a) fix the pattern to
  `grep -c "HANDOFF-"`, and (b) the "non-empty task_type and summary" half of Expected
  has ZERO executable coverage (no assertion against empty cells / `(see file)` fallback).
  Add a content assertion (e.g. fail on `|  |` empty cells).

### P1-2 — §9.1 AC4.3 and AC6.2 methods are prose, not literal commands

- AC4.3 ("Synthetic fixture test: …") and AC6.2 ("Test `tad doctor` on stale …")
  state assertions without runnable commands. Gate 3 executes Verification Methods
  verbatim — prose methods are not executable. Promote each to a literal
  fixture-based script (mktemp-dir quarantine fixture; touch-stale + `tad doctor`
  exit-0 + warning-text assertion) before Blake start. (Carryover of Round1 P1-4/P1-7
  remainder; the schema/idempotency/WARN-only CONTENT is now specified, only the
  literal-command form is missing.)

### P1-3 — Task 2 line numbers drifted slightly from live file

- Handoff cites L98/136/156/174/177/212/251; live census shows the first site at L94
  (plus a `grep '^ *- '` site at L228 the sweep should explicitly include or exclude
  with reason). The "wrap ALL vulnerable sites" mandate covers the drift, but re-pin
  the numbers and state the disposition of L228 so Blake's sweep is exact.

## P2 nits

- **P2-1:** Task 2 says "all 7 sites" then lists 8 numbered bullets (7 grep sites + 1
  find-grouping fix). Reword to "7 grep sites + 1 find-precedence fix" to remove the
  self-contradiction.
- **P2-2:** Upgrade/migrate README preservation uses create-only-if-absent (L168–174).
  Acceptable for a framework-owned seed (closes Round1 P2-2); no further action.

## No-Gate-hard-journal check — PASS (unchanged)

- Forbidden (L57–58) still bans per-ticket journal and `brain-index.md` freshness as
  Gate 3/4 PASS requirements; §9.1 AC8.2 + Task 3 WARN-only freshness (L144–148)
  keep triggers soft. Aligns with L1 "Knowledge Is Forged at Distill" and design §3.4.

## Verdict

- **VERDICT: FAIL** — all 6 unique prior P0 CLOSED and both human locks intact, but
  **1 new P0 (NEW-P0-1)** blocks: §9.1 AC6.1 as written can never pass on a correct
  implementation.
- **To pass re-review (Round3):** apply the NEW-P0-1 one-line awk fix (+ P1-1 pattern
  and content assertion, P1-2 literal commands, P1-3 line re-pin), dry-run every
  touched AC command on this host (GOOD must pass / BAD must fail-cleanly for the
  right reason), then request the second Gate 2 review (spec re-review, canonical
  min-2 rule) before flipping to Blake start.
- **Explicit non-reopen:** Option A pure isolation + quarantine opt-in-only confirmed
  correctly encoded. Do not relitigate.
