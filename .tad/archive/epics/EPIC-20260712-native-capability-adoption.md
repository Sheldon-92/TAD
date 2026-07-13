# Epic: Native Capability Adoption Wave (B-group)

**Epic ID**: EPIC-20260712-native-capability-adoption
**Created**: 2026-07-12
**Owner**: Alex
**Source**: DR-20260712-native-capability-overlap-verdicts.md 第二轮 B 组 — 6 ideas promoted 2026-07-12
**Research base**: .tad/evidence/research/claude-native-capabilities/ (23-source notebook b07a6598 + harness introspection + overlap matrix)

---

## Objective

Adopt six Claude Code native capabilities identified by the 2026-07-12 overlap research as
pure-gain opportunities (no conflict with TAD mechanisms): mechanical pre-compaction state
snapshots, persistent reviewer memory, subagent skill preloading, cloud-scheduled weekly
GitHub scanning, AskUserQuestion previews for design comparison, and path-scoped rules.
Each phase converts one or two captured ideas into working, behaviorally-verified integrations.

## Success Criteria (human-set, 2026-07-12 Socratic round)

- **Behavioral evidence required per phase** — not structural presence. A phase is Done only
  when the capability demonstrably worked once for real (snapshot actually written on a real
  compact; reviewer actually used memory on a second review; weekly scan actually ran).
  Anti-Validation-Theater per principles.md YOLO audit entry.
- P3 degradation policy: if headless auth spike fails → degrade to local manual command +
  Alex startup staleness reminder (value kept, automation deferred). Do NOT silently drop.

## Phase Map

| # | Phase | Ideas | Status | Handoff | Key Deliverable |
|---|-------|-------|--------|---------|-----------------|
| 1 | PreCompact session-state snapshot hook | precompact-hook-session-state | ✅ Done (2026-07-13, merge abca584; AC2a/T1-content PENDING-REAL-EVENT auto-capture at next real /compact) | HANDOFF-20260712-precompact-session-state-hook | Fail-open PreCompact hook + post-compact reminder; §4.5 self-check demoted to second defense |
| 2 | Subagent frontmatter upgrades: reviewer persistent memory + skills preload | subagent-persistent-reviewer-memory, subagent-skills-preload | ✅ Done — NEGATIVE-RESULT (2026-07-13, merge bf51be4): spike proved `memory` AND `skills` frontmatter INERT on CLI 2.1.172; degraded per matrix — delivered spec-compliance-reviewer.md (project-level, shadowing=PASS) + fm-lint.sh + spike evidence. ⛔ BLOCKED-UNTIL: re-spike on CLI upgrade before any retry (E1/E2) | HANDOFF-20260713-native-capability-adoption-phase2 | Reviewer agents get `memory` dir (pattern-only content boundary, anti-anchoring) + pack preload via `skills` field replacing handoff transcription |
| 3 | Cloud-scheduled weekly GitHub registry scan | cron-revive-github-scan | ✅ Done — SPIKE PASS + PARTIAL-AUTOMATION (2026-07-13, merge 0f14d18): headless scan works end-to-end (real gh auth, last_scan null→2026-07-13, merge-write fixture-proven, today-guard md5-proven); BUT native cron = session-only + 7d expiry even with durable:true → standing weekly automation NOT deliverable on CLI 2.1.172; watchdog = STEP 3.9 staleness warnings; cron-prompt.md ready for re-registration any session | HANDOFF-20260713-native-capability-adoption-phase3 | Spike headless auth first; CronCreate weekly routine OR degraded local path |
| 4 | Interaction/context small items: AskUserQuestion preview + path-scoped rules pilot | askuser-preview-in-design, claude-rules-path-scoped | ✅ Done (2026-07-13, merge 0b947a5): preview_usage_rule + tournament wiring landed (additions-only, mirror IDENTICAL); rules spike **LOADED**（判别 token 破 @import 混淆,fire/no-fire 对称,实测裁决 GH #17204 说法不成立——paths: 语法可用）→ .claude/rules/shell-portability.md 上线（25 行/1370B,5 约束溯源）; impl review 0 P0/0 P1; 已知边界:rules 是 READ 触发,盲写新 hook 文件不加载（扩展前须正视）| HANDOFF-20260713-native-capability-adoption-phase4 | *design 2-up/tournament preview wiring + single-file .claude/rules pilot with context measurement |

### Phase Dependencies

- P1 first by human decision (protects all subsequent sessions, including this Epic's own).
- P2 merges two ideas because they edit the same file surface (.claude/agents definitions)
  under the same review lens.
- P3 independent; spike-gated (spike FAIL → degraded local variant, not cancellation).
- P4 independent; rules pilot is exploratory (measure context delta before any expansion).
- Only 1 Active phase at a time (TAD Epic rule).

### Derived Status

- **Status**: ✅ Complete | **Progress**: 4/4 (2026-07-13)

---

## Phase Details

### Phase 1: PreCompact session-state snapshot hook

**Status:** ✅ Done (2026-07-13, merge abca584 — design re-review 0 P0, impl review 0 P0/P1,
Conductor spot-check live PASS; AC2a live-compact + T1 stdin content = PENDING-REAL-EVENT,
auto-captured by built-in last-stdin.json tee at next real /compact)
**Handoff:** HANDOFF-20260712-precompact-session-state-hook.md

#### Scope
Mechanical snapshot block written into .tad/active/session-state.md before every compaction
(manual + auto), plus a post-compact SessionStart reminder to re-read it. Hook writes ONLY
mechanically-derivable state (timestamp, trigger, git branch/status, active handoffs/epics);
conversational position stays agent-maintained (Layer 1 in §4.5). Fail-open by design
(2026-04-15 principle: smoke alarm, not fire suppressor).

### Phase 2: Subagent frontmatter upgrades (reviewer memory + skills preload)

**Status:** ✅ Done — NEGATIVE-RESULT (2026-07-13, merge bf51be4). Spike: `memory`/`skills`
frontmatter INERT on CLI 2.1.172 (silently accepted, no behavior); shadowing=PASS (project-level
def fully replaces user-level). Delivered per degradation matrix: spec-compliance-reviewer.md
(first registered project-level agent) + fm-lint.sh (stdlib frontmatter lint) + full spike
evidence with raw transcripts. Impl review 0 P0/0 P1. Escalations E1-E7 recorded in completion
(key: E3 .claude/agents/ invisible to BOTH distribution paths — human decision before next
*publish, recommend main-repo-only; E6 spec-compliance model=sonnet). ⛔ BLOCKED-UNTIL CLI
upgrade re-spike for memory/skills retry — do NOT inherit "behavioral evidence satisfied" from
the green AC table (arch P2-2).

#### Scope
Add native `memory` field to standing reviewer subagents (code-reviewer, security-auditor,
spec-compliance-reviewer) with a content-boundary rule: store defect PATTERNS and project
conventions only, never past verdicts (anti-anchoring / Rubber Stamp guard). Add `skills`
field preloading matched capability packs into implementation/review agents, replacing
handoff-text transcription; compose with pack≤2 guardrail.

### Phase 3: Cloud-scheduled weekly GitHub registry scan

**Status:** ✅ Done — SPIKE PASS + PARTIAL-AUTOMATION (2026-07-13, merge 0f14d18).
Behavioral evidence real: headless `claude -p` probe ran the scan end-to-end (keyring gh auth,
last_scan null→2026-07-13, merge-write proven via seeded rejected fixture, same-day guard
proven via byte-identical md5 re-run). Deliverables: non-interactive scan branch in SKILL
(+.agents mirror byte-identical), delegating routine prompt (retired a real full-overwrite
drift bug), cron-prompt.md. Impl review 0 P0/0 P1. HONEST LIMIT (Conductor live-tested):
CronCreate = session-only + 7-day auto-expire even with durable:true → standing weekly
automation NOT deliverable on CLI 2.1.172; registered session cron 90c01ae7 (Sun 23:07) +
one-shot fire-verify 3cea3b55; watchdog = Alex STEP 3.9 >7d/>14d staleness warnings; any
session can re-register from cron-prompt.md. Spike's minimal permission set documented in
spike-evidence.md (first attempt with broad allowedTools was classifier-denied).

#### Scope
Spike: verify scheduled cloud agent (CronCreate) can run *research-github scan headlessly
(auth/MCP availability). PASS → weekly routine writing scan-log.yaml (STEP 3.9 consumes it).
FAIL → degraded local manual command + Alex startup staleness reminder (>7d unscanned).

### Phase 4: Interaction/context small items

**Status:** ✅ Done (2026-07-13, merge 0b947a5). Track A: preview_usage_rule 块（use_when/
never_when/scripted 2-up example/named negative example=pack 选择）+ step1_5c step4 tournament
preview wiring,additions-only,line-set FORWARD-missing 空,.agents 镜像 byte-identical。
Track B: spike Verdict LOADED（3/3 fixture + 3/3 in-repo 判别 token 探针;paths: frontmatter
实测可用,GH issue #17204 的"只有 globs: 可用"说法在 2.1.172 上不成立）→ 交付
.claude/rules/shell-portability.md（25 行/1370B,5 条约束逐条溯源+日期,thin-excerpt+指针+
sync note 防 fork）。已知边界（诚实披露 ×3 处）:rules 按 READ 触发——新建 hook 文件或
盲 Edit 不加载;扩展决策前须把 read-triggered-only 当显式 scope 边界。Impl review 0 P0/0 P1。

#### Scope
(a) AskUserQuestion `preview` field wired into *design 2-up comparisons and tournament
final display (human-domain choice questions get visual side-by-side). (b) Single-file
path-scoped .claude/rules pilot (candidate: shell-portability constraints load only when
touching .tad/hooks/**), with before/after context measurement per Measure Before Optimizing.
