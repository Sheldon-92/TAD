# Spec-Compliance Review: Pack System Unification Phase 1

**Reviewer**: spec-compliance-reviewer (independent sub-agent)
**Date**: 2026-06-11
**Handoff**: HANDOFF-20260611-pack-system-unification-phase1.md
**Commit**: 0d965bb

---

## Methodology

Every raw verification command from the handoff section 9.1 was executed independently by this reviewer. Results were compared against the expected evidence. The anchor map and ac-outputs.txt were read and cross-checked.

---

## AC Verification Results

| AC# | Criterion | Status | Evidence |
|-----|-----------|--------|----------|
| AC1 | No active files under `.tad/domains` except retired marker | SATISFIED | `.tad/domains/` contains only `README-retired.md`. 9 YAML packs + 2 guide docs + template + test moved to `.tad/archive/domains/2026-06-11-domain-pack-retirement/`. Raw command exits 0. |
| AC2 | Domain Pack SessionStart injection removed | SATISFIED | `rg` finds zero matches for `DOMAIN_DETAIL`, `Domain Pack [`, or `To use: read .tad/domains` in `startup-health.sh`. The 47-line Domain Pack scan block was cleanly removed. |
| AC3 | Old router active artifacts retired from `.tad/hooks` | SATISFIED | All four files (`userprompt-domain-router.sh`, `keywords.yaml`, `keywords.yaml.draft`, `generate-keywords.sh`) confirmed absent from `.tad/hooks/`. Anchor map notes these were already deleted in v2.17.0, so AC3 correctly reports `test ! -e` = true. |
| AC4 | `.tad/domains` not in active sync/portable/bundle surfaces | SATISFIED | `derive-sync-set.sh --dirs .` output does not contain `domains`. `rg` finds no `.tad/domains` or `domains/` hits in `portable-extract.sh`, `portable-rules.md`, or `codex-tad-bundle`. The `codex-tad-bundle/.tad/domains/` directory was fully removed. |
| AC5 | No YAML Domain Pack active guidance in runtime/protocol/doc surfaces | SATISFIED | The AC5 raw command (11 forbidden patterns across 12 search surfaces) returns zero matches. Broader `rg "Domain Pack"` sweep found only clearly historical or "retired/archived" references in config.yaml changelog, README release history, and capability-upgrade/design-protocol transitional notes. These are correctly classified as historical per FR7 and the anchor map. |
| AC6 | T2 references exist for hw archive and supply-chain-security archive | SATISFIED | Both `.tad/skill-library/tad--hw-domain-archive.md` and `tad--supply-chain-security-archive.md` exist with complete content (source files, what to reuse, what not to reuse, upgrade criteria). Index `_index.md` has both entries at lines 9-10. |
| AC7 | Migration/deprecation metadata targets downstream `.tad/domains` removal | SATISFIED | `.tad/deprecation.yaml` contains `domain-pack-retirement` marker (line 135) and lists `.tad/domains` file paths (lines 137-147) with downstream removal instruction (line 151). Both the marker and the target path are present as required by the strengthened AC7. |
| AC8 | Phase 1 did not modify Capability Pack installer behavior | SATISFIED | `git diff HEAD~1 --name-only` shows zero files under `.tad/capability-packs/`. No staged, unstaged, or untracked `install.sh` files found. NFR1 fully met. |
| AC9 | Claude/Codex touched counterpart files in parity | SATISFIED | `diff -q` returns identical for all 11 counterpart pairs: blake/SKILL.md, release-runbook/SKILL.md, alex/SKILL.md, research-notebook/SKILL.md, capability-upgrade/SKILL.md, and all 6 alex/references files. NFR2 fully met. |
| AC10 | Startup health runs and emits valid TAD summary without Domain Pack text | SATISFIED | `printf '{"source":"startup"}' | bash startup-health.sh` produces valid JSON with `hookSpecificOutput` containing TAD version summary. `rg "Domain Pack\|\.tad/domains"` on the output returns zero matches. |
| AC11 | Archive manifest exists and points to archived source files | SATISFIED | `README.md` exists at the expected archive path. Contains `hw-circuit-design` (line 14), `supply-chain-security` (line 26), and `migrate-on-demand` policy section header (line 32). Manifest lists all 9 YAML packs + 2 guide docs + what-not-to-reuse guidance. |
| AC12 | Completion evidence includes anchor map and raw AC outputs | NOT_SATISFIED | `anchor-map.tsv` (44 rows, 6 columns) and `ac-outputs.txt` (11 ACs) exist. However, the COMPLETION report (`COMPLETION-20260611-pack-system-unification-phase1.md`) does NOT exist yet. The raw command `test -f .tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase1.md` fails. Additionally, `ac-outputs.txt` contains only bare `PASS` labels without raw command output, which does not meet the handoff requirement for "raw section 9.1 command outputs." |

---

## FR/NFR Cross-Check

| Requirement | Status | Notes |
|-------------|--------|-------|
| FR1: Archive active Domain Packs | MET | 9 YAML + 2 guides + template + test archived with README manifest |
| FR2: Remove SessionStart injection | MET | 47-line block removed from startup-health.sh |
| FR3: Retire domain-router artifacts | MET | Already absent (v2.17.0 deletion); AC3 confirms |
| FR4: Remove from sync/portable/bundle | MET | derive-sync-set, portable-extract, portable-rules, codex-tad-bundle all clean |
| FR5: Rewrite Alex/Blake protocols | MET | 124-line reduction in design-protocol.md alone; all SKILL.md files updated |
| FR6: Create T2 skill-library references | MET | Both T2 notes created with complete structure |
| FR7: Preserve historical evidence | MET | Zero deletions from `.tad/evidence/` or `.tad/archive/` (only additions). README changelog rows preserved. config.yaml historical entries tagged `[RETIRED]` |
| NFR1: No Capability Pack installer changes | MET | Zero files touched under `.tad/capability-packs/` |
| NFR2: Claude/Codex parity | MET | All 11 counterpart pairs byte-identical |
| NFR3: No new permanent hooks | MET | No new hooks or settings enforcement added |
| NFR4: Verification commands distinguish live vs historical | MET | AC5 patterns target active guidance strings specifically; historical/retired references pass correctly |
| NFR5: Archive/migration rationale explicit | MET | deprecation.yaml entry + archive README + T2 references provide clear rationale |

---

## Quality Observations

### Positive

1. **Anchor map thoroughness**: 44 entries covering all expected live reference surfaces with classification and action for each. This is high-quality pre-implementation planning evidence.

2. **Claude/Codex parity**: Perfect byte-identical parity across all 11 counterpart files. This is the strongest form of NFR2 compliance.

3. **Archive manifest quality**: The archive README includes not just the file list but a migrate-on-demand policy, T2 reference pointers, and a "what NOT to reuse" section -- genuinely useful for future consumers.

4. **Deprecation metadata**: The `deprecation.yaml` entry lists individual file paths (not just the directory), includes downstream removal instructions, and is properly versioned under `2.30.0`.

5. **Historical reference handling**: Remaining "Domain Pack" strings in config.yaml changelog and README release history are correctly preserved with `[RETIRED 2026-06-11]` annotations rather than deleted, exactly matching FR7.

### Concerns

1. **AC12 completion report missing**: This is expected if the review is happening before the completion report is written (the completion report typically references this review). This is a sequencing issue, not an implementation deficiency.

2. **ac-outputs.txt is thin**: The file contains only `=== AC# === / PASS` entries with no raw command output. The handoff section 8.6 requires "Raw section 9.1 command outputs" and section 6 requires "Raw section 9.1 command outputs and include raw outputs in completion report." The current file lacks the actual command output that would make it independently verifiable. This should be enriched with the actual stdout/stderr from each command.

---

## Issue Summary

### P0 Issues: 0

(None)

### P1 Issues: 1

1. **AC12 NOT_SATISFIED -- Completion report not yet created**: `COMPLETION-20260611-pack-system-unification-phase1.md` does not exist. This is likely a sequencing issue (review before completion), but it means AC12 cannot pass until the completion report is written with the required sections (`Anchor Map`, `AC1`, `AC12`, `Friction Status`, `Knowledge Assessment`).

### P2 Issues: 1

1. **ac-outputs.txt lacks raw command output**: The evidence file contains only PASS/FAIL labels without the actual command stdout that section 8.6 requires. This makes the evidence non-independently-verifiable. Recommendation: re-run section 9.1 commands and capture full output to the file.

---

## Overall Verdict

**NOT_SATISFIED count**: 1 (AC12 -- completion report not yet created)
**PARTIALLY_SATISFIED count**: 0
**P0 count**: 0
**P1 count**: 1

**Verdict**: CONDITIONAL PASS

AC1-AC11 are all independently verified SATISFIED by this reviewer. The single NOT_SATISFIED (AC12) is due to the completion report not existing yet, which is a sequencing issue -- this review is itself part of the evidence that the completion report will reference. Once the completion report is created with the required sections, AC12 will be SATISFIED and the overall verdict will be PASS.

The P2 on thin `ac-outputs.txt` evidence does not block Gate 3 but should be addressed for audit trail completeness.

---

**Reviewed by**: spec-compliance-reviewer
**Date**: 2026-06-11
