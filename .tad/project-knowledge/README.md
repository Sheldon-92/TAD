# Project Knowledge

Project-specific knowledge accumulated through TAD workflow execution.

## Structure

```
project-knowledge/
  code-quality.md     # Code patterns, anti-patterns, standards
  security.md         # Security issues, fixes, best practices
  ux.md               # UX decisions, patterns, user feedback
  architecture.md     # Architecture decisions, trade-offs
  performance.md      # Performance issues, optimizations
  testing.md          # Test patterns, edge cases discovered
  api-integration.md  # External API quirks, third-party services
  mobile-platform.md  # Capacitor, iOS, Android specific issues
  [dynamic]           # New categories can be created (see below)
```

## When Knowledge Gets Updated

| Trigger Point | Who | What Gets Recorded |
|--------------|-----|-------------------|
| Gate 3 Pass | Blake | Implementation discoveries, problems solved |
| *review Complete | Alex | Review insights, patterns found |

## Entry Format

```markdown
### [Short Title] - [YYYY-MM-DD]
- **Context**: What was being done
- **Discovery**: What was learned
- **Action**: Recommended approach going forward
```

## Quantity Limits & Consolidation

### Soft Limits (Guidelines, Not Hard Rules)

| Metric | Guideline | When Exceeded |
|--------|-----------|---------------|
| Entries per file | ~15-20 | Flag for consolidation |
| Lines per entry | 3-5 | Consider if all lines are necessary |
| Total categories | ~8-12 | Can create new; review quarterly |

### Consolidation Triggers

When ANY of these occur, trigger a consolidation review:
1. A file exceeds 20 entries
2. 3+ entries cover similar topics
3. An entry is >6 months old
4. Adding a new entry would create >5 entries on the same sub-topic

### Consolidation Process

When triggered, Alex should:

1. **Review the file** - Read all entries
2. **Identify patterns** - Group similar entries
3. **Merge related entries** - Combine 2-3 entries into 1 comprehensive entry
4. **Archive if needed** - Move outdated entries to `.tad/project-knowledge/archive/`
5. **Update dates** - Consolidated entries get today's date

Example consolidation:

```markdown
# Before (3 entries):
### API Timeout Issue - 2026-01-10
### Another Timeout Problem - 2026-01-15
### Third Timeout Fix - 2026-01-18

# After (1 consolidated entry):
### API Timeout Patterns - 2026-01-20 (consolidated)
- **Context**: Multiple API integrations
- **Discovery**: Timeouts occur when: (1) external APIs slow, (2) large payloads, (3) concurrent requests
- **Action**: Always set explicit timeouts, implement retry with backoff, add circuit breaker for critical paths
```

## What NOT to Record

- Generic best practices (AI already knows these)
- One-time issues unlikely to recur
- Project-agnostic information
- Information already in codebase comments

## Dynamic Category Creation

Alex/Blake 可以在现有类别不适合时创建新类别。

### When to Create New Category

创建新类别的条件（需满足至少 2 项）：
1. 当前发现明显不属于任何现有类别
2. 预计该主题会产生 3+ 条相关记录
3. 该主题具有项目特异性，值得单独追踪

### How to Create

```yaml
Step 1: 确认需要新类别
  - 检查现有类别是否真的不适合
  - 考虑是否可以作为现有类别的子话题

Step 2: 创建文件
  - 文件名: {category-name}.md（使用 kebab-case）
  - 位置: .tad/project-knowledge/

Step 3: 使用标准模板
  内容:
    # {Category Name} Knowledge

    Project-specific knowledge about {description}.

    Covers: {scope of this category}.

    ---

    <!-- Entries will be added below this line -->

Step 4: 添加首条记录
  - 创建类别后立即添加触发创建的那条记录
```

### Discovery Mechanism

Alex/Blake 在记录知识时，应该：

```yaml
Step 1: 列出当前可用类别
  - 读取 .tad/project-knowledge/ 目录
  - 显示所有 .md 文件（除 README.md）作为选项

Step 2: 提供选项
  Available categories:
  1. code-quality
  2. security
  3. ux
  4. architecture
  5. performance
  6. testing
  7. api-integration
  8. mobile-platform
  9. [Create new category...]

Step 3: 如果选择创建新类别
  - 询问类别名称和描述
  - 创建文件
  - 添加记录
```

### Safeguards

防止类别过度膨胀：
- 总类别数建议不超过 12 个
- 每季度审查：是否有可以合并的类别
- 空类别（0 条记录超过 2 个月）应删除

## Reading Knowledge Before Work

When starting implementation that matches a category:
1. Blake should read relevant knowledge file(s)
2. Apply recorded patterns/avoid recorded anti-patterns
3. This is optional but recommended for complex tasks

## Failure Modes & Protection

### Known Failure Modes

| Failure Mode | Likelihood | Impact | Protection |
|--------------|------------|--------|------------|
| Agent forgets knowledge capture | Medium | Low | Built into mandatory Gate 3/review flow |
| Records too much (noise) | Medium | Medium | Skip criteria + consolidation |
| Records too little (misses) | Low | Low | Impact-based criteria helps |
| Wrong category | Low | Low | Can be moved during consolidation |
| Duplicate entries | Medium | Low | Check before adding; consolidation fixes |
| File too large | Low | Medium | Soft limits trigger consolidation |

### Protection Mechanisms

1. **Built into mandatory flows** - Knowledge capture is part of Gate 3 and *review, not a separate step
2. **Skip criteria** - Clear rules on when NOT to record prevents noise
3. **Soft limits** - Flag for consolidation instead of hard rejection
4. **Consolidation cycle** - Regular cleanup prevents drift
5. **Category flexibility** - 6 categories cover most cases; wrong category is low-cost

### Recovery Actions

| Situation | Action |
|-----------|--------|
| File has >25 entries | Immediate consolidation required |
| 5+ entries on same topic | Merge into 1-2 comprehensive entries |
| Entry seems wrong category | Move during next consolidation |
| Outdated entry (>6 months) | Review: still relevant? Archive if not |
| Conflicting entries | Keep most recent; note in consolidated entry |

### What NOT to Worry About

- Perfect categorization (can be fixed later)
- Missing a few entries (impact-based criteria means we capture important ones)
- Exact format compliance (intent matters more than format)
- Entry length limits (guidelines, not rules)
