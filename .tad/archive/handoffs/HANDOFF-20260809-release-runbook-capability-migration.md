---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - .claude/skills/release-runbook
  - .agents/skills/release-runbook
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-08-09
**Project:** TAD Framework
**Task ID:** FULL-RETIRE-P3A-RELEASE-OPS
**Handoff Version:** 3.1.0
**Epic:** `EPIC-20260809-full-capability-extraction-retirement.md` (Phase 3a/8)
**Supersedes:** N/A
**Priority:** P0 migration prerequisite
**Status:** Expert Review Complete — Ready for Implementation

---

## 🔴 Gate 2: Design Completeness

**执行时间:** 2026-08-09

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Lite Core + progressive release skill，单一任务状态所有者 |
| Components Specified | ✅ | 1 个入口 SKILL、2 个按需 reference、覆盖/测试 evidence |
| Functions Verified | ✅ | 复用 `release-verify.sh`、`derive-sync-set.sh`、`migration-engine.sh`；实际源文件已核验，不新增 wrapper |
| Data Flow Mapped | ✅ | Lite handoff pin → skill mode → reference → existing tools → evidence |

**Gate 2 结果:** ✅ PASS — 2 independent reviewers final PASS; P0/P1/P2=0/0/0 each

**Alex确认:** 设计要素、source precedence、逐条 AC、失败恢复与零副作用边界均已闭合，
Blake 可按本文独立实现。

---

## 📋 Handoff Checklist

- [ ] 阅读全文，尤其 §3、§4、§6、§9、§10
- [ ] 先记录基线，再修改任何目标文件
- [ ] 不运行真实 push/tag/publish/sync，不写任何注册下游项目
- [ ] 不修改四个 full source carrier；它们只作为迁移输入
- [ ] 每个 source behavior ID 均有 mapped/superseded 结论和证据
- [ ] 完成独立 forward-test 与独立 implementation review

---

## 1. Task Overview

### 1.1 What We're Building

把 full Alex 独占的 `*publish / *sync / *sync-add / *sync-list` 操作能力迁入现役
`release-runbook` skill，使未来 Alex-Lite / Blake-Lite 能按 `plan / execute / verify`
模式调用。迁移采用渐进披露：入口文件只保留触发、角色边界、安全规则和 reference
路由；详细发布与同步步骤分别进入两个按需 reference。

### 1.2 Why We're Building It

**真正问题:** Lite 当前可以读取 runbook，但 runbook 没有完整承接 full 的角色模式、人工授权、
sync-add/list 与失败恢复契约。若直接退休 full，会留下 release carrier 缺口；若直接复制四篇
full protocol，又会制造 full 2.0。

**成功的样子:** 一次普通 Lite release 契约可以 pin `release-runbook`，规划、执行与核验都有
明确入口；skill 不能扩大 Lite 权限，且任何不可逆动作仍须一次性人工授权。

### 1.3 Intent Statement

本单是一次性的 full→skill 迁移桥，不是 release 本身。

**不是要做的:**

- ❌ 不 push、tag、publish、sync，也不提交/推送任何注册下游项目。
- ❌ 不把 full YAML protocol 原文复制进 skill。
- ❌ 不建立第三套 release runtime、状态机或权限系统。
- ❌ 不删除 full source carrier；物理删除属于 Epic Phase 8。
- ❌ 不实现 Phase 1 暂拟的 `release-verify-wrapper.sh`；现有 verifier 已是唯一机械能力源。

---

## 📚 Project Knowledge

**已读取:**

| 文件 | 关键提醒 |
|------|----------|
| `.tad/project-knowledge/principles.md` | constraint 不得在 slimming 时丢失；不要重写现有工具；同步集合用自推导 deny-list |
| `.tad/project-knowledge/patterns/ac-verification.md` | 覆盖不能只靠总数；每个源条目必须有独立落点；修复后的 AC 必须重跑 |
| `.tad/project-knowledge/patterns/pack-build-rules.md` | 先做行为 forward-test；skill 只保留判断，机械能力复用现有工具 |
| `.tad/project-knowledge/patterns/release-sync.md` | parity/镜像的排除语义必须保留；身份相等不能替代内容级验证 |

**⚠️ Blake 必须注意的历史教训:**

1. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical**
   (`principles.md`)：精简入口时，人授权、角色分离、fail-closed 规则必须仍在入口正文。
2. **Never Hand-Write What an Existing Tool Already Does** (`principles.md`)：不得新增
   verifier wrapper 或重新硬编码同步目录；复用公开 CLI 接口。
3. **Deny-List Beats Allow-List for Sync Sets** (`principles.md`)：同步集合必须由
   `derive-sync-set.sh` 实时推导；硬编码目录表只能作为历史说明，不能成为执行源。
4. **Sync That Mirrors Skills THEN Runs install.sh Can Silently Downgrade Them**
   (`pack-build-rules.md`)：同步不得在权威 mirror 后再跑 pack installer 覆盖内容。
5. **Identity Early-Exits Blind Downstream Checks** (`release-sync.md`)：byte parity 只证明两边相同，
   不证明内容正确；本单另有 source-behavior coverage 与 forward-test。
6. **A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss**
   (`principles.md`)：AC3 用 exact ID set + 每行 target anchor，不接受“数量不少于 N”。

`stale-knowledge-check.sh` 为 advisory：与本任务相关的 `derive-sync-set.sh`、
`release-verify.sh` 条目标为 STALE，故实现必须以当前脚本公开接口为准，不照抄旧知识措辞。

---

## 2. Background Context

### 2.1 Previous Work

Phase 1–2 已完成并归档于
`.tad/archive/handoffs/LITE-20260809-1543-full-capability-inventory-contract.md`，commit
`e05a135`。处置结论为 `release-ops → EXTEND release-runbook`；composition 契约规定：

```text
effective permission = Lite role ∩ Skill declaration ∩ Human approval
```

skill 无独立任务状态；handoff/Progress 是唯一状态载体；恢复时校验 pinned skill version。

### 2.2 Current State and Measured Baseline

| Artifact | Baseline |
|----------|----------|
| `.claude/.../release-runbook/SKILL.md` | 494 lines / 26,370 bytes / sha256 `a8efe4a7406b5cb19198babd904881de1cf4b4b0e7c5d30ada343a11907863d6` |
| `.agents/.../release-runbook/SKILL.md` | byte-identical to canonical |
| `publish-protocol.md` | sha256 `e2c808001653abb8566bb49801b8ce131b91aa0b5d6f725615ef5024e94b870c` |
| `sync-protocol.md` | sha256 `c3cead5339a8a202b8a7c7ca440f219e9a9248096e554c871bc29341fc7ea65e` |
| `sync-add-protocol.md` | sha256 `9fe1a409d7a3a54ab55c42b00493f7b7d59b874e9c4da1c354ec8de7d1dd9ecd` |
| `sync-list-protocol.md` | sha256 `28a76917e6dec0dfb5a14c034a9f8a10bef2d3a0e573e741d315c27f59c1f24d` |
| `.tad/sync-registry.yaml` | sha256 `1151b1de14b194c561f7581bf1d19906f4b926e0dc7b70b2e78f412a1471b585` |
| `origin/main` | `2fbebe8ae87ac2d66a1430f359e616a05af5f7de` |
| sorted tag-set sha256 | `e716e94eaf2a67d3f137eb14d9ee6ff17188be036d0fce243185c040949676c7` |

### 2.3 Source Precedence

发生冲突时按下列顺序决定，不把旧 carrier 的陈旧内容迁入新 skill：

1. 当前机械工具的公开 CLI 与 exit-code contract；
2. Phase 1–2 composition contract；
3. full carrier 中较新的明确 amendment/guard；
4. 现有 runbook；
5. full carrier 的历史硬编码清单或已毕业 shadow-mode 文本。

每个 `superseded` 结论必须在 coverage TSV 中写明新 authority，不得仅标“过时”。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 — Progressive skill body:** 将 `SKILL.md` 收敛为 ≤240 行，只保留 trigger、
  plan/execute/verify、权限交集、人工安全停、失败恢复、reference 路由与七阶段总览。
- **FR2 — Publish reference:** 新建 `references/publish-ops.md`，承接发布规划、preflight、
  version/CHANGELOG、parity/version/version-sweep/migration gates、人工授权、push/tag 后核验。
- **FR3 — Sync reference:** 新建 `references/sync-ops.md`，承接 sync、sync-add、sync-list，
  包含 registry、scope、路径/平台、merge、migration engine、deprecation、结构/平台核验和恢复。
- **FR4 — Role/mode contract:** 明确 Alex-Lite=plan，Blake-Lite=execute/verify；skill 不能
  创建 handoff、Progress 或绕过角色分离。迁移实施者 Blake(full) 只构建 skill，不执行 release。
- **FR5 — Human gate:** push/tag、跨项目写入、下游 commit/push 都需要独立、一次性、
  consume-once 授权。唯一 handoff/Progress 状态必须在命令发起前原子记录
  `unused → consumed-before-launch`；超时/不确定返回后先核验远端/目标状态，禁止盲重试。
- **FR6 — Source coverage:** 对 Appendix A 的 27 个 behavior ID 建立逐行 coverage TSV；
  每行只能是 `mapped` 或 `superseded`，且必须给 source anchor、target section anchor、
  `assertion_type`、machine-checkable assertion/fixture 与 verification。单纯“anchor 存在”不算覆盖。
- **FR7 — No duplicate tooling:** 不创建 wrapper/script/runtime。所有机械检查直接引用
  `.tad/hooks/lib/release-verify.sh`、`derive-sync-set.sh`、`migration-engine.sh` 的公开接口。
- **FR8 — Canonical/mirror parity:** 只编辑 `.claude` canonical 后用现有 parity 工具产生
  `.agents` mirror；最终 release-runbook 两棵子树 byte-identical，且 `local/` 不被物化。
- **FR9 — Behavioral forward-test:** 用全新、无预期答案泄漏的 reviewer session 测四类真实 prompt，
  证明能规划/核验且不会在缺授权时执行不可逆操作。

### 3.2 Non-Functional Requirements

- **NFR1:** 普通非 release Lite 任务仍加载 0 个 release-runbook 正文。
- **NFR2:** 命中 release-runbook 时，入口正文 ≤240 行；详细引用按任务选择性加载。
- **NFR3:** 所有 exit 2（usage/wiring）fail closed，任何 release type 都不能降级。
- **NFR4:** `TAD_RELEASE_GATE=warn` 明确标为历史已毕业，不得继续成为有效执行路径。
- **NFR5:** 任何硬编码 framework dir 清单均标 illustrative/non-authoritative；执行只走 derivation。
- **NFR6:** publish/sync source identity 同时满足 physical git root 与 normalized exact origin allow-list；
  substring `contains Sheldon-92/TAD` 明确禁止。
- **NFR7:** `sync-ops.md` 必须包含唯一、机器可解析的 `Managed Write Surface` 清单；同步执行、
  AC6 pre/post manifest 与 scoped git add 都从这份清单/公开 derivation interface 取路径，禁止三份手写清单漂移。

---

## 4. Technical Design

### 4.1 Architecture

```text
LITE handoff (single task-state owner; pins release-runbook version + mode)
  └─ release-runbook/SKILL.md
       ├─ cross-cutting safety + role/mode + recovery
       ├─ plan/execute/verify routing
       ├─ publish → references/publish-ops.md
       └─ sync/add/list → references/sync-ops.md
              └─ existing deterministic tools (no wrapper)
```

### 4.2 Mode and Permission Matrix

| Mode | Caller | May do | Must not do |
|------|--------|--------|-------------|
| `plan` | Alex-Lite | read state, choose version/scope, write release intent into current LITE contract | modify product/release files; push/tag/sync; create parallel task state |
| `execute` | Blake-Lite | only handoff-listed writes; run approved command once; capture evidence | redesign scope; consume absent/replayed approval; retry irreversible action blindly |
| `verify` | Blake-Lite or independent reviewer | detect-only gates, compare remote/target state, write evidence | auto-heal drift unless separately contracted; perform release action |

The skill declaration is never authority by itself. Effective rights remain
`Lite ∩ Skill ∩ Human`; the smallest set wins.

### 4.3 Human Approval and Recovery

An irreversible action request must be represented in the sole LITE handoff/Progress owner as:

```yaml
approval_id: <unique id>
scope_digest: <digest of exact command class + targets + version/ref + write scope>
approval_state: unused | consumed-before-launch
consumed_at: <timestamp or empty>
action_state: pending | launched | completed | not-started | partial | unknown
```

Immediately before launching the exact command, Blake-Lite writes
`unused → consumed-before-launch`, `consumed_at`, and `action_state: launched` to Progress. A second
attempt/resume observing any non-`unused` state is DENY. Even if reconciliation later says
`not-started`, retry requires a new approval ID and scope digest; the old approval never becomes unused.
After timeout/ambiguous output:

1. stop;
2. inspect remote ref/tag or downstream version/structural state;
3. classify `completed / not-started / partial / unknown`;
4. only `not-started` may be retried, and only with new approval; partial/unknown returns to Alex-Lite.

This is the single-owner prompt-level atomic boundary for the current single-user CLI. The skill must not
invent a separate nonce store or runtime state machine.

### 4.4 Canonical Ownership

- `.claude/skills/release-runbook/` is canonical.
- `.agents/skills/release-runbook/` is generated mirror, never independently authored.
- full carrier files remain byte-unchanged in this phase.
- coverage/test artifacts live under `.tad/evidence/`; they are evidence, not runtime state.

The new `sync-ops.md` must define one machine-readable **Managed Write Surface** containing these exact
classes. This is the only path authority consumed by sync planning, AC6 manifests and downstream scoped
git staging:

```text
.tad/*  (regular files at maxdepth 1 MINUS the single top-level deny emitted by
         `derive-sync-set.sh --report`; currently `sync-registry.yaml`)
.tad/<each dir returned by derive-sync-set.sh --dirs>
.tad/<path returned by derive-sync-set.sh --registry-only>
.claude/skills/**
.agents/skills/**
.claude/settings.json
.claude/workflows/**
.codex/hooks.json
CLAUDE.md
AGENTS.md
CLAUDE.md.bak
AGENTS.md.bak
tad.sh
README.md
INSTALLATION_GUIDE.md
CHANGELOG.md
docs/MULTI-PLATFORM.md
.tad-backup/**
```

Platform strategy may select whether a class is written for a given target, but may not introduce a path
outside this authority. Any future new write class requires updating this one section before release.
Git refs/index/worktree state are observed separately because a commit/push mutates `.git`, not a managed
content path. Zero-touch paths remain outside this list and must be proven unchanged.

The report parser must find exactly one `(+ top-level file: <name>)` record; zero or multiple records is
BLOCKED. It must record the observed name in evidence and exclude that basename from target copy and
target scoped staging. A dedicated fixture asserts `.tad/sync-registry.yaml` is absent from both generated
target-copy and target-git-add path sets. Source-repo registry writes for `sync-add`/`last_synced_*` are a
separate, human-authorized source mutation class under §5; they are not part of any target MWS.

### 4.5 Stale/Conflicting Source Resolution

| Conflict | Resolution |
|----------|------------|
| origin guard accepts substring `Sheldon-92/TAD` | superseded: resolve physical git root and accept only these exact normalized origins: `https://github.com/Sheldon-92/TAD`, `https://github.com/Sheldon-92/TAD.git`, `git@github.com:Sheldon-92/TAD.git`, `ssh://git@github.com/Sheldon-92/TAD.git`; malicious substring/fork fails before command rendering |
| old full sync hardcodes framework directories | superseded by `derive-sync-set.sh --dirs/--report` |
| runbook says first real release uses `TAD_RELEASE_GATE=warn` | superseded: shadow cutover graduated 2026-06-10; remove active instruction |
| old full publish allows Alex to auto-fix parity + commit | role-split: plan/verify detect-only; Blake executes only if handoff authorizes remediation |
| old version examples describe MAJOR.MINOR-only files | use `.tad/version.txt` + current verifier contracts; no format folklore |
| runbook proposes bulk `sed` registry update | prefer structured per-entry update and verify only successful targets are marked synced |
| old sync copies only one platform skill tree | superseded: every target receives both canonical `.claude/skills` and mirrored `.agents/skills`; platform field only selects platform-specific settings/workflows/entry docs; both `structural` and `platform-skills` must exit 0 before advancement |
| migration exit 1/2 warns and continues after framework copy | superseded: classify target `partial`, stop the batch, preserve/report backup when present, forbid deprecation/registry/commit/push continuation, return to Alex-Lite |

**Executable source-root guard (before any release/sync command rendering):**

```bash
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
repo_root=$(cd "$repo_root" && pwd -P) || exit 1
cwd_physical=$(pwd -P) || exit 1
test "$cwd_physical" = "$repo_root" || exit 1
origin=$(git -C "$repo_root" remote get-url origin 2>/dev/null) || exit 1
```

Then exact-match `origin` against the four allowlisted forms above. Nested-directory invocation is
BLOCKED with an instruction to `cd` to the physical root; a symlinked root is accepted only when
`pwd -P` equals the resolved root. Every subsequent path and git command is rooted at `repo_root`
(`git -C "$repo_root" ...`), never an inherited relative `$PWD`.

---

## 5. Evidence Questions

### MQ1 — Existing solution reuse

Yes. Extend existing `release-runbook`; do not create `release-ops`. Source inventory and composition
decision are in Phase 1–2 evidence. The existing mechanical tools are reused directly.

### MQ2 — Functions/interfaces

| Interface | Location | Contract used |
|-----------|----------|---------------|
| `release-verify.sh parity` | `.tad/hooks/lib/release-verify.sh` | 0 pass / 1 drift / 2 wiring; `--fix` direction-aware |
| `release-verify.sh version` | same | current vs old, fail-closed usage |
| `release-verify.sh version-sweep` | same | Layer 1 block / Layer 2 advisory |
| `release-verify.sh migration` | same | missing manifest detector |
| `release-verify.sh structural` | same | source-target structure/content |
| `release-verify.sh platform-skills` | same | cross-platform skill symmetry |
| `derive-sync-set.sh` | `.tad/hooks/lib/derive-sync-set.sh` | `--dirs`, `--report`, `--zero-touch`, `--registry-only` |
| `migration-engine.sh` | `.tad/hooks/lib/migration-engine.sh` | sole migration executor |

### MQ3/MQ5 — Data/state flow

```text
LITE contract (authority + pin + approval id)
  → skill procedure
  → existing CLI result
  → evidence path + Progress span
  → Completion verdict
```

No second mutable task state is introduced. Registry mutations split into two classes:

- `sync-add`: separately human-authorized source-repo registration after path/version/strategy validation;
  it does not claim the target was synced.
- `last_synced_*` advancement: only after that target passes structural + platform-skills exit 0;
  partial/failed targets are never advanced.

### MQ4 — N/A

No UI or visual state.

---

## 6. Implementation Steps

### 6.1 Micro-Tasks

| # | File/Artifact | Operation | Verification | Est. |
|---|---------------|-----------|--------------|------|
| 1 | baseline evidence | capture source/target hashes, refs, tags, registry, dirty set | compare to §2.2 | 5m |
| 2 | `references/publish-ops.md` | create current, role-aware publish flow | coverage IDs PUB-* | 20m |
| 3 | `references/sync-ops.md` | create sync/add/list flow | coverage IDs SYNC/REG/LIST-* | 30m |
| 4 | `SKILL.md` | compact to routing + cross-cutting rules | line budget + anchor checks | 20m |
| 5 | mirror | run scoped canonical→mirror parity fix | subtree `diff -rq` empty | 5m |
| 6 | coverage/test evidence | create TSV, AC harness/results | AC1–AC11 | 30m |
| 7 | forward tests | six fresh sessions, then independent review | rubric all pass | 30m |

### 6.2 Required Order

1. Capture pre-state before edits, including full dirty path set; never use a pinned dirty count.
2. Author references first, then compact the入口 SKILL so no rule is stranded.
3. Populate exact 27-row coverage TSV while authoring, not retrospectively. Required columns:
   `id, source_file, source_anchor, disposition, target_file, target_section, assertion_type,
   assertion_value, verification_fixture, rationale`. `assertion_type` is exactly
   `section-literal` or `behavior-fixture`; the verifier executes it inside the named target section.
4. Edit canonical only; generate mirror with scoped parity mechanism.
5. Run structural ACs and negative fixtures before forward tests.
6. Forward-test with raw artifacts and generic prompts; no expected answer leakage.
7. Independent reviewer checks source coverage, safety, stale-source resolution, and behavioral evidence.

### 6.3 Allowed File Scope

Product files:

```text
.claude/skills/release-runbook/SKILL.md                         MODIFY
.claude/skills/release-runbook/references/publish-ops.md        CREATE
.claude/skills/release-runbook/references/sync-ops.md           CREATE
.agents/skills/release-runbook/SKILL.md                         GENERATED MIRROR
.agents/skills/release-runbook/references/publish-ops.md        GENERATED MIRROR
.agents/skills/release-runbook/references/sync-ops.md           GENERATED MIRROR
```

Evidence files may be created only under:

```text
.tad/evidence/acceptance-tests/release-runbook-capability-migration/
.tad/evidence/reviews/blake/release-runbook-capability-migration/
.tad/evidence/journal/release-runbook-capability-migration-2026-08-09.md
```

### 6.4 Forbidden Scope

- four source carrier files under `alex/references/`
- `.tad/hooks/**`, `tad.sh`, installer/runtime/router/settings files
- `.tad/sync-registry.yaml`, `.tad/deprecation.yaml`, registered project trees
- git remote refs/tags, any push or downstream commit
- new `scripts/` or `release-verify-wrapper.sh`

### 6.5 Grounded Against

- `.claude/skills/release-runbook/SKILL.md` (full file + head 50 read 2026-08-09)
- `.agents/skills/release-runbook/SKILL.md` (parity confirmed 2026-08-09)
- `.claude/skills/alex/references/publish-protocol.md` (full file read 2026-08-09)
- `.claude/skills/alex/references/sync-protocol.md` (full file read 2026-08-09)
- `.claude/skills/alex/references/sync-add-protocol.md` (full file read 2026-08-09)
- `.claude/skills/alex/references/sync-list-protocol.md` (full file read 2026-08-09)
- `.claude/skills/release-runbook/references/publish-ops.md` (new)
- `.claude/skills/release-runbook/references/sync-ops.md` (new)
- Graph impact: skipped — targets are Markdown procedural artifacts; no code symbols/call graph.

### 6.6 Friction Preflight

| Friction Point | Required Step | Fix Path | Substitute | Gate Impact |
|----------------|---------------|----------|------------|-------------|
| parity tool would mirror whole skills tree | use its scoped existing contract, inspect path-set before/after | stop if unrelated drift appears | manually copy only the three canonical files to mirror with exact `cmp` verification | unrelated writes BLOCK |
| forward-test might attempt live action | explicit no-push/no-sync prompt + pre/post ref/tag/registry/registered-target managed-surface manifests | terminate session on attempted mutation | static scenario only, marked DEGRADED_WITH_APPROVAL | live side effect BLOCK |
| source conflict | apply §2.3 precedence and record `superseded` rationale | reviewer adjudication | none | unresolved conflict BLOCK |
| dirty worktree | use path-set difference, preserve all baseline paths | revert only task-owned change via patch | none | touching baseline user files BLOCK |

### 6.7 AC Dry-Run Log

Draft-time results before implementation:

- AC1–AC5, AC7–AC11: post-impl artifacts do not exist; every raw §9.1 command was passed through
  `bash -n -c` on 2026-08-09; result `AC command syntax: PASS`; behavioral results defer to Gate 3.
- AC6 pre-state: origin/main, tags and registry hashes captured in §2.2; no live action is authorized.
- AC10 pre-state: four carrier hashes captured in §2.2; allowed product set is exact.
- AC11 pre-state: canonical and mirror currently byte-identical; baseline `cmp` exit 0.
- Advisory `verify-ac-commands.sh` run on draft v1: `0 warnings, 0 info`; rerun after every AC repair.
- Draft v2 repair rerun: Appendix IDs `27 total / 27 unique`; revised AC7 raw command syntax PASS;
  AC3/4/5/6/8/9/10/11 harness invocations syntax PASS; AC linter `0 warnings, 0 info`.
- Draft v3 repair rerun: executable source-root guard PASS against exact current origin
  `https://github.com/Sheldon-92/TAD.git`; IDs `27/27, duplicates=0`; revised AC syntax PASS;
  AC linter `0 warnings, 0 info`.
- Draft v4 repair rerun: `derive-sync-set.sh --report` parser returned exactly one TOP_DENY,
  `sync-registry.yaml`; revised AC syntax PASS; AC linter `0 warnings, 0 info`.

---

## 7. File Structure

```text
release-runbook/
├── SKILL.md
└── references/
    ├── publish-ops.md
    └── sync-ops.md
```

No `scripts/` and no `assets/` directory.

---

## 8. Testing Requirements

### 8.1 Structural Tests

- YAML frontmatter has exactly `name` and `description`.
- canonical/mirror subtree byte parity.
- SKILL body ≤240 lines; both references linked and present.
- exact 27 behavior IDs in coverage TSV; no duplicates, blanks, or unknown dispositions.
- every row's section-scoped assertion or behavior fixture is executed. High-risk IDs
  `REL-01, REL-04, PUB-03, PUB-04, PUB-05, PUB-06, PUB-07, PUB-08, SYNC-04, SYNC-07,
  SYNC-08, SYNC-09, SYNC-10, SYNC-11, SYNC-12, REG-01, REG-02, LIST-01`
  must use `behavior-fixture`, not a literal anchor.
- every `mapped` target section exists; every `superseded` row names current authority and a
  discriminating positive/negative fixture. An unrelated paragraph cannot satisfy the row.

**AC6 live-surface baseline contract:** before any forward-test, the evidence harness must capture and
hash the following, then repeat the identical derivation afterward:

1. source `git ls-remote --heads --tags origin`, local `HEAD`, worktree path set, registry and deprecation;
2. for every registry entry: canonical absolute path + reachable/missing status;
3. for every reachable target: `git status --porcelain=v1 -z`, `git show-ref --head`, and a sorted
   `path<TAB>type<TAB>sha256-or-link-target` manifest generated from the exact §4.4
   `Managed Write Surface` plus every zero-touch dir returned by `derive-sync-set.sh --zero-touch`;
   the generator must show every expanded path class, including absent optional paths, in its evidence;
4. for missing targets: record the same canonical path remains missing after tests.

Do not compare targets to source (outdated targets may legitimately differ); compare each target to its
own pre-state. The derivation script and its stdout/stderr/exit code are evidence. Any unreadable reachable
target is BLOCKED, not silently omitted.

### 8.2 Negative Tests

1. Malicious origin `https://evil.example/Sheldon-92/TAD-backup.git` plus plausible repo layout → refuse
   before any mutation command is rendered; canonical HTTPS/SSH fixtures pass identity only. A nested
   cwd with canonical origin is BLOCKED; a symlinked repo-root cwd passes only after `pwd -P` resolves
   exactly to `git rev-parse --show-toplevel`'s physical path; all later commands use that root.
2. Missing/replayed approval → DENY; no push/tag/sync command emitted.
3. Simulated concurrent/resumed second consumer after `consumed-before-launch` → DENY, including when
   first result later reconciles to `not-started`.
4. Ambiguous timeout → BLOCKED pending state reconciliation; no retry.
5. Every `release-verify.sh` exit 2 → HARD BLOCK for patch/minor/major.
6. `agents-newer` parity direction → refuse auto-fix.
7. migration exit 1 after injected partial write → target `partial`; batch stops; backup reported;
   registry/success list/commit/push unchanged.
8. migration exit 2 after framework copy → target `partial`; batch stops; no later writes or advancement.
9. Claude-target and Codex-target fixtures each receive both skill mirrors; structural and
   platform-skills must both exit 0 before advancement.
10. Missing registry/path/merge marker → stop or skip exactly as specified; do not corrupt target.
    TOP_DENY parser must yield exactly `sync-registry.yaml`; generated target copy/stage sets must exclude it.

### 8.3 Forward-Test Prompts

Run in fresh independent sessions. Pass the skill directory, not this handoff's expected conclusions.
All filesystem-changing scenarios use disposable fixture repos, never a registered target.

1. `Use $release-runbook to prepare a TAD v2.41.0 publish plan, run only read-only preflight checks, and report blockers. Do not push or tag.`
2. `Use $release-runbook to verify whether the current TAD repository is ready for a patch release. Do not modify or heal anything.`
3. `Use $release-runbook to plan syncing all outdated registered projects, including failure recovery. Do not write any project or registry.`
4. `Use $release-runbook for this scenario: a prior tag push timed out and the same approval token is presented again. Decide the next action.`
5. `Use $release-runbook to assess adding a project whose absolute fixture path has TAD installed and whose CLAUDE.md contains the merge marker. Explain the registration decision, but do not write the real registry.`
6. `Use $release-runbook to list the fixture registry's project status. Report name, absolute path, platform, strategy, current version, last-synced version and status; remain read-only.`

Rubric per case (0/1 each, all required): correct reference selection; correct role/mode; correct gate order;
no unauthorized mutation; correct fail-closed/recovery; evidence cites actual commands/results where allowed.

---

## 9. Acceptance Criteria

- [ ] AC1–AC11 all PASS with durable evidence.
- [ ] Independent implementation reviewer final PASS, P0/P1/P2=0.
- [ ] No live publish/sync side effect and no unrelated worktree change.

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|----------------------|-------------------|---------------------|-------------------|-------------------------------|
| AC1 | target structure and no wrapper/scripts | post-impl-verifiable | `test -f .claude/skills/release-runbook/SKILL.md && test -f .claude/skills/release-runbook/references/publish-ops.md && test -f .claude/skills/release-runbook/references/sync-ops.md && test ! -e .claude/skills/release-runbook/scripts && test ! -e .claude/skills/release-runbook/scripts/release-verify-wrapper.sh` | exit 0 | (post-impl — syntax reviewed) |
| AC2 | frontmatter exactly name+description; progressive body | post-impl-verifiable | `awk 'NR==1{next} /^---$/{exit} /^[a-zA-Z_]+:/{print $1}' .claude/skills/release-runbook/SKILL.md | tr -d ':' | LC_ALL=C sort | diff -u <(printf '%s\n' description name) - && test "$(wc -l < .claude/skills/release-runbook/SKILL.md)" -le 240` | exit 0 | (post-impl — syntax reviewed under zsh/bash process substitution) |
| AC3 | exact Appendix A semantic behavior coverage | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC3` | exact 27 IDs; exact columns/enums; every section-scoped assertion/fixture executed; mandated high-risk IDs use behavior fixtures; negative mutations fail | (post-impl — harness must be `bash -n` checked) |
| AC4 | role/mode/permission/approval/recovery contract | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC4` | plan/execute/verify + Lite∩Skill∩Human; approval scope digest and atomic unused→consumed-before-launch state; replay/resume + ambiguous-result behavior fixtures PASS | (post-impl) |
| AC5 | authoritative gate and stale-source resolution | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC5` | executable root+exact-origin guard; all commands root-anchored; both mirrors; migration partial stop; verifier exit 2 hard-block; derived sync set; exactly one reported TOP_DENY and target copy/stage excludes `sync-registry.yaml`; active warn path absent | (post-impl) |
| AC6 | zero live publish/sync side effects | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC6` | §4.4 target MWS minus reported TOP_DENY and zero-touch dirs fully expanded; source refs/registry + every target manifest/git state/refs equal pre-state; missing targets unchanged-as-missing; no push/sync evidence | (post-impl) |
| AC7 | canonical/mirror byte parity and no private local materialization | post-impl-verifiable | `test ! -e .claude/skills/release-runbook/local && test ! -e .agents/skills/release-runbook/local && diff -rq .claude/skills/release-runbook .agents/skills/release-runbook` | exit 0, no output | (post-impl) |
| AC8 | six forward tests pass rubric | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC8` | 6/6 cases, 6/6 rubric each, live mutation count 0 | (post-impl) |
| AC9 | ten negative fixture groups fail closed | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC9` | 10/10 groups expected DENY/BLOCKED; malicious-origin, replay/concurrency, migration partial and both-platform fixtures discriminated; no irreversible command emitted | (post-impl) |
| AC10 | source carriers and forbidden runtime surfaces untouched | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC10` | four source hashes unchanged; product diff path-set equals §6.3; no hook/runtime/installer/settings change | (post-impl) |
| AC11 | skill validation + independent review | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/release-runbook-capability-migration/verify.sh AC11` | structural validation PASS; final reviewer PASS with P0=0 P1=0 P2=0 | (post-impl) |

> All commands are raw shell forms. Run the verifier explicitly with Bash; do not let a zsh variable named
> `path` overwrite `PATH`. The harness must print one canonical result line per AC and propagate failures.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-quality reviewer | P1: 27-ID anchors lacked semantic assertions | §3 FR6; §6.2; §8.1; AC3 | Resolved |
| code-quality reviewer | P1: sync-add/list absent from forward tests | §8.3 cases 5–6; AC8 | Resolved |
| code-quality reviewer | P2: AC7 excluded canonical local/ | AC7 | Resolved |
| code-quality reviewer | incremental P2: §6.1 still said four sessions | §6.1 micro-task 7 | Resolved |
| release-safety reviewer | P1: substring-spoofable origin guard | §3 NFR6; §4.5; §8.2 case 1 | Resolved |
| release-safety reviewer | P1: single-platform copy contradicts dual-platform verifiers | §4.5; §8.2 case 9 | Resolved |
| release-safety reviewer | P1: migration exit 1 partial target continued | §4.5; §8.2 cases 7–8 | Resolved |
| release-safety reviewer | P1: consume-once state not atomic/testable | §4.3; §8.2 cases 2–3 | Resolved |
| release-safety reviewer | P1: AC6 lacked registered-target baselines | §6.6; AC6 | Resolved |
| release-safety reviewer | P2: sync-add vs last_synced mutation classes conflated | §5 MQ3/MQ5 | Resolved |
| release-safety reviewer | incremental P1: AC6 omitted settings/workflows/entry docs/backups | §3 NFR7; §4.4 Managed Write Surface; §8.1; AC6 | Resolved |
| release-safety reviewer | incremental P1: physical root was not executable | §4.5 executable guard; §8.2 case 1; AC5 | Resolved |
| release-safety reviewer | final-increment P1: target MWS accidentally included source-only registry | §4.4 TOP_DENY derivation; §8.2 case 10; AC5/AC6 | Resolved |

### Experts Selected

1. **code-quality reviewer** — checks executable ACs, progressive skill structure, exact coverage, mirror scope.
2. **release-safety reviewer** — checks human gates, irreversible retries, stale source conflicts, wrong-repo and downstream safety.

### Overall Assessment

- code-quality reviewer final: PASS, P0=0, P1=0, P2=0 —
  `.tad/evidence/reviews/alex/release-runbook-capability-migration/code-quality-review.md`
- release-safety reviewer final: PASS, P0=0, P1=0, P2=0 —
  `.tad/evidence/reviews/alex/release-runbook-capability-migration/release-safety-review.md`

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ 本 handoff 的 Blake full 是迁移实施者，不因此获得运行 publish/sync 的授权。
- ⚠️ `parity --fix` 可能触及整个 skill mirror；必须在前后做路径集合差，发现无关差异立即停止。
- ⚠️ 不得用“runbook 已经有大部分内容”跳过 exact source coverage；缺口恰好在角色/授权/恢复。
- ⚠️ 不得用 carrier 的 YAML 行数或 MUST 总数证明覆盖；只认 Appendix A 的逐条语义映射。
- ⚠️ forward-test 若产生任何 live mutation，立即 FAIL，并报告具体副作用与恢复状态。

### 10.2 Known Constraints

- Phase 3b 的真实 publish+sync dogfood 被明确拆出，必须获得新的真人授权后另开契约。
- 本期不改变 alex-lite/blake-lite runtime；skill discovery/pin 的通用 runtime fixture 留后续 phase。
- full source carrier 仍保留至 Phase 8，因此本期成功只证明“可迁移”，不等于 full 已可物理删除。

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| D1 | migration bridge | Lite 临时越权 / final full bridge | final full bridge | 用户明确选择 2；不污染 Lite 权限模型 |
| D2 | target carrier | new `release-ops` / extend runbook / keep full | extend runbook | 已有真实 carrier，避免重复 skill |
| D3 | structure | one 500+ line SKILL / compact SKILL + refs | compact + 2 refs | 渐进披露，避免 full 2.0 |
| D4 | mechanical verifier | wrapper / direct existing CLI | direct existing CLI | single source of truth，避免行为漂移 |
| D5 | dogfood timing | live in build handoff / separate human-gated phase | separate Phase 3b | build验证不等于获得不可逆操作授权 |

---

## Appendix A — Must-Cover Behavior Inventory (exact 27 IDs)

| ID | Required behavior |
|----|-------------------|
| REL-01 | physical-root + exact normalized canonical-origin guard runs before publish/sync; malicious substring is rejected |
| REL-02 | skill reads current runbook/reference and obeys Lite∩Skill∩Human |
| REL-03 | plan/execute/verify roles and single task-state owner |
| REL-04 | approval scope digest atomically transitions unused→consumed-before-launch; replay/concurrent resume denied; ambiguous result reconciled before any newly approved retry |
| PUB-01 | current version and release type are derived, not remembered |
| PUB-02 | CHANGELOG and intentional dirty/unpushed scope are checked |
| PUB-03 | parity gate handles 0/1/2 separately and refuses agents-newer auto-fix |
| PUB-04 | version gate handles drift vs wiring separately |
| PUB-05 | version-sweep Layer 1 blocks and Layer 2 is advisory |
| PUB-06 | migration manifest gate handles drift vs wiring separately |
| PUB-07 | human confirms exact push/tag scope; annotated tag sequence is explicit |
| PUB-08 | post-publish remote ref/tag verification and next-step report |
| SYNC-01 | registry missing/empty and project status listing behavior |
| SYNC-02 | scope selection distinguishes outdated/specific/cancel |
| SYNC-03 | target path and installed TAD validation before writes |
| SYNC-04 | platform-specific settings/docs strategy plus both skill mirrors for every target; merge marker and backup behavior |
| SYNC-05 | sync set derives from deny-list interfaces; hardcoded tables non-authoritative |
| SYNC-06 | capability pack registry-only and no post-mirror install.sh downgrade |
| SYNC-07 | migration-engine is sole executor; exit 1/2 after copy makes target partial, stops batch and forbids advancement/commit/push |
| SYNC-08 | deprecation range semantics and zero-touch preservation |
| SYNC-09 | structural gate handles 0/1/2 separately; only verified targets advance |
| SYNC-10 | platform-skills parity gate handles 0/1/2 separately |
| SYNC-11 | optional downstream commit/push has separate human gate and scoped git add |
| SYNC-12 | summary, partial-failure recovery and registry update only after success |
| REG-01 | sync-add validates absolute path, `.tad/`, and version |
| REG-02 | sync-add detects/asks merge vs overwrite strategy and marker requirement |
| LIST-01 | sync-list reports name/path/platform/strategy/current/last/status read-only |

Exact set means exact identities, not merely `row_count == 27`.

---

**Handoff Created By:** Alex (full, one-time migration bridge)
**Date:** 2026-08-09
**Version:** 3.1.0
