
# HANDOFF: memory-redirect-capture-layer

---
task_type: mixed      # config (settings/jq) + bash script + protocol text + docs
e2e_required: no
research_required: no  # research already done: DR-20260712 + overlap matrix
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

---

## §9.1 Spec Compliance Checklist (excerpt)
### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence | Verified Output |
|-----|-------------|--------------------|-------------------|-----------------|
| AC1 | settings.local.json 仅多 autoMemoryDirectory 键;permissions **深度相等** | 前后各存 `jq -S .permissions` 快照并 diff;`jq -r '.autoMemoryDirectory'` | diff 空;值为绝对路径以 .tad/memory 结尾 | (post-impl) |
| AC2 | 迁移**内容级**完整且旧目录未动 | `diff -rq ~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory .tad/memory` 只允许 "Only in .tad/memory" 方向差异(如后续新写入);旧目录 `ls | wc -l` = 36 | diff 无 "Only in ~/.claude..." 行(36 条全到齐,内容一致);旧目录不变 | (post-impl) |
| AC3 | **SAFETY 端到端**:memory 在两处 deny-list + drift gate + sync 集排除 | ① `derive-sync-set.sh --zero-touch | grep -cx memory` ② `grep -c '"memory"\|memory' tad.sh 的 TAD_ZERO_TOUCH 块`(实现时按实际格式写精确 grep)③ `bash tad.sh --verify-denylist; echo $?` ④ `derive-sync-set.sh --dirs | grep -cx memory` | ① 1 ② ≥1 ③ 0 ④ 0 | (post-impl;基线 0/0/0(15==15)/—) |
| AC4 | 蒸馏协议纯 additive | `comm -23 <(git show HEAD:.claude/skills/alex/references/distillation-loop-protocol.md | sort -u) <(sort -u 同文件) | wc -l`;`grep -c '^## Step'`;`grep -c '^## Second Capture Source'` | 0(无删除行);7;1 | (post-impl) |
| AC5 | CLAUDE.md §7.5 + runbook gotcha 均 additive | `grep -c 'Memory Capture Layer' CLAUDE.md`;`grep -c 'memory-redirect' .claude/skills/release-runbook/SKILL.md`;两文件同法 comm 删除侧 = 0 | ≥1;≥1;0/0 | (post-impl) |
| AC6 | .agents parity PASS | `bash .tad/hooks/lib/release-verify.sh parity` | PASS/0 drift | (post-impl) |
| AC7 | 脚本健壮 + 幂等 | `bash -n`;`--status` exit 0;二次 `--enable` 后 AC1/AC2 复跑仍 PASS;`--revert` 后 `jq -r '.autoMemoryDirectory'` = ABSENT 且 permissions 不变(测完重新 --enable) | 全部如述 | (post-impl) |
| AC8 | **实测重定向生效 + 负向检测** | Gate 4 人工:新会话(接受 trust dialog)存一条测试 memory → `ls -t .tad/memory | head -3` 出现新文件;**且旧目录文件数仍 36(负向:确认没有静默写回老家)** | 新文件在 .tad/memory/;旧目录 36 不变 | (Gate 4 human-verified) |
| AC9 | 变更范围如计划(判别性)| `git status --short` 逐行对照 §7 表:每个改动行必须能映射到 §7 的一行;§7 中 MODIFY 的 git-tracked 文件必须全部出现在 diff 中;出现表外文件 = FAIL | 一一映射,无表外条目 | (post-impl) |
| AC10 | **敏感隔离(SEC P0-1)** | 分级报告存在且 36 行全覆盖;对报告中每个 SENSITIVE 文件 `git check-ignore <file>; echo $?` = 0;对 tracked 的 memory 文件 `git ls-files .tad/memory | xargs grep -lEi '@[a-z0-9.-]+\.(edu|com|org)|api[_-]?key|password'` = 空 | 全部通过;user_* 无一 tracked | (post-impl) |

⚠️ AC8 falsification → 执行 T8 回退,不硬编 workaround。

### 9.2 Expert Review(Gate 2 audit trail)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: tad.sh 重复硬编码 TAD_ZERO_TOUCH,只改 lib → release drift FAIL;AC3 原版测不出 | §6 T2b/T2c + AC3③(--verify-denylist 门) | Resolved |
| code-reviewer | P1-1: find -newer 在无 cursor 首跑硬报错 | §6 T4 第 2 点(显式 [ -f cursor ] 分支) | Resolved |
| code-reviewer | P1-2: AC8 证伪后留下半套配置无回退 | §6 T8 + 脚本 --revert + AC7 | Resolved |
| code-reviewer | P1-3: AC9 无判别力 | AC9 重写(逐行映射 §7 表) | Resolved |
| code-reviewer | P1-4: jq merge 仅比 keys 不够 | AC1 深度相等(jq -S .permissions diff) | Resolved |
| code-reviewer | P2×5(pipefail 注释/命名等) | 采纳进 T1 伪代码;其余 Blake 酌情 | Deferred(P2) |
| security-auditor | P0-1: public repo commit 36 条含个人画像/敏感引用 → 泄露;无内容扫描 AC | §6 T3a/T3b(分级+gitignore)+ AC10 + D1 修订(Gate 4 用户确认) | Resolved |
| security-auditor | P0-2: AC3 只测单一粒度,tad.sh 内联列表/drift gate/实际排除未验 | §6 T2(先于迁移执行)+ AC3 四断言端到端 | Resolved |
| security-auditor | P1-1: cp -n 部分拷贝,count-floor AC 抓不到 | AC2 改 diff -rq 内容级 | Resolved |
| security-auditor | P1-2: trust dialog 被拒 → 静默写回老家无检测 | AC8 增负向检测(旧目录计数不变) | Resolved |
| security-auditor | P1-3: SLUG sed 推导脆弱无预检 | T1 脚本 OLD_DIR 存在性 preflight + 实证提示 | Resolved |
| security-auditor | P1-4: permissions 深度相等 | AC1(同 CR P1-4) | Resolved |
| security-auditor | P2×4(pre-publish 复扫等) | T5b runbook gotcha 行涵盖复扫;其余 Deferred | Partially Resolved(P2) |

---

## 10. Important Notes

---

## §6 Implementation Steps (head)
## 6. Implementation Steps(Micro-Tasks — **按序执行,T2 必须在 T3 之前**)

### T2: zero-touch 三粒度保护(SAFETY — 先于迁移,防止任何窗口期数据外流)[CR P0-1 / SEC P0-2]

a. `.tad/hooks/lib/derive-sync-set.sh`:ZERO_TOUCH 列表加 `memory`(只加一词)。
b. `tad.sh`:**同步修改重复的硬编码 `TAD_ZERO_TOUCH` 列表**(L207-216 附近)加 `memory`,并按 L200-204 头部注释要求更新配套 count 注释(如有)。
c. 验证 drift gate:`bash tad.sh --verify-denylist` → exit 0(set-equality lib==tad.sh)。
d. 其余 4 个 flag 消费者(release-verify.sh / migration-engine.sh / migration-draft.sh 等)读 `--zero-touch` flag 单一事实源,自动继承——**不要**去改它们(code-reviewer 已验证)。

### T1: 创建 `.tad/hooks/lib/memory-redirect.sh`(新文件)

```bash
#!/usr/bin/env bash
# memory-redirect.sh — point Claude Code auto-memory at .tad/memory/ (TAD Capture layer)
# Usage: --enable | --status | --revert    (run from project root)
# DR-20260712 verdict 1. NO hooks registered — plain CLI tool (principles.md 2026-04-15).
set -euo pipefail

MODE="${1:---status}"
# Guard: must run from a TAD project root [SEC P2 run-from-root]
[ -f .tad/config.yaml ] || { echo "ERROR: run from TAD project root (.tad/config.yaml not found)"; exit 1; }
ROOT="$(pwd)"
LOCAL_SETTINGS=".claude/settings.local.json"
TARGET_DIR="$ROOT/.tad/memory"
# Claude Code derives the per-project dir by replacing '/' and ' ' with '-'
SLUG="$(printf '%s' "$ROOT" | sed 's![/ ]!-!g')"
OLD_DIR="$HOME/.claude/projects/$SLUG/memory"

status() {
  echo "project: $ROOT"
  echo "old native dir: $OLD_DIR ($(ls "$OLD_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "target dir:     $TARGET_DIR ($(ls "$TARGET_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "autoMemoryDirectory: $(jq -r '.autoMemoryDirectory // "ABSENT"' "$LOCAL_SETTINGS" 2>/dev/null || echo "no settings.local.json")"
}

enable() {
  command -v jq >/dev/null || { echo "ERROR: jq required"; exit 1; }
  # SLUG preflight: hard-verify derivation against reality [SEC P1-3]
  if [ ! -d "$OLD_DIR" ]; then
    echo "WARN: derived old dir not found: $OLD_DIR"

---

## §9.2 Expert Review Audit Trail

---


# COMPLETION: memory-redirect-capture-layer

---
task_id: TASK-20260712-001
handoff: HANDOFF-20260712-memory-redirect-capture-layer.md
date: 2026-07-12
gate3_verdict: pass
git_commit: 7fbe24e
---

# Completion Report — memory-redirect-capture-layer

**From:** Blake (Agent B) | **Task:** TASK-20260712-001 | **Commit:** `7fbe24e` (main, NOT pushed)

## 1. Summary

Native auto-memory redirected to `.tad/memory/` (Capture layer, DR-20260712 verdict 1). All 8
micro-tasks executed in the mandated order (T2 SAFETY deny-lists BEFORE T3 migration — zero
exposure window). 36 memories migrated content-complete; sensitivity triage isolated 7 SENSITIVE
files from the public repo; distillation protocol gained the Second Capture Source section purely
additively. T8 rollback path implemented and round-trip tested.

## 2. AC Results (§9.1)

| AC | Result | Evidence (raw source + line) |
|----|--------|------------------------------|
| AC1 | ✅ PASS | AC-01 script: permissions deep-equal (diff of `jq -S .permissions` before/after = empty); `autoMemoryDirectory=/Users/sheldonzhao/01-on progress programs/TAD/.tad/memory` |
| AC2 | ✅ PASS | AC-02 script: `diff -rq` old↔new 0 missing-from-target; old dir `ls | wc -l` = 36 untouched |
| AC3 | ✅ PASS | AC-03 script: lib grep -cx memory = **1**; tad.sh TAD_ZERO_TOUCH block = **1**; `tad.sh --verify-denylist` exit **0** ("16 entries" set-equality); `--dirs` exclusion = **0** |
| AC4 | ✅ PASS | AC-04 script: comm deletion-side = **0**; `grep -c '^## Step'` = **7**; new section = **1** |
| AC5 | ✅ PASS | AC-05 script: CLAUDE.md hit=1, runbook hit=1, comm deletions 0/0 |
| AC6 | ⚠️ PARTIAL (scope PASS) | Both handoff-scope mirrors byte-identical (`cmp` clean). Global `release-verify.sh parity` exit 1 — caused by a CONCURRENT terminal building mobile-*/hw-* packs (moving target, "agents-newer STOP"). See Friction table. **Global parity must re-run PASS before *publish.** |
| AC7 | ✅ PASS | AC-07 script: bash -n / --status exit 0 / 2nd --enable idempotent (AC1+AC2 re-pass) / --revert removes key with permissions byte-identical / re-enabled |
| AC8 | ⏳ Gate-4 human | New-session test: save a memory → appears in `.tad/memory/` AND old dir stays 36 (negative check). Falsification → T8 (`--revert` tested working) |
| AC9 | ✅ PASS | AC-09 script vs actual commit: all **52** committed paths map to §7/Evidence-Manifest; all 7 §7-MODIFY tracked files present; 2 out-of-scope pre-staged index entries from another terminal explicitly EXCLUDED via pathspec commit |
| AC10 | ✅ PASS | AC-10 re-run post-staging (non-vacuous, 29 files in index): report 36 rows; 7 SENSITIVE all `git check-ignore`=0; 0 `user_*` tracked; 0 credential-pattern hits. security-auditor independently re-read all 29 SAFE files: zero misclassification |

AC scripts: `.tad/evidence/acceptance-tests/TASK-20260712-001/` (all standalone, re-runnable).

## 3. Layer 2 Expert Review (3 distinct reviewers — mixed tier ≥2 satisfied)

| Reviewer | Verdict | Findings |
|----------|---------|----------|
| spec-compliance-reviewer | PASS | NOT_SATISFIED=0, PARTIAL=2 (AC6 global parity, AC9 pre-commit state — both resolved/explained above); re-ran all AC scripts live; confirmed T2-before-T3 order via mtime chain |
| code-reviewer | PASS | P0=0, P1=0, P2=6 (all Deferred, listed in report); blast radius confirmed: release-verify.sh:126 + migration-engine.sh:135 inherit `memory` via --zero-touch flag, zero edits needed |
| security-auditor | PASS | critical=0, high=0; independently re-derived the 36-file triage — zero SAFE misclassifications; jq/quoting/mktemp audit clean |

Evidence: `.tad/evidence/reviews/blake/memory-redirect-capture-layer/{spec-compliance-review,code-review,security-audit}.md`

## 4. File Manifest & Provenance

| File | Action | Generated by |
|------|--------|--------------|
| .tad/hooks/lib/derive-sync-set.sh | MODIFY (+memory, counts 10→11/15→16) | direct Edit |
| tad.sh | MODIFY (+memory in TAD_ZERO_TOUCH) | direct Edit |
| .tad/hooks/lib/memory-redirect.sh | CREATE | direct Write (handoff §6 T1 pseudocode, reviewed by Gate 2) |
| .claude/settings.local.json | MODIFY (+1 key, gitignored) | `memory-redirect.sh --enable` (jq) |
| .tad/memory/ (36 files, 29 tracked) | CREATE | `memory-redirect.sh --enable` (cp -n from native dir) |
| .gitignore | MODIFY (sensitive isolation section + `.agents/skills/local/` guard) | direct Edit |
| .tad/evidence/memory-migration-sensitivity-report.md | CREATE | direct Write (mechanical grep + LLM per-file judgment) |
| .claude/skills/alex/references/distillation-loop-protocol.md | MODIFY (additive section) | direct Edit |
| CLAUDE.md | MODIFY (§7.5) | direct Edit |
| .claude/skills/release-runbook/SKILL.md | MODIFY (gotcha 12) | direct Edit |
| .agents mirrors (×2) | SYNC | `release-verify.sh parity --fix .` |

## 5. Implementation Decisions (Made During Execution)

| # | Decision | Context | Chosen | Escalated? |
|---|----------|---------|--------|------------|
| 1 | `.agents/skills/local/` leak mitigation | parity --fix rsynced gitignored local/ scaffolds into the TRACKED .agents tree (public repo) | rm dir + add `.agents/skills/local/` to .gitignore (mirrors existing .claude rule); parity-tool root fix deferred to Alex | No (reversible, mirrors existing rule; surfaced here + Alex message) |
| 2 | AC6 under concurrent-terminal drift | Global parity gate unpassable while another terminal builds packs | Scope-level byte-identity (cmp ×2) as EQUIVALENT_SUBSTITUTE; global re-run required pre-*publish | No (friction protocol applied, documented) |
| 3 | Commit strategy vs shared index | Other terminal had 2 entries pre-staged; plain commit would sweep them in | `git commit -- <pathspec>` (52 paths); riders left staged untouched | No (protective, no behavior change for other workstream) |
| 4 | Runbook gotcha numbering | Heading says "Top 11"; changing it would violate AC5's comm deletion-side=0 | Appended item 12 WITHOUT touching the heading line (AC constraint wins; cosmetic mismatch noted) | No |
| 5 | MEMORY.md classified SENSITIVE | Index hooks reproduce user-profile + seed-idea + leaked-source substance; ledger absorbs future one-liners un-triaged | SENSITIVE, per-file gitignore entry (conservative rule 宁多勿漏) | No (Gate 4 human reviews all 7 classifications) |
| 6 | CLAUDE.md §7.5 placement | "§7 之后" is ambiguous vs the TAD:PROJECT-CONTENT-BELOW marker | Placed above the marker (framework section) with the handoff's exact text; note for Alex: if CLAUDE.md-merge syncs this section downstream, "已重定向" is only true after their opt-in (text already carries the opt-in line) | No (flagged for Gate 4) |

## 6. Friction Status

| Friction | Status | Detail |
|----------|--------|--------|
| Global parity gate vs concurrent workstream | EQUIVALENT_SUBSTITUTE | Original: `release-verify.sh parity` PASS. Unavailable: another terminal actively mutating .claude/skills (direction detect STOP). Substitute: `cmp` byte-identity of both in-scope mirrors (equivalent duty for THIS handoff's changes; independence preserved — spec-compliance reviewer verified). Evidence: AC-06 script output + /tmp/ac6-global.txt. **Required: re-run global parity → PASS before *publish.** |
| Opus classifier quota outage (mid-run) | READY (resolved) | One Bash call blocked temporarily; user confirmed quota restored; command re-run identical |
| workspace trust dialog (AC8) | READY (pending human) | One-time accept in the new session; negative check (old dir stays 36) covers silent-rejection case |

No BLOCKED rows.

## 7. Evidence Checklist (required)

- [x] Expert reviews (Gate 2): .tad/evidence/handoff-reviews/20260712-memory-redirect-{code-reviewer,security-auditor}.md
- [x] Blake Layer-2 reviews (slug contract): .tad/evidence/reviews/blake/memory-redirect-capture-layer/ (3 files)
- [x] Sensitivity report: .tad/evidence/memory-migration-sensitivity-report.md
- [x] AC scripts + outputs: .tad/evidence/acceptance-tests/TASK-20260712-001/ (10 scripts)
- [x] Git commit: 7fbe24e (pathspec-scoped, not pushed)
- [x] Journal: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md

## 8. Knowledge Assessment

**是否有新发现？** ✅ Yes
Journal entry added: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md
(7 raw findings: parity-mirrors-gitignored-local defect; parity race vs concurrent terminals;
shared-index pathspec-commit protection; index/ledger files inherit max sensitivity of what they
summarize; credential-grep false-positive profile; git-index-reading ACs are vacuous pre-staging;
SLUG rule confirmation.)

**Q2 可复用工作模式？** No: not-already-captured gate fails — the sensitivity-triage flow is now
captured in the report's rules + runbook gotcha 12; remaining material is journal-tier.
Skillify Candidate row: **No: not-already-captured**.

**Q3 workflow 模式？** Defect in existing TOOL (not .workflow.js): `release-verify.sh parity --fix`
(a) mirrors gitignored `.claude/skills/local/` into the tracked .agents tree, (b) has no guard
against concurrent-modification races. Recorded for Alex to create a bugfix handoff during *accept.

## 9. Reflexion History

无 reflexion(Layer 1 一次通过 — AC suite green on first full run)。
(The two mid-run anomalies — parity usage-arg retry and the global-parity concurrent drift — were
not Layer-1 check failures; the latter is recorded as friction, not reflexion.)

## 10. Notes for Alex (Gate 4)

1. **AC8 human verify**: new session in this repo → accept trust dialog if shown → save a test
   memory → `ls -t .tad/memory | head -3` shows it AND old dir still 36. Falsified → T8 revert.
2. **D1 修订确认**: all-in-git → selective-git (7 SENSITIVE gitignored) — user must confirm.
3. **Sensitivity triage review**: 7 SENSITIVE calls (esp. MEMORY.md + feedback_share-mode-and-deflation
   + project_tad-universal-method — conservative judgment calls) in the report.
4. **Global parity re-run** at a quiet moment (other terminal done) → must PASS before *publish.
5. **Parity tool bugfix handoff** (local/ exclusion + concurrency guard) — from Q3.
6. First distillation full-sweep of 36 memories via the new Second Capture Source will be heavy (expected).

---


# REVIEW: code-review.md

# Code Review — memory-redirect-capture-layer (TASK-20260712-001)

**Reviewer:** code-reviewer (Blake-tier, second perspective)
**Date:** 2026-07-12
**Scope:** narrow — memory-redirect.sh, deny-list edits (lib + tad.sh), .gitignore, CLAUDE.md, distillation-loop-protocol.md (+ .agents mirror), release-runbook SKILL.md (+ .agents mirror), 8 AC scripts, sensitivity report. Handoff §6/§9.1/§10 conformance.

## VERDICT: PASS

P0 = 0 | P1 = 0 | P2 = 6 (≤10). Pass criteria met.

---

## What was verified live (not paper)

- `bash tad.sh --verify-denylist` → exit 0, "tad.sh inlined DENY_LIST == derive-sync-set.sh (16 entries)". Set-equality drift gate holds after adding `memory` to BOTH lists.
- All 8 automated ACs run green: AC1 (permissions deep-equal, autoMemoryDirectory=absolute path ending `.tad/memory`), AC2 (0 missing-from-target, old dir=36 untouched), AC3 (lib=1 tadsh=1 gate_exit=0 dirs=0), AC4 (deletions=0 steps=7 newsection=1), AC5 (additive both docs), AC6 (both mirrors byte-identical via `cmp`), AC7 (syntax/status/idempotent-enable/revert-roundtrip), AC10 (36 rows, 7 SENSITIVE ignored, 0 user_* tracked, 0 credential hits).
- Blast radius confirmed clean: `release-verify.sh` and `migration-engine.sh` both read `derive-sync-set.sh --zero-touch` as sole authority (`migration-engine.sh:135`, `release-verify.sh:126`) — they inherit `memory` with zero edits, exactly as handoff T2d claims. `harvest-scan.sh`'s `skillify-candidates` reference is a path literal, not a deny-list — correctly untouched.
- `derive-sync-set.sh --dirs` uses `ls -d .tad/*/` (filesystem walk), so `.tad/memory/` (currently untracked on disk) is enumerated but correctly excluded by the deny-list regex → protected regardless of git-tracked status.
- §10 constraints honored: settings.json NOT touched (only settings.local.json gained exactly 1 key via jq merge; permissions byte-identical to the pre-change baseline snapshot); no hooks registered anywhere; `.tad/memory/` written only by the one-time migration cp.
- gitignore isolation genuinely works: `git add -n .tad/memory/` stages exactly the 29 SAFE files and excludes all 7 SENSITIVE (via `user_*` + 6 per-file entries). Direct credential grep over those 29 SAFE files returns zero hits — the property is real, not just the vacuous-set artifact noted in P2-1.

---

## P0 — none

## P1 — none

---

## P2 (6)

**P2-1 — AC10 credential/user_* assertions are vacuous in the current pre-commit state.**
`AC-10-sensitivity-isolation.sh` (credential check + `user_*`-tracked check) both iterate `git ls-files .tad/memory`, which is currently empty (`.tad/memory/` is `?? untracked` — T7 `git add`+commit hasn't run). `xargs grep` on empty stdin runs grep with no file args → 0 hits trivially; the `user_*` count is 0 trivially. The assertions only bite AFTER SAFE files are staged. I re-ran the credential grep directly against the 29 would-be-staged SAFE files and it is genuinely clean, and `git check-ignore` (the other half of AC10) is independent of staging and does hold — so isolation is truly enforced. Fix: in AC10, assert `git ls-files .tad/memory | wc -l -ge 1` (or run against `git add -n` output) so the credential check cannot pass on an empty set.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-10-sensitivity-isolation.sh:16-18`.

**P2-2 — `--enable` no-settings-file branch writes a permissions-less settings.local.json.**
`memory-redirect.sh:37` else-branch emits `{ "autoMemoryDirectory": ... }` only. Correct for a truly absent file (no data loss — guard is `[ -f ... ]`), but a downstream project that later relies on this file existing gets one with no `permissions` block. Non-defect here (main repo has the file); fix for downstream robustness: seed `{"permissions":{"allow":[]},"autoMemoryDirectory":...}` or document that the else-branch is greenfield-only.
File: `.tad/hooks/lib/memory-redirect.sh:36-38`.

**P2-3 — migration cp copies MEMORY.md into the target, then relies on gitignore to hide it.**
`memory-redirect.sh:40` `cp -n "$OLD_DIR"/*.md` includes `MEMORY.md`. It lands in `.tad/memory/MEMORY.md` (confirmed on disk) and is correctly gitignored, but the native runtime also owns/regenerates MEMORY.md in the target dir — copying the stale one in is harmless-but-redundant and briefly duplicates the ledger. Consider `! -name MEMORY.md` on the copy, matching the distillation scan's own exclusion.
File: `.tad/hooks/lib/memory-redirect.sh:40`.

**P2-4 — AC6 masks a real global-parity failure as "out of scope."**
`AC-06-agents-parity.sh` `cmp`s the two handoff-touched mirrors (byte-identical — good) but then runs `release-verify.sh parity`, captures exit=1, and unconditionally `exit 0` with a "concurrent workstream drift is out of handoff scope" note. The scoped assertion is legitimate, but swallowing a non-zero global-parity exit means a genuine parity regression introduced by THIS change would not fail the AC. Acceptable for this handoff (the two files it touches are proven identical), but the runbook gotcha (line 12) tells operators `--verify-denylist` must be green pre-release without an equivalent parity gate. Recommend surfacing the global exit as a WARN with the specific drifting paths listed, so a reviewer can confirm none are memory-related.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-06-agents-parity.sh:6-8`.

**P2-5 — AC3 clause B grep pattern is loosely anchored.**
`grep -cx 'memory\|memory"'` inside the `sed`-extracted `TAD_ZERO_TOUCH` block returns 1 (correct today). The alternation `memory"` guards the last-line-with-trailing-quote case, but `-x` (whole-line) plus the `sed` range end `/"$/` means the closing `memory"` line is the block terminator — it works, but is fragile if the block is ever reordered so `memory` is not last. Minor; a `grep -c '^memory"\?$'` would be equally terse and order-independent.
File: `.tad/evidence/acceptance-tests/TASK-20260712-001/AC-03-safety-end-to-end.sh:5`.

**P2-6 — `.gitignore` per-file SENSITIVE entries are unanchored basenames.**
Entries like `.tad/memory/reference_claude-code-source.md` are exact paths (good), but `.tad/memory/user_*` plus 6 explicit files hard-code the current triage. If a future migrated memory is SENSITIVE but doesn't match `user_*` and isn't hand-added, it would be tracked. The runbook gotcha (line 12) does mandate a pre-`*publish` re-scan, which is the compensating control — so this is an accepted residual, not a defect. Flagged only so the human Gate-4 reviewer knows the ignore list is a point-in-time snapshot, consistent with the report's own "Gate 4 human review item" caveat.
File: `.gitignore:63-69`, `.tad/evidence/memory-migration-sensitivity-report.md:11`.

---

## Handoff conformance notes

- AC4 additive check passes with `## Step` count = 7 preserved and exactly 1 new `## Second Capture Source` section; `comm` deletion side = 0. alex/SKILL.md body untouched (circular-trigger principle respected — new section lives in references/, triggered by the already-known `*accept` event, non-circular). Correct.
- Distillation section's READ-ONLY contract (never edit/delete `.tad/memory/`) is consistent with the script's only-write-being-one-time-cp; cursor lives in `.tad/evidence/` not the memory dir. Contract coherent.
- D1 revision ("selective git, not all-in") is correctly flagged in the handoff as a Gate-4 human-confirm item (public-repo sensitivity). The sensitivity report's 7-SENSITIVE / 29-SAFE split and its "verify before *publish" caveat are the right posture for a public repo; final SENSITIVE/SAFE adjudication is a human-domain call per project principles (AI/Human Judgment Domain Awareness) and is correctly deferred to Gate 4, not asserted as machine-final.
- `set -euo pipefail`, consistent quoting of the space-containing `$ROOT`/`$OLD_DIR`/`$TARGET_DIR`, `mktemp`+`mv` atomic-ish jq writes, and idempotent `. + {autoMemoryDirectory}` merge / `del(...)` revert are all sound. `--revert` on absent file exits 0 cleanly; `--enable` with no old dir warns and proceeds redirect-only.

---


# REVIEW: security-auditor.md

# Security Audit — Memory Redirect Capture Layer (TASK-20260712-001)

**Auditor:** security-auditor (Blake Layer 2, independent)
**Date:** 2026-07-12
**Repo:** github.com/Sheldon-92/TAD (PUBLIC)
**Scope:** Sensitivity triage of 36 migrated memory files; .gitignore isolation; memory-redirect.sh injection/quoting; handoff §9.1 AC10 contract.
**Pass criteria:** critical (P0) = 0, high (P1) = 0.

---

VERDICT: PASS

---

## Executive Summary

The #1 audit target — the SAFE/SENSITIVE triage that decides what gets published to a public repo — is **correct**. I independently read all 29 files git would commit and re-derived the classification. Zero misclassifications: no emails, no credentials/tokens/keys, no personal identity, no verbatim private conversations, no unpublished non-TAD product strategy leaked in the 29 SAFE files. All 7 SENSITIVE files are provably git-ignored. The isolation mechanism is verified at the `git check-ignore` and `git add -n` level (ground truth, not paper). The shell script has no injection or path-quoting vulnerability and cannot clobber unrelated settings keys.

- **P0 (critical): 0**
- **P1 (high): 0**
- **P2 (hardening): 4**

---

## Target 1 — Sensitivity Triage (the #1 target)

### Method
Read all 29 files in `git status --porcelain -uall .tad/memory/` (the exact set git sees as untracked-committable). Re-derived SAFE/SENSITIVE per the report's R1–R4 rules, hunting for: emails, tokens/keys, personal identity, private third-party material, unpublished non-TAD product strategy, verbatim private conversations.

### Ground-truth verification (not paper)
```
git add -n .tad/memory/  → exactly the 29 SAFE files, none of the 7 SENSITIVE
git check-ignore <each of 7 SENSITIVE>  → all 7 IGNORED
git ls-files .tad/memory/  → empty (nothing committed to history yet; clean slate)
```

### Credential / email / identity sweep across all 29 SAFE files
Pattern set: `zhaos948|newschool|@gmail|@outlook|@qq.com|api_key|secret_key|-----BEGIN|ghp_|sk-…|xox[baprs]-|password[:=]`
**Result: zero hits.** The 4 mechanical grep hits noted in the report ("token cost", "header-token" CSP term, "token-burn", "args") are confirmed false positives — all are LLM-token or design-vocabulary usages, no credentials.

### Verbatim-conversation / home-path / friend-detail sweep across all 29 SAFE files
Pattern: `/Users/sheldonzhao|朋友|friend|co-thinking|SEED.md|leaked|泄露|newschool`
**Only one hit**, in `project_pack-quality-leveling-epic.md` line 43:
> 另：独立的"纯 skills 包给朋友"方向见 [[IDEA-20260613-tad-opt-in-mode-posture 文件内 Notes]]（未启动）

This is a bare direction-label ("a pure-skills pack for friends" idea, not started) with **no personal identity, no name, no private detail about any individual**. It is a TAD-scoped roadmap cross-reference. This matches the triage's own stated rationale for file #24 ("朋友" mention is a cross-reference to an idea name, no personal identity). **Correctly SAFE.** No re-classification needed.

Notably, the two SENSITIVE files that carry the actual private material — `project_co-thinking-workshop-seed.md` (contains the absolute home path `/Users/sheldonzhao/01-on progress programs/co-thinking-workshop/SEED.md` and the unpublished sibling-methodology core) and `project_tad-universal-method.md` (unpublished standalone-product strategy + "user's friends only use Codex, non-dev projects" personal context) — are both correctly gitignored, and **no SAFE file reproduces their sensitive content**. The wikilink references to them in SAFE files (`[[project_tad-universal-method]]`, `[[user_agent-builder-goals]]`) are just bracketed names; they leak the existence of a parked idea but no substance.

### Per-file re-classification of the 29 SAFE files
All 29 are TAD-framework-internal engineering records: Epic completion notes, pack build records, workflow/tooling lessons, TAD process/communication rules, and research methodology. None contain third-party private material or personal profile. Representative spot-checks:
- `feedback_no-sync-pull-based.md` — mentions the public repo install command `npx github:Sheldon-92/TAD` (already public) and a downgrade incident; framework-internal. SAFE.
- `feedback_plain-language-after-handoffs.md` / `plain-language-quality.md` — quote the user's *stated preference about communication style* ("我把内容交给 Blake…我还可以看一下你是怎么思考的"). This is a workflow-preference statement about the TAD tool itself, not a private third-party conversation or sensitive personal disclosure. Consistent with the triage's SAFE call for these (contrast with `feedback_share-mode-and-deflation.md`, which the triage conservatively marked SENSITIVE for carrying *interaction-style profiling* — a defensible finer-grained line). SAFE.
- `project_codex-adapter-validation.md`, `project_tad-next-direction.md`, `project_capability-packs.md` — TAD's own public-facing direction/architecture, already reflected in tracked OBJECTIVES/NEXT. SAFE.

**Conclusion: triage is correct. 0 misclassified-SAFE files.**

---

## Target 2 — .gitignore Isolation Robustness

Added block (additive, at end of .gitignore):
```
.tad/memory/user_*
.tad/memory/MEMORY.md
.tad/memory/feedback_share-mode-and-deflation.md
.tad/memory/project_co-thinking-workshop-seed.md
.tad/memory/project_tad-evolution-directions.md
.tad/memory/project_tad-universal-method.md
.tad/memory/reference_claude-code-source.md
```

Verified:
- All 7 SENSITIVE files → `git check-ignore` returns 0 (ignored). ✅
- `user_*` glob is future-proof: a hypothetical new `user_something-new.md` is caught (`.gitignore:62` matches). ✅ — this covers the R1 `type: user` class going forward without re-triage.
- `MEMORY.md` explicit entry covers the native ledger, which auto-absorbs future one-liner memories with no re-triage — correctly kept out of git. ✅
- The 5 per-file SENSITIVE entries are exact-path; no glob gap.

**Residual gap (P2, not P1):** The 6 non-`user_` SENSITIVE files are pinned by exact filename. A *newly created* SENSITIVE memory that is NOT `user_*`-prefixed (e.g. a future `reference_*` leaked-source analysis, or a `project_*` unpublished-strategy note) would default to SAFE/committable and require manual re-triage. This is inherent to a deny-list of individually-named files and is explicitly acknowledged by the handoff (T3d + runbook gotcha: pre-`*publish` re-scan is mandatory; push is out of scope for this handoff). Because push is gated behind a required re-scan, this does not rise to P1. See P2-1.


---


# REVIEW: spec-compliance-reviewer.md

# Spec Compliance Review — HANDOFF-20260712-memory-redirect-capture-layer

**Reviewer:** spec-compliance-reviewer (independent sub-agent)
**Date:** 2026-07-12
**Scope:** Handoff §6 / §7 / §9.1 vs actual working-tree implementation. All AC scripts in
`.tad/evidence/acceptance-tests/TASK-20260712-001/` were RE-RUN live by this reviewer (not
trusted from Blake's claims), plus supplementary independent checks.

VERDICT: PASS

(NOT_SATISFIED = 0; PARTIALLY_SATISFIED = 2 ≤ 3; AC8 = N/A-Gate4)

---

## Per-AC Classification

| AC | Description | Classification | Evidence (re-run by reviewer) |
|----|-------------|----------------|-------------------------------|
| AC1 | settings.local.json +1 key only; permissions deep-equal | **SATISFIED** | Re-ran AC-01: PASS. `jq -S .permissions` diff vs before-snapshot empty; `autoMemoryDirectory=/Users/sheldonzhao/01-on progress programs/TAD/.tad/memory` (absolute, ends `.tad/memory`). Before-snapshot exists at `.tad/evidence/ralph-loops/TASK-20260712-001-ac1-permissions-before.json`. |
| AC2 | Content-level complete migration; old dir untouched (36) | **SATISFIED** | Re-ran AC-02: PASS. `diff -rq` old→target: 0 "Only in <old>" lines; old dir count = 36. Correct direction-scoped diff (not a count floor), per SEC P1-1 resolution. |
| AC3 | SAFETY end-to-end: memory in BOTH deny-lists + drift gate + sync-set exclusion | **SATISFIED** | Re-ran AC-03: PASS (lib=1, tadsh=1, `tad.sh --verify-denylist` exit 0, `--dirs | grep -cx memory`=0). Verified diffs directly: `derive-sync-set.sh` ZERO_TOUCH +memory with count comments updated 10→11 / 15→16; `tad.sh` TAD_ZERO_TOUCH +memory (no separate count comment exists near it — "如有" satisfied). All four assertions hold, including the load-bearing exclusion assertion. |
| AC4 | Distillation protocol purely additive | **SATISFIED** | Re-ran AC-04: PASS (comm deletions=0, `^## Step`=7, `^## Second Capture Source`=1). Diff confirms the new section is inserted immediately before `## Anti-Theater`, content matches handoff T4 text verbatim incl. the explicit `[ -f cursor ]` first-run branch (CR P1-1). alex/SKILL.md body untouched (not in diff). |
| AC5 | CLAUDE.md §7.5 + runbook gotcha both additive | **SATISFIED** | Re-ran AC-05: PASS (claude=1, runbook=1, comm deletion-side 0/0). CLAUDE.md gains only §7.5 block; runbook SKILL.md gains only gotcha #12 (covers double-list + pre-publish re-scan + downstream opt-in, matching T5b). |
| AC6 | .agents parity PASS | **PARTIALLY_SATISFIED** | Both handoff-scope mirrors verified byte-identical by `cmp` (distillation-loop-protocol.md + release-runbook/SKILL.md — the latter sanctioned by T6 "若 runbook 也有镜像一并同步"). Global `release-verify.sh parity` exits 1, but the drift is `mobile-testing/SKILL.md` etc. — a CONCURRENT terminal's mobile-*/hw-* pack build, outside this handoff. Honest call: the AC as WRITTEN ("parity PASS/0 drift") does not pass globally, so this cannot be marked fully SATISFIED; the handoff's intent (this change introduced zero drift) IS met. **Required follow-up: global parity must be re-run and PASS before *publish, after the concurrent workstream lands.** |
| AC7 | Script robust + idempotent + revert round-trip | **SATISFIED** | Re-ran AC-07 live: PASS. `bash -n` clean; `--status` exit 0; 2nd `--enable` idempotent (AC1+AC2 re-pass after); `--revert` removes key with permissions unchanged; re-enabled after test. Script matches T1 pseudocode incl. SLUG preflight (SEC P1-3), quoted expansions for the space-containing path, no hooks registered. |
| AC8 | Live redirect + negative detection (old dir stays 36) | **N/A-Gate4** | Declared Gate-4 human-verified in the handoff (requires a NEW session + trust dialog — cannot be machine-verified by this reviewer). T8 rollback path exists (`--revert`, tested via AC7) if falsified. Old-dir count currently 36 (consistent). |
| AC9 | Change scope maps 1:1 to §7 table | **PARTIALLY_SATISFIED** | All handoff-produced changes map to §7 (see mapping below); no unmapped handoff-produced file found. BUT the commit (T7) has not yet been made, so the discriminative check is prospective, and two hazards must be handled at commit time: (1) **the git index ALREADY contains two staged out-of-scope entries from another workstream** (`M .tad/hooks/post-write-sync.sh`, `A .tad/tests/detect-state-fixture.sh`) — a plain `git commit` after `git add <scope>` would sweep them in and violate AC9; Blake must unstage them or commit with an explicit pathspec. (2) `.gitignore` contains one addition beyond the T3b sensitive-isolation section: `.agents/skills/local/` mirror-protection rule — additive, defensible as a T6 `parity --fix` wholesale-rsync safeguard, but it is scope-plus vs §6/§7 and should be named in the COMPLETION report. Pre-existing dirty files (brain-index, OBJECTIVES, NEXT, SURPLUS-*, hw-*/mobile-*) are other workstreams and correctly excluded from Blake's staging plan. |
| AC10 | Sensitive isolation (SEC P0-1) | **SATISFIED** | Re-ran AC-10: PASS (36 report rows; all 7 SENSITIVE files `git check-ignore` = 0; 0 `user_*` tracked). Note: the script's tracked-file credential grep is currently VACUOUS (`git ls-files .tad/memory` = 0 — nothing staged yet). Reviewer ran a NON-vacuous direct scan of all 29 non-ignored files: 0 credential/email-pattern hits. Report quality is high: per-file frontmatter type + class + reason, mechanical-scan hits individually adjudicated as false positives, email-specific sweep documented, MEMORY.md itself conservatively classed SENSITIVE (index embeds user-profile/seed/leaked-source hooks) — beyond the minimum, consistent with 宁多勿漏. **AC-10 should be re-run after `git add` so the tracked-file assertion is exercised non-vacuously.** |

---

## §6 Execution-Order & Completeness Audit

- **T2 BEFORE T3 (SAFETY ordering)**: HONORED. Artifact mtimes: `derive-sync-set.sh` (…748) < `tad.sh` (…749) < `memory-redirect.sh` (…788) < `.tad/memory/` (…813) < sensitivity report (…968). Deny-lists were in place before any memory data entered the repo — no exposure window. Task ledger agrees (T2 completed first).
- **T2d**: other flag consumers (release-verify.sh / migration-engine.sh / migration-draft.sh) correctly NOT modified (absent from diff) — single source of truth via `--zero-touch` flag.
- **T1**: script matches pseudocode; SLUG derivation empirically correct (old dir found with 36 files).
- **T3a report quality**: GOOD (see AC10 row). 36/36 rows, reasons specific, false positives inspected rather than rubber-stamped.
- **T3b/T3c**: gitignore per-file SENSITIVE entries + `user_*` pattern present; check-ignore verified.
- **T3d**: commit-not-push respected — nothing committed yet (T7 in progress).
- **T4 additive guardrail**: verified by line-set comm (0 deletions) + anchors (7 Steps, Anti-Theater intact).
- **T5a/T5b**: both done, additive.
- **T6**: both mirrors byte-identical; `.agents` diff contains ONLY the two handoff mirrors.
- **T7**: pending (this review is a pre-commit input to it). See AC9 staged-rider hazard.
- **T8**: rollback path implemented and live-tested (AC7 revert round-trip).
- **Nothing in §6 found skipped.**

## AC9 Mapping Detail (handoff-produced changes → §7)

| Change | §7 row |
|---|---|
| `.tad/hooks/lib/derive-sync-set.sh` (M) | T2a |
| `tad.sh` (M) | T2b |
| `.tad/hooks/lib/memory-redirect.sh` (??) | T1 |
| `.claude/settings.local.json` (gitignored, +1 key) | T3 |
| `.tad/memory/` 36 files (??, 29 trackable / 7 ignored) | T3 |
| `.gitignore` (M) | T3b (+1 scope-plus line, see AC9 note) |
| `.tad/evidence/memory-migration-sensitivity-report.md` (??) | T3a |
| `.claude/skills/alex/references/distillation-loop-protocol.md` (M) | T4 |
| `CLAUDE.md` (M) | T5a |
| `.claude/skills/release-runbook/SKILL.md` (M) | T5b |
| `.agents/skills/alex/references/distillation-loop-protocol.md` (M) | T6 |
| `.agents/skills/release-runbook/SKILL.md` (M) | T6 (sanctioned in §6 text) |
| AC scripts + ralph-loop snapshots + handoff-review files (??) | Required Evidence Manifest |

## Action Items for Blake (before/at T7 commit)

1. **P1**: Unstage or pathspec-exclude the pre-staged `post-write-sync.sh` + `detect-state-fixture.sh` before committing (AC9 rider hazard).
2. **P2**: Re-run AC-10 after `git add` so the tracked-file credential grep is non-vacuous.
3. **P2**: Record in COMPLETION: (a) global parity FAIL is external (mobile-* concurrent build) — re-run before *publish; (b) the `.agents/skills/local/` gitignore addition and its rationale.

---


# TRACE EVENTS (slug=memory-redirect-capture-layer, sorted by ts)

/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-12.jsonl:{"ts":"2026-07-12T23:04:47Z","type":"handoff_created","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260712-memory-redirect-capture-layer.md","size_bytes":21171,"slug":"memory-redirect-capture-layer"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-12.jsonl:{"ts":"2026-07-13T02:06:29Z","type":"task_completed","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/COMPLETION-20260712-memory-redirect-capture-layer.md","size_bytes":10261,"slug":"memory-redirect-capture-layer"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-12.jsonl:{"ts":"2026-07-13T02:07:55Z","type":"gate_result","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","context":"Gate 3: Gate 3","outcome":"pass","slug":"memory-redirect-capture-layer","agent":"blake"}

---

