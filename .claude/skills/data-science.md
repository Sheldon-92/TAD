# Data Science & Jupyter Workflows Skill

> 综合自多个开源仓库和最佳实践，已适配 TAD 框架

## 触发条件

当用户需要进行数据分析、机器学习建模、Jupyter Notebook 开发、或数据科学工作流时，自动应用此 Skill。

---

## 核心能力

```
数据科学工具箱
├── 探索性分析 (EDA)
│   ├── 数据概览
│   ├── 分布分析
│   └── 相关性分析
├── 数据预处理
│   ├── 缺失值处理
│   ├── 特征工程
│   └── 数据转换
├── 机器学习
│   ├── 模型选择
│   ├── 训练评估
│   └── 超参调优
├── 可视化
│   ├── 统计图表
│   ├── 交互式图表
│   └── 模型解释
└── Jupyter 工作流
    ├── Notebook 结构
    ├── 代码重构
    └── 生产化部署
```

---

## Jupyter Notebook 标准结构

```python
# 1. 环境设置
"""
# 项目名称
**目标**: [明确的分析目标]
**数据**: [数据来源和描述]
**作者**: [姓名]
**日期**: [创建日期]
"""

# 2. 导入库
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split

# 设置显示选项
pd.set_option('display.max_columns', None)
plt.style.use('seaborn-v0_8-whitegrid')
%matplotlib inline

# 3. 数据加载
# 4. 探索性分析 (EDA)
# 5. 数据预处理
# 6. 特征工程
# 7. 模型训练
# 8. 模型评估
# 9. 结论与建议
```

---

## 探索性数据分析 (EDA)

### 快速数据概览

```python
def data_overview(df):
    """生成数据集的完整概览"""
    print("=" * 50)
    print("数据集概览")
    print("=" * 50)

    print(f"\n📊 数据规模: {df.shape[0]:,} 行 × {df.shape[1]} 列")

    print(f"\n📋 数据类型分布:")
    print(df.dtypes.value_counts())

    print(f"\n❓ 缺失值统计:")
    missing = df.isnull().sum()
    missing_pct = (missing / len(df) * 100).round(2)
    missing_df = pd.DataFrame({
        '缺失数量': missing,
        '缺失比例%': missing_pct
    })
    print(missing_df[missing_df['缺失数量'] > 0])

    print(f"\n🔢 数值列统计:")
    print(df.describe().round(2))

    print(f"\n📝 分类列统计:")
    for col in df.select_dtypes(include='object').columns:
        print(f"\n{col}: {df[col].nunique()} 个唯一值")
        print(df[col].value_counts().head())

# 使用
data_overview(df)
```

### 可视化分析

```python
def plot_distributions(df, figsize=(15, 10)):
    """绘制所有数值列的分布图"""
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    n_cols = 3
    n_rows = (len(numeric_cols) + n_cols - 1) // n_cols

    fig, axes = plt.subplots(n_rows, n_cols, figsize=figsize)
    axes = axes.flatten()

    for i, col in enumerate(numeric_cols):
        axes[i].hist(df[col].dropna(), bins=30, edgecolor='black', alpha=0.7)
        axes[i].set_title(col)
        axes[i].set_xlabel('')

    # 隐藏多余的子图
    for j in range(i + 1, len(axes)):
        axes[j].set_visible(False)

    plt.tight_layout()
    plt.show()

def plot_correlation_matrix(df, figsize=(12, 10)):
    """绘制相关性热力图"""
    numeric_df = df.select_dtypes(include=[np.number])
    corr = numeric_df.corr()

    plt.figure(figsize=figsize)
    mask = np.triu(np.ones_like(corr, dtype=bool))
    sns.heatmap(corr, mask=mask, annot=True, fmt='.2f',
                cmap='RdBu_r', center=0, square=True)
    plt.title('特征相关性矩阵')
    plt.tight_layout()
    plt.show()
```

---

## 数据预处理

### 缺失值处理

```python
class MissingValueHandler:
    """缺失值处理工具"""

    @staticmethod
    def fill_numeric(df, strategy='median'):
        """填充数值列缺失值"""
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        for col in numeric_cols:
            if df[col].isnull().sum() > 0:
                if strategy == 'median':
                    df[col].fillna(df[col].median(), inplace=True)
                elif strategy == 'mean':
                    df[col].fillna(df[col].mean(), inplace=True)
                elif strategy == 'zero':
                    df[col].fillna(0, inplace=True)
        return df

    @staticmethod
    def fill_categorical(df, strategy='mode'):
        """填充分类列缺失值"""
        cat_cols = df.select_dtypes(include='object').columns
        for col in cat_cols:
            if df[col].isnull().sum() > 0:
                if strategy == 'mode':
                    df[col].fillna(df[col].mode()[0], inplace=True)
                elif strategy == 'unknown':
                    df[col].fillna('Unknown', inplace=True)
        return df

    @staticmethod
    def drop_high_missing(df, threshold=0.5):
        """删除缺失率超过阈值的列"""
        missing_pct = df.isnull().sum() / len(df)
        cols_to_drop = missing_pct[missing_pct > threshold].index
        print(f"删除列: {list(cols_to_drop)}")
        return df.drop(columns=cols_to_drop)
```

### 特征工程

```python
class FeatureEngineer:
    """特征工程工具"""

    @staticmethod
    def create_datetime_features(df, date_col):
        """从日期列提取特征"""
        df[date_col] = pd.to_datetime(df[date_col])
        df[f'{date_col}_year'] = df[date_col].dt.year
        df[f'{date_col}_month'] = df[date_col].dt.month
        df[f'{date_col}_day'] = df[date_col].dt.day
        df[f'{date_col}_dayofweek'] = df[date_col].dt.dayofweek
        df[f'{date_col}_is_weekend'] = df[date_col].dt.dayofweek >= 5
        return df

    @staticmethod
    def create_binned_features(df, col, bins, labels=None):
        """创建分箱特征"""
        df[f'{col}_binned'] = pd.cut(df[col], bins=bins, labels=labels)
        return df

    @staticmethod
    def encode_categorical(df, cols, method='onehot'):
        """编码分类变量"""
        if method == 'onehot':
            return pd.get_dummies(df, columns=cols, drop_first=True)
        elif method == 'label':
            from sklearn.preprocessing import LabelEncoder
            le = LabelEncoder()
            for col in cols:
                df[f'{col}_encoded'] = le.fit_transform(df[col].astype(str))
            return df
```

---

## 机器学习工作流

### 模型训练模板

```python
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression

class MLPipeline:
    """机器学习流水线"""

    def __init__(self, X, y, test_size=0.2, random_state=42):
        self.X_train, self.X_test, self.y_train, self.y_test = \
            train_test_split(X, y, test_size=test_size, random_state=random_state)

        # 标准化
        self.scaler = StandardScaler()
        self.X_train_scaled = self.scaler.fit_transform(self.X_train)
        self.X_test_scaled = self.scaler.transform(self.X_test)

        self.models = {}
        self.results = {}

    def train_models(self):
        """训练多个模型"""
        models = {
            'Logistic Regression': LogisticRegression(max_iter=1000),
            'Random Forest': RandomForestClassifier(n_estimators=100, random_state=42),
            'Gradient Boosting': GradientBoostingClassifier(random_state=42)
        }

        for name, model in models.items():
            print(f"\n训练 {name}...")

            # 交叉验证
            cv_scores = cross_val_score(model, self.X_train_scaled, self.y_train, cv=5)

            # 训练
            model.fit(self.X_train_scaled, self.y_train)

            # 预测
            y_pred = model.predict(self.X_test_scaled)

            # 评估
            self.models[name] = model
            self.results[name] = {
                'cv_mean': cv_scores.mean(),
                'cv_std': cv_scores.std(),
                'test_accuracy': accuracy_score(self.y_test, y_pred)
            }

            print(f"  CV Score: {cv_scores.mean():.4f} (+/- {cv_scores.std():.4f})")
            print(f"  Test Accuracy: {accuracy_score(self.y_test, y_pred):.4f}")

    def compare_models(self):
        """比较模型结果"""
        results_df = pd.DataFrame(self.results).T
        results_df = results_df.sort_values('test_accuracy', ascending=False)
        return results_df

    def get_best_model(self):
        """获取最佳模型"""
        best_name = max(self.results, key=lambda k: self.results[k]['test_accuracy'])
        return best_name, self.models[best_name]
```

### 模型解释

```python
def plot_feature_importance(model, feature_names, top_n=20):
    """绘制特征重要性"""
    if hasattr(model, 'feature_importances_'):
        importance = model.feature_importances_
    elif hasattr(model, 'coef_'):
        importance = np.abs(model.coef_[0])
    else:
        print("模型不支持特征重要性")
        return

    # 排序
    indices = np.argsort(importance)[::-1][:top_n]

    plt.figure(figsize=(10, 8))
    plt.barh(range(len(indices)), importance[indices])
    plt.yticks(range(len(indices)), [feature_names[i] for i in indices])
    plt.xlabel('重要性')
    plt.title(f'Top {top_n} 特征重要性')
    plt.gca().invert_yaxis()
    plt.tight_layout()
    plt.show()
```

---

## Notebook 最佳实践

### 代码组织

```
✅ 推荐
□ 使用 Markdown 单元格解释每个步骤
□ 每个单元格只做一件事
□ 将重复代码提取为函数
□ 使用有意义的变量名
□ 在 Notebook 开头列出所有依赖

❌ 避免
□ 超长的代码单元格
□ 未注释的复杂逻辑
□ 硬编码的路径和参数
□ 未处理的警告信息
□ 运行顺序依赖（需从头运行才能工作）
```

### 版本控制友好

```python
# 在 Notebook 开头添加
%load_ext autoreload
%autoreload 2

# 将核心功能移到 .py 文件
# 例如: src/preprocessing.py, src/models.py
from src.preprocessing import clean_data
from src.models import train_model
```

### 生产化转换

```python
# 将 Notebook 转换为脚本
# jupyter nbconvert --to script notebook.ipynb

# 或使用 nbdev 框架
# pip install nbdev
# nbdev_export
```

---

## 常用可视化模板

### 分类问题可视化

```python
def plot_classification_results(y_true, y_pred, labels=None):
    """分类结果可视化"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # 混淆矩阵
    cm = confusion_matrix(y_true, y_pred)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0])
    axes[0].set_title('混淆矩阵')
    axes[0].set_xlabel('预测值')
    axes[0].set_ylabel('真实值')

    # 分类报告
    report = classification_report(y_true, y_pred, output_dict=True)
    report_df = pd.DataFrame(report).T.iloc[:-3, :-1]
    report_df.plot(kind='bar', ax=axes[1])
    axes[1].set_title('分类报告')
    axes[1].set_xticklabels(axes[1].get_xticklabels(), rotation=45)
    axes[1].legend(loc='lower right')

    plt.tight_layout()
    plt.show()
```

### 回归问题可视化

```python
def plot_regression_results(y_true, y_pred):
    """回归结果可视化"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # 预测 vs 真实
    axes[0].scatter(y_true, y_pred, alpha=0.5)
    axes[0].plot([y_true.min(), y_true.max()],
                 [y_true.min(), y_true.max()], 'r--', lw=2)
    axes[0].set_xlabel('真实值')
    axes[0].set_ylabel('预测值')
    axes[0].set_title('预测 vs 真实')

    # 残差分布
    residuals = y_true - y_pred
    axes[1].hist(residuals, bins=30, edgecolor='black', alpha=0.7)
    axes[1].axvline(x=0, color='r', linestyle='--')
    axes[1].set_xlabel('残差')
    axes[1].set_ylabel('频数')
    axes[1].set_title('残差分布')

    plt.tight_layout()
    plt.show()
```

---

## 与 TAD 框架的集成

在 TAD 的数据分析流程中：

```
业务问题 → 数据获取 → EDA → 特征工程 → 建模 → 评估 → 部署
               ↓
          [ 此 Skill ]
```

**使用场景**：
- 探索性数据分析
- 机器学习模型开发
- A/B 测试分析
- 预测建模
- 数据报告生成

---

*此 Skill 帮助 Claude 进行高效的数据科学工作流。*
