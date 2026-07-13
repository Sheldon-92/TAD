# Review Checklists (reviewer personas per capability)

> Run the matching persona checklist BEFORE gate review / accepting any firmware capability's deliverable.
> Source: hw-firmware Domain Pack `reviewers` blocks (archived 2026-06-11). Pair with `quality-criteria.md` pass/fail rules.

## 嵌入式架构师 (Firmware Architecture)

- 模块划分是否清晰？依赖方向是否单一？
- 状态机是否覆盖所有合法状态转换？
- 内存预算是否合理？有没有预留 OTA 空间？
- 初始化顺序是否考虑了总线共享？

## 硬件驱动工程师 (Peripheral Drivers)

- 每个驱动的初始化顺序是否正确？
- 总线共享是否有冲突保护？
- 错误恢复路径是否完整？
- 内存使用是否在预算内？

## 低功耗设计专家 (Low Power Design)

- 功耗预算是否包含所有阶段（含 Boot）？
- 唤醒策略是否匹配使用场景？
- RTC 内存使用量是否在 8KB 限制内？
- 是否有 WiFi 快速重连优化？

## IoT 通信工程师 (Communication)

- 通信协议选择是否匹配功耗需求？
- TLS 配置是否安全？
- 断线重连是否可靠？
- 数据格式是否高效？

## 构建工程师 (Build & Upload)

- 所有库依赖是否版本锁定？
- 分区表是否为目标场景优化？
- 构建是否可重复（其他人 clone 能直接编译）？

## QA 测试工程师 (Firmware Testing)

- 测试层级是否覆盖编译+逻辑+硬件？
- 错误路径是否有测试覆盖？
- 测试是否可自动化运行？
- 测试输出是否可机器解析？

## 技术文档工程师 (Firmware Documentation)

- 新人读完文档能否独立完成硬件接线和固件烧录？
- 引脚映射表是否与代码一致？
- 图表是否用可版本控制的格式（D2/Mermaid）？
- 是否有 CHANGELOG 记录版本变更？
