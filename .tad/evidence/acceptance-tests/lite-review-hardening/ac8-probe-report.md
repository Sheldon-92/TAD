model=codex/gpt-5/native

AC8 探针已完成，结论：PASS。

Finding: toy 缺陷（执行实证）：注释中的 `READY` 只能欺骗 grep，真实脚本执行失败：

- toy contract 要求：exit 0 且输出 `READY`
- 实际：exit 1，输出 `NOT_READY`
- 最小 scratch 修复为 `READY`/exit 0 后通过，确认缺陷真实存在
- 本次没有 P0/P1/P2 产品缺陷。

## 执行证据

```text
$ git status --short
<无输出>
```

```text
$ git log -1 --oneline
c7b19bf ac8: add toy execution contract
```

```text
$ grep -c 'READY' toy-defect.sh
3
```

```text
$ bash toy-defect.sh
NOT_READY
```

退出码：`1`。

玩具命令原始输出明确包含：`NOT_READY`。
