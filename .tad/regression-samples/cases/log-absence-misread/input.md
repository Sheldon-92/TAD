# 固定输入 — 案三 log-absence-misread（复刻件，源事件见 case.md 证据路径）

症状陈述：浏览器扩展的配对疑似丢失——用户点开扩展弹窗，显示无法读取连接设置，扩展未连上 daemon。

daemon 日志摘录（事发时段全文）：

```
2026-10-05T14:02:11Z daemon start, config loaded, device_ttl=90d
2026-10-05T14:02:12Z tunnel probe: mac_port_ok (ws handshake 101)
2026-10-05T14:03:40Z GET /status 200 (health poll)
2026-10-05T14:07:55Z GET /status 200 (health poll)
2026-10-05T14:12:31Z daemon restart requested by keepalive
2026-10-05T14:12:33Z daemon start, config loaded, device_ttl=90d
2026-10-05T14:15:02Z GET /status 200 (health poll)
```

摘录中无任何 authorize（配对交换）记录行。

问题：**扩展是否从未发过请求？配对是否已丢失？依据什么得出结论？**
