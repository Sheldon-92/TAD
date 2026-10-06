# Phase 0 基线冻结 — TASK-20261006-EPIC-P1-CLEARANCE

- 冻结时点：2026-10-06（Blake 实施会话，Phase 0）
- HANDOFF 锚：53,861 B／sha256 `9c3cc3ff3f17c76f10737cb660f534ec55e8bcb0f2558e5ad4b79a7263d67b61`——开工复算全等。
- 结论：§2 全部承重锚值复现（下表）；唯一计数口径差已查明并记录（validate 全集），非盘面漂移。

## 锚值复核表

| 锚 | 设计 §2 值 | Phase 0 实测 | 判 |
|---|---|---|---|
| MQ-1 validate 全集 | PASS 22／FAIL 41 | 以「含 SKILL.md 的技能目录」为全集＝63 目录：PASS 22／FAIL 41（`baseline-validate-sweep.txt`） | ✓（口径注见下） |
| MQ-1 登记面 25 pack | 23 败多键＋2 败禁入件 | 25/25 FAIL：23 extra keys＋2 forbidden artifact（product-thinking、web-frontend，均 README.md） | ✓ |
| MQ-1 治理候选 | alex/blake validate exit 0 | 均 PASS | ✓ |
| MQ-3 publish-protocol | 216 行 | 216 行 | ✓ |
| MQ-4 check5 | 4 项失效引用 | state-surface：check1–4 PASS、check5 恰 4 FAIL、exit 1（`baseline-state-surface.txt`） | ✓ |
| MQ-4 归档实指 | 四件均在盘 | 四件 `test -f` 全 EXISTS；四旧子串在 session-state.md 各恰出现 1 次（行 7/8/9/11，均在头部索引块内） | ✓ |
| MQ-6 hooks.json 存档件 | 805 B、jq exit 0 | 805 B、sha256 `76bb1df398894ea3c29838e4797996fcc00baf742a67fbd995ab049048a9a8be`（`baseline-hooks-json.txt`） | ✓ |
| MQ-7 driftcheck | A=25／B_type=35／C=25；(b) 11 件 | 全文同值（`baseline-driftcheck.txt`）；(d) product-thinking 文案失实在盘（称其无 SKILL.md，实存） | ✓ |
| MQ-8 brain-index | Generated: 2026-09-16 00:54 | 第 2 行同值；实测日龄 20 天（2026-10-06） | ✓ |
| product-thinking 投影 | frontmatter 仅 name+description | 同左；正文（frontmatter 之下）sha256 `c6a83fc4ae584aa3809d3311e372b224c5631d193a3783f9712365d2a9177186`、全文件 `b5542b06e793e603e8d0775c52358462981b5d4516e44994ad45db4d63727df5`（`baseline-product-thinking.txt`） | ✓ |
| product-thinking CAPABILITY | type/keywords 原行 | `type: deep-skill`；`keywords: ["product", "strategy", "business", "PMF", "pivot", "产品", "商业", "市场", "idea", "PRD", "business model", "压力测试", "商业模式"]`（冻结原文，Phase 2 照抄） | ✓ |

**validate 全集口径注**：`.agents/skills/` 下共 64 个条目，其中 `_archived/` 为非技能归档目录（内为散装 .md、无 SKILL.md），不入技能全集。含 SKILL.md 的目录恰 63 个，与设计 PASS 22／FAIL 41 一致。若把 `_archived` 也喂 validate，其因名不合规范化形态 exit 2，计数变 42——属枚举口径差，非锚值不符。

## 件 1.2 封顶表述冻结清单（AC5 判据集）

- 模式集：`封顶 | 两处 | at most | 仅两 | 限两 | two surfaces | two files | capped`
- 扫描面：publish-protocol.md、publish-ops.md、release-runbook 技能树、`.tad/templates/`
- 结果（`baseline-cap-statements.txt`）：publish-protocol 与 publish-ops **零命中**；唯一命中 `.tad/templates/design-tokens-template.md:11`（"exports two files"——设计令牌导出文件数，与发版版本改面无关、非发版模板），不入 AC5 残留集。AC5 按其文面只判 publish-protocol 与 publish-ops 两文件：基线已零残留，Phase 2 落推导规则段后复核仍须零命中。

## 初装 fixture 预跑（改前基线）

- fixture：`/tmp/epic-p1-fix0-VeLuem`（`mktemp -d`；路径另记 `fixture-path.txt`）
- 初装：`bash tad.sh --yes --source <本仓>` exit 0，装后 version.txt＝3.0.1（日志 `baseline-install-fixture.log`）
- **genesis 改前基线**：`.tad/migrations/genesis.yaml` 不存在（migrations 目录止于 `2.43.0-to-2.43.1.yaml`，共 15 件 hop 文件）。
- **模拟升级基线**：fixture version.txt 置 3.0.0 后重跑初装命令 → 升级路径实测输出 `REJECT: chain gap at 3.0.0 — no manifest from 3.0.0. Suggest clean reinstall.`＋`Migration skipped: manifest invalid or chain gap (exit 2)`（`baseline-upgrade-fixture.log` L44–45）——件 1.6 要治的噪声原文在案。
- **件 1.9 核查点三结论**（`baseline-fixture-checks.txt`、`baseline-brainindex-gen-fixture.log`）：
  - (i) 初装后目标树 `.tad/brain-index.md` **缺失**；
  - (ii) 目标 AGENTS.md L43 路由指向 `.tad/brain-index.md`——路由与实存**不一致**（sighting 机制坐实）；
  - (iii) 目标侧 `brain-index-gen.sh` 手动可跑通（exit 0，生成 120 行索引）——生成器未坏死。
  - → 处置按 §4.9 定规走「(i) 为缺」支：tad.sh 初装流程加目标侧生成步（可见 WARN、禁静默吞）。
- **genesis 落点预判（待 Phase 1 落实并在 COMPLETION 终记）**：tad.sh 三处 version.txt 写点分属 `install`／`upgrade`／`migrate` 三个 ACTION 分支；仅 `install` 分支（写点在 L2673）是 CURRENT_VERSION＝"none" 的初装可达路径，genesis 写挂此分支写点之后。`install_form` 映射既有标记：SOURCE_MODE＝1 → `source`；否则（下载面）→ `download`。
- **CF-3 调用点盘清**：`resolve_chain` 全仓仅一处调用——migration-engine.sh 自身 main（L975）；tad.sh 经子进程调 engine，不 source、无第二调用点。
