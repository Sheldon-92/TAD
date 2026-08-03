# Model-Diversity Audit 实验结果：flash 审 flash 的盲区实测

> **日期**: 2026-08-02 | **实验设计**: 同日 *discuss 会话（multi-model portability 研究的 Wave 1b）
> **对象**: 全屋智能化 `LITE-20260802-1016-reminder-reliability`（deepseek-v4-flash 全程执行 + flash reviewer GATE PASS + 人验收归档 + **已部署生产**）
> **方法**: 强模型（Fable 5）code-reviewer 在严格隔离下盲审（契约盲版 + v2/v3 代码 + diff + 测试套件；不可见 flash reviewer 的任何既有发现）。审查者对每项发现用**执行探针**验证（6 个 targeted probes），非纯阅读。

## 结果：GATE PASS（flash 链）vs FAIL（强模型盲审）

盲审发现：**P0×1 + P1×6 + P2×12 + 11 类覆盖缺口**。

### 头条 P0（已在生产运行）

deferred-retry 预算（3 次 × 1.0s ≈ 3s）比代码自己预算的投递时长（Telegram 8s / action 20s）低一个数量级：3 个普通提醒同时触发、其中 Telegram 走满自己的 8s 预算时，晚 1 秒到期的无关提醒会在 4 秒内烧完全部重试、被判 terminal/failed——**从未被播报、从未发 Telegram、timer 已删，用户只收到"没能执行成功"**。执行探针实证：5 个同秒提醒丢 2 个。这是对 v2 的回归（v2 无界线程反而全部播出），且违反契约 decision 6（无动作提醒输出不变）。**系统完全健康时发生**——恰好是这单要防的"丢提醒"。

### 逐条对照：flash reviewer 抓到了什么、漏了什么

| 发现域 | flash L3（记录在案） | 强模型盲审 | 判定 |
|---|---|---|---|
| deferred attempts 不变量记账 | ✅ P1-1 | （被 P0 包含） | **部分重叠——flash 修了记账，漏了同一子系统的时序比率 P0** |
| admission 槽位泄漏 release-first | ✅ P1-2 | P1-7：except OSError 窄卫兵在其它异常类仍永久漏槽 | 部分——flash 的修复不完整 |
| audit_unavailable 日志事件 | ✅ P1-3 | P2：action_failed/telegram_failed 字面事件名仍缺 | 部分 |
| 测试契约矛盾 | ✅ P1-4 | P2×3：空断言（tmp 检查永假匹配、并发峰值在 33× cap 下照样过、retry 时序调参凑绿） | 部分——flash 抓了矛盾，漏了非判别性 |
| 生产路径零覆盖 | ✅ P1-5 | 覆盖缺口：_tick/_startup_catchup 端到端仍零测试 | 部分 |
| _evict_for_new 淘汰边缘 | ✅ P2 | P2：已存在 fire 重试被误判 capacity_exhausted | 相邻重叠 |
| 失败状态无用户话术 | ✅ P2 | P2 族（recovery/audit/telegram 均无话术） | 重叠 |
| **重试预算 vs 投递时长比率 → 健康系统静默丢提醒（P0）** | ❌ | ✅ 执行实证 | **漏** |
| fires.json 损坏时 fail-open → 去重账本清零、物理动作重派 | ❌ | ✅ P1 执行实证 | **漏** |
| fires.json 无 flock（timers.json 有）→ 跨进程丢更新 | ❌ | ✅ P1 | **漏** |
| _dispatch_due 无逐 timer 异常隔离 → 一个失败吞掉同秒整批 | ❌ | ✅ P1 执行实证 | **漏** |
| 崩溃恢复静默丢失（terminal/uncertain 零通知） | ❌ | ✅ P1 | **漏** |
| announce=ok 只证明入队未证明播出、喂给 outcome=done | ❌ | ✅ P1（**诚实契约单里的诚实性缺陷**） | **漏** |
| retention >256 永不收敛 / 无 phase 记录不朽 / DST spring-forward / chmod 吞错 / 资源锁无超时 / _mark_fire 返回值被忽略 等 | ❌ | ✅ P2×~8 | 漏 |

### 结论

1. **flash 审 flash 有真实且系统性的盲区**：抓得住记账/契约文本相邻/表层缺陷（5 P1 都是真的），抓不住需要对抗性压力推演的系统性缺陷（时序比率、fail-open 语义、跨进程竞争、批处理放大）。最刺眼的是：**诚实契约主题的单，漏掉了 announce=ok 的诚实性缺陷**。
2. **两个变量混杂，都要吸收**：(a) 模型强度；(b) 审查方法——盲审者对每项发现跑了执行探针，flash reviewer 以读代验。方法差异至少与模型差异同量级。
3. **对混编舰队的裁定**：执行=便宜模型可行（本单执行质量高，canonical fire_id/DST 双向算术被盲审独立验证正确）；**生产关键单的 L3 审查必须强模型 + 强制执行探针**。lite L3 reviewer prompt 应加"可运行处必须以执行验证，不得以读代验"条款。
4. **Gate 逃逸数据点**：本单 Technical Gate + 人验收全过，P0 逃逸至生产 → 计入 gate-roi escape-rate。同时印证 7-27 评估 §5/CAAF：AC 全绿（28/28 测试、11/11 AC）≠ 无缺陷——3 条核心断言非判别、live AC 恰好停在 cap 边界之下。

### 直接行动项

- 🔴 **生产风险现服役**：v3 已跑在 homeserver。≥3 个提醒同秒（或一次慢 Telegram）即触发静默丢失——含吃药提醒场景。修复单最小集：重试退避按最坏占用（3×20s 串行）定界或 admission-deferral 不消耗重试；fires.json fail-closed 读 + flock + fsync 目录；_dispatch_due 逐 timer 隔离；槽位释放改 finally；补慢投递与损坏账本两类测试。
- 盲审全文已抄送全屋智能化项目：`.tad/evidence/research/2026-08-02-external-blind-audit-reminder-reliability.md`
- lite 协议改进项（并入 Wave 3）：L3 reviewer prompt 增加执行探针强制条款 + 生产关键单 reviewer 模型档位规则
