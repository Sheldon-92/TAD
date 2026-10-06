# Gate 2 合并裁定 — Epic P4 设计（2026-10-06，PM）

双审：fit CONDITIONAL（C-1）、tech CONDITIONAL（P1-1/P1-2）。PM 合并裁定：**增补 B1–B5 落盘核销后转 PASS**。

- B1（tech P1-1）：生成器修复范围扩至全部字节级截断/剥离点位——除 `cut -c` 类外含 L37 标题日期后缀剥离 sed 路径（评审实测其在 POSIX/C locale 独立劈裂多字节字符）；「脚本内强制 LC_ALL=C.UTF-8」式修复经实测无效，明示禁用。判据仍以 AC10/AC11 为准。
- B2（tech P1-2）：AC11 措辞改「去日期后缀后与源标题逐字相等」，并注明两行损坏部位（Deny-List 行在标题段、AI/Human 行在摘要段）。
- B3（fit C-1）：§8/§9.1 补置旧向 fixture 行——隔离副本将索引 Generated 回填旧日期后跑 check7 须出现 WARN（件 1.9 断言双向实测补齐）。
- B4（tech P2-3）：AC23 的 hook 判读源措辞订正——patterns 文件内并无「索引节」，hook 文案以各文件标题/首节内容为准、Gate 3 抽读对位。
- B5（tech P2-2 串行序）：§11「无并行在飞链」订正——tadsh-backup-fix 链同改 tad.sh，两链实施串行：**备份修复链先行落地，Phase 4 的 tad.sh 接线（Phase 1 步 4）在其实施提交后开工、Phase 0 复算时以修复后 tad.sh 为锚**。
- 另记（不入增补、Phase 0 停步点处置）：tech P2-1——若四 worktree 目录多为 (b) 级，AC5 净降判据的达成形态由 PM 在 Phase 0 停步点按比对实测裁定，不预改 AC。
