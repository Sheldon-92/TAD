# TICKET-20261028-backup-fixture-tmpfs-stat

- Status（2026-10-31）：已修，待 Gate 验——`mode_of()` 已改语义值分派（Phase 1 小修批 Step 1，HANDOFF-20261031-small-fix-batch）；双平台证据在 `.tad/evidence/yolo/v409-basket/`（VM 改后行集 `salvage-vm-after.txt`、Mac 改前基线 `salvage-mac-baseline.txt`、AC2 测床 `ac2-modeof-testbed.txt`）；Mac 改后轮待同步到达后重跑，关票留收口。
- 来源：v4.0.8 发版克隆步 run-all（2026-10-28）；conductor 对照实证后立票。
- 现象：`backup-lifecycle-fixture.sh --case salvage` 的一条断言（diff 文件 stat 转储比对）在本机 /tmp（tmpfs）上失败，`PASS=8 FAIL=1`；其余断言全过，含「文件内容不外泄」。
- 对照实证：以 v4.0.7 tag 原样代码在本机同环境同跑同断言同文失败——系 fixture 的期望 stat 转储对文件系统类型不宽容（tmpfs 的 stat 渲染与录制环境不同），非产品回归、非 4.0.8 引入。
- 影响：run-all 在 tmpfs-/tmp 机器上恒红一个单元，久之钝化真红灯。
- 期望处置：该断言改比语义字段（mode 数值、文件类型）而非整段 stat 文本；或按文件系统类型分开期望。改后在本机与录制环境各跑一次留证。
- Owner：TAD PM（随下一批维护票处理，不阻塞发版）。

## 归因更正（2026-10-28，Home 只读复核指出、TAD PM 盘验属实）

- 本票原题与上文「tmpfs」归因**有误**：真因是 `backup-lifecycle-fixture.sh:91` 的 `stat -f '%Lp' … || stat -c '%a'`——GNU coreutils 下 `stat -f` 是文件系统状态查询且以 exit 0 输出整段文件系统信息，`||` 回退永不接管，比对必然失败；Home 已在 ext4 上复现，与文件系统类型无关。原判读系见 stat 转储中 `Type: tmpfs` 字样即下结论、未变换变量验证，本席认错。
- 仍成立的只有回归结论（经对照跑实证）：该失败非 4.0.8 引入，v4.0.7 代码在 GNU/Linux 上同败（4.0.7 当轮检查在 macOS 上跑，故未暴露）。
- 处置方向不变：断言改比语义字段（mode 数值、文件类型），或按 BSD/GNU 分开期望；改后在 GNU/Linux 与 macOS 各跑一次留证。文件名含 tmpfs 系立票时的错误归因，留名存证、不改名。
