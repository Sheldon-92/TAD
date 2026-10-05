# COMPLETION-20260911-publish-v2445 — Publish v2.44.5

**Task ID**: `TASK-20260911-PUBLISH-V2445` | **Owner**: Blake (OpenCode, `opencode-go/muse-spark-1.3-contributor`; NO Gemini)
**Handoff**: `.tad/active/handoffs/HANDOFF-20260911-release-v2445.md` (READY_FOR_BLAKE; Human Gate2 PASS + 当 Blake)
**Date**: 2026-09-11 | **Mode**: publish-only (stopped after GitHub Release verification; NO sync)
**Verdict**: **DONE — all AC1–AC8 PASS at commit R; remote main + annotated tag + GitHub Release live.**

---

## SHAs

| Ref | SHA |
|---|---|
| Parent (mandate binding) | `63cf62912131d1f40273d54b0e6456aad9ba33af` |
| Commit R | `1f6aaad2498f33bb4aef75ad8f414f5d652287cd` |
| Tag object `v2.44.5` | `b3193d2452474cc101fb6b2cc82f2002b2f778f3` (peels to R) |
| Prior release peeled `v2.44.4` | `83e2ff03f48b3510482192797fc7f06e634f425d` |

R subject: `release: v2.44.5 / Verify-delta + pack loader/freeze + KEEP11 knife 1. Version + CHANGELOG only.`

## Gates (detect-only, §3.4 order; pre-push, WT = R + pre-existing noise except PROJECT_CONTEXT reconstructed)

| # | Command | Exit | Disposition |
|---|---|---|---|
| 1 | `bash .tad/hooks/lib/release-verify.sh parity .` | **0** | PASS |
| 2a | `bash .tad/hooks/lib/derive-sync-set.sh --report .` | **0** | PASS (report only) |
| 2b | `bash .tad/hooks/lib/release-verify.sh version . 2.44.5 2.44.4` | **1 (advisory)** | 6 stale refs, all out of R: `pack-registry.yaml:9 synced_from_version` (reserved registry field, not identity) + 5× `NEXT.md` (dirty-tree noise, must not absorb). No history falsified. |
| 3 | `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.5` | **0** | Layer 1 **12/12 PASS**; Layer 2 advisory only |
| 4 | `bash .tad/hooks/lib/release-verify.sh migration .` | **0** | No D/R entries |
| 5 | `bash tad.sh --verify-denylist` | **0** | inlined DENY_LIST == lib (17 entries) |

No exit-2 wiring failure at any gate.

## AC table (§9.1 verification methods, run verbatim)

| AC | Method | Result |
|---|---|---|
| AC1 | `release-verify.sh parity .` | exit 0 (pre-push and post-publish) |
| AC2 | `release-verify.sh version-sweep . 2.44.5` | Layer 1 exit 0 pre-push (12/12). Post-publish WT sweep reports PROJECT_CONTEXT MISSING — **expected**: §3.5 step 6 sidecar restore re-applied the human's ledger noise (2.44.3 + KEEP11/freeze/loader bullets) to the WT as **unstaged** dirt. `git show R:PROJECT_CONTEXT.md` is 2.44.5-pure (see AC4). R unaffected. |
| AC3 | `grep -n '## \[2.44.5\] - 2026-09-11'` → L10; `grep -cE '7048b835\|9c33e2e5\|eb09597a\|63cf6291'` → 4; `grep -cF 'Remaining KEEP11 knives'` → 1 | PASS, no overclaim |
| AC4 | `git show --name-only --pretty=format: HEAD` = exactly the 16 pathspecs; `git rev-parse HEAD^` = `63cf6291…` full SHA; `git diff 63cf6291… R -- PROJECT_CONTEXT.md` = 2 version-token lines only; non-version-hunk grep over other identity diffs = empty | PASS |
| AC5 | `git ls-remote --heads origin refs/heads/main` | `1f6aaad2…` == R |
| AC6 | `git ls-remote --tags origin refs/tags/v2.44.5 refs/tags/v2.44.5^{}` | annotated `b3193d24` + peeled `1f6aaad2` == R |
| AC7 | `gh release view v2.44.5 --json tagName,isDraft,url` | `tagName v2.44.5`, `isDraft false`, `url https://github.com/Sheldon-92/TAD/releases/tag/v2.44.5` |
| AC8 | this file exists with SHAs + exits | PASS |

## Publish sequence (four separate invocations; no `&&`/`;` across P1–P4; no force; no `--tags`)

- **P1** `git push origin 1f6aaad2…:refs/heads/main` → `63cf6291..1f6aaad2 main` (fast-forward)
- **P2** `git tag -a v2.44.5 1f6aaad2… -m "v2.44.5 — Verify-delta + pack loader/freeze + KEEP11 knife 1"`
- **P3** `git push origin refs/tags/v2.44.5:refs/tags/v2.44.5` → `[new tag] v2.44.5 -> v2.44.5`
- **P4** `gh release create v2.44.5 …` → `https://github.com/Sheldon-92/TAD/releases/tag/v2.44.5`

Pre-P1 re-check: remote main was still `63cf6291`, remote `v2.44.5` absent — no fork, no collision.

## Dirty-tree handling (§3.5)

- Pre-existing dirt (NEXT / pm / stale twins / judge bundles / brain-index / pattern noise) left **unstaged, untouched**.
- Only `PROJECT_CONTEXT.md` was dirty inside the 16: sidecarred to `/tmp/tad-v2445-PROJECT_CONTEXT.md`, reconstructed from `git show HEAD:<path>` + 2 version-token edits, staged, committed; sidecar restored to WT **unstaged** after R (` M PROJECT_CONTEXT.md`, second-column only).
- No `git add -A/.`, no directory adds, no `parity --fix` (3 explicit `cp`), only `tad.sh` L26 touched.

## Out of scope (not done, per mandate)

Remaining KEEP11 knives; freeze/unfreeze roster; experiment-path `ai-evaluation` dump; AGENTS ACI leftover; downstream sync; Gemini (none used).

## Friction Status

| Friction | Status | Note |
|---|---|---|
| Dirty `PROJECT_CONTEXT.md` vs byte-purity | RESOLVED via §3.5 reconstruction | sidecar + HEAD base + mixed-reset fallback unused (R clean first try) |
| `gh` auth / network | READY | all remote ops succeeded |
| Dual Gate 2 reviewers | READY | spec + scope carriers on disk, both PASS P0=0 |
| Sandbox push approval | READY | push/tag/release completed without block |
| Post-publish WT sweep divergence | NOT_APPLICABLE_WITH_REASON | mandated sidecar restore; R blob verified pure; not a release defect |

## Implementation Decisions (made during execution)

| # | Decision | Context | Chosen | Escalated? |
|---|---|---|---|---|
| — | none | mechanical publish; handoff fully specified | — | No |

## Evidence carriers

- Layer 2 (spec-compliance, mechanical-publish scope): `.tad/evidence/reviews/20260911-layer2-publish-v2445.md`
- Gate 3: `.tad/evidence/reviews/20260911-gate3-publish-v2445.md`
