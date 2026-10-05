# PM 载体裁定 — maintainer-evidence 证据载体选型（证据复活链收口裁定）

- 裁定人：📐 TAD PM，2026-10-04
- 依据：S1 实测四锚（NOCARRIER=8706／STALE=5／CARRIED=4355／BRANCH_ONLY=16）；Decision Brief 推荐案一（置信度中高）；RG3 Critic verdict PASS；RG4 综合 overall 0.875。链全程产物见 COMPLETION（`.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md`）。

## 裁定一：载体采纳案一

**采纳案一——恢复 maintainer-evidence 分支同步，同步脚本化，并设新鲜度看守。** 案二（主仓例外清单常态化）与案三（分级混合）不采纳：二者都须先修订 F-18 的 SC3 判据才能成立，为偶发直读便利改发行边界不划算；个别件确需主仓直读时，沿 R1 先例逐次以单批 `-f` 例外由 PM 裁定，不设常设登记册。主仓现已 tracked 的 3 件例外维持现状、不回退。

## 裁定二：新鲜度看守三项定死（RG3 弱点 1 处置）

看守是事后侦测，本裁定把它定成可执行的机械规矩，参数如下，恢复执行链负责做成实物（脚本落 `.tad/scripts/`，复算记录落 `.tad/evidence/pm/`）：

- **阈值**：按 S1 summary 的复跑命令序列重算四锚——`TOTAL_NOCARRIER` 超过 **100** 件，或分支尖最新提交距复算日超过 **21 天**，任一命中即判「停摆报警」：PM 当日立处置票并向用户播报，不许只记不报。
- **周期**：每条 TAD 链收口时必跑一次；当月无链收口时，PM 在月度自查中补跑一次。
- **责任人**：TAD PM（本席）。看守不依赖任何执行者自觉，复算与判定都是 PM 动作。

## 裁定三：重议触发（RG3 弱点 2 处置）

案一推荐的前提「关键件直读需求不频繁」目前无数据。定触发条件：usage log（`.tad/evidence/knowledge-usage-log.jsonl`）自 2026-10-04 激活起累计满 **50 行**后，PM 在周期 review 中统计关键件（Gate verdict／设计件／COMPLETION／PM 裁定件）被**跨链**引用的次数；任一关键件跨链引用达到 **5 次**，即重议是否为关键件开主仓路。未达触发前，本裁定维持不变，不许以个别印象提前翻案。

## 裁定四：branch-only 16 件＋gitlink 1 件（RG3 弱点 3 处置）

列为恢复执行链的**强制首步**：逐件给出「保留／弃置（附理由）」意见（清单以 S1 summary 与 manifest 为准，gitlink 件为 `.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work`），经 PM 核准后才许执行任何载体恢复动作。本裁定不预判去向；执行链不许默认吞掉或默认全保留。

## 裁定五：KA 落点

COMPLETION 所列三条候选已按其建议落盘：①「忽略树盲视」条目（`patterns/ac-verification.md`）补本链第二实例；②「AC 断言逐项化」条目（同文件）补误 PASS 镜像实例；③ 新立「git quotepath 伪差集」条目于 `patterns/shell-portability.md`。

## 后续

恢复执行另立票：`.tad/active/TICKET-20261004-evidence-carrier-recovery-execution.md`，输入＝S1 manifest＋本裁定，走完整 TAD 链（设计→Gate 2→实施→Gate 3→Gate 4）另行排期开链。本研究链至此收口：研究轨四件齐（RG3 verdict／Decision Brief／RG4 记录／证据日志收口锚行，AC10 PM 终核 PASS），Gate 2 六条条件全部销账（C-T3 第二算成立，细节见证据日志步序记录）。
