# F1 派发卡权限声明 — 各通道可声明面核查表（件 3.5 判断正本）

- 来源：F1 判断正本 `.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md` L41（「运行时实际权限在多数通道不可编程声明……先核各通道权限可声明面再定，不落空文」）。
- 定案总则：每行必带证据指针（文档 URL＋抓取日期，或实测记录指针）；无指针不成立。样例均为 **inert 声明件**（落 `.tad/templates/runtime-permission-examples/`，不随 tad.sh 分发；启用属各仓所有者/PM 决定，PM 裁断 D-4 已定主案）。

| # | 通道 | 权限面载体 | 可编程声明? | 声明字段集 | 本链定案 | 证据指针 |
|---|---|---|---|---|---|---|
| 1 | 原生 subagent spawn | 无（角色与纪律靠任务书文本＋spawn lint 机器闸） | 否 | —（任务书五项＋开跑卡六字段为文本面，非权限声明面） | 不可声明，记边界：该通道的约束力来自任务书与 PM 验收，不存在运行时权限声明面；不造声明文。 | 判断正本 L41（「原生 subagent 无权限面」）；本仓 spawn lint 实践（`~/workspace/bin/muse-spawn-lint.sh`，仓外件仅记名不引用内容） |
| 2 | Codex harness | 沙箱口径固定（全 role workspace-write，2026-09-16 用户拍板）；仓内 config.toml 为 draft 未激活 | 否（仓内无可落声明） | — | 无仓内可落声明，记口径指针：权限由通道固定口径决定，不随派发卡变化。 | HANDOFF §2.1 盘面核（config.toml draft 在盘）＋判断正本 L41（「Codex 沙箱为固定口径」） |
| 3 | OpenCode | 项目/全局 `opencode.json` 的 `permission` 键 | **是** | 按工具键给 `allow/ask/deny`：`edit`（辖 write/edit/apply_patch）、`bash`（可给 glob 模式对象，末匹配胜）、`read/glob/grep/list/task/external_directory/lsp/skill`（简写或模式对象）、`question/todowrite/webfetch/websearch/doom_loop`（仅简写） | 落样例 `opencode-permission.json`：edit allow（TAD 派发以写仓为常态）、bash 默认 ask＋只读 git/grep allow＋rm deny、external_directory ask、webfetch ask。理由：写面限于 edit 键的受控面，shell 面默认要问、破坏性命令硬拒，仓外路径必问——与 TAD「骨架/目标仓内作业、仓外零写」纪律同构。 | 官方文档 `https://opencode.ai/docs/permissions/`（2026-10-06 抓取）＋Phase 0 实测 OC-5（`.tad/evidence/designs/2026-10-06-p3-phase0-probes.md`：`edit: "deny"` 后 write/edit 自会话名册消失，deny 生效确证） |
| 4 | Cursor CLI | 项目级 `<project>/.cursor/cli.json`（项目层仅 permissions 等面） | **是** | `permissions.allow/deny`（条目为权限 token 精确字符串：`Shell(命令基)`, `Read(路径或glob)`, `Write(路径或glob)`, `WebFetch(域)`, `Mcp(服务:工具)`，deny 优先）、`approvalMode`（`allowlist`/`auto-review`/`unrestricted`）、`sandbox.mode`（`enabled`/`disabled`）、`sandbox.networkAccess`（`user_config_only`/`user_config_with_defaults`/`allow_all`） | 落样例 `cursor-cli.json`：allow＝Read/Write 工作区面＋git 只读与本仓 hooks 的 Shell 面；deny＝`Shell(rm -rf *)`、`Shell(git push *)`（发版动作不归被派发方）；approvalMode＝`allowlist`（白名单外必问，与无头派发的最小面一致）；sandbox＝enabled＋`user_config_with_defaults`（沙箱开、网络从用户配置默认集）。逐值理由即本行。 | 官方文档 `https://cursor.com/docs/cli/reference/configuration` 与 `https://cursor.com/docs/cli/reference/permissions`（设计步 2026-10-06 抓取确证字段集；token 形态与取值集经官方文档镜像多源互证，2026-10-06 复核） |
| 5 | Cursor IDE / cloud agents | hooks 的 `failClosed` 字段（项目 `.cursor/hooks.json`） | 非派发面 | `failClosed`（缺省 false） | 记一行：非派发通道，不另落声明；其纪律归件 3.2——TAD 接线恒不设 `failClosed: true`（AC8 grep 断言在案）。 | 件 3.2 落地件 `.cursor/hooks.json`＋Phase 1 验证件 |

## 样例启用说明（两件共通）

样例文件与目标文件同名、路径不同：启用＝由仓所有者/PM 将其拷入项目对应位置（Cursor：`.cursor/cli.json`；OpenCode：项目 `opencode.json` 或合并其 `permission` 段）。启用不是本链动作，样例不被 tad.sh 引用（AC27 grep 断言：分发面零命中）。
