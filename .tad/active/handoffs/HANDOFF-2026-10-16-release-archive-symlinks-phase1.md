---
task_type: code
e2e_required: yes
research_required: no
dispatch_id: p1-y4-1
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: keep the source repo's `.claude/skills` links out of the release archive

**From:** Alex (dispatched by Cora, step Y4 design fix; first version p1-y3-1) **To:** Blake
**Date:** 2026-10-16 **Project:** TAD **Task ID:** TASK-20261016-001
**Epic:** EPIC-20261016-release-archive-symlinks.md (Phase 1/1)
**Phase block:** `.tad/evidence/yolo/release-archive-symlinks/intake-details.md` (intake-1). This handoff settles its open design points; where they differ, this handoff wins.

---

## Change log (p1-y3-1 → p1-y4-1)

Reviews answered: `phase1-design-review-cr.md` (CR, CONDITIONAL, P0-1) and `phase1-design-review-security.md` (SEC, CONDITIONAL, 0 P0).

**Design-level** (changes what is built or what proves it):
1. **AC3 oracle replaced (CR P0-1).** `structural` is a sync gate (verbatim `cp -R`), so it fails on an installed target because the installer writes `.tad/migrations/genesis.yaml`. Alex reproduced this (§9 dry-run). New oracle: run `structural` unchanged and require that its *only* failure is `.tad/migrations`, and that the full `diff -rq` of that dir is exactly the one line `Only in <target>/.tad/migrations: genesis.yaml`; plus genesis absent from the archive and present in the target. Nothing in `release-verify.sh structural` changes; the single tolerated difference is named and asserted, not filtered. (`.tad-pack-meta.yaml` extras in `.agents/skills` are already tolerated by `structural` itself, unchanged.)
2. **`archive-links` runs two predicates (SEC P1-1).** (a) An independent literal check written in `release-verify.sh` itself (fails on any symlink/hardlink target that is absolute or contains `..`, and on any absolute or `..` member path), and (b) the ref's own `validate_tar_members` (D3 eval) as the same-predicate cross-check. Both must pass. The runbook states the ref must be a reviewed commit because (b) executes code from that ref. See D3/D4.
3. **`archive-links --tarball <file>` form + GitHub-equivalence step in the runbook (SEC P1-3).** Between §4 step 1 (push main) and step 2 (tag), download GitHub's archive of the exact commit (`https://github.com/Sheldon-92/TAD/archive/<commit>.tar.gz`) and run `archive-links --tarball` on it; exit ≠ 0 blocks the tag. Blake only writes this runbook text; Blake pushes and downloads nothing. See D4, D5.
4. **Negative controls fail closed (SEC P1-2, CR P1-3).** A synthetic temp git repo with a tracked `../` symlink must make `archive-links` exit 1, with no SKIP path. The `v4.0.2` controls keep their SKIP-when-absent rule in the fixture, but for this phase's verdict a SKIP leaves "the real defect is rejected" unproven, so AC5 counts it as FAIL (the tag exists locally today). See D6, AC5.
5. **Fixture expected version comes from HEAD (CR P1-1).** `case_archive_shape` reads `git show HEAD:.tad/version.txt` for the archived version and uses that as `--expected-version`; if it differs from the worktree `FIXTURE_VERSION`, print an `INFO:` line naming both (not a FAIL). See D6.

**Local** (wording, precision, cheap hardening; same design):
6. `rev-parse --verify "$ref^{commit}"` for ref resolution, so annotated tags resolve (CR P1-4). D4.
7. `git archive` in the mode runs with `GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null`; the header comment notes `$GIT_DIR/info/attributes` is still read (SEC P2-1). D4.
8. Extracted function must end with a `return 0` line before its closing brace, else exit 2 (SEC P2-2). D3.
9. AC1 dir-count regex anchored (CR P2). AC7 states the exact usage line (CR P2). D5 quotes the real anchor sentence; it does exist in §3.2's last paragraph (CR P2 said it did not; Alex grepped it).
10. AC6 says plainly that plain `run-all.sh` does not run `archive-shape` (FULL loop only); AC6 runs the case directly (CR P1-2).

**Not carried:** SEC P2-5 (hard-link negative control in the fixture): crafting a `..` hard-link member needs a hand-built tar, not cheap; the literal check in (2) covers `link to` lines, and its unit test in AC5 uses a symlink only. SEC P2-3/P2-4 need no action (P2-3 already met by D5 hard block; P2-4 pre-existing and out of scope).

## Gate 2
Not claimed here. Gate 2 = two independent design reviews on disk (Cora dispatches them).

## 1. Task Overview

### 1.1 What we're building
A root `.gitattributes` rule that keeps `.claude/` out of `git archive` (and so out of GitHub's tag tarball), a `release-verify.sh archive-links` mode that fails when a release archive carries an escaping link, a pre-tag step and a GitHub-equivalence step in the publish runbook, and a fixture case that sends a real `git archive`-shaped tarball through the real pinned download path.

### 1.2 Why
Since `99fe7f02` the repo tracks 64 links `.claude/skills/<name> -> ../../.agents/skills/<name>`. GitHub's tag archive carries them; `tad.sh` `validate_tar_members` (tad.sh:181) correctly rejects `..` link targets, so every download install/update of v4.0.2 refuses the archive. Success: an archive built the way GitHub builds it passes the tar-slip gate unchanged and installs end to end.

### 1.3 Intent
- The problem: the release archive's shape, not the security check.
- Not: loosening or reshaping `validate_tar_members` or `structural`; removing the links from the source repo; changing how tad.sh writes `.claude/skills` links into targets; downstream projects; the 4.0.3 bump/tag/push (separate task); model test runs.

### 1.4 Offload Log
无。

## Project Knowledge (Blake must read)
Read: `principles.md`, `patterns/_index.md`, `patterns/release-sync.md`, `patterns/shell-portability.md` (required before editing shell under `.tad/hooks/**`).

Lessons that apply:
1. **Install from `git archive`, not the working tree** (release-sync.md, 2026-10-14 entry). The repo is a superset of an install; the download path differs exactly where it matters. This defect is an instance: `make_src_tarball` builds its fake download from the worktree with `--exclude=./.claude`, so tests never saw the links.
2. **BSD tar `--exclude` matches per path component** (shell-portability.md, 2026-09-02). Do not add tar excludes to work around anything here; the archive shape comes from `git archive` only.
3. **`set -euo pipefail` + `grep -c` with zero matches exits 1** (shell-portability). `release-verify.sh` runs under `set -euo pipefail`; guard every count (`|| true`) and every call to a function that may return 1 (`if ...; then`).
4. **A sync gate is not an install oracle.** `structural` asserts byte-identity after a verbatim copy; an installed target legitimately carries installer-written files. Assert those by name, never by relaxing the gate (this handoff's AC3).

## 2. Background
- `validate_tar_members` (tad.sh:181-237) uses only `log_error` besides `tar`; it rejects absolute/dot-dot members and `->`/`link to` targets that are absolute or contain `..`.
- `download_pinned_source` (tad.sh:3079) curls the tag URL, validates, extracts, `discover_single_source_root` (tad.sh:3059) accepts any single real directory, then checks `.tad/version.txt` against `--expected-version`.
- The installer writes `.tad/migrations/genesis.yaml` (tad.sh:1498) and per-skill `.tad-pack-meta.yaml` (tad.sh:1108) into the target. `structural` already filters the latter; it does not filter the former (by design: it is a sync gate).
- Fixture `.tad/tests/tad-update-fixture.sh`: mock curl serves `MOCK_TAG_TARBALL` for `*/archive/refs/tags/*.tar.gz` (line 160). `case_download_safety` (line 622) shows the call shape for a pinned install. `FIXTURE_VERSION` is read from the worktree at line 32.
- No `.gitattributes` exists today. Local tag `v4.0.2` exists and is the real defective archive.

## 3. Requirements
- FR1 `.gitattributes` at repo root with exactly `/.claude export-ignore` (plus a one-line `#` comment saying why).
- FR2 `release-verify.sh archive-links <repo_root> [<ref>]` (default ref `HEAD`) and `release-verify.sh archive-links --tarball <file>`.
- FR3 Publish runbook: `archive-links` on the commit to tag before tagging (§3.2), and the GitHub-equivalence check between pushing main and tagging (§4).
- FR4 New fixture case `archive-shape`, wired into `run-all.sh`'s `TAD_TEST_FULL` loop.
- FR5 Fix the stale `make_src_tarball` comment.
- NFR: `tad.sh` byte-unchanged; `release-verify.sh structural` byte-unchanged; bash 3.2 / BSD tools; paths quoted (repo path has a space and CJK).

## 4. Technical Design (decisions settled)

**D1 Pattern = `/.claude export-ignore`.** Probed in a scratch clone: `/.claude/skills/** export-ignore` leaves 2 directory entries (`T/.claude/`, `T/.claude/skills/`), failing AC1; `/.claude` and `/.claude/` both give 0 links, 0 `.claude/` entries, 65 `.agents/skills/*/` dirs (= worktree; CR confirmed independently). Use `/.claude`. Leaving all of `.claude/` out is safe: the 64 links are its only tracked entries (SEC and CR confirmed); the installer builds target links from `$src/.agents/skills` and never reads `$src/.claude`; npm `files` already omits `.claude/`. Do not mark `.gitattributes` itself export-ignore.

**D2 `make_src_tarball` stays a worktree tar; a new dedicated case `archive-shape` carries the real shape.** Switching `make_src_tarball` to `git archive HEAD` would change what all seven existing cases install (tracked `.tad/active`, `evidence`, `archive`, `project-knowledge` would ship; uncommitted worktree changes the cases test today would drop) — a wide behaviour change unrelated to this defect. Only its comment changes (FR5).

**D3 Same-predicate cross-check: the ref's own `validate_tar_members`.** tad.sh cannot be sourced (it runs `main`). Extract the function from the ref's installer and eval it with a `log_error` stub (`log_error() { printf '%s\n' "$*" >&2; }`):
```bash
fn="$(git -C "$repo" show "$commit:tad.sh" | awk '/^validate_tar_members\(\) \{/{f=1} f{print} f&&/^}/{exit}')"
```
Exit 2 if `fn` is empty, if its second-to-last line (trimmed) is not `return 0`, or if `type validate_tar_members` fails after eval. With `--tarball` there is no ref: extract from the `tad.sh` of the repo `release-verify.sh` lives in (`git -C "$repo_root_of_script" show HEAD:tad.sh`), and say so in output. Dry-run (y3): HEAD fixed-shape archive rc 0; `v4.0.2` archive rc 1 with `tar-slip rejected: escaping link target: ... TAD-x/.claude/skills/academic-research -> ../../.agents/skills/academic-research`. **Trust note (header comment and runbook):** this evaluates code taken from the ref; run it only on a reviewed commit.

**D3b Independent literal check (new, SEC P1-1).** A function inside `release-verify.sh` (e.g. `_archive_literal_check <tarball>`), not derived from any ref: from `tar -tzf` fail on any member that starts with `/` or has a `..` path component; from `tar -tvzf` fail on any line containing ` -> ` or ` link to ` whose target is absolute or has a `..` component. Print each offending member. This is the primary verdict; D3 is the cross-check that the shipped guard agrees.

**D4 `archive-links` semantics.**
- Ref form: `commit="$(git -C "$repo" rev-parse --verify -q "$ref^{commit}")"` else exit 2. Build `GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null git -C "$repo" archive --format=tar.gz --prefix=TAD-verify/ "$commit"` into a `mktemp -d` (removed on exit via trap). No `--worktree-attributes`: it checks what is committed, as GitHub does. Header comment: GitHub builds from the committed `.gitattributes`; this mode neutralises global/system config, but `$GIT_DIR/info/attributes` is still read locally — keep it empty on the release machine.
- Tarball form: `archive-links --tarball <file>`; exit 2 if the file is missing or `tar -tzf` fails.
- Both forms: print the resolved SHA (ref form) or file path, the link-member count (informational), then run D3b and D3. Exit 0 = both pass; 1 = either rejects (its messages shown, saying which check); 2 = usage / not a git repo / ref does not resolve / archive build or function extraction failure. Echo `GATE: release-verify archive-links exit=<n>` on non-zero, like the other modes. Add both forms to the CONTRACT header block and `usage()`; usage lines exactly:
  `  release-verify.sh archive-links <repo_root> [<ref>]`
  `  release-verify.sh archive-links --tarball <file>`

**D5 Runbook placement** (`.agents/skills/release-runbook/references/publish-ops.md`).
- §3.2: after the existing sentence "The commit to tag is the last one, the one that contains the regenerated ledger; re-run `provenance` on that commit immediately before the publish step, after any closeout commits." add: run `bash "$repo_root/.tad/hooks/lib/release-verify.sh" archive-links "$repo_root" <commit-to-tag>`; exit 0 continue, 1 block, 2 hard block. One sentence why (GitHub's tarball is built from that commit; an escaping link makes every download install refuse it). One sentence: the mode executes the commit's own `validate_tar_members`, so run it only on the reviewed release commit.
- §4: a new step between 1 (push main) and 2 (create tag): download `https://github.com/Sheldon-92/TAD/archive/<commit>.tar.gz` into a temp file (`curl -fsSL`), run `release-verify.sh archive-links --tarball <file>`; exit ≠ 0 blocks the tag (the tag is immutable once pushed; this proves GitHub's export-ignore handling on the exact commit before any tag exists). Renumber the following steps; keep the existing wording of steps 2-3 otherwise.

**D6 Fixture case `archive-shape`** (new function `case_archive_shape`, dispatch line, header usage line):
0. `setup_sandbox`. `ver="$(git -C "$REPO_ROOT" show HEAD:.tad/version.txt | head -1 | tr -d '[:space:]')"`; if `ver` ≠ `$FIXTURE_VERSION` print `INFO: HEAD version $ver differs from worktree $FIXTURE_VERSION; using HEAD`. Use `$ver` below.
1. `git -C "$REPO_ROOT" archive --format=tar.gz --prefix="TAD-$ver/" HEAD > "$SANDBOX/ga.tgz"`. Assert 0 ` -> ` lines and 0 `.claude/` members.
2. Positive: fresh project dir, pinned install `bash "$TAD_SH" --release-ref "v$ver" --expected-version "$ver" --yes` with `MOCK_TAG_TARBALL=ga.tgz`; rc 0, `.tad/version.txt` = `$ver`. Twice: default platform, and `--platform claude-code`; in the claude-code project assert `.claude/skills/cora` is a symlink and `.claude/skills/cora/SKILL.md` exists.
3. Negative A (synthetic, never skipped): tarball with `TAD-main/.tad/version.txt` and a real symlink `TAD-main/x/evil -> ../../etc`; pinned install rc ≠ 0, output contains `tar-slip rejected`, project digest unchanged (`digest_tree`), no `TAD-*` residue in the project.
4. Negative C (synthetic repo, never skipped): `git init` a temp repo under `$SANDBOX`, commit `tad.sh` copied from `$REPO_ROOT` HEAD (`git show HEAD:tad.sh`), a `.tad/version.txt`, and a symlink `x/evil -> ../../etc`; `release-verify.sh archive-links <temp repo> HEAD` exit 1, output names `x/evil` from the literal check. Then `git rm` the link, commit, re-run: exit 0. Also `archive-links --tarball` on Negative A's tarball: exit 1.
5. Negative B (the real defect): if `git rev-parse -q --verify 'v4.0.2^{commit}'` resolves, archive `v4.0.2` and serve it with `--expected-version 4.0.2`; rc ≠ 0 with `escaping link target`; and `release-verify.sh archive-links "$REPO_ROOT" v4.0.2` exit 1. If the tag is absent print `SKIP:` (not PASS) for these two checks only.
6. `release-verify.sh archive-links "$REPO_ROOT" HEAD` exit 0; `archive-links --tarball "$SANDBOX/ga.tgz"` exit 0.
Note: the case reads HEAD, so it is meaningful only once the `.gitattributes` commit exists; run it after committing.

## 5. Mandatory questions
- MQ1 history: the defect commit `99fe7f02`; release-sync.md lesson above. No earlier export-ignore in the repo (grep: none).
- MQ2 functions exist: `validate_tar_members` tad.sh:181, `download_pinned_source` tad.sh:3079, `discover_single_source_root` tad.sh:3059, `setup_sandbox`/`digest_tree`/`make_mock_curl` in the fixture, release-verify `usage()` line 142, `case "$MODE"` line 162, `structural` lines 163-242.
- MQ3 data flow: commit → `git archive` (reads committed `.gitattributes`) → tarball → curl (mock, or GitHub in the runbook step) → `validate_tar_members` → extract → single root → version check → install builds `.claude/skills` links from `.agents/skills`, writes `genesis.yaml` and `.tad-pack-meta.yaml`.
- MQ4/MQ5: n/a (no UI/state).

## 6. Implementation steps
1. Add `.gitattributes` (D1).
2. Add `archive-links` mode (both forms), D3b literal check, CONTRACT entry, usage lines (D3, D3b, D4). Do not touch `structural`.
3. Add `case_archive_shape`, header usage line, dispatch line; fix `make_src_tarball` comment lines 89-94 to say: `.claude/` holds the source repo's tracked skill links (`../` targets) and is export-ignored from the release archive; the `archive-shape` case covers the real archive shape. Add `archive-shape` to `run-all.sh` FULL loop (line 74).
4. Edit `publish-ops.md` §3.2 and §4 (D5).
5. Commit 1 (fix). Then `bash .tad/scripts/gen-claude-provenance.sh` and commit 2 (`chore(provenance): regenerate the ledger after the release-runbook edit`) — the generator reads git history, so it must follow the skill commit; this is the repo's existing two-commit pattern (see `1697ed39`/`bd9fefa7`). Not pushed.
6. Run the ACs; write evidence.

## 7. Files
### 7.1 Create
- `.gitattributes` (not in the provenance ledger's scope; nothing to regenerate for it)
### 7.2 Modify
- `.tad/hooks/lib/release-verify.sh`
- `.tad/tests/tad-update-fixture.sh`
- `.tad/tests/run-all.sh`
- `.agents/skills/release-runbook/references/publish-ops.md` (the `.claude/skills/release-runbook` link points here; edit once)
- `.tad/provenance/claude-legacy.tsv`, `.tad/provenance/MANIFEST.sha1` (regenerated, not hand-edited)
### 7.3 Grounded Against (read during step1c, plus y4)
`tad.sh` 170-237, 1108-1117, 1498, 3059-3125; `.tad/tests/tad-update-fixture.sh` 1-306, 620-780, 1185-1210; `.tad/tests/run-all.sh` 60-90; `.tad/hooks/lib/release-verify.sh` 1-40, 130-242, 960-1006; `publish-ops.md` §2.4a-§4; `.tad/scripts/gen-claude-provenance.sh` header; `installer-data-safety-fixture.sh` archive calls (1423, 1681, 1693, 1762); `CHANGELOG.md` 4.0.2.

### 7.4 Unchanged lines this change contradicts (resolved)
1. `tad-update-fixture.sh` 89-94 "no tracked file lives there" — already false since `99fe7f02`; rewritten (step 3).
2. `CHANGELOG.md` 4.0.2 "This affects the source repo only." — false for the download path. Released notes stay as shipped; the 4.0.3 entry (release task, out of scope) states the correction. Cora carries this to the release task.
3. Intake Output "All in one local commit" — the provenance generator needs the skill change committed first, so two local commits (step 5). This handoff wins.
4. `installer-data-safety-fixture.sh` `git archive v2.44.6 .claude/...` — reads attributes from the old tag (no `.gitattributes` there); not contradicted. Reviewer confirms by running it (AC6).
5. `release-verify.sh` CONTRACT for `structural` ("this gate diffs a VERBATIM-synced target, not an install-transformed one") — consistent with AC3: AC3 does not claim `structural` PASS on an install target; it asserts the one named installer-written difference.

## 8. Testing
Fixture case `archive-shape` (D6) is the integration test; `download-safety` and `run-all.sh` for regression. Edge cases: tag `v4.0.2` absent → SKIP not PASS in the fixture, FAIL for this phase's AC5; `grep -c` zero under `set -e`; paths with spaces/CJK; annotated tag refs.

Evidence: one file per AC (or one combined file with a heading per AC) under `.tad/evidence/yolo/release-archive-symlinks/phase1-ac*.md`, each with the exact commands and their output, and the commit SHA they ran on.

## 9. Acceptance Criteria / 9.1 Spec Compliance Checklist
All run on the committed tree (commit 2's SHA recorded).

| # | Check | Command / expected |
|---|---|---|
| AC1 | Archive shape | `git archive --format=tar.gz --prefix=TAD-test/ HEAD > a.tgz`; `tar -tvzf a.tgz \| grep -c ' -> '` = 0; `tar -tzf a.tgz \| grep -c '^TAD-test/\.claude/'` = 0; `tar -tzf a.tgz \| grep -cE '^TAD-test/\.agents/skills/[^/]+/$'` = `ls -d .agents/skills/*/ \| wc -l` |
| AC2 | Real pinned download path | `tad-update-fixture.sh --case archive-shape` steps 0-2 PASS: `MOCK_TAG_TARBALL` = the git-archive tarball, `tad.sh --release-ref vX --expected-version X --yes` rc 0 (X from `git show HEAD:.tad/version.txt`), installed version = X |
| AC3 | End-to-end install outside repo | Extract `a.tgz` to scratch dir `X` outside the repo (`X` = the `TAD-test` root). Install with `bash "$X/tad.sh" --source "$X" --yes` into empty project `T1` (default platform) and with `--platform claude-code` into `T2`. For each `T`: (i) rc 0 and `$T/.tad/version.txt` = `$X/.tad/version.txt`; (ii) `release-verify.sh structural "$X" "$T"` output has exactly one `❌` line and it is `❌ .tad/migrations DIFF:` (exit 1 expected, from that line only); (iii) `diff -rq "$X/.tad/migrations" "$T/.tad/migrations"` prints exactly one line, `Only in $T/.tad/migrations: genesis.yaml`; (iv) `test ! -e "$X/.tad/migrations/genesis.yaml"` and `test -f "$T/.tad/migrations/genesis.yaml"`. For `T2` also: `test -L .claude/skills/cora` and `test -f .claude/skills/cora/SKILL.md`. Any other `❌` line, any other diff line, or a changed `structural` = FAIL. |
| AC4 | Source repo unchanged | `git ls-files -s .claude \| awk '$1==120000' \| wc -l` = 64; `test -f .claude/skills/cora/SKILL.md` |
| AC5 | Negative controls (fail closed) | Fixture D6 steps 3-5 PASS: synthetic `x/evil -> ../../etc` archive refused by the pinned install with digest unchanged and no residue; synthetic temp repo `archive-links` exit 1 naming `x/evil`, exit 0 after removing it; `archive-links --tarball` on the synthetic archive exit 1; `release-verify.sh archive-links . v4.0.2` exit 1 and the v4.0.2 pinned install refused with `escaping link target`. A `SKIP:` on the v4.0.2 checks = AC5 FAIL for this phase (the tag exists locally). `release-verify.sh archive-links . HEAD` exit 0. |
| AC6 | No regression | `bash .tad/tests/run-all.sh` = `RUN-ALL: PASS` (note: plain run-all does not execute `archive-shape`; it runs only under `TAD_TEST_FULL=1`); `tad-update-fixture.sh --case download-safety` and `--case archive-shape` VERDICT PASS; `git diff <base>..HEAD -- tad.sh` empty; `git diff <base>..HEAD -- .tad/hooks/lib/release-verify.sh` touches no line between `structural)` and its closing `;;`; `TAD_TEST_FULL=1` run of `installer-data-safety-fixture.sh --case all` PASS (or record its runtime and result) |
| AC7 | Runbook + provenance | `grep -n 'archive-links' .agents/skills/release-runbook/references/publish-ops.md` hits §3.2 and §4 (the `--tarball` step sits between the push-main and create-tag steps); `release-verify.sh provenance .` exit 0 on commit 2; `release-verify.sh` with no args exits 2 and its output contains both exact lines `  release-verify.sh archive-links <repo_root> [<ref>]` and `  release-verify.sh archive-links --tarball <file>` |

**AC dry-run (Alex):**
- y3: AC1 pattern probed in a scratch clone (D1). D3 extraction run against a fixed-shape archive (rc 0) and the `v4.0.2` archive (rc 1).
- y4, AC3 oracle: `git archive HEAD` extracted to scratchpad, `.claude` removed from the extraction (the shape `/.claude export-ignore` produces), installed into two empty projects with `--source` (default and `--platform claude-code`): both rc 0, version 4.0.2. `structural` → exactly 1 `❌`, `.tad/migrations DIFF`, exit 1; `diff -rq` of migrations = the single line `Only in <T>/.tad/migrations: genesis.yaml`; the archive has no `genesis.yaml`; `.agents/skills` extras were only `.tad-pack-meta.yaml` (already filtered by `structural`); `.claude/skills/cora -> ../../.agents/skills/cora` in the claude-code target. The new AC3 passes on a correct fix and would fail on any other difference.
- AC2/AC5/AC6/AC7 not dry-run: they need the implementation.

## 9.2 Expert Review Status
Not done by Alex in this dispatch (Cora dispatches reviewers).

## 10. Notes
- 10.1 Warning: never add `--worktree-attributes` to the `archive-links` mode or the fixture case; that would test the worktree, not the commit GitHub archives.
- 10.2 GitHub's own export-ignore handling is proven by the new §4 runbook step (download of the exact commit's archive before tagging), executed by the release task, not by Blake here.
- 10.3 Do not change `structural` to tolerate `genesis.yaml`; it is a sync gate and its strictness is correct for that use.

## Template checks (Alex step1b-1d)
- Frontmatter: `task_type`, `e2e_required`, `research_required`, `dispatch_id: p1-y4-1` present; `e2e_required: yes` because AC2/AC3 are real install runs.
- Files to Modify grounded: every path in §7 was read (§7.3); all exist except `.gitattributes` (create).
- AC dry-run: recorded above; each AC names a command and an expected value.
