# COMPLETION — 激活按需化：启动扫描从「整读文件」改成「跑命令读输出」

**Handoff**: `HANDOFF-20260817-activation-ondemand.md`（rev3）
**Blake**: 2026-08-17
**T0**: `80508bb`（rev3 重跑 Step 0 冻结）
**Evidence**: `.tad/evidence/acceptance-tests/activation-ondemand/`

## 交付物（§5 写权限 1-2）

两个 alex 文件（`.claude/skills/alex/SKILL.md` 与 `.agents/skills/alex/SKILL.md`）各应用 7 条 pins：
STEP 3.4/3.5/3.5b/3.8/3.9 的 7 条整读指令全部改为「只跑命令读其输出，禁止整读」，逐字写入（无 eval、无展开），两文件 `cmp -s` 逐字相同。

| pin | 位置 | 命令功能 |
|---|---|---|
| 1 | STEP 3.4 | 僵尸检测：`wc -l < NEXT.md` + `head -12 PROJECT_CONTEXT.md` + 每 handoff 的 date/epic/completion 三字段 |
| 2 | STEP 3.5 | 依赖扫描：changelog 摘要 + `adv=`（安全公告数组形态判定）+ `cve=`（CVE/GHSA） |
| 3 | STEP 3.5 | 依赖详情：行首锚定按名取段（修复 rev1 无锚子串匹配取错依赖） |
| 4 | STEP 3.5b | 研究图景：三态计数 + **active 的** topic（修复裸 grep 取到 dormant） |
| 5 | STEP 3.8 | `OBJECTIVES.md`：只读标题与 KR 行 |
| 6 | STEP 3.9 | github scan-log：updates/candidates/pending 三计数（修复只给 pending 导致误判 skip） |
| 7 | STEP 3.9 | `ROADMAP.md`：只读标题行 |

## AC 结果（verify-final，exit=0，RESULT=PASS）

AC1-AC10 全绿：
- **AC4 行为负控**（rev1 致命缺陷修复验证）：`scan-results.yaml` 复制 + gh 块 `security_advisories: []` 逐字替换为 `security_advisories:` + 次行 `- id: "GHSA-FAKE-0001"` → pins#2 命令输出 `adv=YES`；改回 `[]` 重跑 → `adv=none`。注入 diff、两次输出均落盘（`negative-controls/ac4-*.txt`）。旧命令恒输出 `adv=6` 的永久假警报已消灭。
- **AC6 逐源断言（rev3 收窄激活块）**：awk 机械取 `^activation-instructions:` 到下一顶格键（不硬编码行号），块内 8 源（NEXT/PROJECT_CONTEXT/研究 REGISTRY/deps scan-results/deps REGISTRY/OBJECTIVES/github scan-log/ROADMAP）`Read <源>` 计数全 0，两文件各查；**块行数 ≥200 防空真**（实测 265）。
- **AC7**：7 条命令实跑全 `exit 0` 且输出非空（`cmd-runs/1..7.out`），pins#3 用真实依赖名 `gh`（从 pins#2 输出解析）。
- AC2 冻结补集零残余（-x 排除，旧 T0 b09a26a vs 新 T0 80508bb 各自验证）；AC3 session-state 行仍在；AC5 五类计数 == 基线；AC9 围栏越界为空；AC10 契约三文件 vs T0 零 diff。

## AC11 三负控（逐条单独跑，全红）

| 负控 | 构造 | 拦截 |
|---|---|---|
| (a) | T0 原始文件只应用 pins 1-3 | AC1（NEW4-7 计数 0）|
| (b) | 全应用 + 删 session-state 行 | AC3 |
| (c) | 全应用 + pins#6 NEW 改回 `Read .tad/github-registry/scan-log.yaml` | AC6（rev3 判据：激活块内计数 1）|

## 过程记录：AC6 停过一次（rev2 → rev3）

- rev2 的 AC6 是全文件断言，与 `alex/SKILL.md:890` 的 `1_find_notebook`（`research_unified_protocol`，T0 即有、不在激活路径）冲突 → **按契约 §6 AC10 停下退回 Alex，未自行改标准**。
- Alex 核实属实（激活块内 8 源已归零 = 实现正确），裁定**收窄 AC6 到激活块** + 补块行数 ≥200 反向断言；契约升 rev3、T0=80508bb，未采纳扩 pins 与已知例外两选项（理由见契约 §10）。
- 重跑 Step 0（先 `git checkout` 恢复两文件到 HEAD 以满足 step0.sh 的 OLD 唯一性校验，再冻结、再应用 pins），全量重验。

## Friction Status

| 项 | 状态 | 处置 |
|---|---|---|
| AC3 前导缩进导致 `grep -cFx` 整行失配 | **RESOLVED** | 改 `grep -cF` 子串（契约语义=该行文本仍在）|
| AC4 命令带 `1. ` 编号前缀被 eval 当命令 | **RESOLVED** | 与 AC7 同法：反引号内抽取 |
| AC4 注入副本路径含空格拆 awk 参数 | **RESOLVED** | 路径单引号包裹 |
| step0.sh 对已应用状态拒绝重跑（OLD 唯一性）| **RESOLVED** | 先 checkout 恢复再冻结 |
| AC6 全文件 vs 激活块范围失配 | **退回 Alex 裁定** | rev3 收窄 + 防空真断言 |
| BLOCKED 项 | 无 | — |

## 未做（按契约 §4/§5）

- 未动 `session-state.md` 整读（压缩恢复安全网）｜未动 config 加载 / `@import` / `principles.md`（P7）｜未动任何 hook/代码｜未归档 `NEXT.md`｜未删任何扫描步骤｜未发布。

## 遗留 Follow-ups（人域）

1. Gate 4（Alex 独立复算）→ 人决定 commit/push（P1a/P2a/P2b 未推送 commit 同批处理）。
2. **存量 bug（契约 §9.2，须另开单）**：STEP 3.5b Path 2 正则 `/CVE-\d{4}-\d+/` 抓不到 GHSA 编号——`gh` 漏洞事故正是 GHSA 格式；替代命令已并入 GHSA，但步骤正文正则未改（不在本单写权限）。
3. P7 承接：config 按意图加载、`principles.md`/SKILL 正文按需化、`NEXT.md` 归档（杂活清单）；激活即付约 64K 落点。
4. 过程观察（可入知识库）：**「AC 红 → 停 → 退回」路径首次真实验证**——rev2→rev3 全流程（核实→裁定→重跑）2 小时内闭环。

---

## Gate 4 验收记录（Alex，2026-08-17）—— **PASS**

**独立重算，非纸面。** 自行重跑验证脚本 `RESULT=PASS`；三个冻结输入相对 T0=`80508bb`
`git diff --quiet` 均未变（git 作外部载体连续第三单守住）。

| 项 | Gate 4 实测 |
|---|---|
| 激活块内仍整读的源 | **0 / 8**，两个 alex 文件均是 |
| 7 条 pins 逐字在位 | **7 / 7** |
| `session-state` 整读行 | **保留**（压缩恢复安全网未被顺手砍掉） |
| 围栏 | 允许内 33 + hook 1；"之外"仅 2 项，均为本 session 开始前既存 |
| **激活即付** | **107.3K → 64.4K tokens，降幅 42.9K**（契约预期 43.2K，吻合） |

### AC4 行为负控：Alex 独立复跑

⚠️ **第一次复跑失败是 Alex 测错**：注入到了文件里第一处 `security_advisories: []`，
而该处属于另一个依赖，命令只打印 `version_changed: true` 的条目（仅 `gh`）→ 输出不变。
**精确注入 `gh` 段（L16..L25）后**：`adv=none` → `adv=YES` → 改回 `adv=none`。
Blake 落盘的 `ac4-inject-diff.txt` 显示注入在第 23 行，正在 gh 段内——**其做法正确**。

### 过程认定：那条"停下退回"的规矩第一次真的生效

rev2 的 AC6 写成**全文件**断言，而本单目标是**激活成本**；`alex/SKILL.md:890` 的
`Read .tad/research-notebooks/REGISTRY.yaml` 属 `research_unified_protocol`
（`*research` 显式调用才跑），T0 即存在。**实现是对的，红的是断言范围。**

Blake **停下退回 Alex，未自行豁免**——与 P1a/P2a 两次"事后追认的用户裁定"形成对照。
差别有二：(1) 冻结物在 git 里、实现方写不到；(2) 退回路径写进了 AC 正文。

**范围错误归 Alex**：两位 Gate 2 审查员审的是"总量门槛不可复算"、给的修法是逐源断言，
**该断言在多大范围内生效，无人审**——修法正确，新引入的维度未经审查。

### 遗留（另开单）

`STEP 3.5b` 的 Path 2 正则为 `/CVE-\d{4}-\d+/`，而本单引用的那起事故（漏掉 `gh` 4 个漏洞）
用的是 **GHSA 编号**——**原正则本来就抓不到**。替换命令已并入 `GHSA-`，但**原步骤正文里
那条正则不在本单写权限内**，须另开单。

**未提交、未推送。**
