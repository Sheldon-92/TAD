# COMPLETION — NotebookLM 整层废弃（2.44.6）

- 日期：2026-09-15；链路：Alex 设计 → Blake 落地 → Gate 3 双审 → Alex Gate 4 → 发版
- 用户决策：TAD 不再使用 NotebookLM（整层废弃，不升级、不删除）；试点"升级 notebooklm-py 到 0.8.2"结论作废

## 交付
- 设计：`.tad/active/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md`（43 路径，14 条 AC）
- 落地：`43b9ade0` docs(deprecation): retire NotebookLM research layer（43 路径，零删除/零改名）
- 返工：`336ba604` docs(deprecation): close Gate4 C2 live-routing residuals（STEP 3.8 / CLAUDE.md:44 / brain-index:36）
- 证据：`.tad/evidence/reviews/2026-09-15-gate{3-code,3-safety,4-acceptance}-notebooklm-deprecation.md`

## Gate 结论
- Gate 3 SAFETY：PASS；Gate 3 CODE：CONDITIONAL PASS（条件=发版步逐字落盘 §6.2）
- Gate 4：CONDITIONAL PASS → C1（发版步）+ C2（336ba604 已闭合）+ C3（本批证据）后转 PASS

## 要点
- fallback 链：`local_wiki → notebooklm_research → claude_websearch` 改为 `local_wiki → claude_websearch`（`fallback_chains` 上移顶层）
- 工具 6 件套 + 指南/依赖登记：原地标 DEPRECATED，文件保留
- 休眠钩子 `notebook-dormant-sync` 从 `.claude/settings.json` / `.codex/hooks.json` / `tad.sh` 三处注销，脚本转 inert
- CHANGELOG `[2.44.6]` 口径：退役不是升级、保留不是删除、无能力回退；supersedes v2.44.3"保留 NotebookLM 作 fallback"决定
- 设计教训：AC3 正则漏 `NotebookLM secondary`（C2-a 盲区）；§6.1 live-routing 清单编制需更严。已记入 Gate 4 验收，下个版本机制修补时复盘 AC 规范。
