# Spike Evidence — Headless Cron GitHub Scan (2026-07)

**Handoff**: HANDOFF-20260713-native-capability-adoption-phase3.md (FR3)
**Probe vehicle**: `claude -p` (Claude Code 2.1.172), run from repo root
(`/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_a4ff2d3f-9c0-3` — Phase 3 isolated worktree)
**Prompt**: cron-prompt.md body (BEGIN/END PROMPT markers) + scope override line
"execute the scan with --domain ai-agents (limit to the ai-agents domain only)"
**Date**: 2026-07-13
**API budget**: ai-agents domain only — 5 REST `gh api commits` calls + 1 `gh search repos` call

## Probe environment note (permission scoping)

The first probe attempt with broad `--allowedTools "Bash,Read,Write,Edit,Glob,Grep"` was
denied by the outer session's auto-mode permission classifier (nested autonomous agent with
unrestricted shell/write). The probe was re-run with a minimal, task-scoped permission set —
read-only gh commands + write access to exactly one file:

```
--allowedTools "Read,Glob,Grep,Bash(gh api:*),Bash(gh search:*),Bash(date:*),Bash(sleep:*),Write(.tad/github-registry/scan-log.yaml),Edit(.tad/github-registry/scan-log.yaml)"
```

This succeeded end-to-end. Implication for the Conductor: the cron routine's permission
config should grant at least this set (the real scheduled routine runs in a main-session
context where the nested-agent classifier does not apply). The denial is a property of
Blake's sandboxed sub-agent environment, not of `claude -p` headless mode itself.

---

## Question (i): Does the headless session see gh CLI auth (keychain)?

**Command**: `claude -p "Run the command: gh auth status. Then print its raw output verbatim (mask nothing except what gh itself masks)." --allowedTools "Bash"`

**Raw output**:

```
`gh auth status` 的原始输出如下（除 gh 自身对 token 的掩码外未做任何处理）：

github.com
  ✓ Logged in to github.com account Sheldon-92 (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'delete_repo', 'gist', 'read:org', 'repo'

已登录 github.com，账号 Sheldon-92（凭据存在 keyring），git 操作走 HTTPS，token 权限包括 repo、gist、read:org 和 delete_repo。
```

**Result (i): SATISFIED** — headless session reads the keyring-stored gh credential.

---

## Question (ii): Is the SKILL protocol parsed and followed headlessly, with zero interactive prompts?

**Evidence A — main probe run 1 raw output** (full transcript, `/tmp/spike-probe-run1.txt`):

```
✅ Scan complete: 4 lists updated, 4 new candidates found (1 previously rejected preserved).
Results saved to .tad/github-registry/scan-log.yaml
Alex will report next time on session start (STEP 3.9).

Run details (ai-agents domain only, per scope override):

- **Freshness (Step 2)**: 4 of 5 registered lists have commits newer than their last_checked (2026-05-04) — awesome-llm-apps (2026-07-11), awesome-ai-agents (2026-07-09), awesome-generative-ai-guide (2026-06-24), awesome-chatgpt-prompts (2026-07-13). Hannibal046/Awesome-LLM is current. No 404s/archived repos.
- **Discovery (Step 3)**: 4 new candidates over the 500-star bar, all marked `pending`: jim-schwoebel/awesome_ai_agents (1884⭐), slavakurilyak/awesome-ai-agents (1829⭐), caramaschiHG/awesome-ai-agents-2026 (1437⭐), Jenqyang/Awesome-AI-Agents (1185⭐). e2b-dev/awesome-ai-agents was skipped (already registered).
- **Merge (Step 4)**: existing `rejected` fixture entry preserved with its first_seen date; no entries garbage-collected (previous last_scan was null). Only scan-log.yaml was written — REGISTRY.yaml untouched per the single-writer principle.
```

The output is the Step 5 summary format defined in the SKILL scan protocol, and the run
details reference the protocol's own step numbers (Step 2/3/4) — the session Read the
SKILL and executed the protocol, not an improvised scan. No AskUserQuestion / interactive
prompt occurred at any point (headless `-p` would have failed or hung on one).

**Evidence B — same-day re-run discrimination test (FR1 non-interactive today-guard)**:

Second identical probe invocation, same day (last_scan already = 2026-07-13).
Raw output (full transcript, `/tmp/spike-probe-run2.txt`):

```
Already scanned today (2026-07-13) — non-interactive mode, exiting without changes.
```

scan-log.yaml md5 before re-run: `135367a73b79ed51c336fa5f3993edf1`
scan-log.yaml md5 after re-run:  `135367a73b79ed51c336fa5f3993edf1` (byte-identical — no re-scan, no write)

The non-interactive branch of Step 1b fired exactly as specified: one-line log, EXIT,
no prompt, no rescan.

**Result (ii): SATISFIED** — protocol parsed and followed; zero interactive prompts in both runs; same-day guard behaves per FR1.

---

## Question (iii): Are Step 4 merge-write semantics honored (fixture discrimination)?

**Fixture seeded before probe** (per handoff §4.3): `tad-spike/fake-rejected-fixture`,
status `rejected`, first_seen `2026-07-13`. GC rule only removes rejected entries with
`first_seen < previous last_scan`; previous last_scan was null → fixture MUST survive.
Disappearance would mean full-overwrite leakage → FAIL(iii).

**scan-log.yaml BEFORE probe** (verbatim snapshot):

```yaml
# GitHub Registry Scan Log — weekly automation output
# Written by: scheduled routine + *research-github scan (manual trigger)
# Read by: Alex STEP 3.9 + *research-github scan-log command
# Single-writer principle: this file is the ONLY output of the routine.
# REGISTRY.yaml last_checked is updated separately (by *research-github refresh or Alex consuming scan-log).
version: 1.0.0
last_scan: null
scan_results:
  updates: []
  new_candidates:
    - repo: "tad-spike/fake-rejected-fixture"
      domain: "ai-agents"
      stars: 9999
      description: "spike fixture"
      status: rejected
      first_seen: 2026-07-13
```

**scan-log.yaml AFTER probe** (fixture section + header excerpt; full file had 4 updates + 4 pending candidates):

```yaml
version: 1.0.0
last_scan: 2026-07-13
scan_results:
  updates:
    - repo: "Shubhamsaboo/awesome-llm-apps"
      domain: "ai-agents"
      last_commit: 2026-07-11
      previous_checked: 2026-05-04
    # ... 3 more update entries (e2b-dev/awesome-ai-agents, aishwaryanr/awesome-generative-ai-guide, f/awesome-chatgpt-prompts)
  new_candidates:
    - repo: "tad-spike/fake-rejected-fixture"
      domain: "ai-agents"
      stars: 9999
      description: "spike fixture"
      status: rejected
      first_seen: 2026-07-13
    - repo: "jim-schwoebel/awesome_ai_agents"
      domain: "ai-agents"
      stars: 1884
      description: "🤖 A comprehensive list of 1,500+ resources and tools related to AI agents."
      status: pending
      first_seen: 2026-07-13
    # ... 3 more pending candidates (slavakurilyak/awesome-ai-agents 1829, caramaschiHG/awesome-ai-agents-2026 1437, Jenqyang/Awesome-AI-Agents 1185)
```

Fixture survived with `status: rejected` and original `first_seen` intact; new pending
candidates were MERGED alongside it, not written over it.

**Result (iii): SATISFIED** — merge-write real, no full-overwrite leakage.

(Fixture removed after evidence capture per Micro-task 7; real scan results retained.)

---

## Question (iv): Did `last_scan` actually flip?

- BEFORE: `last_scan: null` (verified pre-impl, AC1 baseline = 1 occurrence)
- AFTER: `last_scan: 2026-07-13` (`grep -c 'last_scan: null'` = 0)

**Result (iv): SATISFIED** — behavioral evidence, not structural: the routine's output is
now observable by Alex STEP 3.9 (staleness base date set for the first time ever).

---

## Out-of-scope for this probe (Conductor actions, per grounding)

- `claude -p` is the EQUIVALENT_SUBSTITUTE for the gh-auth / skill-resolution / end-to-end
  questions only. **cron-fires-at-all** is NOT covered here — the Conductor verifies it
  post-gate with a +5min one-shot cron.
- CronCreate registration of the weekly routine = Conductor action, post-gate
  (Blake made zero CronCreate/CronDelete calls).

---

Verdict: PASS

CRON-FIRE-VERIFY: PASS — one-shot cron 3cea3b55 fired at 2026-07-13T10:40:29-0400, today-guard exited clean (no write).
