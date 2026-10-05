---
gate: 3
layer: 2
group: 0
role: spec-compliance-reviewer
handoff: /home/box/云同步/TAD/.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md
task_id: TASK-20260908-KNOWLEDGE-SEAM-ISOLATION
date: 2026-09-09
verdict: PASS
counts: { P0: 0, P1: 0, P2: 1, pass_rows: 19, fail_rows: 0 }
---

# Gate 3 Layer 2 Group 0 — Spec Compliance Review: Knowledge Seam Isolation

**Reviewer**: Independent Layer 2 Group 0 spec-compliance-reviewer (did NOT author the implementation; read-only review — no implementation files modified).
**Primary source**: Handoff §9.1 Spec Compliance Checklist (AC1.1–AC8.3), verified row-by-row against the live tree at `/home/box/云同步/TAD`.
**Method**: Every cheap verification re-executed by the reviewer in isolated temp dirs (`mktemp -d`); the live workspace was never mutated except for the mandated AC3.1 generator run, whose output (`.tad/brain-index.md`, a derived artifact) was the required evidence itself, and the AC6.2 stale-touch probe, which used the handoff-specified backup/restore (verified restored; `git status` shows no other reviewer-caused changes).

## Row-by-row results (§9.1 is authoritative)

| # | Row | Result | Evidence |
|---|-----|--------|----------|
| AC1.1 | derive-sync-set.sh declares brain-index.md in TOP_DENY | **PASS** | `.tad/hooks/lib/derive-sync-set.sh:77-78`: `TOP_DENY="sync-registry.yaml`<br>`brain-index.md"` — `grep -F` matches inside TOP_DENY block |
| AC1.2 | tad.sh declares brain-index.md in TAD_TOP_DENY | **PASS** | `tad.sh:575-576`: identical multiline `TAD_TOP_DENY` block |
| AC1.3 | derive_framework_top_files uses set membership | **PASS** | `tad.sh:610`: `printf '%s\n' "$TAD_TOP_DENY" \| grep -Fxq "$bn" && continue`; comment at `tad.sh:603` updated to "the excluded files" (plural). No scalar `[ "$bn" = ... ]` remains |
| AC1.4 | Behavioral top-file probe (main-free loader) | **PASS** | Literal handoff command executed verbatim → `RC=0` (brain-index.md + sync-registry.yaml excluded, version.txt included) |
| AC1.5 | `tad.sh --verify-denylist` passes | **PASS** | Exit 0: "tad.sh inlined DENY_LIST == derive-sync-set.sh (17 entries)" |
| AC2.1 | Clean install creates Option A structure | **PASS** (via cd-form; see deviation a) | `(cd $TMPD && bash $SRC/tad.sh --source $SRC --platform both --yes)`: README.md present; `patterns/` + `incidents/` exist; pk root contains exactly README+2 dirs; 0 `*.md` in subdirs; no `principles.md` leak |
| AC3.1 | brain-index-gen.sh runs to completion | **PASS** | Exit 0, "brain-index.md generated: 278 lines". All 8 grep sites wrapped as `{ grep ... 2>/dev/null \|\| true; }` (lines 94,136,157,175,178,213,229,252) + find grouping parens at line 172 + `task_type` defaults (line 137 `:-unknown`, line 176 `[ -z ... ] && ...="unknown"`) |
| AC3.2 | Archived cap (50) with complete fields | **PASS** | Literal command: count = **50** (≥50 ✅); archived HANDOFF rows contain no `\|\s*\|` empty cells and no `(see file)` |
| AC4.1 | `--help` documents `--quarantine-pk` | **PASS** | `bash tad.sh --help \| grep -F -- "--quarantine-pk"` matches with description; parser at `tad.sh:328-332`, help text at `tad.sh:374` |
| AC4.2 | quarantine script syntax + executable | **PASS** | `-rwxr-xr-x`, `bash -n` clean |
| AC4.3 | Fixture: README + modified files preserved | **PASS** | Literal fixture → README.md + custom.md intact. **Beyond-spec positive path also verified**: byte-identical `frontend-design.md` moved to `quarantine-framework-pk-20260909-002344/`, locally-modified `my-notes.md` preserved with "User-modified knowledge preserved" log, MANIFEST.md matches mandated schema (`\| Original File \| Sha256 \| Action \| Reason \| Timestamp \|`) |
| AC4.4 | Idempotency on clean tree | **PASS** | Literal fixture → "0 files quarantined", no `.tad/archive` created, exit 0 (lazy `mkdir` only on first quarantine, lines ~113-119) |
| AC5.1 | Project-owned skill preservation (3 quoting forms) | **PASS** (via cd-form; see deviation a) | Bare / single-quoted / double-quoted `ownership: project-owned` skills (c1/c2/c3) + `local/keep.txt` all survive re-sync; fresh-install `local/` seeds (`_example.md`, `_index.md`) intact. Guards present in BOTH loops: primary `tad.sh:1185-1193`, secondary (Codex path) `tad.sh:1296-1302`, same `grep -qE '^[[:space:]]*ownership:[[:space:]]*["'\'']?project-owned["'\'']?'` regex |
| AC6.1 | Distillation Step 6 soft trigger (both trees) | **PASS** | Literal stateful-awk probe matches in both `.claude/.../distillation-loop-protocol.md` and `.agents/...` mirror, with `>/dev/null 2>&1 \|\| true`. Acceptance-protocol step4f likewise soft (`blocking: false`, `tad.sh`-side prose "never blocks Gate 4") at line ~181 in both mirrors |
| AC6.2 | Doctor freshness WARN-only, exit 0 | **PASS** | Literal backup/touch probe: "⚠️ brain-index.md is older than project-knowledge..." printed, `doctor-exit=0`, live file byte-restored. Doctor code at `tad.sh:2100-2112` has no failure path; tad-maintain Step 1.6 CHECK=WARN-only / SYNC=auto-rebuild confirmed in both mirrors |
| AC7.1 | Dual-platform parity | **PASS** | `bash .tad/hooks/lib/release-verify.sh parity .` → "parity PASS (exit 0)"; pairwise `diff -q` confirms distillation/acceptance/maintain mirrors byte-identical |
| AC8.1 | update path never calls quarantine | **PASS** | `sed -n '/"update")/,/;;/p' tad.sh \| grep -F quarantine-framework-pk` → empty (RC=1) |
| AC8.2 | No Gate 3/4 block on freshness | **PASS** | `grep -rn brain-index .tad/gates/ pre-gate-check.sh pre-accept-check.sh \| grep -i block` → empty (RC=1) |
| AC8.3 | Zero framework-principles.md / provenance | **PASS** | `ls .tad/project-knowledge/framework-principles.md` → "No such file or directory" |

## Intentional deviations (Blake-declared) — assessment

- **(a) No positional target-dir arg; cd-form used.** CONFIRMED REAL: literal form fails with `tad.sh: unknown option '/tmp/...' (use --help)` (RC=1). The cd-form `(cd "$TMPD" && bash "$SRC/tad.sh" --source "$SRC" --platform both --yes)` is semantically identical (installer targets cwd), and every AC2.1/AC5.1 assertion passed under it. **Intent-preserving — accept.**
- **(b) `local/` skip scoped to existing trees** (`[ "$skill_name" = "local" ] && [ -e ... ]`, `tad.sh:1185`). CONFIRMED NECESSARY: unconditional skip would drop the fresh-install `local/` seeds the post-install self-check requires (verified seeds install: `_example.md`, `_index.md`); scoping preserves both fresh-seed and re-sync-preserve intents, and the AC5.1 ownership-branch proof passes. **Intent-preserving — accept.**
- **(c) `--quarantine-pk` dispatch via script dir** (`_qp_self_dir="$(cd "$(dirname "$0")" && pwd)"`, `tad.sh:330-331`). CONFIRMED NECESSARY: bare relative `.tad/hooks/...` cannot resolve when cwd=$TMPD (the AC4.3/AC4.4 fixtures prove the dispatch works from a foreign cwd). **Intent-preserving — accept.**

## Findings

- **P0 (blocking)**: none.
- **P1 (should fix)**: none.
- **P2 (nit, 1)**: `## Active Handoffs` table emits empty Summary cells for the two newest handoffs (`HANDOFF-20260908-knowledge-seam-isolation.md`, `HANDOFF-20260908-release-v2443.md`) because neither file contains a `### 1.1` heading (verified `grep -c '^### 1.1'` = 0 in both), which is the active-table summary source. Pre-existing generator limitation, NOT a Blake regression; outside the §9.1 AC3.2 scope (archived table only, which fully passes). Suggestion: reuse the archived path's `basename` fallback for empty active summaries.

## Coverage notes (non-§9.1, for completeness)

- Task 4 upgrade/migrate README guards present verbatim in both routines (`tad.sh:2841-2845`, `tad.sh:2925-2929`); additionally verified that a customized pk README survives a re-run install (no clobber observed).
- Task 5 portable hash (`sha256sum` → `shasum -a 256` fallback, lines 28-33), strict pk-only scope, README exclusion (line 107) all confirmed in code and behaviorally.
- `.tad/project-knowledge/README.md` modernization is modified per `git status` (target-file list item; no §9.1 row — no assertion required).

**VERDICT: PASS** (19/19 §9.1 rows PASS; 0 P0; 0 P1; 1 P2)
