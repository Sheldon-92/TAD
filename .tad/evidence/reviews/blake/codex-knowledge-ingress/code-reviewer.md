# Layer 2 CODE Review — codex-knowledge-ingress

**Verdict: PARTIAL — review stopped on user interruption; not a PASS and not evidence that Gate 3/4 is safe to advance.** No implementation files were changed. This report is the only file written by this review.

## 执行证据

已执行的精确检查：

1. `sed -n '1,400p' .tad/project-knowledge/patterns/shell-portability.md` — PASS；先读取了 shell portability 合约，覆盖 BSD/macOS 命令、`set -e`/命令替换、TTY/阻塞、locale 与固定字符串规则。
2. `git status --short` — PASS（只读）；确认当前工作树包含 `hook-envelope.sh`、迁移中的 hook、`.codex/hooks.json`、`tad.sh`、`.agents/.claude` 两棵 skill/reference 树及未注册 evidence/handoff 变化；实现文件未被本审查修改。
3. `git diff --stat` — 结果为 `61 files changed, 285 insertions(+), 312 deletions(-)`（未包含未跟踪文件）；因此存在较大的 line-set 审查面。
4. `find .tad/active/handoffs -maxdepth 1 -type f -print | sort` — 发现 `COMPLETION-20260803-codex-wiring-stopbleed.md` 与 `HANDOFF-20260803-codex-knowledge-ingress.md`。
5. `sed -n '1,240p' NEXT.md` — 结果指向 Codex Universalization Step 2、当前 Gate-2 review；未把 NEXT 的叙述当作实现正确性的证明。
6. `rg -n --hidden --glob '!*.git*' 'hook-envelope|HOOK_(ST|ENVELOPE|SOURCE|TOOL|FILE|SKILL|SESSION|CWD)|read_stdin_json|get_json_field' .tad/hooks tad.sh .codex AGENTS.md` — 定位到共享 envelope 及迁移消费者；旧解析函数仍定义在 `common.sh`，新消费者改为使用 `HOOK_*`。
7. `nl -ba`/`git diff --` 只读检查了 `.tad/hooks/lib/hook-envelope.sh`、`askuser-capture.sh`、`brain-index-gen.sh`、`detect-platform.sh`、`notebook-dormant-sync.sh`、`post-write-sync.sh`、`pre-accept-check.sh`、`pre-gate-check.sh`、`startup-health.sh`，以及 `.codex/hooks.json`、`tad.sh`、Codex adapter 文档、知识文件和两树 skill/reference diff。
8. codebase-memory 的三次 changed-shell `search_graph` 查询均返回 `total:0`；随后按项目规则回退到直接 `git diff`/`nl` 读取，未把旧图结果冒充为当前工作树结果。

静态初步观察（未完成行为裁决）：

- `hook-envelope.sh` 在 `cat` 前检查 `-t 0`，且通过命令替换捕获 stdin；静态上未看到正常路径向 stdout 打日志。
- `pre-accept-check.sh` 的无 envelope 路径要求 argv `4`；`pre-gate-check.sh` 要求 argv `3|4`。这改变了裸手工调用的行为，但本轮没有跑手工/TTY/空 stdin fixture，不能确认所有 false-green 与退出码路径。
- `brain-index-gen.sh` 的 skill fallback 顺序为 `.claude/skills` → `.agents/skills` → “no skills tree found”；尚未生成/比较结果文件。
- `detect-platform.sh` 保留 workflow→codex→none fallback，并新增 stderr 诊断；尚未验证调用方的 stdout purity、相对/绝对 cwd 与 BSD glob 行为。
- `.codex/hooks.json` 的静态 diff 将 matcher 从 `startup|resume` 扩到 `startup|resume|compact`；`tad.sh` 生成/安装路径及两树 36 处 reference 变化尚未完成逐行注册审计。

明确未执行（因此不能宣称 PASS）：

- `bash -n`：未跑全部迁移脚本及 `tad.sh`。
- `jq` 解析/schema 校验：未跑 `.codex/hooks.json` 的 `jq empty` 或 schema/字段断言。
- parity / mirror / line-set verifier：未跑；不能证明 `.agents` 与 `.claude` 的 skill/reference 编辑均已登记且等价。
- pre-gate/pre-accept 手工行为、空 stdin、TTY、无 jq、畸形 JSON、带空格/特殊字符 argv、hook envelope fixtures：未跑。
- `detect-platform`、brain-index fallback、matcher/安装器真实行为：未跑。

## 401 / no-delivery 限制

本轮没有获得可用的认证 Codex hook-delivery 证据。仓库现有 Step 2 记录的隔离 v0.146.0 探针因认证失败（HTTP 401）未到达 authenticated turn，因此不能证明 `.codex/hooks.json` 已被真实运行时接受，也不能证明 `SessionStart`/`compact` matcher 或 PreCompact 等 hook 实际 delivery。结论仅限于静态工作树检查；401 与 no-delivery 必须保留为 PARTIAL 限制，不得写成运行时 PASS。

由于用户要求此刻停止，未继续运行上述验证，也未创建任何其他文件。

## R2 执行证据

执行日期：2026-08-03。

本节仅追加到原有 PARTIAL 记录之后；未修改实现文件，也未创建其他持久化文件。

基础检查（全部 exit 0）：

1. `bash -n .tad/hooks/*.sh .tad/hooks/lib/*.sh tad.sh` — PASS。
2. `jq -e . .codex/hooks.json` — PASS；JSON 解析成功，`description`/`hooks` 对象及当前 hook 配置有效。
3. `bash .tad/hooks/lib/release-verify.sh parity .` — PASS；`VERDICT: parity PASS (exit 0)`。

完整 AC-00..AC-10b（每个脚本 exit 0）：

1. `AC-00-spikes.sh` — `AC-00 PASS: C/D/E real probes are recorded with honest no-delivery mappings.`
2. `AC-01-knowledge-ingress.sh` — `AC-01 PASS: scoped ingress, conditionals, critical rules, and copy guard verified (47 lines).`
3. `AC-02-spike-envelope.sh` — `AC-02 PASS: per-event no-delivery observation and envelope mapping are explicit.`
4. `AC-03-envelope-fixtures.sh` — `AC-03 PASS: Claude fixtures, honest Codex empty shape, empty input, jq fallbacks, and TTY guard verified.`
5. `AC-04-claude-zeroregression.sh` — `AC-04 PASS: frozen same-basename Claude behavior matches; both second trace runs add 0 lines.`
6. `AC-04b-manual-gates.sh` — `AC-04b PASS: manual no-arg/invalid calls fail visibly; missing Completion blocks; valid Completion allows.`
7. `AC-05-spike-d-ledger.sh` — `AC-05 PASS: Spike D honest branch is recorded, untested fire stays partial, no wiring was added, and snapshots remain legal.`
8. `AC-06-detect-platform.sh` — `AC-06 PASS: implementation signal reads equal Spike E {}; override/fallback table outputs are one clean word.`
9. `AC-07-skill-line-set.sh` — `AC-07 PASS: registered line-set only, 38→0 old Source headers, codex-only anchors, parity, and lite guards verified.`
10. `AC-08-brain-index-fallback.sh` — `AC-08 PASS: copied Codex-only tree uses .agents/skills; missing both trees emits explicit marker; repo index is unchanged.`
11. `AC-09-regression.sh` — `AC-09 PASS: parity, skill-body, runtime 21/21 PASS, accepted limitation, and current hook schema verified.`
12. `AC-10a-startup-compact.sh` — `AC-10a PASS: compact discriminator reminds; missing discriminator stays honest and routes to Layer-1 self-check.`
13. `AC-10b-notebook-fail-open.sh` — `AC-10b PASS: absent source remains fail-open and acts; HOOK_SOURCE is empty; compact source is filtered.`

专项复核结果：

- AC-03 已实际覆盖 TTY、empty input、jq-absent fallback；AC-04b 已实际覆盖无参数/非法参数、缺失 Completion 的 BLOCK、有效 Completion 的 allow。
- AC-06 已验证 override/fallback 的 stdout 只有一个 `workflow`/`codex`/`none` 单词，诊断保持在 stderr；AC-08 已验证 `.agents/skills` fallback、无 skills marker，以及根目录 `brain-index.md` 不变。
- 变更涉及的 shell 文件和 `tad.sh` 运行 `shellcheck --shell=bash --severity=error` — exit 0；shell portability 扫描未发现本次变更新增的 `grep -P`/`grep -oP`、bash 内 NUL、pgrep BRE alternation 或 Python timing 构造。
- stdout purity：envelope fixture 输出仅为预期归一化字段；detect-platform stdout 为单词、诊断为 stderr；manual gate usage/block 文本为 stderr；相关 AC 全部通过。
- 补充诊断：对完整 hook 集运行同一 error-level ShellCheck 时，仅报告未修改的 `.tad/hooks/lib/release-verify.sh:607` `SC1087`；本次变更文件子集为 exit 0，且请求的 parity 检查通过。该既有诊断不构成本任务的 P0/P1 代码问题。

未发现本次变更范围内的 P0/P1 代码问题。

Verdict: PASS (R2)
