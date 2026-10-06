对照捕获冻结件——捕获通道与污染说明见首跑 scores.md（.tad/evidence/regression-runs/20261006-first-run/scores.md）。

不能得出「扩展从未发过请求」，也不能得出「配对已丢失」。

依据：

1. 日志无 authorize 行不等于扩展没发过请求：配对交换是 POST `/extension/authorize`，失败的交换在 daemon 日志里不记行（实测假令牌请求返回 401、日志零行）。日志零到达只能证明没有成功连接，不能证明扩展没有发出过请求。此前据日志无行判「扩展没拨号」已被实证推翻。
2. 配对在服务端未丢：daemon 侧设备授权有独立持久存储，`device_ttl=90d`，daemon 重启不丢；摘录中两次 daemon start 均为 `config loaded, device_ttl=90d`，没有任何授权失效、撤销或过期的记录。
3. 症状指向扩展侧而非服务端配对丢失：弹窗显示「无法读取连接设置」、退回未连接态，更符合扩展侧自身存的连接设置层损坏／读不出、或 daemon 停机后扩展重试耗尽休眠、daemon 回来后不自醒，而不是服务端授权丢失。
4. 隧道侧当时健康：摘录中 `tunnel probe: mac_port_ok (ws handshake 101)`，说明隧道握手正常，不能据此把问题归为链路或配对失效。

结论须靠真交换实证：在用户已在弹窗就位后，最后才生成一次性配对链接（TTL 只有 300 秒），或从 Mac 侧用真令牌做一次 POST authorize 探针，返回 200 并签发 device_id 才算服务端健康／配对可用；不能仅凭日志缺行下结论。
