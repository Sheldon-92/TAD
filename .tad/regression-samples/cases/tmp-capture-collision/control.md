对照捕获冻结件（替换版）——本件正文为 run `20261006-first-valid-baseline` 的洁净对照捕获，来源：`.tad/evidence/regression-runs/20261006-first-valid-baseline/controls/tmp-capture-collision.md`（逐字移入）。替换授权：PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p3-three-escalations-ruling.md` 第一节。被替代件系首跑 fork 污染捕获，存档于 `.tad/evidence/regression-runs/20261006-first-run/`（不动）。


有问题。两席共用固定路径 `/tmp/align-full.log`，会撞车：

- `>` 在打开时即截断，后启动的一席会把先一席的文件清空/覆盖；两进程的 fd 同时写同一 inode，输出还会交错，得到的是混合/残缺日志。
- 基于这种日志拆出的 check/apply 段计数与结论不可信——而报告恰恰引用这些计数。
- 另外两席在同一台 VM 上并发跑 `--full` 应用段，本身也可能互相干扰（若脚本会改系统状态）。

修复：每席用唯一、原子创建的捕获文件（可加席位标识便于追溯）。

```bash
log="$(mktemp -t "align-full.${SEAT_ID:-$$}.XXXXXX.log")"
set -C   # noclobber，防止误覆盖已有文件
bash align-install.sh --full >"$log" 2>&1; rc=$?
set +C
echo "seat=${SEAT_ID:-$$} rc=$rc log=$log"
```

若必须并发跑应用段，再加互斥：`flock /tmp/align-install.lock bash align-install.sh --full >"$log" 2>&1`，让 apply 串行、只捕获各自输出。
