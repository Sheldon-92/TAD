# LITE Handoff: Full 能力 inventory 与 Lite-Skill composition contract

**Date**: 2026-08-09
**Series**: full-capability-retirement step 1/8（其余步：release、deps、secondary、migration、burn-in、deprecation、removal）
**Epic**: `.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md` Phase 1–2
**Grounded Against**: `4116517`

## 目标

在创建任何新 capability skill、修改 Lite 协议或删除 full 文件之前，先交付一份机械覆盖的
full 能力 inventory，以及一份 Lite 调用专项 skill 的架构契约。它们要回答三件事：full 到底
有哪些现役能力、每项能力去哪里、skill 如何被 Lite 调用而不扩大权限或复制状态。

为什么先做这一步：当前 full 有 35 个 canonical 文件、30 个 Alex reference 和多个已有独立
skill；直接“开始搬”会同时制造遗漏、重复 skill 与 full 2.0。Phase 1–2 只建立可审查的决策
底座，不创建成品 skill，不改变任何运行时行为。

## 不做什么

- 不修改 `.claude/skills/**`、`.agents/skills/**`、`CLAUDE.md`、`AGENTS.md`、`tad.sh`、
  `.tad/hooks/**`、安装器、版本号或发布物。
- 不创建 `release`、`dependencies`、`tournament` 等成品 skill；本单仅定义候选与资源计划。
- 不读取任何下游 `HANDOFF-*.md` 正文；只允许统计文件名、数量和安装状态。
- 不迁移下游、不归档 handoff、不执行 publish、sync、tag、push 或依赖升级。
- 不把建议性 composition contract 写进 Lite skill；因此本单不新增生效中的 MUST/BLOCKING 约束，
  也不修改约束定价台账。
- 不用固定总行数或 token 上限评价设计；检查覆盖、权限、状态、恢复与测试语义。

## 文件清单

### 创建

1. `.tad/evidence/designs/full-capability-extraction/capability-disposition.yaml`
2. `.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md`
3. `.tad/evidence/designs/full-capability-extraction/generate-inventory.sh`
4. `.tad/evidence/designs/full-capability-extraction/source-inventory.tsv`
5. `.tad/evidence/designs/full-capability-extraction/legacy-handoff-manifest.tsv`
6. `.tad/evidence/designs/full-capability-extraction/composition-negative-fixtures.yaml`
7. `.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md`
8. `.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md`

### 允许追加

- 本 handoff 的 `Lite Progress`、`Completion`、`Reflexion`。

### 不修改

- 本 Epic 由 Alex-Lite 在人工验收后更新；Blake-Lite 不改 Epic。
- 所有 active runtime、skill、routing、installer、hook、knowledge 与 registry 文件均不改。

## 交付规格

### A. `generate-inventory.sh` + `source-inventory.tsv`

生成器只读仓库与 registry，接收两个显式输出路径：source raw TSV 与 legacy handoff manifest。
不得写固定 `/tmp` 文件、不得读取 handoff 正文。source raw TSV 使用三列：
`TYPE<TAB>VALUE<TAB>SOURCE`；交付的 mapped TSV 增加第四列
`CAPABILITY_IDS`（逗号分隔、至少 1 个已声明 ID）。至少包含：

- `canonical_file`：`.claude/skills/{alex,blake,gate}` 的全部现役文件；
- `mirror_file`：对应 `.agents` 文件，并记录 byte parity 结果；
- `legacy_trigger`：Alex/Blake Quick Reference 与现役路由文档公开的 full 命令；
- `standalone_skill`：YAML `existing_equivalents` 引用的现有独立 skill；
- `route_consumer`：全仓 tracked + untracked 搜索后，现役文档、安装器、校验器中暴露或消费 full 的文件；
- `live_contract_consumer`：所有 active `HANDOFF-*.md` 无条件按文件名纳入、禁止读取正文；
  其它 `.tad/active/` 契约仅在内容扫描确认引用 full 时纳入；
- `downstream_summary`：注册项目总数、可访问/失效、full/Lite 安装数、active full handoff 数。

`downstream_summary` 恰好一行，VALUE 固定序列化为：
`registered=N;reachable=N;missing=N;with_full=N;with_lite=N;active_full_handoffs=N`，
SOURCE 固定为 `.tad/sync-registry.yaml`。

legacy triggers 必须从 Alex/Blake `### Key Commands` 块和现役路由表生成，不凭手抄。
route consumer 搜索必须合并 `git grep` 与 untracked 文件扫描。排序使用 `LC_ALL=C`；不得把
`.tad/archive/`、`.tad/evidence/`、`.tad/memory/` 或备份目录当作现役消费者；`.tad/active/`
必须单独归入 `live_contract_consumer`，后续物理删除前其每项都必须有明确处置。
mapped TSV 的前三列必须与生成器 fresh raw 输出集合相等；第四列的每个 ID 必须存在于 YAML。

`legacy-handoff-manifest.tsv` 每行：
`PROJECT<TAB>REACHABILITY<TAB>ROOT_RELATIVE_HANDOFF_PATH<TAB>MIGRATION_STATE`。
`MIGRATION_STATE` 本单固定为 `pending|missing-project`；只列文件名与相对路径，不读正文；同一
project/path 不得重复。该 manifest 是 Phase 6 的迁移输入，不能只留 37 这个汇总数字。

### B. `capability-disposition.yaml`

顶层键：`schema_version`、`generated_at`、`grounded_against`、`baseline`、`capabilities`。
每个 capability 条目字段：

```yaml
- id:
  summary:
  source_files: []
  legacy_triggers: []
  existing_equivalents: []
  route_consumers: []
  carrier_paths: []
  disposition: EXTRACT|EXTEND|EXISTING|LITE_NATIVE|RETIRE|HISTORY_ONLY|DECISION_REQUIRED
  target_skill:
  supported_roles: []
  modes: []
  safety_class: normal|human-gated|history-only
  migration_dependency:
  rationale:
  trigger_examples: []
  resource_plan: {}
  forward_test_prompt:
```

`generated_at` 与所有日期值必须是加引号的字符串，禁止让 YAML 隐式解析为 Date。
所有数组/字符串/map 字段类型封闭；`safety_class`、`supported_roles`、`modes` 使用封闭枚举。

必须显式覆盖以下战略能力 ID，不得合并成一行“其它”：

`release-ops`、`dependencies`、`tournament`、`ideas`、`status-roadmap`、`research`、
`parallel`、`surplus-yolo`、`product-architecture`、`lite-design-handoff`、
`lite-execution-gates`、`full-router-startup`、`legacy-handoff`。

判定纪律：

- 已有独立 skill 真覆盖 → `EXISTING` 或 `EXTEND`，不新建重复 skill；
- Lite 主流程已覆盖 → `LITE_NATIVE`；
- 有价值但无现役等价物且有 carrier → `EXTRACT`；
- 无 carrier 或价值尚不清楚 → `DECISION_REQUIRED`，不得用作者偏好伪装成 `EXTRACT`；
- 只服务旧 `HANDOFF-*` → `HISTORY_ONLY`；
- 固定启动费、重复路由或无价值入口 → `RETIRE`。

### C. `skill-composition-contract.md`

标题必须为 `# Architecture Decision Document`，完整记录 D1–D10，并给出：

1. Lite Core + Capability Skills 拓扑；当前 Lite 角色是唯一任务状态所有者。
2. Skill manifest 候选字段：`name / description / supported_roles / modes / inputs / outputs /
   allowed_writes / safety_class / human_approval_required / evidence_contract / rollback / version`。
3. 权限模型：有效权限取 Lite、skill、人工授权的交集；skill 不得覆盖角色分离、安全停、契约范围或 reviewer。
4. 生命周期：discover → select → pin in handoff → load → execute/verify → unload；压缩恢复只重载被 pin 的 skill/version。
5. 冲突处理：多个 skill 冲突时 fail closed，回 Alex-Lite 做契约决策；不得由执行侧即兴选胜者。
6. 可观测性字段：`skill_selected / mode / version / approval_id / verdict / evidence_path`。
7. D9 验证：schema、角色边界、坏输入、权限旁路、压缩恢复、幂等/重试、真实 dogfood。
8. 对每个 `EXTRACT/EXTEND` 候选给至少 2 个真实触发例、非空资源计划
   （SKILL/references/scripts/assets）和 forward-test 提示；数据写进 YAML，contract 用
   `## Candidate: <id>` 一一展开；遵循 skill-creator 的简洁、渐进披露、低/中/高自由度选择。
9. 成品 skill 未来落点为 `.claude/skills/<name>/`，经框架 parity 机制产生 `.agents` 镜像；本单不初始化目录。
10. 普通 Lite 任务不命中专项能力时，新增正文加载为 0。

### D. `composition-negative-fixtures.yaml`

这是下一阶段 runtime 测试的规范 fixture，不伪称本单已经执行尚不存在的 composition runtime。
每条含 `id / input / expected_verdict / expected_reason / required_evidence / decision_ids`。至少覆盖：

- skill 请求超出 Lite 角色写权限；
- handoff pin 的 skill version 与恢复时版本不同；
- 两个 skill 对同一动作给出冲突规则；
- 一次性人工授权被重复消费；
- skill 尝试另建任务状态；
- publish/sync 超时后的重复动作请求。

全部 `expected_verdict` 必须是 `DENY` 或 `BLOCKED`；Phase 3 建 runtime 时必须让这些 fixtures
成为可执行回归测试，本单只验证 fixture schema 与 D9 的测试映射完整。

## AC

- AC1: **YAML schema、类型与枚举封闭。**
  ```bash
  ruby -ryaml -e '
    f=".tad/evidence/designs/full-capability-extraction/capability-disposition.yaml"
    d=YAML.safe_load(File.read(f), permitted_classes:[], aliases:false)
    top=%w[schema_version generated_at grounded_against baseline capabilities]
    abort "top" unless d.is_a?(Hash) && d.keys.sort==top.sort
    abort "version" unless d["schema_version"]==1 && d["grounded_against"]=="4116517"
    abort "date" unless d["generated_at"].is_a?(String)
    b=d["baseline"]; bkeys=%w[registered reachable missing with_full with_lite active_full_handoffs]
    abort "baseline" unless b.is_a?(Hash) && b.keys.sort==bkeys.sort && b.values.all?{|v| v.is_a?(Integer)}
    fields=%w[id summary source_files legacy_triggers existing_equivalents route_consumers carrier_paths disposition target_skill supported_roles modes safety_class migration_dependency rationale trigger_examples resource_plan forward_test_prompt]
    disp=%w[EXTRACT EXTEND EXISTING LITE_NATIVE RETIRE HISTORY_ONLY DECISION_REQUIRED]
    roles=%w[alex-lite blake-lite]; modes=%w[plan execute verify]; safety=%w[normal human-gated history-only]
    rows=d["capabilities"]; abort "rows" unless rows.is_a?(Array) && !rows.empty?
    rows.each do |r|
      abort "fields" unless r.is_a?(Hash) && r.keys.sort==fields.sort
      abort "id/string" unless r["id"].is_a?(String) && !r["id"].strip.empty?
      abort "strings" unless %w[summary disposition target_skill safety_class migration_dependency rationale forward_test_prompt].all?{|k| r[k].is_a?(String)}
      abort "arrays" unless %w[source_files legacy_triggers existing_equivalents route_consumers carrier_paths supported_roles modes trigger_examples].all?{|k| r[k].is_a?(Array) && r[k].all?{|v| v.is_a?(String)}}
      abort "enum" unless disp.include?(r["disposition"]) && safety.include?(r["safety_class"])
      abort "role/mode" unless (r["supported_roles"]-roles).empty? && (r["modes"]-modes).empty?
      plan=r["resource_plan"]; pkeys=%w[skill references scripts assets]
      abort "resource" unless plan.is_a?(Hash) && plan.keys.sort==pkeys.sort && plan.values.all?{|v| v.is_a?(Array) && v.all?{|x| x.is_a?(String) && !x.strip.empty?}}
    end
    ids=rows.map{|r| r["id"]}; abort "duplicate" unless ids.uniq.length==ids.length
    puts "AC1-PASS rows=#{rows.length}"
  '
  ```
  判据：输出 `AC1-PASS`。所有日期为 quoted string；任何隐式 Date、未知字段或自创枚举均 FAIL。

- AC2: **可重放 source set 与 disposition 双向闭合。**
  ```bash
  set -e
  ROOT=.tad/evidence/designs/full-capability-extraction
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  bash -n "$ROOT/generate-inventory.sh" \
    && bash "$ROOT/generate-inventory.sh" "$TMP/raw.tsv" "$TMP/handoffs.tsv"
  cut -f1-3 "$ROOT/source-inventory.tsv" | LC_ALL=C sort -u > "$TMP/mapped-raw.tsv"
  LC_ALL=C sort -u "$TMP/raw.tsv" > "$TMP/fresh-raw.tsv"
  diff -u "$TMP/fresh-raw.tsv" "$TMP/mapped-raw.tsv"
  ruby -ryaml -e '
    root=".tad/evidence/designs/full-capability-extraction"
    d=YAML.safe_load(File.read("#{root}/capability-disposition.yaml"), permitted_classes:[], aliases:false)
    rows=d.fetch("capabilities"); ids=rows.map{|r| r.fetch("id")}; abort "dup" unless ids.uniq==ids
    inv=File.readlines("#{root}/source-inventory.tsv", chomp:true).map{|l| l.split("\t",-1)}
    abort "4cols" unless inv.all?{|r| r.length==4 && !r[3].empty?}
    abort "bad-id" unless inv.flat_map{|r| r[3].split(",")}.all?{|id| ids.include?(id)}
    file_rows=inv.select{|r| %w[canonical_file mirror_file].include?(r[0])}.map{|r| r[1]}.uniq.sort
    abort "union files" unless file_rows==rows.flat_map{|r| r.fetch("source_files")}.uniq.sort
    unions={"legacy_trigger"=>"legacy_triggers", "standalone_skill"=>"existing_equivalents"}
    unions.each do |type,key|
      a=inv.select{|r| r[0]==type}.map{|r| r[1]}.uniq.sort
      b=rows.flat_map{|r| r.fetch(key)}.uniq.sort
      abort "union #{type}" unless a==b
    end
    consumers=inv.select{|r| %w[route_consumer live_contract_consumer].include?(r[0])}.map{|r| r[1]}.uniq.sort
    abort "union consumers" unless consumers==rows.flat_map{|r| r.fetch("route_consumers")}.uniq.sort
    active_handoffs=Dir.glob(".tad/active/handoffs/HANDOFF-*.md").sort
    inventoried_handoffs=inv.select{|r| r[0]=="live_contract_consumer" && r[1].match?(%r{\A\.tad/active/handoffs/HANDOFF-[^/]+\.md\z})}.map{|r| r[1]}.uniq.sort
    abort "active handoffs" unless inventoried_handoffs==active_handoffs
    abort "files" unless inv.count{|r| r[0]=="canonical_file"}==35 && inv.count{|r| r[0]=="mirror_file"}==35
    abort "triggers" unless inv.count{|r| r[0]=="legacy_trigger"}>=29
    inv.select{|r| r[0]=="standalone_skill"}.each{|r| abort "missing skill #{r[1]}" unless File.directory?(".claude/skills/#{r[1]}")}
    puts "AC2-PASS"
  '
  PARITY=1
  while IFS= read -r f; do
    g=".agents/${f#.claude/}"
    cmp -s "$f" "$g" || { echo "PARITY-FAIL $f $g"; PARITY=0; }
  done < <(find .claude/skills/alex .claude/skills/blake .claude/skills/gate -type f | LC_ALL=C sort)
  [ "$PARITY" -eq 1 ] && echo AC2-PARITY-PASS || { echo AC2-PARITY-FAIL; exit 1; }
  ```
  判据：`diff` 为空并输出 `AC2-PASS`。生成器必须将 tracked 与 untracked live consumer 合并；
  reviewer 仍需抽查 parser 没有把 Key Commands 块截短。

- AC3: **13 个战略能力逐项存在，候选不靠空值冒充。**
  ```bash
  ruby -ryaml -e '
    d=YAML.safe_load(File.read(".tad/evidence/designs/full-capability-extraction/capability-disposition.yaml"), permitted_classes:[], aliases:false)
    rows=d.fetch("capabilities"); by=rows.to_h{|r| [r.fetch("id"),r]}
    ids=%w[release-ops dependencies tournament ideas status-roadmap research parallel surplus-yolo product-architecture lite-design-handoff lite-execution-gates full-router-startup legacy-handoff]
    abort "missing=#{ids-by.keys}" unless (ids-by.keys).empty?
    ids.each do |id|
      r=by[id]; abort "blank #{id}" if %w[summary disposition rationale migration_dependency].any?{|k| r[k].strip.empty?}
      if %w[EXTRACT EXTEND].include?(r["disposition"])
        skill_path=".claude/skills/#{r["target_skill"]}/SKILL.md"
        abort "candidate #{id}" if r["target_skill"].strip.empty? || r["carrier_paths"].empty? || r["supported_roles"].empty? || r["modes"].empty? || r["trigger_examples"].length<2 || r["resource_plan"]["skill"]!=[skill_path] || r["forward_test_prompt"].strip.empty?
      end
    end
    puts "AC3-PASS"
  '
  ```

- AC4: **D1–D10 不只出现 token，而是逐项选择 pattern/rationale/cost/source。**
  ```bash
  F=.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md
  bash .agents/skills/ai-agent-architecture/scripts/audit-decisions.sh "$F" \
    && grep -Fxq '| Decision | Pattern | Rationale | Cost impact | Source |' "$F" \
    && ruby -e '
      lines=File.readlines(ARGV[0], chomp:true).grep(/^\| D(?:[1-9]|10) \|/)
      abort "count" unless lines.length==10
      rows=lines.map{|l| l.split("|").map(&:strip).reject(&:empty?)}
      abort "columns" unless rows.all?{|r| r.length==5 && r[1..4].all?{|v| !v.empty? && v!="SKIPPED"}}
      abort "ids" unless rows.map{|r| r[0]}.sort==(%w[D1 D2 D3 D4 D5 D6 D7 D8 D9 D10].sort)
      base=".agents/skills/ai-agent-architecture/references"
      expected={
        "D1"=>"need-an-agent.md", "D2"=>"coordination-and-state.md", "D3"=>"context-memory.md",
        "D4"=>"tool-management.md", "D5"=>"permissions-safety.md", "D6"=>"context-compression.md",
        "D7"=>"cost-token-economics.md", "D8"=>"observability.md", "D9"=>"testing-evaluation.md",
        "D10"=>"production-disasters.md"
      }
      rows.each do |r|
        source="#{base}/#{expected.fetch(r[0])}"
        abort "source #{r[0]}" unless r[4]==source && File.file?(source)
      end
      puts "AC4-PASS"
    ' "$F"
  ```
  reviewer 逐项核对：D2 状态/幂等、D3 记忆分层、D6 pin/recovery、D7 budget、D8 trace、
  D9 transition/corrupt-input、D10 applicable incidents；结构脚本不能替代语义审查。

- AC5: **权限与恢复反例形成结构化拒绝规范。**
  ```bash
  F=.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md
  ruby -ryaml -e '
    f=".tad/evidence/designs/full-capability-extraction/composition-negative-fixtures.yaml"
    d=YAML.safe_load(File.read(f), permitted_classes:[], aliases:false)
    rows=d.fetch("fixtures"); ids=%w[privilege-escalation version-mismatch skill-conflict approval-replay state-fork irreversible-retry]
    abort "ids" unless rows.map{|r| r["id"]}.sort==ids.sort
    fields=%w[id input expected_verdict expected_reason required_evidence decision_ids]
    abort "schema" unless rows.all?{|r| r.keys.sort==fields.sort && %w[id input expected_verdict expected_reason required_evidence].all?{|k| r[k].is_a?(String) && !r[k].strip.empty?} && r["decision_ids"].is_a?(Array) && r["decision_ids"].all?{|v| v.is_a?(String)}}
    abort "verdict" unless rows.all?{|r| %w[DENY BLOCKED].include?(r["expected_verdict"])}
    expected={
      "privilege-escalation"=>%w[D5 D10], "version-mismatch"=>%w[D6 D9],
      "skill-conflict"=>%w[D2 D5 D9], "approval-replay"=>%w[D5 D9 D10],
      "state-fork"=>%w[D2 D3 D9 D10], "irreversible-retry"=>%w[D2 D5 D9 D10]
    }
    abort "decision map" unless rows.all?{|r| r["decision_ids"]==expected.fetch(r["id"])}
    puts "AC5-PASS"
  ' \
    && grep -Fq 'Lite ∩ Skill ∩ Human' "$F" \
    && grep -Fq 'single task-state owner' "$F" \
    && grep -Fq 'pinned skill version' "$F" \
    && grep -Fq 'skill cannot override' "$F" \
    && grep -Fq 'fail closed' "$F" \
    && grep -Fq 'consume-once approval' "$F" \
    && grep -Fq 'idempotency key' "$F" \
    && echo AC5-ANCHORS-PASS
  ```
  contract 还必须逐字含：`Lite ∩ Skill ∩ Human`、`single task-state owner`、
  `pinned skill version`、`skill cannot override`、`fail closed`、`consume-once approval`、
  `idempotency key`，并把六个 fixture 映射到 D5/D6/D9/D10。运行时行为验证明确顺延 Phase 3。

- AC6: **Skill-creator 输入按候选 ID 一一对应，且没有提前创建 skill。**
  ```bash
  ROOT=.tad/evidence/designs/full-capability-extraction
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  ruby -ryaml -e '
    d=YAML.safe_load(File.read(ARGV[0]), permitted_classes:[], aliases:false)
    puts d.fetch("capabilities").select{|r| %w[EXTRACT EXTEND].include?(r["disposition"])}.map{|r| r["id"]}.sort
  ' "$ROOT/capability-disposition.yaml" > "$TMP/yaml-ids"
  sed -n 's/^## Candidate: //p' "$ROOT/skill-composition-contract.md" | LC_ALL=C sort > "$TMP/doc-ids"
  diff -u "$TMP/yaml-ids" "$TMP/doc-ids" \
    && [ -s "$TMP/yaml-ids" ] \
    && [ "$(find .claude/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort | md5)" = 532e3b02d15c93bad7f30aac9c833f37 ] \
    && [ "$(find .agents/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort | md5)" = 948a58efa031f1479487dcb86a003551 ] \
    && echo AC6-PASS || { echo AC6-FAIL; exit 1; }
  ```
  YAML 的 trigger/resource/forward-test 非空性由 AC3 检查；本条证明 contract 与 YAML 候选身份相同，
  并用 filesystem 目录集阻止任何名称的提前 skill 初始化（包括 gitignored 路径）。

- AC7: **下游基线与 37 张 legacy handoff manifest 可重放、逐文件闭合。**
  ```bash
  ROOT=.tad/evidence/designs/full-capability-extraction
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  bash "$ROOT/generate-inventory.sh" "$TMP/raw.tsv" "$TMP/handoffs.tsv" \
    && diff -u "$ROOT/legacy-handoff-manifest.tsv" "$TMP/handoffs.tsv" \
    && ruby -ryaml -e '
      root=".tad/evidence/designs/full-capability-extraction"
      d=YAML.safe_load(File.read("#{root}/capability-disposition.yaml"), permitted_classes:[], aliases:false)
      b=d.fetch("baseline"); keys=%w[registered reachable missing with_full with_lite active_full_handoffs]
      abort "keys" unless b.keys.sort==keys.sort && b.values.all?{|v| v.is_a?(Integer)}
      summary=File.readlines(ARGV[0], chomp:true).map{|l| l.split("\t",-1)}.find{|r| r[0]=="downstream_summary"}
      abort "summary-row" unless summary && summary[2]==".tad/sync-registry.yaml"
      actual=summary[1].split(";").map{|p| p.split("=",2)}.to_h.transform_values{|v| Integer(v,10)}
      abort "summary-values" unless actual.keys.sort==keys.sort && actual==b
      rows=File.readlines("#{root}/legacy-handoff-manifest.tsv", chomp:true).map{|l| l.split("\t",-1)}
      abort "manifest" unless rows.all?{|r| r.length==4 && %w[pending missing-project].include?(r[3])}
      abort "dups" unless rows.map{|r| [r[0],r[2]]}.uniq.length==rows.length
      abort "counts" unless rows.count{|r| r[3]=="pending"}==b["active_full_handoffs"] && rows.count{|r| r[3]=="missing-project"}==b["missing"] && b["reachable"]+b["missing"]==b["registered"]
      puts "AC7-PASS #{keys.map{|k| "#{k}=#{b[k]}"}.join(" ")}"
    ' "$TMP/raw.tsv"
  ```
  manifest 只使用 `find ... -name 'HANDOFF-*.md'` 的路径，不得 `cat/sed/grep` 正文。

- AC8: **运行时相对 immutable base 零变化，未跟踪/ignored 新 skill 也逃不过。**
  ```bash
  BASE=4116517
  git merge-base --is-ancestor "$BASE" HEAD \
    && [ "$(md5 -q .tad/evidence/audits/lite-constraint-ledger.md)" = 089f940461876e4714d50031f469ed28 ] \
    && [ "$(md5 -q .claude/skills/alex-lite/SKILL.md)" = 1a6bc26c010dba163a69c1fea40e6c82 ] \
    && [ "$(md5 -q .claude/skills/blake-lite/SKILL.md)" = b9a0c096b5fd4436b0a288dee713d55e ] \
    && git diff --quiet "$BASE" -- CLAUDE.md AGENTS.md README.md INSTALLATION_GUIDE.md tad.sh \
         .claude/skills .agents/skills .tad/hooks .tad/deprecation.yaml \
    && ! git ls-files --others --exclude-standard -- .claude/skills .agents/skills .tad/hooks .tad/deprecation.yaml | grep -q . \
    && [ "$(find .claude/skills -print | LC_ALL=C sort | md5)" = 226a1e01bf11f23c7a90ecf75218514d ] \
    && [ "$(find .agents/skills -print | LC_ALL=C sort | md5)" = 6d932d6aa102110c86213a7756d63b53 ] \
    && echo AC8-PASS || { echo AC8-FAIL; exit 1; }
  ```
  这组 filesystem 全节点 path-set 哈希覆盖目录、文件与 symlink，包括 gitignored 路径；tracked
  内容由 immutable base diff 覆盖。
  若并发终端改 protected path，记录 `UNVERIFIED: concurrent mutation`，等待 quiet point 后重跑，
  不得重置或 `parity --fix` 他人工作。

- AC9: **本单成品路径集精确，无额外设计/证据文件。**
  ```bash
  GOT=$(mktemp); EXP=$(mktemp)
  find .tad/evidence/designs/full-capability-extraction \
       .tad/evidence/acceptance-tests/full-capability-inventory-contract \
       .tad/evidence/reviews/blake/full-capability-inventory-contract \
       -type f | LC_ALL=C sort > "$GOT"
  printf '%s\n' \
    '.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md' \
    '.tad/evidence/designs/full-capability-extraction/capability-disposition.yaml' \
    '.tad/evidence/designs/full-capability-extraction/composition-negative-fixtures.yaml' \
    '.tad/evidence/designs/full-capability-extraction/generate-inventory.sh' \
    '.tad/evidence/designs/full-capability-extraction/legacy-handoff-manifest.tsv' \
    '.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md' \
    '.tad/evidence/designs/full-capability-extraction/source-inventory.tsv' \
    '.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md' \
    | LC_ALL=C sort > "$EXP"
  diff -u "$EXP" "$GOT" && echo AC9-PASS || { echo AC9-FAIL; rm -f "$GOT" "$EXP"; exit 1; }
  rm -f "$GOT" "$EXP"
  ```

## AC 空跑记录（2026-08-09）

- AC1：目标 YAML 不存在，改前 FAIL；Ruby 2.6.10 对 unquoted date 会报 `Psych::DisallowedClass`，
  新命令禁止任何 permitted class 并要求 `generated_at` 为 String。
- AC2：canonical full 文件 35、Quick Reference commands 21+8；目标 generator/TSV 不存在，改前 FAIL。
- AC3：13 个战略 ID 来自人已批准的处置矩阵；目标 YAML 不存在，改前 FAIL。
- AC4：`audit-decisions.sh` 存在可执行；新增十行结构解析会拒绝只列 D1–D10 token 的空壳。
- AC5：六类 negative fixture 当前不存在，改前 FAIL；本单只验设计 fixture，不假称 runtime 已实现。
- AC6：当前 skill 顶层目录集实测 `.claude` 62 / `.agents` 61，basename md5 分别
  `532e3b02…` / `948a58ef…`；任何名称的新目录都会 FAIL。
- AC7：只读重算 registered=14 / reachable=12 / missing=2 / with_full=12 / with_lite=1 /
  active_full_handoffs=37；逐文件 manifest 不存在，改前 FAIL。
- AC8：base=`4116517`；ledger/alex-lite/blake-lite md5 与命令一致；tracked protected diff 为空；
  全节点 path-set（目录、文件、symlink）md5 为 `.claude=226a1e01…` / `.agents=6d932d6a…`，改前 PASS。
- AC9：三个目标目录均不存在，`find` 会非零且集合不等，改前 FAIL。

## 知识引用

- `.agents/skills/ai-agent-architecture/references/need-an-agent.md` — D1 要求使用最低足够复杂度；
  保留 Lite 角色、把低频能力做 skill，而不是为能力继续保留第三套代理路径。
- `.agents/skills/ai-agent-architecture/references/tool-management.md` — D4 的 search-then-load 与
  SkillTool 成本层级要求 metadata/index 常驻、正文命中才加载。
- `.agents/skills/ai-agent-architecture/references/permissions-safety.md` — D5 要求最低权限、独立安全层与
  高风险动作一次性人工授权；skill 不能成为权限旁路。
- `.agents/skills/ai-agent-architecture/references/coordination-and-state.md` 与
  `context-memory.md` — D2/D3 要求单一 canonical state owner，并把 procedure、facts、temporary
  task state 分开，避免 skill 另建真相源。
- `.agents/skills/ai-agent-architecture/references/context-compression.md` — D6 要保护当前任务与
  tool-call 原子边界；composition contract 因此 pin skill version 并定义恢复重载。
- `.agents/skills/ai-agent-architecture/references/cost-token-economics.md` 与 `observability.md` —
  D7/D8 要求 session/tool budget 与跨角色 trace；skill 选择、版本、授权和 verdict 必须可追踪。
- `.agents/skills/ai-agent-architecture/references/testing-evaluation.md` 与
  `production-disasters.md` — D9/D10 要求测试 agent transition 与坏输入，重点防权限越界、状态分叉、
  无幂等重试和不可逆动作重复执行。
- `/Users/sheldonzhao/.codex/skills/.system/skill-creator/SKILL.md` — 先用真实触发例规划 resources，
  SKILL.md 保持简洁并渐进披露；实际创建时用 init/validate/forward-test，不提前造空目录。
- `.tad/project-knowledge/patterns/handoff-design.md` — 删除/退役必须做 downstream consumer grep，
  且 tracked 与 untracked 消费者都要覆盖。
- `.tad/project-knowledge/patterns/gate-design.md` — 独立设计审查与实现后审查覆盖不同盲区；
  架构 contract 不能用自审替代 fresh reviewer。
- `.tad/project-knowledge/patterns/release-sync.md` — 镜像与同步必须逐粒度验证，byte parity 不能证明
  两侧内容本身正确。

## Contract Review (2026-08-09)

Reviewer: Codex API independent read-only contract reviewer | model=GPT-5
首轮 verdict: **FAIL**（P0=2, P1=6, P2=2）
最终 verdict: **PASS**（P0=0, P1=0, P2=0）
累计发现：P0=2(fixed), P1=10(fixed), P2=5(fixed); 已审 AC 条数: 9/9
关键发现: AC8 漏未跟踪 runtime 且钉死 HEAD；35 文件覆盖与 command/consumer disposition 脱节；
Ruby Date 策略不一致；D1–D10/权限/skill 示例仅 token/count 级；下游只有汇总无逐 handoff manifest。
增量复核 1 (2026-08-09): **CONDITIONAL**（P0=0, P1=3, P2=2；首轮两项 P0 已闭合）。
残余项：filesystem fence 漏 symlink 且三条失败分支可 exit 0；active live contract 被排除；
decision source 与 fixture→decision 关系未机械验证。
增量复核 2 (2026-08-09): **CONDITIONAL**（P0=0, P1=1, P2=1；已审 AC 9/9；AC8 实跑 PASS）。
残余项：不能在禁止读取正文时筛选“引用 full 的 HANDOFF”；resource path 仍可为空串。
增量复核 3 (2026-08-09): **PASS**（P0=0, P1=0, P2=0；已审 AC 9/9）。
确认所有 active `HANDOFF-*` 无条件按文件名精确纳入且不读正文；resource path 拒绝空串，
`EXTRACT/EXTEND` 的唯一 skill path 精确绑定 `.claude/skills/<target_skill>/SKILL.md`。
UNVERIFIED: 交付物尚未实现，因此 AC1–AC7、AC9 待 Blake-Lite 对成品实跑；AC8 基线已实跑 PASS。

## 风险与注意

1. 本单是判断型 inventory，不应把“有一行 YAML”误当作能力真的被理解；reviewer 必须抽查
   source→capability→disposition 的语义链。
2. 35 文件覆盖只能证明 canonical 文件没有漏，不能证明命令或下游消费者没有漏；因此
   `source-inventory.tsv` 另含 trigger、standalone skill、route consumer 和 downstream summary，
   并由 generator fresh 输出与 mapped 四列 TSV 双向比较。
3. `DECISION_REQUIRED` 是诚实终态，不是失败；没有 carrier 时宁可暂不提取，也不制造空 skill。
4. `release-ops` 很可能应 EXTEND 现有 `release-runbook`，`dependencies` 很可能应 EXTRACT；
   但最终 disposition 必须由 source 与 carrier 证据决定，不能为迎合本段预期倒填。
5. 未来修改 Lite composition 规则会触发约束定价台账；本单只设计，不授予权限、不安装规则。
6. 两个 registry 路径当前失效，Phase 6 前必须由人确认新路径或移出 registry；本单只记录。
7. 当前 local HEAD 比 origin ahead 2。发布/同步属于后续安全停动作，本单不得顺手执行。

## Lite Progress

Phase=admission
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/active/handoffs/LITE-20260809-1543-full-capability-inventory-contract.md
Next Action=读 ai-agent-architecture references + skill-creator，写 generate-inventory.sh

Phase=ac
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md
Next Action=L3 独立审查（spawn code-reviewer；AC9 待 reviewer 文件落盘后终验）

Phase=review
repair_round=1/3
same_error_count=1/2
verdict=RUNNING
Evidence=.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md
Next Action=增量复核 1 CONDITIONAL（P2-2 残留 exit code 传播，已修复 pipefail+守卫，探针 B/B2 exit=1 实测）；等终轮 verdict 后进 L3.5

## Completion (2026-08-09)
**Commit**: uncommitted
**Model**: harness=claude-code | model=deepseek-v4-flash | route=unknown（无 base-URL host 配置；reviewer 自报同模型族，不作 SKU 伪造）
- 上下文刷新：已读 `.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md`、`.tad/sync-registry.yaml`、`.tad/guides/tool-quick-reference-alex.md`、`.agents/skills/ai-agent-architecture/references/` 10 个 D1–D10 来源、`~/.codex/skills/.system/skill-creator/SKILL.md`、patterns 3 个（handoff-design / gate-design / release-sync）、alex-lite/blake-lite SKILL.md（LITE_NATIVE 判定）、Key Commands 块（alex 22 + blake 8）、CLAUDE.md §2 路由表、14 个下游项目目录探测 | 关键约束：只读仓库、不读 HANDOFF 正文、机械提取不手抄、8 文件精确路径集、immutable base 零变化、不初始化 skill 目录 | 成功条件：AC1–AC9 全绿 + 独立 reviewer PASS + 无 runtime/skill/installer/hook 变更
- 改动文件：`.tad/evidence/designs/full-capability-extraction/{generate-inventory.sh, capability-disposition.yaml, source-inventory.tsv, legacy-handoff-manifest.tsv, skill-composition-contract.md, composition-negative-fixtures.yaml}`、`.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md`、`.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md`（8 项，全为清单内新建）；handoff 追加 Lite Progress / Completion / Reflexion（§文件清单「允许追加」）；`.tad/evidence/journal/lite-discoveries.md` 追加 4 行 [清单外——意外发现的 journal 记录，协议允许]
- AC 结果：
  - AC1 ✅ `AC1-PASS rows=19`（17 字段精确闭合、枚举封闭、日期全 quoted）→ ac-results.md
  - AC2 ✅ `AC2-PASS` + `AC2-PARITY-PASS`（fresh raw ↔ mapped 前三列 diff 空；35/35 parity；45 triggers ≥29；10 standalone 目录全存在）→ ac-results.md
  - AC3 ✅ `AC3-PASS`（13 战略 ID 逐项；候选 trigger_examples≥2 / resource_plan.skill 精确绑定）→ ac-results.md
  - AC4 ✅ `RESULT: structurally complete (exit 0)` + `AC4-PASS`（audit-decisions.sh + 10 行五列 + Source 逐文件存在）→ ac-results.md
  - AC5 ✅ `AC5-PASS` + `AC5-ANCHORS-PASS`（6 fixtures 决策映射 + 7 逐字锚点）→ ac-results.md
  - AC6 ✅ `AC6-PASS`（候选 {dependencies, release-ops} == `## Candidate:`；skills 目录 md5 与基线一致，零提前创建）→ ac-results.md
  - AC7 ✅ `AC7-PASS registered=14 reachable=12 missing=2 with_full=12 with_lite=1 active_full_handoffs=37`（fresh manifest diff 空；37 pending + 2 missing-project 无重复）→ ac-results.md
  - AC8 ✅ `AC8-PASS`（HEAD==BASE；ledger/lite md5 一致；protected diff 空；path-set md5 一致）→ ac-results.md
  - AC9 ✅ `AC9-PASS`（初跑 FAIL 为目录未创建、终验 PASS 真实输出见 ac-results.md 重写段）
- Reviewer: **PASS** | model=deepseek-v4-flash（三轮：首轮 CONDITIONAL P0=0 P1=1 P2=4 → 增量复核 1 CONDITIONAL 新增 P1=1 → 终轮 PASS P0/P1/P2=0）关键发现摘录：「ac-results.md 的 AC9『补充终验 PASS』是无载体声明」（P1-1，执行实证——Claims Need Carriers 违反，已改真实记录）；「tracked 路径缺无条件按文件名纳入 HANDOFF-* 分支，且 git grep 路径会读 HANDOFF 正文」（P2-1，执行实证——探针复现 tracked 无关键词 HANDOFF 静默丢失，已修复 pathspec 排除 + find 统一纳入）；「registry 解析失败静默全零 + 空 manifest exit 0」（P2-2，执行实证——已修复显式失败）；「set -u 使 usage 守卫成死代码」（P2-3，执行实证——已修复前置检查）；「P2-2 残留：exit 1 在管道子 shell 不传播，实测两路径 exit=0」（增量 1，执行实证——已修复 pipefail + || 守卫，终轮探针 B/B2 exit=1 且不再产出空 manifest，优于最低要求）；「frontend-design.md 映射 alex-design-inquiry 可辩护，P5 裁决时顺带复核」（P2-4，阅读推断——不改数据）
- Technical Gate: **GATE PASS**（①AC/evidence：9/9 有原始输出与证据路径 ②reviewer PASS、P0=0 ③friction：无 BLOCKED，工具全可用 ④scope/risk：改动限于清单、无共享消费方、AC8 零 runtime 变化 ⑤Knowledge Assessment：journal captured）
- Knowledge Assessment: journal captured（`.tad/evidence/journal/lite-discoveries.md` 4 行：key-commands-multi-token / pipefail-subshell-exit / git-grep-exclude-pathspec / awk-range-swallow）
- 意外发现：1) `## AC 空跑记录` 段被 L0.5 机械计数 awk 范围吞入（18 vs 已审 9，AC 定义行半角冒号精确计数 = 9 与契约一致，非契约过期）；2) alex Key Commands 第 15 行 `*gate 1` or `*gate 2` 单行双命令，首轮提取静默丢失 `*gate 2`（契约风险 2 预警的"截短"实发生，修复后 parser 无截短）；3) CLAUDE.md §2 正文（非表行）还公开 `*deps`/`*tournament`/`*knowledge-maintain`/`/deep-research` 等 full 命令，路由表提取必须含正文
- follow-up：
  - P2-4（frontend-design.md → alex-design-inquiry 映射语义）→ 现象：该文件经 Grounded-in 的 HANDOFF 引用命中；证据：code-reviewer.md 探针 E；不阻塞：union 机械闭合，语义可辩护；建议 owner：Alex-Lite（P5 裁决 alex-design-inquiry 时顺带确认，若只消费 HANDOFF 档案归 legacy-handoff 更贴切）
  - DECISION_REQUIRED 四能力（tournament / ideas / alex-design-inquiry / knowledge-maintain）→ 现象：均有 carrier 但形态待定；证据：capability-disposition.yaml；不阻塞：P5 secondary decisions 是 Epic 既定 Phase；建议 owner：Alex-Lite（P5）
  - `/deep-research` trigger（被 *research 吸收的排除入口）→ 现象：路由文档明示"不要 invoke"；证据：source-inventory.tsv route-table 行；不阻塞：已并入 research legacy_triggers；建议 owner：P7 deprecation shim 时在提示文案中体现
  - legacy-handoff 的 manifest 计数依赖下游 find 结果 → 现象：37 是 2026-08-09 实测快照；证据：AC7；不阻塞：Epic 基线明示"不是永久常量，每次迁移前重新测量"；建议 owner：Blake-Lite（P6 复用生成器前重跑）

## Reflexion
- 修复 1（P1-1 ac-results 载体）：失败=预写"补充终验 PASS"无载体声明 / 假设=先写结论后补证据可接受 / 动作=删除预写措辞，落盘真实初跑 FAIL diff + 终验 PASS 输出 / 结果=reviewer 增量 1 确认 FIXED
- 修复 2（P2-1 tracked HANDOFF 无条件纳入）：失败=tracked 扫描依赖内容命中、会读 HANDOFF 正文 / 假设=git grep 读正文 + 漏纳可用 AC2 fail-closed 兜底 / 动作=pathspec :(exclude) 排除 + 统一 find 纳入循环 / 结果=探针 A 复现 tracked 无关键词 HANDOFF 纳入，reviewer FIXED
- 修复 3（P2-2 registry 显式失败）：失败=初版 exit 1 在 `{ } | sort` 子 shell 不传播，实测 exit=0（增量 1 抓出；我此前"已验证 exit≠0"自述不实——只验了 P2-3）/ 假设=显式 exit 1 即足够 / 动作=set -o pipefail + 管道尾部 || 守卫 / 结果=探针 B/B2 exit=1 且不再产出空 manifest，终轮 PASS
- 修复 4（P2-3 usage 守卫）：失败=set -u 在参数解引用前炸掉 / 假设=守卫先于解引用 / 动作=参数检查前置 [ "$#" -lt 2 ] / 结果=无参 usage + exit=2，reviewer FIXED

Phase=technical-gate
repair_round=1/3
same_error_count=1/2
verdict=GATE PASS
Evidence=.tad/evidence/reviews/blake/full-capability-inventory-contract/code-reviewer.md + .tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md
Next Action=L5 等人验收

## 人验收记录（2026-08-09）
人验收原话（逐字）: "验收通过，归档并 commit" —— 授权归档 + git commit（不含 push；push 另行停问）
Phase=human-gate
repair_round=1/3
same_error_count=1/2
verdict=ACCEPTED / ARCHIVED
Evidence=.tad/evidence/acceptance-tests/full-capability-inventory-contract/ac-results.md
Next Action=归档至 .tad/archive/handoffs/ + pathspec commit（不含 push）
