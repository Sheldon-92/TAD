# Build & Upload (构建与上传)

> 编译配置、上传流程、版本管理、分区表。

## 1. Select — 确定构建配置

1. **Board FQBN**: 从 `arduino-cli board listall` 选择。常用:
   - esp32:esp32:XIAO_ESP32S3
   - esp32:esp32:esp32c3
   - esp32:esp32:esp32s3
2. **分区表** — 默认分区表 (4MB Flash):
   | 分区 | 偏移 | 大小 | 用途 |
   |------|------|------|------|
   | nvs | 0x9000 | 20KB | WiFi 配置、用户数据 |
   | otadata | 0xE000 | 8KB | OTA 状态 |
   | app0 | 0x10000 | 1.25MB | 主固件 |
   | app1 | 0x150000 | 1.25MB | OTA 固件 |
   | spiffs | 0x290000 | 1.5MB | 文件系统 |

   如需更大 app 空间（无 OTA）: huge_app.csv — app 3MB + spiffs 1MB
3. **构建参数**:
   - Flash Mode: QIO (最快) / DIO (兼容)
   - Flash Freq: 80MHz (默认) / 40MHz (省电)
   - CPU Freq: 240MHz (默认) / 80MHz (省电)
   - PSRAM: Enable (如果板载有 PSRAM)
4. **库依赖**: 列出所有需要的库及版本
   `arduino-cli lib install "库名@版本"`

## 2. Execute — 构建与上传流程

```bash
# Step 1: 安装/更新库依赖
arduino-cli lib install "Adafruit GFX Library@1.11.11"
arduino-cli lib install "Adafruit SH110X@2.1.11"
arduino-cli lib install "GxEPD2@1.6.0"
arduino-cli lib install "PubSubClient@2.8"

# Step 2: 编译
arduino-cli compile \
  --fqbn esp32:esp32:XIAO_ESP32S3 \
  --build-property "build.extra_flags=-DVERSION=\"1.0.0\"" \
  --warnings more \
  --verbose \
  ./project/ 2>&1 | tee build.log

# Step 3: 检查编译输出
# Sketch uses XXXXX bytes (XX%) of program storage space.
# Global variables use XXXXX bytes (XX%) of dynamic memory.

# Step 4: 上传
arduino-cli upload \
  -p /dev/cu.usbmodem* \
  --fqbn esp32:esp32:XIAO_ESP32S3 \
  ./project/

# Step 5: 串口监控验证
arduino-cli monitor -p /dev/cu.usbmodem* --config baudrate=115200
```

版本管理：
- 在 config.h 中定义: `#define FW_VERSION "1.0.0"`
- 编译时注入: `--build-property "build.extra_flags=-DVERSION=\"1.0.0\""`
- setup() 中打印: `Serial.println(F("Firmware v" FW_VERSION))`
- 用 sketch.yaml 记录板卡和库依赖（arduino-cli 项目文件）

## 3. Verify — 验证构建结果

1. **编译结果**: 零 error, warnings ≤3
2. **Flash 使用率**: < 75%（留 OTA 空间）
3. **RAM 使用率**: < 60%（留运行时堆空间）
4. **上传成功**: 串口输出 boot 信息
5. **版本确认**: 串口输出含 FW_VERSION 字符串
6. **功能验证**: 运行基本功能检查清单
   - [ ] I2C scan 输出所有设备
   - [ ] OLED 显示正常
   - [ ] WiFi 连接成功
   - [ ] Touch 响应
   - [ ] Deep Sleep 进入和唤醒
7. **构建可重复**: 同一代码第二次编译结果一致

## 4. Optimize — 构建优化

1. **编译速度**:
   - arduino-cli 缓存: 默认启用，第二次编译快 50%+
   - 只修改的文件重新编译（增量编译）
2. **Flash 优化**:
   - 移除未使用的库 include
   - -Os 优化级别（默认）
   - LTO (Link Time Optimization): `--build-property "compiler.c.elf.extra_flags=-flto"`
3. **sketch.yaml 锁定**:
   ```yaml
   default_fqbn: esp32:esp32:XIAO_ESP32S3
   default_port: /dev/cu.usbmodem*
   profiles:
     xiao_s3:
       fqbn: esp32:esp32:XIAO_ESP32S3
       libraries:
         - name: "Adafruit GFX Library"
           version: "1.11.11"
   ```
4. **CI 准备**:
   - 把 arduino-cli compile 命令写入 Makefile
   - GitHub Actions 支持 arduino-cli 编译验证

Pass/fail: see `quality-criteria.md` §Build & Upload. Reviewer checklist: see `review-checklist.md` §构建工程师.
