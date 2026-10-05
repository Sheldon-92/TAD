---
task_id: TASK-20260911-PUBLISH-V2445
task_type: release
express: true
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: READY_FOR_BLAKE
feedback_required: false
git_tracked_dirs: []
gate4_delta: []

**PM 2026-09-11:** Human Gate2 拍通过 + 当 Blake → publish v2.44.5.
---

# HANDOFF-20260911-release-v2445 — Publish v2.44.5 (Verify-Delta + Pack Loader/Freeze + KEEP11 Knife 1)

**Task ID**: `TASK-20260911-PUBLISH-V2445` | **Owner**: Blake (Terminal 2) | **Author**: Alex (Terminal 1)  
**Created**: 2026-09-11 | **Status**: READY_FOR_BLAKE (Human Gate2 拍通过 + 当 Blake 2026-09-11)  
**Target Release**: `v2.44.5` (Patch) | **Prior Release**: `v2.44.4` (`83e2ff03f48b3510482192797fc7f06e634f425d`)  
**Mode**: publish-only (stops after GitHub Release verification; NO sync)  
**Design pointer**: `.tad/evidence/designs/2026-09-11-release-v2445-scope.md`  
**Channel/model (Alex design)**: channel=Cursor model=cursor-grok-4.6-medium. NO Gemini. NO Blake this design turn.

---

## 🔴 Gate 2: Design Completeness (pending dual disk reviews)

**执行时间**: 2026-09-11 (draft; Gate 2 PASS requires dual independent reviews on disk, P0=0)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reuse v2.44.4 publish playbook; no new installer architecture in commit R |
| Components Specified | ✅ | 12 identity files + 3 mirrors + CHANGELOG = 16 pathspecs; P1–P4 sequential publish |
| Functions Verified | ✅ | `release-verify.sh` parity/version-sweep/migration; `tad.sh --verify-denylist`; `gh release` |
| Data Flow Mapped | ✅ | local R → `refs/heads/main` → annotated `v2.44.5` → GitHub Release |

**Gate 2 结果**: dual disk carriers PASS, P0=0 (see §13). Status remains READY_FOR_GATE2 until human promotes to READY_FOR_BLAKE.

**Alex确认**: 人类已锁定 Execution Mandate。Blake 在 Gate 2 PASS + 人说「当 Blake」之前不得 bump/publish。Alex 本回合不实现 bump/publish。

---

## 1. Execution Mandate (Human Authorization Scope — 2026-09-11)

- **Outcome**: Publish patch **v2.44.5** =
  1. Bump version `2.44.4` → `2.44.5` across the 12 primary identity files + `CHANGELOG.md` + dual `.agents/skills/` mirrors of the 3 bumped skills.
  2. Create release commit **R** (child of `63cf62912131d1f40273d54b0e6456aad9ba33af`) using **STRICT PATHSPEC-ONLY STAGING**.
  3. Run detect-only gates in order: parity → derive-sync-set `--report` + version (advisory on patch drift) → version-sweep (Layer 1 blocking) → migration (advisory on patch drift) → `tad.sh --verify-denylist` (required because `tad.sh` is in the bump set).
  4. Push commit R to `origin` `refs/heads/main` (clean fast-forward).
  5. Create annotated tag `v2.44.5` on R and push that tag only.
  6. Create GitHub Release `v2.44.5` with honest notes for the four deltas (no overclaim).
  7. Verify post-publish state; write completion report. NO downstream sync.
- **Target**: `https://github.com/Sheldon-92/TAD.git`
  - `refs/heads/main`
  - `refs/tags/v2.44.5`
- **Consequence**:
  - Remote `main` moves `63cf6291` → commit R (one new commit: version + CHANGELOG only).
  - Public annotated tag `v2.44.5` peels to R.
  - Public GitHub Release `v2.44.5`.
- **Blast radius**:
  - Remote `main`, one new tag, one GitHub release.
  - Working tree may contain unrelated dirty/untracked files. Snapshot at design/Gate2 (all **out of R**): `NEXT.md`; `PROJECT_CONTEXT.md` extra hunks; `docs/pm/now.md`; `brain-index.md`; `.tad/project-knowledge/patterns/_index.md`; `.tad/project-knowledge/patterns/ac-verification.md`; dirty/deleted active twins `HANDOFF/COMPLETION-20260908-knowledge-seam-isolation.md`, `HANDOFF/COMPLETION-20260910-verify-delta.md`; untracked `HANDOFF/COMPLETION-20260908-publish-v2443.md`, `HANDOFF-20260908-release-v2443.md`, `HANDOFF-20260909-release-v2444.md`, `COMPLETION-20260909-publish-v2444.md`; this handoff `HANDOFF-20260911-release-v2445.md`; `.tad/eval/judge/bundles/*`. **Must not enter R.** Any later dirty path not in the 16 pathspecs is also out of R.
  - No registry / downstream sync.
- **Recovery policy**:
  - Ambiguous push/tag: read-only `git ls-remote`; classify completed / not-started / partial / unknown; never blind retry; never `--force`.
  - Remote-ahead: STOP.
  - Tag collision (`v2.44.5` already exists): STOP.
  - If `git show --stat R` lists any file outside the 16 pathspecs: `git reset --mixed HEAD~1` (not `--hard`) before any push, so unstaged dirty files stay in the working tree.
  - If R has 16 names but an identity file contains non-version hunks: same mixed reset; do not push.
- **Forbidden**:
  - `git add -A`, `git add .`, directory adds (`git add .claude/skills/`).
  - `git add -p` / `-i` (unsupported in this harness).
  - Absorbing dirty NEXT / pm notes / stale active handoff twins / judge bundles / knowledge pattern noise.
  - Staging a dirty identity file that contains non-version hunks (see §3.5 reconstruction).
  - `--force`, `--tags`, unscoped refspecs.
  - Chaining (`&&` or `;`) across push/tag/release commands.
  - Implementing feature code in R (the four deltas are already on main).
  - Remaining KEEP11 knives, freeze/unfreeze roster changes, or waiting for them.
  - Starting Blake before Gate 2 PASS + human 「当 Blake」.
  - Gemini this task.

### Socratic (pre-answered by this human mandate — not re-opened)

| Q | Answer |
|---|---|
| Complexity | Small/express *publish* (identity bump + SOP publish). Human selected full channel + patch. |
| Q1 ICP | Skip (ops/release). Audience = TAD maintainer shipping a public tag. |
| Q2 Problem | Four Gate-4-accepted commits are on `origin/main` after live `v2.44.4`; installers pinning the latest tag still miss them. |
| Q3a In | Bump, CHANGELOG, R, push main, annotated tag, gh release. |
| Q3b Out | Feature work, remaining KEEP11 knives, dirty-tree noise, force, sync. |
| Q4 Risk | Public main/tag; recovery = ls-remote + stop on fork; no force. |
| Q5 AC | §9 / §9.1. |

**AC Conflict Matrix**: byte-preservation of dirty working tree × must-bump `PROJECT_CONTEXT.md` (identity file, currently dirty with ledger notes) × honest R. Resolution: reconstruct identity files from `HEAD` then apply **only** mandated version-line edits before `git add -- <path>` (§3.5).

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read this entire file + design pointer
- [ ] Read §📚 historical lessons
- [ ] Confirm origin URL is exactly `https://github.com/Sheldon-92/TAD.git` (or the ssh equivalent listed in release-runbook)
- [ ] Physical cwd == git toplevel (`pwd -P`)
- [ ] Do not start until status is `READY_FOR_BLAKE` after Gate 2 + human 「当 Blake」

---

## 📚 Project Knowledge

**Matched L2 files**: `release-sync.md`, `handoff-design.md`, `ac-verification.md` (max 3; pack-build-rules skipped — R does not edit pack bodies)

**⚠️ Blake 必须注意的历史教训**:

1. **Deny-list / version-grep must scope to git-ls-files; pathspec not allow-list of “whatever is dirty”** (`principles.md` 2026-06-01 + `release-sync.md`) — a dirty tree is not the release set. Stage explicit paths only.
2. **A version-staleness grep without exclusion contract ends in override** (`release-sync.md` 2026-09-04) — `version` mode exit 1 on patch is advisory; classify identity vs historical. Do **not** bump CHANGELOG history / fixture pins to silence the gate. `version-sweep` Layer 1 is always blocking.
3. **Parity `--fix` wholesale copy vs explicit `cp` of 3 files** (`release-sync.md` 2026-07-12) — for this patch, **do not** run `parity --fix`. Copy only the three bumped SKILL.md files. `local/` must never be mirrored.
4. **Alex Handoff AC Design / dry-run** (`ac-verification.md`) — run verification methods verbatim; do not mentally simulate `git show --stat`.
5. **Installer “already latest” green no-op** (`release-sync.md` 2026-08-11) — this patch does not claim fleet auto-upgrade from stale local `tad.sh`; notes must not imply that.
6. **Handoff is Blake’s only information** (`handoff-design.md` / Two-Agent principle) — do not invent extra files into R.

**Research**: N/A (`research_required: no`). Local Wiki not required for SOP publish.

---

## 2. Background — What Commit R Puts on Top of

Design-time local/remote refs (Blake re-verifies remotely before P1):

| Ref | SHA |
|---|---|
| `HEAD` / `origin/main` (local tracking + ls-remote) | `63cf62912131d1f40273d54b0e6456aad9ba33af` |
| `v2.44.4` peeled | `83e2ff03f48b3510482192797fc7f06e634f425d` |
| `v2.44.4` tag object | `4a9d655d58315b7c52479100ea87ac00b4380cb1` |

`v2.44.4..HEAD` (four commits, already on origin):

| Commit | Subject | Gate evidence |
|---|---|---|
| `7048b835` | feat(verify-delta): runnable Verification Method for *bug/*express | Gate 4 PASS (evidence; archived HANDOFF/COMPLETION; no `GATE4-*` twin) |
| `9c33e2e5` | feat(pack-loader): thin on-demand pointer + freeze skip | Gate 4 PASS (evidence + archive GATE4) |
| `eb09597a` | feat(packs): freeze 14 capability packs via CAPABILITY status + registry regen | Gate 4 PASS (evidence + archive GATE4) |
| `63cf6291` | feat(packs): KEEP11 knife 1 CLI/SHA refresh for code-security + web-deployment | Gate 4 PASS re-run (evidence + archive GATE4); prior PARTIAL closed |

**Cite Gate 4 (load-bearing)**:

- `.tad/evidence/reviews/2026-09-10-gate4-verify-delta.md` — Verdict **PASS**. Archives: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260910-verify-delta.md`.
- `.tad/evidence/reviews/2026-09-10-gate4-pack-loader-thin-ondemand.md` + `.tad/archive/handoffs/GATE4-20260910-pack-loader-thin-ondemand.md` — **PASS**.
- `.tad/evidence/reviews/2026-09-10-gate4-pack-freeze-inventory.md` + `.tad/archive/handoffs/GATE4-20260910-pack-freeze-inventory.md` — **PASS**.
- `.tad/evidence/reviews/2026-09-11-gate4-rerun-keep11-knife1-cli-refresh.md` + `.tad/archive/handoffs/GATE4-20260911-keep11-knife1-cli-refresh.md` — **PASS**.

Prior public release: v2.44.4 at R=`83e2ff03`. Playbook parent: `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md` (untracked twin in this tree; treat as pattern, **do not add to R**).

Feature-task “local only; do not push/tag/release” applied to those four tickets. **This mandate authorizes** publishing them via tag `v2.44.5`. Remaining KEEP11 knives stay discuss-locked and are **not** this patch.

---

## 3. Requirements & Implementation Steps (Blake)

### 3.0 Preflight (read-only)

From physical repo root, **separately** (no `&&` across mutating later steps; preflight may be sequential):

1. Origin identity: `git remote get-url origin` must be `https://github.com/Sheldon-92/TAD.git` or `git@github.com:Sheldon-92/TAD.git` (exact allow-list in `.claude/skills/release-runbook/SKILL.md`).
2. `git rev-parse HEAD` == `63cf62912131d1f40273d54b0e6456aad9ba33af` (if not, STOP — mandate binding stale).
3. `git ls-remote --heads origin refs/heads/main` must equal that SHA.
4. `git ls-remote --tags origin refs/tags/v2.44.5` must be **empty**.
5. `git status --short` — treat unexpected dirty files as **out of R**; do not clean by `git add`.

### 3.1 Version Bump Scope (NEW = 2.44.5, OLD = 2.44.4)

Update these **12** primary locations to `2.44.5` (line numbers as of HEAD `63cf6291` / identity files currently `2.44.4`):

1. `.tad/version.txt`: `2.44.5`
2. `.tad/TAD-VERSION`: `2.44.5`
3. `.tad/config.yaml`:
   - Line 1: `# TAD Configuration v2.44.5 - Full is the Default Channel (lite frozen 2026-08-13)`
   - Line 3: `version: 2.44.5`
4. `package.json`: `"version": "2.44.5"`
5. `tad.sh`: **only** the identity assignment `TARGET_VERSION="2.44.5"` at line 26. Do not rewrite other `TARGET_VERSION=` assignments (dynamic).
6. `README.md`:
   - Line 3: `**Version 2.44.5 — Verify-Delta + Pack Loader/Freeze + KEEP11 Knife 1**`
   - Line 5: `> v2.44.5 release: runnable Verification Method fail-close; thin pack loader + freeze skip; freeze 14 packs; KEEP11 knife 1 (code-security + web-deployment only) — see [CHANGELOG](CHANGELOG.md#2445---2026-09-11).`
   - Line 190: `# Should show: 2.44.5`
   - Line 506: `**Welcome to TAD v2.44.5 — Verify-Delta + Pack Loader/Freeze + KEEP11 Knife 1**`
7. `INSTALLATION_GUIDE.md`:
   - Line 3: `**Version 2.44.5 — Alex / Blake is the Default**`
   - Line 51: `cat .tad/version.txt          # 应显示 2.44.5`
8. `PROJECT_CONTEXT.md`:
   - Line 4: `- **Version**: 2.44.5 (Full is the default channel, ...)` (keep remainder of the existing **HEAD** line after the version token)
   - Line 6: `- **Framework**: TAD v2.44.5 + ...` (keep remainder of the **HEAD** line)
9. `docs/MULTI-PLATFORM.md`:
   - Line 3: `**Version**: 2.44.5 (Dual-Platform Architecture — Full is the Default Channel; lite frozen 2026-08-13)`
10. `.claude/skills/tad-help/SKILL.md`:
    - Line 17: ` Version: v2.44.5 | Generated: [timestamp]` (preserve leading space inside the fence if present)
11. `.claude/skills/alex/SKILL.md`:
    - Line 50: `<!-- TAD v2.44.5 Framework -->`
12. `.claude/skills/blake/SKILL.md`:
    - Line 166: `<!-- TAD v2.44.5 Framework -->`

Do **not** bump historical `v2.44.4` CHANGELOG body, exclusion banners, or fixture pins.

### 3.2 Dual-Tree Skill Parity Sync

After editing the three `.claude/skills/**/SKILL.md` files:

```bash
cp .claude/skills/tad-help/SKILL.md .agents/skills/tad-help/SKILL.md
cp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md
cp .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md
```

Do **not** rsync trees; do **not** `parity --fix` unless detect-only parity is already 0 and a later accidental drift appears **only** in these three files (then still prefer the three `cp` commands).

### 3.3 CHANGELOG Entry `[2.44.5]`

Prepend under `## [Unreleased]`:

```markdown
## [2.44.5] - 2026-09-11

### Added / Changed

- **Runnable Verification Method fail-close (*bug / *express)**:
  - Landing-tier Verification Method cells must be a legal runnable form; Gate 3 fail-closes on prose-only Methods.
  - Landed on `main` as `7048b835`. Gate 4 PASS: `.tad/evidence/reviews/2026-09-10-gate4-verify-delta.md`. Archives: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260910-verify-delta.md`.
- **Pack loader thin on-demand pointer + freeze skip**:
  - Keyword/auto-match announces at most 2 pointers and does not Read pack `SKILL.md`; registry `status: frozen` skips auto-match with files left on disk; escalate only when human-named or a recorded failure-retry exists.
  - Landed as `9c33e2e5`. Gate 4 PASS: `.tad/archive/handoffs/GATE4-20260910-pack-loader-thin-ondemand.md`.
- **Freeze 14 capability packs (KEEP-POINTER 11 remain active)**:
  - CAPABILITY first-fence `status: frozen` + live `scan-packs.sh` registry regen (14 frozen / 11 active). Files stay. AGENTS rows stay.
  - Landed as `eb09597a`. Gate 4 PASS: `.tad/archive/handoffs/GATE4-20260910-pack-freeze-inventory.md`.
- **KEEP11 Knife 1 CLI/SHA refresh (two packs only)**:
  - `code-security` + `web-deployment` banners dated; checkout SHA re-pin. Remaining KEEP11 knives are **not** in this patch.
  - Landed as `63cf6291`. Gate 4 PASS: `.tad/archive/handoffs/GATE4-20260911-keep11-knife1-cli-refresh.md`.
```

Honesty rules: do not claim remaining KEEP11 knives shipped; do not claim freeze/unfreeze of other packs; do not claim the `experiment-path` `ai-evaluation` SKILL dump is fixed; do not claim AGENTS ACI leftover is done; do not claim fleet auto-upgrade; do not claim verify-delta gitignored fixture is in the tag.

### 3.4 Verification Gates (detect-only; exact order)

Record stdout/stderr/exit for each. Stop on first wiring failure (exit 2).

1. `bash .tad/hooks/lib/release-verify.sh parity .` — must exit **0**.
2. `bash .tad/hooks/lib/derive-sync-set.sh --report .` then `bash .tad/hooks/lib/release-verify.sh version . 2.44.5 2.44.4` — exit 2 blocks; exit 1 on **patch** = advisory (record disposition: identity vs historical; do not falsify history).
3. `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.5` — Layer 1 must exit **0** (blocking for patch). Layer 2 print is advisory.
4. `bash .tad/hooks/lib/release-verify.sh migration .` — exit 2 blocks; exit 1 on patch = advisory (record).
5. `bash tad.sh --verify-denylist` — must exit **0** (`tad.sh` is in the bump set).

Supporting: pack-registry-driftcheck exit 1 is advisory unless it is a wiring 2.

### 3.5 Create Release Commit R (PATHSPEC-ONLY + dirty-file reconstruction)

Working tree is expected dirty (NEXT / PROJECT_CONTEXT extra / pm / stale active twins / judge bundles). **R must not contain that noise.**

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

1. Copy the current working-tree file to a **non-repo sidecar** (e.g. `/tmp/tad-v2445-$(basename <path>)`) so ledger/noise hunks are not destroyed.
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
git commit -m "release: v2.44.5

Verify-delta + pack loader/freeze + KEEP11 knife 1. Version + CHANGELOG only."
```

Pre-push:

- `git show --stat --name-only --pretty=format: HEAD` lists **exactly** those 16 files. Parent of R must be `63cf62912131d1f40273d54b0e6456aad9ba33af`.
- Intra-file guard: `git diff 63cf62912131d1f40273d54b0e6456aad9ba33af HEAD -- PROJECT_CONTEXT.md` (and any other reconstructed identity file) shows **only** the mandated version-token line edits. If extra hunks appear, mixed-reset R and do not push. Filename-only AC4 is not sufficient.

### 3.6 Mandate-Bound Publish Sequence (NO chaining)

Re-read ls-remote immediately before P1. Then **four separate commands** (new shell invocation each; no `&&` / `;` joining P1–P4):

**P1** Push main:

```bash
git push origin <commit_R>:refs/heads/main
```

**P2** Annotated tag:

```bash
git tag -a v2.44.5 <commit_R> -m "v2.44.5 — Verify-delta + pack loader/freeze + KEEP11 knife 1"
```

**P3** Push tag:

```bash
git push origin refs/tags/v2.44.5:refs/tags/v2.44.5
```

**P4** GitHub Release:

```bash
gh release create v2.44.5 \
  --title "v2.44.5 — Verify-Delta + Pack Loader/Freeze + KEEP11 Knife 1" \
  --notes "### TAD v2.44.5 Release Notes

Patch over v2.44.4. Ships four commits already on main (\`7048b835\`, \`9c33e2e5\`, \`eb09597a\`, \`63cf6291\`).

- Runnable Verification Method fail-close for *bug/*express (Gate 4: .tad/evidence/reviews/2026-09-10-gate4-verify-delta.md).
- Thin pack loader: max-2 pointers, frozen-skip, files stay (GATE4-20260910-pack-loader-thin-ondemand).
- Freeze 14 packs via CAPABILITY status + registry regen; KEEP-POINTER 11 still active (GATE4-20260910-pack-freeze-inventory).
- KEEP11 knife 1 only: code-security + web-deployment CLI/SHA refresh (GATE4-20260911-keep11-knife1-cli-refresh). Remaining KEEP11 knives are not in this patch.

Does not include remaining KEEP11 knives, experiment-path auto-load dump fix, or downstream sync.
"
```

### 3.7 Post-Publish Verification

- `git ls-remote --heads origin refs/heads/main` == `<commit_R>`
- `git ls-remote --tags origin refs/tags/v2.44.5 refs/tags/v2.44.5^{}` peel to `<commit_R>`
- `gh release view v2.44.5` is public (create as published, not draft)
- Completion: `.tad/active/handoffs/COMPLETION-20260911-publish-v2445.md`

---

## 4. Acceptance Criteria (summary)

- [ ] AC1 parity exit 0
- [ ] AC2 version-sweep Layer 1 exit 0 for `2.44.5`
- [ ] AC3 CHANGELOG `[2.44.5] - 2026-09-11` honest vs four deltas + Gate 4 citations; no remaining-knives overclaim
- [ ] AC4 R is exactly 16 pathspec files; parent `63cf62912131d1f40273d54b0e6456aad9ba33af`; no dirty-tree noise
- [ ] AC5 remote main == R
- [ ] AC6 remote annotated tag `v2.44.5` peels to R
- [ ] AC7 GitHub Release `v2.44.5` live
- [ ] AC8 completion report with SHAs, exits, ls-remote

---

## 5. Explicitly OUT of Scope

- Implementing any of the four feature tickets (done, already on `origin/main`).
- Remaining KEEP11 knives (web-ui-design split, P1 API packs, P2 trio, Netlify re-resolve, banner GONE wording).
- Absorbing stale/dirty active twins: `HANDOFF/COMPLETION-20260908-knowledge-seam-isolation.md`, `HANDOFF/COMPLETION-20260908-publish-v2443.md`, `HANDOFF-20260908-release-v2443.md`, `HANDOFF/COMPLETION-20260909-release-v2444.md`, `COMPLETION-20260909-publish-v2444.md`, `HANDOFF/COMPLETION-20260910-verify-delta.md` (WT deletions), or this file `HANDOFF-20260911-release-v2445.md`.
- `NEXT.md` / `docs/pm/now.md` / `.tad/eval/judge/bundles/` / `brain-index.md` / `patterns/_index.md` / `patterns/ac-verification.md` noise in R.
- `--force`, `--tags`, `git add -A`.
- Downstream sync.
- Gemini.

---

## 6. Files

### 6.1 New
- `.tad/active/handoffs/COMPLETION-20260911-publish-v2445.md` (Blake)

### 6.2 Modify (commit R only)
The 16 pathspecs in §3.5.

### 6.3 Grounded Against (Alex Read, 2026-09-11)

- `.tad/version.txt` = `2.44.4`; `.tad/TAD-VERSION` = `2.44.4`; `.tad/config.yaml` L1/L3; `package.json` L3; `tad.sh` L26 `TARGET_VERSION="2.44.4"`
- `README.md` L3/L5/L190/L506 via `git show HEAD:README.md`
- `INSTALLATION_GUIDE.md` L3/L51; `PROJECT_CONTEXT.md` HEAD L4/L6 (WT dirty — reconstruct); `docs/MULTI-PLATFORM.md` L3
- `.claude/skills/tad-help/SKILL.md` L17; `.claude/skills/alex/SKILL.md` L50; `.claude/skills/blake/SKILL.md` L166
- `CHANGELOG.md` L1–20 (`## [Unreleased]` then `[2.44.4] - 2026-09-09`)
- Playbook: `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md` + `.tad/evidence/designs/2026-09-09-release-v2444-scope.md`
- `.claude/skills/release-runbook/SKILL.md` + `references/publish-ops.md`
- Four Gate 4 carriers listed in §2
- `git rev-parse HEAD` / `origin/main` / ls-remote main = `63cf6291…`; peeled `v2.44.4` = `83e2ff03…`; remote tag `v2.44.5` absent
- LSP/graph: skipped (`task_type: release`; identity/docs only; no symbol blast radius for version tokens)

### 6.7 AC Dry-Run Log (Alex step1d, 2026-09-11)

- AC0a: ✅ pre-impl `cat .tad/version.txt` → `2.44.4`
- AC0b: ✅ pre-impl `grep -n '^## [' CHANGELOG.md | head -3` → L10 `## [2.44.4] - 2026-09-09`
- AC0c: ✅ pre-impl both rev-parse = `63cf62912131d1f40273d54b0e6456aad9ba33af`
- AC0d: ✅ local tag file absent; remote ls-remote empty
- AC0e: ✅ reverse log four SHAs as expected
- AC1–AC8: ✅ post-impl-verifiable; commands parse; deferred to Blake Gate 3
- Advisory: `verify-ac-commands.sh` 0 warnings, 0 info

---

## 7. Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/2026-09-11-gate2-review-v2445-spec.md
    - .tad/evidence/reviews/2026-09-11-gate2-review-v2445-scope.md
  gate_verdicts:
    - parity / version-sweep / migration / denylist exits recorded in completion
  completion:
    - .tad/active/handoffs/COMPLETION-20260911-publish-v2445.md
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
| Codex/Claude/Cursor sandbox git push | User approval | Ask human | None | BLOCKED |

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
| AC2 | Identity sweep NEW=2.44.5 | post-impl-verifiable | `bash .tad/hooks/lib/release-verify.sh version-sweep . 2.44.5` | Layer 1 exit 0 | (post-impl) |
| AC3 | CHANGELOG 2.44.5 honesty | post-impl-verifiable | `grep -n '## \[2.44.5\] - 2026-09-11' CHANGELOG.md`; `grep -E '7048b835|9c33e2e5|eb09597a|63cf6291' CHANGELOG.md`; `grep -F 'Remaining KEEP11 knives' CHANGELOG.md` | heading present; four SHAs; remaining-knives sentence present | (post-impl) |
| AC4 | R pathspec isolation + intra-file purity | post-impl-verifiable | `git show --name-only --pretty=format: HEAD` equals the 16 paths; `git rev-parse HEAD^` == `63cf62912131d1f40273d54b0e6456aad9ba33af`; `git diff 63cf62912131d1f40273d54b0e6456aad9ba33af HEAD -- PROJECT_CONTEXT.md` contains only version-token edits (2.44.4→2.44.5) | exactly 16 files; parent match; no ledger/noise hunks in identity diffs | (post-impl) |
| AC5 | Remote main == R | post-impl-verifiable | `git ls-remote --heads origin refs/heads/main` | SHA == R | (post-impl) |
| AC6 | Tag peels to R | post-impl-verifiable | `git ls-remote --tags origin refs/tags/v2.44.5 refs/tags/v2.44.5^{}` | annotated + peeled R | (post-impl) |
| AC7 | GitHub Release live | post-impl-verifiable | `gh release view v2.44.5 --json tagName,isDraft,url` | tagName v2.44.5, isDraft false | (post-impl) |
| AC8 | Completion carrier | post-impl-verifiable | `test -f .tad/active/handoffs/COMPLETION-20260911-publish-v2445.md` | file exists with SHAs + exits | (post-impl) |
| AC0a | OLD identity still 2.44.4 before Blake | pre-impl-verifiable | `cat .tad/version.txt` | `2.44.4` | `2.44.4` |
| AC0b | Prior CHANGELOG head | pre-impl-verifiable | `grep -n '^## \[' CHANGELOG.md \| head -3` | line 10 `## [2.44.4] - 2026-09-09` | L8 Unreleased; L10 `[2.44.4] - 2026-09-09` |
| AC0c | Tip binding | pre-impl-verifiable | `git rev-parse HEAD` and `git rev-parse origin/main` | both `63cf62912131d1f40273d54b0e6456aad9ba33af` | both equal that SHA |
| AC0d | No v2.44.5 tag yet (local + remote) | pre-impl-verifiable | `test ! -e .git/refs/tags/v2.44.5`; `git ls-remote --tags origin refs/tags/v2.44.5` empty | absent | local absent; ls-remote empty |
| AC0e | Four-commit stack | pre-impl-verifiable | `git log --format=%h --reverse v2.44.4..HEAD` | `7048b835` `9c33e2e5` `eb09597a` `63cf6291` | exact four lines in that order |

---

## 10. Important Notes / Anti-patterns

- Do not treat Gate 4 “local only; do not push” on the **feature** tasks as a ban on **this** release — that boundary applied to the four tickets. This mandate **authorizes** publishing those commits via tag `v2.44.5`.
- Do not bump `tad.sh` dynamic `TARGET_VERSION=` lines other than L26.
- Do not run combined `git push && git tag && git push --tags`.
- Do not use `parity --fix` as a substitute for the three `cp` commands.
- Do not wait for remaining KEEP11 knives.

---

## 11. Decision Summary

| Decision | Choice | Source |
|---|---|---|
| SemVer | patch 2.44.5 | Human 2026-09-11 |
| Payload | four commits already on origin/main | Human + Gate 4 PASS citations |
| Remaining KEEP11 | out of scope | Human |
| Staging | 16 pathspecs + HEAD reconstruction | v2.44.4 lesson + dirty tree |
| Sync | none | Human |
| Gemini | none | Human |

---

## 12. MQ1–MQ6

| MQ | Answer | Evidence |
|---|---|---|
| MQ1 Historical | Reuse v2.44.4 handoff + publish-ops; do not invent a new publisher | Read HANDOFF-20260909-release-v2444.md; publish-ops.md |
| MQ2 Functions exist | `release-verify.sh`, `derive-sync-set.sh`, `tad.sh --verify-denylist`, `gh`, `git` | Paths under `.tad/hooks/lib/`; tad.sh L26 |
| MQ3 Data flow | N/A (no UI) | NOT_APPLICABLE_WITH_REASON: release ops |
| MQ4 Visual | N/A | same |
| MQ5 State sync | Dual trees via 3 explicit `cp` | §3.2 |
| MQ6 Research | Existing SOP; no new research | `research_required: no` |

---

## 13. Gate 2 Review Dispatch (STOP — do not start Blake)

Canonical Gate 2 (`.tad/gates/gate-canonical-checklist.md`): expert review min 2 ✅; P0 resolved ✅; architecture/components/functions/data-flow ✅ (publish SOP reuse).

### Audit Trail (expert review)

| Reviewer | Carrier | Verdict | P0 | Disposition |
|---|---|---|---|---|
| Spec & Pathspec | `.tad/evidence/reviews/2026-09-11-gate2-review-v2445-spec.md` | PASS | 0 | P1 already in §10 (feature “do not push” vs this mandate). P2: AC3 now has SHA + remaining-knives greps; §4 AC4 uses full parent SHA. |
| Safety & Blast Radius | `.tad/evidence/reviews/2026-09-11-gate2-review-v2445-scope.md` | PASS | 0 | P1: full dirty/untracked snapshot named in §1 Blast radius + §5. P2 recovery classify-only left as-is (STOP, no force). |

After human confirms Gate 2 (both carriers P0=0, P1 integrated): set status `READY_FOR_BLAKE` and say **当 Blake**.

Status remains `READY_FOR_GATE2` until the human accepts the dual PASS carriers. Alex did not bump or publish.

---

## 📨 Message to Blake (do not send until READY_FOR_BLAKE)

```
Task: Publish patch v2.44.5 (identity bump + CHANGELOG + push/tag/gh release)
Handoff: .tad/active/handoffs/HANDOFF-20260911-release-v2445.md
Priority: high (public tag lagging origin/main)
Scope: 16 pathspecs only; parent 63cf6291; NO sync; NO KEEP11 remainder
```
