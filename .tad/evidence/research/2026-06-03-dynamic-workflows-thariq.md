# A Harness for Every Task: Dynamic Workflows in Claude Code

> Source: https://x.com/trq212/article/2061907337154367865
> Author: Thariq Shihipar (@trq212) & Sid Bidasaria (@sidbid), Anthropic Claude Code team
> Date: 2026-06-03 (captured)
> Also: https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code

---

Last week, we released [dynamic workflows](https://code.claude.com/docs/en/workflows) in Claude Code. Claude can now write its own [harness](https://code.claude.com/docs/en/glossary#agentic-harness) on the fly, custom-built for the task at hand.

While the default Claude Code harness is built for coding, it is also useful for many other types of tasks because, as it turns out, many tasks resemble coding tasks. But there are certain classes of tasks where we have had to build custom harnesses on top of Claude Code to achieve peak performance such as [Research](https://support.claude.com/en/articles/11088861-using-research-on-claude), [security analysis](https://support.claude.com/en/articles/11932705-automated-security-reviews-in-claude-code), [agent teams](https://code.claude.com/docs/en/agent-teams), or [Code Review](https://code.claude.com/docs/en/code-review).

Workflows allow you to dynamically create harnesses that enable Claude to solve all of those problems and more natively inside of Claude Code. You can also share and re-use these workflows with others.

In this article, I'll cover my initial workflows experiences and learnings so you can take full advantage.

That said, best practices are still developing! Dynamic workflows often use more tokens, so think carefully about when and how to use them.

---

## Example Prompts

- "This test fails maybe 1 in 50 runs. Set up a workflow to reproduce it, form theories and adversarially test them in worktrees /goal don't stop until one theory works."
- "Using a workflow, go through my last 50 sessions and mine them for corrections I keep making and turn the recurring ones into CLAUDE.md rules"
- "Use a workflow to dig through #incidents in Slack for the past six months and find recurring root causes where nobody has filed a ticket."
- "Take my business plan and run a workflow where different agents tear it apart from an investor's, a customer's, and a competitor's perspective."
- "Here's a folder of 80 resumes, use a workflow to rank them for the backend role and double-check the top ten. Interview me using the AskUserQuestion tool for a rubric."
- "I need a name for this CLI tool. Use a workflow to brainstorm a bunch of options and run a tournament to pick the top 3."
- "Use a workflow to rename our User model to Account everywhere."
- "Go through my blog post draft and using a workflow verify every technical claim against the codebase, I don't want to ship anything wrong."

---

## How Dynamic Workflows Work

Dynamic workflows execute a javascript file with a few special functions that help spawn and coordinate [subagents](https://code.claude.com/docs/en/sub-agents):

### [DIAGRAM 1: API Reference]
```
agent(prompt, opts?): Promise<string | JsonSchema>

  const bugs = await agent(
    "audit auth.ts",
    {
      schema: BugList,          // schema: JSON Schema -> validated JSON output
      model: "haiku",           // model: opus / sonnet / haiku. Omit = inherit
      isolation: "worktree",    // isolation: "worktree" (checkout) or "remote"
      agentType: "reviewer",    // agentType: custom / built-in subagent
    })

RUN MANY - COMPOSE THE BLOCK:

  parallel([ fns ])                    pipeline(items, ...)
  Fan out, run at once.                Each item streams through every stage.
  Barrier - waits for all.             No barrier.

  const all = await parallel(          await pipeline(items,
    files.map(f =>                       x => agent(draft(x)),
      () => agent(f)))                   d => agent(check(d)))
```

Dynamic workflows also include standard JavaScript functions like JSON, Math, and Array, to help process data.

It's particularly useful to know that dynamic workflows can decide which models an agent uses and whether subagents are run in their own worktree, allowing Claude to choose the intelligence level and isolation needed.

If a workflow is interrupted, for example by user action or quitting the terminal, resuming the session will allow the workflow to pick up where it left off.

---

## Why Dynamic Workflows

When you ask the default Claude Code harness to do a task, it needs to both plan and execute in the same context window. For many coding tasks, this is highly effective, but it can sometimes break down over long-running, massively parallel and/or highly structured adversarial tasks.

This is because the longer Claude works on a complex task in a single context window, the more it becomes susceptible to a few specific failure modes:

- **Agentic laziness** refers to when Claude stops before finishing a particularly complex, multi-part task and declares the job done after partial progress, for example addressing 20 of the 50 items in a security review.
- **Self-preferential bias** refers to Claude's tendency to prefer its own results or findings, especially when asked to verify or judge them against a rubric.
- **Goal drift** refers to the gradual loss of fidelity to the original objective across many turns, especially after compaction. Each summarization step is lossy, and details like edge-case requirements or "don't do X" constraints can get lost.

Creating a workflow helps combat these by orchestrating separate Claudes with their own context windows and focused, isolated goals.

---

## Dynamic vs Static Workflows

You may have previously created a static workflow using the Claude Agent SDK or claude -p to coordinate multiple instances of Claude Code together.

But because static workflows need to work for all edge cases, they are usually more generic. With [Claude Opus 4.8](https://www.anthropic.com/news/claude-opus-4-8) and dynamic workflows, Claude is now intelligent enough to write a custom harness tailor-made for your use case.

### [DIAGRAM 2: Static vs Dynamic Comparison]
```
Question: "Should we migrate our checkout service to a new provider?"

STATIC HARNESS                          DYNAMIC WORKFLOW
  turn into 5 web searches               read our billing code
       |                                   /        |        \
  fetch top results                  billing/   webhooks/   taxes/
       |                                   \        |        /
     verify                          check each feature
       |                             against the new provider's docs
   summarize                                    |
       |                              devil's advocate:
  a generic research report           strongest case against migrating
                                                |
                                     a specific recommendation
```

Key insight: Static harness produces a **generic research report**. Dynamic workflow reads your actual code, classifies by module, checks each feature against the new provider's docs, runs a devil's advocate, and produces a **specific recommendation**.

---

## Helpful Patterns When Using Dynamic Workflows

You can start using dynamic workflows just by asking Claude to make one, or by using the trigger word "ultracode" to ensure that Claude Code creates a workflow.

### [DIAGRAM 3: Six Workflow Patterns]

### 1. Classify-And-Act
Use a classifier agent to decide on the type of task, and then route to different agents or behavior based on the task. Or, use a classifier at the end to determine output.
```
task -> [classifier] -> agent A
                     -> agent B
                     -> agent C
```

### 2. Fan-Out-And-Synthesize
Split up a task into many smaller steps, run an agent on each step and then synthesize those results. This is particularly useful for when there are a large number of smaller steps, or when each step benefits from its own clean context window so they don't interfere or cross-contaminate. The synthesize step is a barrier -- it waits for all the fan-out agents, then merges their structured outputs into one result.
```
task -> [fan-out] -> agent1 -> |barrier| -> synthesize
                  -> agent2 -> |       |
                  -> agent3 -> |       |
```

### 3. Adversarial Verification
For each spawned agent, run a separate spawned agent to adversarially verify its output against a rubric or criteria.
```
worker -> verifier1
       -> verifier2
       -> verifier3
```

### 4. Generate-And-Filter
Generate a number of ideas on a topic and then filter them by a rubric or by verification, dedupe duplicates and return only the highest quality, tested ideas.
```
generators -> ideas -> [filter: rubric + dedupe] -> best
                                                 -> discarded
```

### 5. Tournament
Instead of dividing the work, have agents compete on it. Spawn N agents that each attempt the same task using different approaches. Prompts or models then judge the results in a pairwise fashion using a judging agent until you have a winner.
```
attempts -> [pairwise judges] -> ... -> [final] -> winner
```

### 6. Loop Until Done
For tasks with an unknown amount of work, loop spawning agents until a stop condition is met (no new findings, or no more errors in the logs) instead of a fixed number of passes.
```
agent -> new findings? -> yes -> spawn another (loop)
                       -> no  -> done
```

---

## Use Cases

Think creatively of when and how to ask Claude Code to make dynamic workflows. I've found that workflows are sometimes even more useful for non-technical work.

### [DIAGRAM 4: Where Workflows Shine]
```
| Migrations        | Research           | Verification       | Sorting            | Rules              |
| one agent per fix | verified, cited    | one agent per      | rank 1,000+ items  | verifier per rule  |
|                   | reports            | claim              |                    |                    |
| Root cause        | Triage             | Taste              | Evals              | Routing            |
| competing         | classify and act   | explore vs a       | grade vs a rubric  | pick the model     |
| theories          |                    | rubric             |                    |                    |
```

### Migrations and Refactors

[Bun](https://bun.com/) was rewritten from Zig to Rust using workflows. You can read more about how that was done in [Jarred's X thread](https://x.com/jarredsumner/status/2060050578026189172).

The key is to break down the task into a series of steps that need to be operated on for example callsites, failing tests, modules, etc. Spin off a subagent for every fix in a worktree to make the fix, then have another agent adversarially review, and merge them. Consider telling the agent not to use resource intensive commands so that you can maximally parallelize without running out of resources on your machine.

### Deep Research

We published a deep research skill (/deep-research) inside Claude Code that uses dynamic workflows. Specifically, it fans-out web searches, fetches sources, adversarially verifies their claims, and synthesizes a cited report.

But you may do this sort of research for more than just web searches. For example, asking Claude to compile a status report from context in Slack or to research how a feature works by exploring a codebase in-depth.

### Deep Verification

### [DIAGRAM 5: Deep Verification Flow]
```
Report -> [Claim extractor:         -> Claim checker 1 -> (Source auditor) -\
           identifies every             verifies claim     checks source     |
           factual claim]           -> Claim checker 2 -> (Source auditor) --+-> Verified report
                                    -> Claim checker N -> (Source auditor) -/
```

On the other hand, if you have a report where you want to check and source every factual claim that it references you may want to generate a workflow which has one agent identify all of the factual claims and then spin off a subagent to check each one in-detail. You could also have a verification agent check the source subagent to make sure its source is high quality.

### Sorting

### [DIAGRAM 6: Tournament Sorting]
```
                 ROUND 1              ROUND 2            FINAL
1,000 items ->  item 17 vs 482  \
                (fresh agent)    -> winner vs winner \
                item 9 vs 731   /   (fresh agent)    \                      Sorted:
                (fresh agent)                         -> last comparison -> 1. item 88
                item 256 vs 88  \                    /   (fresh agent)      2. item 17
                (fresh agent)    -> winner vs winner/                       3. item 904
                item 904 vs 3   /   (fresh agent)                          ...
                (fresh agent)                                              1000. item 612
```

You may have a list of items that you want to sort by some qualitative measurement that you believe that Claude Code is good at evaluating, for example: support tickets sorted by severity of the bug. But if you try to sort 1000+ rows in one prompt, quality degrades and it won't fit in context. Instead run a tournament, a pipeline of pairwise-comparison agents (comparative judgment is more reliable than absolute scoring), or bucket-rank in parallel then merge. Each comparison is its own agent, so the deterministic loop holds the bracket and only the running order stays in context.

### Memory and Rule Adherence

### [DIAGRAM 7: Rule Adherence Flow]
```
The diff          The rules - one verifier agent each
+142 lines  ->    1. money is integer cents - never floats        -> * line 42  \
-87 lines         2. every migration ships with a rollback        -> clean       \
                  3. never swallow errors - propagate or log      -> * line 90   -> [Skeptic:        -> Confirmed
                  4. timestamps are UTC, everywhere, always       -> clean          re-reads each       violations
                  5. API responses never leak internal IDs        -> clean          flag - real         only
                                                                                    violation, or
                  one verifier agent per rule - clean context each                  false positive?]
```

If you have a particular set of rules that you find Claude misses or struggles with, even when put into the CLAUDE.mds, create a workflow with a list of rules that must be checked by verifier agents -- one verifier per rule. Creating a skeptic persona subagent to review the rules to make sure they are in line will help avoid too many false positives.

The reverse direction works too: mine your recent sessions and code review comments for corrections you keep making, cluster them with parallel agents, adversarially verify each candidate (would this rule have prevented a real mistake?), and then distill the survivors back into a CLAUDE.md.

### Root-Cause Investigation

Debugging works best when you come up with several independent hypotheses and test them, but if you're only using one context window, Claude can run into self-preferential bias. A workflow can structurally prevent this by spinning up agents to generate hypotheses from disjoint evidence. For example, separate agents for logs, files, and data. Each hypothesis can then face a panel of verifiers and refuters.

This isn't just for code. Workflows can be used for sales (why did sales drop in March?), data engineering (why did this pipeline fail?), or any post-mortem exercise.

### Triaging at Scale

### [DIAGRAM 8: Triage with Quarantine]
```
QUARANTINE                                          TRUSTED
The backlog ->  Reader agents - one per item   ->  Action agent
                read the untrusted content,        acts on summaries - never raw content
                classify it                                |
                     |                                   /   \
                  Dedup:                          attempt fix  escalate
                  doesn't already tracked?                    to a human
                     |
                structured summary only
```

Every team has a support queue, bug reports, or some other backlog that cannot be fully processed by humans.

A triage workflow classifies each item, dedupes against what's already tracked, and takes action. This could mean attempting the fix or escalating to a human user.

A useful pattern for triage workflows is quarantine. This involves barring the agents that read untrusted public content from taking high-privilege actions, which are instead done by the agents in charge of acting on the information.

Pair triage workflows with /loop to have Claude do this continuously.

### Exploration and Taste

Workflows can be useful when exploring different approaches to a solution, especially when it is taste based, like design or naming, and would benefit from a rubric.

Try asking Claude to explore a bunch of solutions, and give a review agent a rubric for what a good solution looks like. The task is complete when the review agent feels like it has met the criteria. Solutions can also be ordered or selected via a tournament based on the rubric.

### Evals

You can run lightweight evals for particular tasks by spinning off separate agents in a worktree and then spinning off comparison agents to compare and grade the specific outputs against a rubric. For example, evaluating and then refining a skill you've created against a particular criteria.

### Model and Intelligence Routing

Create a classifier agent tuned to your tasks that decides which model to use. This can be helpful when your task will involve many tool calls and conducting research prior to execution can identify the best model for the job.

For example, the best model for the task "explain how the auth module works" depends on how many files in the auth module there are and the shape of the codebase. A classifier agent can do this research and then route to Sonnet or Opus based on the expected complexity of the task.

---

## When NOT to Use Dynamic Workflows

Workflows are new. While there are many use cases where it will create outsized results, they are not needed for every task and may end up using significantly more tokens.

It's best to use workflows creatively to push Claude Code in ways that you haven't previously. For regular coding tasks, try and ask yourself does it really need more compute? For example, most traditional coding tasks do not need a panel of 5 reviewers.

---

## Tips for Building Dynamic Workflows

### Prompting
Detailed prompting, using the specific techniques we described above, for dynamic workflows creates the best results.

Workflows are not just for large tasks. You can prompt the model to use a "quick workflow." For example, you can create a quick adversarial review of an assumption.

### Combine with /goal and /loop
When using workflows that can be repeated, for example triage, research, or verification, pair them with /loop to be run at regular intervals, and /goal to set a hard completion requirement.

### Token Usage Budgets
You can set explicit token usage budgets for dynamic workflows to limit how many tokens a task uses. You can prompt it with a budget like: "use 10k tokens," which will set the cap.

### Saving and Sharing Dynamic Workflows

You can save workflows by pressing "s" in the workflow menu. You can check these into `~/.claude/workflows` or distribute them via a skill.

### [DIAGRAM 9: Skill Distribution]
```
SKILL FOLDER                           SKILL.md
~/.claude/skills/deep-verify/          name: deep-verify
|-- SKILL.md                           description: Verify every claim in a report
|-- verify-claims.workflow.js          ---
|-- rubric.md                          ## workflow
                                       Run ./verify-claims.workflow.js to check
The workflow file stays inside the     each claim with its own subagent.
skill. Right next to SKILL.md

Share the folder - anyone who installs the skill runs the same workflow.
```

To share them via a skill, put your JavaScript workflow files in the skill folder and reference them in the SKILL.MD. To allow for more flexibility, you may want to prompt Claude to think of the workflows in the skill as a template instead of a script that needs to be run verbatim.

---

## A Whole New World

Workflows are a helpful new way to extend Claude Code. I encourage you to think of this as a starting point, there's still much to discover in how to use them best. Let us know what you find.

*Thariq Shihipar and Sid Bidasaria (@sidbid) are members of technical staff at Anthropic, working on Claude Code.*
