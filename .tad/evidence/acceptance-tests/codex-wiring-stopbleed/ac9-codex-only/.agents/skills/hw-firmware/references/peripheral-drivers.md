# Peripheral Drivers (外设驱动开发)

> I2C/SPI 设备初始化、驱动 API 封装、错误处理。

## 1. Select — 盘点外设与驱动库

盘点所有外设，为每个选择驱动库：

1. 列出所有外设：
   | 外设 | 接口 | 地址/引脚 | 库 | 版本 |
2. 驱动库选择优先级：
   a. Adafruit 官方库（文档最全、社区最大）
   b. SparkFun 官方库（硬件匹配的模块）
   c. 芯片原厂 SDK 封装
   d. 社区高星库（>100 stars, 近 6 个月有更新）
   e. 自写驱动（仅当无现成库时，标注 [CUSTOM]）
3. 每个库验证：
   `arduino-cli lib search "库名"`
   `arduino-cli lib install "库名@版本"`
4. I2C 地址冲突检查：列出所有 I2C 设备地址，确认无冲突

常用库参考（用户验证过）：
- OLED SH1106: Adafruit_SH110X + Adafruit_GFX
- Haptic DA7280: SparkFun Haptic_Driver
- E-ink: GxEPD2 (Jean-Marc Zingg)
- Touch: ESP32 内置 touchRead()（无需额外库）
- WiFi: WiFi.h (ESP32 内置)
- BLE: NimBLE-Arduino（比官方 BLE 库省 ~50% Flash）

## 2. Execute — 写驱动封装

为每个外设写驱动封装 .h 文件。驱动封装模板：

```cpp
#pragma once
#include "config.h"
#include <ExternalLib.h>

// Driver state
static bool _deviceReady = false;

// Init: returns true if device found
bool deviceName_init() {
  // I2C: check address responds
  Wire.beginTransmission(DEVICE_ADDR);
  if (Wire.endTransmission() != 0) {
    Serial.println("[WARN] DeviceName not found at 0x" + String(DEVICE_ADDR, HEX));
    return false;
  }
  // Library-specific init
  _deviceReady = true;
  return true;
}

// Getter: check _deviceReady before operation
int deviceName_read() {
  if (!_deviceReady) return -1;
  return lib.readValue();
}
```

关键规则：
1. 每个驱动文件 `#pragma once` + `#include "config.h"`
2. init() 先做 I2C/SPI 存在性检测，再调库 init
3. 所有公开函数检查 _deviceReady 状态
4. Serial.println 日志标注 [OK] / [WARN] / [ERR] 前缀
5. 不在驱动内调 delay()（交给调用者决定）

## 3. Verify — 逐个验证驱动

1. **编译测试**: 每个 driver .h 单独 include 到测试 .ino 编译
   `arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 ./test-driver/`
2. **I2C scan 验证**: 运行 i2cScan() 确认设备在线
   串口输出应有: "Found 0x3C (OLED)" 等
3. **基本功能测试**: 每个驱动写最小测试
   - 显示驱动: 画一个像素点 → display.display()
   - 传感器: 读取一个值 → Serial.println()
   - 触摸: touchRead() 返回值在合理范围
4. **错误路径测试**: 拔掉外设（或不连接）→ init() 返回 false，不崩溃
5. **内存占用**: 编译输出对比每加一个驱动的内存增量

## 4. Optimize — 优化驱动

1. **Flash 优化**:
   - 字符串用 F() 宏: `Serial.println(F("[OK] OLED ready"))`
   - 大查找表用 PROGMEM
   - 不用的库功能用 #define 关闭
2. **RAM 优化**:
   - 显示 buffer 检查是否可以用部分刷新（E-ink: window mode）
   - 字符串拼接用 snprintf 替代 String 类（避免堆碎片）
3. **可靠性**:
   - I2C 操作加超时: `Wire.setTimeOut(100)`
   - SPI 操作前检查 busy 标志
   - 看门狗: `esp_task_wdt_add(NULL)` 防止死循环卡死
4. **总线共享**:
   - I2C 多设备: 确保不在中断中调用 Wire
   - SPI 多设备: 正确使用 CS 引脚切换

Pass/fail: see `quality-criteria.md` §Peripheral Drivers. Reviewer checklist: see `review-checklist.md` §硬件驱动工程师.
