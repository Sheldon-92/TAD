# LITE Handoff: Gate 3 加一条 advisory「证据可重放性」检查

**Date**: 2026-08-04 | **escalated_review**: yes (用户原话: "能不能让事情简单一点")

> escalated 记录说明（Alex 自陈）：本单命中升级清单第 2 类（`.claude/skills/*/SKILL.md`）。
> Alex 曾把 escalated_review 做成 AskUserQuestion 选项并标"推荐"，**违反 NOT_via_suggestion**
> （禁止主动提供/建议/选项化）。故不以那次点击为授权，改以用户主动、未经引导的原话
> "能不能让事情简单一点" 为准——该表述有实质理由（此前 full 通道同类改动跑了 4 轮
> Gate 2、8 名专家、26 个 P0、零交付）。

## 目标

Gate 3 清单加一条 advisory 检查：证据采集命令重跑两次应产生 0 diff。
**为什么**：2026-08-02～04 阅读助手项目（Codex + full TAD）在 Gate 3 空转七轮，
七次 commit 全是 `474+/474−` 的同批文件；跨项目实测该项目 **13/42 = 31%** 的 commit
是证据重采（voice-studio 2/111，其余 27 个项目为 0）。根因是证据 JSON 里有随机
`request_id`/`database_generation`/`collected_at`/`commit`，任何一处改动都触发全量重采，
产物每字节都变 → reviewer 无法 diff，只能重读全文，代价随轮数线性放大。
**这条检查让该模式在第一次出现时就被看见**，而不是烧掉几小时后由人事后发现。

## 不做什么

- ❌ 不做 BLOCKING 门控（advisory / WARN-not-BLOCK）。合法场景也会全量改动：
  证据首次生成、schema 版本升级、换 formatter、golden fixture 有意重生成。
  硬门槛必然误伤，且违反 L1「Mechanical Enforcement Rejected on Single-User CLI」。
- ❌ 不做熔断计数器、不做 handoff 体量闸（原 FR1/FR3 已封存于
  `.tad/archive/handoffs/blocked/HANDOFF-20260804-gate-loop-circuit-breaker.md`，
  四轮评审分析完整保留，将来重做有地基）。
- ❌ 不改 `.tad/gates/quality-gate-checklist.md`（已标 SUPERSEDED）。
- ❌ 不改 `.tad/config-quality.yaml`（只有指针 + 不同结构，非清单项镜像；见 consumer 检查）。
- ❌ 不改任何 lite skill、hook、settings。
- ❌ 不提交、不推送（由人决定）。

## 文件清单

**修改（2 个，canonical 先改）**

1. `.tad/gates/gate-canonical-checklist.md` — Gate 3 段（L31–43）
   - checklist 追加第 7 条（放在 `Evidence files exist` 之后）：
     ```
     - [ ] Evidence replayable (advisory) — 证据采集命令重跑两次应 0 diff。若每次重跑都产生
           全量改动（随机 ID / 时间戳 / commit SHA 入了证据体），则任何一处改动都触发全量重采，
           reviewer 无法 diff 只能重读全文 → 先修证据管道再谈验收。Why ME: 证据管道确定性
     ```
   - L33 `# MECE: verified 2026-07-03 — 6 items check 6 distinct artifacts`
     → `# MECE: verified 2026-08-04 — 7 items check 7 distinct artifacts`
   - L43 `Why CE: 产出 + 规格 + 证据 + 版本 + 知识 + 追溯 — 六个独立 artifact。`
     → `Why CE: 产出 + 规格 + 证据 + 可重放 + 版本 + 知识 + 追溯 — 七个独立 artifact。`

2. `.claude/skills/gate/SKILL.md` — Gate 3 inline 镜像（L272–283），**canonical 之后**
   - `Critical Check (5 items):` 列表追加（放在 `Evidence files exist per...` 之后）：
     ```
       - [ ] Evidence replayable (advisory, WARN-not-BLOCK): 证据采集命令重跑两次应 0 diff。
             若重跑产生全量改动（随机 ID / 时间戳 / commit SHA 入了证据体）→ WARN：
             任何改动都会触发全量重采，reviewer 无法 diff 只能重读全文，代价随轮数线性放大。
             建议先修证据管道（把不确定性字段移出证据体或固定种子）再继续。
     ```
   - L276 `# MECE: verified 2026-06-23 — 5 items check 5 distinct artifacts`
     → `# MECE: verified 2026-08-04 — 6 items check 6 distinct artifacts`
   - L277 `Critical Check (5 items):` → `Critical Check (6 items):`
   - ⚠️ 已知既存 drift：canonical 计数与镜像计数本就差 1（6 vs 5，非本单引入）。
     **各自 +1，保留 drift，不得顺手"修正"**。

**自动生成（1 个，不手改）**

3. `.agents/skills/gate/SKILL.md` — 由 `bash .tad/hooks/lib/release-verify.sh parity --fix .` 生成。
   ⚠️ **禁止直接编辑 `.agents/` 下任何文件。**

## AC

- AC1: canonical 落地。
  `grep -Fq 'Evidence replayable (advisory)' .tad/gates/gate-canonical-checklist.md`
  且 `grep -Fq '7 items check 7 distinct artifacts' .tad/gates/gate-canonical-checklist.md`
  且 `grep -Fq '七个独立 artifact' .tad/gates/gate-canonical-checklist.md`
  三者全部命中。

- AC2: Claude 侧镜像落地。
  `grep -Fq 'Evidence replayable (advisory, WARN-not-BLOCK)' .claude/skills/gate/SKILL.md`
  且 `grep -Fq '6 items check 6 distinct artifacts' .claude/skills/gate/SKILL.md`
  且 `[ "$(grep -cF 'Critical Check (6 items):' .claude/skills/gate/SKILL.md)" -eq 2 ]`
  三者全部命中。
  ⚠️ **计数用 `-c == 2` 不用 `-Fq`**（AC 空跑实测）：`Critical Check (6 items):` 在
  Gate 2 段（L85）**已经存在**，裸 `grep -Fq` 在未实现时就 PASS = 零判别力。
  改动后应为 2 处（Gate 2 既有 + Gate 3 新增）。

- AC3: Codex 侧镜像**内容**落地（不能只看 parity 绿）。
  `grep -Fq 'Evidence replayable (advisory, WARN-not-BLOCK)' .agents/skills/gate/SKILL.md`
  且 `[ "$(grep -cF 'Critical Check (6 items):' .agents/skills/gate/SKILL.md)" -eq 2 ]`。
  ⚠️ 理由见知识引用 release-sync：parity 的字节相同早退会让内容检查失效，
  "byte-identical 包含 identically broken" —— 必须独立查内容。
  ⚠️ 计数同 AC2，理由同上。

  **AC 空跑基线实测（2026-08-04，Alex）**：
  `Evidence replayable` 在三个文件均为 **0 命中** → 新文本锚点判别力满格；
  `Critical Check (6 items):` 在 `.claude/skills/gate/SKILL.md` 为 **1**（Gate 2）；
  `7 items check 7 distinct artifacts` 在 canonical 为 **0**；
  lite sentinel 四处 md5 唯一值数 = **1** ✅。

- AC4: parity 一致。先 `bash .tad/hooks/lib/release-verify.sh parity --fix .`
  再 `bash .tad/hooks/lib/release-verify.sh parity .` 返回 PASS；
  且 `cmp -s .claude/skills/gate/SKILL.md .agents/skills/gate/SKILL.md` 退出 0。
  两次原始输出贴进 Completion。

- AC5: 无附带损伤。
  (a) lite sentinel 四处 md5 全部 == `4c55bcb6563f24dc78449fb19ff76067`：
      `for f in .claude/skills/{blake,alex}-lite/SKILL.md .agents/skills/{blake,alex}-lite/SKILL.md; do
         awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' "$f" | md5; done`
      （含标记行）
  (b) `git status --porcelain` 的改动文件集**恰为**本单清单的 3 个文件
      （既有未跟踪项 `.tad/evidence/`、`.tad/research-notebooks/REGISTRY.yaml` 等不计）。

## 知识引用

- `.tad/project-knowledge/patterns/gate-design.md` L85 — 同形先例：旧的硬编码 test-runner 门槛
  被改成「WARN not BLOCK」软提醒，理由是硬门槛对合法场景（纯 config 改动无 compile 行）必误伤，
  遵循单用户 CLI「smoke alarm not fire suppressor」。→ 本单选 advisory 有判例，不是降低标准。
- `.tad/project-knowledge/patterns/release-sync.md` L14–15 — parity 的字节相同早退使其后的内容
  检查不可达；"byte-identical 包含 identically broken"（36 行坏内容在绿 parity 里活了一个月）。
  → AC3 必须独立查 `.agents/` 内容，不能以 AC4 的 parity PASS 代替。
- `.tad/project-knowledge/principles.md`「Mechanical Enforcement Rejected on Single-User CLI」
  (2026-04-15) — 日常恢复成本 > 防偶尔跳步骤收益；软提醒对单用户 CLI，机械 hook 对多租户生产。
  → 直接支持 advisory 而非 BLOCKING 的强度选择。

## Contract Review (2026-08-04)

Reviewer: {待填} | model={待填}
首轮 verdict: {待填}
最终 verdict: {待填}
P0={待填}, P1={待填}, P2={待填}; 已审 AC 条数: {待填}
关键发现: {待填}

## 风险与注意

- **canonical FIRST 是纪律，不是 AC**：两个文件都写着「Edit canonical FIRST, then sync here」。
  本单只加一行，先后顺序不改变最终内容，故不设"两个独立 commit"的 AC（那是 full 通道
  的仪式）。但 Blake 实现时仍按 canonical → 镜像的顺序，并在 Completion 记一句实际顺序。
- **有界 consumer 检查结果**（≤3 处采样，设计期已做）：
  - `.tad/gates/quality-gate-checklist.md` — 文件头逐字标 `⚠️ **SUPERSEDED**`，不是活消费方 → 不改
  - `.tad/config-quality.yaml` — 只有 `gate_checklist_source` 指针 + `gate3_v2` 是**不同结构**
    （ralph loop 证据、expert evidence 文件模式），非清单项副本 → 不改
  - `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/ac9-codex-only/` — **冻结 fixture**，
    含旧 SKILL 副本；任何仓库级 grep 必须排除该路径，否则会读到陈旧锚点
  → 结论：编辑面确认为 2 个手改 + 1 个自动生成，**无第三处镜像**
- **既存 MECE drift 不修**：canonical 6 / 镜像 5 本就不一致（非本单引入）。各自 +1 后变 7/6，
  drift 保留。顺手"对齐"会扩大范围，属 scope 膨胀。
- **advisory 的已知上限**：它只是提醒，agent 可以看见后继续。这是刻意的取舍——本单不试图
  阻止任何人，只保证这件事在第一次发生时被说出来。若将来实测发现提醒被系统性忽略
  （连续多单出现全量重采而无人处理），再考虑升级强度，届时应带实测数据重新设计。
- **不提交不推送**：main 推送 = de facto publish，下游 14 个项目会拉到。提交与推送由人决定。
