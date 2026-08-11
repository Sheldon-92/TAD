# LITE Handoff: Layer 1 AC 驱动化 + 两处环境耦合修复

**Date**: 2026-08-10 | **Contract revision**: 5
（rev1 FAIL P0=4/P1=9/P2=12 → rev2 CONDITIONAL P0=1/P1=2/P2=6 → rev3 CONDITIONAL P0=1/P1=0/P2=7
→ rev4 CONDITIONAL **P0=0**/P1=2/P2=1 → rev5 修 R1/R2/R3。四轮下来 reviewer 的每一条事实主张均由 Alex
独立命令复验属实，无一条被推翻；AC5 的三次失败全部是被**可运行反例**攻破，不是被论证攻破。
rev5 的处置是删掉那个可选宽容口本身，而不是第四次加固它。）

## 目标

把 Blake 的 Layer 1 自检从硬编码 JS 四件套（`npm run build` / `npm test` / `npm run lint` /
`npx tsc --noEmit`）改为执行 handoff §9.1 声明的技术检查行，并修掉另外两处把作者环境当成执行环境的
指导（pyyaml 依赖、Blake 全文无界重读）。

为什么现在：这些缺陷目前只坑本仓库，而 Epic Phase 3c 的 sync 会把它们扇出到 14 个已注册项目。且 ②a
不是新设计：`gate/SKILL.md:159-162` 早已完成同一迁移（"Gate 3 no longer hardcodes tsc/test/lint …
The Gate executes whatever §9.1 declares"），Layer 1 是被落下的那一半。

## 不做什么

- 不做项目类型探测（`package.json` → npm、`pyproject.toml` → pytest）。那是再造一张硬编码表，且违反
  「handoff 是 Blake 唯一信息源」。
- 不改 Layer 1 的 15 次上限与 circuit breaker——它们不是缺陷。
- 不改 Layer 2 / Gate 3 / Gate 4 的任何逻辑。
- 不改 `.tad/schemas/loop-config.schema.json`（D3 已实测无需改）。
- **不动以下已知残留载体**（经审查确认存在，本单显式排除，理由逐条给出）：
  - `.tad/hooks/lib/audit-yolo.sh:278,288` —— 它**实际执行** `npx tsc --noEmit` / `npm test`，是同一
    缺陷的最严重实例；但 `.tad/hooks/` 属高后果面且在本单 mandate 的 `explicit_exclusions` 内。
    **排队为独立单**（见「风险与注意」F3 具名 follow-up）。
  - `.tad/gates/quality-gate-checklist.md:230-232`、`.tad/guides/anti-rationalization-tables.md:29`
    （孤儿文件，仅 CHANGELOG 引用）、`.tad/templates/acceptance-verification-guide.md:39`
    （已带 "or equivalent" 软化）—— 非 Layer 1 执行路径，同批 follow-up。
  - `.tad/tasks/release-execution.md` 与 `config-execution.yaml` 的 `release_checklist` —— 属 TAD 自身
    发布流程，与 Layer 1 无关。⚠️ 更正 revision 1 的错误理由：本仓库 `package.json` 的 `scripts` 实测
    只有 `{"test": "echo \"No tests yet\""}`，**没有 build/lint**，所以那里的 `npm run build` 在本仓库
    同样是坏的。排除它是范围判断，不是因为它合法。
  - `config-execution.yaml:99`（`npm run build:ios`，mobile 场景 `extra_steps`）、`.tad/spike-v3/` 下
    web-frontend 研究文档 —— 按定义就是 JS 域。
- 不 push、不 tag、不 publish、不 sync、不写任何下游项目。

## 文件清单

修改（8 个载体；revision 2 相对 revision 1 的增删已标注）：

1. `.claude/skills/blake/SKILL.md` —— 编辑点：`:96-99`（顶部 ASCII 框图，四行各含一条命令）、
   `:903-918`（`2_layer1_loop` 本体）、**`:921-922`（新增，P1-1）**、**`:1325-1326`（新增，P1-1）**
   —— 后两处是 ANTI-RATIONALIZATION 注释，逐字断言「Layer 1 的 npm test」，属活载体；
   另 `:509-527`（②e）、`:1247`（②d）。
   ~~`:1758`~~ **删除（P2-2）**：实测内容为 `layer1: "Self-Check (max 15 retries, circuit breaker @ 3)"`，
   不含任何 JS 命令，是 revision 1 的幻觉编辑点。
2. `.agents/skills/blake/SKILL.md` —— 同上，镜像
3. `.tad/config-execution.yaml` —— 仅 `:16` 的 Layer 1 描述行
4. `.tad/ralph-config/loop-config.yaml` —— `layer1.commands`
5. `README.md` —— **`:268`**（P2-1 更正：`:267` 是 `**Layer 1 (Self-Check):**` 标题行，缺陷在下一行）
6. **`docs/RALPH-LOOP.md:45-48`（新增，P1-2）** —— 完整的 Layer 1 命令表（4 行 × Command/Timeout/
   Required/Description）。git 跟踪，且被 `README.md:5`、`README.md:466`、`docs/README.md:12`、
   `docs/CODEX-USER-GUIDE.md:481` 链接为「Ralph Loop Guide」。漏掉它会让 README 与它自己链接的指南互相
   矛盾。
7. **`.tad/project-knowledge/patterns/shell-portability.md:72`（新增，P1-3）** —— 该行逐字教
   `python3 -c "import yaml; yaml.safe_load(...)"`，而 `ac-verification.md:108` 有一条本机禁用清单逐字
   写着 ``Ban list for this host … `import yaml` ``。**知识层自相矛盾**，且这是 Blake 在
   `1_5_context_refresh` 会加载的层。仅改该行的命令示例，不动条目的 Context/Discovery/failure_mode。
8. **`.tad/evidence/audits/lite-constraint-ledger.md`（新增，P1-8）** —— D2 定价行。
   **Alex 已在设计期追加完毕**（追加前的强制超期扫描：0 OVERDUE / 0 MALFORMED），Blake 不需再写；
   列入清单是为了让 AC14 的范围断言不把它判为越界。

创建：

9. `.tad/evidence/acceptance-tests/layer1-ac-driven-compat/verify.sh`
10. `.tad/evidence/acceptance-tests/layer1-ac-driven-compat/results.txt`
11. `.tad/evidence/acceptance-tests/layer1-ac-driven-compat/scope-baseline.txt` —— 实现前的
    `git status --porcelain=v1 -uall` 快照，AC14 的基线（**必须在任何编辑之前生成**）
12. `.tad/evidence/reviews/blake/layer1-ac-driven-compat/` —— 实现后独立审查载体

## 决策

- **D1｜Layer 1 的命令来源** = handoff §9.1 Spec Compliance Checklist 中的技术检查行，与 Gate 3 同源。
  **精确优先级（P1-6 新增，必须写进 SKILL 文本）**：§9.1 声明的行是唯一权威来源；`loop-config.yaml`
  的 `layer1.commands` 仅在 §9.1 未声明任何技术检查行时作为项目本地默认生效；两者都为空 → 走 D2。
  这条不能只在本契约里成立——**下游 14 个项目会保留它们非空的 `loop-config.yaml`**，SKILL 文本不写清
  优先级，就等于把硬编码表在下一层原样复活。
- **D2｜零命令语义**：§9.1 与 `loop-config.yaml` 均未提供可运行技术命令时，Layer 1 **判定通过，并在
  Blake 的 completion report 的 Gate 3 小节写下一行零命令记录**（载体已具名，P0-4）。禁止静默跳过。
- **D3｜空数组合法性已实测**：`loop-config.schema.json` 中 `layer1.properties.commands` 仅声明
  `{"type": "array"}`，无 `minItems`；`layer1.required` 含 `commands`，故键必须存在但可为空。不改 schema。
- **D4｜②d 替换目标** = ruby 的 `YAML.safe_load`（macOS 自带）。选它是因为 `ac-verification.md` 的
  active-parse 条目已把 ruby 定为本仓库的 YAML 解析范式，且 `:108` 明确禁用 `import yaml`。
  **替换文本必须是可自测的形式**（P0-3/AC10）：接受一个文件路径参数，而不是把仓库内的具体路径写死进
  会分发到 14 个项目的通用协议文本。
- **D5｜②e 有界读取**与 reviewer 模板（`blake/SKILL.md:1399-1403`）同构：handoff §6 + §9 + YAML
  frontmatter + 本单变更文件；其余节按需再读。顺带修 `1_5_context_refresh` 的步骤编号重复——空跑实测
  （`:514-524`）序列为 `1,2,3,4,5,6,7` 紧接 `5,6,7,8`，即 **5/6/7 各出现两次**；成因是知识加载那段
  被插入时没给原有的 5-8 重编号。修法：整体重排为连续单调序列。
- **D6｜约束准入（revision 1 判错，已更正）**：②a/②d/②e 确为净收窄，无需定价。但 **D2 不是**——它
  在一个原本无通过路径的阻塞循环里新建了一条 PASS 路径，并新增了一项记录义务。已按 alex-lite
  「约束准入」在 `.tad/evidence/audits/lite-constraint-ledger.md` 追加一行，逐字锚 `零命令`，状态
  HAS-CARRIER；追加前的强制超期扫描输出为空（0 OVERDUE / 0 MALFORMED），该结果须随本单 Completion 记录。
  ⚠️ **诚实标注（N9）**：该行的「载体路径」格填的是缺陷代码位置（`blake/SKILL.md:903-918`，grep 可验）
  加 `NEXT.md:15` 的记录，而 alex-lite「约束准入」原文要求的是"journal / 研究文件 / violations.log 中的
  **真实事故位置**"。本仓库没有非 JS 项目空转 15 轮的现场事故记录——这条缺陷是 Phase 3b Gate 4 收尾时
  **靠代码检视**发现的，不是踩出来的。判 HAS-CARRIER 的理由是载体已存在且可机械核验，不是"先加后补"；
  但它确实不是字面意义上的事故记录，此处明记，不粉饰。台账为仅追加，历史行不改。
- **D7｜正向锚原则（P0-1 新增）**：本单每一个「删除某内容」的 AC 都必须配一个「替代品存在」的正向 AC。
  revision 1 的 11 条内容 AC 全是缺席断言，Blake 把 `commands:` 整个删掉即可 11/11 全绿，而 Layer 1
  连命令来源都没有了——比原状更糟。正向锚是本 revision 的核心修复。

## AC

**约定**：凡标注「两棵树」的，必须在 `.claude/skills/...` 与 `.agents/skills/...` 上**各自独立执行**；
不得以「一棵树通过 + AC15 镜像相同」替代——两棵树可以「一样地坏」，字节同一性早退会让内容检查变死代码
（依据：`release-sync.md:27`）。

块截取统一方法（AC1/AC2/AC3/AC12 共用，写进 `verify.sh` 作为函数）：
`s=$(grep -n '^      <key>:' "$f" | cut -d: -f1); e=$(awk -v s="$s" 'NR>s && /^      [0-9a-z_]+:/{print NR; exit}' "$f"); sed -n "${s},$((e-1))p" "$f"`

- AC1（缺席）: 两棵树 `2_layer1_loop` 块内 `grep -c 'npm \|npx '` == `0`。
- AC2（**正向**）: 两棵树 `2_layer1_loop` 块内同时满足 `grep -cF '§9.1'` ≥ 1 **且**
  `grep -cF 'Spec Compliance Checklist'` ≥ 1。锚定 §9.1 确实成为命令来源，而不只是旧内容消失。
- AC3（**正向，覆盖 D2**）: 两棵树 `2_layer1_loop` 块内 `grep -cF '零命令'` ≥ 1 **且**
  `grep -cF 'completion report'` ≥ 1 —— 断言零命令分支存在且记录义务具名。
- AC4（**正向，覆盖 D1 优先级**）: 两棵树 `2_layer1_loop` 块内 `grep -cF 'loop-config.yaml'` ≥ 1，
  且该块内出现 §9.1 与 `loop-config.yaml` 的先后关系表述（`grep -cE '优先|precedence|仅在'` ≥ 1）。
- AC5（缺席，**rev5：闸门整个删除**）: 两棵树 `blake/SKILL.md` **全文**
  `grep -c 'npm run build\|npm test\|npm run lint\|npx tsc --noEmit'` == `0`。无例外、无示例块、无区域运算。
  当前基线 = **12** 命中。
  ⚠️ **为什么删掉而不是再打一次补丁**：那个"至多一个示例块"的宽容口**是我自己发明的**——契约的决策段、
  「不做什么」、文件清单里**没有任何一处要求保留 JS 示例**（实测：`示例块` 一词只出现在 AC5 自己的措辞里）。
  为一个无人要求的可选口，独立审查连续三轮构造出三个能过的反例：
  ① rev2 用绝对行区间 → 被"块必须变长、`:1325` 距上限仅 4 行余量"攻破；
  ② rev3 用内容锚 → 被 `95-102`（框图**内部**，不含定界符）攻破；
  ③ rev4 用区域不相交 → 被 `:104`（两个框图之间的**间隙行**，视觉上仍在流程图里，却落在所有区域之外）
     与"在 `:1325`/`:1326` 之间插一个空行即可让 AR 注释段断开"攻破。
  三次都是同一个形状：**只要允许存在例外区域，就总能找到一个既在例外内、又在读者眼里的位置**。
  删掉宽容口，这一整类反例连同 rev4 的区域运算一起消失。留下的教训不是"锚要写得更细"，而是
  **可选的宽容口要付审查代价，不需要就别开**。
- AC6（**不变量保护**）: 两棵树中，ANTI-RATIONALIZATION 规则的语义部分必须存活。验证：
  `grep -cF 'test-runner subagent 额外检查覆盖率和测试质量'` == `2`（每棵树 2 处：`:922`、`:1326`）。
  只允许改其中的命令引用，不得删除该规则本身。
- AC7（缺席+解析）: `loop-config.yaml` 的 `layer1.commands` 不含 npm/npx，且真实解析器可读、schema 必需
  键齐全。验证：`ruby -ryaml -e 'd=YAML.safe_load(File.read(ARGV[0])); cs=d["ralph_loop"]["layer1"]["commands"];
  abort("FAIL nil") if cs.nil?; cs.each{|c| abort("FAIL npm/npx") if c["command"] =~ /\bnpm\b|\bnpx\b/;
  %w[name command timeout required].each{|k| abort("FAIL missing #{k}") unless c.key?(k)}};
  puts "AC7 PASS n=#{cs.size}"'`。（空数组合法，见 D3。）
- AC8（缺席+正向+解析）: `config-execution.yaml` 的 Layer 1 描述行不再断言 `build, test, lint, tsc`
  （`grep -c 'Layer 1: Self-Check (build, test, lint, tsc)'` == `0`），且该行改写后引用 §9.1
  （`grep -cF '§9.1' .tad/config-execution.yaml` ≥ 1），且整文件 `ruby -ryaml` 解析 PASS。
- AC9（缺席+正向）: `README.md` 的 Layer 1 小节（`**Layer 1 (Self-Check):**` 至下一个 `**Layer 2`）内
  `grep -c 'build, test, lint, tsc'` == `0` 且 `grep -cF '§9.1'` ≥ 1。
- AC10（缺席+正向）: `docs/RALPH-LOOP.md` 的 Layer 1 节内 `grep -c 'npm run build\|npm test\|npm
  run lint\|npx tsc --noEmit'` == `0` 且同节 `grep -cF '§9.1'` ≥ 1。
  **节截取方法（rev3 补，N5）**：`sed -n '/^## Layer 1: Self-Check$/,/^## Layer 2/p' docs/RALPH-LOOP.md`
  ——实测边界为 `:39`（`## Layer 1: Self-Check`）与 `:63`（`## Layer 2: Expert Review`）。
  上方共用块截取函数是 YAML 形状（`^      <key>:`），对 Markdown 不适用，故本 AC 单列方法。
- AC11（②d，缺席+**两分支实测**）: 两棵树 `blake/SKILL.md` 与
  `.tad/project-knowledge/patterns/shell-portability.md` 中 `grep -c 'import yaml'` == `0`（三个文件
  各自断言）。且把新指导中发布的字面命令原样复制，用**两个 fixture** 各跑一次：合法 YAML → exit 0；
  故意损坏的 YAML → exit ≠ 0。两个分支都对才算 PASS——只测 happy path 等于没测（依据
  `ac-verification.md:133` 的 wrapper 教训）。fixture 建在 `verify.sh` 的临时目录，不落仓库。
- AC12（②e）: 两棵树 `1_5_context_refresh` 块内 `grep -c 'full content'` == `0`；块内步骤号
  `grep -o '^[[:space:]]*[0-9]\{1,\}\.' | tr -d ' ' | LC_ALL=C sort | uniq -d` 输出为空；且正向断言
  有界读取目标存在：`grep -cF '§6'` ≥ 1 **且** `grep -cF '§9'` ≥ 1（两条分别断言，不用 `-E '§6|§9'`
  合并——合并后任一条满足即通过）。
  ⚠️ **rev3 删除了原本的 `grep -cF 'frontmatter'` ≥ 1 半（N4）**：实测该块 `:517` 已含
  `Read handoff YAML frontmatter (...)`，当前值就是 **1**，即该断言**零区分力**——正是 D7 要消灭、
  `ac-verification.md:186` 已记载的那类恒真锚。`§6`/`§9` 两半实测当前为 **0**，确实能区分。
- AC13（结构守卫）: 两棵树 `blake/SKILL.md` 的 YAML frontmatter 仍能被真实解析器解析。验证：截取首个
  `---` 到第二个 `---` 之间内容喂给 `ruby -ryaml -e 'YAML.safe_load($stdin.read); puts "PASS"'`。
  （已确认该文件确有 frontmatter：首行 `---`、次行 `name: blake`。）
- AC14（**范围围栏，已修工具**）: 实际改动（含**新建**）不超出本契约文件清单。
  验证：`git status --porcelain=v1 -uall | sed 's/^...//' | LC_ALL=C sort -u` 得到实现后集合，与
  `scope-baseline.txt`（实现前同一命令的输出）做 `comm -13` 取新增项，再与文件清单做 `comm -23`，
  **越界集合必须为空**。
  **（rev3 新增，N3）第二半——已脏路径的内容不变量**：`comm -13` 只能发现**新增**路径。实测当前
  `porcelain -uall` 有 **870** 行（5 个已跟踪修改 + 865 个未跟踪），其中就包括
  `.tad/evidence/audits/lite-constraint-ledger.md`（显示 ` M`，即 Alex 追加 D2 行后的状态）——而 mandate
  对 Blake 在该文件上是**只读**绑定。已在基线里的路径被改动后，porcelain 行逐字节不变，`comm -13` 看不见，
  **唯一有明确只读绑定的文件恰恰是这个围栏结构上管不到的**。
  故 `scope-baseline.txt` 必须同时记录每个已脏路径的摘要：
  `git status --porcelain=v1 -uall | sed 's/^...//' | while IFS= read -r p; do [ -f "$p" ] && shasum -a 256 "$p"; done`
  AC14 断言：所有**不在文件清单内**的已脏路径，其摘要在实现前后完全一致。
  ⚠️ revision 1 用 `git diff --name-only` 是错的：它只看未暂存的已跟踪修改，实测 = **4**，
  `--cached` = **0**，untracked = **865**；Blake 一旦按 mandate 暂存，左集合即空，AC 无论改了什么都
  PASS，且对新建文件全盲（清单第 9-12 项正是新建）。路径为纯 ASCII（实测 0 行带引号转义），
  `sed 's/^...//'` 安全；⚠️ 不得改用 `awk` 做字符串相等比较（本仓库含中文，见
  `shell-portability.md` 2026-08-05）。目录项（清单第 12 项）按前缀匹配归属，规则写进 `verify.sh`。
- AC15（镜像）: `cmp -s .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` 成功。
- AC16（**提交纪律**）: base SHA **必须在 action #1 `snapshot-scope-baseline` 内用
  `git rev-parse HEAD` 采集并写入 `scope-baseline.txt`**（rev3 修，N7——rev2 只说写进
  `results.txt`，而那是验证时才产生的文件，等于 base 可事后挑选，提交范围就成了自证）；
  tip SHA（提交后 HEAD）写入 `results.txt`。断言：
  `git rev-list base..tip` 非空；`git merge-base --is-ancestor base tip` 成功（无历史改写）；
  `git rev-list --merges base..tip | wc -l` == `0`；`git diff --name-only base..tip` ⊆ 文件清单。
  （revision 1 对 `local_commit` 这一授权后果类零覆盖。）
- AC17（验证脚本卫生）: `verify.sh` 不得**调用**非基线工具。验证：
  `grep -cE '(^|[^-[:alnum:]_])(rg|ripgrep)[[:space:]]' verify.sh` == `0` 且
  `grep -cE 'python3 .*import yaml' verify.sh` == `0`。
  **明确豁免 1**：AC11 需要在 `verify.sh` 中出现字面 `import yaml` 作为 grep 的**搜索模式**，这是允许的
  ——本 AC 禁的是「使用」不是「字符串出现」。（revision 1 的 AC7 与 AC11 互相不可满足，P0-3。）
  **明确豁免 2（rev3 补，N6）**：`ruby` 不在知识引用 #1 所列的基线集（`grep/awk/sed/comm/cmp`）内，
  但 AC7/AC8/AC11/AC13 都要用它。豁免依据是**实测**：本机 `ruby 2.6.10p210 (universal.arm64e-darwin25)`
  是 macOS 系统自带、无需安装，与 `rg`（需另装）性质不同。豁免仅限 `ruby -ryaml` 的 YAML 解析用途。
  写明是为了避免下一张单把 AC17 读成「基线集之外一律禁止」而误伤，或反过来拿它当扩权先例。
  **明确豁免 3（rev4 补，M7）**：`shasum` 同样不在基线集内，但 AC14 的摘要半必须用它。实测
  `/usr/bin/shasum` 系统自带，与 `ruby` 同理，豁免仅限内容摘要用途。
  **可移植性验证（rev3 重写 N1，rev4 补 M2）**：
  (a) `verify.sh` **禁止使用进程替换 `<(...)`**，集合运算一律走 `mktemp` 中间文件。
      **本条须有验证器**（M2）：`grep -cF -e '<(' verify.sh` == `0`。
      ⚠️ 不能靠 (b) 代劳——实测 `printf 'comm -13 <(echo a) <(echo b)' | /bin/bash -n` **exit 0**：
      bash 3.2 接受进程替换，语法门根本不会报它。
  (b) 语法门用**最差解析器**固定：`/bin/bash -n verify.sh` 必须 exit 0（实测 `/bin/bash` 为 3.2.57）；
  (c) GNU-only 选项用显式黑名单 grep：`grep -cE 'cat -A|sed -i |grep -P|readlink -f|date -d '` == `0`。
  ⚠️ **rev2 那条「在 `bash --posix` 与默认 shell 下各跑一次」本身就是同类缺陷**（实测）：
  `/bin/bash --posix`（3.2.57）对 `comm -13 <(...) <(...)` 直接 `syntax error near unexpected token '('`，
  而 PATH 上的 Homebrew `bash` 5.3.3 正常输出。而 AC14/AC5 都需要集合差——所以那条跨壳复跑的结果只取决于
  解析到哪个 `bash`，极可能在 Homebrew 壳上"通过"而 `verify.sh` 对独立复算方依然不可跑。这正是
  `shell-portability.md:132` 存在的理由，被我写进了用来防它的那条 AC 里。
- AC18（**rev3 新增 N8，rev4 补全**）: `shell-portability.md` 中除 `:72` 的命令示例外，该条目其余部分
  逐字不变。验证：对 **`:70`（`- **Context**: …`）、`:71`（`- **Discovery**: …`）、`:73`
  （`- **Grounded in**: …`）、`:74`（`- **failure_mode**: …`）四行**做整行精确匹配，四条都必须命中，
  **且必须写作 `grep -Fxq -e "$LINE"`**。
  （rev3 只钉了 `:73`/`:74`，而 mandate 禁改的是 Context/Discovery/failure_mode/Grounded-in 四项——
  `:70`/`:71` 当时是裸的，rev4 补齐。）
  ⚠️ **空跑实测（不加 `-e` 会假 FAIL）**：这四行都以 `-` 开头。`grep -Fxq "$LINE"` 会把它解析成选项
  → `invalid option` 并 **exit 2**；而 exit 2（用法错）与 exit 1（不匹配）对 `||` 链不可区分，断言
  静默变成恒失败。`shell-portability.md:125` 已逐字记载此坑——我写这条 AC 时没先查它，被空跑抓出来。
  **两种实现都需要 `-e`**（rev4 实测，非 ugrep 独有）：交互 shell 里 `grep` 是
  `~/.claude/shell-snapshots/` 的函数 → **ugrep 7.5.0**；而 `bash verify.sh` 直接跑到的是
  `/usr/bin/grep` = **BSD grep 2.6.0-FreeBSD**，同样 exit 2。所以这条规则在两个运行时都承重，不是
  单主机怪癖。（M3：rev3 写"本机 grep 是 ugrep"只在快照 shell 内成立，此处更正。）
  已核对两实现在本单其余用法上无分歧：`\|` 交替（2 vs 2）、AC12 的 `-o '[0-9]\{1,\}\.'` 管道
  （均得 `5. 6. 7.`）。
  **推广到全脚本**：`verify.sh` 中所有定长匹配一律用 `-e` 传模式，且**必须显式判 exit code**
  （`rc=$?; [ "$rc" -eq 0 ]`），不得用裸 `||` 把 2 当成 1。
  （附带实证：`grep -c` 命中 0 时 exit 1，Alex 自己的一条 `&&` 链就因此被截断过——同一个坑。）
- AC19（**rev5 新增，R2——框图的正向配对，D7 合规**）: 用户可见的 `*develop` 流程图里，Layer 1 面板
  必须**仍然存在**并已改挂新来源。验证：现算框图区域（开框行 `grep -n '┌.*┐'`、闭框行
  `grep -n '└.*┘'`，配对前断言 open 数 == close 数，**且断言严格单调递增
  `open[i] < close[i] < open[i+1]`**——不满足即 FAIL 而非猜测，R3）；在包含 `Layer 1: Self-Check`
  的那个区域内断言 `grep -cF -e 'Layer 1: Self-Check'` == `1` 且 `grep -cF -e '§9.1'` ≥ `1`。两棵树各验。
  ⚠️ **为什么必须有这一条**：AC5 是纯缺席断言，而框图是它唯一的守卫（AC1-AC4 只管 `2_layer1_loop`
  块、AC15 只管镜像同一）。实测 `sed '94,103d' | grep -c <四条>` = **8**，其余 8 处都已被 AC1 与
  `:921-922`/`:1325-1326` 的编辑覆盖——**即把整个 Layer 1 面板从流程图里删掉，18 条 AC 无一失败**。
  而"框图列的就是那四条命令，命令没了就把框删了"是一个**朴素而非刁钻**的读法。这正是 D7 要求的
  「每条删除 AC 必须配一条替代品存在 AC」，rev2-rev4 一直漏了框图这一处，属契约违反自身原则。

### AC 空跑日志（Alex L2.25，revision 2，2026-08-10）

⚠️ **诚实标注（P1-9 更正）**：revision 1 的日志声称"11 条全部跑通、实测非声称"，但其中 3 行实为
「形式已验」未真跑，且 AC10 那行的事实陈述是错的。本表逐行标注实跑 / 未跑。

| AC | 状态 | 当前（未修）实测值 | 修后期望 |
|---|---|---|---|
| AC1 | **实跑** | 两棵树块 = 903-918，npm/npx 各 **4** | 0 |
| AC2/AC3/AC4 | **未跑（正向锚，目标文本尚不存在）** | 当前必为 0 | ≥1 |
| AC5 | **实跑（基线计数）** | 全文命中 **12**（revision 1 误写 8） | 0（rev5 起为无条件全文断言） |
| AC6 | **实跑** | 不变量串每棵树 **2** 处（`:922`/`:1326`） | 仍为 2 |
| AC7 | **实跑** | `commands` 4 条，npm/npx **4** | npm/npx 0 |
| AC8 | **实跑** | 缺席半命中 **1**；YAML 解析 OK | 0 / ≥1 / PASS |
| AC9 | **实跑** | README 小节命中 **1**（缺陷在 `:268`） | 0 / ≥1 |
| AC10 | **实跑** | `docs/RALPH-LOOP.md:45-48` 命令表 **4** 行 | 0 / ≥1 |
| AC11 | **实跑（缺席半）** | blake **1**、shell-portability.md:72 **1** | 0；两分支 fixture 未跑 |
| AC12 | **实跑** | `full content` **1**；重复步骤号 = `5. 6. 7.` | 0 / 无重复 |
| AC13 | **实跑** | frontmatter 存在且解析 PASS | PASS |
| AC14 | **实跑（基线工具已验）** | `porcelain -uall` 可用；⚠️ 已跟踪修改 4、未跟踪 865 | 越界集合空 |
| AC15 | **实跑** | 两棵树当前逐字节相同 | identical |
| AC16 | **未跑（需实现后的 SHA）** | — | 四项断言全 PASS |
| AC17 | **实跑（模式已验）** | `\b` 在本机 grep 上工作正常 | 0 / 0 |

**rev5 增补空跑（2026-08-10，针对 R1-R3 的修法）**

| 项 | 状态 | 实测 |
|---|---|---|
| AC5 简化 | **实跑** | 两棵树全文命中 **12**，修后须为 0；区域运算连同全部反例一并消失 |
| R1 前提核实 | **实跑** | `示例块` 一词在契约中仅出现于 AC5 自身措辞；决策段/不做什么/文件清单**无任何**保留 JS 示例的要求 → 宽容口确系可删 |
| R2 前提核实 | **实跑** | `sed '94,103d' \| grep -c <四条>` = **8**，其余 8 处已被 AC1 与 `:921-922`/`:1325-1326` 覆盖 → 删框图可全绿 |
| AC19 | **实跑，能区分** | 两棵树 open=`94,105` / close=`103,121`，计数相等、单调递增成立；`[94,103]` 内 `Layer 1: Self-Check`=**1**、`§9.1`=**0**（修后须 ≥1） |

**rev4 增补空跑（2026-08-10，针对 M1-M7 的修法）**

| 项 | 状态 | 实测 |
|---|---|---|
| AC5 区域现算 | **实跑，封住 M1 反例** | 框图区间 `[94,103]`/`[105,121]`；AR 注释段 9 段（`[921,927]`、`[1325,1326]` 等）；反例 `95-102` 与 `[94,103]` 相交 → 现在 FAIL |
| AC5 定界规则 | **实跑，且当场抓到朴素配对的错** | `grep -c '┌'`=**2** 但 `grep -c '└'`=**5**（多出的是树形图 `└──` 行）→ 顺序配对产出畸形区间 `[2091,]`；改用两角同现后 open=2/close=2，两棵树一致，树形行 `grep -c '└.*┘'`=0 |
| AC17(a) | **实跑** | `printf 'comm -13 <(echo a) <(echo b)' \| /bin/bash -n` → **exit 0**，证明语法门管不到进程替换，必须单独验证器 |
| AC18 四锚 | **实跑** | `:70`/`:71`/`:73`/`:74` 加 `-e` 后均命中；不加 `-e` 时 ugrep 与 `/usr/bin/grep`（BSD 2.6.0）**都** exit 2 |
| M3 运行时 | **实跑** | 交互 shell 的 `grep` 是快照函数 → ugrep 7.5.0；`bash verify.sh` 走 `/usr/bin/grep` = BSD grep 2.6.0-FreeBSD |

**rev3 增补空跑（2026-08-10，针对 N1-N9 的修法）**

| AC | 状态 | 实测 |
|---|---|---|
| AC5 内容锚 | **实跑** | ASCII 框图定界符实测在 `:94`(`┌`) / `:103`(`└`)，可用于 (b) 条；`ANTI-RATIONALIZATION` 串在 `:921`/`:1325` 可用于 (c) 条 |
| AC10 节截取 | **实跑** | `docs/RALPH-LOOP.md` 边界确认：`:39` `## Layer 1: Self-Check`、`:63` `## Layer 2: Expert Review` |
| AC12 | **实跑（证明删对了）** | 原 `frontmatter` 半当前值 = **1**（恒真，零区分力）；保留的 `§6`=**0**、`§9`=**0**（能区分） |
| AC14 摘要半 | **实跑** | `porcelain -uall` = **870** 行；`lite-constraint-ledger.md` 确显示 ` M`；0 行带引号转义（`sed 's/^...//'` 安全） |
| AC17(b) 语法门 | **实跑** | `/bin/bash` = **3.2.57**；`--posix` 下 `comm -13 <(...)` 直接 `syntax error`，而 PATH 上 Homebrew `bash` **5.3.3** 正常 → rev2 那条跨壳复跑确为伪门 |
| AC18 | **实跑，且当场抓到自身缺陷** | 不加 `-e` → `ugrep: invalid option` + **exit 2**；加 `-e` 后两条锚均命中。本机 `grep` = **ugrep 7.5.0** |

## 知识引用

- `.tad/project-knowledge/patterns/shell-portability.md`（`Acceptance Scripts Written on an
  rg-Equipped Host…` 2026-08-03）— AC 脚本有两个执行环境（实现方与独立复算方），只许用
  grep/awk/sed/comm/cmp 基线工具；导出 AC17。
- `.tad/project-knowledge/patterns/shell-portability.md`（`npx <package> --version` Is Not a Safe
  Optional Tool Probe 2026-06-11）— `npx` 在缺包时会联网解析、提示甚至不终止，正是把
  `npx tsc --noEmit` 当默认自检命令的具体危害。
- `.tad/project-knowledge/patterns/ac-verification.md`（`Text-Anchor ACs Are Blind to Parser-Level
  Regressions…` 2026-08-03）— 纯文本锚看不见结构回归须加真实解析器守卫（→ AC7/AC8/AC13）；且
  「验证 wrapper 重写而非发布的字面命令」等于没验（→ AC11 的两分支 fixture）。
- `.tad/project-knowledge/patterns/ac-verification.md`（`A Count-Based AC Constrains the Total,
  Not the Location` 2026-08-04）— 该条最初被用来支撑「删示例块后计数为 0」而非「总数等于 N」；rev5 删掉
  示例块宽容口后，AC5 直接退化为全文计数 == 0，本条转为支撑「断言值必须是 0 而不是某个基线数」。
- `.tad/project-knowledge/patterns/release-sync.md`（`Identity Early-Exits Blind Downstream Checks`
  2026-08-03）— 内容守卫必须在字节同一性早退之前跑；导出「两棵树各自独立执行」的约定。
- `.tad/project-knowledge/principles.md`（`Deny-List Must Be Applied at EVERY Copy Granularity…`
  2026-06-01）— ⚠️ **限定引用**：该条的论证对象是**单一流水线内的复制/验证粒度**，本单借用的是它的
  类比形态（同一条陈述活在多个文件里），不是它的原始论域；该条 2026-08-06 的 AMENDED 恰好警告过这类
  过度外推。此处只作为「横向扫干净」的提醒使用，不作为授权依据。
  **且 revision 1 恰恰违反了它所引用的这条**——漏了 `docs/RALPH-LOOP.md`、`shell-portability.md:72`
  和正在编辑的那个文件内部的两处载体，全部由独立审查抓出。

## Execution Mandate

mandate_id: `LITE-20260810-1820-LAYER1-AC-DRIVEN-COMPAT` | revision: 2 | authority_mode: contract-mandate
> **为何契约到 revision 4 而 mandate 仍是 2（M6）**：rev3/rev4 只改 AC 的验证方法与措辞，
> mandate 正文（outcome / target_scope / consequence_bindings / blast radius / exclusions / recovery）
> 与 rev2 逐字相同——授权边界没变，故 revision 不递增。递增它反而会制造"边界变过"的假信号。
status: accepted | desired_outcome: TAD 的 Layer 1 自检与两处环境耦合指导不再假设 JS/pyyaml 工具链，改由
handoff §9.1 驱动且优先级明确；改动完成并在本地 main 上以任务范围的追加提交落盘，不对外发布任何内容。
authorized_consequence_classes: [`workspace_write`, `local_commit`]
target_scope: repo root = `/Users/sheldonzhao/01-on progress programs/TAD`；ref = `main`（本地）；
pathspec = 本契约「文件清单」第 1-12 项，及本契约文件自身与其 Completion；无 remote、无 registered
target、无环境、无账户、无凭据、无财务绑定。
consequence_bindings:
- `workspace_write` → 仅上述 pathspec；其余路径一律不得写（默认拒绝）。
  其中 `.tad/evidence/audits/lite-constraint-ledger.md` 仅 Alex 在设计期追加（已完成），Blake 只读。
  `.tad/project-knowledge/patterns/shell-portability.md` 仅允许改 `:72` 的命令示例，不得改该条目的
  Context/Discovery/failure_mode/Grounded-in。
- `local_commit` → 仅本地 `main`，task-scoped append-only，显式 pathspec 暂存（禁止 `git add -A`/`.`），
  完整 base→tip SHA 记账（AC16），逐 commit 范围核验，禁止 amend/rebase/reset/squash/任何历史改写。
  commit 数量是技术基数，由 agent 决定，不是人域字段。
max_blast_radius: 本仓库工作区 + 本地 main 的追加历史。外部触达 = 无（零 remote 写入、零 tag、零发布、
零下游项目、零凭据、零支付）。数据影响 = 上述 12 项路径的文本内容。
explicit_exclusions: push / tag / publish / sync / 任何 registered target / `.claude/settings*.json` /
**`.tad/hooks/`（含 `audit-yolo.sh` 的 npx 执行点——已知缺陷，排队为独立单，本单不碰）** /
`CLAUDE.md` 及其 `@import` 列出的任何路径（含尚不存在的空槽）/ `.tad/memory/` /
`.tad/project-knowledge/` 中除 `patterns/shell-portability.md:72` 之外的任何内容（含 `principles.md`、
任何 SAFETY 条目、`patterns/_index.md`）/ 依赖安装或升级 / 除 `blake` 外的任何 SKILL /
Layer 2 与 Gate 逻辑 / `.tad/schemas/loop-config.schema.json`。
recovery_policy: not_started → 直接重试同一 transaction；partial → 以显式 pathspec `git checkout --`
回滚未提交的**已跟踪**改动，并以显式 pathspec `git clean -f --` 清除本单**新建**的未跟踪文件
（清单第 9-12 项；不得用无 pathspec 的 `git clean`），已提交部分用追加提交修正（不改历史）；
unknown → `BLOCK_NO_MUTATION` 并上报。
expires_when: 本单 Gate 4 人工验收通过并归档，或本契约被 superseded。
acceptance: {decision: accepted, decided_at: 2026-08-10, source: L3 contract decision}

## Execution Transactions

transactions:
- transaction_id: `LITE-20260810-1820-LAYER1-AC-DRIVEN-COMPAT-impl`
  mandate_id: `LITE-20260810-1820-LAYER1-AC-DRIVEN-COMPAT`
  mandate_revision: 2
  lock_path: `.tad/active/handoffs/LITE-20260810-1820-layer1-ac-driven-compat.md.txn-lock`
  state_version: 1
  state: launched
  targets: 本契约「文件清单」第 1-12 项，**及本契约文件自身与其 Completion**（P2-5：与 target_scope 对齐）
  consequence_classes: [`workspace_write`, `local_commit`]
  commit_shas: []
  actions:
  - {action_id: `snapshot-scope-baseline`, state: pending}   # 必须最先执行
  - {action_id: `migrate-layer1-to-ac-driven`, state: pending}
  - {action_id: `fix-anti-rationalization-command-refs`, state: pending}
  - {action_id: `sync-docs-and-readme`, state: pending}
  - {action_id: `replace-pyyaml-guidance`, state: pending}
  - {action_id: `bound-context-refresh-read`, state: pending}
  - {action_id: `regenerate-agents-mirror`, state: pending}
  - {action_id: `build-and-run-ac-verifier`, state: pending}
  - {action_id: `independent-review`, state: pending}
  - {action_id: `scoped-local-commit-after-gate`, state: pending}

## Contract Review (2026-08-10)

Reviewer: 独立上下文 code-reviewer（Agent tool，只读权限） | model= Claude Code / claude-opus-5[1m] / independent contract reviewer
首轮 verdict: **FAIL** — P0=4, P1=9, P2=12；已审 AC 条数: 11
关键发现（revision 1）:
- P0-1 全部内容 AC 均为缺席断言，删除即全绿而 Layer 1 失去命令来源 → revision 2 加 D7 正向锚原则与 AC2/3/4/8/9/10/12 的正向半。
- P0-2 AC14（原 AC10）用 `git diff --name-only`，在本契约授予的提交权限下变空集且对新建全盲 → 改 `git status --porcelain=v1 -uall` + 实现前基线快照。
- P0-3 原 AC7 与 AC11 互相不可满足（前者要求 `verify.sh` 含 `import yaml`，后者禁止）→ AC17 改为禁「调用」并显式豁免 grep 模式。
- P0-4 D2 为自称核心修复却零 AC → 新增 AC3，并在 D2 中具名记录载体（completion report Gate 3 小节）。
- P1-1/1-2/1-3 三个漏掉的活载体（`blake/SKILL.md:921-922,1325-1326`、`docs/RALPH-LOOP.md:45-48`、`shell-portability.md:72`）→ 全部纳入清单，用户 2026-08-10 批准扩范围。
- P1-8 D6 对 D2 判错 → 台账已追加定价行，追加前超期扫描 0 OVERDUE / 0 MALFORMED。
- P2-1/2-2/2-3 三处事实错误（README 行号、`:1758` 幻觉编辑点、322KB→实际 120,072 字节）→ 已更正。
Alex 复核：reviewer 的每一条事实主张均由 Alex 独立命令复验属实，无一条被推翻。
增量复核 (2026-08-10)：**CONDITIONAL** — P0=1, P1=2, P2=6；已审 AC 条数: 17。
覆盖改动：rev1 的 P0-1/P0-3/P0-4 与 P1-1/2/3/5/6/7/8/9 及全部 12 条 P2 判定 CLOSED（reviewer 逐条复现了
证据，包括自行重跑超期扫描得 0/0、自行测得不变量串 2/2、AC5 基线 12）；P0-2 与 P1-4 分别以 N3、N2 结转。
新发现 N1(P0)/N2(P1)/N3(P1)/N4-N9(P2)。
增量复核 2 (2026-08-10)：**CONDITIONAL** — P0=1(M1), P1=0, P2=7；已审 AC 条数: 18。
N1/N3/N4/N5/N6/N7/N9 判 CLOSED（reviewer 自行复现证据）；N2 判**未关且回退**——rev3 的内容锚被
**可运行反例**攻破；N8 部分关闭（漏钉 `:70`/`:71`）。新发现 M1(P0) + M2-M7(P2)。
增量复核 3 (2026-08-10)：**CONDITIONAL** — **P0=0**, P1=2(R1/R2), P2=1(R3)；已审 AC 条数: 18。
M1-M7 与 N8 残留全部 CLOSED。R1：示例块宽容口是无人要求的可选affordance，已连续三轮被构造出可过反例
（rev4 的两个新反例：框图**间隙行** `:104`；在 `:1325`/`:1326` 间插空行即可让 AR 注释段断开）。
R2：删掉整个 Layer 1 框图可让 18 条 AC 全绿，且这是朴素读法——契约违反了自己的 D7。
增量复核 4 (2026-08-10)：**PASS** — P0=0, P1=0, P2=3；已审 AC 条数: 19。
R1/R2/R3 全部 CLOSED。reviewer 端到端验证 AC19 的失败闭合性：删掉 `94-103` 后无区域含锚串，
`grep -cF -e 'Layer 1: Self-Check'` = 0，断言写成 `== 1` 而非 `≥ 1` 正是空集不空过的原因。
残留 3 条 P2 均为指向已删机制的陈旧措辞，已在 rev5 定稿中清理（知识引用第 4 条、F2、空跑表 AC5 行）。

**最终 verdict: PASS**
累计（五轮）: P0=6 全部 fixed, P1=13, P2=29; 已审 AC 条数: 19
关键沿革：AC5 三次重写均被**可运行反例**攻破，最终以删除可选宽容口收敛；AC19 补上 D7 要求而 rev2-rev4
一直漏掉的框图正向配对。

## 风险与注意

**caller/consumer 检查（已做，非声称）**：
- `.tad/ralph-config/loop-config.yaml` 是活载体：`blake/SKILL.md:157` 明写它是「Loop 配置」，
  `tad-status/SKILL.md:80` 检查它存在。
- `.tad/config-execution.yaml` 由 Blake 激活时 STEP 3 强制加载（Blake 专属模块）。
- `docs/RALPH-LOOP.md` 由 `README.md:5`/`:466`、`docs/README.md:12`、`docs/CODEX-USER-GUIDE.md:481`
  链接。
- `loop-config.schema.json` 实测 `commands` 无 `minItems`，空数组合法。

**F1｜镜像漂移**：`blake/SKILL.md` 实测 **120,072 字节 / 2,146 行**（revision 1 写的「322KB」是把 Epic
里 full 主 skill 的**合计**数字误当成单文件，已更正），两棵树、6 个编辑点。AC1-AC6/AC11-AC13 均要求两棵
树各自独立断言，AC15 再查字节同一。

**F2｜自指风险（P1-7 加强）**：本单改的是 Blake 自己的执行协议，执行者正是 Blake。真正的危险不是"读到
哪版协议"，而是——**Blake 要在 AC5 的删除压力下编辑 `:921-922`/`:1325-1326`，而那两处正是阻止 Blake
跳过 Layer 2 reviewer 的 ANTI-RATIONALIZATION 守卫**。即"被约束者在一条奖励让文本消失的 AC 下编辑自己
的约束"。缓解（rev5 定稿）：AC5 是**无条件**的全文断言——不存在"示例块"这种可申请的例外，所以"把自己的
约束包装成示例"这条路径整个不存在；AC6 再用不变量串把规则语义钉死（只许改命令引用，实测两棵树各 2 处）。
沿革：rev2 行区间 → rev3 内容锚 → rev4 区域不相交，三次都被可运行反例攻破，rev5 删掉宽容口本身。

**F3｜具名 follow-up（不是"自然发生"）**：
1. D2 新行为的真实行为验证必须在**下一张非 JS 项目的单**上做——本单只做文本断言。
2. `.tad/hooks/lib/audit-yolo.sh:278,288` 实际执行 `npx tsc --noEmit` / `npm test`，是同一缺陷的最严重
   实例（会真的触发 npx 联网解析/挂起），本单因 hooks 属高后果面而排除。
3. `.tad/gates/quality-gate-checklist.md:230-232` 等三处静态残留。
以上三项由 Alex 在本单验收时写入
`.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md` 的 Context for Next Phase，
不依赖记忆。
⚠️ **rev3 自查更正（Alex 自己发现，非 reviewer 提出）**：rev2 写的是"写入 `NEXT.md`"——**alex-lite 没有
写 `NEXT.md` 的权限**。本 skill 的 Forbidden 把可写文件封闭为四项（`lite-constraint-ledger.md`、
`.tad/project-knowledge/`、`.tad/active/epics/`、`.tad/active/session-state.md`），并明写"四项之外一律
禁止，**不得类推扩展**（无协议载体即不授予）"。上一轮我以 full `/alex` 身份改过 `NEXT.md`（那边有
`next_md_rules`），切到 lite 后把上一轮的手感当成了本通道的权限——正是那条 Forbidden 要防的类推扩展。
改用 Epic 文件：它在允许清单内，且这三项本就是 Phase 3c 相邻工作，落在 Epic 比落在 NEXT.md 更合位置。

**F4｜知识层自相矛盾**：`shell-portability.md:72` 教 `import yaml`，`ac-verification.md:108` 禁
`import yaml`。本单修前者。若 reviewer 认为改知识文件的命令示例需要更强证据，按 P1 提出。

**F5｜工作区噪音**：实测已跟踪修改 4 个、未跟踪 865 个，均为历史遗留。AC14 靠实现前基线快照做差，
提交时用显式 pathspec，禁止 `git add -A`。

## Lite Progress

- 2026-08-10 | Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/layer1-ac-driven-compat/scope-baseline.txt | Next Action=实现 8 个修改载体 + 4 个新建证据文件
- 2026-08-10 | Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/layer1-ac-driven-compat/scope-baseline.txt | Next Action=AC 自验
- 2026-08-10 | Phase=ac | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/layer1-ac-driven-compat/results.txt | Next Action=L3 独立审查（AC19 IFS 修复 1 轮，verify.sh 2 处编辑）
- 2026-08-10 | Phase=review | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/layer1-ac-driven-compat/code-reviewer.md | Next Action=Technical Gate（reviewer 首轮 CONDITIONAL P0-1 → 修复 → 增量复核 PASS）
- 2026-08-10 | Phase=technical-gate | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/layer1-ac-driven-compat/results.txt | Next Action=Completion + scoped-local-commit（AC16 已 PASS，提交 9cfea17）

## Completion (2026-08-10)

**Commit**: 9cfea173de38910e48dfde7269ead00a1183013d（提交 1：实现 + 证据载体；Completion 与最终 results.txt 随提交 2 落盘）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=native

- 上下文刷新：shell-portability.md（rg 主机陷阱、npx 探测、awk CJK 陷阱、comm 全局排序、grep -e 教训）、ac-verification.md（Text-Anchor/Count-Based/Design-Agent 条目）、release-sync.md（Identity Early-Exits）、principles.md（Deny-List AMENDED）| 关键约束：AC5 全文无条件断言 + AC6 不变量串存活；两棵树各自独立执行不得早退；AC14 基线差分围栏 | 成功条件：19 条 AC 全绿 + 独立 reviewer PASS + Technical Gate PASS
- 改动文件：.claude/skills/blake/SKILL.md、.agents/skills/blake/SKILL.md、.tad/config-execution.yaml、.tad/ralph-config/loop-config.yaml、README.md、docs/RALPH-LOOP.md、.tad/project-knowledge/patterns/shell-portability.md、.tad/evidence/audits/lite-constraint-ledger.md（Alex 设计期行，随提交入库）、.tad/evidence/acceptance-tests/layer1-ac-driven-compat/{verify.sh,results.txt,scope-baseline.txt}、.tad/evidence/reviews/blake/layer1-ac-driven-compat/code-reviewer.md、本契约文件自身
- Authority: mandate_id=LITE-20260810-1820-LAYER1-AC-DRIVEN-COMPAT revision=2; authorized consequence/target bindings=workspace_write→清单 pathspec（ledger 只读、shell-portability 仅 :72）；local_commit→本地 main append-only 显式 pathspec，无 remote/无发布
- Transactions: LITE-20260810-1820-LAYER1-AC-DRIVEN-COMPAT-impl state_version 0→1 launched；10 actions 全部 completed：snapshot-scope-baseline（ae3485f 基线 1747 行）→ migrate-layer1-to-ac-driven → fix-anti-rationalization-command-refs → sync-docs-and-readme → replace-pyyaml-guidance → bound-context-refresh-read → regenerate-agents-mirror → build-and-run-ac-verifier → independent-review（CONDITIONAL→PASS）→ scoped-local-commit-after-gate（9cfea17）；lock 已清（owner token 归属本会话）
- Runtime decisions: avoidable_runtime_prompt_count=0; boundary_change_prompt_count=0; runtime_prompt_reasons=[]
- AC 结果：AC1-AC19 全部 ✅（最终 30 PASS / 0 FAIL / 0 PENDING）。原始输出与逐条断言见 .tad/evidence/acceptance-tests/layer1-ac-driven-compat/results.txt（verify.sh 全量输出 + AC17 五项 + P0 修复记录）；基线 scope-baseline.txt 1747 行
- Reviewer: PASS（首轮 CONDITIONAL P0=1(fixed), P1=0）| model=deepseek-v4-flash（code-reviewer route，只读）——摘录关键发现原文：P0-1「`grep -F "  path1$"` 在 /usr/bin/grep（BSD 2.6.0）与 ugrep 7.5.0 上均 rc=1 无匹配——$ 在 -F 固定串模式下是字面量不是行尾锚。故 bsha 恒空 → 摘要半无条件跳过，'dirty digests unchanged' 从未被实际评估」（执行实证）→ 修复（awk index 行尾后缀 + traces 排除）→ 增量复核三场景突变探针（变异可检测 / 前缀重叠无串扰 / traces 无假 FAIL）确认 CLOSED。P2-1/P2-2 随修复闭合；P2-3 前提不成立；P2-4/P2-5 建议性留后续
- Technical Gate: GATE PASS（逐项确认：①AC/evidence 每条有原始输出与路径 ②reviewer verdict PASS P0=0 ③friction 无 BLOCKED（ruby/bash 3.2.57/BSD grep 均系统自带）④scope/risk 双半围栏通过 + caller/consumer 检查在 handoff 风险段 ⑤Knowledge Assessment 三态已标 journal captured）
- Knowledge Assessment: journal captured（2 条候选蒸馏：grep -F $ 字面量非锚；框架 traces 遥测使摘要型围栏 AC 按原文不可满足）——待验收归档后追加 lite-discoveries.md（内容已保存 /tmp/journal-pending.txt）
- 意外发现：AC14 摘要半对框架遥测路径按原文不可满足（reviewer P0-1 附带发现，正确实现也会假 FAIL）
- follow-up：
  - P2-4（文档措辞）→ docs/RALPH-LOOP.md:41-55 命令表以「§9.1 声明的技术检查行 1/2/3/N」占位；不阻塞（AC10 合规，用户文档略显机械）；建议 owner=后续文档类单
  - P2-5（死条件）→ .claude/skills/blake/SKILL.md 1_5_context_refresh 步骤 10「If handoff has no Project Knowledge section」在有界读取流程下不再被读取；不阻塞（AC12 合规）；建议 owner=后续协议微调单
  - F3 具名 follow-up（契约风险段）：D2 真实行为验证在下一张非 JS 项目单；audit-yolo.sh:278,288 的 npx 执行点排队独立单；三处静态残留——由 Alex 验收时写入 EPIC 文件

## Reflexion

- 修复 1（L2 自验）：失败=AC19 两树 FAIL（sed 收到 "94 102,p"）；假设=IFS= 前缀 read 分词正常；动作=改显式 `IFS=' '`；结果=PASS。
- 修复 2（L3）：失败=reviewer P0-1：AC14 摘要半恒真死代码；假设=grep -F 的 $ 是行尾锚（错——字面量）；动作=awk index()+substr 行尾后缀 + traces 排除；结果=三场景突变探针证明变异可检测，增量复核 CLOSED。
- 修复 3（Gate 后）：失败=journal 追加使 AC14 第二半误报（lite-discoveries.md 清单外变 M）；假设=journal 是 skill 授权产物可直接留在工作区；动作=保存内容 → git checkout 回滚 → 验收归档后追加；结果=AC14 严格 PASS，journal 内容不丢失。
