# JC-02 — Gate 3 domain 评审未派发（reviewer-dispatch-omission）

- **id**: JC-02
- **来源指针**: `.tad/evidence/escape-log.md` 2026-10-22 行（在册逃逸记录）＋`.tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md`（conductor 台账，记发现时点与 Cora 自认遗漏）。dispatch_id: 来源件未载独立 dispatch_id；链内标识＝EPIC tad-update-flow Phase 1，Gate 4 派发 p1-y7-1 的前置检查（cora-check.sh gate3-files）时点发现。
- **失败类别**: `reviewer-dispatch-omission`（取 INDEX.md class 受控表）
- **被测判者面**: 评审提示／路由——`.agents/skills/cora/references/conductor-protocol.md` step_Y6 3b（Gate 3 镜头组成按 risk_triggers 定）＋`.tad/templates/review-contract.md` §8（评审分工）。版本标识：TAD 发布版 4.0.6（事件时点 2026-10-22 在行版本；`disk-read` 自 NEXT.md 版本行）。
- **冻结输入**: 见下方「冻结输入快照」——conductor 台账中 Gate 3 收束至 Gate 4 派发的相邻行，以及 escape-log 该行原文。源路径与内容 sha256（建集时点 2026-10-27 复算）：`.tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md` sha256: 465a29f1a0e3dae8d1b393a2c0424ab3cc0d0ff1f70bb262b1e5b4c27637d37e；`.tad/evidence/escape-log.md` sha256: d467cdaaffeff2002a458ab45b7e1cd913e4671046a7d4e586cb6409f4627b96（此为本 phase Step 3 表头改动前的建集时点哈希）。
- **期望抓获**（finding 形态）:
  - location: 冻结输入中 Gate 3 收束行（「Y6 r3: run PASS p0 0 … Gate 3 settled」）与 Gate 4 派发行的相邻处。
  - scenario: 该 phase 的 risk_triggers 含 data 与 security，按镜头组成规则 Gate 3 自第 1 轮起须含 domain（security/data）评审；实际派发只有 run＋consistency 两镜头，domain 未派。期望 finding＝「Gate 3 镜头集不完整：risk_triggers [data, security] 要求 domain 评审而未派发；Gate 4 不得先行」。
- **干净对照**: 个案对照 `(none yet)`；集合级对照见 INDEX.md 登记 CTL-01、CTL-02。
- **metric_candidate**: no

## 冻结输入快照（逐字摘录）

conductor 台账（`.tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md`）相邻三行：

> - Y6 r3: run PASS p0 0 (AC17 fixed; flake not new). Gate 3 settled. cora-check gate3-files run. p1-y7-1 Gate 4 (Alex, sonnet): real Claude Code session in a throwaway multi-platform v4.0.5 project (one headless session counted as a normal dispatch; no money beyond the plan).
> - gate3-files: MISSING phase1-impl-review-domain.md. Cora's miss: risk_triggers lists data+security, so Gate 3 needed a domain reviewer from round 1 (step_Y6 3b); the new pre-check caught it before Gate 4. Escape-log line written. p1-y6-r1-domain (security/data, sonnet) on HEAD e21d3aca.
> - p1-y6-r1-domain CONDITIONAL p0 0 (5 P1: …). gate3-files OK. Books updated. p1-y7-1 Gate 4 (sonnet).

escape-log 行原文（`.tad/evidence/escape-log.md`，2026-10-22 行，建集时点形态）：

> | 2026-10-22 | Gate 3 domain review not dispatched for tad-update-flow Phase 1 (risk_triggers data, security) | cora-check.sh gate3-files before Gate 4 | Gate 3 (step_Y6 3b, Cora routing) | .tad/evidence/journal/conductor-tad-update-flow-2026-10-22.md |
