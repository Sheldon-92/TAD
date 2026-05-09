# Mini-Handoff: Domain Pack Batch Expert Review

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Type:** Retroactive Quality Review

---

## Task

6 个 Domain Pack 在创建时没有经过 expert review（Blake 承认跳过了 Ralph Loop Layer 2）。现在补一次快速审核。

**不是重做** — pack 功能已经 E2E 验证通过。这次只做 expert code review，找结构性问题。

## 审核范围

对以下 6 个文件各调一次 code-reviewer sub-agent：

```
.tad/domains/product-definition.yaml
.tad/domains/web-ui-design.yaml
.tad/domains/web-frontend.yaml
.tad/domains/web-backend.yaml
.tad/domains/web-testing.yaml
.tad/domains/web-deployment.yaml
```

## 每个 YAML 的审核 checklist

code-reviewer 对每个文件检查：

1. **结构完整性**: 每个 capability 有 steps + quality_criteria + anti_patterns + reviewers？
2. **Steps 四层覆盖**: 文档类有 搜索→分析→推导→生成？代码类有 选型→执行→验证→优化？
3. **quality_criteria 可量化**: 每条标准能回答 Yes/No？（"≥5 个"是好的，"足够多"是差的）
4. **编造防护**: 有"编造=FAIL"条款？
5. **tool_ref 有效**: 每个 tool_ref 在 tools-registry.yaml 中有对应条目？
6. **anti_patterns 具体**: 不是空话（"避免错误"），而是具体场景（"❌ 定价凭空编造"）？

## 执行方式

**并行** — 6 个 Agent 同时审核 6 个文件。每个 Agent prompt:

```
你是 code-reviewer。审查这个 Domain Pack YAML 的结构质量。

读取: .tad/domains/{file}.yaml
同时读取: .tad/domains/tools-registry.yaml（验证 tool_ref）

检查以下 6 项：
1. 每个 capability 有 steps + quality_criteria + anti_patterns + reviewers？
2. Steps 覆盖四层（文档类:搜索→分析→推导→生成 / 代码类:选型→执行→验证→优化）？
3. quality_criteria 每条可回答 Yes/No？
4. 有"编造数据=FAIL"条款？
5. 所有 tool_ref 在 registry 中有效？
6. anti_patterns 是具体场景不是空话？

输出:
| # | 检查项 | PASS/FAIL | 问题 |
|---|--------|-----------|------|

如果发现 P0 问题（结构缺失、tool_ref 无效），列出具体位置。
P1/P2 只列不修。
```

## AC

- [ ] 6 个文件全部审核完成
- [ ] 每个文件有 6 项 checklist 结果
- [ ] P0 问题列出（如果有）
- [ ] 汇总报告

## Notes

- ⚠️ 这是审核不是重写 — 只找问题不改文件
- ⚠️ 如果发现 P0 → 记录，由 Alex 决定是否修复
- ⚠️ 6 个 Agent 可以并行（互不依赖）
