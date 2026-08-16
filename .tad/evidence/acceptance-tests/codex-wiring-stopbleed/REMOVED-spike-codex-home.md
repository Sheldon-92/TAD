# `spike-codex-home/` 已删除 —— 2026-08-16

> ## ⚠️ 本文件 2026-08-16 首版的核心结论是错的，已全文更正
>
> 首版声称「真实且当时有效的 ChatGPT OAuth 凭据在 PUBLIC 仓库公开了 3 天」。
> **这是错的。凭据从未进入 git。** 更正过程与错误原因见文末「§ 判断错误复盘」。
> 首版不删除、以本节形式留痕 —— 一份被悄悄改对的记录，比一份错的更危险。

## 结论先说

本目录下的 `spike-codex-home/`（40M）与 `spike-work`（孤儿 gitlink）**已删除，不会恢复**。
`AC-01` / `AC-02` / `AC-09` 与 `spike-a-report.md` 引用了它，**这些 AC 无法重跑**。
这不改变本 spike 已归档的验收结论 ——
见 `.tad/archive/handoffs/COMPLETION-20260803-codex-wiring-stopbleed.md`（Gate 4 已通过）。

## 删除理由（更正后的准确版本）

那次 spike 把整个 `CODEX_HOME` 原样留存为"证据"：40M，其中 27M 是 OpenAI 插件缓存、
11M 是远程插件目录 JSON，还有 pptx/docx 模板、四个 sqlite、`installation_id`、`config.toml`。
**这些与"验证了什么"无关，是那台机器当时的样子。** 该删。

其中有一个名为 `auth.json` 的条目。**它是一个符号链接**：

| 项 | 值 |
|---|---|
| git 文件模式 | `120000`（symlink，非常规文件） |
| blob | `3bdaf056`，**35 字节** |
| blob 内容 | 一行路径字符串：`/Users/<user>/.codex/auth.json` |
| 真 token 所在 | 本机 `~/.codex/auth.json`，4185 字节，权限 `600` —— **从未进 git** |

**两个独立来源确认凭据从未泄漏**：
1. `git show 47918da7:<path>` → 35 字节的路径字符串；`git ls-tree` → mode `120000`
2. `gitleaks git`（8.30.1）扫描 **848 个 commit / 227.33 MB / 8m9s** →
   auth.json 与 OAuth token 命中 **0 条**
   （报告里 54 条 findings 全部是研究文档中的示例值：`api.example.com`、
   OpenAPI 的 `BearerAuth` schema 声明、todo-backend / saas-billing 的 API 文档模板）

**实际泄漏的**：符号链接目标里的**家目录路径字符串**。个人信息，轻微，已随目录删除。

## 仍然成立的部分

- **删除是对的**：40M 纯垃圾，且 symlink 暴露家目录路径。
- **`.gitignore` 规则必须留着**，理由是**下一次可能不是符号链接**：
  同一个动作（把工具 HOME 当证据留存）只要复制的是真文件，进的就是真凭据。
  规则挡的是那个动作，不是这一次的结果。
- **git 历史里仍有那个 35 字节的 symlink blob**。它只含一行路径，无凭据，不值得重写公开历史。

## § 判断错误复盘（比这次删除本身更值钱）

**错误链**：
1. `git ls-files --error-unmatch <path>` → 确认路径被跟踪 ✅ **这步是对的**
2. `wc -c < <path>` → 4185 字节；`json.load(open(<path>))` → 读出三个 token
   ❌ **这两个操作跟随了符号链接，读的是本机真文件，不是 git 里的 blob**
3. 把 (1) 与 (2) 拼成结论「凭据已提交到公开仓库」→ **两个各自正确的事实，错误的合取**

**代价**：向用户报了假警报，用户据此执行了一次不必要的紧急凭据吊销。

**规则**：
> **要判断「git 里有什么」，唯一可信的方法是 `git show <commit>:<path>`
> 与 `git ls-tree`（看 mode）。** 任何走文件系统的读取（`wc`、`cat`、`open()`、
> `stat`、`du`）都会跟随符号链接，回答的是「本机有什么」——那是另一个问题。

**这与同日另外三次错误同型**（判据/方法比问题窄），一并见
`patterns/ac-verification.md`「验证了替身，没验证对象」与
`patterns/shell-portability.md`。

## 保留下来的（仍是有效证据）

- `AC-00` ~ `AC-09` 脚本本身
- `spike-a-report.md` / `spike-b-report.md` / `baseline.md`
- `acceptance-verification-report.md` / `ac7-branch-escalation.md`
- `ac9-codex-only/`（544 个文件的测试装置，无凭据）
