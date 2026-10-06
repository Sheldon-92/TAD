# Gate 2 合并裁定 — tad.sh 备份修复设计（2026-10-06，PM）

双审：fit CONDITIONAL（F-1）、tech CONDITIONAL（三条阻断 T-C1–T-C3）。PM 合并裁定：**增补四项落盘核销后转 PASS**。

- S1（fit F-1）：集合对（还原面/全 .tad 面）改名为本链 AC6 断言对，不归承接 B 裁断口径；§4.5 与设计说明 D-4 的分子分母句删除或改写，只保留「验证法对齐（全树哈希前后对照，与试点 before 逐行全等同族）」声明。承接 B 裁断的分子/分母唯一指 (ii) 工时口径，不许同名二义。
- S2（tech T-C1）：C3 补 capability-packs 的 registry-only 特判；§4.3 钉死 manifest 中该分量仅注册表路径行；C6 钉死该分量永不走目录路由；AC1 补递归枚举＋包树哨兵断言。
- S3（tech T-C2）：备份时落盘 `.tad` 顶层全量条目清单，「清本轮新建」改以该清单为判据（顶层悬空符号链接 fixture 反例为据）；fixture 增顶层悬空链接存活例。
- S4（tech T-C3）：AC15 改为只比对三段 deny 赋值块本体（原 grep 计数对合规实现必假 FAIL）。
- P2 五条（同秒排序、TARGET_ROOT 钉 pwd -P、类型翻转 staging 残留、清新建失败时序、组目录 chmod 认领）写入增补作实施注记，不阻断。
