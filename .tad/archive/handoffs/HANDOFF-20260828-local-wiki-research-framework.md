---
task_id: TASK-20260828-LOCAL-WIKI
status: approved
owner: Alex
created: 2026-08-28
task_type: code
e2e_required: no
research_required: yes
gate2_note: >
  Gate 2 双专家审查已完成（2026-08-28, max_review_rounds 1/2）：
  code-reviewer: CONDITIONAL PASS (P0-1 scope, P0-2 enforcement, P1-1/2/3, P2-1)
  security-auditor: CONDITIONAL PASS (P0 Iron Rule 验证剧场, P0 YAML 注入, P1 凭据泄露/覆写, P2 供应链)
  2 个 P0 已在 handoff §4 AC 设计中闭环（见 §4.1 增量），剩余 P1 由 Blake 在 Gate 3 前闭环。
  审查载体：本文件 §11 + 两份独立 review 报告（见 evidence/reviews/alex/local-wiki/）。
---

# HANDOFF-20260828-local-wiki-research-framework

**From**: Alex (Solution Lead) | **To**: Blake (Execution Master)
**Epic**: 独立（关联 `EPIC-20260616-research-system-consolidation` Complete 后的下一代研究底座；不在 `framework-health-repair` 内）
**Design authority**: 本 handoff §1-§10 + `Sober Creator/research/CLAUDE.md` + `research/canon/README.md`（已验证的 wiki 宪法）
**Related decisions**: `Sober Creator/research/canon/_index.md` (227 条实战基线), `.tad/project-knowledge/patterns/research-methodology.md`

---

## 1. 任务概述

用 **本地 Wiki 三层架构（canon → raw → wiki）** 替换 TAD 中已不可用的 NotebookLM 研究链路，保留 `*research Quick/Standard/Deep` 原入口，对用户透明替换实现。消除 auth/30s 索引/假 ready 运维税，同时满足持久化/矛盾消解/引用溯源/GitHub-First/饱和停 5 项能力。

**当前基线**（Blake 开工前核对）：
- HEAD: `check git log --oneline -1`
- NotebookLM 状态：`REGISTRY.yaml` 30 notebook 全 `dormant/archived`，`~/.tad-notebooklm-venv` 不可用（Q1-c 已确认退役）
- 现有发现层：`research-github` 25 domains / 45 lists 可用，`source-preprocessor.sh` handlers 可用
- Sober 参考基线：`canon 227 / cited 27 / raw 19 wiki 18`（`wiki/index.md:15`），`lint 7 规则 PASS`

**不在本单**：恢复对 14 个下游项目的 `*sync`、`framework-health-repair` Phase 2 收口、向量库选型之外的 embedding 训练。

---

## 2. Socratic Inquiry Summary

**Complexity**: large（>3 文件，跨 skill/config/scripts，新增目录 + 约束）

### Key decisions（人类已拍板）
- 核心价值：4 项全要（持久化/综合/引用/GitHub/饱和），Q1-c 运维税为首要痛点
- 架构选型：**A 起步（纯本地 markdown）+ B 插槽（向量）**，C 极简方案排除
- 受控词表：**高包容 + 项目可扩展**（TAD 框架不能锁死 25 domains，每项目可增标签）
- 验收信号：**端到端跑通**为最重；最坏风险是“做了没人用”（机制过重）

### Clarified requirements
- 本地优先、文件即真值；云端仅作 embedding 可选 fallback
- 保留 `*research Quick/Standard/Deep` 入口（`EPIC-20260616` 已统一）
- 首版即需支持图文 + GitHub + 基础向量 + 视频/音频（用户明确“都要保留”）→ **经 Gate 2 修正**：分阶段，Phase1 图文+GitHub+Iron Rule，P2 视频/音频，P3 向量（见 §4.1）
- 受控词表新建，`core 12 + allow_extend` 带 `added_by` 追溯

### Risks identified
- 机制过重导致弃用 → 对策：wiki 模板极简 + `generate.py` 自动索引，人不手写
- 标签失控 → `lint WARN` + 扩展需 1 行 reason
- 引用断链 → Iron Rule 机械校验（AC2 负向用例）

### Acceptance criteria
见 §4；最终判定 = §7。

---

## 3. Scope

### 3.1 Allowed product files
```
research/CLAUDE.md                          # 新建：宪法（复刻 Sober，裁剪为 TAD 版）
research/canon/_topics.yaml                 # 新建：受控词表（core 12 + allow_extend）
research/canon/_questions.yaml              # 新建：6 维问题键（复用 socratic 6 维）
research/canon/_clusters.yaml               # 新建（可选，P1）
research/canon/_index.md                    # 生成：纯函数
research/canon/lint.sh                      # 新建：6 规则（含负向校验）
research/canon/{type}/{slug}.md             # 新建：首批 2 topic 的 canon 条目
research/raw/**                             # 新建：按媒介分（manifests/papers/articles/github）
research/wiki/index.md                      # 新建：Master directory
research/wiki/log.md                        # 新建：append-only
research/wiki/topics/*.md                   # 新建：首批 2 topic 骨架
research/wiki/research/*.md                 # 新建：首批研究页
research/scripts/generate.py                # 新建：--emit index|ammo|clusters
research/scripts/ingest.sh                  # 新建：封装 source-preprocessor
.tad/config-workflow.yaml                   # 修改：fallback primary notebooklm → local_wiki
.claude/skills/alex/SKILL.md               # 修改：*research 路由 + 引用 Iron Rule 正文
.claude/skills/alex/references/research-plan-protocol.md  # 修改：Deep 流程的 canon 循环
.claude/skills/research-github/SKILL.md    # 修改：notebook 命令产出改写 canon（shim）
.tad/project-knowledge/patterns/research-methodology.md  # 修改：新增 local-wiki 条目
```

### 3.2 Allowed evidence/state files
```
.tad/evidence/research/local-wiki/**       # 本单证据（含 lint 报告、迁移清单）
.tad/evidence/reviews/alex/local-wiki/**   # Gate 2 审查载体
.tad/evidence/reviews/blake/local-wiki/**  # Gate 3 Layer 2 报告
.tad/active/handoffs/COMPLETION-20260828-local-wiki-research-framework.md
.tad/active/session-state.md, NEXT.md, ROADMAP.md
```

### 3.3 Forbidden
- `.tad/hooks/**`、`.claude/settings.json`、`.codex/**`（除非本单 AC 明确授权）
- `.tad/evidence/research/agent-pack-factory/**`（历史证据，只读引用）
- `tad.sh`、`*sync` 相关（已退休，不得复活）
- 现有 30 个 NotebookLM notebook 的云端删除（仅本地归档，不得调 NotebookLM API 删除）

---

## 4. Work items and ACs

### AC-A — 目录与宪法（Phase 1 骨架）

创建 `research/` 三层目录 + `CLAUDE.md`（复刻 `Sober/research/CLAUDE.md` 的三层单向/Iron Rule/三档深度/饱和度定义，裁剪为 TAD 术语，≤80 行宪法 + 详规在 `canon/README.md`）。

**Verify**:
```bash
test -f research/CLAUDE.md && grep -q "Iron Rule" research/CLAUDE.md
test -d research/canon && test -d research/raw && test -d research/wiki
cat research/CLAUDE.md | wc -l | awk '{exit ($1<=120)?0:1}'  # 宪法精简
```

### AC-B — 受控词表（高包容设计）

`_topics.yaml`:
```yaml
core: [ai-agents, mcp-servers, rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph, web-frontend, web-backend]
allow_extend: true
extension_rule: "新 topic 需在首条 canon 的 frontmatter 写 added_by + reason: 1行"
```
`_questions.yaml`: 复用 `socratic_inquiry_protocol.question_dimensions` 6 维。

`lint` 对未注册 topic → `WARN`（不 FAIL），`_index.md` 标 `⚠️ unregistered`。

**Verify**:
```bash
yq -e '.allow_extend == true' research/canon/_topics.yaml
yq -e '.core | length == 12' research/canon/_topics.yaml
grep -q "value_validation" research/canon/_questions.yaml
```

### AC-C — Canon Schema 与示例（12 字段精简版）

复用 `Sober/research/canon/README.md` 的 15 字段，精简为 12（去 `identifiers.imdb` 等 TAD 无用键，保留 `title/what/type/citable/explores/topics/availability/verified_on/depth/wiki_page/raw_refs/provenance`）。

创建 2 条示例 canon：`research/canon/research/mcp-prompt-injection.md` + `research/canon/concepts/guardrail-layers.md`（各 1 topic，多挂）。

**Verify**:
```bash
test -f research/canon/research/mcp-prompt-injection.md
yq -e '.citable == false' research/canon/research/mcp-prompt-injection.md
yq -e '.explores | length >=1' research/canon/research/mcp-prompt-injection.md
awk '/^---$/ {c++} END{exit (c==2)?0:1}' research/canon/research/mcp-prompt-injection.md
# 正文 ≤15 行 / ≤120 词（lint 规则 3）
```

### AC-D — Raw 层与 ingest.sh（复用 source-preprocessor）

`research/scripts/ingest.sh` 封装 `.tad/cross-model/source-preprocessor.sh detect|validate|dispatch`，输入 URL → 输出 `raw/{medium}/{slug}.md` + 登记 `raw_refs`。**不得重实现** `normalize_url/validate_url`（`Never Hand-Write` 原则，`principles.md:54`）。

支持 `x_article/bilibili/arxiv_abs/substack/medium/generic_web`（`arxiv_pdf` 直通）。

**YAML 注入修复**（P0-2）：`original_url` 必须 `printf '%s' "$url" | yq` 安全转义，`lint` 规则 6 用 `ruby -ryaml` 解析 frontmatter 必须 PASS。

**Verify**:
```bash
bash research/scripts/ingest.sh "https://arxiv.org/abs/2401.00001" --dry-run  # 不写盘，测试 detect
grep -q "source-preprocessor.sh" research/scripts/ingest.sh
! grep -q "normalize_url()" research/scripts/ingest.sh  # 不得重实现
# 注入用例：含 "quote 的 URL 不应破坏 frontmatter
bash research/scripts/ingest.sh 'https://example.com/a?x="b"&y=1' --dry-run && echo "yaml safe"
```

### AC-E — Wiki 编译层与 Iron Rule（P0 核心）

创建 `research/wiki/topics/mcp-security.md` + `research/wiki/research/mcp-prompt-injection.md`（从 AC-C 的 canon 编译，含 3 条以上 `raw_refs` 引用，每条 `locator: p.X / para Y / timestamp`）。

**Iron Rule**：wiki 每条 claim 必须有 `raw_refs` 且 `locator` 可解析，`lint.sh` 6 规则：
1. frontmatter 合法 YAML
2. 正文 claim 数 == `raw_refs` 数（或 claims 段每条带 `[^raw/path]`）
3. `raw/path` 文件存在
4. `locator` 非空且格式 `p.|para|timestamp`
5. `depth` 派生一致（`wiki_page` 存在 → cited）
6. YAML 前置解析 PASS（防注入）

**Verify（负向为真值）**:
```bash
bash research/canon/lint.sh  # 正向 PASS
# 负向 1：缺 locator → FAIL
cp research/wiki/research/mcp-prompt-injection.md /tmp/bad.md && sed -i '' '/locator/d' /tmp/bad.md && ! bash research/canon/lint.sh /tmp/bad.md
# 负向 2：raw 路径不存在 → FAIL
cp research/wiki/research/mcp-prompt-injection.md /tmp/bad2.md && sed -i '' 's|raw/|raw/missing_|' /tmp/bad2.md && ! bash research/canon/lint.sh /tmp/bad2.md
# 负向 3：无 raw_refs → FAIL
cp research/wiki/research/mcp-prompt-injection.md /tmp/bad3.md && sed -i '' '/raw_refs/d' /tmp/bad3.md && ! bash research/canon/lint.sh /tmp/bad3.md
```

### AC-F — generate.py 纯函数索引

`research/scripts/generate.py --emit all` 生成 `research/canon/_index.md` + `research/wiki/index.md` + `research/wiki/topics/_clusters.md`（如有）。幂等：`diff <(run1) <(run2) == 0`。

**Verify**:
```bash
python3 research/scripts/generate.py --emit all
python3 research/scripts/generate.py --emit all > /tmp/run2.md && diff research/canon/_index.md /tmp/run2.md
grep -q "canon" research/canon/_index.md && grep -q "wiki" research/wiki/index.md
```

### AC-G — *research 入口透明替换

修改 `config-workflow.yaml: research_notebook.fallback_chains.research.primary: local_wiki`，`alex/SKILL.md` 的 `research_unified_protocol.routing_table` 标准路径改为 `local_wiki ask`（Quick 仍 WebSearch）。

`research-github` 的 `notebook` 命令保留别名，产出改写 `research/canon/*.md` 并提示 `*research --standard`。

**执行纪律必须在 SKILL 正文**（`principles.md:103`）：`*research` 路由 + Iron Rule 阻塞文本保留在 `alex/SKILL.md` body，不得仅放 `references/`。

**Verify**:
```bash
grep -q "local_wiki" .tad/config-workflow.yaml
grep -q "Iron Rule" .claude/skills/alex/SKILL.md
grep -q "research.*local_wiki\|local_wiki.*research" .claude/skills/alex/SKILL.md
# 旧 NotebookLM 路径降级提示仍存在
grep -q "NotebookLM" .claude/skills/alex/SKILL.md || echo "fallback note missing"
```

### AC-H — 端到端跑通（用户最重验收）

选 1 个未覆盖 topic（如 `mcp-security`），执行 `*research --standard "MCP prompt injection 防御"` 的等效手工链路：`ingest 3 源 → 建 canon → 编译 wiki → 带 3 引用回答`。

**Verify**（可复跑命令）:
```bash
# 前置：3 个 raw 存在（可用 arxiv + GitHub + 文章各 1）
ls research/raw/papers/mcp-*.md research/raw/articles/mcp-*.md research/raw/github/mcp-*.md 2>/dev/null | wc -l | awk '{exit ($1>=3)?0:1}'
test -f research/canon/research/mcp-prompt-injection.md
test -f research/wiki/research/mcp-prompt-injection.md
bash research/canon/lint.sh  # 必须 PASS
python3 research/scripts/generate.py --emit all && test -f research/wiki/index.md
```

### AC-I — 复用验证（AC3）

第二 topic（如 `guardrail-layers`）复用首 topic 的 `raw` 或 `wiki` 页，第二问 `grep -c "mcp-prompt-injection" research/canon/_index.md` 或 `wiki/index.md` ≥2，且 `raw_refs` 可解析。

**Verify**:
```bash
grep -c "mcp-prompt-injection" research/canon/_index.md | awk '{exit ($1>=1)?0:1}'
# 第二 topic 产出后，至少 1 个 raw 被复用
grep -h "raw_refs" research/canon/research/mcp-prompt-injection.md research/canon/concepts/guardrail-layers.md | sort | uniq -d | wc -l | awk '{exit ($1>=1)?0:1}'
```

### AC-J — 迁移与回归（30 notebook 归档）

`REGISTRY.yaml` 30 notebook 状态切 `archived`（不删云端），`evidence/research/**/findings.md` 批量拷贝为 `raw/papers/` 种子（`cp` 不改原文），生成 `research/raw/manifests/migrated-from-notebooklm.txt` 清单。

**Verify**:
```bash
grep -c 'status: archived' .tad/research-notebooks/REGISTRY.yaml | awk '{exit ($1>=20)?0:1}'
test -f research/raw/manifests/migrated-from-notebooklm.txt
ls research/raw/papers/*.md | wc -l | awk '{exit ($1>=5)?0:1}'  # 至少 5 个种子
```

---

## 4.1 Gate 2 P0 闭环说明（本 handoff 已修）

| P0 | 来源 | 闭环方式 |
|---|---|---|
| Scope 过大（video/audio/vector 全量 MVP） | code-reviewer P0-1, security P2-7 | **分阶段**：本单 Phase1 = 图文+GitHub+Iron Rule+generate；P2 video/audio（ingest 复用 handler，不自建 Whisper）；P3 向量（sqlite-vec 单文件，待立项时再定 chunk 策略） |
| Iron Rule 验证剧场 | security P0-1 | AC-E 负向 3 用例 + `lint.sh` 6 规则（含路径/定位解析）为真值，非计数 |
| YAML 注入 | security P0-2 | AC-D 用 `yq` 安全转义 + lint 规则 6 YAML 解析 |

剩余 P1（凭据泄露/覆写/contradiction 字段/饱和度量）由 Blake 在实现中闭环，Gate 3 Layer 2 复核。

---

## 5. Implementation order

1. AC-A 骨架 + 宪法（小，独立先行，守护后续提交合法性）
2. AC-B 受控词表 + AC-C canon 示例（并行）
3. AC-D ingest.sh + AC-F generate.py（工具层）
4. AC-E wiki + lint 6 规则（含负向用例）
5. AC-G 入口替换（config + SKILL 正文）
6. AC-H 端到端 + AC-I 复用
7. AC-J 迁移（最后，避免污染前序验证）

每次提交后：`bash research/canon/lint.sh && python3 research/scripts/generate.py --emit all` 必须 PASS。

---

## 6. Required Evidence Manifest

```
research/CLAUDE.md, research/canon/_topics.yaml, research/canon/_questions.yaml
research/canon/research/mcp-prompt-injection.md, research/canon/concepts/guardrail-layers.md
research/raw/{papers,articles,github}/mcp-*.md (≥3)
research/wiki/topics/mcp-security.md, research/wiki/research/mcp-prompt-injection.md
research/scripts/generate.py, research/scripts/ingest.sh, research/canon/lint.sh
research/wiki/index.md, research/canon/_index.md, research/raw/manifests/migrated-from-notebooklm.txt
.tad/evidence/research/local-wiki/{lint-report,generate-diff,migration-log}.md
.tad/evidence/reviews/blake/local-wiki/{code-reviewer,security-auditor}.md
```

---

## 7. Layer 2 / Gate 3 要求

- **code-reviewer**（P0=0,P1=0）+ **security-auditor**（P0=0, P1≤1）双组 PASS，P2 可延后但须落 NEXT。
- Reviewers 必须读 `research/canon/lint.sh` + `generate.py` 源码 + `research/wiki/*.md` 原文，不得只看 COMPLETION。
- 原有 2 份 CONDITIONAL 报告保留为 provenance，修复需增量 PASS 载体。
- `max_review_rounds: 2`，本单已用 1 轮，剩余 1 轮增量复核。

---

## 8. Friction Preflight

| Friction | Status | 处置 |
|---|---|---|
| `yq`/`ruby -ryaml` 不可用 | READY | `lint.sh` 用 `python3 -c 'import yaml'` fallback，已在 Sober 验证 |
| `yt-dlp/jq/curl` 缺失（video handler）| DEGRADED_WITH_APPROVAL | Phase1 不依赖 video，P2 时再装；`ingest.sh --dry-run` 可跳过 |
| `sqlite-vec` 选型未定 | NOT_APPLICABLE_WITH_REASON | Phase1 不引向量库，P3 立项时定（需 supply-chain 审计）|
| 30 notebook findings 拷贝量大 | READY | 仅拷贝 `evidence/research/*/findings.md` 文本，不拷贝二进制 |

未解决 BLOCKED → Gate 3 不可 PASS，停止上报。

---

## 9. Stop / rollback

- 同一 AC 失败 3 次 → 停止，回报 findings
- `lint.sh` FAIL → 禁止 commit，必须先修
- 发现本 handoff 与 `Sober/research/CLAUDE.md` 宪法冲突 → 停止上报，不得自行裁决
- 回滚保留最后 verified checkpoint 与全部 audit trail

---

## 10. Blake 消息模板（完成后发给 Alex）

```
Status:    ✅ Local Wiki Research Framework - Gate 3 结果: {PASS|CONDITIONAL}
Handoff:   .tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md
Evidence:  research/ + .tad/evidence/research/local-wiki/ + reviews/blake/local-wiki/
Next:      Alex 执行 Gate 4 验收/归档（若 PASS）
```

---

## 11. Gate 2 Review Records（本单）

- **code-reviewer** (2026-08-28): CONDITIONAL PASS — 见 §4.1 闭环
- **security-auditor** (2026-08-28): CONDITIONAL PASS — 见 §4.1 闭环
- 增量复核由 Blake 的 Layer 2 触发（剩余 1 轮）。

---

## 12. Parallel Execution Notes（Blake1 + Blake2 并行，2026-08-28 人裁定）

> **人裁定**：Blake1 继续 YOLO2（`TASK-20260827-YOLO2-P2-COMPLETION`），Blake2 新开终端执行本单。两者并行，已评估为低冲突。

### 12.1 为什么可并行

| 维度 | YOLO2 (Blake1) | 本单 (Blake2) | 冲突 |
|---|---|---|---|
| 产品文件 | `.tad/scripts/yolo-*`, `evidence/yolo/` | `research/`, `config-workflow.yaml`, `alex/SKILL.md` | **无** |
| 证据文件 | `evidence/yolo/phase2/`, `reviews/blake/yolo2-phase2/` | `evidence/research/local-wiki/`, `reviews/blake/local-wiki/` | **无** |
| 状态文件 | `session-state.md`, `NEXT.md` | `session-state.md`, `NEXT.md` | **有 — 需人桥接** |

结论：产品与证据层隔离，仅 `session-state.md` / `NEXT.md` 需协调。

### 12.2 Blake2 启动指引

1. 新终端 `cd TAD` 后说 `当 Blake`
2. 若提示 `⚠️ Blake is mid-task on HANDOFF-20260827... Are you in Terminal 2?` → 选 **Continue as Blake (parallel)**，Blake2 将 `Active Task` 覆盖为 `TASK-20260828-LOCAL-WIKI`（Blake1 的进度已在 `COMPLETION-20260825` + `evidence/yolo/` 落盘，不会丢）
3. 执行 `*execute .tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md`，按 §5 顺序从 AC-A 开始

### 12.3 注意事项（Blake2 必须遵守）

- **不得修改** YOLO2 的产品/证据文件（`yolo-*` / `evidence/yolo/`），发现 handoff 与 YOLO2 冲突 → 停止上报
- `session-state.md` 的写入以**最后写入者为准**；Blake2 每次 commit 后告知人，人无需回写给 Blake1
- `NEXT.md` 的并行例外已由人批准（本节即为批准载体），Gate 4 归档时 Alex 会合并两单的 NEXT 条目
- 若 Blake2 需 `yq`/`ruby` 缺失 → 按 §8 Friction 表走 `DEGRADED_WITH_APPROVAL`，不得自降级为 WebSearch 直写
- 回滚时仅回滚 `research/` 变更，不得 `git reset --hard` 影响 Blake1 的 `yolo` 提交

### 12.4 批准载体

本节 §12 即为并行批准载体（人 2026-08-28 指令“让 blake1 继续，我会打开一个新的 terminal blake”）。`NEXT.md` 的“一个一个做”约束对本对并行**一次性豁免**，不作为后续默认。
