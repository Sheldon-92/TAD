---
gate: 2
handoff: .tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
design: .tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md
reviewer: Independent Gate 2 scope reviewer (not the handoff author)
date: 2026-09-08
channel: opencode
model: opencode-go/muse-spark-1.3-contributor
scope: scope, blast radius, AC completeness, denylist/install risks, no Gate-hard journal
counts: {P0: 3, P1: 9, P2: 3}
verdict: FAIL
human_locked: ["Option A pure isolation (only README.md on new installs)", "quarantine opt-in only, no auto quarantine on update"]
---

# Gate 2 Independent Scope Review — HANDOFF-20260908-knowledge-seam-isolation

## Independence & method

- Independent reviewer; no handoff authorship. Read-only review except writing this review file. No implementation.
- Read: handoff (130 lines, full), design note (220 lines, full), `principles.md` (L1, full),
  `patterns/_index.md` + at most three pattern files (`release-sync.md`, `ac-verification.md`,
  `shell-portability.md`), gate canonical checklist, prior Gate 2 review format sample.
- Executed (all read-only): `sed -n` slices of `tad.sh` (deny block L530-650, drift check
  L1030-1100, `copy_framework_files` L1081-1250, install/upgrade branches L2650-2870),
  `rg -n "TOP_DENY|verify-denylist|..." tad.sh`, `rg -n "TOP_DENY"` across lib + `tad.sh` +
  `release-verify.sh`, `find .tad/archive/handoffs | wc -l` (= 390), `ls .tad/active/handoffs/`,
  `git ls-files -- .tad/brain-index.md` (tracked), Step 6 body of `distillation-loop-protocol.md`.
- Human-locked decisions respected as constraints, not re-opened: ①A pure isolation,
  ②quarantine opt-in only. Findings below tighten tasks/ACs only; no redesign proposed.

## Gate 2 checklist mapping (canonical)

| Item | Status | Note |
|------|--------|------|
| Expert review complete (min 2) | ⚠️ Partial | This is ONE independent review; Gate 2 needs min 2 before handoff flips to Blake |
| All P0 resolved | ❌ Fail | 3 P0 open (P0-1, P0-2, P0-3) — all fixable as handoff-text patches, no redesign |
| Architecture complete | ✅ Pass | Design §3.1–3.4 covers seam, triggers, isolation, quarantine, skill split, soft evidence |
| Components specified | ⚠️ Partial | Target Files omits `.agents/` mirrors + `tad doctor`/`tad-maintain` carriers (P1-1) |
| Functions verified | ❌ Fail | AC1 verifier does not cover the changed granularity (P0-1); TOP_DENY representation trap (P0-2) |
| Data flow mapped | ✅ Pass | Copy path `derive_framework_top_files` → target verified by code read; quarantine flow mapped |

## P0 findings (blocking — fix in handoff text, then re-run Gate 2)

### P0-1 — AC1 verification is vacuous for the actual change (verifier/granularity mismatch)

- **Claim in handoff:** AC1 "`bash tad.sh --verify-denylist` exits 0" proves
  `derive-sync-set.sh` + `tad.sh` both deny `brain-index.md`.
- **Evidence (code read):**
  - `verify_denylist_drift()` (`tad.sh` L1030-1100) compares ONLY the dir-level `DENY_LIST`
    (`here_set` = `TAD_DENY_LIST` sorted vs `lib_set` = `--zero-touch` ∪ `--transient`).
    It never reads `TOP_DENY` / `TAD_TOP_DENY`.
  - `rg -n "TOP_DENY"` hits: `derive-sync-set.sh:77` (constant), `:122` (`--report` print only),
    `tad.sh:566` (constant), `:599` (the functional equality check), `:1095` (comment).
    Zero hits in `release-verify.sh` — no verifier covers the top-file deny at any granularity.
  - This is the documented 2026-06-01 failure class ("a verifier is only as good as the
    granularity it inspects"): the change is at top-FILE granularity, the cited verifier
    inspects DIR granularity → green gate over unchecked change.
- **Consequence:** AC1 as written PASSes with or without the fix. Gate 3 would certify
  nothing-checked.
- **Required fix (handoff-text only):** replace AC1's verification with direct assertions,
  e.g. `grep -Fxq -e 'brain-index.md'` against the `TOP_DENY` block of BOTH files (plus
  `sync-registry.yaml` still present — see P0-2), AND a behavioral probe:
  `derive_framework_top_files` output on the repo must NOT contain `brain-index.md`
  (extract via `sed`, never reimplement). Keep `--verify-denylist` as a regression companion,
  not the proof.

### P0-2 — `TAD_TOP_DENY` single-string equality breaks silently on the mandated 2-value edit

- **Evidence:** `tad.sh:566` `TAD_TOP_DENY="sync-registry.yaml"` with consumer at `:599`
  `[ "$bn" = "$TAD_TOP_DENY" ] && continue` — exact-string equality, not a set.
  `derive-sync-set.sh:77` is the same single-string shape (report-only, but same trap).
- **Failure mode:** a naive Blake edit `TAD_TOP_DENY="sync-registry.yaml brain-index.md"`
  (or newline-joined without changing the consumer) matches NOTHING: `brain-index.md`
  keeps syncing AND `sync-registry.yaml` STOPS being excluded — strictly worse than baseline,
  under a green AC1 (which per P0-1 cannot see it).
- **Required fix:** Task 1 must mandate the representation change explicitly:
  multiline deny + set-membership consumer (`case` / `grep -Fxq -e`), with complement ACs:
  (a) `brain-index.md` denied in both files, (b) `sync-registry.yaml` STILL denied in both
  files (the "pin the siblings" rule), (c) a "right count, wrong place" probe is N/A here
  but a pre-fix BASE-FAIL / post-fix FULL-PASS pair is mandatory. Also update the stale
  comment at `tad.sh:592` ("the only excluded file").

### P0-3 — Quarantine scope must explicitly exclude `README.md` (sanctioned seed)

- **Evidence:** install/upgrade/migrate branches (`tad.sh` L2667-2668, L2770, L2850) copy
  `$TAD_SRC/.tad/project-knowledge/README.md` into every target — README.md is the ONE
  sanctioned downstream file under locked Option A (handoff Task 4 / Decision Log).
  A fresh downstream README is therefore byte-identical to upstream by construction.
- **Failure mode:** Task 5 ("moves same-hash files to quarantine") with no exclusion will
  quarantine the legitimate README on first run in a clean downstream repo — destroying
  the exact invariant Task 4 establishes. Handoff `Forbidden` bans deleting user-modified
  files but says nothing about the identical-hash sanctioned seed.
- **Required fix:** add to Task 5: NEVER move `project-knowledge/README.md`
  (and never move files outside `project-knowledge/`), plus AC4 assertions:
  (a) seeded README survives a quarantine run byte-identical, (b) one identical framework
  incident file IS quarantined with MANIFEST row, (c) one locally-modified same-name file
  is preserved with warning.

## P1 findings (advisory — fix before or alongside Blake start; re-check at Gate 3)

### P1-1 — Target Files / blast radius omits the dual-tree mirrors and trigger carriers

- Task 3 says "Mirror in `.agents/skills/alex/`" but §1 Target Files lists only
  `.claude/skills/alex/references/...`. Missing carriers: `.agents/skills/alex/references/
  distillation-loop-protocol.md`, same for `acceptance-protocol.md`, plus the actual
  `tad doctor` implementation site in `tad.sh` and the `tad-maintain` skill files touched
  by the freshness check. Blast radius ("installer self-check and drift verification")
  understates: protocol edits ride the Gate 4 path on both platforms.
- Fix: enumerate every edited file in §1 (both trees), or scope Task 3 to named files.

### P1-2 — AC2 non-discriminative at baseline + missing assertions + no command

- Current install ALREADY copies only README (`cp .../README.md`, zero-touch skips the rest
  via `copy_framework_files`), so "copies README but zero framework files" likely PASSes
  pre-fix. The real Task 4 delta is `mkdir patterns/ incidents/` — which AC2 never asserts.
- Fix: AC2 = `mktemp -d` isolated install simulation asserting (a) `patterns/` + `incidents/`
  exist, (b) ONLY `README.md` present at top of `project-knowledge/`, (c) zero `*.md`
  under `patterns/`/`incidents/`. State the exact simulation command; per the 2026-07-13
  pattern, dry-run it on this host before locking.

### P1-3 — AC3 count language vs the `head -50` cap (390 archived exist)

- `find .tad/archive/handoffs | wc -l` = 390; generator §7 caps at `head -50` by design.
  "processing all 50 archived handoffs" is ambiguous and invites Blake to "fix" the cap
  to 390 (scope creep + perf change on every trigger run).
- Fix: "exits 0; processes the 50-most-recent cap + all active handoffs; every emitted row
  has non-empty task_type/summary (no `(see file)` fallback regression)". Assert exit code,
  not vibes.

### P1-4 — AC4 vague (no fixture commands, no undecidable case, no manifest schema)

- "correctly identifies ... moves ... preserves ... regenerates" has no literal commands.
  Per the 2026-06-10 fail-safe pattern, add one AC per input class: identical → quarantined;
  modified same-name → preserved + warning; README → preserved (P0-3); run regenerates
  `brain-index.md` (mtime/content delta). Pin MANIFEST.md schema + date-suffix format +
  executable bit + `bash -n` syntax gate. Dry-run against a fixture tree, not a live repo.

### P1-5 — AC5 underspecified across platforms and serialization forms

- Task 4 names only `.claude/skills/local/`; design requires `.agents/skills/local/` too,
  and `TARGET_SKILL_DIR` is platform-dependent (codex → `.agents`). State both.
- `ownership: project-owned` matcher must cover double-quoted / single-quoted / bare YAML
  forms (2026-08-03 pattern) — a double-quote-only grep is bypassable by re-serialization.
- Add BASE-FAIL (unprotected skill gets overwritten) / FULL-PASS probe pair.

### P1-6 — Design §3.2B provenance tagging silently dropped; mark it OUT-OF-SCOPE

- Design offers provenance frontmatter for explicitly-imported framework knowledge; handoff
  has no task/AC for it. Under locked Option A this is correctly dead code — but silence
  lets Blake reintroduce `framework-principles.md`, violating the lock.
- Fix: add explicit OUT-OF-SCOPE line "No `framework-principles.md`; no provenance-tag
  machinery in v2.45.0 (pure isolation per locked ①)".

### P1-7 — Missing negative ACs for the two locks + WARN-only freshness

- Locks need absence proofs, not prose: (a) "`tad.sh update` never invokes
  `quarantine-framework-pk.sh` (grep the update path; fixture run shows zero quarantine
  dirs created)"; (b) "no Gate 3/4 check reads `brain-index.md` freshness as a PASS
  condition"; (c) "`tad doctor` / `tad-maintain` freshness signal is WARN-only, exit 0
  on stale". Without (b)/(c), Task 3's "status check" can harden into the exact
  Gate-hard journal/knowledge gate the handoff forbids.

### P1-8 — Protocol-edit ACs need section-scoped anchors + header-parse guard

- Whole-file `grep -c 'brain-index-gen.sh'` PASSes with the trigger in the wrong section
  (2026-08-03 section-scope pattern). Require the trigger line BETWEEN `## Step 6: Finalize`
  and the next `## ` heading (stateful awk, not `/start/,/end/`), mirrored in both trees.
- SKILL/reference edits are structured-header files: add an active frontmatter/YAML parse
  guard on every edited file (2026-08-03 text-anchor pattern), not just substring presence.

### P1-9 — Task 2 must enumerate ALL pipefail sites, not just `task_type`

- Code read shows unguarded `grep -m1` at §3 (`summary`, L94), §5 (`task_type` L136 has a
  partial `|| echo` but `summary` L138 does not), §6 (L156), §7 (L174), plus `grep -m1`
  in §9 (L212) and §11 (L251). Task 2's single `task_type` example underspecifies the sweep.
- Fix: list every line/site, mandate the `{ grep ... || true; } | ...` + default pattern
  per site, with BSD/macOS-safe syntax (no bash-4-isms per §5 Friction Preflight).

## P2 nits

- **P2-1:** AC7 cites no command — point it at `bash .tad/hooks/lib/release-verify.sh parity`
  (already in §5 Friction Preflight) with the exact expected output.
- **P2-2:** Upgrade/migrate unconditionally overwrite downstream `project-knowledge/README.md`.
  Acceptable for a framework-owned seed, but note it: a downstream-customized README is
  clobbered. Consider contents-compare-and-backup (same FR-4b discipline as root files)
  or declare README framework-owned in the guide.
- **P2-3:** Quarantine archive name `quarantine-framework-pk-<date>` format, MANIFEST.md
  columns, and re-run idempotency (second run = no-op, exit 0) are unspecified. One line each.

## No-Gate-hard-journal check — PASS (with P1-7 hardening)

- Handoff `Forbidden` explicitly bans per-ticket journal as a Gate 3/4 PASS requirement;
  AC6 requires the Step 6 trigger be soft (`|| true`, non-blocking when skipped). Both align
  with L1 "Knowledge Is Forged at Distill" and design §3.4.
- Residual risk is future-hardening via Task 3 freshness checks → covered by P1-7(c):
  designers must state WARN-only now, or a later "stale index" gate reintroduces through
  the back door what the front door forbids.

## Verdict

- **VERDICT: FAIL** — 3 P0 open (all handoff-text patches; design and human locks intact).
- **To pass re-review:** apply the Required-fix lines in P0-1/P0-2/P0-3 (plus P1-1 file list
  completion so Blake's blast radius is exact), dry-run every AC command on this host at
  baseline (GOOD must pass / BAD must fail-cleanly), then request the second Gate 2 review
  (canonical min-2 rule) before flipping `READY_FOR_GATE2` → Blake start.
- **Explicit non-reopen:** Option A pure isolation + quarantine opt-in-only confirmed
  correctly encoded in §1 Execution Mandate, §6 Decision Log, and Forbidden. Do not relitigate.
