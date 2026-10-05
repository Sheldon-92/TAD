# Gate 4 (Acceptance): 退休 `*sync`，解除与 14 个项目的关联

**Gate**: 4（业务验收）｜**执行**: Alex｜**Date**: 2026-08-17
**实现**: `65380b7c`（Blake, Terminal 2）｜**判定**: ✅ **PASS**

---

## 1. 验收方式

不复述 AC。Gate 4 问一件事：**TAD 还知道那 14 个项目吗？**

## 2. 三项独立复算

| 检查 | 实测 |
|---|---|
| 注册表存在 | **0** ✅ |
| **全仓任何跟踪文件含真实项目路径**（`01-on progress programs/menu-snap` 等） | **0** ✅ |
| 活代码读注册表**内容** | **2 处，且都是 NFR 明令保留的** ✅ |

那 2 处是 `tad.sh:245` 与 `derive-sync-set.sh:77`，均为
`TOP_DENY="sync-registry.yaml"` —— **只用文件名做「永不复制进目标项目」的保护，不读内容**。
AC-N1/N4 正是要求它们不动。

**→ 解耦完整。TAD 仓库里不再有任何「哪些项目装了我」的记录。**

### 2.1 外部信号（非自我断言）

本会话的系统提示在实现后自动更新：
- `alex` skill 的 description 变为 `*bug, *discuss, *idea, *learn, *publish` —— **`*sync` 已消失**
- CLAUDE.md 命令表中 `*sync` 行不再出现

## 3. 功能未被误伤

| 检查 | 实测 |
|---|---|
| `harvest-scan.sh` 在注册表缺失时 | **exit 0**，打印退休说明，**stderr 无 ERROR** ✅ |
| `*publish` 存活 | SKILL.md **8** 处、`publish-protocol.md` 在、CLAUDE.md **3** 处 ✅ |
| 镜像一致 | `skill-body-verify.sh` **exit 0** ✅ |
| 安装器可用 | `bash -n tad.sh` **exit 0** ✅ |

## 4. 对 Blake 六项自报的裁定

| # | 事项 | 裁定 |
|---|---|---|
| **1** | AC-7 = 3（历史记录），要求 Alex 补排除正则 | ✅ **采纳** —— 见 §5 addendum。三处经我核实：`config.yaml:342` v2.4.0 变更日志、`migrations/…:9` 迁移记录、`ac-verification.md:668` 五版教训。**均属 NFR3 明令保留的决策轨迹** |
| **2** | 超枚举改动：SKILL.md 两处命令清单摘除 `*sync` | ✅ **接受** —— 那是**活文本在广告一个已退休的命令**，留着会让 Alex 运行时看到不存在的命令。与 `value-proposition.md` 的裁定同理 |
| **3** | 跨文件残留 4 处未动 | ✅ **同意另立单**。优先级按 Blake 所排：`tad-help/SKILL.md:70-72`（用户可见）> `publish-protocol.md:205`（`*publish` step5 建议跑 `*sync`，**最可达**）> 其余。`research-notebook:1153` 经确认是假阳性（NotebookLM 自己的 `*sync`），**勿动** |
| **4** | migration 记录里「*sync continues to read the local copy」现已为假 | ✅ **维持不动**。NFR3 保护历史记录。**但不追加补记** —— 迁移记录是当时状态的快照，事后注解会污染它作为证据的价值 |
| **5** | FR-1 不可从 git 验证（注册表 untracked） | ✅ **确认**。已用 `ls` 独立验证 = 0。此项记入 §6 以防 fresh clone 上误判 |
| **6** | AC-7 自伤修正 | ✅ **值得记**。Blake 的 completion 初稿含注册表文件名，而 `COMPLETION-*` 被 git 跟踪且不在排除正则内 → AC-7 一度 =4。**验收判据会审查你写的报告本身** |

## 5. AC-7 Addendum（Alex，2026-08-17）

**原 AC-7 的排除正则不含三类历史载体，导致合规实现被判 PARTIAL。**

**修订后的排除集**（在原有基础上追加）：
```
.tad/evidence/ | .tad/archive/ | .tad/decisions/ | .tad/migrations/
CHANGELOG | AUDIT-* | HANDOFF-* | COMPLETION-* | GATE4-* | .gitignore
.tad/project-knowledge/       ← 新增：知识教训引用退休物是正当的
.tad/config.yaml 的 changelog 段  ← 新增：版本变更日志是历史
derive-sync-set.sh | tad.sh   ← 二者只用文件名做 TOP_DENY，不读内容
```

**判据原则**：
> AC-7 要验的是**「活代码还在读它吗」**，不是**「文本里还提它吗」**。
> 历史记录、变更日志、迁移快照、知识教训**都应当继续提到已退休的东西** ——
> 那正是它们存在的意义。把它们计入违规，等于要求删除决策轨迹。

**修订后重算：AC-7 = 0 ✅**（三处历史记录落入新排除集）。

## 6. 判定：**PASS**

人的裁定已完整落地：**TAD 不再持有、不再跟踪、不再能同步任何下游项目。**
是否升级由各项目自行决定。

### 6.1 遗留（已记录，不阻塞）

| 项 | 处置 |
|---|---|
| 跨文件残留 4 处 | 另立单，`tad-help` 与 `publish-protocol:205` 优先 |
| `.tad/sync-registry.yaml` 是 untracked | **验证只能用 `ls`，不能用 git** —— fresh clone 上不可复现 |
| `migrations/…` 中已为假的陈述 | 维持，属历史快照 |

---

## 7. 这次交付里最有价值的东西

**Blake 的第 6 项自报**：他的 completion 初稿因为**写了「sync-registry.yaml」这个词**，
使 AC-7 从 3 变成 4 —— 因为 `COMPLETION-*` 被 git 跟踪且不在排除正则内。

> **验收判据会审查你写的报告本身。**

这暴露了一类我没想过的问题：**当 AC 的扫描范围包含「本次交付产生的文档」时，
描述工作本身会改变验收结果**。这不是 Blake 的实现问题，是我写 AC 时的范围没划清。

→ 已并入 §5 addendum：`COMPLETION-*` / `GATE4-*` 必须在排除集内。
