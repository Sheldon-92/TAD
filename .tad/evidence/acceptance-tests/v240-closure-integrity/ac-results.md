# v2.40 Closure Integrity — AC Results

## AC3 Admission (before Epic copy)

Command:

```bash
S=.tad/active/epics/EPIC-20260804-lite-as-tad-body.md
E=.tad/archive/epics/EPIC-20260804-lite-as-tad-body.md
git cat-file -e "HEAD:$S" \
  && [ -f "$S" ] \
  && [ ! -e "$E" ] \
  && echo AC3-ADMISSION-PASS \
  || { echo 'AC3-ADMISSION-FAIL: source missing or archive destination exists'; exit 1; }
```

Raw output:

```text
AC3-ADMISSION-PASS
```

The command was executed before the Epic source edit; this raw output was recorded before the copy step.

## AC1–AC3 (implementation pass)

- AC1 raw output: `AC1-PASS` — `tad.sh` md5 remained `887658f1581b660de79feccb14ff2f80`; syntax and `TALLY: PASS=12 FAIL=0` passed.
- AC2 raw output: `AC2-PASS` — current Codex route contains the three Lite-first anchors, old full-route sentence is absent, and the v2.35.0 historical slice md5 remained `6fb50d0183ea66542374d61103d83335`.
- AC3 raw output: `AC3-PASS` — active Epic source is absent, archive exists, COMPLETE/SC2/2026-08-06 markers remain, obsolete primary-criterion sentence is absent, and the exact `HEAD` minus one line comparison passed.

## AC5 preliminary probe (not final)

The first post-implementation AC5 diff was intentionally run before L3 evidence creation. It found only the expected missing path `?? .tad/evidence/reviews/blake/v240-closure-integrity/code-reviewer.md`; AC5 will be rerun after the reviewer artifact exists and before any staging/commit.

Final AC5 rerun after reviewer evidence materialization:

```text
AC5-PASS
```

## Reviewer closure

- Initial independent review: `CONDITIONAL`, P0=0, P1=0, P2=0; condition was the not-yet-materialized reviewer artifact.
- Incremental independent review: `PASS`, model=`GPT-5`, harness=`Codex`, route=`unknown`; P0=0, P1=0, P2=0.
- Incremental raw decisive output: `AC5-PASS`; `AC1-PASS`; `AC2-PASS`; `AC3-PASS`; zero AC5 removals.

## AC6 (Commit A)

- Commit A: `ac0699f` with subject `fix(installer): make remote version authoritative before no-op`.
- First execution under zsh was not a content failure: the Bash AC's loop variable `path` is zsh's special PATH array, so the runner reported `git/awk/diff not found`.
- Exact AC6 command rerun under `/bin/bash`:

```text
AC6-PASS
```

## AC4 (quiet-point run)

Human precondition: user confirmed `quiet point` before this run; no `--fix` mode was used.

Command:

```bash
bash .tad/hooks/lib/release-verify.sh version . 2.40.0 \
  && bash .tad/hooks/lib/release-verify.sh version-sweep . 2.40.0 \
  && bash .tad/hooks/lib/release-verify.sh parity . \
  && echo AC4-PASS
```

Decisive raw output:

```text
VERDICT: version PASS (exit 0)
Layer 1 verdict: PASS (12 verified, 0 warnings)
Layer 2 hits: 483 (advisory only, not blocking)
VERDICT: version-sweep PASS (exit 0)
✅ .claude/skills <-> .agents/skills byte-identical
VERDICT: parity PASS (exit 0)
AC4-PASS
```
