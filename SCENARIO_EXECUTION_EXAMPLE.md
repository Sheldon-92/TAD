# TAD场景执行示例 - 展示配置如何工作

## 示例：用户请求"帮我添加一个用户登录功能"

### 1. 场景识别
TAD自动识别这是**场景2：添加新功能**
- 触发条件匹配：项目已存在，需要新功能
- 激活对应的工作流

### 2. Agent A执行（终端1）

```markdown
Alex: 我识别到这是一个"添加新功能"场景。让我开始功能分析。

[Step 1: 功能分析]
我需要调用product-expert来分析这个登录功能的需求。

[调用 product-expert]:
"请分析用户登录功能的需求，包括：
- 用户故事
- 功能要求
- 安全考虑
- 验收标准"

[返回结果整理到]: .tad/working/feature-analysis.md
```

**生成的feature-analysis.md：**
```markdown
# 功能分析：用户登录功能

## 用户故事
作为一个用户，我想要能够登录系统，以便访问我的个人数据和功能。

## 功能要求
1. 邮箱/密码登录
2. 记住我选项
3. 忘记密码流程
4. 登录状态保持

## 安全考虑
- 密码加密存储
- Session管理
- 防暴力破解
- HTTPS传输

## 验收标准
- [ ] 用户能成功注册和登录
- [ ] 密码安全存储
- [ ] Session正确管理
- [ ] 错误处理友好
```

```markdown
Alex: 功能分析完成。现在进行设计方案。

[Step 2: 设计方案]
我需要调用api-designer和backend-architect。

[调用 api-designer]:
"设计登录功能的API端点：
- 注册接口
- 登录接口
- 登出接口
- 密码重置接口"

[调用 backend-architect]:
"设计登录功能的架构：
- 认证机制选择
- Session vs JWT
- 数据库schema
- 安全策略"

[返回结果整理到]: .tad/working/feature-design.md
```

**生成的feature-design.md：**
```markdown
# 登录功能设计方案

## API设计
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/logout
- POST /api/auth/reset-password

## 架构决策
- 使用JWT进行认证
- bcrypt加密密码
- Redis存储session
- Rate limiting防护

## 数据模型
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255),
  created_at TIMESTAMP
);
```

## 实现步骤
1. 创建用户表
2. 实现认证中间件
3. 开发API端点
4. 前端登录界面
5. 集成测试
```

```markdown
Alex: 设计完成。现在创建Sprint计划。

[Step 3: Sprint计划]
[生成]: .tad/working/current-sprint.md

# Sprint - 登录功能实现

## Agent B任务清单
1. [ ] 创建数据库schema
2. [ ] 实现认证API
3. [ ] 开发登录UI
4. [ ] 编写测试用例
5. [ ] 安全测试

## 技术方案已提供
- 参考: feature-design.md
- API规范已定义
- 架构决策已确定

## 预期时间：8小时

Alex: 我的部分完成了。设计方案已经准备好，现在交给Blake实现。
```

### 3. Agent B执行（终端2）

```markdown
Blake: 收到设计方案，开始实施。

[Step 1: 影响评估]
[调用 code-reviewer]:
"评估添加登录功能对现有代码的影响"

[返回]:
- 需要添加认证中间件
- 所有受保护的路由需要更新
- 需要session管理
- 前端需要登录状态管理

Blake: 影响评估完成，现在开始实现。

[Step 2: 功能开发]
[调用 fullstack-dev-expert]:
"基于设计文档，实现登录功能"

并行执行：
1. 后端API开发
2. 前端界面开发
3. 数据库设置

[生成代码]:
- /backend/auth/controller.js
- /backend/middleware/auth.js
- /frontend/pages/login.jsx
- /database/migrations/001_users.sql

Blake: 代码实现完成，进行集成测试。

[Step 3: 集成测试]
[调用 test-runner]:
"执行登录功能的完整测试"

测试结果：
✓ 注册功能正常
✓ 登录功能正常
✓ JWT token生成正确
✓ 密码加密验证
✓ Session管理正常
✓ 前端路由保护

Blake: 功能实现和测试完成！生成执行报告。
```

**生成的execution-report.md：**
```markdown
# 执行报告 - 登录功能

## 完成情况
- [x] 数据库schema创建
- [x] 认证API实现
- [x] 登录UI开发
- [x] 测试用例编写
- [x] 安全测试通过

## 实现细节
- JWT认证机制
- bcrypt密码加密
- 前端状态管理使用Context API
- 添加了rate limiting中间件

## 测试结果
- 单元测试：15/15 通过
- 集成测试：8/8 通过
- 安全测试：无漏洞

## 部署准备
- 环境变量配置完成
- 数据库迁移脚本就绪
```

### 4. Human验证（双层验证）

```markdown
[技术验证 - 自动]
✓ 代码运行正常
✓ 测试全部通过
✓ 无安全漏洞
✓ 性能指标达标

[价值验证 - Human检查]
Human: 让我测试一下...
- 注册新用户 ✓
- 登录系统 ✓
- 保持登录状态 ✓
- 登出功能 ✓
- 忘记密码流程 ✓