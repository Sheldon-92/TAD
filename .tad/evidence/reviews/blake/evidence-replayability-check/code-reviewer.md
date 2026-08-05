# Code Review — HANDOFF-20260804-evidence-replayability-check（Group 1, post-implementation）

Model: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com alias-mapped
（机械捕获：`env` → `CLAUDECODE=1`、`AI_AGENT=claude-code_2-1-220_agent`、`ANTHROPIC_MODEL=deepseek-v4-flash`、`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`）

Review date: 2026-08-04
Reviewed artifact: 实现后工作树（3 个 M 文件），对照 HANDOFF-20260804-evidence-replayability-check.md §3.1/§4/§7/§8/§9.1

---

## 总评

实现与 handoff §3.1 三处改动**逐字一致**，插入位置正确，canonical 先于镜像（mtime 实证），
MECE 计数自洽（canonical 7 / 镜像 6，drift 保留），锚点唯一性成立（Gate 2 段 L85 未被误改），
Non-Goals 三个文件零改动，改动集恰好 = 清单 3 文件（无 scope-violation）。
可执行 AC（AC1/AC2/AC3/AC4 只读部分/AC5/AC7）全部复跑 PASS。
判别力探针实证：AC2 补集断言能杀掉 Gate-2-R1 构造的假 PASS 变体。
parity --fix 收敛路径在 scratch git 仓库实测 FIX-PASS。

**唯一未决项（P1，时序性）**：AC6 的 commit-血径形态未执行——Blake 尚未 commit（工作树未暂存），
`git show --name-status HEAD` 当前指向旧 commit 80e49b3。这是 step3c 时序缺口，非实现缺陷；
以工作区等价断言（`git diff --name-status HEAD | awk '$1=="M"{print $2}'`）实测输出恰好三行。

---

## Findings

### P0（必修）— 无

- 无 scope-violation：实现者改动集 = `.tad/gates/gate-canonical-checklist.md` + `.claude/skills/gate/SKILL.md` + `.agents/skills/gate/SKILL.md` 恰好三文件（执行实证：`git diff HEAD --name-only` + `git status --short` 会话初快照）。
- 无 spec 偏差：§3.1 改动 1/2 的 (a)(b)(c) 全部逐字一致（执行实证：git diff 逐行对照 + AC1/AC2 复跑）。
- 无 Non-Goal 触碰：`config-quality.yaml` / `quality-gate-checklist.md` / `eval/rubric.md` 零改动（执行实证：`git diff HEAD --name-only` 不含三者；AC7 计数 0）。

### P1（应修/应补）— 1 项

**P1-1（流程补录）AC6 执行证据缺失 — evidence 目录无 AC6.txt；commit-血径形态未执行**
- 位置：`.tad/evidence/acceptance-tests/evidence-replayability-check/`（现有 AC1/AC2/AC3/AC4/AC5/AC7.txt，缺 AC6.txt）；handoff §9.1 AC6 行 + §9.1 Required Evidence Manifest（"AC1–AC7 原始输出"）。
- 事实：handoff 规定 AC6 在 step3c commit **之后**执行（`git show --name-status --format='' HEAD`）。审查时点 Blake 尚未 commit（git status 显示三个文件均为未暂存 ` M`，HEAD 仍为 80e49b3），故 AC6 无法按血径口径执行。
- 执行实证（等价断言）：`git diff --name-status HEAD | awk '$1=="M"{print $2}' | LC_ALL=C sort` 输出恰好三行（.agents/skills/gate/SKILL.md、.claude/skills/gate/SKILL.md、.tad/gates/gate-canonical-checklist.md），与 handoff 预期集合一致。
- 处置建议：Blake 在 step3c 完成 commit 后必须补跑 AC6 血径命令并把原始输出补录进 evidence 目录；若 Gate 3 检查时 AC6 证据仍缺 → 该 AC FAIL，应阻塞。**UNVERIFIED-BY-EXECUTION: commit-血径形态需 Blake 先行 commit（当前 HEAD 非本单 commit），审查时点客观无法执行；工作区等价断言已 PASS。**

### P2（建议）— 1 项

**P2-1（流程加固）AC6 血径对 review-后追加 commit 场景的追溯性**
- handoff 要求 AC6 用 `git show --name-status HEAD`。若 Blake 在 step3c commit 之后因 review 反馈追加 commit（非 --amend），HEAD 血径会落在追加 commit 而非实现 commit；幸运的是修复也只允许动这 3 个文件，断言仍成立。建议 Completion 中记录实际实现 commit 的 hash（而非仅 HEAD），使血径可追溯。
- 执行实证：n/a（设计建议）；阅读推断。
- 不阻塞。

---

## 逐项验证结果

### (1) Spec 符合性 — §3.1 逐字对照（执行实证：`git diff HEAD` 全文 + AC1/AC2/AC3 复跑）

| 手稿规定 | 实测 | 判定 |
|---|---|---|
| 改动 1(a)：canonical 在 `Evidence files exist` 后插入 advisory 三项三行 | diff hunk 逐字一致（含续行 6 空格缩进、"Why ME: 证据管道确定性"结尾） | ✅ |
| 改动 1(b)：`2026-07-03 — 6 items…` → `2026-08-04 — 7 items check 7 distinct artifacts` | 逐字一致 | ✅ |
| 改动 1(c)：`Why CE: …六个独立 artifact。` → `…可重放…七个独立 artifact。` | 逐字一致 | ✅ |
| 改动 2(a)：镜像在 `Evidence files exist per the handoff's Required Evidence Manifest` 后插入 4 行 advisory（WARN-not-BLOCK 措辞） | diff hunk 逐字一致（含 8 空格续行缩进） | ✅ |
| 改动 2(b)：`2026-06-23 — 5 items…` → `2026-08-04 — 6 items check 6 distinct artifacts` | 逐字一致 | ✅ |
| 改动 2(c)：`Critical Check (5 items):` → `Critical Check (6 items):` | 逐字一致 | ✅ |
| `Critical Check (6 items):` 恰好 2 处（Gate 2 + Gate 3） | L85 + L277 = 2（grep -n 实证） | ✅ |
| `Critical Check (5 items):` 0 处 | 0（grep -c 实证） | ✅ |
| `Critical Check (4 items):` 1 处（Gate 4 不变量） | L731 = 1 | ✅ |
| canonical 先于镜像 | mtime：canonical 20:00:16 < .claude/.agents 20:01:25（早 69s） | ✅ |
| 镜像未经手改（parity 生成） | .claude 与 .agents blob hash 相同（diff 显示两文件 index 43f48c7→f113d23 完全一致）+ cmp 实证；scratch 探针复现 `--fix` 收敛 | ✅ |

### (2) 正确性 — MECE / 锚点 / Non-Goals

- MECE 自洽：canonical Gate 3 清单项 = 7（awk 精确计数）↔ 头部 `7 items check 7 distinct artifacts`；镜像 Gate 3 清单项 = 6 ↔ `6 items check 6 distinct artifacts`；Provenance 仅 canonical 有（canonical 1 / 镜像 0）→ **drift 保留未修**，符合 §7 纪律 3。执行实证。
- 锚点唯一性（G3）：Gate 2 段 L85 `Critical Check (6 items):` 为既有行；`git diff` 显示 .claude 仅 L273 一处 hunk → Gate 2 段零改动；B3 分支前提（"先查 Gate 2 段那处是否被误改"）当前不触发。执行实证。
- 重复插入防御：`Evidence replayable` 在 canonical/.claude/.agents 各恰 1 处；`7 items…` canonical 1 处；`6 items…` .claude 1 处。执行实证。
- Non-Goals：`config-quality.yaml`（AC7 计数 0）、`quality-gate-checklist.md`、`eval/rubric.md` 零改动。执行实证。
- 范围：`git diff HEAD --name-only` = 恰好 3 个清单文件。执行实证。

### (3) AC 复跑（全部执行实证）

| AC | 结果 |
|---|---|
| AC1（3 条 grep -Fq） | PASS ×3 |
| AC2（五断言，.claude） | PASS ×5（count6=2 / count5=0 / count4=1） |
| AC3（五断言，.agents 独立查） | PASS ×5 |
| AC4 只读部分（`parity .` + `cmp -s`） | parity PASS (exit 0) + cmp exit 0 |
| AC4 `--fix` 部分（写操作） | 仓库内未执行（只读纪律）；scratch git 仓库探针实测 FIX-PASS 收敛（见下） |
| AC5（lite sentinel，原始输出） | 单行 `4c55bcb6563f24dc78449fb19ff76067` ✅（与 handoff 预期完全一致；本机 `md5` 管道输入输出裸哈希，无前缀问题） |
| AC6 | UNVERIFIED-BY-EXECUTION（见 P1-1）；工作区等价断言三行 PASS |
| AC7 | count=0 PASS（Non-Goal 守卫基线即 PASS，符合 handoff §8 说明） |

### 探针实证（scratch=/tmp/evrep-probe.qdLgmQ，仓库零写入）

- **探针 A — AC2 补集断言判别力**（针对 handoff §9.1 AC2 声称的 Gate-2-R1 假 PASS 变体）：
  在 scratch 构造变体——Gate 3 头改回 `(5 items)`、把 Gate 4 的 `(4 items)` 改成 `(6 items)`（总数仍 2）。
  旧式单断言 `grep -cF 'Critical Check (6 items):'` 输出 **2（假 PASS 成立）**；完整五断言 count5=FAIL、count4=FAIL（成功杀掉变体）。→ handoff 关于"后两条补集断言已实测可杀掉该变体"的声称获独立复核。执行实证。
- **探针 B — parity --fix 收敛**：scratch git 仓库（base commit 中 .agents 为旧版 43f48c7、.claude 为新版）跑 `release-verify.sh parity --fix .` → DIRECTION: claude-newer → rsync Claude→Codex → `VERDICT: parity FIX-PASS (exit 0)` → cmp 收敛 + advisory marker 1 处 + `(6 items):` 2 处。执行实证。（注：非 git 目录时脚本 fail-safe 拒绝执行，DIRECTION STOP——行为与文档一致。）

---

## 观察（不列为 finding）

1. **审查期间工作树被并行写入**：会话初快照与首次 `git status --short` 均显示 3 个 M；审查中 `NEXT.md` 出现第 4 个 M（mtime 20:37:47，晚于本单实现 20:01）。内容为用户 2026-08-04 队列更新（① IN FLIGHT 记录 + ②③④ 待办），属并行外部活动，**不归因于本单实现者，不构成 scope-violation**。若后续 diff 复核（如 Gate 4）需注意此文件不在本单范围内。
2. 镜像 advisory 措辞与 canonical 存在设计内差异（canonical "先修证据管道**再谈验收**" vs 镜像 "建议…**再继续**"）——手稿 §3.1 改动 2(a) 逐字规定如此，实现与 spec 一致，非偏差。仅提请 Alex 知悉两条目语气强度略有不同（canonical 读感偏硬），若将来强度设计复评可一并审视。
3. evidence 目录中 AC4.txt 已含两次 parity 原始输出，满足 handoff "两次 parity 原始输出贴进 Completion"要求。

---

## Verdict

**PASS**（附 P1-1 流程补录义务：AC6 的 commit-血径证据须在 Blake step3c commit 后补录；若 Gate 3 时点仍缺 → AC6 FAIL 应阻塞）

实现本体零缺陷：spec 逐字一致、AC 全绿、判别力实证、无 scope/Non-Goal 违规。P1-1 是时序性补录项而非实现缺陷，故不降 CONDITIONAL；但 Completion 与 Gate 3 必须覆盖 AC6 补跑。

---

## 执行证据

实际运行命令与原始输出（每段前 10 行）：

```
$ git status --short          # 会话初：恰好 3 个 M
 M .agents/skills/gate/SKILL.md
 M .claude/skills/gate/SKILL.md
 M .tad/gates/gate-canonical-checklist.md
?? .tad/active/handoffs/   ...

$ git diff HEAD -- .tad/gates/gate-canonical-checklist.md | head -10
diff --git a/.tad/gates/gate-canonical-checklist.md b/.tad/gates/gate-canonical-checklist.md
index 78622a3..c5704df 100644
--- a/.tad/gates/gate-canonical-checklist.md
+++ b/.tad/gates/gate-canonical-checklist.md
@@ -30,17 +30,20 @@ Why CE: 流程 + 质量 + 4 层设计检查。已 MECE ✅。
 ## Gate 3: Implementation Quality
 **Owner:** Blake | **When:** After implementation (Ralph Loop complete)
-# MECE: verified 2026-07-03 — 6 items check 6 distinct artifacts
+# MECE: verified 2026-08-04 — 7 items check 7 distinct artifacts

$ grep -Fq 'Evidence replayable (advisory)' .tad/gates/gate-canonical-checklist.md && echo PASS   # AC1
PASS
$ grep -Fq '7 items check 7 distinct artifacts' .tad/gates/gate-canonical-checklist.md && echo PASS
PASS
$ grep -Fq '七个独立 artifact' .tad/gates/gate-canonical-checklist.md && echo PASS
PASS

$ f=.claude/skills/gate/SKILL.md   # AC2 五断言
$ grep -Fq 'Evidence replayable (advisory, WARN-not-BLOCK)' "$f" && echo PASS
PASS
$ grep -Fq '6 items check 6 distinct artifacts' "$f" && echo PASS
PASS
$ [ "$(grep -cF 'Critical Check (6 items):' "$f")" -eq 2 ] && echo OK
OK
$ [ "$(grep -cF 'Critical Check (5 items):' "$f")" -eq 0 ] && echo OK
OK
$ [ "$(grep -cF 'Critical Check (4 items):' "$f")" -eq 1 ] && echo OK
OK
（AC3 对 .agents 同五断言，全部 OK）

$ grep -nF 'Critical Check (6 items):' .claude/skills/gate/SKILL.md   # 锚点定位
85:Critical Check (6 items):        ← Gate 2 段既有（G3）
277:Critical Check (6 items):       ← Gate 3 段新增
$ grep -nF 'Critical Check (4 items):' .claude/skills/gate/SKILL.md
731:Critical Check (4 items):       ← Gate 4 不变量

$ bash .tad/hooks/lib/release-verify.sh parity . 2>&1 | head -6     # AC4 只读
=========================================
PARITY VERIFY (.claude/skills <-> .agents/skills byte-identity)
  REPO: /Users/sheldonzhao/01-on progress programs/TAD
=========================================
  ✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
$ cmp -s .claude/skills/gate/SKILL.md .agents/skills/gate/SKILL.md && echo "cmp exit 0"
cmp exit 0: byte-identical

$ for f in .claude/skills/{blake,alex}-lite/SKILL.md .agents/skills/{blake,alex}-lite/SKILL.md; do awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' "$f" | md5; done | sort -u   # AC5
4c55bcb6563f24dc78449fb19ff76067

$ [ "$(grep -cF 'Evidence replayable' .tad/config-quality.yaml)" -eq 0 ] && echo PASS   # AC7
PASS

$ git diff --name-status HEAD | awk '$1=="M"{print $2}' | LC_ALL=C sort   # AC6 工作区等价断言
.agents/skills/gate/SKILL.md
.claude/skills/gate/SKILL.md
.tad/gates/gate-canonical-checklist.md

# 探针 A（判别力，scratch）：变体构造后——
$ grep -cF 'Critical Check (6 items):' /tmp/evrep-probe.qdLgmQ/repo/variant.md   # 旧式单断言
2        ← 假 PASS 成立（Gate-2-R1 变体可逃逸旧断言，与 handoff 声称一致）
$ # 完整五断言：count5=FAIL、count4=FAIL → 变体被杀

# 探针 B（--fix 收敛，scratch git 仓库）：
$ bash .tad/hooks/lib/release-verify.sh parity --fix . 2>&1 | tail -8
DIRECTION: claude-newer
  🔧 Auto-fixing: rsync Claude→Codex...
  ✅ Fix successful — .agents/skills now matches .claude/skills
VERDICT: parity FIX-PASS (exit 0)
$ cmp -s .claude/skills/gate/SKILL.md .agents/skills/gate/SKILL.md && echo CONVERGED
CONVERGED

# 模型行机械捕获（脱敏）：
$ env | grep -E '^(ANTHROPIC_MODEL|ANTHROPIC_BASE_URL|CLAUDECODE|AI_AGENT)'
ANTHROPIC_MODEL=deepseek-v4-flash
ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
CLAUDECODE=1
AI_AGENT=claude-code_2-1-220_agent
```
