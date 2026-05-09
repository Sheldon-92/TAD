---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/hooks/lib", ".tad/project-knowledge", ".tad/templates"]
---

# Handoff: Phase 2 — Grounding & Anti-Stale-Knowledge

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2) | **Date:** 2026-04-24
**Epic:** `.tad/active/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md` (Phase 2/6)
**Evidence Reference:** `.tad/evidence/learnings/HARVEST-20260424-cross-project.md`
**Priority:** P0
**Status:** Ready for Implementation (post expert review v2)
**Type:** Standard TAD (Phase handoff; not Express)

---

## 1. Executive Summary

本 handoff 为 Epic Phase 2——**防 toy OPRO 重演**。toy 项目 2026-04-21 的 prompt-tuning 实验白做了一大半，因为 Alex 引用了 4-7 的 knowledge entry 说"用 Qwen Plus"，但实际 config.py 在 4-11~14 已迁移到 qwen3-omni-flash。Alex 没有任何机制检测这种 stale knowledge / aspirational coding。

**这个 Phase 装两道防线：**
1. **后视镜**（P2.1）：knowledge entry 加 `Grounded in` bullet 声明依赖文件 + 可选 `Revalidated` bullet 让 Alex 重新核实后消音；新工具 `stale-knowledge-check.sh` 检测引用文件 mtime > `max(entry_date, revalidated_date)` 的 entry。
2. **前视镜**（P2.2）：Alex `handoff_creation_protocol.step1c`（新）—— 写完 draft §6 后，强制 Read 目标文件 head 50 行；handoff §6 末尾加 `**Grounded Against**:` 行作为证据。

**严格 prompt-level，不是机械 enforcement**——这是 Alex SKILL 自律规则（同 anti_rationalization_registry），**不**注册 PreToolUse hook，**不**改 settings.json，**不**返回 deny exit code。完全符合 2026-04-15 Epic 1 取消教训。

---

## 2. Epic Context

Phase 1 ✅ Done (2026-04-24 commit 08e9e74) — drift detector / git-tracked / slug truncation / router filter / Audit Trail table。Phase 2 与 Phase 1 完全独立。

---

## 3. Task Breakdown

### Task P2.1 — Knowledge entry `grounded_in` + `revalidated` 字段 + stale-knowledge-check.sh

**问题**（toy `architecture.md:172-176` 2026-04-21）: Alex 写 prompt-tuning handoff 时引用的 knowledge entry 比代码晚 14 天，无机制提醒。

**设计决策**（Socratic + 专家审查后）:
- `Grounded in` 作为 bullet 与 Context/Discovery/Action **并列**（用户 Recommended）
- `Revalidated` 作为可选 bullet（**BA-P0-2**）—— Alex 重新核实代码确认 entry 还成立 → bump 此日期，stale-check 用 `max(entry_date, revalidated_date)` 防 alarm fatigue
- stale-check 触发 = on-demand + Alex step0_5 自动调用（用户 Recommended）
- stale 信号 = mtime > `max(entry_date, revalidated_date)` + 1 day grace（用户 Recommended）
- **Backward compat**: pre-Phase-2 entry 无 `Grounded in` → INFO 不 STALE
- **stale-check.sh 是独立工具，非 drift-check.sh 的 subcheck**（**BA-P1-2** 显式声明）

#### P2.1.a — Knowledge entry 格式约定（README）

`.tad/project-knowledge/README.md` "Entry Format" section 扩展：

```markdown
### [Short Title] - [YYYY-MM-DD]
- **Context**: 在审查什么任务
- **Discovery**: 发现了什么
- **Action**: 建议未来如何处理
- **Grounded in**: <optional> 依据的源代码 / 配置文件
  Grammar (strict — 工具按此 parse):
    - 多路径用 `, ` (逗号空格) 分隔
    - 单路径可选 `:LINE` (single integer) 或 `:SYMBOL` 锚点
    - 路径**禁止含逗号、空格、冒号**（除作为 anchor 分隔符）
    - **禁止** line range 如 `:42-55`（用 `:42` 单点或省略）
    例: `loop_voice/config.py:QWEN_OMNI_MODEL, .tad/hooks/lib/router.sh:42`
- **Revalidated**: <optional> YYYY-MM-DD
  Alex 重新读了 Grounded in 文件、确认 entry 还准确时填这一行；stale-check 会取
  max(entry_date, revalidated_date) 作为新鲜度基线，避免重复报警同一已验证条目。
```

#### P2.1.b — stale-knowledge-check.sh

新建 `.tad/hooks/lib/stale-knowledge-check.sh`：

**接口（独立工具，不继承 drift-check.sh Subcheck Contract）:**
```
stale-knowledge-check.sh                   # check all .tad/project-knowledge/*.md (排除 README)
stale-knowledge-check.sh path/to/file.md   # 检查指定文件
stale-knowledge-check.sh --json            # JSONL 输出（供 Alex step0_5 程序消费）
stale-knowledge-check.sh --help            # usage
Exit code:
  0  always (advisory, never blocks)
  1  internal error (malformed input / missing dependency / etc)
Working directory:
  Auto-resolves to git repo root via `git rev-parse --show-toplevel`.
  If not in a git repo → exit 1 with clear stderr message.
Single-session assumption:
  Not designed for concurrent Alex sessions writing to project-knowledge/.
  Race window between read and emit is microseconds; acceptable for advisory.
Symlink policy:
  Use `stat -f "%m" -L` (follow symlinks). 文档化此选择。
```

**JSON schema（--json mode）:**
```jsonl
{"file": "<path>", "title": "<entry title>", "path": "<grounded_in path>", "status": "STALE|INFO|WARN|OK|ERROR", "days_delta": <integer or null>, "msg": "<human-readable>"}
```
- `status` 枚举严格 5 选 1
- `days_delta` 为 int (STALE only)，其他状态为 null
- `path` 是相对 git 根的路径（与 grounded_in 保留一致）

**算法:**
```
For each .tad/project-knowledge/*.md (excluding README.md):
  Parse entries by anchored regex `^### (.+) - ([0-9]{4}-[0-9]{2}-[0-9]{2})( \(consolidated\))?$`
    note: anchor to LAST ` - ` before date; titles含 `-` (如 "Sub-Agent Safety")合法
    note: `(consolidated)` 后缀允许，提取 date 时忽略
  For each entry:
    title, entry_date = parse header
    grounded_in_paths = parse "- **Grounded in**:" bullet (可能不存在)
    revalidated_date  = parse "- **Revalidated**:" bullet (可能不存在)
    baseline_date     = max(entry_date, revalidated_date or entry_date)
    
    If no grounded_in:
      emit INFO "{title} — no grounded_in declared (legacy entry, skip)"
      continue
    
    For each path in grounded_in_paths (split on ', ', 容错 trailing whitespace):
      Validate grammar:
        if path contains illegal chars (` `, `,`) → emit WARN "{title} — malformed path '{p}'"; continue
        strip optional `:LINE_OR_SYMBOL` anchor for file-existence check
      
      If file does not exist on disk:
        if path ends in marker `(new — will be created)` per P2.2 Decision #6:
          emit INFO "{title} — '{path}' marked as new (will be created)"
        else:
          emit WARN "{title} — grounded_in path '{path}' missing"
        continue
      
      file_mtime = stat -f "%m" -L "$path"   # follow symlinks
      baseline_ts = date -j -f "%Y-%m-%d" "$baseline_date" "+%s"
      grace = 86400  # +1 day; entry written late at night vs file edited next morning
      
      If file_mtime > baseline_ts + grace:
        delta_days = floor((file_mtime - baseline_ts) / 86400)
        emit STALE "{title} — '{path}' mtime is {delta_days} days newer than baseline {baseline_date}"
      Else:
        emit OK ""
```

#### P2.1.c — Alex step0_5 集成（stale-check 调用）

`.claude/skills/alex/SKILL.md` 的 `handoff_creation_protocol.step0_5` 段落，在第 8 步（"matching is LLM semantic scan"）之后加新步骤：

```yaml
9. After knowledge matching, run stale-check on matched entries (advisory, non-blocking):
   bash .tad/hooks/lib/stale-knowledge-check.sh --json 2>/dev/null
   Failure handling:
     - If exit code != 0: emit stderr warning "stale-check.sh failed (exit {code}); continuing without staleness data"
       and proceed. **Handoff drafting MUST NOT be blocked**.
     - If exit code == 0: parse JSONL; for entries in relevant_knowledge with status="STALE":
         output to user: "⚠️ Knowledge entry '{title}' may be stale: {path} changed {N} days after baseline"
         DO NOT block; user may re-verify and bump Revalidated, or proceed with awareness
     - INFO/WARN entries: just record count for transparency; no UI noise
```

**AC:**
- [ ] AC-P2.1-a: README 含 Grounded in + Revalidated bullet 说明 + 1 个完整示例 + grammar 严格规则（禁含 `, `、` `、`:` 除 anchor）
- [ ] AC-P2.1-b: `stale-knowledge-check.sh` shellcheck 通过 + macOS BSD 跑通（`stat -f "%m" -L`、`date -j -f`）
- [ ] AC-P2.1-c: Fixture stale: entry date 2026-04-01，grounded_in 文件 mtime = 2026-04-08 → STALE "7 days newer"
- [ ] AC-P2.1-d: Fixture not-stale: entry date 2026-04-08，文件 mtime = 2026-04-01 → OK
- [ ] AC-P2.1-e: Fixture no-grounded: entry 没有 Grounded in bullet → INFO `legacy entry, skip`
- [ ] AC-P2.1-f: Fixture missing-file: grounded_in 指向不存在的路径 → WARN `path missing`
- [ ] AC-P2.1-g: Fixture multi-path: 一个 entry 多 paths → 每个独立判定，emit 多行
- [ ] AC-P2.1-h: Fixture revalidated: entry date 2026-04-01, revalidated 2026-04-10, 文件 mtime = 2026-04-08 → OK（baseline 是 04-10）
- [ ] AC-P2.1-i: Fixture revalidated-stale: revalidated 2026-04-05, 文件 mtime = 2026-04-12 → STALE "7 days newer than baseline 2026-04-05"
- [ ] AC-P2.1-j: Fixture grace boundary: 文件 mtime = entry_date_ts + 86399 → OK（grace 内）；mtime = entry_date_ts + 86401 → STALE
- [ ] AC-P2.1-k: Fixture malformed grammar: `Grounded in: foo, bar.py:42-55` (line range禁用) → WARN `malformed path '42-55'` 不 crash
- [ ] AC-P2.1-l: Fixture (new marker): grounded_in path 含 `(new — will be created)` 后缀 → INFO `marked as new`，不 WARN
- [ ] AC-P2.1-m: Fixture title-with-dash: header `### Sub-Agent Safety: Red-Team Triggers Refusal - 2026-04-14` → 解析正确 (anchor 到 LAST ` - `)
- [ ] AC-P2.1-n: Fixture consolidated suffix: `### API Timeout Patterns - 2026-04-20 (consolidated)` → 解析为 2026-04-20
- [ ] AC-P2.1-o: `--json` 输出符合 schema (5 status enum, days_delta int|null)
- [ ] AC-P2.1-p: AC-P2.1-real-corpus（机械化）: 对真实 architecture.md 跑 → exit code = 0 + stdout 非空 + 0 行以 "ERROR:" 开头
- [ ] AC-P2.1-q: Failure isolation: 模拟 stale-check 崩溃（构造 malformed 输入）→ Alex step0_5 stderr warn + 继续 drafting
- [ ] AC-P2.1-r: Anti-Epic-1 — stale-check **不**注册 settings.json hook，**不**返回 deny code，是纯 advisory CLI
- [ ] AC-P2.1-s: cwd: 从子目录调用脚本 → 自动 resolve 到 git root；非 git repo → exit 1 with clear msg
- [ ] AC-P2.1-t: Symlink: grounded_in 指向 symlink → 检查 target file mtime（`-L` 行为）

---

### Task P2.2 — Alex handoff grounding pass（step1c，prompt-level only）

**问题**（menu-snap `code-quality.md:15` + toy Ghost Task）: Alex 写 handoff 经常基于"我以为代码长这样"的印象，没强制看真代码。

**设计决策**（Socratic + 专家审查后）:
- 输出格式 = handoff §6 末尾一行 `**Grounded Against**:`（用户 Recommended）
- **重要**: enforcement 是 **prompt-level only**（**BA-P0-1**）—— Alex SKILL 自律规则，跟 anti_rationalization_registry 同性质
- **Step 顺序修复**（**CR-P0-1**）: 不是 step0_5b（那时 §6 还没 draft）。改为 **step1c**（step1 draft → step1b frontmatter 验证 → **step1c grounding pass**）
- *express 路径豁免**留给 Phase 3 决定**（CR-P2-1）—— Phase 2 暂不开口子

#### P2.2.a — Alex SKILL `step1c` (新)

`.claude/skills/alex/SKILL.md` 的 `handoff_creation_protocol`，在 `step1b: Frontmatter Validation` 之后、`step2: Expert Selection` 之前，加新步骤：

```yaml
step1c:
  name: "Grounding Pass — Read target files before sending to Expert Review"
  trigger: "After step1b frontmatter validation, before step2 expert selection"
  enforcement: "prompt-level-only"  # ⚠️ NOT a hook, NOT in settings.json, NOT a tool block
  rationale: |
    Phase 2 P2.2 — Alex 经常基于过期或想当然的代码认知写 handoff (toy OPRO 2026-04-21
    case)。在 step1 draft 完成、§6 Files to Modify 已存在之后，强制 Read 目标文件
    head 50 行作为 reality check。先 reload knowledge (step0_5) 是因为那是 Alex 已知
    的"过去印象"; 后做 grounding (step1c) 是验证印象是否仍准确。顺序不可颠倒。
  blocking_in_alex_protocol: true  # Alex 自身 protocol 流程内必做这一步才能进 step2
                                    # 但**不**是 hook-level / tool-block — 是 SKILL 顺序约束
  action: |
    1. Identify target files in handoff scope:
       a. 解析 step1 draft 的 §6 Files to Modify / Create section
       b. 加上 frontmatter `git_tracked_dirs[]` 路径下的相关文件
    2. For each existing target file:
       - Use Read tool with offset=1 limit=50 to fetch head 50 lines
       - Note any surprises vs Alex 写 spec 时的假设 (函数名 / 路径 / 接口已变 等)
       - 如有重大 surprise: 回到 step1 修订 §6 或 escalate to user
    3. For files Alex plans to CREATE (don't yet exist):
       - Skip Read; mark as `(new — will be created)` in Grounded Against
    4. Append to handoff §6 末尾:
       **Grounded Against** (Alex 写 spec 前实际 Read 过的源文件):
       - .tad/hooks/lib/foo.sh (head 50, read at YYYY-MM-DD HH:MM)
       - .tad/templates/handoff-a-to-b.md (head 50, read at YYYY-MM-DD HH:MM)
       - .tad/hooks/lib/bar.sh (new — will be created)
  exemption_pre_phase2_handoffs: |
    Handoffs drafted before Phase 2 ships (filename date < 2026-04-24 OR no
    git_tracked_dirs frontmatter): step1c skipped on revision; warn-only.
    `task_type: doc-only` handoffs: skipped automatically.
    Empty §6 (no files to modify): skipped automatically.
  exemption_express:
    note: "*express path 是否豁免 grounding pass 留待 Phase 3 决定"
    until_phase3: "*express 暂时也跑 step1c (与 standard 一致)，Phase 3 design 再 revisit"
  violation_self_audit: |
    Alex 在 step2 expert review 时若发现 §6 没有 Grounded Against 行 (而 §6 非空):
    self-audit failed → 回到 step1c。这是 Alex 自我检查，**不**是 hook 抓的。
  forbidden_implementations:
    - "MUST NOT register as PreToolUse hook in .claude/settings.json"
    - "MUST NOT add to .tad/hooks/*.sh as auto-fired script"
    - "MUST NOT return deny exit code from any wrapping script"
    - "MUST NOT block ANY tool call (Write/Edit/Read)"
    - "violation level mirrors anti_rationalization_registry: prompt-only enforcement"
```

#### P2.2.b — Handoff template

`.tad/templates/handoff-a-to-b.md` "## 6. Files to Modify / Create" section 末尾加：

```markdown
**Grounded Against** (Alex step1c 实际 Read 过的源文件):
<!-- Alex step1c 强制填写。pre-Phase-2 / doc-only / 空 §6 handoff 可省。 -->
- _(file path 1, head 50 lines, read at YYYY-MM-DD HH:MM)_
- _(file path 2 - or "(new — will be created)" for new files)_
```

**AC:**
- [ ] AC-P2.2-a: Alex SKILL `handoff_creation_protocol` 含新 step1c（位置在 step1b 与 step2 之间）
- [ ] AC-P2.2-b: handoff template `.tad/templates/handoff-a-to-b.md` 含 Grounded Against 占位 + 1 句说明
- [ ] AC-P2.2-c: **Dogfood** — 本 handoff §6 末尾的 Grounded Against 行已填（见 §6）
- [ ] AC-P2.2-d: SKILL 描述明确 enforcement = prompt-level only；含 forbidden_implementations 列表
- [ ] AC-P2.2-e: SKILL 描述涵盖 (new — will be created) 标记
- [ ] AC-P2.2-f: **Anti-Epic-1 对称 AC** — `grep -rE 'step1c|grounding-pass|grounded_against' .claude/settings.json .tad/hooks/*.sh` 应返回 0 hits（grounding pass 不能落到 hook 层）
- [ ] AC-P2.2-g: Pre-Phase-2 exemption: 给一个 filename 日期 < 2026-04-24 的 active handoff fixture → step1c skip
- [ ] AC-P2.2-h: doc-only / 空 §6 exemption: 一个 task_type=doc-only 的 fixture → step1c skip 不报错

---

## 4. Acceptance Criteria Summary

总共 **28 个 AC**（P2.1: 20 + P2.2: 8）。Blake Gate 3 v2 必须逐条 PASS。

---

## 5. Required Evidence Manifest

```yaml
required_evidence:
  completion_report:
    path: .tad/active/handoffs/COMPLETION-20260424-phase2-grounding.md
    required: true

  expert_reviews:
    - path: .tad/evidence/reviews/alex/phase2-grounding/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/alex/phase2-grounding/backend-architect.md
      required: true

  review_feedback_integration:
    - path: .tad/evidence/reviews/alex/phase2-grounding/feedback-integration.md
      required: true

  gate_verdicts:
    - path: .tad/evidence/completions/phase2-grounding/GATE3-REPORT.md
      required: true

  blake_reviews:
    - path: .tad/evidence/reviews/blake/phase2-grounding/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/blake/phase2-grounding/self-review.md
      required: true

  blake_review_feedback:
    - path: .tad/evidence/reviews/blake/phase2-grounding/feedback-integration.md
      required: true

  fixture_results:
    - path: .tad/evidence/completions/phase2-grounding/fixtures/
      required: true
      minimum_fixtures:
        - fixtures/stale.md
        - fixtures/not-stale.md
        - fixtures/no-grounded.md
        - fixtures/missing-file.md
        - fixtures/multi-path.md
        - fixtures/revalidated.md
        - fixtures/revalidated-stale.md
        - fixtures/grace-boundary-pass.md
        - fixtures/grace-boundary-fail.md
        - fixtures/malformed-grammar.md
        - fixtures/new-marker.md
        - fixtures/title-with-dash.md
        - fixtures/consolidated-suffix.md
        - fixtures/pre-phase2-handoff/
        - fixtures/doc-only-handoff/

  real_corpus_run:
    - path: .tad/evidence/completions/phase2-grounding/real-corpus-output.txt
      description: "对真实 architecture.md 跑 stale-check 的输出 (AC-P2.1-p — exit 0 + 非空 + 无 ERROR)"
      required: true

  failure_isolation_test:
    - path: .tad/evidence/completions/phase2-grounding/failure-isolation.txt
      description: "AC-P2.1-q: stale-check 崩溃模拟 → Alex step0_5 stderr warn + 继续"
      required: true

  anti_epic1_compliance:
    - path: .tad/evidence/completions/phase2-grounding/anti-epic1-grep.txt
      description: |
        Extended pattern (per CR-P2-4):
        grep -rE 'PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions\.deny|exit 2.*deny|fail-closed|step1c.*hook|grounding.*hook' \
             .claude/settings.json .tad/hooks/*.sh .tad/hooks/lib/*.sh
        Must return 0 new hits vs Phase 1 baseline.
      required: true

  dogfood:
    - path: .tad/evidence/completions/phase2-grounding/dogfood.md
      description: "本 handoff §6 Grounded Against 已填 + diff vs 初稿"
      required: true

  knowledge_updates:
    - path: .tad/project-knowledge/architecture.md
      description: |
        至少 1 条新 entry，自身使用新 Grounded in 格式 (dogfood meta-trifecta)。
        建议 entry 主题: "stale-check.sh 设计教训" / "Revalidated state vs alarm fatigue" / 等。
      required: true
```

---

## 6. Files to Modify / Create

**修改:**
- `.claude/skills/alex/SKILL.md` (handoff_creation_protocol 加 step0_5 step 9 ~12 行 + 新 step1c ~50 行)
- `.tad/project-knowledge/README.md` (Entry Format 扩展 + Grounded in 严格 grammar + Revalidated 说明 ~25 行)
- `.tad/templates/handoff-a-to-b.md` (§6 末尾 Grounded Against 占位 ~6 行)

**新建:**
- `.tad/hooks/lib/stale-knowledge-check.sh` (~200-280 行 estimated; entry parsing + grounded_in grammar + mtime check + revalidated handling + json mode + cwd resolution)
  - **Escalate to Alex if >350 lines** — 比 Phase 1 P1.2 simpler (1 检查类型 vs 4)
- `.tad/evidence/completions/phase2-grounding/fixtures/**` (15 fixtures per §5)

**Grounded Against** (Alex step1c 实际 Read 过的源文件 — dogfood):
- `.claude/skills/alex/SKILL.md` (head 50 — 验证 step0_5 / step1b 现有结构)
- `.tad/project-knowledge/README.md` (head 50 — 验证 Entry Format 现状)
- `.tad/templates/handoff-a-to-b.md` (head 50 — 验证 §6 当前 frontmatter / structure)
- `.tad/project-knowledge/architecture.md` (head 50 — 验证现有 entry 格式无 Grounded in)
- `.tad/hooks/lib/layer2-audit.sh` (head 50 — Phase 1 BSD shell precedent)
- `.tad/hooks/lib/drift-check.sh` (head 50 — Phase 1 reference for shell 风格 + 配置加载 + cwd 处理；CR-P2-3 要求加入此项)
- `.tad/hooks/lib/stale-knowledge-check.sh` (new — will be created)
- `.tad/evidence/completions/phase2-grounding/fixtures/**` (new — will be created)

---

## 7. Testing Checklist

- [ ] Unit test: 15 fixtures (per AC list)
- [ ] Real-corpus test: AC-P2.1-p 机械化 (exit 0 + 非空 + 无 ERROR 行)
- [ ] Failure isolation test: AC-P2.1-q (stale-check 崩溃 → step0_5 继续)
- [ ] Portability: shellcheck + macOS BSD 跑通 (`stat -f -L`, `date -j -f`)
- [ ] Integration: Alex SKILL step0_5 第 9 步 + step1c 嵌入正确，order 是 step0_5 → step1 → step1b → step1c → step2
- [ ] Anti-Epic-1: 扩展 grep pattern (含 UserPromptSubmit / hookSpecificOutput / step1c hook 关键词) 零新 hit
- [ ] Dogfood: 本 handoff §6 Grounded Against 已填 + 1 条新 architecture.md entry 自带 Grounded in
- [ ] Pre-Phase-2 handoff exemption: fixture 验证

---

## 8. Blake Instructions

- 这是 **Standard TAD Phase handoff**，不是 Express。完整 Ralph Loop Layer 1 + Layer 2 + Gate 3 v2。
- 2 个 task 互相**独立**——可串行做或并行 (建议 P2.1 先，因新工具测试 fixture 多)。
- **macOS BSD 优先**: `stat -f "%m" -L`、`date -j -f "%Y-%m-%d"` — Phase 1 已经踩过这条线，再次重申。
- **严格 prompt-level enforcement（BA-P0-1 重申）**: stale-check 是 advisory CLI；step1c 是 Alex SKILL 自律规则（不是 hook、不是 tool block）。**任何**实现把它做成 PreToolUse / UserPromptSubmit / settings.json 注册 = 直接退回（这就是 Epic 1 取消的原因）。
- **alarm fatigue 防御**: revalidated bullet 是关键。如果实现没考虑 max(entry_date, revalidated_date)，所有 entry 永远报警 → 3 个月内 Alex 习惯性忽略 STALE → 整个 Phase 2 价值清零。
- **scope 警戒**: stale-check.sh 估算 200-280 行；超 350 行 escalate to Alex。
- **不 backfill 老 entry**: 现有 architecture.md 几百条 entry 不强制加 Grounded in。新增 entry 自带；老 entry 由作者偶发更新。
- 对 §6 Grounded Against 自我检查：本 handoff 自身是 dogfood，§6 已示范格式（含 (new) 标记）。
- **可选 reference helper**: 类似 Phase 1 你创建了 `gate3-git-tracked-check.sh`，本 Phase 也可以创建 `step1c-grounding-helper.sh` 作为 reference impl（不强制，judgment call）。

---

## 9. Project Knowledge — Blake 必读历史教训

| 教训 | 文件 | 关系 |
|------|------|------|
| Hook Shell Portability: No grep -P on macOS (2026-04-03) | architecture.md | stale-check 必须 macOS BSD |
| Hook Latency Measurement (2026-04-14) | architecture.md | 如需 perf 测，perl -MTime::HiRes |
| AC Precision: List-based vs Aggregate (2026-04-14) | architecture.md | 本 handoff 28 AC 全列具体项 |
| Alex Handoff AC Must Explicitly List ALL Required Evidence (2026-04-14) | architecture.md | §5 Manifest 完整 |
| Gate 4 Verification Integrity: Verify Files, Not Claims (2026-04-14) | architecture.md | Alex 会 raw-grep 重核 |
| Mechanical Enforcement Rejected on Single-User CLI (2026-04-15) | architecture.md | **⚠️ 严禁 fail-closed**；advisory only |
| Expert Review Blind Spot: Cross-File Internal References (2026-04-04) | architecture.md | grep 验证完整性 |
| Word-Boundary Matching for Identifier-Style Slugs (2026-04-24) | architecture.md | Phase 1 学到的 BSD 边界，stale-check 可参考 portable 写法 |
| Drift-Check Allowlist for Shared Paths (2026-04-24) | architecture.md | stale-check 也是机械检查；评估是否需要 allowlist |
| Long Context Enables In-Session Decision Making (2026-03-25) | architecture.md | step1c grounding 是 in-session reality check |
| Express Handoff is NOT Review-Exemption (2026-04-14) | architecture.md | *express 豁免 grounding pass 留 Phase 3 慎决（不在本 Phase 提前开口） |

---

## 10. Expert Review Status

### Audit Trail (P1.5 模板)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: step0_5b 顺序 chicken-and-egg (§6 在 step1 才生成) | §Task P2.2.a 重命名为 step1c (位于 step1b 之后) + 数据流 rationale | Resolved |
| code-reviewer | P0-2: Grounded in bullet 语法歧义 (`:` line range vs `,` separator) | §P2.1.a grammar 严格化: 单数字 `:LINE`, 禁路径含逗号空格, 禁 `:42-55` 格式 + AC-P2.1-k fixture | Resolved |
| code-reviewer | P0-3: 缺 failure isolation AC | §P2.1.c 加 exit code != 0 时 stderr warn + 继续；AC-P2.1-q 验证 | Resolved |
| code-reviewer | P1-1: 日期解析 edge cases | algorithm regex anchor 到 LAST `-`；`(consolidated)` 后缀允许；AC-P2.1-m/n fixtures | Resolved |
| code-reviewer | P1-2: +1 day grace 边界无 fixture | AC-P2.1-j: 86399s = OK / 86401s = STALE | Resolved |
| code-reviewer | P1-3: symlinks / cwd / 特殊字符 | algorithm 文档 `stat -f -L` (follow); cwd via `git rev-parse --show-toplevel`; AC-P2.1-s/t | Resolved |
| code-reviewer | P1-4: --json schema 不明确 | §P2.1.b JSON schema block: 5 status enum + days_delta int\|null | Resolved |
| code-reviewer | P1-5: AC-P2.1-real-corpus 不可机械化 | 改成 AC-P2.1-p: exit 0 + 非空 + 无 ERROR 行 (机械可 grep) | Resolved |
| code-reviewer | P1-6: 只 2 个 expert，建议加 product-expert/ux | Justify 保留 2 个: Phase 2 是 protocol/工具改动，无 user-facing UX；2 expert 经 Phase 1 验证够用 | Resolved (rationale documented) |
| code-reviewer | P2-1: *express 豁免在 Phase 2 阶段是 trapdoor | §P2.2.a exemption_express 改为"暂时跟 standard 一致，Phase 3 决定"；不提前开口 | Resolved |
| code-reviewer | P2-2: (new — will be created) 智能识别 | algorithm: 路径含此 marker → INFO；AC-P2.1-l fixture | Resolved |
| code-reviewer | P2-3: drift-check.sh 应在 Grounded Against | §6 加 `.tad/hooks/lib/drift-check.sh` (head 50 — Phase 1 reference) | Resolved |
| code-reviewer | P2-4: anti-Epic-1 grep 加 UserPromptSubmit \| hookSpecificOutput | §5 anti_epic1_compliance description 扩展 pattern | Resolved |
| code-reviewer | P2-5: Audit Trail TBD 标注 | 本 section（已填表证明 review 完成）| Resolved |
| backend-architect | P0-1: blocking + VIOLATION 模糊 (机械 vs 提示) | §P2.2.a 显式 `enforcement: prompt-level-only` + forbidden_implementations 列表 + AC-P2.2-d/f | Resolved |
| backend-architect | P0-2: 无 revalidated 状态 → alarm fatigue | §P2.1.a 加 Revalidated bullet；algorithm 用 max(entry_date, revalidated)；AC-P2.1-h/i fixtures | Resolved |
| backend-architect | P1-1: step0_5b ordering rationale 缺 | §P2.2.a rationale block 解释 reload→ground 顺序 | Resolved |
| backend-architect | P1-2: Subcheck Contract 没继承 Phase 1 | §P2.1.b interface block 显式声明 "stale-check 是独立工具，非 drift-check subcheck" | Resolved |
| backend-architect | P1-3: race conditions | §P2.1.b "Single-session assumption" 文档化；race window 微秒级 acceptable for advisory | Resolved |
| backend-architect | P1-4: pre-Phase-2 active handoffs | §P2.2.a exemption_pre_phase2_handoffs (filename date / no git_tracked_dirs / doc-only / 空§6) + AC-P2.2-g/h fixtures | Resolved |

### Experts Selected
1. **code-reviewer** — shell 脚本质量、portability、grammar、edge cases、JSON schema、AC 机械化
2. **backend-architect** — knowledge entry 生命周期 FSM、enforcement-level clarity、step ordering、Anti-Epic-1 合规

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS** (3 P0 + 6 P1 + 5 P2 全 Resolved)
- backend-architect: CONDITIONAL PASS → **PASS** (2 P0 + 4 P1 全 Resolved)

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | grounded_in 字段格式 | bullet / HTML 注释 / 独立 metadata | bullet 与现有并列 | 用户选 Recommended |
| 2 | stale-check 触发 | 仅 on-demand / on-demand + Alex / cron | on-demand + Alex step0_5 集成 | 用户选 Recommended |
| 3 | stale 信号 | mtime / git log / mtime OR git | mtime + 1 day grace | 用户选 Recommended |
| 4 | grounding 输出 | 一行 / 表格 / 独立文件 | handoff §6 末尾一行 | 用户选 Recommended |
| 5 | 老 entry backfill | 全 backfill / 选择性 / 不 backfill | 不 backfill 智能跳过 | Phase 1 P1.2.a 同模式 |
| 6 | grounding 文件存在性 | 强制存在 / 跳过 / 标记 | 标记 (new — will be created) | 允许 Alex 设计新文件 |
| 7 | revalidated 状态 (BA-P0-2 新增) | 不加 / 单独文件 / entry 内 bullet | entry 内 Revalidated bullet | 防 alarm fatigue；max(entry_date, revalidated) baseline |
| 8 | grounding pass step 位置 (CR-P0-1 新增) | step0_5b (early) / step1c (post-draft) / step1 嵌入 | step1c (step1b 之后, step2 之前) | 解决 chicken-and-egg: step1c 时 §6 已存在；reload→ground 顺序对 |
| 9 | enforcement level (BA-P0-1 新增) | hook-level / prompt-level / 混合 | **prompt-level only** | Anti-Epic-1 hard constraint；同 anti_rationalization_registry 性质 |
| 10 | grammar 严格度 (CR-P0-2 新增) | 宽松 / 严格 grammar | 严格 grammar (禁路径逗号空格、禁 `:42-55`) | 防止 silent mis-parse → silent stale missing |
| 11 | *express 豁免 (CR-P2-1 新增) | 现在豁免 / 留 Phase 3 决定 | 留 Phase 3 决定 | 不提前开口；与 2026-04-14 Express NOT review-exempt 教训一致 |
| 12 | 仅 2 expert 是否够 (CR-P1-6 新增) | 加 product-expert / 加 ux / 维持 2 个 | 维持 2 个 | Phase 2 是 protocol+工具，无 user-facing UX；Phase 1 已验证 2 expert 够 |

---

**Status**: Feedback integration complete (5 P0 + 10 P1 + 5 P2 all addressed) → Gate 2 → Blake message
