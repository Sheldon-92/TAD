# Handoff: 质量检查链修复 — SKILL.md 执行清单 + 补充 Hook

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-008
**Priority:** P0 — 质量系统系统性失效

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Problem

v2.7 精简 Blake SKILL.md 从 1052→283 行时，把质量流程的详细执行步骤当作"机械性指令"删除了。结果：
- Blake 跳过 Ralph Loop（承认了）
- Blake 跳过 E2E 测试（4 个 pack）
- Blake 跳过 Phase 1 研究（4 个 pack）
- Alex 验收不检查就放过

**根因**：流程执行规则被错误归类为"judgment-only 可删除"。Hook 只覆盖了几个检查点，覆盖不到研究和 E2E。

## 2. 两个修复

### Fix 1: Blake SKILL.md 加回执行清单

在 Blake SKILL.md 的 mandatory 区域下方，新增 **EXECUTION CHECKLIST** 节：

```yaml
# ═══════════════════════════════════════
# ⚠️ EXECUTION CHECKLIST — 不可精简
# 每次执行 *develop 前读一遍。跳过任何一条 = VIOLATION。
# ═══════════════════════════════════════

execution_checklist:
  description: "每个 handoff 必须按此清单检查。这不是建议，是强制要求。"

  before_start:
    - "读完 handoff 的所有 AC — 理解每个 BLOCKING 要求"
    - "确认所有 AC 都有实现计划（不能'先做完再说'）"
    - "如果某个 AC 你认为不适用 → PAUSE → 问人确认 → 不能自己决定跳过"

  during_development:
    layer1_self_check:
      code_tasks: "build + lint + tsc + test（全部 PASS 才继续）"
      yaml_tasks: "python3 yaml.safe_load + 结构验证 + 编造=FAIL 检查"
      research_tasks: "WebSearch 全部执行 + ≥3 仓库 + 5 维度提取"
      e2e_tasks: "如果 handoff 要求 E2E → 必须执行 → 结果写入 evidence"

    layer2_expert_review:
      - "调 code-reviewer sub-agent（P0=0 才通过）"
      - "如果 code-reviewer 发现 P0 → 修复 → 重新审查"
      - "不能跳过 Layer 2 说'代码简单不需要审查'"

    research_compliance:
      - "如果 handoff 有 Phase 1 研究要求 → 必须执行搜索 → 必须产出文件"
      - "不能用 LLM 知识替代搜索（'我已经知道了'不是跳过研究的理由）"
      - "搜索词必须全部执行 → Search Log 证明"

    e2e_compliance:
      - "如果 handoff 有 E2E 要求 → 必须执行 → 必须有 evidence 文件"
      - "不能自己决定'太简单不需要 E2E'"
      - "E2E 结果必须在 Gate 3 前写入 evidence"

  after_development:
    - "*complete 创建 COMPLETION report"
    - "/gate 3 正式质量检查（不能自己说 'Gate 3 Passed'）"
    - "Knowledge Assessment 填写（Yes/No 必须回答）"
    - "生成 Alex 消息"

  absolute_forbidden:
    - "❌ 不能自己决定跳过任何 handoff AC（必须问人）"
    - "❌ 不能为了速度跳过研究、E2E、Layer 2"
    - "❌ 不能在 agent prompt 里写 'skip Phase X'（这就是上次的问题）"
    - "❌ 不能在没有 evidence 的情况下声称 Gate 3 Passed"
    - "❌ 不能编造 GitHub URL 或仓库名"
```

### Fix 2: 补充 Hook

#### Hook A: Gate 3 前检查 E2E evidence

修改 `pre-gate-check.sh`，在 Gate 3 检查中增加：

```bash
# 现有：检查 COMPLETION 文件存在
# 新增：检查 evidence 目录有 E2E 相关文件

if [ "$GATE_NUM" = "3" ]; then
  # 现有 COMPLETION 检查...
  
  # 新增：检查 evidence 文件
  EVIDENCE_COUNT=$(find .tad/evidence -name "*.md" -newer .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$EVIDENCE_COUNT" = "0" ]; then
    # 不 BLOCK — 但注入强烈提醒
    EXTRA_CONTEXT="⚠️ WARNING: No recent evidence files found. Did you run E2E tests and expert review? Gate 3 requires evidence."
  fi
fi
```

**注意**：这个不用 exit 2 BLOCK（因为有些任务确实不需要 E2E），而是注入强烈警告让 Gate 3 的审查者注意。

#### Hook B: Domain Pack 创建时检查研究文件

修改 `post-write-sync.sh`，在检测到 `.tad/domains/*.yaml` 新文件时：

```bash
# 检测到新 domain pack YAML 创建
*.tad/domains/*.yaml)
  DOMAIN_NAME=$(basename "$FILE_PATH" .yaml)
  RESEARCH_FILE=".tad/spike-v3/domain-pack-tools/${DOMAIN_NAME}-skills-best-practices.md"
  
  if [ ! -f "$RESEARCH_FILE" ]; then
    EXTRA_CONTEXT="⚠️ Domain Pack ${DOMAIN_NAME} created WITHOUT Phase 1 research. Research file missing: ${RESEARCH_FILE}. AC1 requires ≥3 repos × 5 dimensions."
  fi
  
  record_trace "domain_pack_created" "$FILE_PATH" "$DOMAIN_NAME"
  ;;
```

## 3. AC

- [ ] AC1: Blake SKILL.md 有 EXECUTION CHECKLIST 节（≥40 行）
- [ ] AC2: 清单覆盖 before/during/after/forbidden 四个阶段
- [ ] AC3: pre-gate-check.sh 增加 evidence 警告
- [ ] AC4: post-write-sync.sh 增加 domain pack 研究文件检测
- [ ] AC5: 现有 Hook 功能不受影响
- [ ] AC6: 必须走 Ralph Loop + Gate 3（讽刺的是，修复质量系统的这个 handoff 本身也必须过质量检查）

## 4. Notes

- ⚠️ EXECUTION CHECKLIST 标注"不可精简" — 未来再做 SKILL.md 精简时不能删这个区域
- ⚠️ Hook B 是提醒不是阻止 — 因为有些 domain.yaml 是从模板创建的初始文件
- ⚠️ 这个修复不能解决"Alex 验收不认真"的问题 — 那需要 Alex 自己改

**Handoff Created By**: Alex
