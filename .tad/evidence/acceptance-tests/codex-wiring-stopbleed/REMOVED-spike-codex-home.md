# `spike-codex-home/` 已删除 —— 2026-08-16（凭据泄漏处置）

## 结论先说

本目录下的 `spike-codex-home/`（40M）与 `spike-work`（孤儿 gitlink）**已被删除，不会恢复**。
`AC-01` / `AC-02` / `AC-09` 与 `spike-a-report.md` 引用了它，**这些 AC 现在无法重跑**。
这不改变本 spike 已归档的验收结论 —— 见
`.tad/archive/handoffs/COMPLETION-20260803-codex-wiring-stopbleed.md`（Gate 4 已通过）。

## 为什么删

那次 spike 把整个 `CODEX_HOME` 目录原样留存为"证据"，其中 `spike-codex-home/auth.json`
含 **真实且当时有效的** ChatGPT OAuth 凭据：

| 字段 | 长度 |
|---|---|
| `tokens.id_token` | 1953 |
| `tokens.access_token` | 1773（有效期至 2026-08-24） |
| `tokens.refresh_token` | 211 ← **最危险：可持续换取新的 access_token** |
| `tokens.account_id` | 36 |

该文件随 commit `47918da7`（2026-08-13）提交并推送到 **PUBLIC 仓库**
`github.com/Sheldon-92/TAD`，**公开 3 天**后于 2026-08-16 发现。
处置：用户已在 ChatGPT → Security and login → Active sessions 执行 **Log out all**，
令牌全部作废；随后从工作区删除该目录并补 `.gitignore` 规则。

⚠️ **git 历史中该 blob 仍然存在**（本次未重写公开历史 —— 那会让所有 clone/fork 失效，
且 GitHub 上的旧 commit 短期内仍可能经 API 取到）。**凭据已吊销，所以历史里留着的是死令牌。**
若日后决定彻底清除，用 `git filter-repo` 并 force push，代价见上。

## 教训（已进 `.gitignore` 注释，此处留完整版）

1. **把外部工具的 HOME / 配置目录整个当"证据"留存，里面几乎必然有认证态。**
   Codex、gh、gcloud、aws、npm 都一样。证据要留的是「我验证了什么」，
   不是「当时那台机器长什么样」。
2. **上一轮的隐私清理扫的是路径里的个人标识**（`/Users/xxx` → `/path/to/TAD`，
   这个目录里当时 0 命中，那次扫描本身是成功的）**，但没扫凭据模式**。
   两类敏感物需要两套判据，一套过了不代表另一套过。
3. **`du -sh` 对小文件显示 `0B` 不代表文件是空的。** 本次 `auth.json` 显示 `0B`
   （块大小舍入），实际 4185 字节 —— 差点因此被判为无害跳过。查文件是否有内容用
   `wc -c`，不要用 `du`。

## 保留下来的（仍是有效证据）

- `AC-00` ~ `AC-09` 脚本本身
- `spike-a-report.md` / `spike-b-report.md` / `baseline.md`
- `acceptance-verification-report.md` / `ac7-branch-escalation.md`
- `ac9-codex-only/`（544 个文件的测试装置，已确认不含任何凭据）
