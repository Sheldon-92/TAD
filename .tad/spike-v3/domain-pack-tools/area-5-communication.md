# Area 5: 沟通与分发工具

## 工具评估矩阵

| 工具 | 类型 | Claude Code 兼容 | 功能 | 免费额度 | 安装难度 | 推荐度 |
|------|------|-----------------|------|---------|---------|--------|
| Gmail MCP | Cloud MCP | ✅ 已连接 (需 OAuth) | 搜索/阅读/起草/发送邮件 | 免费 | 零 (已内置) | ⭐⭐⭐ |
| Google Calendar MCP | Cloud MCP | ✅ 已连接 (需 OAuth) | 创建/更新/删除/查找空闲时间 | 免费 | 零 (已内置) | ⭐⭐⭐ |
| Slack MCP | Cloud MCP | ✅ 官方支持 | 发消息/搜索/读取频道 | 免费 | 低 (1 行安装) | ⭐⭐ |
| Composio | MCP 网关 | ✅ 统一接口 | 100+ 工具统一接入 | Freemium | 中 | ⭐ |

## 推荐工具

- **首选**: **Gmail MCP + Google Calendar MCP** — 已在当前 Claude Code 实例中可用。零安装成本，覆盖"发送验证材料 + 安排访谈"两大核心需求。
- **备选**: **Slack MCP** — 如果目标用户在 Slack，一行命令安装。需 workspace 管理员权限。

## 当前状态

Gmail 和 Google Calendar MCP 已连接但需要 OAuth 认证。认证后可以：
- 直接发送竞品分析报告给团队
- 安排用户访谈时间（查找空闲时段）
- 发送调研问卷邮件

## 缺口

- WhatsApp/微信 MCP 尚无稳定官方实现
- 短信 (SMS) 通知需要 Twilio API (非 MCP)
