---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: ["bin", ".tad"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: npx 跨平台安装器（Codex/Claude 选择 + pack 选择 + 介绍）

**From:** Alex (Solution Lead) · **To:** Blake (Execution Master) · **Date:** 2026-06-07
**Task ID:** TASK-20260607-002 · **Epic:** N/A (single Standard handoff) · **Priority:** P2

---

## 1. Executive Summary

给 TAD 加一个 **npx 一键安装器**,安装时让用户:(a) **选平台**（Codex 还是 Claude Code）→ 按平台装不同文件；(b) **选要装的 capability packs**，每个带**一句话介绍**。核心目标之一是**给 Codex 用户减压**（装 13K 瘦版而非 86K Claude 版）。

**铁律（principles.md，⚠️ 不可违反）**：
- **不重写安装逻辑** —— npx 必须**复用 `tad.sh`**（2026-05-28 教训：手写安装脚本漏 14 个目录）。npx 只做"交互选择 → 组装参数 → 调 tad.sh"。
- **deny-list 不 allow-list**（2026-06-01 教训）。
- **shell portability**：`gtimeout→timeout→no-op` fallback；macOS 无 `grep -P`/`timeout`。
- 拷贝完整性用 `diff -rq source target` 验证。

## 2. 研究依据（已完成，勿重做）
- BMAD 深挖: `.tad/evidence/research/npx-installer-benchmark/2026-06-07-findings.md`
- Landscape: `.tad/evidence/research/npx-installer-benchmark/2026-06-07-landscape-findings.md`
- 持久 notebook `31445e5a-77ad-4d71-bba8-2939cdcefaa1`（可 `notebooklm ask` 反复查）
- **关键对标**：平台选择走 config-driven（BMAD `platform-codes.yaml` + Crab Code layered config）；pack 选择带描述（BMAD web bundles 卡片水平）；context 减压靠平台选瘦版（B 渐进加载另立 idea，本 handoff 不含）。

## 3. Requirements
1. `npx` 入口可交互运行：选平台 → 选 packs（带描述）→ 实际安装。
2. 平台选择 **config-driven**（先实现 Codex + Claude Code 两个，架构可扩展加 cursor/windsurf 不改代码）。
3. pack 选择 = checkbox 多选 + 每项一句话描述（复用各 pack `SKILL.md` frontmatter `description`）。
4. CLI 非交互模式：`npx ... --platform codex --packs web-frontend,web-backend`。
5. **复用 tad.sh** 做实际拷贝；tad.sh 新增 `--platform` 维度（现写死 claude-code）。
6. 向后兼容：无 `--platform` 时默认 `claude-code`（现有 `curl|bash tad.sh` 行为不变）。

## 4. Technical Design  ⚠️ (v2 — rewritten per expert review P0-1/P0-2/P0-3 + P1-3)

### 4.1 平台差异 = deny-delta，**不是** allow-list ⚠️（修 P0：违反 deny-list 铁律）
core `.tad/` 树对**两个平台都 deny-derived 全装**（沿用现有 `derive_framework_dirs`，两平台都不 enumerate core）。平台差异**只**表达为小的 `extra_deny` delta + root 文件 delta：
```yaml
# .tad/platform-codes.yaml
platforms:
  claude-code:
    label: "Claude Code"
    extra_deny: []                      # 全套（含 hooks + alex/blake SKILL）
    extra_root_files: []
  codex:
    label: "Codex CLI"
    extra_deny:                         # 在 deny-derived shared core 之上额外排除
      - ".claude/settings.json"         # 不装 hooks
      - ".claude/workflows"
      - ".claude/skills/alex"           # ⚠️ 不装 86K Claude SKILL = 减压核心 (P1-3)
      - ".claude/skills/blake"
    extra_root_files: ["AGENTS.md"]     # codex 需 root AGENTS.md
```
- ⚠️ **绝不**用 per-platform `install_dirs` allow-list（旧 v1 的错 → 会漏 `.tad/` core，重演 2026-05-28 + 违反 2026-06-01）。新增 core dir 自动流向两平台。
- codex **仍装全部 capability-pack skills**（`.claude/skills/{pack}/`），只排除 `alex`/`blake` 入口。
- ⚠️ `AGENTS.md` 是 **root 文件**，tad.sh 现无 root 文件拷贝路径（只拷 `.tad/*` + `.claude/*`）→ 需新增 root-file 拷贝（按 `extra_root_files`）。

### 4.2 修改 `tad.sh`（修 P0-1 arg parser + P0-3 ordering + verifier）
- **arg parser**：现 `for arg in "$@"`（line 47）单 token，**无法**吃 `--platform <value>` 两 token（会把值当下个 arg → `*) exit 1`）→ 改 `while [ $# -gt 0 ]; do case … shift`。
- `--platform` 值做 **membership 校验**（∈ platform-codes.yaml 的 platform keys）；未知平台 **`exit 1` 明确报错**，不静默 fallback。
- `detect_installed_tools()`（line 113）：**只消费 parsed flag**（零文件读）；未指定 → auto-detect fallback = claude-code。**不读 yaml** → 解决 ordering（detect 在 line 591，早于下载 line 706）。
- **copy 时**（post-download, ~line 739）从 `$TAD_SRC/.tad/platform-codes.yaml` 读 extra_deny（此时文件已存在，**无需 inline**，区别于 deny-list）。
- 现有**无条件 `.claude/` 拷贝**（line 287-298）+ 新 root-file 拷贝，须按平台 `extra_deny`/`extra_root_files` gate（codex 排除 settings.json/workflows/alex/blake）。
- **verifier** `verify_install_complete`（line 338-393，`return 1` 在 set -e+ERR trap 下会回滚）须用**同一 platform deny-delta** scope —— 否则 codex 合法排除项被误判 missing → 误 FAIL 回滚正确安装（见 AC12）。

### 4.3 pack 选择机制（修 P0-2：现有机制无可用基质）
现状：tad.sh 把 capability-packs 当 **registry-only**（只拷 `pack-registry.yaml`，不拷 pack 树/install.sh，line 160/274-277）；`.claude/skills/*` 是**全量**拷贝（line 291，所有 pack 作 skill 一次性装）。所以"选 N 个只装 N"**没有基质**。解决（Blake 选一并在 completion 说明）：
- **方案 a**：tad.sh `.claude/skills` 拷贝接受 `--packs` 白名单 → selection-aware（只拷选中 pack + alex/blake 受 §4.1 平台 deny 控制）。
- **方案 b**：npx 在 tad.sh 全量拷贝**后**，按用户选择删除未选 pack 的 `.claude/skills/<pack>/`（但这是"拷贝后删"，不优雅，且 npx 不应碰文件 → 倾向方案 a）。
- pack 名 **membership 校验**（∈ pack-registry.yaml keys）+ charset `^[a-z0-9-]+$` 再传 bash。

### 4.4 npx 入口 `bin/tad-install.mjs`（Node，交互 + 安全桥接）
- **shebang `#!/usr/bin/env node` + `chmod +x`**（npx 必需，否则 github: 分发跑不起来）。
- 交互：列平台（读 platform-codes.yaml）→ 列 packs（读 pack-registry.yaml + 各 pack frontmatter `description`，checkbox + 描述）→ 非交互 flag。
- **桥接安全**：`execFileSync('bash', ['tad.sh','--platform',p,'--packs',list,'--yes'])`，**禁止** shell 字符串拼接；**platform 值 + pack 名都 membership 校验**（不只 charset — P1-3）。
- timeout 用 Node `execFileSync(…, {timeout:N})`，**不**用 shell `timeout` shim（macOS 无 `timeout`）。
- prompts 库：优先 **zero-dep readline**（node14 兼容 + 供应链安全，符合用户 pin 原则）；`@clack/prompts` 需 node18，不选。

### 4.5 修改 `package.json`
- 加 `"bin": {"tad-install":"bin/tad-install.mjs"}`；`files` 加 `"bin/"` **和 `"tad.sh"`**（现 files **缺 tad.sh** → npm 分发会漏掉桥接目标，P1-4）。
- version `1.0.0` → `2.24.0`（与 .tad/version.txt 一致）。
- **删** `"version": "git add -A"` script（npm `version` lifecycle footgun — 每次 bump 会 `git add -A` 全树，P2-2）。

### 4.6 修改 pack `install.sh` —— 支持 `--agent codex`（P1-2/P1-5）
- 先**实际 inventory**：`ls -d .tad/capability-packs/*/ | wc -l`（reviewer 数出 **25 个不是 24**，仅 21 含 `Supported: claude-code`，`ml-training` 无对应 `.claude/skills/` 条目）。
- pack target 两平台**相同**（codex 经 AGENTS.md pack 表读 `.claude/skills/{pack}/`）→ `--agent codex` 很可能是 **no-op pass-through**（接受 flag 即可）。Blake 先确认这点：若确为 no-op，25 文件只需"接受并忽略 codex flag"，无需差异逻辑；若需差异，建 shared `install-lib.sh` 避免 25 文件漂移。
- 对**全部** pack（非"至少1"）施加一致处理。

### 4.7 分发方式（⚠️ Blake 评估，Alex 不拍板）
- **A**: `npx github:Sheldon-92/TAD`（零 npm 维护；但跑 HEAD 无 pinning → 文档须说明可 `npx github:Sheldon-92/TAD#v2.24.0` pin，符合用户供应链原则）。
- **B**: npm 包 `npx tad-framework`（immutable 版本 + integrity hash；但多一个版本同步 + `files` 须含 tad.sh）。
Blake 在 completion report 给推荐 + 理由。

## 5. Out of Scope
- **B: context 渐进加载瘦身**（核心激活层 + 按需 page）→ 已立 `IDEA-20260607-...`? 否，是单独方向；本 handoff **不含**。
- 统一认证层（`tad auth`）→ `IDEA-20260607-tad-unified-auth-layer.md`，不含。
- cursor/windsurf 等额外平台 —— 架构支持但本次不实现（只 Codex+Claude）。

## 6. Implementation Steps
1. 读 `platform-codes.yaml` 设计 + 现有 tad.sh `copy_framework_files`，**精确厘清"共享核心" vs "平台专属"文件分界**（用 `diff` 对比 Claude vs Codex 该装什么）。
2. 创建 `.tad/platform-codes.yaml`。
3. 改 `tad.sh`：加 `--platform` arg + 改 `detect_installed_tools` + 平台专属拷贝（deny-list 思路）。验证默认 claude-code 向后兼容。
4. 创建 `bin/tad-install.mjs`：交互选平台+packs（带描述）+ 非交互 flag + 安全桥接调 tad.sh。
5. 改 `package.json`（bin + files + version 一致性）。
6. 改 pack `install.sh` 支持 `--agent codex`（至少 1 个 pack 验证；批量留意 24 个一致性）。
7. 手动验证两条路径（见 §9）。

## 7. Files to Modify / Create
- **CREATE** `.tad/platform-codes.yaml`
- **CREATE** `bin/tad-install.mjs`
- **MODIFY** `tad.sh`（arg 解析 + detect_installed_tools + 平台拷贝）
- **MODIFY** `package.json`（bin + files + version）
- **MODIFY** `.tad/capability-packs/*/install.sh`（加 codex agent 分支）

**Grounded Against**（Alex step1c 实际 Read）:
- `tad.sh`（line 43-51 arg解析, 108-130 platform detect — read 2026-06-07）
- `package.json`（全文 — read 2026-06-07）
- `.tad/capability-packs/academic-research/install.sh`（head 63 — read 2026-06-07）
- `.tad/codex/README.md` + `AGENTS.md`（平台差异 — read 2026-06-07）
- `.tad/platform-codes.yaml`（new — will be created）
- `bin/tad-install.mjs`（new — will be created）

## 8. Required Evidence Manifest
```yaml
required_evidence:
  expert_reviews: [".tad/evidence/reviews/blake/npx-platform-installer/code-reviewer.md",
                   ".tad/evidence/reviews/blake/npx-platform-installer/backend-architect.md"]
  gate_verdicts: ".tad/evidence/reviews/blake/npx-platform-installer/gate3.md"
  completion: ".tad/active/handoffs/COMPLETION-20260607-npx-platform-installer.md"
  manual_test_log: "completion report 内嵌两条安装路径的实跑输出 + diff -rq 验证"
```

## 9. Acceptance Criteria  ⚠️ (v2 — per expert review)

> 通用：AC1/AC2 用 `mktemp -d` 两个独立目标，从**同一本地源**(`$TAD_SRC`)安装（勿 curl live，防网络 skew + process-substitution 不能 diff 目录树）。

- **AC1** (向后兼容): 同一本地源装入两个 temp dir：默认 `tad.sh --yes` vs `tad.sh --platform claude-code --yes`，结果**字节一致**。
  验证: `A=$(mktemp -d); B=$(mktemp -d); (cd $A && bash $TAD_SRC/tad.sh --yes); (cd $B && bash $TAD_SRC/tad.sh --platform claude-code --yes); diff -rq $A $B && echo IDENTICAL`
- **AC2** (codex core 完整 + 排除正确): codex 装出 **完整 `.tad/` core** + `AGENTS.md`，且排除 hooks/Claude-SKILL。
  验证: codex 装入 `C=$(mktemp -d)` 后：(a) `test -f $C/AGENTS.md && test -d $C/.tad/codex`；(b) `test ! -f $C/.claude/settings.json && test ! -d $C/.claude/skills/alex && test ! -d $C/.claude/skills/blake`（减压排除）；(c) **core 完整**：`diff -rq $TAD_SRC/.tad/templates $C/.tad/templates`（抽查代表性 core dir）+ `test -d $C/.tad/hooks/lib`。
- **AC3** (默认平台行为): 无 `--platform` = claude-code，**行为**等同 AC1（非 grep 字符串）。
  验证: 即 AC1 的 IDENTICAL 成立。
- **AC4** (未知平台 fail-fast): `bash tad.sh --platform cursor --yes` → 非零退出 + 明确报错，不静默 fallback。
  验证: `bash $TAD_SRC/tad.sh --platform cursor --yes; test $? -ne 0`
- **AC5** (跨平台 re-run 幂等): 同目录装 codex 再跑 codex = 干净 no-op（不半转换）。
  验证: 连续两次 codex 安装入同一 dir，第二次无报错 + `diff` 前后一致。
- **AC6** (codex 减压 — 无 86K SKILL): codex 目标**不含** Claude 版 alex/blake SKILL。
  验证: `test ! -d $C/.claude/skills/alex/SKILL.md`（与 AC2b 呼应，单列因这是核心目标）。
- **AC7** (npx 交互): 列平台 + packs **带描述**（非仅代号）。
  验证: completion 内嵌交互日志，显示 pack description。
- **AC8** (npx 非交互): `--platform codex --packs <p>` 跳过交互完成。
  验证: completion 内嵌实跑日志。
- **AC9** (桥接 membership 校验): platform 值 **和** pack 名传 bash 前都校验 ∈ 合法 keys（不只 charset）。
  验证: `grep -nE 'platform-codes|pack-registry|includes|indexOf' bin/tad-install.mjs` 显示 membership 检查（非仅 `^[a-z0-9-]+$`）。
- **AC10** (复用 tad.sh，无重实现拷贝): npx **无** copy 原语（含 JS idioms）。
  验证: `[ "$(grep -cE 'cpSync|copyFileSync|fs\.cp\b|rsync|tar |[^a-zA-Z]cp ' bin/tad-install.mjs || true)" -eq 0 ]`（注意 `|| true` 防 grep 无匹配退 1；`execFileSync('bash',...)` 合法不计）。
- **AC11** (package.json): 有 `bin` + shebang + version=2.24.0 + `files` 含 `tad.sh` + **无** `git add -A` script。
  验证: `node -e "const p=require('./package.json'); console.log(!!p.bin, p.version, p.files.includes('tad.sh'), JSON.stringify(p.scripts).includes('git add -A'))"` → `true 2.24.0 true false`；+ `head -1 bin/tad-install.mjs | grep -q '#!/usr/bin/env node'`。
- **AC12** (verifier platform-scoped): codex 安装通过 `verify_install_complete` **不误 fail**，且仍能抓真缺 core dir。
  验证: codex 安装跑完 verifier exit 0；人为删一个 codex 应有的 core dir（如 `.tad/templates`）→ verifier 应 catch（非零）。
- **AC13** (codex 装后可跑 — 反 validation-theater): 装出的 codex 能激活。
  验证: codex 目标里 `bash .tad/codex/codex-tad-alex.sh --dry-run` 成功 + AGENTS.md role 表指向的 `.tad/codex/codex-alex-skill.md` 存在。

## 9.2 Expert Review Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P0-2: §4.1 `install_dirs` allow-list 会漏 core（重演 2026-05-28）| §4.1 改 deny-derived core + extra_deny delta | Resolved |
| code-reviewer | P0-1: AC2 AGENTS.md 无 root 拷贝路径 + settings.json 无条件拷贝 | §4.1 extra_root_files + §4.2 gate line 287-298 | Resolved |
| code-reviewer | P0-2: pack 选择与 registry-only 分发不兼容 | §4.3 方案 a/b（selection-aware skill copy）| Resolved |
| both | P0-3: fresh-machine ordering（detect 早于下载读 yaml）| §4.2 detect 用 parsed flag 零读 + copy 从 $TAD_SRC 读 | Resolved |
| backend-architect | P0-3b: verifier 未 platform-scope → 误 fail 回滚 | §4.2 verifier 同 deny-delta + AC12 | Resolved |
| backend-architect | P0-1: arg parser 单 token 无法吃 --platform value | §4.2 改 while-loop + shift | Resolved |
| backend-architect | P1-3: codex 仍装 86K alex/blake SKILL → 减压失败 | §4.1 extra_deny alex/blake + AC6 | Resolved |
| code-reviewer | P1-1: AC8 grep -c 无匹配退 1，set -e 误判 | §9 AC10 加 `\|\| true` + 整数比较 | Resolved |
| code-reviewer | P1-2: AC8 漏 JS copy 原语 | §9 AC10 加 cpSync/copyFileSync/fs.cp | Resolved |
| both | P1-3/P1-4: platform 值 + pack 名 membership 校验 | §4.3/§4.4 + AC9 | Resolved |
| code-reviewer | P1-4: package.json shebang/chmod/files 缺 tad.sh/git-add script | §4.5 + AC11 | Resolved |
| code-reviewer | P1-5: 25 packs（非24）+ ml-training skill-less | §4.6 实际 inventory + 全部处理 | Resolved |
| backend-architect | P1-4: 无 AC 证 codex 可跑（validation theater）| §9 AC13 dry-run | Resolved |
| both | P2: AC1 process-subst 不能 diff 目录树 | §9 通用说明 mktemp 两 dir | Resolved |
| both | P2-3: prompts 库 node14/供应链 | §4.4 zero-dep readline | Resolved |
| backend-architect | P2-1: 分发 A 无 pinning | §4.7 文档 `#v2.24.0` pin | Resolved |

## 10. Important Notes
- ⚠️ **AC10 是 2026-05-28 铁律的可验证体现** —— npx 里写任何拷贝（含 `fs.cpSync` 等 JS idiom）= Gate 3 FAIL。
- ⚠️ **§4.1 deny-delta 是 P0 核心** —— 绝不退回 per-platform `install_dirs` allow-list。
- ⚠️ shell portability: timeout 用 Node `{timeout:N}` 非 shell shim；勿 `grep -P`/`timeout`。
- ⚠️ Codex 平台**今天刚验证端到端可用**（`.tad/evidence/codex-validation/REPORT-2026-06-07.md`）—— 装出的 codex 版应能 `codex exec` 跑通（AC13）。
- **本任务最大不确定点**（§6 step1 优先）：shared core vs 平台专属分界 —— 须用 `diff -rq` Claude-target vs Codex-target **证据化**每条 delta（对照 platform-codes.yaml），非口头断言。

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | 平台范围 | config-driven, 先 Codex+Claude | 用户拍板;学 BMAD 可扩展 |
| 2 | 复用 vs 重写安装 | 复用 tad.sh | principles 铁律 2026-05-28 |
| 3 | pack 选择 UX | checkbox + 描述 | landscape: 达 BMAD web bundles 水平 |
| 4 | context 瘦身(B) | 不含本 handoff | 用户定"主要 A";B 是雷区另做 |
| 5 | 分发方式 | **Blake 评估** | Alex 不拍板;A(github直跑)/B(npm)列入 |
| 6 | package.json version | 顺带修 1.0.0→2.24.0 | 一致性(grounding 发现陈旧) |
