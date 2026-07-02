# Golden Set Index

> Trajectory Eval Harness Phase 1 — golden set for judge calibration.
> DRAFT labels — require human confirmation at Gate 4 (blind-label review).

| # | File | Slug | Period | task_type | label_class | UNRECOVERABLE dims | Notes |
|---|------|------|--------|-----------|-------------|--------------------|-------|
| GS-01 | GS-01-multi-platform-init.md | multi-platform-init | early (01-26) | N/A | known-good | D1,D3,D4,D5 | Pre-frontmatter era |
| GS-02 | GS-02-cognitive-firewall.md | cognitive-firewall | early (02-06) | N/A | known-good | D1,D3,D4,D5 | Pre-frontmatter era |
| GS-03 | GS-03-plain-language-after-handoffs.md | plain-language-after-handoffs | mid (04-14) | yaml | known-bad | — | Express 4 P0 |
| GS-04 | GS-04-openharness-domain-pack-upgrade.md | openharness-domain-pack-upgrade | mid (04-03) | yaml | known-good | D1,D3,D4,D5 | No completion |
| GS-05 | GS-05-security-tool-research.md | security-tool-research | mid (04-03) | research | known-good | D4 | Research task |
| GS-06 | GS-06-notebooklm-source-preprocessor.md | notebooklm-source-preprocessor | mid-late (05-09) | code | known-bad | — | Silent-bad (bugfix later) |
| GS-07 | GS-07-codex-spike-phase0.md | codex-spike-phase0 | mid-late (05-01) | research | mixed | — | Code-reviewer 3 P0 |
| GS-08 | GS-08-tad-lean-trustworthy-phase5.md | tad-lean-trustworthy-phase5 | mid-late (05-31) | code | known-good | — | YOLO phase |
| GS-09 | GS-09-sep-phase2.md | sep-phase2 | recent (06-10) | mixed | known-bad | — | Claims-without-carriers |
| GS-10 | GS-10-surplus-scan-phase1.md | surplus-scan-phase1 | recent (06-07) | mixed | known-bad | — | Validation theater |
| GS-11 | GS-11-universal-gate-ac-driven.md | universal-gate-ac-driven | recent (06-07) | code | known-good | — | Exemplary execution |
| GS-12 | GS-12-knowledge-redesign-p1-foundation.md | knowledge-redesign-p1-foundation | recent (06-22) | mixed | known-good | D1,D3,D4,D5 | YOLO (no std completion) |

## Composition Summary

| Category | Count | Requirement | Status |
|----------|-------|-------------|--------|
| Total trajectories | 12 | ≥10 | ✅ |
| known-bad | 4 (GS-03, GS-06, GS-09, GS-10) | ≥2 | ✅ |
| silent-bad (subset of known-bad) | 1 (GS-06) | ≥1 | ✅ |
| known-bad with intermediate scores (2-3) | 1 (GS-10: D1=3, D3=3) | ≥1 | ✅ |
| Non-all-green gate history | 4 (GS-03, GS-06, GS-09, GS-10) | ≥3 | ✅ |
| mixed | 1 (GS-07) | — | — |
| known-good | 7 | — | — |
| Distinct task_types | 5 (N/A, yaml, research, code, mixed) | — | — |
| Distinct periods | 4 (early, mid, mid-late, recent) | — | — |

## Human Confirmation Status

human_confirmed: false
blind_label_divergences: (pending Gate 4)
human_modifications: (pending Gate 4)
