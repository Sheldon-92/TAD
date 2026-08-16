# Journal — trace-relative-path (2026-08-16)

## Q1 发现(值得追溯)

### 1. `git rev-parse --show-toplevel` 按 cwd 求值,不是按文件路径求值
- 行为:跨仓库写入(cwd=TAD、文件在下游项目)时,trace 记的是**下游仓库的绝对路径**。
  这是刻意不修的范围决定(AC12 钉死),概念上"仓库相对"在跨仓库场景本身歧义(相对哪个仓库?)。
  已另开 NEXT。
- 延伸:`*sync` 往 ~14 个下游项目写文件,路径全在 `/Users/<user>/` 下 —— 这次修复没有堵住
  那条路径,只是堵住了**本仓库内**写入。隐私泄漏面缩小但未归零。

### 2. macOS `mktemp -d` 给 `/var/...`,`pwd -P` 给 `/private/var/...` —— symlink 分歧
- 判别力陷阱:`mktemp -d` 返回的路径被 git 识别的 top-level 是 `/private/var/...`,
  而我用 `mktemp -d` 原值做沙箱 root 时,正确补丁的 AC2 会**错误地红**。
  修法:mk_sandbox 里 `pwd -P` 物理解析 + 前置自检断言一致,否则整个套件无意义。
- 已有的 AC14 正是利用这个分歧:喂 `/var/...`(symlink 形式)路径 → 前缀不匹配 → 保持绝对(钉死降级)。

### 3. bash `case` 模式里 `'*'` 会被单引号变成字面星号 —— AC 脚本的两处 bug
- `case "$LINE" in *'"size_bytes":'"$BYTES"'*' )` —— 末段 `'*'` 是**字面星号**不是 glob,
  模式永不可能匹配,AC 假 FAIL。换成 `grep -Fq "\"size_bytes\":$BYTES"` 后通过。
- 教训:AC 脚本里断言 JSON 数字字段,用 `grep -F` 固定串,别用 bash case glob;
  case 模式中所有 glob 字符必须不带引号。

### 4. `$()` 命令替换只捕获 stdout —— 想从子 shell 传回诊断值用 stdout 不用 stderr
- AC5 想把子 shell 里的 `HAS_JQ` 值传出来:最初 `echo ... >&2`,结果值**显示在终端**但
  进不了 `$()` 捕获的变量 → 守卫拿不到值。改成 `printf ...`(进 stdout,和 jsonl 行混在一起)
  再 grep 提取。
- 终端上其实看到了 `HAS_JQ_AT_CALL=false`(stderr 穿透),但 LINE 变量里没有 —— 视觉误导。

### 5. AC1 负控 vs 全量重跑:负控是"改前必红",改后重跑当然反绿
- 全量重跑时 AC1 显示 rc=1,一度像回归。实际上负控语义就是:改前红(已存档 baseline-red.txt)+
  改后反绿逆验证 = 修复生效的证据。负控脚本不能进"改后全绿"的循环断言集合。

## Q2 可复用工作模式?
- 候选:AC 套件 + 破坏性测试(把实现"改错位置"验证判别力)的组合。
  已在 handoff rev2 里由 test-runner 实跑验证过(未打补丁 4 FAIL/5 PASS → 打补丁 9 PASS)。
  本次我又实测了 AC3 判别力(cwd=子目录配置)。该模式已在 `patterns/ac-verification.md`
  §7.3 四问中覆盖,不另开 skillify 候选。

## Q3 workflow 模式?
- 否。单任务顺序执行,无多 agent 编排信号。

## 执行事实(供 Alex Gate 4 复核)
- 改动:+9 行(注释 1 + 代码 8),0 deletions,全部落在 record_trace() 内(L72..199)。
- AC:2/3/4/5/6/7/8/10/11/12/13/14/15 PASS;AC1 负控改前红(存档)+ 改后反绿;AC9 等效验证。
- 未提交改动:common.sh(+9)、fixture 目录(AC-*.sh 等)、ralph state、session-state、traces jsonl(已截回 5 行)。
## test-runner 审查发现的 P0/P1 修复记录(2026-08-16 第二轮)

- **F1 (P0, stderr 重定向失效)**:`LINE=$( … ) 2>"$ERR"` 中 `2>` 在 `$(…)` 外侧 → 内部 stderr
  直达终端,err.log 恒空 → 4 条"stderr 为空"断言全死 + AC15 对完全损坏实现误绿。
  修复:`LINE=$( ( … ) 2>"$ERR" )`(重定向作用于显式子 shell 整体),AC15 补 schema 判定
  (LINE 必须含 ts/type 键 → broken 的 echo "TOTALLY BROKEN" 无法冒充)。
  判别力复测:broken lib → AC2/AC15 均红。
- **F2 (P1, AC9 cwd 脆弱)**:AC9 族用相对 JSONL 且不 cd 仓库根 → 错 cwd 下 record 失败、
  BEFORE 空 → 比较报错后静默 PASS + 写嵌套 trace 污染仓库。
  修复:`cd "$ROOT"` + is_num 数字守卫;错误 cwd 实测不再假绿。
- **F3 (P1, 范围双盲区)**:AC10 带路径过滤 → "1 file"恒真;AC11 只查 ?? → 漏 M tracked 修改。
  修复:AC10 全量 numstat 按路径列排除环境 jsonl;AC11 按状态码分流(?? ⊆ 白名单 / M ⊆
  {common.sh}+env jsonl)。模拟注入 trace-writer.sh 会被抓。
- **F4 (P1, baseline 污染)**:AC1 未加守卫时被 patch 后重跑覆盖成相对路径;已从 git 基线
  重建真红基线 + AC1 写保护(patched 时 NOTE 不覆盖)。

教训:AC 脚本自身的 verifier 也要过"损坏即红"测试 —— 断言有效性的验证本身需要判别力测试。
