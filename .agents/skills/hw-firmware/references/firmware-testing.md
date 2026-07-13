# Firmware Testing (固件测试)

> 串口调试、单元测试、集成测试、自动化验证。

## 1. Select — 确定测试策略（嵌入式三层模型）

| 层级 | 内容 | 工具 | 运行环境 |
|------|------|------|----------|
| L1: 编译 | 编译通过 + 静态检查 | arduino-cli | Host |
| L2: 逻辑 | 纯逻辑单元测试（无硬件依赖） | PlatformIO Unity / ArduinoUnit | Host (native) |
| L3: 硬件 | 外设交互测试 | Serial 日志 + 人工验证 | Target board |

L1 编译测试（必须）:
- arduino-cli compile 零 error
- --warnings more 无新 warning

L2 逻辑测试（推荐）:
- 状态机转换逻辑
- 数据解析/编码
- 配置参数校验
- 可以在 host (PC) 上运行，不需要硬件

L3 硬件测试（关键路径）:
- Serial.println 日志 + 人工观察
- 结构化测试日志格式: `[TEST] name: PASS/FAIL`
- I2C scan / WiFi connect / touch read

## 2. Execute — 实现测试代码

**L1 编译测试脚本**:
```bash
#!/bin/bash
# test-compile.sh
set -e
echo "=== Compile Test ==="
arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 \
  --warnings more ./project/ 2>&1 | tee build.log

# Check for errors
if grep -q "error:" build.log; then
  echo "[TEST] compile: FAIL"
  exit 1
fi
echo "[TEST] compile: PASS"

# Check flash/ram usage
FLASH_PCT=$(grep "Sketch uses" build.log | grep -o '[0-9]*%' | tr -d '%')
RAM_PCT=$(grep "Global variables" build.log | grep -o '[0-9]*%' | tr -d '%')
echo "[TEST] flash_usage: ${FLASH_PCT}% (limit: 75%)"
echo "[TEST] ram_usage: ${RAM_PCT}% (limit: 60%)"
```

**L3 硬件自测函数**（在 setup() 中可选调用）:
```cpp
void runSelfTest() {
  Serial.println(F("\n=== SELF TEST ==="));
  int passed = 0, failed = 0;

  // Test 1: I2C bus
  Wire.beginTransmission(OLED_ADDR);
  if (Wire.endTransmission() == 0) {
    Serial.println(F("[TEST] i2c_oled: PASS"));
    passed++;
  } else {
    Serial.println(F("[TEST] i2c_oled: FAIL"));
    failed++;
  }

  // Test 2: Touch input (read value, check range)
  uint32_t tv = touchRead(TOUCH_PINS[0]);
  if (tv > 0 && tv < 500000) {
    Serial.println(F("[TEST] touch_read: PASS (") + String(tv) + ")");
    passed++;
  } else {
    Serial.println(F("[TEST] touch_read: FAIL (") + String(tv) + ")");
    failed++;
  }

  // Test 3: Free heap
  uint32_t heap = esp_get_free_heap_size();
  if (heap > 100000) {
    Serial.println(F("[TEST] heap_free: PASS (") + String(heap) + ")");
    passed++;
  } else {
    Serial.println(F("[TEST] heap_free: FAIL (") + String(heap) + ")");
    failed++;
  }

  Serial.print(F("=== RESULT: "));
  Serial.print(passed); Serial.print(F(" passed, "));
  Serial.print(failed); Serial.println(F(" failed ==="));
}
```

日志格式规范:
- 前缀: [TEST] [OK] [WARN] [ERR] [SLEEP] [BOOT]
- 测试: `[TEST] test_name: PASS/FAIL (optional_value)`
- 时间戳: millis() 在关键事件旁

## 3. Verify — 运行测试套件

1. **L1 运行**: `bash test-compile.sh` → 零 error + usage 在预算内
2. **L3 运行**: 上传 → 串口监控 → 检查 [TEST] 输出
   `arduino-cli upload ... && arduino-cli monitor ...`
3. **结果汇总**:
   - 所有 [TEST] 行收集 → PASS/FAIL 统计
   - 任何 FAIL → 标记为 blocking issue
4. **回归检查**: 修改代码后重新跑 L1 + L3
5. **边界条件**: 特别关注
   - WiFi 连接超时
   - I2C 设备不存在
   - Flash 写满（SPIFFS/LittleFS）
   - Deep Sleep 唤醒后状态恢复

## 4. Optimize — 测试优化

1. **自测模式开关**:
   - `#define SELF_TEST_ON_BOOT 1` (config.h)
   - 生产固件设为 0 → 跳过自测节省启动时间
2. **测试自动化**:
   - test-compile.sh 集成到 pre-commit hook
   - CI: GitHub Actions + arduino-cli compile
3. **串口日志解析**:
   - 脚本自动解析 [TEST] 行 → 生成报告
   - `grep "\[TEST\]" serial.log | grep "FAIL"` → 快速发现失败
4. **Mock 模式**:
   - `#define MOCK_PERIPHERALS 1` → 跳过真实 I2C 操作
   - 用于无硬件环境的逻辑测试
5. **性能基准**:
   - 记录 setup() 耗时: millis() at start vs end
   - 记录 loop() 单次耗时 → 确保不超过显示刷新间隔

Pass/fail: see `quality-criteria.md` §Firmware Testing. Reviewer checklist: see `review-checklist.md` §QA 测试工程师.
