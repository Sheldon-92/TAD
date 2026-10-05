---
task_id: TASK-20260908-PUBLISH-V2443
task_type: release
express: true
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: ARCHIVED
archived_to: .tad/archive/handoffs/HANDOFF-20260908-release-v2443.md
---

# HANDOFF-20260908-release-v2443 — Publish v2.44.3 (Local Wiki Research Route + Experimental Thin-TAD Pilot Tooling)

**Task ID**: `TASK-20260908-PUBLISH-V2443` | **Owner**: Blake (Terminal 2) | **Author**: Alex (Terminal 1)  
**Created**: 2026-09-08 | **Status**: READY FOR BLAKE (Gate 2 PASS 2026-09-08, dual carriers P0=0)
**PM amend 2026-09-08 (Human: rebase):** local 3 commits rebased onto `origin/main`=`edce7606` (NEXT ledger-only). New tip `27acaf37`. Blake may proceed with updated preconditions.
  
**Target Release**: `v2.44.3` (Patch) | **Prior Release**: `v2.44.2` (`edce7606`)  
**Mode**: publish-only (stops after release verification; NO sync)  

---

## 1. Execution Mandate (PM / Human Authorization Scope)

- **Outcome**: Publish patch release **v2.44.3** =
  1. Bump version from `2.44.2` to `2.44.3` across the 12 primary version identity files + `CHANGELOG.md` + dual `.agents/skills/` mirrors.
  2. Create release commit **R** (child of `27acaf37`) using **STRICT PATHSPEC-ONLY STAGING**.
  3. Verify release pre-conditions (`release-verify.sh parity`, `version-sweep`, `migration`, `--verify-denylist`).
  4. Push `main` (commit R) to `origin/main` (clean fast-forward).
  5. Create annotated tag `v2.44.3` on R and push tag `v2.44.3` to `origin`.
  6. Create GitHub Release `v2.44.3` with accurate, honest release notes.
  7. Verify post-publish state and output completion report. NO downstream sync.
- **Target**: `https://github.com/Sheldon-92/TAD.git`
  - `refs/heads/main`
  - `refs/tags/v2.44.3`
- **Consequence**:
  - Remote `main` moves `edce7606` (v2.44.2) → `27acaf37` (3 accepted commits) → commit R (release commit, total 4 new commits on remote).
  - New public tag `v2.44.3` pointing to commit R.
  - Public GitHub Release `v2.44.3` published.
- **Blast radius**:
  - Remote `main`, one new tag `v2.44.3`, and GitHub release entry.
  - Working tree: MUST NOT absorb dirty/mode noise. Working tree has large unrelated dirty/mode noise — staging is strictly pathspec-only.
  - No downstream project sync, no registry modification.
- **Recovery policy**:
  - Ambiguous push/tag: `git ls-remote` check before any retry.
  - Remote-ahead: STOP immediately, never `--force`.
  - Tag collision: STOP.
  - Dirty tree absorption: If `git show --stat R` contains any file other than the designated 16 version/CHANGELOG files, abort/reset before pushing.
- **Forbidden**:
  - `git add -A`, `git add .`, or directory adds (`git add .claude/skills/`).
  - Staging mass mode changes (`chmod` script noise) or uncommitted research files.
  - `--force`, `--tags`, unscoped refspecs.
  - Chaining commands (`&&` or `;`) across push/tag operations.
  - Starting Blake before Gate 2 PASS with dual disk carriers.

---

## 2. Background — What Commit R Puts on Top of

`git log --oneline v2.44.2..HEAD` (all local, accepted, none pushed yet; remote `origin/main` = `edce7606` v2.44.2):

| Commit | Component / Feature | Gate & Task Status | Honesty & Scope Notes |
|---|---|---|---|
| `9e0d8ab1` | `feat(experiment): thin-tad-pilot P1 offline task package tool (AC0-AC9, 32/32 tests)` | PASS `GATE4-20260907-thin-tad-evaluation-p1` | **Experimental Pilot Tooling**: 5 files in `experiments/thin-tad-pilot/`. 12 synthetic task instances across 6 categories × Human/Variant arms, frozen arm texts, offline dry-run harness, 32/32 tests. Zero core framework modifications; offline dry-run only; no live model claims. |
| `12aafe19` | `feat(TAD): implement thin-tad-harness-adapter [Gate 3 pending]` | PASS `GATE4-20260908-thin-tad-harness-adapter` | **Experimental Harness Adapter**: 4 files in `experiments/thin-tad-pilot/` (`oc-adapter.sh`, `runner.mjs`, `runner.test.mjs`, `README.md`). Added fail-closed isolation probe, 40/40 tests. Zero live model spend, fail-closed on missing harness. |
| `27acaf37` | `feat(research): Local Wiki primary route; NotebookLM fallback only` | PASS `GATE4-20260908-research-route-local-wiki` | **Core TAD Research Routing**: Cleared stale NotebookLM-primary pointers across 6 architectural tiers (CLAUDE.md, Alex/Blake SKILLs, protocols, quick-reference guides, capability packs); Local Wiki + Iron Rule established as primary research engine; NotebookLM preserved intact as cloud fallback. 12 dual-platform mirror pairs are 100% byte-for-byte identical. |

- `origin/main`: `edce7606d4324f30cb4d3e20d0d659bc727a3533` (v2.44.2)
- `HEAD` (local main): `27acaf3715533220bb7d15aef49245ae8c8851a1` (ahead by 3 commits, clean fast-forward)
- `origin/refs/tags/v2.44.3`: Absent (verified)

---

## 3. Requirements & Implementation Steps (Blake)

### 3.1 Version Bump Scope (NEW = 2.44.3, OLD = 2.44.2)

Blake must update the following 12 primary version locations to `2.44.3`:

1. `.tad/version.txt`: `2.44.3`
2. `.tad/TAD-VERSION`: `2.44.3`
3. `.tad/config.yaml`:
   - Line 1: `# TAD Configuration v2.44.3 - Full is the Default Channel (lite frozen 2026-08-13)`
   - Line 3: `version: 2.44.3`
4. `package.json`: `"version": "2.44.3"`
5. `tad.sh`: `TARGET_VERSION="2.44.3"`
6. `README.md`:
   - Line 3: `**Version 2.44.3 — Local Wiki Primary Research Route + Experimental Thin-TAD Pilot Tooling**`
   - Line 5: `> v2.44.3 release: Local Wiki primary research route + experimental thin-tad pilot tooling & harness adapter — see [CHANGELOG](CHANGELOG.md#2443---2026-09-08).`
   - Line 190: `# Should show: 2.44.3`
   - Line 506: `**Welcome to TAD v2.44.3 — Local Wiki Primary Research Route + Experimental Thin-TAD Pilot Tooling**`
7. `INSTALLATION_GUIDE.md`:
   - Line 3: `**Version 2.44.3 — Alex / Blake is the Default**`
   - Line 51: `cat .tad/version.txt          # 应显示 2.44.3`
8. `PROJECT_CONTEXT.md`:
   - Line 4: `- **Version**: 2.44.3 (Full is the default channel, ...)`
   - Line 6: `- **Framework**: TAD v2.44.3 + Full-default/Lite-frozen ...`
9. `docs/MULTI-PLATFORM.md`:
   - Line 3: `**Version**: 2.44.3 (Dual-Platform Architecture — Full is the Default Channel; lite frozen 2026-08-13)`
10. `.claude/skills/tad-help/SKILL.md`:
    - Line 17: `Version: v2.44.3 | Generated: [timestamp]`
11. `.claude/skills/alex/SKILL.md`:
    - Line 50: `<!-- TAD v2.44.3 Framework -->`
12. `.claude/skills/blake/SKILL.md`:
    - Line 166: `<!-- TAD v2.44.3 Framework -->`

### 3.2 Dual-Tree Skill Parity Sync

Blake must selectively synchronize the 3 modified skills to `.agents/skills/`:
```bash
cp .claude/skills/tad-help/SKILL.md .agents/skills/tad-help/SKILL.md
cp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md
cp .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md
```
*Note: Do NOT run broad directory copies or permissions modifications that touch scripts.*

### 3.3 CHANGELOG Entry `[2.44.3]`

Prepend the following entry to `CHANGELOG.md` under `## [Unreleased]`:

```markdown
## [2.44.3] - 2026-09-08

### Added / Changed

- **Local Wiki Primary Research Route**:
  - Declared Local Wiki + Iron Rule as TAD's primary research engine across 6 architectural tiers (`CLAUDE.md`, Alex/Blake `SKILL.md` files, elicitation/handoff protocols, quick-reference guides, and capability packs).
  - Preserved NotebookLM intact as cloud fallback (`*research-notebook`), eliminating 20-40s cloud latency and session expiration risks on standard research tasks while maintaining deep cross-source synthesis when needed.
  - Synchronized dual-platform mirrors (`.claude/` and `.agents/`) with 100% byte-for-byte parity.
- **Experimental Thin-TAD Pilot Tooling & Harness Adapter**:
  - Added offline task package tool under `experiments/thin-tad-pilot/` with 12 synthetic instances across 6 categories × Human/Variant arms and 32/32 offline unit tests (`9e0d8ab1`).
  - Added fail-closed isolation probe runner suite and `oc-adapter.sh` with 40/40 tests (`12aafe19`), strictly partitioned as experimental pilot tooling without affecting production TAD core runtime.
```

### 3.4 Verification Gates

Run the verification gates in exact order:
1. Parity check:
   ```bash
   bash .tad/hooks/lib/release-verify.sh parity .
   ```
   (Must exit 0)
2. Version Sweep check:
   ```bash
   bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.3
   ```
   (Must exit 0 on Layer 1)
3. Migration check:
   ```bash
   bash .tad/hooks/lib/release-verify.sh migration .
   ```
   (Must exit 0)
4. Denylist check:
   ```bash
   bash tad.sh --verify-denylist
   ```
   (Must exit 0)

### 3.5 Create Release Commit R (CRITICAL: PATHSPEC-ONLY STAGING)

⚠️ **WARNING — Working tree contains unrelated dirty files and script mode churn.**
Blake MUST NOT use `git add -A`, `git add .`, or directory adds (`git add .claude/skills/`).
Blake MUST stage ONLY the exact 16 files via explicit pathspecs:

```bash
git add \
  .tad/version.txt \
  .tad/TAD-VERSION \
  .tad/config.yaml \
  package.json \
  tad.sh \
  README.md \
  INSTALLATION_GUIDE.md \
  PROJECT_CONTEXT.md \
  docs/MULTI-PLATFORM.md \
  .claude/skills/tad-help/SKILL.md \
  .claude/skills/alex/SKILL.md \
  .claude/skills/blake/SKILL.md \
  .agents/skills/tad-help/SKILL.md \
  .agents/skills/alex/SKILL.md \
  .agents/skills/blake/SKILL.md \
  CHANGELOG.md

git commit -m "release: v2.44.3

Local Wiki primary research route + experimental thin-tad pilot tooling. Version + CHANGELOG only. Local only, NOT pushed."
```

**Blake Verification Pre-Push**:
Run `git show --stat HEAD` and confirm:
- Exactly 16 files changed.
- Diff contains ONLY version string bumps and the CHANGELOG entry.
- Zero unrelated script files or deleted research files are staged or committed.

### 3.6 Mandate-Bound Publish Sequence (Sequential Execution, NO Chaining)

Before executing, verify pre-conditions:
- `origin/main` is at `edce7606`: `git ls-remote --heads origin refs/heads/main`
- `refs/tags/v2.44.3` is absent: `git ls-remote --tags origin refs/tags/v2.44.3` is empty.

**Execute the following 4 actions one by one (DO NOT chain with `&&` or `;`)**:

1. **Action P1 (Push Main Branch)**:
   ```bash
   git push origin <commit_R>:refs/heads/main
   ```
2. **Action P2 (Create Annotated Tag)**:
   ```bash
   git tag -a v2.44.3 <commit_R> -m "v2.44.3 — Local Wiki primary research route + experimental thin-tad pilot tooling"
   ```
3. **Action P3 (Push Tag)**:
   ```bash
   git push origin refs/tags/v2.44.3:refs/tags/v2.44.3
   ```
4. **Action P4 (Create GitHub Release)**:
   ```bash
   gh release create v2.44.3 \
     --title "v2.44.3 — Local Wiki Primary Research Route + Thin-TAD Pilot Tooling" \
     --notes "### TAD v2.44.3 Release Notes

#### Primary Changes
- **Local Wiki Primary Research Route**: Upstream research routing updated to make Local Wiki + Iron Rule the primary research engine across all agent roles and protocols, with NotebookLM retained as cloud fallback.
- **Experimental Thin-TAD Pilot Tooling**: Delivered offline task package tool and runner harness adapter under \`experiments/thin-tad-pilot/\` (strictly experimental, zero runtime impact on core TAD).

#### Verification
- Version sweep: 12/12 must-version patterns match 2.44.3
- Dual-platform skill parity: 100% byte identical
- Zero unmanifested migration drift
"
   ```

### 3.7 Post-Publish Verification

- `git ls-remote --heads origin refs/heads/main` == `<commit_R>`
- `git ls-remote --tags origin refs/tags/v2.44.3 "refs/tags/v2.44.3^{}"` both resolve to `<commit_R>`
- `gh release view v2.44.3` returns active release.
- Write Completion Report to `.tad/active/handoffs/COMPLETION-20260908-publish-v2443.md`.

---

## 4. Acceptance Criteria

- [ ] **AC1**: `release-verify.sh parity .` exits 0 (Layer 1 dual-tree parity PASS).
- [ ] **AC2**: `release-verify.sh version-sweep . 2.44.3` exits 0 (Layer 1 all 12 must-version patterns match).
- [ ] **AC3**: `CHANGELOG.md` has complete, accurate `[2.44.3] - 2026-09-08` entry.
- [ ] **AC4**: Release commit R diff contains ONLY the 16 specified version markers and CHANGELOG (no unrelated dirty tree files).
- [ ] **AC5**: Remote `refs/heads/main` matches `<commit_R>`.
- [ ] **AC6**: Remote tag `v2.44.3` resolves to `<commit_R>`.
- [ ] **AC7**: GitHub Release `v2.44.3` is live and public.
- [ ] **AC8**: Completion report records all SHAs, exit codes, and verification outputs.

---

## 5. Explicitly OUT of Scope

- No `git add -A`, `git add .`, or staging of mode noise / deleted research files.
- No `--force` or `--tags` flags.
- No downstream project sync (`*sync` is retired).
- No new feature code or framework logic changes in commit R.

---

## 6. Gate 2 Review & Dispatch Instructions (For PM / Human)

⚠️ **STOP POINT: DO NOT START BLAKE YET.**

Per TAD rules, Gate 2 requires **dual independent expert reviews on disk** before Blake can be activated.
Gate 2 may be executed in OpenCode (preferred) or Cursor subagent per PM decision.

### Review Carriers on Disk:
1. **Reviewer 1 (Spec & Pathspec Compliance)**:
   - File: `.tad/evidence/reviews/2026-09-08-gate2-review-v2443-spec.md`
   - Scope: Verify 12 version patterns, CHANGELOG accuracy, strict pathspec add list, sequential publish commands.
2. **Reviewer 2 (Safety & Blast Radius Auditor)**:
   - File: `.tad/evidence/reviews/2026-09-08-gate2-review-v2443-scope.md`
   - Scope: Verify protection against dirty tree noise, no `--force`, recovery policy, and git remote safety.

### PM Dispatch / Next Steps:
1. PM dispatches dual independent reviews to the above disk carrier paths (using OpenCode or Cursor reviewer subagents).
2. PM verifies both reviews record `VERDICT: PASS` (P0=0).
3. PM updates handoff status from `READY_FOR_GATE2` to `READY_FOR_BLAKE`.
4. Human / PM then activates **Blake (Terminal 2)** with:
   ```
   当 Blake
   ```
   and directs Blake to execute `.tad/active/handoffs/HANDOFF-20260908-release-v2443.md`.
