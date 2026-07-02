# Gate 4 Acceptance Report — trajectory-eval-p2

**Date:** 2026-07-02 · **Accepter:** Alex (with human approval) · **Verdict:** ✅ PASS
**Prerequisite:** Gate 3 PASS (COMPLETION-20260702-trajectory-eval-p2.md, commits aa8aeaf + 8d7b767)

## Independent Raw Recompute (Alex, from 24 result JSONs + golden frontmatter — NOT Blake's summary)

| Metric | Blake reported | Alex recompute | 判定 |
|--------|----------------|----------------|------|
| R2 GATE within-1 (D1,D2,D3,D5) | 94.1% | 32/34 = 94.1% (misses: GS-10.D5 g5→j3, GS-07.D3 g2→j4) | ✅ ≥80% |
| Valid pairs floor | — | 34 ≥ 27 | ✅ |
| R2 contrast (D4-excl) | 1.75 | GS-11 4.50(n=4) − GS-03 2.75(n=4) = 1.75 | ✅ ≥1.5 |
| R2 contrast (D4-incl, 参考) | 1.40 | 1.40 | （口径裁决见下） |
| R2 anti-anchor GS-06 | 3.75 | 3.75(n=4) | ✅ ≥3.5 |
| Min-dims (GS-11/03/06) | — | 4/4/4 ≥3 | ✅ |
| R1 within-1 | 88.2% | 30/34 = 88.2% | ✅ 一致 |
| R1 contrast 双口径 | 1.25 | D4-excl 1.25 / D4-incl 1.20 均 FAIL | ✅ 无跨轮口径挑选 |
| Stability probe | max Δ=1 | 报告表核对：GS-11 全 0，GS-09 三维 Δ=1 | ✅ 无 instability |

## P1 裁决：对比对 D4 口径
Blake 用 D4-excluded（1.75 PASS）并主动上报歧义。裁决 **接受**，依据：
1. Phase 1 预声明（先于任何 judge 运行）："D4 data-poor 不参与止损判定"——对比对是止损门
2. 口径跨轮一致，round1 两种口径均 FAIL → 非 metric shopping
3. 有效性前置（min-dims ≥3）在排除 D4 后仍满足
记录为 gate4_delta（规格歧义），教训写入 ac-verification.md L2 pattern。

## AC 机械验证（Alex 亲跑）
AC1 五标记 ✅ · AC2 语法+样例 ✅ · AC3 双轮 12+12 全部通过 all() 校验、0 EVAL_ERROR ✅ ·
AC8 verdict: PASS + Final Scoring Basis + Stability Probe 节 ✅ · AC9 anti-Goodhart 0 ✅ ·
AC10 bundle 零泄漏 ✅ · AC11 基线 diff 0 ✅ · AC12 全部 ≤1500 行 ✅ · AC13 探针表 ✅
AC7: wall-clock 全记录；token DEGRADED（预声明允许的 proxy 路径）

## 完整性检查
- **Golden 冻结验证**：`git diff aa8aeaf~1..8d7b767 -- .tad/eval/golden-set/` 为空 ✅
- **Rubric 未动**：D2 修正落在 judge-prompt.md（Evidence Scope Rule）——属 judge prompt 迭代的合法通道 ✅
- Layer 2 audit: PASS, DISTINCT_COUNT=2 ≥ 阈值

## Knowledge Assessment
- A (Blake claims): KA 2 条发现 + Journal 在 completion ✅（发现 #2 与 Alex 裁决独立收敛于同一教训）
- B (raw recompute): 全部定量声明重算一致 ✅
- C (Alex own): 新 L2 entry → patterns/ac-verification.md "A Pre-Declared Exclusion Must Be Restated in Every Gate Metric Definition - 2026-07-02"

## Carry-forward to Phase 3
1. **判别余量薄**：对比对 1.75 vs 门槛 1.5（余量 0.25），单维探针 Δ 可达 1 — ROI 报告引用判别力时注明
2. **GS-07.D3 golden 标签存疑**：Phase 1 盲评（3/3）与 Phase 2 judge（4）三次独立评估均高于 golden 的 2 — Epic 结束后的 golden 维护周期中复审该标签（Epic 期间冻结不动）
3. Judge 生产化输入：judge-prompt.md 的 D2 Evidence Scope Rule 是校准后产物，Phase 3 集成时不得改动 judge prompt（改动 = 校准失效，需重新校准）
4. Token 计量 DEGRADED 为永久状态（Agent tool 不稳定回报）——Phase 3 的 judge 调用成本以 wall-clock + bundle 行数为准
