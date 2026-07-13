# Phase 1 Design Review — Backend/Systems Architecture Lens

**Handoff:** HANDOFF-surplus-o1-landscape-refresh-2026q3.md
**Reviewer domain:** Backend architecture (auto-detected — Files to Modify = 1 YAML registry edit + 1 markdown findings create; no frontend/API/auth files → default backend/systems review)
**Date:** 2026-07-05
**Scope reviewed:** §4 Technical Design, §5 MQ3/MQ5 (data-flow + state-sync), §6 Micro-Tasks/Phases, §9.1 AC verification design, §3 NFRs, §8.4 Friction. Focus: architecture quality, blast radius, design completeness.
**Grounding:** REGISTRY.yaml L54-61 (fields ordered notebook_id/topic/created/status@58/last_queried@59/source_count@60/notes@61), OBJECTIVES.md L8-19 (O1 KR1-3 all 🔄), CLI binary present at `~/.tad-notebooklm-venv/bin/notebooklm`.

---

## Overall Assessment

The workflow is a clean single-chain pipeline with genuinely good discipline: explicit `-n <id>` everywhere (avoids `use` global-state pollution), one-way cloud→local sync deferred to the end (no double-write window), a well-designed "same-artifact, downgraded-evidence-tag" degradation path, and a locked change scope. The failure that keeps this from being fully sound is **mutation idempotency**: `source add` writes to a *persistent, canonical, shared* knowledge base (the 45-source KB that is O1's designated instrument), and the design has no guard against duplicate injection — which its own retry rule (NFR4) can trigger even on the happy path. Secondary issues are verification-integrity gaps in two ACs and a state-reconciliation shortcut that contradicts the handoff's own "cloud is truth" principle.

**Verdict: CONDITIONAL** — fix P0 before implementation; P1s are verification-correctness fixes that should land in the AC rows.

---

## P0 — Must fix before implementation

### P0-1: Non-idempotent `source add` + NFR4 retry can permanently duplicate sources in the canonical KB
- **Where:** FR2 / Micro-task 3 (`source add -n ... <url>` ×≥5) combined with NFR4 ("CLI 调用失败先重试 1 次再判定失败").
- **Problem:** `source add` is a mutating write to NotebookLM cloud, the declared source of truth (registry header L3, MQ5). It is not idempotent and the design never checks whether a URL is already present before adding. NFR4 mandates a retry on CLI-call failure — but a `source add` that fails *ambiguously* (network timeout after the server accepted the write) will, on retry, add the same URL a **second** time. This is a concrete duplicate-injection path in the single-pass happy flow, not just on full re-run. On a YOLO re-run of Phase A it is worse: preflight passes, then all 5 adds fire again → 10 sources.
- **Blast radius:** The 45-source KB is a long-lived asset feeding all future O1 deep-asks. Duplicate sources are (a) not removed by any step in this handoff (no `source remove`), (b) silently degrade future cross-source synthesis (the same claim double-weighted), and (c) make `source_count` diverge from the intended arithmetic. This mutates a shared canonical asset with no undo in-scope — the definition of an irreversible blast-radius miss.
- **Fix:**
  1. Make add idempotent: before adding, list existing source URLs and skip any URL already present (dedup pre-check).
  2. Do **not** blindly retry `source add` under NFR4. Scope NFR4's retry to *read/idempotent* calls (`source list`, `ask`). For `source add`, on failure re-list first and only add URLs still missing.
  3. Add an AC that asserts no duplicate source URLs exist post-add (e.g., list URLs, `sort | uniq -d` must be empty), so a duplicate is caught at Gate 3 rather than shipped.

---

## P1 — Should fix

### P1-1: AC5 counts matching *lines*, not distinct KRs — can false-FAIL a fully-compliant assessment
- **Where:** §9.1 AC5 — `sed -n '/## O1 KR Status Assessment/,/^## /p' FINDINGS | grep -c 'KR[123]'`, expected ≥3.
- **Problem:** `grep -c` counts matching **lines**, not occurrences. A perfectly compliant assessment that writes one summary line — e.g. `Across KR1, KR2, KR3 the evidence now shows…` — matches on a single line → `grep -c` returns **1** → AC5 FAILS despite full KR1/KR2/KR3 coverage. Conversely, three lines each repeating `KR1` would return 3 with zero coverage of KR2/KR3 → false PASS. The AC measures the wrong thing.
- **Fix:** Assert distinct-KR coverage: `... | grep -oE 'KR[123]' | sort -u | wc -l` must equal 3. This counts unique KR tokens regardless of line layout and cannot be gamed by repetition.

### P1-2: State-divergence window + arithmetic `source_count` contradicts "cloud is truth"
- **Where:** FR5 / §4.3 data model (`source_count: 45 + 新增数`) and MQ5 (registry updated only at FR5, end of run).
- **Problem (two coupled defects):**
  1. **Divergence window:** the registry is updated *only* at the final step. If the run aborts after `source add` succeeds but before FR5 (ask fails, findings write fails, process killed), cloud shows 50 while registry still says 45/dormant — a silent inconsistency with **no reconciliation step** and no idempotent recovery (compounds P0-1 on re-run).
  2. **Arithmetic vs actual:** `source_count` is written as `45 + N` rather than read from the actual `source list` output. This violates the handoff's own MQ5 principle ("cloud → local, cloud is Source of Truth"). If any add was silently rejected/deduped by NotebookLM, or the 45 baseline drifted since 2026-05-31, the registry now asserts a count the cloud does not have. AC11 separately counts the *actual* list — so AC9 (arithmetic) and AC11 (actual) can disagree.
- **Fix:** Derive `source_count` from the post-add `source list` actual count (single source of truth), and have FR5 set it to that measured value — never `45+N`. Add a short "if aborted after add, re-run is dedup-safe and registry reconciles to actual list count" note so partial failure self-heals. Capture the *actual* baseline count at preflight (Micro-task 1) instead of assuming 45.

---

## P2 — Consider

### P2-1: AC8 scope allowlist omits the YOLO evidence dir the workflow itself writes to
- **Where:** §9.1 AC8 — `git status --porcelain | grep -vE '(framework-landscape|research-notebooks/REGISTRY.yaml|\.tad/evidence/traces/|\.tad/active/)' | wc -l`, expected 0.
- **Problem:** The YOLO workflow writes design-review / impl-review / completion artifacts into `.tad/evidence/yolo/surplus-o1-landscape-refresh-2026q3/` (this very file lives there). That path is **not** in the allowlist, so any untracked file there at Gate-3 time is counted as an out-of-scope violation → false FAIL of a correctly-scoped run. The completion-report location (if under evidence/yolo or a report dir) has the same exposure.
- **Fix:** Add `\.tad/evidence/yolo/` (and the completion-report path, if separate) to the AC8 allowlist. The intent — "no pack/skill changes" — is preserved; the allowlist just needs to cover the workflow's own bookkeeping surface.

### P2-2: AC11 verification method is non-deterministic ("计数其输出条目")
- **Where:** §9.1 AC11 — run `source list` and "count its output entries" ≥50.
- **Problem:** Every other AC pins an exact `grep -c`/`test`/`sed` command; AC11 relies on a human eyeballing/counting `source list` output whose line format is unspecified (wrapping, headers, multi-line entries). Under YOLO (Conductor stands in for the human) this is the weakest, least reproducible gate — exactly the "validation theater" risk called out in principles.md (2026-05-15).
- **Fix:** Pin a deterministic count command matched to the actual `source list` output shape (e.g., count lines matching a stable per-source marker/URL prefix), so the ≥50 assertion is machine-checked like the rest.

### P2-3: Hardcoded 45 baseline has no drift check
- **Where:** §2.2 / §4.3 / AC11 threshold (≥50 = 45+5).
- **Problem:** `45` and the derived `≥50` threshold assume the cloud notebook is unchanged since 2026-05-31. If sources were added/removed out-of-band, both the arithmetic and the ≥50 gate are wrong (ties into P1-2). Low likelihood, but there is no assertion of the pre-add baseline.
- **Fix:** At preflight, record the *actual* current source count as the baseline and define the post-add threshold as `baseline + (#unique new URLs added)` rather than the literal 50.

---

## What the design gets right (keep)
- Explicit `-n <id>` on every call + explicit ban on `notebooklm use` — correctly isolates from the `active_notebook: agent-computer-control` global state (verified real in REGISTRY.yaml L7). Strong blast-radius containment.
- One-way cloud→local sync deferred to a single end-of-run write — no double-write inconsistency window by construction (the divergence in P1-2 is an *abort*-path gap, not a steady-state one).
- Degradation path designed as "same artifact, downgraded evidence tag, status stays dormant" — refuses to let the registry lie about a KB that was never reactivated (§11.1). Architecturally honest.
- `--new` conversation isolation per round — prevents cross-round context/citation bleed.
- Change scope locked to 2 paths + grounding recorded in §7.3 against real files.

---

## Summary
- **P0 (1):** `source add` is a non-idempotent write to a canonical shared KB; NFR4 retry + no dedup pre-check can permanently duplicate sources with no in-scope undo.
- **P1 (2):** AC5 line-count measures the wrong thing (false-FAIL/false-PASS on KR coverage); arithmetic `source_count` + end-only registry write contradict the "cloud is truth" principle and leave an unreconciled abort-divergence window.
- **P2 (3):** AC8 allowlist omits the YOLO evidence dir; AC11 count is non-deterministic; hardcoded 45 baseline unverified.

Fix P0-1 (dedup + scoped retry + duplicate AC) and fold P1-1/P1-2 into the AC rows before Blake implements.
