# Design: Capability Builder v1 — Merged Phase 2 Evolve + Phase 3 Package

**Design ID**: DESIGN-20260903-capability-builder-phase23-evolve-package
**Epic**: `.tad/active/epics/EPIC-20260831-capability-builder-v1.md`
**Execution**: merged single handoff (human decision 2026-09-03)
**Phase 4**: deferred (human decision 2026-09-03; runs in Voice Studio boundary, not this repo)
**v2431**: parallel separate track (human override of NEXT single-queue discipline; no file overlap expected)

## 1. Objective

Add `$capability-builder evolve` (signal-driven, fixture-first Skill evolution with regression
protection) and `$capability-builder package` (explicit one-Skill/one-Plugin packaging with
isolated validation), proven on a re-materialized `example-skill`, without changing TAD core
(`tad.sh`, alex/blake/gate role semantics, Gates) or any legacy `.tad/capability-packs/*` content.

## 2. Explicit New Requirement (Phase 2 trigger)

Human elevated Gate-4-accepted P2 "Eval-regex resource complexity is not bounded"
(`.tad/evidence/reviews/gate4/capability-builder-create.md:27-29`) to an explicit new
requirement on 2026-09-03 (option A chosen from the three documented P2s; B stale-lock and
C hash-cost explicitly rejected). This satisfies Epic Phase 2 Input "explicit new requirement"
(`EPIC:107`). No failure is fabricated: the fixture below demonstrates the real unbounded
behavior before the fix and bounded behavior after.

Scope note (honest): the bound itself lives in framework `pack-eval-runner.sh` (capability
surface, advisory-only assertion tool — NOT a Gate/role/installer), while the evolve-protocol
mechanics (failure fixture first, smallest edit, rerun old+new, stop on drift, preserve manual
projection) are exercised on `example-skill`. Scope proof (R1) verifies TAD core untouched.

## 3. Gate 1 — Requirements Clarity: PASS

- Signal: explicit new requirement above; no-signal path must exit without writes (E3).
- Package target: `example-skill` (human: "用example-skill"); Plugin name `example-skill`;
  MCP/App absent (not requested → must be absent per Epic P5).
- Materialization sandbox: scratch fixture project under
  `.tad/evidence/acceptance-tests/capability-builder-evolve/fixture-proj/` (NOT framework
  `.agents/skills/`), so framework trees stay clean and the Phase 1 contract is re-proven.
- ACs: 10 (E1–E4, P1–P5, R1), each with a literal runnable command in §6.
- Socratic rounds: 3 (initial 4Q → delegation narrowed to documented P2s → A + merged-handoff
  confirmed). Complexity: ~7 files, 10 ACs → standard path, merged handoff (human decided).

## 4. Mandatory Questions (evidence-backed)

### MQ1 — Historical Code Search
Searched before designing (violation otherwise):
- `.tad/scripts/pack-eval-runner.sh` (404 lines, read whole): `count_matches` (`209-216`)
  and `is_invalid_regex` (`219-226`) call bare `grep -oE` with no size cap and no timeout;
  script intentionally has NO `set -e` (`30-31`, advisory never-fail-closed) — bounds must
  degrade to SKIP/timeout verdicts, never abort a batch.
- `.tad/scripts/capability-skill.sh` (`1-150` read): exit classes 0/1/2/3/4 stable (`28-33`);
  divergent target → exit 3 without mutation (`37-40`) — evolve/package reuse this contract.
- `.tad/project-knowledge/patterns/shell-portability.md`: portable timeout chain
  `gtimeout → timeout → no-op fallback` (`:18`); no `grep -P`; env-var convention for >3 params.
- Router today: `evolve`/`package` are `STOPPED_WITH_REASON` (SKILL.md `20-21`). No existing
  `evolve-protocol.md`, `package-openai-plugin.md`, `capability-plugin.sh`, or
  `.tad/templates/openai-plugin/` (glob confirmed absent).
- Mirror verified byte-identical today: `diff -rq .claude/skills/capability-builder
  .agents/skills/capability-builder` → rc=0.

### MQ2 — Existing Function Verification
- `parse_skill`/`parse_pack_raw` dual-field SKIP, `skill:`-only valid fixture, `diff -rq`
  projection check — all read, not assumed; reused unchanged.
- Legacy `pack:` single-fixture path must keep working (R1 re-runs the 7/7 eval-compat cases).

### MQ3 — Data Flow Completeness
- Evolve: trigger → capture failure fixture → smallest Skill/runner edit → rerun old+new
  fixtures → `validate` → `BEHAVIOR_PROVEN` → `project` (refuses on drift, exit 3) → Gate 3.
- Package: validated Skill → scaffold Plugin (`skills/<name>/` generated from canonical only)
  → `diff -rq` → validate manifest → isolated install (no personal marketplace write) →
  failure leaves both trees byte-unchanged (digest compare).
- No UI/API/DB/registry/background sync (same as Phase 1).

### MQ4 — Visual Hierarchy
N/A — no UI. No visual output beyond verdict text (same format as Phase 1 runner).

### MQ5 — Failure Handling
- Runner stays advisory: any bound trip prints `TIMEOUT`/`OVERSIZE`/`SKIP` verdict text, exit 0
  at process level; Gate reads verdict text (existing convention, `create-protocol.md:91`).
- No-signal evolve: usage error, zero writes (proven by `git status --porcelain` on skill trees).
- Divergent manual `.claude` projection: refuse with exit 3, alter neither tree (E4).
- Failed packaging: both trees digest-identical before/after (P4).

### MQ6 — Research Priority
No external research. Evidence is in-repo: Phase 1 handoff/completion/Gate-4, shell-portability
pattern, Phase-1 journal. `capability-upgrade/references/legacy-pack-research.md` loads only on
a named evidence gap (none identified; deep-research material stays conditional per Phase 1 note).

## 5. Technical Design

### 5.1 Evolve protocol (`references/evolve-protocol.md`, CREATE)
State machine: `TRIGGERED → FAILURE_CAPTURED → EDITED_MINIMAL → OLD_FIXTURES_RERUN →
NEW_FIXTURE_PASSES → PROJECTED → GATE_3_READY`, with named stops `NO_TRIGGER_NO_WRITES`,
`REGRESSION_BLOCKS_PROJECTION`, `DRIFT_REFUSES_OVERWRITE`, `TARGET_DRIFT_STOP`.
Rules: trigger must be one of {real failure, human correction, behavioral regression,
relevant external change, explicit new requirement} — else exit without modifying the Skill;
first new regression fixture is part of the change; projection only after canonical passes.

### 5.2 Runner bounds (`pack-eval-runner.sh`, MODIFY — bounds only)

Guard chain (verified 2026-09-03: this host has neither `gtimeout` nor `timeout`, but has
`/usr/bin/perl`): `gtimeout 10s` → `timeout 10s` → `perl -e 'alarm 10; exec @ARGV'` →
**SKIP with warning** (no-op fallback is FORBIDDEN for the E1 catastrophic fixture; it may
apply to benign fixtures only and must log `WARN: no wall-clock guard available`).
Probe order at startup: `command -v gtimeout || command -v timeout || perl -e 'exit 0'`;
exit-127 tool-missing is a harness state, never a PASS. The guard wraps the FULL match
pipeline (`grep | LC_ALL=C sort -u | wc -l`), TERM then KILL semantics, and any trip returns
0 with a frozen verdict string — `TIMEOUT → SKIP (bounded)` vs `OVERSIZE → SKIP (bounded)`
are DISTINCT strings Gate matches with `grep -F -e` (never bare `grep '…'`; ugrep parses
leading `-` as an option, and `-F` disables `^`/`$` anchors — patterns/shell-portability.md).

Mandatory check order inside `assert_one` (before EVERY grep entry INCLUDING the validity
probe, which today runs first at runner `:276-283`):
1. Reject non-regular files and symlinks for fixture AND output (`[ -f ] && [ ! -L ]`;
   `-f` follows links so the `-L` test is load-bearing). FIFOs, dirs, symlinks → `SKIP`.
2. Fixture size cap 512 KiB BEFORE awk parsing (`wc -c < file | tr -d '[:space:]'`; parse
   functions are otherwise an uncapped DoS surface). Output size cap 1 MiB.
3. Post-YAML-unescape byte-length check on BOTH patterns (combined + discriminative),
   cap 4 KiB each (`printf '%s' "$v" | wc -c | tr -d '[:space:]'` — bytes, not `${#}`
   characters). Oversize → `SKIP (bad fixture: pattern oversize)` before any grep.
4. `is_invalid_regex` probe and `count_matches` both execute UNDER the wall-clock guard.
TOCTOU note (honest): check-then-use races on local evidence files are out of scope, but
symlink/FIFO rejection (step 1) removes the arbitrary-target read; files are repo-local.

`EVAL_*` overrides (`EVAL_TIMEOUT_S=10`, `EVAL_MAX_OUTPUT_B=1048576`,
`EVAL_MAX_PATTERN_B=4096`, `EVAL_MAX_FIXTURE_B=524288`): strict `^[0-9]+$` guard with
closed ranges (timeout 1–60, output 65536–16777216, pattern 1024–16384, fixture
65536–4194304); any violation → safe default + `WARN` line. Quoted expansion only, no
`eval`; `--` end-of-options preserved THROUGH the wrapper so dash-leading fixtures keep
working (exit-2 vs no-match distinguished, never conflated). Threat model: inherited
environment is untrusted and must not silently weaken bounds.

Other hardening in the same edit: `LC_ALL=C` pinned on the `count_matches` pipeline
(CJK collation — patterns/shell-portability.md); global batch note — `run_all` documents
`N fixtures × timeout` worst case in its header line so CI stall is visible, not silent.
No `set -e` added; advisory exit-0 preserved (`main` already maps single-fixture rc to 0).

### 5.3 Builder router (`SKILL.md`, MODIFY mode router only)
- `evolve` → mandatory load `references/evolve-protocol.md`, then protocol.
- `package` → mandatory load `references/package-openai-plugin.md`, then protocol.
- No-arg still asks `create | evolve | package`. Out-of-scope stops unchanged.

### 5.4 Package path (`capability-plugin.sh` CREATE + `.tad/templates/openai-plugin/` CREATE + `package-openai-plugin.md` CREATE)
- Commands: `validate <root> <skill> <plugin-dir>`, `package`, `verify`; exit classes mirror
  `capability-skill.sh` (0/1/2/3/4 semantics).
- Containment contract (same bar as `capability-skill.sh:72-141,274-309,433-464` — exit-code
  mirroring alone is NOT containment): physical root resolution (`cd && pwd -P`);
  `plugin-dir` is caller-selected BUT constrained — must resolve INSIDE the project root
  (prefix proof via `case` on resolved paths) and inside `.tad/evidence/` sandbox for this
  handoff; full symlink-chain rejection for canonical, template, and generated trees;
  traversal/absolute/slash rejection; per-entry normalized-name enforcement
  (`^[a-z0-9]+(-[a-z0-9]+)*$`); frontmatter-`name` vs dirname match; forbidden root
  artifacts (`CAPABILITY.md`, `README.md`, `CHANGELOG.md`, `install.sh`) and placeholder
  (`{{...}}`/`[TODO]`/`[TBD]`) scans reused; lock serialization for concurrent packaging.
- Only `<plugin>/skills/<name>/` generated from canonical; manifest/MCP/App are project-owned
  platform code, absent unless explicitly requested with real project files backing them.
- Manifest: minimal `.codex-plugin/plugin.json` {name, version, skills:[name]} from template;
  folder/name normalized, exactly one generated subtree.
- Temp discipline: sibling `mktemp -d` next to target; `trap EXIT INT TERM HUP`; empty-var +
  parent-prefix guards before any removal; temp cleanup lives in a NAMED helper
  (`cleanup_plugin_tmp`) separate from any user-tree deletion (no shared `rm -rf` line —
  patterns/shell-portability.md rm-chokepoint entry); digest scope+algorithm pinned
  (`shasum -a 256`, `sha256sum` fallback — same shim as Phase-1 `run-acceptance.sh`).
- Isolated install/discovery evidence under `.tad/evidence/acceptance-tests/
  capability-builder-package/`; forbidden roots stated explicitly (`$HOME/.codex`,
  `$HOME/.config`, any personal marketplace path) — install target is constrained by
  construction to the in-repo sandbox, and P3 probes the forbidden roots with `test ! -e`
  (repo `git status` is NEVER used as out-of-repo proof).
- Mirror mechanism (named): framework Builder files are authored in
  `.claude/skills/capability-builder/` and hand-mirrored to `.agents/skills/
  capability-builder/` by Blake in the Ralph Loop, proven by `diff -rq` (same method as
  Phase 1, which shipped both trees); downstream skill direction stays
  `.agents → .claude` via `capability-skill.sh project` only.

### 5.5 Bound paths + implementation pins (rounds the R2 NEW-P1s — mandatory, Gate 3 re-proves)

- `<FIXTURE_PROJ>` = `.tad/evidence/acceptance-tests/capability-builder-evolve/fixture-proj`
- `<PLUGIN>` = `.tad/evidence/acceptance-tests/capability-builder-package/plugin`
- `<SNAPSHOT_DIR>` = `.tad/evidence/acceptance-tests/capability-builder-evolve/runner-corpus-snapshot/`
- `<SANDBOX>` = `.tad/evidence/acceptance-tests/capability-builder-package/sandbox-template/`
- E1 loop (literal): `for i in 1 2 3; do bash .tad/scripts/pack-eval-runner.sh .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.fixture.md .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.output.md > .tad/evidence/acceptance-tests/capability-builder-evolve/verdict.$i.txt; done; grep -F -e 'OVERSIZE → SKIP (bounded)' .tad/evidence/acceptance-tests/capability-builder-evolve/verdict.1.txt .tad/evidence/acceptance-tests/capability-builder-evolve/verdict.2.txt .tad/evidence/acceptance-tests/capability-builder-evolve/verdict.3.txt`
- E2(b) capture (literal): `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh eval-compat > .tad/evidence/acceptance-tests/capability-builder-evolve/eval-compat.after.txt 2>&1; cmp .tad/evidence/acceptance-tests/capability-builder-evolve/eval-compat.before.txt .tad/evidence/acceptance-tests/capability-builder-evolve/eval-compat.after.txt` (before-capture is the same command pre-change).
- E4 digest loop (literal): `for f in $(find <FIXTURE_PROJ>/.agents/skills/example-skill <FIXTURE_PROJ>/.claude/skills/example-skill -type f | LC_ALL=C sort); do shasum -a 256 "$f"; done > digests.after; cmp digests.before digests.after` (before-capture identical pre-mutation; `find` output consumed via `for` over newline-free evidence paths only — fixture paths contain no spaces by construction).
- P4 sandbox invocation (literal): `cp -r .tad/templates/openai-plugin <SANDBOX>; : > <SANDBOX>/.codex-plugin/plugin.json; bash .tad/scripts/capability-plugin.sh package <FIXTURE_PROJ> example-skill <SANDBOX>-plugin` → non-zero.
- Prefix proof (exact): `case "$resolved_child/" in "$resolved_root"/*) ;; *) reject ;; esac` — slash-terminated on BOTH sides plus equality branch; `root.evil` sibling fails by construction.
- Group kill: the guard must kill the whole match pipeline (process group), not just the direct child — `timeout -k 5` where `timeout` exists, else `setsid` + `kill -TERM/-KILL -- -pgid`; proven by a test where a `sleep`-child pipeline is fully reaped (no orphan `sleep` after trip).
- Override audit: log full effective 4-tuple + guard iff any `EVAL_*` is present in the
  environment (silent on defaults-only so `eval-compat` byte-compare stays stable; violation
  WARNs always; `--all` header always and is stripped by E2a); E1 pre-proof is functional,
  not presence-only: `perl -e 'alarm 1; exec sleep 5'` must exit non-zero in ~1s.

### 5.6 Friction Preflight (§8.4)
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| `timeout` availability (this host: NO `gtimeout`, NO `timeout`, HAS `/usr/bin/perl` — verified 2026-09-03) | guard chain `gtimeout → timeout → perl-alarm`; probe with `command -v`, 127 = harness state | local perl-alarm wrapper (`perl -e 'alarm N; exec @ARGV'`, verified working) | no-op fallback FORBIDDEN for E1 catastrophic fixture (must SKIP w/ warning); allowed+logged for benign fixtures only | unguarded catastrophic run blocks Gate 3 |
| Catastrophic-regex demo hangs CI | E1 input is OVERSIZE-deterministic (fires size cap, not timing); pre-fix behavior documented ONLY via mandatory perl-alarm-guarded run with pre-proof the guard binary exists | local guarded run | none — unbounded pre-fix run is forbidden | unguarded demo blocks Gate 3 |
| Marketplace / out-of-repo write risk | plugin-dir prefix-contained in repo sandbox by construction + explicit `test ! -e` probes on `$HOME/.codex`, `$HOME/.config`, marketplace paths | local paths | none | any out-of-repo write = FAIL |
| Reviewer availability | 2 independent experts pre-handoff (code 2026-09-03: CONDITIONAL→integrating; security 2026-09-03: FAIL→integrating — this revision) | subagent invocation | no self-review (NEVER equivalent) | <2 distinct reviewers blocks Gate 2 |
| AC-script portability (repo failure catalog) | Blake's AC scripts: baseline tools only (`grep/awk/sed/comm/cmp/python3/perl` — NO `rg`, exit-127 risk); `grep -F -e` for dash-leading/verdict text (`TIMEOUT → SKIP` starts with `T` but contains `→`; `-e` mandatory); `LC_ALL=C` on every `sort`/`uniq`/`comm`; no awk string-equality on CJK (use `grep -Fx`/`cmp`); no `for x in $VAR` (zsh no-split — use `"$@"`/arrays + iteration-count self-proof); no `grep -F`+`$` anchors | local plain-`bash`-and-zsh smoke run before Gate 3 | none | non-portable AC blocks Gate 3 |
| Batch worst case | `run_all` header documents `N fixtures × timeout`; E2 comparison strips header lines before `cmp` | local run | none | header-fragile compare blocks Gate 3 |

## 6. Acceptance Criteria (10, each dry-run at design time for runnable-ness)

- [ ] **E1 fail-before/pass-after (deterministic, size-cap path)**: fixture
  `.tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.fixture.md`
  (discriminative pattern `(a+)+$`, output = 1.2 MiB of `a`, i.e. ABOVE the 1 MiB cap) yields
  frozen verdict `OVERSIZE → SKIP (bounded)` on the fixed runner, stable across 3 runs
  (asserted with `grep -F -e 'OVERSIZE → SKIP (bounded)' verdict.txt`). Pre-fix behavior is
  documented ONLY by running the OLD runner under the mandatory perl-alarm guard
  (`command -v perl` pre-proof; `perl -e 'alarm 15; exec @ARGV' bash
  .tad/scripts/pack-eval-runner.sh <fixture> <output>`); an unguarded pre-fix run is
  FORBIDDEN. No timing claim is made (BSD/macOS grep is DFA — catastrophe is not assumed).
  `bash .tad/scripts/pack-eval-runner.sh .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.fixture.md .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.output.md`
- [ ] **E2 no regression (two loops)**: (a) `run_all` corpus: capture `--all` verdicts over a
  fixed snapshot outputs dir before/after, strip header lines, `LC_ALL=C sort`, `cmp` identical;
  (b) Phase-1 builder-create fixtures EXPLICITLY (not covered by `--all`'s hardcoded glob):
  re-run `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh eval-compat`
  before/after and `cmp` the verdict files
  (`.tad/evidence/acceptance-tests/capability-builder-create/scope/legacy-baseline-verdict.txt`
  plus fresh outputs).
  `bash .tad/scripts/pack-eval-runner.sh --all <snapshot-dir> | grep -v -e '^===' -e '^outputs dir' -e '^---' -e 'pass / ' | LC_ALL=C sort > before.txt`
  (repeat after; `cmp before.txt after.txt`).
- [ ] **E3 no-signal no-writes (agent-run + probe, all paths bound)**: invoke the evolve entry
  with no trigger (`$capability-builder evolve` with an empty trigger statement) → agent must
  return `NO_TRIGGER_NO_WRITES` and stop. Probe: baseline `find <FIXTURE_PROJ>/.agents
  <FIXTURE_PROJ>/.claude -type f | LC_ALL=C sort > tree.before` (+ `git status --porcelain --
  <FIXTURE_PROJ>` recorded; `??` untracked lines are BASELINED, not treated as dirty), rerun
  after, `cmp` identical. `<FIXTURE_PROJ>` =
  `.tad/evidence/acceptance-tests/capability-builder-evolve/fixture-proj` (created empty by
  the run; no `...` placeholders anywhere).
- [ ] **E4 manual projection preserved (exact CLI)**: append one comment line to
  `<FIXTURE_PROJ>/.claude/skills/example-skill/SKILL.md`, run `bash
  .tad/scripts/capability-skill.sh project <FIXTURE_PROJ> example-skill` → exit 3;
  `shasum -a 256` digests of every file in both trees identical before/after (pinned algorithm;
  `sha256sum` fallback only where `shasum` absent).
- [ ] **P1 manifest valid**: with `<PLUGIN>` =
  `.tad/evidence/acceptance-tests/capability-builder-package/plugin` (bound, in-repo):
  `python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["skills"]==["example-skill"], d' "<PLUGIN>/.codex-plugin/plugin.json"`;
  `find "<PLUGIN>/skills" -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort` yields exactly one
  line (`| wc -l | tr -d '[:space:]'` compared to `1`).
- [ ] **P2 byte-identical**: `diff -rq <FIXTURE_PROJ>/.agents/skills/example-skill <PLUGIN>/skills/example-skill` exits 0 (`<FIXTURE_PROJ>` as in E3; `diff` follows the same symlink policy as E4 — in-tree symlinks are rejected at materialization, so traversal is closed).
- [ ] **P3 isolated install (literal)**: `bash .tad/scripts/capability-plugin.sh validate
  <FIXTURE_PROJ> example-skill <PLUGIN>` → 0; `bash .tad/scripts/capability-plugin.sh package
  <FIXTURE_PROJ> example-skill <PLUGIN>` → 0; `bash .tad/scripts/capability-plugin.sh verify
  <FIXTURE_PROJ> example-skill <PLUGIN>` → 0; discovery check `test -f
  <PLUGIN>/.codex-plugin/plugin.json` and `test -d <PLUGIN>/skills/example-skill`; forbidden
  roots `test ! -e "$HOME/.codex/plugins/example-skill"` and `test ! -e
  "$HOME/.config/example-skill"`; in-repo `git status --porcelain -- <PLUGIN>
  <FIXTURE_PROJ>` shows ONLY expected evidence paths.
- [ ] **P4 failure atomicity (exact fault injection)**: in a SANDBOX COPY of the template dir,
  truncate `.codex-plugin/plugin.json` to 0 bytes (`: > <SANDBOX>/.codex-plugin/plugin.json`),
  run `package` against the sandbox → non-zero; `shasum -a 256` digests of canonical
  (`<FIXTURE_PROJ>/.agents/skills/example-skill`) and projection
  (`<FIXTURE_PROJ>/.claude/skills/example-skill`) identical before/after.
- [ ] **P5 no MCP/App**: `[ ! -e "<PLUGIN>/mcp.json" ] && [ ! -e "<PLUGIN>/app" ]` passes (absent as not requested; no `-a` — obsolescent).
- [ ] **R1 core unchanged (extended fence + closed world)**: `git status --porcelain -- tad.sh
  .claude/skills/alex .claude/skills/blake .claude/skills/gate .tad/capability-packs
  .tad/scripts/capability-skill.sh .tad/hooks release-verify.sh CLAUDE.md AGENTS.md
  .claude/skills/capability-upgrade .claude/skills/capability-builder/references/create-protocol.md`
  is empty; closed-world: new files exist ONLY under the §7 CREATE list
  (`git status --porcelain | awk '{print $2}'` reviewed against §7); legacy `pack:`
  single-fixture behavior reuses the E2(b) `eval-compat` re-run (no separate command — stated
  here so the relationship is explicit).

Design-time dry-run (2026-09-03, revision 2 after two independent FAIL reviews — 4 code P0 +
7 security P0, all integrated above; 12 code P1 + 4 security P1 integrated; zero waived):
all commands use bound paths (no `...`); verified present: `pack-eval-runner.sh`,
`capability-skill.sh`, Gate-4 P2 record, mirror `diff -rq` rc=0, missing `gtimeout`/`timeout`,
present `/usr/bin/perl` (alarm guard verified), Phase-1 `run-acceptance.sh` + `fixtures/example-skill.md`;
`python3` snippet receives its argv; `wc` outputs stripped; `-e` on dash-capable greps;
frozen verdict strings `TIMEOUT → SKIP (bounded)` / `OVERSIZE → SKIP (bounded)` matched with
`grep -F -e`. New paths are CREATE items for Blake.

## 7. Files Likely Affected

- `.tad/scripts/pack-eval-runner.sh` (MODIFY bounds only, §5.2)
- `.claude/skills/capability-builder/SKILL.md` (MODIFY router, §5.3)
- `.claude/skills/capability-builder/references/evolve-protocol.md` (CREATE, §5.1)
- `.claude/skills/capability-builder/references/package-openai-plugin.md` (CREATE, §5.4)
- `.agents/skills/capability-builder/` (MODIFY generated framework mirror)
- `.tad/scripts/capability-plugin.sh` (CREATE, §5.4)
- `.tad/templates/openai-plugin/` (CREATE minimal manifest template)
- `.tad/evidence/acceptance-tests/capability-builder-evolve/` (CREATE)
- `.tad/evidence/acceptance-tests/capability-builder-package/` (CREATE)

Explicitly NOT touched (fenced by R1, any diff = scope creep = FAIL): `tad.sh`,
alex/blake/gate skills, `.tad/capability-packs/*`, `.tad/scripts/capability-skill.sh`,
`release-verify.sh`, `.tad/hooks/`, `CLAUDE.md`/`AGENTS.md`, `.claude/skills/capability-upgrade/`,
`create-protocol.md`, Voice Studio paths, personal marketplace, Phase 1 archived artifacts.
`.tad/templates/` must contain ONLY the §7 CREATE subtree after the run (closed-world).

## 8. Knowledge Assessment (distill candidate)

New failure_mode candidate for `patterns/shell-portability.md`: "advisory assertion tools must
bound their own match calls (size + wall-clock + pattern length) because fixtures are
untrusted input; an unbounded `grep -oE` turns a bad fixture into a hang." Grounded in E1.
Distill decision at Gate 4 (not asserted now).
