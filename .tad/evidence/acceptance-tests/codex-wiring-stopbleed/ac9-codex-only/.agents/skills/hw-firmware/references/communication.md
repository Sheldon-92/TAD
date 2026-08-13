# Communication Protocols (通信协议)

> WiFi STA/AP、BLE、MQTT、HTTP API、OTA 更新。

## 1. Select — 选择通信方案

| 需求 | 推荐方案 | 库 |
|------|----------|-----|
| 连接家庭 WiFi 拉取数据 | WiFi STA | WiFi.h (内置) |
| 手机直接控制（无路由器）| WiFi AP + Captive Portal | WiFi.h + WebServer |
| 低功耗近距离手机连接 | BLE | NimBLE-Arduino |
| 云端双向通信 | MQTT | PubSubClient |
| HTTP API 调用 | HTTPS Client | WiFiClientSecure |
| 固件远程更新 | OTA | ArduinoOTA / esp_https_ota |

组合模式：
1. **WiFi STA + HTTPS**: 周期性拉取 API 数据（如 Movebank）
2. **WiFi AP + WebServer**: 本地配置页面（参考 _template wifi_server.h）
3. **WiFi STA + MQTT**: IoT 云平台双向通信
4. **BLE + WiFi STA**: BLE 配网 → WiFi 传数据（节省配置步骤）

安全选择：
- HTTPS: WiFiClientSecure + CA 证书或指纹验证
- MQTT: TLS 1.2 + client cert（如有）
- BLE: NimBLE 配对 + 绑定

## 2. Execute — 实现通信模块（以 WiFi STA + HTTPS 为例）

```cpp
// network.h
#pragma once
#include "config.h"
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>

// RTC-cached WiFi params for fast reconnect
RTC_DATA_ATTR uint8_t savedBSSID[6] = {};
RTC_DATA_ATTR int32_t savedChannel = 0;

bool wifi_connect(const char* ssid, const char* pass, uint32_t timeoutMs = 10000) {
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(false);  // Manual control for power

  // Fast reconnect if we have cached params
  if (savedChannel > 0) {
    WiFi.begin(ssid, pass, savedChannel, savedBSSID, true);
  } else {
    WiFi.begin(ssid, pass);
  }

  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - start > timeoutMs) {
      Serial.println(F("[ERR] WiFi timeout"));
      WiFi.disconnect(true);
      return false;
    }
    delay(100);
  }

  // Cache for next fast reconnect
  memcpy(savedBSSID, WiFi.BSSID(), 6);
  savedChannel = WiFi.channel();

  Serial.print(F("[OK] WiFi connected, IP: "));
  Serial.println(WiFi.localIP());
  return true;
}

String https_get(const char* url, const char* caCert = nullptr) {
  WiFiClientSecure client;
  if (caCert) {
    client.setCACert(caCert);
  } else {
    client.setInsecure();  // Skip cert verify — [WARN] dev only
  }

  HTTPClient http;
  http.begin(client, url);
  http.setTimeout(10000);
  int code = http.GET();

  String payload = "";
  if (code == HTTP_CODE_OK) {
    payload = http.getString();
    Serial.println(F("[OK] HTTPS GET ") + String(code));
  } else {
    Serial.println(F("[ERR] HTTPS GET ") + String(code));
  }
  http.end();
  return payload;
}

void wifi_disconnect() {
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
}
```

MQTT 实现要点：
- PubSubClient 默认 buffer 128 字节 → 调大: `client.setBufferSize(1024)`
- Keepalive: `client.setKeepAlive(60)`
- Last Will: `client.connect(id, willTopic, willQos, willRetain, willMsg)`
- 重连: 非阻塞 millis 计时，不用 while loop

## 3. Verify — 验证通信

1. **编译**: 通信模块编译零 error
   `arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 ./project/`
2. **WiFi 连接**: 串口输出 "[OK] WiFi connected, IP: x.x.x.x"
3. **HTTPS 请求**: 对目标 API 做 GET 请求，验证返回 200
   测试 URL: https://httpbin.org/get
4. **超时处理**: WiFi 密码错误 → 10s 超时 → 不卡死
5. **断线重连**: WiFi.disconnect() → 自动重连 → 串口日志确认
6. **内存检查**: esp_get_free_heap_size() 在连接前后对比
   WiFi + TLS 典型消耗: 30-50KB heap
7. **RSSI 检查**: WiFi.RSSI() > -70dBm 为良好信号

## 4. Optimize — 通信优化

1. **连接速度**:
   - WiFi 快速重连（RTC 缓存 BSSID + Channel）
   - DNS 缓存或直接用 IP
2. **流量优化**:
   - JSON → MessagePack / CBOR（省 40-60% 字节）
   - 批量传输（N 条数据一次发送）
   - gzip 压缩（如果服务端支持）
3. **可靠性**:
   - 发送失败 → 存入 SPIFFS/LittleFS 队列 → 下次补发
   - MQTT QoS 选择: 状态更新 QoS 0, 重要事件 QoS 1
4. **安全**:
   - 生产环境不用 setInsecure()（→ 嵌入 CA 证书）
   - API key 不硬编码（→ 存 NVS 或 config portal 输入）
   - 证书到期检查（Let's Encrypt 90 天）
5. **OTA 准备**:
   - 预留 Flash 分区给 OTA（至少 50% 空闲）
   - esp_https_ota() 远程固件更新

安全/健壮性硬规则（来源: Wayo 项目实测）：HTTP/JSON 响应必须有大小限制 — JsonDocument 指定 capacity 或用 `DeserializationOption::Filter`，防止异常/恶意响应 OOM（ArduinoJson 无限制解析可耗尽 heap）。

Pass/fail: see `quality-criteria.md` §Communication. Reviewer checklist: see `review-checklist.md` §IoT 通信工程师.
