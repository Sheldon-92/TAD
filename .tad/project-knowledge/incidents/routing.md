# Incidents 检索路由（三层索引：家族 → 子簇 → 逐件钩子行）

本件只在 incidents 语料面验证过（单轮、13 题预注册子集、文件级粒度）；常设形态同限于此面，不证明可扩展到其它知识面。
本件为纯文本结构路由，无向量后端；ChromaDB 许可证检查仍挂账，不在本件内解决，也不在本件名义下引入后端。
patterns 面条目级粒度不在本件范围；本件不收 patterns 条目。
引用本件的验证结论时须连同上述限定一并引用。

维护规则见 `incidents/_index.md` 头部：新 incident 入册时同改动内补本文件 drawer 行。

## Wing: ac-verification

### Room: grep-count-commands

- [ac-verification-command-bug](2026-05/ac-verification-command-bug.md) — grep -ocE | sort -u | wc -l 对单文件恒返回 1；去 -c 改 grep -oE 才数得出互异命中（vimax AC15 案）
- [ac-grep-count-reference-pack](2026-05/ac-grep-count-reference-pack.md) — 参考文件名在 pack SKILL.md 里出现两次（Context Detection 行＋Quick Rule Index 标题），grep -c 型 AC 期望值须写 =2 不是 1

### Room: region-marker-extraction

- [section-9-1-region-marker](2026-05/section-9-1-region-marker.md) — handoff 的 §9.1 实为 ### 9.1（三井号，挂在 ## 9 下）；按 ## 9.1 匹配会扫空区并报假干净

## Wing: gate-design

### Room: reviewer-blind-spots

- [expert-reviewer-premise-check](2026-05/expert-reviewer-premise-check.md) — 评审者把裸 CLI（~/.tad-notebooklm-venv/bin/notebooklm ask）误认成 *research-notebook ask；须标注 (Raw CLI — NOT *command)
- [layer2-audit-reviewer-name-drift](2026-05/layer2-audit-reviewer-name-drift.md) — Blake 落盘名 code-review 与审计表 KNOWN_REVIEWERS 的 code-reviewer 不一致，致 DISTINCT_COUNT=0；评审文件按 sub-agent 类型命名

## Wing: memory-and-learning

### Room: self-triggering-parsers

- [parser-self-trigger](2026-05/parser-self-trigger.md) — 正文逐字引用发现标签正则（^#+ *P0、竖线 P0 竖线）会自触发 trace 解析器、凭空造出一条 P0；记录发现时勿与解析器共用命名空间

## Wing: pack-build-rules

### Room: parity-checks

- [codex-edition-parity](2026-06/codex-edition-parity.md) — 版本对等＝三层判据（覆盖＋约束守卫＋能力标记）配 9 项 expected-absent 白名单；grep -c 配 || echo 0 会双写输出，须用 || true
- [cross-agent-parity-check](2026-06/cross-agent-parity-check.md) — Layer-3 标记写死（research_complexity、step4_5）会误杀 Blake 版；每标记须按源文件有无条件化，无头重生走 codex exec stdin

### Room: skill-migration

- [scienceclaw-skill-decoupling](2026-05/scienceclaw-skill-decoupling.md) — ScienceClaw 285 个 skill 对 plugin-sdk 的运行时 import 为 0/285；迁移范围先 grep 运行时引用再定，判断规则可移植、包装层不可

## Wing: pack-evaluation

### Room: pack-value-measurement

- [pack-value-non-monotonic](2026-06/pack-value-non-monotonic.md) — 包的 Δ 在 Sonnet 档见顶而非 Haiku（rag Δ12 大于 Δ8）：内容丰富的包超出弱模型的应用能力；各档 CONTROL 地板恒 0–5
- [pack-value-cross-vendor](2026-06/pack-value-cross-vendor.md) — 包价值跨厂商成立（Codex Δ6–9、Gemini Δ6–12）；Codex 输出简洁会少引数字密集型包，判价值看 Δ 与 CONTROL 地板不看原始计数

### Room: quality-and-rubric-review

- [scoring-rubrics-need-methodology-review](2026-05/scoring-rubrics-need-methodology-review.md) — 参考文件里的 0–5 评分量规须过 ux/方法论评审：相邻分值定义重叠（2 与 3 之别）对 code-reviewer 不可见
- [academic-research-pack-pilot](2026-05/academic-research-pack-pilot.md) — 酱油试点：深度下限仅建议、非阻塞（工具调用 17 次、低于 20 照样交付）；加 Tier 1–4 证据分级（USDA 5493mg）

### Room: collision-detection

- [pack-collision-detection](2026-05/pack-collision-detection.md) — 跨包冲突与单包评测正交：precedence 只解跨带冲突、同带升级人工；CJK 文本 comm -12 不带 LC_ALL=C 会伪造共享关键词

## Wing: principles-linked

### Room: copy-set-deny-list

- [derived-copy-set-dotfiles](2026-06/derived-copy-set-dotfiles.md) — cp -r src/* 漏 dotfiles（只含 .gitkeep 的目录落空）；拷内容用 cp -R src/. dst/，并配在位加非空自检
- [embedded-copy-drift-check](2026-06/embedded-copy-drift-check.md) — 内联 DENY_LIST 的漂移检查须从 lib 原地重导集合（awk 抽 ZERO_TOUCH 加 TRANSIENT）再以 LC_ALL=C 排序集 comm，禁止第三份写死副本

### Room: role-and-extraction-discipline

- [alex-role-decay-direct-execution](2026-06/alex-role-decay-direct-execution.md) — Alex 角色衰减后跨 14 个项目直跑隔离移动（25,312 文件）；TAD 仓外任何 mv/rm 按定义属 Blake 类工作
- [progressive-disclosure-extract](2026-05/progressive-disclosure-extract.md) — 只抽 0-约束-token 的块（MUST 计数守恒 131）；自底向上切片、边界实时重导、col-0 键清单 diff 为空作证

### Room: audit-validation-theater

- [ad-hoc-dead-code-audit](2026-05/ad-hoc-dead-code-audit.md) — 临时死代码扫描把约 20 个活函数误标 DEAD（含在制中的 emit_*）；逐项回文件核实、先查有无在飞工作再下结论

## Wing: research-methodology

### Room: cli-orchestration-constraints

- [codex-agents-md-auto-load](2026-05/codex-agents-md-auto-load.md) — Codex 与 Claude Code 一样自动加载项目根 AGENTS.md；角色触发短语须至少 8 条，Default Behavior 守卫拦 Blake 域外的 handoff 读取
- [gemini-cli-constraints](2026-05/gemini-cli-constraints.md) — Gemini CLI 无 -p 在非 TTY 下挂死、-p 模式只读；其 PCRE 正则用于 hook 前须先在 macOS 上以 grep -E 验过

### Room: source-import-quality

- [chattts-consistency-pattern](2026-05/chattts-consistency-pattern.md) — ChatTTS 在 16GB Mac 上批量 infer() 不实用（25 分钟以上）；逐段 torch.manual_seed(42) 加保存 spk_emb 为 narrator.pt（约 4KB）保音色一致

## Wing: shell-portability

### Room: sed-path-normalization

- [anchorless-tad-sed](2026-06/anchorless-tad-sed.md) — sed 's,.tad/,,' 对相对路径 ls 输出剥离不一致（拼出 .tadactive/）；glob 带前导斜杠并锚定 s|.*/\.tad/||
- [line-anchored-blockquote-sed](2026-05/line-anchored-blockquote-sed.md) — 单行大于号引文块（CONSUMES 与 PRODUCES 同行）：行锚 sed 只索引第一个标记；去引文块前先把双标记行拆开

### Room: routing-label-grep

- [claude-md-routing-label-conflicts](2026-05/claude-md-routing-label-conflicts.md) — 路由关键字被复用为注记标签前缀会让 grep -c 得 2 非 1；排除与注记行须用唯一标签前缀
