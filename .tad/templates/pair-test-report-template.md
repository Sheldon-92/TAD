# 配对测试报告 (Pair Test Report)

> 本报告由 Claude Desktop 与产品负责人配对测试后生成。
> 所有发现均经人类确认。

---

## 1. 测试概览

| 项目 | 内容 |
|------|------|
| **测试日期** | {YYYY-MM-DD} |
| **测试时长** | {duration} |
| **测试功能** | {feature_name} |
| **参与者** | 产品负责人 + Claude Desktop |
| **测试环境** | {environment_url} |
| **TEST_BRIEF 版本** | {brief_version_or_date} |

---

## 2. 测试结果汇总

| 页面/功能 | 状态 | 问题数 | 截图 |
|-----------|------|--------|------|
| {page_1} | {pass/fail/partial} | {count} | {screenshot_refs} |
| {page_2} | {pass/fail/partial} | {count} | {screenshot_refs} |

**总计**: {total_pages} 个页面/功能测试，{total_issues} 个问题发现

---

## 3. 发现的问题

| # | 问题描述 | Priority | 页面 | 截图 | Human Confirmed |
|---|----------|----------|------|------|-----------------|
| 1 | {issue_description} | {P0/P1/P2} | {page} | {screenshot_ref} | {Yes/No} |

---

## 4. 问题详情

### Issue #{number}: {issue_title}

- **现象**: {what_was_observed}
- **预期行为**: {what_was_expected}
- **优先级**: {P0/P1/P2}
- **人类判断**: {human_comment_on_this_issue}
- **截图**: {screenshot_path}
- **复现步骤**:
  1. {step_1}
  2. {step_2}
  3. {step_3}

<!-- Repeat for each issue -->

---

## 5. 人类反馈

### 整体 UX 观察
{human_overall_ux_observations}

### 设计改进建议
- {design_suggestion_1}
- {design_suggestion_2}

### 总体印象
{human_overall_impression}

---

## 6. 截图索引

| 序号 | 文件名 | 描述 | 关联问题 |
|------|--------|------|----------|
| 01 | {filename} | {description} | {issue_ref_or_none} |

**截图目录**: `e2e-screenshots/`

---

## 7. 后续行动建议

| 优先级 | 问题 | 建议行动 |
|--------|------|----------|
| P0 | {issue} | 立即修复 |
| P1 | {issue} | 下次迭代修复 |
| P2 | {issue} | 加入 backlog |

---

*报告生成时间: {timestamp}*
*报告已经人类审阅确认: {Yes/No}*
