# Journal — retire-sync-decouple-projects (2026-08-17 → 实做 2026-08-22)

**Handoff:** HANDOFF-20260817-retire-sync-decouple-projects ｜ **任务:** TASK-20260817-003

---

## 1. 我的验证管道 bug 差点害我选错方案 —— 过滤器把「调用方」一起滤掉了

§4.3 让 Blake 先查 `*harvest` 是否调用 `harvest-scan.sh`。我第一次跑：

```bash
grep -rn 'harvest-scan' .claude/skills/ .agents/skills/ | grep -v '...'
```

`grep -v` 把含 `harvest-scan.sh` **字面量**的行全滤掉了 —— 而调用行恰恰写成
`bash .tad/hooks/lib/harvest-scan.sh`。于是输出为空、`$?=1`，我一度以为「无人调用 → 方案 B」。

**权威做法**：`git ls-files -z | xargs -0 grep -ln 'harvest-scan'` —— 立刻显示
SKILL.md:1365（`.claude` + `.agents` 各一处）。方案从 B 翻转为 A。

**可迁移判据：**
> `grep ... | grep -v <关键词>` 这类过滤管道，会把自己想找的目标一起滤掉，
> 当目标行的内容**包含**过滤关键词时。用排除法查「谁引用 X」永远先
> 直接 `grep -ln`（不滤），再人工分类；`-v` 只用于确证过的噪音类别。
> Bash 管道 `$?` 是**最后一段**的退出码 —— 别拿它当整条管道的结果。

## 2. 「活清单」与「历史记录」是两种完全不同的东西 —— 同一裁定先例复用

AC-7 判 AC-7 期望 0，删除后实测余 3 处。分类：

| 文件 | 性质 | 处置 |
|---|---|---|
| `docs/value-proposition.md:41` | **活声明**：「注册表是活的同步目标清单」→ 退休后变**假** | 改（人裁定） |
| `alex/SKILL.md:1633,1673-75` | **活命令清单**：向 agent 广告 *sync 可用 | 改（同一文件内，FR-3/4 本来就在重写它） |
| `config.yaml:342` / `migrations yaml` / `ac-verification.md` | **历史轨迹**：v2.4.0 变更日志 / 迁移记录 / 五版失败课 | 一字不动（人裁定） |
| `intent-router` / `tad-help` / `publish-protocol:205` / 其他 | 跨文件残留 | 不动，列残留（超出 FR 枚举范围） |

**可迁移判据：**
> 退休/删除一个能力时，区分三类引用：
> ① **活文档/活清单**（还在指挥行为）→ 必须同步改，否则留下「已退休但还在被推荐」的自相矛盾；
> ② **历史轨迹**（决策记录）→ 保留，那是证据；
> ③ **跨文件残留**（超出本单枚举）→ 不擅动，列清单交 Alex 另单。
> 判据：这个引用**还在被当作当前事实执行吗**？是→①，否→②③。

## 3. 真「不报错」要按效果判，不按退出码判

`harvest-scan.sh` 原代码：注册表缺失时 `echo "ERROR: ..." >&2; exit 0`。
**退出码是 0**（脚本注释写明 "Exit 0 always"），但它确实在**报错**（打印 ERROR）。
AC-6 若只查 `$?` 就会「改前=改后=0」地假绿。

**可迁移判据：**
> 对「是否报错」的验证，除了退出码还要抓 stderr/stdout 里的错误标记。
> `bash script 2>&1 | grep -c 'ERROR'` 比 `echo $?` 更能反映真实行为。
> 设计 AC 时，若被测代码「exit 0 但打印 ERROR」，AC 应同时断两个性质。

## 4. `tad.sh` 不读注册表 ≠ 没有别的活代码读它 —— 逐文件扫描才见全貌

handoff §1.3 实测「tad.sh 不读注册表」，说的是**安装器**。但注册表的活消费者
其实在 `*harvest` 一侧（harvest-scan.sh）—— 这正是一张「退休 *sync」的单
必须同批处理 harvest 的原因。§1.4 已经预见。

**可迁移判据：**
> 「X 不依赖 Y」的断言只能覆盖**被测的那个调用者**。删共享数据时，
> 用 `git ls-files | xargs grep` 全仓扫一遍所有引用者，再逐个分类。
> 单测式断言 + 全仓扫描 = 完整证据。

## 5. 顺带发现的既有缺陷（未修，另立单）

`intent-router-protocol.md:152,201-203` 仍把 *sync/*sync-add/*sync-list 列为
**可路由命令**，指向已删除的协议注册块。`tad-help/SKILL.md:70-72` 亦然。
这些在 FR-1..8 枚举之外 —— 本单不擅动，已列入 completion 残留与 NEXT.md。
发布流程 `publish-protocol.md:205` 的 step5 建议「Run *sync」同样过时。