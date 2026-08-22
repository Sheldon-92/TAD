> # 🔴 第五轮更正（2026-08-17）—— 本图的核心结论曾是循环论证
>
> Gate 2 reviewer `09438365` 实测推翻本图的「26 条有承载 / 4 条孤儿」结论。
>
> **致命缺陷**：`G1 hook_registration` 被判为「有承载」，依据是
> `handoff-creation-protocol.md:310` 与 `:445`。而那两行逐字是：
> ```
> - "MUST NOT register hooks or modify settings — see constraints.deny (global)"
> ```
> **它们本身就是指向本图正要删除的那个块的悬空指针。**
> 用待删的指针证明「内容有别处承载」= 循环论证。
>
> **修正后的判据（本图第 5 条，前四条见 §1）**：
> > **指向被删块的引用不构成承载。** 判定「有承载」时必须排除任何形如
> > `see constraints.*` / `inherits_global` / `# See ...（global）` 的转发指针 ——
> > 它们是**索引**，不是**内容**。
>
> **重判结果**：
> | | 原判 | 重判 |
> |---|---|---|
> | 真孤儿 | 4 | **≥5**（新增 G1；G2 仅条件承载） |
> | 潜在第 6 个 | — | 祖先 skillify 的 `MUST NOT register hooks for skillify enforcement`（`deny_extra` 未编码，也无承载） |
>
> **连带失效**：§5.3 关于 `step1c_grounding`/`step1c_lsp` 的 `inherits_global: true`
> 在 O1/O2 落地后即成立的推论 —— G1/G2 未承载时仍不成立。
>
> **其余四条更正**（均经复核）：
> 1. `skillify.auto_invoke` 引的承载者 `body:1372` 说的是 `*harvest` 不是 skillify
> 2. 悬空引用在 `SKILL.md:702` 不是 `:703`
> 3. O4 的「全仓无第二处承载」说过头 —— `hcp:719` 泛化承载了 Terminal 隔离
> 4. **`*skillify` 命令已不存在**（实测 `grep -c '\*skillify' alex/SKILL.md` = 0）——
>    O3/O4 管的是一个已退休的命令
>
> ⚠️ **本图在修正前不得作为 Phase 1b 的实施依据。**

# 承载者地图：`alex/SKILL.md` frontmatter `constraints:` 块

**日期**: 2026-08-16
**作者**: Alex
**用途**: `HANDOFF-1b`（退休 frontmatter 约束块）的**前置产物**。没有这张图，1b 无法安全设计 —— 前身单 `HANDOFF-20260816-phase1-zero-risk-sweep.md` 两次 Gate 2 FAIL，根因即缺此图。
**基线 commit**: `4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7`

---

## 0. 这张图回答什么

对 `constraints:` 块（`alex/SKILL.md` L6-146）里的**每一条规则**，回答：

> **删掉 frontmatter 之后，这条规则的散文原文还活在哪里？**

- **有承载** → 删除无损，只需处理指向它的悬空引用
- **孤儿** → 删除即真丢，必须先在正文写下明文，否则治理静默失效

## 1. 方法与其失败史（重要）

本图迭代了**四轮**，前三轮都错。记录在此，因为错误形状本身是知识：

| 轮次 | 搜索范围 | 判据 | 结果 | 错在哪 |
|---|---|---|---|---|
| 1 | 仅 `alex/SKILL.md` 正文 | 关键字出现 | 「3 条禁令从未生效」 | **漏了 `references/`** —— 禁令一直在那里正常送达 |
| 2 | 正文 + references | 关键字出现 | 「只剩 1 个孤儿」 | **命中 ≠ 承载** —— `exit_codes` 的 16 处全是 bash 退出码的普通用法 |
| 3 | 正文 + references | 限 `MUST NOT` 语境 | 「6 个孤儿」 | **禁令措辞不止 `MUST NOT`** —— 漏掉 `forbidden interpretation` / `禁止` / `VIOLATION` |
| **4（本图）** | 正文 + references | 禁令语义全集 + **逐条人眼确认** | **3 个真孤儿** | — |

**判据（第 4 轮采用）**：
```bash
PROHIB='MUST NOT|forbidden|禁止|不得|VIOLATION|never '
```
命中后**必须人眼确认语义对应**，不得只看计数 —— 第 4 轮里 `tool_blocking` 的 5 处命中经人眼查验全是「某检查不阻塞流程」，与「不得阻断 Write/Edit/Read」无关，故判为孤儿。

> ⚠️ **本图自身的教训**：三轮错误都是同一形状 —— **量了一个代理指标，当成了本体**。
> 使用本图时，若要新增一行，必须重跑判据 **并人眼确认**，不得凭计数下结论。

---

## 2. 全局 `deny:`（5 条）

| # | 规则 | 承载者 | 判定 |
|---|---|---|---|
| G1 | `hook_registration: [PreToolUse, PostToolUse, UserPromptSubmit, SessionStart]` | 正文 ×1 + refs ×3（`handoff-creation-protocol.md:310`、`:445` 等） | ✅ 有承载 |
| G2 | `settings_modification: .claude/settings.json` | 正文 ×1 + refs ×1 | ✅ 有承载 |
| **G3** | **`hook_scripts: .tad/hooks/*.sh` create/modify** | **无** | ❌ **真孤儿** |
| G4 | `exit_codes: deny_exit_codes` | refs ×1（`handoff-creation-protocol.md:523` 内嵌于 verify-ac-commands 那条长规则） | ✅ 有承载（勉强 —— 是另一条规则的从句） |
| **G5** | **`tool_blocking: never_block [Write, Edit, Read]`** | **无**（5 处命中经人眼确认全是「某检查不阻塞流程」，语义不同） | ❌ **真孤儿** |

## 3. `cross_model:` + `enforcement:`

| # | 规则 | 承载者 | 判定 |
|---|---|---|---|
| C1 | `auto_invoke: false` / `NOT_via_alex_auto` / `delegation_requires: user_confirmation` | 正文 L701 + L704-709 的 4 条 `MUST NOT`（含 DR-20260531 豁免） | ✅ 有承载（且优于 frontmatter） |
| E1 | `enforcement: prompt-level-only` | refs ×8，但**均为引用而非定义**（`# See constraints.enforcement (global)`） | ⚠️ **指针存在、定义将消失** —— 见 §5 |

## 4. `section_overrides` 的 24 条 `deny_extra`

| key | 规则 | 承载者 | 判定 |
|---|---|---|---|
| cross_model_awareness | couple w/ skipKA+express | 正文 L707 | ✅ |
| | bypass socratic via delegation | 正文 L708 + refs | ✅ |
| express_path | `'express = review-exempt'` 禁止解释 | `express-path-protocol.md:56`（措辞 `forbidden interpretation`） | ✅ |
| | auto_downgrade standard→express | refs ×2 | ✅ |
| experiment_path | replace_silently gate_3_4 | 正文 + `experiment-path-protocol.md:112` | ✅ |
| | bypass socratic via shortcut | `experiment-path-protocol.md:113` | ✅ |
| step0_graph | auto_index repository | `handoff-creation-protocol.md:344` | ✅ |
| | block_on_failure graph_probe | `handoff-creation-protocol.md:345`（含 `<500ms` 预算） | ✅ |
| step1d_ac_dryrun | skip rationalizations | `handoff-creation-protocol.md:521` | ✅ |
| | promote verify-ac-commands to gate | `handoff-creation-protocol.md:523` | ✅ |
| skip_knowledge_assessment | auto_inject_override via hook | `acceptance-protocol.md:317` | ✅ |
| | couple w/ layer2_audit_step4c | `acceptance-protocol.md:318` | ✅ |
| gate4_delta | auto_populate via hook/script | `acceptance-protocol.md:363` | ✅ |
| | block accept_command | `acceptance-protocol.md:364` | ✅ |
| | *(couple w/ skipKA —— 祖先有，`deny_extra` 无)* | `acceptance-protocol.md:365` | ✅ 见 §6 |
| **skillify** | auto_accept candidates | 正文 L1374 | ✅ |
| | **create_directly `.claude/skills/{slug}/SKILL.md`** | **无** | ❌ **真孤儿** |
| | **call_from terminal: blake** | **无** | ❌ **真孤儿** |
| | auto_invoke without explicit command | 正文 L1372 | ✅ |
| cancel_protocol | auto_downgrade standard→cancel | `cancel-protocol.md:112` | ✅ |
| | `'cancel = silent abandonment'` 禁止解释 | `cancel-protocol.md:111`（措辞 `forbidden interpretation`） | ✅ |
| | couple w/ skip_knowledge_assessment | `cancel-protocol.md:110` | ✅ |
| step1c_grounding | `inherits_global: true` | 依赖 G1-G5 全部落地 | ⚠️ **条件性** |
| step1c_lsp | `inherits_global: true` | 同上 | ⚠️ **条件性** |

---

## 5. 结论：`HANDOFF-1b` 必须做的事

### 5.1 四个真孤儿（删 frontmatter 即真丢）

| # | 孤儿 | 语义 | 为什么要紧 |
|---|---|---|---|
| **O1** | `deny.hook_scripts` | 不得创建/修改 `.tad/hooks/*.sh` | Alex 不写实现代码的一个具体面 |
| **O2** | `deny.tool_blocking` | 不得阻断 Write/Edit/Read 工具 | 防「hook 拒绝一切」事故（`principles.md` 2026-04-15 有先例） |
| **O3** | `skillify.create_directly` | Alex 不得直接创建 `.claude/skills/{slug}/SKILL.md` | **CLAUDE.md §4「Alex 不写实现代码」的编码** |
| **O4** | `skillify.call_from: blake` | 不得从 Blake 终端调用 | **CLAUDE.md §4 Terminal 隔离的编码** |

⚠️ **O3/O4 是框架核心不变式**，全仓无第二处承载。前身单曾把 `skillify` 归为「已覆盖，只核对」，依据是它在正文出现 9 次 —— **那 9 次全是 `*harvest` 的命令描述和路径字符串**。

### 5.2 一个半孤儿

**E1 `enforcement: prompt-level-only`** —— 定义在 frontmatter，8 处引用在 references。删定义后引用悬空。
处置二选一（1b 需人裁定）：(a) 在正文写下该声明；(b) 把 8 处引用改成自足表述。

### 5.3 两个条件性覆盖

`step1c_grounding` / `step1c_lsp` 的 `inherits_global: true` **当且仅当 G1-G5 全部在正文落地**才成立。
因 G3/G5 是孤儿 → **当前不成立**。1b 必须先落 O1/O2，这两个 key 才真被覆盖。

### 5.4 悬空引用总数：**16 处，6 个文件**

| 文件 | 处数 |
|---|---|
| `references/handoff-creation-protocol.md` | 6（含 `:310`、`:445` 两处**正文指令项**） |
| `references/acceptance-protocol.md` | 3 |
| `references/express-path-protocol.md` | 2 |
| `references/cancel-protocol.md` | 2 |
| `references/experiment-path-protocol.md` | 2 |
| **`SKILL.md:703`（正文内，前身单遗漏）** | **1** |

`.agents/skills/alex/` 镜像同样 16 处 → 两侧合计 32。

### 5.5 明确无损的部分

**19 / 24 条 `deny_extra` + G1/G2/G4 + C1 均有承载**，且多数位置**优于** frontmatter —— 与各自治理的步骤同处一地，由 `load_when` 按需送达，常驻成本为零。

**这意味着 1b 的真实工作量远小于前身单的设计**：不是「搬 11 个 key」，而是「写 4 条孤儿 + 处理 1 个标量 + 改 16 处引用」。

---

## 6. 附带发现：`deny_extra` 是有损索引

祖先 `697c616e` 的 `gate4_delta` 有 **5** 条 `MUST NOT`，现存 `deny_extra` 只编码了 **2** 条。缺失的 `MUST NOT couple gate4_delta to skip_knowledge_assessment` 靠 `acceptance-protocol.md:365` 独立存活。

**推论**：前身单「冲突时以 `deny_extra` 为准」的规则是错的，会删掉祖先有而索引无的条目。
**正确规则**：**祖先原文权威，`deny_extra` 只是查找清单。**

---

## 7. 复用价值

本图的方法可迁移到任何「退休一个声明层」的任务：

> **退休声明层前，必须先做承载者地图。**
> 对每一条规则问「散文原文还活在哪」，且判据必须覆盖**禁令语义全集**（不止 `MUST NOT`），命中后**人眼确认语义对应**。
> 缺这张图时，删除与迁移会互相污染 —— 分不清「删干净了」和「删过头了」。
