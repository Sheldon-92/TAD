# FR5 Delivery Evidence — security-auditor ← code-security skills preload

- **Handoff**: HANDOFF-20260713-skills-preload-delivery.md
- **Date**: 2026-07-13 (12:35-12:50 local, UTC-4)
- **CLI**: 2.1.207 (Claude Code) — `claude --version` verified
- **Implementer**: Blake (YOLO workflow agent, isolated worktree `agent-a4604956fa3f7f4c9`, branch `worktree-agent-a4604956fa3f7f4c9`, base 3d2a5b1)
- **Fresh md5 of source** `~/.claude/agents/security-auditor.md`: `99b98017ac28c4e68ef7afb8cc1a51ca` — identical to the handoff §FR1 value (NO drift)

## OVERALL VERDICT: **BLOCKED (§5 row 1 — AC1a FAIL)**

`SKILLS-PRELOAD-HEADLESS: FAIL` — 5 independent headless spawns on 2.1.207 all returned
`NO-PRELOADED-SKILLS`, including an EXACT replication of the re-spike PASS setup
(fixture def `tad-spike-memory-agent.md` in main-repo `.claude/agents/`, spawned from main
repo root, nested `claude -p`). Per §5: **def is NOT committed** (no false capability
claim enters history). Both deliverable files exist UNCOMMITTED in the worktree for
reviewer inspection. Escalation analysis at the end of this file.

---

## AC execution order and raw outputs

### AC8 — Provenance md5 honest — **PASS**

```
$ md5 -q ~/.claude/agents/security-auditor.md
99b98017ac28c4e68ef7afb8cc1a51ca
$ grep -o 'md5=[0-9a-f]*' .claude/agents/security-auditor.md
md5=99b98017ac28c4e68ef7afb8cc1a51ca
```

### AC3 — Shadow fidelity (byte-identical body) — **PASS**

Exact pipeline from the handoff table (no substitution):

```
$ diff <(awk 'f{print} /^---$/{c++; if(c==2)f=1}' ~/.claude/agents/security-auditor.md) \
       <(awk 'f{print} /^---$/{c++; if(c==2)f=1}' .claude/agents/security-auditor.md \
         | sed -n '2,$p' | sed '/^## Preloaded Pack Budget (TAD)$/,$d' \
         | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')
(empty output)
AC3 diff exit code: 0
```

### AC4 — No config theater — **PASS**

```
$ grep -c '^memory:' .claude/agents/security-auditor.md || true
0
```
(stdout `0`; exit-code not gated per handoff note)

### AC5 — Frontmatter lint — **PASS**

```
$ bash .tad/evidence/spikes/subagent-frontmatter-2026-07/fm-lint.sh
FM-OK (2 files)
```

### AC6 — Blake SKILL untouched — **PASS**

```
$ git diff --stat HEAD -- .claude/skills/blake/SKILL.md
(empty output)
```

### AC7 — BEFORE capture (whole-tree porcelain minus 2 deliverables)

```
$ git status --porcelain | grep -vE '\.claude/agents/security-auditor\.md$|fr5-delivery-evidence\.md$'
(empty — 0 lines; worktree clean at capture time)
```

---

### AC1a — Headless preload probe — **FAIL** (§5 BLOCKED branch)

**Attempt 1 (verbatim handoff command form — comma-joined `--disallowedTools` arg, prompt
as trailing positional). The flag is VARIADIC on 2.1.207: it consumed the trailing prompt
as additional deny rules and the session never ran.** Raw output:

```
Permission deny rule "Is" matches no known tool — check for typos.
Permission deny rule "the" matches no known tool — check for typos.
Permission deny rule "content" matches no known tool — check for typos.
Permission deny rule "of" matches no known tool — check for typos.
Permission deny rule "a" matches no known tool — check for typos.
Permission deny rule "skill" matches no known tool — check for typos.
Permission deny rule "named" matches no known tool — check for typos.
Permission deny rule "'code-security'" matches no known tool — check for typos.
Permission deny rule "present" matches no known tool — check for typos.
Permission deny rule "in" matches no known tool — check for typos.
Permission deny rule "your" matches no known tool — check for typos.
Permission deny rule "context" matches no known tool — check for typos.
Permission deny rule "right" matches no known tool — check for typos.
Permission deny rule "now?" matches no known tool — check for typos.
Permission deny rule "If" matches no known tool — check for typos.
Permission deny rule "yes" matches no known tool — check for typos.
Permission deny rule "quote" matches no known tool — check for typos.
Permission deny rule "3" matches no known tool — check for typos.
Permission deny rule "specific" matches no known tool — check for typos.
Permission deny rule "concrete" matches no known tool — check for typos.
Permission deny rule "rules" matches no known tool — check for typos.
Permission deny rule "verbatim." matches no known tool — check for typos.
Permission deny rule "not" matches no known tool — check for typos.
Permission deny rule "reply" matches no known tool — check for typos.
Permission deny rule "exactly" matches no known tool — check for typos.
Permission deny rule "NO-PRELOADED-SKILLS." matches no known tool — check for typos.
Permission deny rule "Do" matches no known tool — check for typos.
Permission deny rule "write" matches no known tool — check for typos.
Permission deny rule "create" matches no known tool — check for typos.
Permission deny rule "or" matches no known tool — check for typos.
Permission deny rule "modify" matches no known tool — check for typos.
Permission deny rule "any" matches no known tool — check for typos.
Permission deny rule "file;" matches no known tool — check for typos.
Permission deny rule "answer" matches no known tool — check for typos.
Permission deny rule "text" matches no known tool — check for typos.
Permission deny rule "only." matches no known tool — check for typos.
Permission deny rule "Also" matches no known tool — check for typos.
Permission deny rule "attempt" matches no known tool — check for typos.
Permission deny rule "to" matches no known tool — check for typos.
Permission deny rule "file" matches no known tool — check for typos.
Permission deny rule "and" matches no known tool — check for typos.
Permission deny rule "report" matches no known tool — check for typos.
Permission deny rule "exact" matches no known tool — check for typos.
Permission deny rule "denial/error" matches no known tool — check for typos.
Permission deny rule "you" matches no known tool — check for typos.
Permission deny rule "receive." matches no known tool — check for typos.
Error: Input must be provided either through stdin or as a prompt argument when using --print
```

**AC1a-guard branch taken**: switched to space-separated form per the guard row, with the
prompt moved BEFORE the flag (variadic list otherwise consumes it):

```
$ claude -p "Is the content of a skill named 'code-security' present in your context right now? If yes, quote 3 specific concrete rules verbatim. If not, reply exactly NO-PRELOADED-SKILLS. Do not write, create, or modify any file; answer in text only. Also attempt to Read any file and report the exact denial/error you receive." \
    --agent security-auditor \
    --disallowedTools Read Bash Grep Glob WebFetch WebSearch Write Edit NotebookEdit Task
```

Raw output (Attempt 2, from worktree root):

```
**Result of the read attempt:**

I could not perform a local file read, because **no local-filesystem read tool exists in my available toolset**. My active tools are only: `ReportFindings`, `ScheduleWakeup`, `Skill`, `ToolSearch`, and `Workflow`. There is no built-in `Read`, `Grep`, or `Glob` tool, and searching the deferred-tool registry (`select:Read`, then keyword search) surfaced **no local file reader** — only remote **Google Drive** MCP tools (`read_file_content`, `download_file_content`, etc.), which operate on Drive `fileId`s, not paths like `/Users/sheldonzhao/.../CLAUDE.md`.

So the honest report of what I hit:

- `ToolSearch "select:Read"` → **"No matching deferred tools found"** (exact string returned).
- No filesystem access tool is exposed to me at all, so I cannot produce a permission-denial error from an actual local read — the capability simply isn't present. I won't invoke the Google Drive reader against an arbitrary file, since (a) that's remote Drive, not a local file, and (b) I have no legitimate `fileId` and fabricating one would just produce a contrived not-found rather than a meaningful denial.

**Summary of both parts:**

1. **NO-PRELOADED-SKILLS** — the `code-security` skill body is *not* in my context (only its one-line catalog description is), so I cannot quote any rule verbatim without inventing it.
2. **File read: not possible** — no local read tool is available; the closest attempt (`ToolSearch "select:Read"`) returned *"No matching deferred tools found."*

I made no writes, edits, or file creations.
```

**grep -F fragment verification**: N/A — the agent quoted ZERO fragments (it explicitly
refused to fabricate; reply contains `NO-PRELOADED-SKILLS`). 0 of required ≥3 fragments.
→ `SKILLS-PRELOAD-HEADLESS: FAIL`

### AC1a-guard — Tool-ban efficacy — **PASS**

Denial evidence (from Attempt 2 raw output above, verbatim): the agent reported
"no local-filesystem read tool exists in my available toolset" and
`ToolSearch "select:Read"` returned **"No matching deferred tools found"** — i.e. the
banned tools were REMOVED from the toolset entirely (stronger than a runtime denial).
The ban is effective in the space-separated form.
FINDING for future probes: on 2.1.207 `--disallowedTools` is variadic; the comma-joined
single arg IS accepted as a tool list, but any trailing positional prompt is swallowed as
more deny rules → pass the prompt via stdin or place it before the flag.

### Diagnostics run before declaring FAIL (confound elimination)

**Diag 1 — deliverable def, stdin prompt, comma-joined ban list (closest to re-spike arg
form); also confirms the def BODY loaded (persona active).** Raw output:

```
**First sentence of my system prompt (persona definition), verbatim:**

> "You are an expert security auditor specializing in application security, infrastructure security, and secure coding practices."

**Is the content of a skill named 'code-security' present in my context right now?**

NO-PRELOADED-SKILLS

To be explicit about why: my context contains a *one-line description* of `code-security` in the available-skills listing (the "Code security capability pack..." blurb), and my agent definition includes a "Preloaded Pack Budget (TAD)" note *claiming* the pack is statically preloaded via `skills:` frontmatter. But the actual skill body — its concrete judgment rules for Semgrep/Nuclei/Gitleaks/Checkov/osv-scanner, etc. — is **not** materialized in my context. I cannot quote 3 rules verbatim because those rules are not present to quote; doing so would be fabrication. The frontmatter note itself flags the preload as "confirmation AC1b pending" and "INERT on ≤2.1.172," which is consistent with what I actually observe: no loaded rule text.

No files were read, written, or modified in producing this answer.
```

→ Persona line quoted verbatim-correct ("You are an expert security auditor…") — the
project def IS resolved and its body IS the system prompt. Only the `skills:` preload is
inert. NO-PRELOADED-SKILLS.

**Diag 2 — EXACT re-spike fixture def (`fixtures/tad-spike-memory-agent.md`, the def that
produced VERDICT-skills PASS on 2026-07-13) copied to worktree `.claude/agents/`, spawned
from worktree root, removed immediately after.** Raw output:

```
No, the code-security skill's content is not present in my context — I only see its one-line description in the skills listing, not its actual rules/body.

NO-PRELOADED-SKILLS
```

**Diag 3 — env-stripped spawn (unset CLAUDECODE, CLAUDE_CODE_CHILD_SESSION,
CLAUDE_CODE_SESSION_ID, CLAUDE_CODE_ENTRYPOINT, AI_AGENT) to rule out nested-session
markers.** Raw output:

```
NO-PRELOADED-SKILLS

To be precise about what *is* versus *isn't* in my context:

- **Present:** only the one-line *description* of `code-security` from the available-skills listing (the "SAST scanning (Semgrep), DAST testing (Nuclei), secret detection…" blurb). That is metadata, not the skill body.
- **Not present:** the actual `SKILL.md` body with concrete, quotable rules. Despite my agent definition's frontmatter note claiming a static `skills:` preload of the `code-security` pack, no verbatim rule content is actually loaded in this context — so I cannot quote 3 concrete rules. (Consistent with that note's own caveats: AC1b confirmation pending, and the mechanism is inert on older CLI builds.)

If you want the real rules, invoke the skill (`/code-security` or via the Skill tool) and I can then quote them verbatim. I have not written or modified any file.
```

**Diag 4 — FULL re-spike replication: fixture def transiently placed in MAIN repo
`.claude/agents/` (same location the re-spike used), spawned from MAIN repo root, nested
`claude -p`, comma-joined ban list via stdin prompt. Fixture removed immediately after;
main `.claude/agents/` verified restored (spec-compliance-reviewer.md only).** Raw output:

```
NO-PRELOADED-SKILLS
```

**Conclusion**: 5/5 spawns FAIL on the same CLI version (2.1.207) that produced the
re-spike PASS hours earlier, including the exact fixture+cwd replication. The failure is
not caused by: arg form (3 forms tried), def content (deliverable + fixture), worktree cwd
(main root tried), or nested-session env markers (stripped).

---

### AC2 — Negative control (academic-research) — **PASS (VACUOUS)**

```
$ echo "Is the content of a skill named 'academic-research' present in your context right now? Quote 3 rules verbatim or reply exactly NOT-IN-CONTEXT. Do not write, create, or modify any file; answer in text only." \
  | claude -p --agent security-auditor --disallowedTools "Read,Bash,Grep,Glob,WebFetch,WebSearch,Write,Edit,NotebookEdit,Task"
```

Raw output:

```
NOT-IN-CONTEXT

Based on my review of the context I've been given, the `academic-research` skill appears only in the **skills listing** — as a one-line description ("Academic research methodology pack for systematic literature review, citation integrity, and quality evaluation..."). That listing tells me the skill *exists* and how to invoke it, but it does **not** load the skill's actual contents (its rules/body). No verbatim rules from inside the skill file are present in my context, so I cannot quote any.
```

`NEGATIVE-CONTROL: PASS` — but VACUOUS/non-discriminative: with the positive control
(AC1a) failing, "unlisted pack not preloaded" cannot distinguish selective-preload from
no-preload-at-all.

---

### AC7 — Headless side-effect cleanliness — **PASS**

AFTER capture (same command as BEFORE):

```
$ git status --porcelain | grep -vE '\.claude/agents/security-auditor\.md$|fr5-delivery-evidence\.md$'
(empty — 0 lines)
$ diff ac7-before.txt ac7-after.txt
(empty — captures IDENTICAL)
```

Explicit eyeball (worktree): `git status --porcelain -- .tad/memory/
.tad/github-registry/REGISTRY.yaml .tad/evidence/traces/` → EMPTY. No memory writes, no
REGISTRY flip, no trace lines (worktree traces untouched).

MAIN-repo note (Diag 4 ran from main root): main `.tad/memory/` porcelain = 0 lines; main
`REGISTRY.yaml` diff = 0 lines; main trace files were ALREADY dirty from the user's live
session before this delivery started (per session-start snapshot), and the newest line in
`2026-07-13.jsonl` (`handoff_created` @ 16:31:34Z = 12:31 local) PREDATES all spawns here
(12:35+). Zero pollution attributable to this delivery; fixture def removed from main
`.claude/agents/` (verified: only spec-compliance-reviewer.md remains).

---

### AC1b — Direct Agent-tool spawn confirmation

```
AC1b: PENDING-FRESH-SESSION
Completion condition: next interactive session in which .claude/agents/security-auditor.md
  exists at session startup, Alex spawns subagent_type=security-auditor via the Agent tool
  with prompt: "不使用任何工具,不写任何文件,列出你已掌握的 code-security 判断规则(逐字引用 3 条)"
  and grep-F-verifies each quote against .claude/skills/code-security/SKILL.md.
Expected: SKILLS-PRELOAD-DIRECT: PASS recorded in this file by Alex.
STATUS UPDATE GIVEN AC1a FAIL: AC1b is now the DECISIVE experiment, not a confirmation.
  The re-spike PASS (provisional) did not reproduce in 5/5 headless attempts including
  exact replication — the nested-wrapper confound flagged in spike-report.md RE-SPIKE
  ADDENDUM is now the leading explanation for the original PASS (the wrapper session's own
  loaded skill content may have bled into the probe), with server-side/flag variance the
  alternative. If AC1b PASSes, headless-vs-interactive is the real boundary; if AC1b
  FAILs, VERDICT-skills should be re-flipped to FAIL on spike-report.md and the def's
  `skills:` key quarantined per §5 AC1b-FAIL row.
```

---

## Verdict table

| AC | Verdict | Evidence |
|----|---------|----------|
| AC8 | PASS | md5 equal, no drift |
| AC3 | PASS | empty diff, exit 0 (exact handoff pipeline) |
| AC4 | PASS | stdout `0` |
| AC5 | PASS | `FM-OK (2 files)` |
| AC6 | PASS | empty git diff on blake SKILL |
| AC7 | PASS | before/after captures identical (both empty); memory/REGISTRY/traces clean |
| AC1a | **FAIL** | 5/5 spawns NO-PRELOADED-SKILLS; 0 quotable fragments |
| AC1a-guard | PASS | banned tools absent from toolset; variadic-arg finding recorded |
| AC2 | PASS (vacuous) | NOT-IN-CONTEXT |
| AC1b | PENDING-FRESH-SESSION | now the decisive experiment (see block above) |

## Degradation branch applied

§5 row 1: **AC1a FAIL → BLOCKED — do not merge.** Def and this evidence file left
UNCOMMITTED in worktree `agent-a4604956fa3f7f4c9` for escalation review. No commit made.
