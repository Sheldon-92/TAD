---
task_type: code        # Production hook script + keywords DB
e2e_required: no
research_required: no  # Phase 1 + 2a already did all research
---

# Handoff: Phase 2b — Keyword Router Hook (Architecture C)

**From:** Alex (Agent A — Solution Lead)
**To:** Blake (Agent B — Execution Master)
**Date:** 2026-04-07
**Project:** TAD Framework
**Task ID:** TASK-20260407-004
**Epic:** EPIC-20260407-domain-pack-reliable-loading.md (Phase 2b/4)
**Process Depth:** Standard TAD
**Architecture:** C — `type: command` hook + keyword matching (no LLM)
**Timebox:** **6 hours hard cap**(从 4h 上调 — 专家审查后 scope 增加)

## Expert Review Status

| Reviewer | Verdict | 关键 P0 | 修复状态 |
|----------|---------|---------|---------|
| code-reviewer | CONDITIONAL PASS | set -e conflict, locale, trim semantics, awk regex | ✅ |
| backend-architect | CONDITIONAL PASS | scoring normalization, generator quality, kill-switch, test set size | ✅ |

**Post-revision fixes**:
1. Scoring 改为 `matched/total_keywords` ratio + 显式 tie-break
2. Threshold 语义明确:每 pack 默认 2 个不同关键词(≥8 keywords pack),否则 1
3. 关键词唯一性约束:任一关键词最多出现在 2 个 pack,每 pack 至少 3 个唯一 anchor
4. Kill-switch:`TAD_DOMAIN_ROUTER=off` 或 `.router-disabled` 文件
5. 结构化 log:`.tad/hooks/.router.log`(单行,size-capped)
6. Generator 声明 English-only,Chinese 关键词必须手工 curate
7. 测试集 7 → 30+ cases(5 家族 × 6 cases:happy + 对抗 + 负面)
8. `yq` 调用 ≤2 次/请求(一次性 dump 到 bash 变量)
9. `set -euo pipefail` 改为 `set -uo` + `trap 'exit 0' ERR`
10. UTF-8 locale 强制(`export LC_ALL=en_US.UTF-8`)
11. Trim 语义修复(sed 前后去空白,删 5-char 门槛)
12. awk regex 锚定 `^[[:space:]]*$`(排除 4-space 嵌套)
13. 跨项目 sync 推迟到 Phase 3(Phase 2b TAD repo only)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1 spike-hook.sh 是直接模板,模式 100% 验证过 |
| Components Specified | ✅ | 4 个文件,每个职责明确 |
| Functions Verified | ✅ | hook stdin schema 已知(jq -r '.prompt'),Phase 1 hookSpecificOutput 格式已知 |
| Data Flow Mapped | ✅ | user msg → hook script → keyword score → top-1 → additionalContext → Alex |

**Gate 2**: ✅ PASS

---

## Expert Review Status

(待 Alex 在 step3 调用 2+ 专家审查后填写)

---

## 📋 Handoff Checklist

- [ ] 阅读所有章节
- [ ] **阅读 §📚 Project Knowledge**(Phase 1 + 2a 的所有 hook 教训)
- [ ] 阅读 Phase 1 spike-hook.sh(`.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/spike-hook.sh`)— 这是直接模板
- [ ] 阅读 Phase 2a SPIKE-REPORT-PHASE2A.md §11(architecture.md update)和 §12(Phase 2b recommendations)
- [ ] 理解 Architecture A 已**死透**,**不要尝试 type:prompt**
- [ ] 理解 Architecture C 是确定性的:**没有 LLM 调用,纯 bash + grep**

---

## 1. Task Overview

### 1.1 What We're Building

一个生产级 `type: command` UserPromptSubmit hook,用关键词匹配判断用户输入是否与某个 Domain Pack 相关,并向 Alex/Blake 注入 system-reminder 提示加载对应 pack。**完全不调用 LLM**。

### 1.2 Why We're Building It

**业务价值**:解决"Alex/Blake 不会主动加载 Domain Pack"的根本问题。Phase 2a 证明了 type:prompt 不能用于注入,Architecture C 是用户选定的方案 — 零延迟、零成本、零依赖。

**用户受益**:每次任务自动获得对应领域的专业指导。每条消息延迟 < 100ms(grep 比 LLM 快几十倍)。

**成功的样子**:用户输入"做一个 React button 组件",hook 在 50ms 内提示 Alex Read web-frontend pack。Alex 开始响应时已经加载了 pack 内容。

### 1.3 Intent Statement

**真正要解决的问题**:让 Domain Pack 加载从"靠 LLM 自觉" → "靠系统强制",**且不引入 UX 延迟**。

**不是要做的**:
- ❌ 不是写 LLM 分类器(Architecture A 死了,不要去碰)
- ❌ 不是给用户加新功能(用户感知不到 hook 存在)
- ❌ 不是改 Domain Pack 内容
- ❌ 不是 100% 准确率(关键词匹配本身就是模糊的,接受 80% 准确率)
- ❌ 不需要 ANTHROPIC_API_KEY
- ❌ 不需要 intent context routing(用户已确认不需要)
- ❌ 不需要 skill 检查点强化(留给 Phase 3 看真实使用情况再决定)

**Blake 请确认理解**:

```
开始前用你自己的话回答:
1. 这个 hook 解决什么问题?
2. 为什么 Architecture C 不能用 type:prompt?
3. 关键词怎么从 .tad/domains/*.yaml 里来?
```

---

## 📚 Project Knowledge (Blake 必读)

**⚠️ MANDATORY READ**:开始实现前必须 Read `.tad/project-knowledge/architecture.md`,以下条目直接相关:

| 条目 | 来源 | 关键提醒 |
|------|------|---------|
| **UserPromptSubmit Hook Verified** (含 Phase 2a sub-finding) | architecture.md | **type:command 是唯一支持注入的类型**;stdin payload 含 `prompt` 字段;Haiku 总 wrap fence(本 hook 不调 Haiku 故无关) |
| **Spike-Driven Epic De-Risking** | architecture.md | Phase 2a 的方法论 |
| **Hook Shell Portability** | architecture.md, 2026-04-03 | **不要用 grep -P**(BSD 不支持 Perl regex)|
| **Hook Path Matching** | architecture.md, 2026-04-02 | hook glob 用 `*.tad/` 不是 `*/.tad/` |
| **Claude Code Native Mechanism Validation** | architecture.md, 2026-03-31 | hook event 名 PascalCase |
| **Claude Code Enforcement Priority Order** | architecture.md, 2026-03-31 | hook 在 deny 之后,不要假设最高优先级 |

### Blake 确认

- [ ] 我已读上述知识
- [ ] 我理解所有 bash 必须 BSD-compatible(macOS)
- [ ] 我理解 Architecture A(type:prompt)在 Phase 2a 已被证明不可行,**绝不尝试**

---

## 2. Background Context

### 2.1 Phase 1 + 2a Provided Foundation

| 已知 | 来源 | Phase 2b 怎么用 |
|------|------|---------------|
| `type: command` UserPromptSubmit hook 触发 | Phase 1 spike-hook.sh | 直接模板,复制结构 |
| stdin payload schema:`{session_id, transcript_path, cwd, permission_mode, hook_event_name, prompt}` | Phase 2a sentinel-p1b.log | `jq -r '.prompt'` 拿 user message |
| `hookSpecificOutput.additionalContext` 注入工作 | Phase 1 (3/3 MARKER_SEEN) | 输出格式直接照抄 spike-hook.sh |
| Haiku-4.5 准确率 93.75%(理想情况下)| Phase 1 | 关键词匹配能达到的目标参考 |
| `type: prompt` 不支持注入 | Phase 2a | **不要走这条死路** |

### 2.2 现有 hook 资产可复用

```bash
.tad/hooks/lib/common.sh                    # output_response, read_stdin_json 等 helpers
.tad/hooks/startup-health.sh                # additionalContext 注入参考
.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/spike-hook.sh  # 30 行模板
```

Phase 1 spike-hook.sh 已经做了 90% 的工作 — 你只需要把 hardcoded marker 换成 keyword matching 逻辑。

### 2.3 Dependencies

- Claude Code ≥ 2.1.92
- bash, jq, grep(BSD-compatible)
- 不需要 ANTHROPIC_API_KEY
- 不需要 Python / curl / 任何 LLM 工具

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: 在 `.claude/settings.json` 添加 UserPromptSubmit hook,`type: command`(永久,不是 spike)
- **FR2**: 创建 `.tad/hooks/userprompt-domain-router.sh` — 主 hook 脚本
- **FR3**: 创建 `.tad/hooks/keywords.yaml` — 20 packs 的关键词数据库
- **FR4**: 创建 `.tad/hooks/generate-keywords.sh` — 一次性脚本,从 `.tad/domains/*.yaml` 自动生成 keywords.yaml 的初版
- **FR5**: Hook 脚本必须:
  - **Kill-switch 首先检查**(P0-S3):`[ "${TAD_DOMAIN_ROUTER:-on}" = "off" ] && exit 0`;`[ -f "$SCRIPT_DIR/.router-disabled" ] && exit 0`
  - **UTF-8 locale**(P0-C2):`export LC_ALL=en_US.UTF-8 2>/dev/null || export LC_ALL=C.UTF-8 2>/dev/null || true`
  - **Error handling**(P0-C1):`set -uo pipefail`(**无 -e**)+ `trap 'exit 0' ERR`
  - 从 stdin 读 JSON,用 `jq -r '.prompt // empty'` 拿 user message
  - **Trim only leading/trailing whitespace**(P0-C3):`MSG=$(printf '%s' "$USER_MSG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')`
  - **不用 `${#var}` 短 gate**(CJK byte vs char bug),直接 whitelist case 检查
  - 应用 whitelist pre-filter(yes/no/ok/y/n/继续/嗯/明白/收到/好的)→ 早退
  - **yq ≤ 2 次调用**(P1-4):`ALL_PACKS_JSON=$(yq -o=json . "$KEYWORDS_FILE" 2>/dev/null || echo '{}')` 一次性 dump,后续用 `jq` 在 bash 里处理
  - 对每个 pack 计算 **normalized score = matched_distinct_keywords / total_keywords_in_pack**(P0-S1,解决大 list 偏向)
  - **阈值语义明确**(P0-S1):`threshold` = 匹配的**不同关键词最小数量**(不是 ratio)。默认 2(≥8 keywords pack),1(< 8 keywords pack)
  - 选 top-1 pack(score ≥ threshold AND ratio 最高)
  - **Tie-break**(P0-S1):ratio 相同 → 选 pack 名字母序靠前(确定性)
  - **结构化 log**(P0-S3):每次调用追加一行到 `.tad/hooks/.router.log`,格式 `{timestamp} {elapsed_ms} {matched_pack|none} {ratio} {input_length_bytes}`。文件 > 1MB 时 rotate。**不记录 prompt 内容**(privacy)
  - 输出 hookSpecificOutput JSON,中文 reminder:"⚠️ 检测到任务匹配 Domain Pack [X]。请 Read .tad/domains/X.yaml 加载 capability 后再响应。"
  - 总是 `exit 0`(ERR trap 兜底)
- **FR6**: keywords.yaml schema:
  ```yaml
  # ⚠️ 关键词质量规则 (P0-S2):
  # - 任一关键词最多出现在 2 个 pack (强制判别性)
  # - 每 pack 至少 3 个 unique anchor (零 cross-pack 冲突)
  # - 最短长度:英文 3 字符,中文 2 字符
  # - 禁止 high-collision 词:build, code, test, project, system, api, design, tool, file, data
  whitelist:                     # (P2-2) 早退白名单,用户可编辑
    - yes
    - no
    - ok
    - 继续
    - 嗯
    - 明白
    - 收到
    - 好的
  packs:
    - name: web-frontend
      file: .tad/domains/web-frontend.yaml
      keywords:
        - "react"
        - "组件"
        - "jsx"
        - "tsx"
        - "useState"
        - "前端"
        - "frontend"
        - "props"
      threshold: 2               # 必须 ≥2 个不同关键词命中
  ```
- **FR7**: generate-keywords.sh 必须:
  - ⚠️ **English-only heuristic**(P0-S2):`tr` 对 CJK 不可靠,**不尝试**生成中文关键词。草稿只包含英文候选,中文必须**人工手工添加**
  - 读取 `.tad/domains/*.yaml`(20 个 packs,排除 tools-registry 和 HOW-TO-CREATE-DOMAIN-PACK)
  - 提取每个 pack 的 description + capabilities 名称 + capability descriptions
  - **严格 awk anchor**(P0-C4):`/^[[:space:]]*$/` 排除 4-space 嵌套字段,只匹配 2-space 顶层 capability 名
  - English 启发式:tokenize → lowercase → 停用词过滤(含高频冲突词)→ 去重
  - 输出 `.tad/hooks/keywords.yaml.draft`,不覆盖 keywords.yaml
  - **Idempotent `--append-missing-only` 模式**(P1-2):跳过已在 keywords.yaml 中的 pack
  - Script header 声明:"English heuristic only. Chinese keywords MUST be hand-added after generation. Deduplication audit required before use."

### 3.2 Non-Functional Requirements

- **NFR1**: Hook 平均延迟 < 100ms(grep 应该 < 50ms,jq 解析 < 30ms)
- **NFR2**: 准确率 ≥ 70%(关键词匹配的合理目标,低于 LLM 但够用)
- **NFR3**: 不需要任何 API key
- **NFR4**: BSD-compatible bash(macOS)
- **NFR5**: 现有 PreToolUse Write|Edit hook 不能受影响
- **NFR6**: keywords.yaml 维护成本低 — 加新 pack 时只需在 yaml 里加一条
- **NFR7**: 工作量 ≤ 4h,超时升级

---

## 4. Technical Design

### 4.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ User: "做一个 React button 组件"                         │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Claude Code: UserPromptSubmit fires                    │
│ Calls .tad/hooks/userprompt-domain-router.sh           │
│ stdin = {"session_id":...,"prompt":"做一个...",...}     │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ userprompt-domain-router.sh                            │
│  1. INPUT=$(cat); MSG=$(jq -r '.prompt' <<< "$INPUT") │
│  2. Whitelist check:                                   │
│     case "$MSG" in yes|ok|继续|...) exit 0 ;; esac    │
│  3. Load keywords.yaml (yq or yaml-to-bash parser)     │
│  4. For each pack:                                     │
│       score = grep -c -i "$kw" <<< "$MSG"              │
│  5. Pick top-1 if score ≥ threshold                   │
│  6. Emit hookSpecificOutput JSON                       │
│  7. exit 0 (always)                                    │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Claude Code: parse hookSpecificOutput                  │
│ Inject additionalContext as system-reminder            │
└────────────────────┬───────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│ Alex/Blake (主对话):                                     │
│ "⚠️ 任务匹配 Domain Pack [web-frontend]。               │
│  Read .tad/domains/web-frontend.yaml 加载              │
│  component_development capability"                      │
└────────────────────────────────────────────────────────┘
```

### 4.2 Component Specifications

**Component 1: settings.json hook 配置**

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash '/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/userprompt-domain-router.sh'"
          }
        ]
      }
    ]
  }
}
```

⚠️ **注意**:
- Phase 1 spike 用了绝对路径 `bash '/abs/path/spike-hook.sh'`,本 hook 也用绝对路径
- `matcher: ""` 是 Phase 1 验证过的,继续用
- 这是**永久**修改,不是 spike — 必须 backup + JSON 校验 + smoke test

**Component 2: userprompt-domain-router.sh(主 hook 脚本)**

骨架(Blake 完成细节):

```bash
#!/bin/bash
# Domain Pack Router Hook — keyword-based classification
# Architecture C: no LLM, deterministic, BSD-compatible
# Always exit 0 — failures degrade to no-injection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYWORDS_FILE="${SCRIPT_DIR}/keywords.yaml"

# === Read user message from stdin ===
INPUT=$(cat 2>/dev/null || echo '{}')
USER_MSG=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

# Empty/missing prompt → no-op
[ -z "$USER_MSG" ] && exit 0

# === Pre-filter: whitelist short/affirmation messages ===
# Trim and lowercase for matching
MSG_TRIMMED=$(printf '%s' "$USER_MSG" | tr -d '[:space:]')
MSG_LOWER=$(printf '%s' "$MSG_TRIMMED" | tr '[:upper:]' '[:lower:]')

case "$MSG_LOWER" in
  yes|no|ok|y|n|继续|嗯|明白|收到|好的|"")
    exit 0
    ;;
esac

# Optional: skip very short messages (< 5 chars after trim)
[ ${#MSG_TRIMMED} -lt 5 ] && exit 0

# === Load keywords and score each pack ===
# Use yq if available, fallback to manual parser
# (Blake's choice — yq is simplest if installed)

if ! command -v yq >/dev/null 2>&1; then
  # Fallback: keywords.yaml not parseable without yq
  # In production, document yq as a dependency
  exit 0
fi

# Read all packs into a structured form
# (Pseudo — Blake writes the actual loop)
BEST_PACK=""
BEST_SCORE=0

while read -r PACK_NAME; do
  # Get keywords for this pack
  KEYWORDS=$(yq -r ".packs[] | select(.name == \"$PACK_NAME\") | .keywords[]" "$KEYWORDS_FILE")
  THRESHOLD=$(yq -r ".packs[] | select(.name == \"$PACK_NAME\") | .threshold // 1" "$KEYWORDS_FILE")

  # Score = count of distinct keywords matching (case-insensitive)
  SCORE=0
  while read -r KW; do
    if printf '%s' "$USER_MSG" | grep -qi -F "$KW"; then
      SCORE=$((SCORE + 1))
    fi
  done <<< "$KEYWORDS"

  # Track best
  if [ "$SCORE" -ge "$THRESHOLD" ] && [ "$SCORE" -gt "$BEST_SCORE" ]; then
    BEST_SCORE=$SCORE
    BEST_PACK=$PACK_NAME
  fi
done < <(yq -r '.packs[].name' "$KEYWORDS_FILE")

# === Emit hookSpecificOutput if match ===
if [ -n "$BEST_PACK" ]; then
  PACK_FILE=$(yq -r ".packs[] | select(.name == \"$BEST_PACK\") | .file" "$KEYWORDS_FILE")
  REMINDER="⚠️ Domain Pack match: [$BEST_PACK] (keyword score: $BEST_SCORE). Read $PACK_FILE before responding to load relevant capability and quality_criteria."

  jq -n --arg ctx "$REMINDER" \
    '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}'
fi

exit 0
```

**关键约束**:
- BSD compat:`grep -i -F`(fixed string + case-insensitive),不用 `-P`
- jq 用 `-r` + `// empty` 防 null
- 任何失败路径都 `exit 0`(set -euo pipefail 配 trap if needed)

**Component 3: keywords.yaml(关键词数据库)**

```yaml
# Auto-generated initial version by generate-keywords.sh
# Reviewed and curated by user
# Update when adding new packs

packs:
  - name: web-frontend
    file: .tad/domains/web-frontend.yaml
    keywords:
      - "react"
      - "vue"
      - "组件"
      - "component"
      - "前端"
      - "frontend"
      - "ui"
      - "useState"
      - "props"
      - "tsx"
      - "jsx"
    threshold: 1

  - name: web-backend
    file: .tad/domains/web-backend.yaml
    keywords:
      - "api"
      - "rest"
      - "graphql"
      - "数据库"
      - "database"
      - "后端"
      - "backend"
      - "endpoint"
      - "schema"
    threshold: 1

  # ... 18 more packs (total 20)
```

**关键设计**:
- 每个 pack 5-15 个关键词
- 中英混合(用户可能用任一种)
- threshold 通常 1(只要任一关键词命中就算 hit),特殊 pack 可调高
- file 字段是 pack YAML 的相对路径(reminder 中使用)

**Component 4: generate-keywords.sh(一次性生成器)**

```bash
#!/bin/bash
# One-shot script: generate keywords.yaml.draft from .tad/domains/*.yaml
# Output: .tad/hooks/keywords.yaml.draft
# User reviews + manually moves to keywords.yaml

set -euo pipefail

DOMAINS_DIR=".tad/domains"
OUTPUT="$(dirname "$0")/keywords.yaml.draft"

echo "# Auto-generated $(date +%F) — REVIEW BEFORE USING" > "$OUTPUT"
echo "packs:" >> "$OUTPUT"

for f in "$DOMAINS_DIR"/*.yaml; do
  base=$(basename "$f" .yaml)
  [ "$base" = "tools-registry" ] && continue
  [ "$base" = "HOW-TO-CREATE-DOMAIN-PACK" ] && continue

  # Extract description
  DESC=$(grep -m1 '^description:' "$f" | sed 's/description:[[:space:]]*//;s/"//g' | cut -c1-200)

  # Extract capability names (all lines like "  cap_name:" under capabilities:)
  CAPS=$(awk '/^capabilities:/{flag=1; next} /^[a-z]/{flag=0} flag && /^  [a-z_]+:/{gsub(/[: ]/, ""); print}' "$f")

  # Extract keywords from description + capability names
  # Heuristic: split by spaces/punctuation, lowercase, dedupe, filter stopwords
  KEYWORDS=$(printf '%s\n%s\n' "$DESC" "$CAPS" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -s '[:space:][:punct:]' '\n' \
    | grep -v -E '^(the|a|an|is|are|of|to|for|with|and|or|in|on|at|by|from|as|that|this)$' \
    | grep -v '^.\{0,2\}$' \
    | sort -u)

  echo "  - name: $base" >> "$OUTPUT"
  echo "    file: $f" >> "$OUTPUT"
  echo "    keywords:" >> "$OUTPUT"
  while read -r kw; do
    [ -z "$kw" ] && continue
    echo "      - \"$kw\"" >> "$OUTPUT"
  done <<< "$KEYWORDS"
  echo "    threshold: 1" >> "$OUTPUT"
done

echo ""
echo "Generated: $OUTPUT"
echo "Review and manually move to keywords.yaml when satisfied"
```

⚠️ **生成器是启发式的,初版关键词会有噪声**。用户(Alex/human)review 后手工调整。

### 4.3 Settings.json Safety (P0 from Phase 2 review)

永久修改 settings.json 必须:

```bash
# Pre-edit
cp .claude/settings.json .claude/settings.json.phase2b-backup-$(date +%s)

# Edit (Blake choice: jq, manual, or sed)
# ...

# Validate
jq . .claude/settings.json > /dev/null || {
  echo "JSON invalid — restore"
  cp .claude/settings.json.phase2b-backup-* .claude/settings.json
  exit 1
}

# Verify PreToolUse hooks preserved
diff <(jq -S '.hooks.PreToolUse' .claude/settings.json) \
     <(jq -S '.hooks.PreToolUse' .claude/settings.json.phase2b-backup-*) \
  || { echo "PreToolUse mutated — restore"; exit 2; }
```

---

## 5. 强制问题回答

### MQ1: 历史代码搜索

```bash
# 现有 hook 资产
ls .tad/hooks/
ls .tad/hooks/lib/
cat .tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/spike-hook.sh

# Phase 2a 的 stdin schema
cat .tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/sentinel-p1b.log
```

记录:Phase 1 spike-hook.sh 的输出格式 + Phase 2a stdin schema 中 prompt 字段的真实形式。

### MQ2: 函数/机制存在性验证

| 验证 | 命令 | 预期 |
|-----|------|------|
| `jq` 可用 | `command -v jq` | 路径输出 |
| `yq` 可用(关键!) | `command -v yq` | 路径输出 |
| 如 yq 缺失 | 决定:让 generator 失败并提示用户安装,OR 写 awk fallback | Blake 决定 |
| `grep -i -F` BSD 兼容 | `echo "Test" \| grep -iF "test"` | 输出 Test |

### MQ3-5: 不适用(无前后端数据流、无 UI、无多状态同步)

---

## 6. Implementation Steps

### Phase 1: Foundation (~1.5h,milestone T+1.5h) — **扩大了,P0-S2 修复**

#### 交付物
- [ ] `.tad/hooks/generate-keywords.sh`(含 English-only 声明 + idempotent 模式)
- [ ] `.tad/hooks/keywords.yaml.draft`(generator 产物,英文 only)
- [ ] `.tad/hooks/keywords.yaml`(最终版,Blake 深度 curated 含中文 + 唯一性检查)

#### 步骤
1. Read Phase 1 spike-hook.sh + Phase 2a sentinel-p1b.log
2. Read all `.tad/domains/*.yaml`(20 packs)description + capabilities
3. 写 generate-keywords.sh:严格 awk anchor(§4.2 Component 4),English-only heuristic,扩展停用词
4. 跑 generator → keywords.yaml.draft
5. **Blake 深度 curation**(不是"快速 review"):
   - **去冲突审计**(blocking):任一关键词出现在 > 2 个 packs → 删或做具体化。用脚本辅助:
     ```bash
     yq -o=json . keywords.yaml.draft | jq '[.packs[] | {name, keywords}] | ...'
     # 找出任何出现 > 2 次的词
     ```
   - **添加中文关键词**:每个 pack 必须至少 3 个中文关键词
   - **添加 unique anchor**:每个 pack 至少 3 个只出现在此 pack 的关键词
   - **threshold 调整**:≥8 keywords → threshold 2;否则 1
   - **删高冲突词**:build, code, test, project, system, api, design, tool, file, data(除非是该 pack 的核心指代)
6. 手工检验每个 pack:拿 2 个测试 user message(典型 + 对抗)在心里跑一遍 match
7. mv draft 到 keywords.yaml

### Phase 2: Hook Script (~1.5h,milestone T+3h)

#### 交付物
- [ ] `.tad/hooks/userprompt-domain-router.sh`(executable,含 kill-switch + log + UTF-8 locale)

#### 步骤
1. 复制 spike-hook.sh 作为骨架
2. 在顶部加:
   - `export LC_ALL=en_US.UTF-8 2>/dev/null || export LC_ALL=C.UTF-8 2>/dev/null || true`
   - `set -uo pipefail`(不加 -e)
   - `trap 'exit 0' ERR`
   - Kill-switch 检查(§4.2 Component 2)
3. 实现 §4.2 Component 2 的逻辑:
   - stdin 读取 + `jq -r '.prompt // empty'`
   - `sed` trim(不是 `tr -d`)
   - whitelist case(不加 `${#var}` byte-length gate)
   - **一次性** `yq -o=json ... | jq` dump keywords 到 bash 变量
   - per-pack normalized scoring(ratio = matches / total)
   - threshold + top-1 + alphabetical tie-break
   - hookSpecificOutput 输出
   - 结构化 log 追加 + rotate (> 1MB)
4. `chmod +x`
5. **扩展 unit smoke tests**(P1-5 要求,覆盖 §8.3 edge cases):
   ```bash
   # 正常 match
   echo '{"prompt":"做一个 React 组件"}' | bash .tad/hooks/userprompt-domain-router.sh
   # whitelist 早退
   echo '{"prompt":"yes"}' | bash .tad/hooks/userprompt-domain-router.sh
   # 无 match
   echo '{"prompt":"今天天气"}' | bash .tad/hooks/userprompt-domain-router.sh
   # empty stdin
   printf '' | bash .tad/hooks/userprompt-domain-router.sh
   # malformed JSON
   printf 'not json' | bash .tad/hooks/userprompt-domain-router.sh
   # missing prompt field
   echo '{}' | bash .tad/hooks/userprompt-domain-router.sh
   # null prompt
   echo '{"prompt":null}' | bash .tad/hooks/userprompt-domain-router.sh
   # Chinese-only
   echo '{"prompt":"做一个按钮组件"}' | bash .tad/hooks/userprompt-domain-router.sh
   # shell metachar injection test
   echo '{"prompt":"test `rm -rf /tmp/nothere`"}' | bash .tad/hooks/userprompt-domain-router.sh
   # verify no files deleted, no command execution
   ```
6. **行为测试**(P1-6 替代 AC10):
   ```bash
   for bad in 'not json' '' '{"prompt":null}' '{"prompt":""}' '{}'; do
     printf '%s' "$bad" | bash .tad/hooks/userprompt-domain-router.sh
     [ $? -eq 0 ] || { echo "FAIL on: $bad"; exit 1; }
   done
   ```
7. **Latency 测量**(P2-1):
   ```bash
   for i in 1 2 3 4 5; do
     /usr/bin/time -p bash -c 'echo "{\"prompt\":\"做一个 React 组件\"}" | bash .tad/hooks/userprompt-domain-router.sh' 2>&1 | grep real
   done
   # 中位数 < 200ms (AC12)
   ```

### Phase 3: settings.json Integration (~30 min,milestone T+3.5h)

#### 交付物
- [ ] `.claude/settings.json` 含新 UserPromptSubmit hook
- [ ] `diff` 验证 PreToolUse 不变

#### 步骤
1. **Backup 用变量捕获**(P1-4 修复):
   ```bash
   BACKUP=".claude/settings.json.phase2b-backup-$(date +%s)"
   cp .claude/settings.json "$BACKUP"
   # 全程用 $BACKUP 引用,不要 glob
   ```
2. 加 UserPromptSubmit hook 到 hooks 字段(§4.2 Component 1)
3. `jq . .claude/settings.json >/dev/null` 验证
4. `diff` 验证 PreToolUse 部分未变(用 $BACKUP)
5. 启动新 terminal + `claude`(interactive),smoke test:
   - 输入 "做一个 React 组件" → Alex 应被注入 reminder
   - 输入 "yes" → 无 reminder(早退)
   - 验证 `.tad/hooks/.router.log` 有记录
6. 失败则 `cp "$BACKUP" .claude/settings.json`
7. **⚠️ 不 `*sync` 到其他项目**(P0-S3 rollout):Phase 2b 只在 TAD 主项目生效,跨项目推广是 Phase 3 决定

### Phase 4: Integration Test (~1.5h,milestone T+5h) — **扩大到 30 cases,P0-S4 修复**

#### 交付物
- [ ] `.tad/evidence/phase2b-integration-test.md` 含 30 场景结果

#### 30 个测试场景(5 family × 6 cases 结构)

**Family 1: Web(6 cases)**:
| # | 输入 | 预期 |
|---|------|------|
| 1 | "做一个 React button 组件" | web-frontend ✅ |
| 2 | "我想加一个登录 API 端点用 Express" | web-backend ✅ |
| 3 | "Vue 组件的 props 传递怎么做" | web-frontend ✅ |
| 4 | "PostgreSQL 索引优化" | web-backend ✅ |
| 5 | "需要一套设计系统 tokens" | web-ui-design ✅ |
| 6 | **对抗**: "网页上显示一个按钮列表,后端也要返回数据" | web-frontend OR web-backend(tie-break 验证)|

**Family 2: Mobile(6 cases)**:
| # | 输入 | 预期 |
|---|------|------|
| 7 | "iOS App 的导航栏用 SwiftUI 怎么做" | mobile-ui-design ✅(具体 pack 不是通配)|
| 8 | "React Native 测试 Detox 配置" | mobile-testing ✅ |
| 9 | "Android Release 到 Play Store 流程" | mobile-release ✅ |
| 10 | "为 iPhone App 加 Gesture 手势" | mobile-development ✅ |
| 11 | **对抗**: "移动端 performance 怎么测" | mobile-testing OR mobile-development |
| 12 | **负面**: "桌面应用 Electron" | NONE ❌ |

**Family 3: AI/ML(6 cases)**:
| # | 输入 | 预期 |
|---|------|------|
| 13 | "设计一个 RAG agent 架构" | ai-agent-architecture ✅ |
| 14 | "我的 prompt 总是漂移,怎么优化" | ai-prompt-engineering ✅ |
| 15 | "如何评估 agent 的准确率" | ai-evaluation ✅ |
| 16 | "写一个 MCP server 集成" | ai-tool-integration ✅ |
| 17 | **对抗**: "agent 的 prompt 怎么设计防幻觉" | ai-prompt-engineering OR ai-agent-architecture |
| 18 | **负面**: "chatgpt 和 claude 哪个好" | NONE ❌(纯闲聊)|

**Family 4: Security(6 cases)**:
| # | 输入 | 预期 |
|---|------|------|
| 19 | "审查一下这段代码有没有 SQL 注入" | code-security ✅ |
| 20 | "这个 npm 包能信任吗" | supply-chain-security ✅ |
| 21 | "生产环境密钥泄漏排查" | code-security ✅ |
| 22 | **对抗**: "依赖项有个 CVE,怎么评估" | supply-chain-security OR code-security |
| 23 | **负面**: "密码忘记了怎么办" | NONE ❌ |
| 24 | **负面**: "SSH key 用法基础" | NONE ❌(教学类非任务)|

**Family 5: Hardware(6 cases)**:
| # | 输入 | 预期 |
|---|------|------|
| 25 | "PCB 布线密度怎么算" | hw-circuit-design ✅ |
| 26 | "ESP32-S3 驱动 SSD1306 OLED" | hw-firmware ✅ |
| 27 | "3D 打印外壳公差设计" | hw-enclosure ✅ |
| 28 | "电路板上电测试流程" | hw-testing ✅ |
| 29 | **对抗**: "固件低功耗优化" | hw-firmware OR hw-circuit-design |
| 30 | **whitelist**: "yes" | (early exit)❌ |

#### 准确率门槛
- ≥ 21/30 = **70%**(NFR2 真目标)
- 正面案例(24 个)准确率 ≥ 17 = 71%
- 负面 + whitelist 案例(6 个)必须全对(= 6/6)
- 不达标 → 调 keywords.yaml 增删,重测,最多 2 轮

### Phase 5: Knowledge + Completion (~30 min,milestone T+4h hard cap)

- [ ] 写 completion report(`.tad/active/handoffs/COMPLETION-20260407-phase2b-keyword-router.md`)
- [ ] 含 architecture.md 知识条目草稿(如有新发现)

---

## 7. File Structure

### 7.1 Files to Create

```
.tad/hooks/userprompt-domain-router.sh        # 主 hook 脚本(executable)
.tad/hooks/generate-keywords.sh               # 一次性 keywords 生成器(executable)
.tad/hooks/keywords.yaml                      # 关键词 DB(20 packs)
.tad/hooks/keywords.yaml.draft                # generator 中间产物(可不 commit)
.tad/evidence/phase2b-integration-test.md     # 7 场景测试报告
.tad/active/handoffs/COMPLETION-20260407-phase2b-keyword-router.md
```

### 7.2 Files to Modify

```
.claude/settings.json   # 加 UserPromptSubmit type:command hook(永久)
```

⚠️ **不修改任何 skill 文件** — Phase 2b 不做 skill checkpoint(留 Phase 3 看真实使用情况再决定)。

---

## 8. Testing Requirements

### 8.1 Unit Smoke Tests (Phase 2 内)

3 个 echo-pipe 测试:
- 匹配场景
- whitelist 早退
- 无匹配

### 8.2 Integration Tests (Phase 4)

7 个真实场景(见 §6 Phase 4 表格)

### 8.3 Edge Cases

- [ ] Empty prompt(`{"prompt":""}`)→ exit 0,无注入
- [ ] Missing prompt 字段(`{}`)→ exit 0
- [ ] Malformed JSON stdin → exit 0(jq fail safe)
- [ ] Very long prompt(10k 字符)→ 不超时,正常匹配
- [ ] Emoji in prompt → 不 crash
- [ ] Multi-line prompt → 完整匹配
- [ ] yq 不存在 → exit 0(degrade gracefully,不阻塞 user)

---

## 9. Acceptance Criteria

- [ ] **AC1**: §7.1 列出的 6 个文件全部创建
- [ ] **AC2**: §7.2 列出的 1 个文件修改成功(settings.json)
- [ ] **AC3**: settings.json 是合法 JSON(`jq . .claude/settings.json > /dev/null`)
- [ ] **AC4**: PreToolUse hook 未被影响(`diff` 比对 backup)
- [ ] **AC5**: hook 脚本是 executable(`chmod +x` 已应用)
- [ ] **AC6**: keywords.yaml 包含 20 个 packs(`yq '.packs | length' keywords.yaml` = 20)
- [ ] **AC7**: 每个 pack 至少 5 个关键词
- [ ] **AC8**: Phase 2 unit smoke tests 全过(3 个 echo-pipe 场景)
- [ ] **AC9**: Phase 4 integration test 30 cases,准确率 ≥ 21/30 = 70%;正面 ≥ 17/24;负面/whitelist 6/6 全对
- [ ] **AC10 (behavioral, P1-6 替代)**: 喂 5 种坏输入,hook 全部 exit 0:
  ```bash
  for bad in 'not json' '' '{"prompt":null}' '{"prompt":""}' '{}'; do
    printf '%s' "$bad" | bash .tad/hooks/userprompt-domain-router.sh; [ $? -eq 0 ] || exit 1
  done
  ```
- [ ] **AC11**: BSD bash 兼容:无 `grep -P`/`-oP`,无 GNU-only `date -d`/`readlink -f`/`stat -c`;verified by grep
- [ ] **AC12**: hook median latency < 200ms(n=5 测量,Phase 2 步骤 7 数据)
- [ ] **AC13**: 工作量 ≤ 6h,超时升级
- [ ] **AC14**: completion report 含 Phase 2b → Phase 3 的输入
- [ ] **AC15 (P0-S1)**: Scoring 是 normalized ratio(不是 raw count),tie-break 按字母序,threshold 语义是"distinct keywords count",写在脚本注释里
- [ ] **AC16 (P0-S2)**: keywords.yaml 质量审计 — 任一关键词最多出现在 2 个 pack,每 pack ≥ 3 个 unique anchor,每 pack ≥ 3 个中文 AND ≥ 3 个英文关键词
- [ ] **AC17 (P0-S3)**: Kill-switch 工作 — 设 `TAD_DOMAIN_ROUTER=off` 或创建 `.router-disabled`,hook 必须立即 early exit(测试验证)
- [ ] **AC18 (P0-S3)**: 结构化 log `.tad/hooks/.router.log` 存在,每次调用 1 行,> 1MB 时 rotate;**不含 prompt 内容**(privacy check)
- [ ] **AC19 (P0-S3)**: Phase 2b **不运行 `*sync`** — TAD 主项目 only,跨项目推广留 Phase 3
- [ ] **AC20 (yq 优化)**: hook 脚本中 `yq` 调用 ≤ 2 次(用 `grep -c "yq " script` 验证;只有 initial dump 算,bash 处理不算)
- [ ] **AC21 (UTF-8)**: 脚本顶部有 `export LC_ALL` UTF-8 locale 设置
- [ ] **AC22 (set -e 修复)**: 脚本用 `set -uo pipefail`(无 `-e`)+ `trap 'exit 0' ERR`

---

## 9.1 Spec Compliance

| # | AC | Verification |
|---|----|----|
| AC1 | `ls .tad/hooks/userprompt-domain-router.sh .tad/hooks/keywords.yaml .tad/hooks/generate-keywords.sh` | 三个文件存在 |
| AC3 | `jq . .claude/settings.json > /dev/null` | exit 0 |
| AC4 | `diff <(jq -S '.hooks.PreToolUse' .claude/settings.json) <(jq -S '.hooks.PreToolUse' .claude/settings.json.phase2b-backup-*)` | 输出空 |
| AC5 | `[ -x .tad/hooks/userprompt-domain-router.sh ]` | true |
| AC6 | `yq '.packs \| length' .tad/hooks/keywords.yaml` | 20 |
| AC8 | smoke test 输出 | 见 Phase 2 步骤 |
| AC9 | integration test report 中 correct count | ≥ 5 |
| AC11 | `grep -nE "grep -P\|grep -oP\|sed -i [^']\|date -d \|readlink -f\|stat -c " .tad/hooks/userprompt-domain-router.sh .tad/hooks/generate-keywords.sh` | 无匹配 |

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ **不要尝试 type:prompt** — Phase 2a 已证明死路。本 hook **必须** type:command
- ⚠️ **settings.json 是 daily driver** — backup + jq validate + PreToolUse diff 三重保护
- ⚠️ **hook 必须永远 exit 0** — set -euo pipefail 配合显式 exit 0,任何失败都不阻塞 user
- ⚠️ **BSD bash compat** — 不要用 grep -P,不要用 GNU-only date/sed/readlink/stat 标志
- ⚠️ **绝对路径** — settings.json 中 hook command 用绝对路径(参考 Phase 1 spike-hook.sh)
- ⚠️ **yq 是潜在依赖** — 如果用户系统没有,fallback 必须 graceful(exit 0,不 crash)
- ⚠️ **keywords.yaml 是用户可编辑的** — 设计要让用户可以手工增删而不破坏结构
- ⚠️ **不要破坏现有 PreToolUse hook**(用户 daily driver)

### 10.2 Known Constraints

- 准确率 70% 是合理目标,不是 LLM 的 93%
- 关键词维护成本:加新 pack 要在 keywords.yaml 加一条
- 中英混合环境:keywords 必须包含中英两种(用户可能任一种)

### 10.3 Sub-Agent 使用建议

- [ ] **bug-hunter** — 如果 hook 在某个 edge case 行为诡异
- [ ] **test-runner** — 不严格适用(无传统单元测试)
- [ ] **parallel-coordinator** — 不适用

---

## 11. Decision Rationale

### 11.1 为什么 Architecture C 而不是 B?

| 维度 | B (command + claude -p) | C (keyword) |
|------|------------------------|------------|
| 延迟 | 4-7s/call(Phase 1 实测) | < 100ms |
| 智能度 | 高(LLM)| 中(关键词)|
| API key | 不需要(用 Max 套餐 OAuth)| 不需要 |
| UX 风险 | 高(用户一周后会拆)| 低 |
| 维护 | 几乎零(LLM 处理新 pack)| 加 pack 时维护 keywords |

**用户决策**:接受关键词维护成本以换取零延迟、零依赖。

### 11.2 为什么 Top-1 而不是 Top-N?

避免一次塞 5 个 pack reminder 给 Alex/Blake。Top-1 简洁、容易 review、低噪声。轻微跨 pack 任务可能漏一个,但 Phase 3 看真实数据再决定是否升级 Top-N。

### 11.3 为什么不做 intent context routing?

关键词匹配本身就是模糊的,*analyze 严格 vs *learn 宽松的区分价值不大 — 关键词命中就是命中,跟用户意图模式无关。Phase 2b 设计简化,跑一段时间看真实需求。

---

## 12. Sub-Agent 使用记录

(Blake 完成后填)

| Sub-Agent | 调用? | 时机 | 输出 |
|-----------|------|------|------|
| bug-hunter | ?/❌ | | |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-07
**Status**: Draft — pending expert review
