---
task_id: TASK-20260909-PUBLISH-V2444
task_type: release
express: true
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: READY_FOR_BLAKE

**PM 2026-09-09:** Human Gate2 拍通过 + 当 Blake → publish v2.44.4.
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-20260909-release-v2444 — Publish v2.44.4 (Knowledge-Seam Isolation + Opt-in PK Quarantine)

**Task ID**: `TASK-20260909-PUBLISH-V2444` | **Owner**: Blake (Terminal 2) | **Author**: Alex (Terminal 1)  
**Created**: 2026-09-09 | **Status**: READY_FOR_BLAKE (Gate2 dual PASS; Human 当 Blake)  
**Target Release**: `v2.44.4` (Patch) | **Prior Release**: `v2.44.3` (`b9b28bf4667df8fc1aee8ce74cbfa5be304286ce`)  
**Mode**: publish-only (stops after GitHub Release verification; NO sync)  
**Design pointer**: `.tad/evidence/designs/2026-09-09-release-v2444-scope.md`

---

## 🔴 Gate 2: Design Completeness (pending dual disk reviews)

**执行时间**: 2026-09-09 (draft; Gate 2 PASS requires dual independent reviews on disk, P0=0)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reuse v2.44.3 publish playbook; no new installer architecture in commit R |
| Components Specified | ✅ | 12 identity files + 3 mirrors + CHANGELOG = 16 pathspecs; P1–P4 sequential publish |
| Functions Verified | ✅ | `release-verify.sh` parity/version-sweep/migration; `tad.sh --verify-denylist`; `gh release` |
| Data Flow Mapped | ✅ | local R → `refs/heads/main` → annotated `v2.44.4` → GitHub Release |

**Gate 2 结果**: ⏳ READY_FOR_GATE2 — dual disk carriers exist (both PASS, P0=0); human has not yet promoted to READY_FOR_BLAKE

**Alex确认**: 人类已锁定 Execution Mandate。Blake 在 Gate 2 PASS + 人说「当 Blake」之前不得 bump/publish。

---

## 1. Execution Mandate (Human Authorization Scope — 2026-09-09)

- **Outcome**: Publish patch **v2.44.4** =
  1. Bump version `2.44.3` → `2.44.4` across the 12 primary identity files + `CHANGELOG.md` + dual `.agents/skills/` mirrors of the 3 bumped skills.
  2. Create release commit **R** (child of `65963d6b`) using **STRICT PATHSPEC-ONLY STAGING**.
  3. Run detect-only gates in order: parity → derive-sync-set `--report` + version (advisory on patch drift) → version-sweep (Layer 1 blocking) → migration (advisory on patch drift) → `tad.sh --verify-denylist` (required because `tad.sh` is in the bump set).
  4. Push commit R to `origin` `refs/heads/main` (clean fast-forward).
  5. Create annotated tag `v2.44.4` on R and push that tag only.
  6. Create GitHub Release `v2.44.4` with honest notes (knowledge-seam; no overclaim).
  7. Verify post-publish state; write completion report. NO downstream sync.
- **Target**: `https://github.com/Sheldon-92/TAD.git`
  - `refs/heads/main`
  - `refs/tags/v2.44.4`
- **Consequence**:
  - Remote `main` moves `65963d6b` → commit R (one new commit: version + CHANGELOG only).
  - Public annotated tag `v2.44.4` peels to R.
  - Public GitHub Release `v2.44.4`.
- **Blast radius**:
  - Remote `main`, one new tag, one GitHub release.
  - Working tree may contain unrelated dirty/untracked files (`NEXT.md`, `PROJECT_CONTEXT.md` extra hunks, `docs/pm/now.md`, stale `.tad/active/handoffs/` twins). **Must not enter R.**
  - No registry / downstream sync.
- **Recovery policy**:
  - Ambiguous push/tag: read-only `git ls-remote`; classify completed / not-started / partial / unknown; never blind retry; never `--force`.
  - Remote-ahead: STOP.
  - Tag collision (`v2.44.4` already exists): STOP.
  - If `git show --stat R` lists any file outside the 16 pathspecs: `git reset --mixed HEAD~1` (not `--hard`) before any push, so unstaged dirty files stay in the working tree.
  - If R has 16 names but an identity file contains non-version hunks: same mixed reset; do not push.
- **Forbidden**:
  - `git add -A`, `git add .`, directory adds (`git add .claude/skills/`).
  - `git add -p` / `-i` (unsupported in this harness).
  - Absorbing dirty NEXT / pm notes / stale active handoff twins.
  - Staging a dirty identity file that contains non-version hunks (see §3.5 reconstruction).
  - `--force`, `--tags`, unscoped refspecs.
  - Chaining (`&&` or `;`) across push/tag/release commands.
  - Implementing feature code in R (knowledge-seam is already on main).
  - Starting Blake before Gate 2 PASS.

### Socratic (pre-answered by this human mandate — not re-opened)

| Q | Answer |
|---|---|
| Complexity | Small/express *publish* (identity bump + SOP publish). Human selected full channel + patch. |
| Q1 ICP | Skip (ops/release). Audience = TAD maintainer shipping a public tag. |
| Q2 Problem | Knowledge-seam is Gate 4 PASS and on `origin/main`, but the live tag is still `v2.44.3`; installers pinning the latest tag miss isolation/quarantine. |
| Q3a In | Bump, CHANGELOG, R, push main, annotated tag, gh release. |
| Q3b Out | Feature work, dirty-tree noise, force, sync, auto-quarantine, syncing `brain-index.md`. |
| Q4 Risk | Public main/tag; recovery = ls-remote + stop on fork; no force. |
| Q5 AC | §9 / §9.1. |

**AC Conflict Matrix**: byte-preservation of dirty working tree × must-bump `PROJECT_CONTEXT.md` (identity file) × honest R. Resolution: reconstruct identity files from `HEAD` then apply **only** mandated version-line edits before `git add -- <path>` (§3.5).

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read this entire file + design pointer
- [ ] Read §📚 historical lessons
- [ ] Confirm origin URL is exactly `https://github.com/Sheldon-92/TAD.git` (or the ssh equivalent listed in release-runbook)
- [ ] Physical cwd == git toplevel (`pwd -P`)
- [ ] Do not start until status is `READY_FOR_BLAKE` after Gate 2

---

## 📚 Project Knowledge

**Matched L2 files**: `release-sync.md`, `handoff-design.md`, `ac-verification.md`

**⚠️ Blake 必须注意的历史教训**:

1. **Deny-list / version-grep must scope to git-ls-files; pathspec not allow-list of “whatever is dirty”** (`principles.md` 2026-06-01 + `release-sync.md`) — a dirty tree is not the release set. Stage explicit paths only.
2. **A version-staleness grep without exclusion contract ends in override** (`release-sync.md` 2026-09-04) — `version` mode exit 1 on patch is advisory; classify identity vs historical. Do **not** bump CHANGELOG history / fixture pins to silence the gate. `version-sweep` Layer 1 is always blocking.
3. **Parity `--fix` wholesale copy vs explicit `cp` of 3 files** (`release-sync.md` 2026-07-12) — for this patch, **do not** run `parity --fix`. Copy only the three bumped SKILL.md files. `local/` must never be mirrored.
4. **Alex Handoff AC Design / dry-run** (`ac-verification.md`) — run verification methods verbatim; do not mentally simulate `git show --stat`.
5. **Installer “already latest” green no-op** (`release-sync.md` 2026-08-11) — this patch does not claim fleet auto-upgrade from stale local `tad.sh`; notes must not imply that.

**Research**: N/A (`research_required: no`). Local Wiki not required for SOP publish.

---

## 2. Background — What Commit R Puts on Top of

Design-time local refs (Blake re-verifies remotely before P1):

| Ref | SHA |
|---|---|
| `HEAD` / `origin/main` (local tracking) | `65963d6b9d5beac107d4565368f9786b292d8e3f` |
| `v2.44.3` peeled | `b9b28bf4667df8fc1aee8ce74cbfa5be304286ce` |
| `v2.44.3` tag object | `d6120fb26f0ca3e3d83dec541c7b871824bb1b5f` |

`v2.44.3..HEAD` (two commits, already on origin per human + local `origin/main`):

| Commit | Subject | Gate evidence |
|---|---|---|
| `e6e2126e` | `feat(TAD): knowledge-seam isolation + opt-in quarantine [Gate 3 PASS]` | Gate 4 PASS |
| `65963d6b` | `docs: record implementation commit hash in COMPLETION` | same task, evidence sync |

**Cite Gate 4 (load-bearing)**:

- `.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md` — Verdict **PASS → ACCEPTED**
- `.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md` — same verdict; implementation SHAs `e6e2126e` + `65963d6b`
- Human locks recorded there: **Option A** README-only pk install; **quarantine opt-in only** (`tad.sh --quarantine-pk`); `brain-index.md` excluded from top-file sync

Prior public release: v2.44.3 Gate 4 PASS (`.tad/archive/handoffs/GATE4-20260908-publish-v2443.md`) at R=`b9b28bf4`.

Playbook parent: `.tad/archive/handoffs/HANDOFF-20260908-release-v2443.md`.

---

## 3. Requirements & Implementation Steps (Blake)

### 3.0 Preflight (read-only)

From physical repo root, **separately** (no `&&` across mutating later steps; preflight may be sequential):

1. Origin identity: `git remote get-url origin` must be `https://github.com/Sheldon-92/TAD.git` or `git@github.com:Sheldon-92/TAD.git` (exact allow-list in `.claude/skills/release-runbook/SKILL.md`).
2. `git rev-parse HEAD` == `65963d6b9d5beac107d4565368f9786b292d8e3f` (if not, STOP — mandate binding stale).
3. `git ls-remote --heads origin refs/heads/main` must equal that SHA.
4. `git ls-remote --tags origin refs/tags/v2.44.4` must be **empty**.
5. `git status --short` — treat unexpected dirty files as **out of R**; do not clean by `git add`.

### 3.1 Version Bump Scope (NEW = 2.44.4, OLD = 2.44.3)

Update these **12** primary locations to `2.44.4` (line numbers as of HEAD `65963d6b` / identity files currently `2.44.3`):

1. `.tad/version.txt`: `2.44.4`
2. `.tad/TAD-VERSION`: `2.44.4`
3. `.tad/config.yaml`:
   - Line 1: `# TAD Configuration v2.44.4 - Full is the Default Channel (lite frozen 2026-08-13)`
   - Line 3: `version: 2.44.4`
4. `package.json`: `"version": "2.44.4"`
5. `tad.sh`: **only** the identity assignment `TARGET_VERSION="2.44.4"` at line 26. Do not rewrite other `TARGET_VERSION=` assignments (dynamic).
6. `README.md`:
   - Line 3: `**Version 2.44.4 — Knowledge-Seam Isolation + Opt-in PK Quarantine**`
   - Line 5: `> v2.44.4 release: knowledge-seam isolation (brain-index not synced; install pk README-only; --quarantine-pk opt-in) — see [CHANGELOG](CHANGELOG.md#2444---2026-09-09).`
   - Line 190: `# Should show: 2.44.4`
   - Line 506: `**Welcome to TAD v2.44.4 — Knowledge-Seam Isolation + Opt-in PK Quarantine**`
7. `INSTALLATION_GUIDE.md`:
   - Line 3: `**Version 2.44.4 — Alex / Blake is the Default**`
   - Line 51: `cat .tad/version.txt          # 应显示 2.44.4`
8. `PROJECT_CONTEXT.md`:
   - Line 4: `- **Version**: 2.44.4 (Full is the default channel, ...)` (keep remainder of the existing line after the version token)
   - Line 6: `- **Framework**: TAD v2.44.4 + ...` (keep remainder)
9. `docs/MULTI-PLATFORM.md`:
   - Line 3: `**Version**: 2.44.4 (Dual-Platform Architecture — Full is the Default Channel; lite frozen 2026-08-13)`
10. `.claude/skills/tad-help/SKILL.md`:
    - Line 17: `Version: v2.44.4 | Generated: [timestamp]` (preserve leading space inside the fence if present)
11. `.claude/skills/alex/SKILL.md`:
    - Line 50: `<!-- TAD v2.44.4 Framework -->`
12. `.claude/skills/blake/SKILL.md`:
    - Line 166: `<!-- TAD v2.44.4 Framework -->`

Do **not** bump historical `v2.44.0` exclusion banners or CHANGELOG `[2.44.3]` body.

### 3.2 Dual-Tree Skill Parity Sync

After editing the three `.claude/skills/**/SKILL.md` files:

```bash
cp .claude/skills/tad-help/SKILL.md .agents/skills/tad-help/SKILL.md
cp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md
cp .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md
```

Do **not** rsync trees; do **not** `parity --fix` unless detect-only parity is already 0 and a later accidental drift appears **only** in these three files (then still prefer the three `cp` commands).

### 3.3 CHANGELOG Entry `[2.44.4]`

Prepend under `## [Unreleased]`:

```markdown
## [2.44.4] - 2026-09-09

### Added / Changed

- **Knowledge-seam isolation (downstream zero-touch)**:
  - Stopped syncing `brain-index.md` as a framework top file (`TOP_DENY` / `TAD_TOP_DENY`); generated index stays local to each project.
  - Fresh install `project-knowledge/` is **Option A**: `README.md` only at pk root, empty `patterns/` and `incidents/` directories; no `framework-principles.md`.
  - Added opt-in `tad.sh --quarantine-pk` to archive identical upstream pk copies; **never** auto-runs on `tad.sh update`.
  - Landed on `main` as `e6e2126e` + `65963d6b`. Gate 4 PASS: `.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md` and `.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md`.
```

Honesty rules: do not claim auto-quarantine, do not claim `brain-index.md` is distributed, do not claim live-model or downstream fleet already upgraded.

### 3.4 Verification Gates (detect-only; exact order)

Record stdout/stderr/exit for each. Stop on first wiring failure (exit 2).

1. `bash .tad/hooks/lib/release-verify.sh parity .` — must exit **0**.
2. `bash .tad/hooks/lib/derive-sync-set.sh --report .` then `bash .tad/hooks/lib/release-verify.sh version . 2.44.4 2.44.3` — exit 2 blocks; exit 1 on **patch** = advisory (record disposition: identity vs historical; do not falsify history).
3. `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.4` — Layer 1 must exit **0** (blocking for patch). Layer 2 print is advisory.
4. `bash .tad/hooks/lib/release-verify.sh migration .` — exit 2 blocks; exit 1 on patch = advisory (record; knowledge-seam D/R if any should already be manifested or accepted as non-framework-scope).
5. `bash tad.sh --verify-denylist` — must exit **0** (`tad.sh` is in the bump set).

Supporting: pack-registry-driftcheck exit 1 is advisory unless it is a wiring 2.

### 3.5 Create Release Commit R (PATHSPEC-ONLY + dirty-file reconstruction)

Working tree is expected dirty (NEXT / PROJECT_CONTEXT extra / pm / stale active twins). **R must not contain that noise.**

**Detect (mandatory, before any `git add` of the 16):**

```bash
git diff HEAD -- \
  .tad/version.txt .tad/TAD-VERSION .tad/config.yaml package.json tad.sh \
  README.md INSTALLATION_GUIDE.md PROJECT_CONTEXT.md docs/MULTI-PLATFORM.md \
  .claude/skills/tad-help/SKILL.md .claude/skills/alex/SKILL.md .claude/skills/blake/SKILL.md \
  .agents/skills/tad-help/SKILL.md .agents/skills/alex/SKILL.md .agents/skills/blake/SKILL.md \
  CHANGELOG.md
```

Any path that is dirty **beyond** the edits you are about to make must be reconstructed (typical: `PROJECT_CONTEXT.md`). Paths with a clean `git diff HEAD` may be edited in place then added.

**Reconstruction rule** (dirty identity files):

1. Copy the current working-tree file to a **non-repo sidecar** (e.g. `/tmp/tad-v2444-$(basename <path>)`) so ledger/noise hunks are not destroyed.
2. `git show HEAD:<path>` as the base.
3. Apply **only** §3.1 / §3.3 edits.
4. Write that result to the path.
5. `git add -- <path>` (explicit).
6. After R exists, restore sidecar extras to the working tree if the human still wants them (they must remain **unstaged**).

Never `git add PROJECT_CONTEXT.md` (or any identity file) while mixed ledger/noise hunks are still in the index blob.

Stage **exactly** these 16 pathspecs:

```bash
git add -- \
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
```

```bash
git commit -m "release: v2.44.4

Knowledge-seam isolation + opt-in pk quarantine. Version + CHANGELOG only."
```

Pre-push:

- `git show --stat --name-only --pretty=format: HEAD` lists **exactly** those 16 files. Parent of R must be `65963d6b`.
- Intra-file guard (Gate2-R2 P1-1): `git diff 65963d6b HEAD -- PROJECT_CONTEXT.md` (and any other reconstructed identity file) shows **only** the mandated version-token line edits. If extra hunks appear, mixed-reset R and do not push. Filename-only AC4 is not sufficient.

### 3.6 Mandate-Bound Publish Sequence (NO chaining)

Re-read ls-remote immediately before P1. Then **four separate commands** (new shell invocation each; no `&&` / `;` joining P1–P4):

**P1** Push main:

```bash
git push origin <commit_R>:refs/heads/main
```

**P2** Annotated tag:

```bash
git tag -a v2.44.4 <commit_R> -m "v2.44.4 — Knowledge-seam isolation + opt-in pk quarantine"
```

**P3** Push tag:

```bash
git push origin refs/tags/v2.44.4:refs/tags/v2.44.4
```

**P4** GitHub Release:

```bash
gh release create v2.44.4 \
  --title "v2.44.4 — Knowledge-Seam Isolation + Opt-in PK Quarantine" \
  --notes "### TAD v2.44.4 Release Notes

Patch over v2.44.3. Ships knowledge-seam work already on main (\`e6e2126e\`, \`65963d6b\`).

- \`brain-index.md\` is not a synced framework top file.
- Fresh install project-knowledge is README-only (Option A); empty patterns/ and incidents/.
- \`tad.sh --quarantine-pk\` is opt-in only; update never auto-quarantines.

Gate 4: .tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md
"
```

### 3.7 Post-Publish Verification

- `git ls-remote --heads origin refs/heads/main` == `<commit_R>`
- `git ls-remote --tags origin refs/tags/v2.44.4 refs/tags/v2.44.4^{}` peel to `<commit_R>`
- `gh release view v2.44.4` is public (not draft unless human later says otherwise — **create as published**)
- Completion: `.tad/active/handoffs/COMPLETION-20260909-publish-v2444.md`

---

## 4. Acceptance Criteria (summary)

- [ ] AC1 parity exit 0
- [ ] AC2 version-sweep Layer 1 exit 0 for `2.44.4`
- [ ] AC3 CHANGELOG `[2.44.4] - 2026-09-09` honest vs Gate 4 locks
- [ ] AC4 R is exactly 16 pathspec files; parent `65963d6b`; no dirty-tree noise
- [ ] AC5 remote main == R
- [ ] AC6 remote annotated tag `v2.44.4` peels to R
- [ ] AC7 GitHub Release `v2.44.4` live
- [ ] AC8 completion report with SHAs, exits, ls-remote

---

## 5. Explicitly OUT of Scope

- Knowledge-seam feature implementation (done).
- Absorbing `.tad/active/handoffs/{HANDOFF,COMPLETION}-20260908-knowledge-seam-isolation.md` or `{HANDOFF,COMPLETION}-20260908-release-v2443.md` stale twins.
- `NEXT.md` / `docs/pm/now.md` in R.
- `--force`, `--tags`, `git add -A`.
- Downstream sync.
- Reopening Option A / quarantine locks.

---

## 6. Files

### 6.1 New
- `.tad/active/handoffs/COMPLETION-20260909-publish-v2444.md` (Blake)

### 6.2 Modify (commit R only)
The 16 pathspecs in §3.5.

### 6.3 Grounded Against (Alex Read, 2026-09-09)

- `.tad/version.txt`, `.tad/TAD-VERSION`, `.tad/config.yaml` (head), `package.json` (head), `tad.sh` TARGET_VERSION, `README.md` L1–6 + grep 2.44.3, `INSTALLATION_GUIDE.md` L1–5 + L51, `PROJECT_CONTEXT.md` L1–8, `docs/MULTI-PLATFORM.md` L1–5, `.claude/skills/tad-help/SKILL.md` L17, `.claude/skills/alex/SKILL.md` L50, `.claude/skills/blake/SKILL.md` L166
- `CHANGELOG.md` L1–20 (`## [Unreleased]` then `[2.44.3]`)
- `.tad/archive/handoffs/HANDOFF-20260908-release-v2443.md`
- `.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md` + evidence twin
- `.claude/skills/release-runbook/references/publish-ops.md`
- `.git/refs/heads/main`, `.git/refs/remotes/origin/main`, `.git/logs/refs/heads/main` (tail)

---

## 7. Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/2026-09-09-gate2-review-v2444-spec.md
    - .tad/evidence/reviews/2026-09-09-gate2-review-v2444-scope.md
  gate_verdicts:
    - parity / version-sweep / migration / denylist exits recorded in completion
  completion:
    - .tad/active/handoffs/COMPLETION-20260909-publish-v2444.md
  blake_reviews: []  # mechanical bump; Gate 3 = verifier exits + AC table; Layer 2 N/A unless human demands
  perf_evidence: []
  fixture_results: []
  dogfood: []
  knowledge_updates: []  # optional; Gate 4 KA later
```

---

## 8. Testing / Friction / Feedback

### 8.1–8.3
No app unit/e2e suite. Gates in §3.4 are the tests. Edge: dirty `PROJECT_CONTEXT.md`; remote-ahead; tag exists.

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Dirty identity files | Reconstruct from HEAD + version-only edits | §3.5 | None | Absorbing noise → AC4 FAIL, do not push |
| `gh` auth | `gh release create` | Renew `gh auth` | BLOCKED if missing | P4 cannot complete |
| Network for ls-remote/push | Remote CAS + P1/P3 | Request network | BLOCKED | cannot publish |
| Dual Gate 2 reviewers | Independent spec + scope reviews | Spawn two reviewers; write disk carriers | Equivalent independent reviewer (never self-review) | No READY_FOR_BLAKE |
| Codex/Claude sandbox git push | User approval | Ask human | None | BLOCKED |

### 8.5 Feedback Collection

```yaml
feedback_required: false
artifact_type: generic
suggested_dimensions: []
notes: "GitHub Release notes are specified verbatim in §3.6 P4"
```

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | Dual-tree skill parity after bump | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh parity .` | exit 0 | (post-impl) |
| AC2 | Identity sweep NEW=2.44.4 | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.4` | Layer 1 exit 0 | (post-impl) |
| AC3 | CHANGELOG 2.44.4 honesty | post-impl-verifiable | `grep -n '## \[2.44.4\] - 2026-09-09' CHANGELOG.md`; body mentions brain-index not synced, Option A README-only, `--quarantine-pk` opt-in | heading present; three locks named | (post-impl) |
| AC4 | R pathspec isolation + intra-file purity | post-impl-verifiable | `git show --name-only --pretty=format: HEAD` equals the 16 paths; `git rev-parse HEAD^` == `65963d6b9d5beac107d4565368f9786b292d8e3f`; `git diff 65963d6b HEAD -- PROJECT_CONTEXT.md` contains only version-token edits (2.44.3→2.44.4) | exactly 16 files; parent match; no ledger/noise hunks in identity diffs | (post-impl) |
| AC5 | Remote main == R | post-impl-verifiable | `git ls-remote --heads origin refs/heads/main` | SHA == R | (post-impl) |
| AC6 | Tag peels to R | post-impl-verifiable | `git ls-remote --tags origin refs/tags/v2.44.4 refs/tags/v2.44.4^{}` | annotated + peeled R | (post-impl) |
| AC7 | GitHub Release live | post-impl-verifiable | `gh release view v2.44.4 --json tagName,isDraft,url` | tagName v2.44.4, isDraft false | (post-impl) |
| AC8 | Completion carrier | post-impl-verifiable | `test -f .tad/active/handoffs/COMPLETION-20260909-publish-v2444.md` | file exists with SHAs + exits | (post-impl) |
| AC0a | OLD identity still 2.44.3 before Blake | pre-impl-verifiable | `cat .tad/version.txt` | `2.44.3` | `2.44.3` |
| AC0b | Prior CHANGELOG head | pre-impl-verifiable | first version heading after Unreleased | `## [2.44.3] - 2026-09-08` | confirmed Read CHANGELOG L9–11 |
| AC0c | Tip binding | pre-impl-verifiable | `cat .git/refs/heads/main` and `cat .git/refs/remotes/origin/main` | both `65963d6b9d5beac107d4565368f9786b292d8e3f` | both files Read equal that SHA |
| AC0d | No v2.44.4 tag yet (local ref file) | pre-impl-verifiable | `test ! -e .git/refs/tags/v2.44.4` | absent | refs/tags glob had no v2.44.4; Blake still ls-remote |

Pipe-escape: table cells do not need unescaped regex for these commands.

---

## 10. Important Notes / Anti-patterns

- Do not treat Gate 4 “local only; do not push” on the **feature** task as a ban on **this** release — that boundary applied to TASK-20260908-KNOWLEDGE-SEAM-ISOLATION. This mandate **authorizes** publishing those commits via tag `v2.44.4`.
- Do not bump `tad.sh` dynamic `TARGET_VERSION=` lines 39/54/2524.
- Do not run combined `git push && git tag && git push --tags`.
- Do not use `parity --fix` as a substitute for the three `cp` commands.

---

## 11. Decision Summary

| Decision | Choice | Source |
|---|---|---|
| SemVer | patch 2.44.4 | Human 2026-09-09 |
| Payload | knowledge-seam already on main | Gate 4 PASS 2026-09-09 |
| Isolation story | brain-index unsynced; Option A; opt-in quarantine | Human + Gate 4 locks |
| Staging | 16 pathspecs + HEAD reconstruction | v2.44.3 lesson + dirty tree |
| Sync | none | Human |

---

## 12. MQ1–MQ6

| MQ | Answer | Evidence |
|---|---|---|
| MQ1 Historical | Reuse v2.44.3 handoff + publish-ops; do not invent a new publisher | Read archive HANDOFF-20260908-release-v2443.md; publish-ops.md |
| MQ2 Functions exist | `release-verify.sh`, `derive-sync-set.sh`, `tad.sh --verify-denylist`, `gh`, `git` | Paths under `.tad/hooks/lib/`; tad.sh L26 |
| MQ3 Data flow | N/A (no UI) | NOT_APPLICABLE_WITH_REASON: release ops |
| MQ4 Visual | N/A | same |
| MQ5 State sync | Dual trees via 3 explicit `cp` | §3.2 |
| MQ6 Research | Existing SOP; no new research | `research_required: no` |

---

## 13. Gate 2 Review Dispatch (STOP — do not start Blake)

Disk carriers:

1. Spec & Pathspec: `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-spec.md` — 12 markers, CHANGELOG, 16 pathspecs, no chained push/tag, Gate 4 citation honesty.
2. Safety & Blast Radius: `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-scope.md` — dirty-tree reconstruction, no force, origin allow-list, recovery, do not absorb twins.

### Audit Trail (expert review)

| Reviewer | Carrier | Verdict | P0 | Disposition |
|---|---|---|---|---|
| Spec & Pathspec | `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-spec.md` | PASS | 0 | P1 operational reminder already in §10 |
| Safety & Blast Radius | `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-scope.md` | PASS | 0 | P1-1/P1-2/P1-3 integrated into §3.5 detect+sidecar+AC4 intra-file; P2-1 mixed reset in Recovery |

After human confirms Gate 2 (both carriers P0=0, this draft integrated): set status `READY_FOR_BLAKE` and say **当 Blake**.

**Alex did not run `/gate` as a separate command in this session.** Status remains `READY_FOR_GATE2` until the human accepts the dual PASS carriers.
