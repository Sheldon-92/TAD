# 核准 — 恢复执行链十七件处置定稿（Phase 1 硬前置凭据）

- 日期：2026-10-04
- 核准人：📐 TAD PM
- 凭据对象：处置表草案 `.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv`（17 行）；Phase 0 记录 `.tad/evidence/completions/2026-10-04-evidence-recovery-phase0-note.md`；备案件 `.tad/evidence/pm/2026-10-04-termination-secret-isolation-check.md`

## 核准结论

1. **处置定稿照准**：keep 10 件／drop 7 件，与设计附录 A 草案及 PM 载体裁定一致。裁定 2 对照两列（原件路径＋当场重算 sha256）已预填，AC3 对照断言在草案态自跑通过；**自动转保留无触发**（7 件 drop 候选原件全在册）。实施第二段先将处置表 `ruling_ref` 由 PENDING-PM 回填为本文件路径，定稿生效。
2. **第 16 件核准保留**：备案件结论「无真实凭据迹象」（7 类令牌形态扫描命中 0＋全文目检均为测试结构材料）经 PM 读件核可，裁定 3 的附条件已销清；该件不悬置，按 keep 入同步范围。
3. **Phase 0 冻结接受**：四锚复算 STALE=5／CARRIED=4355／BRANCH_ONLY=16 与 S1 全等；NOCARRIER 8754（＋48 逐件归因：本链自产 11／上游链自产 18／他链新增 19，类别迁移 0、盘上消失 0）接受；执行版清单冻结（13,130 行，sha256 `afba59dd…ed5f`，冻结队列 8,759 件，EXCL 2 件未入）生效。首轮瞬时读数多出 19 件、其后消失且成因未定——接受稳定快照口径，记为已知现象，看守后续轮次若复现再立查。
4. **AC10 基线登记接受**：设计钉值「跟踪修改 0」与复算时点不符，实测 20 件全为本链开工前既存（复活票回写 1／迁档删除 12／KA 修改 2／收口保留集 5，本链新增 0），已在 Phase 0 记录逐件登记；按增补 A7，Gate 3 以该登记值为 AC10 基线判读。
5. **授权进第二段**：Phase 2–5 按设计执行（脚本经临时索引 plumbing、逐件当场 sha、失败中止不许部分前移）；推送只许走设计写死的 grokbox 通道，VM 直推禁止；回滚锚 `8713ea4e` 保持。Phase 3 对账时 drop 行对照按 AC3 复核；第 16 件随 keep 队列正常同步。
