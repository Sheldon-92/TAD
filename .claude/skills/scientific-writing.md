# Scientific Writing Skill

> 来源: K-Dense-AI/claude-scientific-writer，已适配 TAD 框架

## 触发条件

当用户需要撰写学术论文、科研报告、技术文档或进行学术写作时，自动应用此 Skill。

---

## 核心能力

```
学术写作工具箱
├── 论文结构
│   ├── IMRAD 格式
│   ├── 章节规划
│   └── 逻辑框架
├── 写作规范
│   ├── 学术语言
│   ├── 引用格式
│   └── 图表规范
├── 文献处理
│   ├── 文献综述
│   ├── 引用管理
│   └── 参考文献
└── 质量提升
    ├── 同行评审
    ├── 语言润色
    └── 格式检查
```

---

## 论文结构 (IMRAD)

### 标准学术论文结构

```
┌─────────────────────────────────────────┐
│  Title (标题)                            │
│  - 简洁准确，包含关键词                   │
│  - 15-20 个单词以内                      │
├─────────────────────────────────────────┤
│  Abstract (摘要)                         │
│  - 背景、目的、方法、结果、结论            │
│  - 150-300 词                           │
├─────────────────────────────────────────┤
│  Keywords (关键词)                       │
│  - 3-5 个，不与标题重复                   │
├─────────────────────────────────────────┤
│  Introduction (引言)                     │
│  - 研究背景                              │
│  - 问题陈述                              │
│  - 研究目的与意义                         │
│  - 研究假设                              │
├─────────────────────────────────────────┤
│  Methods (方法)                          │
│  - 研究设计                              │
│  - 数据收集                              │
│  - 分析方法                              │
│  - 可重复性信息                          │
├─────────────────────────────────────────┤
│  Results (结果)                          │
│  - 客观呈现数据                          │
│  - 图表展示                              │
│  - 统计分析                              │
├─────────────────────────────────────────┤
│  Discussion (讨论)                       │
│  - 结果解释                              │
│  - 与前人研究对比                         │
│  - 局限性                                │
│  - 未来方向                              │
├─────────────────────────────────────────┤
│  Conclusion (结论)                       │
│  - 主要发现总结                          │
│  - 理论/实践意义                         │
├─────────────────────────────────────────┤
│  References (参考文献)                   │
│  - 按规定格式排列                         │
└─────────────────────────────────────────┘
```

---

## 各部分写作指南

### 摘要 (Abstract)

```markdown
结构化摘要模板:

**背景** (1-2 句)
[研究领域的背景和研究问题]

**目的** (1 句)
[本研究的具体目标]

**方法** (2-3 句)
[研究设计、样本、主要方法]

**结果** (2-3 句)
[主要发现，包含关键数据]

**结论** (1-2 句)
[研究意义和启示]

---
示例:

背景：随着人工智能技术的发展，自然语言处理在医疗领域的应用日益广泛。
目的：本研究旨在评估大语言模型在医学诊断辅助中的准确性。
方法：我们收集了 1000 例临床病例，使用 GPT-4 进行诊断预测，并与
专家诊断进行对比分析。
结果：模型诊断准确率达到 87.3%，在常见病诊断中表现尤为突出
（准确率 92.1%）。
结论：大语言模型在医学诊断辅助中具有较高的应用潜力，但仍需结合
专业医师判断。
```

### 引言 (Introduction)

```markdown
引言结构（倒金字塔）:

1. 宏观背景 (General Context)
   - 研究领域的整体情况
   - 为什么这个主题重要

2. 具体背景 (Specific Background)
   - 前人研究回顾
   - 现有研究的贡献

3. 研究缺口 (Research Gap)
   - 现有研究的不足
   - 尚未解决的问题

4. 研究目的 (Research Objectives)
   - 本研究要解决什么
   - 研究问题/假设

5. 研究意义 (Significance)
   - 理论贡献
   - 实践价值

---
过渡短语:

引出背景:
- "近年来，[领域] 受到广泛关注..."
- "随着 [技术/趋势] 的发展..."

指出缺口:
- "然而，现有研究存在以下不足..."
- "尽管如此，[具体问题] 仍缺乏深入研究..."

说明目的:
- "基于此，本研究旨在..."
- "为解决上述问题，本文提出..."
```

### 方法 (Methods)

```markdown
方法部分要素:

1. 研究设计
   - 研究类型（实验/调查/案例等）
   - 研究框架

2. 研究对象
   - 样本来源
   - 纳入/排除标准
   - 样本量及计算依据

3. 数据收集
   - 收集工具/仪器
   - 收集流程
   - 数据类型

4. 数据分析
   - 分析方法
   - 使用的软件/工具
   - 统计检验方法

5. 伦理考量（如适用）
   - 伦理审批
   - 知情同意

---
写作技巧:
- 使用被动语态
- 提供足够的可重复性细节
- 引用已建立的方法
```

### 结果 (Results)

```markdown
结果呈现原则:

1. 客观性
   - 只报告数据，不解释
   - 使用精确的数字
   - 报告统计显著性

2. 组织结构
   - 按研究问题组织
   - 从主要到次要
   - 图表配合文字

3. 图表使用
   - 每个图表有明确目的
   - 图表标注完整
   - 正文中引用图表

---
统计结果报告格式:

- t 检验: t(df) = x.xx, p = .xxx
- 方差分析: F(df1, df2) = x.xx, p = .xxx
- 卡方检验: χ²(df) = x.xx, p = .xxx
- 相关分析: r = .xx, p = .xxx
- 效应量: d = x.xx / η² = .xx

示例:
"实验组与对照组在测试成绩上存在显著差异，
t(98) = 3.45, p < .001, d = 0.69。"
```

### 讨论 (Discussion)

```markdown
讨论结构:

1. 主要发现总结
   - 重述关键结果
   - 回应研究问题

2. 结果解释
   - 解释发现的含义
   - 为什么会有这样的结果

3. 与前人研究对比
   - 一致的发现
   - 不一致的发现及可能原因

4. 理论贡献
   - 对现有理论的支持/拓展
   - 新的理论启示

5. 实践意义
   - 对实践的指导
   - 应用场景

6. 局限性
   - 研究设计局限
   - 样本局限
   - 测量局限

7. 未来研究方向
   - 需要进一步研究的问题
   - 建议的研究方向
```

---

## 学术语言规范

### 词汇选择

```markdown
✅ 推荐用词:

表示研究行为:
- investigate (调查)
- examine (检验)
- analyze (分析)
- evaluate (评估)
- demonstrate (证明)

表示因果关系:
- result in (导致)
- contribute to (有助于)
- lead to (引起)
- be attributed to (归因于)

表示程度:
- significantly (显著地)
- considerably (相当地)
- slightly (轻微地)
- marginally (边缘地)

谨慎表达:
- suggest (表明)
- indicate (指出)
- imply (暗示)
- appear to (似乎)

❌ 避免用词:
- very, really, extremely (过于口语化)
- a lot of, lots of (用 numerous, substantial)
- thing, stuff (用具体名词)
- prove (用 demonstrate, support)
```

### 句式结构

```markdown
学术写作常用句式:

背景介绍:
- "X has been widely studied in the context of..."
- "Recent years have witnessed growing interest in..."
- "It is well established that..."

文献引用:
- "According to X (2020), ..."
- "X (2020) demonstrated that..."
- "As noted by X (2020), ..."

方法描述:
- "Data were collected using..."
- "The analysis was conducted by..."
- "Participants were randomly assigned to..."

结果报告:
- "The results indicate that..."
- "A significant difference was found between..."
- "There was a positive correlation between..."

讨论观点:
- "This finding suggests that..."
- "One possible explanation is that..."
- "This result is consistent with..."
```

---

## 引用格式

### APA 格式 (第 7 版)

```markdown
期刊文章:
Author, A. A., & Author, B. B. (Year). Title of article.
Title of Periodical, volume(issue), page–page.
https://doi.org/xxxxx

示例:
Smith, J. A., & Johnson, M. B. (2023). Machine learning
in healthcare: A systematic review. Nature Medicine,
29(3), 412-425. https://doi.org/10.1038/nm.xxxxx

---
书籍:
Author, A. A. (Year). Title of work: Capital letter also
for subtitle. Publisher.

示例:
Russell, S., & Norvig, P. (2020). Artificial intelligence:
A modern approach (4th ed.). Pearson.

---
网页:
Author, A. A. (Year, Month Day). Title of page. Site Name.
URL

示例:
World Health Organization. (2023, March 15). Global health
statistics 2023. https://www.who.int/data/statistics
```

### IEEE 格式

```markdown
期刊文章:
[1] A. A. Author and B. B. Author, "Title of article,"
Abbrev. Title of Journal, vol. x, no. x, pp. xxx–xxx,
Month Year.

示例:
[1] J. Smith and M. Johnson, "Deep learning for medical
image analysis," IEEE Trans. Med. Imaging, vol. 42,
no. 3, pp. 512-525, Mar. 2023.

---
会议论文:
[1] A. A. Author, "Title of paper," in Proc. Name of
Conf., City, Country, Year, pp. xxx–xxx.

示例:
[1] J. Smith, "Transformer architectures for NLP," in
Proc. ACL, Toronto, Canada, 2023, pp. 1234-1245.
```

---

## 图表规范

### 图片要求

```markdown
一般要求:
- 分辨率: 至少 300 DPI
- 格式: TIFF, EPS, PDF (矢量图优先)
- 尺寸: 符合期刊要求（通常单栏 8cm，双栏 17cm）

图注 (Figure Caption):
Figure 1. [简短描述]. [详细说明方法或数据来源]

示例:
Figure 1. Comparison of model accuracy across different
datasets. Error bars represent standard deviation from
five independent runs.
```

### 表格要求

```markdown
表格规范:
- 使用三线表（顶线、栏线、底线）
- 标题在表格上方
- 脚注在表格下方
- 避免纵向分隔线

表注 (Table Note):
Table 1
[标题]

[表格内容]

Note. [解释说明]
* p < .05. ** p < .01. *** p < .001.
```

---

## LaTeX 模板

### 基础论文模板

```latex
\documentclass[12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage[backend=biber,style=apa]{biblatex}
\addbibresource{references.bib}

\title{Your Paper Title}
\author{Author Name\\
\small Institution\\
\small \texttt{email@example.com}}
\date{\today}

\begin{document}

\maketitle

\begin{abstract}
Your abstract here...
\end{abstract}

\section{Introduction}
Your introduction...

\section{Methods}
Your methods...

\section{Results}
Your results...

\section{Discussion}
Your discussion...

\section{Conclusion}
Your conclusion...

\printbibliography

\end{document}
```

---

## 写作检查清单

### 提交前检查

```markdown
内容检查:
□ 摘要完整包含所有要素
□ 引言逻辑清晰，有研究缺口
□ 方法描述可重复
□ 结果只报告数据，无解释
□ 讨论与结果对应
□ 结论回应研究问题

格式检查:
□ 符合目标期刊格式要求
□ 图表编号连续
□ 引用格式一致
□ 参考文献完整
□ 字数符合要求

语言检查:
□ 无语法错误
□ 时态使用正确
□ 术语使用一致
□ 避免口语化表达
```

---

## 与 TAD 框架的集成

在 TAD 的学术写作流程中：

```
研究问题 → 文献综述 → 研究设计 → 数据分析 → 论文撰写
                                      ↓
                                 [ 此 Skill ]
```

**使用场景**：
- 学术论文撰写
- 研究报告编写
- 技术白皮书
- 学位论文
- 会议论文

---

## 常用工具

| 用途 | 工具 | 说明 |
|------|------|------|
| 文献管理 | Zotero/EndNote | 引用管理 |
| 写作 | Overleaf/LaTeX | 排版 |
| 语法检查 | Grammarly | 英文语法 |
| 查重 | Turnitin/iThenticate | 相似度检测 |
| 图表 | Origin/MATLAB | 数据可视化 |

---

*此 Skill 帮助 Claude 进行规范的学术论文写作。*
