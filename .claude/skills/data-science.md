# Data Science & Jupyter Workflows Skill

---
title: "Data Science & Jupyter Workflows"
version: "3.0"
last_updated: "2026-01-06"
tags: [data-science, ml, jupyter, mlops, reproducibility, experiment-tracking]
domains: [data, ml, analytics]
level: intermediate
estimated_time: "60min"
prerequisites: [python]
sources:
  - "MLflow Documentation"
  - "Weights & Biases Best Practices"
  - "Google ML Best Practices"
  - "Model Cards for Model Reporting (Mitchell et al.)"
enforcement: recommended
tad_gates: [Gate2_Design, Gate3_Testing, Gate4_Review]
---

> 综合自多个开源仓库、MLOps 最佳实践和负责任 AI 指南，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] Set random seeds for reproducibility
2. [ ] Lock dependencies (requirements.txt / conda.yaml)
3. [ ] Track experiments with MLflow/W&B
4. [ ] Version datasets with DVC
5. [ ] Document model with Model Card
6. [ ] Validate with hold-out test set
```

**Red Flags:**
- No random seed set
- Missing dependency versions
- No experiment tracking
- Unreproducible results across runs
- No model documentation
- Training on test data (data leakage)

---

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

## Reproducibility (复现性)

Reproducibility is **non-negotiable** for scientific validity and production reliability.

### Setting Random Seeds

```python
import os
import random
import numpy as np
import torch  # if using PyTorch

def set_seed(seed: int = 42):
    """Set all random seeds for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)

    # PyTorch
    if 'torch' in dir():
        torch.manual_seed(seed)
        torch.cuda.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False

    # TensorFlow
    try:
        import tensorflow as tf
        tf.random.set_seed(seed)
    except ImportError:
        pass

# Call at the START of every script/notebook
SEED = 42
set_seed(SEED)

# Also pass to sklearn functions
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=SEED
)
```

### Environment Management

```yaml
# environment.yml (Conda - RECOMMENDED)
name: my-ml-project
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.11.5
  - numpy=1.26.2
  - pandas=2.1.3
  - scikit-learn=1.3.2
  - matplotlib=3.8.2
  - seaborn=0.13.0
  - jupyter=1.0.0
  - pip:
    - mlflow==2.9.2
    - wandb==0.16.1
```

```bash
# Create and export environment
conda env create -f environment.yml
conda activate my-ml-project
conda env export > environment.lock.yml  # Full lockfile

# Pip alternative
pip freeze > requirements.txt

# Or use pip-tools for better dependency resolution
pip-compile requirements.in -o requirements.txt
```

### Docker for Full Reproducibility

```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy and install dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONHASHSEED=42

# Default command
CMD ["python", "train.py"]
```

### Reproducibility Checklist

```markdown
## Reproducibility Verification

### Environment
- [ ] Python version pinned
- [ ] All package versions locked
- [ ] CUDA/cuDNN versions documented (if GPU)
- [ ] Docker image available (optional but recommended)

### Code
- [ ] Random seeds set at script start
- [ ] Seeds passed to all random functions
- [ ] Data loading is deterministic
- [ ] No hidden state between runs

### Data
- [ ] Data version tracked (hash or DVC)
- [ ] Train/val/test splits saved or reproducible
- [ ] Preprocessing steps documented
- [ ] No data leakage between splits

### Results
- [ ] Metrics match across repeated runs (within tolerance)
- [ ] Model weights can be reloaded
- [ ] Inference results are reproducible
```

---

## Experiment Tracking (实验追踪)

Track every experiment systematically to avoid "which model was best again?"

### MLflow Setup

```python
import mlflow
import mlflow.sklearn
from sklearn.metrics import accuracy_score, f1_score

# Set tracking URI (local or remote)
mlflow.set_tracking_uri("sqlite:///mlflow.db")  # Local
# mlflow.set_tracking_uri("http://mlflow-server:5000")  # Remote

# Set experiment name
mlflow.set_experiment("customer-churn-prediction")

# Training with tracking
def train_with_tracking(X_train, y_train, X_test, y_test, params):
    with mlflow.start_run(run_name=f"rf_{params['n_estimators']}trees"):
        # Log parameters
        mlflow.log_params(params)
        mlflow.log_param("dataset_version", "v2.1")

        # Train model
        model = RandomForestClassifier(**params, random_state=SEED)
        model.fit(X_train, y_train)

        # Evaluate
        y_pred = model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred, average='weighted')

        # Log metrics
        mlflow.log_metrics({
            "accuracy": accuracy,
            "f1_score": f1,
            "train_samples": len(X_train),
            "test_samples": len(X_test)
        })

        # Log model
        mlflow.sklearn.log_model(model, "model")

        # Log artifacts (plots, reports)
        # mlflow.log_artifact("confusion_matrix.png")

        # Log tags for organization
        mlflow.set_tags({
            "model_type": "random_forest",
            "feature_set": "v3",
            "author": "data-team"
        })

        return model, accuracy

# Run experiments
for n_trees in [50, 100, 200]:
    params = {"n_estimators": n_trees, "max_depth": 10}
    train_with_tracking(X_train, y_train, X_test, y_test, params)
```

### Weights & Biases (W&B)

```python
import wandb
from wandb.integration.sklearn import plot_confusion_matrix

# Initialize project
wandb.init(
    project="customer-churn",
    name="experiment-001",
    config={
        "model": "random_forest",
        "n_estimators": 100,
        "learning_rate": 0.01,
        "dataset": "churn_v2"
    }
)

# Training loop with logging
for epoch in range(epochs):
    # ... training code ...

    # Log metrics
    wandb.log({
        "epoch": epoch,
        "train_loss": train_loss,
        "val_loss": val_loss,
        "val_accuracy": val_accuracy
    })

# Log confusion matrix
wandb.sklearn.plot_confusion_matrix(y_test, y_pred, labels=class_names)

# Log model artifact
artifact = wandb.Artifact("model", type="model")
artifact.add_file("model.pkl")
wandb.log_artifact(artifact)

wandb.finish()
```

### DVC for Data Versioning

```bash
# Initialize DVC
dvc init

# Track data files
dvc add data/raw/customers.csv
git add data/raw/customers.csv.dvc .gitignore
git commit -m "Add raw customer data"

# Create data pipeline
dvc run -n preprocess \
    -d data/raw/customers.csv \
    -d src/preprocess.py \
    -o data/processed/customers_clean.csv \
    python src/preprocess.py

dvc run -n train \
    -d data/processed/customers_clean.csv \
    -d src/train.py \
    -o models/model.pkl \
    -M metrics.json \
    python src/train.py

# dvc.yaml is created automatically
# Push data to remote storage
dvc remote add -d storage s3://my-bucket/dvc
dvc push
```

### Experiment Comparison

```python
# MLflow: Compare runs programmatically
import mlflow
from mlflow.tracking import MlflowClient

client = MlflowClient()
experiment = client.get_experiment_by_name("customer-churn-prediction")

# Get all runs
runs = client.search_runs(
    experiment_ids=[experiment.experiment_id],
    order_by=["metrics.accuracy DESC"],
    max_results=10
)

# Compare
for run in runs:
    print(f"Run: {run.info.run_name}")
    print(f"  Accuracy: {run.data.metrics['accuracy']:.4f}")
    print(f"  Params: {run.data.params}")
```

---

## Model Cards (模型卡)

Model Cards document model capabilities, limitations, and intended use for responsible AI.

### Model Card Template

```markdown
# Model Card: Customer Churn Predictor

## Model Details

| Attribute | Value |
|-----------|-------|
| **Model Name** | ChurnPredictor-v2.1 |
| **Model Type** | Gradient Boosting Classifier |
| **Version** | 2.1.0 |
| **Release Date** | 2026-01-06 |
| **Developers** | Data Science Team |
| **License** | Internal Use Only |
| **Contact** | ml-team@company.com |

## Intended Use

### Primary Use Case
Predict customer churn probability to enable proactive retention campaigns.

### Intended Users
- Customer Success Team
- Marketing Automation Systems

### Out-of-Scope Uses
- ❌ Credit decisions
- ❌ Employment decisions
- ❌ Individual customer targeting without consent

## Training Data

| Attribute | Value |
|-----------|-------|
| **Dataset** | customer_data_v5 |
| **Size** | 150,000 records |
| **Time Period** | 2023-01 to 2025-12 |
| **Features** | 45 (demographics, behavior, transactions) |
| **Label** | Churned within 90 days (binary) |

### Data Distribution
- Churn Rate: 18%
- Geographic: 60% US, 25% EU, 15% APAC
- Customer Tenure: Mean 2.3 years

## Performance

### Overall Metrics
| Metric | Value |
|--------|-------|
| Accuracy | 0.87 |
| Precision | 0.82 |
| Recall | 0.78 |
| F1 Score | 0.80 |
| AUC-ROC | 0.91 |

### Performance by Subgroup
| Segment | Accuracy | Precision | Recall |
|---------|----------|-----------|--------|
| US Customers | 0.89 | 0.84 | 0.81 |
| EU Customers | 0.86 | 0.80 | 0.76 |
| APAC Customers | 0.83 | 0.78 | 0.72 |
| < 1 year tenure | 0.84 | 0.79 | 0.74 |
| > 3 year tenure | 0.90 | 0.86 | 0.83 |

## Limitations

### Known Limitations
- Lower performance for APAC region (less training data)
- May not generalize to B2B customers (trained on B2C)
- Seasonal patterns not fully captured

### Failure Modes
- Poor prediction for customers with < 30 days of data
- May overpredict churn during promotional periods

## Ethical Considerations

### Fairness
- Model tested for demographic parity
- No protected attributes used directly
- Regular bias audits scheduled

### Privacy
- No PII in features
- Aggregated behavioral data only
- GDPR compliant

## Maintenance

| Attribute | Value |
|-----------|-------|
| **Retraining Frequency** | Monthly |
| **Monitoring** | Daily drift detection |
| **Owner** | ML Platform Team |
| **Last Audit** | 2025-12-15 |
```

### Model Card in Code (Hugging Face Format)

```python
from huggingface_hub import ModelCard, ModelCardData

card_data = ModelCardData(
    language='en',
    license='mit',
    library_name='sklearn',
    tags=['classification', 'churn', 'tabular'],
    datasets=['company/customer-data-v5'],
    metrics=[
        {'type': 'accuracy', 'value': 0.87},
        {'type': 'f1', 'value': 0.80}
    ],
    model_name='ChurnPredictor-v2.1'
)

card = ModelCard.from_template(
    card_data,
    model_id="company/churn-predictor",
    model_description="Predicts customer churn probability",
    developers="Data Science Team",
    model_type="Gradient Boosting Classifier"
)

# Save to README.md
card.save("models/churn-predictor/README.md")
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

### Gate Mapping

```yaml
Gate2_Design:
  ml_design:
    - Problem definition documented
    - Success metrics defined
    - Data sources identified
    - Experiment design outlined

Gate3_Testing:
  ml_validation:
    - Reproducibility verified
    - Cross-validation performed
    - Hold-out test evaluation
    - Baseline comparison

Gate4_Review:
  ml_documentation:
    - Model Card completed
    - Experiment tracked in MLflow/W&B
    - Code peer reviewed
    - Production readiness assessed
```

### Evidence Template

```markdown
## ML Evidence - [Model/Analysis Name]

**Date:** [Date]
**Developer:** [Name]
**MLflow Run ID:** [run_id]

---

### 1. Problem Definition

| Attribute | Value |
|-----------|-------|
| Business Objective | [Clear statement] |
| ML Task | Classification / Regression / Clustering |
| Success Metric | [e.g., F1 > 0.80] |
| Baseline | [Previous model or simple heuristic] |

### 2. Reproducibility Evidence

**Environment:**
\`\`\`
Python: 3.11.5
Key Packages:
  - scikit-learn==1.3.2
  - pandas==2.1.3
  - numpy==1.26.2
\`\`\`

**Random Seed:** 42

**Verification:**
| Run | Accuracy | F1 | Status |
|-----|----------|----| -------|
| Run 1 | 0.8721 | 0.8015 | ✅ |
| Run 2 | 0.8721 | 0.8015 | ✅ |
| Run 3 | 0.8721 | 0.8015 | ✅ |

### 3. Experiment Tracking

**MLflow Experiment:** customer-churn-v3
**Best Run:** rf_200trees_v3

| Metric | Value |
|--------|-------|
| Accuracy | 0.872 |
| Precision | 0.824 |
| Recall | 0.783 |
| F1 Score | 0.803 |
| AUC-ROC | 0.912 |

**Hyperparameters:**
\`\`\`json
{
  "n_estimators": 200,
  "max_depth": 12,
  "min_samples_split": 5,
  "class_weight": "balanced"
}
\`\`\`

### 4. Data Versioning

| Item | Version/Hash |
|------|--------------|
| Training Data | DVC: abc123 |
| Test Data | DVC: def456 |
| Feature Pipeline | v2.3 |

### 5. Model Card Status

- [x] Model details documented
- [x] Intended use specified
- [x] Training data described
- [x] Performance metrics by subgroup
- [x] Limitations documented
- [x] Ethical considerations reviewed

### 6. Review Sign-off

| Reviewer | Area | Status |
|----------|------|--------|
| [Name] | Code Quality | ✅ |
| [Name] | ML Methodology | ✅ |
| [Name] | Data Privacy | ✅ |

---

**ML Pipeline Ready:** ✅ Yes
**Model Registry:** models/churn-predictor-v2.1
```

### CI/CD for ML Projects

```yaml
# .github/workflows/ml-pipeline.yml
name: ML Pipeline

on:
  push:
    paths:
      - 'src/**'
      - 'data/**'
      - 'dvc.yaml'

jobs:
  test-reproducibility:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Pull DVC data
        run: dvc pull
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Run training (reproducibility check)
        run: |
          python train.py --seed 42
          python train.py --seed 42
          python scripts/compare_runs.py  # Verify identical results

      - name: Run tests
        run: pytest tests/ -v

      - name: Upload metrics
        uses: actions/upload-artifact@v4
        with:
          name: ml-metrics
          path: metrics.json
```

**使用场景**：
- 探索性数据分析
- 机器学习模型开发
- A/B 测试分析
- 预测建模
- 数据报告生成
- 模型审计与合规

---

*此 Skill 帮助 Claude 进行高效、可复现、负责任的数据科学工作流。*
