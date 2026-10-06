# 实施完工说明 — 本体收口批（Phase 0 停步版＋续跑完工版）

- 任务：TASK-20261005-TAD-CLOSEOUT-BATCH；实施者：Blake；日期：2026-10-05
- 状态：**Phase 0 完成后停步**——CF-3 枚举（release-verify version）判 191 处写集外 stale（exit 1），按 HANDOFF Phase 0 规则停步报 PM，未进入 Phase 1。详情与分诊见 [COMPLETION-2026-10-05-tad-closeout-batch.md](sandbox://workspace/yun-sync/TAD/.tad/evidence/completions/COMPLETION-2026-10-05-tad-closeout-batch.md) §2。
- **续跑状态（2026-10-05 同日）**：PM 裁定采甲案后同链续跑，**Phase 1–3 全部完成**，AC1–AC16 逐条实测见 COMPLETION §6；本说明以下各节为续跑增补，停步版原文保留在上。

## 写集逐件字节变化（续跑增补）

（numstat 为对 HEAD 的终态值；含 D 线在册 hunk 的文件按行集口径注明本批份额。）

| 文件 | 变化 |
|---|---|
| `.agents/skills/gate/SKILL.md` | 对 HEAD 8+/3−（含 D 线 hunk）；本批三处：L279 区注释行改写 1 行、`Critical Check (6 items):`→`(7 items)` 1 行、新增 Provenance 行 +1 |
| `.agents/skills/release-runbook/SKILL.md` | +46/−0（§4.4 整节逐字插入，节首终态 L126；文件 148→194 行） |
| `.tad/tasks/evidence-collection.md` | +20/−0（§4.8 整节逐字插入，节首终态 L284；448→468 行，EOF 无尾随换行状态已恢复、diff 仅插入节） |
| `.tad/scripts/scan-downstream-versions.sh` | +1/−0（「覆盖口径」printf 一行，终态 L93） |
| `.agents/skills/research-methodology/`（新建） | 12 件 CREATE：SKILL.md 11,921 B（本体 CAPABILITY.md 11,936 B 删 `status: frozen` 一行派生，差 15 B 即该行；余 11 件与本体 sha256 逐件全等，清单见 COMPLETION §6 AC7） |
| `AGENTS.md` | 对 HEAD 18+/1−（含 D 线 +16 行节）；本批份额：指针行 +1（L152）、L9 标记行改写 1 行；文件终态 12,742 B |
| `.tad/scripts/scan-packs.sh` | 对 HEAD 24+/1−（override 标志行改写 1、`pack_names` 初始化 +1 与收集 +1、断言段 +21） |
| `.tad/version.txt` | 1 行改写：`3.0.0`→`3.0.1`（终态 6 B） |
| 扩面 12 文件 16 行 | 逐行定点改写、各 1 行计：config.yaml 2 行、TAD-VERSION 1、tad.sh 1、package.json 1、README.md 2、INSTALLATION_GUIDE.md 2、PROJECT_CONTEXT.md 2、docs/MULTI-PLATFORM.md 1、tad-help SKILL 1、alex SKILL 1（对 HEAD 3+/1− 含丙层在册 hunk，本批仅 L50 标记行）、blake SKILL 1、docs/CODEX-USER-GUIDE.md 1；改后值逐处点名见 COMPLETION §6 AC15 |
| `.tad/capability-packs/pack-registry.yaml` | 生成面：Phase 2／3 两次以改后脚本重跑，对 HEAD 终态 2+/2−（头部 `synced_from_version` 随 bump 更新等）；包名＋status 集合与基线全等（25 对，基线件 `registry-names-status-baseline.txt`）；终态 29,159 B |
| `.tad/evidence/pm/downstream-versions.md` | 生成面：Phase 3 以改后脚本重跑，对 HEAD 7+/6−（头注「覆盖口径」行新增、TAD 行版次与计数更新）；终态 2,362 B |

仓外写：零。git 写操作：零。NEXT.md／ROADMAP.md：零触碰。

## fixture 三态证据路径（续跑增补）

同 fixture（`/tmp/closeout-fixture-Ld73IM`，mktemp 唯一目录）三态捕获，均在 `.tad/evidence/closeout-batch-20261005/`：

- `fixture-control-unmodified.txt`——未改脚本、pack-b 缺投影：exit 0（无断言的对照态）
- `fixture-negative-missing.txt`——植入断言后、pack-b 缺投影：exit 1，stderr 点名 pack-b
- `fixture-positive-complete.txt`——补齐 pack-b 投影后：exit 0
- 真实树正控／终态：`scan-packs-realtree-phase2.txt`（exit 0）、`scan-packs-realtree-phase3.txt`（exit 0）

## 遗留登记句

- **校验器漂移（批外登记，Gate 2 合并裁定 3）**：`capability-skill.sh` frontmatter 键集契约与现行 26 件投影惯例漂移、且未被任何规程引用——本批完事卡遗留节应登记此项另行处置；指针正本：HANDOFF §4.5 末段。本步停步未及于完事卡（完事卡归收口），先在此登记，勿遗漏。
- **版本口径恒久修订（批外登记，CF-3 裁定 ⑥）**：§4.10「字面量封顶两处」口径已经裁定作废（本批实际改面以 Must-Version Registry 断言面＋发布前例为准），HANDOFF／规程中该口径的恒久修订待另批处理；指针正本：`.tad/evidence/pm/2026-10-05-closeout-batch-cf3-ruling.md` ⑥。本批完事卡遗留节应登记此项。
- **minor/major 升版时 168 件史述面处置（批外登记，CF-3 裁定 ⑥）**：类 A 168 件历史/夹具旧版字样本批按 patch 口径放行、一件未动；未来升 minor/major 时其处置口径未定，须另行立项裁定；指针正本：分诊件 `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-triage.md` §3 类 A 定性＋裁定 ⑥。本批完事卡遗留节应登记此项。
- **CF-3 分诊（待 PM 裁定）**：191 处 stale 中类 B 疑似活复述点名清单见 COMPLETION §2（含 `.tad/TAD-VERSION`、`config.yaml`、`tad.sh:26`、`package.json`、README/INSTALLATION_GUIDE/PROJECT_CONTEXT 等）。
- 设计文「handoffs 删除 11 件」与 Phase 0 实测 12 件不符（COMPLETION §3 第 5–16 行注记），与 tech 路 P2 一致，属计数漂移、非本链处置面。
