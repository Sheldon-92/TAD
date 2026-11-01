# SURPLUS-REPORT — 2026-10-31（Phase 2 · PM 自跑）

- 授权：用户 2026-10-31 05:58 亲令（不等 execute 脚本修复，各席自有链路跑完已备行集）；本席口径＝16 条 auto-eligible、预算上限 +2M、EV 序、正常 Gate 纪律、连败或异常即停报 GM。
- 输入：`.tad/active/SURPLUS-PLAN-2026-10-31.json`（46 行；本报告只执行 auto_eligible 16 条；needs-human 17／stale 2 不动）。
- 执行形态：每件＝Blake 实现 spawn＋独立 Alex 评审 spawn（一角色一 spawn、上下文不共享），产物与评审件落 `.tad/evidence/surplus-phase2-20261031/<id>/`。
- 状态行随件续写：DONE（评审 PASS）／DONE-WITH-BOUNDARY（诚实边界，见注）／FAILED（原因）。

| # | id | EV | 状态 | 产物 | 评审 |
|---|---|---|---|---|---|
| 1 | release-full-version-sweep | 3.40 | DONE | .tad/hooks/lib/release-verify.sh（Layer 2 主版本集改实时推导） | PASS |
| 2 | gen-floor-check-dry-run | 2.70 | DONE | gen-floor.py＋test-gen-floor-check.py | PASS |
| 3 | handoff-volume-gate | 2.40 | DONE | handoff-creation-protocol.md step1b_5 | PASS（P3×2） |
| 4 | traces-hour-practice | 2.40 | DONE | 新能力包 production-observation＋模板＋pattern | PASS |
| 5 | repositioning-capability-acquisition | 2.00 | DONE | patterns/judgment-surface.md＋模板 | PASS（复核·限判据 8） |
| 6 | full-unconditional-round-limit | 2.00 | DONE | | PASS |
| 7 | deterministic-rules-over-llm | 1.95 | DONE | | PASS（复核·限 P1） |
| 8 | self-evolving-domain-pack | 1.80 | DONE | | PASS |
| 9 | domain-pack-monthly-refresh | 1.80 | DONE | 模板＋首轮健康检查报告（等价替代成立） | PASS |
| 10 | session-health-check | 1.80 | DONE | .tad/hooks/startup-health.sh（+67 行健康检查） | PASS（P3×2） |
| 11 | ac08-baseline-design | 1.80 | DONE | .tad/active/DESIGN-20261031-ac08-baseline.md | PASS（携带 P2×2/P3×2） |
| 12 | hook-timeout-config | 1.65 | DONE-WITH-BOUNDARY | .tad/templates/claude/settings.json＋.tad/hooks/lib/hook-timeout-test.sh | PASS-with-boundary（P3×2） |
| 13 | self-critique-generation-pipeline | 1.65 | DONE | | PASS |
| 14 | capability-builder-v1-phase4-voice-studio-dogfood | 1.65 | NOT-EXECUTED（前提不成立） | — | — |
| 15 | saveable-skills-from-conversation | 1.50 | DONE | | PASS（记录更正 P2/P3 已派修） |
| 16 | jax-extreme-parallelism | 1.05 | DONE | | PASS（P2 摘要更正已派修） |

## 逐件记录（续写）


### #10 session-health-check — DONE（评审 PASS）
- 实现：startup-health.sh 集成三类检查（hook 脚本存在＋bash -n／三版本载体一致／核心模板非空），坏件以 `⚠ BROKEN components:` 显名并入启动摘要；警告不阻塞（依该 hook 头部成文契约＋principles 软提醒定版）。
- 评审（独立 Alex，亲跑）：正常态逐字复现；损坏态自选变体（删脚本／注入语法错误／删 version.txt／删模板／单改 config 版本）全被显名、零漏检零误报；射程与子席数自报属实。P3 两条：config.yaml 本身缺失未显名；组件覆盖面为有意收窄子集（扩面建议清单自衍）。
- 口径差显名：任务书的 `.tad/config/` 目录不存在，检查对真实三载体实现，未越界建目录。

### #2 gen-floor-check-dry-run — DONE（评审 PASS）
- 实现：gen-floor.py 加 argparse 真解析（未知参数 exit 2）；--check 只读比对、零写入（stale exit 1／clean exit 0）；无参数行为与改前逐字一致。测试 test-gen-floor-check.py 在脏树夹具上以 sha256＋mtime_ns 双断言，7 条全 PASS。
- 评审（独立 Alex，亲跑＋diff 改前副本仅 31 行三处）：四条交付物全 PASS；实现方上报的既有故障属实——冻结自检锚点恰 6 条与现行载体漂移（属 NEXT 同节 (a) 项射程，未越界修）；推论已记：--check 在锚点修复前可作零副作用漂移探针。
- 收口携带：Blake 写权限外的 session-state／ralph-loops／knowledge-usage-log 三件由 conductor 收口时处置；锚点漂移归 (a) 项另单。

### #1 release-full-version-sweep — DONE（评审 PASS）
- 盘面先行事实：version-sweep 模式原已存在（实物在 .tad/hooks/lib/release-verify.sh，任务书路径 .tad/scripts/ 不存在，未另建副本）；本件修其实质缺陷——Layer 2 的 grep 主版本写死字面 `2`，对卡在 3.2.0／4.0.7 的文件全盲（idea 要治的病在闸门自身复发）。修法：主版本集合自 .tad/migrations/*-to-*.yaml 文件名实时推导 ∪ 期望主版本，IP 排除改为任意四段序列；仅动一文件（65,214 B）。
- 评审（独立 Alex，自建 fixture 双向亲跑）：改后四探针（2.15.0／3.2.0／4.0.7／9.9.7）全报、7.0.0 不报、五排除全守；副本强制回写死-2 后仅报 2.15.0——因果独立成立。显名收窄裁定**可接受**：字面全扫约 2.0–2.3K 行噪声命中（量级互证），且未发布主版本不可能成为卡版串、零真阳性损失；来源件实证病例全在覆盖集内。
- 残余：P2 推导集依赖迁移清单完整性（缓解：migration 模式已有 shipped-hop presence 断言）；P3 排除 (d) 对「同行含卡版串＋IP」散文行漏报（仅 advisory）；来源件 B/C/D 项不在 sidecar 交付物内、未做。

### #12 hook-timeout-config — DONE-WITH-BOUNDARY（评审 PASS-with-boundary）
- 实现：落点查明为框架正本 `.tad/templates/claude/settings.json`（tad.sh:4438 注明复制源、3083/3115 两处 cmp 逐字节校验，评审亲查行号全中）；字段名裁定用 Claude Code 原生 `timeout`（IDEA 的 timeout_seconds 是 OpenHarness 拼写、写进原生 settings 会被静默忽略）；三条 command handler 10s→定版 30s。
- 测试：Part A 一致性亲跑 4/4 PASS，评审自备 4 夹具（错值/缺字段/空集/合规混合）判别力全验；Part B 行为腿（挂死 hook 被切断）**未验**——本 VM 无 claude 二进制（评审与本席探针双证 `command -v claude` 无果），实现方拒绝自写 runner 冒充、明标 NOT-RUN，处置正确。闭环条件：在装有 Claude Code 的机器跑同一脚本取得 exit 0/1 并补 log 入证据目录。
- P3 两条：Part B 在 claude 未登录/异常慢时可能假 FAIL（建议加可用性前置探针）；.codex/.cursor 的 hooks.json command 型仍 10s 与定版 30s 不一致（射程外未动，待 PM 裁定是否对齐）。

### #12 hook-timeout-config — DONE-WITH-BOUNDARY（评审 PASS-with-boundary，P0/P1＝0）
- 实现：落点查明为框架模板正本 .tad/templates/claude/settings.json（tad.sh 复制与 cmp 校验为据）；字段名裁定用 Claude Code 原生 `timeout`（IDEA 的 timeout_seconds 拼写会被静默忽略）；三条 command 型 10s 改定版 30s。测试 hook-timeout-test.sh Part A 一致性 4/4 PASS、负向夹具判别力有证。
- 评审（独立 Alex，亲跑＋自备 4 夹具＋独立探 claude 二进制缺席）：配置面全成立、PARTIAL 自报诚实准确。**边界显名**：行为腿（挂死 hook 在真 harness 被切断）本机零证据——VM 无 Claude Code 二进制，实现方拒绝自写 runner 冒充、明标 NOT-RUN，处置正确。闭环条件：在装有 Claude Code 的机器上跑同一脚本取 exit 0 并把 log 补入证据目录。
- 附带观察（未动）：.codex/.cursor 两面 hooks.json 的 command 型仍 10s、与新定版 30s 不一致，待后续裁定对齐。
- 文书小瑕（conductor 侧）：本件评审任务书模板残留一行错文件名，评审按派发指令正名落件、已在 verdict 件显名——不影响结论，模板已修口径后续件注意。

### #3 handoff-volume-gate — DONE（评审 PASS，P3×2）
- 实现：step1b_5_volume_gate 插在 step1b（行 279）与 step1c（行 330）之间、评审 spawn 之前；计数口径入规程（wc -c >81920；AC grep 口径 >20）；prompt-only、明文 not_a_reject、禁 hook 化/硬拦入 forbidden_implementations。
- 评审（独立 Alex，亲跑＋临界语义自备样本）：插入位与 step 序、计数边界（> 非 >=）全过；NEXT 所记 107KB/27AC 样本不可复现的处置判诚实。P3 两条小注在 verdict 件。

### #4 traces-hour-practice — DONE（评审 PASS）
- 实现：形态裁定 Capability Pack（production-observation）：SKILL.md＋watch-list／session-protocol／failure-taxonomy-and-routing 三 references＋每周模板 traces-hour-record.md＋pattern 与索引行。自验首轮抓到 frontmatter 未引号冒号致 YAML 解析失败（包不可加载），修复后全 PASS。
- 评审（独立 Alex）：形态裁定成立（与 llm-observability 分工在两包文本双向写明）、包可加载性亲验过；发版面注册四步留发版步、实场 Traces Hour NOT-RUN（本仓无生产 trace 源）均判诚实。**P2 一条**：失败分类把 F2/F3 的 eval-case 候选路由到「trajectory-eval harness」——该 harness 仓内不存在（前提继承自 IDEA 原文、实现方未验存在性），回流四腿中此腿暂落不了地；随发版注册步一并处置（改指 ai-evaluation 现行面或包内显名暂存）。P3：behavioral eval 为发版定 status 的前置、非可选。

### #9 domain-pack-monthly-refresh — DONE（评审 PASS，等价替代成立）
- 盘面前提更正：目标 tools-registry.yaml 已随 YAML Domain Pack 机制（2026-06-11 退役）冻结于 .tad/archive/domains/ 作审计轨迹，.tad/domains/README-retired.md 在盘。实现方以「模板＋只读审计＋changelog、归档零编辑」等价履行——评审一手查证退役事实后裁定成立。
- 首轮健康检查实测：注册表 80 能力／99 工具、last_updated 停 2026-04-02（212 天未更新）、仅 41/99 标 tested；9 个 live pack 结构全健康（镜像哈希一致）；Web 候选 7 项只登记未采纳。计数经评审亲算抽验。

### #5 repositioning-capability-acquisition — 评审 FAIL（限判据 8）→ 整改中
- 指南面全 PASS：反射规则双条件与 IDEA 收敛节逐项对应、化石两例证据标注诚实、L1/L2 分层守住、README 不动裁定成立（实现方对）。
- FAIL 一条（实质）：模板导出只对上字段名、值域四处不合 Feedback JSON Schema v1.0 正本——verdict 枚举（keep/reject 非正本 ok/delete/replace）、selector_type 写死 manual（正本 css/time_range/spatial/semantic 且 CONFIG 无此字段）、structured_feedback 被挪用塞打分（正本定型 {text,style,position}）、priority 预填 medium（正本 null if not set，且抵触指南自身反锚定规矩）。评审以 node 真执行 collect() 坐实；实现方自备校验只验字段名不验值域、「逐字段对齐」主张不成立。
- 处置：按 verdict 件 5 条整改点派 Blake 修复＋独立复核判据 8，不重做指南面。
- 整改与复核（已闭环）：五点全落（verdict 正本枚举／selector_type 入 CONFIG 默认 semantic／structured_feedback 复原定型＋打分移 scores／priority 去预填未评审导出 null／校验升级为真执行 collect() 断言值域 18 PASS）；原 COMPLETION「逐字段对齐」不实主张已在 FIX 件逐字点名作废。复核（独立 Alex）自备探针加严复验（delete 值透传、双候选同改 css、仅 position 有值、未评审元素 priority 拨 high 仍导出 null）全过，判据 8 转 PASS、本件全判据 PASS。留痕一条（conductor 接受）：COMPLETION 本件内未加指向 FIX 的指针注记，单读它看不到作废指针——FIX 逐字点名作废＋本报告在账，链路可溯，形态可辩护，不另派修。

### #11 ac08-baseline-design — DONE（设计评审 PASS，带携带）
- 设计件 DESIGN-20261031-ac08-baseline.md（19,650 B）：问题定性全有一手出处（AC-08.py 的 check() 首错 sys.exit(1)、后段检查整段没跑、「完整 FAIL 集仅两条 E1」靠工具外人工担保；基线无分类、豁免靠脚本内硬编码两条单路径）。
- 四类边界 S/T/X/R＋五步有序判定程序（集外 fail-closed）＋豁免登记册设计（数据非代码、运行中不可增改）；全量 diff 报告＝collect-and-continue＋双口径并印防洗真问题＋JSON 侧车；后续实现验收 AC1–AC6。
- 评审（独立 Alex，亲读 AC-08.py 全文＋自走判定程序验 4 件实物归类全合）：设计成立、可作实现票开工依据。携带入实现票 Gate 2：P2×2（§1 两处数字与原件不合须更正——126 行总长/113 PASS 非「约 157」；AC2 重跑底座未钉、Gate 2 先锁捕获件与 --root 重建法）、P3×2（判定程序第 1 步补 T-未枚举路由句；AC3 与 §8 开放问题的退出码口径注）。

### #14 capability-builder-v1-phase4-voice-studio-dogfood — NOT-EXECUTED（前提不成立，扫描误分类）
- conductor 前提核查（2026-10-31 亲查）：交付物输入「accepted SCAND-20260606-eval-page-generator＋四份真实使用证据锚」在 Voice Studio 仓与 TAD 仓全树检索均不存在（find SCAND-* 零命中、eval-page 零命中、.tad/evidence/capability-builder/ 目录不存在）；EPIC- capability-builder-v1 Phase 4 原文亦以该 SCAND 在 Voice Studio 项目内为输入。
- 第二重不成立：Phase 4 验收含「human business acceptance」——交付物自带人闸，与 auto-eligible（无人拍板）的分类定义相抵，本行系 Phase 1 扫描误分类（与 musecloud 席首跑的路径误判同类，记为扫描质量数据）。
- 第三重：目标路径全在 Voice Studio 项目内——该项目 2026-10-05 已退出 PM 体系、归用户直管，不在本席链路射程。
- 处置：本轮不执行、不跨界代跑。建议去向：由用户/GM 交 Voice Studio 对话按其本链推进（或先定位 SCAND 实体——不排除同步分区未收敛所致的他机在盘）；本行 sidecar 与排名保留，再跑时须先复核前提并降为 needs-human。

### #13 self-critique-generation-pipeline — DONE（评审 PASS）
- 实现：五阶段管线协议（.tad/skill-library/self-critique-pipeline.md）＋过滤脚本 self_critique_filter.py（唯一交付通道）＋演示轮：6 候选→交付 3、keep ratio 0.50（健康带内）；弃 3 件各有实据（两件既有知识弱化复述、一件多项不合格）；通过件只以 draft 入册、升正式仍走陌生人蒸馏/Gate（协议明文，不冒充独立评审）。
- 评审（独立 Alex）：/tmp 副本删 run-log/shipped 后亲跑复现（输出逐字合）、自建畸形批次验 exit 2 零交付、通过件 candidates==shipped==入册三方逐字节一致、弃件理由逐条对原文成立。transcript mining 半部定为 Stage 5 扩展点，记边界不作 FAIL。
- conductor 小注（评审显名、不归实现方）：本席评审任务书把来源件日期引作 IDEA-20260717，协议/完工件所载为 IDEA-20260703——引用出入在本席，未影响判据（评审按协议内 rubric v1 核判）。

### #8 self-evolving-domain-pack — DONE（评审 PASS，仅 Stage 1 按口径）
- 实现：domain-trace.py 记录器（九字段 schema、jsonl 落 evidence/domain-traces）观测式接线进 pack-eval-runner.sh（发射挂真实运行路径、|| true 守护、DOMAIN_TRACE=0 可关）；Stage 2/3 未做在记录器头部、接线文档、完工件三处显名，接线文档另明文「不得被引为自优化已上线」。
- 评审（独立 Alex，/tmp 假根整套复制亲跑）：接线开/关两跑 stdout 逐字节一致；把记录器换成恒 exit 1 的桩、再整件删除，主流程输出仍与基线逐字节一致（守护是行为事实）；validate 5 事件 0 违规、demo log 与 jsonl 逐行对账合。

### #15 saveable-skills-from-conversation — DONE（评审 PASS，带记录更正）
- 实现：提示落真实装载点（alex/SKILL.md load_when 整份加载的 discuss/bug 两 references，评审逐行核 L658–664）；两协议纯新增（+34/+24 行、删 0）；轻路径约定自洽（T2 实质收敛为会话内一次确认、与 *save-skill 不混库、T3 规则未动）；worked example 逐条对得上各席当日真实记录。
- 评审 PASS，确认腿 NOT-RUN 判可接受（伪造点击即造假证据；待首次真实触发补一行实证）。两处记录面问题交收口：P2 完工件「四件 yaml.safe_load 全 PARSE OK」按字面不可复现（bug 文件首行 HTML 注释致整份加载改前改后均 FAIL、跳注释行后两版均可解析），须补解析口径更正；P3 DEMO §1 把「54 条作废」误挂 Menu 席、实属商业洞见席（已入册条目本身归属正确）。更正已落盘（FIX-SAVEABLE-RECORDS.md：三处注记留痕式落明、原句不删，落笔前亲跑解析复核与评审口径逐项相符）。

### #7 deterministic-rules-over-llm — 评审 PASS（P1 一条，整改中）
- 实现：intent-route.py 把 intent-router step2 信号计数机械化（计数语义钉死在脚本头 CONTRACT）；双标签 38 样本 spec 一致率 38/38、semantic 32/35（91.4%，3 分歧皆已知天花板）；learning filter（intent-overrides.yaml，出厂空规则）演示端到端成立；基线诚实（仓内无可执行 LLM router、未虚构数字，评审全文扫确认）。
- 整改与复核（已闭环）：load_overrides 对缺 reason（缺失/空串/纯空白）条目逐条拒绝生效、stderr＋输出 JSON 双通道显名告警、坏条不拖垮整批；基准复跑零退化、出厂 overrides 文件 sha 未变。复核（独立 Alex）自备六组探针全过、显式命令早退路径亦显名，本件全判据关闭。
- 评审（独立 Alex）亲跑基准逐行零差异复现、守卫与去重探针全过。**P1**：「每条 override 强制带 reason」只有文书强制、无机械强制——无 reason 的 force_route 被静默接受生效（输出以 reason:'' 显形、可审计但约束未执行）；完工件无限定表述偏强。conductor 裁定走评审整改点甲案：load_overrides 对缺 reason 条目拒绝生效并告警（与 unknown mode 同型），已派修＋定点复核。

### #6 full-unconditional-round-limit — DONE（评审 PASS）
- 实现：无条件轮次上限入全通道 loop 机器——载体为 handoff 内 Gate Rounds 阶段边界追加表，计数靠行派生、无存储计数器（跨 compaction 不丢）；G{n}≥3 或 TOTAL_ROUNDS≥6 输出 NO-PROGRESS 熔断并停；consecutive_same_error 逐字保留。五文件纯插入（评审 diff 验删除/改写行全 0）。
- 评审（独立 Alex）：机械测试亲跑复现 44 断言全 PASS 且输出与盘存逐字节一致；三处显名适配逐项专判全成立（归档锚点已漂移改挂派发前计数时点为唯一自洽承重／TOTAL 只计非 PASS 终态防全 PASS 链误熔断、算术成立且 deviation 注记在文／.claude/skills 符号链接同 inode、parity 结构性成立）。P3 一条：deviation 注记一句措辞可收紧，不返工、后续触碰时顺手改。活体 spawn 行为腿 NOT-RUN 处置判诚实可接受。

### #16 jax-extreme-parallelism — DONE（评审 PASS，有界版）
- 实现：评估报告落 .tad/research-notebooks/——全量移植 NO-GO（基线吞吐与时间构成从未测、真成本在卡牌效果长尾而非 vmap 机制）；有界 spike 条件 GO（四条件钉死：基线在场测构成／GPU 一台／最小内核＋同种子差分／端到端未达 10× 即停）。机制面论证 TCG 可 JAX 化（60 张牌库封顶→定长数组＋掩码、单动作步进、洗牌与不完全信息机制无碍），Jaxpot「1 亿步/秒」明文禁止搬运。CPU 代理微基准仅标机制开销（整段编译 2.2M–9.7M steps/s、填充税实测与浪费率线性），未验五项显名。
- 评审（独立 Alex）PASS：18 个数值逐字对账、自建同版 venv 亲跑数量级零漂移、前提（无 GPU/基线零命中）与清理（583M venv 已删）盘面复核属实。P2 一处：§0 摘要「100–500×」与自家 §1 数据重算（49.7×–358.5×）对不上（数据本身完整属实披露、不构成造假），已派更正为「约 50–360×」留痕。

## 收口总账（2026-10-31 定稿）

- **终态 16/16**：DONE 14（#1/#2/#3/#4/#6/#7/#8/#9/#10/#11/#13/#15＋#5 整改后 PASS＋#16 有界版）、DONE-WITH-BOUNDARY 1（#12 hook 超时：框架面定版落盘、行为腿待有 Claude Code 的机器补跑同脚本销边界）、NOT-EXECUTED 1（#14 前提不成立：输入 SCAND 盘面不存在＋交付物自带人闸属扫描误分类＋目标在用户直管项目）。
- 形态分布（诚实口径）：等价替代 1（#9 目标注册表已退役冻结）、设计件 1（#11）、有界版 1（#16 无 GPU/无基线）、边界版 1（#12）。
- 评审总账：独立评审全覆盖；FAIL 1（#5 判据 8，整改＋复核闭环）；PASS-with-P1 1（#7，整改＋复核闭环）；记录更正 3（#15 P2/P3、#16 P2，均留痕落盘）；P2/P3 携带若干（#4 路由目标不存在、#11 两数更正与 AC2 底座、#12 两面 hooks.json 不一致等，均显名入各件记录或后续票）。
- **conductor 自报两错（在账）**：① 第二波五份评审任务书生成切坏一段、每份残留一行他件旧口径——逐份核过结论未受污染、生成法已改（整句 replace＋grep 自查）；② #13 评审任务书来源件日期引用出入（20260717 vs 20260703），评审显名、未影响判据。
- **收口三件裁断**（多件完工件共同上报的规程摩擦：session-state 更新／ralph-loops 落盘／knowledge-usage-log append 在单件任务书写权限之外）：本轮各件均未自行动、完工件内 KA/Friction/Evidence 齐全，信息无损；三件属框架级收口书写，归 4.0.9 批次收口与修复链 Epic 收口时统一回写，本报告即本轮总账载体。此裁断为 conductor 处置、非各件欠账。
- 预算口径：用户预批 +2M 上限内运行；本席无 token 级计量面（同缺陷一的记账缺口），不报伪造花费数——执行件数与评审件数即本轮可对账量：实现 16 派＋整改 4 派＋评审/复核 17 派，另设计链（EPIC-20261031）独立在跑、不计入本轮。
- 后续承接：TICKET-20261031（签认层）与 IDEA-20261031（已升 EPIC-20261031 在跑）均排 4.0.9 批次/独立链；step3f 与 downstream-versions 仍按既有时序等 GM 升级收口通告。
