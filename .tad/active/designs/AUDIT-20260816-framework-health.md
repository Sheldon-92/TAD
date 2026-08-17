# TAD 框架健康审计报告

**日期**: 2026-08-16
**执行**: Alex（Solution Lead）+ 4 个独立 subagent 审计
**仓库 HEAD**: `4718c5ec`（main，工作区干净）
**性质**: 只读审计。**本次审计未修改任何文件。**

---

## 0. 怎么读这份报告

- 每条发现有稳定编号（`F-xx` 缺陷 / `S-xx` 结构问题），Epic 按编号切 phase，不要重新编号。
- 每条都标了**证据等级**：
  - `[已验证-Alex]` — 我本人在源码/运行时直接验证，附命令
  - `[已验证-审计]` — subagent 在隔离沙箱复现，我复核了源码依据
  - `[推断]` — 有强证据链但缺直接实测，**动手前需先验**
  - `[未验证]` — 明确不知道，不要当结论用
- **§9 记录了本次审计中我自己说错并更正的地方**，避免下次重复。

---

## 1. 结论

**一个必须马上处理的缺陷，一个必须想清楚的结构问题，其余可以慢慢来。**

| | 是什么 |
|---|---|
| **马上处理** | 安装器会删除用户数据，且发生在**别人的项目**里。在修好前不应执行 `*sync`，也不应让任何人跑安装命令。 |
| **想清楚** | 质量度量体系完全自指（只量流程合规，不量结果），因此**没有任何依据决定该删什么** —— 这是框架持续膨胀、无法收缩的根因。 |

工程纪律本身是这个项目的**优势**而非问题：单点删除闸口、deny-list 推导、安装完整性校验、hook 失败开放，这些设计都是对的。缺陷集中在**绕过了自己防护的那条路径**，以及**声称已完成但实际只做了一部分的迁移**。

---

## 2. 审计范围与方法

| 审计面 | 覆盖 | 方法 |
|---|---|---|
| 发行重量 | `tad.sh` 安装路径、`package.json`、全部 git 跟踪文件 | `git archive` 实测打包体积、`git hash-object` 逐对比对 |
| 提示词架构 | `alex`/`blake`/`gate` SKILL.md + 285 个 reference + config 模块 | 字节/token 计量、YAML 顶层键切分、body↔reference 重复检测 |
| Shell / 安装器 | **364 个 shell 文件**、`tad.sh`(1895 行)、`.tad/hooks/**`(7722 行) | `bash -n` 全量、shellcheck 0.11.0、`mktemp -d` 隔离沙箱**逐字 `sed` 提取真函数**复现 |
| 文档 / 知识 | 顶层文档、`docs/**`、`.tad/project-knowledge/**` | 机械检查（版本、链接、索引、@import） |

**方法限制**：
- 文档审计的 subagent 中途自行 fan-out 并停止，未交付报告。§7 的文档结论由 Alex 本人重跑机械检查得出，**覆盖面小于原计划**（未做逐条语义阅读）。
- 未在真实下游项目上执行任何安装/同步。所有破坏性行为均在 `mktemp -d` 沙箱中复现。
- token 估算统一用 `bytes ÷ 3.5`（中英混排）。YAML/框线字符实际 tokenize 更差，**估算偏保守**。

---

## 3. P0 — 数据安全（必须先修，阻塞一切对外动作）

> 本节含 F-01 ~ F-04（P0 本体）、F-34（P0，缺陷被写进验收标准）、F-33（P1，但阻塞 P0 验收，故并列于此）。

### F-01 安装器每次运行都删除用户的 `.codex/`、`.gemini/`、`AGENTS.md`、`GEMINI.md`

**严重度**: P0 — 不可逆数据丢失，发生在用户项目
**位置**: `tad.sh:1152-1213`（函数）、`tad.sh:1196-1205`（删除循环）、`.tad/deprecation.yaml:5-14`（载荷）
**证据等级**: `[已验证-Alex]` 源码 + 闸门实测；`[已验证-审计]` 沙箱复现

**载荷**：
```yaml
# .tad/deprecation.yaml
deprecations:
  "2.3.0":
    description: "Multi-platform cleanup — remove Codex/Gemini full runtime"
    files:
      - AGENTS.md
      - GEMINI.md
      - .codex/
      - .gemini/
```

**删除代码**（`tad.sh:1196-1205`）：
```bash
if [ "$in_files" = "1" ] && printf '%s' "$line" | grep -qE '^[[:space:]]+-[[:space:]]+'; then
    if version_le "$current_dep_version" "$current_version"; then
        target=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+-[[:space:]]+//' | tr -d '"')
        if [ -e "$target" ]; then
            rm -rf -- "$target" 2>/dev/null && deleted=$((deleted + 1))
        fi
    fi
fi
```

**闸门实测**：
```bash
v1=2.3.0; v2=2.42.0
[ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -1)" = "$v1" ] && echo TRUE
# → TRUE   ⇒ "2.3.0" 这块每次都触发，永远
```

`tad.sh:1149-1150` 的文档字符串声称范围是 `(old_version, current_version]`，**代码实现的是无上界的 `≤ target`**。

**触发面**（`copy_framework_files` 内含此调用，三个分支全覆盖）：
```bash
grep -n 'copy_framework_files' tad.sh
# 1617:  install 分支
# 1712:  upgrade 分支
# 1791:  migrate 分支
```

**沙箱复现结果**（审计执行，逐字 `sed` 提取 `apply_deprecations` + `version_le`）：
```
BEFORE: .codex/config.toml  .codex/prompts/mine.md  .gemini/settings.json
        AGENTS.md  GEMINI.md  .tad/version.txt
  → Removed 4 deprecated file(s)
AFTER : ./.tad/version.txt          ← 其余全部消失
```

**作者知情，但补救方向错了**。`tad.sh:861-863` 的注释：
> `Placed AFTER apply_deprecations because deprecation.yaml v2.3.0 removes AGENTS.md (old full-runtime cleanup). For codex platform, we re-install it.`

补救是**装回 TAD 自己的 `AGENTS.md`**，不是恢复用户的。按 `.tad/platform-codes.yaml` 的 `extra_root_files`：

| 平台 | `AGENTS.md` | `.codex/` | `.gemini/` + `GEMINI.md` |
|---|---|---|---|
| `codex` / `both` | 用户版被删，覆盖成 TAD 版 | **永久丢失** | **永久丢失** |
| `claude-code`（`extra_root_files: []`） | **删除后不恢复** | **永久丢失** | **永久丢失** |

**实际影响**：`AGENTS.md` 是跨厂商 agents.md 标准（Codex / Cursor / Aider / Zed 等读取），**本仓库自己就有一个**。`.codex/` 存放 Codex CLI 用户的 `config.toml`、prompts、MCP 接线。一个已有 Codex 配置的开发者首次执行 `curl … | bash`，全部丢失，无备份无提示。

**修复方向**：
1. 闸门收成文档声明的 `(old_version, target]`
2. 删除动作改走 `migration-engine.sh` 的 `guarded_remove`
3. **不再删除整个第三方工具目录** —— 只删其中 TAD 自己写入的文件

---

### F-02 该删除路径绕过了框架全部安全机制

**严重度**: P0
**位置**: 无防护 `tad.sh:1201-1202`；有防护的同类 `.tad/hooks/lib/migration-engine.sh:41/85/147/205/216/231`
**证据等级**: `[已验证-审计]` 双路径对照实测

`migration-engine.sh` 是教科书级的单点删除闸口：
`validate_path` → `check_containment` → `check_zero_touch` → 备份断言 → `guarded_remove`（在 rm 现场二次校验，防 TOCTOU；无备份则拒绝删除）。

`apply_deprecations` **一个都不走**。它与 `deprecation.yaml` 之间唯一的东西是 `[ -e "$target" ]` —— 只挡空字符串。

**双路径对照**（同样两个 zero-touch 路径）：
```
A) apply_deprecations
   BEFORE: .tad/project-knowledge/patterns/mine.md  .tad/active/handoffs/HANDOFF-x.md
     → Removed 2 deprecated file(s)
   AFTER : .tad/version.txt          ← 两棵 zero-touch 树被销毁

B) migration-engine.sh 自己的守卫
   ZT_LIST loaded: 12 entries
   REJECT: ZERO_TOUCH: .tad/project-knowledge/patterns
   REJECT: ZERO_TOUCH: .tad/active/handoffs
     ALLOW .tad/hooks
```

**含义**：`deprecation.yaml` 里写 `~`、`/`、`../..` 或任何 zero-touch 路径都会被逐字执行。

**这条同时说明**：`shell-portability.md`（2026-06-10 条目）记录的「单一 rm 闸口」不变式 **`tad.sh` 自己已经破了**。

**建议同时写入知识库**：
> 「管住 COPY 路径的 deny-list 不管 DELETE 路径。任何在 `guarded_remove` 之外新增的 `rm`/`mv` 都静默退出了 containment + zero-touch + backup 三重保护。用 `grep -c 'rm -rf' tad.sh .tad/hooks/lib/migration-engine.sh` 在 release-verify 里钉死。」

---

### F-03 首次安装覆盖用户已有的 `CLAUDE.md`（无备份、无合并）

**严重度**: P0 — 数据丢失，且命中最常见的新用户形态
**位置**: `tad.sh:1623`（install 分支）对比 `tad.sh:1719`（upgrade）、`tad.sh:1797`（migrate）
**证据等级**: `[已验证-Alex]` 源码；`[已验证-审计]` `detect_state` 沙箱实测

```bash
# tad.sh:1623 —— install 分支
cp "$TAD_SRC"/CLAUDE.md ./          # 裸 cp，直接覆盖

# tad.sh:1719 / 1797 —— upgrade / migrate 分支
merge_claude_md "$TAD_SRC"          # 正确：备份 + 认 marker 保留用户内容
```

`merge_claude_md`（`tad.sh:1304-1345`）做的是对的事：备份到 `CLAUDE.md.bak`、定位 `<!-- TAD:PROJECT-CONTENT-BELOW -->`、保留标记以下全部内容。**它就在 300 行外，install 分支没有调用它。**

`detect_state`（`tad.sh:1365`）在 `.tad/` 与 `.claude/commands/` 均不存在时返回 `fresh` —— **那正是「已有 `CLAUDE.md`、但从未装过 TAD」的用户状态**，这是最常见的一类新用户。

沙箱实测：
```
detect_state (existing CLAUDE.md, no .tad) => fresh
   → ACTION=install (tad.sh:1456) → tad.sh:1623 → 用户规则消失，无 .bak
```

**修复**：`tad.sh:1623` 替换为 `merge_claude_md "$TAD_SRC"`。其自身的 `[ ! -f "CLAUDE.md" ]` 分支（`tad.sh:1313-1316`）已正确处理真·全新的情况。**单行修复。**

---

### F-04 Frontmatter 约束块从未生效过（**严重度已下调：P0 → P1**，2026-08-16 复审后）

> ⚠️ **本条原标 P0 并声称「3 条禁令从未生效」。该子结论已被推翻并撤回，见下方「🔴 撤回」。**
> 修正后的实质：frontmatter 是 4,229 B **死重**（无消费者、未送达），删除零风险；但**治理内容并未丢失** —— 它在 reference 中正常送达。故本条是**清理项**，不是**治理失效事故**。

**严重度**: P0 — 治理机制失效（非数据丢失，但影响所有后续判断）
**位置**: `.claude/skills/alex/SKILL.md:1-147`（frontmatter，闭合 `---` 在 L148）
**证据等级**: `[已验证-Alex]` 本 session 运行时实测

`alex/SKILL.md` 开头 4,229 字节的约束块自称 `enforcement: prompt-level-only`。

**运行时实测**（本 session 由 `/alex` 激活，对比源文件与实际送达内容）：

| | 源文件 | 模型实际收到 |
|---|---|---|
| `deny_ref` | 9 | **0** |
| `source_baseline` | 有 | **0** |
| `enforcement: prompt-level-only` | 有 | **0** |

**frontmatter 被 harness 剥离。** 随后确认无任何其他消费者：
```bash
grep -rn 'deny_ref|constraints_schema|source_baseline' --include=*.sh .   # → 空
grep -c 'deny_ref' .tad/hooks/lib/skill-body-verify.sh                    # → 0
```

**读取它的东西一个都不存在。** 它声称在 prompt 层强制，而 prompt 层正是它被剥离的层。

附带（次要）：9 个 `deny_ref` 中 8 个指向 `source_baseline: { lines: 6145 }` 的祖先版本，现文件 1,789 行。但这不重要 —— 整块从未被执行。

### 🔴 撤回：本条曾声称「3 条禁令从未生效」—— **该说法是错的**（2026-08-16 由 Gate 2 复审推翻）

**原表述**（保留留痕）：

> 逐条核对 8 个 section override 在正文中的存在情况：`gate4_delta` 正文 0、`step1d_ac_dryrun` 正文 0、`step0_graph` 正文 0 —— **这 3 条禁令自写下之日起，没有任何 agent 见过。**

**为什么错**：该结论的 grep 范围是 `alex/SKILL.md` **正文**。而这三条禁令的完整明文一直在 **Alex 会加载的 reference 文件**里：

```
handoff-creation-protocol.md:344   "MUST NOT auto-index the repository (TAD never triggers indexing)"
handoff-creation-protocol.md:345   "MUST NOT block or slow down if graph probe fails (strict <500ms budget)"
handoff-creation-protocol.md:521   "MUST NOT skip step1d under Anti-AR-001 rationalizations..."
handoff-creation-protocol.md:523   "MUST NOT turn verify-ac-commands.sh ... into a blocking gate ..."
acceptance-protocol.md:363         "MUST NOT auto-populate gate4_delta entries via any hook or script ..."
acceptance-protocol.md:364         "MUST NOT block *accept on gate4_delta presence/absence ..."
acceptance-protocol.md:365         "MUST NOT couple gate4_delta to skip_knowledge_assessment ..."
```

且位置**优于** frontmatter —— 与各自治理的步骤同处一地，由 `load_when` 按需送达，常驻成本为零。

**错误的形状**：量的是「SKILL.md 正文有没有」，回答的却是「agent 有没有见过」。**代理指标当本体** —— 这是本次审计同一形状的第三次（rev1 命令锚点错、rev2 §4.2 范围窄、本条 grep 范围窄）。

### 修正后的 F-04 结论

**仍然成立**：
- frontmatter 整块**未送达模型**（运行时实测：`deny_ref`/`source_baseline`/`enforcement` 计数均为 0）
- **无任何脚本读取它**（`grep -rn --include=*.sh` 为空；`skill-body-verify.sh` 对 `deny_ref` 引用数为 0）
- 因此它是 4,229 B 的**净死重**，删除零风险

**不再成立**：
- ~~「3 条禁令从未生效」~~ —— 它们经 reference 正常送达
- ~~「删除会丢失治理」~~ —— 绝大部分内容在别处仍然活着

**真正会丢的只有四样**（2026-08-16 复审逐条核定）：

| # | 内容 | 有无替代 |
|---|---|---|
| 1 | 全局 `deny:` 块（hook 注册 / settings.json / hook 脚本 / exit code / never_block） | 正文仅有 `SKILL.md:750-751` 的 **Phase-1-friction 窄版** → **真丢** |
| 2 | `enforcement: prompt-level-only` 标量 | 正文零；且 15 处交叉引用中 **4 处指着它** → **真丢** |
| 3 | `skillify` 的 `create_directly` / `call_from: blake` 两条 | `*skillify` 在 Alex 侧已退役 → **应退役，非应搬运** |
| 4 | `(inherits_global)` 的闭世界断言（`step1c_grounding` / `step1c_lsp`） | 正文无对应词汇 → 需显式声明「丢弃而非重指」 |

**这次迁移的真实性质**：2026-06-03 的改动是**加了一层压缩索引**，散文原文**原地保留**（每个 reference 里都留着 `# Mechanical deny migrated to frontmatter ...` 的注释为证）。frontmatter 是附加声明层，不是替代品。

**与既有决策的关系**：`principles.md` 的「Mechanical Enforcement Rejected on Single-User CLI」（2026-04-15）选择「靠提示词硬化 + 人工审计」。**该选择依然成立且实际有效** —— 硬化内容通过 reference 在送达。失效的只是那一层多余的 frontmatter 索引。

**约束块的三层结构与可恢复性**（2026-08-16 立 Epic 时追加勘定，`[已验证-Alex]`）：

| 层 | 位置 | 内容性质 | 可恢复性 |
|---|---|---|---|
| `deny:` | L9-20 | 自足的全局禁令（hook 注册、settings.json、exit code、never_block） | ✅ 就在眼前，无需恢复 |
| `cross_model:` | L22-34 | 自足；含 `AR-001 grep anchor`（L24，shell 侧 CI 使用） | ✅ 同上 |
| `section_overrides[].deny_extra` | L36-129 | **自足的结构化禁令，实质内容完整** | ✅ 同上 |
| `section_overrides[].deny_ref` | 9 处 | 指向祖先版本的行号 | ❌ **不可恢复且不该恢复**，见下 |

**关键勘定：同一个文件里存在两套行号，一套错、一套对，而被当作权威写进 `deny_ref` 的是错的那套。**

以 6,145 行祖先（`697c616e`，2026-06-02，`wc -l` 实测正是 6145）验证：

```bash
A=697c616ee281f3ab3c604bfd31041e6da9b73f35
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '3051p'   # step0_graph 的 deny_ref
```

| Key | `deny_ref` 指向 | 落点实际内容 | 判定 |
|---|---|---|---|
| `step0_graph` | L3051 | 「重新推导 AC 值」的子规则 | ❌ 无关 |
| `step1d_ac_dryrun` | L3228 | `step7: Human Handover` | ❌ 无关 |
| `gate4_delta` | L4285 | 取消确认对话 | ❌ 无关 |

而**同一个 frontmatter 里的 `migration.provenance.old_line` 指得完全正确**：

| Key | `old_line` | 落点实际内容 |
|---|---|---|
| `step0_graph` | 2915 | `forbidden_implementations:` → `MUST NOT auto-index the repository` / `MUST NOT modify .claude/settings.json MCP configuration` / `MUST NOT block or slow down if graph probe fails` |
| `step1d_ac_dryrun` | 3095 | `forbidden_implementations:` → `MUST NOT register as PreToolUse / UserPromptSubmit hook…`（5 项） |
| `gate4_delta` | 4159 | `forbidden_implementations:` → `MUST NOT register PreToolUse/PostToolUse hook to mechanically diff…` / `MUST NOT auto-populate gate4_delta entries via any hook or script — Alex writes them based on judgment` |

**因此实质内容一条没丢**：这些原文都是**反机械化**规则，而现存的 `deny_extra` 正是同一批规则的压缩编码（如 `gate4_delta.deny_extra: [auto_populate via hook/script, block accept_command]` ≈ 上述明文）。它们与 `principles.md` 的「Mechanical Enforcement Rejected on Single-User CLI」（2026-04-15）同源。

**修复方向（已因上述勘定而简化）**：
1. 把 `deny:` / `cross_model:` / 各 `deny_extra` 的**实质内容**以明文祈使句写入 SKILL 正文 —— 与正文顶部既有的「义务型祈使句」段落同风格。**不做 git 考古**：`provenance` 证明内容与 `deny_extra` 同源，无净增信息。
2. **删除** `deny_ref`（9 处，错误锚点）与整个 `migration:` 块（纯考古）。
3. 保留 `AR-001 grep anchor` 字符串本体（shell 侧 CI 用，与模型无关）—— 需确认其消费者读的是文件而非模型上下文。
4. ⚠️ **形式选择**：写入正文用**明文 `MUST NOT` 祈使句**而非压缩 YAML。理由见 §8 —— 全仓 83% 是 LLM 必须解析的 YAML 伪代码，正文顶部的义务型祈使句才是本文件已验证有效的表达形式。

**限定** `[未验证]`：只能证明本 harness（`.agents/skills/` 路径）剥离了 frontmatter。Claude Code 原生加载 `.claude/skills/` 的行为无法从仓库内观察。**但「无脚本读取」与「3 条禁令仅存于此」两点在两个平台均成立。**

---

### F-34 验收测试把 F-01 的破坏行为断言为「期望结果」

**严重度**: P0 — 缺陷被编码进规格；**这是 F-01 长期存活的直接原因**
**位置**: `.tad/tests/upgrade-acceptance.sh` → `check_deprecated()`（Check 3）
**证据等级**: `[已验证-Alex]`

`check_deprecated()` 解析 `deprecation.yaml` 的全部 `files:` 条目（即 `AGENTS.md`、`GEMINI.md`、`.codex/`、`.gemini/`），然后断言它们**不存在**：

```bash
local full_path="$TARGET/$fpath"
if printf '%s' "$fpath" | grep -q '/$'; then
  if [ -d "$full_path" ]; then
    printf '    stale dir: %s\n' "$fpath"
    stale_found=1          # ← 存在即 FAIL
  fi
else
  if [ -f "$full_path" ]; then
    printf '    stale file: %s\n' "$fpath"
    stale_found=1          # ← 存在即 FAIL
  fi
fi
```

**判定方向**：用户的 `.codex/` 幸存 → `stale dir` → **测试 FAIL**；用户的 `AGENTS.md` 幸存 → `stale file` → **测试 FAIL**。

**含义**：
1. **「用户的 Codex 配置必须被删除」是被写进验收标准的。** 每一次验收通过，都在确认 F-01 的破坏行为是正确的。
2. **修复 F-01 会让这个测试失败。** 因此修复必须同时修正该测试，否则 Phase 会被自己的测试挡住。
3. 这是本次审计发现的最强的一条 **Validation Theater 实例**（呼应 S-03）：测试验证的是「仪式是否执行」，而不是「结果是否正确」。

**修复方向**：`deprecation.yaml` 须区分「TAD 自己写入的文件」与「用户/第三方拥有的路径」。Check 3 只应对前者断言不存在；对后者应断言**存在且未被改动**（方向完全相反）。

---

### F-33 安装器无法离线端到端测试

**严重度**: P1 — 阻塞 P0 修复的验收（**禁止纸面验收**，故必须先解决）
**位置**: `tad.sh:28`、`tad.sh:1570-1572`
**证据等级**: `[已验证-Alex]`

```bash
grep -n 'TAD_SRC=' tad.sh          # → 只有一处：1572:    TAD_SRC="TAD-main"
grep -n 'DOWNLOAD_URL' tad.sh      # → 28（硬编码常量）、1570、1571
```

`DOWNLOAD_URL` 是硬编码常量，**无 env 覆盖、无 `--source` 参数**；`TAD_SRC` 唯一来源是网络下载解压出的 `TAD-main`。因此安装器无法在沙箱中以本地源端到端执行。

现有 `.tad/tests/upgrade-acceptance.sh` 是**事后校验器**（检查同步后的目标项目），不测试安装器本身；且其 zero-touch 逐字节比对需要 `--snapshot`，**未提供时直接 SKIP**。

**含义**：F-01/F-02/F-03 的修复**无法用端到端 AC 验证**，只能靠 `sed` 提取函数做沙箱复现（本次审计采用的方式）。TAD 明令「禁止纸面验收 — 必须 subagent 实际验证」，因此**可测试性本身必须作为修复的一部分交付**。

**修复方向**：增加 `--source <dir>`（或 `TAD_SOURCE_DIR` env）走本地源路径，使安装器可在 `mktemp -d` 沙箱中完整执行。这同时是 Phase 2 全部 AC 的前置条件。

---

## 4. P1 — 真实缺陷（用户可见）

### 安装器 / 同步

| 编号 | 问题 | 位置 | 等级 |
|---|---|---|---|
| **F-05** | `CLAUDE.md.bak` 是无命名空间的临时名，`:1319` 无条件覆盖、`:1339` 成功路径无条件删除。用户自己的同名备份每次升级都丢。`backup_existing()`(`:165`) 已有时间戳方案未复用 | `tad.sh:1319, 1339` | `[已验证-审计]` |
| **F-06** | `rollback_on_failure` 只恢复 `.tad/`，却打印 "Rollback complete"。此时 `.codex/`、`.gemini/`、`AGENTS.md` 已被 F-01 删除，`.claude/skills/**` 已重写，`CLAUDE.md.bak` 可能已 `rm -f`。**声明不属实** | `tad.sh:1273-1284` | `[已验证-审计]` |
| **F-07** | `curl \| tar -xz` 解压到用户项目根目录生成 `TAD-main/`，随后 `rm -rf "$TAD_SRC"`。用户自有同名目录会被合并覆盖再删除。无解压后存在性断言；ERR 路径遗留 `TAD-main/` | `tad.sh:1570-1572, 1586, 1865` | `[已验证-审计]` |
| **F-08** | `.claude/skills/*.md` 顶层文件被批量搬进 `_archived/`（allow-nothing 过滤，用户自建 flat skill 一律搬走）。upgrade 分支有 `[ ! -d _archived ]` 守卫，**migrate 分支 `:1783` 无守卫**，重复运行静默覆盖同名文件（`mv` 覆盖 + `\|\| true` 吞掉证据） | `tad.sh:1702-1708, 1783-1788` | `[已验证-审计]` |
| **F-09** | `sync-v2.8.4.sh` 用 `eval` 执行插值后的绝对路径 `rm -rf`，路径来自 `sync-registry.yaml`（**含空格 `OpenClaw Hack` 与中文 `运动打卡小助手`**）。含 `"`/`` ` ``/`$(` 的路径会变成 `rm -rf` 内的可执行代码。同文件另有三处：`:32` `ZERO_TOUCH_RE` 是**死守卫**（全文件只有定义行，零引用，且只列 6 个目录而权威源是 12 个）；`:29` `FW_DIRS` 是过期硬编码 allow-list（14 项 vs 权威推导 23 项）；`:105-110` 空元素时 `[ -d "$TAD_SRC/.tad/" ]` 为真 → 下一行变成 `rm -rf "$proj_path/.tad/"` **整棵 `.tad` 连 zero-touch 一起清空** | `.tad/scripts/sync-v2.8.4.sh:47-52, 107-108, 126-127, 146, 32, 29, 105-110` | `[已验证-Alex]` 复核：`eval "$@"` 在 `:50`；`grep -c 'ZERO_TOUCH_RE'` = **1**（仅定义行）；三处 `run "rm -rf ..."` 在 `:107/:126/:146` |
| **F-10** | 同文件 `--project` 参数解析在 `for arg in "$@"` 内 `shift`，不推进已捕获的词表 → **整轮静默空跑并报告成功**。⚠️ 精确边界：**只有空格分隔的 `--project X` 形式坏掉**，`--project=X` 形式走 `--project=*` 分支，工作正常 | `.tad/scripts/sync-v2.8.4.sh:20-26` | `[已验证-Alex]` 实测：`set -- --dry-run --project menu-snap` → `ONLY_PROJECT='--project'`（期望 `menu-snap`） |
| **F-11** | `release-verify.sh --fix` 用 `rsync -a --delete` 镜像 `.claude/skills/` → `.agents/skills/`，仅豁免 `/local/`。Codex 原生用户手写的 skill 目录会被删除。`--delete` 前无非空断言 | `.tad/hooks/lib/release-verify.sh:681` | `[已验证-审计]` |

> **F-09 / F-10 建议直接删除或隔离 `sync-v2.8.4.sh`** —— 它是一次性历史脚本（仅被 evidence 文档引用），却握着 4 个真实项目的绝对路径和一个 `eval` 驱动的 `rm -rf`。

### 恢复安全网

| 编号 | 问题 | 位置 | 等级 |
|---|---|---|---|
| **F-12** | PreCompact 快照对含空格的 handoff 名**多计数**。`list_dir` 用空格拼接 basename 再按词计数，且文件名被拆散。`ls -1 $1` 变量未加引号（SC2086 `:120`）。**这是 CLAUDE.md §4.5 指定的 Layer-0 机械安全网** —— 错在这里最难被发现 | `.tad/hooks/precompact-session-snapshot.sh:117-126` | `[已验证-Alex]` 沙箱实测：2 个真实文件（其一名含空格）→ `count` 输出 **3** |

### 提示词架构

| 编号 | 问题 | 证据 | 等级 |
|---|---|---|---|
| **F-13** | **渐进加载只对 Alex 完成**。`principles.md:103-108` 记载 v2.26.0「提取了 36 个协议」—— 那 36 个恰好是 Alex 的全部。Blake 与 Gate 从未迁移，原则措辞看不出来。**这是 SC1（62K→15K）停滞的直接原因** | 见下表 | `[已验证-审计]` |
| **F-14** | 激活即付约 **70,200 tokens ≈ 35.1%** 的 200K 窗口（用户尚未开口）；实际干活时 **43%–47%**。约 83% 内容是 LLM 必须解析的 YAML 伪代码；真正的硬禁令约 50 条，装在 272 KB 里 | `cat <11 files> \| wc -c` → 245,811 | `[已验证-审计]` + Alex 独立复算 252,676 B（含 AGENTS.md，同量级） |
| **F-15** | **模块绑定指令冲突 —— 三个实例，`config-cognitive` 对三个角色全部未加载**。详见下方展开 | `alex/SKILL.md:242`、`blake/SKILL.md:182`、`gate/SKILL.md`（无加载步骤）vs `.tad/config.yaml:101,105,109` | `[已验证-Alex]` 亲历 + 逐角色核对 |
| **F-16** | `playground` 已于 2026-06-10 废弃、正文 6 处标注废弃，**但仍写在 `alex/SKILL.md:3` 的 `description:` 里**（模型在技能目录中唯一可见的一行），且 `.claude/skills/playground/SKILL.md` (16,310 B) 照常发布 | `alex/SKILL.md:3, 584, 672, 1153-1154, 1172, 1621, 1673` | `[已验证-审计]` |
| **F-17** | **Gate 3 有四个「权威」定义**：`config-quality.yaml:125`、`gate/SKILL.md`、`blake/SKILL.md:1097 my_gates.gate3_v2`、`.tad/gates/gate-canonical-checklist.md`（后者自称 SSOT）。Blake 那份自己在打圆场：`items: "... (see canonical; MECE verified)"` | 见位置 | `[已验证-审计]` |

**F-13 数据**：
| Skill | 正文 | references | 正文占比 | 判定 |
|---|---|---|---|---|
| alex | 99,014 B | 314,485 B / 36 个 | **23.9%** | ✅ 名副其实 |
| blake | 120,413 B | 7,101 B / **2 个** | **94.4%** | ❌ 不成立 |
| gate | 52,661 B | **0** | **100%** | ❌ 从未开始 |

Blake 正文三个键占 64.5%：`ralph_loop_execution`(L360-1072, 40,017 B)、`completion_protocol`(L1599-1928, 21,621 B)、`execution_checklist`(L1225-1479, 16,060 B)。

**F-15 展开 —— Cognitive Firewall 对三个角色全部未加载**

`.tad/config-cognitive.yaml`（7,470 B）是 TAD「有益摩擦」哲学的执行层，内含 `decision_transparency`（定义什么算重大技术决策、必须停下来问人）、`research_first`、`integration`。其文件头自述消费者为 `tad-alex.md, tad-blake.md, tad-gate.md`。

`config.yaml` 的绑定**三个角色全部声明了它**：
```yaml
tad-alex:  modules: [config-agents, config-quality, config-workflow, config-platform, config-cognitive]   # :101
tad-blake: modules: [config-agents, config-quality, config-execution, config-platform, config-cognitive]  # :105
tad-gate:  modules: [config-quality, config-cognitive]                                                    # :109
```

而实际执行面：

| 角色 | SKILL 正文实际指令 | 结果 |
|---|---|---|
| Alex | `alex/SKILL.md:242` 硬编码 4 个，漏 `config-cognitive` | 未加载 |
| Blake | `blake/SKILL.md:182` 硬编码 4 个，漏 `config-cognitive` | 未加载 —— **且 `blake/SKILL.md:440` 有活指针 `config: ".tad/config-cognitive.yaml → decision_transparency.decision_triggers"`，指向一个从未被加载的文件** |
| Gate | **完全没有模块加载步骤** | `config-quality` 与 `config-cognitive` 均未按绑定加载（`config-quality` 仅在 `:227` 的特定协议内按需读取） |

**含义**：这与 F-04 是同一种形状 —— **声明存在、实际不送达的治理机制**。Blake 的情况最严重：它在运行时会去解引用一个不在上下文里的配置。

> ⚠️ **2026-08-16 更正（Gate 2 专家审查推翻）**：上表「Alex — 无引用」**是错的**。Alex 有活指针，且在一个 MANDATORY 块内：
> ```
> alex/SKILL.md:1145  # ⚠️ MANDATORY: Research & Decision Protocol (Cognitive Firewall - Pillar 1 & 2)
> alex/SKILL.md:1147    reference: "references/research-decision-protocol.md"
>                              ↓
> research-decision-protocol.md:8   blocking: true
> research-decision-protocol.md:9   config: ".tad/config-cognitive.yaml"
> ```
> 原判断只 grep 了 `decision_transparency` 字面量，**未沿 reference 下钻一层**。Alex 与 Blake 的证据等级实为**相同**（都是活指针 → 断链）。
>
> 同一次审查还推翻了「Gate 零引用」的表述：Gate 的真实理由**更强** —— 它已把 Cognitive Firewall 内容**内联**（`gate/SKILL.md:219` Risk Translation Pillar 3、`:706` Decision Compliance Pillar 1），所以绑定是多余声明，不是缺失实现。

**修复方向（2026-08-16 大幅收窄）**：

⛔ **不在 Phase 1 修**。人已裁定（2026-08-16）将「给 Alex/Blake 补 `config-cognitive`」**移出 Phase 1 单独立项**，理由见 F-36。

Gate 一侧（删除 `config.yaml` 的 `tad-gate` 绑定）风险为零且理由独立成立（内容已内联），**保留在 Phase 1**。

---

### F-36 `config-cognitive` 的加载会激活两条治理台账标为「待判」的纪律

**严重度**: P0 — 治理绕过（由 Gate 2 专家审查发现，2026-08-16）
**位置**: `.tad/config-cognitive.yaml:119-178`、`.tad/discipline-floor.md:20-21`
**证据等级**: `[已验证-Alex]`

原 F-15 的修复方向（给 Alex/Blake 补 `config-cognitive`）被当作「机械的一致性修正」。**它不是。**

**(a) 该模块不止 `decision_transparency`**：

```yaml
# .tad/config-cognitive.yaml:119-135
research_first:
  blocking: true
  protocol:
    step1_search:
      min_queries: 3
      tools: ["WebSearch", "WebFetch"]
# :174-178
  violations:
    - "Designing a custom solution without searching for existing ones = VIOLATION"
```

加载它 = 激活一个**阻塞式、设计任何方案前必须跑 ≥3 次 WebSearch** 的协议。

**(b) 与 `CLAUDE.md §2` 直接冲突**：
> 研究工具排除：遇到研究型任务时，不要 invoke `/deep-research` skill 或 spawn generic Agent 做 web search。用 `*research` 统一入口

**(c) 两条纪律在治理台账中均为「待判」**：

```
.tad/discipline-floor.md:20  研究先行     待判 ... 解除条件=循环触发实测 ... 需实测设计阶段搜索步骤的真实执行率
.tad/discipline-floor.md:21  技术决策透明  待判 ... 解除条件=循环触发实测 ... 需实测决策记录的实际留存率
```

在一次「零风险清扫」中加载该模块 = **未经实测即将两条待判纪律转正**，绕过 `discipline-floor.md` 的解除条件。

**归属**：独立工作包，见 §10.2。**先决条件是 `discipline-floor.md` 的实测**，不是写代码。

---

### 发行重量

| 编号 | 问题 | 数据 | 等级 |
|---|---|---|---|
| **F-18** | 文档主推的 `curl \| bash` 路径下载**整棵工作树**：实测 **30.19 MB**，实际需要 **4.54 MB**（6.6 倍）。`.tad/evidence/` 65.49 MB / 3522 文件 = 仓库 67%；其中**单张验收单 `release-runbook-capability-migration` 占 37.50 MB = 全仓 38%** | `git archive HEAD \| gzip -9 \| wc -c` | `[已验证-审计]` |
| **F-19** | `stable5-pre` / `stable5-post` **182 对文件、182 对 blob 完全相同、0 对有差异**。⚠️ **2026-08-16 更正**：「18.62 MB 纯重复」**只对工作树与 tarball 成立，对 `.git` 不成立** —— git 早已按内容去重（该目录 **396 个 blob 引用 → 103 个唯一 blob**）。删除 `stable5-pre` 释放工作树/发行包约 18.6 MB（对 **F-18 有效**），但 **`.git` 释放 0 字节**，反而多一个 commit。原表述夸大了收益的适用范围 | `git ls-tree -r HEAD <dir> \| wc -l` = 396；`\| awk '{print $3}' \| sort -u \| wc -l` = 103 | `[已验证-Alex]` 复核更正 |
| **F-20** | `package.json` `"files"` 列 `.tad/` 且**无 `.npmignore`**，npm 路径会打包 evidence | **✅ 2026-08-16 已实测**（`npm pack --dry-run --cache /tmp/npmcache-test` 绕过 EPERM）：`package size 23.1 MB`／`unpacked 83.2 MB`／`total files 6512`／**其中 evidence 条目 3443** | `[已验证-Alex]`（原 `[推断]`，已升级） |

**F-18/F-19 的关键有利条件**：
- `tad.sh:226` 已将 `evidence` 列入 `TAD_ZERO_TOUCH`，**不会复制进用户项目**（设计正确）。
- **运行时无任何东西读取已提交的 evidence** —— 33 处 `evidence/` 引用全部是写入目标、对用户运行时产物的计数、或 `release-verify.sh:807` 的显式 `continue` 跳过。
- 反证：`blake/SKILL.md:2114`、`dependency-ops/SKILL.md:70` 已在引用 evidence 路径，而因 zero-touch，**这些引用在每个已安装项目中今天就是断的，什么也没坏**。
- **`tad.sh` 拉的是 tarball（树快照，不含历史）** ⇒ 从 main 删除**立刻生效，无需重写历史**。

预期收益：
```
现状                             30.19 MB
删 evidence 后                   12.10 MB   (−60%)
再删 archive/active/spike-v3      5.98 MB   (−80%)
```

---

## 5. P2 — 潜在 / 风格（不阻塞，但会在未来咬人）

| 编号 | 问题 | 位置 |
|---|---|---|
| **F-21** | `version_le` 用 `sort -V`，**与本项目自己的知识条目冲突**（2026-06-14 明令「纯 bash 数值 semver 比较，NO `sort -V`」），且 `tad.sh:1351-1362` 已实现合规的 `_tad_ver_cmp`。**一个概念两个比较器**，而这正是 F-01 删除的闸门 | `tad.sh:1216-1221`、`migration-engine.sh:236` |
| **F-22** | `check_zero_touch` 在 `ZT_LIST` 为空时 **allow-all**（空输入 while 循环零次 → `return 0`）。`load_zero_touch` 本身有空断言与 sentinel 检查（设计良好），但守卫自身应断言非空而非依赖调用方 | `migration-engine.sh:147-203` |
| **F-23** | `safe_count` 对含空格的**绝对路径 pattern** 失败返回 `0`，而 `0` 正是 `exit 2 # BLOCK` 的触发值。当前 6 个调用点均传相对路径故为潜在；任何人改用 `$CLAUDE_PROJECT_DIR` 就复现「hook 拒绝一切」事故 | `common.sh:200-208`；调用点 `startup-health.sh:37-39`、`pre-accept-check.sh:47`、`pre-gate-check.sh:68,257` |
| **F-24** | 未加引号的前缀剥除 `${x#$REPO/}` ×4，**与本仓 2026-08-16 知识条目直接冲突**（`tad.sh` 4 处都写对了）。另 `:607` 把 `$AGENTS_SKILLS` 裸插进以 `\|` 为分隔符的 `sed` 正则（SC1087） | `release-verify.sh:550, 607, 612, 620, 638` |
| **F-25** | `for X in $VAR` 词分割 ×7。当前值均无空格，但这是「34 个 skill 只装了 9 个」事故与 zsh 单次迭代陷阱的记录在案的根因 | `tad.sh:189, 702, 908`；`release-verify.sh:917, 963, 995`；`runtime-freshness-verify.sh:56` |
| **F-26** | `.tad/project-knowledge/` 并非字面零接触 —— 三处 `cp` README 进去。仅框架自身 README 且错误被吞，但文档中的不变式无例外声明 | `tad.sh:1620, 1722, 1800` |
| **F-27** | 安装完成计数里的硬编码排除表只列了 12 个 zero-touch 目录中的 5 个（缺 `decisions`/`dependencies`/`github-registry`/`memory`/`research-notebooks`/`skill-library` 等）。仅影响日志行，但正是本文件他处已治愈的 allow-list 病 | `tad.sh:975-978` |
| **F-28** | shellcheck: `SC2148` 缺 shebang ×4、`SC1071` zsh 脚本 ×2 —— 全在 `.tad/evidence/**` 的 `verify*.sh`。鉴于本仓 2026-08-05 的教训「Bash 工具跑的是 zsh」，无 shebang 的验证脚本正是最容易被错误解释器执行的产物 | `.tad/evidence/**/verify*.sh` |
| **F-29** | `codex-tad-bundle/.tad/hooks/lib/common.sh` 与 `.tad/hooks/lib/common.sh` 内容不同 —— `safe_count`/`record_trace` 两份拷贝无漂移检查 | `codex-tad-bundle/` |
| **F-30** | `CLAUDE.md` §7 的 `@import` 清单 **8 个里 5 个不存在**（`testing.md`/`ux.md`/`performance.md`/`api-integration.md`/`mobile-platform.md`）。设计上静默跳过故无害，但意味着文档描述的知识结构 5/8 是愿景 | `CLAUDE.md` §7 |
| **F-31** | 顶层文档死链 1 条（`ROADMAP.md` → 已删除的 `IDEA-20260603-dual-platform-orchestration-adapter.md`）；`docs/archive/`、`docs/releases/` 内 20+ 条，均为历史文件 | 见位置 |
| **F-32** | `sync-registry.yaml` 与磁盘实际不符：`Next Guest` 实际 `2.33.0` 而注册表记 `2.30.0`；2 个注册项目目录已不存在（`运动打卡小助手`、`Colin声音项目`） | `.tad/sync-registry.yaml` |

---

## 6. 已验证为正确的部分（不要在 Epic 里误伤）

审计明确确认这些设计是好的，**修复时不要破坏**：

- **zero-touch 在 COPY 路径上确实成立**：`derive-sync-set.sh --dirs`(23) ∩ `--zero-touch`(12) = **∅**；`tad.sh` 内联推导与库输出**逐字节一致**；`tad.sh --verify-denylist` 通过（17 条）；所有活跃 `.tad/*` 目录都被分类为 sync/zero-touch/transient，**无遗漏**。缺陷**只在 DELETE 路径**。
- **`migration-engine.sh` 是正确的单点删除闸口**（见 F-02 的 B 路径实测）。
- **hook 失败开放，不会锁死用户 session**：`hook-envelope.sh:9-11` TTY 先于 `cat` 判定（不会挂起）；`common.sh:6-9` 探测 `jq` 并提供纯 shell 回退；`notebook-dormant-sync.sh:41` 显式注释非零不得读作 block。唯二的 `exit 2` 都在冷启动逃逸之后，是语义上有意的阻塞。
- **`verify_install_complete`(`tad.sh:1005-1096`)** 对每个推导目录 `diff -rq`、每个顶层文件 `cmp -s`，失败返回 1 触发 ERR → rollback。这是抵消 `2>/dev/null || true` 的关键承重设计。
- **语法健康**：364 个 shell 文件 `bash -n` **全部通过**；`tad.sh` 仅 7 条 shellcheck 提示且全为风格类。
- **空格安全的正确实践**：`copy_framework_files` 用 `"$src"/.claude/skills/*/`（引号变量 + 裸 glob）；`while IFS= read -r` + here-string 处理 `find` 输出；推导与漂移检查路径全程 `LC_ALL=C`；`is_denied`(`:344-356`) 做目录边界匹配；`fork_pack`/`unfork_pack` 拒绝 `*/*|..|.`；`probe_remote_version` 用 semver 正则校验载荷（防「404 返回 HTML」）。
- **知识索引准确**：`patterns/_index.md` 10 条索引 ↔ 10 个文件，**0 悬空 0 孤儿**。
- **版本一致**：`.tad/version.txt` / `package.json` / `.tad/config.yaml` / `tad.sh:26` **全部 2.42.0**。
- **URL 组织名已修干净**：`github.com/sheldonzhao` 仅剩 1 处，位于 `.tad/evidence/**/_archived/` 的冻结测试装置内；正确的 `Sheldon-92` 出现在 66 个文件。
- **`docs/value-proposition.md` 措辞诚实**，主动声明「注册表是同步目标列表，不是营销数字」。

---

## 7. 文档与知识层

**这是四个审计面中最健康的一层。**

| 检查项 | 结果 |
|---|---|
| 版本一致性 | ✅ 四个权威源全部 2.42.0 |
| 错组织 GitHub URL | ✅ 仅 1 处，在归档测试装置内 |
| 顶层文档死链 | 1 条（F-31） |
| `patterns/_index.md` 索引准确性 | ✅ 10/10，0 孤儿 0 悬空 |
| `CLAUDE.md` `@import` | ⚠️ 8 个里 5 个不存在（F-30，设计上静默跳过） |
| `docs/archive` 死链 | 20+，均历史文件，无害 |

知识库本体：213 条 L1/L2 条目，**未发现内部矛盾**，L3 自 2026-06-10 休眠。条目普遍 600–813 词，**偏长到不适合按需加载**。

`[未验证]`：213 条条目的逐条语义可复用性（「是可迁移规则还是会话日记」）**未完成独立复核**。原计划执行该项的 subagent 中途自行 fan-out 并停止，未交付报告。

---

## 8. 结构问题（不是 bug，是方向）

### S-01 两个月零交付

```
当前版本         2.42.0  (2026-08-16)
14 个下游项目     全部 2.30.0  (2026-06-11)
其间发布          13 个版本，一次都没送出去
```

盘上实测（不信注册表）：`menu-snap` / `ArtForge` / `toy` 均 `2.30.0`；`Next Guest` 实为 `2.33.0`（注册表记错，见 F-32）；2 个注册项目目录已不存在。

**两个月的框架演进，价值目前为零。** 在 F-01/F-02/F-03 修复前**不应执行同步** —— 那会把删除缺陷推送到 13 个真实项目。

### S-02 力气的去向

最近 300 个 commit 的目录触碰次数：

| 目录 | 次数 |
|---|---|
| `.tad/evidence` | 3300 |
| `.claude` + `.agents`（agent 提示词） | 1208 |
| `.tad/archive` | 442 |
| `.tad/hooks` + `tad.sh`（真正的可执行代码） | **87** |

**23% 的 commit 只动 `evidence`/`archive`/`active`/`memory`，不碰任何功能。**

347 个归档 handoff 的标题几乎全是框架自身的事（codex 对齐、能力包、gate 改造、activation 优化）。

`[推断]` 347 个 handoff 中约 **129 个**（按名字匹配）无对应 COMPLETION，而正式标记 cancelled/blocked 的仅 9 个。匹配方法较粗，**动手前需精确重算**；但对一个以「证据化验收」为卖点的框架，这个缺口值得查。

### S-03 质量尺子完全自指 ⭐ 最重要

`.tad/eval/rubric.md` 的五个维度：

| 维度 | 量的是什么 |
|---|---|
| D1 规格对齐 | AC 有没有逐条记录 |
| D2 验证严谨度 | 盘上有没有 review 文件 |
| D3 流程纪律 | 步骤顺序对不对 |
| D4 偏差透明度 | 偏差有没有写出来 |
| D5 知识捕获 | 有没有蒸馏成条目 |

**五个维度，没有一个在问：做出来的东西是不是更好用、更少 bug、更快。**

全部在问「TAD 的仪式有没有被正确执行」，且数据来源是 TAD 自己产生的文件。

**这不是新发现** —— `principles.md` 2026-05-15 的 "Validation Theater" 条目（Codex/Gemini 交叉审计，3/5 与 2/5 分）已经记录了同一问题，当时的建议 (A) 是「每个包必须做 3–5 组 before/after 行为对比」。**三个月后建成的 eval harness，量的仍然是流程合规。**

**为什么这是所有减法的前置条件**：那约 50 条硬禁令，每一条背后都有一次真实事故（F-04 的 GHSA 正则防的是「停跑 28 天漏 4 个漏洞、其中一个明文打印 token」；F-17 的 `git_tracked_dirs_verification` 生于「38 个生产文件数周未 `git add`」）。**没有结果尺子，删任何一条都会因为「万一它在防某个事故」而删不掉，框架只能持续膨胀。**

### S-04 README 的采纳表述

`README.md:65-68` 称「14 registered downstream projects use TAD」。外部读者会读作「有 14 个采纳者」。实际是作者自己的 14 个本地目录，2 个已不存在，全部停在两个月前的版本。`docs/value-proposition.md` 已诚实限定过，**README 这句没有**。

---

## 9. 本次审计中的自我更正（留档，避免重复）

**更正 1 —— Alex 关于 evidence 分发的表述有误。**
- 原述：「evidence 会随包发给所有人，装一次下载 87MB」
- 事实：① `tad.sh:226` 已将 `evidence` 列入 zero-touch，**不会进用户项目**（设计正确，是我漏看）；② 真实下载量是 **30.19 MB 压缩后 tarball**，非 87 MB（那是未压缩的 git 跟踪量）；③ npm 路径带 evidence 属 `[推断]`，`npm pack --dry-run` 因本机缓存权限未能实测。
- 教训：**区分「git 跟踪量」「打包下载量」「安装落盘量」三个不同的数**，不要互相替代。

**更正 2 —— 「129 个 handoff 无 completion」是粗匹配结果**，未做精确核对，已在 S-02 标为 `[推断]`。

**更正 3 —— F-04 的「3 条禁令从未生效」是错的**（由 Gate 2 复审推翻，详见 F-04 内的「🔴 撤回」）。
- 原述：`gate4_delta` / `step1d_ac_dryrun` / `step0_graph` 只存在于被剥离的 frontmatter，无 agent 见过
- 事实：三条的完整明文一直在 Alex 会加载的 `references/` 中，且位置优于 frontmatter
- 后果：F-04 严重度 P0 → P1；Phase 1 的迁移工作量大幅缩小

**更正 4 —— F-15 的「Alex 对 `config-cognitive` 零引用」是错的**（详见 F-15 内更正）。只 grep 字面量，未沿 reference 下钻一层。

**更正 5 —— F-19 的「18.62 MB 纯重复」适用范围被夸大**（详见 F-19）。对工作树/tarball 成立，对 `.git` 不成立。

**补验 1 —— F-20 已从 `[推断]` 升级为 `[已验证]`**（2026-08-16，Phase 4 审查期）。
原因：起草时 `npm pack --dry-run` 因本机 npm 缓存 root 权限报 EPERM。
解法：`--cache /tmp/npmcache-test` 绕过。实测 **6512 个文件中 3443 条属 evidence**，包体 23.1 MB。
→ **教训：`[推断]` 标记必须有解除路径。** 本条卡在一个纯环境问题上，而绕过只需一个参数 ——
标记为推断后若不主动找解法，它会一直以推断的身份被引用。

### ⚠️ 五次更正里有三次是同一个形状

| 次 | 量了什么 | 用来回答什么 | 缺口 |
|---|---|---|---|
| F-04 | `alex/SKILL.md` **正文**有无该 key | agent **有没有见过**这条禁令 | 漏了 `references/` |
| F-15 | SKILL.md 有无 `decision_transparency` **字面量** | Alex **有没有**消费该配置 | 漏了沿 reference 下钻一层 |
| handoff rev1 | 改「robust」后的新命令 | 配的却是**旧命令**的测量值 | 改判据未重测 |

**共同教训（已具备进 `patterns/ac-verification.md` 的资格）**：
> **代理指标不是本体。** 每次用 grep 计数回答一个语义问题前，必须显式写出「我量的范围」与「问题的范围」，并确认二者重合。范围不重合时，计数为 0 只说明**没在我看的地方**，不说明**不存在**。
> 推论：**改判据 = 判据失效，必须重测；旧测量值不随命令迁移。**

**方法说明**：本次审计对所有 P0 声明均由 Alex 本人回到源码独立复核后才采信，未直接转述 subagent 结论。F-04 由 Alex 在运行时亲自实测。P1 中后果最重的三条（F-09 `eval`+死守卫、F-10 参数解析、F-12 Layer-0 计数）已由 Alex 追加独立复现；F-10 在复现中**收窄了原结论**（只有空格分隔形式坏，`--project=X` 正常），已写回条目。其余 P1/P2 条目为审计方沙箱结论 + Alex 源码位置核对，未逐条复现。

---

## 10. 工作包与去向

> ⚠️ **编号权威边界（2026-08-16 立 Epic 后收口）**
> - **发现编号（F-xx / S-xx）的权威源是本报告**，Epic 与 handoff 只引用、不重编。
> - **Phase 编号的权威源是 `.tad/active/epics/EPIC-20260816-framework-health-repair.md`**，本节**不再**定义 Phase 编号。
> - 本节下表是**工作包清单与去向登记**：说明每条发现被哪个 Epic 吸收、或仍在待立项状态。
> - 之所以这样切：一个概念两套编号必然漂移 —— 这正是 F-17（Gate 3 有四个"权威"家）的同一种病，不在立项第一天就重犯。

### 10.1 已被 EPIC-20260816-framework-health-repair 吸收

| Epic Phase | 覆盖发现 |
|---|---|
| Phase 1 清扫失效声明 | F-04, F-16, F-19, F-15（**仅 Gate 一侧：删 `tad-gate` 绑定**） |
| Phase 2 安装器数据安全 | F-01, F-02, F-03, F-05, F-06, F-07, F-08, F-33, F-34 |
| Phase 3 遗留脚本与计数安全 | F-09, F-10, F-11, **F-12** |
| Phase 4 发行瘦身 | F-18, F-20 |

⚠️ **Epic 级硬约束**：Phase 2 通过 Gate 4 之前，不执行 `*sync`、不发布、不建议任何人运行安装命令。

### 10.2 尚未立项的工作包（待本 Epic 完成后另议）

| 工作包 | 覆盖发现 | 前置 | 说明 |
|---|---|---|---|
| **恢复交付** | S-01, F-32 | 上述 Epic 全部完成 | 修正注册表（2 个死项目、1 个版本错记），同步到 12 个存活项目。跨 12 个版本，需分批 |
| **激活成本** | F-13, F-14, F-17 | Epic Phase 1 | **先单独搬 `ralph_loop_execution`**（40 KB，`*develop` 显式触发，非循环）验证后再动其余两个，正文留触发桩。`completion_protocol` / `execution_checklist` 正是 2026-06-09 Codex dogfood 失败的那一类，循环触发器会咬人 |
| **结果度量** ⭐ | S-03 | 无（可随时开始设计） | **唯一需要真正想清楚的一件**。建议先 `*discuss` 而非直接立单。开场问题见 §10.3 |
| **Cognitive Firewall 激活** | **F-36**, F-15（Alex/Blake 一侧） | **`discipline-floor.md:20-21` 的循环触发实测** | 2026-08-16 由 Gate 2 专家审查从 Phase 1 **移出**。它不是一致性修正，而是激活两条治理台账标为「待判」的纪律，其中 `research_first`（`blocking: true`, 强制 ≥3 次 WebSearch）与 `CLAUDE.md §2`「研究工具排除」直接冲突。**先做实测，再谈加载**；若决定加载，须显式限定范围（仅 `decision_transparency`）|
| **长尾清理** | F-21 ~ F-31 | Epic Phase 1 | 低风险，可择机批量处理 |
| **表述修正** | S-04 | 无 | README「14 downstream projects use TAD」需加与 `value-proposition.md` 同等的限定 |
| **（不立项）** | **S-02** | — | **诊断性观察，非工作包** —— 23% 的 commit 只动 evidence/archive/active/memory；`.tad/evidence` 被改 3300 次 vs `hooks`+`tad.sh` 87 次。它没有对应的"修复"动作，而是 **S-03 为何重要的证据**：力气正在流向自我记录而非产出。收口方式是把 S-03 的结果尺子建起来，不单独立单。**保留此行以免被静默丢弃。** |

### 10.3 结果度量的开场问题（供 `*discuss` 用）

1. 什么样的证据能让你相信「用了 TAD 的任务比没用的更好」？
2. 现有 12 条 golden-set 轨迹能否回填出结果维度，还是必须前瞻性收集？
3. 结果维度是进 rubric 成第 6 维，还是单独一层（流程分 vs 结果分分开报）？
4. 如果结果分与流程分背离（流程满分、结果差），谁说了算？

---

## 11. 一句话

**先把会删别人数据的三个洞堵上，再做清理，最后解决「怎么知道自己是不是在变好」。前两件是工程，第三件决定这个项目接下来的方向。**

---

*报告生成：2026-08-16 · Alex（Solution Lead）· 只读审计，未修改任何文件*
