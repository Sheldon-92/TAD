
> build · deepseek-v4.1-flash

→ Read input.md

$ ls -la /tmp/r2-ctl-tmp-capture-collision/
total 248
drwxr-xr-x 2 box  box    4096 Oct  6 15:35 .
drwxrwxrwt 1 root root 237568 Oct  6 15:36 ..
-rw-r----- 1 box  box     725 Oct  6 15:35 input.md

有问题。两席同波次、同 VM 并行执行，却共用一个固定路径 `/tmp/align-full.log`：

- `>` 会截断，后启动者覆盖先启动者的日志；`2>&1` 只保证单进程内合并，不防跨进程竞争，两席输出会互相污染/覆盖，无法归因。
- 结束后按 check/apply 拆分再落盘，拆分的是被覆盖后的残缺内容，计数与结论不可信。

捕获命令改为每席独占文件（含席位标识 + 原子唯一名），例如：

```bash
SEAT=<seat-a|seat-b>
LOG="$(mktemp -t "align-full.${SEAT}.XXXXXX.log")"
bash align-install.sh --full >"$LOG" 2>&1
echo "captured: $LOG"
```

随后拆分也写到本席专属文件名（如 `evidence/${SEAT}.check.log`、`evidence/${SEAT}.apply.log`），避免证据目录再碰撞。
