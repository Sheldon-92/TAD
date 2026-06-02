# Phase 1 Design Review — Self-Deriving Release/Sync (code-reviewer, blue-team)

**Reviewer**: code-reviewer (blue-team / defensive design review)
**Artifact**: HANDOFF-20260601-self-deriving-release-sync-phase1.md (design, pre-implementation)
**Grounding**: phase1-grounding.md, DR-20260601-self-deriving-release-sync.md
**Date**: 2026-06-01
**Verdict**: **CONDITIONAL PASS** (2 P0, 4 P1, 5 P2 — all fixable in the design before Blake implements)

Scope note: this reviews the DESIGN. Findings are spec-bugs / under-specifications / latent shell hazards
the design hands to Blake — not implementation defects (no code exists yet). Several are "the spec is
ambiguous enough that a correct-looking implementation will still fail an AC."

---

## 1. Critical (P0)

### P0-1 — `version` mode FR2/§4.2 specifies the historical-version exclusion in prose only; as written it will EITHER false-pass the tad.sh straggler class OR false-fail historical refs. The exclusion is the load-bearing logic and it is undefined.

Focus area 3 is the core risk of this phase and the design under-specifies it to the point of being
non-implementable without Blake inventing the contract.

FR2 (L206) / §4.2 (L274-277) say: exclude "the README/INSTALLATION/CHANGELOG **version-history table
lines**", "anchor on lines inside a 'version history' / 'Changelog' table — e.g. lines matching a
`| **vX.Y.Z** |` history-row shape, or lines under a 'Revision history'/'版本历史' heading."

Two mutually-defeating failure modes are both reachable from this prose:

- **False-PASS (misses a real straggler):** The disease this DR exists to kill is `tad.sh
  TARGET_VERSION="2.19.1"` and `config.yaml` stuck at an old version. Those stale refs are NOT in a
  version-history table — they are live assignments. So a *correctly narrow* exclusion is fine for them.
  BUT the anchor "lines matching a `| **vX.Y.Z** |` history-row shape" is a SHAPE match, not a LOCATION
  match. Any stale ref that happens to sit in a markdown table cell (e.g. a comparison table, a "current
  version" badge row, a sync-registry-style `| project | version |` row) will be silently excluded →
  false-PASS. The very class of bug (a version frozen in a structured doc) is the most likely to live in
  a table cell.
- **False-FAIL (kills a legit historical ref):** Conversely "lines under a 'Revision history' heading"
  has no defined END. A naive "from the heading to EOF" implementation excludes everything after the
  heading; a "next heading" terminator depends on heading depth (the project has a documented
  `### 9.1` vs `## 9.1` depth-mismatch hazard — code-quality.md 2026-05-31). If the terminator is wrong,
  either the whole tail of the file is excluded (false-pass) or only one line is (false-fail on the rest).

The design gives Blake a *description* of intent but no testable contract: which FILES are in scope, what
exact line-pattern is the exclusion, and — critically — **there is no AC that exercises BOTH a legit
historical ref AND a real straggler in the same run.** AC2 only asserts "grep-confirm returns zero" on a
clean repo; AC4's synthetic ref is a fresh scratch-file ref (not in any history table), so it tests
neither boundary.

**Required before implementation:**
1. Replace the prose with an explicit, testable exclusion contract: a definite file allow-list for
   history (`README.md`, `INSTALLATION.md`, `CHANGELOG.md`) AND a definite line regex
   (BSD-`grep -E`, bare-pipe) for the history-row shape, AND a definite region terminator if heading-based.
2. Add a dogfood case to AC4 (or a new AC) that injects, in the SAME run: (a) a legit `$OLD` ref inside a
   real history table line (must SURVIVE / not be reported), and (b) a real straggler `$OLD` in a live
   assignment outside any table (must be REPORTED). Paste both. This is the only proof the exclusion
   discriminates rather than just "returns zero on a clean tree."
3. Decide and document: is the straggler detection a `grep -rn` over the WHOLE repo-minus-zero-touch, or
   only over a known file-set? FR6/grounding imply whole-repo `grep -rl`/`grep -rn`; if so, the exclusion
   must be LOCATION-precise (file+line), because a shape-only exclusion over the whole repo is far too
   broad.

### P0-2 — The `structural`-at-publish resolution leaves a real gap: publish ships a repo whose *editions/derived dirs can be internally inconsistent* with no structural check. The design acknowledges the gap in passing but provides no compensating control.

Focus area 5. The design's resolution (§6.2 step 4, L416-424): "`structural` is the *sync*-side check …
at publish, run `release-verify.sh version`". This is sound for the source-vs-target axis (there is no
target at publish). BUT it silently drops the only check that catches *intra-repo* structural
inconsistency at the moment of tagging.

Concretely: `*publish` tags + pushes the source repo. The codex/cross-model editions, the
`capability-packs/pack-registry.yaml`, and the 20 framework dirs are all part of that tag. If the codex
edition of a SKILL is out of sync with the Claude edition (exactly the DR-sibling
codex-edition-parity problem), or `pack-registry.yaml` is stale vs the actual `capability-packs/` tree,
publish ships it. The version-only gate cannot see this — `version` only greps for stale version strings,
not structural drift.

The handoff hand-waves "publish runs version, sync runs structural per-project" as if symmetric, but the
asymmetry means **a structurally-broken repo can be tagged and pushed, and the structural gate only fires
later, downstream, per-project** — i.e. after the bad release is already public. That inverts the DR's
own thesis ("a release with any omission is BLOCKED, not silently shipped" — L83/L85).

**Required before implementation — pick one and document it:**
- (a) At publish, additionally run an INTRA-repo structural self-check the design already half-owns: the
  Codex parity gate (step3b, already present) covers codex editions; ADD a `pack-registry.yaml`-vs-tree
  consistency check (or explicitly state step3b + the existing pack-collision/registry tooling already
  cover the intra-repo axis and cite where). OR
- (b) Explicitly SCOPE this out in the DR/handoff with a one-line rationale ("intra-repo structural
  consistency is covered by step3b parity + scan-packs registry regen; publish-time `structural` would
  have no second tree to diff and is intentionally omitted"), so the gap is a documented decision, not a
  silent hole. Right now it is the latter — §6.2 step 4 reads like the author noticed the gap mid-sentence
  and patched it with "run version instead," which is not the same as proving the gap is covered.

---

## 2. Recommendations (P1)

### P1-1 — AC completeness: all 7 ACs are present (good), but only 4 carry `- [ ]` checkboxes elsewhere; confirm the grep that found "only 4" was looking at the wrong section.

Focus area 1. **AC1–AC7 ARE all present verbatim** in §9 (L496-502) — the grep concern is a false alarm
*if* it scanned §9. The "only 4 `- [ ] AC` checkboxes" almost certainly came from §6.4 / Evidence
Manifest / §8, which reference AC4/AC6/AC7 (and AC3 implicitly) as evidence items but do NOT re-list
AC1/AC2/AC5 as checkboxes. So **no AC is dropped** — but the asymmetry is a real maintenance hazard:
§6.4's completion-evidence checklist (L432-437) lists AC4, AC7, AC6 explicitly and omits AC1/AC2/AC3/AC5
as standalone evidence lines (they are folded into SC commands). Per the project's own "AC lists become
the operational contract — anything not in ACs is effectively optional" lesson (architecture.md
2026-04-14), make §6.4 enumerate evidence for ALL of AC1–AC7 so Blake's completion checklist is 1:1 with
§9. Recommend: add explicit §6.4 lines for AC1 (`--dirs` count+codex), AC2 (version dogfood — see P0-1),
AC3 (structural self==self + bad-mode exit 2), AC5 (runbook grep). Currently AC2's evidence is the
weakest-covered, which compounds P0-1.

### P1-2 — Deny-list category membership is internally consistent, but the "total dir count" provenance is wrong in BOTH the handoff and the grounding, and the SC1 expected value rests on that wrong arithmetic.

Focus area 2. The three-category model itself is correctly implemented by the deny-list:
DENY_LIST = A(8 dirs) + C(4 dirs) = 12, and the `grep -vxE` alternation in §6.2 step 1 (L405) lists
exactly those 12. **Main-only dirs are correctly excluded**: `github-registry`, `research-notebooks`,
`spike-v3`, `working` are all in the deny-list ✅. **No framework dir is wrongly excluded**: codex,
cross-model, context, tests, scripts, capability-packs all survive the deny-list ✅. So the derivation
LOGIC is right.

BUT the arithmetic narration is wrong and self-contradictory across the three docs:
- Handoff §4.3 L290: "`ls -d .tad/*/` **(31 today)** − 12 = **20**". 31 − 12 = **19**, not 20.
- grounding L8: "Scanning the ACTUAL `.tad/` tree shows **33 dirs**".
- SC1-pre (L525-532) actual command output: **20** derived, and the listed 20-dir set + 12 denied
  ⇒ true total = **32**.

So the real total is 32; both "31" and "33" are wrong, and "31 − 12 = 20" is an arithmetic error that
only *happens* to land on the right derived number (20) because the wrong total and wrong subtraction
cancel. SC1 asserts `--dirs | wc -l` ⇒ 20, which IS correct against this repo today — but the count is
fragile: it's pinned to "32 dirs exist right now." This is fine as a smoke test, but flag it as
non-load-bearing: the AC4 anti-theater synthetic-dir test (count-agnostic) is the real proof, exactly as
§10.1 says. **Fix the §4.3 arithmetic to "32 − 12 = 20" and reconcile grounding's "33"** so a future
reader doesn't "correct" the deny-list to chase a phantom dir.

### P1-3 — The `capability-packs` registry-only sub-rule is split across `derive-sync-set.sh` (reports it) and `release-verify.sh` (diffs only the file) with NO single enforcement point — a classic two-consumer drift hazard.

Focus area 2 edge case. The sub-rule "`capability-packs` → only `pack-registry.yaml`" is implemented in
TWO places that must agree:
1. `derive-sync-set.sh --dirs` — per §4.2/FR3 it still EMITS `capability-packs` in the dir set (SC1 counts
   it among the 20; the 20-dir SC1-pre list includes `capability-packs`).
2. `release-verify.sh structural` — §4.2 L270-271 says "skip `capability-packs` dir-level — instead diff
   only `capability-packs/pack-registry.yaml`."

So `derive-sync-set.sh` says "capability-packs is a sync dir," and `release-verify.sh` special-cases it by
NAME (`if d == capability-packs`). That hardcoded basename check inside `release-verify.sh` is itself a
mini hardcoded-list — the exact anti-pattern this Epic kills — and worse, the per-release `sync-vX.Y.Z.sh`
GENERATOR (FR5, generated from `--dirs`) will see `capability-packs` in the dir list and, unless IT also
special-cases the basename, will `cp -R` the whole 299-file pack-source tree downstream (the §8.3 /
grounding L41-43 false-FAIL / over-sync hazard). The sub-rule must be enforced in ONE place that ALL THREE
consumers (`--dirs` output, the generator, `structural`) honor. **Recommend:** have `derive-sync-set.sh`
expose the sub-rule as machine-readable output (e.g. `--dirs` emits `capability-packs/pack-registry.yaml`
as the path, or a separate `--registry-only` line / `--report` field both the generator and `structural`
read), so the basename special-case lives in derive-sync-set.sh only and is consumed, not re-implemented.
As designed, three independent `== capability-packs` checks will drift.

### P1-4 — The `version`-mode grep scope ("repo minus .git minus zero-touch dirs") is specified but the zero-touch exclusion is not pinned to the SAME source of truth as the deny-list — second hardcoded list risk.

Focus area 3 + MQ5. FR2 (L206) and §4.2 (L274) say `version` excludes "the zero-touch dirs." The deny-list
in `derive-sync-set.sh` is the documented sole source of truth (MQ5, L378-384). But `release-verify.sh
version` needs the *zero-touch* subset (category A = 8 dirs), NOT the full deny-list (which also contains
transient C dirs). Nothing in the design says `version` derives its exclusion from `derive-sync-set.sh`;
the natural (wrong) implementation is a second hardcoded zero-touch list inside `release-verify.sh`. That
recreates the disease for the version path: add a 9th zero-touch dir later, forget to update the
`version`-scope exclusion, and a stale ref hides there. **Recommend:** define exactly which dir-set
`version` scans relative to `derive-sync-set.sh`'s constants (e.g. expose the zero-touch subset from
derive-sync-set.sh, or scan repo-minus-`.git` and rely on the history-line exclusion alone). Pin it to one
source.

---

## 3. Suggestions (P2)

### P2-1 — Shell correctness (focus area 4): the design's stated conventions are correct; spot hazards to hand Blake.

The handoff explicitly mandates the right things (NFR1 L226-227: no `grep -P`, `LC_ALL=C` on sort/comm;
§4.2 BARE-pipe `grep -vxE`; fail-CLOSED exit 2). No `grep -P` appears. Residual hazards to call out so
Blake doesn't trip them:
- **`ls -d "$root"/.tad/*/ | sed 's|.*/.tad/||;s|/$||'` (§6.2 L404-405) breaks if `$root` itself contains
  `/.tad/`** — unlikely, but the repo path has a SPACE (`01-on progress programs`), and `ls -d glob`
  output with a space is fine through the `sed` pipe, yet a later `for d in $(... )` word-splits on the
  space. The 20 derived dir NAMES have no spaces, so this is safe AS LONG AS iteration is over basenames
  only (it is). Confirm the structural loop iterates the derive-sync-set OUTPUT (space-free basenames),
  never the full paths, and quotes `"$src/.tad/$d"`. §8.3 L482 already flags this — good.
- **`grep -vxE` whole-line match requires the input be exactly the basename** (no trailing slash, no
  leading path). The `sed 's|/$||'` strips the trailing slash; verify no leading `./` survives from
  `ls -d` (it won't with `.tad/*/`, but if someone passes `--report .` the glob becomes `./.tad/*/`).
  Normalize before the `grep -vxE` or the deny-list silently fails to match and ALL dirs pass through.
- **`LC_ALL=C sort`** is mandated (good) — also apply to any `comm`/`diff`-of-sorted if the generator
  diffs dir lists (code-quality.md 2026-05-31 CJK collation). Dir names are ASCII so low-risk, but the
  convention should be uniform.

### P2-2 — §9.1 SC commands: the grep-bug guards are correct, but SC7 has a latent fragility and SC5/SC6 use rendered `\|` that must be un-escaped.

Focus area 4. The handoff correctly avoids `grep -c … | sort -u | wc -l` (the always-returns-1 bug) and
documents the bare-pipe rule. Specific checks:
- **SC7 (L520):** `grep -oE 'release-verify\.sh' … | sort -u | wc -l` ⇒ expects `1` (distinct token),
  then `grep -c 'release-verify' … ` ⇒ `≥2`. The first is fine (one distinct literal). The second `≥2`
  asserts "≥1 in each protocol" but `grep -c` counts LINES not protocols — two references in
  publish_protocol alone would also yield `≥2` and false-PASS the "wired into BOTH" intent. Tighten:
  separately assert the token appears within each protocol's line-range, or grep for both a
  publish-context and a sync-context anchor.
- **SC5/SC6 (L518-519):** written with `\|` (`'derive-sync-set\.sh|release-verify\.sh'` is fine — that's
  a real `|` alternation with escaped dots; but `'DERIVED — illustrative only|illustrative only|...'`
  in SC6 — confirm these render as BARE `|` when Blake runs them; the §9.1 header (L508-510) says they're
  bare-pipe runnable, so OK, just re-flag the rendered-vs-runnable trap from code-quality.md).
- **SC2 (L515):** `grep -c 'codex' derive-sync-set.sh` ⇒ expects `0`. Good intent (codex must never be
  named). But the CONTRACT header / comments could legitimately mention "the codex omission that motivated
  this" — if any comment says "codex", SC2 false-FAILs. This is the "AC self-leak from rationale" pattern
  (architecture.md 2026-04-27). Recommend SC2 grep be scoped to non-comment lines, or the handoff
  explicitly forbid the word `codex` anywhere in the file including comments (and the CONTRACT block).

### P2-3 — "A NEW unclassified dir defaults to SYNC + is reported" — the REPORT is specified but the gate does not FAIL or PROMPT on a newly-included dir, so the audit signal can be silently ignored.

Focus area 2. FR3/§10.1 (L569-572) correctly bias-to-sync and mandate `--report` print the synced set. But
"VISIBLE and auditable" only works if a human looks. There is no mechanism (a diff vs a recorded baseline,
a prompt) that forces acknowledgement of a newly-included dir. For P1 this is acceptable (the bias-to-sync
is the deliberate choice and over-sync is the safe direction), but note for P2/Epic: consider a recorded
`known-sync-set` baseline so a NEW inclusion produces a one-time "new dir `X` now syncs — confirm or
deny-list it" notice. Otherwise the disease's mirror-image (silently OVER-syncing a main-only dir that
should've been denied) re-emerges. Not blocking for P1.

### P2-4 — Per-release script destination (`evidence/releases/`) is correct, but nothing verifies it actually lands there / isn't accidentally created under `scripts/`.

Focus area 2 edge case. FR5/§4.3 correctly route the generated `sync-vX.Y.Z.sh` to
`.tad/evidence/releases/` (zero-touch ⇒ auto-excluded). But P1 ships only the *procedure* (§7.1 L448-449),
no generator code and no AC that the procedure writes to the right place. Low risk for P1 (no generator
built), but the runbook upgrade (AC5) should state the destination as a MUST, and a future AC should grep
that no `sync-v*.sh` exists under `scripts/`. Minor.

### P2-5 — Exit-code contract is good; add a one-line note that exit 2 (usage) must be distinguishable from exit 1 (drift) at the gate, since both HARD-BLOCK on minor+.

Focus area 4 / NFR3. §4.4 / MQ4 correctly define 0/1/2 and "exit 1 or 2 → HARD BLOCK on minor+." Since the
gate treats 1 and 2 identically (both block on minor+), confirm the gate still LOGS which it was — a usage
error (exit 2, e.g. a missing arg / refactor bug in the gate wiring) blocking a release looks identical to
a real drift (exit 1) and would send Blake hunting for a non-existent omission. Recommend the gate echo the
raw exit code + mode so a fail-closed usage error is diagnosable, not mistaken for a real drift.

---

## 4. Overall

**CONDITIONAL PASS.**

The design is well-grounded, correctly applies the project's accumulated shell lessons (grep-bug, bare-pipe,
LC_ALL=C, fail-closed, single-user-CLI gate placement), and the deny-list derivation LOGIC is sound —
all main-only dirs (github-registry/research-notebooks/spike-v3/working) are correctly excluded and no
framework dir (codex/cross-model/context/tests/scripts/capability-packs) is wrongly excluded. All 7 ACs are
present verbatim (the "only 4 checkboxes" grep was scanning a non-§9 section; no AC is dropped).

Two P0s must be resolved in the DESIGN before Blake implements:
- **P0-1**: the `version`-mode historical-exclusion is the load-bearing logic of focus-area-3 and is
  specified in prose only — as written it can both false-pass a real straggler (shape-only table exclusion)
  and false-fail a historical ref (undefined region terminator). It needs an explicit file+line exclusion
  contract AND a discriminating dogfood (legit-historical-survives + real-straggler-reported in one run).
- **P0-2**: the publish=version / sync=structural split leaves intra-repo structural inconsistency
  (codex-edition / pack-registry drift) unchecked at tag time — must either add an intra-repo structural
  self-check at publish or explicitly document the gap as covered-by-step3b/scan-packs.

The four P1s (AC-evidence symmetry, the 32-not-31 arithmetic provenance, the `capability-packs` sub-rule
enforced in 3 places, the `version`-scope second-hardcoded-list risk) are design-hardening that prevent
predictable post-impl AC failures. Address P0-1, P0-2, and P1-3 (the sub-rule single-enforcement-point)
before handing to Blake; P1-1/P1-2/P1-4 and all P2s can be folded into the same revision.
