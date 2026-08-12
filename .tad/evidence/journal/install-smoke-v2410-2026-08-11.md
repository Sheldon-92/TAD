# install-smoke-v2410 raw journal (2026-08-11)

## 发现 F1（P1）: 2.30.0 版 tad.sh 升级判定缺陷
- 在 2.30.0 fixture 跑本地 tad.sh --yes → "Nothing to do" 秒退，升级路径未执行
- 根因：2.30.0 main() 顺序 detect_state(L961) → 下载(L1073) → derive_target_version(L1079)；
  检测时 TARGET_VERSION 硬编码 "2.30.0"(L22) == 本地 → STATE=current → ACTION=none
- 2.41.0 版在 detect_state 前加 probe_remote_version(L1437)，已修复该顺序
- 影响：含此顺序的旧版本地升级自检永远判 current（误导）；curl 变体不受影响
- 处置：本单只诊断；须 2.41.1 前判定是否影响存量下游（9 个 2.30.0 项目）

## 契约判据缺陷 F3（已修 rev6）
- AC10b 第 1 组豁免漏 skills 根级 .md（doc-organization.md 契约性不装，tad.sh:822/883 只遍历子目录）
- rev6 补豁免 + AC19 声明；增量复核 PASS

## 执行笔记
- AC11 diff 假阳性：源路径 vs U 路径前缀不同 → 用 SHA 集合比较（10482/10482）
- AC14 符号链接：diff 含路径前缀/mtime 假阳性 → 相对目标语义比较（7 一致）
- 围栏 REPO 路径解析 bug：verify.sh 相对 ../../../.. 才到仓库根（第一版 ../../.. 停在 .tad/）
- 小垃圾/.tad/version.txt 读取超时（特殊文件），普查排除并注明
