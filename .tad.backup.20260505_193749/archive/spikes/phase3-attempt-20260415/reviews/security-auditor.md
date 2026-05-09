# Security Review — HANDOFF-20260415-phase3-hooks-skill-impl

**Reviewer:** security-auditor (blue-team defensive review)
**Date:** 2026-04-15
**Scope:** Handoff specification contract that Blake will implement. v3-LEAN design
(`DESIGN-20260414-phase2-enforcement-matrix-v3-LEAN.md`) is the source of truth;
items cut from v2 (external HMAC witnesses, TR39 confusables, SHA content-binding,
HMAC-chained log) are scoped OUT per the single-user CLI threat model and are
NOT re-argued here. Review focuses on whether what v3-LEAN keeps is correctly
specified in the handoff, and whether the realistic LLM-skip-attempts are
mechanically blocked.

**Verdict summary:** CONDITIONAL PASS — 4 P0 issues must be resolved before
Blake starts coding; 6 P1 recommendations should be incorporated into the AC
wording or §4 phase ordering; 4 P2 suggestions for hardening.

---

## 1. Critical Issues (P0 — must fix before Blake starts)

### P0-1. Bootstrap ordering leaves a partially-armed window (AC6 / §9 / §10.1)

**File/Section:** HANDOFF §3 AC6 + §10.1 "Dogfood Paradox"; design §9.

**Problem:** The AC6 sequence is under-specified and, as written, allows a
partially-armed state in which the secret.key exists but `.gitignore` has not
yet been updated. Concretely, AC6 lists four actions (a) mkdir state, (b)
generate secret.key, (c) gitignore append, (d) historical-commit scan — but
does NOT fix their order. If Blake implements them in listed order (state
dir, then key, then gitignore, then history scan), there exists a window
between (b) and (c) where `secret.key` is on disk but not gitignored; if the
Claude Code session is killed (SIGKILL / power loss / user Ctrl-C) between
(b) and (c), the next `git add -A` will stage the secret.

Additionally, the AC does not specify **fsync / atomicity** semantics — if
generation writes `secret.key` with `openssl rand -base64 32 > secret.key`
without `chmod 600` happening atomically, there is a brief world-readable
window on default-umask systems (macOS default 022).

Finally, the historical-commit scan (d) is specified as "stderr ERROR
(non-blocking for first-run itself, but subsequent sessions must block)".
The "subsequent session must block" half has **no corresponding enforcement
rule** anywhere in the AC list or §1 matrix. There is no persistent marker
that says "historical leak detected — gate all further writes". This makes
(d) a log-only advisory in practice, defeating its purpose.

**Impact:** Single-user threat model still cares about git leaks — the
entire rationale for `secret.key` protection is "don't publish it to the
user's GitHub repo". A partial-bootstrap window + a no-op historical-scan
advisory silently defeats that protection.

**Fix (required in handoff before Blake starts):**

1. Rewrite AC6 with explicit, ordered sub-steps:
   ```
   AC6 (ordered, atomic):
     1. Check .gitignore — if missing `.tad/state/` line, append FIRST and fsync
     2. mkdir -p .tad/state with chmod 700 (umask 077 for the block)
     3. Generate secret.key via `(umask 077; openssl rand -base64 32 > .tad/state/secret.key)`
        — NOT `openssl rand ... > file; chmod 600 file`
     4. Historical scan: `git log --all -- .tad/state/secret.key` — if any commit,
        write a persistent `.tad/state/LEAK_DETECTED` sentinel file (chmod 600)
     5. quality-enforcement.sh hook start: if `.tad/state/LEAK_DETECTED` exists,
        fail-closed DENY all Write-family and Bash (not just log), require OV-1
        `gate=emergency` override with explicit "secret.key was committed to
        history, I have rotated and cleaned git history" reason
   ```
2. Add this as AC6-FIX to the AC list. Also update §3.1 Conflict Matrix: the
   bootstrap exception window (AW-1 LOG-ONLY) MUST close on `.gitignore`
   update, not on `secret.key` existence — otherwise the sentinel "first-run"
   marker conflates gitignore-done with key-done.

### P0-2. HP-2 env-injection pattern list is incomplete — silently bypassable (AC10)

**File/Section:** HANDOFF §3 AC10; design §1 HP-2.

**Problem:** The HP-2 list as specified is:
```
TAD_SKIP_VALIDATION=, TAD_DISABLE_HOOKS=, CLAUDE_SETTINGS_PATH=,
CLAUDE_CONFIG_DIR=, BASH_ENV=, LD_PRELOAD=, DYLD_INSERT_LIBRARIES=
```

Missing realistic LLM bypass vectors:

- **`ENV=`** — bash reads `$ENV` in non-interactive shells (POSIX); same
  class of risk as `BASH_ENV`.
- **`SHELLOPTS=`** / **`BASHOPTS=`** — can disable `errexit`/`nounset`,
  causing fail-closed checks to silently fail-open in the hook itself.
- **`PATH=`** — can redirect `jq`, `perl`, `yq`, `openssl` to attacker-
  controlled replacements. The handoff-level enforcement matters because
  Blake will clearly reason "dep-guard.sh pins PATH internally so PATH
  injection is fine" — but tool-invocation sites (e.g., Bash commands
  written by the model) can set PATH before invoking a TAD-relevant
  command.
- **`IFS=`** — classic bash injection primitive; a `Bash` command that
  sets IFS can break quoting in downstream TAD scripts invoked by the
  same chain.
- **`PS4=`** + `set -x` — if a debug hook prints expansion, `PS4` can
  execute a command substitution. Low probability but trivial to add
  to the deny list.
- **`PYTHONPATH=`** / **`NODE_OPTIONS=`** — if any TAD tooling ever
  spawns python3 or node (Domain Pack tools do — `admesh`, some linters),
  these redirect module loading. NODE_OPTIONS specifically can `--require`
  an arbitrary module.
- **`GIT_*`** family — `GIT_DIR`, `GIT_WORK_TREE`, `GIT_EXTERNAL_DIFF`,
  `GIT_SSH_COMMAND` — the bootstrap scan (AC6 d) invokes `git log`, and
  `GIT_EXTERNAL_DIFF` / `GIT_SSH_COMMAND` execute arbitrary programs.

Additionally, the pattern match is specified only on content/Bash string
— not on **tool_input envelope fields outside `.content` and `.command`**.
For Write tool, `file_path` could theoretically contain env assignment if
Claude Code ever passes that through. For Bash, the `description` field is
passed through to the model but not executed; still, check strip surface.

**Impact:** The LLM agent rationalizing "I'll just set `PATH=/tmp/poison`
before my command" will find it works. This is the single most likely
skip-attempt once the framework is deployed.

**Fix:** Extend AC10 pattern list to include:
- `ENV=`, `SHELLOPTS=`, `BASHOPTS=`, `IFS=`, `PATH=`, `PS4=`
- `PYTHONPATH=`, `NODE_OPTIONS=`, `PERL5OPT=`, `PERL5LIB=`
- `GIT_DIR=`, `GIT_WORK_TREE=`, `GIT_EXTERNAL_DIFF=`, `GIT_SSH_COMMAND=`,
  `GIT_CONFIG=`, `GIT_CONFIG_GLOBAL=`, `GIT_CONFIG_SYSTEM=`
- Store the full list in `.tad/schemas/protected-paths.yaml` under a new
  `env_injection_patterns:` top-level key so Blake does not hardcode in the
  shell script — schema-driven list allows later expansion without touching
  code.
- Explicit AC wording: "All patterns from `protected-paths.yaml::
  env_injection_patterns` must be matched case-sensitively at the
  start of any whitespace-delimited token in Bash.command OR at line-start
  in Write/Edit.content."

### P0-3. OV-2 content scan coverage is under-specified — missing surfaces (AC11)

**File/Section:** HANDOFF §3 AC11; design §1 OV-2.

**Problem:** AC11 says "OV-2: tool_input 内容含 `TAD_OVERRIDE:` 必须 deny"
but does not enumerate the fields scanned. The v3-LEAN design §1 table
says OV-2 fires on "any tool_input content" for Write-family + Bash, but
Phase 3 implementation needs explicit surfaces to not miss one.

Surfaces that MUST be scanned:
- `Write.content`
- `Edit.new_string`
- `MultiEdit.edits[].new_string` (concat all, then scan)
- `NotebookEdit.new_source` (also `.cell_type=markdown` cells)
- `Bash.command`
- `Task.prompt` (sub-agent spawn — design §2.2 mentions Task in routing
  but AC11 does not; sub-agents inherit parent context and can be told
  "write TAD_OVERRIDE: emergency ..." in their system_prompt)

Missing or ambiguous:
- `Bash.description` — user-visible but not executed; still, a model
  reasoning about bypass will try this.
- `Edit.old_string` — appears harmless but if tool implementation ever
  includes old_string in the persisted content (partial-match fallback),
  an override string could be injected.
- Heredoc in Bash — `cat <<'EOF' > file\nTAD_OVERRIDE: ...\nEOF` — this
  is covered by BW-3 already blocking heredoc redirects to
  `.tad/evidence/`, but NOT if the heredoc target is outside those paths
  (attacker writes to `/tmp/foo` containing an override string, then
  `cp /tmp/foo .tad/evidence/...` — covered by cp pattern, but not
  obvious without tracing).

Additionally, the **canonicalization pipeline** (strip invisibles +
Unicode casefold) from §3 applies to the sentinel detection per the
handoff, but AC11 OV-2 does NOT explicitly inherit the same
canonicalization. A model can write `TAD\u200BOVERRIDE:` (zero-width
space inside) and bypass a literal `grep -F TAD_OVERRIDE:` check.

**Impact:** LLM rationalizes "I'll write TAD_OVERRIDE into the document
content itself as a fake audit trail, then reference it from COMPLETION
to claim human approved" — bypasses OV-1's requirement that override
come from a USER UserPromptSubmit message. The whole override auth
model depends on "LLM cannot self-grant" — if content-scan has gaps,
the model CAN self-grant.

**Fix:** Expand AC11 into AC11-A (OV-1 flow) and AC11-B (OV-2 scan):

```
AC11-B (OV-2 content scan — fail-closed):
  Must apply the §3 canonicalization pipeline (strip invisibles +
  Unicode casefold) to ALL of the following fields before literal
  match against canonicalized pattern `tad_override:`:
    - Write.content
    - Edit.new_string  (also Edit.old_string — belt+suspenders)
    - MultiEdit.edits[].new_string (concatenated) AND .old_string
    - NotebookEdit.new_source
    - Bash.command
    - Bash.description
    - Task.prompt (if Task tool reaches the PreToolUse hook)
  Any match → DENY with reason "TAD_OVERRIDE only via UserPromptSubmit".
  Fixture fixture-ov2-zwsp-bypass.sh must PROVE that
  `TAD\u200BOVERRIDE:` in Write.content is denied.
```

### P0-4. Fail-closed semantics on missing dep / crash are NOT enforced in AC wording

**File/Section:** HANDOFF §3 AC6, AC7, AC10, AC11; design §8.

**Problem:** Phase 1c knowledge entry ("AC17 missing_dep FAILED fail-OPEN
— jq absent silently disables enforcement") identified this as a
critical security failure. Phase 1c hardened hooks fixed it for the
earlier hook set. But the Phase 3 handoff's AC wording does NOT
re-enforce this for the NEW 8 scripts being built.

Specifically, there is no AC that says "if jq / perl / yq / openssl is
missing → DENY", no AC that says "if the hook crashes (syntax error,
unbound var, timeout) → DENY", and no AC for "if stdin JSON is
unparseable → DENY". Design §8 mentions "hardcoded deny JSON + exit 0
on timeout" as a CI/perf prerequisite, but this is not wired into AC1
or any functional AC.

The `lib/dep-guard.sh` from Phase 1c is inherited (handoff §11) but the
handoff does not mandate that **every new hook entrypoint** (both
`quality-enforcement.sh` and `userprompt-override.sh`) source dep-guard
FIRST before any other code path — a Blake who reads design §2.2 will
see dep-guard is sourced in `quality-enforcement.sh` but userprompt-
override.sh has no corresponding explicit requirement in design §2.2
or in handoff AC1/AC11.

**Impact:** Re-opens the exact failure mode Phase 1c was designed to
close. A `jq` uninstall (or a PATH injection from P0-2) could silently
disable the entire enforcement layer. Phase 1c memory entry explicitly
warns against shipping without this.

**Fix:** Add AC16 (exceeds the "≤15 AC target" but safety-critical —
cap can be relaxed for a security-critical AC):

```
AC16 (fail-closed discipline — ALL of the following must hold):
  1. Both quality-enforcement.sh AND userprompt-override.sh `source`
     lib/dep-guard.sh as the FIRST executable line after the shebang
     + `set -euo pipefail`.
  2. Every hook entrypoint has `read -t 2` on stdin (design §8 #3)
     AND a `trap` on EXIT that emits `{"ok":false,"reason":"hook
     crashed"}` to stdout + `exit 0` if the main flow did not already
     exit.
  3. Every external invocation (jq, perl, yq, awk, openssl) uses
     the dep-guard-whitelisted absolute path.
  4. Missing required file (nonces.jsonl read target absent) →
     treat as "deny-unless-bootstrap", not "allow".
  5. Fixture fixture-faildep-jq-missing.sh: runs the hook under
     `PATH=/tmp/empty` and verifies stdout contains a deny JSON
     and NOT an allow.

Verification: 4 fixtures (missing jq, missing perl, stdin timeout,
stdin malformed JSON) — all MUST deny. Imperative list form.
```

---

## 2. Recommendations (P1 — should address before Blake starts)

### P1-1. AW-3 cross-role edit role-detection can be circumvented (design §1 AW-3)

**Problem:** §2.5 of the design says role is derived from "last 100 lines
of transcript_path, most recent `Skill` tool_use matching `tad-alex|alex`
→ role=alex; else role=blake/system". But:

- An LLM that wants to edit the other role's handoff can simply invoke
  the other role's Skill first (e.g., Blake invokes `tad-alex` Skill
  in the same session, which flips the role-derivation result). The
  handoff does not call out that Skill invocation is the transcript
  signal — an adversary-in-context (not adversary-on-disk) who reads
  the design will know to flip role before editing.
- Transcript tailing with `.tad-alex|alex` regex matches any mention of
  "alex" in tool_use name, which could falsely match user-authored
  subagent with "alex" in the name (e.g., a custom `alex-helper` subagent).
- "Last 100 lines" is a heuristic — if the transcript is >100 lines since
  last Skill invocation, role=system and the write is denied, which is
  safe; but if BOTH Skills appear in last 100 lines, the "most recent"
  ordering depends on transcript line ordering, which is not explicitly
  guaranteed chronological by Claude Code.

**Recommendation:** Add an AC sub-item requiring:
- Regex tightened to `^tad-(alex|blake)$` or `^Skill\\(name: (?:tad-)?(alex|blake)\\)` (anchored).
- Role-flip detection: if the LAST two Skill invocations are (Blake
  then Alex) within a 5-minute window AND the current tool is Write/Edit
  on a handoff/completion file → treat as suspicious, require OV-1.
- Document the circumvention-by-Skill-switch in `.tad/project-knowledge/
  security.md` so future audits know the assumption.

### P1-2. BW-3 Bash write-path pattern list is incomplete

**Problem:** The list `>`, `>>`, `tee`, `<<`, `ln`, `cp`, `mv`, `git mv`,
`rsync`, `sed -i` misses:

- `install -m 644 src dst` (BSD/GNU install, common for scripted deploys)
- `awk '{...}' > file` — covered by `>` but awk with `print > file`
  INSIDE the awk program is NOT covered by a shell-level `>` match
  (awk internal redirect). Pattern must scan for `> *"?\\.tad/` INSIDE
  awk script strings.
- `printf ... > file` — covered by `>`.
- `dd of=.tad/evidence/...`
- `python3 -c 'open(\".tad/evidence/x\",\"w\").write(...)'` — any scripting
  language with file-write. This is fundamentally unbounded; the lean
  response is to rely on HP-1 protected-path for `.tad/evidence/**` OR
  to extend BW-3 to match ANY string ending in `.tad/evidence/` or
  `.tad/active/handoffs/` regardless of preceding token.
- `cat > file <<EOF` / `cat >> file <<EOF` — heredoc WITH redirect
  target is `>` or `>>` so covered, but the pattern list "`<<`" alone
  (without redirect) is a red herring — heredoc input without redirect
  target doesn't write a file.
- `>|` (bash noclobber override) — covered by `>` greedy match only if
  the regex is `>+`.
- `&>`, `&>>`, `2>`, `2>>` — stderr/combined redirects.
- `exec >file` (shell-builtin redirect in subshell) — covered by `>`.

**Recommendation:** Rewrite BW-3 detection as: "Any Bash command whose
**resolved target path** (after shell tokenization) matches
`.tad/evidence/**` or `.tad/active/handoffs/**` MUST deny, regardless of
the redirect operator used." Implement via: extract all tokens ending
in `.tad/evidence/` / `.tad/active/handoffs/` or starting with those
prefixes AFTER stripping quotes; deny if ≥1 such token appears in a
writeable context (after `>`, `>>`, `&>`, `tee`, `cp`, `mv`, `ln`,
`rsync`, `install`, `dd of=`, `sed -i`, awk `> file` substring, or as
the destination of any of these).

Add fixtures:
- `fixture-bash-install-to-evidence.sh`
- `fixture-bash-awk-internal-redirect.sh`
- `fixture-bash-python-c-write.sh`
- `fixture-bash-stderr-redirect-to-evidence.sh`

### P1-3. Mtime-based evidence freshness has a trivial LLM bypass (AC12)

**Problem:** v3-LEAN correctly cuts SHA content-binding for the threat
model (scope decision respected). But mtime alone introduces a NEW gap
that v3-LEAN does NOT explicitly note: the LLM agent can
`touch -t <future> .tad/evidence/reviews/alex/.../code-reviewer.md` to
make the evidence file NEWER than the handoff, trivially defeating
`evidence.mtime < handoff.mtime → stale`.

This is NOT arguing to re-add SHA-binding. It IS arguing that the
handoff should either:
(a) detect `touch` / `utimes` syscalls in Bash commands (add `touch` to
    the BW-3 patterns list), OR
(b) compare evidence mtime against `git log -1 --format=%ct HANDOFF file`
    (the git-tracked timestamp, which the LLM cannot forge without
    rewriting git history), OR
(c) at minimum, document in AC12 that `touch` is a known bypass and add
    `touch .tad/evidence/` to the Bash deny pattern list (BW-3 ext).

**Recommendation:** Option (c) at minimum — extend BW-3 pattern list to
include `touch` when the target is `.tad/evidence/**` or
`.tad/active/handoffs/**`. Add fixture `fixture-bash-touch-evidence.sh`.
Also add `utimes`-equivalent Python/Perl one-liners to the deny list
(covered by P1-2 if the general `.tad/evidence/` target rule is
implemented).

### P1-4. Settings.json hook-ordering trap — existing Haiku prompt hook runs FIRST

**Problem:** The existing `.claude/settings.json` has a `PreToolUse` hook
with `matcher: "Write|Edit"` that uses `type: prompt` (Haiku) and
currently returns permissive `{ok: true}` for everything. AC3 says the
new `quality-enforcement.sh` must be added as a `type: command` hook.

Claude Code runs PreToolUse hooks in order; a `type: prompt` hook that
returns `{ok: false}` blocks the tool call before downstream hooks see
it. Conversely, a `type: prompt` hook returning `{ok: true}` does NOT
bypass downstream hooks — they run. Good so far.

BUT: the current Haiku hook has `timeout: 10` seconds. If Haiku is
slow/overloaded, a Write is delayed by up to 10s BEFORE
quality-enforcement.sh runs, which combined with quality-enforcement's
own `read -t 2` + execution time can exceed the overall Claude Code hook
budget. Also, the Haiku hook is currently a NO-OP security-wise ("ALLOW
(default permissive for framework project)") — it's pure latency tax.

The AC3 wording "保留现有 Haiku prompt hook 不动" is wrong from a
security standpoint. The Haiku hook should either be (a) removed
entirely, since it's no-op, (b) repurposed as a defense-in-depth
pre-filter that pre-classifies suspicious intent, or (c) moved to run
AFTER quality-enforcement.sh so it doesn't add latency to the critical
path.

**Recommendation:** Change AC3 to either:
- Remove the Haiku prompt hook entirely (it adds latency with zero
  current security value) — simplest.
- If keeping it, register `quality-enforcement.sh` as a SEPARATE
  PreToolUse entry with matcher `Write|Edit|MultiEdit|NotebookEdit|Bash`
  — NOT merged into the same `Write|Edit` matcher as the Haiku hook.
  Claude Code processes each entry independently; ordering within
  settings.json determines invocation order.
- Verify via `claude -p` smoke test (handoff §5.1 entry #6 gives the
  exact invocation pattern) that BOTH hooks fire on a test Write, and
  that `quality-enforcement.sh`'s deny JSON takes effect even when the
  Haiku hook returns `{ok: true}`.

### P1-5. OV-1 nonce scope — subagent isolation is correct but underspecified

**Problem:** Design §6.1 says "Subagent spawn gets new session_id →
parent nonce not consumable by subagent (intentional, documented)".
AC11 inherits this. GOOD — this is correct.

But: the handoff does NOT explicitly require a fixture that PROVES
subagent isolation. If Claude Code ever changes sub-agent session_id
propagation (e.g., sub-agent inherits parent session_id in a future
version), the invariant silently breaks and no CI signal catches it.

**Recommendation:** Add fixture `fixture-ov1-subagent-no-inherit.sh`:
- Spawn a Task sub-agent after parent allocates an override nonce.
- In the sub-agent, attempt a gated Write.
- Expected: DENY (sub-agent session_id ≠ parent session_id, nonce
  not in scope).
- If it ALLOWS: this is a Claude Code contract change — surface via
  fixture failure, not silent enforcement bypass.

### P1-6. "bootstrap exception" window is not time-bounded

**Problem:** AC7 says "AW-1 bootstrap exception 正确工作" — secret.key
absent → LOG-ONLY allow. AC15 says "after first gate2-verdict.tsv PASS,
bootstrap exception clears". But:

- There is no TIME bound. If the user never runs a gate (e.g., Phase 3
  acceptance hangs for a week), the bootstrap exception remains open
  for a week — during which Alex can write arbitrary handoffs with no
  sentinel/evidence enforcement.
- There is no way for the USER to explicitly close the bootstrap
  window early — no `/tad-bootstrap-done` command.

**Recommendation:** Add time-bound: bootstrap exception auto-closes 1
hour after `secret.key` creation OR after first gate2-verdict.tsv
writes, whichever comes first. Record `secret.key` mtime as the anchor;
compare `now() - secret.key.mtime > 3600` OR gate2-verdict exists →
exception closed. Add fixture `fixture-bootstrap-timeout-closes.sh`.

---

## 3. Suggestions (P2 — nice to have)

### P2-1. AC15 dogfood trace should include a deliberate NEGATIVE case

Current AC15 trace has 3 events (bootstrap-allow, completion-write,
post-bootstrap-deny). Add a 4th: `fake-override-rejected` — Blake
includes in the handoff a deliberate OV-2 violation (writes
`TAD_OVERRIDE:` in markdown body) and verifies the hook denies it.
This exercises OV-2 in dogfood, not just in fixture.

### P2-2. Protected-paths schema should cover symlinks

HP-1 denies writes to `.tad/hooks/**` etc. But the path-guard.sh check
probably uses literal path-match on `tool_input.file_path`. If
`.tad/hooks/quality-enforcement.sh` is a symlink (because user
dual-projects TAD via `ln -s`), the write goes to a different realpath
but matches the protected pattern. Conversely, a user could create a
symlink `.tad/public/evil.sh -> .tad/hooks/quality-enforcement.sh` and
write through it, bypassing the pattern match.

Add to AC10: "All HP-1 checks apply to BOTH tool_input.file_path AND
realpath of target directory (when parent dir exists)." This requires
a readlink/realpath call per check; may cost 2-5ms but worth it.

Cross-ref: KG-002 TOCTOU is scoped OUT per design §7.2, but symlink
HP-1 bypass is a RELATED attack, and a realpath check mitigates the
easy case (pre-existing symlink) even if it doesn't close the race.

### P2-3. evidence-validator.sh --handoff-path should validate UTF-8

If Blake writes `--handoff-path $(printf '%b' '\\x00\\x01evil')`, the
validator may mis-parse or crash. Add an input-sanitize step: reject
--handoff-path values containing any byte < 0x20 (except tab) or
matching the HP-2 env-injection patterns (belt+suspenders).

### P2-4. Settings.json itself should be protected against self-write via HP-1

HP-1 already lists `.claude/settings*.json` as protected. GOOD. But
the Bash watcher (BW-3) does NOT list `.claude/settings.json` as a
protected redirect target — if an agent rationalizes "I'll just
`cat > .claude/settings.json`" and the HP-1 denial is only on the
Write tool, the Bash path is open.

Check: does BW-3's enforcement target `.tad/evidence/` and
`.tad/active/handoffs/` ONLY (design §1 says so), or does it also
cover `.claude/settings.json` and `.tad/hooks/**`? Handoff §3 AC9
mentions only the two evidence/handoff paths. If HP-1's Bash-branch
coverage is the intended defense, then AC10 must explicitly say:
"HP-1 applies to BOTH Write-family AND Bash redirect targets" —
design §1 HP-1 row says "PreToolUse Write-family + Bash" so it IS
scoped, but the handoff AC10 verification says only Write-family
fixtures. Add Bash-to-protected-path fixtures.

---

## 4. Cross-Reference Against Focus Areas

Focus area mapping:

1. **Bootstrap flow (AC6)** → P0-1 (ordering gap + historical-scan no-op).
2. **AC10 coverage (HP-1 + HP-2 + PT-1)** → P0-2 (env-injection list
   incomplete), P2-2 (symlink bypass), P2-4 (Bash-to-protected-path
   fixtures).
3. **OV-1 nonce lifecycle (AC11)** → P1-5 (subagent isolation fixture
   missing), P1-6 (bootstrap window not time-bounded).
4. **OV-2 content scanning** → P0-3 (surfaces not enumerated,
   canonicalization not inherited).
5. **Cross-role edit (AW-3)** → P1-1 (Skill-flip circumvention +
   regex tightening).
6. **Bash write-path exfiltration (BW-3)** → P1-2 (pattern list
   incomplete), P1-3 (touch not in list).
7. **Sentinel canonicalization handoff to fixtures** → Acceptable as
   written; fixtures 6 (eszett) and 7 (ZWJ) cover the pipeline. P0-3
   calls out that canonicalization must also apply to OV-2.
8. **Mtime freshness (AC12)** → P1-3 (touch bypass, no `utimes` cover).
9. **Settings.json ordering** → P1-4 (Haiku hook interaction).
10. **Fail-closed semantics** → P0-4 (not in any AC wording).

---

## 5. Overall Assessment

**Verdict: CONDITIONAL PASS**

The handoff correctly implements the v3-LEAN design at a structural level:
- 8-script layout matches §2.1.
- AC list maps 1:1 to §10.1 scope.
- SKILL hardening anchors match §5.
- AC Conflict Matrix (§3.1) is genuinely useful and catches the
  protected-path-vs-self-edit paradox.
- Phase ordering in §4 is correct (SKILL → hook code → settings.json
  activation → fixtures).
- Domain pack references + project knowledge lessons are well-integrated.

Blocking issues before Blake starts:
- **P0-1** (bootstrap ordering + historical scan no-op)
- **P0-2** (HP-2 env-injection list dangerously incomplete)
- **P0-3** (OV-2 surface list + canonicalization gap)
- **P0-4** (fail-closed discipline not in any AC)

These are all **specification-level** fixes — they are 1-hour handoff
edits, not design-level rework. Blake should NOT start implementation
until P0-1..P0-4 are resolved in the handoff text.

P1 items should be incorporated where fast; P1-4 (Haiku hook ordering)
specifically should be resolved because Blake will otherwise hit a
10-second latency in every test iteration.

**Blue-team framing confirmation:** No red-team language used in this
review. Focus is defensive validator coverage / negative test cases /
evasion mechanism enumeration, per project-knowledge entry
"Claude Code Sub-Agent Safety Classifier: Red-Team Language Triggers
Refusal - 2026-04-14".

---

## Appendix: Quick-Ref Fix List for Alex Handoff Edit

Before Blake starts, edit HANDOFF-20260415 to:

1. Rewrite AC6 with ordered sub-steps + LEAK_DETECTED sentinel
   (P0-1).
2. Expand AC10 env-injection list + move to protected-paths.yaml
   schema (P0-2).
3. Split AC11 into AC11-A (OV-1) and AC11-B (OV-2 surface-
   complete + canonicalized) (P0-3).
4. Add AC16 fail-closed discipline (P0-4). Relax "≤15 AC target"
   for this safety-critical AC.
5. Tighten §2.5 role-detection regex + add role-flip detection
   (P1-1).
6. Expand BW-3 pattern list + rewrite as "target-path-based"
   rather than "operator-based" (P1-2).
7. Add `touch` + `utimes`-class to BW-3 (P1-3).
8. Resolve Haiku hook ordering in AC3 (P1-4).
9. Add subagent-isolation fixture (P1-5).
10. Add bootstrap-time-bound fixture + auto-close (P1-6).
11. Add ≥4 new fixtures to AC14 (raises 10 → 14): OV-2 ZWSP,
    Bash install/awk/touch, fail-dep jq-missing, subagent-nonce.

Post-edit, re-run Gate 2 with updated AC count; v3-LEAN §11 "Phase 3
scope ≤15 ACs" becomes ≤17 (acceptable inflation for safety-critical
coverage — document the delta in Gate 2 notes).
