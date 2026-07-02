
# HANDOFF: openharness-domain-pack-upgrade

---
task_type: yaml
e2e_required: no
research_required: no
---

---

## §9.1 Spec Compliance Checklist (excerpt)
## 9.1 Spec Compliance Checklist

---

## §6 Implementation Steps (head)
## 6. Implementation Steps

### Phase 1: 读参考文档 + 改 YAML（单 Phase）

#### 交付物
- [ ] `ai-agent-architecture.yaml` 更新（9 个 capability 全部有改动）
- [ ] `.tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md` 对比文档

#### 实施步骤

1. **读取参考文档**：
   `.tad/references/openharness-architecture.md` 全文（重点：G1-G10、TAD Mapping、Key Metrics）

2. **读取现有 YAML**：
   `.tad/domains/ai-agent-architecture.yaml` 全文

3. **逐 capability 改动**（按 4.1 映射表）：
   对每个 capability：
   a. 读参考文档对应章节
   b. 对比现有 YAML 找差距
   c. 添加新 step / quality_criteria / anti_pattern
   d. 标注来源

4. **写 before-after 对比文档**：
   `.tad/spike-v3/domain-pack-tools/before-after-ai-agent-architecture.md`
   格式同 HW 研究补充：

   ```markdown
   ## ai-agent-architecture 迭代记录

   ### 来自 OpenHarness 参考架构的改进
   | Capability | 来源章节 | 改进了什么 | 改进前 | 改进后 |
   |-----------|---------|-----------|--------|--------|

   ### 改动统计
   - 新增 steps: N
   - 新增 quality_criteria: N
   - 新增 anti_patterns: N
   - 修改 existing: N
   ```

---

