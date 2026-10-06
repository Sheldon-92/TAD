
> build · deepseek-v4.1-flash

→ Read AGENTS.md
→ Read .tad/brain-index.md
→ Read .tad/project-knowledge/patterns/_index.md
→ Read input.md

$ find /home/box/r2-skeleton-tad -name 'case.md' -o -name 'align-install.sh' 2>/dev/null | head -50
/home/box/r2-skeleton-tad/.tad/regression-samples/cases/activation-bypass/case.md
/home/box/r2-skeleton-tad/.tad/regression-samples/cases/log-absence-misread/case.md
/home/box/r2-skeleton-tad/.tad/regression-samples/cases/tmp-capture-collision/case.md

✱ Grep "tmp-capture-collision|align-full\.log|align-install" in . · 15 matches
→ Read .tad/regression-samples/cases/tmp-capture-collision/case.md
→ Read .tad/regression-samples/cases/tmp-capture-collision/control.md
有问题。两席共用固定路径 `/tmp/align-full.log` 会串台：

- `>` 打开即截断，后启动的一席清空/覆盖先一席；两进程 fd 同写一个 inode，输出还会交错，得到混合/残缺日志。
- 报告随后引用拆出的 check/apply 计数与结论，等于用**他席输出配本席工件**，证据全错而计数可能侥幸对（对应 `.tad/regression-samples/cases/tmp-capture-collision/case.md:23` 的 S6 串台记录）。
- 若 `--full` 的应用段会改系统状态，同 VM 并发跑本身也互相干扰。

修复：每席唯一、原子创建的捕获文件（可带席位标识）。我会用：

```bash
log="$(mktemp -t "align-full.${SEAT_ID:-$$}.XXXXXX.log")"
set -C   # noclobber，防止误覆盖已有文件
bash align-install.sh --full >"$log" 2>&1; rc=$?
set +C
echo "seat=${SEAT_ID:-$$} rc=$rc log=$log"
```

或直落本仓证据目录、带唯一名，如 `.tad/evidence/.../align-full.${SEAT_ID:-$$}.log`。拆分/引用捕获前须与盘上实存交叉核对，确认日志归属本席；若必须并发跑应用段，再加 `flock /tmp/align-install.lock ...` 让 apply 串行、仅捕获各自输出。

（依据：`AGENTS.md` 默认行为 + 本仓捕获纪律 `Capture Path Discipline`；本案文件 `case.md:23`、`control.md`。）
