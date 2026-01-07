# PowerPoint Creation Skill

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架

## 触发条件

当用户需要创建、编辑或分析 PowerPoint 演示文稿（.pptx）时，自动应用此 Skill。

---

## 核心能力

```
PPT 工作流
├── 创建新演示
│   ├── HTML → PPTX 转换
│   ├── 模板驱动创建
│   └── 编程式生成
├── 编辑现有文件
│   ├── 修改文本
│   ├── 调整布局
│   └── 更新样式
├── 分析与提取
│   ├── 提取文本
│   ├── 导出讲稿
│   └── 生成缩略图
└── 高级功能
    ├── 主题定制
    ├── 动画效果
    └── 模板管理
```

---

## 设计优先原则

### 颜色选择指南

**不要使用默认颜色！** 根据主题选择配色：

| 主题类型 | 配色方案 |
|----------|----------|
| 商务/专业 | 深蓝 #1a365d + 灰白 #f7fafc + 金色点缀 #d69e2e |
| 科技/创新 | 深紫 #553c9a + 青色 #38b2ac + 黑 #1a202c |
| 自然/环保 | 森林绿 #276749 + 米色 #fffaf0 + 棕色 #8b4513 |
| 金融/严肃 | 海军蓝 #2c5282 + 白色 #ffffff + 深灰 #4a5568 |
| 创意/活力 | 珊瑚红 #fc8181 + 薄荷绿 #9ae6b4 + 紫色 #b794f4 |
| 简约/现代 | 纯黑 #000000 + 纯白 #ffffff + 单一亮色点缀 |

### 字体选择

```
✅ 推荐（网络安全字体）:
- 标题: Arial Black, Trebuchet MS, Impact
- 正文: Calibri, Segoe UI, Tahoma

❌ 避免:
- 系统可能没有的特殊字体
- 衬线字体作为标题
- 同一页面超过 2 种字体
```

---

## 创建演示文稿

### 方法 1: HTML → PPTX 转换（推荐）

```html
<!-- slides.html -->
<!DOCTYPE html>
<html>
<head>
  <style>
    .slide { width: 1280px; height: 720px; padding: 60px; }
    .title { font-size: 48px; font-weight: bold; color: #1a365d; }
    .content { font-size: 24px; color: #4a5568; margin-top: 40px; }
  </style>
</head>
<body>
  <div class="slide">
    <h1 class="title">Q4 Business Review</h1>
    <div class="content">
      <ul>
        <li>Revenue growth: 25%</li>
        <li>New customers: 1,200</li>
        <li>Market expansion: 3 regions</li>
      </ul>
    </div>
  </div>

  <div class="slide">
    <h1 class="title">Key Metrics</h1>
    <img src="chart.png" style="width: 80%;">
  </div>
</body>
</html>
```

### 方法 2: Python 编程创建

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RgbColor

# 创建演示文稿
prs = Presentation()
prs.slide_width = Inches(16)
prs.slide_height = Inches(9)

# 添加标题页
slide_layout = prs.slide_layouts[6]  # 空白布局
slide = prs.slides.add_slide(slide_layout)

# 添加标题
title_box = slide.shapes.add_textbox(Inches(1), Inches(2), Inches(14), Inches(2))
title_frame = title_box.text_frame
title_para = title_frame.paragraphs[0]
title_para.text = "2024 年度报告"
title_para.font.size = Pt(60)
title_para.font.bold = True
title_para.font.color.rgb = RgbColor(0x1a, 0x36, 0x5d)

# 添加内容页
content_slide = prs.slides.add_slide(slide_layout)

# 添加要点
for i, point in enumerate(["营收增长 25%", "新客户 1,200 家", "市场扩张 3 个区域"]):
    text_box = content_slide.shapes.add_textbox(
        Inches(2), Inches(2 + i * 1.2), Inches(12), Inches(1)
    )
    text_frame = text_box.text_frame
    para = text_frame.paragraphs[0]
    para.text = f"• {point}"
    para.font.size = Pt(28)

# 添加图表
content_slide.shapes.add_picture("chart.png", Inches(2), Inches(5), width=Inches(8))

prs.save("presentation.pptx")
```

### 方法 3: 模板驱动

```python
from pptx import Presentation

# 加载模板
prs = Presentation("template.pptx")

# 替换占位符
for slide in prs.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    if "{{title}}" in run.text:
                        run.text = run.text.replace("{{title}}", "实际标题")
                    if "{{date}}" in run.text:
                        run.text = run.text.replace("{{date}}", "2024-01-06")

prs.save("final_presentation.pptx")
```

---

## 幻灯片布局模式

### 常用布局

```
1. 标题页
┌────────────────────────────┐
│                            │
│      [ 大标题 ]            │
│      [ 副标题 ]            │
│                            │
└────────────────────────────┘

2. 要点页
┌────────────────────────────┐
│ [ 标题 ]                   │
│                            │
│ • 要点一                   │
│ • 要点二                   │
│ • 要点三                   │
└────────────────────────────┘

3. 图文混排
┌────────────────────────────┐
│ [ 标题 ]                   │
├──────────────┬─────────────┤
│              │             │
│   [ 文字 ]   │  [ 图片 ]   │
│              │             │
└──────────────┴─────────────┘

4. 全屏图片
┌────────────────────────────┐
│                            │
│      [ 全屏背景图 ]        │
│      [ 覆盖文字 ]          │
│                            │
└────────────────────────────┘

5. 数据展示
┌────────────────────────────┐
│ [ 标题 ]                   │
├────────┬─────────┬─────────┤
│  25%   │  1,200  │   3     │
│ 增长率 │ 新客户  │ 新市场  │
└────────┴─────────┴─────────┘
```

---

## 演示文稿结构

```markdown
典型结构（10-15 页）:

1. 封面/标题页
2. 议程/目录
3. 执行摘要（1-2 页）
4. 背景/现状（1-2 页）
5. 核心内容（3-5 页）
6. 数据/证据（2-3 页）
7. 建议/下一步（1-2 页）
8. 结语/感谢页
9. 附录（可选）
```

---

## 与 TAD 框架的集成

在 TAD 的内容创建流程中：

```
用户需求 → 内容规划 → 设计风格 → PPT 生成 → 优化调整
              ↓
         [ 此 Skill ]
```

**使用场景**：
- 从 Word 文档生成汇报 PPT
- 数据分析结果可视化展示
- 会议材料快速制作
- 项目提案演示文稿

---

## 最佳实践

```
设计原则:
□ 每页一个核心信息
□ 文字精简，图表为主
□ 统一的视觉风格
□ 留白比内容更重要

技术要点:
□ 使用网络安全字体
□ 图片分辨率至少 150 DPI
□ 16:9 宽屏比例
□ 文件大小控制在 50MB 内
```

---

*此 Skill 帮助 Claude 创建专业、美观的 PowerPoint 演示文稿。*
