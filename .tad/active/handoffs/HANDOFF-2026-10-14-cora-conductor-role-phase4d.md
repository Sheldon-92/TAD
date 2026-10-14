---
dispatch_id: p4-y3-1
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff for Blake — Phase 4d: release preparation for 4.0.0 (nothing leaves this machine)

**From:** Alex (design dispatch `p4-y3-1`) · **To:** Blake · **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 4, part d of e
**Starts after:** 4c committed (README read by the human). **Human stops after this part:** (1) push to `main`; (2) tag and GitHub release (with the repository description). Each is confirmed by the human at that moment; Cora or the human runs the prepared commands. **Blake never pushes, tags, publishes or edits the GitHub repository.**
**Index:** `.tad/evidence/yolo/cora-conductor-role/phase4-design-index.md`

Design handoff only; no Gate 2 claim. Questions go to `.tad/evidence/yolo/cora-conductor-role/phase4-questions.md` (line 1 `dispatch_id: <your id>`), then stop.

## 1. Task overview

### 1.1 What we are building
Everything from Phases 1–3 and 4a–4c made into one release commit chain on `feat/cora-role`, every release gate green on the last commit, and a file with the exact publish commands for the human-confirmed steps.

### 1.2 Why
Epic Phase 4 Scope B and ACs: one major release through the existing flow (`alex/references/publish-protocol.md`, `release-runbook/references/publish-ops.md`, `release-verify.sh`), detailed changelog and release note, regenerated ledgers, upgrade notes, and push/tag only after the human confirms.

### 1.3 Intent
Version **4.0.0** (major: the first principle and the default way of working changed; Epic Phase 4 Scope B). The number lives only where the release flow puts it. Every per-harness claim is a measured fact with a pointer; nothing unrun is called verified.

### 1.4 Offload log
None.

## 2. Background and knowledge
Read: `.agents/skills/release-runbook/SKILL.md` then `references/publish-ops.md` (gate order §2, bump §3, provenance §3.2, publish §4), `.agents/skills/alex/references/publish-protocol.md` (step3d2, step3e, step3f), `patterns/release-sync.md`, `patterns/shell-portability.md`. Facts: `phase3-gate-report.md` (section 2, P4-E), `phase4a-queue-judge.md`, `phase4a-smoke-judge.md`, 4b's `docs/MULTI-PLATFORM.md` `## Cora on each harness`. Previous release records for shape: `.tad/evidence/releases/3.3.0-*.md`, `.tad/migrations/3.2.0-to-3.3.0.yaml`, `CHANGELOG.md` `## [3.3.0]`.

The runbook is written for the Lite mandate; here the Epic's approval plus the human's confirmations at the push and release stops play that part. Use its gate order and commands; ignore its Lite-only bookkeeping (CAS ledger in a LITE handoff).

## 3. Requirements

### 3.1 Content
1. **Version bump** 3.3.0 → 4.0.0 on the change surface the gates derive (`release-verify.sh version <root> 4.0.0 3.3.0` detect-only first; classify every hit per publish-ops §3.1 into `.tad/evidence/releases/4.0.0-version-triage.md`; never rewrite history lines). Includes the README version line, `package.json`, `.tad/config.yaml`, `tad.sh` target, `tad-help`, `INSTALLATION_GUIDE.md`, `docs/MULTI-PLATFORM.md`, `AGENTS.md` marker, `.agents/skills/tad/SKILL.md` banner if the gate lists it.
2. **CHANGELOG** `## [4.0.0] - <release date>`: what changed (Cora role; conductor protocol moved out of Alex; first principle "Three Roles, Independent Judgment"; queue, pointer and owner line; acceptance and archiving as two questions; per-round verdict files; Epic template PARTIAL status; installer ships Cora on all four targets), `### Upgrading from 3.x`, `### What was run on each harness`, known limits.
3. **Release note** `docs/releases/v4.0.0-release.md` with `## What Cora is`, `## How the roles split`, `## What was run on each harness`, `## Not run`, `## Upgrading from 3.x`. It is the GitHub release body. `## Not run` must name at least: Cora on Cursor and OpenCode; gates and acceptance with Codex as conductor; Codex conducting runs whose fixtures need `claude -p` (R-CC-9); the retry id `-t<m>` and Y4 round ids (CF-8, text only); interactive Claude Code; download install paths before this release's 4e check. Do not restate run-record residuals as facts (CF-6): cite verdict files, not `run-record.md` claims its check marked unproven.
4. **Upgrade notes** (CHANGELOG, release note, `INSTALLATION_GUIDE.md` short section): re-run the installer; `/cora` (`$cora`) appears; `/alex`, `/blake` and existing handoffs work unchanged; Epics without a `**Conductor**: Cora` line are Alex's and Cora asks before taking one over; what the migration manifest removes.
5. **Migration hop** `.tad/migrations/3.3.0-to-4.0.0.yaml` covering the framework files deleted or renamed since `v3.3.0` (at least `alex/references/yolo-manual-conductor-protocol.md`, `alex/references/update-roadmap-protocol.md`, `alex/references/status-panoramic-protocol.md` → `cora/references/status-roadmap-protocol.md`); the `migration` gate is the judge.
6. **Brain index** regenerated (`.tad/hooks/lib/brain-index-gen.sh`) and committed (P2-C).
7. **Records commit** (P4-D), before the bump: both Epic files and the Phase 1–4 handoffs/completion reports under `.tad/active/handoffs/` that belong to this Epic and its sub-Epic, as they stand. **Not** `.tad/memory/` (the human's capture layer): list its untracked files in the publish-commands file for the human to decide.
8. **Live regression (step3f, all four runtimes HARD):** one transcript per runtime dated on/after 2026-10-10 at `.tad/evidence/live-regression/<runtime>-<YYYYMMDD>.md`, six fields, using the fixed task `.tad/evidence/live-regression/raw/task-text.md` and the method of the 2026-10-09 transcripts, installing the release candidate from the local tree. A runtime that cannot run (login, quota): write the transcript with result FAIL and the vendor text, then stop and ask (a HARD runtime missing blocks the release).
9. **Local fresh-install check:** install the candidate from the local tree into two fresh throwaway git projects (`--platform claude-code`, `--platform codex`), open one headless session each (`/cora you are Cora.` / `$cora you are Cora.`), and write `.tad/evidence/yolo/cora-conductor-role/phase4d-install-{claude,codex}.md` with lines `### install exit: <rc>`, `### session exit: <rc>` and the transcript.
10. **State surface (step3e):** the bump commit contains `.tad/version.txt`, `NEXT.md` and `ROADMAP.md` (header lines only in NEXT.md; leave Cora's entries as they are); re-read `AGENTS.md` Runtime status and Known Gaps against current facts and fix stale lines; run `bash .tad/scripts/scan-downstream-versions.sh` and commit its ledger with `git add -f` by path.
11. **Ledgers:** after the bump commit, `bash .tad/scripts/gen-claude-provenance.sh`, commit `.tad/provenance/` by path; re-run `version-sweep` and `provenance`. `freshness` exit 1: re-verify the flagged row for real, never only its date.
12. **Publish-commands file** `.tad/evidence/yolo/cora-conductor-role/phase4d-publish-commands.md`: line `release_commit: <40-hex sha of the last commit>`; `git merge-base --is-ancestor origin/main <release_commit>` result (must be true; if not, stop and ask); then, each in its own block and never chained: `git push origin <sha>:refs/heads/main`; `git tag -a v4.0.0 <sha> -m "v4.0.0 — …"`; `git push origin refs/tags/v4.0.0:refs/tags/v4.0.0`; `gh release create v4.0.0 --title "TAD v4.0.0" --notes-file docs/releases/v4.0.0-release.md --verify-tag`; `gh repo edit Sheldon-92/TAD --description "<package.json description>"`; the recovery reads of publish-ops §5; and the list of untracked files left out (`.tad/memory/*`).
13. **Closeout record** `.tad/evidence/releases/4.0.0-closeout.md`: `git show --name-only` of the bump commit and the raw output of every gate in order, from the last commit.

### 3.2 Gate order (publish-ops §2), all on the last commit
structural → version → version-sweep → migration → installer-destructive-guard → freshness → provenance → state-surface → path-refs; plus `bash .tad/hooks/lib/pack-registry-driftcheck.sh` (advisory) and `tad.sh --verify-denylist` if `tad.sh` changed. Stop at the first red that you cannot fix inside this scope.

## 4. Technical design
Commit order: records (§3.1 item 7) → docs/CHANGELOG/release note/migration/upgrade notes → bump commit (with NEXT.md, ROADMAP.md, downstream ledger) → provenance commit → brain index if not already included. The tag target is the last commit; any later commit means re-running all gates.

## 5. Mandatory questions
MQ1: use `release-verify.sh` and the existing generators, not hand-written checks (principle "Never Hand-Write What an Existing Tool Already Does"). Others N/A.

## 6. Implementation steps
1. Source identity guard (release-runbook SKILL); `git status --short`; write `base: <HEAD>` in `.tad/evidence/yolo/cora-conductor-role/phase4d-completion.md`.
2. Items 7, 2–5, 1, 10, 11, 6 in the commit order of §4.
3. Items 8 and 9 (long; background is fine).
4. All gates (§3.2) on the last commit; item 13; item 12.
5. Run `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh 4d`.
6. Completion report: `dispatch_id`, `base:`, `gate3_verdict:` empty, commits, every command with rc, `Journal:`. Stop.

## 7. File structure
### 7.1 Create
`docs/releases/v4.0.0-release.md`, `.tad/migrations/3.3.0-to-4.0.0.yaml`, `.tad/evidence/releases/4.0.0-{version-triage,closeout}.md`, four `.tad/evidence/live-regression/<runtime>-<date>.md` (+ raw), `phase4d-install-{claude,codex}.md`, `phase4d-publish-commands.md`, `phase4d-completion.md`.
### 7.2 Modify
`.tad/version.txt`, `CHANGELOG.md`, `package.json`, `.tad/config.yaml`, `tad.sh` (version string only), `README.md` (version line only), `AGENTS.md`, `INSTALLATION_GUIDE.md`, `docs/MULTI-PLATFORM.md`, `.agents/skills/tad-help/SKILL.md`, `.agents/skills/tad/SKILL.md` (version strings only), other files the version gate lists, `NEXT.md` (header lines), `ROADMAP.md` (header lines), `.tad/brain-index.md`, `.tad/provenance/*`, `.tad/evidence/pm/downstream-versions.md` (forced add); commit only: the Epic files and handoffs of item 7.
### 7.3 Grounded Against
Read 2026-10-14 at `c666a2de`: `.tad/version.txt` (`3.3.0`), `CHANGELOG.md` (1961 lines; `## [3.3.0] - 2026-10-10` line 8), `package.json` (80; version line 3), `tad.sh` (5961; pinned-tag download at line ~3066, `--release-ref` usage line 454), `.tad/hooks/lib/release-verify.sh` (968; subcommands structural, version, freshness, migration, version-sweep, installer-destructive-guard, provenance, state-surface, path-refs), `.tad/scripts/gen-claude-provenance.sh` (137), `.tad/hooks/lib/brain-index-gen.sh` (exists), `.tad/scripts/scan-downstream-versions.sh` (exists), `.tad/migrations/3.2.0-to-3.3.0.yaml` (format), `docs/releases/` (v1.4, v1.6 notes), `.tad/evidence/live-regression/` (2026-10-09 transcripts and `raw/`), `origin/main` = `e693d8b9` is an ancestor of HEAD (fast-forward possible). `git diff --name-status main..HEAD` shows the three alex reference deletions/rename listed in item 5. All exist.

## 8. Testing
The gates are the tests. Live regression and install sessions are real harness runs; a failure is recorded as FAIL with the vendor text, never as a pass.

### 8.6 Evidence manifest
```yaml
required_evidence:
  completion: .tad/evidence/yolo/cora-conductor-role/phase4d-completion.md
  release_records: [.tad/evidence/releases/4.0.0-version-triage.md, .tad/evidence/releases/4.0.0-closeout.md]
  live_regression: .tad/evidence/live-regression/<runtime>-<date>.md x4
  install_checks: [phase4d-install-claude.md, phase4d-install-codex.md]
  publish_prep: .tad/evidence/yolo/cora-conductor-role/phase4d-publish-commands.md
```

## 9. Acceptance criteria
`bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh <id>` (or `4d`); expect PASS.

| AC | Checks |
|---|---|
| D1 | `version.txt` = 4.0.0; `version` and `version-sweep` gates exit 0 |
| D2 | CHANGELOG `## [4.0.0]` with `### Upgrading from 3.x`, `### What was run on each harness` |
| D3 | release note with the five sections of §3.1 item 3 |
| D4 | migration hop present; `migration` gate exit 0 |
| D5 | structural, installer-destructive-guard, freshness, provenance, state-surface, path-refs exit 0 |
| D6 | four current-cycle live-regression transcripts, six fields each |
| D7 | the commit that last touched `version.txt` also has `NEXT.md` and `ROADMAP.md` |
| D8 | local fresh install activates Cora on Claude Code and Codex |
| D9 | publish-commands file prepared; tag `v4.0.0` not on origin |
| D10 | release paths have no uncommitted changes |

Design dry-run (2026-10-14): runs; D5a–f, D7 (on the 3.3.0 commit), D9b, D10 PASS on today's tree; the rest FAIL as expected.

## 9.2 Design checks
Frontmatter filled. Packs: `web-deployment` matches (release, deploy); pointer-only per `AGENTS.md`, not loaded, no criteria injected (conflict with the dispatch prompt recorded; repository rule ranks higher). Grounding §7.3. LSP: not applicable. AC dry-run above.

## 10. Important notes
- Never `git push`, `git tag`, `gh release`, `gh repo edit`. Never `--force` or `--tags`.
- `.tad/` sits in a Syncthing folder: before committing a file git shows as modified that you did not edit, compare it with its last commit; a hunk that restores older text is a stop.
- The release record must not call anything verified that a verdict file does not show.

## 11. Learning content
None expected.

## 12. Sub-agent record
None called by this design dispatch.
