# 增补完工说明 — Epic Phase 1 Gate 2 条件 B2/B3（Alex，2026-10-06）

- 对象：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p1-clearance.md`
- 判据：PM 合并裁定 `.tad/evidence/pm/2026-10-06-epic-p1-gate2-merged-ruling.md` 条件 B2/B3；细节出处 tech verdict `.tad/evidence/reviews/2026-10-06-gate2-tech-review-epic-p1.md` C1/C2。
- 开工对锚：修订前 52,982 B／sha256 `767941d8af434449f6c44f95462be3749303c08fe5446a64c89393fcab31fbf8`，复算与派发锚全等后才动笔。
- **修订后：53,861 B／sha256 `9c3cc3ff3f17c76f10737cb660f534ec55e8bcb0f2558e5ad4b79a7263d67b61`**（落盘后复算）。

## B2（源 tech C1）— validate 调用写死双参数形态，逐处点名改（无总注代改）

修订后行号定位（均在 HANDOFF 内）：

1. **L166（§4.1 A2 自检步文／step3c3 草案处）**：step3c3 引文内「对受治集逐一跑 `capability-skill.sh validate`」改为「对受治集逐一跑 `capability-skill.sh validate "$PWD" <name>`（双参数形态写死，<name> 逐件代入）」。
2. **L378（AC1）**：「在发布源逐一 validate exit 0」改为「在发布源逐一跑 `capability-skill.sh validate "$PWD" <name>`（双参数形态写死，<name> 逐件代入名单）exit 0」。
3. **L379（AC2）**：负控三连引导语加写死调用形态——「三连逐件均以 `capability-skill.sh validate "$PWD" <name>` 双参数形态调用，<name> 代入造件名」；三连 (a)(b)(c) 判据原文未动。
4. **L380（AC3）**：「save-skill validate 仍 exit 2、alex-lite validate 仍 exit 2」改为逐件全命令形——「`capability-skill.sh validate "$PWD" save-skill` 仍 exit 2、`capability-skill.sh validate "$PWD" alex-lite` 仍 exit 2（双参数形态写死；…)」。

复核：`grep 'validate "$PWD"'` 全件恰 4 处命中（L166/378/379/380），与上表逐一对应；AC1–AC3 外的 validate 提及（件目表、MQ-1、FR-2 等描述性文字）非调用点，按定点纪律未动。

## B3（源 tech C2）— §4.9 check6 无条件集五件点名写死＋提取规则排除口径

修订后行号定位：**L256（§4.9 check6 条）**，一处整段改：

1. **五件点名写死**：原「现行无条件集应为四件：…（Phase 0 以提取实跑结果为准冻结）」改为「现行无条件集按提取实跑冻结为**五件**，点名写死」，名单＝`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`、`.tad/brain-index.md`、`.tad/project-knowledge/frontend-design.md`、`.tad/project-knowledge/patterns/shell-portability.md`；第五件注明出处——「Before editing any shell file…」句所在行（仓根 AGENTS.md L50–51，本步已盘上实测：L50 为该句首行、L51 为路径行）。
2. **提取规则排除口径一句**：在原跳过规则（「If」行／glob／目录记号）之后补入——「提取规则另补一句排除口径：「Before editing」类条件句行不入无条件集（此类行为先读后改的前置条件指令、非无条件装载件，后续提取不计入）」；并在第五件注记中写明衔接：该行因现行规则未含此排除而被实跑计入、本批冻结集按实得五件收录、其后提取按排除口径执行（与裁定「五件写死＋补排除口径」双重要求逐项对应）。

复核：全件「无条件集」仅 L256 一处；残留「四件」命中 2 处均为他义（L27 件数表述、L161 Class A 禁入四件），未误动。

## 纪律自报

只写 HANDOFF 与本说明两件；仓外零写、git 零写操作；除上列 5 处定点改动（B2 四处＋B3 一处）外未顺手改动 HANDOFF 他处。
