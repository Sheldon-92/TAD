dispatch_id: D32
gate3_verdict:

# Completion report: Cora Phase 2 (slim)

impl_status: complete (commit 4, the principle, NOT APPLIED: awaiting approval; complete-with-gate-pending)
Branch feat/cora-role, base ad6feb80. No push, no tag.

## Commits
| # | sha | files |
|---|---|---|
| 1 | 4a01fa32 | cora/references/conductor-protocol.md, cora/SKILL.md (Intake pointer), alex/references/conductor-dispatch-mode.md |
| 2 | 8dad2b23 | AGENTS.md, tad.sh, .tad/codex/README.md, cora/SKILL.md (description triggers) |
| 3 | c6a563d7 | AGENTS.md, config-agents.yaml, config.yaml, handoff-creation-protocol.md, blake/SKILL.md, gate/SKILL.md, nondev-execution-track.md, deliverable-completion.md, post-write-sync.sh |
| 4 | none | principle: NOT APPLIED, awaiting approval. Gate command `tail -n 1 ...phase2-principle-before-after.md \| grep -q '^Approved: yes'` returned 1 (last line `Approved: (none yet)`), checked when reached. principles.md, gate-design.md, brain-index.md untouched. |
| 5 | 083011f9 | .tad/provenance/claude-legacy.tsv, MANIFEST.sha1 (alone) |
| 6 | fc48413b | .tad/scripts/path-refs-allowlist.txt (one row: AGENTS.md -> rulings/human-rulings.md; path-refs flagged the new conditional Ingress line as dangling). Not a skill file, ledger stays green. |

## Acceptance (bash; full output in phase2-ac-output.txt)
- AC-1: 1,1,1,0,1,1 PASS.
- AC-2: 3,2,1,1 PASS.
- AC-3: one hit, principles.md:116 (allowed while principle NOT APPLIED); blocking:true grep empty; third grep empty.
- AC-4: 0,1 = NOT APPLIED branch, as the handoff states.
- AC-5: skill-body-verify rc0, state-surface-check rc0, freshness rc0, installer-destructive-guard rc0, version-sweep 3.3.0 rc0, provenance rc0. path-refs rc0 after the allowlist row (it was rc1 before commit 6: 1 dangling). One STALE-ALLOW row at allowlist :67 concerns NEXT.md (not mine, not a failure).
- AC-6: phase1-slim-ac.sh 8 ACs, FAIL count 0 (it was FAIL 1 on AC-7 path-refs until commit 6).
- AC-7: 0 matches (pipeline prints 0, grep exit 1).
- AC-8: 16 paths, all in the handoff section 2 list (path-refs-allowlist added after the first listing; it is on the section 2 list).
- AC-9: both installs rc 0; cora SKILL.md present in both; .claude/skills/cora -> ../../.agents/skills/cora on claude-code; structural: `.agents/skills identical`, only X is `.tad/migrations`.
- AC-10: not graded by me. Transcripts below; judge pending.

## The ten notes
1 plain `|` used. 2 everything run via bash (zsh did not split `$P`; I hit that once with a pathspec variable and reran under bash -c). 3 provenance: one regeneration cleared both checks (rc 0). 4 structural exit 1 recorded as the migrations X only. 5 AC-3 wording avoided the banned phrases; passes. 6 not reached (commit 4 not applied). 7 gate read `(none yet)`, NOT APPLIED. 8 explicit pathspecs only; evidence dir and handoffs untouched by commits. 9 AC-7 rc 1 noted. 10 `/cora` in headless claude -p: see transcript-claude-slash.md as is (exit 0, output present).

## Activation transcripts (.tad/evidence/yolo/cora-conductor-role/phase2-activation/)
transcript-claude-bare.md (exit 0), transcript-claude-slash.md (exit 0), transcript-codex-bare.md (exit 0), transcript-codex-dollar.md (exit 0); each `### files changed` empty by my reading (not graded). install-{claude-code,codex}.log, structural-*.txt. Both harnesses ran; none NOT RUN. Scratch dirs: /var/folders/.../tmp.oLR4dGc2yC/fi-claude-code, tmp.qOQLuwPFFl/fi-codex. Observed in the transcripts without grading: the fresh installs have no principles.md or patterns/_index.md, and the sessions said so.

## Deviations
- AGENTS.md says "measured in Phase 2 (headless activation sessions)" instead of the handoff's "(§8.2)", which would dangle in an installed repo.
- Extra commit 6 (allowlist row), permitted by section 2.
- cora/SKILL.md description edit went into commit 2 (as section 4 places it), not commit 1.
- Commit 5 was made before commit 6; commit 6 touches no skill file.

## Not-yours files
shasum of NEXT.md, PROJECT_CONTEXT.md, ROADMAP.md, docs/pm/status.md, capability-builder EPIC.md, the Cora Epic, all handoffs (except this new report, added after), .tad/memory/*: identical before and after. Only the new COMPLETION file and evidence files are additions, uncommitted.

## Could not do
Commit 4 (approval). Grading (not mine).

## Rework 1
dispatch_id: D36
Commits: d165f5bd (fixes), 56b04d45 (provenance ledger regenerated, alone, last). Base fc48413b. No push.

| Finding | Change | Where |
|---|---|---|
| ARCH P1-1, CR P2-3 | Round-1 reviewer ids `p{N}-y6-r1-cr` / `-r1-dom` in step 1; step 4b writes the pointer first with round-k ids (`p{N}-y6-r<k>-cr/-dom`, never equal to the rework id or earlier rounds) and both paths; on resume only the current round's ids count, stale round file = "output not on disk"; resume rule for rework-present vs pointer-names-reviewers | conductor-protocol.md, Y6 step 1 and 4b, commit d165f5bd |
| ARCH P2-1 | `human_still_bridge: true` kept but qualified "manual path only; under Cora the dispatching conductor is the bridge" (key kept in case a reader expects it) | config-agents.yaml:312, d165f5bd |
| ARCH P2-2 | Default Behaviour step 3 clause: handoff named by an Epic's `Dispatched:` belongs to a Cora run, do not send the human to Blake | AGENTS.md:129, d165f5bd |
| ARCH P2-3 | `$cora` / `$alex` / `$blake` in the activation sentence | AGENTS.md:29, d165f5bd |
| CR P2-2 | "Line 1 is" capitalised | conductor-dispatch-mode.md:17, d165f5bd |
| CR P2-1 | not in the D36 list; unchanged (Gate 4 sequencing) | none |

Principle gate: `tail -n 1 ... | grep -q '^Approved: yes'` returned 1; commit 4 still NOT APPLIED. File not edited.
AC rerun: appended under "Rework 1" in phase2-ac-output.txt. AC-1 1,1,1,0,1,1; AC-2 3,2,1,1; AC-3 only principles.md:116; AC-4 0,1; AC-5 all rc 0 (path-refs, provenance included); phase1-slim-ac FAIL 0; AC-7 0; skill-body-verify and state-surface pass.
Activation rerun: round-1 transcripts moved to phase2-activation-round1/. The first claude-code install attempt crashed (rc 139, no .tad written; log kept as install-claude-code-attempt1-rc139.log) and the first two claude sessions ran in that empty dir; those two transcripts are in phase2-activation/discarded-broken-install/. The claude-code install was rerun (rc 0, structural: only `.tad/migrations` differs, `.agents/skills identical`, `.claude/skills/cora` link present) and both claude sessions rerun there. Codex install rc 0, sessions run once. Four current transcripts, all harness exit 0, `### files changed` empty. Not graded by me.
Not-yours files: shasum identical before/after. Not done: nothing outstanding; the Y4 reviewer ids were not given a round scheme (outside the D36 list).

## Commit 4 (principle)

dispatch_id: D37

Principle: APPLIED (gate `Approved: yes` on the before/after file passed). Commit `1320ba8f` on feat/cora-role.

```
 .tad/brain-index.md                            | 45 +++++++++++++++-----------
 .tad/project-knowledge/patterns/gate-design.md |  2 +-
 .tad/project-knowledge/principles.md           | 14 ++++----
 3 files changed, 35 insertions(+), 26 deletions(-)
```

- "Two-Agent System" entry replaced with the approved "After" text verbatim; two approved clauses in "Knowledge Is Forged at Distill" applied verbatim (SAFETY and Grounded-in lines untouched); `gate-design.md:114` phrase changed; brain-index regenerated.
- AC-3: 0 hits (all three commands exit 1). AC-4: 1 / 0 (applied branch).
- AC-5: skill-body-verify, state-surface-check, path-refs, freshness, installer-destructive-guard, version-sweep 3.3.0, provenance all exit 0. Provenance stayed green; no ledger regeneration needed, so no ledger commit.
- Outputs appended to `.tad/evidence/yolo/cora-conductor-role/phase2-ac-output.txt` under "Commit 4".
