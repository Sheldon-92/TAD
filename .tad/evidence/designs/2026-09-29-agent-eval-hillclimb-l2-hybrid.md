# Design：hillclimb 方法句落 L2 hybrid

**Mode**: *analyze → *design（docs-only land design）
**Status**: READY_FOR_GATE2
**Date**: 2026-09-29
**Channel / model**: Cursor / grok-4.7-medium @grokbox
**Task ID**: `TASK-20260929-AGENT-EVAL-HILLCLIMB-L2`
**Prior discuss**: `.tad/evidence/discuss/2026-09-29-agent-eval-vehicle-choice.md` §3 + §5（载体已定 hybrid）。措辞吸收仅用 `.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md`「可选吸收」表第 1–2 行。

## Human locks

- 采纳 hybrid。方法句的家是既有 `.tad/project-knowledge/patterns/pack-evaluation.md` 追加一条；`patterns/_index.md` 只改 Pack Evaluation 那一行钩子。
- `ai-evaluation` 最多一行交叉引用。本设计已读 `references/`：同句缺失 → **ONE cross-ref line**（见下）。不把该包改写成爬坡工作流。
- 本席不改 live pattern / pack / SKILL。草稿只在本设计与 handoff。
- 本席不跑 Gate 2 双审。状态停在 `READY_FOR_GATE2`。
- 不发明新 Gate 编号，不新开 hillclimb slash，不改 `*experiment`。

苏格拉底未再提问：人锁写明 do not re-ask；载体与范围已在 discuss §5 与本轮 HUMAN LOCK 里闭合。

## Problem

爬坡纪律（先量噪声地板、标题只报未参与本轮修改的对照面、一轮一个变量、失败样例不写进会进模型上下文的被优化说明、五行 audit 只是证据形状）还没有一句落在 Alex/Blake 会读到的 L2。`principles.md` 的 Measure Before Optimizing 与 `pack-evaluation.md` 已有的负对照，管的是「先测再优化」和「无负对照即剧场」，不管「同一套题重跑的抖动」和「见过的题上变绿」。`ai-evaluation` 的 keywords 会在人谈评测时发指针，但包正文没有这三句流程约束。discuss §3 已把家定在 L2，包只做指针。

## Exact paste-ready L2 entry

Blake 追加到 `.tad/project-knowledge/patterns/pack-evaluation.md` 文件末尾（现有最后一条「Named Workflow Resolution…」之后）。不改既有条目。

```markdown
### Declare Improvement Only Past a Noise Floor, on a Held-Out Headline, One Variable per Round - 2026-09-29
- **Context**: Method sentences for an optimization round on a prompt, skill, tool description, or grader. Home is this L2 file (discuss `.tad/evidence/discuss/2026-09-29-agent-eval-vehicle-choice.md` §5; wording from optional-absorb rows 1–2 in `.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md`). Not a new Gate number and not a slash command.
- **Discovery**: A delta inside the re-run noise of the same suite is not an improvement. A headline taken from items this round already edited against can rise because those items were seen. Changing more than one variable in a round makes the delta unattributable. Fail samples copied into the artifact under optimization leak into model context.
- **Action**: Before declaring an improvement: measure the noise floor on the unchanged suite and refuse the claim when that floor is larger than the smallest lift you would act on; take the headline number only from a held-out surface this round did not edit against; change one variable per round, then read the delta; do not write fail samples into the optimized artifact that enters model context (keep an evidence path instead). Leave this 5-line AUDIT SHAPE as evidence, not as a new Gate number: task; harness; metrics; grader; can-this-set-detect-the-change. 「见过的题上变绿」是标题数字涨在本轮已经用来改被优化说明的题上，只说明这些题进过上下文。「结构绿冒充行为绿」是文件、计数或 grep 过了，却没有负对照把行为分开。
- **failure_mode**: Naive default: announce an improvement from a higher score on the items this round already edited, or from a green structure count with no negative control. Why wrong: 无负对照即剧场 — the touched-surface score and the structure pass both fail to show that this set detected the change.
- **Grounded in**: `.tad/evidence/discuss/2026-09-29-agent-eval-vehicle-choice.md` §5.1; `.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md` optional-absorb rows 1–2
```

## Exact paste-ready `_index.md` Pack Evaluation line

替换现有 Pack Evaluation 那一行（不要新增第二行）。钩子 86 字符，≤120。

```markdown
- [Pack Evaluation](pack-evaluation.md) — Anti-slop, cross-model, discriminative gates, dogfood, blind A/B, 噪声地板, held-out, 一轮一改
```

现钩子（131 字符，已超格式上限）被这条替换，并保留 anti-slop / cross-model / discriminative / dogfood / blind A/B，补上人锁的三个检索词。

## ai-evaluation `references/` audit

2026-09-29 已读（人点名 escalate）。全包 `rg`（noise floor / 噪声地板 / held-out / hold-out / holdout / one variable per round / 一轮一变 / 一轮一改 / 见过的题上变绿 / 结构绿冒充行为绿）在 `.agents/skills/ai-evaluation/**/*.md` **零命中**。

| File | Same sentence? | Nearest neighbor (not the same sentence) |
|------|----------------|------------------------------------------|
| `references/eval-framework-workflow.md` | No | EF1「Output Variance」；「Pass@1 … = statistical noise」；capability floor = Pass@k |
| `references/benchmark-rules.md` | No | B5 ≥3 repeats；B5/B8「capability floor」= Pass@k，不是宣布改进前的噪声地板 |
| `references/regression-rules.md` | No | Anti-pattern「Noise masquerades as regression」禁止把噪声当回归；golden baseline ≠ held-out 标题 |
| `references/ab-testing-rules.md` | No | AB1「n=20 … differences are noise」是样本量 Wilson 区间；AB7 同一题集 ≠ 未参与本轮的对照面 |
| `references/human-eval-protocol.md` | No | HE6「label leakage」/过饱和题集，不是失败样例写进被优化说明 |
| `references/adversarial-rules.md` | No | 「GitHub README headlines」是产品宣传语，不是评测标题数字 |
| `references/pipeline-rules.md` | No | CI 分层 / 预算 / 阻断合并，无这三句 |

**Decision: ONE cross-ref line.** `references/` 零编辑。唯一插入点：`.agents/skills/ai-evaluation/SKILL.md`，紧接现有分界句（约第 25 行）`Pack = evaluation judgment. Your workflow system = process constraints. No overlap.` 之后，不加新标题、不加 subcommand。

Paste-ready（一行）:

```markdown
流程约束（噪声地板、held-out 标题、一轮一变）见 L2 `.tad/project-knowledge/patterns/pack-evaluation.md` 条目「Declare Improvement Only Past a Noise Floor, on a Held-Out Headline, One Variable per Round」。本包不改写成爬坡工作流。
```

## Blake pathspec

只允许这三处，且仅在 Gate 2 双审 PASS 且人说「当 Blake」之后：

1. `.tad/project-knowledge/patterns/pack-evaluation.md` — 文末追加上面那一条。
2. `.tad/project-knowledge/patterns/_index.md` — 只替换 Pack Evaluation 那一行。
3. `.agents/skills/ai-evaluation/SKILL.md` — 只插入上面那一行交叉引用。

## Acceptance criteria

实现前这三条「必须出现」的检查会失败。2026-09-29 Alex 空跑：全包 `rg` 零命中（同句尚未落地）。Blake 落地后应全部通过。

1. L2 条目在，且两句失败类与五行 audit 都在该文件、不在 `gate-design.md`。
   - `grep -F 'Declare Improvement Only Past a Noise Floor, on a Held-Out Headline, One Variable per Round' .tad/project-knowledge/patterns/pack-evaluation.md`
   - `grep -F '见过的题上变绿' .tad/project-knowledge/patterns/pack-evaluation.md`
   - `grep -F '结构绿冒充行为绿' .tad/project-knowledge/patterns/pack-evaluation.md`
   - `grep -F '无负对照即剧场' .tad/project-knowledge/patterns/pack-evaluation.md`
   - `grep -F 'can-this-set-detect-the-change' .tad/project-knowledge/patterns/pack-evaluation.md`
   - `grep -F 'can-this-set-detect-the-change' .tad/project-knowledge/patterns/gate-design.md` 必须无输出。
2. 索引钩子含三个检索词且钩子 ≤120 字符。
   - `grep -F '噪声地板' .tad/project-knowledge/patterns/_index.md`
   - `grep -F 'held-out' .tad/project-knowledge/patterns/_index.md`
   - `grep -F '一轮一改' .tad/project-knowledge/patterns/_index.md`
   - `python3 -c "import pathlib; line=next(l for l in pathlib.Path('.tad/project-knowledge/patterns/_index.md').read_text().splitlines() if l.startswith('- [Pack Evaluation]')); hook=line.split(' — ',1)[1]; assert len(hook)<=120, len(hook); print(len(hook))"`
3. 包内交叉引用恰好一行，且 `references/` 仍无同句。
   - `grep -c 'patterns/pack-evaluation.md' .agents/skills/ai-evaluation/SKILL.md` 输出 `1`
   - `grep -RIn 'patterns/pack-evaluation.md' .agents/skills/ai-evaluation/references` 必须无输出
   - `grep -RIn '见过的题上变绿' .agents/skills/ai-evaluation/references` 必须无输出
4. 范围外文件无 diff。
   - `git diff --exit-code -- .tad/project-knowledge/principles.md .tad/project-knowledge/patterns/gate-design.md .agents/skills/agent-skill-evolution .tad/capability-packs/pack-registry.yaml`

## Non-goals

- 不改 `principles.md`。
- 不把句子写进 `gate-design.md`，不新增 Gate 编号。
- 不新建 skill 或 pack；不改 `agent-skill-evolution`；不把它补进 `pack-registry.yaml`。
- 不改 `*experiment` 协议，不把本工作改名为 experiment。
- 不改 PM 文案，不采纳 `docs/pm/ops/` 草稿，不把 discuss 可选吸收第 3–5 行并进本刀。
- 不写 Claude Code / `/claude-api` 命令名进 L2 或 pack。
- 不 git push。本席不替 Blake 改产品文件。

## Friction

Docs-only 追加。无新依赖、无外部 CLI、无密钥。Gate 2 双审是下一刀的审查者，不是本文件能跳过的步骤。

READY_FOR_GATE2

SUMMARY: Hybrid 设计已落盘——L2 追加一条 hillclimb 纪律、索引钩子补三个检索词、`ai-evaluation` 只加一行指向该条目的交叉引用；Gate 2 双审仍未做。
