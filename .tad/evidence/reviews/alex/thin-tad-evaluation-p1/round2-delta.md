# Incremental review packet — v1.0-draft → v1.1-review

Round 1 full reasons are preserved in round1-experiment.md and round1-execution.md. This packet describes edits, not a new overall review request.

| Fix | Before | After / full changed section to read |
|---|---|---|
| E1/C1 | source root implicit; existence-only | §4.2 canonical parent root + static allowlist + lstat/realpath + sources manifest/hash; §7 manifest location |
| C2 | six-file source limit ambiguously covers all reads | §3.2 distinguishes external-history from pinned TAD git-object roots and reference closure |
| E2 | 12 cases undifferentiated after H calibration | §4.3 H calibration-only, V minimal-input new author; §4.4/4.5 evaluation_role; §6.2 sequencing; Epic final refinements |
| E3/C5 | builder oracle checked after rehearsal | §4.4 independent blind requirement derivation before seeing oracle, approval/freeze before any arm rehearsal, manifest expected non-authoritative; §6.2 order |
| E4/E5 | whole-chain/fairness shorthand | §4.2/4.3 + §6.2/9.1 offline-only/freeze-provenance wording and reviewer-approved applicability |
| C3 | no model/network prose only | §4.2 static import and strict git-only execFile policy plus rejection tests; §4.4 no arbitrary artifact import/execution |
| C4 | commit/lifecycle split implicit | §3.2 explicit tool-only staged list; all lifecycle/evidence stay uncommitted; verify implementation SHA and working tree separately |
| Alex MQ6 correction | mislabeled MQ6 as executability | §5 restores technical research question; official Node/Promptfoo links, no SDK/version claims relied upon |

For incremental review read ONLY: Handoff §3, §4, §5, §6, §7 and §9.1 (full text of changed sections), plus these round1 reason files and this delta. Do not reread unchanged handoff sections or free-explore projects.
Determine whether each original P0 is closed and whether the changes conflict within those touched sections. Maximum second round: new issues are P1 for human disposition; no third iteration loop. Return PASS/CONDITIONAL PASS/FAIL with unresolved original P0 list.
