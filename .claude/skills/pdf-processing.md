# PDF Processing Skill

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架

## 触发条件

当用户需要处理 PDF 文件（提取文本、合并、拆分、创建、填表等）时，自动应用此 Skill。

---

## 核心能力

```
PDF 处理工具箱
├── 读取与提取
│   ├── 文本提取
│   ├── 表格提取
│   └── 元数据获取
├── 创建与编辑
│   ├── 从零创建 PDF
│   ├── 合并多个 PDF
│   ├── 拆分页面
│   └── 添加水印
├── 表单处理
│   ├── 填写表单
│   └── 提取表单数据
└── 高级功能
    ├── OCR 扫描件
    ├── 提取图片
    └── 密码保护
```

---

## Python 库选择指南

| 任务 | 推荐库 | 备注 |
|------|--------|------|
| 基础操作 | pypdf | 合并、拆分、旋转、元数据 |
| 文本提取 | pdfplumber | 保留布局，支持表格 |
| 表格提取 | pdfplumber + pandas | 导出为 DataFrame |
| 创建 PDF | reportlab | Canvas 或 Platypus |
| OCR | pytesseract + pdf2image | 扫描件文字识别 |
| 表单填写 | pdfrw / PyPDF2 | AcroForm 表单 |

---

## 常用操作示例

### 提取文本

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

### 提取表格到 Excel

```python
import pdfplumber
import pandas as pd

with pdfplumber.open("report.pdf") as pdf:
    tables = []
    for page in pdf.pages:
        table = page.extract_table()
        if table:
            tables.append(pd.DataFrame(table[1:], columns=table[0]))

    # 合并所有表格
    df = pd.concat(tables, ignore_index=True)
    df.to_excel("extracted_data.xlsx", index=False)
```

### 合并多个 PDF

```python
from pypdf import PdfMerger

merger = PdfMerger()

files = ["doc1.pdf", "doc2.pdf", "doc3.pdf"]
for file in files:
    merger.append(file)

merger.write("merged.pdf")
merger.close()
```

### 拆分 PDF 页面

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("document.pdf")

# 提取第 1-5 页
writer = PdfWriter()
for i in range(5):
    writer.add_page(reader.pages[i])

writer.write("first_5_pages.pdf")
```

### 从零创建 PDF

```python
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

c = canvas.Canvas("new_document.pdf", pagesize=A4)

# 添加标题
c.setFont("Helvetica-Bold", 24)
c.drawString(100, 750, "Report Title")

# 添加正文
c.setFont("Helvetica", 12)
c.drawString(100, 700, "This is the first paragraph...")

# 添加图片
c.drawImage("chart.png", 100, 400, width=400, height=250)

c.save()
```

### OCR 扫描件

```python
from pdf2image import convert_from_path
import pytesseract

# PDF 转图片
images = convert_from_path("scanned.pdf")

# OCR 识别
full_text = ""
for image in images:
    text = pytesseract.image_to_string(image, lang='chi_sim+eng')
    full_text += text + "\n"

print(full_text)
```

### 添加水印

```python
from pypdf import PdfReader, PdfWriter

# 创建水印 PDF（用 reportlab）
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

c = canvas.Canvas("watermark.pdf", pagesize=A4)
c.setFont("Helvetica", 60)
c.setFillColorRGB(0.5, 0.5, 0.5, alpha=0.3)
c.rotate(45)
c.drawString(200, 100, "CONFIDENTIAL")
c.save()

# 应用水印
reader = PdfReader("document.pdf")
watermark = PdfReader("watermark.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark.pages[0])
    writer.add_page(page)

writer.write("watermarked.pdf")
```

---

## 命令行工具

```bash
# pdftotext - 提取文本
pdftotext document.pdf output.txt

# qpdf - 合并/拆分
qpdf --empty --pages doc1.pdf doc2.pdf -- merged.pdf
qpdf document.pdf --pages . 1-5 -- first_5.pdf

# pdftk - 批量操作
pdftk *.pdf cat output combined.pdf
pdftk document.pdf burst  # 拆分成单页
```

---

## 表单填写

```python
from pdfrw import PdfReader, PdfWriter, PageMerge

# 读取带表单的 PDF
template = PdfReader("form_template.pdf")

# 填写表单字段
annotations = template.pages[0]['/Annots']
for annotation in annotations:
    if annotation['/T']:
        field_name = annotation['/T'][1:-1]  # 去掉括号
        if field_name == 'name':
            annotation.update({'/V': '(John Doe)'})
        elif field_name == 'date':
            annotation.update({'/V': '(2024-01-06)'})

# 保存
PdfWriter("filled_form.pdf", trailer=template).write()
```

---

## 与 TAD 框架的集成

在 TAD 的数据处理流程中：

```
用户上传 PDF → Claude 分析需求 → 选择合适工具 → 处理 → 输出结果
                    ↓
               [ 此 Skill ]
```

**使用场景**：
- 从财务报告 PDF 提取数据到 Excel
- 合并多个合同 PDF
- 为敏感文档添加水印
- OCR 扫描的发票提取信息
- 批量处理 PDF 文件

---

## 最佳实践

```
✅ 推荐
□ 选择合适的库处理特定任务
□ 大文件分页处理避免内存问题
□ OCR 前先尝试直接提取文本
□ 保留原始文件备份

❌ 避免
□ 用 OCR 处理可直接提取文本的 PDF
□ 一次性加载超大 PDF 到内存
□ 忽略 PDF 的编码问题
```

---

*此 Skill 帮助 Claude 高效处理各种 PDF 文档任务。*
