---
task_id: TASK-20260907-PUBLISH-V2442
task_type: release
express: false
skip_knowledge_assessment: no
e2e_required: no
research_required: no
---

# HANDOFF-20260907-publish-v2442 — Publish v2.44.2 (Framework-Health B + Lite Mute)

**Task ID**: `TASK-20260907-PUBLISH-V2442` | **Owner**: Blake (Terminal 2) | **Author**: Alex (Terminal 1)  
**Created**: 2026-09-07 | **Status**: READY FOR BLAKE  
**Mode**: publish-only (stops after publish verification; NO sync)  

---

## 1. Execution Mandate (Human Authorized 2026-09-07)

- **Outcome**: Publish **v2.44.2** = 
  1. Synchronize tracking branch `maintainer-evidence` (`8713ea4e`) to `origin/maintainer-evidence` (safeguard 134 untracked evidence/archive files in remote git).
  2. Bump version to `2.44.2` across 12 identity markers + `CHANGELOG.md` into release commit **R** (child of `6b3b9787`).
  3. Push `main` (commit R) to `origin/main` (clean fast-forward).
  4. Create annotated tag `v2.44.2` on R and push only that tag.
  5. Verify and report. NO sync.
- **Target**: `https://github.com/Sheldon-92/TAD.git`
  - `refs/heads/maintainer-evidence`
  - `refs/heads/main`
  - `refs/tags/v2.44.2`
- **Consequence**:
  - Remote `maintainer-evidence` moves `b6956606` → `8713ea4e` (clean fast-forward, containing 4377 evidence/archive files).
  - Remote `main` moves `6a29edad` → R (7 accepted local commits + release commit R = 8 commits total).
  - New public tag `v2.44.2`.
- **Blast radius**: Remote `main`, remote `maintainer-evidence`, and one tag `v2.44.2`. No downstream projects touched, no registry modification, no `*sync`.
- **Recovery policy**: Ambiguous push/tag result → `ls-remote` classify (completed / not-started / partial / unknown); completed never repeats; verified not-started retries same action; unknown blocks. Remote-ahead → STOP, never `--force`. Tag collision → STOP.
- **Forbidden**: `--force`, `--tags`, unscoped refspecs, combined shell chains (`&&`/`;` between the remote push actions), absorbing any unrelated or dirty file into R.

---

## 2. Background — What R Puts on Top of

`git log --oneline origin/main..HEAD` (all local, none pushed; remote pre-state `refs/heads/main = 6a29edad`, tag `v2.44.2` absent — verified 2026-09-07):

| Commit | Track / Feature | Gate Status |
|---|---|---|
| `fdd4831f` | Workspace hygiene, driver path & v2.44 release sync | PASS `GATE4-20260904-workspace-hygiene-and-scan.md` |
| `8eb57ca2` | Docs Gate 4 record in NEXT.md | post-Gate-4 docs |
| `30aa5ea4` | Fix: mute Lite triggers on Full-channel default path | PASS `GATE4-20260903-bugfix-lite-mute.md` |
| `52db7aa2` | Docs mark bugfix-lite-mute Gate 4 PASS | post-Gate-4 docs |
| `5f500691` | Feat: retire alex constraints frontmatter & dangling refs (1b/SC2) | PASS `GATE4-20260906-framework-health-closeout-b.md` |
| `98b7e396` | Chore: stop tracking .tad/evidence and archive on main (SC3) | PASS `GATE4-20260906-framework-health-closeout-b.md` |
| `6b3b9787` | Docs mark closeout-b Gate 4 PASS & close EPIC-20260816 | post-Gate-4 docs |

- `origin/maintainer-evidence`: `b695660661fd8ee210061cfd0de04b77cf61c020`
- `maintainer-evidence` (local): `8713ea4eb88b53f74f70f50477143a6fec05d22a` (clean fast-forward, containing 4377 evidence/archive files, including 2 forced `.log` files).
- `origin/main`: `6a29edad7976ad7a685cb4823267d3d7bfa5db2f`
- `HEAD` (local main): `6b3b9787e91d6cb25bc6fe51897b6ec340a6b7ee` (ahead by 7 commits, clean fast-forward).

Read-only preflight by Alex (2026-09-07, current tree):
- `parity` exit 0 (clean).
- `migration` exit 0 (clean).
- `tad.sh --verify-denylist` exit 0 (clean).
- `pack-registry-driftcheck` exit 1 (advisory only, pre-existing).

---

## 3. Requirements & Implementation Steps (Blake)

### 3.1 Version Bump Scope (NEW = 2.44.2, OLD = 2.44.1 / 2.44.0)

Blake must update the following 12 files to `2.44.2`:

1. `.tad/version.txt`: `2.44.2`
2. `.tad/TAD-VERSION`: `2.44.2`
3. `.tad/config.yaml`:
   - Line 1: `# TAD Configuration v2.44.2 - Full is the Default Channel (lite frozen 2026-08-13)`
   - Line 3: `version: 2.44.2`
4. `package.json`: `"version": "2.44.2"`
5. `tad.sh`: `TARGET_VERSION="2.44.2"`
6. `README.md`:
   - Line 3: `**Version 2.44.2 — Framework Health close-out B + Lite mute + 72.5% tarball slimming**`
   - Line 5: `> v2.44.2 release: Framework-Health repair Track B (-72.5% tarball slimming + SC2 frontmatter retirement) + Full-channel Lite trigger mute — see [CHANGELOG](CHANGELOG.md#2442---2026-09-07).`
   - Line 190: `# Should show: 2.44.2`
   - Line 506: `**Welcome to TAD v2.44.2 — Framework Health close-out B + Lite mute + 72.5% tarball slimming**`
7. `INSTALLATION_GUIDE.md`:
   - Header: `**Version 2.44.2 — Alex / Blake is the Default**`
   - Test line: `cat .tad/version.txt          # 应显示 2.44.2`
8. `PROJECT_CONTEXT.md`:
   - Line 4: `- **Version**: 2.44.2 (Full is the default channel, ...)`
   - Line 6: `- **Framework**: TAD v2.44.2 + Full-default/Lite-frozen ...`
9. `docs/MULTI-PLATFORM.md`:
   - Header: `**Version**: 2.44.2 (Dual-Platform Architecture — Full is the Default Channel; lite frozen 2026-08-13)`
10. `.claude/skills/tad-help/SKILL.md`:
    - Line 17: `Version: v2.44.2 | Generated: [timestamp]`
11. `.claude/skills/alex/SKILL.md`:
    - Line 50: `<!-- TAD v2.44.2 Framework -->`
12. `.claude/skills/blake/SKILL.md`:
    - Line 166: `<!-- TAD v2.44.2 Framework -->`

### 3.2 Dual-Tree Skill Parity Auto-Sync

After modifying `.claude/skills/`, run:
```bash
bash .tad/hooks/lib/release-verify.sh parity --fix .
```
This ensures `.agents/skills/` is automatically synchronized and byte-identical with `.claude/skills/`.

### 3.3 CHANGELOG Entry `[2.44.2]`

Prepend the following entry to `CHANGELOG.md` under `## [Unreleased]`:

```markdown
## [2.44.2] - 2026-09-07

### Added / Changed

- **Framework-Health Repair Track B (SC2 & SC3 Closed)**:
  - **Release Tarball Slimming**: Removed `.tad/evidence/` and `.tad/archive/` from `main` tracking, reducing release package size by 72.5% (down to 8.70MB). Historical evidence safely preserved on `maintainer-evidence` branch.
  - **Governance Cleanup**: Retired `alex/SKILL.md` frontmatter constraints block (`deny_ref` count = 0), migrated core prohibitions (O1/O2/G1) into prose obligations, eliminated 16 dangling references, and synchronized `.claude` / `.agents` dual-tree with 100% byte parity.
  - **Epic Closed**: Fully satisfied and closed `EPIC-20260816-framework-health-repair` with all phases (1a, 1a-2, 1b, 2, 3, 4) and success criteria (SC1–SC5) verified.
- **Lite Channel Mute**:
  - Muted Lite triggers on the Full-channel default path to reduce session startup noise while keeping explicit invocations (`当 Blake Lite` / `当 Alex Lite`) fully available.
- **Workspace Hygiene**:
  - Hardened pair-driver path resolution and updated release-sync documentation.
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
   bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.2
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

### 3.5 Create Release Commit R

Verify working tree cleanliness before staging:
```bash
git status --porcelain --untracked-files=no
```
Stage only the version bump files, skills, and CHANGELOG:
```bash
git add .tad/version.txt .tad/TAD-VERSION .tad/config.yaml package.json tad.sh README.md INSTALLATION_GUIDE.md PROJECT_CONTEXT.md docs/MULTI-PLATFORM.md .claude/skills/ .agents/skills/ CHANGELOG.md
git commit -m "release: v2.44.2

Framework Health close-out B (SC2/SC3 -72.5% slim) + Lite mute. Version + CHANGELOG only. Local only, NOT pushed."
```
Confirm `git show --stat HEAD` contains only version bumps and CHANGELOG entries.

### 3.6 Mandate-Bound Publish Sequence (Execute Sequentially, NO Chaining)

Before executing, verify pre-conditions:
- `origin/maintainer-evidence` matches expected: `git ls-remote --heads origin refs/heads/maintainer-evidence` equals `b695660661fd8ee210061cfd0de04b77cf61c020`.
- `origin/main` has not moved: `git ls-remote --heads origin refs/heads/main` equals `6a29edad`.
- `refs/tags/v2.44.2` is absent: `git ls-remote --tags origin refs/tags/v2.44.2` is empty.

**Execute the following 4 actions one by one**:

1. **Action P1 (Orphan Branch Push)**:
   ```bash
   git push origin 8713ea4eb88b53f74f70f50477143a6fec05d22a:refs/heads/maintainer-evidence
   ```
2. **Action P2 (Main Branch Push)**:
   ```bash
   git push origin <commit_R>:refs/heads/main
   ```
3. **Action P3 (Create Annotated Tag)**:
   ```bash
   git tag -a v2.44.2 <commit_R> -m "v2.44.2 — Framework Health close-out B + Lite mute + 72.5% tarball slimming"
   ```
4. **Action P4 (Push Tag)**:
   ```bash
   git push origin refs/tags/v2.44.2:refs/tags/v2.44.2
   ```

### 3.7 Post-Publish Verification

- `git ls-remote --heads origin refs/heads/main` == `<commit_R>`
- `git ls-remote --heads origin refs/heads/maintainer-evidence` == `8713ea4eb88b53f74f70f50477143a6fec05d22a`
- `git ls-remote --tags origin refs/tags/v2.44.2 "refs/tags/v2.44.2^{}"` both resolve to `<commit_R>`
- Write Completion Report to `.tad/active/handoffs/COMPLETION-20260907-publish-v2442.md`

---

## 4. Acceptance Criteria

- [ ] **AC1**: `release-verify.sh parity .` exits 0 (Layer 1 dual-tree parity PASS).
- [ ] **AC2**: `release-verify.sh version-sweep . 2.44.2` exits 0 (Layer 1 all 12 must-version patterns match).
- [ ] **AC3**: `CHANGELOG.md` has complete, accurate `[2.44.2] - 2026-09-07` entry.
- [ ] **AC4**: Release commit R diff contains ONLY version markers and CHANGELOG.
- [ ] **AC5**: Remote `maintainer-evidence` matches `8713ea4eb88b53f74f70f50477143a6fec05d22a`.
- [ ] **AC6**: Remote `refs/heads/main` matches `<commit_R>`.
- [ ] **AC7**: Remote tag `v2.44.2` resolves to `<commit_R>`.
- [ ] **AC8**: Completion report records all SHAs, exit codes, and verification outputs.

---

## 5. Explicitly OUT of Scope

- No `--force` or `--tags` flags.
- No downstream project sync (`*sync` is retired).
- No modifications to `.tad/evidence/` or `.tad/archive/` disk files (they remain on disk).
- No new feature code or framework logic changes in commit R.

---

## 6. Next Steps

Human activates **Blake (Terminal 2)** with:
```
当 Blake
```
and directs Blake to execute `.tad/active/handoffs/HANDOFF-20260907-publish-v2442.md`.
