# Gate 4 终判 — TASK-20261006-TADSH-BACKUP-FIX（tad.sh 备份缺陷修复）

**验收者**：Alex（Solution Lead，Gate 4；未参与本链设计增补之外的实施与评审，与 Gate 3 两路独立）
**日期**：2026-10-06
**判据**：`.tad/gates/gate-canonical-checklist.md` Gate 4 节＋`.tad/tasks/gate-execution.md` Gate 4 规程；对象为 HANDOFF §9.1 AC1–AC16（本体＋SUPPLEMENT-1 S1–S4／N1–N5 修订口径）。
**方法**：不采信完工自述——全部关键值由本席从盘重算（锚值、AC14 命令链原文、AC15 S4 口径、AC16 grep、diff 逐点定位、函数顺序亲读），终版 fixture 全套在本席手上于 VM 与 grokbox 骨架各复跑一轮（见 §5）。git 只读；复跑仅限 mktemp 隔离面与 grokbox /tmp 骨架，未碰任何真实项目仓。

**对象锚（本席实测）**：HANDOFF 44,721 B／sha256 `dbc7d56c…` ✓；SUPPLEMENT-1 15,136 B ✓；COMPLETION 28,748 B／sha256 `40ccabdc…` ✓（含 F-S1 修复追记）；终版 `tad.sh` 157,388 B／3,519 行／sha256 `459b9fc9…` ✓；终版测试脚本 34,018 B／sha256 `941d3609…` ✓。

---

## 总判：PASS

Gate 4 Canonical 四项全过（§6 逐项）；GM 四条验收口径逐条成立（§1）；披露偏离本席**追认**（§2）；F-S1 终核关闭成立（§3）；终态 fixture 证据强度经本席补齐为两机 15/15（§5）。无 P0/P1 遗留；残项 4 条均为后续票级别、不阻断本判（§7）。**建议报 GM 验盘解冻**（§8）。

---

## 1. GM 四条逐条终判（票 `.tad/active/TICKET-20261006-tadsh-backup-fix.md`）

| # | GM 口径 | 终判 | 本席重算证据 |
|---|---|---|---|
| 1 | 备份面收窄：只备框架与配置面，排除 evidence/archive 及同类数据面，体量回 MB 级 | ✅ 成立 | 备份集由既有 deny-list 派生函数直接枚举（无第二份名单）；AC1 两机绿（manifest 行集与派生集 diff 空、递归内容集相等、7 个数据面/包树哨兵命中 0）；AC2 两机绿（≥5M 填充零入备份、备份字节 < fixture 总量 20%）；registry-only 特判（S2）已钉入拷贝/清单/还原三面 |
| 2 | 落点移出同步盘：默认 `~/.tad-backups/<仓名>/<时间戳>/` | ✅ 成立 | AC3/AC4 两机绿：默认落点形态与规格一致（HOME 沙箱实测）、项目根条目集备份前后不变、根/组目录 700；落点指进目标根（含符号链接别名形态）在任何 mkdir/chmod 效应前拒绝（AC11＋F-S1 修复，§3） |
| 3 | 自动保留策略：每仓最近 2 份，写新份时自动清旧 | ✅ 成立 | AC5 两机绿＋Gate 3 CODE 路独立探针 A1–A3/B1–B2 互证：(时间戳, 后缀数值) 序、残份先清不占名额、同秒命名 max+1 单调不复用（grokbox 首轮抓到的排序反转已修且有确定性回归场景钉住）、刚写份兜底恒在保留集；AC8 清旧失败只 warn 不阻塞 |
| 4 | rollback 读新落点、功能不退化，与承接 B 常设回退还原机制同口径 | ✅ 成立 | AC6/AC7/AC10 两机绿：新防线闸三条把关、manifest 域逐条目原子还原、数据面在 AC6 断言对下逐字节保持「备份后用户改动时点」、失败保留备份点名且已还原条目不回退；同口径按 S1 定案收窄为**验证法对齐**（全树哈希前后对照），断言对命名已改「本链 AC6 断言对」、不再借用承接 B 裁断的分子/分母工时口径——票面第 4 条的对齐要求以此定案形态满足 |

## 2. 披露偏离追认：`_tad_tree_equal` 替换两 restore helper 内 4 处 `diff -rq` 校验点

**结论：追认（批准）。**

**盘面事实（本席逐点核）**：`_tad_tree_equal` 调用点恰 4 处——`restore_dir_entry` 内 L2251（stage 校验）、L2255（rename 后复验），`restore_file_entry` 内 L2275、L2278，无多无少；仓内其余 `diff -rq` 执行点仅 `verify_install_complete` 的 L1744 一处，与 HEAD 逐字相同、未动（其上方注释行 L1699 亦未改，与披露一致）。

**追认理由**：
1. **原探针在合法载荷上恒失败**：GNU `diff -rq` 目录比对解引用符号链接，框架目录内悬空链接（HANDOFF §6 fixture 规格明定、AC13 的合法载荷）使其 exit 2——不是更严，是不可用。HANDOFF 的 fixture 规格与其指定 helper 的探针自相矛盾，实施在探针层消解矛盾是唯一不动合同的路径。
2. **合同不变**：两 helper 的 stage-verify-rename 原子性、失败保源、消息面一字未变；变的只有「相等」的测法。新探针语义经 Gate 3 两路独立判读一致：常规文件 cmp 逐字节、目录条目集全量比对、链接比目标串（正是 cp -R 拷贝忠实度的正确判据）、特殊文件保守判不等（大声失败方向）；权限位维度与旧探针平价（两路均不比），无校验变弱。SAFETY 路 O1（不可读同名子目录的理论面）在还原流中不可达（cp 先行失败），不构成追认障碍。
3. **写集外溢定性**：形式上越出 HANDOFF §4.6「step-2…5 不动」与 §7.3 字面写集（两 helper 为 step-1 与 step-2 快照还原共用）——定性为**实现层探针修正，非设计变更**：未改任何函数的对外合同、未动 deny-list 与 derive 语义（AC15 S4 口径本席重算 = 0、三函数与 HEAD 逐字节同已经两路 cmp 实测）、step-2 同等受益且行为平价由全套 fixture 复跑证明。披露及时（COMPLETION 与实施说明双处显式、Reflexion 留根因），程序面无隐瞒。本追认即 CODE 路 CONDITIONAL 的唯一条件与 SAFETY 路对该项的悬置的关闭依据；替代路径（C6 私有化 helper）只增重复、不增安全，两路与本席均不取。

## 3. F-S1 修复终核

**结论：关闭成立（抽核通过）。**

- 复核件 `gate3-safety-fs1-recheck.md` 判 CLOSED，本席抽核盘面一致：`resolve_backup_root` 现体（L504–553 亲读）判定顺序为字面快速拒绝 → 只读物理解析（既存目录 `cd && pwd -P`；存在非目录直接报错；不存在经最近既存祖先只读解析预计落点）→ 空/`/` 检查 → 物理 inside-target 拒绝 → 其后才 `mkdir -p`＋`chmod 700`（L548–549）。函数头注释已如实记录此顺序合同。
- 证据面：作者新场景 `root-alias`（别名拒绝零痕迹＋合法既存根收紧保留）＋复核方 12 例对抗探针＋双负控（旧函数体拼回 FAIL 签名恰为 F-S1、变异体 root-alias FAIL／root-guard PASS）互证；本席终版全套复跑两机均含 root-alias 绿（§5）。
- 至此 Gate 3 两路的 CONDITIONAL 条件全部关闭：CODE 路条件＝本判 §2 追认；SAFETY 路条件＝F-S1 关闭。Gate 3 整体以 PASS 论。

## 4. AC 终核抽验（本席重算，非转述）

| 项 | 本席实测 |
|---|---|
| AC14 回归链原文 | rc=0：`bash -n` 过、`--verify-denylist` PASS（17 条与 lib 一致）、detect-state-test 12/12 PASS |
| AC15（S4 口径） | `git diff -- tad.sh \| grep -cE '^[+-]TAD_(ZERO_TOUCH\|TRANSIENT\|TOP_DENY)='` ＝ **0**；`.tad/version.txt` git diff 为空、仍 3.1.0（版本冻结守） |
| AC16 | `grep -c 'Backup:  .tad.backup'` ＝ 0；`grep -c 'tad-backups'` ＝ 1 |
| 其余 AC1–AC13 | Gate 3 两路已逐行独立执行全过；本席以终版全套复跑两机 15/15 覆盖其行为面（§5），且 F-S1 修复后函数外行为平价已经复核件 ③ 与本席复跑双证 |

## 5. 终态 fixture 证据强度（本席补齐）

修复前证据缺口属实：grokbox 在盘日志（grokbox-test.log）为 F-S1 修复前 14 场景版。本席本次以**终版两文件**（sha 与 VM 在盘终版逐字一致：tad.sh `459b9fc9…`、测试脚本 `941d3609…`）在 grokbox `/tmp/tadfix-g4` 骨架复跑全套：**TALLY PASS=15 FAIL=0**（含 root-alias）；VM 本地同轮复跑 **15/15**。终态证据强度至此为：红基线两机 14/14 红（对 HEAD 源）＋终版全套两机 15/15 绿。附带互洽核：两机真实 HOME 下均无 `.tad-backups` 目录——全程未以真实 HOME 跑过备份，冻结令合规的旁证成立。

## 6. Gate 4 Canonical 四项

| 项 | 结论 | 依据 |
|---|---|---|
| Functional acceptance（§9 AC met、无未决实施阻塞） | ✅ | AC1–AC16 全过（两路独立执行＋本席重算与复跑）；开口项仅 §7 后续票级残项，非阻塞 |
| Quality evidence complete | ✅ | Code review（gate3-code）、Security review（gate3-safety＋fs1-recheck）均在盘；本链为 CLI 脚本、无 UI，UX N/A；性能面无（HANDOFF NFR 无性能项） |
| Subagent issues resolved | ✅ | Gate 2 四条件（S1–S4）经增补核销；Gate 3 全部 P0/P1 为零，唯一 P2 条件（F-S1）已修复关闭、P2 偏离已追认；风险卡 REQ-1–4 证伪信号两路复核均未出现 |
| Knowledge Assessment complete | ✅（附收口动作） | COMPLETION KA 非空（2 条发现，原料完整记于 COMPLETION Reflexion 与实施说明）；蒸馏落盘（patterns/shell-portability.md 两条）按本链写集安排留 PM 收口时由 Alex 补落，列为 §7 残项 R4，不阻断本判 |

## 7. 残项（全部后续票级，不阻断 PASS、不阻断解冻）

- **R1**：`verify_install_complete` 的 L1744 `diff -rq` 同病灶（新装树同样可能含悬空链接）——后续票同口径换 `_tad_tree_equal`（实施方建议、CODE 路附议、本席认可方向）。
- **R2**：清新建顶层粒度的一格（CODE 路 P2-2）：失败运行在备份时点已存在的 `capability-packs/` 内新建的嵌套文件（如时点不存在的 pack-registry.yaml 本体）不在清扫面、回滚后残留。与 S3.4 顶层判据设计一致、影响面窄，后续票决定是否收。
- **R3**：`.tad-migrate-backup.*` 结构备份的体量/落点评估——HANDOFF §4.6 原议，PM 另立后续票。
- **R4**：知识蒸馏落盘（diff 悬空链接探针、同秒命名单调性两条 → patterns/shell-portability.md）＋COMPLETION 的 `gate3_verdict` 回填、票关闭与 HANDOFF 迁档——PM 收口动作。

## 8. 解冻建议

**建议：可报 GM 验盘解冻。** 四条口径全数成立、证据两机齐备、冻结令全程合规（零真实仓运行、存量备份零触碰、版本冻结守）。按票面 sequencing 明示：**解冻 ≠ 发版**——本修复不单独发版，随自优化 Epic 最终版统一发布；存量约 150 份旧备份的清理仍归 GM 在用户点头后统一组织，本链未碰。

## 9. Human 验收区

**验收结果**：CHECK 待人

（本判为 Gate 4 机器/规程面终判；human CHECK 按链惯例留人。）

---

**Verdict**: PASS
**Gate 4 Executor**: Alex (Agent A)
**Date**: 2026-10-06

**自报**：本件字节数与 sha256 于落盘后由 `wc -c`／`sha256sum` 实测，随回执上报（自引用值不写进正文，循本链惯例）。
