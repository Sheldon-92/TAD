---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
express: true
escalated_review: yes
gate4_delta: []
---

# Express Handoff: Lite Capability-Complete + Shared Knowledge

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-07-31
**Project:** TAD Framework
**Handoff Version:** 3.1.0-express
**User direction:** “我只是唤起你想帮我把它理整理成一个完整的handoff”；“你直接走express handoff就可以”

## 1. Intent

### What we are building

Strengthen `alex-lite` and `blake-lite` so Lite is the default, capability-complete TAD workflow rather than a small/simple feature subset.

Lite must preserve the load-bearing TAD properties—clear intent, executable acceptance criteria, shared project knowledge, execution evidence, human checkpoints, and independent expert review—while removing unnecessary ceremony and token overhead.

### Why now

Full Alex/Blake has become too expensive in time and credits for normal work. The user wants most work to stay in Lite. The existing Lite channel is useful, but it currently excludes knowledge/memory reads and writes by protocol and does not make Alex’s execution spine explicit enough.

### Explicit non-goals

- Do not redesign or modify full Alex/Blake in this handoff.
- Do not make Full TAD an automatic destination because a handoff is long, touches several files, or needs more context.
- Do not remove independent expert review.
- Do not treat Claude Code’s native memory as the cross-platform source of truth.
- Do not enforce a literal one-page ceiling that causes important constraints or ACs to be omitted.

### Success in one sentence

An ordinary user can run Lite on either Claude Code or Codex, the agent reads the relevant shared knowledge, produces a clear executable contract, implements it with independent review, records reusable discoveries, and does not auto-upgrade merely because the task needs more detail.

## 2. Scope

The implementation is limited to these five mirrored/routing files:

1. `.claude/skills/alex-lite/SKILL.md`
2. `.agents/skills/alex-lite/SKILL.md`
3. `.claude/skills/blake-lite/SKILL.md`
4. `.agents/skills/blake-lite/SKILL.md`
5. `AGENTS.md`

The `.claude` and `.agents` Lite files must remain byte-identical pairs. Do not modify `.tad/codex/README.md`, full Alex/Blake, hooks, settings, config modules, or project-knowledge files in this express handoff. If documentation still needs updating outside this scope, record it as a follow-up rather than expanding the file set.

### Escalated-review authorization

This handoff intentionally changes Lite skill/protocol contracts, which is normally on the Blake-Lite escalation list. The user explicitly authorized keeping this work in Lite/express because the full Alex/Blake workflow is too heavy in credits and time, and most work should remain in Lite. The authorization preserves the two-reviewer shape: this Alex contract review plus Blake-Lite's post-implementation reviewer. Fatal operations remain out of scope.

> “Alex和Blake现在也已经有一点太重了，太重到我们本身都很难用，就是都会耗很多credit，所以我并不觉得需要升级……我想大部分的工作都能够用Lite版本来完成。”
>
> “Yes, my idea is not to think of the lite version as small and simple.”
>
> “你直接走express handoff就可以。”

## Gate 2: Design Completeness

**Execution date:** 2026-07-31

| Check | Status | Evidence |
|---|---|---|
| Architecture / capability boundary | PASS | Shared memory, Lite-first policy, and Full-TAD boundary are specified in §§3 and 6. |
| Components / files specified | PASS | Exactly five implementation files are listed in §2 and §8. |
| Cross-platform data flow | PASS | Claude Code and Codex converge on the shared `.tad/` authority map in §3; platform routing remains in `AGENTS.md` and mirrored skill files. |
| Functions / route references verified | PASS | Current Lite skill entry rules, handoff naming, Completion path, and `AGENTS.md` role routes were read and aligned before drafting. |
| Verification plan | PASS | §9.1 provides one executable verification row per AC; §12 and §9.2 preserve independent review. |
| Expert review complete | PASS | Fresh-context Averroes review is recorded in §9.2 and its evidence artifact. |
| All P0 resolved | PASS | Both initial P0 findings are resolved: parser-compatible Lite admission fields and canonical evidence manifest. |

**Gate 2 result:** PASS after independent contract review findings were integrated in §9.2.

**Alex confirmation:** Blake-Lite can implement the requested change from this document, subject to the explicit express exception in §13 and the post-implementation Gate 3 / human Gate 4 checks.

## 3. Shared Memory Contract

Add the same concise contract to both Lite skills. It must define the following authority map:

| Layer | Canonical location | Meaning | Lite behavior |
|---|---|---|---|
| Durable curated knowledge | `.tad/project-knowledge/` | Validated project principles, patterns, and incidents | Read selectively; never load the whole tree by default |
| Knowledge index | `.tad/brain-index.md` and `.tad/project-knowledge/patterns/_index.md` | Cheap discovery before targeted reads | Read during knowledge preflight |
| Current task state | LITE handoff, appended Completion, optional `.tad/active/session-state.md` | Resume/checkpoint state | Read on activation/resume |
| Raw execution learning | `.tad/evidence/journal/` and `.tad/evidence/journal/lite-discoveries.md` | Episode-level capture before distillation | Blake writes only when a reusable discovery exists or the handoff requests it |
| Native capture layer | `.tad/memory/` | Claude-native raw memory capture | Read-only, optional/contextual, never authoritative; neither Lite agent manually edits it |
| Platform instructions | `AGENTS.md` / Claude skill files | Runtime routing only | Never duplicate durable project knowledge here |

Required rules:

- `project-knowledge/` is the shared, platform-neutral source of truth for durable project knowledge.
- `.tad/memory/` is not the shared knowledge authority; it is a native capture layer and remains read-only to TAD workflow agents.
- Knowledge is retrieved on demand: read the index, select relevant entries, then read at most three matched pattern files by default. Expand only when the task genuinely needs it.
- If current code/config conflicts with an old knowledge entry, current repository reality wins; record the conflict or staleness rather than silently following stale knowledge.
- Every important knowledge claim must have a file/path carrier. Chat-only claims do not count as recorded knowledge.

## 4. Alex-Lite Execution Spine

Rewrite Alex-Lite’s workflow so the execution order is explicit and each step states its input, action, output, and stop condition. Keep it compact, but use these stable headings/markers:

1. **L0 — Applicability and current-state check**
   - Confirm this is a Lite task and locate the relevant current handoff/state.
   - Do not auto-upgrade based only on page length, number of context references, or the desire for additional detail.
2. **L1 — Goal anchor**
   - Use the already-established requirement context when available.
   - Ask at most one goal-anchor question only when the success condition is genuinely unclear.
3. **L1.5 — Shared knowledge preflight**
   - Read the relevant shared indexes and targeted knowledge before designing.
   - Record consulted paths and one-line implications in the handoff.
4. **L2 — Design contract**
   - Produce the goal, non-goals, files, decisions, ACs, risks, and knowledge references.
   - The contract may use a concise core plus linked detail/appendix; one-page is a preferred view, not a hard limit or upgrade trigger.
5. **L2.25 — AC dry run**
   - Check that every AC has a runnable or objectively inspectable verification method before review.
6. **L2.5 — Independent contract review**
   - Keep the existing fresh-context reviewer requirement. The reviewer checks scope, knowledge references, AC executability, and whether the Lite contract is sufficient.
7. **L3 — Human decision**
   - Present the concise plan summary and wait for human confirmation before handing off to Blake-Lite.

Alex-Lite must remain design-only: it does not implement application changes and does not invoke Blake-Lite automatically.

## 5. Blake-Lite Context and Execution Contract

Add a matching execution contract to Blake-Lite:

1. Read the selected LITE handoff in full.
2. Read every project-knowledge path explicitly referenced by the handoff.
3. If the handoff has no references, perform the bounded shared-memory preflight: principles when relevant, patterns index, and at most three matched patterns.
4. State the refreshed context before implementation: relevant knowledge read, task goal, key constraint, and success condition.
5. Implement only the requested contract; record deviations and new decisions.
6. Run every AC exactly as written, then run the existing independent implementation reviewer.
7. Append Completion with:
   - changed files and any out-of-scope file;
   - AC results and evidence;
   - reviewer verdict;
   - `Knowledge Assessment: none | journal captured | candidate for distillation`;
   - journal path when a reusable discovery exists.

Blake-Lite must not write finished durable knowledge directly from execution context. It writes raw evidence/journal material; a later Alex-Lite/acceptance knowledge closeout may distill reusable material into `project-knowledge/` using the existing variabilize and provenance rules.

## 6. Lite-First Policy

Replace the current interpretation that Lite is a narrow channel which should normally escalate when the work becomes detailed.

Required policy:

- Lite is the default workhorse and may carry full-quality reasoning within a compact protocol.
- Page count is not a hard boundary.
- Detail may live in linked files or an appended section without changing the Lite channel.
- File count, protocol density, or need for additional knowledge context alone must not automatically route to Full TAD.
- Full TAD remains available when the user explicitly requests it or when a genuinely destructive/fatal operation cannot safely proceed under Lite; this is an exception, not the normal Lite workflow.
- Do not remove safety stops, human confirmation, AC verification, or independent review in order to keep a task in Lite.

The old escalation language must be revised consistently in both Lite files so it does not contradict this Lite-first policy. Preserve the distinction between “add more Lite detail/checks” and “switch to Full TAD.”

## 7. Cross-Platform Routing

Update `AGENTS.md` so Codex users can explicitly invoke the Lite roles. Add routing for:

- `$alex-lite`, `/alex-lite`, `当 Alex Lite`, `Alex Lite 模式`
- `$blake-lite`, `/blake-lite`, `当 Blake Lite`, `Blake Lite 模式`

State that both platforms use the same `.tad/` knowledge/state files and that the platform-specific files only route/load the role. Keep the existing full-role routing intact.

## 8. Files to Modify

### Canonical skill files

- `.claude/skills/alex-lite/SKILL.md` — add execution spine, shared memory contract, Lite-first policy, and lightweight knowledge closeout behavior.
- `.claude/skills/blake-lite/SKILL.md` — add bounded context refresh, shared memory contract, Completion knowledge marker, and Lite-first policy.

### Codex mirrors

- `.agents/skills/alex-lite/SKILL.md` — byte-identical mirror of the Claude Alex-Lite file.
- `.agents/skills/blake-lite/SKILL.md` — byte-identical mirror of the Claude Blake-Lite file.

### Routing

- `AGENTS.md` — add explicit Lite role routing and shared-memory source-of-truth note.

## 9. Acceptance Criteria

### Functional / behavioral AC

- **AC1 — Shared authority is explicit.** Both Lite skills identify `.tad/project-knowledge/` as durable shared knowledge, `.tad/brain-index.md`/patterns index as retrieval indexes, handoff/Completion as task state, journal as raw capture, and `.tad/memory/` as read-only non-authoritative native capture.
- **AC2 — Alex execution is explicit.** Alex-Lite contains the ordered L0 → L1 → L1.5 → L2 → L2.25 → L2.5 → L3 execution spine, with an output/stop condition for each stage, and remains design-only.
- **AC3 — Blake reads knowledge before work.** Blake-Lite requires a bounded context refresh before implementation and records the refreshed paths/constraint in Completion.
- **AC4 — Learning is recorded without self-distillation.** Blake-Lite writes raw journal material for reusable discoveries and a machine-readable Knowledge Assessment marker; it does not directly write finished `project-knowledge` entries or `.tad/memory/`.
- **AC5 — Lite remains capability-complete.** Both Lite skills retain human confirmation, executable ACs, independent contract/implementation review, evidence carriers, resume behavior, and role separation.
- **AC6 — One-page is not a hard gate.** Both Lite skills explicitly define a concise core contract plus linked detail/appendix and explicitly prohibit page length as an automatic Full-TAD trigger.
- **AC7 — Lite-first is the default.** Both Lite skills state that file count, detail, or protocol density alone does not auto-upgrade to Full TAD; the policy does not remove safety stops or required review.
- **AC8 — Codex routing exists.** `AGENTS.md` contains explicit `$alex-lite` and `$blake-lite` routes and states the shared `.tad/` knowledge boundary.
- **AC9 — Mirror parity holds.** The Claude and Codex Lite skill files are byte-identical after implementation.
- **AC10 — Existing Lite behavior remains intact.** LITE handoff admission, AC verification, independent reviewers, no Alex implementation, no Blake commit/push, and human acceptance are not weakened.

### 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

Gate 3 must execute every row below. A failed row blocks Gate 3. `post-impl` means the row is intentionally verified after Blake-Lite updates the five scoped files.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|---|
| AC1 | Shared authority is explicit | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do for p in 'project-knowledge' 'brain-index' '\.tad/memory' 'journal'; do rg -q "$p" "$f" || exit 1; done; done` | Every Lite file names all shared layers and the native memory boundary | (post-impl) |
| AC2 | Alex execution is explicit | post-impl | `python3 -c 'import pathlib,re; s=pathlib.Path(".claude/skills/alex-lite/SKILL.md").read_text(); h=["L0","L1","L1.5","L2","L2.25","L2.5","L3"]; starts=[s.index("**"+x+" —") for x in h]; assert len(set(starts))==7 and starts==sorted(starts); ends=starts[1:]+[len(s)]; blocks=[s[a:b] for a,b in zip(starts,ends)]; assert all(re.search(r"(?is)(input|输入).*?(action|动作).*?(output|输出).*?(stop|停止)",b) for b in blocks)'` | Each anchored stage heading is present exactly once, strictly ordered, and each stage states input/action/output/stop semantics | (post-impl) |
| AC3 | Blake reads knowledge before work | post-impl | `for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -qi 'project-knowledge.*before|context.*refresh|知识.*预检|knowledge.*preflight' "$f" || exit 1; done` | Both Blake-Lite mirrors require a pre-implementation bounded knowledge refresh | (post-impl) |
| AC4 | Learning is recorded without self-distillation | post-impl | `for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -q 'Knowledge Assessment|journal' "$f" || exit 1; ! rg -qi 'write.*finished.*project-knowledge|directly.*project-knowledge|直接.*project-knowledge' "$f" || exit 1; done` | Both Blake-Lite mirrors record Completion/journal state and forbid direct durable self-distillation | (post-impl) |
| AC5 | Lite remains capability-complete | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do for p in 'human confirmation|人.*确认' 'acceptance criteria|AC' 'independent.*review|独立.*审查' 'evidence|证据' 'resume|恢复'; do rg -qi "$p" "$f" || exit 1; done; done; for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do for p in 'human acceptance|人.*验收' 'acceptance criteria|AC' 'independent.*review|独立.*审查' 'evidence|证据' 'resume|恢复'; do rg -qi "$p" "$f" || exit 1; done; done` | Each mirror retains its role-appropriate safety, confirmation, review, evidence, and resume controls | (post-impl) |
| AC6 | One-page is not a hard gate | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -qi 'one-page|one page|page.*not.*hard|page.*not.*trigger|一页.*硬|页数.*升级' "$f" || exit 1; ! rg -q '一页纸 handoff|≤ *1页|一页.*必须' "$f" || exit 1; done` | Every Lite mirror explicitly rejects page length and removes the old literal one-page requirement | (post-impl) |
| AC7 | Lite-first is the default | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -qi 'does not.*auto.*upgrade|must not.*auto.*upgrade|Lite.*default|Lite.*workhorse|自动.*升级.*不|不会.*升级' "$f" || exit 1; rg -qi 'safety|安全|review|审查' "$f" || exit 1; ! rg -q '适用：≤ *5 文件|总数 ≤ *5|预计总改动 > *5 个文件|复杂任务用 /alex|详细.*full' "$f" || exit 1; done` | Every Lite mirror states Lite-first/no-auto-upgrade, retains a safety/review control, and removes the old hard file-count/detail routing language | (post-impl) |
| AC8 | Codex routing exists | post-impl | `rg -q '\$alex-lite|/alex-lite|Alex Lite' AGENTS.md && rg -q '\$blake-lite|/blake-lite|Blake Lite' AGENTS.md && rg -qi '(shared|共用|共享).*\.tad|\.tad.*(shared|共用|共享)' AGENTS.md` | Explicit Codex Lite role routes and the shared `.tad/` knowledge/state boundary are present | (post-impl) |
| AC9 | Mirror parity holds | post-impl | `cmp -s .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md && cmp -s .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md` | Both mirror pairs are byte-identical | (post-impl) |
| AC10 | Existing Lite behavior remains intact | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md; do rg -qi 'design.only|design-only|不.*实现|human confirmation|人.*确认|Contract Review' "$f" || exit 1; done; for f in .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do rg -qi 'no.*commit|no.*push|不.*commit|不.*push|human.*acceptance|人.*验收|Contract Review' "$f" || exit 1; done` | Alex remains design-only; Blake retains no-commit/push, contract review, and human acceptance controls | (post-impl) |

### 9.2 Expert Review Status

## AC

- AC1 — Shared authority is explicit
- AC2 — Alex execution is explicit
- AC3 — Blake reads knowledge before work
- AC4 — Learning is recorded without self-distillation
- AC5 — Lite remains capability-complete
- AC6 — One-page is not a hard gate
- AC7 — Lite-first is the default
- AC8 — Codex routing exists
- AC9 — Mirror parity holds
- AC10 — Existing Lite behavior remains intact

## Contract Review

最终 verdict: PASS
Reviewer: Averroes (independent fresh-context code-reviewer)
关键发现: 初审发现 Gate 2/§9.1 缺失、HANDOFF 文件名会误路由 full Blake、express 协议例外未显式记录、AC 语义检查不足；以上均已在本 handoff 中修复并留存证据。
P0=2 (fixed)
P1=2 (fixed)
已审 AC 条数: 10

This express handoff retains the mandatory fresh-context `code-reviewer`. The review was completed before implementation; all findings are integrated below.

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| Averroes (independent code-reviewer) | P0: Gate 2/Audit Trail and machine-readable §9.1 were missing | Gate 2 section above; §9.1; this §9.2 | Resolved |
| Averroes (independent code-reviewer) | P0: `HANDOFF-*` would route to full Blake while the contract requires Blake-Lite | Filename is `LITE-*`; §14 Blake message; §8 routing | Resolved |
| Averroes (independent code-reviewer) | P1: express protocol normally excludes architecture/protocol changes | §13 explicit user-directed exception; one reviewer, Gate 2, Gate 3, and Gate 4 retained | Resolved |
| Averroes (independent code-reviewer) | P1: marker-only ACs under-verified semantics | §9.1 adds positive/negative checks and post-implementation verification expectations; reviewer remains required | Resolved |
| Averroes (independent code-reviewer) | P1: AC2 ordering/per-stage semantics and AC6–AC10 per-file/negative checks needed stronger mechanical assertions | §9.1 uses anchored ordering, per-stage checks, per-file loops, and contradiction checks | Resolved |

**Overall assessment:** PASS after incremental re-review; all recorded P0/P1 findings are resolved. Implementation remains blocked until Blake-Lite executes §9.1 and completes its independent implementation review.

**Reviewer evidence:** The review output is preserved in `.tad/evidence/reviews/alex/express-lite-capability-complete/code-reviewer.md`.

### Structural verification commands

Blake must run and preserve raw output for these checks:

```bash
cmp -s .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md
cmp -s .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md
```

```bash
for f in .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  rg -q 'project-knowledge|brain-index|\.tad/memory|journal' "$f"
  rg -q 'one-page|one page|page.*not.*hard|page.*not.*trigger' "$f"
  rg -q 'reviewer|独立审查|independent review' "$f"
done
```

```bash
f=.claude/skills/alex-lite/SKILL.md
a=$(rg -n 'L0.*Applicability|Applicability and current-state' "$f" | head -1 | cut -d: -f1)
b=$(rg -n 'Shared knowledge preflight|L1\.5' "$f" | head -1 | cut -d: -f1)
c=$(rg -n 'Design contract|L2.*Design' "$f" | head -1 | cut -d: -f1)
d=$(rg -n 'AC dry run|L2\.25' "$f" | head -1 | cut -d: -f1)
e=$(rg -n 'Independent contract review|L2\.5' "$f" | head -1 | cut -d: -f1)
test -n "$a" -a -n "$b" -a -n "$c" -a -n "$d" -a -n "$e" -a "$a" -lt "$b" -a "$b" -lt "$c" -a "$c" -lt "$d" -a "$d" -lt "$e"
```

```bash
rg -q '\$alex-lite|/alex-lite|Alex Lite' AGENTS.md
rg -q '\$blake-lite|/blake-lite|Blake Lite' AGENTS.md
```

Also run the repository’s existing skill-body/parity checks where applicable and record any pre-existing unrelated failure separately; do not modify hooks/settings to make the checks pass.

## 10. Knowledge References

Blake must read these before implementation:

- `.tad/project-knowledge/principles.md`
- `.tad/project-knowledge/patterns/_index.md`
- `.tad/project-knowledge/patterns/memory-and-learning.md`
- `.tad/project-knowledge/patterns/handoff-design.md`
- `.tad/project-knowledge/patterns/pack-build-rules.md`
- `.tad/codex/README.md` (read-only platform context; do not modify in this handoff)
- `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md`
- `.tad/evidence/journal/tad-lite-channel-2026-07-30.md`
- `.tad/evidence/journal/lite-v11-quality-amendments-2026-07-30.md`

Relevant lessons carried into this contract:

- Independent perspective comes from a fresh context, not from opening a second terminal.
- Knowledge must be forged through capture → distillation; the executor should not silently author finished reusable knowledge.
- Claims require on-disk carriers; a chat assertion that review happened is not evidence.
- Cross-platform mirrors must remain byte-identical.

## 11. Friction Preflight

| Friction point | Required step | Fix path | Gate impact |
|---|---|---|---|
| Claude/Codex mirror drift | Update both pairs and run `cmp` | Copy canonical content, then verify | AC9 fails; Gate 3 blocked |
| Codex Lite route not recognized | Update `AGENTS.md` | Use explicit `$alex-lite`/`$blake-lite` routes | AC8 fails; record as blocked if runtime smoke test unavailable |
| Existing `.codex/hooks.json` warning | Do not modify hooks in this handoff | Record pre-existing warning; skills must still load by file path | Non-blocking unless Lite invocation itself fails |
| Independent reviewer unavailable | Invoke the required fresh-context reviewer | Request tool availability or record explicit degraded approval | No reviewer means Gate 3 cannot PASS |

## 12. Review Requirements

This is an express handoff by explicit user direction. It retains one independent contract reviewer before Blake-Lite implementation and Blake-Lite’s existing post-implementation reviewer. The reviewer must specifically check:

- whether the shared memory contract is complete but token-efficient;
- whether Alex’s execution spine is actually actionable;
- whether Lite-first semantics accidentally weaken safety or review;
- whether the five-file scope and mirror parity are credible;
- whether every AC is mechanically verifiable.

## 13. Decision Summary

| Decision | Choice | Rationale |
|---|---|---|
| Lite positioning | Capability-complete, ceremony-light default | User wants most work completed in Lite without Full-TAD credit cost |
| Knowledge authority | `.tad/project-knowledge/` + shared `.tad/` artifacts | Works across Claude Code and Codex; platform memory is not portable authority |
| Memory loading | Bounded index → targeted files | Preserves relevance without paying for full knowledge reload every task |
| Handoff length | Core contract + linked detail; no hard one-page gate | Prevents token waste without deleting load-bearing constraints |
| Review | Keep independent contract and implementation review | Fresh-context review is the load-bearing quality property |
| Escalation | No automatic upgrade for length/detail/file count alone | Lite is the primary workflow; safety and human approval remain |
| Implementation channel | Express handoff, explicitly user-directed | Requirements were already discussed and the user requested express |
| Express protocol exception | Approved by explicit user direction | This changes Lite protocol/skill contracts, which express normally excludes; the exception retains fresh `code-reviewer`, Gate 2, Gate 3, and Gate 4 rather than weakening quality controls |

## Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/alex/express-lite-capability-complete/code-reviewer.md
    required: true
  - path: .tad/evidence/reviews/blake/express-lite-capability-complete/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/express-lite-capability-complete/spec-compliance.md
    required: true
acceptance_tests:
  - path: .tad/evidence/acceptance-tests/express-lite-capability-complete/ac-report.md
    required: true
completion:
  - path: .tad/active/handoffs/LITE-20260731-express-lite-capability-complete.md
    required: true
knowledge_updates:
  - path: .tad/evidence/journal/lite-capability-complete-2026-07-31.md
    required: false
```

Blake-Lite must produce or update the manifest paths above; the journal is conditional on a reusable discovery.

## 15. Blake Message

### Machine-readable

Activate `$blake-lite` and implement only the five files in §2. Read §3 and all paths in §10, execute §9.1 row by row, run the independent implementation reviewer, and append `## Completion` to this LITE handoff. Do not commit or push.

### 人话版

请用 Blake Lite 实现：让 Lite 保留 TAD 最重要的确定性能力，但少掉重复仪式；让 Alex Lite 明确知道每一步做什么，让 Alex/Blake Lite 在 Claude Code 和 Codex 之间共用 `.tad/` 知识；不要因为 handoff 变长就自动升级 Full TAD，也不要把 handoff 硬限制成一页。专家审核、AC 验证和人工验收必须保留。

**Gate 2 status:** PASS — independent review integrated; Gate 3 AC/reviewer PASS; human acceptance PASS

**Handoff Created By:** Alex (Agent A)
**State:** ACCEPTED / ARCHIVED

## Completion (2026-07-31)

**Commit**: uncommitted（按 handoff §15 与 blake-lite 纪律，不主动 commit；由人验收后决定）

- 上下文刷新：`.tad/project-knowledge/principles.md`、`patterns/_index.md`、`patterns/memory-and-learning.md`、`patterns/handoff-design.md`、`patterns/pack-build-rules.md`、`.tad/codex/README.md`、`.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md`、`.tad/evidence/journal/tad-lite-channel-2026-07-30.md`、`.tad/evidence/journal/lite-v11-quality-amendments-2026-07-30.md` | 关键约束：仅改 5 个文件，`.claude`/`.agents` 镜像 byte-identical，不削弱人工确认/独立审查/AC 验证 | 成功条件：Lite 成为能力完整的默认通道，不因篇幅/文件数/细节自动升级 Full TAD
- 改动文件：
  - `.claude/skills/alex-lite/SKILL.md`（执行脊柱 L0→L1→L1.5→L2→L2.25→L2.5→L3 + 共享记忆契约 + Lite-First 政策）
  - `.agents/skills/alex-lite/SKILL.md`（byte-identical 镜像）
  - `.claude/skills/blake-lite/SKILL.md`（L0.75 有界上下文刷新 + 共享记忆契约 + Completion 知识标记 + Lite-First 政策）
  - `.agents/skills/blake-lite/SKILL.md`（byte-identical 镜像）
  - `AGENTS.md`（$alex-lite/$blake-lite 路由 + 共享 `.tad/` 边界声明 + Default Behavior LITE 分支）
- AC 结果：AC1–AC10 逐条按 §9.1 原文运行，全部 ✅（原始输出：`.tad/evidence/acceptance-tests/express-lite-capability-complete/ac-report.md` + `structural-verification-raw.txt`）；§9.2 结构验证命令全 exit 0；`skill-body-verify.sh` ALL CHECKS PASSED
- Reviewer: PASS（独立 fresh-context code-reviewer），P0=0, P1=0, P2=4——关键发现原文："The escalation-list rewrite keeps every real guard (SAFETY, protocol-contract, fatal classes, escalated_review discipline, human stops) while removing only the file-count/page-length auto-upgrade the handoff explicitly targeted." P2 两项已修（恢复路径经 AC 空跑、AGENTS.md intro 补 Lite 路由），修复后同 reviewer 增量复核 verdict: PASS。证据：`.tad/evidence/reviews/blake/express-lite-capability-complete/code-review.md` + `spec-compliance.md`
- Knowledge Assessment: journal captured — `.tad/evidence/journal/lite-capability-complete-2026-07-31.md`（负向 regex AC 约束禁令措辞；负向 AC 选词经验；镜像 cp 即时同步纪律），另 append lite-discoveries.md 一行
- 意外发现：负向 regex AC（`直接.*project-knowledge` 类）会惩罚"禁令本身的措辞"——写"禁止直接写 project-knowledge"反而 FAIL 自己的 AC；已通过换词/拆行规避并记入 journal
- follow-up：
  1. {blake-lite 规模阈值主观化："明显超出契约声明的规模"无客观锚点 / code-review.md P2#2 / 不阻塞：§6 明确授权去文件数硬阈值，stop-and-report 仍保留 / 建议 owner: 下次 alex-lite 修订时评估是否加 ×2 锚点}
  2. {仓库既有未提交残留（NEXT.md、.tad/research-notebooks/REGISTRY.yaml）与本任务无关 / code-review.md P2#4 / 不阻塞：非本任务改动 / 建议 owner: 人——commit 时勿夹带}
