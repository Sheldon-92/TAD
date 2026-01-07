# Error Handling Skill

> 综合自多个开源仓库，已适配 TAD 框架

## 触发条件

当 Claude 编写可能失败的代码、处理异常情况、或设计错误处理策略时，自动应用此 Skill。

---

## 核心原则

**"错误处理不是事后添加的功能，而是代码的一等公民。"**

---

## 错误处理策略

### 错误分类

```
可恢复错误 (Recoverable)
├── 输入验证失败
├── 资源暂时不可用
├── 网络超时
└── 处理: 重试、降级、用户反馈

不可恢复错误 (Unrecoverable)
├── 配置错误
├── 关键依赖缺失
├── 内存耗尽
└── 处理: 快速失败、告警、人工介入

编程错误 (Programming Errors)
├── 空指针
├── 类型错误
├── 断言失败
└── 处理: 修复代码，不要 catch
```

---

## 错误处理模式

### 1. 快速失败 (Fail Fast)

```javascript
// ❌ 静默失败
function getUser(id) {
  if (!id) return null;
  // ...
}

// ✅ 快速失败
function getUser(id) {
  if (!id) {
    throw new Error('User ID is required');
  }
  // ...
}
```

### 2. 显式错误返回 (Result Pattern)

```typescript
// Result 类型
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// 使用
function divide(a: number, b: number): Result<number, string> {
  if (b === 0) {
    return { success: false, error: 'Division by zero' };
  }
  return { success: true, data: a / b };
}

// 调用
const result = divide(10, 0);
if (result.success) {
  console.log(result.data);
} else {
  console.error(result.error);
}
```

### 3. 异常处理

```javascript
// 自定义错误类
class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

class NotFoundError extends Error {
  constructor(resource, id) {
    super(`${resource} with id ${id} not found`);
    this.name = 'NotFoundError';
    this.resource = resource;
    this.id = id;
  }
}

// 使用
function getUser(id) {
  const user = db.users.find(id);
  if (!user) {
    throw new NotFoundError('User', id);
  }
  return user;
}

// 处理
try {
  const user = getUser(123);
} catch (error) {
  if (error instanceof NotFoundError) {
    res.status(404).json({ error: error.message });
  } else if (error instanceof ValidationError) {
    res.status(400).json({ error: error.message, field: error.field });
  } else {
    // 未知错误，记录并返回通用错误
    logger.error('Unexpected error', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
```

### 4. 错误边界 (React)

```jsx
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    // 上报错误
    errorReporting.report(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}

// 使用
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

---

## API 错误响应

### 标准错误格式

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email format is invalid"
      }
    ],
    "requestId": "req_abc123",
    "timestamp": "2024-01-06T10:00:00Z"
  }
}
```

### 错误码设计

```javascript
const ErrorCodes = {
  // 验证错误 (4xx)
  VALIDATION_ERROR: { status: 400, message: 'Validation failed' },
  INVALID_INPUT: { status: 400, message: 'Invalid input' },
  UNAUTHORIZED: { status: 401, message: 'Authentication required' },
  FORBIDDEN: { status: 403, message: 'Access denied' },
  NOT_FOUND: { status: 404, message: 'Resource not found' },
  CONFLICT: { status: 409, message: 'Resource conflict' },
  RATE_LIMITED: { status: 429, message: 'Too many requests' },

  // 服务器错误 (5xx)
  INTERNAL_ERROR: { status: 500, message: 'Internal server error' },
  SERVICE_UNAVAILABLE: { status: 503, message: 'Service temporarily unavailable' },
};
```

### 全局错误处理中间件

```javascript
// Express 错误处理中间件
function errorHandler(err, req, res, next) {
  // 记录错误
  const requestId = req.id || uuidv4();
  logger.error({
    requestId,
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  // 已知错误
  if (err instanceof AppError) {
    return res.status(err.status).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
        requestId,
      }
    });
  }

  // 未知错误 - 不暴露内部信息
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      requestId,
    }
  });
}

app.use(errorHandler);
```

---

## 重试策略

### 指数退避

```javascript
async function withRetry(fn, options = {}) {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 30000,
    shouldRetry = (error) => true,
  } = options;

  let lastError;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;

      if (attempt === maxRetries || !shouldRetry(error)) {
        throw error;
      }

      // 指数退避 + 抖动
      const delay = Math.min(
        baseDelay * Math.pow(2, attempt) + Math.random() * 1000,
        maxDelay
      );

      await sleep(delay);
    }
  }

  throw lastError;
}

// 使用
const data = await withRetry(
  () => fetchFromAPI('/users'),
  {
    maxRetries: 3,
    shouldRetry: (error) => error.status >= 500 || error.code === 'ECONNRESET',
  }
);
```

### 断路器模式

```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 30000;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failures = 0;
    this.lastFailure = null;
  }

  async execute(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailure > this.resetTimeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('Circuit breaker is OPEN');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failures++;
    this.lastFailure = Date.now();
    if (this.failures >= this.failureThreshold) {
      this.state = 'OPEN';
    }
  }
}
```

---

## 日志与监控

### 错误日志结构

```javascript
logger.error({
  // 上下文
  requestId: req.id,
  userId: req.user?.id,
  path: req.path,
  method: req.method,

  // 错误信息
  error: {
    name: error.name,
    message: error.message,
    code: error.code,
    stack: error.stack,
  },

  // 额外数据（脱敏）
  input: sanitize(req.body),
  timestamp: new Date().toISOString(),
});
```

### 告警规则

```yaml
alerts:
  - name: high_error_rate
    condition: error_rate > 1%
    duration: 5m
    severity: critical

  - name: slow_response
    condition: p99_latency > 5s
    duration: 10m
    severity: warning

  - name: circuit_breaker_open
    condition: circuit_state == 'OPEN'
    severity: critical
```

---

## 与 TAD 框架的集成

在 TAD 的开发流程中：

```
设计 → 实现 → 错误处理 → 测试
              ↓
         [ 此 Skill ]
```

**TAD 集成点**：
1. Alex 设计错误处理策略
2. Blake 实现错误处理代码
3. Gate 验证错误处理完整性

---

## 错误处理检查清单

### 代码层面

```
□ 所有可能失败的操作都有错误处理？
□ 错误类型明确分类？
□ 不会静默吞掉错误？
□ 错误信息对调试有帮助？
□ 敏感信息不会暴露给用户？
```

### 系统层面

```
□ 有全局错误处理？
□ 有错误日志记录？
□ 有告警机制？
□ 有降级策略？
□ 有重试机制（如需要）？
```

---

## 常见错误

### ❌ 空的 catch 块

```javascript
// ❌
try {
  doSomething();
} catch (e) {
  // 什么都不做
}

// ✅
try {
  doSomething();
} catch (e) {
  logger.error('Failed to do something', e);
  throw e; // 或适当处理
}
```

### ❌ 捕获所有异常

```javascript
// ❌
try {
  doSomething();
} catch (e) {
  // 处理所有异常
}

// ✅
try {
  doSomething();
} catch (e) {
  if (e instanceof ExpectedError) {
    // 处理预期错误
  } else {
    throw e; // 重新抛出未知错误
  }
}
```

---

*此 Skill 指导 Claude 实现健壮的错误处理策略。*
