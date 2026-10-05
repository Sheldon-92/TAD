# Handoff: Capability Builder v1 — Merged Phase 2 Evolve + Phase 3 Package

**Handoff**: `.tad/active/handoffs/HANDOFF-20260903-capability-builder-phase23-evolve-package.md`
**Epic**: `.tad/active/epics/EPIC-20260831-capability-builder-v1.md` (Phase 1 ✅ Done; Phase 2+3 this handoff; Phase 4 deferred by human 2026-09-03)
**Design**: `.tad/active/designs/DESIGN-20260903-capability-builder-phase23-evolve-package.md` (authoritative for rationale; THIS handoff is authoritative for implementation steps + literal ACs)
**Task ID**: `TASK-20260903-BUILDER-P23`
**Mode**: YOLO (human-authorized 2026-09-03) — YOLO skips non-critical confirmations ONLY. Gates, 2-expert Gate-2 (done), Ralph Loop, Gate 3 + Layer 2, and Gate-4 handoff-back are NOT skipped.
**Execution Mandate** (human-accepted 2026-09-03): merged Phase 2+3 single handoff, ~7 files, 10 ACs. Phase 4 deferred. v2431 is a parallel separate track — do not touch its files.

## 🔴 Gate 2: Design Completeness — ✅ PASS (Alex, 2026-09-03)

- Gate 1 PASS: signal = explicit new requirement (Gate-4 P2 "eval-regex unbounded" elevated by human, option A of 3); package target = `example-skill` / Plugin `example-skill`, no MCP/App; sandbox paths bound.
- Design complete: §§5.1–5.6 (evolve protocol, runner bounds, router, package path + containment + temp discipline, bound paths + pins, friction preflight).
- ACs: 10/10 literal runnable (§9.1), design dry-run incl. unicode `grep -F -e` probe PASS and perl-alarm guard verified on this host (no `gtimeout`/`timeout`, HAS `/usr/bin/perl`).
- Expert review: R1 code FAIL (4 P0 + 12 P1) + security FAIL (7 P0 + 4 P1) → ALL integrated, zero waived → R2 code CONDITIONAL (1 NEW-P1, closed in design §5.5) + security CONDITIONAL PASS (3 NEW-P1s, pinned in §5.5 as mandatory implementation constraints). 2 distinct reviewers. No self-review.
- MQ1–MQ6 answered with file:line evidence (design §4). Knowledge Assessment present (design §8; distill decision at Gate 4). Friction preflight present (design §5.6).
- Scope fenced: R1 + closed-world new-files-only-§7. No implementation started.

## 📋 Handoff Checklist

- [ ] This handoff is Blake's ONLY info source (design doc is rationale backup, not a second instruction set — on conflict, §9 of THIS handoff wins for execution)
- [ ] YOLO: proceed through Ralph Loop without pausing for non-critical confirmations; STOP + report on any P0-grade surprise, scope-creep pressure, or mandated AC red

## 1. Task Overview

### 1.1 What We Are Building
1. `$capability-builder evolve` (signal-driven, fixture-first Skill evolution) + `evolve-protocol.md`.
2. Resource bounds in `.tad/scripts/pack-eval-runner.sh` (the elevated P2): size caps + wall-clock guard + pattern-length caps, advisory exit-0 preserved.
3. `$capability-builder package` (one-Skill/one-Plugin) + `package-openai-plugin.md` + `.tad/scripts/capability-plugin.sh` + `.tad/templates/openai-plugin/`.
4. Router update in Builder `SKILL.md` (remove evolve/package STOPPED_WITH_REASON → mandatory protocol loads).
5. Framework mirror `.agents/skills/capability-builder/` (hand-mirror + `diff -rq` proof).
6. Evidence: `capability-builder-evolve/` + `capability-builder-package/` suites; `example-skill` re-materialized in the evolve sandbox (NOT framework `.agents/skills/`).

### 1.2 Why
Phase 1 shipped create-only; evolve/package are STOPPED stubs. The eval runner (which every evolve fixture runs through) has unbounded `grep -oE` on untrusted fixture input — the exact P2 Gate 4 deferred. This handoff closes both.

### 1.3 Intent Statement
Prove signal-driven evolution and explicit packaging on `example-skill` with 10/10 ACs while proving TAD core behavior unchanged (R1). Do not invent scope: anything not in §7 + §9.1 is out.

## 📚 Project Knowledge

### Files Read by Alex
- `.tad/scripts/pack-eval-runner.sh` (whole, 404 lines) — `count_matches:209-216`, `is_invalid_regex:219-226`, no `set -e` (`30-31`), `run_all` glob `:322-337`, advisory exit-0 (`397-398`, `:344`)
- `.tad/scripts/capability-skill.sh` (`1-150`) — exit classes 0–4 (`28-33`), divergent exit 3 (`37-40`), resolve/symlink/containment (`72-141`)
- `.claude/skills/capability-builder/SKILL.md` — STOPPED stubs (`20-21`), ownership directions (`10-13`)
- `.claude/skills/capability-builder/references/create-protocol.md` — verdict-text convention (`:91`), state machine, contracts
- `.tad/project-knowledge/patterns/shell-portability.md` — timeout chain (`:18`), `grep -P` ban, env-var convention, `rg`-in-AC trap, awk-CJK, zsh no-split, `comm` locale, heredoc sinks, rm-chokepoint, `grep -F`+`$`, `~`-in-variables
- `.tad/evidence/reviews/gate4/capability-builder-create.md:27-29` — the three P2s (signal source)
- `.tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh` — `eval-compat` mode + `shasum -a 256` shim (reuse pattern)
- Mirror verified `diff -rq` rc=0 (2026-09-03)

### Blake Must Remember
- Runner is ADVISORY: never `set -e`, never fail-closed; bound trips → verdict TEXT (`TIMEOUT → SKIP (bounded)` / `OVERSIZE → SKIP (bounded)`, DISTINCT, matched with `grep -F -e`), process exit stays 0.
- Unguarded pre-fix catastrophic run is FORBIDDEN (P0). E1 is oversize-deterministic — no timing claim (BSD/macOS grep is DFA).
- `plugin-dir` is caller-selected → containment contract is MANDATORY (§4.3), not optional.
- AC scripts: baseline tools only, `LC_ALL=C` on sorts, `grep -F -e` for verdict text, no `for x in $VAR` (zsh), literal bound paths (§8).

## 2. Background Context

### 2.1 Existing Assets to Reuse
- `pack-eval-runner.sh` structure (add bounds ONLY; parsers, gates, formats unchanged)
- `capability-skill.sh` contract shapes (exit classes, lock, symlink/traversal checks — mirror for plugin script)
- Phase-1 `run-acceptance.sh eval-compat` + `fixtures/example-skill.md` + `scope/legacy-baseline-verdict.txt` (E2b/R1 loop)
- `hash_file`/`hash_tree` shims from Phase-1 acceptance driver (`shasum -a 256` → `sha256sum` fallback)

### 2.2 Current vs Target
- Current: evolve/package STOPPED; runner unbounded; no plugin script/template.
- Target: §1.1 (1)–(6). Nothing else.

### 2.3 Dependencies
Phase 1 (done). No other blocking dependency. Perl present, `gtimeout`/`timeout` absent (guard chain accounts for it).

## 3. Requirements

### 3.1 Functional Requirements
- FR1 Evolve protocol with TRIGGERED→FAILURE_CAPTURED→EDITED_MINIMAL→OLD_RERUN→NEW_PASSES→PROJECTED→GATE_3_READY + stops `NO_TRIGGER_NO_WRITES`, `REGRESSION_BLOCKS_PROJECTION`, `DRIFT_REFUSES_OVERWRITE`, `TARGET_DRIFT_STOP`.
- FR2 Runner bounds per design §5.2 (caps, order, validation, ranges, guard chain, frozen strings).
- FR3 Router update per design §5.3.
- FR4 Package path per design §5.4 (containment + temp discipline + forbidden roots + isolated evidence).
- FR5 Bound paths + pins per design §5.5 (slash-terminated `case`, process-group kill, override audit log, functional alarm proof).

### 3.2 Non-Functional Requirements
- Portability: BSD/macOS-safe, no `grep -P`, no `rg`, `LC_ALL=C` discipline, zsh-safe ACs.
- Advisory preservation: batch never aborts on one bad fixture.
- Atomicity: failed package/projection leaves both trees digest-identical.

### 3.3 Conflict Matrix
- YOLO speed vs mandatory evidence: evidence wins; YOLO never skips Gates/reviews/AC runs.
- Catastrophic demo vs safety: determinism wins — E1 proves the SIZE path, never an unbounded hang.

## 4. Technical Design (implementation view; rationale in design §§5.1–5.6)

### 4.1 Architecture
Unchanged topologies: runner stays a pure assertion tool; plugin script mirrors skill-helper shapes; framework mirror stays hand-authored `.claude → .agents`; downstream stays `.agents → .claude` via `project` only.

### 4.2 Builder Router and Protocol
Edit `SKILL.md` router only: `evolve` → mandatory read `references/evolve-protocol.md`; `package` → mandatory read `references/package-openai-plugin.md`. Create `references/evolve-protocol.md` (state machine + trigger enum + fixture-first rule + stops) and `references/package-openai-plugin.md` (scaffold/validate/install/drift rules). Out-of-scope stops unchanged.

### 4.3 Helper Command Contracts
- `pack-eval-runner.sh`: implement design §5.2 EXACTLY (order: symlink/regular → fixture 512 KiB cap → parse → post-unescape byte-length both patterns → guarded probe + guarded counts; `EVAL_*` strict validation + ranges + WARN; full-pipeline guard; frozen strings; `LC_ALL=C`; batch worst-case header note).
- `capability-plugin.sh` (new): `validate|package|verify <root> <skill> <plugin-dir>`; exit classes 0/1/2/3/4; containment EXACTLY per design §5.4 (physical resolve, in-root + in-`.tad/evidence/`-sandbox prefix with slash-terminated `case`, symlink-chain rejection ×3 trees, traversal/absolute rejection, per-entry name check, frontmatter match, forbidden artifacts, lock); temp EXACTLY per §5.4 (`cleanup_plugin_tmp`, sibling mktemp, full traps, prefix+empty guards).
- `.tad/templates/openai-plugin/`: minimal `.codex-plugin/plugin.json` {name, version, skills:[name]} + layout for one generated `skills/<name>/`.

### 4.4 Skill Validation Contract
Reuse Phase-1 contract unchanged (frontmatter, name==dir, no placeholders, no forbidden root artifacts).

### 4.5 Eval Fixture Contract
Reuse Phase-1 contract unchanged (`skill:`-only valid; dual-field SKIP; missing Verification Command SKIP; SKIP never proves PASS/FAIL). New: oversize/pattern-oversize/timeout SKIP verdicts per §4.3.

### 4.6 State and Evidence Flow
Sandbox roots in §8. Raw outputs + manifests + digests under the two evidence dirs. Prompt byte-identical for any CONTROL/WITH pair; record hashes (prompt, trees, outputs, fixtures) in `run-manifest.json` equivalents.

## 5. Mandatory Questions (answered — see design §4; not re-asked)

MQ1 historical search ✓ / MQ2 function verification ✓ / MQ3 data-flow ✓ / MQ4 N/A no UI / MQ5 failure handling ✓ / MQ6 in-repo evidence only, no external research ✓.

## 6. Out-of-Scope (STOP conditions)

TAD core edits, legacy pack edits/conversion, marketplace writes, MCP/App (not requested), DSH, multi-skill bundles, catalog/registry, scheduled refresh, Voice Studio paths, v2431 files. If the work seems to need any of these → STOP and report back instead of widening.

## 7. Files (closed world — new files ONLY below)

MODIFY: `.tad/scripts/pack-eval-runner.sh` (bounds only); `.claude/skills/capability-builder/SKILL.md` (router only).
CREATE: `.claude/skills/capability-builder/references/evolve-protocol.md`; `.claude/skills/capability-builder/references/package-openai-plugin.md`; `.agents/skills/capability-builder/` mirror updates; `.tad/scripts/capability-plugin.sh`; `.tad/templates/openai-plugin/`; `.tad/evidence/acceptance-tests/capability-builder-evolve/`; `.tad/evidence/acceptance-tests/capability-builder-package/`.
FENCED (any diff = FAIL): `tad.sh`, alex/blake/gate skills, `.tad/capability-packs/*`, `.tad/scripts/capability-skill.sh`, `release-verify.sh`, `.tad/hooks/`, `CLAUDE.md`/`AGENTS.md`, `.claude/skills/capability-upgrade/`, `create-protocol.md`, Voice Studio, v2431 handoff.

## 8. Bound Paths

- `<FIXTURE_PROJ>` = `.tad/evidence/acceptance-tests/capability-builder-evolve/fixture-proj`
- `<PLUGIN>` = `.tad/evidence/acceptance-tests/capability-builder-package/plugin`
- `<SNAPSHOT_DIR>` = `.tad/evidence/acceptance-tests/capability-builder-evolve/runner-corpus-snapshot/`
- `<SANDBOX>` = `.tad/evidence/acceptance-tests/capability-builder-package/sandbox-template/`
- Phase-1 reusables: `.tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh`, `fixtures/example-skill.md`, `scope/legacy-baseline-verdict.txt`

## 9. Acceptance Criteria (literal — run EXACTLY; `SKIP` never satisfies PASS)

### 9.1 Runnable checks
- [ ] **E1**: single-run `bash .tad/scripts/pack-eval-runner.sh .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.fixture.md .tad/evidence/acceptance-tests/capability-builder-evolve/regex-bound.output.md` (fixture: `(a+)+$` + 1.2 MiB `a`-output) + 3-run loop asserting `grep -F -e 'OVERSIZE → SKIP (bounded)' verdict.1.txt verdict.2.txt verdict.3.txt` (full loop in design §5.5). Pre-fix behavior ONLY via `command -v perl` pre-proof + `perl -e 'alarm 15; exec @ARGV' bash .tad/scripts/pack-eval-runner.sh <fixture> <output>`; unguarded pre-fix run FORBIDDEN. Functional guard proof: `perl -e 'alarm 1; exec sleep 5'` exits non-zero in ~1s.
- [ ] **E2**: (a) `bash .tad/scripts/pack-eval-runner.sh --all <SNAPSHOT_DIR> | grep -v -e '^===' -e '^outputs dir' -e '^---' -e 'pass / ' | LC_ALL=C sort > before.txt`, repeat after, `cmp before.txt after.txt`; (b) `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh eval-compat > <evolve-dir>/eval-compat.before.txt 2>&1` pre-change and `.after.txt` post-change, `cmp` identical (full command in design §5.5).
- [ ] **E3**: evolve entry with empty trigger → `NO_TRIGGER_NO_WRITES`, no writes; probe `find <FIXTURE_PROJ>/.agents <FIXTURE_PROJ>/.claude -type f | LC_ALL=C sort > tree.before` (+ `git status --porcelain -- <FIXTURE_PROJ>` baselined incl. `??`), rerun after, `cmp` identical.
- [ ] **E4**: one comment line appended to `<FIXTURE_PROJ>/.claude/skills/example-skill/SKILL.md` → `bash .tad/scripts/capability-skill.sh project <FIXTURE_PROJ> example-skill` exits 3; per-file `shasum -a 256` loop digests identical before/after (loop in design §5.5).
- [ ] **P1**: `python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["skills"]==["example-skill"], d' "<PLUGIN>/.codex-plugin/plugin.json"`; `find "<PLUGIN>/skills" -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort` exactly one line (`| wc -l | tr -d '[:space:]'` = `1`).
- [ ] **P2**: `diff -rq <FIXTURE_PROJ>/.agents/skills/example-skill <PLUGIN>/skills/example-skill` exits 0.
- [ ] **P3**: `bash .tad/scripts/capability-plugin.sh validate <FIXTURE_PROJ> example-skill <PLUGIN>` → 0; `package` → 0; `verify` → 0; `test -f <PLUGIN>/.codex-plugin/plugin.json`; `test -d <PLUGIN>/skills/example-skill`; `test ! -e "$HOME/.codex/plugins/example-skill"`; `test ! -e "$HOME/.config/example-skill"`; in-repo `git status --porcelain -- <PLUGIN> <FIXTURE_PROJ>` shows only expected evidence paths.
- [ ] **P4**: corrupt tree itself is the destination — `bash .tad/scripts/capability-plugin.sh package <FIXTURE_PROJ> example-skill <SANDBOX>` where `<SANDBOX>/.codex-plugin/plugin.json` is 0 bytes → non-zero (`ERROR: manifest empty (corrupt)`); both skill trees digest-identical before/after (evidence `p4bis.log` + `p4bis-digests.before/after`). Rationale: the script reads the framework template (validated), never a sandbox copy — sibling-absent destinations cannot exercise the corrupt-manifest path, and `<SANDBOX>-plugin` additionally mangles the basename.
- [ ] **P5**: `[ ! -e "<PLUGIN>/mcp.json" ] && [ ! -e "<PLUGIN>/app" ]`.
- [ ] **R1**: `git status --porcelain -- tad.sh .claude/skills/alex .claude/skills/blake .claude/skills/gate .tad/capability-packs .tad/scripts/capability-skill.sh .tad/hooks release-verify.sh CLAUDE.md AGENTS.md .claude/skills/capability-upgrade .claude/skills/capability-builder/references/create-protocol.md` empty; closed-world new-files-only-§7; legacy `pack:` covered by E2(b) (explicit, no orphan).

### 9.2 Expert Review Status (Gate 2)
code-reviewer R1 FAIL→R2 CONDITIONAL (residual 1 NEW-P1 closed in design §5.5); security-auditor R1 FAIL→R2 CONDITIONAL PASS (residual 3 NEW-P1s pinned in §5.5, Gate 3 must re-prove: slash-`case`, process-group kill incl. orphan-`sleep` test, override-value logging). Zero P0 open. Zero waivers.

## 10. Ralph Loop + Gate 3 Notes

- Materialize `example-skill` in `<FIXTURE_PROJ>` via the Phase-1 create contract first (this doubles as Phase-1 regression proof).
- Implement runner bounds → E1/E2 → evolve protocol files → router → plugin script/template → P1–P5 → mirror + `diff -rq` → full AC sweep.
- Gate 3 requires Layer 2 (2 reviewers, one MUST re-prove the §5.5 security pins) + build/test/lint self-check + completion report + evidence. Then hand back to Alex for Gate 4 (distill decision on the §8 knowledge candidate included).
- AC scripts obey the §8 portability rules; smoke-run them under both `bash` and the default `zsh` tool shell before declaring Gate-3-ready.

## 11. Do NOT

Do not touch §7-fenced files. Do not run unguarded catastrophic input. Do not write outside the repo (especially `$HOME/.codex`, `$HOME/.config`, marketplaces). Do not "fix" adjacent files (capability-skill.sh, create-protocol.md) — read-only reference. Do not publish/tag/sync (framework-health Phase-2 publish ban still stands; v2.43.1 release is the OTHER track's business).
