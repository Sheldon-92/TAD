# IDEA: TAD 统一认证层 (`tad auth`)

**Captured:** 2026-06-07 · **Status:** open · **Scope:** medium
**Source:** npx 安装器设计过程中发现的底层痛点(NotebookLM 登录折腾触发)

## Summary
TAD 依赖 4+ 个需登录工具,认证机制异构 → 老在登录上栽跟头:
| 工具 | 机制 | 持久性 |
|------|------|--------|
| gh | OAuth token 存 macOS **keyring** | 长期稳(标杆)|
| codex | ChatGPT token `~/.codex/` | 较稳 |
| gemini | Google `~/.gemini/` | 较稳 |
| NotebookLM | **Playwright 浏览器 cookie** | 几周过期,最脆 |

**根因**:(1) 机制全不同,无统一封装;(2) 判据不一致(auth check 输出各异,人和脚本都易误判 — 本次实测 grep 错);(3) 过期检测分散(用到才发现);(4) NotebookLM 非官方浏览器自动化,登录本质需浏览器。

## 提议方案(分层,诚实)
- **✅ 高性价比**:统一 `tad auth status` 层 — 一命令查全部工具 + 输出统一表格 + **Alex/Blake 启动时自动跑(提前预警)**。解决根因 2+3,即"老出问题"大头。
- **✅ 持久化**:能迁 macOS keyring 的(codex/gemini token)迁过去,学 gh。
- **🟡 简化登录**:OAuth 工具探 device-code flow(对话内给 URL+code,浏览器输,不用复制粘贴回来)。
- **❌ 做不到**:NotebookLM 无法纯对话内登录(浏览器自动化本质)。只能减频 + 预警 + **修 `Aborted!` 误报** + 统一 auth check 判据。

## Open Questions
- keyring 迁移范围?codex/gemini token 能否安全迁 keychain?
- device-code flow 哪些工具支持?
- 跟 npx onboarding 怎么协同?(装完 → `tad auth status` 作为 onboarding 下一步)
- NotebookLM cookie 自动续期可行性?

## 与其他工作的关系
- 与 npx 安装器协同(onboarding 的一环),但更底层(影响整个运行时工具链)。
- 可作独立功能,或并入 npx Epic 的一个 phase。

## 相关证据
- grounding: gh=keyring / codex=~/.codex / gemini=~/.gemini / notebooklm=~/.notebooklm(storage_state.json+browser_profile)
- 本次实测痛点:setup-notebooklm.sh 末尾 `Aborted!` 误报(实际登录成功);auth check 判据 grep 'authenticated' 失效(0.3.4 输出表格 `✓ pass`);`timeout` 命令 macOS 不存在。
