# TAD v3.1 升级和安装指南

## 快速导航

- **已有TAD v3.0？** → 使用[升级脚本](#升级到-v31)
- **全新安装？** → 使用[安装脚本](#全新安装-v31)
- **查看变更？** → 阅读[CHANGELOG](.tad/CHANGELOG.md)
- **完整文档？** → 查看[升级计划](TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md)

---

## 升级到 v3.1

### 前提条件
- 当前版本：TAD v3.0
- 已备份重要数据
- 有30分钟时间

### 升级步骤

#### 方式1：自动升级脚本（推荐）

```bash
# 1. 确保在TAD项目根目录
cd /path/to/your/TAD-project

# 2. 运行升级脚本
./upgrade-to-v31.sh

# 3. 按照提示完成配置更新
# （主要是将v3.1配置追加到config.yaml）

# 4. 验证升级
./verify-v31-upgrade.sh
```

#### 方式2：手动升级

```bash
# 1. 备份
mkdir -p .backup/v3.0-$(date +%Y%m%d)
cp .tad/config.yaml .backup/v3.0-$(date +%Y%m%d)/
cp .tad/templates/handoff-a-to-b.md .backup/v3.0-$(date +%Y%m%d)/

# 2. 创建目录
mkdir -p .tad/guides
mkdir -p .tad/evidence/{patterns,failures,metrics}

# 3. 更新配置（从升级计划文档复制）
# 打开 TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md
# 复制第1195行开始的config.yaml内容
# 追加到 .tad/config.yaml 末尾

# 4. 更新模板
# 复制第1955行开始的handoff模板
# 替换 .tad/templates/handoff-a-to-b.md

# 5. 创建指南文档
# 复制第2349行的Human快速参考
# 保存到 .tad/guides/human-quick-reference.md

# 6. 创建指标文件
# 复制第2667行的metrics.yaml
# 保存到 .tad/evidence/metrics/tad-v31-metrics.yaml

# 7. 更新版本
echo "3.1.0" > .tad/version.txt

# 8. 验证
./verify-v31-upgrade.sh
```

---

## 全新安装 v3.1

### 前提条件
- 无需现有TAD安装
- 有基本的命令行知识

### 安装步骤

#### 方式1：从Git克隆（推荐）

```bash
# 1. 克隆TAD仓库
git clone https://github.com/your-org/TAD.git your-project-name
cd your-project-name

# 2. 已包含完整v3.1配置，直接可用
./verify-v31-upgrade.sh

# 3. 阅读文档开始使用
cat .tad/guides/human-quick-reference.md
```

#### 方式2：使用安装脚本

```bash
# 1. 创建项目目录
mkdir my-tad-project
cd my-tad-project

# 2. 下载安装脚本
curl -O https://raw.githubusercontent.com/your-org/TAD/main/install-tad-v31.sh
chmod +x install-tad-v31.sh

# 3. 运行安装
./install-tad-v31.sh

# 4. 按提示获取配置文件和模板
# （从TAD仓库或升级文档）

# 5. 开始使用
cat .tad/guides/README.md
```

---

## 验证安装/升级

### 运行验证脚本

```bash
./verify-v31-upgrade.sh
```

**预期输出**：
```
✅ 通过: 24项
❌ 失败: 0项
🎉 所有验证通过！
```

### 手动验证清单

- [ ] `.tad/config.yaml` 包含 `tad_version: 3.1.0`
- [ ] `.tad/templates/handoff-a-to-b.md` 包含 MQ1-5 部分
- [ ] `.tad/guides/human-quick-reference.md` 存在
- [ ] `.tad/evidence/metrics/tad-v31-metrics.yaml` 存在
- [ ] `.tad/version.txt` 内容为 `3.1.0`

---

## 快速开始

### 对于Alex（Solution Lead）

1. **阅读证据收集指南**
   ```bash
   cat .tad/guides/evidence-collection-guide.md
   ```

2. **使用新模板创建设计**
   ```bash
   cp .tad/templates/handoff-a-to-b.md ./my-feature-handoff.md
   ```

3. **填写MQ1-5**（带证据）
   - MQ1: 搜索历史代码
   - MQ2: 验证函数存在
   - MQ3: 绘制数据流图
   - MQ4: 定义视觉层级
   - MQ5: 说明状态同步

### 对于Human（Value Guardian）

1. **阅读快速参考**
   ```bash
   cat .tad/guides/human-quick-reference.md
   ```

2. **Gate 2审查**（10-15分钟）
   - 检查MQ1-5是否有证据
   - 验证数据流图和状态流图
   - 确认方向正确

3. **Phase检查**（5-10分钟/Phase）
   - 看代码截图
   - 看测试结果
   - 看UI截图
   - 判断方向是否正确

### 对于Blake（Execution Master）

1. **阅读Handoff**
   - 确认所有MQ都有证据
   - 理解Phase划分
   - 了解证据要求

2. **按Phase实施**
   - 每Phase完成后提供证据
   - 等待Human审查
   - 根据反馈调整

---

## 常见问题

### Q: 升级会影响现有项目吗？
**A**: 不会。v3.1 100%向后兼容v3.0。现有项目可继续使用，新项目采用v3.1特性。

### Q: 必须使用所有v3.1特性吗？
**A**: 推荐使用，但可渐进启用。核心特性（MQ1-5、Phase检查）强烈建议立即使用。

### Q: 升级失败怎么办？
**A**:
1. 检查验证脚本输出的具体错误
2. 查看备份目录：`.backup/v3.0-*`
3. 使用备份回滚：`cp .backup/v3.0-*/config.yaml .tad/`

### Q: 如何回滚到v3.0？
**A**:
```bash
cp .tad/config.yaml.backup.v3.0.* .tad/config.yaml
cp .tad/templates/handoff-a-to-b.md.v3.0.backup .tad/templates/handoff-a-to-b.md
echo "3.0" > .tad/version.txt
```

### Q: 升级需要多长时间？
**A**:
- 自动脚本：~10分钟（主要是阅读和确认）
- 手动升级：~30分钟
- 学习新特性：~1小时

### Q: 我不懂技术，能用v3.1吗？
**A**: 完全可以！v3.1专门为非技术Human设计：
- 看图表（数据流、状态流）
- 看截图（测试结果、UI）
- 回答简单问题（方向对不对）
- 无需懂代码

---

## 获取帮助

### 文档资源
- [升级完成报告](TAD_V3.1_UPGRADE_COMPLETE.md) - 完整功能说明
- [升级计划](TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md) - 详细实施指南
- [CHANGELOG](.tad/CHANGELOG.md) - 所有变更列表

### 支持
- GitHub Issues: https://github.com/your-org/TAD/issues
- 文档: https://tad-docs.example.com

---

## 版本兼容性

| 版本 | 发布日期 | 兼容性 | 状态 |
|------|---------|-------|------|
| v3.1.0 | 2025-11-25 | - | ✅ 当前版本 |
| v3.0 | 2024-XX-XX | 100%向后兼容 | ✅ 支持 |
| v2.x | - | 不兼容 | ⚠️ 需迁移 |

---

**升级愉快！如有问题，请参考上述文档或提交Issue。**
