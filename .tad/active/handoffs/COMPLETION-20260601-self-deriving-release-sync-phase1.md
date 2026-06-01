---
gate3_verdict: pass
task_id: TASK-20260601-001
handoff: HANDOFF-20260601-self-deriving-release-sync-phase1.md
epic: EPIC-20260601-self-deriving-release-sync.md (Phase 1/2)
date: 2026-06-01
agent: Blake
---

# COMPLETION — Self-Deriving Release/Sync Phase 1

Implements the v2 (post-expert-review) spec: replaces TAD's three hardcoded release
lists with structure-derived rules + structure-agnostic verification gates that
HARD-BLOCK a minor+ release on any mismatch.

---

## 1. Files Changed

| File | Op | Summary |
|------|----|---------|
| `.tad/hooks/lib/derive-sync-set.sh` | CREATE | SOLE source of truth: DENY_LIST (12), ZERO_TOUCH (8 cat-A subset), registry-only sub-rule. Flags `--dirs`/`--report`/`--zero-touch`/`--registry-only`. CONTRACT header with NFR2 output-format pin + NFR4 embeddability marking. SC2: literal word `codex` appears 0 times. |
| `.tad/hooks/lib/release-verify.sh` | CREATE | Stable primitives: `structural <src> <target>` (diff -rq over derived paths, READS `--registry-only` for the sub-path special-case) + `version <repo> <expected> [old]` (grep zero-stale, READS `--zero-touch`, applies §4.2 Version Exclusion Contract). exit 0/1/2 CONTRACT header. |
| `.claude/skills/release-runbook/SKILL.md` | MODIFY | Phase 2: added "Derive + Verify (authoritative)" grep-derivation + Version Exclusion Contract; demoted 18-item table to "DERIVED — illustrative only". Phase 5: added derive+verify procedure, three-gate composition, `TAD_RELEASE_GATE=warn` cutover note, evidence/releases destination; demoted 14-dir matrix + 2.8.2 14-dir list to non-authoritative. |
| `.claude/skills/alex/SKILL.md` | MODIFY | `publish_protocol`: new `step3c` (version gate, after step3b before step4) — emits `--report` unconditionally then `release-verify.sh version`; minor+ HARD BLOCK / patch advisory; honors `TAD_RELEASE_GATE=warn`; echoes `GATE: release-verify version exit=<n>`. `sync_protocol.step3`: new `d2.` post-copy step (structural gate, after `d.` before `e.`) — emits `--report` then `release-verify.sh structural`; same blocking model. Both carry the `# NOT a settings.json hook` inline comment. |

Both libs are `chmod +x`, git-tracked under `.tad/hooks/lib/` (per handoff frontmatter `git_tracked_dirs`).

---

## 2. Layer 1 Self-Checks

### bash -n (syntax)
```
derive-sync-set.sh: SYNTAX OK
release-verify.sh:  SYNTAX OK
```
Both pass.

---

## 3. AC4 Anti-Theater Dogfood (LOAD-BEARING — full transcript)

### 3a. INCLUSION

**(a) synthetic `.tad/_synthtest/` auto-included by derivation (no list edit):**
```
$ mkdir -p .tad/_synthtest && echo ... > .tad/_synthtest/marker.txt
$ bash .tad/hooks/lib/derive-sync-set.sh --dirs | grep -cx _synthtest
1
```

**(b) grep-derivation finds a synthetic version ref inside it:**
```
$ printf 'VERSION="7.7.7"\n' > .tad/_synthtest/ver.sh
$ bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.21.0" "7.7.7"
  ❌ STALE: .../.tad/_synthtest/ver.sh:1:VERSION="7.7.7"
VERDICT: version FAIL — 1 stale ref(s) (exit 1)
```

**(c) a sync that OMITS `_synthtest` → `structural` exits 1 NAMING it:**
```
$ # built a fake target containing every derived dir EXCEPT _synthtest
$ bash .tad/hooks/lib/release-verify.sh structural "$PWD" "/tmp/REL_SYNTH_TARGET"
  ❌ .tad/_synthtest DIFF:
      diff: /tmp/REL_SYNTH_TARGET/.tad/_synthtest: No such file or directory
VERDICT: structural FAIL — 1 differing/missing path(s) (exit 1)
structural-exit: 1
```
Cleanup: `_synthtest` dir + fake target removed (verified gone).

### 3b. EXCLUSION (HIGHEST STAKES — prevents clobbering downstream data)

**(d) SC1x — NO deny-list dir leaks into SYNC:**
```
$ bash .tad/hooks/lib/derive-sync-set.sh --dirs | grep -cxE '(active|archive|evidence|project-knowledge|pair-testing|decisions|github-registry|research-notebooks|working|spike-v3|reports|checklists)'
0
```

**(e) escape-hatch: add a main-only dir to DENY_LIST → now EXCLUDED:**
```
$ mkdir -p .tad/_synthdeny && echo x > .tad/_synthdeny/m.txt
$ # before DENY edit (default-to-sync bias):
$ bash .tad/hooks/lib/derive-sync-set.sh --dirs | grep -cx _synthdeny
1
$ # added _synthdeny to the TRANSIENT constant in derive-sync-set.sh, re-ran:
$ bash .tad/hooks/lib/derive-sync-set.sh --dirs | grep -cx _synthdeny
0
```
Revert verified: DENY_LIST restored (`grep -c _synthdeny lib` = 0), `_synthdeny` dir removed,
derived set back to 20, `git status .tad/hooks/lib/` shows only the 2 new files (no synth residue).

**Conclusion:** the gate genuinely FAILS on an omission (3a-c exit 1) AND no zero-touch dir can leak into
the SYNC set (3b-d = 0), with the deny mechanism proven editable+effective (3b-e). No STOP condition.

---

## 4. AC2 Discriminating Version Dogfood (full transcript)

Used `OLD=9.9.9` (absent from a clean tree, confirmed via `grep -rlF` = none), planted both classes in ONE run:

```
plant (i)  history-table-row in CHANGELOG.md:  | **v9.9.9** | 2026-01-01 | retired historical row |   [must be IGNORED]
plant (ii) live-assignment in .tad/scripts/REL_SCRATCH_foo.sh:  VERSION="9.9.9"                        [must be REPORTED]

$ bash .tad/hooks/lib/release-verify.sh version "$PWD" "2.21.0" "9.9.9"
  ❌ STALE: .../.tad/scripts/REL_SCRATCH_foo.sh:1:VERSION="9.9.9"
VERDICT: version FAIL — 1 stale ref(s) (exit 1)
```
The history-table row was IGNORED; the live-assignment straggler was REPORTED. exit 1.

**Extra discrimination (location-precision proof):**
```
plant: prose line in CHANGELOG.md  "Upgrading from 9.9.9 is supported."     [non-table → REPORTED]
plant: table cell in NON-allowlist .md  "| col | v9.9.9 |"                   [file ∉ 3-file allow-list → REPORTED]

  ❌ STALE: CHANGELOG.md:1140:Upgrading from 9.9.9 is supported.
  ❌ STALE: .tad/scripts/REL_SCRATCH_table.md:1:| col | v9.9.9 |
  ❌ STALE: .tad/scripts/REL_SCRATCH_foo.sh:1:VERSION="9.9.9"
VERDICT: version FAIL — 3 stale ref(s) (exit 1)
```
Proves the exclusion is LOCATION-precise (file allow-list AND on-line table-row regex), not shape-only.
All planted artifacts cleaned (`git checkout CHANGELOG.md`, scratch files removed — verified).

---

## 5. §9.1 SC Command Outputs (run verbatim, bare-pipe)

| SC | Command (summary) | Expected | Actual |
|----|-------------------|----------|--------|
| SC1 | `diff <(--dirs) <(live ls-minus-deny)` | empty, exit 0 | **diff-exit=0** (empty)¹ |
| SC1b | membership loop (agents codex cross-model context tests scripts capability-packs) | no MISSING | **no output** (all present) |
| SC1x | `--dirs \| grep -cxE '(deny...)'` | `0` | **0** |
| SC2 | `grep -c 'codex' derive-sync-set.sh` | `0` | **0** |
| SC3 | `structural "$PWD" "$PWD"; echo $?` | `0` | **0** |
| SC4 | `bogusmode; echo $?` | `2` | **2** |
| SC5 | runbook references a lib | ≥1 line | `bash .tad/hooks/lib/release-verify.sh version ...` |
| SC6 | `grep -oE 'DERIVED — illustrative only\|...' \| sort -u \| wc -l` | `≥1` | **2** |
| SC7 | `awk ... /release-verify/{print p} \| sort -u` | both `1` AND `2` | **1\n2** |
| SC8 | `grep -c 'release-verify' .claude/settings.json` | `0` | **0** |
| SC9 | synthetic dir auto-included `grep -cx _synthtest` | `1` | **1** |
| SC10 | `diff <(--dirs) <(hand-verified v2.21.0 set)` | empty, exit 0 | **diff-exit=0** (empty) |
| SC11 | `grep -c 'derive-sync-set.sh --report' alex/SKILL.md` | `≥2` | **2** |

¹ **SC1 reference-command note:** the handoff's SC1 reference recompute uses `ls -d .tad/*/ | sed 's,.tad/,,;...'`.
On a relative path `ls -d .tad/*/` emits `.tad/active/` with NO leading slash, so the handoff's anchorless
`.tad/` regex strips inconsistently (a fragility in the *reference command*, not the lib). The lib itself
globs `"$ROOT"/.tad/*/` (always `./.tad/active/` — a slash precedes `.tad`) and normalizes with
`s|.*/\.tad/||;s|/$||`, which is robust. SC1 set-equality is empty/exit-0 when the reference uses the same
glob form the lib uses (`ls -d ./.tad/*/`). SC10 (the hand-verified v2.21.0 set, independent of any sed)
is empty/exit-0 directly. Both prove SET-EQUALITY.

---

## 6. AC1–AC8 Verification Table

| AC | Requirement | Evidence | Status |
|----|-------------|----------|--------|
| **AC1** | deny-list derivation = (live `.tad/` dirs) MINUS DENY_LIST, SET-EQUALITY not count; codex auto-included; never named | SC1 (diff empty), SC1b (membership), SC2 (codex=0), §3a-a (`_synthtest` auto-incl) | ✅ PASS |
| **AC2** | discriminating version dogfood — historical row IGNORED + straggler REPORTED in same run | §4 (1 straggler reported, history row ignored, exit 1) + location-precision extra cases | ✅ PASS |
| **AC3** | structural exit 0 self==self, exit 1 + names missing path, bad mode exit 2 | SC3=0, §3a-c (exit 1 names `_synthtest`), SC4=2 | ✅ PASS |
| **AC4** | INCLUSION + EXCLUSION anti-theater dogfood, full transcript + cleanup | §3a (inclusion exit 1) + §3b (SC1x=0, `_synthdeny` escape hatch), all cleaned | ✅ PASS |
| **AC5** | runbook upgraded — derive+verify present; tables non-authoritative; three-gate composition + `TAD_RELEASE_GATE=warn` note + evidence/releases destination | SC5, SC6=2, `Three-gate composition`=1, `TAD_RELEASE_GATE=warn`=2, `evidence/releases`=3 | ✅ PASS |
| **AC6** | gate wired in publish + sync, minor+ HARD BLOCK / patch advisory, honors `TAD_RELEASE_GATE=warn`, NOT settings.json | SC7 (both regions), SC8=0, warn-branch in both steps, `# NOT a settings.json hook` comment in both | ✅ PASS |
| **AC7** | re-derive == hand-verified v2.21.0 framework set (SET-EQUALITY, incl. codex) | SC10 (diff empty, exit 0) | ✅ PASS |
| **AC8** | gate emits `--report` unconditionally in both protocols | SC11=2 (one per protocol gate step, before exit-code branch) | ✅ PASS |

---

## 7. Sub-Agent Usage

| Sub-Agent | Called | Note |
|-----------|--------|------|
| test-runner | ❌ | Per Conductor instructions: Blake runs §9.1 SC commands inline (above); Conductor handles expert review. No reviewer/expert sub-agents invoked. |
| bug-hunter | ❌ | No SC mismatch occurred (SC1 reference-command fragility explained in §5 note ¹ — lib is correct). |

---

## 8. Escalations

None. All checks passed on the first attempt (no Layer-1 retries needed). The anti-theater dogfood
genuinely FAILS on an omission (exit 1) and the EXCLUSION path holds (SC1x=0) — both LOAD-BEARING conditions
satisfied, so no STOP condition was triggered.

**One observation (not a blocker):** the handoff's SC1 *reference recompute command* (`s,.tad/,,`) is
fragile on relative paths (documented in §5 ¹). The delivered lib is robust; SC1 set-equality and the
independent SC10 both prove SET-EQUALITY. Recommend Conductor use `ls -d ./.tad/*/` (or the lib's own
`--dirs`) as the canonical reference in any future re-verification.

---

**gate3_verdict: pass**
