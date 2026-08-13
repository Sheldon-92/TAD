# PDF Processing Skill

---
title: "PDF Processing"
version: "3.0"
last_updated: "2026-01-06"
tags: [pdf, document, extraction, ocr, reportlab]
domains: [backend, data]
level: intermediate
estimated_time: "30min"
prerequisites: [python]
sources:
  - "pypdf Documentation"
  - "pdfplumber Documentation"
  - "PDF/A ISO Standard"
enforcement: recommended
tad_gates: [Gate4_Review]
---

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架和文档合规标准

## TL;DR Quick Checklist

```
1. [ ] Choose correct library for task (pypdf vs pdfplumber)
2. [ ] Handle encoding properly (UTF-8)
3. [ ] Process large files in chunks (pagination)
4. [ ] Add proper metadata to generated PDFs
5. [ ] Test output across multiple PDF readers
6. [ ] Verify copyright/licensing for included assets
```

**Red Flags:**
- Loading entire large PDF into memory
- Using OCR when text is directly extractable
- Missing metadata in generated PDFs
- Ignoring PDF version compatibility
- Including copyrighted fonts without license

---

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

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description                     | Location                              |
|---------------|---------------------------------|---------------------------------------|
| `cmd_log`     | 执行命令与参数                  | `.tad/evidence/pdf/commands.log`      |
| `samples`     | 提取样例（文本/表格/图片）      | `.tad/evidence/pdf/samples/`          |

### Acceptance Criteria

```
[ ] 命令可复现；记录关键参数
[ ] 提取结果清晰；表格列对齐；编码正确
[ ] 不泄露敏感信息；必要时做脱敏
```

### Artifacts

| Artifact     | Path                                  |
|--------------|---------------------------------------|
| Command Log  | `.tad/evidence/pdf/commands.log`      |
| Samples      | `.tad/evidence/pdf/samples/`          |

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

## Copyright & Licensing (版权合规)

When generating or modifying PDFs, ensure proper licensing for all assets.

### Font Licensing

```python
# Safe fonts for commercial use
SAFE_FONTS = {
    # Built-in PDF fonts (always safe)
    'Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique',
    'Times-Roman', 'Times-Bold', 'Times-Italic',
    'Courier', 'Courier-Bold', 'Courier-Oblique',

    # Open source alternatives
    'DejaVuSans',      # Public domain / Free
    'Noto Sans',       # SIL Open Font License
    'Source Sans Pro', # SIL Open Font License
    'Liberation Sans', # SIL Open Font License (Arial equivalent)
}

# Using reportlab with safe fonts
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

c = canvas.Canvas("document.pdf", pagesize=A4)
c.setFont("Helvetica", 12)  # Built-in, always safe
c.drawString(100, 750, "Text with safe font")
c.save()

# Registering custom open-source font
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

pdfmetrics.registerFont(TTFont('NotoSans', '/path/to/NotoSans-Regular.ttf'))
c.setFont("NotoSans", 12)
```

### Image Copyright Verification

```python
# Metadata-based copyright check
from PIL import Image
from PIL.ExifTags import TAGS

def check_image_copyright(image_path):
    """Check image for copyright metadata."""
    img = Image.open(image_path)
    exif = img._getexif()

    copyright_fields = {}
    if exif:
        for tag_id, value in exif.items():
            tag = TAGS.get(tag_id, tag_id)
            if 'copyright' in tag.lower() or 'artist' in tag.lower():
                copyright_fields[tag] = value

    return {
        'has_copyright': bool(copyright_fields),
        'fields': copyright_fields,
        'recommendation': 'Verify license before use' if copyright_fields else 'No metadata found - verify source'
    }

# Always document image sources
IMAGE_ATTRIBUTION = """
Images included in this document:
- chart.png: Generated by internal analytics (company owned)
- logo.png: Company trademark (authorized use)
- stock_photo.jpg: Licensed from Unsplash (Free license)
"""
```

### PDF Metadata for Generated Documents

```python
from pypdf import PdfWriter
from datetime import datetime

def add_document_metadata(writer: PdfWriter, title: str, author: str):
    """Add proper metadata to generated PDF."""
    writer.add_metadata({
        '/Title': title,
        '/Author': author,
        '/Creator': 'Company Document System',
        '/Producer': 'pypdf',
        '/CreationDate': datetime.now().strftime("D:%Y%m%d%H%M%S"),
        '/ModDate': datetime.now().strftime("D:%Y%m%d%H%M%S"),
        '/Subject': 'Auto-generated report',
        '/Keywords': 'report, automated, internal',
        # Copyright statement
        '/Copyright': '© 2026 Company Name. All rights reserved.',
    })
```

---

## Compatibility (兼容性)

Ensure generated PDFs work across different readers and platforms.

### PDF Version Compatibility

```python
# PDF version reference
PDF_VERSIONS = {
    '1.4': 'Acrobat 5.0 - Most compatible, no advanced features',
    '1.5': 'Acrobat 6.0 - Compressed object streams',
    '1.6': 'Acrobat 7.0 - AES encryption, 3D artwork',
    '1.7': 'Acrobat 8.0 - Most features supported',
    '2.0': 'ISO 32000-2 - Latest standard',
}

# For maximum compatibility, use PDF 1.4
from reportlab.pdfgen import canvas

c = canvas.Canvas("compatible.pdf")
# reportlab default is PDF 1.4 - good compatibility
```

### Cross-Platform Testing Checklist

```markdown
## PDF Compatibility Verification

### Desktop Applications
- [ ] Adobe Acrobat Reader (Windows/Mac)
- [ ] Preview (macOS)
- [ ] Evince/Okular (Linux)
- [ ] Microsoft Edge built-in viewer

### Mobile Applications
- [ ] iOS Files app
- [ ] Android PDF viewer
- [ ] Google Drive viewer

### Web Browsers
- [ ] Chrome built-in viewer
- [ ] Firefox built-in viewer
- [ ] Safari

### Specific Features to Test
- [ ] Fonts render correctly
- [ ] Images display properly
- [ ] Links are clickable
- [ ] Bookmarks work
- [ ] Form fields are fillable (if applicable)
- [ ] Print output matches screen
```

### PDF/A for Archival (Long-term Compatibility)

```python
# PDF/A is an ISO standard for long-term archiving
# Use reportlab with specific settings

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

def create_pdfa_compatible(filename: str):
    """Create PDF/A-compatible document."""
    c = canvas.Canvas(filename, pagesize=A4)

    # PDF/A requirements:
    # 1. Embed all fonts
    # 2. No encryption
    # 3. No JavaScript
    # 4. No audio/video
    # 5. Include XMP metadata

    # Use only embedded fonts
    c.setFont("Helvetica", 12)  # Built-in fonts are always embedded

    # For true PDF/A compliance, consider using:
    # - pikepdf with PDF/A profile
    # - pdfa library for validation

    c.save()

# Validate PDF/A compliance
# pip install pikepdf
import pikepdf

def validate_pdfa(filename: str) -> bool:
    """Basic PDF/A validation."""
    try:
        with pikepdf.open(filename) as pdf:
            # Check for JavaScript (not allowed in PDF/A)
            if '/JS' in pdf.Root:
                return False
            # Check for embedded files (restricted in PDF/A)
            if '/EmbeddedFiles' in pdf.Root.get('/Names', {}):
                return False
            return True
    except Exception:
        return False
```

---

## 与 TAD 框架的集成

在 TAD 的数据处理流程中：

```
用户上传 PDF → Claude 分析需求 → 选择合适工具 → 处理 → 合规检查 → 输出结果
                    ↓
               [ 此 Skill ]
```

### Gate Mapping

```yaml
Gate4_Review:
  pdf_quality:
    - Correct library chosen for task
    - Output tested across readers
    - Fonts properly licensed
    - Images copyright verified
    - Metadata properly set
    - PDF/A compliance (if archival)
```

### Evidence Template

```markdown
## PDF Processing Evidence - [Task Name]

**Date:** [Date]
**Developer:** [Name]

---

### 1. Processing Summary

| Attribute | Value |
|-----------|-------|
| Input Files | [List of source PDFs] |
| Operation | Merge / Split / Extract / Generate |
| Output File | [output.pdf] |
| Library Used | pypdf / pdfplumber / reportlab |

### 2. Asset Licensing

| Asset | Type | License | Status |
|-------|------|---------|--------|
| Helvetica | Font | Built-in | ✅ Safe |
| Company Logo | Image | Owned | ✅ Authorized |
| Chart | Image | Generated | ✅ Owned |

### 3. Compatibility Testing

| Reader | Platform | Status |
|--------|----------|--------|
| Adobe Acrobat | Windows | ✅ Pass |
| Preview | macOS | ✅ Pass |
| Chrome | Web | ✅ Pass |
| iOS Files | Mobile | ✅ Pass |

### 4. Metadata Verification

\`\`\`
Title: [Document Title]
Author: [Author Name]
Creator: [Application]
Copyright: © 2026 Company
Creation Date: 2026-01-06
\`\`\`

### 5. Quality Checks

- [x] All text readable
- [x] Images render correctly
- [x] Links functional
- [x] File size reasonable
- [x] No security warnings

---

**PDF Processing Complete:** ✅ Yes
```

**使用场景**：
- 从财务报告 PDF 提取数据到 Excel
- 合并多个合同 PDF
- 为敏感文档添加水印
- OCR 扫描的发票提取信息
- 批量处理 PDF 文件
- 生成合规存档文档

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
