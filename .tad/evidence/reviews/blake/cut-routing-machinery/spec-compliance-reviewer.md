# Spec Compliance Review — HANDOFF-20260805-cut-routing-machinery (v2, P2+P3 合并单)

**Reviewer**: spec-compliance-reviewer (Layer 2, Group 0 — blocking)
**Model 身份自报**: harness=claude-code | model=deepseek-v4-flash | route=native
（环境未注入可验证的模型自报载体；按 L4 模板约定自报运行时信息。）
**Date**: 2026-08-05 | **HEAD 锚**: 6a7cef0b22fddcd050af53949fd43e3c8ca0a36a（核验时未移动）
**方法**: 逐条实跑 handoff §4 命令原文（Bash tool 直接跑 zsh，未包 bash -c），全部判定基于执行输出，无读代验。

---

## 一、AC 逐条结果（6 条全部实跑）

| AC | 结果 | 实测输出摘要 |
|---|---|---|
| AC1 | **PASS** | 两个 digest 全绿：alex-lite 178 行 md5=13b0b87bb2412d81244979c47dc202a1；blake-lite 251 行 md5=0afa760c84d60bbbf5b018efd749cd5b |
| AC1b | **PASS** | 5 个 digest 全绿：AGENTS.md 135/9862c78301ed4e7d170f036a259e1462；INSTALLATION_GUIDE.md 140/f9b8bd543cee31341bc041cd524159b1；CLAUDE.md 109/c358c0c0c0bcd49602b43509c77f91c6；tad-help ×2 各 231/dfd2ba7abd2c8a002132da9dc28218f1 |
| AC2 | **PASS** | 负向锚全部 0 命中（28 组 lite-skill 锚 + 9 组 AGENTS/tad-help 锚 + 3 组 INSTALLATION_GUIDE 锚 + 1 组 CLAUDE.md 旧文本）；正向锚 22 条全部存活（blake-lite 8 条×2 树、alex-lite 3 条×2 树、CLAUDE.md `默认通道` 1） |
| AC3 | **PASS** | 4 文件哨兵块 md5=166464e66b98c701a2b892d6e773256f、7 行，全部 OK |
| AC4 | **PASS** | alex-lite 319 行/20,846 字符 + blake-lite 371 行/24,298 字符 = 合计 45,144（带内 44,000–47,000；忠实实现实测 45,234）；parity alex-lite/blake-lite/tad-help 三组全部 OK |
| AC5 | **PASS** | HEAD=6a7cef0b22fddcd050af53949fd43e3c8ca0a36a 未移动；`git ls-files -v` 无非 `H ` 项；tracked 越权改动为空（允许清单 + journal/traces/decisions/ralph-loops/memory/COMPLETION- 排除后）；4 个 skill 目录各恰 1 文件 |

**6/6 PASS，无 FAIL 行，无需 degradation 路径。**

---

## 二、额外核验（删除精确性，本单本质）

| # | 规格项 | 结果 | 实证 |
|---|---|---|---|
| 1 | §3.1 整节删除边界 | **PASS** | 改动前 Route Contract 节 = alex-lite 66 行 / blake-lite 54 行（含标题行，与规格实测一致）。删后 alex-lite L52 `## L0-pre 命名消歧` → L56 `## 执行脊柱` 直接邻接；blake-lite L23 `## 共享记忆契约` → L41 `## L0 读契约 + 准入` 直接邻接 |
| 2 | §3.2 Reviewer 档位规则子节（fix-reviewer-tier.py Repair Round 1） | **PASS** | alex-lite 28 行（含标题，删到 `人工拍板后变更回流：` 前——规格边界）且回流块保留（改动后 L150）；blake-lite 28 行（到 `## L3.5` 前）。4 文件 `### Reviewer 档位规则`/`强档`/`REVIEWER-TIER-DEGRADED` 全 0 |
| 3 | §3.2 Model 行捕获纪律 26 行→1 行 | **PASS** | 改动前块 26 行（含标题行）；改动后 L241 `Model 行按运行时自报填写，一行即可；无法判定的字段填 unknown，不得伪造。` + 恰一个空行接 L243 `学习捕获纪律：`。L4 模板 `**Model**: harness=` 保留（blake-lite L227，含 route= 字段，符合"删命令不删字段"） |
| 4 | §3.3 哨兵块含「转 full」字面串 | **PASS** | 块第 2 行 `…不再有"转 full"分支）：` 有意保留（AC3 md5 钉死）；AC2 锚 `转 full TAD` 未误伤（两锚互不冲突，v1 阻塞缺陷未复发） |
| 5 | §3.4(d) d3 子串替换保住真约束 | **PASS** | L146 `…/命中安全停清单 → 停，报告人；不得把 FAIL 契约交给 blake-lite。` — 子串替换生效且 `不得把 FAIL 契约交给 blake-lite。` 完整保留（v1 P1 教训守住） |
| 6 | §3.4(d) d5/d6 行中片段 | **PASS** | d5: L115 `Reviewer: {待填} \| model={reviewer 自报}`（`，格式同 Model 行}` → `}`）；d6: L136 `…（harness/model/route）。`（`，机械捕获同 Model 行纪律` 已删）。两串残留均 0 |
| 7 | §3.4(a)(b)(c)(e)(f) | **PASS** | (a) frontmatter 第 6 行已删；(b) L0 节 = 规格文本逐字节；(c) 哨兵 END 后仅空行接 `### **L1 — Goal anchor`，escalated_review 授权规则块 0 残留；(e) Series 锚点新文本在 L164；(f) Forbidden 3 行已删（`主动建议或默认 escalated_review /`、`在无用户明示坚持时设置 escalated_review: yes /`、`把额度出口句…` 开头行），正向锚 `以自审替代 reviewer spawn` 在正文 |
| 8 | §3.5(a)(b)(c) | **PASS** | (a) L0 step2 末条+step3 = 规格文本；(b) escalated 两行已删，L0.5 区内无连续双空行，4 skill 文件全局连续双空行（`\n\n\n`）均 0；(c) e1 L118、e2 L357、e3 残留 0、e4 无 `，机械捕获…` 尾巴 |
| 9 | §3.6 AGENTS.md 21 行 | **PASS** | diff 删 21 行（22 含 diff header）= `## Lite / Standard / Full Routing（用户可读说明）` 整节（含 `当前建议: Lite\|Standard\|Full`、`Full 是治理边界`、routing-contract.yaml 引用）；L88 `---` 直接接 `## Default Behavior (no role specified)` |
| 10 | §3.7 CLAUDE.md 两行 | **PASS** | diff 恰为 2 行替换：L33 标题 `### 2.5 Lite 通道（默认通道）` + L34 正文新文本（逐字节 = 规格）；其余一个字未动 |
| 11 | §3.8 tad-help ×2 5 条 | **PASS** | 3 整行删（routing profiles / Shared route contract / Independent depth selection）+ 2 子串替换（`explicit routing rules do`→`risk does`；`escalation valve (SAFETY/protocol/fatal → full TAD, fail-closed)`→`safety stop (irreversible ops / SAFETY surface / global registration → stop and ask)`）；两树逐字节相同 |
| 12 | §3.9 INSTALLATION_GUIDE 4 行 | **PASS** | diff 删 4 行 = `## Lite / Standard / Full 路由` 整节（标题+空行+正文+空行）；L73 直接接 `## 平台说明` |
| 13 | 版本横幅豁免 | **PASS** | INSTALLATION_GUIDE.md:3 `**Version 2.39.0 — Lite / Standard / Full Routing Profiles**` 未动 |
| 14 | §2.1 两处明确不修 | **PASS** | `载体（R6）` 两 skill 均在（alex-lite L230 / blake-lite L275）；`full TAD 是例外而非常态` 两 skill 均在（L26/L15）；blake-lite L21 `"切换通道到 full"（例外）` 均在——未碰 |

---

## 三、其它观察（不阻塞）

- 工作区改动面 = 9 个交付文件 + AC5 允许清单 4 文件（lite-pricing-gate-protocol ×3 + REGISTRY.yaml）+ decisions/traces 等排除目录，与契约 §4 AC5 描述一致。
- 实现载体 `apply-changes.py`（主变换，8 组变换全部 fail-fast 断言唯一锚）+ `fix-reviewer-tier.py`（Repair Round 1 补 §3.2 Reviewer 档位规则删除——主脚本遗漏，修复后 AC2 负向锚全 0 证实补删到位）。脚本逻辑与规格逐条对应，未见越权操作。
- §6.1b 已记录：touched 节内部无逐字节 AC 保证，由 Alex Gate 4 读 diff 验（人 2026-08-05 裁定）——本审查的额外核验按规格边界逐项确认了删除精确性，未发现规格外改动。

---

## verdict: PASS

6 条 AC 全部实跑 PASS；14 项删除精确性核验全部通过；无 FAIL 行、无 degradation、无 BLOCKED。实现满足 handoff §4 全部验收判据。Gate 3 可放行（Group 0 视角）。
