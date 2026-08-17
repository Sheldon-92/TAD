# Completion Report: Phase 4 — 发行瘦身

**From:** Blake（由 Alex 在 YOLO 授权下代执行）
**To:** Alex
**Date:** 2026-08-16
**Handoff:** `HANDOFF-20260816-phase4-distribution-slimming.md`
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 4/5)
**起始 SHA:** `b695660661fd8ee210061cfd0de04b77cf61c020`

---

## 1. 交付摘要

| FR | 内容 | 状态 |
|---|---|---|
| **FR-A** | orphan 分支 `maintainer-evidence` 保存完整 evidence + archive，**并推送到 origin** | ✅ |
| **FR-B** | 从 main 索引移除二者 + `.gitignore` | ✅ |
| **FR-C** | 收窄 `package.json` 的 `files` 白名单 | ✅ |
| **FR-D** | `.tad/evidence/README.md` 说明取回方式 | ✅ |

### 核心成果

| 指标 | 改前 | 改后 |
|---|---|---|
| **npm 包体** | **23.1 MB** | **3.3 MB**（−86%） |
| **npm 文件数** | 6512 | **1720** |
| **npm 内 evidence 条目** | **3445** | **0** |
| `.tad/evidence/` 跟踪数 | 3348 | **0** |
| `.tad/archive/` 跟踪数 | 895 | **0** |

内容零丢失：`maintainer-evidence` 分支保留 **3348 + 895** 个文件，已推送至 origin，可用
`git show origin/maintainer-evidence:<path>` 随时读取。

---

## 2. AC 结果（RESULT=PASS）

| AC | 期望 | 改前 | 改后 | |
|---|---|---|---|---|
| AC-A1 orphan 分支存在 | OK | 不存在 | **OK** | ✅ |
| AC-A2 可从远端取回 | 非空 | — | **`menu-snap`** | ✅ |
| AC-A3 **远端**有该分支 | 1 | 0 | **1** | ✅ |
| AC-B1 evidence 跟踪数 | 0 | 3348 | **0** | ✅ |
| AC-B2 archive 跟踪数 | 0 | 895 | **0** | ✅ |
| AC-C1 `files` 已收窄 | 0 | 1（含裸 `.tad/`） | **0** | ✅ |
| AC-C2 npm 内 evidence | 0 | 3445 | **0** | ✅ |
| AC-C2b 磁盘上仍在 | 2 | 2 | **2** | ✅ |
| AC-D1 README 存在 | 1 | 0 | **1** | ✅ |
| AC-N2 起始 commit 可解析 | OK | OK | **OK** | ✅ 未重写历史 |
| AC-N3 未碰 `tad.sh` | 0 | 0 | **0** | ✅ |
| AC-N4 project-knowledge 路径哈希 | 不变 | `843aa189…` | **`843aa189…`** | ✅ |
| AC-N6 `release-verify parity` | 0 | 0 | **0** | ✅ |

**证据**：`.tad/evidence/acceptance-tests/phase4-distribution-slimming/{AC-before,AC-after}.txt`

---

## 3. 实现期的三次判断修正

### 3.1 🔴 裁定 #2 被实测推翻 —— `.npmignore` 对 `files` 白名单无效

**我的裁定**：用 `.npmignore` 而非收窄 `package.json` `files`，理由「不容易漏」。

**实测结果**：创建 `.npmignore` 后 `npm pack --dry-run | grep -c 'evidence/'` **仍是 3445，纹丝不动**。

**原因**：npm 的 `files` 是**白名单，优先级高于 `.npmignore``**。列了裸 `.tad/` 就会整个打包，`.npmignore` 拦不住。

**改用方案 B**（收窄 `files` 为显式子目录清单）→ evidence 条目 **3445 → 0**，包体 **23.1 → 3.3 MB**。

> **这次是实测抓到的，不是 reviewer。** 因为裁定时给了可证伪判据（AC-C2），错误一执行就暴露。
> **判据：代裁定必须附带可证伪的验证命令**，否则错误会静默存活到 Gate 3 之后。

⚠️ `.npmignore` 已保留 —— 它对 `files` 之外的路径仍有效，且是第二层防护。但**不是**本单达标的原因。

### 3.2 🔴 「origin 不可达」是错的 —— 工具失败被读成数据结论

上一轮我判定 origin 不可达，据此裁定「拆分交付，FR-A 延后」。

**真相**：探测命令是 `timeout 15 git ls-remote ...`，而 **macOS 上没有 `timeout`**。
命令本身返回 `command not found` 的非零，**我把它当成了「网络不通」**。

重测后 origin 完全可达，FR-A 正常创建并**推送成功**。裁定已撤销并改回完整交付。

> **第 15 次同形错误的新子型**：前 14 次是「判据范围 ≠ 问题范围」，这次是
> **「判据本身执行失败，其失败信号被当成被测对象的属性」**。
> **规则：任何"返回非零即下结论"的探测，必须先 `command -v` 确认命令可用** ——
> 否则「工具缺失」与「条件不成立」不可区分。

### 3.3 AC-N6 的期望值是我写错的

`release-verify.sh` 无参数调用**恒返回 2**（usage 错误），我却写期望 0。
用正确子命令 `parity .` 重测：改后 **exit 0**；并用 `git worktree` 在改前状态 `b6956606` 实测**同为 0** → 我的改动未破坏它。

---

## 4. 阈值修订：8 MB 判据已废弃

**原 SC3/AC-B3**：`git archive | gzip -9 | wc -c` < 8,388,608。

**问题**：移出后实测 8,382,734 —— **余量仅 5,874 字节**，而本单自己要产出的单张工单 gzip 后就有 **10,134 字节**。
**该阈值会被本单自己的交付物撞破。**

**根因**：8 MB 是审计时拍的圆整数，**非从需求推导**。真实需求（F-18）是「用户不该下载维护者的调试记录」。

**改判据**：
- **主判据**：`git ls-files '.tad/evidence/*'` == 0 **且** archive == 0 —— 直接断言意图
- **辅助度量**：相对审计基线 `31,659,251` 降幅 ≥70%

> **教训（第 16 条）**：验收阈值必须从需求推导，不能取「看起来整齐」的数。
> **一个会被自己的交付物撞破的阈值，度量的是巧合而非目标。**
> 症状识别：当你发现「为了让 AC 通过，必须约束交付物本身的大小」时，阈值就已经错了。

---

## 5. Gate 3 判定：**PASS**（2026-08-16）

独立 subagent `c2a0a107` 逐条验证 **13/13 PASS** → `PHASE4 GATE3 PASS`

关键复核项：

| 检查 | reviewer 实测 |
|---|---|
| orphan 分支在**远端**存在（非本地跟踪引用） | `ls-remote` 计数 **1** ✅ |
| 分支保留文件数 | evidence **3348** / archive **895** ✅ |
| 从远端取回内容 | `menu-snap`（非空）✅ |
| main 上跟踪数 | evidence **0** / archive **0** ✅ |
| 磁盘上仍在（运行时仍需写入） | **2** ✅ |
| `.gitignore` 条目 | L122 `.tad/evidence/`、L123 `.tad/archive/` ✅ |
| npm 包内 evidence 条目 | **0** ✅ |
| npm 包体 | **3.3 MB**（unpacked 14.1 MB）/ **1720** 文件（改前 23.1 MB / 6512）✅ |
| `files` 无裸 `".tad/"` | 0 匹配，全为具体子路径 ✅ |
| 未碰 `tad.sh` / parity | 0 文件；`VERDICT: PASS` exit 0 ✅ |
| 未重写历史 | `4718c5ec` 仍解析；PK 哈希 `843aa189cb906ba1` 未变 ✅ |

**判定依据**：规则 2 满足；禁止纸面验收满足 —— 全部由独立 subagent 实跑。

---

## 6. Knowledge Assessment

**(a) npm `files` 白名单覆盖 `.npmignore`** —— 二者不是互补关系而是**覆盖关系**。
若 `files` 已指定，排除子路径**必须**改 `files` 本身。（本单实测：`.npmignore` 完全无效）

**(b) 工具缺失 ≠ 条件不成立** —— 见 §3.2。macOS 无 `timeout`，是本仓 shell 可移植性教训的新实例，
应并入 `patterns/shell-portability.md`。

**(c) 代裁定必须附可证伪判据** —— 裁定 #2 错了但被 AC-C2 当场抓住；
若当时只写「用 `.npmignore` 更好」而无验证命令，错误会存活到 Gate 3 之后。

**(d) 阈值的来源决定其有效性** —— 见 §4。

---

## 7. 执行方式说明

同 Phase 1a/3：Alex 在 YOLO 授权下代 Blake 执行。
**保留**：两名独立 reviewer（`522ad012` 前提核查 / `a5e03891` 可执行性核查）、Gate 3 独立验证、全部 AC 落盘。
**削弱**：角色分离。

**三项 Alex 代裁定**（人未明确批准，回滚方式见工单 §4.0c）：
1. ~~方案 A 拆分交付~~ → 已因前提被推翻而改为**完整交付**
2. ~~`.npmignore`~~ → 已因实测无效而改为**收窄 `files`**
3. **维持删除范围**（不动 `assets/`）—— 仍然有效


---

## 8. Gate 4 判定：**PASS**（2026-08-16，Alex 业务验收）

**验收方式**：不复述 Gate 3 的技术结论，而是回到**审计报告的原始发现**，逐条复算「这个问题现在还在不在」。

| 原始发现 | 复算结果 |
|---|---|
| **F-16** playground 废弃两月仍在发布、仍在 description 推销 | 两侧目录 **0**、`description` 提及 **0** ✅ |
| **F-15**（Gate 侧）无消费者的空头绑定 | `tad-gate` 绑定 **0**，且留下可追溯注释 **1** ✅ |
| **F-19** 182 对逐字节重复的证据 | `stable5-pre` 跟踪 **0**；`stable5-post` 磁盘递归 **182** 完好；清单 **182** 行可回溯 ✅ |
| **F-09/F-10** `eval` 驱动的 `rm -rf` + 死守卫 + 参数解析静默失效 | 脚本 **0**；全仓 `eval "$@"` 的 4 处命中**全是本 Epic 自己的文档**在引述该缺陷，无可执行脚本 ✅ |
| **F-11** `rsync --delete` 无非空守卫 | 守卫 **1**，三场景实测（空/不存在/正常）行为正确 ✅ |
| **F-12** 压缩恢复安全网对含空格文件名多计数 | 2 文件（其一名含空格）实测返回 **2**（原为 3）✅ |
| **F-18/F-20** 发行重量 | npm 包体 **3.3 MB**（原 23.1 MB）、包内 evidence **0**（原 3445）✅ |

**两处需澄清的读数**（复算时发现，均为检查命令不准而非缺陷）：
1. `eval "$@"` 计数 4 —— 全部是文档引述，非可执行代码
2. `stable5-post` 计数 2 —— 那是**顶层目录数**（`source`/`targets`），递归实际 182 文件

**业务判定**：审计中归属本 Phase 的全部原始发现均已闭环，且无一是靠削弱验收标准达成的。**Gate 4 PASS。**

⚠️ **执行方式偏离已记录在 §7**：本单由 Alex 在人类 YOLO 授权下代 Blake 执行，角色分离被削弱。
Gate 2/3 的独立审查、AC 落盘、禁止纸面验收三项均保留。
