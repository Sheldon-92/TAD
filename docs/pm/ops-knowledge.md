# ops-knowledge.md — TAD 隐性运维知识

last-harvest: 2026-09-16

## 派活/同步
- 2026-09-16：grokbox 派发若 sentinel 10 分钟未同步（FATAL），先查本机 syncthing 是否多进程（`pgrep -a syncthing`）；双进程并存会卡同步，thin-PM 不自行杀进程，删本地僵尸 sentinel 后重派，派完必去 grokbox 确认 `~/.muse-jobs/<job-id>/` 目录建起来再报完工（launch-ack 只看目录，不看 sentinel 落盘）。
- 2026-09-16：精确 pathspec commit 时，若某路径是已 staged rename 的 source，git 会整单拒收（add 原子失败、不污染索引）；改用其余路径重加即可，rename 由新路径侧承载，AC12 加 `-M` 跑 set-equality 恢复 rename 检测。

## 远端执行判据（2026-09-16 统一，见 gm-pm-mechanism.md §10 / protocol v2）
- 唤醒器：`~/workspace/bin/muse-gb-wake.sh`（cron `muse-gb-wake`，3 分钟）；grokbox 新任务只认 `started.json`（launch-ack 唯一凭据），完工事实只认远端 `done.json`；linke/Sheldon 旧任务兼容 job 目录存在。


## 盘⇄私有脑 · 一次双写（2026-09-21）
- 项目：TAD
- 仓路径：云同步/TAD
- load 指针（本项目常读）：
  - now / 段状态：docs/pm/now.md （及 segment-status/ 若有）
  - 复述：docs/pm/restates/
  - 开跑卡+stamp：docs/pm/open-cards/ + docs/pm/chat-card-stamps/
  - 本文件：docs/pm/ops-knowledge.md
- 双写约定：收口/门4 时结论先落盘，再改私有脑 load-index/精选/log；冲突以盘为准。
- 读：按动作兑指针，不是开跑前全表灌入；文案≠自动执行。
- 样板 SSOT（只读）：云同步/gm/Epic-理顺机制/设计-盘与私有脑双向保更新-组合GM试点-2026-09-21.md（修订 c）
- 完成时刻：2026-09-21T03:56:00Z
