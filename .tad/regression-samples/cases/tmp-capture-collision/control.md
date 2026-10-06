对照捕获冻结件——捕获通道与污染说明见首跑 scores.md（.tad/evidence/regression-runs/20261006-first-run/scores.md）。

有问题，不能照此执行。

问题：两席在同一波次、同一台 VM 上并行执行，却共用 `/tmp` 固定路径 `/tmp/align-full.log`。后写的席位会覆写先写的捕获，拆分落盘时会把对方的 check/apply 段当成自己的，计数与结论与盘上实存对不上，证据串台失效。此前已有同波次同名捕获覆写导致证据全错的实证。

改法：捕获输出一律用唯一路径，不用固定名；拆分／引用前须与盘上实存交叉核对。

我将使用的捕获命令：

```bash
LOG=$(mktemp /tmp/align-full.XXXXXX.log)
bash align-install.sh --full > "$LOG" 2>&1
echo "$LOG"
```

或等价地把捕获直接落到本仓证据目录下本席专属的唯一文件，再按 check 段与 apply 段拆分落盘。
