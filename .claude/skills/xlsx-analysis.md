# Excel Data Analysis Skill

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架

## 触发条件

当用户需要处理 Excel 文件（数据分析、清洗、可视化、自动化报表等）时，自动应用此 Skill。

---

## 核心能力

```
Excel 数据分析工具箱
├── 数据读取
│   ├── 单表/多表读取
│   ├── 多 Sheet 处理
│   └── 大文件分块读取
├── 数据清洗
│   ├── 缺失值处理
│   ├── 重复值删除
│   └── 数据类型转换
├── 数据分析
│   ├── 统计描述
│   ├── 透视表
│   └── 分组聚合
├── 可视化
│   ├── 图表生成
│   ├── 条件格式
│   └── 数据条/色阶
└── 输出
    ├── 格式化 Excel
    ├── 多 Sheet 输出
    └── 模板填充
```

---

## Python 库选择

| 任务 | 推荐库 | 特点 |
|------|--------|------|
| 数据分析 | pandas | DataFrame 操作，强大灵活 |
| 读写 Excel | openpyxl | 支持 .xlsx，可设置样式 |
| 老格式 | xlrd/xlwt | 支持 .xls 格式 |
| 大文件 | polars | 超大数据集，高性能 |
| 可视化 | matplotlib/seaborn | 生成图表嵌入 Excel |

---

## 常用操作示例

### 读取 Excel 文件

```python
import pandas as pd

# 基本读取
df = pd.read_excel("data.xlsx")

# 读取指定 Sheet
df = pd.read_excel("data.xlsx", sheet_name="销售数据")

# 读取所有 Sheet
all_sheets = pd.read_excel("data.xlsx", sheet_name=None)
for name, df in all_sheets.items():
    print(f"Sheet: {name}, Rows: {len(df)}")

# 跳过行/选择列
df = pd.read_excel(
    "data.xlsx",
    skiprows=2,           # 跳过前 2 行
    usecols="A:D",        # 只读 A-D 列
    dtype={"订单号": str} # 指定类型
)

# 大文件分块读取
chunks = pd.read_excel("big_data.xlsx", chunksize=10000)
for chunk in chunks:
    process(chunk)
```

### 数据清洗

```python
import pandas as pd

# 读取数据
df = pd.read_excel("raw_data.xlsx")

# 查看数据质量
print(df.info())
print(df.isnull().sum())  # 缺失值统计
print(df.duplicated().sum())  # 重复行统计

# 处理缺失值
df['数量'].fillna(0, inplace=True)  # 填充 0
df['备注'].fillna('无', inplace=True)  # 填充默认值
df.dropna(subset=['订单号'], inplace=True)  # 删除关键字段为空的行

# 删除重复
df.drop_duplicates(subset=['订单号'], keep='first', inplace=True)

# 数据类型转换
df['日期'] = pd.to_datetime(df['日期'])
df['金额'] = df['金额'].astype(float)
df['订单号'] = df['订单号'].astype(str)

# 数据标准化
df['产品名称'] = df['产品名称'].str.strip().str.upper()
df['手机号'] = df['手机号'].str.replace('-', '')
```

### 数据分析

```python
import pandas as pd

# 基本统计
print(df.describe())  # 数值列统计
print(df['类别'].value_counts())  # 分类统计

# 分组聚合
summary = df.groupby('产品类别').agg({
    '销售额': ['sum', 'mean', 'count'],
    '利润': 'sum',
    '数量': 'sum'
}).round(2)

# 透视表
pivot = pd.pivot_table(
    df,
    values='销售额',
    index='地区',
    columns='产品类别',
    aggfunc='sum',
    fill_value=0,
    margins=True  # 添加合计
)

# 时间序列分析
df['月份'] = df['日期'].dt.to_period('M')
monthly_sales = df.groupby('月份')['销售额'].sum()

# 同比/环比计算
monthly_sales_pct = monthly_sales.pct_change() * 100
```

### 生成图表

```python
import pandas as pd
import matplotlib.pyplot as plt
from openpyxl import Workbook
from openpyxl.chart import BarChart, LineChart, PieChart, Reference

# 方法 1: Matplotlib 生成图表保存为图片
fig, ax = plt.subplots(figsize=(10, 6))
df.groupby('类别')['销售额'].sum().plot(kind='bar', ax=ax)
plt.title('各类别销售额')
plt.tight_layout()
plt.savefig('chart.png', dpi=150)
plt.close()

# 方法 2: 在 Excel 中直接创建图表
from openpyxl import load_workbook
from openpyxl.chart import BarChart, Reference

wb = load_workbook('data.xlsx')
ws = wb.active

# 创建柱状图
chart = BarChart()
chart.title = "月度销售趋势"
chart.y_axis.title = "销售额"
chart.x_axis.title = "月份"

data = Reference(ws, min_col=2, min_row=1, max_row=13, max_col=2)
categories = Reference(ws, min_col=1, min_row=2, max_row=13)
chart.add_data(data, titles_from_data=True)
chart.set_categories(categories)

ws.add_chart(chart, "E2")
wb.save('data_with_chart.xlsx')
```

### 格式化输出

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Fill, PatternFill, Alignment, Border, Side
from openpyxl.utils.dataframe import dataframe_to_rows

# 创建工作簿
wb = Workbook()
ws = wb.active
ws.title = "销售报表"

# 从 DataFrame 写入
for r_idx, row in enumerate(dataframe_to_rows(df, index=False, header=True), 1):
    for c_idx, value in enumerate(row, 1):
        ws.cell(row=r_idx, column=c_idx, value=value)

# 设置标题行样式
header_font = Font(bold=True, color="FFFFFF")
header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")

for cell in ws[1]:
    cell.font = header_font
    cell.fill = header_fill
    cell.alignment = Alignment(horizontal="center")

# 设置列宽
ws.column_dimensions['A'].width = 15
ws.column_dimensions['B'].width = 20

# 设置数字格式
for row in ws.iter_rows(min_row=2, min_col=3, max_col=3):
    for cell in row:
        cell.number_format = '¥#,##0.00'

# 添加边框
thin_border = Border(
    left=Side(style='thin'),
    right=Side(style='thin'),
    top=Side(style='thin'),
    bottom=Side(style='thin')
)

for row in ws.iter_rows():
    for cell in row:
        cell.border = thin_border

# 冻结首行
ws.freeze_panes = 'A2'

wb.save('formatted_report.xlsx')
```

### 条件格式

```python
from openpyxl import load_workbook
from openpyxl.formatting.rule import ColorScaleRule, DataBarRule, FormulaRule
from openpyxl.styles import PatternFill

wb = load_workbook('data.xlsx')
ws = wb.active

# 色阶（数值越大颜色越深）
color_scale = ColorScaleRule(
    start_type='min', start_color='FFFFFF',
    end_type='max', end_color='4472C4'
)
ws.conditional_formatting.add('C2:C100', color_scale)

# 数据条
data_bar = DataBarRule(
    start_type='min',
    end_type='max',
    color='63BE7B'
)
ws.conditional_formatting.add('D2:D100', data_bar)

# 条件高亮（大于阈值变红）
red_fill = PatternFill(start_color='FFC7CE', end_color='FFC7CE', fill_type='solid')
formula_rule = FormulaRule(formula=['$E2>10000'], fill=red_fill)
ws.conditional_formatting.add('E2:E100', formula_rule)

wb.save('data_with_formatting.xlsx')
```

### 多 Sheet 输出

```python
import pandas as pd
from openpyxl import Workbook

# 创建多个分析结果
summary_by_region = df.groupby('地区').sum()
summary_by_product = df.groupby('产品').sum()
summary_by_month = df.groupby(df['日期'].dt.to_period('M')).sum()

# 写入多个 Sheet
with pd.ExcelWriter('analysis_report.xlsx', engine='openpyxl') as writer:
    df.to_excel(writer, sheet_name='原始数据', index=False)
    summary_by_region.to_excel(writer, sheet_name='按地区汇总')
    summary_by_product.to_excel(writer, sheet_name='按产品汇总')
    summary_by_month.to_excel(writer, sheet_name='按月汇总')

    # 设置每个 Sheet 的格式
    for sheet_name in writer.sheets:
        ws = writer.sheets[sheet_name]
        ws.column_dimensions['A'].width = 15
```

---

## 数据分析模板

### 销售分析模板

```python
def sales_analysis(file_path):
    """完整的销售数据分析流程"""
    # 1. 读取数据
    df = pd.read_excel(file_path)

    # 2. 数据清洗
    df.dropna(subset=['订单号', '销售额'], inplace=True)
    df['日期'] = pd.to_datetime(df['日期'])

    # 3. 生成分析
    results = {
        '总览': {
            '总销售额': df['销售额'].sum(),
            '订单数': len(df),
            '平均订单金额': df['销售额'].mean()
        },
        '按地区': df.groupby('地区')['销售额'].sum().to_dict(),
        '按产品': df.groupby('产品')['销售额'].sum().to_dict(),
        '月度趋势': df.groupby(df['日期'].dt.to_period('M'))['销售额'].sum().to_dict()
    }

    # 4. 输出报表
    with pd.ExcelWriter('sales_report.xlsx') as writer:
        df.to_excel(writer, sheet_name='明细', index=False)
        pd.DataFrame(results['按地区'], index=['销售额']).T.to_excel(writer, sheet_name='地区分析')
        pd.DataFrame(results['按产品'], index=['销售额']).T.to_excel(writer, sheet_name='产品分析')

    return results
```

---

## 与 TAD 框架的集成

在 TAD 的数据处理流程中：

```
用户上传 Excel → Claude 分析数据 → 生成洞察 → 输出报表
                      ↓
                 [ 此 Skill ]
```

**使用场景**：
- 销售数据分析报表
- 财务数据清洗整理
- 库存数据统计汇总
- 客户数据分析挖掘
- 自动化周报/月报生成

---

## 最佳实践

```
✅ 推荐
□ 先用 .info() 了解数据结构
□ 处理前先备份原始数据
□ 使用有意义的变量名
□ 输出时设置合适的格式
□ 大数据集考虑分块处理

❌ 避免
□ 直接覆盖原始文件
□ 忽略数据类型问题
□ 一次性加载超大文件
□ 忽略缺失值处理
```

---

## 常见问题

### 中文乱码

```python
# 读取时指定编码
df = pd.read_excel("data.xlsx", engine='openpyxl')

# 或者对于 csv
df = pd.read_csv("data.csv", encoding='utf-8-sig')
```

### 日期格式问题

```python
# Excel 日期数字转换
from datetime import datetime, timedelta

def excel_date_to_datetime(excel_date):
    return datetime(1899, 12, 30) + timedelta(days=excel_date)

# 或使用 pandas
df['日期'] = pd.to_datetime(df['日期'], origin='1899-12-30', unit='D')
```

### 大文件处理

```python
import polars as pl

# Polars 处理大文件更快
df = pl.read_excel("big_data.xlsx")
result = df.groupby("category").agg(pl.sum("amount"))
```

---

*此 Skill 帮助 Claude 高效处理 Excel 数据分析任务。*
