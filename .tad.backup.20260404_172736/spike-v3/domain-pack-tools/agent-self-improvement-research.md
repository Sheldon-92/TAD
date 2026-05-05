# Agent Self-Improvement: Production Implementation Research

**Date**: 2026-04-03
**用途**: ai-agent-architecture pack 的 self_improvement_design capability 参考

---

## 关键发现：没有全自动，都是"trace → 浮现 → 人决定 → 配置部署"

| 环境 | trace 存储 | 分析触发 | 变更部署 | 人审批 | 回滚 |
|------|-----------|---------|---------|--------|------|
| **OpenClaw** | .learnings/ 文件 | Hook 检测错误自动记录 | 阈值推送（3次+2任务+30天→写入 prompt） | 无（阈值自动） | 文件 revert |
| **LangSmith** | 云 SaaS trace | Annotation Queue + 自动评估 + Promptim | Prompt Hub 版本管理 | 专家标注队列 | Hub 版本切换 |
| **Firebase RC** | Google Analytics | A/B 统计显著性 | `remoteConfig.getString("prompt")` | Console 手动 | rollout 百分比→0% |
| **Langfuse** | 自托管/云 trace | 手动筛选低分 trace | 不可变版本 + 可移动 label（production/staging） | UI 移动 label | label 回指 |
| **企业级** | 自建 | 7 阶段管线 | 容器流量切换 | 强制 gate（金融/合规） | 容器切换<0s |

## 每个环境的真实工具

### iOS/Android App
- **trace**: Google Analytics events（标准移动分析）
- **部署**: Firebase Remote Config（`fetchAndActivate()`，无需 App Store 更新）
- **A/B**: Firebase A/B Testing（基于业务指标：留存、收入）
- **回滚**: Console 调 rollout 百分比到 0%

### OpenClaw
- **trace**: `.learnings/` 目录，markdown 文件，`pattern_key` 去重
- **分析**: Hook 检测错误字符串 → 自动追加到 learnings
- **推送**: `Recurrence-Count >= 3` + 跨 2+ 任务 + 30 天内 → 写入系统 prompt
- **你的 OpenClaw**: HEARTBEAT.md 是严格单次执行，无自动改进循环。改进通过手动编辑 HEARTBEAT.md

### LangChain/LangSmith
- **trace**: LangSmith 全链路（steps、tool calls、reasoning、token cost）
- **优化**: Promptim 库（baseline → 训练集 → metaprompt 建议 → 测试集 → 保留更好的）
- **部署**: Prompt Hub 版本管理 + 实验对比
- **审批**: Annotation Queue 分配给专家 → 反馈校准评估器

### Langfuse（开源替代）
- **trace**: 自托管，用户反馈（thumbs up/down）附在 trace 上
- **版本**: 不可变版本号(1,2,3) + 可移动 label（production/staging）
- **部署**: SDK `langfuse.get_prompt("name")` 获取 production label
- **回滚**: 移动 label 回上一版本（一键，即时生效）

### 企业级
- **版本模型**: 4 层复合 ID（agent + prompt + model + tool API 各自版本号）
- **管线**: Dev → 静态分析 → 行为评估 → 沙箱 → 人审 → 金丝雀 1% → 全量
- **关键数据**: "工具版本导致 60% 的生产 agent 故障" — prompt 优化不够，工具兼容性才是大风险
