# Gate 3 双审裁决 — Claude 路径彻底移除 (v3.0.0)

- **角色**: Alex (Solution Lead) — 只裁决不写代码；未改源码；未 commit；`docs/pm/` 只读
- **日期**: 2026-09-16 | **Workdir**: TAD 仓库 (grokbox 侧) | **基线 HEAD**: `c32bde27` (v2.44.6)
- **输入**: Gate 3 双审均 CONDITIONAL、CODE 零功能缺陷
  - CODE review: `.tad/evidence/reviews/2026-09-15-gate3-code-review-claude-removal.md` (C-1–C-4)
  - SAFETY review: `.tad/evidence/reviews/2026-09-15-gate3-safety-review-claude-removal.md` (R1–R4)
  - Handoff: `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md`
- **裁决范围**: 仅 R2 / R3 / C-3 / C-4 四点。R1 (`.gitignore` 机器本地忽略)、R4 (V-P7 sandbox 实证)、C-1 (stage 漏文件)、C-2 (unstage `docs/pm`) 属执行侧，Blake 按原返工条款办理，不在本裁决内。
- **裁决原则**: 保留 = 任务前既有、真实专名/领域知识/历史记录，改写会破坏语义或制造 doc↔registry 漂移；任何"保留"必须同步把 V-P1/AC 命令的**字面判据**改准，否则门永远红 (verification theater)。

---

## 结论速览

| 点 | 裁决 | 一句话 |
|----|------|--------|
| **R2-1** agent-computer-interface | **保留**（补入 §3.H 领域知识例外 + V-P1 排除） | "Claude in Chrome" 是真产品，`claude-code-tools-rules.md` 是真引用文件；删它=删领域知识并打断 pack 路由表 |
| **R2-2** deps-protocol `claude-code-cli` | **保留**（补入保留清单 + V-P1 排除） | 是 `.tad/dependencies/REGISTRY.yaml:171` 真实登记项名，非 `.claude/skills` 绑定；改写会与 registry 脱钩 |
| **R2-3** dependency-ops `claude-code-cli` | **保留**（同 R2-2） | 同上，同一依赖名 |
| **R2-4** pack CHANGELOG 历史行 | **保留**（补入 §3.K 历史面 + V-P1 排除） | 历史记录，改写历史 = 伪造变更史 |
| **R2-5** verifier `claude-code.md` 接线 | **保留 → (a) carve-out**（补入保留清单 + V-P1 窄排除；不改 verifier、不重命名 ledger） | 活接线必须点名被保留的 RETIRED ledger 才能 INFO-skip（I18/J6）；`claude-code.md` 是保留历史真名，改名 = 为绿 grep 伪造历史漂移并悬空不可变 evidence 引用（同 C-3） |
| **R3** AC21 freshness BLOCK | **二选一 → (b) Gate 4 书面 waiver** + 强制另立单 | 真实重验 6 个 codex 高波动面 = 独立工作项；本批塞入会扩大 blast radius 并诱发空 bump |
| **C-3** V-P1 grep 是否给 `parity-criterion.md` carve-out | **二选一 → 是，加 carve-out** | 该文件已 ARCHIVED、零活消费者；不加则 AC20 门永久红 |
| **C-4** codex 侧 BLOCK 是否与 R3 同处置 | **二选一 → 是，同一处置** | 与 R3 同源同物；合并为**一个** waiver + **一个**另单，不重复开单、不塞本批 |

---

## 1. R2 逐条裁决（4 条，全部 **保留**）

### R2-1 — `.agents/skills/agent-computer-interface/SKILL.md:110,115,116,118,145,147`

- **Verdict: 保留（RETENTION，零代码改动）。**
- **理由**:
  1. `Claude in Chrome` 是 Anthropic 的真产品（Chrome MCP 扩展），非 TAD 平台绑定；`mcp__claude-in-chrome__*` (`SKILL.md:55`) 同理。
  2. `claude-code-tools-rules.md` 是**被引用的真实领域文件**（tracked: `.agents/skills/agent-computer-interface/references/claude-code-tools-rules.md`，内含 Tools/Decision Rules R1–R7、`last_verified: 2026-06-17`）。SKILL.md 的 5 条 Context-Detection 路由行 + 1 条 quick-index 行全部指向它；删除/改名会**打断该 pack 的路由表**并丢失真实工具知识。
  3. 与 `ai-prompt-engineering` / `ai-evaluation`（§3.H/§3.K "领域知识例外，必须保留"）**同类**：领域知识以真名引用产品，不是 TAD Claude 运行时依赖（无 `.claude/skills` 路径、无 TAD 运行时耦合）。
  4. 4 条 fail V-P1 的唯一原因是 §3.H 保留清单**未点名**该 pack——是清单覆盖缺口，不是残留。
- **落地要求（非代码）**: 在 §3.H 领域知识例外的 pack 列表加入 `agent-computer-interface`；V-P1 首条 grep 排除正则加入 `agent-computer-interface`。可选（非阻塞、不本批改）: pack 内 "(most common Claude Code context)" 措辞可在未来 pack 刷新时中性化。

### R2-2 — `.agents/skills/alex/references/deps-protocol.md:132`

- **Verdict: 保留（RETENTION，零代码改动）。**
- **理由**:
  1. `claude-code-cli` 是**真实登记的依赖名**：`.tad/dependencies/REGISTRY.yaml:171`（`name: claude-code-cli`, `type: platform`, `status: active`）、`.tad/dependencies/scan-results.yaml:56`。该行只是协议里"`registry: null` 依赖被跳过"的举例枚举，属**专名**，非 `.claude/skills` 路径绑定。
  2. 改写该行会让 `deps-protocol.md` 与 `.tad/dependencies/REGISTRY.yaml` 事实脱钩（doc 指向不存在的依赖/漏列真实项），制造新的不一致。
  3. `.tad/dependencies/**` **不在 handoff §3.I/§3.K scope，也不在 V-P1 扫描路径内**；本批对该处零改动，属 pre-existing 文本。
- **落地要求（非代码）**: 加入保留清单（依赖专名类）；V-P1 首条 grep 排除正则加入对应文件路径。**附带另单**见 §6。

### R2-3 — `.agents/skills/dependency-ops/SKILL.md:67`

- **Verdict: 保留（RETENTION，零代码改动）。**
- **理由**: 与 R2-2 同一依赖名同一语义（"当前为 `notebooklm-cli`、`rsync`、`claude-code-cli` 三个"）。dependency-ops 是**操作协议 pack**，该行说明 `registry: null` 依赖永远扫不到——删名会使协议覆盖声明失真。
- **落地要求（非代码）**: V-P1 首条 grep 排除正则加入 `dependency-ops/SKILL.md`（或 `dependency-ops` pack）；保留清单与 R2-2 合并为一条"依赖专名"类目。

### R2-4 — `.tad/capability-packs/ai-agent-architecture/CHANGELOG.md:24`

- **Verdict: 保留（RETENTION，零代码改动）。**
- **理由**:
  1. 该行 `- install.sh with --agent=claude-code (Phase 1) ...` 是 **pack 历史变更记录**，落在 handoff §3.K "明确不动（历史/权威记录）" 语义内（`CHANGELOG.md` 旧条目）。
  2. 改写历史行等于伪造变更史，违反"历史只读"原则（与 §3.L 历史 manifest 只读同构）。
  3. V-P1 首条 grep 扫 `.tad/capability-packs` 才命中它——属**命令作用域过宽**，非真残留。
- **落地要求（非代码）**: §3.K 明确点名 "pack `CHANGELOG.md` 历史块"；V-P1 首条 grep 排除 `CHANGELOG.md`（与根 CHANGELOG 历史面同规则）。

> **R2 汇总**: 4 条全部 RETENTION。**保留的前提是同步改字面判据**——否则 §"AC5/AC6/AC20 仍字面红"。命令同步清单见 §5。Blake 不得以"解释通过"替代字面命令修正（沿用 SAFETY R2 纪律）。

---

## 2. R3 裁决 — AC21 `runtime-freshness` BLOCK

**二选一，选定 (b): Gate 4 书面 waiver（本批）；真实重验刷新**另立单**，不塞本批。**

- **事实基线**（复核）: `runtime-freshness-verify.sh` 现为 `BLOCK: 6 / WARN: 6 / PASS: 0`；6 个 BLOCK 全部是 **codex ledger 高波动条目** `last_verified: 2026-08-03`（44 天 > 30）且 `next_review: 2026-09-02` 已过期（`.tad/runtime-compat/codex.md`，12 条）。claude ledger 已 `RETIRED` 头、`info: skipping`（I18 正确）。**HEAD 上同样 BLOCK**——与本批移除无关。
- **为何不选 (a)（本批真实重验）**:
  1. 达到 AC21 字面 `exit 0` 需把 **6 个 codex 高波动条目全部刷新**，而其中 `context_compaction` / `trace_evidence_capture` 为 `verified_partial`、需可信鉴权的 Codex 会话实测（spike-d 当时未取到鉴权回合）。这是一次**独立的平台重验工作项**，不是移除任务的边角。
  2. 本批是 major 版本、已有 722 改动面；把"平台台账重验"混合进移除批会**扩大 blast radius、污染证据链**（Gate 4 无法区分"移除引入"与"刷新引入"）。
  3. (a) 的现实压力会诱导"只改日期不改实测"的**空 bump**（本次明确禁止）。与其在错误的批次里赶真验，不如隔离成单。
- **waiver 具体条件（Gate 4 落字，缺一不可）**:
  1. AC21 记为 **WAIVED（不是 PASS）**，豁免范围**精确限定**为"codex ledger 高波动条目的日期陈旧（last_verified 2026-08-03 / next_review 2026-09-02）"，并注明 **pre-existing、HEAD 复现、与移除无关**。
  2. AC21 的**意图子句**独立判 PASS：移除未破坏 freshness 门——claude ledger retire-skip 生效、缺 ledger/RETIRED 不再 exit 2、无永久 wiring-BLOCK（I18 目标达成）。即：**接线 PASS + 日期陈旧 WAIVED**。
  3. 发布物料**不得**声称 AC21 全绿；release note 如实标注该项 waiver。
  4. **强制另立单**（见 C-4），在 Gate 4 签字前登记（有 Task ID、owner Blake、写入 `NEXT.md` 优先队列）：范围 = 对 codex ledger 12 条（至少 6 个 BLOCK）做**真实** re-verification（live codex-cli + 官方文档），随后刷新日期，恢复 `exit 0`。
  5. waiver **单批次有效**；不授权任何后续"无实测仅 bump 日期"。
- **禁止**: 空 bump 日期；把"另单重验"塞进本移除批。

---

## 3. C-3 裁决 — V-P1 是否给 `parity-criterion.md` 加 carve-out

**二选一，选定: 是，加 carve-out。**

- **事实基线**（复核）: `.tad/hooks/lib/parity-criterion.md` 头注已是 `ARCHIVED in TAD v3.0.0`（本批 S3/§3.I20 已落）；`:90,:102` 两处 `.claude/skills/alex|blake/SKILL.md` 是**归档文件内的历史示例**（PIN 表来源标注）。零活消费者：仅 `.tad/evidence/spikes/codex-parity/parity-check.sh`（evidence 域）与 evidence/disposition 记录引用，无 gate 执行。
- **理由**:
  1. V-P1 第二条 `grep -rn '\.claude/skills' .tad/hooks/lib ...` 会**恒定命中** `:90,:102` → AC20 门**永久红** = 验证剧场；AC20 的真实意图是"活消费者无遗漏"，不是"归档文件无历史字面"。
  2. 保留正确（§3.I20 选 ARCHIVED 而非删除），因此必须让**判据**承认归档面，而不是去改归档文件（改回 = 破坏归档完整性）。
- **落地要求（非代码）**: V-P1 第二条命令加 `--exclude=parity-criterion.md`（或等价路径过滤），并在 §6.3 命令旁注一行理由（"ARCHIVED per I20；归档面不属活零残留"）。**不得**通过编辑 `parity-criterion.md` 消除命中。
- **边界**: 排除仅限该 ARCHIVED 文件；若未来有**活**脚本被指向 `.claude/skills`，仍应命中。

---

## 4. C-4 裁决 — codex 侧 BLOCK 是否与 R3 同一处置

**二选一，选定: 是，与 R3 同一处置。**

- **理由**: CODE review C-4 与 SAFETY review R3 是**同一发现的两个视角**（同一条 `runtime-freshness` BLOCK、同一 codex ledger 日期陈旧、同一 pre-existing 证据）。同一事实不得开两张单、给两种处置。
- **合并处置**:
  1. 本批: 仅 **一个** Gate 4 书面 waiver（内容见 §2），覆盖两个评审发现的同一 BLOCK。
  2. 另单: 仅 **一个** out-of-band ticket（真实 re-verification + 日期刷新），C-4 的"另单做"即 R3 的"另立单"——**同一张单**。
  3. C-4 作为**独立行动项关闭（duplicate-of-R3）**，不追加第二条执行要求。
- **"不塞本批"明确**: 刷新 codex ledger 日期的任何动作**不得**进入 v3.0.0 移除批次（不进本批 commit、不进本批 AC 证据）；与本批的 `codex.md` 改动（J7 单行 source-of-truth 措辞）区分开。

---

## 5. 对 Blake 的命令同步清单（保留裁决的必要配套，全部为**判据字面**修正，非源码）

> 背景: §1 的 4 条保留 + §3 的归档 carve-out，若不落到 V-P1/AC 命令，AC5/AC6/AC20 仍字面红。以下为**建议形态**，Blake 落地时可微调 shell 但不得放宽语义。

**V-P1 首条（活运行时零残留）** — 在既有排除正则上追加保留项:
```bash
git ls-files -z -- tad.sh bin .tad/platform-codes.yaml .tad/config-workflow.yaml \
  .tad/config-agents.yaml .tad/cross-model/capabilities.yaml .tad/hooks .tad/scripts \
  .tad/capability-packs .tad/templates .agents/skills .codex package.json .gitignore \
  | grep -zv 'ai-prompt-engineering\|ai-evaluation\|agent-computer-interface' \
  | grep -zv 'deps-protocol\.md\|dependency-ops/SKILL\.md' \
  | grep -zv 'CHANGELOG\.md' \
  | xargs -0 grep -n 'claude-code\|claude_websearch\|claude_code_reviewer' \
  | grep -v 'claude-code\.md' ; echo "exit=$?"
# 期望：无输出
# R2-5：排除仅限保留 ledger 路径字面 `claude-code.md`；不得整文件排除
# runtime-freshness-verify.sh（其余 claude-code CLI/spawn/.claude 字面仍应命中）。
```

**V-P1 第二条（消费者完整性 / AC20）** — 加归档 carve-out:
```bash
! grep -rn --exclude=parity-criterion.md '\.claude/skills' .tad/hooks/lib .tad/scripts \
    .tad/capability-packs .tad/templates .tad/tests .tad/config-workflow.yaml .tad/skills-config.yaml
# 期望：无输出
```

**AC5/AC6/AC20 备注**: 在 handoff AC 表/§6.3 注明 R2-1–R2-4 属保留清单（附本裁决文件名），AC20 注明 `parity-criterion.md` 已 ARCHIVED 故排除。

**AC21 备注**: 在 handoff AC 表记录 `exit 0` 的达成路径 = Gate 4 waiver（+ 另单刷新），禁止写成 PASS。

---

## 6. 附带观察（**不属本 4 点裁决，单列，不阻塞本批**）

- **`.tad/dependencies/REGISTRY.yaml:171` 的 `claude-code-cli` 条目本身在 v3.0.0 后语义失效**：`type: platform`、`status: active`、`files_depending: [.claude/settings.json, .claude/settings.local.json, .claude/skills/, .claude/workflows/, .tad/hooks/]`、`integration_context: "Runtime platform for TAD ..."`——已指向被移除的 Claude 运行时。
- 该文件**本批零改动**（`git diff HEAD` 为空），且 `.tad/dependencies/**` **不在 handoff §3.I/§3.K scope、不在 V-P1 扫描路径**（故双审 PASS，非漏审证据项）。R2-2/R2-3 的"保留"因此是本批的正确最小解（doc↔registry 现状自洽）。
- **建议（另单，非本批、非 R2 阻塞）**: 立"依赖登记表 v3 对账"小单——裁决 `claude-code-cli` 条目去留（retire/remove）并同步 `deps-protocol.md` / `dependency-ops` 示例；同时复核 `REGISTRY.yaml:28-29,66,192-195` 的 `.claude/skills/...`/`.claude/settings*` `files_depending` 是否需要 repoint。**若该单决定退役该依赖，R2-2/R2-3 的保留裁决需随之复核**（本裁决按"本批不改 registry"前提作出）。

---

## 7. 边界与声明

- 本裁决**未改任何源码/配置/handoff/docs/pm**，**未 commit**；仅新增本证据文件。
- 未裁决 R1/R4/C-1/C-2（执行侧返工，按原评审条款执行），未裁决 O1–O3 观察项。
- R2 四条均以"任务前既有、`git diff HEAD` 为空"为前提（已逐条复核）；R2-1/R2-4 的 reference/CHANGELOG 文件均 tracked。
- 保留裁决的成立**强依赖** §5 命令同步；若 Blake 只改源码不同步判据，AC5/AC6/AC20 将字面红，Gate 4 不得放行。
- R3/C-4 的 waiver 必须在 Gate 4 显式落字并登记另单，否则该两点保持未决。

---

## 8. R2-5 追加裁决 — `.tad/hooks/lib/runtime-freshness-verify.sh:12`（2026-09-16 续裁）

**二选一，选定 (a): 加 carve-out 进保留清单；Blake 只加排除行，不改 verifier、不重命名 ledger。**（(b) 改名不采纳，如需做另立单。）

- **Verdict 一句话**: `:12` 是活接线，必须点名被保留的 RETIRED ledger `claude-code.md` 才能把"缺文件 / 带 RETIRED 头"判为 INFO-skip（I18/J6，永不 exit 2）；而 `claude-code.md` 是保留的历史真文件名——改名只会为绿一个 grep 而伪造历史漂移、并悬空散落在不可变 evidence 里的引用，与 C-3 `parity-criterion.md` 同构，故按**判据侧 carve-out** 处理，不动被保留物。

- **事实基线**（本续裁复核）:
  1. V-P1 首条**仅 1 处**命中，即 `runtime-freshness-verify.sh:12 CLAUDE_LEDGER="$COMPAT_DIR/claude-code.md"`（实跑确认 `exit=0`，无第二处）。
  2. ledger 文件本身 retained（J6）：`.tad/runtime-compat/claude-code.md` 头注 `RETIRED in TAD v3.0.0` / `Status: RETIRED`，并明示 "NOT gated by `runtime-freshness-verify.sh`"；文件名是历史真名，非 `.claude` 运行时绑定，且 `.tad/runtime-compat/**` 不在 V-P1 扫描面。
  3. `:35-42` 的 `SKIP_CLAUDE` 逻辑靠该变量同时覆盖"文件缺失"与"RETIRED 头"两种退役态，输出 INFO 并**绝不给 exit 2**——`:12` 是这段 I18/J6 语义的必需接线，删/改名即丢失退役识别与 INFO 记录。
- **理由**:
  1. 命中根因是 **V-P1 首条判据过宽**（把"保留 ledger 的路径名"与"活运行时残留"一视同仁）——属清单/判据缺口，不是残留；同 R2-4（命令作用域过宽）、C-3（归档面被过宽扫中）类。
  2. 与 C-3 同构：**保留物正确 → 就该让判据承认保留面，而不是改被保留物**。C-3 明确"不得通过编辑归档文件消除命中"，此处同理。
  3. (b) 改名代价/风险显著更大：(i) 改动被保留的历史记录文件本身 = 为绿门做 cosmetic 漂移；(ii) `claude-code.md` 被多处**不可变** evidence 引用（如 `.tad/evidence/designs/full-capability-extraction/capability-disposition.yaml`、`source-inventory.tsv`、多份 review/manifest），改名即制造悬空引用与新的 doc↔history 不一致；(iii) 收益仅为消除一个 grep 字面——不抵其害。(b) 若确要做，另立单、不在本批。
- **落地要求（非代码）**:
  1. **保留清单**新增"保留 ledger 路径"类目，条目 = `.tad/hooks/lib/runtime-freshness-verify.sh:12`（保留 ledger `claude-code.md` 接线）。
  2. **V-P1 首条**追加**窄**内容级排除，只排保留 ledger 文件名字面：
     ```bash
     ... | xargs -0 grep -n 'claude-code\|claude_websearch\|claude_code_reviewer' \
         | grep -v 'claude-code\.md' ; echo "exit=$?"
     # 期望：无输出
     ```
     **不得**整文件排除 `runtime-freshness-verify.sh`——那会遮蔽该 verifier 内其他真残留（扩大豁免面）。
- **边界**: 排除仅限字符串 `claude-code.md`（保留 ledger 路径）。任何 `claude-code` CLI/spawn、`claude_websearch`、`claude_code_reviewer` 或其他 `.claude` 字面仍应命中。
- **不改动**: verifier 源码（`:12` 保留）、`.tad/runtime-compat/claude-code.md`（保留、RETIRED、只读）；未 commit；`docs/pm/` 只读。
