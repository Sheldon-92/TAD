# AC 改前实测 — HANDOFF-20260817-retire-sync-decouple-projects (TASK-20260817-003)

**基线 HEAD:** b15f3fb7 ｜ **手写基线:** 0566ee4d（出单提交的父提交）
**实测日期:** 2026-08-22 ｜ **执行:** Blake

| AC | 改前实测 | 说明 |
|---|---|---|
| AC-1 `ls .tad/sync-registry.yaml` | **1** | 文件存在（14 条记录）。注意：该文件被 `.gitignore:79` 覆盖且**未被 git 跟踪**（`git ls-files` = 0），与 `migrations/2.42.0-to-2.42.0.yaml` 的「Untracked from version control (local file retained)」一致。删除 = 仅删本地文件。 |
| AC-2 三协议文件（两侧 6 个） | **6** | sync-protocol.md 12.8KB / sync-add-protocol.md 1.6KB / sync-list-protocol.md 540B × .claude/.agents |
| AC-3 注册块（行首锚定） | **3** | SKILL.md:1541-1547：`sync_protocol:` / `sync_add_protocol:` / `sync_list_protocol:` |
| AC-3b 退休注释 | **0** | 待加 |
| AC-4 SKILL.md:3 含 `*sync` | **1** | `Supports modes: *bug, *discuss, *idea, *learn, *publish, *sync.` |
| AC-5 CLAUDE.md 含 `*sync` | **3** | :17（lite 实测注）、:19（lite mandate 注）、:37（§2 表格行） |
| AC-6 harvest-scan exit | **0**（exit code） | ⚠️ 现有脚本缺失时打印 **"ERROR: sync-registry.yaml not found"** 但 **exit 0**——AC-6 的「不报错」须按 **stderr 无 ERROR** 判，不能只看 exit code。 |
| AC-7 非排除区含 `sync-registry` | **13** | 详见下方清单 |
| AC-N1 未碰 tad.sh | - | 实测范围 `0566ee4d..HEAD` 无 tad.sh |
| AC-N2 `*publish` 存活 | **8** 处 | SKILL.md 内 |
| AC-N2b publish-protocol.md | **1** | 存在 |
| AC-N3 DR 文件 | **1** | `.tad/decisions/DR-20260601-self-deriving-release-sync.md` |
| AC-N4 derive-sync-set TOP_DENY | **1** | `TOP_DENY="sync-registry.yaml"`（:77）|
| AC-N5 skill-body-verify | **0** | exit 0 |
| AC-N6 `bash -n tad.sh` | **0** | 语法 OK |

## AC-7 基线清单（13 个非排除区命中，`grep -vE '\.tad/(evidence|archive|decisions)/|CHANGELOG|AUDIT|HANDOFF|\.gitignore|derive-sync-set|tad\.sh'`）

```
.agents/skills/alex/references/sync-add-protocol.md      → 删除（FR-2）
.agents/skills/alex/references/sync-list-protocol.md     → 删除（FR-2）
.agents/skills/alex/references/sync-protocol.md          → 删除（FR-2）
.agents/skills/release-runbook/references/sync-ops.md    → 退休桩（FR-7，桩文不含字面量）
.claude/skills/alex/references/sync-add-protocol.md      → 删除（FR-2）
.claude/skills/alex/references/sync-list-protocol.md     → 删除（FR-2）
.claude/skills/alex/references/sync-protocol.md          → 删除（FR-2）
.claude/skills/release-runbook/references/sync-ops.md    → 退休桩（FR-7）
.tad/config.yaml                                         → 保留（历史：v2.4.0 变更日志 :342）
.tad/hooks/lib/harvest-scan.sh                           → 方案 A 重写（新文本不含字面量）
.tad/migrations/2.42.0-to-2.42.0.yaml                    → 保留（历史：迁移记录 :9）
.tad/project-knowledge/patterns/ac-verification.md       → 保留（历史：五版教训 :668）
docs/value-proposition.md                                → 更新为退休后定位（:41）
```

**预期终态：AC-7 = 3**（config.yaml + migrations + ac-verification，均为历史记录）。
**⚠️ 人已裁定（2026-08-22）：只改 value-proposition；历史 3 处保留；AC-7 判据请 Alex 以 addendum 修正**
（把配置变更日志 / 迁移记录 / 知识教训纳入排除正则）。Gate 3 按 PARTIAL 报告此冲突，不掩盖。

## 本单其他关键实测（决策依据）

1. **§4.3 harvest-scan 调用方**：`*harvest` 在 `alex/SKILL.md:1365` 调用
   `bash .tad/hooks/lib/harvest-scan.sh` → **采方案 A**（保留脚本，优雅跳过）。
   ⚠️ 我最初的 `grep -rn … | grep -v` 管道有过滤 bug，把调用行一起滤掉了——
   `git ls-files -z | xargs grep -ln 'harvest-scan'` 才是权威。教训：验证管道前先自测 `$?`。
2. **§4.4 sync-ops 调用方**：`publish-protocol.md` **不引用** sync-ops；
   但 `release-runbook/SKILL.md:22,24` 与 `alex-lite/SKILL.md:411`、`blake-lite/SKILL.md:554`
   （各两侧）引用它 → **改「已退休」桩**（删除会产生 6 处悬空引用；桩是 FR-7 明示选项）。
3. **harvest-scan.sh 现状**：缺失注册表时打印 ERROR 但 **exit 0**（:13-15）。
   方案 A 的最小修法：缺失 → 打印一行说明（非 ERROR）→ exit 0；且新文本不含 `sync-registry` 字面量。