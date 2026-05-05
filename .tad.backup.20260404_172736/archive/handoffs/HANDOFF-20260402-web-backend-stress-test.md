# Mini-Handoff: Web Backend Domain Pack — 压力测试

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Type:** Quality Stress Test

---

## 测试议题

**"一个多租户 SaaS 订阅计费系统"**

为什么这个够复杂：
- **API 复杂**：租户管理 + 用户管理 + 订阅计划 + 支付集成 + 用量计费 + 发票，6 个资源域
- **数据库复杂**：多租户隔离（shared DB + tenant_id vs schema-per-tenant）、复杂关系（Plan→Subscription→Invoice→Payment）、软删除、审计日志
- **认证复杂**：多租户 + 多角色（SuperAdmin / TenantAdmin / Member / BillingAdmin）、API Key 认证、JWT + Refresh Token
- **业务逻辑复杂**：订阅升降级（proration）、用量超限处理、Webhook 接收（Stripe events）、并发安全（两人同时升级）
- **实时通信**：WebSocket 推送用量告警、计费事件通知
- **错误处理复杂**：支付失败重试、幂等性、部分失败回滚

## 深度检查维度

| # | 维度 | Todo App 没测到的 | 这次必须出现的 |
|---|------|-----------------|--------------|
| 1 | API 资源建模 | 3 个简单 model | 6+ 资源域，嵌套关系（Tenant→User→Subscription→Invoice→LineItem） |
| 2 | 多租户数据隔离 | 无 | 明确选型（RLS vs schema isolation），有 trade-off 分析 |
| 3 | 复杂认证 | 单角色 | 多租户×多角色权限矩阵，API Key + JWT 双认证 |
| 4 | 事务与一致性 | 简单 CRUD | 订阅升降级的 proration 计算、支付失败的状态机 |
| 5 | WebSocket 设计 | 无 | 实时用量告警的消息协议 + 频道设计 |
| 6 | 幂等性与重试 | 无 | Stripe Webhook 的幂等处理、支付重试策略 |
| 7 | 错误处理深度 | 通用 RFC 7807 | 支付失败→优雅降级→通知→重试的完整链路 |

## 执行

读取 `.tad/domains/web-backend.yaml`，用 7 个 capability 逐一处理这个 SaaS 计费系统。

## 质量评估标准

| # | 维度 | PASS | FAIL |
|---|------|------|------|
| 1 | API 资源建模 | 6+ 资源有 RESTful 端点 + OpenAPI spec 通过 lint | ≤3 个资源 |
| 2 | 多租户 | 有选型分析（RLS vs schema），有 trade-off 表，不是拍脑袋 | "用 tenant_id" 没分析 |
| 3 | 认证 | 权限矩阵覆盖 4+ 角色 × 6+ 资源，有 API Key 设计 | 只有 JWT 单角色 |
| 4 | 事务 | proration 计算有公式、状态机有 D2 图 | "支持升降级" 一句话 |
| 5 | WebSocket | 有消息协议定义（event type + payload schema） | "支持实时推送" |
| 6 | 幂等性 | Webhook 幂等键设计 + 重试策略（指数退避+最大次数） | 没提幂等 |
| 7 | 错误链路 | 支付失败→状态→通知→重试→最终失败，完整状态图 | 只有 try/catch |

**≥5/7 PASS = 深度合格。**

## AC

- [ ] 7 个 capability 全部执行
- [ ] 压力测试 ≥5/7 PASS
- [ ] 产出文件 ≥ Todo 测试（43 个）
- [ ] 测试完清理 .tad/active/research/saas-billing/
