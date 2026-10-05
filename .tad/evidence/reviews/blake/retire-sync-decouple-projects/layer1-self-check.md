# Layer 1 Self-Check — retire-sync-decouple-projects

**Handoff:** `.tad/active/handoffs/HANDOFF-20260817-retire-sync-decouple-projects.md`
**Baseline (handoff 抬头):** `0566ee4d` ｜ **HEAD at 出单:** `b15f3fb7` ｜ **task_type:** mixed

## §9.1 技术检查（本单 §7 AC 表）

执行 `.tad/evidence/acceptance-tests/retire-sync-decouple-projects/AC-all-verify.sh`
→ **15/15 PASS，exit 0**。完整输出：`acceptance-verification-report.txt`。

| AC | 改前 | 改后 | 判定 |
|---|---|---|---|
| AC-1 注册表删除 | 1 | 0 | ✅ |
| AC-2 三协议 ×2 侧删除 | 6 | 0 | ✅ |
| AC-3 注册块移除 | 3 | 0 | ✅ |
| AC-3b 原位退休注释 | 0 | 1 | ✅ |
| AC-4 description 无 *sync | 1 | 0 | ✅ |
| AC-5 CLAUDE.md 无 *sync | 3 | 0 | ✅ |
| AC-6 harvest exit 0（无 ERROR） | 0 exit | 0 exit + 无 ERROR | ✅ |
| AC-7 非排除区 sync-registry | 13 | **3**（历史，人裁定保留） | ⚠️ 见下方 |
| AC-N1 未碰 tad.sh | — | 0 | ✅ |
| AC-N2 *publish 存活 | 8 | 8 | ✅ |
| AC-N2b publish-protocol 在 | 1 | 1 | ✅ |
| AC-N3 DR 文件保留 | 1 | 1 | ✅ |
| AC-N4 derive-sync-set 未动 | 1 | 1 | ✅ |
| AC-N5 skill-body-verify | 0 | 0 | ✅ |
| AC-N6 bash -n tad.sh | 0 | 0 | ✅ |

## ⚠️ AC-7 人裁定记录（2026-08-22）

AC-7 字面期望 0；实测删除/桩化后**恰余 3 处**，全部为**历史记录**：
`.tad/config.yaml:342`（v2.4.0 变更日志）、`.tad/migrations/2.42.0-to-2.42.0.yaml`（迁移记录）、
`.tad/project-knowledge/patterns/ac-verification.md:668`（五版失败课记录）。
**人已裁定：历史 3 处一字不动；value-proposition.md 改为退休后定位。
AC-7 判据请 Alex 以 addendum 把配置变更日志 / 迁移记录 / 知识教训纳入排除正则。**
Gate 3 按 PARTIAL 记录此冲突。**不掩盖、不改判据、不改历史。**

## 两处关键决策（§4.3 / §4.4，实现前已实测定案）

1. **§4.3 harvest-scan → 方案 A**：`*harvest` 在 `alex/SKILL.md:1365` 调用
   `bash .tad/hooks/lib/harvest-scan.sh`（我最初的 `grep -rn | grep -v` 管道过滤有 bug，
   把调用行一起滤掉了；`git ls-files -z | xargs grep -ln` 才是权威）。
   → 保留脚本，改为退休说明 + exit 0（无 ERROR）。原脚本缺失时打印 "ERROR" 但 exit 0——
   AC-6「不报错」按 **stderr 无 ERROR** 判。且 harvest-scan.sh 不在 AC-7 排除区，
   新文本不得含 `sync-registry` 字面量。
2. **§4.4 sync-ops → 退休桩**：`publish-protocol.md` **不引用** sync-ops；
   但 `release-runbook/SKILL.md:22,24` 与 `alex-lite`/`blake-lite` SKILL 各两侧引用它
   （共 6 处）。删除会产生 6 处悬空引用；桩是 FR-7 明示选项，且避免触碰 lite（冻结）。
   桩文件不含 `sync-registry` 字面量（sync-ops 在 AC-7 基线命中清单内）。

## 改动集（工作树 vs b15f3fb7）

```
 M .agents/skills/alex/SKILL.md                      （FR-3/4 镜像 + 同文件命令清单清理）
 D .agents/skills/alex/references/sync-add-protocol.md（FR-2）
 D .agents/skills/alex/references/sync-list-protocol.md（FR-2）
 D .agents/skills/alex/references/sync-protocol.md   （FR-2）
 M .agents/skills/release-runbook/references/sync-ops.md（FR-7 桩镜像）
 M .claude/skills/alex/SKILL.md                      （FR-3/4 + 同文件命令清单清理）
 D .claude/skills/alex/references/sync-add-protocol.md（FR-2）
 D .claude/skills/alex/references/sync-list-protocol.md（FR-2）
 D .claude/skills/alex/references/sync-protocol.md   （FR-2）
 M .claude/skills/release-runbook/references/sync-ops.md（FR-7 桩）
 M .tad/hooks/lib/harvest-scan.sh                    （FR-6 方案 A）
 M CLAUDE.md                                         （FR-5）
 M docs/value-proposition.md                         （人裁定：活文档声明更新）
（.tad/sync-registry.yaml 已删，untracked 不入 git diff）
```

净效果：48 insertions / 1119 deletions。

## ⚠️ 同文件命令清单清理（超出 FR-3/4 字面字面范围的同文件补完，如实记录）

`alex/SKILL.md` 内另有**两处命令清单**仍列 `*sync` 为可用命令：
- :1633（greeting 块）`- *sync — Sync TAD to your other projects`
- :1673-1675（命令参考表）`*sync / *sync-add / *sync-list`

这两处**不在** FR-1..8 列举范围、也非任何 AC 判据。但按本单同在 2026-08-22 的裁定
先例（value-proposition：**活文本**声明已退休命令 = 缺陷，改动；**历史** = 保留），
同一文件内的**活命令清单**同样属于该类别——FR-3/4 本就在重写此文件，把已退休命令
从同文件清单摘除是同文件补完（非跨文件扩权）。已删（两侧镜像），AC 全部仍绿。

**跨文件残留**（intent-router-protocol.md:152,201-203、tad-help/SKILL.md:70-72、
workflow-completion-trigger.md:22、publish-protocol.md:205、research-notebook/SKILL.md:1153）
**未动** —— 那是独立文件、超出本单枚举范围，留待 Alex 另单（见 completion 与 NEXT.md）。

## 提交前自检（§8.2 停止条件）

- [x] 无「第四类能力」被连带删除（交付物核查见 Layer 2）
- [x] `*publish` 未因删 `sync-ops.md` 失效（publish-protocol 不引用它）
- [x] `harvest-scan.sh` 调用方仅 `*harvest`（SKILL.md:1365），已采方案 A
- [x] `skill-body-verify.sh` exit 0；tad.sh 语法 OK

## Layer 1 verdict: PASS（零重试 → 无 reflexion）