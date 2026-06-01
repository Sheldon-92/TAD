---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
gate3_verdict: pass
gate4_delta:
  - field: "AC8a/8c (anti-theater) + AC1/AC4/AC7/AC9 — Alex re-verified"
    alex_said: "detect-only gate blocks on drift; never writes; pin moved; audit fixed"
    actual: "Alex Gate-4 re-ran: drift→exit 1 (verified); regen batch-mv-only-if-both-pass + AC8c live byte-unchanged; check runs from hooks/lib with pin co-located; *publish step3b READ-ONLY; layer2-audit DISTINCT_COUNT=2; settings.json parity=0. All confirmed."
    caught_by: "Alex Gate 4 raw recompute"
  - field: "AC8b regen wrapper live e2e — GENUINE environmental residual"
    alex_said: "run regen-codex-editions.sh for real"
    actual: "Alex independently confirmed codex `401 Unauthorized: token_revoked` — auth genuinely expired, regen cannot execute. Blake honestly reported (did not fake). Regen MECHANISM proven e2e in P2 (codex exec 175s); only the new wrapper's live happy-path run is deferred. CLOSE by: re-auth codex, run `bash .tad/codex/regen-codex-editions.sh` once, review git diff."
    caught_by: "Alex Gate 4 (independent codex exec → 401 token_revoked)"
  - field: "≤5min per-release (Success Criterion) honest caveat"
    alex_said: "≤5min near-zero per-release human"
    actual: "Met for the COMMON case (no drift → detect-only gate runs in seconds). Drift remediation = ~350s for 2 regens (slightly over 5min) BUT only when drift exists + it's human-review time. Steady-state guarantee holds."
    caught_by: "Alex Gate 4 (backend-architect P1-1 reconciliation)"
git_tracked_dirs:
  - .tad/codex/
  - .tad/hooks/lib/
  - .claude/skills/release-runbook/
  - .claude/skills/alex/
---

# HANDOFF: Codex-Edition Parity — Phase 3 (Release Gate) — EPIC FINALE

**Epic:** EPIC-20260601-codex-edition-parity.md (Phase 3/3 — completes the Epic)
**Decision Record:** DR-20260601-codex-edition-parity-architecture.md (Architecture B)
**Priority:** P2
**From:** Alex (Terminal 1)
**Status:** Expert Review Complete — Ready for Implementation
**Builds on:** P1 (1b74dec) + P2 (4881bc1…) — the per-owner parity gate + regen-procedure are DONE & proven

---

## 1. Task Overview

Wire the proven parity gate into the release process as a **DECOUPLED, release-time hard block**
(user re-decision 2026-06-01, after backend-architect P0 flagged that auto-heal would ship an
unreviewed LLM-generated edition into a permanent tag → 14 projects). Design:
- `*publish` runs **detect-only** `codex-parity-check.sh` on the live editions. PASS → proceed.
  Drift (minor+) → **HARD-BLOCK** with a message telling the human to run the separate regen command,
  review the diff, commit, then re-publish. patch → advisory. **`*publish` NEVER modifies the editions.**
- A **separate, human-invoked** regen command (`regen-codex-editions.sh`) regenerates both editions via
  `codex exec`, atomically (both→scratch → parity-check both → batch-mv only if both pass), leaving the
  result for the human to `git diff`-review + commit. This is the reviewed remediation path.

Plus carry-forwards: graduate the check to a stable path (+ its pin file), **mechanical marker-extraction**
(so future must-cover owners are checked — self-sustainability), fix the recurring layer2-audit
reviewer-name drift, finalize the P1-2 awk fix. On acceptance the Epic completes + archives.

---

## 2. Background Context

P1 built + P2 hardened & proved the gate: `parity-check.sh` does per-must-cover-owner-body presence,
is compensation-resistant (Alex Gate-4 verified: delete express block + add surplus → still exit 1),
fail-CLOSED, pin-validated. Both live editions are at v2.20.0 parity. Headless regen via
`codex exec --full-auto` = 175s (`claude -p` FAILs on 326KB — produces analysis, not a raw file).

What's MISSING is the wiring: the release process (`release-runbook` items 15-18 + the "Codex Adapter
Smoke Test" at L335 + `*publish` `publish_protocol` at alex SKILL L5155) only bumps the `TAD vX.Y.Z`
version string + checks files exist/launch. **Nothing regenerates content or gates on parity** — which
is exactly why the editions drifted a month (`Generated: 2026-05-04`) in the first place.

Grounded facts (2026-06-01): release-runbook ALREADY has the "minor+ = HARD block; patch = advisory"
convention (L335) — P3 augments that section. `layer2-audit.sh` KNOWN_REVIEWERS (L32) contains
`spec-compliance-reviewer` but Blake's file was `spec-compliance.md` → name mismatch → false
"1 reviewer" WARN (recurring, architecture.md 2026-05-27). `grep -c parity .claude/settings.json` = 0
(must stay 0 — single-user-CLI lesson).

---

## 3. Requirements

1. Graduate `codex-parity-check.sh` **and its pin file `parity-criterion.md`** to a stable path
   (`.tad/hooks/lib/`, co-located — the check reads `$SCRIPT_DIR/parity-criterion.md`); update all references.
2. Add a **detect-only** parity gate to the release process: `*publish` runs `codex-parity-check.sh` on the
   live editions; PASS → proceed; drift (minor+) → HARD-BLOCK with remediation message; patch → advisory.
   **`*publish` MUST NOT modify the editions.** fail-CLOSED on check error.
3. Create a **separate, human-invoked** `regen-codex-editions.sh`: regenerates both editions via `codex exec`,
   atomically (both→scratch → check both → batch-mv only if BOTH pass; live untouched otherwise), for the
   human to `git diff`-review + commit. Includes **mechanical marker-extraction** (carry-forward 1b) so the
   check covers NEW must-cover owners on future releases (self-sustainability).
4. Wire the detect-only gate into BOTH `release-runbook` (Codex Adapter section) AND `*publish`
   `publish_protocol` (pre-publish blocking step).
5. Fix the layer2-audit reviewer-name drift (add `spec-compliance` to KNOWN_REVIEWERS — NOT suffix-normalize).
6. Finalize the P1-2 awk header self-counting fix in the check.
7. Document the standing mechanism + the codex-unavailable escape valve in README + portable-rules + runbook.
8. **Anti-theater dogfood**: prove the gate BLOCKS (drift a live edition → `*publish` gate exits 1) AND prove
   `regen-codex-editions.sh` works e2e (drift → regen → review → parity restored). Run the regen for REAL.
9. **Single-user-CLI compliance**: gate lives ONLY in `*publish`/runbook — never a settings.json hook.

**NOT in scope:** changing the parity criterion logic (DONE in P2). P3 is wiring + the regen command + 3 small fixes.

---

## 4. Technical Design

**Detect-only release gate (the core — `*publish` NEVER writes editions):**
```
codex_parity_gate(release_type):   # runs in *publish, READ-ONLY
  pass = codex-parity-check.sh alex-src codex-alex == 0 AND codex-parity-check.sh blake-src codex-blake == 0
  on check error → treat as FAIL (fail-CLOSED at release)
  if pass: proceed
  else:
    if release_type in {minor, major}:
      HARD BLOCK — print missing (category,owner) + this remediation message:
        "Codex editions drifted. Run:  bash .tad/codex/regen-codex-editions.sh
         then review the diff (git diff .tad/codex/), commit, and re-run *publish."
    else (patch): advisory WARN, proceed
```
The gate only READS. The human runs regen, reviews, commits — then re-publishes. This is the user's
literal "detect drift → hard-block" + keeps an unreviewed LLM artifact OUT of a tagged release.

**Separate human-invoked regen — `.tad/codex/regen-codex-editions.sh` (atomic, reviewed):**
```
for ed in alex blake:
  regen <source> -> mktemp scratch  via  codex exec --full-auto (regen-procedure via stdin)   # ~175s each
ok_alex = codex-parity-check.sh alex-src scratch_alex == 0
ok_blake = codex-parity-check.sh blake-src scratch_blake == 0
if ok_alex AND ok_blake:  mv (same-fs) both scratches -> live   # BATCH — live untouched unless BOTH pass
else: print which failed; leave live UNCHANGED; exit 1
print "Review: git diff .tad/codex/ ; then commit."   # human reviews + commits — NOT auto-committed
```
This fixes both code-reviewer P0s: live is mutated only on full success (no half-applied state), and the
regen is a human-reviewed step (no unreviewed artifact auto-shipped). `codex exec --full-auto`, NOT
`claude -p` (P2: claude -p analyzes the 326KB input instead of emitting the file). codex-unavailable →
the regen command errors with the escape valve (install codex, OR hand-port per portable-rules).

**Mechanical marker-extraction (carry-forward 1b — self-sustainability):** `codex-parity-check.sh` Layer 3
must DERIVE the feature-marker list from the current source at check time (e.g. source `task_type:` enum
values + `*_protocol:`/`### Phase` markers), NOT a hardcoded/frozen list. Otherwise a NEW must-cover track
added to Claude but not Codex passes silently → drift re-opens. (P2 source-conditioned per-agent; P3 makes
the LIST itself source-derived.)

**Graduation (CR P0-1 — move BOTH):** `mv` `parity-check.sh` → `.tad/hooks/lib/codex-parity-check.sh`
AND `parity-criterion.md` → `.tad/hooks/lib/parity-criterion.md` (the check reads `$SCRIPT_DIR/parity-criterion.md`
and fail-CLOSED-exits if absent — moving only the script bricks every release). Broad-grep for both old paths
(EPIC file, regen-procedure.md Step D, etc.) and update all dangling references. Leave spike-dir pointers.

**layer2-audit fix (CR P1-1 — add to list, NOT suffix-normalize):** add `spec-compliance` to
`KNOWN_REVIEWERS_LIST` (L32). Suffix-normalize would collide (`code-review.md`→counts as reviewer; the exact
2026-05-27 artifact). One-line list add, zero collision. Dogfood: re-run on the P2 slug → DISTINCT_COUNT=2.

**fail-CLOSED at release:** any parse/boundary error in the check during `*publish` → parity FAIL → block
(minor+). (Distinct from the P1 scratch fail-open.)

---

## 6. Implementation Steps

### Step 1 — Graduate the check + its pin file (BOTH — CR P0-1)
- `mv parity-check.sh → .tad/hooks/lib/codex-parity-check.sh` AND `mv parity-criterion.md →
  .tad/hooks/lib/parity-criterion.md` (co-located; the check reads `$SCRIPT_DIR/parity-criterion.md`).
- Broad-grep BOTH old paths across the repo (EPIC file, regen-procedure.md Step D, any evidence refs);
  update every dangling reference; leave one-line pointers in the spike dir.
- Verify the check runs from the new path WITH the spike dir absent/renamed (proves pin moved too).

### Step 2 — Finalize P1-2 + mechanical marker-extraction
- P1-2 awk fix: header comment lines must not self-count toward owner/category tallies (parser-self-count
  class, architecture.md 2026-05-30). Add a header-token dogfood.
- Mechanical marker-extraction (carry-forward 1b): Layer 3 derives the marker list from the current source
  at check time (source `task_type:` enum + `*_protocol:`/`### Phase` markers), NOT a hardcoded list.
- Confirm P2 live editions still PASS after both changes (no regression).

### Step 3 — Build the separate regen command
- Create `.tad/codex/regen-codex-editions.sh` per §4: regen both via `codex exec --full-auto` (regen-procedure
  via stdin) to `mktemp` scratch → parity-check both → batch same-fs `mv` ONLY if both pass (live untouched
  otherwise) → print "review git diff + commit" (does NOT auto-commit). codex-unavailable → error + escape valve.

### Step 4 — Build the detect-only gate (read-only)
- Implement `codex_parity_gate` per §4 — READ-ONLY: runs `codex-parity-check.sh` on both live editions;
  minor+ drift → HARD BLOCK with the remediation message pointing at `regen-codex-editions.sh`; patch →
  advisory; fail-CLOSED on error. The gate NEVER writes editions.

### Step 5 — Wire into release-runbook
- Augment the "Codex Adapter Smoke Test (minor+ = HARD block; patch = advisory)" section (L335): add the
  detect-only parity gate (existing smoke test retained as secondary). Document the regen command + that it
  uses `codex exec` (not claude -p) + the codex-unavailable escape valve.

### Step 6 — Wire into *publish (alex SKILL publish_protocol)
- Add a pre-publish blocking step to `publish_protocol` (L5155, before "Confirm & Execute" L5235): run the
  detect-only gate; minor+ drift → BLOCK (do not reach push); patch → advisory.

### Step 7 — Fix layer2-audit reviewer-name drift
- Add `spec-compliance` to `KNOWN_REVIEWERS_LIST` (L32) — NOT suffix-normalize. Dogfood: re-run on
  `codex-parity-phase2-catchup` → DISTINCT_COUNT=2, no "1 reviewer" WARN (paste before/after).

### Step 8 — Anti-theater dogfood (block + regen e2e, both for REAL)
- **8a Block path:** temp-copy a live edition; delete a must-cover block; run the detect-only gate → MUST
  exit 1 / BLOCK (minor+), naming the (category,owner). Paste.
- **8b Regen e2e (run for REAL — codex was available at 175s in P2):** drift a live edition; run
  `regen-codex-editions.sh` → it regens both, parity-check passes, batch-mv restores parity; `git diff` shows
  the regenerated content for review. Paste the run + the post-regen gate PASS. (codex genuinely unavailable
  → honest_partial: show the command + the codex-unavailable error path; do NOT fake a pass.)
- **8c Partial-heal safety:** force blake regen to fail (e.g. bad source path) → assert BOTH live editions
  byte-unchanged (`git status --porcelain .tad/codex/` empty). Paste.

### Step 9 — Document + single-user-CLI verify
- README + portable-rules + runbook: document the standing mechanism (Codex editions = derived artifacts,
  human regens + reviews + commits; `*publish` detect-only blocks on drift) + the codex-unavailable escape
  + an honest enumeration of residual manual touch-points (backend P1-3). Verify `grep -c parity
  .claude/settings.json` == 0 and the gate is NOT any hook.

### Step 10 — Layer 1 + completion + Epic completion prep
- §9.1 dry-runs; COMPLETION with gate3_verdict. Note Epic ready to complete on Gate 4 accept.

---

## 7. File Structure

**Files to Create / Move:**
- `.tad/hooks/lib/codex-parity-check.sh` (MOVE from spike — graduated gate)
- `.tad/hooks/lib/parity-criterion.md` (MOVE from spike — the pin file the check reads; CR P0-1)
- `.tad/codex/regen-codex-editions.sh` (CREATE — separate human-invoked atomic regen command)

**Files to Modify:**
- `.claude/skills/release-runbook/SKILL.md` (MODIFY — Codex Adapter section: detect-only gate + regen-command note)
- `.claude/skills/alex/SKILL.md` (MODIFY — publish_protocol pre-publish detect-only blocking step)
- `.tad/hooks/lib/layer2-audit.sh` (MODIFY — add `spec-compliance` to KNOWN_REVIEWERS_LIST)
- `.tad/evidence/spikes/codex-parity/regen-procedure.md` (MODIFY — stable path refs + codex exec lead)
- `.tad/codex/README.md` + `.tad/portable-rules.md` (MODIFY — document standing mechanism + escape valve)

**Grounded Against** (Alex step1c, 2026-06-01):
- `.claude/skills/release-runbook/SKILL.md` (L335 "Codex Adapter Smoke Test (minor+ HARD block; patch advisory)" already exists — augment it)
- `.claude/skills/alex/SKILL.md` (publish_protocol L5155: Version Consistency → Confirm & Execute L5235 → Post-Publish; insert gate before Confirm)
- `.tad/hooks/lib/layer2-audit.sh` (L32 KNOWN_REVIEWERS has `spec-compliance-reviewer` not `spec-compliance`; L72 case-match)
- `.tad/evidence/spikes/codex-parity/parity-check.sh` (11KB, the gate being graduated)

---

## 8. Testing Requirements

No unit tests. Verification = §9.1 + the Step 8 dogfood (detect-only gate BLOCKs on drift; regen-codex-editions.sh
restores parity e2e for real; failed regen leaves live byte-unchanged) + the Step 7 audit dogfood (DISTINCT_COUNT=2).

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/hooks/lib/codex-parity-check.sh` AND `.tad/hooks/lib/parity-criterion.md` both at the new path; check runs from there with the spike dir renamed/absent (proves pin moved); broad-grep shows no dangling old-path refs; spike-dir pointers left
- [ ] AC2: P1-2 awk header self-count fixed + Layer-3 marker list source-DERIVED (not hardcoded); P2 live editions still PASS post-fix; header-token dogfood pasted
- [ ] AC3: `.tad/codex/regen-codex-editions.sh` created — atomic (both→scratch→check→batch-mv only if BOTH pass; live untouched otherwise); `codex exec` not claude -p; codex-unavailable → error+escape
- [ ] AC4: detect-only `*publish` gate per §4 — READ-ONLY (never writes editions); minor+ drift → BLOCK with remediation message pointing at regen-codex-editions.sh; patch → advisory; fail-CLOSED
- [ ] AC5: `release-runbook` Codex Adapter section augmented (detect-only gate + regen-command + codex-exec + escape-valve notes; existing smoke test retained)
- [ ] AC6: `*publish` `publish_protocol` has a pre-publish detect-only blocking step before "Confirm & Execute"
- [ ] AC7: `layer2-audit.sh` KNOWN_REVIEWERS adds `spec-compliance` — dogfood: `bash layer2-audit.sh codex-parity-phase2-catchup` → DISTINCT_COUNT=2, no "1 distinct" WARN (paste before/after)
- [ ] AC8: **Anti-theater dogfood (3 cases)** — 8a: drift live edition → detect-only gate exit 1 / BLOCK naming (cat,owner); 8b: regen-codex-editions.sh run for REAL → drift→regen→parity restored + `git diff` reviewable (honest_partial only if codex genuinely unavailable); 8c: force one-edition regen fail → both live byte-unchanged (`git status --porcelain .tad/codex/` empty). All pasted.
- [ ] AC9: single-user-CLI: `grep -c parity .claude/settings.json` == 0 AND gate not registered in any hook
- [ ] AC10: README + portable-rules + runbook document the standing mechanism + codex-unavailable escape valve + residual manual touch-points enumeration

### 9.1 Spec Compliance Checklist

⚠️ PIPE-ESCAPE: run bare-pipe ERE forms (RUNNABLE FORMS below); BRE `\|` rows kept as-is.

| AC | Command (table-escaped) | Expected | Verified (step1d) |
|----|--------------------------|----------|-------------------|
| AC1 | `test -f .tad/hooks/lib/codex-parity-check.sh && test -f .tad/hooks/lib/parity-criterion.md && echo ok` | `ok` | post-impl (not yet moved) |
| AC7 | `bash .tad/hooks/lib/layer2-audit.sh codex-parity-phase2-catchup 2>&1 \| grep -c '1 distinct'` | `0` | post-impl; pre-impl currently `1` (the drift) |
| AC9 | `grep -c parity .claude/settings.json` | `0` | pre-impl PASS: `0` ✅ |

**RUNNABLE FORMS:**
```bash
test -f .tad/hooks/lib/codex-parity-check.sh && test -f .tad/hooks/lib/parity-criterion.md && echo ok   # AC1 → ok
bash .tad/hooks/lib/layer2-audit.sh codex-parity-phase2-catchup 2>&1 | grep -c '1 distinct'   # AC7 → 0
grep -c parity .claude/settings.json                             # AC9 → 0 (must stay)
```

**AC Dry-Run Log** (Alex step1d, 2026-06-01):
- AC9: ✅ pre-impl PASS — `grep -c parity .claude/settings.json` = `0` (the single-user-CLI invariant to preserve).
- AC7: pre-impl baseline — layer2-audit currently WARNs "1 distinct" on the P2 slug (the drift this fixes).
- AC1: post-impl — files not yet at the stable path.

### 9.2 Expert Review Status

Reviewed by **code-reviewer** + **backend-architect** (2 distinct, parallel). Both CONDITIONAL PASS.
Raw: `.tad/evidence/reviews/alex/codex-parity-phase3-releasegate/{code-reviewer,backend-architect}.md`.
⚠️ backend P0-1/P0-2 triggered a USER RE-DECISION (self-heal → decouple) before fixing — see §11 Decision #1.

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P0-1: self-heal silently changes "hard-block on drift" → silent-heal, no notify | §1 + §4 decouple (detect-only block) + §11 Decision #1 (user re-decided) | Resolved |
| backend-architect | P0-2: unreviewed LLM 46KB artifact auto-ships into a tagged release → 14 projects | §4 detect-only + separate human-reviewed regen command + §11 D#1 | Resolved |
| code-reviewer | P0-1: graduation moved only the script, not its pin `parity-criterion.md` → bricks release | §4 graduation (move BOTH) + Step 1 + AC1 (run with spike dir absent) | Resolved |
| code-reviewer | P0-2: per-edition live `mv` before final gate → half-applied state | §4 regen = batch-mv only if BOTH pass + Step 3 + AC3 + AC8c | Resolved |
| backend-architect | P1-2: mechanical marker-extraction (carry-forward 1b) DROPPED → re-opens drift | §4 mechanical marker-extraction + Step 2 + AC2 | Resolved |
| code-reviewer | P1-1: suffix-normalize wrong/collision-prone | §4 + Step 7 (add `spec-compliance` to list, not normalize) | Resolved |
| code-reviewer | P1-3: regen-procedure still leads with claude -p | Step 2/Step 5 (codex exec lead) | Resolved |
| code-reviewer | P1-4: no broad-grep for moved path | Step 1 (broad-grep both old paths) + AC1 | Resolved |
| backend-architect | P1-1: ≤5min blown by 2 regens (~350s) | Dissolved by decouple — `*publish` gate is detect-only (fast); regen is separate/human-initiated | Resolved |
| backend-architect | P1-4 / S-1: codex-unavailable deadlock | §4 + Step 9 (document escape valve; minor+ block kept correct) | Resolved |
| backend-architect | P1-3 / S-3: enumerate residual manual touch-points; run regen e2e for real | Step 9 (enumeration) + Step 8b/AC8 (real regen e2e) | Resolved |
| code-reviewer | P2: AC8 `&&` chain / anchor on machine line | §9.1 (AC9 no `&&`; AC7 anchors on '1 distinct') | Resolved |

---

## 10. Important Notes

- **10.1 Detect-only — the gate NEVER writes editions; the BLOCK must be real (anti-theater):** AC8a must prove
  the `*publish` gate exits 1 / BLOCKs on a drifted live edition. AC8c must prove a failed regen leaves BOTH
  live editions byte-unchanged (no half-applied state). The regen command is the ONLY thing that writes
  editions, and only on full success — and the human reviews `git diff` before committing.
- **10.2 Single-user-CLI (load-bearing, DR §Critical constraint):** the gate is a `*publish`/runbook step ONLY.
  MUST NOT be a settings.json PreToolUse/SessionStart hook (`grep -c parity .claude/settings.json` stays 0).
  A fail-closed daily-work hook is the exact thing architecture.md 2026-04-15 forbids.
- **10.3 fail-CLOSED at release** (≠ the P1 scratch fail-open): any check error during `*publish` → block (minor+).
- **10.4 codex exec, not claude -p:** P2 proved `claude -p` analyzes the 326KB input. `regen-codex-editions.sh`
  uses `codex exec --full-auto`. The `*publish` gate is detect-only and needs no codex. If codex is unavailable
  when you NEED to regen (drift detected), the escape valve is: install codex, OR hand-port per portable-rules.
  The gate still blocks (minor+) on drift either way — it never ships a drifted edition.
- **10.5 Don't touch the parity criterion logic** — it's P2-proven. P3 only graduates/wires/documents.

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Gate behavior at release | self-heal (auto-regen+ship) / **detect-only+block + separate reviewed regen** | **detect-only (decouple)** | RE-DECIDED 2026-06-01 after backend-architect P0: self-heal ships an unreviewed LLM-generated 46KB edition into a permanent tag → 14 projects, gated only by a coverage check (not correctness). Decouple keeps unreviewed AI content out of tagged releases, matches the user's literal "detect→hard-block" + the Epic's own original "regeneration as remediation path". Common case (no drift) is still silent-pass ≤5min; review only when drift exists (exactly when you want it). |
| 2 | layer2-audit name drift | fix in P3 / separate express | **fix in P3** | Already editing audit/release infra; root-fix the recurring 2026-05-27 drift. User 2026-06-01. |
| 3 | Regen tool at release | codex exec / claude -p | **codex exec** | P2 Gate-4: claude -p FAILs on 326KB (analysis not file); codex exec PASS 175s. |

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/codex-parity-phase3-releasegate/code-reviewer.md
  - .tad/evidence/reviews/blake/codex-parity-phase3-releasegate/backend-architect.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict marker
completion: .tad/active/handoffs/COMPLETION-20260601-codex-parity-phase3-releasegate.md
artifacts:
  - .tad/hooks/lib/codex-parity-check.sh (graduated)
  - .claude/skills/release-runbook/SKILL.md (gate wired)
  - .claude/skills/alex/SKILL.md (publish_protocol gate)
  - .tad/hooks/lib/layer2-audit.sh (name-drift fixed)
  - dogfood paste (8a block path + 8b regen e2e + 8c partial-fail safety) in COMPLETION
knowledge_updates: project-knowledge entry if the detect-only wiring / decouple decision reveals a new pattern
```
