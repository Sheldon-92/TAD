# Code Review — LITE-20260807-1050-tadsh-version-authority（实现后独立审查）

**Model**: deepseek-v4-flash | harness=Claude Code Agent tool（本机 Bash 工具运行 zsh；AC10/AC12 及探针按规格用 bash 跑）| route=subagent（code-reviewer）

**审查对象**: `tad.sh`（唯一改动文件，md5 `887658f1581b660de79feccb14ff2f80`，1895 行；基线 1855 行）

**Verdict**: **PASS**（无 P0、无 P1；P2 观察项 3 条，均非本单引入且方向 fail-safe）

---

## 一、改动集核验（scope-violation 检查）

以 handoff §文件清单为基准（唯一文件：tad.sh）：

- `git diff HEAD --name-only` tracked 改动仅 `tad.sh` 一项，其余 4 项（lite-pricing-gate-protocol 3 个证据文件、REGISTRY.yaml）均为会话开始快照中已存在的既有脏项，与本任务无关，不计 scope-violation。
- untracked 新增仅 `.tad/evidence/acceptance-tests/tadsh-version-authority/`（本单证据产物，handoff 明示）。其余 untracked 项均与会话开始快照逐一相同。
- 审查期间快照集合差（`comm -13` / `comm -23`）：**两个方向均空** —— 审查过程零写入（仓库只读遵守）。
- **无清单外改动 hunk，无 scope-violation。**（执行实证）

## 二、Spec 符合性（M1-M8 逐处核对）

| 处 | 位置 | 判定 | 依据 |
|---|---|---|---|
| M1 | L17-25 注释 | 符合 | "can never go stale" 措辞已删，改写为「状态闸 MUST NOT 依赖字面量，判定由 probe/ROOT FIX 完成」，且明确记录 2.19.1-class 两次补丁史（执行实证：AC6a N=0） |
| M2 | L29 `VERSION_URL` | 符合 | 与规格逐字一致；真实 GET 返回 `2.40.0`（URL 有效，执行实证） |
| M3 | L44-57 `PROBE_OK` + `probe_remote_version` | 符合 | 与规格逐字一致（含 `|| true`、正则 `^[0-9]+\.[0-9]+\.[0-9]+$`、双注释块）；AC3 三载荷全过 |
| M4 | L1440 调用 | 符合 | `probe_remote_version`（L1440）在 `STATE=$(detect_state)`（L1441）之前，且在 `main() {`（L1401）之后 —— AC1 的 `MN < P < S` 三锚全过 |
| M5 | L1445 CRLF 裁剪 | 符合 | 与 detect_state L1369 同款语法 `"${CURRENT_VERSION//[$'\r\n ']/}"`；bash 实测 CRLF 裁剪有效（执行实证）；与 --force 分支（L1497）口径一致（handoff 风险 #7 确认修复） |
| M6 | L1494-1519 三分支 | 符合 | **承重顺序正确：`--force` 最前**（L1495）、`elif [ "$PROBE_OK" != "1" ]` 第二（L1505）、`else` 快速退出最后（L1510）；`--force` 分支原样保留（含 L1502「does not downgrade」+ exit 0）；AC10 a/b/c/d 全过 |
| M7 | L1581-1590 ROOT FIX 块 | 符合 | 与规格逐字一致（含注释块、`rm -rf "$TAD_SRC"`、`!= "-1"` 判定、exit 0）；AC12 五向 harness 全过 |
| M8 | L1574-1577 注释 | 符合 | "can never go stale" 措辞已去，写明「derive 在下载后运行故天然新鲜，状态闸必须靠 probe/ROOT FIX」 |

## 三、代码质量审查

### P0（必修）
无。

### P1（应修）
无。

### P2（建议 / 观察项）

1. **[P2-1] 多行 `version.txt` 的裁剪行为是连接而非取首行**（执行实证 + 阅读推断）
   探针：`printf "2.40.0\n2.39.0\n"` → 裁剪后 `2.40.02.39.0`（连接）。方向分析：连接值在 `_tad_ver_cmp` 下非数字段归一为 0，实际比较多数落入「已装 < 目标」→ 继续安装，fail-safe。且这是既有行为（detect_state L1369 同款语法），`.tad/version.txt` 由脚本自身单行写入。**非本单引入，不改**。
2. **[P2-2] 高段垃圾版本值（如 `9.9.9abc`）会被判「已是最新」**（阅读推断）
   `_tad_ver_cmp` 对非数字段归一为 0，`9.9.9abc` > `2.40.0` → detect_state 判 current + M7 判 Nothing to do → 静默不升级。但这是**既有行为**（改前同一判定链同样静默），M7 只是复用了 `_tad_ver_cmp`，非回归。若要防御，可在 `_tad_ver_cmp` 对**首段**非数字输入 fail-safe（如直接返回 -1），超本单范围，仅记录。
3. **[P2-3] AC3 shim 不覆盖生产 `set -euo pipefail` 上下文**（阅读推断）
   AC3 在 zsh 子 shell 里 source 函数体，验证的是函数逻辑正确性；「`|| true` 在生产解释器下确属必需」由本次 reviewer bash 探针补验（无 `|| true` 时 curl 失败 → 退出码 7 → set -e 终止；有则兜住）。AC 可选的加固方向：shim 内加 `set -euo pipefail`。非缺陷，仅验证强度建议。

### 关键机制实证（探针结果）

- **`|| true` 是功能性的，不是保险**：tad.sh 为 `set -euo pipefail`（L7）。bash 探针：桩 curl `return 7` → 管道非零 → 无 `|| true` 时命令替换返回 7 → set -e 终止整个脚本；有 `|| true` 则兜住（v 为空、PROBE_OK 保持 0）。与 handoff 知识引用（`shell-portability.md` §grep No-Match）一致。实现正确。
- **根因修复端到端生效（核心场景 S1）**：集成模拟（M6 块 + derive 覆盖 + M7 块 + `_tad_ver_cmp` 组合，bash 跑）—— 探测失败 + 字面量 2.40.0 陈旧 + 本机 2.40.0 + 真实源树 2.41.0 → `FINAL_ACTION=upgrade`（改前此场景静默不升级）。**本单标题级目标实证达成。**
- **不降级路径（S2）**：探测失败 + 本机 2.41.0 + 真实目标 2.40.0 → Nothing to do（不降级）。符合「绝不降级」既定方向。
- **继续安装路径（S3）**：探测失败 + 本机 2.39.0 + 真实目标 2.41.0 → `FINAL_ACTION=upgrade`。
- **AC10a 拦截力独立反证**：构造 v1 错误分支顺序变体（PROBE_OK 在 FORCE 前）→ A 行输出 `ACTION=upgrade`、无 `does not downgrade` → AC10a 判据 FAIL。**AC10a 确实拦得住 P0-2**（handoff 双向反证声明独立复现）。
- **M5 裁剪语法**：bash 下 `${v//[$'\r\n ']/}` 对 `2.40.0\r\n` 有效裁剪为 `2.40.0`。

### 静态走读确认（阅读推断，未发现缺陷）

- M6 `--force` 分支内 `cmp_result ∈ {0, 1}` 不可达 -1：进入前提是 `ACTION=="none"` ⇔ `STATE=="current"`（detect_state 用同一 TARGET_VERSION 判定），本机不可能比目标旧 —— else 分支「is NEWER」文案无错配路径。
- M7 触发时机在用户确认（Continue?）与下载解包之后、`case $ACTION` 之前 —— 已最新时多一次确认+下载后 exit 0，为 handoff 显式接受的行为。
- `rm -rf "$TAD_SRC"` 与既有 L1865 收尾清理同一语句同一对象（TAD-main 刚由本脚本 tar -xz 创建），无新增删除面；handoff 已按 `shell-portability.md` §rm Chokepoint 论证。
- `CURRENT_VERSION="none"`（fresh/partial 状态）→ M7 条件不满足 → 跳过，安装路径不受影响。
- 探测失败 + 字面量陈旧 + `--force` 相等场景：force 分支 cmp=0 → ACTION="upgrade" → M7 跳过（FORCE=1）→ 强制重装真实目标，符合 force 语义。
- 展示层预览（L1525 起）用探测值、M7 后 derive 二次覆盖 —— 已知展示不一致，handoff 风险 #8 显式声明不处理。

## 四、AC 重跑结果（11 条执行，AC4 退役不执行）

| AC | 结果 | 实测关键值 |
|---|---|---|
| AC1 | PASS | MN=1401 P=1440 S=1441（`MN < P < S`） |
| AC2 | PASS | D=1578 R=1581 X=1592 N=2 |
| AC3 | PASS | AC3a/AC3b/AC3c 三载荷全过（桩 curl，零网络） |
| AC5 | PASS | `TALLY: PASS=12 FAIL=0`，退出码 0 |
| AC6 | PASS | N=0（can never go stale 清零）、M≥1（state gate 锚存活） |
| AC7 | PASS | `^TARGET_VERSION="2.40.0"$` 恰 1 处 |
| AC8 | PASS | `bash -n` 退出 0；numstat 仅 tad.sh 一行（43 增 3 删） |
| AC9 | PASS | 集合差两个方向均空（无越界、无条目消失） |
| AC10 | PASS | A 含 does not downgrade 不含 ACTION=upgrade；B 含 ACTION=upgrade；C 含 Nothing to do；D 含 does not downgrade（bash harness） |
| AC11 | PASS | TOTAL=1 INSIDE=1（PROBE_OK 读取全在 ACTION=="none" 块内） |
| AC12 | PASS | eq_noforce/newer_noforce 含 Nothing to do；older_noforce/eq_force/fresh_none 含 PROCEEDED 不含 Nothing to do（bash harness） |

与实现者证据 `ac-results.md`（MN/P/S、D/R/X/N、AC3 三载荷、AC5 12/0 等）**逐项吻合**，无任何一处复核结果与证据文件矛盾。

## 五、结论

**PASS**。改动集严格限定 tad.sh 一个文件；M1-M8 全部逐字符合规格（M6 三分支承重顺序正确、M7 逐字）；11 条 AC 全部重跑通过且与实现者证据吻合；根因修复在端到端集成模拟中实证生效（核心场景 S1 从静默不升级变为正确升级），不降级保护（S2）与 --force 保护（AC10a 反向拦截力）均独立实证；`|| true` 必要性、M5 裁剪、探测 URL 有效性均执行实证。3 条 P2 观察项均属既有行为或 fail-safe 方向，不阻塞放行。

---

## 执行证据

（以下命令均实际执行；AC 命令逐字取自 handoff，探针为 reviewer 构造）

```
$ git diff HEAD --name-only
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt      (既有脏项)
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
.tad/research-notebooks/REGISTRY.yaml                                 (既有脏项)
tad.sh                                                                 (本单唯一)
```

```
$ MN=$(grep -n '^main() {' tad.sh | head -1 | cut -d: -f1); P=$(grep -n '^    probe_remote_version$' ...); S=$(...)
MN=1401 P=1440 S=1441
AC1-PASS
```

```
$ D=1578 R=1581 X=1592 N=2
AC2-PASS
```

```
$ AC3 shim（sed 抽取函数 + 桩 curl 三载荷）
AC3a-PASS
AC3b-PASS
AC3c-PASS
```

```
$ bash .tad/hooks/lib/detect-state-test.sh | tail -2
TALLY: PASS=12 FAIL=0
exit=0
```

```
$ AC6a/AC6b/AC7
AC6a-PASS
AC6b-PASS
AC7-PASS
```

```
$ bash -n tad.sh && echo AC8a-PASS && git diff --numstat -- tad.sh
AC8a-PASS
43	3	tad.sh
```

```
$ AC9 集合差（会话开始快照 vs 当前）
before-sorted-OK / after-sorted-OK
comm -13: (空)
comm -23: (空)
```

```
$ AC10 harness（bash）
A: WARN:Installed v2.41.0 is NEWER than target v2.40.0. --force does not downgrade.
B: ACTION=upgrade
C: ✅ Nothing to do. TAD v2.40.0 is already installed.
D: WARN:Installed v2.42.0 is NEWER than target v2.41.0. --force does not downgrade.
```

```
$ AC11
TOTAL=1 INSIDE=1
AC11-PASS
```

```
$ AC12 harness（bash）
eq_noforce   : ✅ Nothing to do. TAD v2.40.0 is already installed.
newer_noforce: ✅ Nothing to do. TAD v2.40.0 is already installed.
older_noforce: PROCEEDED
eq_force     : PROCEEDED
fresh_none   : PROCEEDED
```

```
$ 探针1：真实网络探测（只读 GET）
2.40.0
```

```
$ 探针2：bash + set -euo pipefail，桩 curl 失败，有/无 || true
PASS: bash+pipefail 下 curl 失败被 || true 兜住, v=[]
对照退出码=7 (非 0 = set -e 会终止)
```

```
$ 探针3：M5 裁剪语法（bash）
M5-bash-PASS: CRLF 裁剪有效 v=[2.40.0]
多行输入裁剪后 v2=[2.40.02.39.0] (连接而非保留首行)
```

```
$ 探针4：集成模拟 S1/S2/S3（M6+M7+_tad_ver_cmp 组合，bash）
S1: FINAL_ACTION=upgrade      # 核心场景：探测失败+字面量陈旧+本机==字面量+真实源树更新 → 正确升级
S2: ✅ Nothing to do ...      # 本机 2.41.0 > 真实目标 2.40.0 → 不降级
S3: FINAL_ACTION=upgrade      # 本机 2.39.0 < 真实目标 2.41.0 → 继续安装
```

```
$ 探针5：AC10a 反向拦截力（v1 错误分支顺序变体）
A: ACTION=upgrade     # 判据 FAIL → 变体被 AC10a 抓住（无 does not downgrade）
B: ACTION=upgrade
```
