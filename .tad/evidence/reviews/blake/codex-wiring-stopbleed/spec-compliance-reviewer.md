# Codex Wiring Stopbleed — Layer 2 Spec Compliance Review

**Reviewer:** independent Blake Layer 2 reviewer
**Handoff:** `.tad/active/handoffs/HANDOFF-20260803-codex-wiring-stopbleed.md`
**Verdict: PASS**

The scoped implementation diff was reviewed against handoff sections 3–5,
the pre-edit baseline, and both Spike reports. No product file was modified by
this review.

## AC0–AC9 evidence map

| AC | Independent evidence | Result |
|---|---|---|
| AC0 | `spike-b-report.md` records Claude Code 2.1.220 and Codex 0.146.0 direct-read paths/tool sequences, with no Glob/search fallback in the decisive runs. A fresh path-shaped resolver check found 76 declarations and `missing=0` across both trees. | PASS |
| AC1 | `spike-a-report.md` contains the real trusted-scratch session transcript with `unknown field \`SessionStart\`` and the expected `description`/`hooks` parse signature. The normal candidate session has no parse warning; bypass-trust was recorded only as a separate contrast. | PASS |
| AC2 | Current scratch `.codex/hooks.json` and repository `.codex/hooks.json` compare byte-for-byte (`cmp` exit 0, md5 `89e4164d3a56f15efa251767e48dd4e8`); `jq` parsing and hook-shape assertions pass. A current isolated Codex candidate session exited 0 with no hooks parse warning. | PASS |
| AC3 | Extracting the heredoc delimited by `HOOKS_EOF` from `tad.sh` yields 28 lines and compares byte-for-byte with `.codex/hooks.json` (`cmp` exit 0, same md5). | PASS |
| AC4 | `grep -rn 'reference: ".claude/skills'` returns zero. The resolver check covers nested markdown references, resolves relative paths from each skill directory and `.tad/` paths from the repository root, and reports 38 path-shaped refs/tree with zero missing. | PASS |
| AC5 | Against baseline commit `e5b810d7ab1bf1a61d7ad5372a174b95b007c5e3`: Alex has 34 reference replacements plus exactly one note per tree; Blake has 2 plus exactly one note per tree; all other added/deleted lines are zero. All four mirrors remain byte-identical and `AC-05-sentinel-preservation.sh` passes. | PASS |
| AC6 | In an isolated copy, simultaneous identical injection into both trees keeps byte parity clean but `parity` exits 1 with `parity FAIL: platform-coupled reference path in .agents/skills/alex/SKILL.md:<line>`. A pristine copy passes; single-tree injection exits 1 through the existing byte-diff path. `parity --fix` also fails closed on the dual injected declaration. | PASS |
| AC7 | Baseline is documented as 5 BLOCKs. Current `runtime-freshness-verify.sh . 2026-08-03` reports `21 entries | PASS: 21 | WARN: 0 | BLOCK: 0`; the verifier itself is unchanged and scoped docs contain no `0.137` residue. In an isolated branch-β ledger simulation, only the pre-registered `ask_user_question_hook` blocks (1 < 5), with no verified row blocked; the escalation list is recorded in `ac7-branch-escalation.md`. | PASS |
| AC8 | `skill-body-verify.sh` passes; `bash -n tad.sh` and `bash -n .tad/hooks/lib/release-verify.sh` pass; `jq empty .codex/hooks.json` passes. | PASS |
| AC9 | An isolated Codex-only tree containing `.agents/skills` and shared `.tad/guides`, with no `.claude/skills`, resolves all 38 path-shaped references with `missing=0`. | PASS |

## Findings and boundary note

No unmet acceptance criterion was found. AC4 has one wording boundary worth
preserving in the final Completion: each tree contains one pre-existing,
free-form `reference: "Phase 1c knowledge — ..."` value in a nested reference
document. It is not a filesystem path; the zero-missing result above therefore
checks path-shaped declarations (`references/*`, `.tad/*`, or absolute paths),
not that prose label. Treating every literal `reference:` value as a path would
make AC4 impossible without an out-of-scope edit to the nested document.

Primary evidence:

- `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/baseline.md`
- `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-a-report.md`
- `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-b-report.md`
- `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac7-branch-escalation.md`
- `.tad/evidence/acceptance-tests/lite-review-hardening/AC-05-sentinel-preservation.sh`
