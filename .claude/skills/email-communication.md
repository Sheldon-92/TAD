# Business Email Communication Skill

---
title: "Business Email Communication"
version: "3.0"
last_updated: "2026-01-07"
tags: [communication, email, templates, professionalism]
domains: [product, operations]
level: beginner-intermediate
estimated_time: "20min"
prerequisites: []
sources:
  - "Harvard Business Review - Email Etiquette"
  - "Google Writing Style Guide"
enforcement: recommended
tad_gates: []
---

## TL;DR Quick Checklist

```
1. [ ] 主题精确；正文三段内说明目的、背景、行动项
2. [ ] 明确 CTA（期望动作/截止时间/附件与链接）
3. [ ] 语气专业简洁；避免模糊词与过度寒暄
4. [ ] 模板复用：请求/会议/道歉/更新/催促/感谢
5. [ ] 发送前自查：收件人/抄送/附件/链接/拼写
```

**Red Flags:**
- 长段落无结构；主题与正文不一致；无明确行动项
- 使用口语/情绪化表达；多收件人但无主责人

---

## 核心能力

```
商务邮件工具箱
├── 邮件撰写
│   ├── 正式商务信函
│   ├── 内部沟通邮件
│   └── 客户服务邮件
├── 邮件回复
│   ├── 确认回复
│   ├── 问题解答
│   └── 委婉拒绝
├── 特殊场景
│   ├── 催促跟进
│   ├── 道歉致歉
│   └── 感谢表达
└── 邮件优化
    ├── 语气调整
    ├── 结构优化
    └── 简洁精炼
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type   | Description                  | Location                                   |
|-----------------|------------------------------|--------------------------------------------|
| `email_template`| 选用/定制的模板样例          | `.tad/evidence/comms/email-templates.md`   |
| `review_notes`  | 语气/结构审查笔记（可选）    | `.tad/evidence/comms/email-review.md`      |

### Acceptance Criteria

```
[ ] 主题与正文一致；目的明确；CTA 可执行且带截止
[ ] 模板化结构清晰；适配场景；避免冗长与歧义
[ ] 链接/附件正确；收件人/抄送/密送配置合理
```

### Artifacts

| Artifact           | Path                                         |
|--------------------|----------------------------------------------|
| Templates Catalog  | `.tad/evidence/comms/email-templates.md`     |
| Review Notes       | `.tad/evidence/comms/email-review.md`        |

## 邮件基本结构

### 标准商务邮件结构

```markdown
## 邮件六要素

**1. 主题行 (Subject Line)**
- 简洁明了，概括核心内容
- 包含关键词便于搜索
- 紧急邮件可加前缀 [紧急]

**2. 称呼 (Salutation)**
- 正式: Dear Mr./Ms. [姓氏],
- 半正式: Dear [名字],
- 内部: Hi [名字], / [名字]，你好

**3. 开场 (Opening)**
- 说明写信目的
- 或引用之前的沟通

**4. 正文 (Body)**
- 核心内容
- 条理清晰，分段落/要点

**5. 行动号召 (Call to Action)**
- 明确期望对方做什么
- 说明截止日期

**6. 结尾 (Closing)**
- 正式: Best regards, / Sincerely,
- 半正式: Best, / Thanks,
- 签名块
```

---

## 常用邮件模板

### 工作请求邮件

```markdown
**主题**: [Request] [具体请求内容]

Dear [Name],

I hope this email finds you well.

I am writing to request [具体请求].

**Background:**
[简要背景说明]

**Request Details:**
- [详细需求1]
- [详细需求2]
- [详细需求3]

**Timeline:**
It would be greatly appreciated if you could complete this by [日期].

Please let me know if you need any additional information or have any questions.

Thank you for your time and assistance.

Best regards,
[Your Name]
```

### 会议邀请邮件

```markdown
**主题**: [Meeting Invitation] [会议主题] - [日期]

Dear [Name/Team],

I would like to invite you to a meeting to discuss [会议主题].

**Meeting Details:**
- **Date:** [日期]
- **Time:** [时间] ([时区])
- **Location:** [地点/会议链接]
- **Duration:** [预计时长]

**Agenda:**
1. [议题1]
2. [议题2]
3. [议题3]

**Preparation:**
Please review [相关文档] before the meeting.

Kindly confirm your attendance by [确认截止日期].

Best regards,
[Your Name]
```

### 项目更新邮件

```markdown
**主题**: [Project Update] [项目名] - Week [周数]

Dear [Name/Team],

Here is the weekly update for [项目名].

**Progress Highlights:**
✅ [完成事项1]
✅ [完成事项2]

**In Progress:**
🔄 [进行中事项1] - Expected completion: [日期]
🔄 [进行中事项2]

**Blockers/Risks:**
⚠️ [风险/阻塞说明]

**Next Steps:**
- [下一步计划1]
- [下一步计划2]

**Key Metrics:**
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| [指标1] | X | Y | 🟢 |
| [指标2] | X | Y | 🟡 |

Please let me know if you have any questions or concerns.

Best regards,
[Your Name]
```

### 道歉邮件

```markdown
**主题**: [Apology] Regarding [问题简述]

Dear [Name],

I sincerely apologize for [具体问题].

**What happened:**
[简要说明发生了什么]

**Impact:**
[承认造成的影响]

**Root cause:**
[原因分析（如适用）]

**Actions taken:**
1. [已采取的补救措施1]
2. [已采取的补救措施2]

**Prevention:**
To prevent this from happening again, we will [预防措施].

I understand this has caused [影响], and I take full responsibility. Please let me know if there is anything else I can do to make this right.

Once again, I apologize for any inconvenience caused.

Sincerely,
[Your Name]
```

### 催促跟进邮件

```markdown
**主题**: [Follow-up] Re: [原邮件主题]

Dear [Name],

I hope you're doing well.

I wanted to follow up on my previous email regarding [主题] sent on [日期].

[简要重申请求]

I understand you may be busy, but I would appreciate it if you could [具体请求] by [新的截止日期].

If you need any additional information or if there are any concerns, please don't hesitate to let me know.

Thank you for your attention to this matter.

Best regards,
[Your Name]

---
*Original message attached below*
```

### 感谢邮件

```markdown
**主题**: Thank You for [感谢事项]

Dear [Name],

I wanted to take a moment to express my sincere gratitude for [具体感谢事项].

[具体说明对方的帮助/贡献]

Your [support/help/contribution] has [产生的积极影响].

I truly appreciate your [time/effort/expertise], and I look forward to [未来合作/继续交流].

Best regards,
[Your Name]
```

### 委婉拒绝邮件

```markdown
**主题**: Re: [原邮件主题]

Dear [Name],

Thank you for [对方的请求/提议].

After careful consideration, [we/I] have decided that we are unable to [具体请求] at this time.

**Reason:**
[简要说明原因，如适用]

**Alternative:**
However, I would like to suggest [替代方案/建议].

I hope you understand, and I appreciate your [understanding/patience].

Please feel free to reach out if you have any questions.

Best regards,
[Your Name]
```

---

## 中文商务邮件模板

### 工作汇报邮件

```markdown
**主题**: 【周报】[项目名称] 第X周工作汇报

[领导名称]，您好：

现将本周工作情况汇报如下：

**一、本周完成事项**
1. [完成事项1]
2. [完成事项2]
3. [完成事项3]

**二、进行中事项**
1. [事项1] - 预计完成时间：[日期]
2. [事项2] - 进度：XX%

**三、遇到的问题**
1. [问题描述]
   - 解决方案：[方案]
   - 需要支持：[支持需求]

**四、下周计划**
1. [计划1]
2. [计划2]

如有任何问题，请随时与我沟通。

祝工作顺利！

[姓名]
[日期]
```

### 请示邮件

```markdown
**主题**: 【请示】关于[事项]的请示

[领导名称]，您好：

现就[事项]向您请示：

**一、背景说明**
[背景描述]

**二、具体情况**
[详细说明]

**三、建议方案**
- 方案一：[方案描述]
  - 优点：[优点]
  - 缺点：[缺点]
- 方案二：[方案描述]
  - 优点：[优点]
  - 缺点：[缺点]

**四、建议采用方案**
建议采用方案[X]，理由如下：
[理由说明]

请您审批，谢谢！

[姓名]
[部门]
[日期]
```

### 通知邮件

```markdown
**主题**: 【通知】关于[事项]的通知

各位同事：

现将[事项]相关事宜通知如下：

**一、[主题/原因]**
[说明]

**二、具体安排**
1. 时间：[时间]
2. 地点：[地点]
3. 参与人员：[人员范围]
4. 注意事项：
   - [事项1]
   - [事项2]

**三、联系方式**
如有疑问，请联系：
- [联系人]：[联系方式]

请各位知悉并做好相关准备。

[部门/发件人]
[日期]
```

---

## 主题行写作技巧

### 有效主题行公式

```markdown
## 主题行最佳实践

### 格式建议
- [类型标签] + 核心内容 + 关键信息

### 常用标签
- [Action Required] - 需要采取行动
- [FYI] - 仅供参考
- [Urgent] - 紧急
- [Request] - 请求
- [Update] - 更新
- [Question] - 问题
- [Reminder] - 提醒
- [Feedback Needed] - 需要反馈

### 示例
✅ 好的主题行:
- [Action Required] Budget Approval Needed by Friday
- Q3 Marketing Report - Key Highlights
- Meeting Rescheduled: Product Review → Oct 15

❌ 不好的主题行:
- Hi
- Quick question
- Important!!!
- Please read
```

---

## 语气调整指南

### 正式程度对照

```markdown
## 语气级别

### 非常正式 (Very Formal)
- 场景: 外部客户、高层管理、官方文件
- 示例:
  - "I am writing to inquire about..."
  - "I would be grateful if you could..."
  - "Please do not hesitate to contact me."

### 正式 (Formal)
- 场景: 业务伙伴、跨部门沟通
- 示例:
  - "I wanted to follow up on..."
  - "Could you please provide..."
  - "Thank you for your assistance."

### 半正式 (Semi-formal)
- 场景: 熟悉的同事、团队内部
- 示例:
  - "Just checking in on..."
  - "Can you help me with..."
  - "Thanks for your help!"

### 非正式 (Informal)
- 场景: 非常熟悉的同事、即时通讯
- 示例:
  - "Hey, quick question..."
  - "Any updates on this?"
  - "Thanks!"
```

### 语气转换示例

```markdown
## 同一内容的不同语气

**请求对方提供文件**

Very Formal:
> I would be most grateful if you could kindly provide the
> requested documents at your earliest convenience.

Formal:
> Could you please send me the documents when you have a chance?

Semi-formal:
> Can you send me those documents when you get a moment?

Informal:
> Hey, can you send over those docs?
```

---

## 常用表达库

### 开场白

```markdown
## 邮件开场白

### 初次联系
- I am writing to introduce myself as...
- I am reaching out regarding...
- Your name was given to me by...

### 后续跟进
- Following up on our conversation...
- As discussed in our meeting...
- In reference to your email dated...

### 回复邮件
- Thank you for your email regarding...
- I appreciate you bringing this to my attention.
- In response to your inquiry...

### 一般开场
- I hope this email finds you well.
- I trust you had a good weekend.
- I hope you're doing well.
```

### 结束语

```markdown
## 邮件结束语

### 请求回复
- I look forward to hearing from you.
- Please let me know your thoughts.
- I would appreciate your feedback by [date].

### 提供帮助
- Please don't hesitate to reach out if you have any questions.
- I'm happy to discuss this further.
- Let me know if you need any additional information.

### 表示感谢
- Thank you for your time and consideration.
- I appreciate your prompt attention to this matter.
- Thanks in advance for your help.

### 正式结尾
- Best regards,
- Kind regards,
- Sincerely,
- Respectfully,

### 较随意结尾
- Best,
- Thanks,
- Cheers,
```

---

## 邮件礼仪

### 基本规则

```markdown
## 商务邮件礼仪

### DO ✅
- 24小时内回复（至少确认收到）
- 使用清晰的主题行
- 校对拼写和语法
- 使用专业的邮箱签名
- 回复全部时考虑是否必要
- 重要邮件发送前再检查一遍

### DON'T ❌
- 全部大写（表示喊叫）
- 使用过多感叹号!!!
- 转发长邮件链而不总结
- 使用过于随意的语言
- 讨论敏感话题
- 在情绪激动时发送邮件
```

### 抄送规则

```markdown
## CC (抄送) 和 BCC (密送) 使用指南

### CC - Carbon Copy
- 需要知晓此信息的人
- 不需要采取行动，仅供参考
- 通常用于向管理层同步信息

### BCC - Blind Carbon Copy
- 保护隐私（群发时）
- 私下知会某人
- 避免暴露联系人列表

### 最佳实践
- To: 需要采取行动的人
- CC: 需要知晓的人（数量要少）
- BCC: 需要私下知会的人

### 警告
⚠️ 谨慎使用"Reply All"
⚠️ BCC收件人不要回复全部
```

---

## 与 TAD 框架的集成

在 TAD 的沟通流程中：

```
沟通需求 → 场景分析 → 邮件撰写 → 语气调整 → 发送跟进
               ↓
          [ 此 Skill ]
```

**使用场景**：
- 商务邮件撰写
- 邮件回复优化
- 语气和措辞调整
- 邮件模板生成
- 跨文化沟通指导

---

## 最佳实践

```
✅ 推荐
□ 主题行明确，便于搜索和理解
□ 开门见山，说明目的
□ 一封邮件一个主题
□ 使用项目符号提高可读性
□ 明确行动项和截止日期

❌ 避免
□ 主题行模糊或缺失
□ 邮件过长，信息过多
□ 语气不当（过于随意或生硬）
□ 情绪化表达
□ 发送前不检查收件人
```

---

*此 Skill 帮助 Claude 进行专业的商务邮件沟通。*
