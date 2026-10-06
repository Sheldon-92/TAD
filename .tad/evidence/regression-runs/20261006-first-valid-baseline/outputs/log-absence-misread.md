
✱ Glob "**/NEXT.md" 1 match
✱ Glob "**/case.md" 0 matches

$ ls -la /home/box/p3-skeleton-tad && echo "---NEXT---" && ls /home/box/p3-skeleton-tad/NEXT.md 2>/dev/null
total 572
-rw-r--r--  1 box box     94 Sep 22 11:01 -guard-tmp.log
drwxr-xr-x 23 box box   4096 Oct  6 08:13 .
drwx------  1 box box   4096 Oct  6 08:05 ..
drwxr-xr-x  3 box box   4096 Sep 12 17:07 .agents
drwxr-xr-x  4 box box   4096 Sep 16 21:03 .claude
drwxr-xr-x  2 box box   4096 Oct  6 08:07 .codex
drwxr-xr-x  2 box box   4096 Oct  6 08:07 .cursor
drwxr-xr-x  8 box box   4096 Oct  6 08:12 .git
-rw-r--r--  1 box box   4838 Sep 22 11:02 .gitignore
-rw-r--r--  1 box box    856 Sep 22 11:02 .npmignore
drwxr-xr-x  5 box box   4096 Oct  6 08:07 .opencode
drwxr-xr-x  4 box box   4096 Sep 12 17:16 .reading
drwxr-xr-x  3 box box   4096 Sep 12 17:08 .research
drwxr-xr-x 41 box box   4096 Oct  6 08:07 .tad
drwxr-xr-x  3 box box   4096 Oct  6 08:07 .tad-backup
drwxr-xr-x 40 box box   4096 Oct  6 08:07 .tad.backup.20261006_080747
drwxr-xr-x  2 box box   4096 Sep 12 21:45 .vscode
-rw-r-----  1 box box  12779 Oct  6 08:07 AGENTS.md
-rw-r--r--  1 box box 133495 Sep 22 11:02 CHANGELOG.md
-rw-r--r--  1 box box   7784 Oct  6 03:21 INSTALLATION_GUIDE.md
-rw-r--r--  1 box box   1068 Sep 22 11:01 LICENSE
-rw-r--r--  1 box box  50805 Oct  6 03:21 NEXT.md
-rw-r--r--  1 box box   5029 Sep 22 11:02 OBJECTIVES.md
-rw-r--r--  1 box box  19161 Oct  6 03:21 PROJECT_CONTEXT.md
-rw-r--r--  1 box box  32327 Oct  6 03:21 README.md
-rw-r--r--  1 box box   4043 Oct  6 03:21 ROADMAP.md
drwxr-xr-x  2 box box   4096 Sep 12 22:37 assets
drwxr-xr-x  2 box box   4096 Sep 15 20:58 bin
drwxr-xr-x  3 box box   4096 Sep 12 17:08 codex-tad-bundle
drwxr-xr-x  6 box box   4096 Oct  6 03:21 docs
drwxr-xr-x  3 box box   4096 Sep 12 18:25 experiments
-rw-r--r--  1 box box    448 Oct  6 08:13 p2-closeout.md
-rw-r--r--  1 box box    431 Oct  6 08:13 p2-review-record.md
-rw-r--r--  1 box box      5 Oct  6 08:12 p2-write-target.txt
-rw-r--r--  1 box box   1681 Oct  6 03:21 package.json
drwxr-xr-x  9 box box   4096 Sep 16 21:03 research
drwxr-xr-x  3 box box   4096 Sep 12 17:10 scripts
drwxr-xr-x  3 box box   4096 Sep 12 22:51 supabase
-rwxr-xr-x  1 box box   6298 Sep 22 11:02 tad
-rw-r--r--  1 box box  21533 Sep 22 11:01 tad-intro-feedback.html
-rw-r--r--  1 box box   7426 Sep 22 11:02 tad-intro.html
drwxr-xr-x  7 box box   4096 Sep 12 18:53 tad-work
-rwxr-xr-x  1 box box 130897 Oct  6 03:21 tad.sh
---NEXT---
/home/box/p3-skeleton-tad/NEXT.md

✱ Grep "log-absence-misread|log_absence|absence-misread|case\.md" 28 matches

$ find /home/box/p3-skeleton-tad -iname "*case*" -not -path "*/.git/*" 2>/dev/null; echo "---"; ls /home/box/p3-skeleton-tad/.tad
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/active/research/todo-app-ui/component-showcase.html
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/active/research/saas-pm-tool/a11y-showcase.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/active/research/saas-pm-tool/component-showcase.html
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/activation-bypass/case.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/log-absence-misread/case.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/regression-samples/cases/tmp-capture-collision/case.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/spikes/SPIKE-20260407-domain-pack-hook/test-cases.yaml
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/yolo/yolo2-verified-orchestration/phase2/dogfood/cases
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/completions/phase1-state-consistency/regression-phase2b-30case.txt
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.log
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.md
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.exit
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/sync-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/filter-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/filter-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/routine-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/evidence-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/date-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/evidence-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/rename-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/date-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/sync-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/routine-V/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/experiments/thin-tad-pilot/cases/rename-H/case.json
/home/box/p3-skeleton-tad/.tad.backup.20261006_080747/evidence/epic-p2-measurement-20261006/drill-p1-case-a-interrupt-recovery.md
/home/box/p3-skeleton-tad/.tad/active/research/todo-app-ui/component-showcase.html
/home/box/p3-skeleton-tad/.tad/active/research/saas-pm-tool/a11y-showcase.json
/home/box/p3-skeleton-tad/.tad/active/research/saas-pm-tool/component-showcase.html
/home/box/p3-skeleton-tad/.tad/regression-samples/cases
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/activation-bypass/case.md
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/log-absence-misread/case.md
/home/box/p3-skeleton-tad/.tad/regression-samples/cases/tmp-capture-collision/case.md
/home/box/p3-skeleton-tad/.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/test-cases.yaml
/home/box/p3-skeleton-tad/.tad/evidence/yolo/yolo2-verified-orchestration/phase2/dogfood/cases
/home/box/p3-skeleton-tad/.tad/evidence/completions/phase1-state-consistency/regression-phase2b-30case.txt
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-2.exit
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.exit
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-3.exit
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.log
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-1.exit
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-4.md
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-6.exit
/home/box/p3-skeleton-tad/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/case-5.exit
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/sync-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/filter-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/filter-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/routine-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/evidence-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/date-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/evidence-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/rename-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/date-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/sync-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/routine-V/case.json
/home/box/p3-skeleton-tad/.tad/evidence/experiments/thin-tad-pilot/cases/rename-H/case.json
/home/box/p3-skeleton-tad/.tad/evidence/epic-p2-measurement-20261006/drill-p1-case-a-interrupt-recovery.md
---
CHANGELOG.md
README.md
TAD-POINTER.md
TAD-VERSION
active
agents
archive
brain-index.md
capability-packs
codex
config-agents.yaml
config-cognitive.yaml
config-execution.yaml
config-platform.yaml
config-quality.yaml
config-workflow.yaml
config.yaml
context
cross-model
data
decisions
dependencies
deprecation.yaml
discipline-floor-budget.md
discipline-floor.md
domains
eval
evidence
gates
github-registry
guides
hooks
logs
manifest.yaml
mcp-registry.yaml
memory
migrations
pair-testing
platform-codes.yaml
portable-extract.sh
portable-rules.md
project-detection.yaml
project-knowledge
ralph-config
references
regression-samples
reports
research-notebooks
routing-contract.yaml
runtime-compat
schemas
scripts
skill-library
skills
skills-config.yaml
spike-v3
sub-agents
tasks
templates
tests
version.txt
workflows
working

→ Read .tad/regression-samples/cases/log-absence-misread/case.md
→ Read .tad/regression-samples/cases/log-absence-misread/input.md

$ ls -la /home/box/p3-skeleton-tad/.tad/regression-samples/cases/log-absence-misread/
total 20
drwxr-x--- 2 box box 4096 Oct  6 03:01 .
drwxr-x--- 5 box box 4096 Oct  6 02:39 ..
-rw-r----- 1 box box 2622 Oct  6 08:07 case.md
-rw-r----- 1 box box 1596 Oct  6 08:07 control.md
-rw-r----- 1 box box  865 Oct  6 08:07 input.md

→ Read .tad/tasks/evidence-collection.md
→ Read .tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md
→ Read .tad/regression-samples/cases/log-absence-misread/control.md

$ ls /home/box/p3-skeleton-tad/.tad/project-knowledge/ && echo "---patterns---" && ls /home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ 2>/dev/null
README.md
architecture.md
code-quality.md
frontend-design.md
incidents
patterns
principles.md
security.md
---patterns---
_index.md
ac-verification.md
capability-ownership.md
gate-design.md
handoff-design.md
hook-contracts.md
memory-and-learning.md
pack-build-rules.md
pack-evaluation.md
process-tax-cut.md
release-sync.md
research-methodology.md
shell-portability.md

→ Read .tad/project-knowledge/principles.md
→ Read .tad/project-knowledge/patterns/_index.md

$ ls /home/box/p3-skeleton-tad/.tad/project-knowledge/incidents/ 2>/dev/null; echo "---grep log/pairing---"; grep -rl "日志误判\|log-absence\|pairing\|配对\|负证据" /home/box/p3-skeleton-tad/.tad/project-knowledge/ 2>/dev/null
2026-05
2026-06
_index.md
---grep log/pairing---
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/pack-evaluation.md
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ac-verification.md

→ Read .tad/project-knowledge/patterns/ac-verification.md

$ grep -rn "Positive behavior\|positive probe\|absence\|negative evidence\|负证据" /home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/*.md | head -40
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/_index.md:14:- [Capability Ownership](capability-ownership.md) — Internalized capability vs hidden runtime dependency; require positive behavior plus absence proof
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ac-verification.md:133:- **Discovery**: (1) State isolation and authentication are a tradeoff, not a free win: the same isolation that protects user state removes the credentials the probe needs — plan the auth path (copy/mint credentials into the scratch home, or budget an authenticated turn) at spike-design time, or pre-declare which branch fires when auth is unreachable. (2) "Couldn't measure" (401, budget cap) is NOT "measured absent" — the honest-mapping branches a contract pre-authorizes for measured absence must not silently absorb unmeasured cases; the safe absorption is only legitimate when the terminal states happen to coincide with the most conservative branch, and the evidence must say "unmeasured", never "absent". (3) Fixture suites prove parser/consumer behavior under assumed envelope shapes; they prove nothing about runtime delivery — an AC set that is all-fixtures must label the delivery question open.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ac-verification.md:134:- **Action**: When designing spikes that need runtime state isolation: enumerate what the isolation strips (auth, trust, caches, budget) and either provision it deliberately or pre-register the couldn't-measure branch with its own terminal states (distinct from measured-absence). Keep an oracle that binds implementation inputs to measured evidence (set-equality) so unmeasured candidates cannot be promoted. Queue the authenticated re-probe as an explicit follow-up, not a silent loss.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ac-verification.md:135:- **failure_mode**: Naive default: treat probe failure as equivalent to "feature not supported" and take the honest-absence branch, or quietly fall back to documentation values so the feature can ship "complete". Why wrong: the first fabricates a measurement that never happened (the ledger then reports verified-absent on zero evidence); the second is exactly the doc-evidence-as-verified failure the ledger discipline exists to block.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/ac-verification.md:158:  those literal commands against absence fixtures (file/key/env/glob missing) instead of a wrapper.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/capability-ownership.md:12:  behavioral AC with an absence proof: scan portable runtime/docs for the old boundary and run the
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/handoff-design.md:170:- **Discovery**: An inventory format that requires a carrier for "covered" and requires nothing for "not needed" is not uniformly rigorous — it is rigorous exactly where the risk isn't. A covered row must name something, so it can be checked, and checking found no problems. A not-needed row asserts an absence, so there is nothing to check and no later step that can fail; a wrong judgment there is undetectable by construction and stays wrong silently. The bundling makes it worse: the retired row named a *mechanism* (startup routing and its scans) rather than the *functions* riding on it, and the rationale priced the mechanism as overhead — true of the routing, false of the scans, and the bundle let one judgment cover both. Two properties reliably mark this shape: the disposition is justified by cost rather than by redundancy, and it names a delivery mechanism rather than an outcome. The audit question that exposes it is not "was this dispositioned" — that re-runs the original judgment — but "if the old channel were frozen today, what would stop happening, and what carries it now"; that one is falsifiable, and a row that cannot answer it is a loss regardless of what its rationale says.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/shell-portability.md:163:- **Discovery**: Tilde expansion happens at **lexical parse time** and only for an unquoted literal `~` at the start of a word. A path that arrives as *data* — from a variable, a file, a loop, a config table — is never re-parsed, so `p='~/.claude/CLAUDE.md'; test -f "$p"` returns false and `wc -c < "$p"` errors, for a file that plainly exists (reproduced on zsh 5.9). The consequence was worse than the original bug it fixed: the row got marked `MISSING`, counted as 0, and **the repair re-introduced the exact 927-byte undercount it was written to remove** — this time wearing a "faithfully reported MISSING" disguise, which is harder to spot than a plain omission. Second-order trap: the failure is indistinguishable from genuine absence, so a contract clause like "report honestly if the measured missing-set differs from the expected one" actively *rewards* propagating the error. A related collation hazard travels with tilde paths: `~`(0x7E) sorts after `C`(0x43) under `LC_ALL=C` but before it under the default UTF-8 locale, so any `comm` over a manifest containing both is order-undefined unless the locale is pinned.
/home/box/p3-skeleton-tad/.tad/project-knowledge/patterns/shell-portability.md:164:- **Action**: In any path manifest or config consumed as data, store `$HOME` and dereference as `"$HOME/..."` (double quotes expand the variable; they do not expand tilde). Reserve `~` for display tables and literal-comparison anchors, and annotate at that spot that the *value* must be taken via `$HOME`. For every entry that crosses the home boundary, pin a ground-truth counter-check (e.g. "927 bytes / 499 chars — if this row reads MISSING, the tilde-expansion convention was misapplied, the file is not absent"), which is what makes a shell bug distinguishable from real absence. Pin `LC_ALL=C` on every `sort` feeding a manifest that mixes `~`-prefixed and bare-relative paths.

$ grep -rn "BrowserSkill\|日志\|negative\|absence\|probe\|探针" /home/box/p3-skeleton-tad/.tad/project-knowledge/incidents/_index.md 2>/dev/null; echo "---journal---"; ls /home/box/p3-skeleton-tad/.tad/evidence/journal/ 2>/dev/null | grep -i "sweep\|browser\|pair\|2026-10-05\|2026-10-06" 
---journal---
local-wiki-phase3-browser-ingest-2026-09-02.md

# 案三回答：日志零行不能推定「未发生」，更不能推定配对丢失

**结论（两个断言都不成立）：**

1. **不能据此断言扩展没有发起过请求。** 日志摘录里没有 authorize（配对交换）记录行，只是**日志零行**，不等于该请求未发生。
2. **不能由日志缺行推定服务端配对已失效或丢失。** 配对存否的正确核查对象是**服务端授权记录**，不是 daemon 日志。

---

## 依据一：本案的盲区形态是「失败交换不落日志」

配对交换走的是 `POST /extension/authorize`。**失败的配对交换在 daemon 日志里不记行**——源事件已实测：用假令牌打该端点为 401，日志仍为零行（`.tad/tasks/evidence-collection.md`「Negative Evidence Discipline」实例；本案判断正本 `.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md` §C1 记为「日志误判」）。

因此，日志中没有 authorize 行，至多证明**没有一次成功的配对交换被记录**；它并不能证明扩展没拨号。事发时段同一份日志还显示 `tunnel probe: mac_port_ok (ws handshake 101)`，隧道握手正常，更不能把问题归为链路或配对失效。

## 依据二：负证据纪律——结论依赖「未发生」时须附**正向探针**

`.tad/tasks/evidence-collection.md` 明定：一个「某事没有发生」的发现（无日志行、无文件、无事件、空搜索结果），其证据强度只等于它背后的探针强度。

- **先探针、后结论**：当结论依赖一个缺席时，必须先跑一个**正向探针**——若该事件真的发生、这个探针本应能检出它（对端点打一个已知坏令牌、让一条 canary 记录穿过管线、跑一个有已知命中的控制查询）——并把探针与结果与结论一并归档。**当失败路径从未被证明会写日志时，沉默的日志什么也证不了。**
- **标注强度**：若无法做正向探针，结论必须带显式证据强度标签（`probed` / `observed-absent` / `assumed`）。未标注的缺席断言过不了 Gate 审查。

本案中，据零行直接下断言，正是被实证推翻过三次的误判形态（「据日志无行判扩展没拨号」此前已逐次更正）。

## 依据三：配对状态应查服务端授权记录

daemon 侧设备授权有独立持久存储，`device_ttl=90d`（摘要两次 `daemon start, config loaded, device_ttl=90d`），daemon 重启不丢，且没有任何授权失效、撤销或过期的记录。但这份日志同样只是「没有显示异常」，本身不构成配对尚存的实证——必须去查服务端授权记录本体。症状（弹窗「无法读取连接设置」、退回未连接态）更指向**扩展侧连接设置层损坏／读不出**，而非服务端授权丢失。

## 实证路径（先做这个再下结论）

1. 从 Mac 侧用真令牌对 `POST /extension/authorize` 做一次**正向探针**：返回 200 且签发 `device_id`，才算服务端健康、配对可用；配一次已知坏令牌作对照，证明该探针通道确实能区分成败。
2. 或在用户已在弹窗就位后，最后才生成一次性配对链接（TTL 仅 300 秒）走一次真交换。
3. 直接查服务端**授权记录**确认配对条目是否存在、是否过期/撤销。
4. 在拿到上述任一项之前，若必须给结论，须标注为 `assumed`（或 `observed-absent`），不得当成实锤。
