# Interview Preparation Skill

---
title: "Interview Preparation"
version: "3.0"
last_updated: "2026-01-07"
tags: [interview, resume, questions, feedback]
domains: [career]
level: beginner-intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "Cracking the Coding Interview"
  - "Google Interview Warmup"
enforcement: recommended
tad_gates: []
---

> 综合自面试最佳实践和职业发展指南，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 简历量化；STAR 法讲述经历
2. [ ] 题库与答案库；模拟问答与反馈
3. [ ] 行为/技术/案例题覆盖
4. [ ] 演示材料与感谢信模板
5. [ ] 产出：题库/答案/反馈记录
```

**Red Flags:** 陈述空泛无数据、准备只偏一类问题、无反馈改进

## 触发条件

当用户需要准备面试、练习面试问题、优化简历或进行职业规划时，自动应用此 Skill。

---

## 核心能力

```
面试准备工具箱
├── 简历优化
│   ├── 内容优化
│   ├── 格式规范
│   └── ATS 优化
├── 面试准备
│   ├── 行为面试
│   ├── 技术面试
│   └── 案例面试
├── 自我介绍
│   ├── Elevator Pitch
│   ├── 经历讲述
│   └── 亮点展示
└── 面试跟进
    ├── 感谢信
    ├── Offer 谈判
    └── 入职准备
```

---

## 简历优化

### 简历结构模板

```markdown
## 简历标准结构

### 1. 个人信息
- 姓名（大字醒目）
- 联系方式（电话、邮箱）
- LinkedIn/GitHub（如适用）
- 所在地（城市即可）

### 2. 职业摘要 (Optional)
> 2-3句话总结你的核心竞争力和职业目标
> 适合有5年以上经验的候选人

### 3. 工作经历
**公司名称** | 职位 | 起止时间
- [动词开头] + [做了什么] + [量化结果]
- [动词开头] + [做了什么] + [量化结果]

### 4. 项目经历 (Optional)
**项目名称** | 角色 | 时间
- 项目背景和目标
- 个人职责和贡献
- 量化成果

### 5. 教育背景
**学校名称** | 学位 | 专业 | 毕业时间
- 相关课程/荣誉（如适用）

### 6. 技能
- 技术技能: [技能列表]
- 语言能力: [语言及水平]
- 证书: [相关证书]
```

### STAR 成就描述法

```markdown
## STAR 法则描述成就

**Situation (情境)**: 背景是什么？
**Task (任务)**: 你的任务/目标是什么？
**Action (行动)**: 你具体做了什么？
**Result (结果)**: 取得了什么成果？

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type   | Description            | Location                                   |
|-----------------|------------------------|--------------------------------------------|
| `question_bank` | 面试题库               | `.tad/evidence/interview/questions.md`     |
| `answer_bank`   | 参考答案与讲述要点     | `.tad/evidence/interview/answers.md`       |
| `feedback_log`  | 模拟面试与反馈记录     | `.tad/evidence/interview/feedback.md`      |

### Acceptance Criteria

```
[ ] 题库覆盖行为/技术/案例题；答案结构化
[ ] 模拟与反馈记录完整；改进可见
[ ] 简历/材料更新到位
```

### Artifacts

| Artifact       | Path                                        |
|----------------|---------------------------------------------|
| Question Bank  | `.tad/evidence/interview/questions.md`      |
| Answer Bank    | `.tad/evidence/interview/answers.md`        |
| Feedback Log   | `.tad/evidence/interview/feedback.md`       |

### 示例

❌ 不好的描述:
"负责用户增长相关工作"

✅ 好的描述 (STAR):
"在公司 DAU 增长停滞的背景下 (S)，
负责设计并执行用户拉新策略 (T)，
通过数据分析识别高价值渠道，优化落地页转化率，
并建立 A/B 测试框架 (A)，
3个月内将新用户注册率提升 45%，获客成本降低 30% (R)"

---

### 常用动词
**领导类**: Led, Managed, Directed, Spearheaded, Orchestrated
**分析类**: Analyzed, Evaluated, Assessed, Researched, Investigated
**创造类**: Created, Developed, Designed, Built, Launched
**改进类**: Improved, Enhanced, Optimized, Streamlined, Transformed
**沟通类**: Presented, Communicated, Negotiated, Collaborated, Coordinated
```

### 量化成果指南

```markdown
## 如何量化成果

### 可量化的维度
- **规模**: 影响了多少用户/客户？
- **效率**: 节省了多少时间/成本？
- **增长**: 提升了多少百分比？
- **金额**: 创造/节省了多少收入？
- **排名**: 在多少人中排名多少？

### 量化示例
| 模糊表述 | 量化表述 |
|----------|----------|
| 提高了销售业绩 | 季度销售额提升 35%，达到 200 万 |
| 管理团队 | 管理 12 人跨职能团队 |
| 优化了流程 | 将处理时间从 3 天缩短至 4 小时 |
| 负责重要项目 | 主导 500 万预算的数字化转型项目 |
| 改善用户体验 | 用户满意度从 3.2 提升至 4.5 (5分制) |

### 没有数据怎么办？
- 估算范围: "约 50-100 个客户"
- 频率: "每周处理 200+ 请求"
- 比较: "效率是团队平均的 2 倍"
```

---

## 行为面试准备

### 常见问题分类

```markdown
## 行为面试问题库

### 领导力
1. Tell me about a time you led a team through a difficult situation.
2. Describe a situation where you had to influence others without authority.
3. How do you handle underperforming team members?

### 团队合作
1. Tell me about a time you had a conflict with a coworker.
2. Describe a successful collaboration experience.
3. How do you handle disagreements in a team?

### 问题解决
1. Describe a complex problem you solved.
2. Tell me about a time you made a mistake and how you handled it.
3. How do you approach problems you've never seen before?

### 压力管理
1. Tell me about a time you worked under tight deadlines.
2. How do you prioritize when everything is urgent?
3. Describe a stressful situation and how you dealt with it.

### 成长学习
1. Tell me about a time you failed and what you learned.
2. Describe a situation where you had to learn something quickly.
3. How do you stay updated in your field?
```

### STAR 回答模板

```markdown
## 行为面试回答结构

### 问题: "Tell me about a time you led a project."

### 回答框架 (2-3分钟)

**Situation (20%)** - 设定背景
"In my previous role at [Company], we were facing [challenge/situation].
The stakes were [explain why it mattered]."

**Task (10%)** - 说明任务
"As the [role], I was responsible for [specific responsibility]."

**Action (50%)** - 详述行动
"First, I [action 1]. This involved [details].
Then, I [action 2]. I specifically [details].
Finally, I [action 3]."

**Result (20%)** - 展示结果
"As a result, we [quantified outcome].
Additionally, [secondary benefit].
This taught me [learning/insight]."

---

### 示例回答

**Q: Tell me about a time you had to deal with a difficult stakeholder.**

**S**: "At my previous company, I was leading a product launch when our
VP of Sales pushed back strongly on our timeline, threatening to escalate
to the CEO if we didn't move the date up by two weeks."

**T**: "As the PM, I needed to find a solution that would satisfy Sales
while not compromising product quality."

**A**: "I scheduled a one-on-one with the VP to understand his concerns.
I learned that he had promised a key client this feature by a specific date.
I then worked with engineering to identify which features were truly
essential for the client's use case. We created a phased rollout plan:
core features in week 2, full features in week 4. I also set up weekly
syncs with Sales to maintain transparency."

**R**: "We launched the MVP on time for the client, and the VP became
one of our strongest internal advocates. The deal closed at 150% of
expected value. I learned that understanding the 'why' behind pushback
often reveals win-win solutions."
```

---

## 技术面试准备

### 编程面试框架

```markdown
## 编程问题解决框架

### 步骤 1: 理解问题 (2-3分钟)
- 复述问题确认理解
- 问澄清问题
  - 输入的范围和约束？
  - 边界情况如何处理？
  - 有时间/空间复杂度要求吗？
- 举例确认

### 步骤 2: 设计方案 (3-5分钟)
- 先说暴力解法
- 讨论优化思路
- 确定最终方案
- 分析复杂度

### 步骤 3: 编码实现 (10-15分钟)
- 写清晰的代码
- 边写边解释思路
- 处理边界情况

### 步骤 4: 测试验证 (3-5分钟)
- 用示例走一遍
- 测试边界情况
- 讨论可能的改进

---

### 常用问题类型

| 类型 | 关键技巧 | 常见问题 |
|------|----------|----------|
| 数组/字符串 | 双指针、滑动窗口 | Two Sum, Valid Palindrome |
| 链表 | 快慢指针、虚拟头节点 | Reverse List, Detect Cycle |
| 树 | DFS/BFS, 递归 | Tree Traversal, LCA |
| 图 | DFS/BFS, 拓扑排序 | Connected Components |
| 动态规划 | 状态定义、转移方程 | Climbing Stairs, Knapsack |
| 设计题 | 需求分析、取舍 | LRU Cache, Design Twitter |
```

### 系统设计面试框架

```markdown
## 系统设计面试框架 (45分钟)

### 步骤 1: 需求澄清 (5分钟)
- 功能需求 (核心功能)
- 非功能需求 (规模、性能、可用性)
- 约束条件

**示例问题**:
- 预期用户量？DAU/MAU？
- 读写比例？
- 数据保留多久？
- 可用性要求？

### 步骤 2: 估算 (5分钟)
- QPS 估算
- 存储估算
- 带宽估算

### 步骤 3: 高层设计 (10分钟)
- 画出核心组件
- 数据流向
- API 设计

### 步骤 4: 详细设计 (15分钟)
- 数据库设计
- 核心算法
- 深入某个组件

### 步骤 5: 扩展讨论 (10分钟)
- 扩展性
- 可靠性
- 监控告警

---

### 常考系统

| 系统 | 关键考点 |
|------|----------|
| URL Shortener | 哈希、数据库设计、缓存 |
| Twitter/微博 | Feed 生成、扇出问题、缓存策略 |
| Rate Limiter | 滑动窗口、分布式限流 |
| Chat System | WebSocket、消息队列、分片 |
| YouTube | 视频上传、转码、CDN |
| Search Engine | 倒排索引、分词、排序 |
```

---

## 自我介绍

### Elevator Pitch 模板

```markdown
## 30秒自我介绍 (Elevator Pitch)

### 结构
1. **现在** - 你是谁，做什么
2. **过去** - 相关背景/成就
3. **未来** - 为什么对这个机会感兴趣

### 模板
"Hi, I'm [Name]. I'm currently a [Role] at [Company],
where I [key responsibility/achievement].

Before that, I [relevant experience] which helped me develop
[relevant skill].

I'm excited about this [Role] because [genuine reason connected
to your experience and the opportunity]."

---

### 示例

**技术岗位**:
"Hi, I'm Sarah. I'm a Senior Software Engineer at Stripe,
where I lead the payments optimization team. Over the past
2 years, I've helped reduce payment failures by 40%,
directly impacting millions in revenue.

Before Stripe, I worked at a fintech startup where I
built their core payment infrastructure from scratch.

I'm excited about Google because I want to work on
payments at an even larger scale, and your Google Pay
team is doing exactly that."

**产品岗位**:
"Hi, I'm Michael. I'm a Product Manager at Spotify,
where I own the podcast discovery experience. I shipped
features that increased podcast listening by 30%.

I have a background in both engineering and design,
which helps me bridge technical and user needs effectively.

I'm interested in Airbnb because I love the complexity
of marketplace products, and I'm passionate about travel."
```

### Tell Me About Yourself (2分钟版)

```markdown
## 2分钟自我介绍结构

### 框架: Present → Past → Future

**Present (30秒)**
- 当前角色和公司
- 核心职责
- 最近的成就

**Past (45秒)**
- 相关的职业经历 (选择性)
- 技能如何发展
- 关键转折点

**Future (45秒)**
- 为什么对这个机会感兴趣
- 你能带来什么价值
- 职业愿景如何契合

---

### 注意事项
✅ 突出与职位相关的经历
✅ 包含量化成果
✅ 展示热情和目的性
✅ 自然过渡，有故事性

❌ 不要背诵简历
❌ 不要说太多无关内容
❌ 不要超过2分钟
```

---

## 常见问题回答

### Why This Company?

```markdown
## 回答 "Why This Company?"

### 框架
1. **公司层面**: 使命/产品/文化
2. **个人层面**: 与你的目标/价值观契合
3. **具体层面**: 特定的项目/团队/技术

### 模板
"I've been following [Company] for [reason], and I'm particularly
impressed by [specific thing].

On a personal level, [how it aligns with your values/goals].

Specifically, I'm excited about [specific team/project/initiative]
because [genuine reason]."

### 示例
"I've been a Notion user for 3 years, and it's genuinely transformed
how I work. What impressed me most is how you've built something
that's both powerful and accessible.

As someone who values craftsmanship in software, I resonate with
your attention to detail and user-centric approach.

Specifically, I'm excited about the API team because I believe
the platform opportunity is massive, and I'd love to help shape
how developers build on top of Notion."
```

### Why Should We Hire You?

```markdown
## 回答 "Why Should We Hire You?"

### 框架
1. 总结你的核心优势
2. 连接到职位需求
3. 差异化/独特价值

### 模板
"Based on our conversation, it sounds like you need someone who can
[key job requirement].

I believe I'm a strong fit because [your relevant strength/experience].

Additionally, my unique background in [differentiator] means I can
bring [specific value] that others might not."

### 示例
"Based on our conversation, it sounds like you need someone who can
scale your data infrastructure while mentoring a growing team.

I've done exactly this at my current company, where I led the team
that scaled our data pipeline from processing 1 million to 1 billion
events daily.

Additionally, my background in both data engineering and machine
learning means I can bridge these two teams effectively, which
seems important given your ML roadmap."
```

---

## 面试跟进

### 感谢信模板

```markdown
**主题**: Thank You - [Position] Interview

Dear [Interviewer's Name],

Thank you for taking the time to speak with me about the [Position]
role at [Company] today.

I enjoyed learning about [specific topic discussed], and I'm even
more excited about the opportunity after our conversation.
[Specific reason why].

I was particularly interested in [something specific from the interview],
and I believe my experience in [relevant experience] would allow me to
contribute to [specific goal/project].

Please don't hesitate to reach out if you need any additional information.

Thank you again for your time and consideration.

Best regards,
[Your Name]
[Phone Number]
[LinkedIn]
```

### Offer 谈判要点

```markdown
## Offer 谈判指南

### 谈判时机
- 收到正式 Offer 后再谈
- 了解完整的薪酬包后再谈
- 表达热情后再开始谈判

### 可谈判的内容
- 基本薪资
- 签约奖金
- 股票/期权
- 年假天数
- 入职日期
- 职级/Title
- 远程工作政策

### 谈判话术
"Thank you so much for the offer. I'm very excited about the
opportunity to join [Company].

I've done some research on market rates for similar roles, and
I was hoping we could discuss the base salary. Based on my
[experience/skills/competing offers], I was hoping for something
closer to [target number].

Is there flexibility here?"

### 注意事项
✅ 保持专业和感恩
✅ 基于数据和事实
✅ 考虑整体薪酬包
✅ 有底线但保持灵活

❌ 不要撒谎
❌ 不要过于激进
❌ 不要只关注薪资
```

---

## 与 TAD 框架的集成

在 TAD 的职业发展流程中：

```
目标设定 → 简历优化 → 面试准备 → 面试执行 → Offer 决策
               ↓
          [ 此 Skill ]
```

**使用场景**：
- 简历撰写和优化
- 面试问题练习
- 自我介绍设计
- 技术面试准备
- Offer 谈判策略

---

## 最佳实践

```
✅ 推荐
□ 提前研究公司和职位
□ 准备 5-7 个 STAR 故事
□ 练习说出来，不只是想
□ 准备好问面试官的问题
□ 面试后及时发送感谢信

❌ 避免
□ 背诵式回答
□ 说前公司坏话
□ 夸大或虚构经历
□ 不问任何问题
□ 过于关注薪资
```

---

*此 Skill 帮助 Claude 进行全面的面试准备和职业指导。*
