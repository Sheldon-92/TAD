---
# Quality Chain Metadata (Alex 必填)
task_type: research   # 设计文档 + DR + 示例 manifest（服务下游 Phase 2 构建）
e2e_required: no
research_required: yes  # 回溯起点取证（git tag 调查 + 在野版本证据）
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-09
**Project:** TAD Framework
**Task ID:** TASK-20260609-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260609-upgrade-lifecycle-system.md (Phase 1/6)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-09 (专家审查后)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Schema 契约层定位清晰；FR1.5 消费者语义 + NFR1 前向兼容补全（BA 3 P0 已整合）；与既有 3 工具（derive-sync-set/release-verify/tad.sh）接口关系明确 |
| Components Specified | ✅ | 6 个交付物逐一规格化；manifest 骨架含冻结 merge shape + min_engine_version；4 canonical 锚点定义 |
| Functions Verified | ✅ | MQ2 表：--zero-touch/--transient/derive_target_version/release-verify 模式均 Read 验证；apply_deprecations 现状（L471-477/L673-745）由 code-reviewer 实读确认 |
| Data Flow Mapped | ✅ | MQ3 manifest section → 消费者对照表；ZERO_TOUCH 单一权威源引用链；FR4d 双调用方版本格式 normalize 契约 |

**Gate 2 结果**: ✅ PASS

**附注**:
- 专家审查：code-reviewer + backend-architect，7 P0 / 10 P1 / 9 P2 全部 Resolved（§9.2 Audit Trail）
- 唯一降级项：AC12 live dry-run 因 Bash 分类器会话中断未实跑，已静态验证（=9）并升格为 Blake Task 0 硬性 preflight 门 — 诚实记录于 AC Dry-Run Log

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Migration Manifest **schema v1 设计**（纯设计 Phase，不写执行代码）：
1. `.tad/migrations/{from}-to-{to}.yaml` 的字段规范（delete / rename / merge / verify 四个 section）
2. 回溯起点决定（DR，基于 git tag + 在野版本证据）
3. 用户修改检测方案选型（DR，≥2 候选对比）
4. 一个手写示例 manifest：`2.26.0-to-2.27.0.yaml`（schema 的活 fixture）

### 1.2 Why We're Building It

**业务价值**：TAD 远程升级有结构性缺口 — 废旧文件不清理、改名造成重复、无 migration 记录、验证不查旧文件。Schema 是整个升级生命周期机制的契约层，后续 5 个 Phase（引擎/接入/merge/门禁/验收）全部建立在它之上。
**用户受益**：远程用户和 14 个本地项目升级后零垃圾残留，用户数据永不被触碰。
**成功的样子**：Phase 2 的引擎作者可以只读 schema 文档就写出正确的解析器；未来任何版本的 manifest 都不需要 schema 破坏性变更。

### 1.3 Intent Statement（意图声明）

**真正要解决的问题**：定义一个**长期契约**——"版本 A 到版本 B 需要删什么、改名什么、合并什么、验证什么"的机器可读格式，让升级行为可声明、可验证、可链式组合。

**不是要做的（避免误解）**：
- ❌ 不是写 migration 执行引擎（Phase 2）
- ❌ 不是修改 tad.sh 或 *sync（Phase 3）
- ❌ 不是批量生成历史 manifest（Phase 5 — 本 Phase 只手写 1 个示例）
- ❌ 不是重新设计 sync 的 deny-list（已有机制，schema 只引用它）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个 Phase 解决什么问题？
2. schema 的消费者是谁？
3. 成功的标准是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read `.tad/project-knowledge/principles.md`（重点：4 条 deny-list/sync 相关 SAFETY entries）
2. Read `.tad/project-knowledge/patterns/handoff-design.md`、`patterns/ac-verification.md`、`patterns/shell-portability.md`
3. Read 本节"⚠️ Blake 必须注意的历史教训"

### 步骤 1：识别相关类别
- [x] architecture - 架构决策（schema 契约设计）
- [x] code-quality - deny-list/验证模式
- [x] security - 误删用户数据防护

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 4 条 | deny-list 系列 SAFETY entries（见下） |
| patterns/handoff-design.md | 3 条 | Registry field 设计、auto-generated vs decision state 分离 |
| patterns/ac-verification.md | 2 条 | AC dry-run 纪律、self-leak 防护 |
| patterns/shell-portability.md | 2 条 | yq 归一化、LC_ALL=C |

**⚠️ Blake 必须注意的历史教训**：

1. **Deny-List Beats Allow-List for Sync Sets**（principles.md, 2026-06-01）
   - 问题：allow-list 在结构演化时静默遗漏（codex/ 目录冻结一个月）
   - 应用：schema 的 delete 列表是"操作清单"不是"同步集合"——它**必须**是显式枚举（操作不可默认）；但 schema 的 ZERO_TOUCH 保护引用 `derive-sync-set.sh --zero-touch` 公共 flag，不得抄写内部变量（避免双源漂移）

2. **Deny-List Must Be Applied at EVERY Copy Granularity**（principles.md, 2026-06-01）
   - 问题：dir 层修了 deny-list，file 层的扩展名 glob 仍是 allow-list，病灶转移
   - 应用：schema 必须同时覆盖 dir 级和 file 级操作的表达，且 verify section 的粒度必须与操作粒度对称

3. **A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover Loss**（principles.md, 2026-06-01）
   - 应用：verify section 的设计禁止"全局计数下限"型断言，必须 per-path/per-category presence 断言

4. **Auto-Generated Registry → Persisted Decision State in Side-File**（patterns/handoff-design.md, 2026-05-31）
   - 应用：manifest 是**手工/半自动维护的决策文件**，不是自动生成产物——schema 文档必须声明这一点，且 Phase 5 的生成脚本只产 draft，人工确认后才入库

5. **mikefarah yq -i Normalizes Whole File on First Write**（patterns/shell-portability.md, 2026-05-31）
   - 应用：如果设计中假设工具会用 yq 编辑 manifest，schema 示例文件应当已是 yq-normalized 形态，避免未来 byte-identity AC 失效

6. **AC Verification Drift / dry-run 纪律**（patterns/ac-verification.md, 2026-04-25）
   - 应用：DR 和 schema 文档中给出的任何示例验证命令，必须在文档内附 dry-run 输出

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题

### Research Notebook Findings
Notebook: **"AI Agent Framework Installers — Platform Selection, Selective & Progressive Install Landscape 2026"**（active, .tad/research-notebooks/REGISTRY.yaml）
- 本 Phase 取证步骤中，Blake **应当**用 `*research-notebook ask` 向该 notebook 查询："mainstream AI agent framework installers 如何处理版本升级时的文件删除/重命名/migration manifest？有哪些 schema 设计可借鉴？"
- 查询结果作为 schema 设计的外部参照写入研究证据文件（§6 Task 1）
- CLI: `~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n <id>`（preflight: `test -x ~/.tad-notebooklm-venv/bin/notebooklm`；不可用则 WebSearch 降级并在证据中注明）

---

## 2. Background Context

### 2.1 Previous Work（已有基础 — 复用不重写）
- `tad.sh`：已有 `--yes` / `--verify-denylist` / `--platform` / `derive_target_version`（version.txt 权威派生）；安装+升级一体
- `.tad/hooks/lib/derive-sync-set.sh`：DENY_LIST 唯一权威源，公共 flags `--dirs/--zero-touch/--transient/--registry-only/--report`，exit 契约 0/2
- `.tad/hooks/lib/release-verify.sh`：structural + version 模式，文档化 exit-code 契约（0=pass / 1=fail named / 2=usage）
- `.tad/deprecation.yaml`：现存的按版本文件清理机制（v2.3.0 AGENTS.md 等）— **schema 设计必须明确它与 migration manifest 的关系（吸收/共存/废弃）**

### 2.2 Current State
- 无 `.tad/migrations/` 目录，无 manifest 格式
- tad.sh 升级 = 复制新文件 + deprecation.yaml 有限清理，不删除"新版不再存在"的文件
- 已知具体案例：v2.27.0 删除了 `blake/references/completion-protocol.md`，远程升级用户该文件仍残留

### 2.3 Dependencies
- git tags（v1.0.0–v2.27.0 连续存在，packed-refs 验证过 v2.23 及更早；v2.24+ 为 loose refs）
- 14 个注册项目当前全部 2.27.0（sync-registry.yaml，2026-06-09 同步）
- 已知在野最老远程版本：v2.19.1（principles.md 记载）

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Schema 文档定义 4 个 section（delete/rename/merge/verify），每字段含类型、约束、示例、错误形态反例。文档必须含 4 个**逐字 canonical 标题锚点**：`## Section: delete` / `## Section: rename` / `## Section: merge` / `## Section: verify`（AC 逐个 grep -cF 断言，防全局计数失效 — principles Coverage-Gate-Floor 教训）

- FR1.5 **Consumer Semantics Contract**（BA-P0-1）：schema 文档必须规范性定义消费者行为语义，缺一不可：
  a. **未知 `schema_version` 处理**：消费者读到高于自身支持的 schema_version → MUST hard-fail（拒绝执行整个 manifest + 报错建议升级引擎/clean reinstall）。远程旧引擎读新 manifest 是主场景
  b. **未知字段策略（per-section）**：delete/rename 条目含未识别字段 → fail-closed 拒绝该 manifest（防语义降级误删）；verify 条目含未识别字段 → 忽略+警告（验证宽松无害）
  c. **跨 section 路径冲突优先级**：同一路径同时出现在 delete 和 rename.from / delete 和 verify.present → manifest 非法（schema 层拒绝），不定义运行时优先级
  d. **Section 执行顺序**：rename → delete → merge → verify（固定声明，禁止引擎自选）；section 内按文件顺序执行
  e. **空 section 与缺失 section 等价**：`delete: []` ≡ 缺失 `delete:` ≡ `delete:`(null)，消费者必须三者同义处理

- FR2: 路径安全约束 = **allow-list 型 normalization + assertion 流水线**（CR-P0-2 — 注意：路径安全用 allow-list，与 sync 集合的 deny-list 原则是相反工具对相反问题，schema 文档必须写明这个对比，防止误用 principles 的 deny-list 教训）：
  1. **Normalize**：拒绝前后空白；拒绝空字符串/纯空白路径；拒绝 NUL/控制字符/换行；拒绝尾部斜杠（目录操作用显式 `type: dir` 字段，不用尾斜杠表达）
  2. **Reject-if-forbidden**：禁止 `*` `?` `[`（通配符）；禁止 `..`（任何位置）；禁止 `~` 开头（tilde 展开）；禁止 `/` 开头（绝对路径）；禁止 `\`（Windows 分隔符）；禁止 `-` 开头（leading-dash 选项注入——同时 schema 强制要求引擎使用 `rm -- ` end-of-options，不得假设）
  3. **Assert-prefix**：必须以 `.tad/`、`.claude/`、`.codex/` 开头，或 ∈ 显式列举的 root 文件 allow-list（如 CLAUDE.md、AGENTS.md、tad.sh）
  4. **Assert-realpath-containment + not-symlink**（引擎层执行，schema 层声明）：执行 delete/rename 前 resolve realpath 必须包含于 repo root 之下，且路径任何 component 不得是 symlink——这是"绝不误删"的最后防线（`rm -rf` 经 symlink 可逃逸 repo）
  5. 以上规则必须以**可运行 validator 片段**（grep -E / case-glob，BSD 兼容）+ 1 组合法/非法示例对的形式写出，供 Phase 2 引擎直接采用；含空格路径必须安全（repo 路径本身含空格）

- FR3: ZERO_TOUCH 双重拦截设计：schema 层（写入即非法）+ 引擎层（执行时拒绝，Phase 2 实现）；schema 文档引用 `derive-sync-set.sh --zero-touch` 作为唯一权威源。**禁止在 schema 文档中转写目录数量或清单**——引用 flag 的运行时输出，不引用数字（BA-P1-5：lib 注释 L48/L52 写 8、字面量实为 9 项，存在注释漂移；引用数字会继承漂移）

- FR4: 链式升级规则（声明式，BA-P1-2 精确化）：
  a. "相邻"定义 = manifest 存在集上按 `sort -V` 排序的下一个版本（含 patch 版本，2.22.0→2.22.1→2.23.0 全链）
  b. **仅前向**：检测到 from ≥ to → 拒绝执行 + 明确报错（禁止反向跑 delete 列表 — 删除安全问题）
  c. 链缺口（from→to 无完整 manifest 链可达）→ 报错 + 建议 clean reinstall（引擎层行为，schema 层声明）
  d. `from`/`to` 规范格式：带引号三段式 semver 字符串（`"2.26.0"`），调用方（tad.sh 的 version.txt / *sync 的 sync-registry）必须 normalize 到此格式再匹配（BA-P1-1；检测机制本身是 Phase 3 职责，schema 只declare格式契约）
  e. **文件名 ↔ 字段一致性不变式**：`{from}-to-{to}.yaml` 文件名必须与文件内 `from`/`to` 字段一致，字段为权威（BA-P2-2）

- FR5: DR-1 回溯起点：基于 git tag 完整列表 + 在野版本证据，决定从哪个版本对开始建 manifest；≥2 个**具名证据源**（每个证据 = 独立引用行，含来源标记，非词频）

- FR6: DR-2 用户修改检测方案：≥2 候选对比（如：发布版 hash 库 vs git tag 内容对照 vs "与当前发布版不一致即跳过"简化方案），必须含**成本/精度/维护负担**三维对比矩阵

- FR7: 示例 manifest `2.26.0-to-2.27.0.yaml`：真实反映 v2.26→v2.27 的实际文件变化（用 git diff 两个 tag 取证，不凭记忆）。**单向溯源即可**：manifest 的每条 delete/rename 必须可追溯到 diff 的 D/R 行；但 manifest 不必穷尽 diff（manifest 是"批准删除的 allow-list"，不是 diff 完整性镜像——schema 文档必须写明这一点，防止未来被误用作 coverage gate；CR-P1-3）

- FR8: Schema 与 `deprecation.yaml` 的关系 → 升格为 **DR-3**（独立 Decision Record，CR-P0-3），必须解决：
  a. **裁决约束**（BA-P1-3）：默认裁决必须是吸收（absorb）或取代（supersede）——删除操作单一权威源；"共存"仅当两机制有可证明的不相交领域（如 deprecation.yaml 冻结为 pre-migration 遗留、manifest 接管全部未来）+ 书面不重叠不变式时才可接受
  b. **执行顺序契约**：tad.sh 已在升级中调用 `apply_deprecations`（tad.sh:474，先清理后复制有顺序依赖）；DR 必须声明 migration 引擎与 apply_deprecations 的执行顺序与幂等契约，防双删/竞态
  c. **版本比较器一致**：apply_deprecations 实际用 `sort -V`（tad.sh:744）但 L721 注释错写 lexicographic；FR4 链解析必须采用同一比较器并在 DR 中点名引用（顺带在 DR 中记一行：Phase 3 触及此路径时修正误导性注释）
  d. **路径安全升级论据**：`apply_deprecations` 现状 `rm -rf -- "$target"` 无任何路径校验（tad.sh:724-726）——吸收 = 安全升级（旧机制纳入 FR2 流水线），这是吸收派的核心论据，DR 必须评估

### 3.2 Non-Functional Requirements
- NFR1: Schema 前向兼容（BA-P0-2/P0-3 强化）：
  a. `schema_version`（int，本版=1）+ FR1.5a 的未知版本 hard-fail 语义
  b. **merge 条目 shape 本 Phase 完整冻结**（不只是字段名占位）：`{path, strategy: "tad-head-marker", marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->", on_missing_marker: "skip_and_report"}` — Phase 4 只实现执行，不改 shape。占位字段名 ≠ 前向兼容
  c. **预留 `min_engine_version`**（manifest 级，optional，defined-now/enforced-later）：未来新增操作类型/verify 类型时，旧引擎据此 fail-closed 而非静默误执行；缺失 = 无要求
  d. **平台作用域扩展规则**（BA-P1-4）：本版不定义 `platform:` 字段，但 schema 文档的 forward-compat section 必须声明加法扩展规则："条目缺失 platform 键 = 适用全平台；未来加 `platform:` 键是 additive、非破坏性"
  e. 可选 `generated_by` 来源字段（手写 vs Phase 5 脚本起草），使"决策文件非生成产物"边界机器可见（BA-P2-4）
- NFR2: 示例与文档全部 BSD/macOS 可验证（无 grep -P；LC_ALL=C 排序敏感处注明；含空格路径全部加引号）
- NFR3: manifest 必须可被严格 YAML parser 解析（`python3 yaml.safe_load`），含冒号的字符串加引号（Codex 严格 parser 教训）。Schema 文档必须含 **YAML 陷阱规则**（CR-P1-5）：版本号必须带引号三段式（`2.26` 裸写会解析成 float、`2.30`→`2.3`）；`schema_version` 显式声明 int 类型；section 必须是 list-of-maps，**禁止** map-keyed-by-path 替代形态（key 去重会静默吞掉重复路径条目，并写明理由）；`reason`/`strategy` 等自由文本一律加引号（含失败示例）；空 section 三形态等价（FR1.5e）；交付的示例文件必须已是 yq-normalized 形态（防未来 byte-identity AC 失效）
- NFR4: `verify` section 同时是**幂等性 oracle**（BA-P2-1）：delete 之后的 `type: absent` verify 即"已应用"判据；schema 文档明确声明这一双重职责，Phase 2 不得另造平行机制

---

## 4. Technical Design

### 4.1 Architecture Overview

```
.tad/evidence/designs/migration-manifest-schema-v1.md  ← 本 Phase（schema 规范，唯一位置）
.tad/migrations/
├── 2.26.0-to-2.27.0.yaml                              ← 本 Phase（示例；目录需 mkdir -p 创建）
└── (Phase 5 回溯批量生成其余)

消费者链：
  manifest ──读──> migration-engine.sh (Phase 2)
           ──读──> release-verify.sh migration mode (Phase 5)
           ──引用──> derive-sync-set.sh --zero-touch (保护边界)
```

### 4.2 Component Specifications

**Manifest 骨架（Blake 在 schema 文档中细化；已含专家审查修订）**：
```yaml
schema_version: 1            # int（显式声明类型）
min_engine_version: "2.28.0" # optional；缺失=无要求（NFR1c 预留）
from: "2.26.0"               # 带引号三段式 semver（NFR3 陷阱规则）
to: "2.27.0"                 # 必须与文件名一致，字段为权威（FR4e）
generated_by: "manual"       # optional: manual | draft-script（NFR1e）
delete:
  - path: ".claude/skills/blake/references/completion-protocol.md"
    type: "file"             # file | dir（显式，禁止尾斜杠表达目录）
    reason: "v2.27.0 progressive loading 重组"
rename:
  - from: ".tad/old-name.md"
    to: ".tad/new-name.md"
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"   # shape 本 Phase 冻结（NFR1b）
    on_missing_marker: "skip_and_report"            # Phase 4 实现执行
verify:
  - type: "absent"
    path: ".claude/skills/blake/references/completion-protocol.md"
  - type: "present"
    path: ".claude/skills/blake/SKILL.md"
```
（以上是 Alex 的草图——Blake 设计时可改字段名/结构，但 4 section + schema_version + min_engine_version 预留 + merge 完整 shape + 路径安全流水线 + per-path verify + FR1.5 消费者语义不可少）

### 4.3 Data Models
manifest = 声明式操作清单（决策文件，人工维护 + Phase 5 脚本辅助起草）。**不是**自动生成产物。

### 4.4 API Specifications — N/A（设计 Phase）
### 4.5 User Interface Requirements — N/A

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**回答**：[x] 是 — 用户机制构想基于既有工具。
**搜索证据**：Alex 已 Read 三个既有工具头部（见 §7.3 Grounded Against）。决定：✅ 复用 `derive-sync-set.sh` 公共 flags + `release-verify.sh` exit 契约 + `tad.sh` 既有参数体系；schema 是新契约层，但保护边界全部引用既有权威源。
**Blake 补充取证**：实现时必须 `git diff v2.26.0 v2.27.0 --name-status` 取真实文件变化（FR7）。

### MQ2: 函数存在性验证

| 函数/接口 | 文件位置 | 验证 |
|--------|---------|------|
| `derive-sync-set.sh --zero-touch` | .tad/hooks/lib/derive-sync-set.sh:16-18 | ✅ Alex Read 确认 |
| `derive-sync-set.sh --transient` | .tad/hooks/lib/derive-sync-set.sh:19-23 | ✅ Alex Read 确认 |
| `tad.sh derive_target_version` | tad.sh:28-37 | ✅ Alex Read 确认 |
| `release-verify.sh structural/version` | .tad/hooks/lib/release-verify.sh:9-50 | ✅ Alex Read 确认 |

### MQ3: 数据流完整性
设计 Phase 数据流 = manifest 字段 → 消费者：

| Manifest section | 消费者 | 何时消费 |
|---------|---------|---------|
| delete/rename | migration-engine.sh | Phase 2 执行 |
| merge | migration-engine.sh | Phase 4 执行 |
| verify | engine 升级后自检 + release-verify | Phase 2/5 |
| schema_version | 所有消费者（前向兼容门） | 永久 |

每个 section 必须有 ≥1 个声明的消费者 — schema 文档需包含此对照表。

### MQ4: 视觉层级 — [x] 无不同状态（文档交付物），跳过
### MQ5: 状态同步
**单一状态**：manifest 文件本身是唯一 source of truth；ZERO_TOUCH 列表权威源在 derive-sync-set.sh（schema 引用不复制）。
```
.tad/migrations/*.yaml (唯一存储，git 版本控制)
✅ 无双写状态；唯一引用关系 = --zero-touch flag（运行时读取）
```

---

## 6. Implementation Steps

### Task 0: Preflight（硬性门，CR-P1-4 — 不可跳过）
1. `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch | wc -l` → 必须输出 9（AC12 live run；Alex 因 Bash 中断只做了静态验证）
2. `git tag -l | grep -c 'v2.26.0\|v2.27.0'` → 必须 ≥2（tag 对存在）
3. 任一失败 → STOP，返回 Alex

### Task 1: 取证（预计 1h）
1. `git tag -l | sort -V` 全列表 + 相邻 tag 对枚举
2. `git diff v2.26.0 v2.27.0 --name-status` → 真实 delete/rename/add 清单（FR7 数据源）；**原始输出全文粘贴**进证据文件（含 `D\t`/`R100\t` 行，转述不算）
3. 在野版本证据收集：principles v2.19.1 记载 + 其他可得证据（每个证据独立引用行 + 来源标记）
4. NotebookLM ask（Installer notebook）→ 外部 schema 设计参照
5. 读 tad.sh `apply_deprecations`（L471-477 调用点 + L673-745 实现）→ 为 DR-3 取证：执行顺序、`sort -V` 比较器、`rm -rf -- "$target"` 无校验现状
6. 产出研究证据文件：`.tad/evidence/research/2026-06-09-migration-schema-evidence.md`

### Task 2: Schema 文档（预计 3-4h）
1. 写 `.tad/evidence/designs/migration-manifest-schema-v1.md`，必含 section（FR1 的 4 个 canonical 锚点标题逐字使用）：
   - `## Section: delete` / `## Section: rename` / `## Section: merge` / `## Section: verify` 字段规范
   - 路径安全流水线（FR2 五步，含可运行 validator 片段 + 合法/非法示例对）
   - Consumer Semantics Contract（FR1.5 a-e 全部）
   - ZERO_TOUCH 引用设计（FR3，引用 flag 不引用数字）
   - 链式规则（FR4 a-e）
   - 前向兼容 section（NFR1 a-e：schema_version 语义 + merge 冻结 shape + min_engine_version + platform 加法扩展规则 + generated_by）
   - YAML 陷阱规则（NFR3）
   - verify 幂等 oracle 声明（NFR4）
   - 消费者对照表（MQ3）
   - allow-list-for-paths vs deny-list-for-sync-sets 对比说明（FR2 引言）
   - manifest 非穷尽声明（FR7 — 防误用作 coverage gate）
2. 每个字段配 1 个合法示例 + 1 个非法反例（说明为何非法）

### Task 3: 三个 DR（预计 2h）
1. `DR-20260609-migration-backfill-depth.md`：回溯起点（FR5，≥2 具名证据源）
2. `DR-20260609-user-modified-detection.md`：检测方案选型（FR6，成本/精度/维护三维矩阵）
3. `DR-20260609-deprecation-yaml-disposition.md`：deprecation.yaml 裁决（FR8 a-d；裁决 token 必须是 吸收/absorb、取代/supersede 或带不重叠不变式的 共存/coexist 之一）
4. 三个 DR 都用 .tad/decisions/ 现行格式（参考目录内已有 DR）

### Task 4: 示例 manifest（预计 0.5-1h）
1. `mkdir -p .tad/migrations/`（目录尚不存在）
2. 基于 Task 1 第 2 步的真实 diff 写 `.tad/migrations/2.26.0-to-2.27.0.yaml`
3. 严格 YAML parser 自检（NFR3）+ yq normalize（交付已 normalized 形态）
4. 对照 schema 文档逐字段自检并在 completion report 记录

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/designs/migration-manifest-schema-v1.md      # Schema v1 规范
.tad/decisions/DR-20260609-migration-backfill-depth.md     # DR-1 回溯起点决定
.tad/decisions/DR-20260609-user-modified-detection.md      # DR-2 用户修改检测选型
.tad/decisions/DR-20260609-deprecation-yaml-disposition.md # DR-3 deprecation.yaml 裁决（CR-P0-3）
.tad/migrations/2.26.0-to-2.27.0.yaml                      # 示例 manifest（活 fixture；mkdir -p）
.tad/evidence/research/2026-06-09-migration-schema-evidence.md  # 取证记录
```

### 7.2 Files to Modify
```
(无 — 纯新建设计 Phase；不改 tad.sh / derive-sync-set.sh / release-verify.sh)
```

### 7.3 Grounded Against (Alex step1c 实际 Read 过的源文件)
- .tad/hooks/lib/derive-sync-set.sh (head 60, read at 2026-06-09)
- tad.sh (head 60, read at 2026-06-09)
- .tad/hooks/lib/release-verify.sh (head 50, read at 2026-06-09)
- .git/packed-refs (tags 取证, read at 2026-06-09)
- .tad/sync-registry.yaml (head 60, read at 2026-06-09)
- .tad/evidence/designs/migration-manifest-schema-v1.md (new — will be created)
- .tad/decisions/DR-20260609-*.md ×2 (new — will be created)
- .tad/migrations/2.26.0-to-2.27.0.yaml (new — will be created)

---

## 8. Testing Requirements

设计 Phase 无单元测试；验证 = §9.1 文档结构断言 + YAML parser 自检 + 真实 diff 对照。

### 8.4 Test Evidence Required
- [ ] `git diff v2.26.0 v2.27.0 --name-status` 原始输出（粘贴进研究证据文件）
- [ ] 示例 manifest 的 `yaml.safe_load` 自检输出
- [ ] NotebookLM ask 查询输出（或 WebSearch 降级记录）

---

## 9. Acceptance Criteria

实现完成当且仅当：
- [ ] FR1-FR8 全部落实并有对应文档 section
- [ ] §9.1 全行 PASS
- [ ] 取证文件含原始命令输出（不是转述）

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1a | Schema 文档含 4 个 canonical section 锚点（逐字，per-category 断言） | post-impl-verifiable | `for s in delete rename merge verify; do grep -cF "## Section: $s" .tad/evidence/designs/migration-manifest-schema-v1.md; done` | 4 行输出，每行恰好 = 1 | (post-impl) |
| AC2a | 禁止字符逐项写出（非提及话题） | post-impl-verifiable | `for t in '*' '?' '[' '..' '~' '\\'; do grep -cF -- "\`$t\`" .tad/evidence/designs/migration-manifest-schema-v1.md; done` | 6 行输出，每行 ≥ 1（每个禁止 token 以反引号代码形态独立出现） | (post-impl) |
| AC2b | 前缀 allow-list 三项齐全 | post-impl-verifiable | `for p in '.tad/' '.claude/' '.codex/'; do grep -cF "$p" .tad/evidence/designs/migration-manifest-schema-v1.md; done` | 3 行输出，每行 ≥ 1 | (post-impl) |
| AC2c | 可运行 validator 片段 + 合法/非法示例对存在 | post-impl-verifiable | schema 文档含一个标注 `validator` 的代码块（`grep -c '```' 配合人工定位 validator 块`）；从文档复制该片段实跑：喂 1 个合法路径 exit 0、喂 1 个非法路径（含 `..`）非 0 | validator 片段实跑双向判别正确 | (post-impl) |
| AC2d | symlink/realpath containment 声明存在 | post-impl-verifiable | `grep -cE 'realpath\|symlink' .tad/evidence/designs/migration-manifest-schema-v1.md` | ≥ 2（流水线第 4 步声明） | (post-impl) |
| AC3 | ZERO_TOUCH 引用公共 flag 而非抄写 | post-impl-verifiable | `grep -c 'derive-sync-set.sh --zero-touch' .tad/evidence/designs/migration-manifest-schema-v1.md` 且哨兵反查 `grep -c 'skillify-candidates' <同文件>` | 前者 ≥ 1；**后者 = 0**（哨兵目录名出现 = 抄写嫌疑，CR-P2 机械化） | (post-impl) |
| AC4 | 回溯起点 DR ≥2 具名证据源 | post-impl-verifiable | `grep -cE '^- (Source\|来源):' .tad/decisions/DR-20260609-migration-backfill-depth.md` | ≥ 2（独立引用行，非词频） | (post-impl) |
| AC5 | 用户修改检测 DR ≥2 候选 + 三维对比 | post-impl-verifiable | `grep -cE '^#+ .*(候选\|Option) [A-Z0-9]' <DR-2>` 且 `grep -cE '成本\|精度\|维护' <DR-2>` | 前者 ≥ 2；后者 ≥ 3（对比矩阵维度词齐全） | (post-impl) |
| AC6 | 示例 manifest 通过严格 YAML 解析 | post-impl-verifiable | `python3 -c "import yaml,sys; yaml.safe_load(open('.tad/migrations/2.26.0-to-2.27.0.yaml'))"` | exit 0 | (post-impl) |
| AC7 | 示例 manifest 基于真实 tag diff（单向溯源） | post-impl-verifiable | 对照证据文件中粘贴的原始输出，manifest 每条 delete/rename 有对应 `D`/`R` 行 | 逐条可追溯；manifest 不要求穷尽 diff（FR7） | (post-impl) |
| AC8 | 前向兼容字段齐全 | post-impl-verifiable | `for k in schema_version min_engine_version marker on_missing_marker; do grep -c "$k" .tad/evidence/designs/migration-manifest-schema-v1.md; done` | 4 行输出，每行 ≥ 1（NFR1 a-c 全部落地） | (post-impl) |
| AC9 | DR-3 deprecation 裁决实质化 | post-impl-verifiable | `grep -cE '吸收\|absorb\|取代\|supersede\|共存\|coexist' .tad/decisions/DR-20260609-deprecation-yaml-disposition.md` 且 `grep -cE 'apply_deprecations' <DR-3>` 且 `grep -cE 'sort -V\|比较器\|comparator' <DR-3>` | 三个 grep 都 ≥ 1（裁决 token + 执行顺序契约 + 比较器一致，FR8 a-c） | (post-impl) |
| AC10 | 取证文件含真实 diff 输出（非命令转述） | post-impl-verifiable | `grep -cE '^(D\|R[0-9]*)[[:space:]]' .tad/evidence/research/2026-06-09-migration-schema-evidence.md` | ≥ 1（diff --name-status 的 D/R 行签名） | (post-impl) |
| AC11 | 交付完整 + 范围无越界 | post-impl-verifiable | `for f in <§7.1 的 6 个路径>; do test -f "$f" && echo OK; done` 且 `git status --short` | 6 个 OK（防漏交付）；status 只含 §7.1 文件（防越界） | (post-impl) |
| AC12 | derive-sync-set.sh --zero-touch 可用 | pre-impl-verifiable | `bash .tad/hooks/lib/derive-sync-set.sh --zero-touch \| wc -l` | **= 9**（已知集合精确断言，≥8 浮动下限是 global-floor 盲区，CR-P1-4） | 静态验证=9（lib :53-61 字面量）；live run = Blake Task 0 preflight 硬性门（Bash 分类器中断，见 Dry-Run Log） |

**AC Dry-Run Log** (Alex step1d at 2026-06-09，专家审查后 r2):
- AC12: ⚠️ pre-impl-verifiable — Bash 分类器会话级中断，无法实跑。降级为**静态验证**：Read 确认 ZERO_TOUCH 字面量 = 9 项（derive-sync-set.sh:53-61，含 skillify-candidates）。Expected 已按 CR-P1-4 从 ≥8 收紧为 **= 9**。live run 已升格为 Blake **Task 0 preflight 硬性门**（不只是 AC 注记）。
- AC1a/AC2a/AC2b/AC8: ✅ per-category for-loop 断言（每项独立 = 1 或 ≥ 1），替代 r1 的全局计数（CR-P0-4/P0-1 修复）。语法审查：grep -cF 字面匹配无正则歧义；`--` 保护 leading-dash token。
- AC2c: 半自动 — validator 片段实跑由 Blake 在 Gate 3 执行并粘贴输出（双向判别：合法 exit 0 / 非法非 0）。
- AC3 哨兵反查 / AC9 三重 grep / AC10 D-R 行签名: 判别性强化（CR-P2 / CR-P0-3 / CR-P2 对应）。
- AC7 前提验证: ✅ tag 对存在 — v2.26.0 (2c13b54) + v2.27.0 (a582412)，Read .git/refs/tags 确认。
- 表格内 `\|` 为 markdown 转义，实跑时按 §9.1 pipe-escape note 还原为裸 `|`。所有 grep 均 BSD 兼容（无 -P）。

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: AC2 vacuous（词频证明不了机械可验证规则） | §9.1 AC2a/2b/2c/2d 拆分 + FR2 流水线第 5 步 | Resolved |
| code-reviewer | CR-P0-2: FR2 路径安全缺 symlink/~/空路径/尾斜杠/空格/leading-dash 向量 | §3.1 FR2 五步 allow-list 流水线（1-5 全向量）+ §4.2 骨架 `type: file\|dir` | Resolved |
| code-reviewer | CR-P0-3: FR8 deprecation 关系欠规范（双删/比较器/无校验现状未触及）| §3.1 FR8 a-d + 升格 DR-3 + §6 Task 1 第 5 步取证 + §9.1 AC9 三重 grep | Resolved |
| code-reviewer | CR-P0-4: AC1 全局计数可被无关标题凑满 | §9.1 AC1a per-category grep -cF 逐锚点断言 + FR1 canonical 锚点 | Resolved |
| code-reviewer | CR-P1-1: AC4 词频可刷 | §9.1 AC4 改为独立引用行计数（`^- (Source\|来源):`）+ FR5 具名证据源 | Resolved |
| code-reviewer | CR-P1-2: AC5 两个空标题可过 | §9.1 AC5 双重断言（候选标题 + 三维度词）+ FR6 三维矩阵 | Resolved |
| code-reviewer | CR-P1-3: AC7 单向溯源需声明非穷尽 | §3.1 FR7 非穷尽声明 + §6 Task 2 必含 section | Resolved |
| code-reviewer | CR-P1-4: AC12 floor ≥8 是 global-floor 盲区；preflight 非硬性 | §9.1 AC12 = 9 精确断言 + §6 Task 0 硬性门 | Resolved |
| code-reviewer | CR-P1-5: §4.2 YAML 类型陷阱未警示 | §3.2 NFR3 陷阱规则 + §4.2 骨架注释 | Resolved |
| code-reviewer | CR-P2: AC3 人工核对/AC10 命令转述/AC11 漏交付/mkdir/SCHEMA.md 二义/tad.sh:721 注释 bug | AC3 哨兵反查 / AC10 D-R 签名 / AC11 test -f / Task 4 mkdir / §4.1 单一位置 / FR8c 注释 bug 记入 DR-3 | Resolved |
| backend-architect | BA-P0-1: 消费者语义契约整体缺失（unknown version/fields/冲突/顺序/空section） | §3.1 FR1.5 a-e + §6 Task 2 必含 + §9.1 AC8 | Resolved |
| backend-architect | BA-P0-2: merge 字段名占位 ≠ 前向兼容，Phase 4 必破坏 | §3.2 NFR1b merge shape 本 Phase 完整冻结（marker + on_missing_marker）+ §4.2 骨架 | Resolved |
| backend-architect | BA-P0-3: 缺 min_engine_version 预留，首个新能力即破坏性变更 | §3.2 NFR1c 预留（defined-now/enforced-later）+ §9.1 AC8 | Resolved |
| backend-architect | BA-P1-1: 双调用方版本格式无规范声明 | §3.1 FR4d 规范格式 + 调用方 normalize 契约（机制归 Phase 3） | Resolved |
| backend-architect | BA-P1-2: "相邻"未定义（patch 版本）；降级未处理 | §3.1 FR4a/4b（sort -V 全 tag 链 + 仅前向 + from≥to 拒绝） | Resolved |
| backend-architect | BA-P1-3: FR8 自由"共存"= 双权威源漂移 | §3.1 FR8a 裁决约束（默认吸收/取代；共存需不重叠不变式） | Resolved |
| backend-architect | BA-P1-4: platform 作用域未预留 | §3.2 NFR1d 加法扩展规则声明（本版不定义字段，声明扩展路径） | Resolved |
| backend-architect | BA-P1-5: lib 注释 8-vs-9 漂移会被 schema 继承 | §3.1 FR3 禁止转写数量/清单，引用 flag 运行时输出 | Resolved |
| backend-architect | BA-P2: verify=幂等 oracle / 文件名↔字段不变式 / generated_by | §3.2 NFR4 / §3.1 FR4e / §3.2 NFR1e | Resolved |

### Experts Selected
1. **code-reviewer** — 必选；schema 契约的可验证性、AC 命令正确性、路径安全规则的完备性
2. **backend-architect** — schema 作为长期系统契约的架构审查；链式升级规则、版本检测、与既有 3 工具的接口关系

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS**（4 P0 + 5 P1 + 6 P2 全部 Resolved，见 Audit Trail）
- backend-architect: CONDITIONAL PASS → **PASS**（3 P0 + 5 P1 + 3 P2 全部 Resolved，见 Audit Trail）

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **绝不误删 > 漏删**：路径安全规则（FR2）是本 schema 最高约束。设计时任何"方便"的模糊匹配提案都必须拒绝
- ⚠️ **symlink 是最大误删漏洞**：`rm -rf` 经 symlink 可逃逸 repo（`a→$HOME` 则删 a/b 即删 $HOME/b）。FR2 第 4 步 realpath containment + not-symlink 是最后防线，schema 必须声明为引擎 MUST
- ⚠️ **既有 apply_deprecations 无任何路径校验**（tad.sh:724-726 `rm -rf -- "$target"` 直接取 YAML 值）— DR-3 的吸收裁决评估必须把"纳入 FR2 流水线 = 安全升级"作为核心论据
- ⚠️ **路径安全用 allow-list，sync 集合用 deny-list** — 相反工具对相反问题，schema 文档必须写明对比，防止套错 principles 教训
- ⚠️ manifest 是决策文件不是生成产物 — schema 文档必须写明（防 Phase 5 脚本直接覆盖人工决策）
- ⚠️ 示例 manifest 必须来自真实 `git diff`，禁止凭记忆列文件（principles 2026-05-28 manual-install 教训：凭记忆列 12/32 目录漏 14 个）
- ⚠️ repo 路径含空格（`01-on progress programs`）— 所有示例命令/validator 片段必须空格安全（引号包裹路径展开）

### 10.2 Known Constraints
- 本 Phase 零执行代码 — Alex 不写代码，Blake 本 Phase 也只写文档+YAML+DR
- merge 字段定义但不实现（Phase 4）
- BSD/macOS 兼容约束适用于文档中所有示例命令

### 10.3 Sub-Agent使用建议
- [ ] **test-runner** — 不适用（无测试）
- [x] 完成后 Layer 2 专家审查照常（code-reviewer + spec-compliance-reviewer）

---

## 11. Learning Content

### 11.1 Decision Rationale: 为什么先做 Schema 而不是先写引擎

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| Schema 先行（选中）| 契约稳定后 5 个下游 Phase 不返工；merge 字段预留避免破坏性变更 | 多一个 Phase 的流程成本 | ✅ 选中 |
| 引擎先行，schema 随写随定 | 见效快 | schema 被实现细节绑架；历史上 v2.7 "实现倒灌设计"造成质量链失效 | 教训在先 |

**💡 Human学习点**：长期契约（文件格式、API、协议）值得独立设计 Phase；一次性脚本不值得。区分标准 = 有多少未来消费者。

---

## 12. Sub-Agent使用记录
（Blake 完成后填写）

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-09
**Version**: 3.1.0
**Status**: Expert Review Complete — Ready for Implementation
