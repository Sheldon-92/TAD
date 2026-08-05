---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff Document for Agent B (Blake)
## Gate 3 加一条 advisory「证据可重放性」检查

**Created**: 2026-08-04
**Author**: Alex (Solution Lead)
**Channel**: full TAD（**强制** — R0 判定 F1_GOVERNANCE_CRITICAL，见 §0）
**Priority**: P2
**Gate 2 Status**: ⬚ PENDING

---

## 0. Route Decision（R0 preflight — 为什么是 full）

```
risk_class      : F1_GOVERNANCE_CRITICAL
match           : gate_ac_reviewer（本单修改 Gate 3 的验收清单本身）
result          : route_level=full, design_depth=full, execution_depth=full
override_allowed: false
state           : escalated_full
```

依据 `.tad/routing-contract.yaml`（`contract_id: TAD-ROUTING-2026-08`）。
⚠️ **F1 不可降级**：用户请求、escalated_review、Standard 均不能改变 `override_allowed: false`。

**历史记录（诚实留痕）**：本单曾被 Alex 误判为 lite 可行并一度写成 LITE 契约
（`.tad/archive/handoffs/withdrawn/LITE-20260804-1634-evidence-replayability-check.md`）。
两处过失：① Alex 把 escalated_review 做成 AskUserQuestion 选项并标"推荐"，违反
NOT_via_suggestion；② 跳过了 BLOCKING 的 R0 preflight，补做后才撞出 F1。
该 LITE 契约已撤出 `active/`，其设计内容被本单继承。

---

## 1. Task Overview

### 1.1 What We're Building

Gate 3 清单加**一条 advisory 检查**：证据采集命令重跑两次应产生 0 diff。
两个文件手改（canonical → 镜像），第三个由 parity 自动生成。约 17 行。

### 1.2 Why

2026-08-02～04，阅读助手项目（Codex + full TAD）在 Gate 3 空转七轮，七次 commit
全是同批文件的 `474+/474−`：

```
000b34d 09:24 | 7bfd325 09:41 | 6f345e8 09:46 | 83f6c88 09:50
b3cf2a4 12:27 | b617ce4 12:34 | 8e3b504 12:37
```

跨项目实测（30 个兄弟项目）：阅读助手 **13/42 = 31%** 的 commit 是证据重采；
voice-studio 2/111；其余 27 个为 0 —— 极端离群值。

根因：证据 JSON 含随机 `request_id` / `database_generation` / `collected_at` / `commit`，
叠加 `max_age_minutes: 15` 新鲜度策略 → 改一行代码就触发全量重采 → 产物每字节都变 →
reviewer 无法 diff 只能重读全文 → 代价随轮数线性放大。最极端的一次：`fadd18f`
只改了 `scripts/verify-scope.py` **一行**（验证器白名单），下一条就重采 474 行。

**本单让这个模式在第一次出现时就被说出来**，而不是烧掉几小时后由人事后发现。

### 1.3 Intent

**这是烟雾报警，不是灭火器。** 不阻止任何人，只保证这件事被看见。
强度选择有判例支持，见 §3.2。

---

## 2. Grounding（Alex 逐条实测 2026-08-04）

| # | 文件 | 行 | 现状逐字 |
|---|------|-----|---------|
| G1 | `.tad/gates/gate-canonical-checklist.md` | 31–43 | Gate 3 段；L33 `# MECE: verified 2026-07-03 — 6 items check 6 distinct artifacts`；L38 `- [ ] Evidence files exist — per handoff manifest. Why ME: 证据存在性`；L43 `Why CE: 产出 + 规格 + 证据 + 版本 + 知识 + 追溯 — 六个独立 artifact。` |
| G2 | `.claude/skills/gate/SKILL.md` | 272–283 | Gate 3 inline 镜像；L276 `# MECE: verified 2026-06-23 — 5 items check 5 distinct artifacts`；L277 `Critical Check (5 items):`；L280 `  - [ ] Evidence files exist per the handoff's Required Evidence Manifest` |
| G3 | `.claude/skills/gate/SKILL.md` | 85 | `Critical Check (6 items):` ← **Gate 2 段已有该字符串**（AC 锚点唯一性的关键） |
| G4 | `.tad/gates/quality-gate-checklist.md` | 3 | `> ⚠️ **SUPERSEDED** — This file is superseded by .tad/gates/gate-canonical-checklist.md (SSOT).` → 非活消费方 |
| G5 | `.tad/config-quality.yaml` | 56–57 / **110–117** / 125+ | L56 `# Edit canonical FIRST, then align checks values here.`；L57 `gate_checklist_source` 指针；**L110–117 `gate3_verification.checks` 确为清单项副本（5 项）**；L125+ `gate3_v2_implementation_integration` 为不同结构（ralph loop / expert evidence） |
| G6 | `.tad/config-quality.yaml` | 113–117 | 该 5 项副本**已缺** canonical 的 `Provenance non-empty (advisory)`（canonical 6 项 vs 此处 5 项）→ **「advisory 项不入 `gate3_verification.checks`」已有先例**，本单遵循同一先例 |
| G7 | `.tad/eval/rubric.md` | 23 | 引用 canonical Gate 3 条目原文（`Evidence files exist — per handoff manifest`）。是**引用非副本**，加第 7 项不使其失效 → 不改（具名登记，使 consumer 清扫显式） |
| G8 | `.claude/skills/gate/SKILL.md` | 251–270 | `# ⚠️ GIT COMMIT VERIFICATION CHECK (BLOCKING)`；`if_missing: action: "BLOCK Gate 3"`；doc-only 豁免要求 handoff 无 Files to Create/Modify —— **本单有 3 项文件清单，不满足豁免** |

**AC 空跑基线实测**（判别力依据）：

| 锚点 | canonical | .claude/gate | .agents/gate |
|---|---|---|---|
| `Evidence replayable` | **0** | **0** | **0** |
| `Critical Check (6 items):` | — | **1**（Gate 2） | 1 |
| `7 items check 7 distinct artifacts` | **0** | — | — |
| lite sentinel 四处 md5 唯一值数 | **1**（`4c55bcb6563f24dc78449fb19ff76067`） | | |

**结构事实**：canonical-first 纪律（镜像注释逐字写「Edit canonical FIRST, then sync here」）｜
既存 MECE drift（canonical 6 / 镜像 5，**非本单引入，不得顺手修正**）｜镜像单向
`bash .tad/hooks/lib/release-verify.sh parity --fix .`，**禁止直接编辑 `.agents/`**｜
`.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/` 是**冻结 fixture**，
任何仓库级 grep 必须排除。

---

## 3. Design

### 3.1 改动

**改动 1 — `.tad/gates/gate-canonical-checklist.md`（G1）— 必须最先**

(a) checklist 在 L38 `Evidence files exist` **之后**插入：
```
- [ ] Evidence replayable (advisory) — 证据采集命令重跑两次应 0 diff。若每次重跑都产生
      全量改动（随机 ID / 时间戳 / commit SHA 入了证据体），则任何一处改动都触发全量重采，
      reviewer 无法 diff 只能重读全文 → 先修证据管道再谈验收。Why ME: 证据管道确定性
```
(b) L33 `# MECE: verified 2026-07-03 — 6 items check 6 distinct artifacts`
 → `# MECE: verified 2026-08-04 — 7 items check 7 distinct artifacts`
(c) L43 `Why CE: 产出 + 规格 + 证据 + 版本 + 知识 + 追溯 — 六个独立 artifact。`
 → `Why CE: 产出 + 规格 + 证据 + 可重放 + 版本 + 知识 + 追溯 — 七个独立 artifact。`

**改动 2 — `.claude/skills/gate/SKILL.md`（G2）— canonical 之后**

(a) L280 `Evidence files exist per...` **之后**插入：
```
  - [ ] Evidence replayable (advisory, WARN-not-BLOCK): 证据采集命令重跑两次应 0 diff。
        若重跑产生全量改动（随机 ID / 时间戳 / commit SHA 入了证据体）→ WARN：
        任何改动都会触发全量重采，reviewer 无法 diff 只能重读全文，代价随轮数线性放大。
        建议先修证据管道（把不确定性字段移出证据体或固定种子）再继续。
```
(b) L276 `# MECE: verified 2026-06-23 — 5 items check 5 distinct artifacts`
 → `# MECE: verified 2026-08-04 — 6 items check 6 distinct artifacts`
(c) L277 `Critical Check (5 items):` → `Critical Check (6 items):`

**改动 3 — 镜像（自动，不手改）**：`bash .tad/hooks/lib/release-verify.sh parity --fix .`

### 3.2 为什么是 advisory 不是 BLOCKING

- **合法场景也会全量改动**：证据首次生成、schema 版本升级、换 formatter、
  golden fixture 有意重生成 —— 硬门槛必然误伤。
- **有直接判例**：`gate-design.md` L85 —— 旧的硬编码 test-runner 门槛被改成
  「WARN not BLOCK」软提醒，理由同构（纯 config handoff 无 compile 行，硬 block 会假阳性），
  遵循 L1「smoke alarm not fire suppressor」。
- **L1 原则**：「Mechanical Enforcement Rejected on Single-User CLI」（2026-04-15）——
  日常恢复成本 > 防偶尔跳步骤收益；软提醒对单用户 CLI，机械 hook 对多租户生产。

### 3.3 已放弃的更重方案

原设计含三个 FR（无进展熔断 / 证据可重放 / handoff 体量闸），走 full 通道跑了
**4 轮 Gate 2、8 名专家、26 个 P0、零交付**，已封存于
`.tad/archive/handoffs/blocked/HANDOFF-20260804-gate-loop-circuit-breaker.md`
（四轮分析完整保留，将来重做有地基）。本单只取其中唯一直接命中事故根因的一条，
且强度降为 advisory —— 26 个 P0 全部来自熔断机制的复杂度（新状态、计数器、
跨终端载体），本单零新状态，那些表面不存在。

---

## 4. 文件清单

| 文件 | 改动 |
|------|------|
| `.tad/gates/gate-canonical-checklist.md` | 改动 1（**必须最先**） |
| `.claude/skills/gate/SKILL.md` | 改动 2 |
| `.agents/skills/gate/SKILL.md` | 改动 3（parity 自动生成，**不手改**） |

**Non-Goals**：
- ❌ `.tad/gates/quality-gate-checklist.md` —— 文件头逐字标 SUPERSEDED（G4），非活消费方
- ❌ `.tad/config-quality.yaml` 的 `gate3_verification.checks`（L110–117）—— ⚠️ **它确为清单项副本**
  （Gate 2 R1 纠正了本单初稿"不同结构"的错误判断）。不同步的依据是**先例而非结构**：
  既存 advisory 项 `Provenance non-empty (advisory)` 同样未入该列表（G6），本单遵循同一先例；
  **drift 保留，不得顺手修正**
- ❌ `.tad/eval/rubric.md` L23（G7）—— 引用非副本，不受影响
- ❌ 既存 MECE drift 的"修正"｜❌ 任何 lite skill / hook / settings｜❌ 直接编辑 `.agents/`
- ❌ **`git push`**（见 §7.4）—— 本地 commit 允许且必需

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| AC | Verification Method | Expected Evidence |
|---|---|---|
| AC1 | `grep -Fq 'Evidence replayable (advisory)' .tad/gates/gate-canonical-checklist.md` 且 `grep -Fq '7 items check 7 distinct artifacts' 同文件` 且 `grep -Fq '七个独立 artifact' 同文件` | 三者退出 0。baseline 均为 0 命中 → 未实现必 FAIL |
| AC2 | 对 `f=.claude/skills/gate/SKILL.md`：<br>`grep -Fq 'Evidence replayable (advisory, WARN-not-BLOCK)' "$f"` 且<br>`grep -Fq '6 items check 6 distinct artifacts' "$f"` 且<br>`[ "$(grep -cF 'Critical Check (6 items):' "$f")" -eq 2 ]` 且<br>`[ "$(grep -cF 'Critical Check (5 items):' "$f")" -eq 0 ]` 且<br>`[ "$(grep -cF 'Critical Check (4 items):' "$f")" -eq 1 ]` | 五者全部成立。⚠️ **`-c == 2` 单用有已实测的假 PASS**（Gate 2 R1 构造变体：清单项插对但把 `(6 items):` 误改到 L727 的 Gate 4 块、Gate 3 仍留 `(5 items)` → 总数照样 2 → PASS）。后两条补集断言（旧头归零 + Gate 4 块不变量）已实测可杀掉该变体且不误伤正确实现 |
| AC3 | 对 `f=.agents/skills/gate/SKILL.md`：同 AC2 的五条断言 | 五者全部成立。⚠️ 必须**独立查 `.agents/` 内容**，不得以 AC4 的 parity PASS 代替（理由见 §10 知识引用 release-sync）。补集断言理由同 AC2 |
| AC4 | 先 `bash .tad/hooks/lib/release-verify.sh parity --fix .`，再 `bash .tad/hooks/lib/release-verify.sh parity .`；然后 `cmp -s .claude/skills/gate/SKILL.md .agents/skills/gate/SKILL.md` | parity 返回 PASS；cmp 退出 0。**两次 parity 原始输出贴进 Completion** |
| AC5 | `for f in .claude/skills/{blake,alex}-lite/SKILL.md .agents/skills/{blake,alex}-lite/SKILL.md; do awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' "$f" \| md5; done \| sort -u` | 输出**恰一行**且该行 == `4c55bcb6563f24dc78449fb19ff76067`。⚠️ **末尾不接 `wc -l`**：只输出计数 `1` 就看不到哈希值本身，照抄执行会漏验 Expected Evidence 的后半句（Gate 2 R1 P1）。原始输出贴进 Completion |
| AC6 | 在 step3c commit **之后**执行：<br>`git show --name-status --format='' HEAD \| awk '$1=="M"{print $2}' \| LC_ALL=C sort` | 输出恰为三行：<br>`.agents/skills/gate/SKILL.md`<br>`.claude/skills/gate/SKILL.md`<br>`.tad/gates/gate-canonical-checklist.md`<br>⚠️ **改用 commit 血径口径，不用 `git status --porcelain`**：后者与 Gate 3 的 BLOCKING commit 检查（G8）互斥——commit 后 M 集必为空（Gate 2 R1 P0-1）。新增的证据文件为 `A`，本判据只取 `M`，不受影响。<br>⚠️ 不得具名豁免任何已跟踪文件；baseline M 集为空（2026-08-04 实测） |
| AC7 | `[ "$(grep -cF 'Evidence replayable' .tad/config-quality.yaml)" -eq 0 ]` | 成立。钉死 Non-Goal：`gate3_verification.checks`（L110–117）**确为清单项副本**，本单按 `Provenance` advisory 先例（G6）不同步；此 AC 防止实现时"顺手对齐"扩大范围 |

**Required Evidence Manifest**：
- `.tad/evidence/acceptance-tests/evidence-replayability-check/` —— AC1–AC7 原始输出（含两次 parity、AC5 的哈希行、AC6 的三行）
- `.tad/evidence/reviews/blake/evidence-replayability-check/` —— Layer 2 两名 reviewer 产物。
  ⚠️ slug 必须**逐字**为 `evidence-replayability-check`（blake step3c SLUG CONTRACT 为 MANDATORY；
  Alex step4c 的 `layer2-audit.sh` 按该 slug 审计，mismatch 会红字告警；且 step3c 在 `git add` 前
  对 manifest 每个路径跑 `ls -la`，缺失即 ABORT）

---

## 6. 预注册降级分支

| # | 触发 | 处置 |
|---|------|------|
| B1 | 镜像段插入形态与 canonical 不同（yaml 围栏内） | 围栏内以同缩进列表项插入；不可行 → 停，报告人 |
| B2 | `parity --fix` 后 cmp 仍不一致 | 停，报告人；**不得手改 `.agents/`** |
| B3 | AC2/AC3 的 `Critical Check (6 items):` 计数不等于 2 | 先查 Gate 2 段那处是否被误改；确认后停，报告人 |

---

## 7. Blake 执行纪律

1. **canonical FIRST** — 改动 1 先于改动 2，Completion 记一句实际顺序。
2. **不手改 `.agents/`** — 只经 `parity --fix`。
3. **不修既存 MECE drift**（canonical 6 / 镜像 5）——各自 +1，drift 保留。
4. **允许本地 commit（step3c 正常执行），禁止 `git push`** —— main **推送** = de facto publish，
   下游 14 个项目会拉到；本地 commit 不会。推送由人决定。
   ⚠️ 初稿写成"不提交不推送"，与 Gate 3 的 BLOCKING commit 检查（G8）构成死锁——
   不 commit 则 Gate 3 BLOCK（本单有文件清单，不满足 doc-only 豁免），已按 Gate 2 R1 P0-1 修正。
5. **Layer 2 至少 2 名 distinct reviewer**（本单规模小，不需要 3 名）。

---

## 8. Expert Review Status

### Round 1（2026-08-04）— 2 名 distinct reviewer，均执行验证

| Reviewer | 维度 | verdict | P0 | P1 | P2 |
|---|---|---|---|---|---|
| code-reviewer | 锚点实证 + 一致性 + Non-Goals | CONDITIONAL | 2 | 2 | 4 |
| spec-compliance-reviewer | AC 逐行实跑 + 判别力 | CONDITIONAL | 0 | 1 | 3 |

**2 个 P0 的处置（均改契约，设计本体无返工）：**

| P0 | 处置 |
|---|---|
| **commit 三方死锁**：Gate 3 的 `Git_Commit_Verification` 是 BLOCKING（G8），而 §7.4 写"不提交" + AC6 要求文件停在 M 集 → 不 commit 则 Gate 3 BLOCK，commit 则 AC6 FAIL。且原理由（"main 推送 = publish"）只支持禁 push | §7.4 改为「允许本地 commit，禁止 `git push`」；AC6 改为 commit 血径口径 `git show --name-status` |
| **G5 事实错误**：初稿称 `config-quality.yaml` "非清单项副本"，实测 L110–117 `gate3_verification.checks` **就是**副本（Alex 采样时跳过了该区段）；文件头 L56 还写着 "align checks values here" | G5 改写为实测事实 + 新增 G6（`Provenance` advisory 先例）；§4 Non-Goal 理由从"不同结构"换成"advisory 先例"；新增 **AC7** 把该 Non-Goal 钉死 |

**P1/P2 处置**：AC2/AC3 加补集断言（reviewer 实测构造出假 PASS 变体：`(6 items):` 误改到 Gate 4 块也能过 → 加 `(5 items)==0` + `(4 items)==1` 后已实测杀掉该变体）｜AC5 去掉末尾 `wc -l`（否则只输出计数看不到哈希值，漏验 Expected Evidence 后半句）｜AC6 补可执行命令 + 删掉对已跟踪文件的具名豁免｜manifest 补 Layer 2 reviewer slug 目录（step3c SLUG CONTRACT 为 MANDATORY，缺失会 ABORT）｜`.tad/eval/rubric.md` L23 具名登记为 G7（引用非副本，不改）。

**修复后 Alex 复跑基线**（2026-08-04）：`(5 items)`=1（改后应 0，故 AC2 当前正确 FAIL）｜`(4 items)`=1（不变量成立）｜AC5 去 `wc -l` 后输出单行 `4c55bcb6563f24dc78449fb19ff76067` ✅｜AC7 基线 0 ✅。

> AC7 是 **Non-Goal 守卫**，基线即 PASS 属正常——它只在 Blake "顺手对齐" `config-quality.yaml` 时才 FAIL，作用是防范围膨胀，不是进度指示。

### Gate 2 结论

| 检查项 | 状态 |
|---|---|
| Expert review ≥2 distinct | ✅ 2 名（code-reviewer / spec-compliance-reviewer） |
| All P0 resolved | ✅ 2/2 已修，修复后基线已复跑 |
| Architecture / Components / Functions / Data flow | ✅ 单文件级改动，§3.1 三处逐字 old→new，锚点唯一性经双方实证 |

**Gate 2: PASS** —— 可交付 Blake。

---

## 10. 重要提示

### 10.1 知识引用

- `patterns/gate-design.md` L85 — 硬门槛→WARN 软提醒的同形判例（本单强度选择的依据）
- `patterns/release-sync.md` L14–15 — parity 的字节相同早退使其后的内容检查不可达；
  "byte-identical 包含 identically broken"（36 行坏内容在绿 parity 里活了一个月）→ **AC3 的存在理由**
- `principles.md`「Mechanical Enforcement Rejected on Single-User CLI」(2026-04-15)

### 10.2 已知约束

- **advisory 的上限是刻意的**：它只提醒，agent 看见后可以继续。本单不试图阻止任何人。
  若将来实测发现提醒被系统性忽略（连续多单出现全量重采而无人处理），再带实测数据
  重新设计强度 —— 而不是现在就假设需要 BLOCKING。
- **本单不修阅读助手**：那边的证据去随机化属该项目自己的 backlog（跨项目边界，
  人已裁定 2026-08-03）。本单只让 TAD 下次能更早看见同类模式。

---

*TAD v2.39.0 — full channel（F1 强制）*
