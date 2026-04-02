# Handoff: Domain Pack Loading Fix + Self-Test Verification

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Task ID:** TASK-20260401-003
**Epic:** EPIC-20260401-domain-pack-framework.md (Phase 2/2 — Validation)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Problem

Domain Pack 文件存在（.tad/domains/product-definition.yaml + tools-registry.yaml），但 Alex 启动时**没有读取和应用**。验证 session 显示 Alex 走了标准 TAD 流程，完全忽略了 Domain Pack。

根因：
1. startup-health.sh 只输出 domain 名字，不输出内容
2. Alex SKILL.md 没有读取 domain.yaml 的逻辑
3. domain.yaml 是被动文件，没有 agent 消费它

## 2. Fix Design

**两层修复：**

### Fix 1: startup-health.sh 注入 Domain Pack 摘要

当前输出：
```
TAD v2.7 | 0 handoffs | 1 epics | 0 ideas | Domains: product-definition | Hooks: active
```

改为输出**完整的 domain capabilities 摘要**，让 Alex 在 additionalContext 里就能看到 domain pack 的内容：

```bash
# 读取每个 domain.yaml，提取 capabilities 列表和 description
for domain_file in .tad/domains/*.yaml; do
  [ "$(basename $domain_file)" = "tools-registry.yaml" ] && continue
  
  domain_name=$(basename $domain_file .yaml)
  # 用 grep/sed 提取 capabilities 名称和 description
  capabilities=$(grep "^  [a-z_]*:" $domain_file | grep -v "^  #" | sed 's/://g' | tr -d ' ' | head -10)
  description=$(grep "^description:" $domain_file | sed 's/description: *//;s/"//g')
  
  DOMAIN_DETAIL="${DOMAIN_DETAIL}
Domain Pack [${domain_name}]: ${description}
Available capabilities: ${capabilities}
To use: read .tad/domains/${domain_name}.yaml for full workflow, tools, and quality criteria.
When user's task matches a capability, load the domain pack and follow its steps."
done
```

输出的 additionalContext 变成：
```
TAD v2.7 | 0 handoffs | Hooks: active

Domain Pack [product-definition]: 产品定义：从想法到可验证的产品方案
Available capabilities: user_research, competitive_analysis, product_definition, quick_validation
To use: read .tad/domains/product-definition.yaml for full workflow, tools, and quality criteria.
When user's task matches a capability, load the domain pack and follow its steps.
```

**这样 Alex 通过 additionalContext（system-reminder 级别）就知道有哪些 domain capabilities 可用，以及在什么时候应该去读 domain.yaml。**

### Fix 2: 不改 Alex SKILL.md

关键洞察：**不需要改 Alex SKILL.md。**

Alex 已经有 Intent Router + Research & Decision 能力。当 additionalContext 告诉它"有 Domain Pack 可用，包含 user_research 和 competitive_analysis 能力"时，Alex 自己会判断：
- 用户说"做竞品分析" → additionalContext 提示有 competitive_analysis capability → Alex 读取 domain.yaml → 按里面的 steps 执行

**这就是 Harness Engineering 的做法** — 通过 hook 注入信息，让模型自己决定怎么用，不需要硬编码逻辑。

如果实测发现 Alex 仍然忽略 domain pack 信息，再考虑在 SKILL.md 加一行提示。但先试 hook-only 方案。

---

## 3. Self-Test Agent（验证方式）

**不用手动开 terminal 测试。** 用 Agent tool spawn 一个测试 agent 来验证。

创建测试脚本 `.tad/tests/test-domain-pack.md`：

```markdown
# Domain Pack Loading Test

你是一个测试 agent。验证 Domain Pack 是否被正确加载和识别。

## 测试项

### Test 1: Hook 输出检查
- 读取 .tad/hooks/startup-health.sh
- 确认包含 domain pack 检测逻辑
- 确认输出 additionalContext 包含 capabilities 列表
- PASS 条件: 脚本中有读取 domain.yaml 并提取 capabilities 的逻辑

### Test 2: Domain 文件完整性
- 检查 .tad/domains/product-definition.yaml 存在
- 检查 .tad/domains/tools-registry.yaml 存在
- 检查 product-definition.yaml 包含 capabilities 节点
- 检查 capabilities 下有 user_research, competitive_analysis, product_definition, quick_validation
- PASS 条件: 所有文件存在且包含预期内容

### Test 3: Tools Registry 完整性
- 检查 tools-registry.yaml 包含 ≥10 个 capability
- 检查每个 recommended 有 install + usage 字段
- PASS 条件: ≥10 capabilities，每个有完整的 recommended

### Test 4: Hook 实际执行测试
- 运行: echo '{"session_id":"test","cwd":"'$(pwd)'","hook_event_name":"SessionStart"}' | bash .tad/hooks/startup-health.sh
- 检查输出 JSON 的 additionalContext 是否包含 "Domain Pack" 和 "capabilities"
- PASS 条件: 输出包含 domain pack 信息

### Test 5: Cross-reference 检查
- 读取 product-definition.yaml 中所有 tool_ref 值
- 检查每个 tool_ref 在 tools-registry.yaml 中有对应条目
- PASS 条件: 零 dangling references

## 输出格式

| # | Test | Result | Details |
|---|------|--------|---------|
| 1 | Hook 输出 | ✅/❌ | ... |
| 2 | Domain 文件 | ✅/❌ | ... |
| 3 | Registry 完整性 | ✅/❌ | ... |
| 4 | Hook 执行 | ✅/❌ | ... |
| 5 | Cross-ref | ✅/❌ | ... |

**总结**: X/5 PASS
```

Blake 在修复后，直接用 Agent tool spawn 这个测试 agent 来验证，不用开新 terminal。

---

## 4. Implementation Steps

### Step 1: 修改 startup-health.sh
1. 读取当前版本: `.tad/hooks/startup-health.sh`
2. 在 domain detection 部分，增加 capabilities 提取逻辑
3. 确保输出的 additionalContext 包含完整的 domain pack 摘要
4. 用 `echo '{}' | bash .tad/hooks/startup-health.sh` 本地测试

### Step 2: 创建测试脚本
1. 创建 `.tad/tests/test-domain-pack.md`
2. 内容如 Section 3 所述

### Step 3: 运行 Self-Test
1. 用 Agent tool spawn 测试 agent，prompt = 读取 `.tad/tests/test-domain-pack.md` 并执行所有测试
2. 确认 5/5 PASS

### Step 4: 同步到 Sober Creator
1. 复制更新后的 startup-health.sh 到 Sober Creator
2. 在 Sober Creator 目录下也跑一次 self-test

---

## 5. Acceptance Criteria

- [ ] AC1: startup-health.sh 输出包含 domain pack capabilities 摘要
- [ ] AC2: `.tad/tests/test-domain-pack.md` 测试脚本创建
- [ ] AC3: Self-test agent 执行 5/5 PASS（在 TAD 项目）
- [ ] AC4: Sober Creator 同步 + self-test 通过
- [ ] AC5: 不修改 Alex/Blake SKILL.md
- [ ] AC6: YAML 解析有 guard — capabilities 为空时输出 WARNING
- [ ] AC7: 行为验证 — spawn test agent 对 Alex 说"做竞品分析"，检查 Alex 是否读取了 domain.yaml（self-test 只验证结构，这个验证行为）

---

## 6. Important Notes

- ⚠️ **不改 SKILL.md** — 纯 hook 方案，通过 additionalContext 注入
- ⚠️ **用 Agent tool 测试，不要手动开 terminal**
- ⚠️ startup-health.sh 的 domain 提取用 grep/sed（不依赖 yq），保持 POSIX 兼容
- ⚠️ additionalContext 不能太长 — 只提取 capabilities 名称和一句话描述，不要全文注入

---

**Handoff Created By**: Alex
**Date**: 2026-04-01
