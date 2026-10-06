# Phase 0 核查点清账记录 — Epic Phase 3「运行时适配补全」

- 链：TICKET-20261006-epic-p3-runtime；HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md`（86,126 B／sha256 `2c77e39f42b65bd85887b66bb41b56c5172f2aacdf446a5ce046921e77035b64`，开工复算全等）。
- 执行：Blake（原生 subagent 续跑席；前任 Blake 于 Phase 0 因 grokbox 隧道中断停步、零实施写入，本席从 Phase 0 重走）。
- 日期：2026-10-06（EDT）。真机面：grokbox（ssh `box@grokbox`）。
- PM 裁断 D-5 在案：本记录所列分支处置均按 HANDOFF §4 预写执行，逐项回填如下，不逐项停步等裁。

## 0. 基线锚（承接 B「变更前」面）

- 前任暂存 `/tmp/p3-blake-43600a95/` 已失（本席开工核查不存在），按任务书口径在新暂存 `/tmp/p3-blake-Dqnr3y/`（VM 本地）重采并落本节；数值与前任回执对位：HEAD、8 件 sha 全等；`git status` 行数前任 60、本席 61，增量 1 行经查为 `?? docs/pm/open-cards/2026-10-06-epic-p3-impl-resume-start-card.md`（PM 续跑派发时新增的开跑卡），归因明确。
- HEAD：`7e407b7c78514ab08b70613afc66f620f65e4a25`（main，ahead 6 于远端 `526f1df3`）。
- `git status --porcelain`：61 行（快照存 `/tmp/p3-blake-Dqnr3y/git-status.txt`；构成：M 6（EPIC 件＋docs/pm 五件）、D 13（已收口链 handoffs 删除，PM 链务）、?? 42（开跑卡/TICKET/HANDOFF 等未跟踪件））。
- §7 写集 MODIFY 面 8 件 sha256（变更前）：
  - `tad.sh` = `c6b4e6587c6259def31ca39472b65d039e5144b7df99c77b998ce4af7ae10b2e`
  - `AGENTS.md` = `04004cba0406da4dd0e171e832803625d15992152fbe1c97e011e41997a8d198`
  - `.tad/project-knowledge/patterns/_index.md` = `ea57f8460ee1a07b83592b47f216909c6e0e0c4a16159b4bef2778b111538561`
  - `.tad/evidence/pm/2026-10-06-epic-p2-first-run-ruling.md` = `1c2652590b9beb1b2d7f270c31eeb786f29e098a8db0c5aa36166de4d5f09b6d`
  - `.tad/hooks/lib/state-surface-check.sh` = `cae4746c2a968ecd1495fd1882a7f91b4966c202fc857d67f971b816a9e0f4d7`
  - `.agents/skills/alex/references/publish-protocol.md` = `38d9a428f1a9416c8a37ca30e2568f4e6d31dcf1fc2acaafc0391c14ac52b7e3`
  - `.agents/skills/release-runbook/references/publish-ops.md` = `f86a60c829058be269f41e01c933fb9db2a14ccecd0b597480010d50d0ac5848`
  - `.tad/version.txt` = `b2f44d3b6e29f8b1b73ea4735f006affc4d198e1fd9c7d50e736159b1ef636c6`（内容 `3.1.0`）

## 0.1 骨架隔离面（§4.0 写死＋断言）

- 路径（写死）：grokbox `/home/box/p3-skeleton-tad`。
- 断言：目录名含 `p3-skeleton` ✔；不在任何下游真实仓路径内 ✔（下游仓位于 grokbox `/home/box/云同步/` 下，本路径在其外）；本链全部真机运行写面封闭于此目录与 `/home/box/p3-probe-logs/`（探针日志面）之内。
- 建法：VM 侧本仓工作树 tar 管道复制（排除 `.git`、`.worktrees`、`.opencode/node_modules`），181M／18,954 文件；其后在骨架内 `git init` 并作基线提交 `f68701e`，使 git 依赖面（post-write-sync/precompact 的 git 事实段）与真实仓同形态。
- 原始探针日志面：`/home/box/p3-probe-logs/`（grokbox 本地，不入仓；本记录逐项给指针＋sha256）。

## OC-6 真机版本复测（先行项）

- 方法：ssh grokbox 三家二进制 `--version` 直跑（2026-10-06）。
- 结果：OpenCode **1.18.33**；Cursor Agent **2026.10.01-e373342**；Codex CLI **0.159.3**（输出 `codex-cli 0.159.3`）；Node **v20.19.2**。与设计步实测值逐项一致，transcript 与实例版本值以此为源。
- 分支影响：无（HA-1 的版本跳变分支未触发）。infra 清单 Cursor 版本陈旧（CF-7）维持原处置：只在收口材料给 PM 一行知会素材，本链不改清单。

## OC-1 OpenCode 工具名册实测

- 方法：骨架仓置只记录探针插件 `.opencode/plugins/probe.ts`（源码附本节末），跑脚本化会话（`opencode run --model opencode-go/deepseek-v4.1-flash`，建文件→改文件→如有提问工具则触发）；另以一轮独立会话让模型列全工具名册互证。
- 原始输出指针：grokbox `/home/box/p3-probe-logs/oc1-tools.log`（10,094 B，sha256 `af8e9f20…bea9e5b4`）、`oc1-session.log`（406 B，sha256 `48f46bbf…f097e`）。
- 结论（实测确证）：
  - 写类工具名册＝**`write`**（args：`filePath`,`content`）、**`edit`**（args：`filePath`,`oldString`,`newString`）；`tool.execute.after` 的 output 键为 `title/metadata/output/attachments`。
  - 模型全名册自报（与探针事件互证）：bash, edit, glob, grep, read, skill, task, todowrite, webfetch, websearch, write——**无 question 类工具**（被明确要求「有则用之」后自报 `NO_QUESTION_TOOL`，且名册互证无此工具）。注记：官方 permissions 文档的权限键表含 `question` 键，但该工具在 `opencode run` 无头面（build 代理）不出现；本结论的辖区是无头运行面，即本链适配面。
  - `event` 总线 `session.created` 实测触发 ✔。
- 分支影响：§4.1 插件写类名册常量＝ `{write, edit}` 写死（文件头注记实测日期 2026-10-06＋OpenCode 1.18.33）；question 分支**不注册**，**R-OC-2 成立**（§4.6 实例登记）；`bash` 不入名册（与 Codex 面仅 `^apply_patch$` 触发 post-write-sync 的对等口径一致）。
- 探针源码（临时件，不入仓正本，会话后已删除）：

```ts
import { appendFileSync } from "fs"
const LOG = "/home/box/p3-probe-logs/oc1-tools.log"
function rec(obj) { try { appendFileSync(LOG, JSON.stringify(obj) + "\n") } catch (e) {} }
export const ProbePlugin = async (input) => {
  rec({ kind: "plugin-init", keys: Object.keys(input || {}) })
  return {
    "tool.execute.after": async (inp, out) => {
      rec({ kind: "tool.after", tool: inp && inp.tool, argsKeys: inp && inp.args ? Object.keys(inp.args) : [], outKeys: out ? Object.keys(out) : [] })
    },
    "tool.execute.before": async (inp, out) => { rec({ kind: "tool.before", tool: inp && inp.tool }) },
    event: async (inp) => { rec({ kind: "event", type: inp && inp.event && inp.event.type }) },
  }
}
export default ProbePlugin
```

- 操作发现（留痕）：`opencode run` 在 stdin 为不关闭的管道时无限阻塞（首跑 280s 超时、零输出；空目录复现）；`</dev/null` 后 6–11s 正常完成。本链全部无头运行（含 Phase 2 三家）一律 `</dev/null` 并记入运行命令原文。

## OC-2 Cursor CLI hooks 探活

- 方法：骨架仓置日志型 `.cursor/hooks.json`（sessionStart/postToolUse/preCompact 三条目，命令为写日志垫片 `/home/box/p3-probe-logs/cursor-hook-log.sh`，sessionStart 时回 canary 形 `additional_context`），以 `agent -p --trust` 跑会写文件的脚本化提示（无 `--trust` 时 CLI 以 exit 1 要求信任确认，此为探活前置事实，一并记录）。
- 原始输出指针：grokbox `/home/box/p3-probe-logs/oc2-hooks.log`（1,718 B，sha256 `7f28f2ee…3ac`）、`oc2-session.log`（sha256 `8221ac66…836e`）。
- 结论（实测确证）：**分支 A 成立**——CLI 无头面触发项目 hooks.json：`sessionStart` 与 `postToolUse` 均实测触发并落日志；`preCompact` 本轮未触发（短会话无 compact 事件，属未及触发、非不触发，Phase 1 以 OC-7 直调面兜底验证）。
- 真实 payload 样本（指针同上；`user_email` 字段已在转录时剔除，不入仓）：
  - sessionStart：`{conversation_id, generation_id, model, is_background_agent, session_id, hook_event_name:"sessionStart", cursor_version, workspace_roots, transcript_path}`——**无 source 字段**（与文档面一致，envelope 留空合法）。
  - postToolUse：`{..., tool_name:"Write", tool_input:{file_path:"/home/box/p3-skeleton-tad/cursor-probe.txt"(绝对路径), content}, tool_output, duration, tool_use_id, hook_event_name:"postToolUse", ...}`。
  - 归一判定：envelope 既有兜底链（`.tool_input.file_path // .tool_input.path // .file_path // .path`、`.tool_name`、`.session_id // .conversation_id`）**直接覆盖** Cursor payload ——§4.2 条目 2 的 jq 归一**不需要**，垫片 stdin 直通即可；此判定即归一规则的处置结论，记于此。
- 分支影响：§4.2 按分支 A 全量落地；**R-CU-2 不成立**；3.3 的 Cursor transcript 可含 hooks 触发段。

## OC-3 Cursor sessionStart 注入达模型验证

- 方法：沿用 OC-2 垫片（sessionStart 输出 `additional_context` 含 canary 秘密短语 `PLUM-TIGER-42`），新会话仅要求模型报告其初始系统上下文中的 canary 短语。
- 原始输出指针：OC-2 同轮会话日志（`oc2-hooks.log`）＋本轮会话 stdout（执行记录在案，模型回复原文 `PLUM-TIGER-42`）。
- 结论（实测确证）：**注入对等成立**——模型逐字复述 canary。§4.2 条目 1 的转码形态（Codex 形 `additionalContext` → Cursor 形 `additional_context`）在 CLI 面有效。

## OC-4 OpenCode output 改写达模型验证

- 方法：探针插件在 `tool.execute.after` 向 `output.output` 追加 `CANARY_OC4_7f3a`，会话要求模型报告写工具结果文本中的 CANARY 串。
- 原始输出指针：grokbox `/home/box/p3-probe-logs/oc4-tools.log`（73 B，sha256 `c4dddf71…9eee`，含改写前 output 原文 `Wrote file successfully.`）。
- 结论（实测确证）：模型逐字复述 `CANARY_OC4_7f3a`——**改写达模型成立**，§4.1 条目 3 的注入支**启用**（post-write-sync 的 `additionalContext` 经插件追加进 `output.output`），不走降级支。
- 附带：同轮探针的 `experimental.session.compacting` 钩子在短会话未触发（无 compact 事件），其 push 实测归 Phase 1 AC4 的 compact 场景专测。

## OC-5 OpenCode permission 面核实

- 文档面：官方 Permissions 页 `https://opencode.ai/docs/permissions/`（2026-10-06 抓取）——`permission` 键按工具给 `allow/ask/deny`，`edit` 键辖 write/edit/apply_patch，`bash` 键可给 glob 模式对象，另有 `external_directory`、`question` 等键；官方 config 文档同面互证。grokbox 全局配置在盘实存 `permission.external_directory` 对象（本席探活时亲见），为该面在 1.18.33 生效的旁证。
- 实测面：骨架仓置 `.opencode/opencode.json` 置 `"permission": {"edit": "deny"}` 后跑会话，模型工具名册中 write/edit 消失（自报仅余 bash, read, glob, grep, webfetch, websearch, task），写文件未发生——**deny 生效形态实测确证**。
- 结论：permission 面**存在且可编程声明**。§4.7 第 3 行定案＝「是」；写集 `opencode-permission.json` 样例**建**（条件件转为正件）。

## OC-7 preCompact 兼容验

- 方法：骨架仓以 Cursor 形 envelope（OC-2 实测字段集：conversation_id/session_id/hook_event_name=preCompact/cursor_version/workspace_roots）直调 `bash .tad/hooks/precompact-session-snapshot.sh`。
- 结果：exit 0；快照落 `.tad/active/precompact/snapshot-20261006-075851-oc7-prob.md`（骨架内），六字段形态正确（When/Trigger/Session/Git HEAD/Git/Active handoffs/Active epics 齐；Trigger 渲染 `(unavailable: no-trigger-field)` 为脚本既定回退形态；Session 取 session_id 前 8 字符 `oc7-prob`）。
- 结论：**直调成立**——§4.2 条目 3 按直调落地，条件件 `cursor-precompact.sh` **不建**（写集自动收缩，COMPLETION 注明）。

## Phase 0 出口判读

七项全有结论，无空缺：OC-1 确证（名册＋R-OC-2）／OC-2 分支 A／OC-3 对等成立／OC-4 注入支启用／OC-5 有面（样例建）／OC-6 复测全等／OC-7 直调（转接件不建）。分支影响逐项已注记。按 D-5 预授权径进 Phase 1。
