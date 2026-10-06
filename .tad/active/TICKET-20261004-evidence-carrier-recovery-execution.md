# TICKET-20261004-B：maintainer-evidence 载体恢复执行

- 登记人：TAD PM（2026-10-04，源自证据复活链收口裁定）
- 状态：CLOSED（2026-10-04 全链收口：Gate 2 PASS→实施（含 F1 增补与 F4 裁定）→Gate 3 双审 PASS→Gate 4 PASS；human CHECK 记「CHECK 待人」留痕于验收件）
- 裁定依据：`.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`（采纳案一）

## 输入（现成，不许重新盘）

- 影响面清单：`.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl`（13,082 行逐件清单）＋`inventory-summary.md`（四锚与完整复跑命令序列）。开链时先按复跑序列重算四锚，新旧差额以新增行追加，不改首跑口径。
- 待入载体队列（以开链复算为准）：no-carrier＋stale-content（2026-10-04 时点为 8,706＋5 件）。

## 范围

1. **强制首步——17 件逐件处置**：branch-only 16 件＋gitlink 1 件（`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work`）逐件给「保留／弃置（附理由）」意见，PM 核准后才许动载体（裁定四）。
2. **同步脚本**：把两树当前状态提交至 maintainer-evidence 分支——显式清单/`-f`（两树被整树忽略，朴素 add 会静默空转）；管线用安全口径（`-z`／`-print0`）；同步后以四锚复算断言收尾（no-carrier 应降至约 0，只剩同步时点后新增件），不许绿着空转。
3. **首轮全量补同步**：待入载体队列全量入分支；推送 origin 并验远端尖与本地同尖。
4. **新鲜度看守落地**：脚本落 `.tad/scripts/`、复算记录落 `.tad/evidence/pm/`；参数认裁定二（阈值 NOCARRIER>100 件或分支尖超 21 天报警；每链收口必跑、无链月份月度自查补跑；责任人 TAD PM）。

## 红线

- 不改 `.gitignore`、不动 F-18/SC3 判据、不回退主仓已 tracked 的 3 件例外。
- 逐件销账：以 manifest 行为单位补 outcome 回写执行版清单；入载体时当场重算内容 sha 记入，不许拿 manifest 的 bytes 当内容凭据。
