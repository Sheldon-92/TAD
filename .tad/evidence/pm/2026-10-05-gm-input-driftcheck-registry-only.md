# 本体输入登记 — driftcheck 对 registry-only pack 的 (c) 假阳性（GM 上报，2026-10-05）

- 来源：GM 上报（3.0.1 刷新批第三件）：pack-registry-driftcheck 把 Voice Studio 的 product-thinking 判为「(c) 登记无投影」，但其实测：该 pack 的 skill 树在目标仓与源逐字节一致、SKILL.md 在位；源仓基线同跑 (b) 11 项与目标仓逐字相同、该 pack 在源仓同样被标 source-only。(c) 源于其 SKILL.md 不合 B 探针 frontmatter 口径＋目标仓 C 集恒为 0 的设计形态。
- 风险：与 v3.0.1 新断言（scan-packs 登记⊆投影）叠加后，易被误读为「投影缺件判红」。
- 证据：`Voice Studio/.tad/evidence/install-checks/2026-10-05-align-301-report.md`。
- GM 建议方向：driftcheck 口径里对 registry-only pack 单列形态（如 (r) registry-only），与真缺件的 (c) 区分。
- 本席登记：列入**下个本体批候选清单**，随批处理、不急。此件与本批件 5 新断言的判读面相邻，下批设计时一并厘清三层口径——源仓断言（登记⊆投影，本批已立）／目标仓 driftcheck 形态分类／探针 frontmatter 口径，三者对「设计形态」与「真缺件」的区分必须一致，不许一面判红一面判绿。
