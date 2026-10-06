# Phase 1 适配验证记录 — 件 3.1（OpenCode）＋件 3.2（Cursor）

- 链：TICKET-20261006-epic-p3-runtime；设计正本 HANDOFF §4.1/§4.2；Phase 0 结论见 `2026-10-06-p3-phase0-probes.md`（OC-1 名册 {write, edit}／OC-2 分支 A／OC-3 注入对等／OC-4 注入支启用／OC-7 直调）。
- 执行：Blake，2026-10-06。真机面：grokbox 骨架仓 `/home/box/p3-skeleton-tad`；原始日志面 `/home/box/p3-probe-logs/`（grokbox 本地）。
- 落地件：`.opencode/plugins/tad-hooks.ts`（5,715 B）、`.cursor/hooks.json`、`.tad/hooks/lib/cursor-session-start.sh`、`.tad/hooks/lib/cursor-post-write.sh`；`tad.sh` 五处改动（两投影族函数＋preflight/project/rollback 三个调用点＋自检段两 cmp 块＋L519 邻域注记改写）。

## 1. 投影 fixture（AC5／AC12，函数级）

法：sed 抽 tad.sh 新函数入 harness（仓内既有 fixture 法），mktemp 目标四案。结果 **12/12 PASS**：
- 干净装：两件落位＋与源 cmp 同体；
- 分歧负控：插件与 hooks.json 各自 preflight 非零退出且本地文件逐字未动；
- rollback：本轮所建两件被移除、目录树回到空；
- 预存同体：project 不置 created 旗、rollback 不删预存文件。
脚本：`/tmp/p3-projection-fixture.sh`（VM 本地）；全输出已于执行当轮核对（12 PASS 行）。

## 2. 垫片转码 fixture（AC9／AC13）

法：/tmp 结构内真实垫片＋真实共享脚本＋假目标三态。结果：
- session-start 真跑：Cursor payload 进 → `{"additional_context": "TAD v3.1.0 | 0 handoffs | 0 epics | 0 ideas | Hooks: active"}`，exit 0；
- post-write 真跑（路径 `.tad/active/handoffs/HANDOFF-20990101-fixture-case.md`）：`additional_context` 转码对位（Handoff 提醒全文）、session-state 的 `Last File Written` 已更新、当日 trace 落 `handoff_created` 行；
- 非托管路径：`{}`＋exit 0；
- 假目标三态（垃圾输出／空输出／exit 1）：垫片恒 `{}`＋exit 0（AC13）。
- 过程注记：首跑 E 案因 fixture 路径未含 `.tad/active/handoffs/` 前缀落入共享脚本的非托管分支（`{}` 为正确行为），按真实路径形态重跑后全过——判别力自证在案。

## 3. 骨架仓实装（AC5／AC12 实装路＋AC6 自检）

- 命令：骨架内 `bash /home/box/p3-src-tad/tad.sh --source /home/box/p3-src-tad --platform codex --yes --force`（源树＝本仓实施完成态副本，tar 管道自 VM 送达）。
- 结果：exit 0；日志含 `Projected .opencode/plugins/tad-hooks.ts` 与 `Projected .cursor/hooks.json` 两行；自检段 `Self-check passed: 91 derived paths (diff-clean) + 23 top-level files present`；两件与源 cmp 同体。
- 原始日志：`/home/box/p3-probe-logs/phase1-install.log`（sha256 `ccda15b5…fc`）。

## 4. 触发实测（AC3／AC11＋Cursor 写链）

- **OpenCode 会话**（`opencode run --model opencode-go/deepseek-v4.1-flash`，任务：建＋改 `.tad/active/handoffs/HANDOFF-20990101-p1-opencode-probe.md`）：exit 0；骨架 `.tad/evidence/traces/2026-10-06.jsonl` 新增 `handoff_created` 行；session-state 的 `Hook Last Touched` 与 `Last File Written` 已更新。日志 `/home/box/p3-probe-logs/p1-opencode-session.log`（sha256 `8a78c815…61`）。
- **Cursor 会话**（`agent -p --trust`，任务：建 `.tad/active/handoffs/HANDOFF-20990102-p1-cursor-probe.md`）：exit 0；当日 `handoff_created` 增至 2 行（第二行即本会话）；`Last File Written` 指向本会话文件。经投影 hooks.json＋matcher Write＋垫片的实链成立。日志 `/home/box/p3-probe-logs/p1-cursor-session.log`。
- **AC11（preCompact 落位）**：hooks.json 的 preCompact 条目直调共享脚本；其 Cursor 形 envelope 兼容已由 OC-7 实测（快照正确落盘）。短会话内无 compact 事件，CLI 内实触发未观测——此点以 OC-7 直调实测＋条目在盘为据，如实标注强度为 probed（非 live-fired）。

## 5. 注入与 compacting（AC3 注入支／AC4）

- 注入支：OC-4 已验 output 改写达模型，插件按启用形态落地（post-write 的 additionalContext 追加进 `output.output`）。
- **session.created 接线证明**（仪表化 fixture，/tmp/p3-wirefx）：假 startup-health 捕获到插件合成的 envelope 原文 `{"hook_event_name":"SessionStart","source":"startup","cwd":"/tmp/p3-wirefx"}`——事件→插件→共享脚本的调用链成立。
- **AC4 compacting**：以 bun 直跑真实插件处理器（假 `$` 回放共享脚本 compact 分支输出）：`experimental.session.compacting` 把 `Post-compact: read session-state…` push 进 `out.context`，合成 envelope 为 `source:"compact"`，PASS；`$` 抛错时处理器静默、context 不变（fail-open），PASS。共享脚本 compact 分支本体另经直调实证（输出 Post-compact 提醒原文）。强度标注：处理器级实测（probed）——无头运行面无法按需触发真实 compaction 事件，live-fired 未观测；`session.compacted`→precompact 的事件支与 session.created 同一已证接线路径。

## 6. 故障负控（AC7／AC13 真机路）

- 骨架内令 `startup-health.sh` 与 `post-write-sync.sh` 同时不可执行后：OpenCode 会话 exit 0 回 DONE 且写文件成功；Cursor 会话 exit 0 回 DONE。脚本权限已恢复并验。日志 `/home/box/p3-probe-logs/p1-negctl-opencode.log`（sha256 `a48b84a7…b`）、`p1-negctl-cursor.log`。
- 结论：ASM-1（适配件在共享脚本故障下 fail-open）在骨架面成立。

## 7. 漂移红控（AC6 自检面）

- 骨架内给已装插件追加一行漂移后重跑安装器：exit 1，`OpenCode conflict: .opencode/plugins/tad-hooks.ts already exists and differs` FATAL，漂移文件逐字未动；随后自源恢复 cmp 同体。日志 `/home/box/p3-probe-logs/p1-drift.log`（sha256 `211d1d2a…db`）。自检段 cmp 与 preflight 为同一比对的两道防线，本红控走 preflight 一道实证。

## 8. 与设计字面的两处对位说明（供 Gate 3 判读）

1. **AC3「startup-health 副作用（traces 当日行新增）」**：共享脚本本体经实测不写 trace（VM 直跑对盘验证：零新文件，行为只有 stdout 输出健康 JSON）。会话当日 trace 行来自 post-write-sync。本链的 startup 触发以第 5 节仪表化 fixture 的 envelope 捕获为证、post-write 触发以骨架 trace 为证——判读时请按此实测形态对位，勿按 AC 字面把 trace 归于 startup-health。此为设计字面与盘上行为的出入，实施未改共享脚本（写集纪律），在此点名留痕。
2. **AC8「四条目」**：§4.2 形态表的第 4 行是「提问捕获不设条目」（R-CU-1），故 hooks.json 实落三事件条目（sessionStart/postToolUse/preCompact）＋提问条目缺席（设计形态）。jq 验：`version=1`、三键齐、`"failClosed": true` 零命中。

---
**收口指针（PM 补记，2026-10-06，闭 Gate 4 delta 2）**：本件 §4 所称骨架 handoff_created 行已无存活载体一事，其订正记述落在 COMPLETION-2026-10-06-epic-p3-runtime.md「Gate 3 订正追记」§2(b)（盘面实况：骨架 traces 现仅含两行 evidence_created、与仓内 raw 逐字相同；触发结论改以 session-state 元数据＋Phase 2 trace 行＋垫片复跑为据）。本件旧记述保留原文，以此指针为准。
