# BUNDLE 2026-10-27 — 第二轮回放判者输入（P4-2/P4-4 落盘文本）

备包：dispatch r4-p4-impl-1 Step 7a。本文件是判者的全部输入，由四部分组成：被测落盘文本（`.tad/templates/review-contract.md` 实施后版本的 §2 与 §4，逐字）、artifact A 与 artifact B 的冻结输入快照、artifact C1 与 C2 的对照文件路径。

## 被测文本 — review-contract.md §2（落盘逐字）

### 2. A finding
Each P0 and P1 carries:
- `location`: file:line, or the command
- `scenario`: input or situation -> wrong result
- `blocks`: what it blocks (§3)
- `checked`: the lines read or the command run, with its result; a P0 without `checked` is not a P0
- `kind: empirical | design`
- `origin: introduced_by_fix | missed_earlier | preexisting` (required from round 2; in round 1 only `preexisting` is marked: the defect was there before the change)
- Gate 2 P0s also carry `class:` (short name of the rule or mechanism the defect breaks), `repeat_of:` (earlier review file + P0 id that named the same class, or an earlier premise file of the phase, else empty) and `approach: enumerate` when the P0 is against a design that lists the bad cases it blocks and lets the rest pass
- an `empirical` P0 whose `checked:` holds the reviewer's own run and its output also carries `reproduced: yes`
Read the object and the reference first and form your own judgment; read the author's own account (completion report, handoff rationale) after.
Empty review allowed: "no P0, no P1" is a valid result. There is no minimum number of findings; do not pad.

A veto-grade conclusion (FAIL, a return, a not-feasible call) whose supporting findings carry neither location nor scenario is recorded as a remark, not a finding: it does not count toward p0_count, and no routing decision may rest on it (what a finding must carry is stated in this section and §3). Precedence: the writer applies this classification before sealing the verdict header — a remark is excluded from p0_count and from every sum §7 computes over headers (round arithmetic, the shrinking test, the spike sum). A header that counts a remark breaks §1's self-consistency rule: the file counts as not returned (§1) and is re-issued as a format defect before any routing or arithmetic uses it.

## 被测文本 — review-contract.md §4（落盘逐字）

### 4. The reference
Judge against the Epic's `## Requirement` and `## Result contract` plus the handoff (Epic and handoff tiers); the handoff's §1.5 Requirement and §9 (direct /alex without an Epic); the journal line (simple tier: request, blocks, verification, `risk_triggers`). A finding that the change departs from the requirement names the requirement line.

Citation discipline (applies in parallel with the reference rule above; it renames nothing in it): cite only originals this chain actually read, and cite with section numbers. Citing an original the chain did not read is itself a finding. The finding is recorded in the review file of the reviewer who spots it, naming the file that carries the citation and the citation as written; when the carrying file is a completion report, the Gate 3 run reviewer also appends one line to that report's Citation findings section (date, the reviewer's dispatch_id, the citation as written, and the read-list fact). The Citation findings section and the gate3_verdict marker are the run reviewer's only write rights in a completion report.

## Artifact A（冻结输入快照）

## 冻结输入快照（2026-10-12 收口件裁定正文，逐字摘录原文主体）

> ## 一、Phase 3 Gate 4 条件 1 —— 销账，Phase 3 升 PASS
>
> 条件 1 原文（`reviews/epic-p3-runtime-20261006/gate4-alex.md`）：「2026-10-10 配额恢复后 PM 派补跑，回填 codex transcript＋字段表＋step3f 登记」。
>
> - 补跑：已实跑（2026-10-09，`.tad/evidence/live-regression/codex-20261009.md`，任务链两跑均 PASS——默认信任跑与信任绕过跑；raw 指针在 `live-regression/raw/20261009/`）。
> - 字段表：六字段齐（3.3.0 step3f 登记件逐项核「yes (1 to 6)」）。
> - step3f 登记：已登记（`.tad/evidence/releases/3.3.0-step3f-registration.md`，2026-10-10），且如实保留两点：默认信任下写时 hook 未触发之保留点、交互信任审查未测——此二点属台账 trace/hooks 行的既有状态面，非条件 1 的未竟项。
> - 判：条件 1 销账；**Epic Phase 3 Gate 4 由 CONDITIONAL 升 PASS**。Epic 四 Phase 至此全 PASS。
>
> ## 二、TASK-20260916-CODEX-LEDGER-REVERIFY —— 按其自身判据关票
>
> - 「Gate 4 验收时 waiver 自动失效（AC21 回归 PASS）」：本裁定即该单 Gate 4 验收，验收结论 PASS，2026-09-16 waiver 随之失效。
> - 判：**票 CLOSED**，票面已加关票节。

（摘录范围＝原文 §一全文与 §二判行；背景节与 §三连带节从略，全文以源路径＋sha256 为准。）

## Artifact B（冻结输入快照）

## 冻结输入快照（逐字摘录）

conductor 台账（`.tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md`）相邻三行：

> - Y6 r3: run PASS p0 0 (AC17 fixed; flake not new). Gate 3 settled. cora-check gate3-files run. p1-y7-1 Gate 4 (Alex, sonnet): real Claude Code session in a throwaway multi-platform v4.0.5 project (one headless session counted as a normal dispatch; no money beyond the plan).
> - gate3-files: MISSING phase1-impl-review-domain.md. Cora's miss: risk_triggers lists data+security, so Gate 3 needed a domain reviewer from round 1 (step_Y6 3b); the new pre-check caught it before Gate 4. Escape-log line written. p1-y6-r1-domain (security/data, sonnet) on HEAD e21d3aca.
> - p1-y6-r1-domain CONDITIONAL p0 0 (5 P1: …). gate3-files OK. Books updated. p1-y7-1 Gate 4 (sonnet).

escape-log 行原文（`.tad/evidence/escape-log.md`，2026-10-22 行，建集时点形态）：

> | 2026-10-22 | Gate 3 domain review not dispatched for tad-update-flow Phase 1 (risk_triggers data, security) | cora-check.sh gate3-files before Gate 4 | Gate 3 (step_Y6 3b, Cora routing) | .tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md |

## Artifact C1（对照，文件路径）

`.tad/evidence/yolo/r4-batch/phase2-gate2-review-risk.md`

## Artifact C2（对照，文件路径）

`.tad/evidence/yolo/r4-batch/phase2-gate2-review-consistency.md`
