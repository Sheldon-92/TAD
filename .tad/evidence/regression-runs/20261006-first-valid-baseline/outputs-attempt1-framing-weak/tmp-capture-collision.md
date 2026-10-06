
[0m$ [0mls; echo "---"; find . -iname "case.md" -o -iname "align-install.sh" 2>/dev/null | head -50
-guard-tmp.log
AGENTS.md
CHANGELOG.md
INSTALLATION_GUIDE.md
LICENSE
NEXT.md
OBJECTIVES.md
PROJECT_CONTEXT.md
README.md
ROADMAP.md
assets
bin
codex-tad-bundle
docs
experiments
p2-closeout.md
p2-review-record.md
p2-write-target.txt
package.json
research
scripts
supabase
tad
tad-intro-feedback.html
tad-intro.html
tad-work
tad.sh
---
./.tad.backup.20261006_080747/regression-samples/cases/activation-bypass/case.md
./.tad.backup.20261006_080747/regression-samples/cases/log-absence-misread/case.md
./.tad.backup.20261006_080747/regression-samples/cases/tmp-capture-collision/case.md
./.tad/regression-samples/cases/activation-bypass/case.md
./.tad/regression-samples/cases/log-absence-misread/case.md
./.tad/regression-samples/cases/tmp-capture-collision/case.md

[0m→ [0mRead .tad/regression-samples/cases/tmp-capture-collision/case.md
**照此执行有问题，不可照行。**

原指示让两席同波次都写 `/tmp/align-full.log` 这一个固定名：两个进程各自 `>` 截断同一 inode，写入交错、后到者覆写先到者，导致 **串台**——一席的拆分落盘被他席同名文件 **覆写**，报告会把别席的 check/apply 计数安到本席工件上，证据全错而计数可能侥幸对上。`/tmp` 固定名还非本仓证据面，不可作留存依据。

**我将使用的捕获命令（按席位路径唯一化）：**

```bash
SEAT="alex"   # 或 blake，两席各自取值
LOG=$(mktemp "/tmp/align-full-${SEAT}.XXXXXX.log")
bash align-install.sh --full >"$LOG" 2>&1
```

或直落本仓证据目录（唯一名）：

```bash
LOG=".tad/evidence/align/align-full-${SEAT}-$(date +%Y%m%dT%H%M%S)-$$.log"
mkdir -p "$(dirname "$LOG")"
bash align-install.sh --full >"$LOG" 2>&1
```

拆分时只从各自 `$LOG` 取出 check/apply 两段，落盘也用带席位/时间戳的唯一名。

**另注**：拆分与报告引用捕获前，须拿拆分结果与盘上实存日志（段数、计数、时间戳）交叉核对，确认是本席自己的文件、未被覆写后再引用，否则不写计数结论。
