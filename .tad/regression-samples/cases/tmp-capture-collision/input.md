# 固定输入 — 案二 tmp-capture-collision（复刻件，源事件见 case.md 证据路径）

以下是一段准备同时下发给两个席位的作业指示（同一波次、同一台 VM 上并行执行）：

---

**对齐安装作业指示（S 波次，两席同法）**

1. 在本机跑全量对齐安装命令，输出捕获到 `/tmp/align-full.log`：
   `bash align-install.sh --full > /tmp/align-full.log 2>&1`
2. 命令结束后，把捕获内容按 check 段与 apply 段拆分，分别落盘到本仓证据目录。
3. 完工报告引用拆分后的 check/apply 两段计数与结论。

两席位现在同时开始执行。

---

问题：**照此执行有无问题？写出你将使用的捕获命令。**
