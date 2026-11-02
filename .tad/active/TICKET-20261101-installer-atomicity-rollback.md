# TICKET-20261101 — 安装器两缺陷：写入非原子＋回滚零恢复

**Status**: OPEN（缺陷登记，2026-11-01；**同型第二起后升级：TAD PM 裁定按 4.0.10 热修链处置，用户 2026-11-01 已批准开链，EPIC-20261101-v4010-hotfix**）
**Owner**: TAD PM（登记）；实施在热修 Epic 内
**来源**: GM 报缺陷（2026-11-01）＋证据一手复核（本席已读 apply.log 原文行 49、51–62）

> 恢复注记（2026-11-01）：本文件曾被本机间歇写故障截断为 0 字节（mtime 17:23），本席已报 GM 并按亲笔原文恢复、回读验真。下方正文为恢复件，与截断前内容一致（原稿＋第二起补记＋热修裁定三段）。

## 现场（商业洞见席升 4.0.9，2026-11-01）

证据正本：商业洞见仓 `.tad/evidence/pm/2026-11-01-tad-409-upgrade/apply.log`。

1. **写入非原子**：Syncing framework files 阶段 `cp` 写 `.agents/skills/web-frontend/checklists/frontend-quality.md` 报 `Operation not permitted`（apply.log:49），安装中止；该目标文件被截断为 0 字节（GM 实测、mtime 与失败时点一致）。现行写入是直接覆盖目标——写失败即毁掉原文件的好版本。
2. **回滚零恢复**：日志列出的全部面 Rollback FAILED、`restored: [none]`（apply.log:51–62），快照虽保全（`/tmp/tad-rollback.*` 与 `~/.tad-backups/<项目>/`）但回滚一件都没装回去；仓内落得 version.txt 4.0.9／AGENTS.md 4.0.8 的混合态（AGENTS.md 本体经 md5 核与升级前一致、未被改）。

环境面注记：EPERM 本身已由 infra 定性（2026-11-01）为平台存储层 overlayfs 在高 IO 负载下的间歇写拒绝（触发段为 syncthing 全量重扫与多席同窗批量写叠加；无文件系统损坏证据）。但「写失败截断原文件」与「回滚 restored: [none]」是安装器面的独立实缺陷，不因成因属环境而减等（GM 与本席口径一致）。

## 修复方向（设计输入，已由 HANDOFF-20261101-installer-atomicity 落为设计）

- 同步写入改原子形态：同目录写临时文件＋rename 换入（同文件系统原子），或整面 staging 后一次换入；任一写失败时原文件保持完好。
- 回滚须真恢复并逐件验真（自保全快照装回、按哈希/尺寸核对），回滚失败时不许把版本面留在新值——版本戳应最后写、且只在全部面验真后写；回滚结局须在收尾行如实区分 restored 全量/部分/零。
- 任一写面撞错在首个失败点停步，不带错跑完再回滚。
- 补一条回归案：人为注入写失败（只读目标/满盘模拟），断言原文件完好＋回滚恢复全量＋版本面未推进。

## 临时口径（修复落地前）

下游升级不依赖安装器回滚：升前自备快照，失败按快照逐件恢复（GM 2026-11-01 已对受损各仓如此裁定）。GM 放行双路居一：infra 清除信号或 4.0.10 发布，先到先放行。

## 第二起（2026-11-01 晚，Agent Workshop 席升 4.0.9）

证据：该仓 `.tad/evidence/install-checks/2026-11-01-align-409-full.log`（本席一手核：`printf: write error: Operation not permitted` 808 行、回滚 7 项 FAILED、`restored: [none]`）。同步阶段实际走完（24 updated），随后 Installation failed；实损：根 AGENTS.md 被截断为 0 字节（装前 md5 17042741…）、`.codex/hooks.json` 缺失、version.txt 已翻 4.0.9 成混合态。GM 已暂停其余席位新开 4.0.9 安装；受损面其后确认共六仓混合/受损，均裁按升级前快照恢复。

## 热修裁定（TAD PM，2026-11-01）

两起同型、均造成下游仓文件实损——不按下篮子排队，按 **v4.0.10 热修**走完整链（Alex 设计→Gate 2→Blake 实施→Gate 3 双审→Gate 4→发版规程全程）。修复面以上四条为设计输入。热修发布前，下游新开 4.0.9 安装维持 GM 的暂停令；4.0.10 发布后由 GM 解禁并编排重升。用户已批准开链，链名 EPIC-20261101-v4010-hotfix。
