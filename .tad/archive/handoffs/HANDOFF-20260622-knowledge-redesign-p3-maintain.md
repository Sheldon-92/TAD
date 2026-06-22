---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/hooks/lib"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Recording Redesign — P3 Maintain (dedup/retire/reconcile + lint)

**From:** Alex (Terminal 1) · **To:** Blake (Terminal 2) · **Date:** 2026-06-22
**Epic:** EPIC-20260622-knowledge-recording-redesign.md (Phase 3/4)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三个产物:维护协议 reference + lint 脚本 + 使用率近似定义 |
| Components Specified | ✅ | 和解 4 操作(ADD/UPDATE/DELETE/NOOP) + hash 去重 + lint 3 检查 + 判别自检 |
| Functions Verified | ✅ | 目标文件明确;lint 是新建脚本,和解协议是新建 reference |
| Data Flow Mapped | ✅ | distill step6 写 entry → lint 检查 → 和解 against 现有 _index → 人 gate DELETE/UPDATE |

**Gate 2 结果**: ✅ PASS(专家审查后回填 §9.2)

---

## 1. Task Overview

### 1.1 What We're Building
让 playbook 不退化的廉价维护层:机械去重(零 LLM)、语义和解(LLM 但人 gate 破坏性操作)、软 lint(报告不阻塞)。

### 1.2 Why We're Building It
P2 让 entry 能被正确创建,但没有防止 playbook 随时间退化——重复 entry 累积、过时 entry 不清理、格式滑坡。SkillOps 证明这些用规则驱动+近零 LLM 就能做。

### 1.3 Intent Statement
**不是要做的**:
- ❌ 不建 embedding 向量检索(文件系统没有,接受 lexical 作为近似)
- ❌ 不自动执行 DELETE/UPDATE(人 gate)
- ❌ 不注册 hook(L1 reject-mechanical-enforcement)
- ❌ 不迁移现有知识(P4)

---

## 📚 Project Knowledge

**⚠️ Blake 必读**:

1. **Mechanical Enforcement Rejected on Single-User CLI**(principles.md) — lint 和维护全是 advisory/soft;exit 0 always;不注册 hook/settings。
2. **Verify Before Delete**(memory) — DELETE/UPDATE 必须人确认,从不 auto-apply。
3. **研究 findings §3(Maintain)**:`.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md` — Mem0 的 ADD/UPDATE/DELETE/NOOP + hash 去重、SkillOps 的 utility retire + 5-dim health。

---

## 3. Technical Plan

### 3.1 维护协议 reference

**创建**:`.claude/skills/alex/references/knowledge-maintain-protocol.md`

这是 Alex 在 `*accept` 结束时(distillation_loop 之后)或独立 `*knowledge-maintain` 命令时运行的协议。

**内容规格(Blake 按此写)**:

```markdown
# Knowledge Maintenance Protocol

> 在 distillation_loop 产出新 entry 后,或独立 *knowledge-maintain 调用时运行。
> 规则驱动,近零 LLM 调用(除和解步骤)。全程 advisory — 提议而非自动执行。

## 1. Hash-Dedup Pre-Filter (零 LLM)

对新 entry 的 `label` + `value`(归一化:小写、去空白、去标点):
```bash
echo -n "$normalized" | md5 -q    # macOS; Linux 用 md5sum | cut -d' ' -f1
```
⚠️ TAD 运行在 macOS(darwin)。用 `md5 -q`(quiet,只输出 hash)。如需跨平台:
`echo -n "$normalized" | { md5sum 2>/dev/null || md5 -q; } | cut -d' ' -f1`
与 project-knowledge/ 下所有现有 entry 的同样归一化 hash 比对。
- 完全匹配 → **NOOP**:报告"byte-identical entry already exists: {existing_label}"。不添加。
- 不匹配 → 继续下一步。

## 2. Candidate Retrieval (lexical, _index.md)

从新 entry 的 `selector` + `label` 提取关键词。
在 `project-knowledge/patterns/_index.md` 和各 category.md 的 `### ` 标题中做 LLM 语义匹配(不是 grep——用 Alex 的 context 内 LLM 判断,不额外调 API)。
取 top-5 最相似的现有 entry 作为候选集。

⚠️ 已知限制:这是 lexical + in-context LLM 匹配,不是 embedding 检索。
会漏掉用完全不同措辞描述同一模式的 entry(over-ADD 是预期失败模式)。
接受此限制;不伪造"语义检索"能力。

## 3. Reconciliation (LLM, 4-way decision)

将新 entry + top-5 候选以编号列表展示给 Alex:

```
## 现有候选(编号 = 临时 ID,不是真实 ID):
0: [label: bgm-loop-seam, selector: "...", failure_mode: "..."]
1: [label: tts-reference-audio, selector: "...", failure_mode: "..."]
...

## 新 entry:
[label: bgm-swell-volume, selector: "...", value: "...", failure_mode: "..."]

## 对每个候选,判断新 entry 与其关系(必须选一个):
- ADD: 新 entry 是新信息,不和任何候选重叠 → 直接添加
- UPDATE {N}: 新 entry 是候选 N 的更新版(保留原 label,合并更丰富的内容) → 提议
- DELETE {N}: 新 entry 与候选 N 矛盾(不是补充,是否定) → 提议
- NOOP: 新 entry 的信息已完全被某候选覆盖,无新内容 → 不添加
```

⚠️ **编号→label 映射**:临时编号只用于和解判断;输出时翻译回真实 label(anti-hallucination,Mem0 UUID→int 技术)。

⚠️ **NOOP 是一等公民**:默认是"do nothing",不是"append"。(Mem0 经验)

## 4. Human Gate (DELETE/UPDATE only)

- **ADD** → 直接执行(写 entry 到 playbook)
- **NOOP** → 不执行(报告"covered by {existing_label}")
- **UPDATE {label}** → 展示 old vs new 对比 → AskUserQuestion:"更新 {label} 吗?" → 用户确认才执行;UPDATE 保留原 label,合并内容(取信息量更大的版本),旧版本作为注释保留审计线索
  - **用户拒绝 UPDATE** → 新 entry 仍然 ADD(两条共存)。报告:"UPDATE 被拒,新 entry 作为独立条目添加。两条可能有重叠——后续 *knowledge-maintain 会再次检测。"(不丢弃新 entry——信息损失 > 轻度重复)
- **DELETE {label}** → 展示理由 + 矛盾证据 → AskUserQuestion:"删除 {label} 吗?" → 用户确认才执行;DELETE 不物理删除文件,标注 `[SUPERSEDED by {new_label}, {date}]`
  - **用户拒绝 DELETE** → 新 entry 仍然 ADD(矛盾的两条共存)。报告:"DELETE 被拒,两条矛盾的 entry 共存——建议人工审查决定保留哪条。"

## 5. Usage-Utility Retire Signal (honest approximation)

**问题**:在文件系统上无法像 SkillOps 那样精确追踪"最近多少次任务真的用了这条 entry"。

**近似方案**:
- 在每次 distillation_loop step1(读 journal)和 step0_5(handoff 创建 knowledge reload)时:
  记录"本次任务匹配了哪些 _index.md entry"到 `evidence/knowledge-usage-log.jsonl`
  格式:`{"date":"2026-06-22","handoff":"xxx","matched_labels":["bgm-loop-seam","tts-ref"]}`
- `*knowledge-maintain` 运行时:读最近 N 条(default 20)usage-log,统计 label 出现频率
  - 0 次 match in last 20 tasks → 标注 "[LOW-USAGE — 最近 20 个任务未匹配]"
  - 不自动删除;只标注,人决定

**已知限制(诚实列出)**:
- 不覆盖 **Blake 的 `1_5_context_refresh`**(最频繁的自动加载路径——每个任务都跑,keyword match 加载 pattern 文件)。要覆盖需在 Blake SKILL 加一行 log emit,但那是跨 agent 写入,本 phase 不做(protocol 边界)。
- 不覆盖人直接 Read 文件。
- 因此 usage 信号**显著低估**被 Blake 频繁加载的 entry。LOW-USAGE 标注仅供参考,不能作为 retire 的唯一依据。

## 5b. Dedup Health Metric (over-ADD 预警)

在 `*knowledge-maintain` 运行时,附加一个 entry-count 健康检查:
```bash
for f in "$DIR"/*.md "$DIR"/patterns/*.md; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  [[ "$base" == "README.md" || "$base" == "_index.md" ]] && continue
  count=$(grep -c '^### ' "$f" 2>/dev/null || echo 0)
  if [ "$count" -gt 30 ]; then
    echo "WARN: $base has $count entries (>30) — consider manual consolidation review"
  fi
done
```
超 30 条 = over-ADD 的先导信号(lexical 候选选择漏掉了近义重复)。WARN 级,不阻塞。

## 6. Lint Integration

运行 `knowledge-lint.sh` 对 project-knowledge/ 所有 entry 做格式检查。
详见脚本(§3.2)。结果展示给用户,不阻塞。
```

### 3.2 Soft Lint 脚本

**创建**:`.tad/hooks/lib/knowledge-lint.sh`

**规格**:

```bash
#!/usr/bin/env bash
# knowledge-lint.sh — soft lint for playbook entries
# ALWAYS exits 0 (never blocks). Reports violations to stdout.
# Usage: bash .tad/hooks/lib/knowledge-lint.sh [directory]
# Default directory: .tad/project-knowledge/

set -euo pipefail

DIR="${1:-.tad/project-knowledge}"
VIOLATIONS=0

# Scan all .md files (except README.md, _index.md, principles.md)
for file in "$DIR"/*.md "$DIR"/patterns/*.md; do
  [ -f "$file" ] || continue
  base=$(basename "$file")
  [[ "$base" == "README.md" || "$base" == "_index.md" || "$base" == "principles.md" ]] && continue

  # Check 1: failure_mode present in entries that have ### headers
  entry_count=$(grep -c '^### ' "$file" 2>/dev/null || echo 0)
  if [ "$entry_count" -gt 0 ]; then
    fm_count=$(grep -ciE 'failure.mode|naive.default|错误默认' "$file" 2>/dev/null || echo 0)
    if [ "$fm_count" -eq 0 ]; then
      echo "WARN: $file — $entry_count entries but 0 failure_mode mentions"
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  fi

  # Check 2: relative time words (⚠️ no \b — BSD grep on macOS doesn't support it; use bracket-class)
  rel_time=$(grep -niE '(^|[^a-zA-Z])today([^a-zA-Z]|$)|(^|[^a-zA-Z])recently([^a-zA-Z]|$)|(^|[^a-zA-Z])yesterday([^a-zA-Z]|$)|last week|今天|最近|上次|昨天' "$file" 2>/dev/null || true)
  if [ -n "$rel_time" ]; then
    echo "WARN: $file — relative time detected:"
    echo "$rel_time" | head -3
    VIOLATIONS=$((VIOLATIONS + 1))
  fi

  # Check 3: ALL-CAPS MUST/NEVER/ALWAYS on non-SAFETY entries
  # Skip files that are entirely SAFETY (principles.md already excluded)
  must_lines=$(grep -nE '\b(MUST|NEVER|ALWAYS)\b' "$file" 2>/dev/null || true)
  if [ -n "$must_lines" ]; then
    # Filter out lines that also contain SAFETY marker
    non_safety_musts=$(echo "$must_lines" | grep -viE 'SAFETY|read_only' || true)
    if [ -n "$non_safety_musts" ]; then
      echo "INFO: $file — ALL-CAPS imperative on non-SAFETY entry (yellow flag per Anthropic rule):"
      echo "$non_safety_musts" | head -3
      # INFO not WARN — it's a yellow flag, not a violation
    fi
  fi
done

echo ""
echo "knowledge-lint: $VIOLATIONS warnings found"
exit 0  # ALWAYS exit 0
```

**关键约束**:
- `exit 0` always(不注册 hook,不阻塞任何操作)
- 只读(不修改任何文件)
- 三个检查:failure_mode 缺失(WARN)、相对时间(WARN)、全大写 MUST on 非-SAFETY(INFO)
- 排除 README/\_index/principles(它们不是 playbook entry)

### 3.3 Alex SKILL.md 改动

在 `commands:` 段加一个新命令:

```yaml
knowledge-maintain: "Run knowledge maintenance — hash-dedup, reconcile against existing, lint, usage-retire signal"
```

在 SKILL body 加触发规则(不只放 reference,防 circular-trigger):

```yaml
knowledge_maintain_protocol:
  trigger: "*knowledge-maintain 或 distillation_loop step6 完成后自动触发"
  blocking: false
  reference: ".claude/skills/alex/references/knowledge-maintain-protocol.md"
  load_when: "When *knowledge-maintain is invoked or after distillation_loop step6 completes"
```

### 3.4 Usage Log 目录

**创建**:`.tad/evidence/knowledge-usage-log.jsonl`(空文件,首次 append 时写入)

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/skills/alex/references/knowledge-maintain-protocol.md   # 维护协议(6 步)
.tad/hooks/lib/knowledge-lint.sh                                # 软 lint(3 检查,exit 0)
.tad/evidence/knowledge-usage-log.jsonl                         # usage 日志(空,首写时 append)
```
### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md    # 加 *knowledge-maintain 命令 + 触发规则
```

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist

| # | AC | Verification Type | Verification Method | Expected | Verified Output |
|---|-----|-------------------|---------------------|----------|-----------------|
| 1 | maintain-protocol reference 存在 | post-impl | `test -f .claude/skills/alex/references/knowledge-maintain-protocol.md && echo OK` | OK | (post-impl) |
| 2 | protocol 含 6 步(Hash→Candidate→Reconcile→Gate→Usage→Lint) | post-impl | `grep -cE '^## [0-9]+\.' .claude/skills/alex/references/knowledge-maintain-protocol.md` | 6 | (post-impl) |
| 3 | 和解有 4 操作(ADD/UPDATE/DELETE/NOOP) | post-impl | `grep -oE '(ADD\|UPDATE\|DELETE\|NOOP)' .claude/skills/alex/references/knowledge-maintain-protocol.md \| sort -u \| wc -l` | 4 | (post-impl) |
| 4 | DELETE/UPDATE 标 human-gated | post-impl | `grep -iE '(DELETE\|UPDATE).*human\|human.*(DELETE\|UPDATE)\|AskUserQuestion' .claude/skills/alex/references/knowledge-maintain-protocol.md \| wc -l` | >= 2 | (post-impl) |
| 5 | lint 脚本存在 + 可执行 | post-impl | `test -f .tad/hooks/lib/knowledge-lint.sh && bash .tad/hooks/lib/knowledge-lint.sh 2>&1; echo $?` | 0 | (post-impl) |
| 6 | lint 始终 exit 0 | post-impl | `bash .tad/hooks/lib/knowledge-lint.sh; echo $?` | 0 | (post-impl) |
| 7 | **判别自检:故意残缺 entry → lint 抓到** | post-impl | 见 §10.2 | WARN 出现 | (post-impl) |
| 8 | **判别自检:完整 entry → lint 不误报** | post-impl | 见 §10.2 | 0 warnings for that file | (post-impl) |
| 9 | *knowledge-maintain 命令在 alex SKILL | post-impl | `grep -c 'knowledge-maintain' .claude/skills/alex/SKILL.md` | >= 2 | (post-impl) |
| 10 | 触发规则在 body 非纯 reference | post-impl | `grep -cE 'knowledge_maintain_protocol.*trigger\|trigger.*knowledge.maintain' .claude/skills/alex/SKILL.md` | >= 1 | (post-impl) |
| 11 | usage log 文件存在 | post-impl | `test -f .tad/evidence/knowledge-usage-log.jsonl && echo OK` | OK | (post-impl) |
| 12 | 无 hook/settings 注册 | post-impl | `git diff --name-only \| grep -cE '(settings\.json\|\.claude/settings)' \| head -1` | 0 | (post-impl) |

## 9.2 Expert Review Status

### Experts Selected
1. **code-reviewer** — lint 脚本 bash 正确性、AC 可执行性、shell 跨平台
2. **maintenance-design reviewer**(general-purpose) — 维护机制能否真正防退化、经济性、失败模式

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: `\b` word boundary 在 macOS BSD grep 不支持 | §3.2 Check 2 改 bracket-class `(^\|[^a-zA-Z])today([^a-zA-Z]\|$)` | Resolved |
| code-reviewer | P0-2: AC5 `--help` 测的是错东西(脚本无 --help handler) | §9.1 AC5 删 --help,改 exist+run | Resolved |
| code-reviewer | P0-3: `md5` 跨平台不一致 | §3.1 Step 1 改 `md5 -q` + 跨平台 fallback 注明 | Resolved |
| maintenance-design | P0-4: UPDATE 被人拒绝后无路径 → 默认 ADD = 造重复 | §3.1 Step 4 加 UPDATE/DELETE 拒绝路径(拒绝 → 仍 ADD + 报告共存) | Resolved |
| maintenance-design | P1-1: usage-utility 漏掉 Blake 1_5_context_refresh(最频繁加载路径) | §3.1 Step 5 known-limits 补充,诚实标注显著低估 | Resolved |
| maintenance-design | P1-2: over-ADD 无预警 → 重复静默累积 | §3.1 新增 Step 5b dedup health metric(>30 entries WARN) | Resolved |
| code-reviewer | P1-1: failure_mode grep 是 file-level 不是 per-entry | Noted — soft lint 的已知限制,文档化不修 | Noted |
| code-reviewer | P1-2: Check 3 SAFETY 过滤是 line-level(同行有 SAFETY 字样就排除) | Noted — INFO 级,影响低 | Noted |

### Overall Assessment
- **code-reviewer**: CONDITIONAL PASS → 3 P0 Resolved
- **maintenance-design**: CONDITIONAL PASS → 1 P0 + 2 P1 Resolved

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **lint exit 0 是硬约束**:即使检测到 100 个 WARN,也必须 exit 0。不注册为 hook。L1"reject-mechanical-enforcement"。
- ⚠️ **和解的 candidate-selection 是 lexical(弱)**:会漏掉措辞不同的重复 entry。接受 over-ADD,不伪装 semantic。
- ⚠️ **usage-utility 是近似**:只追踪 _index 匹配,不追踪直接 Read。标注 LOW-USAGE 但不自动 retire。

### 10.2 判别自检(Discriminative Self-Check)

Blake 必须在 completion evidence 中跑两个判别测试,证明 lint 不是 theater:

**阳性测试**(故意残缺):
```bash
# 创建临时 entry 缺 failure_mode
mkdir -p /tmp/lint-test && cat > /tmp/lint-test/test-bad.md << 'EOF'
### Bad Entry - 2026-06-22
- **Context**: testing
- **Discovery**: something
- **Action**: do something
EOF
bash .tad/hooks/lib/knowledge-lint.sh /tmp/lint-test
# 预期:WARN 出现(failure_mode 缺失)
```

**阴性测试**(完整):
```bash
cat > /tmp/lint-test/test-good.md << 'EOF'
### Good Entry - 2026-06-22
- **failure_mode**: Naive default is X, which causes Y
- **Context**: testing
- **Discovery**: something
- **Action**: do something on 2026-06-22
EOF
bash .tad/hooks/lib/knowledge-lint.sh /tmp/lint-test
# 预期:0 warnings for this file
```

两个测试结果都贴在 completion evidence 中。阳性不报 WARN = lint 是 theater = P0。

---

**Handoff Created By**: Alex · **Date**: 2026-06-22 · **Version**: 3.1.0
