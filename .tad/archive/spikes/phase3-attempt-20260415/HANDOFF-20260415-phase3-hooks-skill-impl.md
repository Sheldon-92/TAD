---
task_type: code
e2e_required: yes
research_required: no
---

# Handoff: Phase 3 — Hooks + SKILL Implementation (v3-LEAN)

**From:** Alex | **To:** Blake | **Date:** 2026-04-15
**Epic:** EPIC-20260413-symmetric-quality-enforcement.md (Phase 3/5)
**Priority:** P0 (Epic critical path)
**Handoff Version:** 3.1.0
**Task ID:** TASK-20260415-001

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了全文 + **v3-LEAN 设计文档 `.tad/evidence/designs/DESIGN-20260414-phase2-enforcement-matrix-v3-LEAN.md`（这是实际 spec，本 handoff 是实现契约）**
- [ ] 阅读了「📚 Project Knowledge」章节的 15 条历史教训（全部直接影响实现）
- [ ] 阅读了「🔧 Domain Pack References」章节
- [ ] 理解 AW-1 bootstrap exception（first-run 降级为 LOG-ONLY，否则本 handoff 自己会被新 hook 阻断 → dogfood paradox）
- [ ] 确认可独立完成实现；不清楚处**立即返回 Alex**

---

## 1. Task Overview

### 1.1 What We're Building

实现 Phase 2 v3-LEAN 设计的 **机械对称质量链强制栈**：

- **2 个 hook dispatcher**：`quality-enforcement.sh`（PreToolUse Write-family + Bash）+ `userprompt-override.sh`（UserPromptSubmit OV-1）
- **6 个 lib 模块**：`quality-checker.sh` / `sentinel-detect.sh` / `path-guard.sh` / `content-scanner.sh` / `evidence-validator.sh` / `override-verify.sh`（`lib/common.sh` + `lib/dep-guard.sh` 沿用 Phase 1c 产物）
- **3 个 YAML schema**：`evidence-manifest.yaml` / `sentinel-patterns.yaml` / `protected-paths.yaml`
- **SKILL 硬化**：byte-exact 注入 `anti_rationalization_registry`（Alex）+ `honest_partial_protocol`（Blake）+ 6 条 anchor 插入
- **Gate verdict 写入器**：gate2/3/4-verdict.tsv 在 `/gate` skill、completion_protocol、acceptance_protocol 中自动写入
- **Bootstrap**：first-run 生成 `secret.key`、追加 `.tad/state/` 到 `.gitignore`、扫描历史 secret 提交
- **10 个 regression fixtures**：覆盖 sentinel + cross-role + Bash exfil + Unicode edge cases
- **CI perf gate**：dedicated runner，N=100，p95 < 100ms

### 1.2 Why We're Building It

**业务价值**：2026-04-13 用户反馈 Blake 两次在 Next Guest / menu-snap 显式跳过 Layer 2，证明**文字约束对 LLM 行为无效**。Phase 3 是 Epic 核心产出，把 Phase 1a/1b/1c 验证通过的机制**真正装到 `.claude/settings.json`**，让 Alex 和 Blake 都不能再跳过专家审查 / evidence / Gate。

**成功的样子**：Phase 3 完成后，在 Next Guest 或 menu-snap 项目故意让 Blake 跳过 Layer 2 → PreToolUse hook 硬阻断，error 清单列出缺失的 evidence 文件路径。

### 1.3 🆕 Intent Statement

**真正要解决的问题**：让"没写专家审查文件就不能 Write `📨 Message from Blake`"成为**机械事实**（hook deny），而不是 SKILL.md 里的文字劝告。

**不是要做的（避免误解）**：
- ❌ 不是重新设计 v3-LEAN（设计已冻结，Gate 2 PASS v2，commit `3dbc998`）
- ❌ 不是把 v2 的"理想版"防御（HMAC witness、TR39 confusables、grapheme rule、SHA content-binding）也实现进来——v3-LEAN 明确按单用户 CLI 威胁模型砍掉了这些
- ❌ 不是只改 SKILL.md——SKILL 文字只是次级防御，**主防御必须是 hook**
- ❌ 不是追求 100% bulletproof——OV-1 override 是设计保留的唯一人类逃生通道，LLM 永不可用

### 1.4 Required Evidence Manifest (Alex 必填 — hook 将检查此段)

Blake 完成后，以下文件**必须全部存在**（hook AW-1/BW-1 将拒绝缺失）：

```yaml
required_evidence:
  expert_reviews:
    - path: ".tad/evidence/reviews/alex/phase3-hooks-skill-impl/code-reviewer.md"
      min_bytes: 500
    - path: ".tad/evidence/reviews/alex/phase3-hooks-skill-impl/security-auditor.md"
      min_bytes: 500
    - path: ".tad/evidence/reviews/alex/phase3-hooks-skill-impl/backend-architect.md"
      min_bytes: 500
  gate_verdicts:
    - path: ".tad/evidence/gates/phase3-hooks-skill-impl/gate2-verdict.tsv"
      must_contain: "PASS"
    - path: ".tad/evidence/gates/phase3-hooks-skill-impl/gate3-verdict.tsv"   # Blake writes at completion
      must_contain: "PASS"
  completion:
    - path: ".tad/active/handoffs/COMPLETION-20260415-phase3-hooks-skill-impl.md"
      anchor_regex: "^Overall: (PASS|FAIL|PARTIAL-GO)$"
  blake_reviews:
    - path: ".tad/evidence/reviews/blake/phase3-hooks-skill-impl/code-reviewer.md"
      min_bytes: 500
    - path: ".tad/evidence/reviews/blake/phase3-hooks-skill-impl/security-auditor.md"
      min_bytes: 500
  perf_evidence:
    - path: ".tad/evidence/perf/phase3-hooks-skill-impl/ci-bench-N100.tsv"
    - path: ".tad/evidence/perf/phase3-hooks-skill-impl/ci-env-manifest.json"
  fixture_results:
    - path: ".tad/evidence/fixtures/phase3-hooks-skill-impl/fixture-results.tsv"
  dogfood:
    - path: ".tad/evidence/traces/phase3-hooks-skill-impl/dogfood-trace.jsonl"
      min_lines: 3   # AC15 三条事件：bootstrap-allow / completion-write / post-bootstrap-deny
  knowledge_updates:
    - path: ".tad/project-knowledge/security.md"
      anchor_regex: "TOCTOU.*symlink"   # KG-002 条目（AC18）
    - path: ".tad/project-knowledge/architecture.md"
      anchor_regex: "Phase 3.*(2026-04)"   # Gate 3/4 Knowledge Assessment 产出（CLAUDE.md Rule 5 BLOCKING）
  skill_diff_evidence:
    - path: ".tad/evidence/designs/extracts/v2-section-4.1.1-anti-rationalization.yaml"  # 从 v2 design 提取的 byte-exact 参考（AC4 用于 diff 对比）
    - path: ".tad/evidence/designs/extracts/v2-section-4.2.1-honest-partial.yaml"         # 同上（AC5）
```

**Manifest contract**：hook AW-1/BW-1 只校验 `expert_reviews` / `gate_verdicts` / `completion` / `blake_reviews` 四类的存在 + anchor 匹配。其余类（perf/fixture/dogfood/knowledge/skill_diff）作为 Gate 3/4 Alex 人工验收项，由 `evidence-validator.sh` 只做 existence check 不做 deny。

---

## 2. Spec Source Contract

**v3-LEAN 设计文档是本实现的单一来源 (Single Source of Truth)**：

- **文件**：`.tad/evidence/designs/DESIGN-20260414-phase2-enforcement-matrix-v3-LEAN.md`
- **Commit**：`3dbc998` (feat: Phase 2 v3-LEAN — threat-model-calibrated design)
- **权威度**：如设计文档与本 handoff 冲突，**以设计文档为准**。本 handoff 的职责是把设计拆解成 AC 清单 + 验证证据清单，不是重新定义行为。

Blake 实现前**必须 Read 该设计文档全文**（424 行），本 handoff 的所有 AC 都有 `(design §X.Y)` 反向引用。

**v2 版本**（`DESIGN-20260414-phase2-enforcement-matrix.md`，835 行）仅作扩展参考（多租户/对抗威胁模型），**不是 Phase 3 实现目标**。v2 砍掉的项目（HMAC witness、TR39、grapheme、SHA binding 等）**明确 OUT OF SCOPE**。

---

## 3. Acceptance Criteria (19 items — v3-LEAN §10.1 "≤15 target" 扩展为 19，new AC16-AC19 来自 expert review P0 整合)

**AC 措辞规则**（来自 Phase 1c 知识）：
- 所有 "列表 + 计数" 的 AC 使用 imperative list form："All of A, B, C must PASS"，**不**使用 "≥N of these"
- 所有包含多约束的 AC 先过 **AC Conflict Matrix 自检**（见本文 §6）

| # | AC | 验证方法 | Design ref |
|---|----|---------|-----------|
| AC1 | **8 个 shell 脚本全部创建且可执行**：`quality-enforcement.sh`, `userprompt-override.sh`, 以及 `lib/` 下 6 个模块（`quality-checker.sh`, `sentinel-detect.sh`, `path-guard.sh`, `content-scanner.sh`, `evidence-validator.sh`, `override-verify.sh`）均需 `#!/usr/bin/env bash` + chmod +x + `bash -n` 语法检查通过 | `ls -la` + `bash -n` 每个文件，结果入 `fixture-results.tsv` | §2.1 |
| AC2 | **3 个 YAML schema 创建且 yq 可解析**：`evidence-manifest.yaml`, `sentinel-patterns.yaml`, `protected-paths.yaml` 均能通过 `yq -o=json '.' {file}` 无报错 | `yq` 测试，输出存 TSV | §1.1, §1.3, §3 |
| AC3 | **settings.json 注册 2 个新 hook**：PreToolUse Write-family matcher 走 `quality-enforcement.sh`（保留现有 Haiku prompt hook 不动）+ UserPromptSubmit 新增 `userprompt-override.sh`（与现有 `userprompt-domain-router.sh` 共存）。`claude -p` 启动时无配置错误 | 启动 `claude -p --no-session-persistence --tools '' --settings .claude/settings.json` 用一条简单 prompt 验证 hook 链不报错 | §2.1 |
| AC4 | **SKILL 硬化 — Alex**：`.claude/skills/alex/SKILL.md` 新增 `anti_rationalization_registry` top-level key（v2 §4.1.1 byte-exact 80 行 YAML）+ `handoff_creation_protocol` 三处 anchor 插入（step0_5 AC Conflict Matrix / step1 Required Evidence Manifest / acceptance_protocol.step7 raw-TSV recompute）。**参考提取文件**：`.tad/evidence/designs/extracts/v2-section-4.1.1-anti-rationalization.yaml`（Blake 从 v2 design §4.1.1 ` ```yaml` fence 之间的原文提取，作为 AC4 diff 基准） | `diff -u .tad/evidence/designs/extracts/v2-section-4.1.1-anti-rationalization.yaml <(yq '.anti_rationalization_registry' .claude/skills/alex/SKILL.md)` 必须返回空 + 3 处 anchor `grep -c` 各 ≥1 | §5, v2 §4.1.1 |
| AC5 | **SKILL 硬化 — Blake**：`.claude/skills/blake/SKILL.md` 新增 `honest_partial_protocol` top-level key（v2 §4.2.1 byte-exact 30 行 YAML）+ `completion_protocol` 三处 anchor 插入（step3c evidence ls-check / step8_generate_message raw-metric quote / ralph_loop.layer2 express-not-exempt）。**参考提取文件**：`.tad/evidence/designs/extracts/v2-section-4.2.1-honest-partial.yaml` | `diff -u .tad/evidence/designs/extracts/v2-section-4.2.1-honest-partial.yaml <(yq '.honest_partial_protocol' .claude/skills/blake/SKILL.md)` 必须返回空 + 3 处 anchor `grep -c` 各 ≥1 | §5, v2 §4.2.1 |
| AC6 | **Bootstrap + gitignore — 原子有序**：first-run 时 `quality-enforcement.sh` 必须按以下**固定顺序**执行（任一步失败 → DENY fail-closed + stderr ERROR，不可部分完成）：(a) `mkdir -p .tad/state && chmod 700 .tad/state`；(b) **先追加 `.gitignore`**（`grep -qxF '.tad/state/' .gitignore \|\| echo '.tad/state/' >> .gitignore`）；(c) **再原子生成 secret.key**：`(umask 077; openssl rand -base64 32 > .tad/state/secret.key.tmp && mv .tad/state/secret.key.tmp .tad/state/secret.key)`——确保 secret.key 出现在磁盘时 gitignore 已就位；(d) `git log --all -- .tad/state/secret.key` 若有任何提交 → 写 `.tad/state/LEAK_DETECTED` 持久 sentinel 文件（chmod 600），所有后续 PreToolUse 写操作必须 deny 直到人类 OV-1 `gate=emergency` 清理 | `fixture-bootstrap-atomic.sh`：验证顺序 a→b→c；`fixture-bootstrap-leak-detected.sh`：模拟历史提交 → LEAK_DETECTED 存在 + 后续 Write 被 deny | §9 |
| AC7 | **AW-1 bootstrap exception 边界——只针对 secret.key 存在性**：secret.key **不存在**（first-run） → Write `.tad/active/handoffs/HANDOFF-*.md` 的 sentinel-less 内容 LOG-ONLY allow；secret.key **存在**（armed） → sentinel-less 写仍 allow（正常编辑），但带 sentinel 的写必须走完整 evidence manifest 校验（AC8 覆盖）。本 AC 仅验证 bootstrap→armed 的二元切换，不与 AC8 的 manifest 检查重复 | 2 个 fixture：`fixture-bootstrap-no-secret-allow.sh`（删 state 后 sentinel-less Write → allow + stderr warn）+ `fixture-armed-no-manifest.sh`（留 state、带 sentinel、无 evidence → deny JSON 含缺失清单） | §1.1 AW-1, §9 |
| AC8 | **AW-2/BW-1 sentinel 检测 + evidence manifest 联合校验**：Write 内容含 `📨 Message from Alex` 或 `📨 Message from Blake` + U+2500 连续 ≥16 时，必须检查对应 manifest（alex_handoff_ready / blake_completion_ready）；缺失任一 required 文件 → deny JSON 列出缺失清单 | 4 个 fixture：分别对 Alex/Blake sentinel + 有/无 evidence 验证 | §1, §3 |
| AC9 | **BW-3 Bash write-path 拦截（target-path-based）**：Bash 命令**以目标路径**判定（非仅操作符）——若最终写入路径落在 `.tad/evidence/**` 或 `.tad/active/handoffs/**` 则 deny，无论使用何种机制：重定向（`>`, `>>`, `&>`, `2>>`, heredoc `<<`, `<<<`）、复制/移动（`cp`, `mv`, `git mv`, `rsync`, `install`）、链接（`ln`, `ln -s`）、内容编辑（`sed -i`, `awk ... > file`, `tee`, `dd of=`）、时间戳伪造（`touch`——防 mtime 绕过 AC12 freshness）、解释器写入（`python -c '...write...'`, `perl -e '...'`, `node -e '...'`）。**实现策略**：`path-guard.sh` 在 Bash 分支内解析 command 中所有可能的输出目标（`>`/`>>`/`tee`/`cp N`/`mv N`/`ln N`/`sed -i`/`-o FILE`/`touch N` 模式），逐一校验是否落在保护目录 | 3 个 fixture：`fixture-bash-cp-to-evidence.sh`（cp 拦截）、`fixture-bash-touch-evidence.sh`（touch mtime 伪造拦截）、`fixture-bash-python-write.sh`（解释器写入拦截） | §1 BW-3 |
| AC10 | **HP-1 protected path + HP-2 env injection + PT-1 path traversal 全部 deny**：HP-1 protected paths 列表以 **`protected-paths.yaml::protected_paths`** 为 authoritative source（至少包含：`.claude/settings*.json`, `.tad/hooks/**`, `.tad/skills/**/SKILL.md`, `hardened-*.sh`, `~/.claude/settings.json`, `.tad/state/**`, `.tad/state/LEAK_DETECTED`）；HP-2 env-injection patterns 以 **`protected-paths.yaml::env_injection_patterns`** 为 authoritative source（**完整清单必须包含**：`TAD_SKIP_VALIDATION=`, `TAD_DISABLE_HOOKS=`, `CLAUDE_SETTINGS_PATH=`, `CLAUDE_CONFIG_DIR=`, `BASH_ENV=`, `ENV=`, `SHELLOPTS=`, `PS4=`, `IFS=`, `PERL5OPT=`, `PERL5LIB=`, `AWKPATH=`, `PYTHONSTARTUP=`, `PYTHONPATH=`, `NODE_OPTIONS=`, `LD_PRELOAD=`, `DYLD_INSERT_LIBRARIES=`, `DYLD_LIBRARY_PATH=`, `GIT_EXTERNAL_DIFF=`, `GIT_SSH_COMMAND=`, `GIT_PROXY_COMMAND=`）；PT-1：file_path canonicalized 后含 `..` 段 → deny。**HP-1 也必须 realpath 检查**（防 symlink 绕过）。所有三条 deny 必须同时覆盖 Write-family **和** Bash（不限 Write-family） | 6 个 fixture：protected-write / protected-bash / protected-symlink / env-inj-write / env-inj-bash / path-traversal，每类至少 3 个子 case（含 GIT_*, IFS, realpath symlink target） | §1 HP-1, HP-2, PT-1 |
| AC11 | **OV-1 override 流程 + OV-2 canonicalized scan**：UserPromptSubmit 收到 `^TAD_OVERRIDE: <gate> <reason>$`（reason ≥20 非空白字符、无 `\t\n`、无禁用子串 `prev_hmac=/hmac=/ts=/source=/FAKE_ROW`）必须：(a) 生成 nonce 写入 `.tad/state/nonces.jsonl`（chmod 600 plain JSONL）；(b) **幂等分配**——同 session_id + 同 gate + 未消费 + 未过期（1h TTL） → 返回已有 nonce 不追加；(c) 同 session 下一次 PreToolUse 若匹配 gate 则 allow + 标记 consumed；(d) **Subagent 隔离**——Task-spawned subagent 获新 session_id → 父 session nonce 不可被消费（记录 fixture 验证）；(e) **OV-2 canonicalized content scan**——tool_input 内容先走 §3 canonicalization（strip U+200B..U+200F / U+202A..U+202E / U+2060..U+2069 / U+FEFF + Unicode casefold）**再**匹配 `tad_override:` literal，任一命中 deny（防 `TAD\u200BOVERRIDE:` 零宽空格绕过）；OV-2 覆盖面 = Write + Edit + MultiEdit.edits[].new_string + NotebookEdit + Bash.command + Bash.description + Task.prompt | 7 个 fixture：合法 / 理由太短 / 禁用子串 / 幂等重发 / subagent-isolation / OV-2-literal / OV-2-zerowidth-bypass | §1 OV-1/OV-2, §3, §6 |
| AC12 | **KG-001 `--handoff-path` flag + mtime 新鲜度**：`lib/evidence-validator.sh` 接受 `--handoff-path` 参数；evidence 文件 mtime < handoff 文件 mtime → deny "stale evidence"（**明确不做 SHA content-binding**——v2 特性，v3-LEAN 砍掉） | 2 个 fixture（fresh / stale），结果入 TSV | §7.1 KG-001 |
| AC13 | **Perf gate — CI dedicated runner（含 per-lib 分解 + short-circuit）**：GitHub Actions workflow `.github/workflows/tad-perf-gate.yml` 必须：(a) dedicated runner + `concurrency: cancel-in-progress: false`；(b) bench 前 `uptime` load avg < 1.0（否则 sleep 30s 重试最多 3 次，3 次仍超标 → workflow FAIL）；(c) `pgrep -a claude` 必须为空；(d) warm-up run 丢弃；(e) N=100 per hook；(f) **per-hook p95 目标**——`quality-enforcement.sh` (dispatcher 总) <100ms、`userprompt-override.sh` <100ms；**per-lib 内部目标**（通过 `CHECKPOINT` 分段测量）：`path-guard.sh` <10ms、`content-scanner.sh` <15ms、`sentinel-detect.sh` <40ms、`evidence-validator.sh` <40ms；(g) **evidence-validator PARTIAL-GO 允许**：若 `evidence-validator.sh` p95 在 100-120ms 之间，可标记 PARTIAL-GO + 在 completion report 中明确 documented gap（per v3-LEAN §8 原文），Phase 5 用 archive manifest cache 修复；**超过 120ms 强制 FAIL**；(h) **short-circuit ordering 强制**——dispatcher 内 path-guard → content-scanner → sentinel-detect → evidence-validator 严格顺序，任一 deny 立即 return（不继续执行后续 lib）；(i) 导出 `ci-bench-N100.tsv`（含 per-lib 分段 checkpoint 时间）+ `ci-env-manifest.json`（uname、load avg、runner 型号、`which perl jq yq awk`） | CI workflow 运行通过 + artifact 上传；若 evidence-validator PARTIAL-GO 则 completion report `Overall: PARTIAL-GO` + documented gap 段落 | §8 per v3-LEAN, §10.3 |
| AC14 | **10 个 regression fixtures 全部 PASS**：按 v3-LEAN §3 清单 10 个 fixture 全部通过期望结果，`fixture-results.tsv` 记录 `fixture_name\texpected\tactual\tverdict` | `bash .tad/evidence/fixtures/phase3-hooks-skill-impl/run-all.sh` 全绿 | §3 |
| AC15 | **Dogfood — 本 handoff 自己走全流程**：Phase 3 COMPLETION 写入时走 bootstrap exception（first hand-off）→ 之后 Alex Gate 4 写 gate4-verdict.tsv → 下一个 handoff 写 sentinel 时 hook 已 fully armed（deny 缺 evidence 场景）。记录 `dogfood-trace.jsonl`（**至少 4 条事件**：bootstrap-allow、completion-write、post-bootstrap-deny、OV-2-negative-case——后者验证 LLM 试图在 tool content 写 `TAD_OVERRIDE:` 被 deny） | 本 handoff acceptance 时 Alex 验证该 trace 文件存在且 4 条事件齐全 | §9 |
| **AC16** | **Fail-closed 纪律（P1c AC17 血泪教训延续）**：所有 8 个脚本必须：(a) **第一行 source `lib/dep-guard.sh`**（PATH pin + 工具白名单 jq/yq/perl/awk/openssl/git，缺任一 → hardcoded deny JSON + exit 0）；(b) **stdin 读超时**——每个 stdin-reading hook 用 `perl -e 'alarm(2); ...'` 或 `read -t 2`，超时 → 硬编码 deny + exit 0；(c) **1 MB size cap**——stdin 先 `head -c 1048576` 再喂给 jq，超限 → deny `payload_too_large` + exit 0；(d) **任何未捕获异常**（`set -euo pipefail` + trap ERR） → deny + exit 0；(e) **LEAK_DETECTED sentinel**（AC6.d）存在时所有写操作 deny 直到 OV-1 `gate=emergency` | 4 个 fail-closed fixture：`fixture-missing-jq.sh`（PATH 去掉 jq → deny）、`fixture-slow-stdin-3s.sh`（timeout → deny）、`fixture-1.1MB-payload.sh`（size cap → deny）、`fixture-leak-detected.sh`（sentinel → deny），对比 Phase 1c AC17 回归套件确保无 fail-OPEN | §7.3, Phase 1c AC17 知识 |
| **AC17** | **Gate verdict 写入路径允许——防递归悖论**：`/gate` skill、Blake `completion_protocol`、Alex `acceptance_protocol` 最终会 Write `.tad/evidence/gates/<slug>/gate{2,3,4}-verdict.tsv`——这些 Write 不能被 HP-1 deny（会造成"验收要写 verdict 但 verdict 被 hook 拦 → 永远过不去"死锁）。**解决**：`path-guard.sh` 的 allowlist 显式豁免 `.tad/evidence/gates/*/gate{2,3,4}-verdict.tsv` 路径模式；允许 append-only 写入，但 **拒绝 overwrite 已存在的 PASS 记录**（防止 Blake 改已 archived handoff 的 gate3 verdict） | 3 个 fixture：`fixture-gate2-write-allowed.sh`、`fixture-gate3-append-allowed.sh`、`fixture-gate3-overwrite-pass-denied.sh` | §1.2 per v3-LEAN |
| **AC18** | **KG-002 TOCTOU 知识条目** (v3-LEAN §7.2)：追加条目到 `.tad/project-knowledge/security.md`：标题含 "TOCTOU" + "symlink"，正文说明"单 session 策略 + procedural mitigation + 等待 Claude Code core realpath-on-write 原语作为 structural fix"。本 Phase 3 无 active detection（v3-LEAN 明确砍掉 v2 §6.2 的 concurrent-session detect） | `grep -E "TOCTOU.*symlink" .tad/project-knowledge/security.md` ≥1 行 | §7.2 per v3-LEAN |
| **AC19** | **check_write 接口扩展签名**：`lib/quality-checker.sh::check_write` 必须接受以下 env-var 或参数（**不使用位置参数——避免空串歧义**）——`TAD_ROLE` (alex\|blake\|system)、`TAD_TOOL_NAME` (Write\|Edit\|MultiEdit\|NotebookEdit\|Bash)、`TAD_TARGET_FILE` (绝对路径 or null)、`TAD_CONTENT` (concatenated MultiEdit edits[].new_string OR Bash command)、`TAD_HANDOFF_SLUG`、`TAD_SESSION_ID`（nonce scope 必需）。**MultiEdit concat 层**：dispatcher 层负责 concat edits[].new_string with `\n`，lib 层只处理单一 content blob | `fixture-multiedit-split-sentinel.sh`：MultiEdit 将 sentinel 拆到两个 edit 中 → concat 后仍能 match → deny | §2.3 per v3-LEAN（签名扩展） |

### 3.1 AC Conflict Matrix 自检（Phase 1c 知识教训）

| # | 约束三元组 | 可同时满足？ | 解决方案 |
|---|----------|-----------|---------|
| C1 | AC1 脚本语法正确 × AC13 perf p95<100ms × AC14 10 fixture PASS | ✅ | 三者独立维度 |
| C2 | AC3 settings.json 注册 × AC4/5 SKILL 硬化 × AC10 protected path deny | ⚠️ | AC10 会 deny `.claude/skills/**/SKILL.md` 的 Write——Blake 首次编辑 SKILL 时**必须在 hook 安装前完成** AC4/5 的 SKILL 注入。**解决**：按 §4 硬顺序——先 3.A (SKILL) → 3.B (hook code) → 3.C (activate)；settings.json 本身的 write 在 3.C 时 hook 尚未 fully armed（secret.key 不存在）走 bootstrap allow |
| C3 | AC6 bootstrap 写 secret.key / LEAK_DETECTED × AC10 deny `.tad/state/**` | ⚠️ | bootstrap 由 hook 自己用 bash `>` 重定向执行，不走 Claude 的 Write tool，因此不经过 PreToolUse 拦截（hook 自写豁免）。**`path-guard.sh` 判定逻辑**：只检查 `tool_name` 是 Write-family 或 Bash 的 invocation，内部 shell 重定向不在拦截面 |
| C4 | AC11 OV-1 写 `nonces.jsonl` / `override-log.jsonl` × AC10 deny `.tad/state/**` | ⚠️ | 同 C3——`userprompt-override.sh` 内部写是 bash 重定向 |
| C5 | **AC17 gate verdict 写入** × AC10 HP-1 deny | ✅ | AC17 明确要求 `path-guard.sh::allowlist` 豁免 `.tad/evidence/gates/*/gate{2,3,4}-verdict.tsv`（append-only），解决 `/gate` skill + acceptance_protocol 的递归悖论 |
| C6 | **Post-activation SKILL recovery**：Layer 2 review 若在 3.E 发现 SKILL P0 → 需编辑 SKILL × hook 已 armed (HP-1 deny `.tad/skills/**/SKILL.md`) | ⚠️ → ✅ | **解决路径**：人类输入 `TAD_OVERRIDE: protected-path Blake Layer2 review revealed SKILL P0 must patch` → 获 one-shot nonce → 下一次 Write `.claude/skills/**/SKILL.md` allow。Blake 在 COMPLETION 中记录 override 使用 + reason。此路径**明确允许**，不被视为"逃生通道"（符合 Epic 决策 #3：override 是人类最后钥匙） |
| C7 | **Post-activation settings.json edit**：如需调 hook timeout 或 matcher × HP-1 deny `.claude/settings*.json` | ⚠️ → ✅ | 同 C6 路径：人类 `TAD_OVERRIDE: protected-path <reason>` → 允许单次 settings.json 编辑 + git commit 留审计 |
| C8 | AC15 dogfood × AC7 bootstrap exception × AC8 fully armed | ✅ | 这正是 dogfood 设计意图（本 handoff 是 first-run 触发 bootstrap） |
| C9 | **AC13 evidence-validator 100-120ms PARTIAL** × "所有 hook p95<100ms" 文字表述 | ✅ | AC13 已明确允许 evidence-validator PARTIAL-GO 100-120ms（per v3-LEAN §8 原文），超过 120ms 才 FAIL。无矛盾 |

**结论**：9 项交叉已识别；C2-C4 由 §4 phase 硬顺序 + hook 自写豁免解决；C5 由 AC17 allowlist 解决；C6-C7 由 OV-1 `gate=protected-path` 明确覆盖（Epic 决策 #3）；C1/C8/C9 天然兼容。**无需 PARTIAL-GO 保留项**。

---

## 4. Implementation Phases (执行顺序硬约束)

Blake 必须按以下顺序执行，**不可并行** AC4/5 与 AC3：

### Phase 3.A — SKILL 硬化（先做，hook 未启用前）
1. AC4：Alex SKILL.md 注入 `anti_rationalization_registry` + 3 处 anchor
2. AC5：Blake SKILL.md 注入 `honest_partial_protocol` + 3 处 anchor
3. 每次 Edit 前先 `git add -A && git commit` 留下可回滚锚点

### Phase 3.B — Hook 代码 + Schema（不启用）
4. AC2：写 3 个 YAML schema 到 `.tad/schemas/`
5. AC1：写 8 个 shell 脚本到 `.tad/hooks/` 及 `.tad/hooks/lib/`
6. 本阶段结束时 `.claude/settings.json` **还未更新**，hook 未生效——此时可自由调试

### Phase 3.C — 激活 hook（settings.json 写入即生效）
7. AC3：修改 `.claude/settings.json` 注册两个 hook（此次 Write 会被 Phase 1c 现有 Haiku prompt hook 过一遍；但本 handoff 的新 `quality-enforcement.sh` 还未注册，不会自己拦截自己）。**注册完成后，settings.json 成为 HP-1 protected path**——任何后续编辑**必须**走 OV-1 `gate=protected-path`（见 §3.1 C7），禁止未授权修改
8. AC6：启动新 `claude -p` session 触发 first-run bootstrap（必须按 AC6 原子顺序 a→b→c→d 产出 state dir + gitignore + secret.key + LEAK_DETECTED 扫描结果）
9. **activation verification**：跑 AC3 验证脚本——一条最小 prompt 走 claude -p，确认 hook 链无报错且 fail-closed AC16 纪律生效（`lib/dep-guard.sh` 不可用时 deny）

### Phase 3.D — Fixtures + Perf
9. AC7-AC12：10 个 fixture 全部通过
10. AC13：跑 CI workflow（可先本地 dry-run 验证，再 push 到 GitHub Actions 真 CI runner）
11. AC14：regression 套件全绿
12. AC15：Dogfood trace 产出

### Phase 3.E — Evidence + Review + Completion
13. 跑 Layer 2 expert review（code-reviewer + security-auditor，min 2，**AR-003：spike / infra handoff 不是 review-exempt**）
14. 写 COMPLETION-20260415-phase3-hooks-skill-impl.md（Overall: PASS/FAIL/PARTIAL-GO anchored）
15. 写 Message from Blake sentinel（此时 hook 已 fully armed，会校验 Blake evidence manifest）

---

## 5. 📚 Project Knowledge — Blake 必须注意的历史教训

以下 **15 条** 直接影响本 Phase 3 实现，全部来自 `.tad/project-knowledge/architecture.md` + `security.md`，Blake 实现前**逐条对照**：

### 5.1 Hook 基础设施

| # | 条目 | Why 相关 |
|---|------|---------|
| 1 | **Hook Path Matching: Glob Prefix Must Handle Relative Paths - 2026-04-02** | 所有 case 语句里的 hook path 匹配**必须用 `*.tad/` 而非 `*/.tad/`**，Claude Code 传递 relative path。`path-guard.sh` 和 `content-scanner.sh` 都受影响 |
| 2 | **Hook Shell Portability: No grep -P on macOS - 2026-04-03** | 所有脚本**禁用 `grep -P`**（BSD grep 无 Perl regex）。Lookbehind 用 `grep -o` + `sed`。`sentinel-detect.sh` 的 Unicode casefold 需用 `perl -CSD` |
| 3 | **Hook Performance: Single-awk vs Per-item grep Loop - 2026-04-07** | AC13 要 p95<100ms。**禁止** N×grep bash loop；必须用单次 `awk` 扫所有 keyword/pattern。`content-scanner.sh` 的 env-injection pattern match + `sentinel-detect.sh` 的 box-drawing detection 都属此范畴 |
| 4 | **Hook Latency Measurement: Never Use python3 for Per-Step Timing on macOS - 2026-04-14** | 性能测量**禁用 python3**（macOS ~130ms 启动）。用 `perl -MTime::HiRes=time`。CI bench 脚本要同时产出 instrumented 和 uninstrumented 两组数据 |
| 5 | **Hook Data Integrity: bash $() Strips \x00; jq @tsv Escapes Content Tabs - 2026-04-14** | 多路复用输出**禁用 `\x00` 分隔符**（bash $() 会吃掉），用 `\x1E` (RS)。jq 输出 content 字段**禁用 `@tsv`**（转义 tab），用 `join("\u001e")` raw mode |
| 6 | **`claude -p` Hook Contract Testing - 2026-04-14** | AC3/AC13 的 hook 注册验证**必须用** `echo "prompt" \| claude -p --settings /tmp/test-settings.json --permission-mode default --no-session-persistence --tools ''`。**禁用 `CLAUDE_CONFIG_DIR` 做隔离**（破坏认证）。**禁用 `bypassPermissions` 模式**（会绕过所有 deny） |
| 7 | **Claude Code Enforcement Priority: permissions.deny > hooks > allow - 2026-03-31** | `permissions.deny` 字段**不要**改——它会在 hook 之前生效，而本 Phase 3 的所有 deny 必须走 hook（有 override 机制）。保持 `"deny": []` |
| 8 | **UserPromptSubmit Hook Verified - 2026-04-07** | OV-1 用 `type: command`（非 `type: prompt`——后者是 permission gate only，不支持 additionalContext）。payload 6 字段含 `prompt`，用 `jq -r '.prompt'` 读，**不是 `$ARGUMENTS`** |

### 5.2 AC + Handoff 设计

| # | 条目 | Why 相关 |
|---|------|---------|
| 9 | **Alex Handoff AC Must Explicitly List ALL Required Evidence Files - 2026-04-14** | Required Evidence Manifest §1.4 本次已显式列出 7 类 evidence（expert_reviews / gate_verdicts / completion / blake_reviews / perf_evidence / fixture_results + dogfood-trace） |
| 10 | **Gate 4 Verification Integrity: Verify Files, Not Claims - 2026-04-14** | Alex Gate 4 时会 re-derive 关键数字（p95, fixture pass count），Blake 的 COMPLETION 必须引用 raw TSV 行号/值，不只是 summary |
| 11 | **Handoff Design Conflict: Byte-Preservation vs Optimization - 2026-04-14** | 本 handoff §3.1 已做 AC Conflict Matrix 自检；AC10 vs AC4/5 vs AC3 的执行顺序硬约束已在 §4 phases 明确 |
| 12 | **AC Precision: "≥N Triggers" vs "Specific List of N" - 2026-04-14** | 所有 AC 用 imperative list form（AC1/2/10 等），**不用** "≥N of these" |
| 13 | **Express Handoff is NOT Review-Exemption - 2026-04-14** (AR-001) | 本 handoff 不是 express，但 AR-003 "spike/infra = review-exempt" 同样适用：**Phase 3 是高风险 infra 变更，强制 ≥3 专家（code-reviewer + security-auditor + backend-architect）** |

### 5.3 Perf + Testing

| # | 条目 | Why 相关 |
|---|------|---------|
| 14 | **Perf Gate Measurement Requires Dedicated CI Runner - 2026-04-14** | Phase 1c 血泪教训：dev host 2-3x inflation。AC13 **必须**在 GitHub Actions 专用 runner 跑 N=100，不接受 dev host 数据作为最终 verdict |
| 15 | **Claude Code Sub-Agent Safety Classifier - 2026-04-14** | Phase 1b 血泪：security-auditor 对 red-team 措辞触发 Haiku classifier。Blake 写 security-auditor review prompt 时**必须用 blue-team framing**："defensive enforcement hook review" / "validator rejection coverage"，禁用 "adversarial / bypass / malicious" |

---

## 6. 🔧 Domain Pack References (Blake 必读)

**Loaded Packs** (from Epic decisions §9):

| Pack | File | Matched Capabilities |
|------|------|---------------------|
| ai-agent-architecture | `.tad/domains/ai-agent-architecture.yaml` | role_behavior_design, safety_design, self_improvement_design |
| ai-evaluation | `.tad/domains/ai-evaluation.yaml` | adversarial_testing, regression_testing |

**⚠️ Blake 必须在开始实现前 Read 这两个 YAML**。关键应用点：
- `safety_design` → §3 AC10 protected path 设计的反模式参考
- `regression_testing` → §3 AC14 10 fixture 结构参考
- `adversarial_testing` → 虽然 v3-LEAN 按 honest-but-lazy 威胁模型，但 fixture 设计仍可参考 pack 的反模式清单

---

## 7. Out of Scope (显式延迟)

本 Phase 3 **不做**（与 v3-LEAN §10.2 一致）：
- MCP tool coverage（无当前 TAD MCP write 面）
- External HMAC witnesses（`~/.claude/tad-chain-witnesses/`）
- TR39 confusables full mapping（v2 pipeline 4 步，v3-LEAN 简化为 2 步）
- Grapheme-based override reason rule（简化为 ≥20 非空白字符）
- Archive manifest cache（Phase 5 优化）
- Active concurrent-session detection（知识条目即可）
- SHA content-binding evidence freshness（mtime + 存在性足够）
- HMAC-chained log + `--re-verify` CLI（plain JSONL + chmod 600 足够）
- Semantic paraphrase sentinel detection（"a note authored by Blake"）

---

## 8. Gate 2: Design Completeness (Alex 填写)

**执行时间**：2026-04-15（本 handoff 创建时）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | v3-LEAN §1-9 完整覆盖 enforcement matrix + module layout + control flow + canonicalization |
| Components Specified | ✅ | 8 脚本 + 3 schema + 6 SKILL anchor + CI workflow 全部列清楚 |
| Functions Verified | ⚠️ | `lib/common.sh::read_stdin_json` 已存在 Phase 1c 验证；`lib/dep-guard.sh` 已存在 Phase 1c 交付。其余 6 个 lib 模块是 Phase 3 新建，按 v3-LEAN §2.1 接口设计 |
| Data Flow Mapped | ✅ | §2.2 control flow + §1.4 Gate verdict lifecycle + §6 override flow 全部图文对齐 |
| Acceptance Criteria Testable | ✅ | 15 AC 全部含 "验证方法" 列，evidence 落到具体文件 |
| AC Conflict Matrix | ✅ | §3.1 识别 5 个约束交叉，2 个通过 bootstrap exception 解决，3 个通过 Phase 执行顺序硬约束解决 |

**Gate 2 结果 (v1 draft)**：⚠️ CONDITIONAL PASS → **Gate 2 (v2 post-review)**：✅ PASS

**Alex 确认**：v3-LEAN 设计已冻结（commit `3dbc998`）；3 专家 17 P0 findings 全部整合为 13 distinct resolutions + 4 new ACs (AC16-19)；未整合 P1 已 documented in §9.2 trade-offs；Blake 可独立完成。Gate 2 verdict 写入 `.tad/evidence/gates/phase3-hooks-skill-impl/gate2-verdict.tsv`。

---

## 9. Expert Review Status

**Parallel expert review completed 2026-04-15**. Reports saved to `.tad/evidence/reviews/alex/phase3-hooks-skill-impl/`.

| Reviewer | Verdict (v1) | P0 Count | 整合状态 (v2) |
|----------|--------------|----------|--------------|
| code-reviewer | CONDITIONAL PASS | 8 (6 primary + 2 scope-gap) | ✅ 全部整合 |
| security-auditor | CONDITIONAL PASS | 4 | ✅ 全部整合 |
| backend-architect | CONDITIONAL PASS | 5 | ✅ 全部整合 |

### 9.1 P0 Resolution Map (17 findings → 13 distinct issues)

| # | Source | Issue | Resolution in v2 |
|---|--------|-------|-----------------|
| 1 | code-P0-1 | AC7 混淆 secret.key 边界与 slug-gate2-verdict | AC7 重写为仅测 bootstrap→armed 二元切换；manifest 检查归 AC8 |
| 2 | code-P0-2 | AC3×AC4/5×AC10 缺 post-activation SKILL recovery | §3.1 新增 C6/C7 显式用 OV-1 `gate=protected-path` 覆盖 |
| 3 | code-P0-3 | AC4/5 byte-exact diff 缺验证命令 + 参考提取 | AC4/5 新增 `diff -u <(yq ...) <(extract)` 命令；Required Evidence Manifest §1.4 新增 `skill_diff_evidence` 类别 |
| 4 | code-P0-4 | Manifest §1.4 缺 4 类（Knowledge Assessment / gate3 / KG-002 / dogfood-trace） | §1.4 已全部补齐（新增 gate3 / dogfood / knowledge_updates / skill_diff_evidence 四类） |
| 5 | code-P0-5 | Phase 3.C settings.json 自锁 | §4 Phase 3.C 步骤 7 加 "后续编辑必须走 OV-1" 声明 |
| 6 | code-P0-6 | AC13 "所有 hook p95<100ms" 比 §8 过严 | AC13 重写允许 evidence-validator 100-120ms PARTIAL-GO + 120ms+ FAIL（与 §8 对齐） |
| 7 | code-P0-scope-7 | Gate verdict writer 集成无 AC | 新增 **AC17**（path-guard allowlist + append-only 写入控制） |
| 8 | code-P0-scope-11 | KG-002 知识条目无 AC | 新增 **AC18**（写入 security.md） |
| 9 | sec-P0-1 | AC6 bootstrap 顺序不定 + LEAK_DETECTED 非持久 | AC6 重写：固定顺序 a→b→c→d + `(umask 077; openssl > tmp && mv)` 原子 + `LEAK_DETECTED` sentinel 文件 + 后续 Write 强 deny |
| 10 | sec-P0-2 | HP-2 env-injection 清单缺关键项（GIT_*, IFS, ENV, SHELLOPTS, PYTHONPATH, NODE_OPTIONS 等） | AC10 改为以 `protected-paths.yaml::env_injection_patterns` 为权威清单 + 列出 21 条完整 pattern + 覆盖 Write-family 和 Bash |
| 11 | sec-P0-3 | OV-2 未继承 §3 canonicalization 可被 `TAD\u200BOVERRIDE:` 绕过 | AC11 明确要求"先 canonicalize 再 literal match"，覆盖 MultiEdit.edits[] / NotebookEdit / Task.prompt / Bash.description 全面 |
| 12 | sec-P0-4 | Fail-closed 纪律未入 AC | 新增 **AC16**（source dep-guard + stdin timeout + 1MB cap + 未捕获异常 → deny + LEAK_DETECTED 检查） |
| 13 | arch-P0-1 | `check_write` 签名缺 session_id / tool_name + MultiEdit concat 层未定 | 新增 **AC19**（env-var 方式传递 6 字段 + dispatcher 层负责 MultiEdit concat） |
| 14 | arch-P0-2 | Gate verdict TSV 递归悖论 | 合并到 #7（AC17 解决） |
| 15 | arch-P0-3 | sentinel-detect perl 缺失 fail-closed 未定 | 合并到 #12（AC16 覆盖）|
| 16 | arch-P0-4 | Bootstrap 自写 invariant 非正式 | 合并到 #9（AC6 原子顺序已覆盖）|
| 17 | arch-P0-5 | p95 无 per-lib 分解 + short-circuit 未强制 | 合并到 #6（AC13 扩展包含 per-lib 分段 + dispatcher 顺序硬约束）|

**P1 吸收**（高杠杆项整合）：
- sec-P1-3 `touch` 加入 BW-3 pattern → AC9 已加 `touch`
- sec-P1-4 Haiku prompt hook 延迟税问题 → 延迟到 Phase 4 Dogfood 观察后再决定是否移除（不入 Phase 3 scope）
- arch-P1-1 `content-scanner.sh` vs `path-guard.sh` 职责 → AC9 已明确"target-path-based"归 `path-guard.sh` Bash 分支
- arch-P1-4 `lib/common.sh::get_json_field` grep-fallback → AC16.a 要求 jq 为硬依赖（dep-guard whitelist）

**P2 捕获在 fixture/AC wording 内**：AC15 dogfood trace 加 OV-2 negative case；AC14 fixtures 覆盖 `fixture-embedded-table-with-u2500.md` 等。

### 9.2 未整合 P1（documented trade-offs）

| # | 项 | 原因 | 未来计划 |
|---|----|-----|---------|
| P1-arch-3 | `.tad/schemas/**` 在 `*sync` 时的 ownership 模糊 | Phase 5 *sync 策略课题，非 Phase 3 必需 | Epic Phase 5 明确 |
| P1-sec-6 | Bootstrap exception window 无时间上限 | 单用户 CLI 威胁模型可接受；增加时间窗增加 bootstrap 失败率 | 知识条目记录，Phase 5 评估 |
| P2-all | canonicalization cache / state-io lib 抽取 / dogfood-trace schema / jq --slurpfile | 属 Phase 5 优化范畴 | Phase 5 backlog |

---

## 10. Important Notes

### 10.1 Dogfood Paradox 解决

本 handoff 自己的 Write 是 first-run：`.tad/state/secret.key` 尚未存在（Phase 3 还没装 hook），所以 hook 尚未激活——本 handoff Write 成功。激活后的 first session 会触发 bootstrap 生成 secret.key + gitignore 追加，本 handoff 的 acceptance（Alex Gate 4 写 gate4-verdict.tsv）成为 first "fully armed" 事件。

### 10.2 Bash write-path 豁免

Blake 自己在实现 hook 时需要写 `.tad/hooks/lib/*.sh`。这些 Write **不会**被 BW-3 拦截，因为 BW-3 只管 `.tad/evidence/**` 和 `.tad/active/handoffs/**`。但 HP-1 会拦截 `.tad/hooks/**` 和 `.tad/skills/**/SKILL.md`——**必须先完成 Phase 3.A (SKILL) 和 Phase 3.B (hook code)，再激活 Phase 3.C (settings.json)**，否则会自锁。

### 10.3 Sub-Agent 使用建议

- **code-reviewer**（强制）：focus on shell portability (AR knowledge #2 grep -P, #5 \x00), single-awk pattern (#3), perl timing (#4)
- **security-auditor**（强制）：focus on bootstrap gitignore race, AW-3 cross-role edit, OV-2 content-scan coverage, HP-2 env-injection list. **用 blue-team framing**（#15）
- **backend-architect**（强制）：focus on module boundaries `lib/*.sh`, shared `check_write` interface, control flow §2.2, failure modes on missing dep / timeout

### 10.4 Domain Pack Anti-Patterns（Blake 自查）

- ⚠️ [ai-agent-architecture → safety_design] 反模式："只用 prompt MANDATORY 无 hook 层强制 = 建议不是规则"——本 Phase 3 就是来根治这个反模式的，**禁止** 引入只靠 SKILL prose 的新约束
- ⚠️ [ai-evaluation → adversarial_testing] 反模式："只测快乐路径"——AC14 10 fixture 必须含 positive control + 边界（eszett casefold / ZWJ 穿插 / cp 重定向）

---

## 11. File Layout

```
.tad/
  hooks/
    quality-enforcement.sh             # NEW (AC1)
    userprompt-override.sh             # NEW (AC1)
    lib/
      common.sh                        # existing (Phase 1c)
      dep-guard.sh                     # existing (Phase 1c)
      quality-checker.sh               # NEW (AC1)
      sentinel-detect.sh               # NEW (AC1)
      path-guard.sh                    # NEW (AC1)
      content-scanner.sh               # NEW (AC1)
      evidence-validator.sh            # NEW (AC1, KG-001)
      override-verify.sh               # NEW (AC1)
  schemas/
    evidence-manifest.yaml             # NEW (AC2)
    sentinel-patterns.yaml             # NEW (AC2)
    protected-paths.yaml               # NEW (AC2)
  state/                               # NEW (AC6, .gitignored)
    .gitkeep                           # (dir marker; actual state files generated first-run)
  evidence/
    reviews/alex/phase3-hooks-skill-impl/
      code-reviewer.md                 # Alex expert review output
      security-auditor.md
      backend-architect.md
    reviews/blake/phase3-hooks-skill-impl/
      code-reviewer.md                 # Blake Layer 2 review output
      security-auditor.md
    gates/phase3-hooks-skill-impl/
      gate2-verdict.tsv                # Alex (step after this handoff created)
      gate3-verdict.tsv                # Blake (completion)
    designs/extracts/
      v2-section-4.1.1-anti-rationalization.yaml   # NEW (AC4 byte-exact reference)
      v2-section-4.2.1-honest-partial.yaml         # NEW (AC5 byte-exact reference)
    fixtures/phase3-hooks-skill-impl/
      run-all.sh
      fixture-*.sh (10 files)
      fixture-results.tsv
    perf/phase3-hooks-skill-impl/
      ci-bench-N100.tsv
      ci-env-manifest.json
    traces/phase3-hooks-skill-impl/
      dogfood-trace.jsonl

.claude/
  skills/
    alex/SKILL.md                      # MODIFIED (AC4) — anti_rationalization_registry + 3 anchors
    blake/SKILL.md                     # MODIFIED (AC5) — honest_partial_protocol + 3 anchors
  settings.json                        # MODIFIED (AC3) — 2 new hook registrations

.github/workflows/
  tad-perf-gate.yml                    # NEW (AC13)

.gitignore                             # MODIFIED (AC6) — append .tad/state/
```

---

## 12. Status

**Final Status**: ✅ **Expert Review Complete — Ready for Implementation**

- v1 draft (2026-04-15): 15 AC, 3 experts called in parallel
- Expert review returned 17 P0 findings (8 code + 4 security + 5 architecture) → 13 distinct issues
- v2 revision (2026-04-15): 19 AC (14 revised + 4 new AC16-19 + 1 original AC12 unchanged), all P0 integrated
- Gate 2 verdict: PASS (v2)

---

**Alex 签名**：设计已冻结，19 AC 封装完整，P0 全部整合，Gate 2 v2 PASS。Blake 可独立完成。
