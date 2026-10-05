---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - ".tad/scripts"
  - ".claude/skills/tad-update"
  - ".agents/skills/tad-update"
  - ".opencode/commands"
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)  
**To:** Blake (Agent B - Execution Master)  
**Date:** 2026-09-02  
**Project:** TAD Framework  
**Task ID:** TASK-20260902-TAD-UPDATE-V2431  
**Handoff Version:** 1.0.0  
**Epic:** N/A  
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-02

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | One updater helper delegates to one pinned canonical installer path |
| Components Specified | ✅ | Installer, helper, three entry surfaces, fixtures, docs, and release transaction specified |
| Functions Verified | ✅ | Existing installer functions and call graph grounded |
| Data Flow Mapped | ✅ | Check → human confirmation → canonical installer mapped |

**Gate 2 结果**: ✅ PASS

**Alex确认**: Two independent review rounds completed; all P0/P1 findings are resolved in this contract. Blake can implement independently.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read this handoff in full.
- [ ] Read the project-knowledge files listed below.
- [ ] Restate the user flow and safety boundary before implementation.
- [ ] Do not publish until implementation, Gate 3, and Alex Gate 4 are complete.

## 1. Task Overview

### 1.1 What We're Building

Ship TAD v2.43.1 with two tightly related changes:

1. Permanently repair macOS upgrades when a project-owned `.tad/` contains a dangling symlink, including the reported `helpers/node_modules` case.
2. Add one current-project updater surfaced as `$tad-update` in Claude Code/Codex and `/tad-update` in OpenCode. All three entrypoints delegate to one `.tad/scripts/tad-update.sh`; that helper delegates installation to the canonical remote `tad.sh`.

### 1.2 Why We're Building It

**Business value:** v2.43.0 cannot upgrade some real projects because BSD/macOS `cp -r` dereferences a dangling symlink and exits non-zero under `set -e`. A safe in-product update entry removes the need to remember a long curl command.  
**User benefit:** the user can inspect the local/remote versions and backup destination, approve once, and upgrade the current project without losing local project data or OpenCode commands.  
**Success:** the original dangling-symlink fixture upgrades successfully; decline/network/invalid-version paths make no mutation; all three agent surfaces invoke the same updater; v2.43.1 can then be released from a verified exact commit.

### 1.3 Intent Statement

**真正要解决的问题**：make routine current-project upgrades safe and easy without turning OpenCode into a claimed full TAD runtime.

**不是要做的**：

- Not a second installer or migration engine.
- Not a full `--platform opencode` implementation.
- Not a global/fleet updater.
- Not an unattended updater that lets an agent silently approve on the human's behalf.
- Not permission to use `--force`, downgrade, or overwrite arbitrary `.opencode/` content.

Before implementation, Blake must restate: (1) the one-engine architecture, (2) the explicit human confirmation boundary, and (3) the updater-only OpenCode scope.

## 📚 Project Knowledge（Blake 必读）

### Relevant categories

- [x] architecture
- [x] testing
- [x] release/sync
- [x] shell portability
- [x] user-data safety

### Required reads

| File | Key instruction |
|------|-----------------|
| `.tad/project-knowledge/principles.md` | User-owned data is never an acceptable casualty of framework synchronization. |
| `.tad/project-knowledge/patterns/release-sync.md` | Fetch remote version before any “already latest” exit; test a real old-install upgrade path; do not leak local-only content through mirrors. |
| `.tad/project-knowledge/patterns/shell-portability.md` | BSD/macOS behavior is load-bearing; quote paths and test spaces/symlinks on the actual shell contract. |
| `.tad/project-knowledge/patterns/ac-verification.md` | AC commands must be runnable and discriminative, with negative controls for silent-failure paths. |
| `.tad/project-knowledge/patterns/handoff-design.md` | Keep implementation authority and verification scope explicit. |

### Historical lessons

1. A stale local installer cannot repair itself if it decides “already latest” before fetching the remote version. The updater must obtain and validate the remote version before deciding.
2. A framework copy may only add/update the exact TAD-owned OpenCode command. It must not replace `.opencode/commands/` or touch unrelated user commands.
3. A successful-looking partial backup is unacceptable. Backup failure must stop before framework mutation.

## 2. Background Context

### 2.1 Previous Work

- v2.43.0 was published and a formal GitHub Release exists.
- `tad.sh` already owns remote version probing, source download, project backup, framework copy, migration, rollback, and post-install completeness verification.
- Claude Code and Codex share byte-parity skill trees.
- OpenCode officially discovers project commands from `.opencode/commands/<name>.md`; the filename becomes `/name`.

### 2.2 Current State

- `backup_existing()` currently runs `cp -r .tad "$backup_dir"`.
- The legacy migration branch separately runs `cp -r .tad .tad-migrate-backup`.
- On macOS, a dangling symlink beneath `.tad` makes lowercase `cp -r` fail. Uppercase `cp -R` preserves the symlink and succeeds.
- There is no `tad-update` helper, Claude/Codex skill, or OpenCode command.
- Installer platform codes remain `claude-code`, `codex`, and `both`; this task must not add OpenCode as a full platform.

### 2.3 Dependencies

- Existing tools only: Bash, `curl`, `tar`, standard POSIX/macOS utilities, and the canonical `tad.sh`.
- No new package dependency or credential.
- Network is required only for the remote version check and approved update.

## 3. Requirements

### 3.1 Functional Requirements

**FR-1 — Backup repair**

- Change both recursive `.tad` snapshot operations that traverse project-owned data from `cp -r` to `cp -R` (or an equivalently proven symlink-preserving BSD/macOS-safe mechanism).
- Do not mechanically rewrite unrelated recursive copies without evidence they traverse the same user-data boundary.
- Move the normal backup out of the current preflight position: source download, immutable-version validation, platform resolution, OpenCode collision preflight, and human confirmation occur first; the backup occurs immediately before the first project mutation.
- A failed backup must abort before framework copy/migration mutates the project.
- Both normal and migration backup destinations must be unique. Replace the fixed `.tad-migrate-backup` plus destructive pre-delete with one captured unique path variable used by every later migration read/report. Never delete or overwrite a pre-existing recovery copy.

**FR-2 — Single updater engine**

- Create `.tad/scripts/tad-update.sh` as the only update orchestration helper.
- Default/check behavior resolves the current project root, reads `.tad/version.txt`, downloads the official remote `.tad/version.txt` with a bounded timeout, validates strict `MAJOR.MINOR.PATCH`, and reports:
  - current version,
  - remote version,
  - whether an update is available,
  - the backup path/pattern that the installer will create.
- If already current: exit 0 without mutation.
- If remote is older: refuse downgrade and make no mutation.
- If the project is not TAD-initialized, remote data is malformed, or network retrieval fails: fail clearly and make no mutation.
- When an update is available, default interactive mode asks once for explicit human confirmation. Decline exits cleanly without mutation.
- `--check` is always read-only. With no flag and no controlling TTY, perform the check, print `confirmation required`, exit with a documented nonzero status, consume no piped input, and invoke no installer. `--yes` is the sole apply mechanism after external human approval. Agent-facing instructions must never infer human consent.
- Bind apply to the version that the human saw: after reading `X.Y.Z`, use the immutable release ref `vX.Y.Z`, download the official tagged `tad.sh` to a private temporary file, and invoke it with a new strict expected-version/release-ref contract. The installer must download the same immutable tag archive, derive its `.tad/version.txt`, and reject any ref/version/source mismatch before project mutation.
- The tagged installer download must be non-empty and recognizable as TAD's Bash installer; propagate failure and clean the private temp file. All archive download/extraction also occurs under a unique mode-0700 `mktemp -d` outside the project root; validate exactly one safe extracted source root and trap-clean it on every exit. No `TAD-*` directory or download residue may appear in the project.
- Do not use `curl | bash`, `--force`, or reimplement backup/copy/migration logic.
- Preserve the installed platform with deterministic precedence: both canonical Alex skill roots present → `both`; only `.claude/skills/alex` → `claude-code`; only `.agents/skills/alex` → `codex`; neither, inconsistent, or partial markers → check may report ambiguity but apply must require explicit `--platform claude-code|codex|both`. Forward the resolved value to `tad.sh`; never invent an OpenCode platform value.
- Production endpoint constants are fixed to the official HTTPS GitHub repository. Do not accept URL/code-source overrides from inherited environment variables. Deterministic tests intercept fixed URLs with a temporary mock `curl` in `PATH`.

**FR-3 — Claude Code and Codex entrypoints**

- Create byte-identical `.claude/skills/tad-update/SKILL.md` and `.agents/skills/tad-update/SKILL.md`.
- The skill runs the helper's check first, presents the result, waits for explicit human confirmation, then runs the helper's approved noninteractive path.
- The skill contains no independent version comparison, download, backup, migration, or copy algorithm.

**FR-4 — OpenCode updater-only entrypoint**

- Create `.opencode/commands/tad-update.md`, yielding `/tad-update` under OpenCode's documented convention.
- It invokes the same helper and preserves the same two-step human confirmation boundary.
- It explicitly labels OpenCode support as updater-only compatibility, not full Alex/Blake/Gate support.
- Every TAD install/upgrade mode projects only this exact TAD-owned command into `.opencode/commands/`; unrelated user files and subdirectories survive byte-identically.
- Installer completeness verification must fail if the source owns the command but it is absent or mismatched in the target.
- If `.opencode/commands/tad-update.md` already exists and differs from the source, fail in a preflight before any `.tad`, `.claude`, `.agents`, root-file, or `.opencode` mutation. Print a deterministic recovery instruction telling the user to rename/remove the conflicting file and retry. Identical content is accepted.
- If the command did not exist and this run creates it, record that fact before the atomic write. Rollback must remove only that newly created TAD file (and empty TAD-created parent directories), never pre-existing OpenCode content. Injected failure after projection must restore the exact pre-run `.opencode` state.

**FR-5 — Release/documentation**

- Bump all authoritative release carriers to `2.43.1` using the existing release derivation/order, not a hand-maintained guess list.
- Add a v2.43.1 CHANGELOG entry covering the backup defect and updater surfaces.
- Update README and installation documentation with Claude Code/Codex/OpenCode invocation and the OpenCode scope caveat.
- After Gate 3 and Alex Gate 4, publish the exact accepted main commit as tag `v2.43.1` and a formal GitHub Release. Do not publish from a dirty tree or move an existing tag.

### 3.2 Non-Functional Requirements

- macOS Bash 3.2 compatible; no Bash-4-only arrays/features in shipped shell paths.
- All path expansions quoted; works from a project path containing spaces.
- Network and validation failures are fail-closed before project mutation.
- No credential collection or persistence.
- Tests are deterministic and do not call real providers.
- Do not alter the semantics of `--platform claude-code|codex|both`.

## 4. Technical Design

### 4.1 Architecture Overview

```text
Claude/Codex skill ─┐
                    ├─> .tad/scripts/tad-update.sh --check
OpenCode command ───┘              │
                                   ├─ no update / error / decline → no mutation
                                   └─ explicit human approval
                                              │
                                              v
                                tad-update.sh --yes
                                              │ download to private temp
                                              v
                              canonical remote tad.sh --yes
                                              │
                             backup → copy → migrate → verify/rollback
```

Authority is one-way: entrypoint prose → updater helper → canonical installer. No lower layer calls back into an entrypoint, and no entrypoint embeds installer behavior.

### 4.2 Component Specifications

**`tad.sh`**

- Repair `backup_existing()` and the migration snapshot.
- Add a narrow copy + verification block for `.opencode/commands/tad-update.md`; create parent directories as needed, copy only that file, and compare it with the source.
- Never delete or recursively synchronize `.opencode`.

**`.tad/scripts/tad-update.sh`**

- CLI: `--check` (explicit read-only), `--yes` (apply after external human approval), `--platform claude-code|codex|both`, and `--help`. Default prompts only with a controlling TTY; non-TTY never applies.
- Use exact compiled-in official HTTPS URLs. Tests shadow `curl` through `PATH`; there is no production URL override.
- Record no state of its own; the existing installer remains recovery authority.

**Pinned installer contract in `tad.sh`**

- Add narrowly scoped `--release-ref vX.Y.Z --expected-version X.Y.Z` options, accepted only as a matching pair with strict syntax/equality. They select the corresponding immutable GitHub tag archive.
- In pinned mode, do not call or consume the mutable-main `probe_remote_version`: set the target from the validated expected version, download only the matching tag archive into the private temp root, derive its authoritative version, and compare before state detection/confirmation. A fixture where `main` advertises a different version must still offer/install only the pinned version (or reject consistently), never mix them.
- After download, discover exactly one safe extracted source root without assuming `TAD-main`; reject symlinked/escaping/multiple roots, derive its authoritative version, and compare it to the expected version.
- Perform OpenCode conflict preflight and create backups only after this match succeeds and confirmation has been granted. A mismatch exits nonzero with no project mutation.
- The ordinary curl install path remains compatible and continues to use `main` when these options are absent.

**Agent entrypoints**

- Keep them short, declarative, and identical in behavior.
- OpenCode command may differ in frontmatter/format, but not in workflow semantics.

### 4.3 Data Models

No durable data model. Runtime values are validated semantic version strings and ephemeral download paths.

### 4.4 API Specifications

No public network API is introduced. The only remote reads are the existing official raw version and installer URLs.

### 4.5 User Interface Requirements

Example check output:

```text
TAD update check
Current: 2.43.0
Remote:  2.43.1
Backup:  .tad.backup.<timestamp-or-unique-suffix>
Update available. Continue? [y/N]
```

The default is No. Error messages must say what failed and confirm that no update was applied when failure occurs before installer execution.

## 5. 强制问题回答

### MQ1: Historical code search

Graph search found `backup_existing`, `copy_framework_files`, `verify_install_complete`, `probe_remote_version`, and `derive_target_version` in `tad.sh`. Shell inspection found the second project-data snapshot at the migration branch. Existing install fixtures live under `.tad/tests/`.

### MQ2: Function existence

| Function | Exists | Role |
|----------|--------|------|
| `backup_existing` | yes | Pre-mutation project `.tad` snapshot |
| `probe_remote_version` | yes | Remote version fetch before state gate |
| `derive_target_version` | yes | Authoritative downloaded-source version |
| `copy_framework_files` | yes | Framework projection |
| `verify_install_complete` | yes | Post-copy completeness check |
| `call_migration_engine` | yes | Sole migration executor |

### MQ3: Data flow completeness

| Input | Validation | Mutation boundary | Recovery/exit |
|------|------------|-------------------|---------------|
| local `.tad/version.txt` | strict SemVer | none during check | invalid → error |
| remote version | timeout + strict SemVer | none during check | failure → error |
| human decision | explicit yes only | enables installer | no/EOF → no mutation |
| remote installer | private temp + content sanity | `bash installer --yes` | installer rollback contract |
| OpenCode command | exact source file | exact-file copy only | verify mismatch → install failure |

### MQ4/MQ5

No visual UI or persistent client state. Terminal states are `UP_TO_DATE`, `UPDATE_AVAILABLE`, `DECLINED`, `REFUSED_DOWNGRADE`, `CHECK_ERROR`, and the canonical installer's exit result.

## 6. Implementation Steps

### Phase 1 — Repair and deterministic updater

1. Add a red regression fixture for the reported dangling symlink.
2. Repair both project-data snapshot sites and collision behavior.
3. Implement the updater helper and deterministic classification/apply fixtures.
4. Run focused shell syntax and update tests.

### Phase 2 — Platform projection and release

1. Add parity skills and the exact OpenCode command.
2. Add installer copy/completeness coverage that preserves unrelated OpenCode content.
3. Update docs/version carriers through the release runbook.
4. Run full release gates, Gate 3, and hand back to Alex for Gate 4.
5. Only after Gate 4, publish exact main/tag/GitHub Release v2.43.1 and verify remotely.

## 6.1 Micro-Tasks

| ID | Task | Proof |
|----|------|-------|
| M1 | Reproduce lowercase `cp -r` failure with dangling symlink | Negative control fails before fix |
| M2 | Repair both backup paths and uniqueness | Fixture passes and link remains a link |
| M3 | Implement updater state machine | Matrix test passes |
| M4 | Add agent entrypoints | parity + content checks |
| M5 | Project OpenCode command safely | preservation fixture passes |
| M6 | Update release carriers/docs | release gates pass |
| M7 | Gate 3 and Gate 4 | reports PASS |
| M8 | Publish v2.43.1 | remote tag/release/source verification |

### AC Dry-Run Log

Alex step1d on 2026-09-02:

- AC1 pre-implementation negative control ran on macOS: lowercase `cp -r` emitted `No such file or directory`, inner exit `1`; the wrapper assertion exited `0` as expected.
- AC2–AC14 are post-implementation rows. Their shell command forms were parsed with `bash -n -c` where applicable; required existing CLI usages were checked against their `--help`/runbook contracts. AC9 was corrected after dry-run showed `upgrade-acceptance.sh` requires explicit target/version arguments.
- `bash .tad/hooks/lib/verify-ac-commands.sh .tad/active/handoffs/HANDOFF-20260902-tad-update-v2431.md` reported `0 warnings, 0 info`.
- AC14 intentionally contains `<GATE4_SHA>` and becomes runnable only after Alex records the accepted commit; Blake must not substitute an implementation guess.

## 7. File Structure

### 7.1 Files to Create

```text
.tad/scripts/tad-update.sh
.tad/tests/tad-update-fixture.sh
.claude/skills/tad-update/SKILL.md
.agents/skills/tad-update/SKILL.md
.opencode/commands/tad-update.md
```

### 7.2 Files to Modify

```text
tad.sh
.tad/tests/upgrade-acceptance.sh
.tad/hooks/lib/release-verify.sh       # only if derived structural/version coverage requires it
.tad/version.txt
package.json
CHANGELOG.md
README.md
INSTALLATION_GUIDE.md
PROJECT_CONTEXT.md                     # version carrier only if selected by version-sweep
NEXT.md                                # release status only
```

The release tooling may identify additional existing version carriers. Blake may modify only those reported by the authoritative version-sweep/migration/supporting gates and must list them in the completion report. Do not add `opencode` to `.tad/platform-codes.yaml` unless a reviewer proves it is required for the narrow exact-file projection; the preferred design does not require it.

### 7.3 Grounded Against

- `tad.sh` — head and relevant functions read 2026-09-02; graph-qualified functions verified.
- `.tad/platform-codes.yaml` — full file read 2026-09-02.
- `.tad/tests/upgrade-acceptance.sh` — existing test location identified 2026-09-02.
- `.tad/hooks/lib/release-verify.sh` — supported gate CLI inspected 2026-09-02.
- `.tad/version.txt`, `package.json`, `CHANGELOG.md`, `README.md`, `INSTALLATION_GUIDE.md`, `PROJECT_CONTEXT.md`, `NEXT.md` — existing carriers; Blake must reread their current heads immediately before editing.
- New files listed in §7.1 do not yet exist.

## 8. Testing Requirements

### 8.1 Unit/fixture tests

- Backup fixture with a dangling relative symlink named beneath `helpers/node_modules`; backup succeeds and preserves link target text/type.
- Backup collision fixture proves two same-second normal backups cannot overwrite/nest; migration fixture begins with a pre-existing `.tad-migrate-backup` and proves it survives while the new unique migration snapshot is used by all migration reads.
- Update state matrix: newer, equal, older, malformed local, malformed remote, remote unavailable.
- Interaction matrix: TTY yes, TTY no/default/EOF, `--yes`, unsupported flag.
- Download matrix: empty/non-installer payload rejected before execution; installer non-zero propagated.
- Binding matrix: displayed version, release ref, tagged script, downloaded archive version, and `--expected-version` must agree; mismatch produces zero project mutation.
- Extraction matrix: archive extraction stays outside the project; malformed/multiple/escaping roots fail and leave the full project tree unchanged with no `TAD-*` residue.
- Platform matrix: `claude-code`, `codex`, `both`, explicit override, and ambiguous/partial layout.

### 8.2 Integration tests

- Upgrade a disposable v2.43.0 fixture containing project evidence plus the dangling link to the candidate version.
- Confirm source project files and symlink survive in the announced backup.
- Confirm `.opencode/commands/custom.md` and an unrelated subdirectory are byte-identical after fresh/partial install, same-major upgrade, and legacy migration while TAD's `tad-update.md` is present and source-identical.
- With a divergent existing `.opencode/commands/tad-update.md`, confirm the installer fails before any `.tad`, `.claude`, `.agents`, root-file, or `.opencode` digest changes.
- Inject a failure after a newly created OpenCode command is projected and prove rollback returns `.opencode` to its exact pre-run tree while preserving all pre-existing files.
- Exercise the update helper using local/fake endpoints only; no real GitHub mutation.
- Run existing upgrade, state-detection, migration, parity, version, version-sweep, structural, and supporting gates.

### 8.3 Edge cases

- Project path contains spaces.
- Symlink target is absent.
- Backup destination collision.
- stdin is not a TTY.
- Remote version is HTML or contains extra lines.
- Remote is behind local.
- `curl` timeout/failure.
- Existing user OpenCode command has the same filename but different content: fail the preflight without writing anything and print the rename/remove recovery instruction.

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| macOS-specific `cp` semantics | Run fixture on macOS/BSD `cp` | Local machine is macOS | GNU-only evidence is not equivalent | Missing macOS proof blocks Gate 3 |
| Network for final publish | GitHub auth and connectivity | Existing `gh`/git credentials | None for publication; local implementation may still pass | Blocks release, not implementation Gate 3 |
| Existing v2.43.0 consumers | Publish patch release | Exact accepted commit/tag/release | None | Task incomplete until remote verification |
| Human confirmation | User approves apply/publish boundary | Explicit conversation record | `--yes` only after that approval | Agent may not self-authorize |

## 8.5 Feedback Collection

N/A — code and command-line documentation only.

## 8.6 Test Evidence Required

- Focused fixture logs including negative controls.
- Full release-gate output and exact commit SHA.
- Before/after digests for user-owned OpenCode fixtures and backup contents.
- Gate 3 reviewer reports and Alex Gate 4 record.
- Remote GitHub tag/release/source verification after publication.

## 9. Acceptance Criteria

All rows in §9.1 are mandatory. A failure is not waived by the updater being “convenient”; data safety and explicit human consent are the feature.

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | Baseline reproduces the reported macOS dangling-symlink failure | pre-impl-verifiable | `tmp=$(mktemp -d); mkdir -p "$tmp/src/.tad/evidence/helpers"; ln -s missing "$tmp/src/.tad/evidence/helpers/node_modules"; (cd "$tmp/src" && cp -r .tad "$tmp/backup-r"); rc=$?; rm -rf "$tmp"; test "$rc" -ne 0` | exit 0 because lowercase copy fails | `PASS on macOS: inner cp emitted No such file or directory; wrapper exit 0` |
| AC2 | Both project-data snapshot sites preserve dangling links and never destroy an existing recovery copy | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case backup` | PASS; link preserved; normal collisions unique; pre-existing migration backup unchanged; new unique migration path used end-to-end | (post-impl; command syntax validated) |
| AC3 | Update and platform classification are deterministic | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case states` | PASS for newer/equal/older/malformed/unavailable plus claude-code/codex/both/explicit/ambiguous layouts; ambiguous apply refuses; all pre-mutation failures preserve project digest | (post-impl; command syntax validated) |
| AC4 | Explicit confirmation is required and apply delegates exactly once to the canonical installer | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case consent` | decline makes zero calls; no-TTY default exits `confirmation required` nonzero without consuming stdin; only approved/`--yes` calls once; no `--force` | (post-impl; command syntax validated) |
| AC5 | Download, private extraction, and immutable release binding are fail-closed | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case download-safety` | empty/HTML/non-installer and unsafe archive roots rejected; pinned mode ignores mutable-main probe; version/ref/script/archive mismatch leaves full project digest unchanged with no `TAD-*` residue; non-zero installer propagated; temp cleaned; environment URL override ignored/rejected | (post-impl; command syntax validated) |
| AC6 | Claude and Codex updater skills are byte-identical and delegate only to shared helper | post-impl-verifiable | `cmp -s .claude/skills/tad-update/SKILL.md .agents/skills/tad-update/SKILL.md && rg -q '\.tad/scripts/tad-update\.sh' .claude/skills/tad-update/SKILL.md && ! rg -q 'curl|cp -[rR]|migration-engine|raw\.githubusercontent' .claude/skills/tad-update/SKILL.md` | exit 0 | (post-impl; command syntax validated) |
| AC7 | OpenCode exposes updater-only `/tad-update` through the same helper | post-impl-verifiable | `test -f .opencode/commands/tad-update.md && rg -q '\.tad/scripts/tad-update\.sh' .opencode/commands/tad-update.md && rg -qi 'updater.only|update.only|升级入口|更新入口' .opencode/commands/tad-update.md && ! rg -q 'curl|cp -[rR]|migration-engine|--platform opencode' .opencode/commands/tad-update.md` | exit 0 | (post-impl; command syntax validated) |
| AC8 | All installer branches project exactly one TAD OpenCode command without altering user content | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case opencode-preservation` | fresh/partial, upgrade, and migration PASS; custom tree unchanged; missing/mismatched source command caught; divergent target conflict causes zero changes across all managed surfaces; injected post-projection failure restores exact pre-run `.opencode` tree | (post-impl; command syntax validated) |
| AC9 | Real disposable v2.43.0→2.43.1 upgrade and existing state/migration suites remain green | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case full-upgrade && bash .tad/tests/detect-state-fixture.sh && bash .tad/tests/migration-fixtures/run-fixtures.sh` | full-upgrade invokes `upgrade-acceptance.sh --target <fixture> --expected-version 2.43.1 --snapshot <snapshot> --expect-migration-from 2.43.0`; all suites PASS | (post-impl; command syntax validated) |
| AC10 | Release preflight runs in the authoritative order | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case release-gates` | recorded order and exit 0: parity → derive-sync-set report + version 2.43.1/2.43.0 → version-sweep → migration → pack-registry driftcheck (advisory recorded) → tad.sh denylist | (post-impl; fixture must invoke the canonical commands, not reimplement them) |
| AC11 | Version carriers contain the patch release with no unexplained stale authoritative references | post-impl-verifiable | `test "$(cat .tad/version.txt)" = 2.43.1 && test "$(node -p 'require("./package.json").version')" = 2.43.1 && bash .tad/hooks/lib/release-verify.sh version . 2.43.1 2.43.0 && bash .tad/hooks/lib/release-verify.sh version-sweep . 2.43.1` | exit 0; any patch-advisory historical reference explicitly dispositioned | (post-impl; command syntax validated) |
| AC12 | Shell files parse under shipped Bash contract | post-impl-verifiable | `bash -n tad.sh .tad/scripts/tad-update.sh .tad/tests/tad-update-fixture.sh` | exit 0 | (post-impl; command syntax validated) |
| AC13 | Documentation describes the updater and OpenCode limitation in every intended carrier | post-impl-verifiable | `for f in README.md INSTALLATION_GUIDE.md CHANGELOG.md; do rg -q 'tad-update' "$f" || exit 1; done; for f in README.md INSTALLATION_GUIDE.md; do rg -qi 'OpenCode' "$f" && rg -qi 'updater.only|update.only|升级入口|更新入口' "$f" || exit 1; done` | exit 0; each file independently satisfies its requirement | (post-impl; command syntax validated) |
| AC14 | Published release is annotated and every remote ref resolves to the exact accepted commit | post-impl-verifiable | `bash .tad/tests/tad-update-fixture.sh --case remote-release --expected-version 2.43.1 --expected-commit <GATE4_SHA>` | local tag object type is `tag`; origin/main, remote tag peeled SHA, and GitHub Release target all equal `<GATE4_SHA>`; release is non-draft/non-prerelease with URL | (post-Gate-4 publication only; syntax validated) |

AC conflict note: AC4's no-mutation consent boundary and AC14's publication mutation occur in different phases. Publication is never part of a pre-confirmation updater test.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P1: fixed migration backup could delete prior recovery data | FR-1, AC2 | Resolved |
| code-reviewer | P1: platform preservation undefined and untested | FR-2, AC5/AC9 fixture matrix | Resolved |
| code-reviewer | P1: approved version not bound to installed source | FR-2, pinned installer contract, AC5 | Resolved |
| code-reviewer | P1: AC9 invoked upgrade-acceptance without required arguments | AC9 | Resolved |
| code-reviewer | P1: same-name OpenCode collision policy unresolved | FR-4, AC8 | Resolved |
| code-reviewer | P2: documentation AC could pass with only one carrier | AC13 | Resolved |
| code-reviewer | P2: universal OpenCode projection lacked branch coverage | §8.2, AC8 | Resolved |
| release/security architect | P0: divergent OpenCode command could be destroyed outside rollback | FR-4 preflight, AC8 | Resolved |
| release/security architect | P1: environment URL override would create code-execution injection | FR-2 fixed endpoints, AC5 | Resolved |
| release/security architect | P1: no-TTY consent behavior ambiguous | FR-2, AC4 | Resolved |
| release/security architect | P1: release gate order and remote proof incomplete | AC10, AC14 | Resolved |
| code-reviewer (R2) | P1: source extraction could mutate the project before validation | Pinned installer contract, AC5 | Resolved |
| code-reviewer (R2) | P1: pinned mode could still consume mutable-main probe | Pinned installer contract, AC5 | Resolved |
| release/security architect (R2) | P1: new OpenCode write lacked rollback treatment | FR-4, AC8 | Resolved |

### Experts Selected

1. **code-reviewer** — shell correctness, regression, and runnable-AC review.
2. **release/security architect** — self-update trust boundary, user-data preservation, and publication ordering.

Reviewed via subagent fallback in two rounds: `/root/update_code_review` and `/root/update_release_review`. Both were read-only and independently grounded findings against the current `tad.sh` and release runbook.

### Overall Assessment

- code-reviewer: PASS after two rounds; 7 P1 and 2 P2 findings integrated, no unresolved P0/P1.
- release/security architect: PASS after two rounds; 1 P0 and 5 P1 findings integrated, no unresolved P0/P1.

## 10. Important Notes

### 10.1 Critical Warnings

- Do not “fix” the report by deleting the dangling `node_modules` symlink; project evidence is user-owned.
- Do not recursively copy or delete `.opencode/`.
- Do not let the agent-facing command turn check mode into automatic approval.
- Do not publish before Gate 4 or from any SHA other than the accepted clean main commit.

### 10.2 Known Constraints

- Old installations do not yet contain `/tad-update`; their one-time bridge remains the current curl installer command. After v2.43.1 lands, future upgrades can use the new entrypoint.
- OpenCode support in this task is updater-only. Its availability does not certify full TAD role, hook, or gate parity.

### 10.3 Sub-Agent use recommendation

One implementation owner is preferred because installer, updater, and release carriers share a serial safety boundary. Use independent reviewers for code and release/security; do not split concurrent edits across `tad.sh` and its tests.

## 11. Learning Content

### Decision Rationale: one engine, three entrypoints

| Option | Benefit | Cost/Risk | Decision |
|--------|---------|-----------|----------|
| Shared updater delegating to canonical installer | One safety and migration authority | Small wrapper + projection work | Selected |
| Duplicate update logic per platform | Superficially direct | Drift and inconsistent safety | Rejected |
| Add full OpenCode platform | Larger future surface | Claims unsupported runtime parity | Rejected |

The updater is a control surface, not a new installer. Reuse the existing transactional path and keep human consent outside the noninteractive `--yes` execution step.

## 12. Sub-Agent Use Record

Blake records implementation/review agents and evidence here in the completion report; no mandatory parallel implementation is prescribed.

---

**Handoff Created By:** Alex (Agent A)  
**Date:** 2026-09-02  
**Version:** 1.0.0
