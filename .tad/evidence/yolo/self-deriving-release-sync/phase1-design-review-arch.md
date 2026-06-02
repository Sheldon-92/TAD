# Phase 1 Design Review — backend-architect (blue-team)

**Artifact:** HANDOFF-20260601-self-deriving-release-sync-phase1.md (+ grounding, DR, Epic P1)
**Reviewer role:** backend-architect / structure-resilience & gate-composition focus
**Date:** 2026-06-01
**Verdict:** CONDITIONAL PASS

The design is architecturally sound on its central thesis (deny-list > allow-list, gate-as-guarantee
not script-freshness, release-time not settings.json). It genuinely achieves structure-resilience in the
mechanism. The conditions below are mostly spec-internal arithmetic inconsistencies and two real gaps
(exclusion-path proof + no real-release fallback) that should be closed before Blake builds, because they
will either block Blake at AC1 or leave the "structure-resilience" claim half-proven.

---

## 1. Critical (P0) — must resolve before implementation

### P0-1 — The "total dirs" / "20 SYNC dirs" arithmetic is internally inconsistent across three docs; Blake will hit a hard contradiction at AC1/SC1.

Three different numbers for the same `ls -d .tad/*/` scan appear:
- grounding L8: "the ACTUAL `.tad/` tree shows **33 dirs**"
- handoff §4.3 L290: "`ls -d .tad/*/` (**31** today) − 12 = **20**"
- handoff SC1-pre L528: `ls -d .tad/*/ | … | grep -vxE '<12 names>' | wc -l` ⇒ **20**

The arithmetic does not close. If `ls -d .tad/*/` = 31 and DENY_LIST has 12 names, the deny is
`grep -vxE` (whole-line match), so the result is `31 − (count of DENY_LIST names that ACTUALLY exist as
dirs)`. To get 20 from 31, exactly **11** of the 12 deny names must exist (one deny name matches no dir).
But grounding says 33 dirs. 33 − 20 = 13 removed, which exceeds the 12-name deny-list — impossible by the
stated rule. So at least one of {33, 31, the 12-name list, 20} is wrong, and the docs disagree with each
other, not just with reality.

This matters because **SC1 hard-asserts `--dirs | wc -l ⇒ 20`** and **AC7 asserts "re-derive == v2.21.0
set exactly."** If the live tree is actually 33 (or the working tree has drifted since SC1-pre was run —
note `git status` shows new evidence files added this very session), Blake's `wc -l` will not be 20 and
SC1 fails on a number Alex pinned from a stale snapshot. This is precisely the "AC Verification Drift"
pattern (project-knowledge, recurring): a count pinned by mental/early dry-run that the live command
contradicts at Blake time.

**Required fix (one of):**
- (a) Re-run `ls -d .tad/*/ | wc -l` and the full `--dirs` pipeline on the CURRENT working tree, paste the
  real number, and replace ALL three occurrences (33/31/20) with the reconciled set. Pin SC1 to the live
  count, not a snapshot. OR
- (b) Change SC1/AC7 from an absolute count (`⇒ 20`) to a **membership + set-equality** assertion:
  "derived set ⊇ {agents,…,codex,cross-model,context,tests,scripts,capability-packs}" AND "derived set ∩
  DENY_LIST = ∅". A membership/exclusion assertion is structure-resilient; a hardcoded `20` is itself a
  hardcoded list — the exact anti-pattern this Epic exists to kill. (b) is strongly preferred: pinning
  `wc -l ⇒ 20` re-imports the brittleness into the acceptance gate.

### P0-2 — AC4 proves INCLUSION only; the deny-list EXCLUSION path is never exercised. Structure-resilience is half-proven.

AC4 injects `_synthtest` (a dir that SHOULD sync), proves derivation includes it, proves the gate names it
when omitted. That proves the *bias-to-sync + catch-omission* half. It does **not** prove the deny-list
actually removes anything — i.e. that `grep -vxE '(project-knowledge|active|…)'` correctly EXCLUDES a
zero-touch/transient dir. A `grep -vxE` with a subtly wrong anchor (missing `-x`, a stray `.`, a `|`
rendered as `\|` — all documented failure modes in this very handoff's §Project-Knowledge) could pass
through a dir it should deny, and **nothing in AC1–AC7 would catch it** because every assertion checks
*presence* (codex present, `_synthtest` present, count==20), never *absence*.

Consequence if missed: a zero-touch dir (e.g. `active/`, `evidence/`) silently joins SYNC_DIRS → the next
real sync **overwrites downstream project data** (the whole reason zero-touch exists). That is a far worse
blast radius than the omission disease — the design would convert a "miss files" bug into a "clobber
user's project state" bug.

**Required fix:** add an explicit EXCLUSION assertion to AC4 (or a new SC):
`bash derive-sync-set.sh --dirs | grep -cxE 'active|evidence|github-registry|spike-v3|working' ⇒ 0`
(every DENY_LIST member is absent from the derived set). Optionally extend the AC4 dogfood with a synthetic
`.tad/_synthdeny/` that you ADD to the deny-list constant and confirm derivation now EXCLUDES it — that
closes the loop on "the deny mechanism is editable and effective," which is the user's stated escape hatch
("if it turns out main-only, it's added to the explicit DENY_LIST"). Reviewer-focus-#2 answer: **yes, a
main-only/exclusion test is needed and is currently missing.**

---

## 2. Recommendations (P1)

### P1-1 — No staged rollout / fallback for the FIRST REAL release. Reviewer-focus-#3 is a genuine gap.

The design correctly scopes P1's *dogfood* to synthetic dirs (blast radius = TAD repo). But P1 also
**rewires `publish_protocol` + `sync_protocol` + the runbook** — so the NEXT real `*publish`/`*sync` runs
the new, never-run-on-real-downstream mechanism, with a **minor+ HARD BLOCK** authority. If the derive or
the `structural` diff misbehaves on a real downstream tree (e.g. the `capability-packs` sub-path rule, or a
target that legitimately differs because of install-time transforms), the gate HARD-BLOCKS a real release
with no documented escape. The handoff says "blast radius = TAD repo" — true for the *dogfood*, but the
*protocol change* has blast radius = every future release.

Three things compound the risk:
- `structural` does `diff -rq src/.tad/$d target/.tad/$d` over ~20 dirs. Downstream targets are installed
  via `install.sh` / `tad.sh`, which may legitimately transform or omit files (the handoff itself notes
  capability-packs reach downstream as installed `.claude/skills`, not as source). A naive `diff -rq` of
  every framework dir against an *installed* target may report legitimate, expected differences as
  "drift" → false HARD-BLOCK on the first real sync.
- The exit-2 fail-CLOSED rule means any usage/parse hiccup in the new lib HARD-BLOCKS minor+ releases.
- There is no `--dry-run` / advisory-first mode documented for the first real cutover.

**Recommendation:** add to the runbook an explicit **"first-real-release cutover" note**: run the new gate
in **advisory mode (report, do not block) for the first real minor+ release**, compare its verdict to a
manual check, THEN flip to HARD-BLOCK. Cheapest form: the gate already has a `patch=advisory` path —
document that the operator may force-advisory for one cutover via an env flag (e.g.
`RELEASE_VERIFY_ADVISORY=1`) that downgrades block→warn, with a runbook instruction to remove it after the
first clean real release. This is the standard "ship the detector in shadow mode before it gates" pattern
and costs ~5 lines. Without it, the first real release is a live-fire test of an unproven blocker.

### P1-2 — `structural` semantics vs an INSTALLED target are under-specified (the false-positive risk above, called out separately because it needs a design answer, not just a rollout note).

`diff -rq` is exact-byte equality of two trees. The dogfood runs `structural "$PWD" "$PWD"` (self==self,
trivially 0) and the synthetic omission case (target literally missing a dir → diff reports it). Neither
exercises the real question: **what is a legitimate downstream target supposed to look like after a sync?**
If the answer is "byte-identical for the 20 framework dirs," fine — but that contract must be stated,
because the handoff also says capability-packs source dirs are NOT synced and packs arrive as installed
skills. So the target's `.claude/skills` is NOT byte-identical to source `.claude/skills` (install.sh
transforms, e.g. AGENTS.md for codex edition, frontmatter). Yet FR1/§4.2 explicitly adds
`diff -rq src/.claude/skills target/.claude/skills` to `structural`. **That diff will almost certainly be
non-empty on a real downstream** → false HARD-BLOCK.

**Recommendation:** §4.2 should state the structural contract precisely: which paths are expected
byte-identical post-sync vs which are install-transformed and must be EXCLUDED from `diff -rq` (or compared
with a transform-aware check). At minimum, `.claude/skills` cross-vendor editions (codex AGENTS.md, gemini)
need an exclusion or the diff is comparing source-Claude-skills against an installed-mixed-vendor target.
Resolve before the first real sync, or P1-1's advisory cutover will immediately surface it as noise.

### P1-3 — P2 reusability of the primitives is asserted but not verified against the curl-on-fresh-machine constraint. Reviewer-focus-#5.

P2's premise (Epic L102-124) is that `tad.sh` reuses P1's `release-verify.sh` / `derive-sync-set.sh`. But
`tad.sh` runs **standalone via `curl … | bash` on a fresh machine** where `.tad/hooks/lib/` does not yet
exist (that's what's being installed). So P2 **cannot `source .tad/hooks/lib/derive-sync-set.sh`** at
install time — the lib isn't on disk until after the copy step it's supposed to drive. This is a
chicken-and-egg the Epic glosses ("reuse the same lib/primitives in the installer"). P1 is not wrong, but
its claim of forward-compat primitives is overstated for the curl path.

**Recommendation (P1 design note, P2 work):** make `derive-sync-set.sh` **logic** reusable as a pure
function with no repo-relative assumptions — accept `<root>` (already does) AND keep the DENY_LIST
expressible as a single copy-pasteable constant block so `tad.sh` can either (a) curl-fetch the lib from
the repo first then source it, or (b) inline-embed the same DENY_LIST + derivation snippet. Document in P1's
CONTRACT header which functions are "embeddable verbatim into a standalone installer" vs "repo-context
only." Otherwise P2 reimplements the derivation (the Epic's stated anti-goal) and the two copies drift —
re-creating the disease in a second location. This is a forward-compat field to add now (architecture.md
"Epic Architecture: pre-allocate forward-compatibility fields").

### P1-4 — publish=version / sync=structural split: sound, but confirm the gap is actually covered.

Reviewer-focus-#4: the split is architecturally correct — at publish there is no target, so only `version`
(grep zero-stale) makes sense; at sync there is a target, so `structural` (diff) applies. The two gates
**compose without overlap**: `version` guards "did we bump every ref" (publish-side), `structural` guards
"did every framework file reach the target" (sync-side). Good.

One real **gap** though: `version` only runs at publish, `structural` only runs at sync. A repo that is
`*sync`'d WITHOUT a fresh `*publish` (the common "push latest framework to projects between releases" case)
**never runs `version`** → a stale-version target is not caught by the sync gate, only the structural diff
(which would catch the version-string difference IF the source was already bumped, but says nothing if the
SOURCE itself is stale). And publish runs `version` but NOT `structural` (correct — no target). So neither
gate verifies, at publish time, that the *source's own* cross-vendor editions are at parity. The handoff
notes step3b (codex-parity-check) already covers source-side codex parity — good, that's the answer to
focus-#4's sub-question, BUT it should be stated explicitly in §2.2/§4 that **step3b (codex parity) +
step3c (version) together cover the publish-side source-consistency, and structural is sync-only** so a
reader can see there's no source-consistency hole. Add one sentence to §4.1 making the three-gate
composition (3b parity / 3c version / sync-side structural) explicit and non-overlapping.

### P1-5 — Deny-list-as-hardcoded-list: acceptable, but the asymmetry should be documented as the design's load-bearing rationale.

Reviewer-focus-#1: yes, the deny-list IS a 12-name hardcoded list, so it does **relocate** some brittleness
rather than eliminate it. But the relocation is asymmetric in the *right* direction: a stale **allow**-list
fails CLOSED-WRONG (new framework dir silently OMITTED → the disease). A stale **deny**-list fails
OPEN-SAFE-ish (new dir defaults to SYNC + is REPORTED → visible, auditable, fixable by adding one deny
entry). The failure mode flips from "silent omission" to "visible over-inclusion you can see in the
report." That is the correct bias **for the framework-distribution direction** — BUT note P0-2: the
over-inclusion is only "safe" if the REPORT is actually read AND if a wrongly-included zero-touch dir
doesn't clobber downstream. The bias is right; the safety depends entirely on (a) the `--report` being
surfaced at gate time and (b) the exclusion path being correct. Document this rationale explicitly in the
lib header so a future maintainer doesn't "simplify" the deny-list back to an allow-list. (The handoff §11
table captures this; recommend lifting it into the `derive-sync-set.sh` header CONTRACT block too.)

---

## 3. Suggestions (P2)

- **S1** — `version` mode's "exclude version-history table lines" is specified heuristically ("lines
  matching `| **vX.Y.Z** |` shape, or under a 'version history'/'版本历史' heading"). This is the most
  fragile part of the whole design (regex over prose). Recommend AC2/dogfood explicitly include a
  README/CHANGELOG with a real version-history table and assert the grep-confirm returns zero (i.e. the
  exclusion works) AND a planted stale ref OUTSIDE the history table is still caught. Otherwise the
  exclusion either over-matches (misses a real stale ref → false PASS) or under-matches (flags a legit
  history row → false BLOCK). This is the single highest-risk false-negative in the design.
- **S2** — The CONTRACT header (NFR2) should pin the exit-code semantics AND the `--dirs` output format
  (one basename per line, sorted, LC_ALL=C) as a consumed contract — the gate and the per-release-script
  generator both parse `--dirs` output, making it a `.router.log`-class consumed API. A format change
  (trailing slash, full path vs basename) is then a breaking change. Already implied; make it explicit.
- **S3** — `--report` should print to **stderr** (or a clearly delimited block) so that
  `derive-sync-set.sh --dirs` consumed by the generator never accidentally ingests report prose if someone
  later merges the modes. Keep `--dirs` machine-clean, `--report` human-facing.
- **S4** — Consider having the sync gate print the `--report` (synced set) on EVERY run, not just on
  failure — the handoff §10.1 mandates "REPORT the synced set each run" but the wiring in §6.2 step 4 only
  describes block/advisory on exit code, not the unconditional report emission. Make the unconditional
  report an explicit AC (currently it's a Critical-Warning prose requirement with no SC backing it — so by
  the project's own "anything not in an AC is optional" rule, it's effectively optional).

---

## 4. Overall: CONDITIONAL PASS

The architecture is correct where it counts: deny-list bias is the right direction for framework
distribution, gate-as-guarantee is the right mental model, release-time-not-settings.json is the correct
(and well-grounded) enforcement placement, and the publish/sync split is clean. The dogfood's
*inclusion-omission* proof is genuinely anti-theater.

**Conditions to clear before Blake builds (P0):**
1. **P0-1** — reconcile the 33/31/20 arithmetic; convert SC1/AC7 from a hardcoded `wc -l ⇒ 20` to a
   membership+exclusion set assertion (a pinned count is itself the brittleness this Epic kills).
2. **P0-2** — add an EXCLUSION assertion to AC4 (every DENY_LIST member absent from derived set; optionally
   a synthetic add-to-deny dogfood). Current ACs only prove inclusion; a broken `grep -vxE` could leak a
   zero-touch dir into SYNC and **clobber downstream project data** — a worse failure than the original
   disease, and undetected by AC1–AC7.

**Strongly recommended before first REAL release (P1-1/P1-2):** ship the gate in advisory/shadow mode for
the first real minor+ release and resolve the `diff -rq` vs installed-target false-positive (especially
`.claude/skills` cross-vendor editions) before flipping to HARD-BLOCK. The synthetic dogfood does NOT prove
the gate behaves correctly against a real installed downstream — that is an unproven path the design hands
straight to production.

**Forward-compat (P1-3):** state which derivation logic is embeddable verbatim into the standalone
`curl | bash` installer, since P2's `tad.sh` cannot `source` a lib that doesn't exist yet on a fresh
machine — otherwise P2 reimplements and the two copies drift.
