# PM checkpoint — Gate 2 Handoff Amendment (knowledge-seam-isolation)

- date: 2026-09-08
- role: Alex (Solution Lead, Terminal 1)
- channel: cursor
- model: gemini-3.8-flash-medium
- handoff: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md`
- status: `READY_FOR_GATE2`

## 1. Summary of Actions
Per PM / Human instructions, Alex amended `HANDOFF-20260908-knowledge-seam-isolation.md` to clear ALL P0 blocking issues from both Gate 2 reviews (Scope P0=3, Spec P0=5, total 8 P0 items cleared):

1. **AC1 / Granularity Mismatch (Scope P0-1, Spec P1-3)**:
   - Added direct dual-file assertions for `brain-index.md` and `sync-registry.yaml` in `TOP_DENY`.
   - Added behavioral probe testing `derive_framework_top_files()` logic to ensure `brain-index.md` and `sync-registry.yaml` are excluded while `version.txt` is retained.
   - Retained `bash tad.sh --verify-denylist` as regression companion.

2. **`TAD_TOP_DENY` Representation Trap (Scope P0-2, Spec P0-2)**:
   - Specified multi-value newline block representation for `TAD_TOP_DENY` in `tad.sh` and `TOP_DENY` in `derive-sync-set.sh`.
   - Updated consumer from scalar equality `[ "$bn" = "$TAD_TOP_DENY" ]` to set-membership `printf '%s\n' "$TAD_TOP_DENY" | grep -Fxq "$bn" && continue`.
   - Mandated sibling-pinning assertions (`sync-registry.yaml` remains excluded).

3. **Quarantine Seed `README.md` Exclusion (Scope P0-3, Spec P0-3)**:
   - Added explicit constraint in §1 Forbidden, §3 Task 5, and §4 AC4: `quarantine-framework-pk.sh` must NEVER quarantine or touch `.tad/project-knowledge/README.md`.
   - Confirmed scope is strictly limited to `.tad/project-knowledge/`.

4. **`tad.sh --quarantine-pk` CLI Wiring (Spec P0-4)**:
   - Added Task 5 requirements for `tad.sh` CLI option parser (`--quarantine-pk`), `--help` text, and dispatch logic.

5. **`## 9.1 Spec Compliance Checklist` (Spec P0-1)**:
   - Populated complete 6-column table with 12 AC rows, runnable shell verification commands, expected evidence, and step1d raw outputs (preventing `Spec_Compliance_Empty_Guard` block at Gate 3).

6. **Required Evidence Manifest (Spec P0-5)**:
   - Added §10 YAML block declaring required reviewer reports and test logs.
   - Enforced slug consistency contract matching `knowledge-seam-isolation`.

7. **Critical P1 Gaps Addressed**:
   - Enumerate all 7 pipefail sites in `brain-index-gen.sh` with protective `{ grep ... || true; }` wrappers and default variable fallbacks.
   - Exhaustively listed dual-tree platform mirrors (`.claude/` and `.agents/`).
   - Added portable hash helper (`sha256sum` / `shasum -a 256`).
   - Robustified `ownership: project-owned` YAML regex to support bare, single, and double quotes.
   - Formally designated provenance-tagging as OUT-OF-SCOPE per locked Option A.
   - Added negative assertions (quarantine is not invoked on update; knowledge freshness is WARN-only).

## 2. Next Steps
Handoff status is updated to `READY_FOR_GATE2` (Rev 2). Ready for Gate 2 re-review by PM / independent reviewers. Do NOT activate Blake until Gate 2 achieves dual PASS.
