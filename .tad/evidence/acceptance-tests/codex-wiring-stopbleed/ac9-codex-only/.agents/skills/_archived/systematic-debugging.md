# Systematic Debugging Skill

---
title: "Systematic Debugging"
version: "3.0"
last_updated: "2026-01-07"
tags: [debugging, root-cause, repro, logging]
domains: [engineering]
level: intermediate
estimated_time: "30min"
prerequisites: []
sources:
  - "obra/superpowers"
  - "USENIX Debugging Best Practices"
enforcement: recommended
tad_gates: [Gate3_Implementation_Quality]
---

> 来源: obra/superpowers，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 先复现：稳定复现路径与最小重现仓库/脚本
2. [ ] 证据收集：日志/栈/请求响应/系统状态（分层定位）
3. [ ] 根因分析：与“正常路径”对比，记录差异
4. [ ] 修复方案：最小改动 + 回归测试用例
5. [ ] 复核：合并后全量测试 + 监控验证
```

**Red Flags:** 只改症状不找根因、无法复现、改动大且无回归、无证据链

## 触发条件

当 Claude 遇到 Bug、错误、异常行为或需要排查问题时，自动应用此 Skill。

---

## 核心原则

**"在尝试修复之前，必须找到根本原因。症状修复 = 失败。"**

---

## 四个必经阶段

### Phase 1: 根因调查

```
┌─────────────────────────────────────────┐
│  1. 仔细阅读错误消息                      │
│  2. 稳定复现问题                          │
│  3. 检查最近的代码变更                     │
│  4. 在系统边界收集诊断证据                 │
└─────────────────────────────────────────┘
```

**分层系统调试**：
- 在每一层添加日志
- 确定故障发生在哪一层
- 从外向内逐层排查

### Phase 2: 模式分析

```
┌─────────────────────────────────────────┐
│  1. 在代码库中找到正常工作的例子           │
│  2. 与出问题的代码系统对比                 │
│  3. 记录每一个差异，无论多小               │
└─────────────────────────────────────────┘
```

**对比检查清单**：
- [ ] 导入语句
- [ ] 配置项
- [ ] 数据结构
- [ ] 调用顺序
- [ ] 环境变量

### Phase 3: 假设测试

```
┌─────────────────────────────────────────┐
│  1. 提出具体的根因假设                    │
│  2. 用最小改动测试假设                    │
│  3. 一次只改一个变量                      │
└─────────────────────────────────────────┘
```

**假设模板**：
```
我认为问题是 [具体原因]，
因为 [观察到的证据]，
验证方法是 [具体测试步骤]。
```

### Phase 4: 实施修复

```
┌─────────────────────────────────────────┐
│  1. 创建复现问题的测试用例                │
│  2. 应用单一、有针对性的修复              │
│  3. 验证修复有效                         │
│  4. 确保没有引入回归                      │
└─────────────────────────────────────────┘
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type     | Description                     | Location                               |
|-------------------|---------------------------------|----------------------------------------|
| `repro_steps`     | 可稳定复现的步骤/最小重现       | `.tad/evidence/debug/repro.md`         |
| `root_cause`      | 根因分析与证据链                | `.tad/evidence/debug/root-cause.md`    |
| `fix_plan`        | 修复方案与回归用例清单          | `.tad/evidence/debug/fix-plan.md`      |

### Acceptance Criteria

```
[ ] 能稳定复现；最小重现可运行
[ ] 根因与证据链一致，非猜测
[ ] 修复范围最小化；回归用例补齐并通过
```

### Artifacts

| Artifact     | Path                                  |
|--------------|---------------------------------------|
| Repro Steps  | `.tad/evidence/debug/repro.md`        |
| Root Cause   | `.tad/evidence/debug/root-cause.md`   |
| Fix Plan     | `.tad/evidence/debug/fix-plan.md`     |

## 危险信号 🚨

当出现以下情况时，**停下来，回到 Phase 1**：

| 信号 | 问题 |
|------|------|
| 在理解问题前就提出修复方案 | 没有做根因分析 |
| 同时尝试多个改动 | 无法确定哪个有效 |
| 跳过测试创建 | 无法防止回归 |
| 两次修复失败后继续尝试 | 可能方向错误 |

---

## 三次法则

> **如果三次或更多修复尝试失败，暂停并评估底层架构是否需要重新考虑。**

---

## 调试工具箱

### 日志分析
```bash
# 查看最近的错误
tail -f logs/error.log | grep -i error

# 过滤特定时间段
grep "2024-01-06 10:" logs/app.log
```

### Git Bisect（二分查找）
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# Git 会自动找到引入问题的提交
```

### 断点调试
```javascript
// Node.js
debugger;  // 在这里暂停

// 浏览器
console.trace();  // 打印调用栈
```

---

## 与 TAD 框架的集成

在 TAD 的 Issue 处理流程中：

1. **收到 Issue**: 不要急着修复
2. **应用 Phase 1-3**: 系统性调查
3. **编写测试**: 复现问题
4. **实施修复**: Phase 4
5. **Gate 验证**: 确认修复有效

---

## 关键心态

> "系统性调查实际上比试错法更节省时间，尤其是在截止日期压力下。"

**调试的悖论**：慢下来，反而更快。

---

*此 Skill 强制 Claude 在任何修复尝试前完成根因分析。*
