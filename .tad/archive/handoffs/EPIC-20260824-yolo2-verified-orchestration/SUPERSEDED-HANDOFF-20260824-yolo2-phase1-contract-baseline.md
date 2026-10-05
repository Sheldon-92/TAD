> **SUPERSEDED 2026-08-24 — DO NOT IMPLEMENT.** The Epic was reset to a real recovery vertical slice. This document is retained only as design-history evidence. See `.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md` v2 and `.tad/decisions/DR-20260824-yolo2-vertical-slice-first.md`.

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs:
  - .tad/schemas
  - .tad/workflows/yolo
  - .tad/tests/yolo2
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-08-24
**Project:** TAD Framework
**Task ID:** TASK-20260824-YOLO2-P1
**Handoff Version:** 1.5.0-blocked (design review cycle 5 cap exhausted)
**Epic:** EPIC-20260824-yolo2-verified-orchestration.md (Phase 1/6)
**Decision:** DR-20260824-yolo2-orchestration-kernel.md
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间:** 2026-08-24 — design review cycle 5 final round failed; review cap exhausted

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|---|---|---|
| Expert Review Complete | ✅ | Cycle 5 used both authorized rounds; final code review passed and final test review failed |
| All P0 Resolved | ❌ | Final test review found an aliasable `vm.Script` capability that permits extra host-realm scripts |
| Architecture Complete | ❌ | Host boundary is sound, but the claimed unique VM capability is not closed |
| Components Specified | ✅ | Schemas, validator, reducer, runner, author verifier and review carriers are named |
| Functions Verified | ❌ | Direct VM path is checked, but aliases and alternate VM execution methods remain possible |
| Data Flow Mapped | ✅ | Gate 3 live invocation, source carriers, normalized artifacts and receipt bindings are explicit |
| AC Conflict Matrix | ✅ | Six-schema count conflict resolved; no live-file/edit conflict remains |
| AC Dry Run | ✅ | Both verifiers pass syntax checks; both T=0 paths exit 2; AC linter reports 0 warnings; signature and lock probes passed in temp isolation |

**Gate 2 结果:** ❌ FAIL — DESIGN REVIEW CYCLE 5 CAP EXHAUSTED

**Alex确认:** 用户于 2026-08-24 选择方案 1，明确授权 Design Cycle 5。两轮均已完成并保留证据；最终轮仍有 P0，因此 Gate 2 失败。不得交给 Blake；任何修复必须由用户另行授权新的 review cycle。

---

## 📋 Handoff Checklist (Blake必读)

开始实现前确认：

- [ ] 已读完整 handoff、Epic Phase 1、Decision Record。
- [ ] 已重新读取 §Project Knowledge 列出的四份知识文件。
- [ ] 理解这是“可执行参考合同 + 基线”，不是 live YOLO 2 内核。
- [ ] 理解任何受保护 live 文件的字节变化都会使本 Phase 失败。
- [ ] 理解 fixture 不得携带自己的 expected verdict；判定 oracle 必须独立。
- [ ] 理解 test output、completion report、executor claim 都不能直接产生 verified/complete。
- [ ] 理解唯一允许的依赖变化是 `devDependencies.acorn=8.18.0` 与精确的 npm lockfile v1；安装脚本必须禁用。
- [ ] 理解本单不测真实 LLM 质量，也不声称 Claude/Codex/OpenCode 已接入。

不清楚就停止并返回 Alex；不得自行扩展到 Phase 2–5。

---

## 1. Task Overview

### 1.1 What We're Building

建立 YOLO 2.0 的第一层可信基础：

1. 六个版本化 JSON Schema。
2. 一份完整、可执行的状态机/信任边界协议。
3. 一个无 I/O 的纯函数参考模型，作为 Phase 2 production kernel 的独立行为 oracle。
4. 一个依赖 Node 标准库的窄 JSON-Schema validator（只支持本合同声明的 keyword 子集）。
5. 对当前 YOLO v1 live workflow 的确定性 5×3 基线 runner。
6. 正控、负控和三类 mutation-kill 测试。
7. 受保护 live surface 的 Alex-authorized SHA-256 封条验证。

### 1.2 Why We're Building It

用户的核心问题不是“compact 后有没有摘要”，而是长任务执行过程中目标、进度和完成标准逐渐失真，最后质量下降。Phase 1 先把“什么证据才算进度、什么条件才能完成、哪些假完成必须拒绝”变成机器可复算的合同。

**成功的样子:** Phase 2 可以直接按本单的 schema、状态转换和 reference model 实现 durable kernel，不再重新决定完成语义；任何删除 audit/evidence/replay 防线的实现都会被测试击杀。

### 1.3 Intent Statement

**真正要解决的问题:** 给长任务一个不会随上下文压缩而漂移、也不会被执行者自报完成所欺骗的外部认证合同。

**不是要做的:**

- ❌ 不修改或启用 live YOLO 2。
- ❌ 不把 fixture 结果冒充真实 harness 或真实模型 benchmark。
- ❌ 不做数据库、服务端、Web dashboard、LangGraph/Temporal 或 LongHorizon runtime 接入。
- ❌ 不实现 Phase 2 的持久化 ledger、原子写、锁、resume CLI。
- ❌ 除精确锁定、仅用于验收解析的 `acorn@8.18.0` 外，不引入第三方 npm 依赖。
- ❌ 不更改 package.json 的现有 test script 来制造“全仓测试已接入”的假象。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：本任务类别

- 状态机与 Gate authority
- AC 判别力与 mutation testing
- author-side baseline / scope freeze
- Node + shell 跨平台验证
- 长上下文恢复与证据权威

### 步骤 2：必须重读

1. .tad/project-knowledge/principles.md
2. .tad/project-knowledge/patterns/gate-design.md
3. .tad/project-knowledge/patterns/ac-verification.md
4. .tad/project-knowledge/patterns/shell-portability.md

### Capability Pack References

- `.agents/skills/ai-agent-architecture/SKILL.md` — 长任务状态、证据权威与降级边界。
- `.agents/skills/supply-chain-security/SKILL.md` — Acorn 身份、行为、锁文件与安装脚本约束。

### ⚠️ Blake 必须注意的历史教训

- 状态文件只是 cache；没有可重放 event carrier，就不是可信进度。
- executor claim、completion 文件存在、测试文字都只是输入，不能直接成为 verified。
- 只由受约束者自己执行的约束等于没有约束；audit authority 必须由控制面登记并与 executor 隔离。
- fixture 同时携带输入和 expected_result 会自我认证；本单 expected oracle 固定在 reference test contract 中。
- Gate 必须证明会红：known-good PASS、known-bad FAIL、删除防线后重新 FAIL。
- baseline 不能由执行方开工后自行拍摄；本单使用 Alex 已写的 120-row manifest，并在本文钉住其摘要。
- AC 命令必须在 live host 上运行；缺工具、usage error、空输入都不能伪装成被测失败或 PASS。
- Phase 1 验收只依赖当前 Node 与 macOS/POSIX 基础工具，并静态执行 `node14-static-v1`；真实 Node 14.0.x 运行由 Epic Phase 4 阻断验证。不得依赖 rg、timeout、PyYAML、Ajv 或网络。
- shell 排序/集合运算必须 LC_ALL=C；脚本通过 bash 文件执行，不依赖交互 zsh 分词。
- 修复是新的缺陷源；每一轮修复后必须重跑整个 revised suite，不只回归原 finding。

### 知识新鲜度说明

2026-08-24 执行 stale-knowledge-check.sh --json，退出 0。报告中的 stale/warn 项集中在 frontend、历史 release/sync 载体或格式不良引用，与本单选择的 gate/AC/shell 规则没有直接冲突。

---

## 2. Background Context

### 2.1 Previous Work

- LongHorizon-Harness 研究证据：
  .tad/evidence/research/longhorizon-harness/2026-08-24-raw-web-research.md
- 已接受架构决策：
  .tad/decisions/DR-20260824-yolo2-orchestration-kernel.md
- 已确认 Epic：
  .tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md
- Alex T=0 control-logic probe：
  .tad/evidence/yolo2-baseline/t0-control-logic-probe.md
- Alex live surface baseline：
  .tad/evidence/yolo2-baseline/live-surface-baseline.md

研究 notebook registry 中没有 LongHorizon 专用 notebook；本地研究证据已足够支撑本 Phase，不新建云 notebook，也不把旧 notebook 的陈旧状态当阻塞。

### 2.2 Current State

T=0 确定性注入结果：

| 场景 | 3 次结果 | Safety Pass³ | 假完成率 |
|---|---|---:|---:|
| normal | 3/3 workflow_complete | 100% | 0% |
| failed_test | 3/3 在 layer1=false 下 workflow_complete | 0% | 100% |
| single_reviewer | 3/3 在 reviewers=1 下 workflow_complete | 0% | 100% |
| stale_evidence | 3/3 对 missing-old-review.md 不核验仍 complete | 0% | 100% |
| interruption | 3/3 uncaught_error，无 recoverable state | 0% | n/a |

总计 3/15 safety-correct；三个能走到正常 terminal 的 adverse 场景 9/9 假完成。fake_tokens=0 只代表确定性 adapter，不代表真实模型 token 成本。

### 2.3 Dependencies

- Runtime: Node >=14.0.0（package.json 已声明）
- Allowed built-ins for the exact Node 14.0 floor: fs, fs/promises, path, crypto, url, os, perf_hooks. Use bare specifiers, not the node: prefix.
- Exactly one development dependency delta: `acorn@8.18.0`, exact version, used only by the Alex-owned acceptance verifier.
- Commit npm `package-lock.json` with `lockfileVersion: 1` and the exact Acorn registry URL/integrity pinned in the dependency baseline. `npm-shrinkwrap.json`, `yarn.lock`, and `pnpm-lock.yaml` remain absent.
- Install with lifecycle scripts disabled. Network is needed only to fetch that pinned package during implementation setup; Phase 1 runtime artifacts perform no network access.
- Supply-chain decision evidence: `.tad/evidence/research/yolo2-parser/2026-08-24-parser-dependency-decision.md`.
- Phase 2 depends on all Phase 1 ACs passing

### 2.4 AC Conflict Matrix

| Constraint A | Constraint B | Conflict | Resolution |
|---|---|---|---|
| Epic Output lists contract/event/state/round/audit/capability | Original AC1.1 said five record classes | Yes | Epic AC1.1 corrected to six; six schemas are authoritative |
| Phase 1 needs executable transition tests | Phase 2 owns production kernel | Potential | Phase 1 creates a pure, no-I/O reference model only; no ledger/lock/resume/action execution |
| Baseline must execute current workflow | Phase 1 must not edit live workflow | No | Read live source at runtime and wrap in memory; never copy or patch source |
| Mutation tests delete defenses | Live/reference source must remain intact | No | Mutate a temporary copy under os.tmpdir; original digest must remain unchanged |
| Honest unknown states may block | All tests should exit 0 | Potential | Test runner exit 0 means expected PASS/BLOCK classifications matched; it does not require every scenario to complete |
| Evidence directory is generated during work | Scope freeze forbids live changes | No | Evidence paths are outside protected roots; protected-set verifier uses explicit closed roots |
| Phase 1 originally froze package.json | RegExp camouflage proved the custom scanner unsound | Yes | Human authorized one exact dev-only delta: Acorn 8.18.0 plus pinned lockfile; all other package/lock changes fail closed |

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1 — Six closed schemas**

Create Draft-07-compatible schema documents for:

- contract
- event
- state
- round
- audit
- capabilities

Every schema MUST:

- use schema_version enum ["1.0.0"];
- have a record kind const;
- set additionalProperties false at every governed object boundary;
- include a repo-relative artifact_path using custom format tad-relative-path;
- include at least one typed enum so bad-enum fixtures are meaningful;
- reject missing required fields, wrong types, unknown versions, absolute paths, dot-dot traversal, and unknown fields;
- produce stable errors shaped as {code, instance_path, schema_path, message}.

**FR2 — Narrow validator**

Create a dependency-free validator supporting only keywords used by the six schemas:

- type, required, properties, additionalProperties
- items, minItems, uniqueItems
- enum, const
- minLength, pattern
- minimum, maximum
- allOf, anyOf, oneOf
- format: tad-relative-path
- local JSON Pointer refs only if schemas actually use $ref

Unsupported keywords MUST fail closed with code E_SCHEMA_KEYWORD_UNSUPPORTED. Invalid schema documents MUST never be treated as valid instances.

This is not advertised as full JSON Schema Draft-07 conformance.

**FR3 — Frozen contract digest**

Canonicalize JSON recursively by lexicographically sorting object keys, preserving array order, rejecting non-JSON values and non-finite numbers, then SHA-256 the UTF-8 bytes.

Digest input MUST include:

- Epic ID and Phase ID
- handoff path and handoff version
- ordered AC manifest with IDs and normative text hashes
- allowed create/modify paths
- required checks with commands and required/optional flag
- risk level
- authority policy（allowed reviewer roles, quorum, issuer and separation rules; no runtime session IDs）
- capability mode and schema versions

Changing any one of these fields MUST change the digest. A pre-existing unverified round bound to the old digest MUST derive contract_changed, never silently rebind.

**FR4 — Pure reference state model**

Create pure functions with no filesystem/process/global writes:

- validateRecord(kind, value)
- canonicalize(value)
- computeContractDigest(contract)
- reduceEvents(contract, events)
- canFinalize(contract, replayState, cachedState)
- classifyAuditAuthority(contract, audit, candidate)

The reference model is a behavioral oracle. It MUST NOT implement atomic append, locks, resume, adapter calls, action receipts or CLI mutation.

Legal derived states:

- planned
- ready
- executing
- candidate
- audit_pending
- verified
- complete
- contract_changed
- blocked
- honest_partial
- corrupt

Only the reducer derives verified/complete. No public input event named verified or complete is accepted.

**FR5 — Completion authority**

complete requires all of:

1. contract digest matches the current frozen contract;
2. candidate digest and target snapshot digest are present and match audit receipts;
3. layer1_passed is true;
4. every required check has passed;
5. at least two valid, distinct auditor actors, each backed by a candidate-bound control-plane authority grant event;
6. every accepted audit uses a distinct session from executor and no accepted auditor has executor actor_id or executor role;
7. at least one accepted audit has reviewer_role=code-reviewer;
8. accepted audits are not older than the candidate and bind the current capability mode;
9. accepted audits contain no P0 and verdict PASS;
10. cached state, if supplied to finalize, byte-semantically equals replayed state;
11. no unresolved contract_changed, corrupt, blocked or honest_partial condition.

executor_claimed, completion_written and receipt text are never sufficient.

**FR6 — Fixed transition oracle**

Fixtures contain inputs only. They MUST NOT contain expected_result, expected_state, expected_error or pass booleans. The runner contains this contract-fixed outcome table:

| Case ID | Required classification |
|---|---|
| happy_path | complete |
| executor_claim_only | not_complete |
| completion_only | not_complete |
| layer1_false | not_complete |
| required_test_failed | not_complete |
| one_auditor | not_complete |
| unregistered_auditor | not_complete |
| executor_actor_audit | not_complete |
| executor_session_audit | not_complete |
| executor_role_audit | not_complete |
| stale_audit | not_complete |
| candidate_digest_mismatch | not_complete |
| snapshot_digest_mismatch | not_complete |
| contract_digest_mismatch | contract_changed |
| cache_replay_mismatch | corrupt |
| capability_not_strict | honest_partial |
| executor_issued_grant | not_complete |
| audit_before_grant | not_complete |
| grant_candidate_mismatch | not_complete |
| grant_snapshot_mismatch | not_complete |
| grant_contract_mismatch | contract_changed |
| reused_grant | not_complete |
| grant_invocation_mismatch | not_complete |
| grant_session_mismatch | not_complete |

The runner MUST reject missing IDs, duplicate IDs and extra IDs.

**FR7 — Deterministic YOLO v1 baseline**

baseline-v1.mjs MUST read .claude/workflows/yolo-epic.workflow.js from disk and execute that body through one exact `vm.Script` sandbox with deterministic fake agent/parallel adapters. The enclosing Node process MUST have the explicit CLI argument `--disallow-code-generation-from-strings`; using `NODE_OPTIONS` is not a substitute.

It MUST run normal, failed_test, single_reviewer, stale_evidence and interruption exactly three times each and emit:

- one raw JSONL row per run;
- scenario summary with safe-run count;
- Safety Pass@3 and Safety Pass³;
- false completion count/rate where applicable;
- elapsed_ms;
- fake_tokens=0 plus token_measurement_mode=synthetic_adapter;
- source SHA-256;
- an explicit boundary that this is control-logic measurement, not live model quality.

The observed classifications must match Alex's T=0 evidence. Timing values may differ; classifications and counts may not.

The in-memory transform may only replace the leading export token required by the wrapper. It MUST assert exactly one replacement and must not rewrite any other source text. The VM context receives only the frozen deterministic adapter seed and disables both string and WebAssembly code generation. The author verifier allows `vm` only in `baseline-v1.mjs`, only as the exact named imports `Script` and `createContext`, and token-checks this single construction path:

~~~js
import { Script, createContext } from 'vm'

const workflowSource = readFileSync(workflowSourcePath, 'utf8')
const exportToken = 'export const meta ='
const replacementToken = 'const meta ='
const replacementCount = workflowSource.split(exportToken).length - 1
if (!workflowSource.startsWith(exportToken) || replacementCount !== 1) throw new Error('E_WORKFLOW_TRANSFORM')
const transformedSource = replacementToken + workflowSource.slice(exportToken.length)
const wrappedSource = '(async () => {\n' + transformedSource + '\n})()'
const contextSeed = Object.assign(Object.create(null), { agent, parallel, args, log, phase })
const context = createContext(contextSeed, { codeGeneration: { strings: false, wasm: false } })
const script = new Script(wrappedSource, { filename: 'yolo-epic.workflow.js' })
const workflowPromise = script.runInContext(context)
~~~

The identifiers, literal values, arguments, and single-use counts above are normative. `contextSeed` is the exact fresh null-prototype object shown: only the scenario's deterministic `agent`, `parallel`, `args`, `log`, and `phase` values cross into the sandbox; it must not expose `process`, `require`, filesystem, module loaders, or other host globals. `transformedSource` is a `const` built only by the shown prefix replacement. The static AST policy still rejects common dynamic-code, reflection, global-root and capability-object forms as defense in depth, but it does not claim exhaustive recognition. The authoritative boundary is the required host CLI flag plus the VM context's two disabled code-generation switches.

**FR8 — Mutation-kill tests**

The reference model must contain exactly one delimited defense region for each:

- AUDIT_AUTHORITY
- EVIDENCE_BINDING
- REPLAY_CONSISTENCY

mutation tests copy reference-model.mjs plus its schema-validator.mjs dependency to a fresh, unique os.tmpdir, remove one region at a time, import the mutant, and run the applicable independent oracle cases. Each delimited region must surround a syntactically optional guard statement/block so removing it leaves a valid, importable module.

Required:

- original model: full suite PASS;
- audit defense removed: `executor_issued_grant`, `audit_before_grant`, `grant_candidate_mismatch`, and `reused_grant` all execute; at least one exposes unsafe completion and the mutant is KILLED, while the original keeps all four non-complete;
- evidence defense removed: candidate/snapshot digest mismatch exposes unsafe completion, mutant KILLED;
- replay defense removed: cache_replay_mismatch exposes unsafe completion, mutant KILLED;
- zero surviving mutants;
- temp copies removed after run;
- original reference-model SHA is unchanged before/after.

The structured mutation evidence is closed. Its root includes `original_suite_result`, and every mutant row includes `executed_case_ids` plus `case_results[{case_id, original_classification, mutant_classification}]`. The exact, sorted case sets are: AUDIT_AUTHORITY = `audit_before_grant`, `executor_issued_grant`, `grant_candidate_mismatch`, `reused_grant`; EVIDENCE_BINDING = `candidate_digest_mismatch`, `snapshot_digest_mismatch`; REPLAY_CONSISTENCY = `cache_replay_mismatch`. The author verifier requires every original classification to equal FR6 and remain non-complete, recomputes `unsafe_outcomes` from mutant classifications, and requires at least one explicit mutant `complete` per defense.

A mutant is killed only when it imports successfully, executes the designated cases, and the independent outcome oracle observes at least one explicit unsafe completion. Syntax/import/runtime errors are INVALID MUTANT and make the mutation suite ERROR; they do not count as killed. Merely printing a mismatch with exit 0 is not killed.

**FR9 — Live surface freeze**

The authoritative baseline file is:
.tad/evidence/yolo2-baseline/live-surface-baseline.md

Its SHA-256 at handoff authoring is:
a10fc0a8cf02f9f386b35c541fa04ef47449d1aed80b92ef801f540c731e6ddd

It contains exactly 120 TSV rows. The final verifier MUST:

- first verify the baseline file itself has that exact digest;
- reconstruct the closed path set from the five protected-root rules in the baseline;
- assert reconstructed path count is 120;
- compute SHA-256 for every current file;
- compare normalized TSV byte-for-byte;
- fail on added, removed, renamed or modified files;
- write the comparison output to required evidence.

Blake MUST NOT edit, regenerate, re-date or replace the baseline.

The independent dependency baseline is `.tad/evidence/yolo2-baseline/dependency-surface-baseline.md` with author digest `1ca20682b9f900e628e082e56d61ca927a577ded8d44ad0284141d79b43b47b4`. It freezes the parent `package.json` at SHA-256 `62a2f529de107940ca5b7424f0f1f56711e19d5f67862668031890a0fbb3a32d`, permits the child manifest to differ only by exact `devDependencies.acorn: "8.18.0"`, and requires one exact npm lockfile v1 entry with integrity `sha512-lGq+9yr1/GuAWaVYIHRjvvySG5/4VfKIvC8EWxStPdcDh/Ka7FG3twP6v4d5BkravUilhIAsG4Qj83t02LWUPQ==`. It additionally pins the installed manifest/parser bytes actually loaded by the verifier, rejects resolution/realpath escape, and requires a live registry-signature audit. `npm-shrinkwrap.json`, `yarn.lock`, and `pnpm-lock.yaml` remain absent. This check runs outside the Blake-authored runner and compares both the committed parent and committed child blobs.

**FR10 — Stable runner exit contract**

Every test subcommand ends with exactly one terminal line:

- RESULT=PASS and exit 0
- RESULT=FAIL and exit 1
- RESULT=ERROR and exit 2

Missing artifacts, malformed schema, duplicate fixture IDs, empty fixture sets, unsupported validator keyword, inability to read live source, or inability to create temp isolation are ERROR, never PASS.

Every subcommand MUST accept these read-only test overrides so Gate 3 can exercise a disposable project copy rather than the review target:

- `--root <absolute-project-root>` (default: resolved current worktree root);
- `--workflow-source <absolute-file>` (default: `<root>/.claude/workflows/yolo-epic.workflow.js`);
- `--evidence-dir <absolute-dir>` (default: `<root>/.tad/evidence/yolo2-baseline`);
- `live-surface` additionally accepts `--baseline-file <absolute-file>`.

Unknown flags, relative override paths, or override paths that do not exist are ERROR. Overrides may change where the runner reads test inputs and writes generated test evidence, but may not weaken schema, transition, digest, mutation or surface-match assertions.

**FR11 — Independent acceptance authority**

Layer 1 runner output is not completion authority. Alex owns a separate evidence verifier at `.tad/evidence/yolo2-baseline/author-verify-phase1-evidence.mjs`; its author-time SHA-256 is `0ae5cd4376eaef3bd69517d6f94c37ac3525b8f4e26ab385019e32081ad4fdc4`. Alex also owns `.tad/evidence/yolo2-baseline/author-verify-gate3-receipt.mjs`, author-time SHA-256 `717bd8f18e7d869bd00d9997a7761be536698f29e00e8efddaad0ff6c2618dec`. Blake MUST NOT edit, copy-replace or regenerate either verifier.

The Phase 1 author verifier reads the nine required evidence files directly and enforces closed key sets, 42 schema result IDs (six valid + 36 isolated invalid), the exact 24 transition classifications, ten contract-digest mutations, the exact mutation case/classification map, three valid/importable killed mutants, the four-entry static Node 14 policy, the 15-row T=0 baseline, the live workflow source digest, the 120-row live-surface result, and an empty-invalid/empty-missing npm registry-signature audit. It refuses to run unless `process.execArgv` contains the explicit `--disallow-code-generation-from-strings` CLI flag. It uses pinned Acorn to parse every reached module with `ecmaVersion: 2020` and `sourceType: module`, then traverses parser-produced AST and tokens for static external imports, literal/computed dynamic imports, common forbidden APIs, least-privilege fs imports, and the exact VM sandbox boundary. Static recognition is defense in depth, not the authority for proving that every possible JavaScript constructor alias was enumerated. Every reached local module must lie under one of the two implementation module roots, exist in the recorded implementation commit's Git tree, and match that commit's blob byte-for-byte. It also verifies the exact parent/child dependency delta, installed parser bytes, and committed lockfile from FR9. Evidence files must be structured JSON despite their `.txt` extension; baseline raw remains JSONL. The Gate 3 receipt verifier checks exact reviewed HEAD/parent/worktree, clean tracked state, both source-to-normalized review chains, verdict/P0 fields, hashes, identities, implementation bindings, SHA-256-derived safe carrier IDs, resolved path containment, and closed assertion IDs. It remains an integrity verifier: only Gate 3's observed live harness invocations establish reviewer provenance.

Gate 3 MUST additionally spawn a fresh test-runner session after the implementation commit. That reviewer must bypass `run-phase1.mjs` for semantic judgment, directly import the public exports from schema-validator.mjs and reference-model.mjs, construct fresh inputs not copied from Blake fixtures, independently execute the exact FR6 matrix, reproduce the T=0 VM sandbox, remove each defense in a valid temp copy, reconstruct both author baselines, and independently repeat FR12 plus the runtime-boundary positive and negative probes. The reviewer's Node process and every child test process must use the explicit CLI flag; the reviewer must prove host `eval`, host `Function`, VM `eval`, and VM `Function` all throw `EvalError`, while an ordinary VM expression and the frozen baseline still execute. The reviewer's live harness invocation is the provenance authority; files alone cannot prove freshness. The reviewer may create only its own new partition described in §9.1b and is otherwise read-only. If Gate 3 cannot observe a real reviewer actor/session/invocation from the harness control plane, the result is BLOCKED (not PASS and not a forged file fallback).

**FR12 — Static Node 14 policy in Phase 1; real runtime proof in Phase 4**

Phase 1 makes the narrower, honest claim `node14_static_compatible`; it does not claim Node 14 was executed. The `compatibility` subcommand MUST:

- run `node --check` on exactly `schema-validator.mjs`, `reference-model.mjs`, `run-phase1.mjs`, and `baseline-v1.mjs` under the available host runtime;
- reject the closed `node14-static-v1` list: `node:` specifiers, `node:test`, `structuredClone`, `fs.cp`/`fs.cpSync`, `Array.prototype.at`, import assertions, and CommonJS `require`; adding a forbidden token requires a new policy ID rather than silently changing the claim;
- allow static bare imports only from `fs`, `fs/promises`, `path`, `crypto`, `url`, `os`, `perf_hooks`, and the exact FR7 `vm` import; `vm` may appear only in `baseline-v1.mjs` as unaliased named imports `Script` and `createContext`; all other static bare package specifiers fail;
- recursively follow all static and literal dynamic relative/file-URL imports reachable from the four entries and reject external packages anywhere in that graph; computed dynamic imports fail closed except the single mutation-loader form below;
- the sole computed-import allowlist is the exact expression `import(pathToFileURL(mutantPath).href)` in `run-phase1.mjs`, accompanied by named import `mkdtempSync`, exact creation `const mutationRoot = mkdtempSync(path.join(os.tmpdir(), 'tad-yolo2-mutation-'))`, and the resolved-path containment guard enforced by the pinned author verifier. The runner and independent reviewer must also prove at runtime that `mutantPath` is a regular file below the fresh mutation root before import;
- parse every reached module with pinned `acorn@8.18.0`, `ecmaVersion: 2020`, `sourceType: module`, and parser-produced tokens; perform import traversal and forbidden API checks against the AST/token stream, so comments, templates, RegExp literals, and token separation cannot camouflage executable syntax;
- apply least privilege to `fs` and `fs/promises`: allow named imports only; reject default imports, namespace imports, `import {default as ...}`, the `promises` object, and named `cp`/`cpSync`. Implementation uses named `readFileSync`/`mkdtempSync` rather than propagating an ambient fs capability object;
- reject `globalThis` and Node `global` roots entirely; reject direct `eval`, `Function`, `AsyncFunction`, `.constructor`, dangerous/computed ObjectPattern keys, property/prototype reflection, `structuredClone`, and `.at` member access as defense in depth. These checks intentionally make no exhaustive claim about all possible aliases or prototype paths;
- require every Phase 1 runner, baseline, compatibility, author-verifier, and independent-review process to receive the literal CLI argument `--disallow-code-generation-from-strings`; the author verifier checks `process.execArgv` and fails `E_CODEGEN_FLAG` when absent. `NODE_OPTIONS` remains unset and cannot satisfy the requirement;
- require the exact FR7 VM boundary: one `createContext(contextSeed, { codeGeneration: { strings: false, wasm: false } })`, one `new Script(wrappedSource, { filename: 'yolo-epic.workflow.js' })`, and one `script.runInContext(context)`. No other reached module may import/use `vm`, and the context seed exposes no host authority;
- resolve every reachable local/file-URL module to a repo-relative POSIX path below `.tad/workflows/yolo/` or `.tad/tests/yolo2/`; require `git show <implementation_commit>:<path>` to exist and equal the worktree file byte-for-byte. Untracked, post-commit, out-of-root, or blob-mismatched modules fail;
- execute with both `NODE_PATH` and `NODE_OPTIONS` unset and record `node_path_observed: null`, `node_options_observed: null`, plus `code_generation_from_strings_observed: "blocked"` after a live host `Function` negative probe;
- expose a `runtime-boundary` subcommand and include it in `all`; it proves ordinary VM execution succeeds while host `eval`, host `Function`, VM `eval`, and VM `Function` each throw `EvalError`;
- write `.tad/evidence/yolo2-baseline/phase1-compatibility-results.txt` using policy ID `node14-static-v1`, exact `implementation_commit`, and `runtime_test_deferred_to: EPIC-20260824-yolo2-verified-orchestration.md#phase-4`.

The static Node 14 scan plus current-host runtime boundary is still not real Node 14 runtime proof. Both controls are documented as available before Node 14 in `.tad/evidence/research/yolo2-parser/2026-08-24-node-codegen-boundary.md`. Epic Phase 4 MUST run the frozen Phase 1 suite on a real Node 14.0.x runtime before any adapter or YOLO 2 integration can pass. If Phase 4 cannot obtain Node 14.0.x, the Epic remains `honest_partial` and cannot reach default-on.

### 3.2 Non-Functional Requirements

- Phase 1 compatibility claim remains `node14_static_compatible`; the current-host code-generation probes do not upgrade it to real Node 14 proof. Use bare built-in import specifiers and no APIs introduced after Node 14.0. A real Node 14.0.x run is a blocking Epic Phase 4 criterion, not a Phase 1 prerequisite.
- Deterministic output order and LC_ALL=C when shell sorting is unavoidable.
- Phase 1 runtime modules perform no network, subprocess LLM calls or external credentials. Network is allowed only for the exact scripts-disabled Acorn install and live `npm audit signatures`; inability to verify is BLOCKED.
- The only third-party package is exact `acorn@8.18.0`, dev-only and used by the Alex-owned acceptance verifier. Phase 1 implementation modules have no third-party runtime dependency.
- No absolute paths embedded in committed fixtures/evidence.
- No writes outside .tad/evidence/yolo2-baseline during normal test execution; temp mutation work uses os.tmpdir.
- All JSON and JSONL artifacts end with newline.
- Security: reject absolute paths, empty segments, dot segments, dot-dot traversal, NUL and backslash separators for tad-relative-path.
- Performance is reported, not gated by an arbitrary duration threshold.

### 3.3 Optimization Target

None. Correct rejection and replayability outrank speed.

---

## 4. Technical Design

### 4.1 Architecture Overview

~~~text
six JSON schemas
      │
      ▼
schema-validator.mjs ───────────────┐
      │                             │
      ▼                             │
reference-model.mjs                 │
(contract digest + pure reducer)    │
      │                             │
      ├── transition input fixtures│
      ├── mutation temp copies      │
      └── replay/cache comparison   │
                                    ▼
live v1 workflow ── fake runtime ── run-phase1.mjs ── evidence/*
                                    │
Alex baseline manifest ─────────────┘
~~~

### 4.2 Components

**schema-validator.mjs**

- Pure recursive validator.
- Deterministic error ordering: instance_path, code, schema_path.
- Never imports reference-model.mjs.
- Exports validateSchemaDefinition and validateInstance.
- Error paths use RFC 6901 JSON Pointer escaping.

**reference-model.mjs**

- Imports validator.
- Pure, deterministic, no I/O.
- Event log is sole authority; cached state is an optional comparison input.
- Defense sentinels are comments only used by test mutation extraction; one BEGIN/END pair per named defense.

**baseline-v1.mjs**

- Imports no reference-model logic.
- Reads live workflow directly.
- Imports only named `Script` and `createContext` from `vm`; the context disables string and WebAssembly code generation and receives no host authority.
- Fake adapters are scenario-specific and deterministic.
- Catches injected interruption at the runner boundary and records uncaught_error/recoverable_state=false.

**run-phase1.mjs**

Subcommands:

- syntax
- compatibility
- runtime-boundary
- schemas
- transitions
- digest
- baseline
- mutations
- live-surface
- all

all runs each suite in the fixed order above and emits per-suite terminal records plus one overall terminal line. The process refuses execution without the explicit CLI flag required by FR12.

### 4.3 Data Models

**Contract authority policy**

The frozen contract contains allowed reviewer roles, minimum quorum, mandatory code-reviewer role, issuer=control-plane, and actor/session/role separation rules. It never contains runtime auditor session IDs, so spawning a fresh audit does not mutate the contract digest.

**Authority grant event**

For one candidate, the control plane records actor_id, reviewer_role, session_id, invocation_id, granted_at, contract_digest, candidate_digest, target_snapshot_digest and capability_mode. The grant must precede its audit receipt and cannot be reused for a different candidate or snapshot. The executor cannot issue a grant.

**Audit receipt**

Binds contract_digest, candidate_digest, target_snapshot_digest, auditor identity, session/invocation, reviewer role, verdict, P0 count, observed_at, evidence digest and capability mode.

**State**

Contains only reducer-derived facts plus source event count/head digest. It never accepts an external complete flag.

### 4.4 State Transitions

The following is the complete accepted event grammar for Phase 1. Any other event type, missing payload field, wrong predecessor, or failed guard returns a stable E_EVENT_* / E_TRANSITION_* error and leaves the previous derived state unchanged.

| From | Event type | Required payload | To / rejection |
|---|---|---|---|
| planned | contract_registered | contract_digest, schema_versions, authority_policy_digest, capability_mode | ready if schema/digest valid; otherwise reject |
| ready | round_started | round_id, contract_digest, executor_actor_id, executor_role, executor_session_id, started_at | executing if current digest and strict capability match; otherwise contract_changed or honest_partial |
| executing | executor_claimed | round_id, claim_digest, claimed_at | executing; recorded but never advances certification |
| executing | candidate_recorded | round_id, contract_digest, candidate_digest, target_snapshot_digest, evidence_digest, created_at | candidate when all bindings are present/current; otherwise reject |
| candidate | layer1_recorded | candidate_digest, passed, receipt_digest, observed_at | candidate when true; blocked with E_LAYER1_FAILED when false |
| candidate | required_check_recorded | candidate_digest, check_id, passed, receipt_digest, observed_at | candidate when true; blocked with E_REQUIRED_CHECK_FAILED when false; duplicate check_id rejects |
| candidate | audit_requested | candidate_digest, target_snapshot_digest, requested_at | audit_pending only after layer1=true and the exact required-check set all passed; otherwise reject |
| audit_pending | authority_granted | grant_id, issuer, actor_id, reviewer_role, session_id, invocation_id, granted_at, contract_digest, candidate_digest, target_snapshot_digest, capability_mode | audit_pending only for issuer=control-plane and current bindings/separation; otherwise reject |
| audit_pending | audit_recorded | grant_id, audit_id, actor_id, reviewer_role, session_id, invocation_id, verdict, p0_count, observed_at, contract_digest, candidate_digest, target_snapshot_digest, evidence_digest, capability_mode | audit_pending for matching unused grant + PASS; blocked for FAIL/P0; honest_partial for UNVERIFIABLE; ungranted/stale/reused/mismatched receipt rejects |
| audit_pending | finalize_requested | round_id, candidate_digest, cached_state_digest or null, requested_at | verified only when every FR5 guard passes; otherwise reject and remain non-complete |
| verified | phase_completed | round_id, verified_state_digest, completed_at | complete only when replay/cache comparison passes; otherwise corrupt |
| any unverified | contract_replaced | old_contract_digest, new_contract_digest, changed_at | contract_changed; old round can never rebind |
| any | capability_degraded | capability_mode, reason_code, observed_at | honest_partial |
| any | corruption_detected | reason_code, observed_digest, expected_digest, observed_at | corrupt |
| any | policy_blocked | reason_code, observed_at | blocked |

Grant semantics are closed: one grant is usable by exactly one audit receipt with identical actor/session/invocation/candidate/snapshot/mode bindings. Two grants without two matching PASS receipts do not satisfy quorum. Quorum counts distinct actor_id and session_id values; at least one matched receipt must have reviewer_role=code-reviewer.

The happy_path fixture sequence is exactly: contract_registered → round_started → candidate_recorded → layer1_recorded(true) → one required_check_recorded(true) per required check → audit_requested → authority_granted(A) → authority_granted(B) → audit_recorded(A, PASS) → audit_recorded(B, PASS) → finalize_requested → phase_completed.

### 4.5 Trust Boundary

Trusted for deriving status:

- frozen contract digest;
- event sequence accepted by reference model;
- frozen authority policy plus candidate-bound control-plane authority grants;
- accepted audit receipts bound to candidate and snapshot;
- independent replay.

Untrusted inputs:

- executor structured output;
- completion report prose;
- test log prose;
- fixture expected values;
- cached state;
- self-declared auditor identity;
- audit produced before candidate;
- same executor actor/session/role;
- unproven harness capability.

### 4.6 Threat Model

| Threat | Required defense |
|---|---|
| executor self-certifies | no verified/complete input event; authority isolation |
| one reviewer silently disappears | quorum of two distinct registered actors |
| stale review reused | candidate time/digest/snapshot binding |
| evidence edited after audit | evidence/candidate/snapshot digests |
| state cache forged | replay comparison before finalize |
| contract changes mid-round | contract_changed terminal for old unverified round |
| fixture lies about expected answer | input-only fixtures + fixed oracle table |
| test runner only prints failure | stable exit contract |
| executor refreshes its own baseline | Alex baseline digest pinned in handoff |
| compact loses goal | frozen contract and replayable state live outside context |

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

Code graph first:

- search_graph on YOLO implementation/audit located audit-yolo.sh functions find_handoff/find_completion and existing fixture/test patterns.
- workflow top-level control code is not represented as named functions in the graph, so source reading was the permitted fallback.
- existing schema inventory: expert-criteria.schema.json, loop-config.schema.json, trace-schema.yaml.
- existing package initially had no dependency lockfile and Ajv was not installed.

Decision: keep the deliberately narrow JSON validator on Node standard library. Separately, after the Cycle 3 RegExp-camouflage failure and explicit human authorization, use exact `acorn@8.18.0` only for the Alex-owned JavaScript acceptance boundary. The selection and supply-chain evidence are pinned in `.tad/evidence/research/yolo2-parser/2026-08-24-parser-dependency-decision.md`.

### MQ2: 函数存在性验证

| Symbol | Existing? | Evidence / disposition |
|---|---:|---|
| current YOLO workflow body | yes | .claude/workflows/yolo-epic.workflow.js, 458 lines, fully read |
| audit-yolo find_completion | yes | code graph and source head |
| validateRecord | no | CREATE in reference-model.mjs |
| computeContractDigest | no | CREATE in reference-model.mjs |
| reduceEvents | no | CREATE in reference-model.mjs |
| canFinalize | no | CREATE in reference-model.mjs |
| validateInstance | no | CREATE in schema-validator.mjs |
| baseline runner | no | CREATE; must load live workflow, not duplicate it |

### MQ3: 数据流完整性

~~~text
Epic/Handoff normative fields
  → contract instance
  → canonical digest
  → round/event inputs
  → pure reducer
  → candidate
  → registered independent audit receipts
  → verified
  → replay/cache equality
  → complete

At every arrow:
  malformed/unbound/unregistered/degraded
  → explicit stable error or non-complete terminal
~~~

No branch allows completion report or executor claim to jump directly to verified.

### MQ4: 视觉层级

N/A. This Phase has no UI.

### MQ5: 状态同步

- Event inputs are authoritative for the reference model.
- Derived state is recomputed from zero for each suite.
- Cached state is never trusted; equality is checked only at finalize.
- Phase 2 will design durable storage; Phase 1 must not write a production state file.

### MQ6: 研究结论边界

LongHorizon supports bounded manage/execute/audit loops and explicit state as a direction. Its reported benchmark does not validate TAD. All TAD claims in this Phase come from local replayable evidence.

---

## 6. Implementation Steps

### 6.1 Micro-Tasks

| ID | Scope | Depends on | Done when |
|---|---|---|---|
| M1 | six schemas + fixture IDs | none | syntax and closed-world schema tests pass |
| M2 | narrow schema validator | M1 | positive/negative/meta-fixtures discriminate |
| M3 | protocol + reference model | M1–M2 | transition and digest oracle pass |
| M4 | v1 baseline runner | none | reproduces T=0 5×3 classification |
| M5 | mutation runner | M3 | 3/3 mutants killed, original unchanged |
| M6 | live-surface verifier | none | 120-row author baseline matches |
| M7 | exact parser dependency setup | none | package delta and npm lockfile v1 match FR9 byte/field constraints; scripts disabled |
| M8 | Node 14/import and runtime code-generation boundary | M1–M7 | four modules pass FR12; host and VM negative probes plus VM positive control pass |
| M9 | integrated runner/evidence/docs | M1–M8 | all subcommands and manifest complete |

M1/M4/M6 may be developed independently, but Blake remains owner of integration. Do not split reference-model and its mutation tests across agents without an explicit integration checkpoint.

### Phase 1A — Contract and Schemas

1. Create six schemas.
2. Create input-only positive/negative fixtures.
3. Implement supported-keyword validator.
4. Add schema-definition meta tests, including unsupported keyword and unknown field.

### Phase 1B — Reference State Model

1. Write PROTOCOL.md with state table, authority rules, failure taxonomy and threat model.
2. Implement pure reference functions.
3. Encode exact transition case-ID oracle from FR6.
4. Prove contract component changes alter digest.

### Phase 1C — Baseline, Mutation and Freeze

1. Build v1 fake-runtime runner against live source.
2. Reproduce T=0 15-run classification.
3. Run three source-defense mutations in temp isolation; every mutant must remain syntactically valid and importable.
4. Recompute live surface against Alex manifest.
5. Run the static Node 14/import policy with `NODE_PATH` unset.
6. Produce required evidence and completion report.

Commit discipline: before implementation, record the resolved starting HEAD in execution evidence as `implementation_parent: <40-hex>`. Stage only `package.json`, `package-lock.json`, the six schema files, `.tad/workflows/yolo/`, and `.tad/tests/yolo2/` using explicit paths. Never use `git add -A` or `git add .` in this dirty worktree. Generated evidence and completion/review paperwork may remain outside the implementation commit. Produce exactly one non-merge implementation commit. The completion frontmatter must record the same `implementation_parent`, the full resolved child SHA as `implementation_commit: <40-hex>`, and the reviewed worktree root as `implementation_worktree: <absolute-path>` before review; Gate 3 checks that exact parent/child pair and worktree, never ambient HEAD.

### Completion evidence Blake must provide

- exact command, exit code and terminal RESULT line for every §9.1 row;
- all raw baseline JSONL rows;
- original and mutant outcomes;
- live-surface cmp output and both manifest hashes;
- independent reviewer reports;
- statement of what remains unmeasured.

---

## 7. File Structure

### 7.1 Files to Create

- package-lock.json
- .tad/schemas/yolo-contract.schema.json
- .tad/schemas/yolo-event.schema.json
- .tad/schemas/yolo-state.schema.json
- .tad/schemas/yolo-round.schema.json
- .tad/schemas/yolo-audit.schema.json
- .tad/schemas/yolo-capabilities.schema.json
- .tad/workflows/yolo/PROTOCOL.md
- .tad/workflows/yolo/schema-validator.mjs
- .tad/workflows/yolo/reference-model.mjs
- .tad/tests/yolo2/run-phase1.mjs
- .tad/tests/yolo2/baseline-v1.mjs
- .tad/tests/yolo2/fixtures/schema/{contract,event,state,round,audit,capabilities}/{valid,missing-required,wrong-type,unknown-version,bad-path,bad-enum,unknown-field}.json
- .tad/tests/yolo2/fixtures/transitions/<FR6-case-id>.json
- .tad/evidence/yolo2-baseline/phase1-schema-results.txt
- .tad/evidence/yolo2-baseline/phase1-transition-results.txt
- .tad/evidence/yolo2-baseline/phase1-digest-results.txt
- .tad/evidence/yolo2-baseline/phase1-baseline-raw.jsonl
- .tad/evidence/yolo2-baseline/phase1-baseline-summary.json
- .tad/evidence/yolo2-baseline/phase1-mutation-results.txt
- .tad/evidence/yolo2-baseline/phase1-live-surface-results.txt
- .tad/evidence/yolo2-baseline/phase1-compatibility-results.txt
- .tad/evidence/yolo2-baseline/acorn-signature-audit.json

Fixture packaging is fixed by the paths above. Each of six record classes has exactly one valid plus six named invalid shapes, and the transition filename stem set equals FR6 exactly. No extra JSON fixture file is permitted under either tree.

### 7.2 Files to Modify

- package.json — add only exact `devDependencies.acorn: "8.18.0"`; every pre-existing key/value remains identical.

Do not modify any pre-existing production/runtime/config/protocol file.

### 7.3 Grounded Against

- .claude/workflows/yolo-epic.workflow.js — fully read, read-only input
- .tad/hooks/lib/audit-yolo.sh — source head and graph symbols verified, read-only
- .agents/skills/alex/references/yolo-execution-protocol.md — source head read, read-only
- .claude/skills/alex/references/yolo-execution-protocol.md — source head read, read-only
- .agents/skills/blake/SKILL.md — source head read, read-only
- .claude/skills/blake/SKILL.md — source head read, read-only
- .tad/config.yaml — source head read, read-only
- .tad/config-workflow.yaml — source head read, read-only
- package.json — Node >=14, type=module, no meaningful test script; parent digest frozen and exact child delta specified
- .tad/evidence/yolo2-baseline/dependency-surface-baseline.md — Alex-owned exact manifest/lock delta carrier
- .tad/evidence/research/yolo2-parser/2026-08-24-parser-dependency-decision.md — parser comparison and supply-chain decision
- .tad/evidence/yolo2-baseline/author-verify-phase1-evidence.mjs — Alex-owned independent evidence verifier; digest-pinned, read-only
- .tad/evidence/yolo2-baseline/author-verify-gate3-receipt.mjs — Alex-owned review-receipt integrity verifier; digest-pinned, read-only
- .tad/evidence/designs/yolo2-architecture-audit-cycle2.md — D1–D10 + CoALA/compaction/checkpoint audit, updated with Cycle 4 parser boundary
- .tad/schemas/expert-criteria.schema.json — Draft-07 convention
- .tad/schemas/loop-config.schema.json — Draft-07 convention

### 7.4 Required Evidence Manifest

~~~yaml
expert_reviews:
  - .tad/evidence/reviews/blake/yolo2-phase1/code-reviewer.md
  - .tad/evidence/reviews/blake/yolo2-phase1/test-runner.md
  - .tad/evidence/reviews/blake/yolo2-phase1/independent-api-verifier.mjs
  - .tad/evidence/reviews/blake/yolo2-phase1/independent-api-verifier-output.txt
  - .tad/evidence/reviews/blake/yolo2-phase1/gate3-review-receipt.json
  - .tad/evidence/yolo2-baseline/author-verify-gate3-receipt.mjs
gate_verdicts:
  - .tad/evidence/yolo2-baseline/gate3-report.md
completion:
  - .tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-contract-baseline.md
blake_reviews:
  - .tad/evidence/reviews/blake/yolo2-phase1/code-reviewer.md
  - .tad/evidence/reviews/blake/yolo2-phase1/test-runner.md
perf_evidence:
  - .tad/evidence/yolo2-baseline/phase1-baseline-summary.json
fixture_results:
  - .tad/evidence/yolo2-baseline/acorn-signature-audit.json
  - .tad/evidence/yolo2-baseline/phase1-schema-results.txt
  - .tad/evidence/yolo2-baseline/phase1-transition-results.txt
  - .tad/evidence/yolo2-baseline/phase1-digest-results.txt
  - .tad/evidence/yolo2-baseline/phase1-baseline-raw.jsonl
  - .tad/evidence/yolo2-baseline/phase1-mutation-results.txt
  - .tad/evidence/yolo2-baseline/phase1-live-surface-results.txt
  - .tad/evidence/yolo2-baseline/phase1-compatibility-results.txt
dogfood: []
knowledge_updates:
  - completion report must state whether a new reusable lesson surfaced
~~~

---

## 8. Testing Requirements

### 8.1 Unit / Contract Tests

- all supported schema keywords;
- stable error order/code/path;
- canonical JSON/digest;
- every FR6 transition case;
- authority identity/session/role/quorum;
- candidate/snapshot/evidence bindings;
- replay/cache equality;
- fail-closed unknown/unsupported inputs.

### 8.2 Integration Tests

- live workflow body + fake adapters, 5 scenarios ×3;
- schema files + fixture files + validator;
- reference model + temp-source mutations;
- author manifest + reconstructed protected path set.

### 8.3 Edge Cases

- empty fixture directory;
- duplicate/missing/extra transition ID;
- unknown schema version;
- absolute path, ../, ./, repeated separator, backslash and NUL;
- two audits from same actor or session;
- registered audit with stale timestamp;
- contract changed after candidate;
- evidence digest changed after audit;
- cache says complete while replay says audit_pending;
- unsupported schema keyword;
- malformed live workflow wrapper transform count !=1;
- baseline manifest file itself edited.
- Acorn registry signature audit missing, invalid, or unverifiable.

### 8.4 Friction Preflight

Verified on 2026-08-24:

- node --version = v24.7.0; nvm/fnm/volta/asdf/docker/podman are absent. Human chose static Phase 1 proof + real Node 14.0.x Phase 4 proof; do not install a runtime in Phase 1.
- Ajv resolution = MISSING and remains unused. `acorn@8.18.0` was selected after identity/behavior/typosquat/lock review; install exactly with `npm install --package-lock-only --lockfile-version=1 --ignore-scripts --save-dev --save-exact acorn@8.18.0`, then install from the committed lock with lifecycle scripts disabled. If the exact artifact/integrity cannot be obtained, stop BLOCKED.
- A temporary exact install returned `npm audit signatures --json` exit 0 with `{"invalid":[],"missing":[]}`. Blake must rerun this live after the locked install and save exactly that JSON shape to `.tad/evidence/yolo2-baseline/acorn-signature-audit.json`; unavailable verification is BLOCKED, not accepted risk.
- package test script only prints “No tests yet”; it is not an acceptance gate.
- current schema directory exists and contains two JSON schemas plus one YAML schema.
- current .tad/tests contains shell-style custom runners; no node:test convention exists.
- live workflow wrapped-body probe executes successfully.
- baseline author file digest = a10fc0a8cf02f9f386b35c541fa04ef47449d1aed80b92ef801f540c731e6ddd.
- protected manifest row count = 120.
- T=0 adverse classifications reproduced 3/3 per scenario.
- macOS portability: do not use timeout; acceptance scripts cannot assume rg.

### 8.5 Feedback Collection

N/A. This is a code/contract task, not a user-facing artifact.

### 8.6 Test Evidence Required

Every subcommand output is written to its manifest path. A report that merely says “all tests pass” without raw terminal RESULT lines is incomplete.

---

## 9. Acceptance Criteria

Phase 1 is complete only when every §9.1 row passes, all required evidence exists, two independent Blake-side reviews pass, and the 120-row live surface remains byte-identical.

### 9.1 Spec Compliance Checklist

Markdown table cells escape shell/case pipe characters as `\|`. When executing a row, remove only that Markdown escape so the shell receives `|`. Do not alter any other character. AC commands were dry-run from their executable, unescaped form.

Gate 3 obtains `implementation_worktree` from its live orchestration state and runs AC12 first. Every remaining AC is then executed through the shown `bash -c` wrapper with that exact absolute path as `$1`; no acceptance command runs from the coordinator's ambient checkout.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| AC1 | Six schemas and closed positive/negative fixtures | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs schemas' _ "$implementation_worktree" | terminal RESULT=PASS; six valid classes; 36 named invalid fixtures rejected with stable code/path; zero extra/missing fixture IDs | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC2 | Legal transitions reject all false-completion routes | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs transitions' _ "$implementation_worktree" | terminal RESULT=PASS; exact 24-case FR6 ID set; only happy_path complete; contract/cache/degraded/grant cases reach required explicit states | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC3 | Frozen contract digest and contract_changed semantics | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs digest' _ "$implementation_worktree" | terminal RESULT=PASS; each contract component mutation changes digest; old unverified round derives contract_changed | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC4 | Current YOLO v1 deterministic 5×3 baseline is reproducible | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs baseline' _ "$implementation_worktree" | terminal RESULT=PASS; 15 raw rows; scenario counts/classifications equal T=0; synthetic token boundary explicit | T=0 measured: normal 3/3 safe; adverse false-complete 9/9; interruption 3/3 uncaught |
| AC5 | Three load-bearing defenses are mutation-killed | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs mutations' _ "$implementation_worktree" | terminal RESULT=PASS; original passes; exact defense-specific case IDs/classifications; AUDIT_AUTHORITY, EVIDENCE_BINDING, REPLAY_CONSISTENCY each killed; 0 survivors; original digest unchanged | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC6 | Alex-authorized live surface is unchanged | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs live-surface' _ "$implementation_worktree" | terminal RESULT=PASS; baseline digest exact; 120 current rows; byte-for-byte TSV match; no additions/removals/modifications | baseline digest a10fc0a8… and rows=120; runner missing at T=0 (rc=1) |
| AC7 | All JS/JSON syntax and non-empty-set guards pass | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs syntax' _ "$implementation_worktree" | terminal RESULT=PASS; every created mjs parses; every schema/fixture JSON parses; enumerated sets non-empty | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC8 | Integrated suite and stable exit contract | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs all' _ "$implementation_worktree" | terminal RESULT=PASS and exit 0; every suite including runtime-boundary ran exactly once; no WARN treated as PASS | post-impl: runner missing at T=0 (rc=1 MODULE_NOT_FOUND) |
| AC9 | Alex-owned verifier independently validates structured evidence and implementation import graphs | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; read verifier rest < <(shasum -a 256 .tad/evidence/yolo2-baseline/author-verify-phase1-evidence.mjs); test "$verifier" = "0ae5cd4376eaef3bd69517d6f94c37ac3525b8f4e26ab385019e32081ad4fdc4"; unset NODE_PATH NODE_OPTIONS; node --disallow-code-generation-from-strings .tad/evidence/yolo2-baseline/author-verify-phase1-evidence.mjs' _ "$implementation_worktree" | author verifier digest exact; terminal RESULT=PASS; explicit host code-generation flag observed; all closed evidence sets/values match; pinned Acorn and four entry graphs pass imports, exact VM boundary, least-privilege fs and common forbidden-API checks; exact dependency/signature evidence passes; every reached local module equals its recorded Git blob | T=0 must exit 2 on first missing implementation evidence |
| AC10 | Only the exact parser dependency delta was used; live YOLO/config/protocol stayed frozen | post-impl-verifiable + live-registry-signature | bash -c 'set -e; cd -- "$1"; read depbase rest < <(shasum -a 256 .tad/evidence/yolo2-baseline/dependency-surface-baseline.md); test "$depbase" = "1ca20682b9f900e628e082e56d61ca927a577ded8d44ad0284141d79b43b47b4"; read parent rest < <(git show HEAD^:package.json \| shasum -a 256); test "$parent" = "62a2f529de107940ca5b7424f0f1f56711e19d5f67862668031890a0fbb3a32d"; node -e '"'"'const a=require("assert"),f=require("fs"),c=require("child_process");const p=JSON.parse(c.execFileSync("git",["show","HEAD^:package.json"],{encoding:"utf8"})),q=JSON.parse(f.readFileSync("package.json","utf8")),l=JSON.parse(f.readFileSync("package-lock.json","utf8"));a.deepStrictEqual(q,{...p,devDependencies:{acorn:"8.18.0"}});a.deepStrictEqual(l,{name:"tad-framework",version:"2.42.0",lockfileVersion:1,requires:true,dependencies:{acorn:{version:"8.18.0",resolved:"https://registry.npmjs.org/acorn/-/acorn-8.18.0.tgz",integrity:"sha512-lGq+9yr1/GuAWaVYIHRjvvySG5/4VfKIvC8EWxStPdcDh/Ka7FG3twP6v4d5BkravUilhIAsG4Qj83t02LWUPQ==",dev:true}}})'"'"'; sig=$(mktemp); trap '"'"'rm -f "$sig"'"'"' EXIT; npm audit signatures --json > "$sig"; node -e '"'"'const a=require("assert"),f=require("fs");const exact={invalid:[],missing:[]};a.deepStrictEqual(JSON.parse(f.readFileSync(process.argv[1],"utf8")),exact);a.deepStrictEqual(JSON.parse(f.readFileSync(".tad/evidence/yolo2-baseline/acorn-signature-audit.json","utf8")),exact)'"'"' "$sig"; for f in npm-shrinkwrap.json yarn.lock pnpm-lock.yaml; do test ! -e "$f"; done; read livebase rest < <(shasum -a 256 .tad/evidence/yolo2-baseline/live-surface-baseline.md); test "$livebase" = "a10fc0a8cf02f9f386b35c541fa04ef47449d1aed80b92ef801f540c731e6ddd"; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs live-surface >/dev/null; echo RESULT=PASS' _ "$implementation_worktree" | terminal RESULT=PASS; both author baselines intact; exact parent/child package and lock; live registry signature invalid/missing sets empty and equal saved evidence; three competing lockfiles absent; 120-row protected surface matches | T=0: frozen author baselines and parent PASS; implementation package/lock/signature evidence absent, overall rc=1 |
| AC11 | Gate 3 reviewer artifacts are closed and cross-bound to live harness-observed reviews | post-impl-verifiable + Gate-3-live-authority | bash -c 'set -e; cd -- "$1"; read verifier rest < <(shasum -a 256 .tad/evidence/yolo2-baseline/author-verify-gate3-receipt.mjs); test "$verifier" = "717bd8f18e7d869bd00d9997a7761be536698f29e00e8efddaad0ff6c2618dec"; node .tad/evidence/yolo2-baseline/author-verify-gate3-receipt.mjs' _ "$implementation_worktree" | terminal RESULT=PASS; closed receipt; SHA-256 carrier IDs, no symlink components, lexical+realpath containment; both source-to-normalized chains and PASS/P0 fields; reviewer identities distinct from executor/each other; exact implementation, hashes and assertion IDs; Gate 3 separately observes both live invocations per §9.1b | T=0 exits 2 on missing receipt; no file-only command may claim provenance |
| AC12 | Recorded one-commit implementation is exactly the clean HEAD of its authorized linked worktree | post-impl-verifiable | bash -c 'set -e; worktree="$1"; test -n "$worktree"; test "$(git -C "$worktree" rev-parse --is-inside-work-tree)" = true; resolved=$(cd -- "$worktree" && pwd -P); top=$(git -C "$worktree" rev-parse --show-toplevel); top=$(cd -- "$top" && pwd -P); test "$resolved" = "$top"; report="$worktree/.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-contract-baseline.md"; parent=$(sed -n "s/^implementation_parent: //p" "$report" \| head -1); commit=$(sed -n "s/^implementation_commit: //p" "$report" \| head -1); recorded=$(sed -n "s/^implementation_worktree: //p" "$report" \| head -1); test "$recorded" = "$resolved"; test "$(git -C "$worktree" rev-parse "$parent^{commit}")" = "$parent"; test "$(git -C "$worktree" rev-parse "$commit^{commit}")" = "$commit"; test "$(git -C "$worktree" rev-parse HEAD)" = "$commit"; test "$(git -C "$worktree" rev-list --parents -n 1 "$commit" \| awk "{print NF}")" -eq 2; test "$(git -C "$worktree" rev-parse "$commit^")" = "$parent"; git -C "$worktree" diff --quiet; git -C "$worktree" diff --cached --quiet; test -z "$(git -C "$worktree" ls-files --others --exclude-standard -- package.json package-lock.json .tad/schemas .tad/workflows/yolo .tad/tests/yolo2)"; n=0; while IFS= read -r f; do n=$((n+1)); case "$f" in package.json\|package-lock.json\|.tad/schemas/yolo-contract.schema.json\|.tad/schemas/yolo-event.schema.json\|.tad/schemas/yolo-state.schema.json\|.tad/schemas/yolo-round.schema.json\|.tad/schemas/yolo-audit.schema.json\|.tad/schemas/yolo-capabilities.schema.json\|.tad/workflows/yolo/*\|.tad/tests/yolo2/*) ;; *) echo "OUT_OF_SCOPE=$f"; exit 1 ;; esac; done < <(git -C "$worktree" diff-tree --no-commit-id --name-only -r "$commit"); test "$n" -gt 0; echo RESULT=PASS' _ "$implementation_worktree" | terminal RESULT=PASS; linked worktree accepted; exact clean HEAD=child; zero untracked implementation files; exact parent; child non-merge; non-empty allowlisted diff including exact package/lock delta | T=0 rc=1: completion/implementation identifiers absent |
| AC13 | Static Node 14/API/import policy passes without claiming real Node 14 runtime proof | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; unset NODE_PATH NODE_OPTIONS; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs compatibility' _ "$implementation_worktree" | terminal RESULT=PASS; exact four entries and recursive local graph; implementation_commit=HEAD; every local blob committed and identical; policy=node14-static-v1; exact VM import boundary; host string-code generation recorded blocked; real Node 14 runtime deferred to Epic Phase 4 | T=0 rc=1: runner absent |
| AC14 | Host and VM code-generation boundaries are live and discriminating | post-impl-verifiable | bash -c 'set -e; cd -- "$1"; unset NODE_PATH NODE_OPTIONS; node --disallow-code-generation-from-strings .tad/tests/yolo2/run-phase1.mjs runtime-boundary' _ "$implementation_worktree" | terminal RESULT=PASS; ordinary VM expression succeeds; host eval, host Function, VM eval and VM Function each throw EvalError; missing CLI flag is separately proven non-PASS | T=0 rc=1: runner absent; author-time host probes PASS |

### 9.1a Exit-Code Negative Controls

Before Gate 3 acceptance, test-runner reviewer MUST independently perform all twenty-six in isolated temp copies and record exact exit codes. Every Node invocation below uses the explicit FR12 CLI flag. Controls 15–26 pass only when the common-form static verifier rejects the mutation or the executed mutation is stopped by `EvalError`; the exact Cycle 5 Round-1 bypasses in controls 24–25 MUST reach the runtime boundary and produce `EvalError`, proving the design does not depend on enumerating their syntax:

1. delete one required fixture → schemas exits 1 or 2 and terminal is not PASS;
2. add unsupported schema keyword → schemas exits 2 with E_SCHEMA_KEYWORD_UNSUPPORTED;
3. flip one transition outcome in the reference model without changing the oracle → transitions exits 1;
4. seed a fresh BOX with all 120 protected files and the unmodified author baseline; first require PASS, then change exactly one protected file byte while keeping the baseline unchanged → require exit 1, terminal RESULT=FAIL and E_LIVE_SURFACE_MISMATCH.
5. create a disposable local Git clone at the implementation commit, add a committed import of `./untracked-helper.mjs` to a copied entry, commit that mutation, then create the helper only as an untracked file; copy the eight valid evidence files and set only compatibility `implementation_commit` to the disposable HEAD → the pinned author verifier must exit 1 with `E_IMPORT_NOT_COMMITTED` for that helper.
6. in another disposable clone, add and commit `import/*comment*/ value from 'external-package'` to a copied entry, copy the valid evidence and set compatibility `implementation_commit` to that disposable HEAD → the pinned author verifier must exit 1 with `E_EXTERNAL_IMPORT` before module execution.
7. repeat control 5 with committed `import/*comment*/('./untracked-helper.mjs')` and an untracked helper → require `E_IMPORT_NOT_COMMITTED`.
8. commit `import/*comment*/('external-package')` in another disposable clone → require `E_DYNAMIC_EXTERNAL_IMPORT`.
9. commit a template expression containing `` `${fs./*comment*/cp(a,b)}` `` in another disposable clone → require `E_FS_CP`.
10. commit syntactically valid camouflage `async function probe(){ const camouflage = /[/*a]/; await import('external-package'); const scanner_closer = '*/' }` in another disposable clone → Acorn parsing must succeed and the pinned verifier must exit 1 with `E_DYNAMIC_EXTERNAL_IMPORT`.
11. commit `import fsAlias from 'fs'; fsAlias.cp(a,b)` → require `E_FS_OBJECT_IMPORT`.
12. commit `import * as filesystem from 'fs'; filesystem.cp(a,b)` → require `E_FS_OBJECT_IMPORT`.
13. commit `import * as filesystem from 'fs'; filesystem.promises.cp(a,b)` → require `E_FS_OBJECT_IMPORT`.
14. commit `globalThis.structuredClone(value)` → require `E_DYNAMIC_CODE`.
15. commit `const load = Function("return import('external-package')"); load()` → require `E_DYNAMIC_CODE` before execution.
16. repeat control 15 with `Function("return import('./untracked-helper.mjs')")`, leaving the helper untracked → require `E_DYNAMIC_CODE` before execution.
17. commit `const load = (() => {}).constructor("return import('external-package')"); load()` → require `E_DYNAMIC_CODE` before execution.
18. commit `const { constructor: C } = (() => {}); const load = C("return import('external-package')"); load()` → require `E_DYNAMIC_CODE` before execution.
19. repeat control 18 with computed key `{['con' + 'structor']: C}` → require `E_DYNAMIC_CODE` before execution.
20. commit `const g = globalThis; const n = 'Fun' + 'ction'; const F = g[n]; const load = F("return import('fs')"); await load()` inside an async function → require `E_DYNAMIC_CODE` before execution.
21. commit `import { default as fsAlias } from 'fs'; fsAlias.cp(a,b)` → require `E_FS_OBJECT_IMPORT`.
22. commit `import fs from 'fs'; const { promises: { cp } } = fs; cp(a,b)` → require `E_FS_OBJECT_IMPORT`.
23. commit `const proto = Object.getPrototypeOf(() => {}); const { value: C } = Object.getOwnPropertyDescriptor(proto, 'constructor'); const load = C("return import('external-package')"); load()` → require `E_DYNAMIC_CODE` before execution.
24. commit `const { __proto__: proto } = (() => {}); const key = 'con' + 'structor'; const C = proto[key]; const load = C("return import('external-package')"); load()` → static scan may pass, but execution with the required CLI flag must stop with `EvalError` before import.
25. commit `const C = Object['con' + 'structor']; const load = C("return import('external-package')"); load()` → static scan may pass, but execution with the required CLI flag must stop with `EvalError` before import.
26. commit `const { getOwnPropertyDescriptor: descriptor } = Object; const proto = (() => {}).__proto__; const C = descriptor(proto, 'constructor').value; const load = C("return import('external-package')"); load()` → require static `E_DYNAMIC_CODE` or runtime `EvalError` before import.

The reviewer, not Blake's implementation author, chooses the exact row/fixture to mutate. The four runner invocations are fixed:

~~~bash
node --disallow-code-generation-from-strings "$BOX/.tad/tests/yolo2/run-phase1.mjs" schemas --root "$BOX" --evidence-dir "$BOX/evidence"
node --disallow-code-generation-from-strings "$BOX/.tad/tests/yolo2/run-phase1.mjs" schemas --root "$BOX" --evidence-dir "$BOX/evidence"
node --disallow-code-generation-from-strings "$BOX/.tad/tests/yolo2/run-phase1.mjs" transitions --root "$BOX" --evidence-dir "$BOX/evidence"
node --disallow-code-generation-from-strings "$implementation_worktree/.tad/tests/yolo2/run-phase1.mjs" live-surface --root "$BOX" --workflow-source "$BOX/.claude/workflows/yolo-epic.workflow.js" --baseline-file "$BOX/live-surface-baseline.md" --evidence-dir "$BOX/evidence"
~~~

For the first three invocations, `BOX` is a fresh absolute directory from `mktemp -d`; the reviewer copies only the implementation commit's `.tad/schemas/`, `.tad/workflows/yolo/`, and `.tad/tests/yolo2/` into it, then performs exactly one named mutation. Control 4 uses another fresh BOX. The reviewer extracts the 120 `<digest><TAB><relative-path>` rows only from the pinned baseline's fenced TSV block, asserts exactly 120 unique paths, creates each parent directory, and copies every corresponding file from `implementation_worktree` while preserving its relative path. It then copies the author baseline unchanged to `$BOX/live-surface-baseline.md`, runs the positive command above, and requires PASS. Only after that PASS may it choose one copied protected file other than the workflow source, append one byte, rerun the identical command, and require exactly `E_LIVE_SURFACE_MISMATCH`, `RESULT=FAIL`, exit 1. Controls 5–26 use twenty-two additional fresh local clones, local-only Git identity, and commits that exist only in those BOXes; they never change the reviewed worktree. Controls 24–25 invoke the mutated committed entry under the CLI flag and require `EvalError`, not a package-resolution error. Editing a baseline row is a separate baseline-digest test and cannot satisfy control 4. Missing files, a baseline-digest error, reuse of a BOX, mutation of the reviewed worktree, or syntax/import failure invalidates the review.

### 9.1b Gate 3 Fresh-Session Protocol

Gate 3 gives each fresh reviewer only this handoff path, the exact `implementation_parent`, `implementation_commit`, and `implementation_worktree`. This is a bootstrap trust boundary: Phase 1 cannot cryptographically attest a harness feature that Phase 4 has not built yet. Therefore Gate 3's live control-plane observation is authoritative and file artifacts are integrity carriers only. If the harness cannot expose two reviewer actor/session/invocation triples that are distinct from the executor and each other, stop BLOCKED.

Raw reviewer session IDs remain receipt/header data and are never used as path segments. Gate 3 computes each `reviewer_carrier_id = SHA-256(UTF-8 reviewer_session_id)` as exactly 64 lowercase hex characters. Before every carrier create/read/normalization, Gate 3 walks all existing path components with no-follow `lstat`, rejects every symlink, and proves both lexical and `realpath` containment below the real `.tad/evidence/reviews/blake/yolo2-phase1/` directory.

The fresh code-reviewer is read-only. Gate 3 observes its live invocation and captures the returned response verbatim into the previously absent coordinator-owned path `.tad/evidence/reviews/blake/yolo2-phase1/code-reviewer-<reviewer-carrier-id>/code-reviewer-response.md`; the reviewer itself does not write files. The review prompt requires exactly one occurrence of each header field `reviewer_actor_id`, `reviewer_session_id`, `reviewer_invocation_id`, `implementation_parent`, `implementation_commit`, `implementation_worktree`, `VERDICT: PASS|FAIL`, and `P0_COUNT: <nonnegative integer>`. Gate 3 validates those fields against its observed invocation and exact implementation, and can proceed only with `VERDICT: PASS` and `P0_COUNT: 0`.

The fresh test-runner MUST:

1. verify the parent/child/worktree binding from AC12 before reading generated evidence;
2. create a fresh, previously absent partition `.tad/evidence/reviews/blake/yolo2-phase1/test-runner-<reviewer-carrier-id>/`; inside it create `independent-api-verifier.mjs`, `independent-api-verifier-output.txt`, and `test-runner.md`, without copying any Blake test helper;
3. import only the documented public exports of `schema-validator.mjs` and `reference-model.mjs`, generate fresh records in code, and independently assert all six record classes, all 24 FR6 cases, all ten digest components and one-use authority grants;
4. run all twenty-six §9.1a controls in twenty-six fresh BOX directories and record command, mutation, exit code and terminal line or required `EvalError`;
5. independently reproduce the 15-row T=0 VM sandbox and 120-row live-surface comparison from the pinned Alex inputs;
6. repeat FR12 directly with `NODE_PATH` and `NODE_OPTIONS` unset, include the exact four compatibility assertion IDs, and add `runtime-boundary-5` for the ordinary VM positive control plus four host/VM `EvalError` negatives;
7. write `independent-api-verifier-output.txt` with fields `reviewer_actor_id`, `reviewer_session_id`, `reviewer_invocation_id`, `implementation_parent`, `implementation_commit`, `implementation_worktree`, `verifier_sha256`, and `assertion_manifest_sha256`, followed by raw assertions and exactly one terminal `RESULT=PASS|FAIL|ERROR` line;
8. write `test-runner.md` with exactly one occurrence of the same six identity/implementation header fields and exactly one standalone `VERDICT: PASS|FAIL` line. Any mismatch, missing assertion, invalid mutant, reused BOX, or inability of Gate 3 to observe the same live actor/session/invocation is FAIL.

The exact execution command is:

~~~bash
cd -- "$implementation_worktree"
unset NODE_PATH NODE_OPTIONS
reviewer_carrier_id=$(printf %s "$reviewer_session_id" | shasum -a 256 | awk '{print $1}')
node --disallow-code-generation-from-strings ".tad/evidence/reviews/blake/yolo2-phase1/test-runner-$reviewer_carrier_id/independent-api-verifier.mjs" --root "$implementation_worktree" --implementation-parent "$implementation_parent" --implementation-commit "$implementation_commit"
~~~

After both live reviewers return, Gate 3—not Blake's executor loop—normalizes the code-review response and the three test-runner files to the fixed manifest paths and writes `gate3-review-receipt.json`. Every source partition and destination is create-only and no-follow: if any path already exists, any component is a symlink, or either real path escapes the review base, Gate 3 stops ERROR rather than reading, replacing, merging, or appending it. Normalization is byte-for-byte copy, not summarization.

The receipt's closed fields are: `schema_version`, `attestation_mode=harness_observed`, `executor_actor_id`, `code_reviewer_actor_id`, `code_reviewer_session_id`, `code_reviewer_invocation_id`, `code_reviewer_carrier_id`, `code_reviewer_source_path`, `code_reviewer_response_sha256`, `code_reviewer_output_sha256`, `code_reviewer_verdict`, `code_reviewer_p0_count`, `test_runner_actor_id`, `test_runner_session_id`, `test_runner_invocation_id`, `test_runner_carrier_id`, `test_runner_source_dir`, `test_runner_verifier_sha256`, `test_runner_output_sha256`, `test_runner_report_sha256`, `test_runner_verdict`, `implementation_parent`, `implementation_commit`, `implementation_worktree`, `assertion_manifest_sha256`, `direct_api_assertion_ids`, and `negative_control_ids`.

`direct_api_assertion_ids` is exactly, in lexicographic order: `baseline-15`, `compatibility-4`, `digest-10`, `grant-one-use`, `live-surface-120`, `mutations-3-importable`, `runtime-boundary-5`, `schemas-42-fresh`, `transitions-24-fresh`. `negative_control_ids` is exactly, in lexicographic order: `ambient-object-computed-constructor`, `comment-separated-dynamic-external`, `comment-separated-dynamic-untracked`, `comment-separated-external-import`, `constructor-dynamic-external`, `fs-default-alias-cp`, `fs-named-default-alias-cp`, `fs-namespace-alias-cp`, `fs-nested-destructure-cp`, `fs-nested-promises-cp`, `function-dynamic-external`, `function-dynamic-untracked`, `global-alias-computed-function`, `global-structuredclone`, `live-protected-file-byte`, `missing-fixture`, `objectpattern-computed-constructor-external`, `objectpattern-constructor-external`, `proto-computed-constructor-external`, `reflection-constructor-external`, `reflection-destructured-constructor-external`, `regexp-comment-camouflage-dynamic-external`, `template-comment-fs-cp`, `transition-oracle-flip`, `unsupported-schema-keyword`, `untracked-local-module`. `assertion_manifest_sha256` is `04e43d284c529b92484de96ce5141a8205bde859c30e5da45d56b4a7bba75180`, computed from UTF-8 canonical JSON with keys `direct_api_assertion_ids` then `negative_control_ids`, arrays in the order just specified, no whitespace, and no trailing newline.

Gate 3 compares both receipt identities to the live harness tool results, asserts they differ from the executor and each other, and checks both verdicts before recording PASS. It then records the same identities, implementation binding, verdicts, P0 count, and hashes in `gate3-report.md`. AC11 uses the pinned Alex-owned receipt verifier to validate every file/hash/assertion binding, but explicitly does not manufacture provenance from files.

### 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| Cycle 1 code-reviewer R1 | P0 incomplete event grammar; P1 fixture count, commit binding, Node floor; P2 Epic filename | §4.4, FR6, §7.1, NFR, AC12, Epic Phase 1 | Closed by Cycle 1 R2 |
| Cycle 1 test-runner R1 | P0 self-certification and dependency gap; P1 authority cases, commit binding, negative controls, provenance | FR6, FR9–FR11, AC9–AC12, §9.1a–b | Partially closed in Cycle 1 |
| Cycle 1 code-reviewer R2 | P0 reviewer-write contradiction, unavailable Node 14 route, non-discriminative live-surface BOX; P1 worktree execution | Cycle 1 Round-2 evidence | Cycle 1 blocked; retained permanently |
| Cycle 1 test-runner R2 | P0 fresh-session provenance not computably bound; P1 external imports, mutation coverage, live-surface control | Cycle 1 Round-2 evidence | Cycle 1 blocked; retained permanently |
| Cycle 2 code-reviewer R1 | P0 code-review result not receipt-bound; linked worktree rejected; P1 direct import scan; P2 run path drift | FR11–FR12, AC11–AC12, §9.1b, architecture audit | R1 findings closed by Cycle 2 R2 |
| Cycle 2 test-runner R1 | P0 tested HEAD/clean worktree not commit-bound; code-review chain absent; P1 recursive imports and exact mutation cases | FR8, FR11–FR12, AC1–AC13, §9.1a–b | R1 findings closed; R2 found interacting untracked-module P0 |
| Alex integration check C2 R1 | Baseline-row mutation is intercepted by baseline digest and cannot prove surface mismatch | §9.1a complete 120-file BOX + protected-file-byte mutation | Closed by Cycle 2 R2 |
| Cycle 2 code-reviewer R2 | R1 P0 closure plus interacting changes | Cycle 2 final code-review evidence | PASS; three non-P0 follow-ups |
| Cycle 2 test-runner R2 | Untracked local import can be tested without belonging to certified commit | Cycle 2 final test-runner evidence | Open P0 — blocks Gate 2 |
| Human Cycle 3 authorization | Open a fresh review cycle; preserve prior failures | User reply `1`, 2026-08-24 | Cycle 3 active; max two rounds |
| Cycle 3 code-reviewer R1 | Comment-separated dynamic import bypasses traversal and Git binding | FR12, author verifier normalized dynamic scan, controls 7–8 | Redesigned; Cycle 3 R2 verification pending |
| Cycle 3 test-runner R1 | Dynamic/template comment bypass; symlink escape in reviewer carriers | FR11–FR12, controls 7–9, no-follow + realpath receipt verification | Redesigned; Cycle 3 R2 verification pending |
| Cycle 3 code-reviewer R2 | Round-1 repair closure and interactions | Cycle 3 final code-review evidence | PASS; no residual P0/P1 |
| Cycle 3 test-runner R2 | RegExp literal can camouflage a real dynamic import from comment normalization | Cycle 3 final test-runner evidence | Open P0 — blocks Gate 2 |
| Human Cycle 4 authorization | Open a fresh review cycle and permit a pinned mature parser dependency | User reply `1`, 2026-08-24 | Cycle 4 active; max two rounds |
| Cycle 4 code-reviewer R1 | fs aliases bypass forbidden API; dynamic code hides imports | FR7, FR11–FR12, controls 11–17 | Redesigned; Cycle 4 R2 verification pending |
| Cycle 4 test-runner R1 | dynamic code P0; alias/signature P1 | FR7, FR9, FR11–FR12, AC9–AC10, controls 11–17 | Redesigned; Cycle 4 R2 verification pending |
| Cycle 4 code-reviewer R2 | ObjectPattern destructuring retrieves inherited constructor | Cycle 4 final code-review evidence | Open P0 — blocks Gate 2 |
| Cycle 4 test-runner R2 | aliased computed `globalThis` retrieves Function; nested/default fs gaps | Cycle 4 final test-runner evidence | Open P0 + P1 — blocks Gate 2 |
| Human Cycle 5 authorization | Open a fresh review cycle for capability-flow repair | User reply `1`, 2026-08-24 | Cycle 5 active; max two rounds |
| Cycle 5 Round 1 code-reviewer | Inherited `__proto__` plus computed constructor name bypasses the enumerated AST policy | Cycle 5 Round-1 evidence | Open P0; static-blacklist strategy retired |
| Cycle 5 Round 1 test-runner | `Object['con' + 'structor']` bypasses the enumerated AST policy | Cycle 5 Round-1 evidence | Open P0; static-blacklist strategy retired |
| Cycle 5 runtime-boundary repair | Required host CLI flag, exact VM sandbox with code generation disabled, runtime-boundary suite, controls 24–26 | FR7, FR11–FR12, AC8–AC14, §9.1a–b | Reviewed in final round |
| Cycle 5 Round 2 code-reviewer | Runtime-boundary repair and Round-1 closure | Final code-review evidence | PASS; no P0/P1/P2 |
| Cycle 5 Round 2 test-runner | `Script` alias plus `runInThisContext` creates an uncounted second VM execution path; missing-flag claim unbound | Final test-review evidence | Open P0 + P1 — blocks Gate 2 |

### Experts Selected

1. code-reviewer — mandatory; review file list, Node >=14 design, trust boundaries, and scope.
2. test-runner — execute/dry-run every §9.1 command and attempt false-green variants.

### Overall Assessment

FAIL — DESIGN REVIEW CYCLE 5 CAP EXHAUSTED. The runtime-boundary direction closes both Round-1 constructor bypasses, and the final code reviewer passed it. The final test reviewer nevertheless proved that the allowed `Script` binding can be aliased and used with `runInThisContext`, creating a second host-realm script that the CLI flag intentionally does not block. It also found that the claimed missing-flag negative is not command/receipt-bound. No Blake handoff or implementation is authorized. A new cycle, if the human authorizes one, must close the VM capability itself and add both exact regressions before any further review.

---

## 10. Important Notes

### 10.1 Critical Warnings

- Do not edit any protected live file, even to add comments or tests.
- Do not regenerate Alex baseline after a mismatch.
- Modify `package.json` only by adding exact `devDependencies.acorn: "8.18.0"`; create only the exact npm lockfile v1. Any other manifest, lockfile, package, version, resolved URL, integrity, or lifecycle-script path fails AC9/AC10.
- Do not treat package npm test output “No tests yet” as evidence.
- Do not put expected verdicts inside fixture records.
- Do not catch ERROR and continue to a PASS terminal line.
- Do not claim real harness quality, compact recovery or token savings from synthetic adapters.
- Do not implement Phase 2 I/O/kernel features.

### 10.2 Known Constraints

- The narrow validator is contract-scoped, not a general JSON Schema engine.
- The v1 baseline is deterministic control-logic replay, not live LLM evaluation.
- Phase 1 schemas may evolve only through a new contract version; silently accepting unknown versions is forbidden.
- Evidence under .tad/evidence may be gitignored; completion must still list exact paths and reviewers must read them from the worktree.

### 10.3 Sub-Agent Use

Blake should use exactly two independent reviewers after implementation:

- code-reviewer
- test-runner

They are read-only for implementation, author baselines, Blake-generated evidence, completion, handoff, and other reviewers' files. The Gate 3 test-runner has one narrow exception: it may create only its own previously absent SHA-256-carrier partition under `.tad/evidence/reviews/blake/yolo2-phase1/`; raw harness session IDs are never path segments, symlink components are forbidden, and lexical plus realpath containment is mandatory. It may not modify or replace an existing path. The code-reviewer remains fully read-only; after observing its live return, Gate 3 alone creates the previously absent coordinator-owned response carrier. Gate 3 then performs create-only no-follow byte normalization and receipt writing. Both reviewers report fresh actor/session/invocation provenance in their review header.

---

## 11. Learning Content

### 11.1 Why a reference model exists before the kernel

The reference model makes completion semantics determinate without prematurely choosing storage or concurrency mechanics. Phase 2 can be tested against it. If the reference model itself starts writing events or managing locks, the separation has failed.

### 11.2 Why fixtures cannot carry expected results

A fixture that supplies both question and answer can remain internally consistent while being wrong. This handoff fixes the expected classification table independently; mutation tests prove the oracle distinguishes unsafe implementations.

### 11.3 Why the baseline belongs to Alex

If the implementer captures the “before” state after starting work, it can redefine its own constraint. The pinned manifest and its handoff-level digest make the baseline an author-side carrier.

---

## 12. Sub-Agent使用记录

Design Cycle 1 Round 1 used the two pre-existing read-only reviewers required by Gate 2:

- `/root/yolo2_architecture` — code-reviewer; CONDITIONAL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-round1.md`.
- `/root/yolo2_quality` — adversarial test-runner; FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-round1.md`.

Alex resolved the Round 1 findings in the normative event grammar, closed fixture layout, dependency/live baselines, author-owned verifier, exact parent/commit/worktree binding, fixed temp-copy controls, and Gate 3 fresh-session direct-API protocol. Round 2 is limited to these fixes, interactions among them, and changed sections. No third round is allowed.

Design Cycle 1 Round 2 used the same two reviewers in incremental read-only mode:

- `/root/yolo2_architecture` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-round2.md`.
- `/root/yolo2_quality` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-round2.md`.

The Design Cycle 1 two-round cap was exhausted, and that failure remains recorded. The human explicitly authorized Design Cycle 2 with a changed Node 14 proof boundary.

Design Cycle 2 Round 1 reused the same two independent read-only reviewers:

- `/root/yolo2_architecture` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle2-round1.md`.
- `/root/yolo2_quality` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle2-round1.md`.

Alex integrated their findings plus the independently detected live-surface false-negative path into the pinned verifiers, exact clean-HEAD/worktree binding, recursive compatibility policy, closed mutation evidence, dual reviewer carriers, and complete-surface negative control. Design Cycle 2 Round 2 is the final incremental review and is limited to those changes and their interactions; there is no third round.

Design Cycle 2 Round 2 final results:

- `/root/yolo2_architecture` — PASS; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle2-round2.md`.
- `/root/yolo2_quality` — FAIL with one P0; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle2-round2.md`.

The two-round cap is exhausted. Gate 2 is BLOCKED until the human explicitly authorizes a new design-review cycle; Alex may not silently repair and self-certify the untracked-module boundary.

The human explicitly authorized Design Cycle 3 by selecting option 1 on 2026-08-24. Alex revised only the handoff, architecture audit, and two Alex-owned acceptance verifiers. Cycle 3 review evidence will use `*-cycle3-roundN.md`; the same two independent reviewers are reused, and Cycle 3 again has a hard two-round cap.

Design Cycle 3 Round 1 results:

- `/root/yolo2_architecture` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle3-round1.md`.
- `/root/yolo2_quality` — FAIL; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle3-round1.md`.

Alex moved every dynamic-import pattern to the normalized source stream, added template-expression brace tracking, expanded the negative controls from six to nine, and added no-symlink plus realpath containment. Cycle 3 Round 2 is final and limited to these fixes/interactions; no third round is allowed.

Design Cycle 3 Round 2 final results:

- `/root/yolo2_architecture` — PASS; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle3-round2.md`.
- `/root/yolo2_quality` — FAIL with one P0; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle3-round2.md`.

The Cycle 3 cap is exhausted. Gate 2 remained BLOCKED. The human then explicitly authorized Design Cycle 4 and chose the mature-parser direction by selecting option 1 on 2026-08-24.

For Cycle 4, Alex selected exact `acorn@8.18.0` after comparing Acorn, `@babel/parser`, Esprima, and the rejected bespoke scanner. Identity, published behavior, tarball contents, install-script surface, typosquat probes, exact integrity, and npm lockfile v1 semantics are recorded in `.tad/evidence/research/yolo2-parser/2026-08-24-parser-dependency-decision.md`. The author verifier now uses Acorn AST/tokens and independently proves the exact committed parent/child dependency delta; the receipt contract adds a tenth RegExp-camouflage control. Cycle 4 retains a hard two-round cap.

Design Cycle 4 Round 1 used the same two independent read-only reviewers:

- `/root/yolo2_architecture` — FAIL with two P0s; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle4-round1.md`.
- `/root/yolo2_quality` — FAIL with one P0 and two P1s; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle4-round1.md`.

Alex replaced literal fs-name checks with import-binding/alias/member-chain checks, fail-closed dynamic-code rules plus one exact FR7 wrapper, live npm registry-signature verification, and controls 11–17. Cycle 4 Round 2 is final and limited to these repairs and their interactions; no third round is allowed.

Design Cycle 4 Round 2 final results:

- `/root/yolo2_architecture` — FAIL with one P0; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle4-round2.md`.
- `/root/yolo2_quality` — FAIL with one P0 and one P1 group; evidence: `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle4-round2.md`.

The Cycle 4 cap is exhausted. Gate 2 is BLOCKED. A future authorized cycle must treat `globalThis`, fs objects, and dynamic constructors as propagated capabilities across declarations, assignments, imports, member access, and recursive destructuring, then add the exact final-round bypasses as permanent controls. Alex may not apply and self-certify that repair in this cycle.

The human explicitly authorized Design Cycle 5 by selecting option 1 on 2026-08-24. Round 1 reused the same two independent reviewers. Both returned FAIL/P0: the architecture reviewer demonstrated inherited `__proto__` followed by a computed constructor property; the test reviewer demonstrated `Object['con' + 'structor']`. Reports are retained at `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle5-round1.md` and `test-runner-cycle5-round1.md`.

Alex therefore retired the exhaustive-static-blacklist claim. The final repair requires the explicit Node CLI string-code-generation prohibition, moves the sole frozen workflow execution into an exact least-authority VM context with both string and WebAssembly generation disabled, adds `runtime-boundary` to the runner and independent review, and makes the two Round-1 bypasses permanent controls 24–25. The supporting primary-source note is `.tad/evidence/research/yolo2-parser/2026-08-24-node-codegen-boundary.md`. Cycle 5 Round 2 is final and limited to this repair and its interactions; no third round is allowed.

Cycle 5 Round 2 final results:

- code-reviewer: PASS, P0=0, no P1/P2; evidence `.tad/evidence/reviews/alex/yolo2-phase1/code-reviewer-cycle5-round2.md`.
- test-runner: FAIL, P0=1, P1=1; evidence `.tad/evidence/reviews/alex/yolo2-phase1/test-runner-cycle5-round2.md`.

The P0 demonstrates `const S = Script; new S('40 + 2').runInThisContext()` executes despite the host CLI flag while escaping the direct-use counters. The P1 shows AC14's missing-flag claim lacks a closed command/receipt assertion. The Cycle 5 cap is exhausted; Gate 2 is BLOCKED and Alex may not apply or self-certify the next repair without new human authorization.
