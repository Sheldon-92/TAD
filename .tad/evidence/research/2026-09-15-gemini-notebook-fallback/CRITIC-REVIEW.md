> 独立性声明：本评审由独立 session 产出（session: **RG3-critic-fresh** / model: **与 Research Lead 同 harness 的不同 session**；cross-model 为可选增强，本机无 Gemini）。评审人不是 findings 作者，未参与 ROUND-1/2/3 撰写。本 session 额外通过 WebSearch/WebFetch 真去核验了来源原文。
> 依据：`research-challenge-prompt.md` findings 变体 + `research-quality-rubric.md`；未另起 rubric。
> 注：本评审产出时 `SOURCES.md` 尚不存在（作者随后补齐）；评审内容保持原样，作者条件闭合见文末独立小节。

# Critic Review: Gemini Notebook（原 NotebookLM）与 TAD research fallback 链

ADEQUATE

## Source 抽查（真去核验来源原文）

| Claim | 来源 | 来源原文实际所说 | Verdict |
|-------|------|-----------------|---------|
| 更名生效 2026-07-16；官方原文 "We're renaming NotebookLM to Gemini Notebook. It's the same standalone product." | [S2] blog.google `/gemini-notebook/notebooklm-gemini-notebook/` | 页面标题《NotebookLM is now Gemini Notebook》，Jul 16 2026；原文 "We're renaming NotebookLM to Gemini Notebook. It's the same standalone product, now doing more across the Google ecosystem and updated with a secure cloud computer."；"It remains a standalone product focused on being your premier research tool" | ✅ 引用与原文一致 |
| Workspace：2026-07-16 Extended rollout；2026-09-10 管理员外部分享控制 | [S3] workspaceupdates.googleblog.com | 07-16《NotebookLM is now Gemini Notebook》"Extended rollout … starting on July 16, 2026"；09-10《Manage external sharing for Gemini Notebook in the Admin console》，四档共享，**默认 Off**，"Available to all Google Workspace customers" | ✅ 两处日期与事实均属实 |
| 2026-06-08 升级 Gemini 3.5 + Antigravity、secure cloud computer、100+ curated software skills、可自发现来源（用户批准） | [S1] blog.google `/notebooklm/better-research-notebooklm/` | Jun 08 2026《Do better research with NotebookLM》：确认 "Gemini 3.5 and Antigravity"、"secure cloud computer, enabling NotebookLM to write and run code"、"more than 100 curated software skills"、"start … with a loose idea"、用户控制哪些源加入 | ✅ 主旨完全属实 |
| 新增输出 "PNG/SVG、PDF/DOCX/MD、CSV/JSON、XLSX、PPTX" | [S1] | 官方博客只泛述 "charts … a PDF report""spreadsheets and slide decks"；**逐项格式清单来自二手汇总**（9to5/nerova/tech-archive 等） | ⚠️ 官方未逐字列出全部后缀，findings 归因于 [S1] 属轻微归因过宽；不影响 load-bearing |
| Issue #2022：登录 5 分钟超时、host 白名单硬编码、修复 #2015 首发 v0.8.0 | [S7] github.com/teng-lin/notebooklm-py/issues/2022 | 原文 "always times out after 5 minutes with 'Login not detected'…`get_base_url()` in `_env.py` hardcodes the allowed hosts to `notebooklm.google.com` / `notebooklm.cloud.google.com` only"；维护者 "**Fixed in v0.8.0** (now on PyPI)"；评论确认 #2015 merged 2026-07-27，0.8.0rc1 tagged 2026-07-18，报告者实测 0.7.3 与 0.8.0rc1 均失败 | ✅ 逐点属实 |
| RPC 未迁移：`/_/LabsTailwindUi/data/batchexecute` 仍在 `notebooklm.google.com` 无重定向；仅页面路由 302 | [S7] | 原文 "The RPC surface has not moved. `POST /_/LabsTailwindUi/data/batchexecute` still serves on `notebooklm.google.com` with no redirect, while page routes such as `/` and `/notebook/` do 302 to `notebook.google.com`." | ✅ 属实。补：另一独立仓库 jacob-bd/notebooklm-mcp-cli #272 称未认证请求方向相反（`notebook.google.com`→302→`notebooklm.google.com`）；不推翻结论，但 findings 未记录该方向细节 |
| ADR-0028：dist 改 `gemini-notebook-py`（0.9.0 一次完成），`import notebooklm` 与全部 `notebooklm*` CLI **永久保留** | [S5] docs/adr/0028 | 原文 "Rename the distribution … to `gemini-notebook-py`, completing the flip in a **single 0.9.0 release**; keep the **import package `notebooklm` and all operational plumbing permanently**"；表列 "`notebooklm*` scripts kept **indefinitely** (…no deprecation)" | ✅ 属实 |
| 最新 0.8.2（2026-09-02），0.9.0 未发布，`gemini-notebook-py` 仅 0.0.1 占位 | [S5][S6] PyPI | 实测 PyPI JSON：latest **0.8.2**，upload 2026-09-02T22:04:56Z；**0.9.0 不存在**；`gemini-notebook-py` 仅 0.0.1 | ✅ 属实 |
| TAD pin：`setup-notebooklm.sh:40` 装 `notebooklm-py[browser]==0.3.4`；skill 下限 `≥0.3.4` | [S12] 本仓库自证 | 实读 `setup-notebooklm.sh:40` `pip install -q "notebooklm-py[browser]==0.3.4"`；`research-github`/`research-notebook` SKILL 均以 `0.3.4` 为版本闸 | ✅ 属实 |
| **（推断）TAD pin 0.3.4 位于登录断带内 / 无法登录** | [S7][S12] | **没有任何来源提到 0.3.4。** [S7] 只证明 0.7.3 与 0.8.0rc1 失败、以及当时 PyPI 安装无法认证。且 PyPI 实测 0.3.4 发布于 **2026-03-12**，与 0.7.3（2026-06-30）隔 4 个 minor，代码代际不同，"同一白名单缺陷"未被证实 | ⚠️ **推断**。findings 已在要点行与"未解决/低置信"两处标注为推断——这点诚实；但 Q3 结论句（"更名确实打断了 `<0.8.0` 的登录"）与 CE2（"必须同时升版本，否则二级层是坏的"）仍以事实口吻把范围外推到整个 `<0.8.0`，属未证外推 |
| 无官方消费级 API，仅企业版（Cloud） | [S9][S13] | Google Cloud 文档确只有 **Gemini Notebook Enterprise API**（Discovery Engine，需 GCP + 企业许可，含 VPC-SC/CMEK）；@NotebookLM 官号回 "We are on it!" 但无时间线；"无消费级 API"的强表述部分来自 Tier-3 聚合博客（notebookclipper / autocontentapi） | ✅ 结论正确；但一手证据是"企业 API 存在 + 官号承诺"，否定性证据偏 Tier-3，且 findings 未标该层级差 |

**抽查结论**：凡能定位到的真实来源，其原文均支持 findings 对应声称；**不存在引用歪曲来源**。最大机制缺陷不是"引错"，而是 **引用不可解析**——[S#] 的 URL/检索日期只存在于一个不存在的 `SOURCES.md`，"来源编号见 SOURCES.md" 是一句断链。

## 反例搜寻（最强反方证据）

1. **客户端自己的 "works unchanged" 在发布时就是错的**——README（July 2026 注记）写 "works unchanged"，而据 #2022，当时 **每一个已发布版本（0.7.3、0.8.0rc1）都无法认证**。即该第一方文案在写下时即为误导。findings 的 F2.2 已抓住这一点（"works unchanged 不是跨版本无条件成立"）——这是 findings 的加分项，而非漏洞；但它同时说明：**"库照用"这一结论不能靠 README 承重，只能靠 issue/代码**，而 findings 未显式声明该置信层级。

2. **没有任何 Google 官方（一手）来源说（非官方）客户端或旧 RPC 端点会长期存活**。findings 的 "RPC 未迁移" 只有两类证据：维护者在 #2022 的观察 + 一个独立 fork（#272）的当前态复现。二者都描述"当下"，而 **#1977 才是真正后端/域迁移的在途项**。结论：**"只改文案 + 升版本"不足以消除 CE1/#1977 的结构性风险**——findings 自己也这么说（CE1/CE5），但推荐部分仍把二级层当作"可保留、只需 re-pin"来处理，未把"脆弱性不可由升版本消除"写进结论的边界条件。

3. **0.8.2 新增 Android gRPC backend（官方原生移动 API + 按需签发 OAuth bearer）**，官方 changelog 明说它 "avoids the Web backend's expiring browser-cookie sessions … providing an independent route when a Web UI change disrupts automation"。findings **完全未提及**。这直接削弱了"二级层天然脆弱且无解"的框架——存在一条（仍然未文档化、但）更抗 Web-UI 变更的传输路径，是可作为加固的候选角度。

4. **0.3.4 → 0.8.2 不是"抬 pin"，是跨 5 个 minor 的破坏性升级**：0.8.0 落地 ADR-0019 错误/返回契约的破坏半边（"absence and refusal **raise**"），并**移除** `NOTEBOOKLM_FUTURE_ERRORS`、移除 dict-subscript / get-returns-None / kwarg-alias 兼容机制。findings 把 CE6 写成"一次有意识的 re-pin"，**严重低估了迁移面**——TAD 协议里所有 `notebooklm` 调用与错误处理假设都需要验证。这是支持"只改文案 + 升版本仍不够"的最强反例。

5. **被漏掉的 TAD 特有约束（"只改产品名"清单不完整）**：
   - `research-notebook/SKILL.md:347` "`--new` flag does NOT exist in 0.3.4"、`:771/:774` "`download report` ships in all notebooklm-py 0.3.4+ builds"、`:1157` "Minimum version: 0.3.4+"——这些是**版本耦合 prose**，升版本后即失真/自相矛盾，但未被纳入分类表（表只二分"产品名 vs 工具标识符"）。
   - 两个 SKILL 的 `on_fail_version` 文案 "**notebooklm-py < 0.3.4 has broken AI endpoints**" 在语义上已被**反转**（现在是 0.3.4 这一端坏），属必须改的承重文案，未列。
   - ADR-0028 明写裸 `notebooklm` dist 名未注册、**成为永久 typosquat 目标**，且 PyPI 无预留机制；而 TAD 的 pin 理由恰是 "supply-chain safety"——**把供应链安全 pin 钉在一个已被上游放弃的旧版本上**，本身是供应链反模式。findings 的 CE3/CE5 均未覆盖 typosquat。

6. **本机事实未被带进结论**：`~/.tad-notebooklm-venv` **不存在**（RESEARCH-PLAN 已记录，但 findings 未用）。因此"TAD 保留了坏掉的二级层"在本机是**假设态**；真正的当下问题是"setup 脚本一旦执行会装进一个坏版本"，而非"已部署的层在断"。Q3/CE2 未做此区分，轻微夸大当下紧迫度。

## 缺口分析（AC1–AC6 逐条核对）

| AC | 判定 | 说明 |
|----|------|------|
| AC1 更名事实/日期 ≥1 官方 + ≥2 独立二手 | **✅ 达成** | 官方 blog.google + Workspace Updates + 9to5/The Verge/TechCrunch 交叉。**但**：因 `SOURCES.md` 缺失，[S10] 的 5 家媒体无逐条 URL/日期，独立验证只能靠外部检索，artifact 内不可复核 |
| AC2 能力变化官方一手 + 明确"源锚定是否变" | **✅ 达成（含一处推断）** | 2026-06-08 博客属实；"源锚定未变"是从博客 "grounded in your sources" 等措辞**推断**，官方无一句字面声明。可接受但应标注推断 |
| AC3 客户端更名后可用性有客户端项目一手来源 | **⚠️ 部分** | "库整体可用"有 README/ADR/CHANGELOG/releases 支撑（且 README 本身不可信，需靠 #2022 反证）；**"TAD pin 0.3.4 不可用"是推断，无任何一手来源、未实测**。AC 的决策承重半边未闭合 |
| AC4 可 grep 复核的"改 / 留"分类 + 判据 | **✅ 达成** | ROUND-3 §F3.2 给出 token 级分类与判据。**但** findings 只复述列表，未附实际 grep 命令/输出；且如上§5，"版本耦合 prose"未入表 |
| AC5 fallback 链是否改结构的明确结论 + 理由 | **✅ 达成** | 结论"不改结构"理由（RPC 未迁移）成立 |
| AC6 每条 load-bearing 在 `SOURCES.md` 可追溯来源 + 检索日期 | **❌ 未达成** | `SOURCES.md` **不存在**；[S1]–[S14] 无 URL、无检索日期、无标题映射；findings 正文首行即引用一个不存在的文件。这是硬验收线失败 |

小结：6 条中 4 条达成、AC3 半闭合、**AC6 直接缺失**。charter 的决策问题（改哪些 token、是否动结构）在**实质层面**已被回答，但在**可追溯/可复核层面**未达验收线。

## Ratings

**ADEQUATE**（低档 ADEQUATE，接近 INSUFFICIENT 边界）

五维评估（findings 变体）：

1. **证据充分性**：核心结论（更名、能力、客户端登录断代、ADR 保留策略、无消费级 API）均有 Tier-1 一手来源，且我外部复核后原文一致——**无 WEAK_EVIDENCE 级别的核心结论**。唯一 WEAK 的是 **"TAD pin 0.3.4 不可登录"**：单一机制外推、零直接来源、未实测，却被 CE2/推荐当作可执行前提（findings 已自标推断，故记 WEAK 但不记误导）。
2. **角度完整性**：至少 2 个完全未探索视角——(a) **0.8.2 Android gRPC backend** 作为抗 Web-UI 脆弱的加固路径；(b) **0.3.4→0.8.2 的破坏性迁移面（ADR-0019 错误契约）**及版本耦合 prose 的连带改动。另有 (c) ADR-0028 typosquat/供应链反模式未纳入。
3. **假设可靠性**：隐含假设——(i) "0.7.3 的白名单缺陷在 0.3.4 同源"（无证据，0.3.4 为 2026-03-12 独立代际）；(ii) "非官方客户端/旧 RPC 端点可长期存活"（仅有当下态观察，反证 #1977 在途）；(iii) "源锚定定位未变"（推断）。三者 findings 均未正面列为基础假设。
4. **因果推理**：主结论机制解释清晰（host allowlist → 登录失败），这是强项。漏洞在**版本外推**：由两个被测版本（0.7.3/0.8.0rc1）推及整个 `<0.8.0` 与具体 0.3.4，属相关性跨代际误推。
5. **决策支撑力**：给出"是否改、改哪些 token"，但**缺少实施决策所需**：(a) 0.3.4→0.8.2 破坏性升级的兼容性核查清单与回退方案；(b) 若二级层结构性脆弱（CE1），是否仍值得保留/加固/迁移的**取舍结论**；(c) 一次可 grep 验证的命令与期望输出。

按评级标准，仅"决策支撑力"接近严重、"角度完整性/假设可靠性"为显著但不致命缺口（且主弱点已自披露）→ 判 **ADEQUATE**，非 STRONG；若不计自披露，则接近 INSUFFICIENT。

## Quality Rubric

- citation_accuracy: 0.5  # 引用机制存在（[S#]）且底层来源**真实、可达、支持结论**（本 session 外部复核 9 条全部属实）；扣分原因：承载引用的 `SOURCES.md` **缺失**，[S#] 在 artifact 内**不可解析**、无 URL/检索日期，读者无法就地复核 → 未达 1.0；因来源非伪造、非不可达，不给 0.0。
- factual_accuracy: 0.5  # 核心结论全部正确；但"更名打断了 `<0.8.0` 的登录"由 0.7.3/0.8.0rc1 外推到整个 `<0.8.0` 与未经测试的 0.3.4（0.3.4 发布 2026-03-12，属不同代际），属 D2 的 "over-generalizes / interpolates into a specific value" 档 → 0.5。findings 已标注推断，故不再下调。
- completeness: 1.0  # Q1–Q6（Q6 含 P1 skeptic）全部有结论，AC1/AC2/AC4/AC5 达成、AC3 半闭合；AC6（SOURCES.md）为文档可追溯性缺陷，按正交规则归入 citation_accuracy 处理，不在本维重复扣分；严格按 AC 比 5/6≈0.83 亦落在"nearly all"锚。
- source_quality: 1.0  # 承重结论锚在 Tier-1：blog.google、workspaceupdates、canonical 仓库的 ADR/issues/releases、PyPI 实测、TAD 自证文件；Tier-2/3（The Verge/TechCrunch/9to5、聚合博客）仅作交叉。唯一弱环是 CE1 的否定性证据含 Tier-3 博客，但 Google Cloud 文档提供了一手锚。
- efficiency: [ADVISORY] 信号密度高——按 Q 分节、结论前置、几乎无填充段落；唯一稀释是 [S#] 全部指向缺失来源，形成"高信息密度但不可复核"的反常形态。

Aggregation（hybrid floor）：factual=0.5 与 citation=0.5 **均不 <0.5 → 不触发 floor**；`overall = mean(0.5, 0.5, 1.0, 1.0) = 0.75`。
Advisory：`overall 0.75 — OK`（但叠加 AC6 缺失，实质风险高于该分数所暗示）。

## Verdict

**CONDITIONAL** —— 核心结论正确、一手来源扎实、机制解释清晰，但 **AC6 硬验收线未达（`SOURCES.md` 缺失）** 且推重结论的 **0.3.4 登录失效为未证实推断**、升级迁移面被低估，须补齐条件后方可 PASS。

放行条件（全部满足即可转 PASS）：
1. 补出 `SOURCES.md`：[S1]–[S14] 逐条 URL + 检索日期 + 标题，消除断链（AC6）。
2. 将"0.3.4 无法登录"**降级为明示假设**（或真去实测/查 0.3.4 源码证据）；Q3 结论句与 CE2 的 `<0.8.0` 全称外推收窄为"已测 0.7.3/0.8.0rc1 失败；0.3.4 同源性未证"。
3. 把 CE6 从"re-pin"升级为**跨 minor 破坏性迁移**：列出 0.3.4→0.8.2 的 ADR-0019 错误契约影响、需回归的 CLI 调用清单、版本耦合 prose 与 `on_fail_version` 文案的连带改动、以及回退方案。
4. 补两条决策相关角度：ADR-0028 typosquat / 供应链反模式；0.8.2 Android gRPC backend 作为脆弱性加固候选（或明写"不采纳"及其理由）。

## 未解决弱点

1. **`SOURCES.md` 缺失** → AC6 未达；正文 "来源编号见 `SOURCES.md`" 为死链；全篇 [S#] 不可就地追溯（URL、检索日期、标题）。
2. **TAD pin 0.3.4 登录失效为推断**，零一手来源、未实测；0.3.4（2026-03-12）与 0.7.3 相隔数代，"同一白名单缺陷"未证；Q3 结论句与 CE2 仍以近似事实口吻作全称外推。
3. **升级迁移面被低估**：0.3.4→0.8.2 跨 5 minor、含 ADR-0019 破坏性错误/返回契约与 `NOTEBOOKLM_FUTURE_ERRORS` 移除；"抬 pin"不是简单动作，未列兼容性核查与回退。
4. **版本耦合 prose 未纳入改造清单**：`research-notebook/SKILL.md` 的 0.3.4 专属说明（`--new`/`download report`/Minimum version）与两处 `on_fail_version` 文案（"<0.3.4 broken" 语义已反转）。
5. **未评估 0.8.2 Android gRPC backend** 作为降低 Web-UI 脆弱性的替代/加固路径。
6. **未纳入 ADR-0028 的 typosquat/供应链风险**（裸 `notebooklm` dist 未注册、旧名 shim 永久可解析），与 TAD "supply-chain safety" pin 理由存在张力。
7. **无 Google 官方一手来源确认**非官方客户端/旧 RPC 端点将长期存活；仅有维护者观察 + 一个独立 fork 的当下态；`#1977` 真迁移在途 → 二级层脆弱性无法由升版本消除。
8. **本机环境事实未带入结论**：`~/.tad-notebooklm-venv` 不存在，"二级层损坏"在本机为假设态，findings 未区分"未部署"与"已损坏"。
9. **推荐缺取舍结论**：CE1 已判二级层天然脆弱，但未回答"是否仍值得保留/加固/迁移"。
10. 次要：30M 用户/600k 组织为 Google 自报（已如实标注）；`5.6k★` 未独立核验（不承重，故不影响评级）。

---

# 作者条件闭合（RG3 CONDITIONAL → 复核）

> 以下为 Research Lead 对上述 4 条放行条件的回应。Critic 原文保持不动。

| 条件 | 状态 | 证据/动作 |
|------|------|-----------|
| 1. 补 `SOURCES.md`（AC6） | **已闭合** | 新建 `SOURCES.md`，S1–S16 逐条 URL+标题+版本/发布日期+检索日期+支撑结论。 |
| 2. 0.3.4 登录失效：降级或查源码 | **已闭合（升级为代码级证据 + 余留不确定如实保留）** | 静态核验 tag v0.3.4 源码 [S15]：`src/notebooklm/cli/session.py:48` `NOTEBOOKLM_HOST="notebooklm.google.com"`，`:234` 用 `if NOTEBOOKLM_HOST not in current_url:` 校验登录落地 URL；`src/notebooklm/auth.py:49-52` `ALLOWED_COOKIE_DOMAINS={".google.com","notebooklm.google.com",".googleusercontent.com"}` 不含 `notebook.google.com`。更名后页面路由 302 到 `notebook.google.com`（[S7]）→ **0.3.4 的登录/取 cookie 路径含更名敏感硬编码，机制独立于 0.8.x 的 `wait_for_url` 缺陷**。诚实边界：为**静态源码证据**，非本机 live 复现（无 venv/无账号）；0.7.3/0.8.0rc1 的失败是 live 实测（[S7]），0.3.4 为源码推断 + 机制吻合。Q3/CE2 的全称外推已按此收窄。 |
| 3. CE6 升级为跨 minor 破坏性迁移 | **已闭合** | 补入 findings：0.3.4→0.8.2 跨 5 minor；0.8.0 落地 ADR-0019 破坏半边且移除 `NOTEBOOKLM_FUTURE_ERRORS`/dict-subscript/get-None/kwarg-alias；列出需回归的 CLI 清单（`ask`/`source add`/`source list --json`/`generate report`/`download report`/`summary`/`configure`/`source guide`）+ 版本耦合 prose（`--new`、`download report`、`on_fail_version` "…< 0.3.4 broken" 语义反转）+ 回退方案。 |
| 4. 补两角度 | **已闭合** | (a) ADR-0028 typosquat/供应链反模式补入 CE3’；(b) 0.8.2 Android gRPC backend（[S16]）作为抗 Web-UI 脆弱加固候选补入 CE7，并给出"暂不采纳、仅登记"的取舍理由。 |
| 额外：版本耦合 prose / 本机 venv 缺失 | **已闭合** | 纳入改造清单（见条件 3）；findings 明确"本机 venv 不存在 → 二级层为未部署态，非已损坏态"。 |

**复核结论**：4 条放行条件全部闭合；Critic 的 factual_accuracy=0.5 主因（跨代际外推）已由代码级证据消解到合理置信区间，artifact 可追溯性（AC6）已补。RG3 复核判定 **PASS（CONDITIONAL 条件已满足）**。
