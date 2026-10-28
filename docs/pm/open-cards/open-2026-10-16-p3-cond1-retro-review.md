# 派发任务书 — 追补复核：EPIC-20261006 Phase 3 Gate 4 条件 1 销账（TASK-20260916）

## §0 开跑卡
【开跑卡】
项目名: TAD
Epic位置: 合规抽查 B 组红项处置（对象＝EPIC-20261006 Phase 3 收口步）
role: Alex
任务名: 条件 1 销账追补独立复核（retro-review）
channel=internal-subagent
model=Muse 原生 subagent（独立会话、未参与该 phase）
env=VM 本机，目标仓本机副本（只读核查＋verdict 落盘）
目的: 独立核 EPIC-20261006 Phase 3 Gate 4 条件 1 在 2026-10-12 时点是否已被盘上证据满足，出追补 verdict 治愈合规抽查红项

## §1 激活（缺一不开跑）
- 先加载 skill 壳：`~/workspace/skills/tad-alex/SKILL.md`，按其激活协议进入目标仓读 TAD 原件（AGENTS.md → principles → patterns 索引 → brain-index 路由 → 本步规程与判据原件）。
- $REPO = /home/hatch/workspace/yun-sync/TAD
- 开工第一件产物＝激活自报：写明已读原件清单（路径）与本步判据出处；自报随 verdict 件同文件落盘（文件首节）。无自报，PM 不验收。

## §2 本步定位与判方
- step_kind: Gate 4 条件销账的追补独立复核（retro-review）。你未参与 EPIC-20261006 Phase 3 的设计、实施、Gate 3 双审与 2026-10-12 收口，满足独立性。
- tad_scope: 只核一件事——独立 Alex Steve 于 2026-10-06 出具的 Gate 4 CONDITIONAL 之条件 1（「Codex 真机基线补跑＋台账重验」，原文以 gate4-alex.md 为准），在 2026-10-12 收口时点是否已被盘上证据满足。PM 于 2026-10-12 自行裁定销账并升 PASS、且自任 TASK-20260916 关票验收，无独立复核件在盘（合规抽查 B 组红项）；你的 verdict 是该销账的追补独立判断。
- tad_basis: 判据原件，逐一读盘：
  1. `.tad/evidence/reviews/epic-p3-runtime-20261006/gate4-alex.md`——条件 1 原文与 CONDITIONAL 总判。
  2. `.tad/evidence/pm/2026-10-12-p3-condition1-task20260916-closeout.md`——PM 收口裁定（被复核对象）：其事实主张逐条列出核对。
  3. `.tad/active/TICKET-20260916-codex-ledger-reverification.md`——票面 Done 判据（关票节在内）。
  4. 条件证据本体：`.tad/evidence/step3f/claude-code-20261009.md` 等四家基线件、台账现况（`.tad/capabilities/` 下 codex 相关台账文件，以收口件所引为准逐一对盘）、2026-10-12 freshness 实跑记录（收口件与 now.md 所引；仓内若有日志件以其为据，无日志件则注明「当日实跑仅有收口件自述＋PM 复跑陈述」，按现有证据判，不许假设）。

## §3 通过标准（verdict 形态）
- 逐条核收口件的事实主张（基线四家成件、台账 12 条已重验且两保留点诚实留注、freshness Total 42 全 PASS），每条给出：在盘／不在盘／与主张不符，附盘上路径或行号指针。
- 总判 VERDICT: PASS 或 FAIL（可附条件说明，但总判必须二值）：PASS＝条件 1 在 2026-10-12 时点已被盘上证据满足，升判与关票可维持；FAIL＝指出哪条主张不成立、缺什么，PM 将据此重开。
- 时点纪律：你判的是「2026-10-12 时点证据是否满足条件」，不是今日仓面状态；今日盘面与当日记录冲突时，以当日成件为准并注明差异。

## §4 证据落盘
- verdict 正本：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/reviews/epic-p3-runtime-20261006/gate4-condition1-retro-review-20261016.md`（首节＝激活自报；含逐条核对表与 VERDICT 行）。
- 只写这一个文件；其余一切只读。

## §5 角色与禁止事项
- 你是 Alex（Solution Lead），独立判断；不得与 PM 商量结论措辞，判完直接落盘。
- 禁止：修改任何既有文件（收口件、票面、台账、代码）；运行 tad.sh 或任何安装器；git 提交/推送；访问目标仓之外的仓；把 PM 的自述当作证据（PM 陈述只作待核主张）。
- 工具纪律：同步目录内跑 python 须带 PYTHONDONTWRITEBYTECODE=1；freshness 如需复跑，只许只读运行并把结果写入你的 verdict 件，不改仓面。

taint_external: no
taint_private: no
taint_outbound: no
