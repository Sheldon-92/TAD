# Next Steps

> **本文件只放"还没做的"。** 已完成条目一律迁进
> `.tad/archive/next/NEXT-completed-through-YYYYMMDD.md`（逐字保留，可回查）。
> 规矩：**动手前先验一遍条目是否还成立**——2026-08-14 清账时发现
> ②a/②d/②e 三条标着「最高优先级」的待办**早已修复**，清单挂了两周没人划掉，
> 照它找活等于被误导。**清单不准 = 清单有害。**

**当前版本**：2.42.0 ｜ **默认通道**：full（`/alex` `/blake` `/gate`）｜ lite 🧊 冻结于 2026-08-13

---

## 🔴 优先队列（一个一个做，不并行）

### 0. ✅ **DONE 2026-08-16** — Gate 3 Check 8 已改成「出声但不拦」（commit `f5f62af`）

- [x] **`pre-gate-check.sh` 补了 `else`**，读不到判定行时发 WARNING 并点名它读的文件。
      Gate 2（code-reviewer + security-auditor，5 个 P0）+ Gate 3 + Gate 4（Alex 独立复算）全过。
      归档：`.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260816-gate3-check8-audible.md`
      ⚠️ **本条原来的三处说法都是错的，留档备查**（清单不准 = 清单有害）：
      (a) 称它是「Gate 3 FAIL 唯一的 BLOCK 路径」→ 实际有 4 条 exit-2 路径，
          只有这条以**判定本身**为触发条件；主拦截是「无 COMPLETION」那条。
      (b) 原修法「补 else → `HAS_BLOCK=1`」→ **照做会误拦 90% 的报告**。
          实测最近 20 份 COMPLETION 有 **18 份根本不写任何 Gate 3 判定标记**。
          用户 2026-08-16 裁定：只出声，不拦截。
      (c) 起草时一度提出「扩 grep 抓 frontmatter `gate3_verdict:`」→ 也错：
          那字段是 Gate 3 **跑完后**的 post-step 才写，PreToolUse 时点按设计就是空的。

### 0b. ~~上游根本不写 Gate 3 判定标记~~ —— 🛑 **前提是错的，2026-08-16 重新测量后撤销**

- [x] **原表述「18/20 的 COMPLETION 既无正文自评行、也无 frontmatter」是错的。**
      那个 18 是用 `grep 'Gate 3.*结果\|Gate 3.*Result'` 数出来的 ——
      **判据只认模板那一种措辞**。重新按语义测量最近 20 份：

      | | 份数 |
      |---|---|
      | 有模板标记（`**Gate 3 v2 结果**` 或 frontmatter `gate3_verdict:`） | 4 |
      | **有等价判定表述**（`## AC 结果（…RESULT=PASS）`、`## Layer 2（Gate 3）` 等） | **10** |
      | 确实没有判定 | **6** —— 且全部集中在 YOLO/Conductor、spike、pack-build 这类非常规通道 |

      也就是说：**full 通道的常规任务，判定信息一直都在，只是措辞不统一。**
      典型反例 `COMPLETION-20260814-routing-decouple.md` 结构完整、有 Layer 2 记录、
      有 Gate 4 验收段、甚至有「更正 Blake 报告中的两处不准」——它只是没照抄模板那句话。
- [x] **因此不立单。** §0 那一刀（Check 8 出声不拦）**仍然是对的**：
      机器确实读不到那 10 份的判定（措辞是开放集合），WARNING 说「我读不到」是**诚实的**。
      而 Gate 3 的判定本来就是**人跑 `/gate 3` 时做的**，报告措辞只是记录。
- [ ] **若日后想让判定机器可读**（可选，非缺陷）：统一措辞或强制 frontmatter。
      **取舍**：统一 → 机器可读但损失表达力（那些精简报告质量很高）；
      不统一 → 保持灵活、靠人读。**这是设计选择，不是 bug，需人裁定后再立单。**
- [ ] **`args` 形状可绕过整个 Gate 3 块**（同一批发现，独立缺陷）：
      `GATE_NUM` 由 `grep -oE '^[0-9]+'` 行首锚定解析，
      `" 3"`（前导空格）和 `"gate 3"` 都会让 hook 静默放行 `{}` exit 0。
      详见 `.tad/archive/handoffs/HANDOFF-20260816-gate3-check8-audible.md` §10.2(b)。

### 0d. ✅ 隐私：trace hook 写绝对路径 —— **源头已修**（Gate 4 accepted 2026-08-16）

- [x] **✅ DONE 2026-08-16 — 源头已修（commit `87c3db93`，Gate 3 PASS）**
      `record_trace()` 在 stat 之后把 `file_path` 转成**仓库相对路径**
      （`git rev-parse --show-toplevel` + case 前缀剥离，一处覆盖 jq/无-jq 两条输出路径）。
      15 条 AC 全绿（负控改前红 + 判别力实测：错序实现被 AC3 抓、jq 分支内插被 AC5 抓）；
      Layer 2：code-reviewer PASS、test-runner R1 CONDITIONAL → R2 PASS（F1-F4 全修复）。
      hook 端到端等效验证：`post-write-sync.sh` 产出的新 trace 是相对路径
      （`file":".tad/evidence/...`，不再以 `/` 开头、不含 `/Users/`）。
      AC12 钉死已知残留：**跨仓库写入保持绝对路径**（`*sync` 写下游项目仍泄漏），见下一条 NEXT。
      **Gate 4（Alex 独立复算，2026-08-16）**：自建 harness 重跑五条核心行为全过
      （含唯一有判别力的 AC3 —— cwd=子目录时 `size_bytes=2` 且路径相对，证明转换在 `stat` 之后）。
      **真实 Write→PostToolUse 链路已复核**（Blake 环境限制的那一环）：Alex 用 Write 工具建探针文件，
      hook 触发，`file` 字段为 `.tad/evidence/.../gate4-probe.md` —— **相对路径，修复在真实链路上生效**。
      探针与当天 trace 已清理；同文件内另一条 `/Users/` 是 `18:46:32Z` 产生的、
      **早于修复 commit `19:56:29Z`**，属修复前残留而非回归，已脱敏。
      ⚠️ **Gate 4 更正了 handoff 的一处机理描述**：「`case` 加引号防空格」是错的
      （`case` 模式不分词，含空格加不加引号都 MATCH）；引号真正防的是 **glob 元字符**
      （`/a[b]/repo` 不加引号 NO MATCH）。**结论没变，理由变了** —— 已进 `patterns/shell-portability.md`。

### 0d-2. 隐私：跨仓库写入的 trace 仍是绝对路径（AC12 钉死的残留，本单未堵）

- [ ] `git rev-parse --show-toplevel` 按 **cwd** 求值，不按文件路径求值：cwd=TAD、文件在
      下游项目（如 `*sync` 写 ~14 个项目）时，trace 记下**下游仓库的绝对路径**，仍在
      `/Users/<user>/` 下。语义本身歧义（相对 TAD 还是相对下游？），也可能正确答案是
      "跨仓库写入根本不该记进本仓库的 trace"。需要独立设计决定，另立单。
      证据：HANDOFF-20260816-trace-relative-path.md §7.1 + AC12。

### 0e. ~~建隐私/凭据扫描器~~ —— 🛑 **用户 2026-08-16 裁定不做**

- [x] **不做。** 契约已撤到 `.tad/archive/handoffs/blocked/HANDOFF-20260816-privacy-scanner-and-trace-relpath.md`。
      **撤单理由（两条，都不是"改不完"）**：
      (a) **前提没了** —— 立单的紧迫性来自"凭据泄漏过 3 天"，事后核定**凭据从未进入 git**
      （被提交的是 symlink，35 字节；`gitleaks` 扫 848 commit 确认 0 条）。
      (b) **方案本身是错的** —— Gate 2 两名专家合计 **11 个 P0**：手写正则漏掉
      Stripe/Slack/npm/PyPI/GCP/AWS-secret/`sk-proj-`/`.env` 几乎所有主流形态；
      `\s` 在 BSD ERE 里失效；`{40,}` 长度门槛把 32-36 字符的真凭据挡在外面；
      扫工作区而非暂存 blob（`git add` 后编辑即可绕过）；扫描器打印凭据且被要求提交进公开仓库。
      **而 `gitleaks` 已装（8.30.1），项目 `code-security` pack 里早有调用规范** ——
      违反 `principles.md`「Never Hand-Write What an Existing Tool Already Does」(2026-05-28)。
- [ ] **顺带发现，值得单独修**：`code-security` pack 里写的 `gitleaks protect --staged`
      在 **8.30.1 上是不存在的命令**（子命令已改为 `git` / `dir` / `stdin`）。
      **一条失效的安全操作指令，比没有更糟。** 改成 `gitleaks git --staged`。
- [ ] **若日后重启**：凭据检测直接用 gitleaks，只手写"个人路径三形态"那部分
      （`/Users/<u>/` ✅上轮覆盖 · `-Users-<u>-` ❌漏 4 文件 · 裸用户名 ❌漏 18 文件）。
      已知基线：gitleaks 开箱在本仓库有 **54 条误报**（全是研究文档里的 `api.example.com`
      等示例值），必须先建 allowlist。**服务端的 GitHub secret scanning + push protection
      优先级高于任何本地钩子** —— 服务端执行、`--no-verify` 绕不过、新 clone 免装。

### 0c. EPIC alex-blake-lightening 的两项未收口标准（Epic 已归档 2026-08-16）

> Epic 5/5 phase 全 Gate 4 PASS，已归档到 `.tad/archive/epics/`。
> 这两条是它**自己写明未达标**的成功标准，单列出来免得随 Epic 关闭一起消失。

- [ ] **SC1 收口：激活即付从 62K 继续降。** 全程已砍 42%（107.7K → 62K），但离 15K 目标还远。
      **Epic 的自述值得先读**：地板本体只占 20,081 B（≈5K tokens），
      其余 ~230K B 在「可搬但要搬得安全」的区间——**本 Epic 交付的是"能安全地搬"这个能力，不是 15K 这个数**。
      动手前先量，别把「精简」做成 v2.7 那种连约束一起删。
- [ ] **SC3：0/5 真活验证。** Epic 要求「每刀切完跑过 ≥1 个非框架真活且未回滚」，五刀一个都没跑。
      **这是唯一能证明减负没伤到能力的证据**，纯框架内自证不算。

### 1. 英文化 —— 🛑 **计划已作废，需重做**（用户 2026-08-15 裁定停下）

- [ ] **重做前先读作废的那版**：`.tad/archive/handoffs/blocked/HANDOFF-20260815-english-unification.md`
      **三轮专家审查、18 个 P0。停下的理由是结构问题，不是改不完**：
      **S0 要改的文件正是验证 S0 的机器要测量的文件**——插一个锚就改变地板表记录的载体字节数，
      地板表必须重生成、而它不在写权限里；真做成干跑不写文件，地板表就静默过时。**两条路都坏。**
      → **重做时拆成三张独立小单**，每张只碰一个文件：
      (a) Gate 3 fail-closed（= 上面第 0 条，已单列）
      (b) `skill-body-verify.sh` 的 SAFETY 判据从**全局计数**改成**行集 diff**
          （`verify.sh` 的 `acref()` 已实现过一遍，中英双语、防等量替换、已冻结——**复用别新造**）。
          ⚠️ 现状：`SAFETY_FLOOR=70`，blake 命中 84（余量 14）；而 blake 有 **26 行**、
          alex 有 **44 行**中文约束**完全不在计数内**——这是今天就存在、与翻译无关的洞。
      (c) `gen-floor.py` 真加 `--check` 干跑（现在压根不解析参数，`--check` 被静默忽略照样写文件）。
- [ ] **仍然有效、别重新量的调研结论**（作废那版的 §1.2/§2）：
      · 活文件含汉字 **626 个 / 320,883 字**；`.tad/evidence`+`archive` 另有 1,719 个 / 123 万字（**记录，不翻**）
      · `.claude/skills` 354 个 / 204,752 字 = **64%**，两位审查员一致判「96% 的风险换未验证的收益」→ 等有英文读者再动
      · **34 个包的中文 `keywords` 与 5 个 skill 的中文 `description` 是路由面不是文案**
        （`save-skill` 的触发串就是 `把这个存成 skill`）——**翻掉就破坏「能用中文使唤 TAD」这件事本身**。
        **用户已裁定：保留中文（选项 A）。**
      · 要立的规则：**产物一律英文，对话跟随用户**——这两件事框架里从来没区分过，
        所以不先立规则，翻完下个 session 又开始写中文。

### 2. 纪律可达性剩余项

TAD 自己的四笔账，源自 `EPIC-20260813-alex-blake-lightening` 收口。前两条是同一个病：**约束够不着 agent**。

- [x] **✅ 2026-08-15 ACCEPTED + ARCHIVED — 致命操作识别表已搬到够得着的地方**
      commit `2c220f5`（**已推送，2026-08-16 核实在 `origin/main`**）。`fatal_operations`（97 行/3,439 B）从 `config-cognitive.yaml`
      整块移到 `config-quality.yaml`（alex/blake 正文实读 + Gate 显式指针可达），11 处指针同步。
      Gate 4：10/10 AC **Alex 独立复算**；AC7 用 **Alex 自派**的零上下文 agent 复验 **6/6**
      （12 次 Read、每文件一次、无 offset、无 Bash/Grep）。**结构保证**：目标文件 875 行 ≈10.8K tokens，
      离 Read 上限 25K 有一倍余量——不重演 P7「在场但不可达」。
      ⚠️ 契约出了 7 个 rev，**没有一个是因为要做的事有问题**——全是验收层：落点判据错、
      字节漏算、键三次选错、行内替换按 1 行计、指针 #9 无 AC 覆盖。
      ⚠️ 过程如实记录不追认：Blake 一次越权改契约（内容对、过程错）＋ 一次误报指针已改。
      归档：`.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260814-discipline-reachability.md`；
      Gate 4 报告 `.tad/evidence/acceptance-tests/reachability/gate4-alex-recompute.md`。
      **剩下三条（`研究先行`/`技术决策透明` 的载体仍在不加载的 `config-cognitive`）见下条。**

- [ ] **`config-cognitive.yaml` 仍不被 Alex 加载 → 另两条纪律仍是暗的**
      `研究先行` / `技术决策透明` 的载体还在 `config-cognitive.yaml`，而 `STEP 3` 正文不读它。
      ⚠️ 这两条**有常驻祈使句兜底**（P7 放的），缺的是本体；不像致命操作那样本体即识别能力，
      优先级低于原来的判断。**动手前先量：它们的本体到底承载什么，值不值 +N 字节。**

- [x] **✅ 2026-08-15 三件杂活修完** —— 都是「改了产物没改生成器」这一个形状：
      (a) `gen-floor.py` 的 `keys30` 路径指向已归档文件 + `启动扫描` 锚点是 P3 前的旧串
      （实测该旧串在 `SKILL.md` 命中 0）→ 锚点改成常驻祈使句原文
      `激活时必须跑健康/依赖/研究/僵尸四类扫描`（它同时满足 keys30 的 `scan|扫描` 校验），
      生成器现已 exit 0，重跑只改那 3 行、`致命操作` 载体未被改回；
      (b) `measure.sh` 的 `HB=` 指向已归档路径 → 已修，现可跑（STATIC 254,630 B ≈ 63K）；
      (c) `STEP 3.5b` Path 2 正则只写 `CVE-` → 补 `GHSA-`。**触发这条纪律的那次真实事故
      （停跑 28 天、漏 4 个漏洞、含明文打印 token）里编号全是 GHSA-，原正则本就不可能命中。**
      parity 零输出、`skill-body-verify` 全绿。
- [ ] **`alex/references/**` 83 条强制行中 82 条在常驻层无重复副本**
      → **今天守住纪律的是"重复"，不是加载机制。** 9 条 `forbidden` 里 8 条靠 `CLAUDE.md` 重复侥幸安全。
- [ ] **净省要打 25% 的折**：`knowledge-bootstrap` 的 `load_when` 是"每次激活时"，
      它每次都被读，只是搬出了测量分母。1,342 B / 净省 5,389 B 是假的。同类外置都要按这条复查。
- [ ] **express 审查下限两个口径**（**需人裁定**）：五处说 min 2（含 `CLAUDE.md:63`、
      `alex/SKILL.md:1551/1236/1585`、`config-quality.yaml:74`）；
      `principles.md` 的 SAFETY 条目与 AR-001（`alex/SKILL.md:1710`）说 express 可降到 **min 1**。
      P7 把 min 2 一侧写成了常驻祈使句（更严，方向安全），矛盾因此更显眼。

### 3. Phase 3c —— **BLOCKED，通道被关**（需人裁定）

- [ ] **Phase 3c Release live dogfood** — 原文：「**Lite-only** 真实 publish+sync，
      这是整个 Epic 第一个真正对外写的阶段」。**但 lite 已于 2026-08-13 冻结**
      （`CLAUDE.md` §2.5：不接新工作）。**一个 READY 状态的阶段，它的通道已被另一条线关掉。**
      三选一：改走 full ｜ 作废 ｜ 作为"在飞单"例外放行。开工前另需处理
      AC8 只剩 **2 字节**余量（Lite core 52,198 / 上限 52,200）。

### 4. 剩余机制缺口

- [ ] **③ 移植 lite 的无条件轮次上限到 full**
      lite 有 `repair_round 3/3`（不看错是否相同）+ 跨压缩持久化；full 只有 error-shaped 的
      `consecutive_same_error>=3`，**错不重样就永远归零**。
      ⚠️ **重做前必须先读** `.tad/archive/handoffs/blocked/HANDOFF-20260804-gate-loop-circuit-breaker.md`：
      2026-08-04 按三 FR 大单设计过，**4 轮 Gate 2 / 8 名专家 / 26 个 P0 / 零交付**，四版栽在同一处。
      关键洞察：lite 的免疫来自 **boundary-append**（阶段边界枚举、与成败无关），不是「3 轮」这个数字。
- [ ] **④ handoff 体量闸** — 生成时超 80KB / 20 AC → 提示拆分或降级（提示不硬拒）。
      落点必须在**任何 reviewer 被 spawn 之前**（step1b/step1c 之间），否则"坚持原样"是唯一理性选项。
      实测分布：出事那张 107KB/27AC；64/62/52KB 三张都跑完了；其余 <40KB。

### 5. 杂活（不走 phase 那套机器）

- [ ] **brain-index 生成器 `set -e` 缺陷** — 撞到缺 `task_type:` 的旧归档即退出 →
      「recent 50」段只出 11 条（缺 39）。**预存缺陷**。
- [ ] **`STEP 3.5b` 的 CVE 正则抓不到 GHSA** — Path 2 是 `/CVE-\d{4}-\d+/`，
      而触发这条纪律的那次真实事故（停跑 28 天、漏 4 个漏洞、含明文 token 打印）
      里的编号全是 **GHSA-**。**原正则本来就不可能命中。**

---

## 📌 判断依据（不是待办，是下次动手前要想起来的）

- **改一个机制时去找它的兄弟位置。** 同病治一半是本仓库的高频形状：
  Gate 3 改了 AC 驱动、Layer 1 被落下；reviewer 读取有界了、Blake 自己无界；
  lite 有护栏、full 没有。**修复没横向扫干净 = 病灶原地转移。**
- **遇到 full 侧的纪律问题，先去 lite 找有没有现成答案**，别从头设计。
  lite 是踩完坑之后建的，full 是更早的设计。
- **`grep` 证明"在文件里"，不证明"agent 读得到"。** 文件超过 Read 单次上限
  （本机实测 25,000 tokens）后，尾部是"在场但不可达"的内容，而所有基于 grep 的检查对它全盲。
  详见 `patterns/gate-design.md` 同名 SAFETY 条目。

---

## 💡 Ideas（未裁定，按需捞取）

完整清单见 `.tad/ideas/`。此处只留最近三批的入口：

- **2026-07-03（AI Tinkerers #33）**：single-loop agent 无框架 · trace hour 周会 ·
  rubber stamp effect（人验证 AI 判断会盲目同意，已进 `principles.md`）· JAX 极致并行
- **2026-06-16（SkillOpt 深研）**：见 `.tad/ideas/`
- **长期停放**：TAD opt-in 模式（担心放松默认）· Domain Pack YAML 退役 ·
  跨项目 skill 提升 · declarative agent constraints · agent adapter pattern

## 🧊 长期停放的 Epic（非阻塞）

- Agent Capability Packs 6/9 · Goal-Driven Research Director 3/4 · Security Domain Pack Chain 2/5（暂停）
