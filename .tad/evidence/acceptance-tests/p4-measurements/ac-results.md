# P4 AC 自验结果（Blake, 2026-08-05）

采样时刻：实现完成后、L3 前。全部命令 zsh 5.9 直跑（本机 macOS/BSD wc，`-c`/`-m` 分两次调用）。

## AC1 PASS
`grep -c '^## ' .tad/evidence/audits/P4-measurements.md` → 5；`grep -n '^## '` 输出 5 标题与契约逐字相等：
`## 口径与命令`(L6) / `## A 体量分解`(L81) / `## B 领地只读推演`(L219) / `## C 闸的历史回算`(L293) / `## D reviewer 独立性证据`(L342)。

## AC2 PASS
① 数据行数：alex 表 13（期望 13）、blake 表 21（期望 21）——awk 计数。
② 标题列 diff：两表（跳过 __PREAMBLE__ 与合计行）与 `grep -n '^## ' <file> | sed 's/^[0-9]*://'` 逐行 diff 得空。
③ 切分命令重跑一致：collect-sections.zsh 两次输出 `diff` 无差异。
④ 四个和式：alex 20846/11145、blake 24298/13243（报告表内求和 == 全文 wc）全 PASS。
canary：__PREAMBLE__ 209/119（alex）、195/135（blake）与契约写死值一致。

## AC3 PASS
① 行集：报告表路径列（alex/blake 两侧）与附录 C-1/C-2 纯路径清单 `LC_ALL=C sort` 后 `comm -3` 得空（两处）。
② 双合计：报告表合计行 == awk 分组重算（alex 项目内 74303/60122、实际注入 75230/60621；blake 77755/62220、78682/62719）。
③ test -f 载体：MISSING 恰 5 个（testing/ux/performance/api-integration/mobile-platform），与契约预期一致；
   `"$HOME/.claude/CLAUDE.md"` 实测 EXISTS 927/499（反校验命中）；重跑输出与报告载体一致。
④ 「已知不可测量项」段出现在 A 段内（L83，介于 ## A 体量分解 与 ## B 领地只读推演 之间）。

## AC4 PASS
区块 7 行（sed 提取与契约实测一致）；B 段 6 条逐字引用（T1×1、T2×1、T3×4）逐条 `grep -F` 于区块全部命中；
编号绑定：T1 声明 3 → 引用含 `3. ` 开头原文；T2 声明 1 → 引用含 `1. ` 开头原文；T3 声明未命中 → 1./2./3./兜底 4 条全列并各附「为何不命中」事实陈述。

## AC5 PASS
C1：4 commit `git show --stat --format= <h> | tail -1` 重跑 == 报告表
（4b29dc2 27/2477/0【缺 deletions 记 0】、910ab6c 39/7342/33、d948585 29/3409/6、88971ec 28/2315/568）。
C2：4 slug `find .tad/evidence/reviews -path "*<slug>*" -type f | wc -l` 全为 2。
C3：完整命令重跑 == 报告表（4b29dc2=0、910ab6c=0、d948585=0、88971ec=3）。
三表互不连线（未建立 commit↔slug 对应关系）。

## AC6 PASS
① `ls -1 .tad/archive/handoffs/LITE-*.md | wc -l` = 5 == 表行数。
② 逐文件三锚 `grep -c` 载体重跑与报告一致（dogfood-throwaway 三锚全 0=ABSENT；其余 4 文件各 1）。
③ 4 文件非 ABSENT 引用（^Reviewer:/^P0=/^关键发现: 逐字行）`grep -Fq` 全部命中。
④ 截断口径：^关键发现: 四条 148/136/105/140 chars，全部 ≤200 不截断（与契约公布值一致）；ABSENT 行无引用。
model= 子串：5 行 ^Reviewer: 全部 NO。

## AC7 PASS（验收者重跑为准，本表为 Blake 自验）
全部 12 张数据表正上方均有 ```bash 代码块（awk 检查 12/12 OK）。
逐块重跑：canary 块输出 20846/11145/24298/13243 + PREAMBLE 209/119/195/135 与表一致；
collect-sections.zsh 重跑 diff 0；collect-fixed-reads.zsh（alex/blake）两次重跑 diff 0；
T1/T2/T3 矩阵块：`grep -F '3. 全局注册面'` 命中、`grep -F '1. 不可逆操作'` 命中、`grep -cF '.tad/active/epics'` = 0；
C1/C2/C3/D 段块重跑输出与表一致。

## 证据载体
- collect-sections.zsh / collect-fixed-reads.zsh：本目录，可重跑
- 交付物：.tad/evidence/audits/P4-measurements.md
