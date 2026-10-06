# 实施完工说明 — Epic Phase 3「运行时适配补全」（TASK-20261006-EPIC-P3-RUNTIME）

- 执行：Blake，2026-10-06。完工件：`.tad/evidence/completions/COMPLETION-2026-10-06-epic-p3-runtime.md`（16,434 B，sha256 `3e242fb84dcc5193…`）。

## 一句话结论

Phase 3 九件中八件全落、AC 自检 31/33 完整 PASS；两处未竟均非机制失败、已升级在案：Codex 真机基线卡厂商配额（10-10 后补跑）、承接 A 机械销账卡样本集冻结 control 面（待 PM 授权替换后同 runner 复评即整轮 PASS）。

## 落地形态速览

- **件 3.1**：OpenCode 垫片插件（四处理器：startup 副作用／precompact 快照／compacting 注入／写后同步＋注入，名册 {write, edit}，全 fail-open）＋Cursor `.cursor/hooks.json`（三事件条目，timeout 30/10/10）＋两 jq 转码垫片（恒 exit 0）＋tad.sh 两投影族全链（preflight→投影→写后 cmp→rollback，镜像既有插件族）。
- **件 3.2**：Codex 零代码（既有 hooks 面复测在案）。
- **件 3.3**：三家 step3f 基线成件——OpenCode PASS、Cursor PASS、Codex FAIL（配额归属，raw 日志在盘）。
- **件 3.4**：适配清单＋三实例＋索引登记＋Known Gaps 回写（残项 R-OC-1/R-OC-2/R-CU-1 成立、R-CU-2 未成立）。
- **件 3.5**：F1 五通道核查表（逐行证据指针）＋Cursor/OpenCode 两份 inert 权限样例。
- **承接 A**：洁净对照重捕跑完（判别 0/1/0、被测 5/7/6、must_not 全 0），机械判 INVALID 的根因定位至样本集冻结面，PM 裁断请求已写入 scores.md 附注。
- **承接 B**：回退还原试点成立——16 路径比对面回退后与变更前逐行全等；(ii) 维待 Gate 3 工时回填。
- **承接 C**：OLD_PAT 限定注释（5 行）＋publish-ops check4 核对段＋三锚正负控实跑通过。
- **承接 D**：publish-protocol step4 去「Push only」＋来历注记；step5 tag 在位断言；publish-ops §6 镜像指针。

## 给 PM 的收口清单（§10 交接）

1. Gate 3 独立双审派发（COMPLETION 的 gate3_verdict 留空待回填；human CHECK 记「CHECK 待人」）。
2. 承接 A 裁断：是否授权以本轮洁净对照替换样本集三件 `cases/*/control.md`（裁准后：替换→复评→回填销账行，均在链收口材料留指针）。
3. Codex step3f 补跑：2026-10-10 10:24 AM（grokbox 侧配额恢复时点）后派跑，回填 codex transcript 与字段表。
4. 承接 B (ii) 维回填：Gate 3 工时发生后补终值并复核试点结论行。
5. session-state 索引行补记（不在 Blake §7 写集内，未动）。
6. CF-7 infra 清单知会：VM 面与 grokbox 面 Cursor/opencode CLI 版本不同步观察，一行转 infra 席。
7. 发版口径：按 2026-10-06 新规，P3 不单独升版；Epic 全完后统一发最终版。

## 纪律自报

- git 零写；仓外写入面仅 grokbox 骨架/试点/源树/探针日志与 /tmp 临时件（COMPLETION §6 列明）；同名文件全程绝对路径；version.txt 与基线锚全等，零升版。
