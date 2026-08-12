# install-smoke-v2410 Findings（2026-08-11）

## 1. 发现缺陷 F1（P1）— 2.30.0–2.40.x 版 tad.sh 升级判定缺陷（AC12/AC13 FAIL 根因）
- **现象**：在 2.30.0 fixture 上跑本地 `bash tad.sh --yes` → `Nothing to do` 秒退，升级路径未执行（AC12 FAIL；U 保持 2.30.0，AC13 FAIL）
- **机理**（执行实证）：2.30.0 版 main() 顺序为 `STATE=$(detect_state)`(L961) → 下载(L1073) → `derive_target_version`(L1079)。检测时 `TARGET_VERSION` 仍是硬编码 `"2.30.0"`(L22)，与本地 `.tad/version.txt` 相等 → `detect_state`(L905) 判 `current` → L1014 状态闸 `Nothing to do` 早退 → 下载与权威版本导出**不可达**
- **影响面**（reviewer 实证扩大）：`probe_remote_version` 由 commit `ac0699f`（2026-08-09）引入，`git tag --contains ac0699f` 仅 v2.41.0；`git show v2.40.0:tad.sh | grep -c probe_remote_version` = 0 → **2.30.0–2.40.x 全部受影响**（任何旧版 tad.sh 在其对应版本项目上恒判 current，无法自助升级）。AC19 普查 25 个 2.x 旧版项目均在范围内
- **修复对照**（2.41.0 已修）：`probe_remote_version`(L1436) 先于 `detect_state`(L1437)，探测成功即以远端版本覆盖 TARGET_VERSION（L49-58）；且 `PROBE_OK != 1` 时强制 `ACTION=upgrade`（L1509，拒绝基于未证实目标宣称"已最新"）；下载后 M7 权威复判（L1588）
- **严重度**：P1——核心升级功能静默失效（用户误以为已最新），无数据破坏，有 workaround（curl 全新安装/手动替换 tad.sh），不到 P0
- **处置**：本单只诊断不修复；须在 2.41.1 前评估存量下游影响（25 个旧版项目）与修复方案

## 2. 契约判据缺陷 F3（rev6 已修，增补复核 PASS）
- **现象**：AC10b 第 1 组实跑差异恰 1 条 `.claude/skills/doc-organization.md`（REF 有、A 无）
- **根因**：skills 根级 `*.md` 契约性不装（`tad.sh:822/883` 拷贝循环 `for ... in .claude/skills/*/` 只遍历子目录；`tad.sh:1704/1784` 升级归档显式豁免保留它），而 AC10b 豁免清单只列 `.tad-pack-meta.yaml`
- **处置**：rev6 补 AC10 预期缺失 + AC10b 第 1 组豁免 + AC19 声明；增量复核 PASS（P0=0/P1=0）
- **待产品裁定**：新装项目不会获得 `doc-organization.md`（v1.4 孤儿遗留，17/30 下游历史遗留）——是否为期望行为待裁定

## 3. 执行期偏离记录
- **AC14/AC15 在 U2 执行**（契约原文指定 U）：因 F1 使 U 未升级不可达，U2（=U 内容拷贝，AC12b-pre 三条断言保障保真度）是唯一真实升级路径；AC14.txt/AC15.txt 如实注明。**该偏离实际缩小了 AC19 缺口**（curl 变体数据零损失已验：冻结集 8607/8607（SHA 行数，排除 README；含 README 8608/8608） + README 替换 + 符号链接 7 一致 + 覆盖行为预判一致）
- **AC11 摘要比较**：源路径 vs U 路径前缀不同导致 diff 假阳性，改用 SHA 集合比较（10482/10482 一致）
- **AC14 符号链接比较**：diff 含路径前缀/mtime 假阳性，按相对目标语义比较（7 一致）
- **AC18 前值**：984M 记录于 scope-baseline.txt（`du -sh "$HOME/.npm/_cacache"`），后值 1.0G 落盘 AC18.txt

## 4. 覆盖缺口（AC19 声明，本单不假装覆盖）
- 仅覆盖 2.30.0 fixture；下游其余版本未覆盖（普查表见 AC19.txt）
- 未覆盖 `--platform claude-code`、`--platform codex`、`--packs` 子集
- 未覆盖分支：`copy_pack_skill_smart` Case 4（hash-skip）、`merge_claude_md` 有锚点分支、migration engine 有效链路（本 fixture 断链）
- 未覆盖检查面：`.tad/hooks/**` 可执行位、`.claude/settings.json` JSON 合法性、`.codex/hooks.json` 生成正确性
- 单平台（claude-code/codex）下 `doc-organization.md` 行为未单独验证
- **本 fixture 无合并锚点、无 pack-meta → 两条保护分支不可达、完全未被验证——本单最大覆盖缺口**

## 5. 普查异常
- `小垃圾/.tad/version.txt` 为特殊文件（读取超时），普查排除并注明

## 6. 验收补录（2026-08-11）
- **围栏 audit 半边无负控**：AC17 负控探针是未跟踪文件，只被 fence-fresh 看见；fence_audit 的 NEW-PATH 排除分支（基线无摘要=本单新增→不比对）在构造上对未跟踪文件不可见。verify.sh 修改虽被增量复核的篡改探针覆盖（已跟踪文件），但 audit 半边从未被未跟踪文件探针触达。建议下个触碰 verify.sh 时补：负控加一例已跟踪文件篡改探针直击 fence_audit。
- **冻结集口径**：统一为 8607/8607（SHA 行数，排除 README；含 README 8608/8608）。计数定义 = `grep -cE '^[0-9a-f]{64}'`（SHA-256 行数，不含 `## ` section 标记；AC14-baseline 实测 8608 = active 7870 + evidence 693 + project-knowledge 45，其中 README 1 条）。
