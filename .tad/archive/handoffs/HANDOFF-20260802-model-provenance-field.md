---
task_type: protocol-docs
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
express: true
gate4_delta: []
---

# Express Handoff: Model Provenance Field (Completion + RouteDecision)

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-08-02
**Priority:** P1（所有 harness×模型质量归因的数据地基）
**Research basis:** `.tad/evidence/research/2026-08-02-multi-model-portability-verification.md`

## 1. Intent

### What
在 TAD lite 的两个证据载体中加入执行模型身份记录：
1. Blake-Lite `## Completion` 模板新增 `**Model**:` 必填行
2. RouteDecision 记录字段新增 `model`（alex-lite / blake-lite 各自写入自己那侧的 revision 时填写）

### Why now
2026-08-02 实证核查发现：全屋智能化 4 个真实 LITE 单中，2 个由 `deepseek-v4-flash` 全程执行（session 日志坐实），2 个经 `k3` API 中转——**底层模型已永远不可考**。用户正转向 Codex + DeepSeek 混编，模型×质量归因矩阵、混编舰队 reviewer 档位决策、成本三格对比全部依赖这个字段。不记录 = 每个新单都在制造新的 k3。

### Non-goals
- 不改升级清单哨兵块（`ESCALATION-LIST-BEGIN/END` 之间一个字节都不动）
- 不改 routing 状态机、precedence、risk_classes
- 不追溯补写已归档单的模型字段（已不可考的保持不可考，不编造）
- 不引入模型自动检测脚本/hook——机械捕获用现有 `env` + `jq` 命令组合完成（见 §3.1；route 可完全机械捕获，model 为"机械捕获 + 自报交叉记录"）
- 版本号 bump、CHANGELOG、publish 均推迟到下一个发布周期（release 操作属升级清单第 4 类 fatal，不入 express 单）——本单只产生 working-tree 改动
- 归因边界诚实声明：走聚合中转时（如 k3），`route=聚合器 host` + 自报 `model=` 仍无法确定底层真实模型。本字段防止的是**静默丢失**，不解决聚合器归因；归因矩阵中此类行须标注为 route-only 证据，不得当 ground truth（expert review CR-4）

## 2. Scope（6 产品文件 + evidence artifacts；除 verify-state-flow.sh L70-71 为 in-place 字面更新外均 additive-only）

1. `.claude/skills/blake-lite/SKILL.md`
2. `.agents/skills/blake-lite/SKILL.md`（与 1 逐字节相同）
3. `.claude/skills/alex-lite/SKILL.md`
4. `.agents/skills/alex-lite/SKILL.md`（与 3 逐字节相同）
5. `.tad/routing-contract.yaml`
6. `.tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh`（L70-72 的 `alex_may_write`/`blake_may_write` 字面全量匹配须与 YAML 改动 lockstep 更新，见 §3.4）
7. 无其它产品文件；full Alex/Blake 不动（full 通道的 Completion 由后续单独决定，本单只做 lite）。AC 产生的 evidence artifacts（`.tad/evidence/acceptance-tests/model-provenance/`）不计入 scope 文件数。

## 3. 设计契约

### 3.1 blake-lite Completion 模板（L4 段）

在 `**Commit**:` 行之后新增一行：

```
**Model**: harness={claude-code|codex} | model={运行时自报模型 ID} | route={ANTHROPIC_BASE_URL 的 host，未设置则 native}
```

并在 L4 段落新增捕获纪律（三句）：
1. route 与 model 的机械捕获命令（env 无输出 = native 直连；settings 两层都查）：
   ```bash
   env | grep -E '^ANTHROPIC_(BASE_URL|MODEL|SMALL_FAST_MODEL)='
   jq -r '.model // "unset"' ~/.claude/settings.json 2>/dev/null
   jq -r '.model // "unset"' .claude/settings.json 2>/dev/null
   ```
   会话内 `/model` 运行时覆盖优先级最高，若用户切过必须逐字记录（expert review CR-4）。
2. 自报模型 ID 与 route 冲突时（如自报 claude-* 但 route 指向 api.deepseek.com）两者都记录，以 route 为准并标注 `(alias-mapped)`。
3. 若本单跨越 compaction 或中途换过 harness/模型，Model 行按发生顺序逐个列出，不得只记最后一个（expert review CR-7；混编舰队下单行末值会静默错误归因）。

字段语义区分（写入模板注释一句话）：`writer` = 角色身份（alex|blake），`model` = 执行模型/harness 身份——两者不冗余（expert review CR-11）。

### 3.2 RouteDecision 字段（alex-lite R0 step5 / blake-lite R0 step4 的输出字段清单）

⚠️ 每个 lite skill 有**两处**字段清单，两处都要加 `model`（expert review P1-2 指出只改一处会造成 skill 内部不一致）：
1. "输出 RouteDecision" 完整枚举（alex-lite ~L64-65：route_id、base_revision、…、state；blake-lite ~L57-59 对应处）→ 追加 `model`
2. "只写 Alex/Blake 可写字段" 括号清单（alex-lite ~L66-67：design_depth / risk_class / … / evidence；blake-lite ~L60 对应处）→ 追加 `model`

值格式同 3.1 的 Model 行；各角色各写自己 revision 的 model 字段。

同时在两个 skill 的对应 R0 步骤（alex-lite step 5、blake-lite step 4）各加一行 tolerance 条款（expert review CR-10——YAML 注释只保护读 YAML 的人，skill 侧枚举了必填字段却无豁免会让恢复旧 snapshot 的 agent 误判）：
"（model 自 2026-08-02 起必填；更早的 revision 缺该字段仍为合法 snapshot，不得据此判 stale）"

### 3.3 routing-contract.yaml

- `decision_record.required` 数组追加 `model`
- `revision_rules.alex_may_write` 与 `revision_rules.blake_may_write` 各追加 `model`
- 紧邻处加一行注释：`# model field required for revisions written on/after 2026-08-02; earlier snapshots without it remain valid (backward tolerance)`
- `schema_version` 保持 1 **不 bump**——两个原因都要写进注释：(a) backward tolerance；(b) `verify-route-schema.sh` L18 硬 pin `^schema_version: 1$`，bump 需协调 verifier 变更，超出本 express 范围（expert review P2-3）
- 前瞻注（非本单实现）：当前无任何代码路径按 `decision_record.required` 校验 snapshot 字段完整性，comment 级 tolerance 足够；若未来加入该校验，须同时引入结构化 `required_since` 标记

### 3.4 verify-state-flow.sh lockstep 更新（expert review P0-1）

verify-state-flow.sh L70-72 对 `alex_may_write` / `blake_may_write` 做**字面全量匹配**（ownership guard，故意 fail-closed）。YAML 追加 `model` 后该匹配必失败。处置：
- **保持字面全量匹配语义不变**（它守的是"写权限数组的任何变更必须是经审查的 deliberate amendment"——这正是本单在做的事），只把两处字面数组 lockstep 更新为含 `, model` 的新字面
- 不改为 presence-loop：presence 检查无法发现数组被塞入未授权字段，会弱化 ownership guard 的 fail-closed 属性（呼应 principles "Deny-List / fail-closed" 与 "Rewiring a Gate's Prose" 的 re-cite-constraint 处置）

## 4. AC（全部可机器验证）

前置：`mkdir -p .tad/evidence/acceptance-tests/model-provenance/`。所有 grep -c 类 AC 注意 zsh 下禁用进程替换形式（CR-1），一律用管道；`grep -c` 计数为 0 时 exit 1，AC 脚本不得依赖 `set -e`。

- AC1: `grep -c '\*\*Model\*\*:' .claude/skills/blake-lite/SKILL.md` ≥ 1（baseline 0）且 `cmp .claude/skills/blake-lite/SKILL.md .agents/skills/blake-lite/SKILL.md` exit 0
- AC2: `awk '/^decision_record:/,/^revision_rules:/' .tad/routing-contract.yaml | grep -v '^[[:space:]]*#' | grep -c '\bmodel\b'` ≥ 1（baseline 0；排除注释行防止 §3.3 的 tolerance 注释假满足——CR-6）
- AC3: 四处 skill 字段清单全覆盖（CR-3；两条命令的锚点已在当前文件验证存在且现值为 0）：
  - `awk '/^5\. 输出 RouteDecision/,/^6\. 用户可见解释/' .claude/skills/alex-lite/SKILL.md | grep -c '\bmodel\b'` ≥ 2（输出枚举 + 可写清单各 1）
  - `awk '/^4\. 输出\/追加 RouteDecision/,/^5\. 用户可见解释/' .claude/skills/blake-lite/SKILL.md | grep -c '\bmodel\b'` ≥ 2
  - alex-lite 两镜像 `cmp` exit 0（blake-lite 镜像已由 AC1 覆盖）
  - 禁止"等效定位"替代——命令按本文逐字运行
- AC4: 捕获纪律文本落位（判别式，baseline 0——CR-5）：`grep -Ec 'ANTHROPIC_\(BASE_URL\|MODEL\|SMALL_FAST_MODEL\)|ANTHROPIC_\(BASE_URL' .claude/skills/blake-lite/SKILL.md` ≥ 1（锚定 §3.1 捕获命令文本进入 L4 模板；实际锚点以 Blake 写入的命令文本为准并在 Completion 记录实测命令与计数）
- AC5: 哨兵块零变更：对 4 个 lite skill 文件各执行 `awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' {f} | md5` — **期望值固定 `4c55bcb6563f24dc78449fb19ff76067`（4 文件一致，expert review 实测锚定；自校验，无前后顺序依赖——CR-9b）**；另每文件 `grep -c 'ESCALATION-LIST-BEGIN'` == 1（防 awk 区间误触发——CR-9c）
- AC6: `grep -E 'alex_may_write:.*model' .tad/routing-contract.yaml` 与 `grep -E 'blake_may_write:.*model' .tad/routing-contract.yaml` 均命中
- AC7: verifier baseline-diff（CR-8：`rg` 在本机是 shell snapshot 函数非二进制，裸 `bash` 跑 verifier 在**未改动仓库上已经 FAIL**，不能用 exit 0 做判据）：
  1. 改动前：`bash .tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh > .tad/evidence/acceptance-tests/model-provenance/verifier-baseline-state-flow.txt 2>&1` 捕获全输出
  2. 改动后同命令捕获 post 输出
  3. 判据：post 的 FAIL 行集合 ⊆ baseline 的 FAIL 行集合（不新增 FAIL 行）；且 L70-71 ownership 断言相关行在 post 中不得为新 FAIL
- AC8: fail-closed 突变探针：临时副本中从 YAML 的 alex_may_write 移除 model（verifier 不动）→ 与 AC7-post 对比**必须新增 ownership FAIL 行**；恢复后重跑与 AC7-post 输出一致。证明 lockstep 后 guard 仍 fail-closed（探针输出存 evidence 目录）

## 5. 风险与注意

- 本单改协议契约面（lite SKILL + routing-contract.yaml），走 full 通道 express——本 handoff 即为该通道载体；express ≠ 免审（AR-001），已完成 2 名专家审查（见 §6）
- routing-contract.yaml 被 3 个 fail-closed verifier 消费：实际破坏点是 verify-state-flow.sh L70-71 对 `may_write` 数组的**字面全量匹配**（非 required 字段计数、非 fixture）——处置见 §3.4 lockstep + AC7/AC8；另注意 `rg` 在本机为 shell 函数，裸 bash 下 verifier 有环境性 FAIL 噪音，故 AC7 用 baseline-diff 而非 exit code（CR-2/CR-8）
- 老 RouteDecision snapshot 无 model 字段 → 3.3 的 backward tolerance 注释是防止 resume 时被误判 stale 的关键，不可省略
- 4 镜像文件必须成对逐字节相同（AC1/AC3 的 cmp 是硬门）

## 6. Expert Review — Audit Trail（2026-08-02，2 reviewers）

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| config-manager | P0-1 verify-state-flow.sh L70-72 字面全量匹配必炸 | §2 scope +verifier、§3.4 lockstep、AC7/AC8 | ✅ Fixed |
| config-manager | P1-2 两处字段清单只锚定一处 | §3.2 双清单显式化、AC3 重写 | ✅ Fixed |
| config-manager | P2-3 schema_version 不 bump 未说明双重原因 | §3.3 补注（tolerance + verifier pin） | ✅ Fixed |
| config-manager | P2-5 evidence 路径超出"无其它文件"绝对表述 | §2 措辞豁免 | ✅ Fixed |
| code-reviewer | P0-1 AC2 进程替换在 zsh 下永远 FAIL | AC 前置注 + AC2 管道形式 | ✅ Fixed |
| code-reviewer | P0-2 verifier 破坏无 AC 且 §5 误判机制 | §3.4 + §5 重写 + AC7/AC8 | ✅ Fixed |
| code-reviewer | P0-3 四处 skill 编辑三处无 AC + "等效定位"逃生舱 | AC3 重写（awk 区间锚点 ≥2 ×2 skill）+ 删逃生舱 | ✅ Fixed |
| code-reviewer | P1-4 model= 无机械来源（env 为空、settings 不可见） | §3.1 捕获纪律扩展（env+jq 两层 settings+/model 覆盖）+ §1 聚合器归因边界 | ✅ Fixed |
| code-reviewer | P1-5 AC4 永真式 | AC4 改判别式（baseline 0） | ✅ Fixed |
| code-reviewer | P1-6 tolerance 注释假满足 AC2 | AC2 grep -v 注释行 | ✅ Fixed |
| code-reviewer | P1-7 跨 compaction/换模型单行误归因 | §3.1 纪律第 3 句（按序逐列） | ✅ Fixed |
| code-reviewer | P1-8 rg 为 shell 函数、verifier 环境性 FAIL 掩盖真破坏 | AC7 baseline-diff 判据 | ✅ Fixed |
| code-reviewer | P2-9 sentinel：目录不存在/顺序依赖/awk 误触发 | AC 前置 mkdir + 期望 md5 固定 + BEGIN 计数守卫 | ✅ Fixed |
| code-reviewer | P2-10 skill 侧缺 tolerance 条款（不对称） | §3.2 R0 双侧条款 | ✅ Fixed |
| code-reviewer | P2-11 writer vs model 语义未区分 | §3.1 末句 | ✅ Fixed |
| code-reviewer | P2-12 scope 计数与列表不符 | §2 头部改"6 产品文件" | ✅ Fixed |
| code-reviewer | P2-13 无版本/CHANGELOG 处置声明 | §1 Non-goals 新增推迟条款 | ✅ Fixed |

两名 reviewer 初判均 CONDITIONAL；全部 P0（4）/P1（6）已整合，P2（7）全部采纳。方案分歧一处：config-manager 建议 verifier 改 presence-loop，code-reviewer 建议 lockstep+baseline——采后者（保留 ownership guard 的 fail-closed 语义），理由记录于 §3.4。

## Completion (2026-08-02)

**Commit**: uncommitted（是否 commit 由人决定）
**Model**: harness=claude-code | model=claude-fable-5（settings 实测 `claude-fable-5[1m]`，会话自报 claude-fable-5）| route=native（env 无 ANTHROPIC_* 变量，exit=1 实测）

**执行授权**：用户原话"我做什么啊，你自己做你啊"（2026-08-02）→ Alex 承担 Blake 执行职责（DEGRADED_WITH_APPROVAL：角色桥由用户口头指令替代 terminal 切换；独立审查未降级——实现后 reviewer 为全新上下文 subagent，非自审）。

- 改动文件（6，全部在 §2 清单内，无清单外）：
  - `.claude/skills/blake-lite/SKILL.md` — R0 step4 双清单 + tolerance；L4 Completion 模板 Model 行；Model 行捕获纪律 3 条（5 hunks）
  - `.agents/skills/blake-lite/SKILL.md` — 镜像 cmp exit 0
  - `.claude/skills/alex-lite/SKILL.md` — R0 step5 双清单 + tolerance + 值格式/捕获命令/alias-mapped 告诫（review P1-2 修复）
  - `.agents/skills/alex-lite/SKILL.md` — 镜像 cmp exit 0
  - `.tad/routing-contract.yaml` — required+model、双 may_write+model、注释块置于 decision_record 之外（review P1-1 Fix A）、revision_rules 指针注释
  - `.tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh` — L70-71 字面 lockstep（§3.4）+ DR_BLOCK 剥注释加固（review P1-1 Fix B）
- AC 结果 8/8 ✅（证据：`.tad/evidence/acceptance-tests/model-provenance/`）：
  - AC1=1+cmp OK / AC2=1（剥注释后）/ AC3a=5、AC3b=3（≥2）+cmp OK / AC4=1 / AC5 md5=4c55bcb6563f24dc78449fb19ff76067 ×4、BEGIN=1 ×4 / AC6=2
  - AC7：shim 完整树对（HEAD baseline PASS exit 0 vs post PASS exit 0，byte-identical）——首版裸 bash 证据对被 reviewer 判 vacuous，已重造并标 SUPERSEDED
  - AC8：突变探针恰好 2 行 diff（ownership OK→FAIL + PASS→FAIL，exit 1）、restore 与 post byte-identical
  - 附加：verify-route-schema / route-enforcement / routing-behavior 三 verifier 均 PASS（reviewer 独立复跑）
- Reviewer: 首轮 **CONDITIONAL**（P1=2：注释块致 writer 守卫失明[突变实证]、alex-lite 缺值格式；P2=4）→ 全部修复 → 增量复核 **PASS**（"findings 1-5 genuinely closed, verified by re-execution"；每个证据 artifact 与其独立运行 byte-for-byte 复现）。后续 2 个 P2 nit（SUPERSEDED 改名 + jq 2>/dev/null 对齐）已采纳，镜像重同步 cmp OK、哨兵 md5 不变。
- follow-up：
  - verify-state-flow.sh L38 `required_fields` 未含 model（reviewer finding 6，本单 scope 外；注释泄漏已闭，现在加是安全的）→ 建议并入下一个 routing 触碰单
  - agent 报告投递失败 ×4（idle 通知到达但报告未达主会话，均靠 SendMessage 取回）→ 平台级现象，已记 journal
- 意外发现：本单实现审查自身复现了"注释假满足 comment-blind 检查"缺陷类（CR-6 同类，被我在 YAML 里复刻、被 reviewer 用突变探针抓获）——执行探针式审查的价值在本单二次实证
