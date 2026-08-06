# Code Review — HANDOFF-20260805-cut-routing-machinery（P2+P3 合并单，v2/v3）

**Reviewer**: Layer 2 Group 1 code-reviewer（独立专家审查）
**Model 身份自报**: harness=claude-code | model=deepseek-v4-flash | route=native
**日期**: 2026-08-05 | **审查对象**: 9 文件实现（HEAD `6a7cef0b22fddcd050af53949fd43e3c8ca0a36a` 上未提交改动）
**方法**: 六条 AC 逐条执行重跑 + 全 diff 逐段对照 §3 规格 + 豁免区核验 + 逃逸面扫描 + 正向对照探针（/tmp 副本）

---

## 0. 结论摘要

**Verdict: PASS**

- P0: 0 | P1: 0 | P2: 3（均为观察，不影响交付）
- 六条 AC 独立重跑全部 PASS（与 Blake 的 post-impl-output.txt 逐字节一致）
- 9 文件 diff 与 §3 规格逐段吻合；d3 子串教训、两处 §2.1 豁免、版本横幅豁免、L4 Model 行保留全部落实
- 逃逸面扫描：hooks/configs/settings/tad.sh/release-verify.sh 零残留、零新文件、parity 三对全同

---

## 1. AC 执行结果（逐条重跑，命令原文来自 handoff §4）

| AC | 结果 | 关键输出 |
|---|---|---|
| AC1 | **PASS** | alex-lite 178 行 `13b0b87b…`；blake-lite 251 行 `0afa760c…`（双树） |
| AC1b | **PASS** | AGENTS 135 行 `9862c783…`；INSTALLATION_GUIDE 140 行 `f9b8bd54…`；CLAUDE 109 行 `c358c0c0…`；tad-help ×2 231 行 `dfd2ba7a…` |
| AC2 | **PASS** | 全部负向锚 = 0（4 skill + AGENTS + tad-help×2 + INSTALLATION + CLAUDE）；22/22 正向锚全在 |
| AC3 | **PASS** | 四份 skill 哨兵块均 7 行、md5 `166464e66b98c701a2b892d6e773256f` |
| AC4 | **PASS** | 两 skill 合计 45,144 字符（44–47K 带内）；alex-lite/blake-lite/tad-help 三对 parity 全同 |
| AC5 | **PASS** | HEAD 锚未移动；index 无 assume-unchanged/skip-worktree；tracked 越权改动 0；4 个 skill 目录 find 计数均 = 1 |

判别力验证（执行实证）：预实现输出（pre-impl-output.txt）中 AC2 负向锚全命中、AC3 旧 md5 `4c55bcb6…`×16 行、AC4 64,050>47,000 —— 三条判据在零改动仓库全部 FAIL，实现后全部 PASS。正向对照探针（/tmp 副本掏空 Forbidden + 换哨兵内容）：`以自审替代 reviewer spawn` / `## Forbidden` 计数归 0、哨兵 md5 变 `d611bfbe…` —— v1 的两条逃逸路径在本环境同样被 AC2/AC3 抓住，判据非空转。

## 2. 规格逐段对照（阅读推断 + diff 实证，全部吻合）

| 规格 | 验证 |
|---|---|
| §3.1 Route Contract 整节删（66/54 行） | ✓ diff 确认；alex-lite `## L0-pre 命名消歧`→`## 执行脊柱` 直接相接；blake-lite `## 共享记忆契约`→`## L0 读契约` 直接相接 |
| §3.2 Reviewer 档位规则 ×2（28 行/处） | ✓ 边界锚正确（alex-lite 止于 `人工拍板后变更回流：`前，blake-lite 止于 `## L3.5`前），无连续双空行 |
| §3.2 Model 行捕获纪律 26 行块 → 1 行 + 空行 | ✓ `Model 行按运行时自报填写…` + 空行 + `学习捕获纪律：`（markdown 未并段） |
| §3.3 哨兵块（md5 钉死 + 7 行 + 双 marker） | ✓ 四文件逐字节一致；块内第 2 行字面 `"转 full"` 有意保留，与 AC2 锚 `转 full TAD` 不互斥（AC2 PASS 实证） |
| §3.4(a) frontmatter 第 6 行 | ✓ 仅删该行，YAML folded scalar 结构完好 |
| §3.4(b) L0 节替换 | ✓ 与规格文本逐字一致 |
| §3.4(c) escalated 两整块删（8 行含空行） | ✓ 删后 `### **L1 — Goal anchor` 前恰一个空行 |
| §3.4(d) d1–d6 | ✓ **d3 为子串替换**：`或 P0 修复扩大范围/命中安全停清单 → 停，报告人；不得把 FAIL 契约交给 blake-lite。` —— 尾部真约束完整保留（v1 P1 教训落实）；d5/d6 行中片段正确摘除 |
| §3.4(e) Series 锚点 | ✓ 与规格新文本逐字一致 |
| §3.4(f) Forbidden 3 行 | ✓ 含以「把额度出口句用于推荐/暗示 escalated」开头整行 |
| §3.5(a)(b)(c) e1–e4 + L0 step2/step3 + L0.5 2 行 | ✓ 全部逐字吻合；L0.5 删后无连续双空行；e3 单前导空格字节正确 |
| §3.6 AGENTS.md 21 行整节 | ✓ 删后 `---`→`## Default Behavior (no role specified)` |
| §3.7 CLAUDE.md 仅 2 行（标题+首行） | ✓ 其余一个字未动（AC1b 四态排除 + digest 钉死） |
| §3.8 tad-help ×2 5 条（3 删 2 子串替换） | ✓ 两树逐字节同；`risk and explicit routing rules do`→`risk does`、`escalation valve (…)`→`safety stop (…)` |
| §3.9 INSTALLATION_GUIDE 4 行整节 | ✓ 删后单空行接 `## 平台说明`；**L3 版本横幅 `**Version 2.39.0 — Lite / Standard / Full Routing Profiles**` 未动**（豁免落实） |

## 3. 重点核查项（任务清单逐项）

1. **d3 子串保住了 `不得把 FAIL 契约交给 blake-lite。`** — 执行实证：AC2 正向锚计数 ≥1 + diff 目视（§3.4(d) 行尾完整）。✓
2. **AC2 正向 22 锚全存活 / 负向全 0** — 执行实证：AC2 PASS。繁体探针 `Model 行捕获紀律` 为 0。✓
3. **哨兵块 md5 钉死 + `转 full` 字面保留 vs `转 full TAD` 锚不互斥** — 执行实证：AC3 PASS 且 AC2 PASS 同跑。✓
4. **§2.1 两处豁免未好心修复** — 执行实证：`载体（R6）`（两 skill L230/L275）与 `切换通道到 full（例外）`（两 skill L32/L21）原样保留。✓
5. **版本横幅豁免** — 执行实证：INSTALLATION_GUIDE L3 原样；§2 豁免清单内其余（README/CHANGELOG/PROJECT_CONTEXT/docs/MULTI-PLATFORM/config.yaml:1）均未动（git diff 确认）。✓
6. **parity 三对镜像** — 执行实证：AC4 md5 全同。✓
7. **路由机器搬进新文件逃逸** — 执行实证：AC5 find 计数四目录均 1；全仓扫描（含 untracked，排除既有证据/夹具）未发现新交付文件含被删机制。✓
8. **AC 判别力对照 pre-impl-output.txt** — 执行实证：见 §1。✓

## 4. 逃逸面与消费方扫描（执行实证）

- `git grep` 9 文件外 tracked 文件：`escalated_review|升级清单|route_level|routing-contract|Reviewer 档位规则` 零命中。
- 附加词汇扫描（route_id/risk_class/affected_side/override_allowed/approval_record/TAD-ROUTING/schema_version/base_revision/execution_ready/approval_pending/f0_or_f1）9 文件零残留。
- 活机器扫描：`.tad/hooks/`、`.tad/config*.yaml`、`.claude/settings*.json`、`tad.sh`、`release-verify.sh`、`.tad/hooks/lib/` 对 `escalated|升级清单|route_level|routing-contract|转 full TAD|ESCALATION-LIST` 零命中；哨兵旧 md5 `4c55bcb6…` 仅存在于 `.tad/evidence/` 历史证据与待作废 handoff（§6.2 第 3 条归 Alex，非本单范围）。**哨兵块改动不破坏任何活消费者。**
- 改动集围栏：14 个 tracked 改动 = 9 交付 + 4 起草时已 dirty 的 pricing-gate 证据 + `decisions/2026-08-05.jsonl`（AC5 的 decisions/ 排除面内；内容为当日人工决策记录，与路由机器无关）。
- tad-help L77「Standard TAD」与 AGENTS.md「Handoff and routing」经查为 full 通道 Adaptive Complexity 档位与 handoff 格式路由，非被删的三层路由机器，不构成悬空承诺。

## 5. Findings

### P0（必修）
无。

### P1（应修）
无。

### P2（建议，均不阻塞）

- **P2-1（阅读推断）**：handoff §1/§6.1b 声称「~254 行删除 + 一处替换」，实际唯一删除 296 行（alex-lite 131 + blake-lite 133 + tad-help 5 + AGENTS 21 + INSTALLATION_GUIDE 4 + CLAUDE 2）、插入 30 行，替换点 8 处。数字是 v1 的过期估计。影响面：仅 Alex 在 Gate 4 的逐行读 diff 工作量（约 300 行而非 254），不涉实现正确性。建议 Gate 4 前把 §6.1b 数字更正，避免后续 reviewer 再次对账。
- **P2-2（阅读推断）**：§8 声称 v3 预实现实跑「22/22 正向锚存在」，但 pre-impl-output.txt 实际打印「正向锚跳过——零改动仓库正向必在」。零改动仓库正向锚确实按构造必在、实现后状态我实测 22/22 全在（AC2 PASS），结论实质成立；仅证据文本与声称的核验方式不一致。属证据表述精度问题。
- **P2-3（阅读推断，仅提示不作 defect）**：untracked 夹具 `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/.agents/skills/{alex,blake}-lite/SKILL.md` 仍含被删机制全文——它们是既有 spike 夹具（起草前已存在，AC5 不覆盖 evidence/ 之外路径之外的 untracked 顶层），非本单交付物。提示 Gate 4 不要把它们误读为残留。

## 6. 正面确认

- **实现手段质量高**：apply-changes.py 全部变换带唯一锚断言（fail-fast，子串操作用 `count==1` 保护），fix-reviewer-tier.py（Repair Round 1 补 §3.2）边界与契约实测 28 行一致；脚本与最终落盘状态吻合。
- **d3 教训落实**：v1「字面整行替换静默删约束」的 P1 被 §3.4(d) 子串分类 + AC2 正向锚双重封死，实现端未重蹈。
- **§6.1b 口子如实申报**：touched 节内部无逐字节保证的残余风险被契约显式披露并交 Gate 4 人读——我逐行读了全部 touched 节 diff，未发现规格之外的改写（如 L0、Scope/Risk Router、Forbidden 均只含规格所列变换）。
- **AC 设计判别力经预实现输出 + 正对照探针双重实证**，非空转。

---

## 执行证据

实际运行命令与原始输出（前 10 行）：

```
$ git rev-parse HEAD
6a7cef0b22fddcd050af53949fd43e3c8ca0a36a

$ git status --short（13 个 M + untracked，与 AC5 授权集一致）
 M .agents/skills/alex-lite/SKILL.md
 M .agents/skills/blake-lite/SKILL.md
 M .agents/skills/tad-help/SKILL.md
 M .claude/skills/alex-lite/SKILL.md
 M .claude/skills/blake-lite/SKILL.md
 M .claude/skills/tad-help/SKILL.md
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
 M .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
 M .tad/evidence/decisions/2026-08-05.jsonl

$ git diff --numstat HEAD（9 交付文件）
15	131	.agents/skills/alex-lite/SKILL.md
11	133	.agents/skills/blake-lite/SKILL.md
2	5	.agents/skills/tad-help/SKILL.md
15	131	.claude/skills/alex-lite/SKILL.md
11	133	.claude/skills/blake-lite/SKILL.md
2	5	.claude/skills/tad-help/SKILL.md
0	21	AGENTS.md
2	2	CLAUDE.md
0	4	INSTALLATION_GUIDE.md

$ AC1（handoff §4 原文 heredoc）→ OK alex-lite 178行 13b0b87b… / OK blake-lite 251行 0afa760c… → AC1 PASS
$ AC1b（原文）→ 5 个 digest 全 OK → AC1b PASS
$ AC2（原文）→ （无任何 FAIL 行）→ AC2 PASS
$ AC3（原文）→ 4×OK 7 行 md5=166464e6… → AC3 PASS
$ AC4（原文）→ 两 skill 合计 45144 / parity 3×OK → AC4 PASS
$ AC5（原文）→ （无 FAIL 行）→ AC5 PASS

$ 正向对照探针（/tmp 副本：掏空 Forbidden + 换哨兵）
AC2 正向锚 '以自审替代 reviewer spawn' 计数: 0
AC2 正向锚 '## Forbidden' 计数: 0
AC3 哨兵 md5: d611bfbe86721fa8824dc020b3a1e9ad
```

（其余原始输出：post-impl-output.txt 与本次重跑逐字节一致；pre-impl-output.txt 见 §1 引用。）
