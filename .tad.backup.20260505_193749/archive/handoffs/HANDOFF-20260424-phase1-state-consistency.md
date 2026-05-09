---
task_type: mixed
e2e_required: no
research_required: no
---

# Handoff: Phase 1 — State Consistency Mechanical Checks

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2) | **Date:** 2026-04-24
**Epic:** `.tad/active/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md` (Phase 1/6)
**Evidence Reference:** `.tad/evidence/learnings/HARVEST-20260424-cross-project.md`
**Priority:** P0
**Status:** Ready for Implementation (post expert review v2)
**Type:** Standard TAD (Phase handoff; not Express)

---

## 1. Executive Summary

本 handoff 为 Epic Phase 1——"装烟雾报警器"。根据 4 个消费者项目（menu-snap / my-openclaw-agents / toy / Next Guest）踩过的实际坑，给 TAD 工具层加 **5 个 localized 机械检查**，全部是 **smoke alarm**（响但不灭火），避开 2026-04-15 Epic 1 被取消时那种 fail-closed 锁死风险。

**不做什么：** 不加任何阻止 Claude 行为的 PreToolUse 硬拦截；不改 `.claude/settings.json` 的 behavior hooks；不做 fail-closed default。

**做什么：** 5 个任务（P1.1 ~ P1.5），全是文件系统状态一致性检查 + 自检工具升级 + 模板标准化。

---

## 2. Epic Context

Epic Phase Map（共 6 phase）:
1. **State Consistency** (此 handoff)
2. Grounding & Anti-Stale-Knowledge
3. New Paths (*express / *experiment)
4. Domain Pack Expansion
5. Evolve Data Capture Infrastructure
6. Assumption Re-Design (v3 candidate)

此 Phase 独立，不依赖其他 Phase 产出；做完不阻塞后续任何 Phase。

---

## 3. Task Breakdown

### Task P1.1 — Blake Gate 3 self-check: `git ls-files` 断言

**问题**（toy `architecture.md` 2026-04-22）: 38 个 production 代码文件 weeks of work 差点没 commit 就 ship。Blake 当时的 Gate 3 self-check 不检查 git 追踪状态。

**设计决策**（Socratic 已定）: Alex 在 handoff frontmatter 加 `git_tracked_dirs: [dir1, dir2]` 字段。Blake Gate 3 读这个字段并检查。**文档/配置类 handoff 可以留空该字段或整个省略，这种情况下 Blake 跳过此检查**。

**Blake 改动：**
1. `.claude/skills/blake/SKILL.md` — Gate 3 v2 Layer 1 self-check 段落加一行检查：
   ```
   If handoff frontmatter has git_tracked_dirs[]:
     for each dir in git_tracked_dirs:
       if ! git ls-files "$dir" | grep -q .: FAIL "Dir {dir} has no git-tracked files"
   Failure mode: collect all dir failures, report together (not short-circuit on first).
   ```
2. `.tad/templates/handoff-a-to-b.md` — frontmatter 示例加 `git_tracked_dirs` optional field + 1 句说明（用于 Gate 3 git-tracked 检查，文档类 handoff 可留空）

**AC:**
- [ ] AC-P1.1-a: 一个 frontmatter 声明了 `git_tracked_dirs: ["src/pages"]` 且 src/pages 实际被 git 追踪的 fixture → Gate 3 PASS
- [ ] AC-P1.1-b: 一个 frontmatter 声明了 `git_tracked_dirs: ["src/pages"]` 但 src/pages 下所有文件都 untracked 的 fixture → Gate 3 FAIL
- [ ] AC-P1.1-c: 一个没有 git_tracked_dirs 字段的 handoff → Gate 3 照常通过（跳过此检查，不 FAIL）**← backward compat**
- [ ] AC-P1.1-d: git 不可用（不在 git repo）时 → 错误信息清晰，不 crash
- [ ] AC-P1.1-e: `git_tracked_dirs: []` 空数组 → 等同未声明，skip with warn，不 FAIL (edge case per CR-P1-2)
- [ ] AC-P1.1-f: 声明的 dir 不存在于磁盘 → 输出 WARN (dir not found)，不 FAIL（避免暂时删除目录就卡 Gate 3）
- [ ] AC-P1.1-g: dir 存在但被 .gitignore 覆盖（`git ls-files` 合法返回空）→ 输出 WARN 清楚区分"被 ignore"vs"真 untracked"
- [ ] AC-P1.1-h: `git_tracked_dirs` YAML 类型错（是字符串而非数组）→ 清晰错误信息，不 crash；建议 Alex fix frontmatter

**实现提示：**
- `git ls-files` 不需要工作树干净也能跑
- 用 `git rev-parse --is-inside-work-tree 2>/dev/null` 先探测 repo
- Don't use `git status --porcelain`（那是检查未 commit 变更，不是 untracked files in git index）
- 区分 .gitignore vs untracked：`git check-ignore <dir>` 若返回匹配 → ignored，WARN 而非 FAIL

---

### Task P1.2 — `/tad-maintain` CHECK 扩展为 drift detector（4 subcheck 打包）

**问题**: 4 种 handoff 生命周期 drift 模式目前靠人工发现。实际案例：menu-snap 的 zombie handoff (code-quality.md:36)，toy layer2-audit 两次 FN (2026-04-23)，Next Guest 3 个同一天 supersede 的 handoff 堆在 active/ 10+ 天，toy 3 个 housekeeping handoff cite stale state。

**设计决策**（Socratic 已定）: **4 个 subcheck 一次性在此 handoff 打包实现。** Supersedes detection 产出**建议**（不自动 mv），人工确认后归档——符合 /tad-maintain 既有 CHECK（建议）/SYNC（应用）双模式。

#### Subcheck Contract (BA-P0-2 要求)

```yaml
each_subcheck:
  signature: "check_{name}(active_handoffs_snapshot_array) → stdout JSON"
  output_format:
    per_handoff: '{"subcheck": "slug_consistency", "handoff": "NAME", "status": "ok|drift|info", "message": "...", "suggested_action": "..."}'
  shared_state:
    active_handoffs_snapshot: "ONCE-read at CHECK entry, passed as arg to each subcheck"
    no_live_refresh: "subcheck 不重新读 active/；避免与 Alex 正在写 handoff 的 race"
  execution_order: "serial a → b → c → d (deterministic output ordering)"
  findings_semantics: "additive — 一个 handoff 可触发多个 subcheck（zombie AND supersedes-tail 可共存）"
  concurrency_note: "CHECK mode advisory; snapshot 可能 <1s stale；用户发现异常可立即重跑"
  failure_isolation: "任一 subcheck 抛异常 → 其他 subcheck 继续；输出中 failed subcheck 标记 ERROR 状态"
  observability: "每个 subcheck 决定前 emit 1-line stderr: [drift-check] {subcheck} {handoff} {status}"
public_interface:
  drift-check.sh:
    - "drift-check.sh check-all              # run all 4 serially"
    - "drift-check.sh check slug_consistency # run single subcheck"
    - "drift-check.sh --help                 # usage"
  exit_code:
    0: "any drift found (non-zero count in stdout)"
    0: "or no drift (clean)"
    1: "internal error (not drift)"
  note: "不用 exit code 表示 drift yes/no — 用 stdout JSON lines；exit 1 专用于 internal error"
```

**Blake 改动：**

1. `.claude/skills/tad-maintain/SKILL.md` — CHECK mode 加 "Drift Detection" 子流程，含 4 subcheck。
2. 新增 `.tad/hooks/lib/drift-check.sh` — 实现 4 subcheck 的独立工具。
3. 每个 subcheck 独立成一个函数 (`check_slug_consistency`, `check_zombie_handoffs`, `check_supersedes_chains`, `check_ghost_tasks`)，可单独调用。
4. 新增配置文件 `.tad/config-workflow.yaml` 的 `drift_check:` 块（见各 subcheck 说明），避免常量硬编码在 shell 里（BA-P2-1）。

**Subcheck P1.2.a — slug 一致性**
- 逻辑: 对每个 active handoff (`.tad/active/handoffs/HANDOFF-*.md`)：
  1. 提取 handoff filename slug (从 HANDOFF-{date}-{slug}.md 里解析)
  2. 如果 handoff 有 `## Required Evidence Manifest` section (YAML code block)，parse 其中的路径
  3. 对每个路径，grep 是否包含 handoff slug
  4. 不一致 → status=drift，message="Handoff {name} slug '{slug}' 在 Manifest path '{path}' 中找不到"
- **Backward compat（CR-P1-4 + BA-P0-3 合并）**：没有 `## Required Evidence Manifest` section 的 handoff（pre-Phase-1 convention）→ status=info（**NOT drift**），message="{name}: pre-manifest-era, slug check skipped"。INFO 行在 CHECK 输出中**单独分组**，不混入 drift findings。这保证本 Phase 1 刚 ship 时不会被旧 handoff 淹没。

**Subcheck P1.2.b — zombie handoff 检测**
- 逻辑: 对每个 active handoff：
  1. 提取 slug
  2. **Word-boundary search（CR-P0-2 修正）**: `git log --grep "\b${slug}\b" -E --since="${zombie_window_days} days ago" --format="%H %s"`（其中 zombie_window_days 默认 60，从 config-workflow.yaml 读，BA-P2-2）
  3. **Secondary check（CR-P0-2）**: `ls .tad/archive/handoffs/COMPLETION-*${slug}*.md 2>/dev/null` 是否存在对应的 completion report
  4. 判定：
     - git commit 有 + COMPLETION 已在 archive + handoff 还在 active → status=drift (**真 zombie**)，suggested_action="retrospective *accept"
     - git commit 有 + 无 COMPLETION + handoff 还在 active → status=info，message="commit detected but no COMPLETION report — check if work truly done"（不是 zombie，可能半完成）
     - 都没有 → status=ok
- **边界**: `git log --grep` 默认 case-sensitive，用 `-i` flag 启用不区分大小写；然后 `-E` + `\b` 实现 word boundary。

**Subcheck P1.2.c — Supersedes 链检测**
- 逻辑: 对每个 active handoff：
  1. **Regex fix（CR-P0-1）**: grep 两种格式：`grep -E '^(\*\*)?Supersedes(\*\*)?:'`
     - 支持 plain: `Supersedes: HANDOFF-xxx`
     - 支持 bold markdown: `**Supersedes:** HANDOFF-xxx`
     - 支持带 `.md` 后缀 + 链接 / 不带
  2. Extract supersedee handoff name via loose regex `HANDOFF-\d{8}-[a-z0-9-]+(\.md)?`
  3. 如果 supersedee 仍在 `.tad/active/handoffs/` → status=drift，suggested_action="archive {supersedee_name}"
  4. **不自动 mv**。CHECK 模式只输出建议，用户 review 后手动或用 SYNC 应用。
- **新 fixture（CR-P0-1）**: 加 2 个真实 archive 样本（grep 确认其中有 Supersedes 字段的 handoff）作为 fixture，证明 regex 能匹配到。
- **Template 配合（CR-P0-1）**: P1.5 handoff template 在 "## Metadata" section 加入可选 `**Supersedes:** HANDOFF-xxx` 字段说明，让约定外显。

**Subcheck P1.2.d — Ghost task 预检**
- **配置化（BA-P2-1）**: Ghost task prefix list 存在 `.tad/config-workflow.yaml` 的 `drift_check.ghost_task_prefixes: [housekeeping, sync, rsync, cleanup, maintenance, audit, refresh]`，非硬编码。
- 逻辑: 对每个 active handoff 的 slug 做正则匹配 `^(prefix1|prefix2|...)-`（从 config 加载）：
  1. 如果匹配，检查 handoff 是否有 `grounded_state:` frontmatter field
  2. 没有 → status=drift，message="Housekeeping handoff {name} 缺少 grounded_state 字段，建议 Alex 在 step0_5 读取实际 repo 状态后再写 handoff"
- **边界**: prefix list 通过 config 可扩展，不改 shell

**AC:**
- [ ] AC-P1.2-a: 4 个 subcheck 函数各有独立单元测试 (fixture handoffs)
- [ ] AC-P1.2-b: `tad-maintain CHECK` 命令输出按 subcheck 分组的报告
- [ ] AC-P1.2-c: 对一个干净的 active/ 目录 → 全部 PASS、输出"No drift detected"
- [ ] AC-P1.2-d: 对构造的 4 种 drift 的 fixture → 对应 subcheck 输出明确报告
- [ ] AC-P1.2-e: Supersedes detection 输出的是"建议归档"不是实际 mv
- [ ] AC-P1.2-f: drift-check.sh 可以单独调用（不依赖整个 tad-maintain 流程），便于 hook 集成或 CI 用；含 `--help` 输出
- [ ] AC-P1.2-g: **Backward compat**（BA-P0-3 / CR-P1-4）—— 对 `.tad/archive/handoffs/` 中随机采样 5 个 pre-Phase-1 的旧 handoff 跑 P1.2.a → 全部输出 `status: info` 的 pre-manifest-era 行，不进 drift summary
- [ ] AC-P1.2-h: **False positive 防御**（CR-P0-2）—— Fixture handoff slug `auth`，构造 git log 含 `post-auth` 和 `pre-auth` 的 commits（都不是 auth handoff 的实现）→ P1.2.b 不标 auth 为 zombie
- [ ] AC-P1.2-i: **Portability**（CR-P0-3）—— drift-check.sh 通过 shellcheck 检查；只用 `grep -E` / `grep -F` / `grep -i` / `sed`；无 `grep -P`；无 `grep -oP`；无 `gdate`；无 `EPOCHREALTIME`
- [ ] AC-P1.2-j: **Supersedes regex 真实数据**（CR-P0-1）—— 对 archive 中至少 2 个真实含 Supersedes 字段（含 `**Supersedes:**` 粗体和 `Supersedes:` 平文本两种）的 handoff fixture → P1.2.c 全部识别到
- [ ] AC-P1.2-k: **失败隔离**（BA-P1-3）—— 构造 git 不可用场景 → P1.2.b 单独报 ERROR，但 P1.2.a/c/d 继续正常输出
- [ ] AC-P1.2-l: **Observability**（BA-P1-3）—— 每个 subcheck 决定前写入 stderr 1 行 status；可通过 `2>&1 | grep "[drift-check]"` 验证

---

### Task P1.3 — `layer2-audit.sh` slug 宽松化

**问题**（toy 2026-04-23）: `loop-mpr121-da7280` vs 实际 evidence dir `loop-mpr121-da7280-integration` 导致严格 slug 匹配 false-negative。2026-04-15 刚 ship 的 layer2-audit 在 8 天内命中此 bug 2 次。

**Blake 改动：**
`.tad/hooks/lib/layer2-audit.sh` — 添加 slug truncation fallback：

```
if ! ls .tad/evidence/reviews/blake/$slug/ 2>/dev/null | grep -q .; then
  # Pre-check single-segment slug (CR-P1-3) — e.g., slug="foo" truncates to itself
  slug_try1="${slug%-*}"
  if [ "$slug_try1" = "$slug" ] || [ -z "$slug_try1" ]; then
    # Single-segment OR empty truncation — skip fallback, continue with exit 1
    true  # fall through to original FAIL
  elif ls .tad/evidence/reviews/blake/$slug_try1/ 2>/dev/null | grep -q .; then
    echo "⚠️ Exact slug '$slug' not found; matched truncated '$slug_try1' — consider canonicalizing slug." >&2
    slug="$slug_try1"
  else
    # Try truncation variant 2: drop last 2 segments
    slug_try2="${slug_try1%-*}"
    if [ -n "$slug_try2" ] && [ "$slug_try2" != "$slug_try1" ] && ls .tad/evidence/reviews/blake/$slug_try2/ 2>/dev/null | grep -q .; then
      echo "⚠️ Exact slug '$slug' not found; matched doubly-truncated '$slug_try2'" >&2
      slug="$slug_try2"
    fi
    # else continue with original slug (will FAIL later naturally)
  fi
fi
```

**AC:**
- [ ] AC-P1.3-a: 原有严格匹配 fixture 继续 PASS (no regression)
- [ ] AC-P1.3-b: 新 fixture `loop-mpr121-da7280-integration` 在 evidence dir 为 `loop-mpr121-da7280` 时能匹配到（warn 但不 FAIL）
- [ ] AC-P1.3-c: 完全不存在的 slug（truncation 也找不到）→ 按原有逻辑 exit 1（报告 missing reviewer artifacts）
- [ ] AC-P1.3-d: Truncation 匹配时 stderr 输出 warn 告知用户 slug 不精确
- [ ] AC-P1.3-e: **单段 slug**（CR-P1-3）—— fixture slug=`foo`（无 `-`），truncation fallback 跳过（`${foo%-*}` 不变），按原有 FAIL 逻辑退出，不死循环

**实现提示：**
- 上限 2 次截断（防止奇怪 edge case 比如 `a-b` 截到空串）
- 截断后的候选若等于原 slug 或为空 → skip 该次 truncation attempt
- 3 次截断为未来扩展（BA-P2 建议 `-v2` 长 slug），当前 2 次够用

---

### Task P1.4 — `userprompt-domain-router.sh` 修 false positive（scope 精简：仅事件过滤，不动阈值）

**问题**（本 session 内 dogfood 2 次复现）: hook 在 system 注入的 `<task-notification>` 内容上也跑 keyword matching，弱匹配（1-2/14）也提示。2 次误报：首次 Vercel → web-deployment；刚才 ai-tool-integration 命中 1/12。

**关键 scope 修正（BA-P0-1）**: 原草案说"`MATCH_THRESHOLD=2` → `3`"——事实不符：
- 不存在全局 `MATCH_THRESHOLD` 环境变量；阈值是**每个 pack 在 `keywords.yaml` 里有自己的 `threshold` 字段**
- **当前所有 20 个 pack 的 `threshold: 1`**（2026-04-07 Phase 2b 故意选择"阈值 1 + 关键词严格 unique"换 30-case 100% accuracy）
- 全局升到 3 会破坏 100% 准确率

**决策（Decision #5 in §11）**: **Descope 阈值调整，只做事件过滤**。本次 dogfood 2 次误报都是在 **system-injected content**（task-notification / system-reminder）上触发，**不是真 user prompt**。事件过滤从根源切掉假阳性，不动 keyword accuracy baseline。如果过滤后仍观察到真用户 prompt 的假阳性，再做 per-pack 阈值分析（下个 Phase）。

**设计决策**（Socratic + BA-P0-1）: 检查 stdin JSON envelope 里 prompt 字段是否含 `<task-notification>` / `<system-reminder>` / `<function_results>` tag 黑名单。不修改任何 threshold。

**Blake 改动：**
`.tad/hooks/userprompt-domain-router.sh`:

**精确插入点（CR-P0-4）**: 现有 hook line 63-67 已经有 `USER_MSG=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' ...)`。**在 line 63-67 之后、sed-trim 之前**插入以下 check：

```sh
# Phase 1 P1.4: skip system-injected prompts (task-notification / system-reminder / function_results)
# These are hook events from Claude Code harness, not real user prompts.
# Evidence: 2026-04-24 session 2x false positives (web-deployment 2/14 + ai-tool-integration 1/12)
if printf '%s' "$USER_MSG" | grep -qE '<task-notification>|<system-reminder>|<function_results>'; then
  exit 0
fi
```

**重要**：
- 用 `printf '%s'` 不用 `echo`（CR-P0-4，避免 backslash 解释问题）
- 复用现有 `$USER_MSG` 变量，**不加第二次 jq 调用**（CR-P0-4，perf 保留）
- 保持现有 `// empty` default，**不改为 `// ""`**（CR-P0-4，避免语义变化破坏后续 `[ -z "$USER_MSG" ] && exit 0` 分支）

**决策：不改 threshold**（BA-P0-1 + Decision #5）。`keywords.yaml` 中所有 pack `threshold: 1` 维持不变。

**AC:**
- [ ] AC-P1.4-a: Fixture 1: 真实 user prompt "帮我添加一个部署到 Vercel 的流程" → hook 仍触发（web-deployment 命中）→ 正常行为（阈值未变）
- [ ] AC-P1.4-b: Fixture 2: `<task-notification>...mentions Vercel...</task-notification>` 作为 prompt → hook **不触发**（过滤生效）
- [ ] AC-P1.4-c: Fixture 3: `<system-reminder>...</system-reminder>` 作为 prompt → hook **不触发**
- [ ] AC-P1.4-d: Fixture 4: `<function_results>...</function_results>` 作为 prompt → hook **不触发**
- [ ] AC-P1.4-e: **本 session dogfood fixture**: 截取本 session 真实触发的 `ai-tool-integration` 假阳性 task-notification 内容作为 fixture → hook **不触发**
- [ ] AC-P1.4-f: **Regression**（BA-P1-5）—— 对 2026-04-07 Phase 2b 的 30-case test set 跑全套 → accuracy 保持 100%（因为 keyword 阈值和字典都没动）
- [ ] AC-P1.4-g: Latency 保持 <200ms p95（现有 81ms 基线，加一行 grep 不显著退化）
- [ ] AC-P1.4-h: **Edge case**（BA-P1-4）—— 用户 prompt 本身含 `<task-notification>` 字面字符串（比如"我想问这个 `<task-notification>` tag 什么意思"）→ hook **不触发**（按设计 silent skip，advisory-only，可接受）。Decision 记在 §11 #7。

**实现提示：**
- 参考 knowledge: "Hook Performance: Single-awk vs Per-item grep Loop" (2026-04-07) — 不要破坏现有 single-awk 优化
- 参考 knowledge: "Hook Data Integrity: bash $() Strips \x00" (2026-04-14) — jq 输出处理注意分隔符
- 用 `claude -p --settings <test-settings.json> --permission-mode default --no-session-persistence --tools '' "prompt"` 做契约测试（参考 knowledge 2026-04-14 "claude -p Hook Contract Testing"）
- **不要用 `CLAUDE_CONFIG_DIR`** 做隔离（2026-04-14 knowledge：会破坏 auth）

---

### Task P1.5 — handoff template 加 Expert Review Audit Trail 4-列表格 + Supersedes 字段约定

**问题**: toy 项目的 handoffs 自发演化出 4 列表格（reviewer / issue / resolution-section / status），比自由文本更可审计。但 `.tad/templates/handoff-a-to-b.md` 当前还是自由文本格式。另外（CR-P0-1 延伸）: template 当前**没有 Supersedes 字段**，导致 P1.2.c 即使 regex 正确也可能因作者没采用约定而失效。

**Blake 改动：**

1. `.tad/templates/handoff-a-to-b.md` — 在 "## Expert Review Status" section 加入默认 Audit Trail 表格：

```markdown
## Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | _(e.g., "P0: shell 脚本未处理 empty array edge case")_ | _(e.g., "§Task P1.2 实现提示 #3")_ | Resolved / Open / Deferred |
| backend-architect | ... | ... | ... |

### Expert Prompts Used (reference)
<!-- 可选: 记录专家 review 的完整 prompt，便于重现 -->
```

2. `.tad/templates/handoff-a-to-b.md` — 在 header metadata section 加可选字段：

```markdown
**Supersedes:** HANDOFF-YYYYMMDD-{slug}.md <!-- optional — cite previous handoff if this one supersedes -->
```

3. `.claude/skills/alex/SKILL.md` 的 `handoff_creation_protocol.step4 Feedback Integration` 段落加一条：
> "将每个专家反馈 integrate 为 Audit Trail 表格一行，status 字段必填（Resolved / Open / Deferred）。Resolved 必须指向 handoff 中的 resolution section（e.g., '§Task P1.2 实现提示 #3'）。"

**AC:**
- [ ] AC-P1.5-a: 模板 `handoff-a-to-b.md` 含新 Audit Trail section
- [ ] AC-P1.5-b: 模板 metadata 含可选 `**Supersedes:**` 字段说明（CR-P0-1 延伸）
- [ ] AC-P1.5-c: Alex SKILL 的 step4 描述更新，强制 integrate 为表格而非自由文本
- [ ] AC-P1.5-d: **Dogfood**—— 本 handoff（phase1-state-consistency）的 Expert Review Status section 使用新表格格式（dogfood，见 §10）

---

## 4. Acceptance Criteria Summary

总共 **33 个 AC**（P1.1: 8 + P1.2: 12 + P1.3: 5 + P1.4: 8 + P1.5: 4）。Blake Gate 3 v2 必须逐条 PASS。

All ACs must be verified through:
- Shell fixture tests (mechanical — unit test per subcheck function)
- Regression testing against existing fixtures (P1.3 / P1.4 Phase 2b 30-case)
- Self-dogfooding (P1.5 applies to this very handoff)

---

## 5. Required Evidence Manifest

Blake 必须产出以下 evidence 文件（未产出 → Gate 3 FAIL）：

```yaml
required_evidence:
  completion_report:
    path: .tad/active/handoffs/COMPLETION-20260424-phase1-state-consistency.md
    required: true

  expert_reviews:
    - path: .tad/evidence/reviews/alex/phase1-state-consistency/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/alex/phase1-state-consistency/backend-architect.md
      required: true

  review_feedback_integration:
    - path: .tad/evidence/reviews/alex/phase1-state-consistency/feedback-integration.md
      description: "Alex 对两份 review 的 P0/P1 integration trail (per CR-P2-1)"
      required: true

  gate_verdicts:
    - path: .tad/evidence/completions/phase1-state-consistency/GATE3-REPORT.md
      required: true

  blake_reviews:
    - path: .tad/evidence/reviews/blake/phase1-state-consistency/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/blake/phase1-state-consistency/self-review.md
      required: true

  blake_review_feedback:
    - path: .tad/evidence/reviews/blake/phase1-state-consistency/feedback-integration.md
      description: "Blake 对 Gate 3 Layer 2 feedback 的 integration trail"
      required: true

  fixture_results:
    - path: .tad/evidence/completions/phase1-state-consistency/fixtures/
      description: "每个 subcheck 的 fixture 输出 (至少 P1.2 4 subcheck × 多场景 + P1.3 truncation + P1.4 router filter + P1.4 dogfood fixture from this session)"
      required: true
      minimum_fixtures:
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/slug-mismatch.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/zombie.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/supersedes-bold.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/supersedes-plain.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/ghost.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/pre-manifest-era.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/drift/false-positive-short-slug.md
        - .tad/evidence/completions/phase1-state-consistency/fixtures/p1.4/task-notification-vercel.txt
        - .tad/evidence/completions/phase1-state-consistency/fixtures/p1.4/task-notification-aitool.txt
        - .tad/evidence/completions/phase1-state-consistency/fixtures/p1.4/real-user-vercel.txt

  perf_evidence:
    - path: .tad/evidence/completions/phase1-state-consistency/perf-P1.4-router.tsv
      description: "userprompt-router hook latency p50/p95/p99 at N≥30 (use perl -MTime::HiRes=time per 2026-04-14 knowledge)"
      required: true

  anti_epic1_compliance:
    - path: .tad/evidence/completions/phase1-state-consistency/anti-epic1-grep.txt
      description: "(BA-P1-1) mechanical grep check: `grep -rE 'PreToolUse|permissions\\.deny|exit 2|fail-closed' .claude/settings.json .tad/hooks/*.sh` — 产出应与 main 分支 baseline 一致 (no new hits)"
      required: true

  dogfood:
    - path: .tad/evidence/completions/phase1-state-consistency/dogfood.md
      description: "证明 P1.5 新模板格式在本 handoff 自身使用（本 handoff §10 的 Audit Trail diff）"
      required: true

  knowledge_updates:
    - path: .tad/project-knowledge/architecture.md
      description: "新 entries: 至少 2 条关于 Phase 1 过程中发现的 TAD 机制、shell portability、或 drift detection pattern"
      required: true
```

---

## 6. Files to Modify / Create

**修改：**
- `.claude/skills/blake/SKILL.md` (Gate 3 check, ~25 lines addition including failure collection + ignore-aware logic)
- `.claude/skills/alex/SKILL.md` (step4 Audit Trail requirement, ~5 lines)
- `.claude/skills/tad-maintain/SKILL.md` (Drift Detection section, ~40 lines)
- `.tad/templates/handoff-a-to-b.md` (frontmatter git_tracked_dirs + Supersedes field + Audit Trail section, ~35 lines)
- `.tad/hooks/lib/layer2-audit.sh` (slug truncation fallback, ~20 lines including single-segment skip)
- `.tad/hooks/userprompt-domain-router.sh` (event filter only, ~6 lines)
- `.tad/config-workflow.yaml` (new `drift_check:` section with ghost_task_prefixes + zombie_window_days, ~10 lines)

**新建：**
- `.tad/hooks/lib/drift-check.sh` (~250-300 lines estimated, up from 150-200 per CR-P1-1; 4 subcheck functions + shared helpers + argparse + --help)
  - **Escalate to Alex if >400 lines** — 可能意味着 scope 蔓延，需要 subcheck 独立 Phase
- `.tad/evidence/completions/phase1-state-consistency/fixtures/**` (see §5 manifest list)

---

## 7. Testing Checklist

- [ ] Unit test: 每个 drift subcheck 函数在 fixture 上独立跑通
- [ ] Unit test: layer2-audit truncation fallback 5 case (exact / 1-trunc / 2-trunc / not-found / single-segment)
- [ ] Unit test: userprompt-router filter 4 case (user prompt match / task-notification skip / system-reminder skip / function_results skip)
- [ ] Integration test: `/tad-maintain` CHECK 在一个构造的测试 active/ 目录（含 4 种 drift + 1 个 pre-manifest-era）上跑通
- [ ] Regression test: P1.4 对 2026-04-07 Phase 2b 的 30-case test set 保持 accuracy **100%**（keywords 和 threshold 都没动）
- [ ] Perf test: P1.4 router hook N≥30 runs, p95 < 200ms
- [ ] Dogfood: P1.5 新 Audit Trail format 用在本 handoff §10
- [ ] **Anti-Epic-1 mechanical check（BA-P1-1）**: `grep -rE 'PreToolUse|permissions\.deny|exit 2|fail-closed' .claude/settings.json .tad/hooks/*.sh` diff vs main → 0 new matches
- [ ] **False positive fixture（CR-P0-2）**: P1.2.b 对 fixture slug=`auth` + git log 含 `post-auth/pre-auth` → 不误标 zombie
- [ ] **Portability**（CR-P0-3）: shellcheck drift-check.sh → zero violations; drift-check.sh 在纯 macOS BSD (无 brew GNU coreutils) 上跑通

---

## 8. Blake Instructions

- 这是 **Standard TAD Phase handoff**，不是 Express。需完整走 Ralph Loop Layer 1 + Layer 2 专家审查 + Gate 3 v2。
- 5 个 task 互相**独立**——可串行做也可并行（Git worktree 非必要）。建议顺序：P1.3 (layer2-audit，最小) → P1.4 (router，已知 bug) → P1.1 (Gate 3 check) → P1.5 (template) → P1.2 (drift-check.sh 最复杂)。最简单的先做积累 context。
- **严格 fail-closed 陷阱警告**: 本 Phase 所有检查都是 **smoke alarm（响但不阻塞）**。不要引入 fail-closed default、PreToolUse 硬拦截、settings.json 行为 hook 改动——会重蹈 Epic 1 取消的覆辙（2026-04-15 教训，详见 project-knowledge/architecture.md 末尾条目）。**且产出 anti-epic1-grep.txt 作为机械证据**（BA-P1-1）。
- `/tad-maintain` 和 `layer2-audit.sh` 本身已经是监督层设计，加 drift detection 扩展的是报告范围，不是 enforcement power。
- **macOS BSD 优先（CR-P0-3）**: 所有 shell 代码在纯 macOS（不依赖 brew GNU coreutils）上跑通。无 `grep -P`、无 `gdate`、无 `EPOCHREALTIME`、无 `awk gensub()`（gawk 扩展）。用 `perl -MTime::HiRes=time` 做 timing（2026-04-14 knowledge）。
- 如果发现 P1.2 drift-check.sh 的某个 subcheck 实现超预期（>400 行 or 外部依赖），**escalate to Alex**，不要硬做或偷偷降范围。
- **Regression 优先**: P1.4 改动极小（~6 行 grep filter），但 regression 测试必须跑完——2026-04-07 Phase 2b 100% accuracy 是 load-bearing 数据，不能退化。

---

## 9. Project Knowledge — Blake 必读的历史教训

以下 entries 跟 Phase 1 直接相关，Blake 实现前必须读 `.tad/project-knowledge/architecture.md` 里的这几条：

| 教训 | 文件 | 与此 Phase 的关系 |
|------|------|-------------------|
| Hook Shell Portability: No grep -P on macOS (2026-04-03) | architecture.md | P1.2 / P1.3 / P1.4 都是 shell，grep -P 不可用；用 grep -E 或 sed |
| Hook Performance: Single-awk vs Per-item grep Loop (2026-04-07) | architecture.md | P1.4 不能破坏现有 single-awk 优化 |
| Hook Data Integrity: bash $() Strips \x00; jq @tsv Escapes Tabs (2026-04-14) | architecture.md | P1.4 jq 输出处理注意分隔符；不要用 \x00 |
| Hook Latency Measurement: Never Use python3 for Per-Step Timing (2026-04-14) | architecture.md | P1.4 perf 测量用 perl -MTime::HiRes=time |
| Hook Path Matching: Glob Prefix Must Handle Relative Paths (2026-04-02) | architecture.md | P1.4 stdin parsing 如需匹配 handoff 路径 pattern 注意 |
| Alex Handoff AC Must Explicitly List ALL Required Evidence Files (2026-04-14) | architecture.md | 本 handoff 已含 Required Evidence Manifest，Blake 必须对照产出 |
| AC Precision: "≥N Triggers" vs "Specific List of N" Are Different Contracts (2026-04-14) | architecture.md | 本 handoff AC 列清了具体项目，不是 aggregate 数量 |
| Gate 4 Verification Integrity: Verify Files, Not Claims (2026-04-14) | architecture.md | Gate 4 时 Alex 会 raw-grep 重新核对，别假报告 |
| Mechanical Enforcement Rejected on Single-User CLI (2026-04-15) | architecture.md | **⚠️ Phase 1 严格避免 fail-closed / hard-block**。所有检查都是 smoke alarm |
| UserPromptSubmit Hook Verified (2026-04-07) | architecture.md | P1.4 hook event 背景 |
| claude -p is a Valid UserPromptSubmit Hook Testing Channel (2026-04-07) | architecture.md | P1.4 用 claude -p 做契约测试 |
| claude -p Hook Contract Testing: CLAUDE_CONFIG_DIR Breaks Auth (2026-04-14) | architecture.md | P1.4 测试: 用 --settings 不用 CLAUDE_CONFIG_DIR |
| Domain Pack Keyword Curation: Uniqueness > Count (2026-04-07) | architecture.md | P1.4 Decision #5 依据: 不动阈值，保留 Phase 2b 的 threshold=1 + 严格 unique 设计 |
| Perf Gate Measurement Requires Dedicated CI Runner (2026-04-14) | architecture.md | P1.4 perf 测 N≥30 可以在 dev，但标注 "dev-host directional" |

---

## 10. Expert Review Status

### Audit Trail (dogfood per P1.5 新格式)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: Supersedes regex `^Supersedes:` 匹配不到真实格式 `**Supersedes:**` (bold markdown) | §Task P1.2.c regex 修正 + §Task P1.5 template 加 Supersedes 字段说明 + AC-P1.2-j | Resolved |
| code-reviewer | P0-2: `git log --grep "$slug"` 会 substring-match 造成 false positive (`auth` → `post-auth`) | §Task P1.2.b word boundary 修正 + COMPLETION 二次核查 + AC-P1.2-h fixture | Resolved |
| code-reviewer | P0-3: 缺显式 shellcheck/portability AC | AC-P1.2-i + §8 Blake Instructions 加 macOS BSD 条款 | Resolved |
| code-reviewer | P0-4: P1.4 insertion point 与现有 `USER_MSG` 冲突 | §Task P1.4 完全重写 insertion point 描述 + printf vs echo + 保留 `// empty` | Resolved |
| code-reviewer | P1-1: drift-check.sh 估算 150-200 行不现实 | §6 Files 更新至 ~250-300，escalate 阈值改为 400 | Resolved |
| code-reviewer | P1-2: P1.1 edge case 不全 | AC-P1.1-e/f/g/h 补 4 条 edge case | Resolved |
| code-reviewer | P1-3: P1.3 单段 slug 边界 | §Task P1.3 code block 加 single-segment check + AC-P1.3-e | Resolved |
| code-reviewer | P1-4: P1.2.a 对 pre-Manifest handoff 处理不明 | §Task P1.2.a backward compat 规则 + AC-P1.2-g | Resolved |
| code-reviewer | P1-5: P1.5 dogfood chicken-and-egg | §10 (本 section) 本身就是 dogfood 示例，本 handoff 整合时填表 | Resolved |
| code-reviewer | P2-1: Evidence Manifest 缺 alex-review-feedback / blake-review-feedback | §5 Manifest 加 review_feedback_integration + blake_review_feedback 两项 | Resolved |
| code-reviewer | P2-2: AC-P1.4-d 30-case fixture 路径不明 | §Task P1.4 实现提示 + §7 明确 2026-04-07 Phase 2b 引用 | Resolved |
| code-reviewer | P2-3: fixture 路径显式化 | §5 minimum_fixtures 列出具体路径 | Resolved |
| code-reviewer | P2-4: §9 knowledge 条目验证 | 已 grep 确认 11 条全部存在 | Resolved |
| backend-architect | P0-1: P1.4 threshold 机制事实错误（无全局变量，所有 pack threshold=1） | §Task P1.4 彻底 descope threshold，只做事件过滤 + Decision #5 | Resolved |
| backend-architect | P0-2: P1.2 subcheck FSM / 接口未定义 | §Task P1.2 新增 "Subcheck Contract" YAML 定义 + AC-P1.2-k/l | Resolved |
| backend-architect | P0-3: P1.2.a Manifest backward compat | 合并 CR-P1-4 → §Task P1.2.a backward compat + AC-P1.2-g | Resolved (merged) |
| backend-architect | P1-1: Anti-Epic-1 仅文字警告，无机械检查 | §5 Manifest + §7 Testing + AC 加 anti-epic1-grep.txt 产出 | Resolved |
| backend-architect | P1-2: P1.5 scope creep (template 非 state consistency) | Decision #6 解释 bundling 选择 | Resolved (documented, not moved) |
| backend-architect | P1-3: 缺 backward compat / failure isolation / observability AC | AC-P1.1-c/e + AC-P1.2-g/k/l 补齐 | Resolved |
| backend-architect | P1-4: P1.4 legitimate `<task-notification>` 字面使用 edge case | AC-P1.4-h + Decision #7 接受 silent skip | Resolved |
| backend-architect | P1-5: threshold descope 后仍需 regression AC | AC-P1.4-f 保留 30-case 100% regression | Resolved |
| backend-architect | P2-1: ghost prefix list 应 config 化 | §Task P1.2.d 移到 config-workflow.yaml + §6 新建 config | Resolved |
| backend-architect | P2-2: zombie window 应 config 化 | §Task P1.2.b zombie_window_days 配置化 | Resolved |
| backend-architect | P2-3: 3 次截断可能 | §Task P1.3 实现提示 #3 记录决策（当前 2 次足够） | Resolved |
| backend-architect | P2-4: §9 knowledge 加一条 Hook Path Matching | §9 已补加 2026-04-02 Hook Path Matching 条目 | Resolved |
| backend-architect | P2-5: Decision Summary 加 threshold 决定 | §11 Decision #5 新增 | Resolved |

### Experts Selected
1. **code-reviewer** — shell 脚本语法、portability、edge case 审查
2. **backend-architect** — drift detection flow 设计、handoff lifecycle 模型、state consistency 正确性

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS** (all 4 P0 resolved, all 5 P1 resolved)
- backend-architect: CONDITIONAL PASS → **PASS** (all 3 P0 resolved, all 5 P1 resolved)

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | git-tracked check 的 production 目录定义 | frontmatter 声明 / heuristic scan / 全仓 + 排除列表 | frontmatter 声明 | 精确、可跳过、无误报（用户选 Recommended） |
| 2 | /tad-maintain 4 subcheck 打包策略 | 4 个同时 / 只做 2 / 逐个独立 handoff | 4 个同时 | 实现成本低（都是独立 grep/git 小脚本）、状态一次转正（用户选 Recommended） |
| 3 | Supersedes detection 行为 | 自动 mv / CHECK 建议 + SYNC 应用 / 仅警告 | CHECK 建议 + 人工确认 | 贴合现有 CHECK/SYNC 双模式、避免误判（用户选 Recommended） |
| 4 | userprompt-router event filter 策略 | stdin tag 检查 / hook_event_name 检查 / 两者结合 | stdin tag 检查 (黑名单) | 简单直接、能覆盖本 session 发现的 task-notification 案例（用户选 Recommended） |
| 5 | userprompt-router threshold 策略 | 全局 2→3 / per-pack 选择性升 / **descope 不动 threshold** | **descope 不动 threshold** | BA-P0-1: 不存在全局变量；所有 pack threshold=1 + Phase 2b 严格 unique 设计获得 100% accuracy；本次 dogfood bug 根因是 system-injected content，事件过滤即可解决；升阈值会破坏 accuracy baseline。保留 Phase 2b 的 2026-04-07 设计。 |
| 6 | P1.5 Audit Trail bundling in Phase 1 | 放 Phase 1（当前）/ 拆到 Phase 6（假设重设计里）/ 独立 micro-handoff | 保留 Phase 1 | BA-P1-2 识别到 naming friction，但 Audit Trail 与 Expert Review 强相关（Phase 1 的专家审查本身就是 dogfood 场景）；Decision Summary 明示 bundle 选择，不改 Phase banner |
| 7 | P1.4 legitimate `<task-notification>` 字面 prompt | hook 触发 / 位置敏感（仅开头匹配才过滤）/ silent skip | silent skip | BA-P1-4: hook 是 advisory（没命中就没 domain pack 提示），worst case 是用户问此 tag 时没得到分类建议；位置敏感引入复杂性不值得；低概率 edge case |
| 8 | Supersedes 字段约定外显化 | 不显式 / template 可选字段 / frontmatter 必填 | template **可选**字段（与 Audit Trail table 一起） | CR-P0-1 延伸：template 不教约定 → P1.2.c 再好 regex 也因作者不用约定失效。可选不是必填，避免破坏现有 handoff |

---

**Status**: Feedback integration complete → Gate 2 check → Blake message generation
