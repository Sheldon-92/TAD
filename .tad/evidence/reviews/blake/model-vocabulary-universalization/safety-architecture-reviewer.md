Model: harness=codex | model=gpt-5 | route=unknown
# Model Vocabulary Universalization — Layer 2 Safety / Architecture Review

**Handoff:** `.tad/active/handoffs/HANDOFF-20260803-model-vocabulary-universalization.md`
**Baseline:** `39ba1c1c0fc1a92b373331d23553794dd54da135`
**Final verdict: CONDITIONAL PASS**

The scoped implementation diff and handoff sections §2, §3 (especially C/D),
§5 AC5/AC8, §6, and §7 were reviewed. All supplied AC scripts return zero and
the intended product edits are present, but two safety validators accept
mutated evidence that violates the stated fail-closed contracts. One full
reviewer template also has an incomplete Codex capture instruction. No product
file was modified by this review.

## Findings

### P1-1 — AC8 registered line-set gate is fail-open

**Type:** execution evidence; reproduced in an isolated copy.

`.tad/evidence/acceptance-tests/model-vocab-universalization/AC-08-registered-line-set.sh`
skips every empty diff body with `[ -n "$body" ] || continue`, and
`registered_line()` authorizes broad substring matches such as `*"config.toml"*`
instead of an exact registered line/block set. `reverse_added` is initialized
but never populated, and untracked product paths are not considered by the
`git diff` walk.

Scratch probe `/tmp/tad-model-vocab-safety.FbT3i3/repo` appended both an empty
line and this unregistered line to a registered file:
`unregistered line deliberately smuggled via config.toml`. The unchanged AC8
script returned:

```text
AC8_MUTATION_RC=0
AC8 PASS: baseline=39ba1c1c0fc1a92b373331d23553794dd54da135 registered changed-file and line-set diff are closed
```

The live diff also contains deleted empty lines in
`.claude/skills/alex/references/acceptance-protocol.md` and
`.claude/skills/alex/references/handoff-creation-protocol.md`; AC8 does not
account for them. This violates the §7 line-set ground-truth claim even though
the intended edits themselves are in scope.

**Required disposition:** make AC8 compare exact sorted plus/minus line sets
(including empty-line changes), remove substring authorization, account for
reverse/deletion direction explicitly, and either reject or explicitly scope
untracked product files.

### P1-2 — AC7 accepts unrelated “real re-verification” text

**Type:** execution evidence; reproduced in an isolated copy.

When `last_verified` changes,
`AC-07-ledger-binding.sh` only checks whether any file under
`.tad/active/handoffs` or `.tad/archive/handoffs` contains the substring
`真实重验证`. It does not bind the evidence to this handoff’s Completion, the
current date, or an evidence path.

In the same scratch copy, `ask_user_question_hook` was changed from
`2026-08-03` to `2026-08-02`, no Completion was created, and an unrelated
archive note containing `真实重验证` was added. AC7 still returned:

```text
AC7_MUTATION_RC=0
AC7 PASS: status accepted_limitation, numbered-options note, and last_verified change binding hold
```

This does not invalidate the current row (its date is unchanged), but it makes
the AC unable to enforce its own provenance rule. The check should require the
same handoff slug’s Completion and a dated, concrete re-verification record;
otherwise it must fail.

### P1-3 — Workflow full-reviewer Codex capture is not equivalent to §B2

**Type:** reading inference, corroborated by the AC9 runtime probe.

`.claude/workflows/handoff-review.workflow.js:238` tells full-channel reviewers
to inspect `CODEX_HOME/config.toml`, while the Blake/Alex full templates and §B2
correctly define `CFG="${CODEX_HOME:-$HOME/.codex}"`. The workflow prompt also
omits the explicit selected-provider `base_url` route resolution and the
section-ownership caveat. A reviewer with `CODEX_HOME` unset is therefore given
an ambiguous/nonexistent config path and less precise route provenance. AC4
only checks token presence, so it does not catch this semantic mismatch.

The raw AC9 evidence shows the real fallback is `/path/to/.codex`
when `CODEX_HOME` is unset, plus per-agent overrides. Align the workflow
semantic port with §B2’s fallback and route-resolution wording.

### P2 — Environment capture should enforce redaction, not only prose

**Type:** reading inference.

The prescribed `env | grep -E '^OPENAI_BASE_URL='` and analogous Anthropic
probe print the entire variable value. The handoff says to record only the
variable name and host and never a key, but the command itself does not redact
credentials embedded in a URL. Replace or wrap the probe with host extraction
and explicit redaction before durable evidence capture.

## Required safety / architecture checks

- **AC5 sentinel and SAFETY blocks:** PASS. The sentinel reports the expected
  preservation hash; sorted content checks for Blake and handoff safety blocks,
  the byte-equal `hard_requirement_distinct_reviewers` block, Criterion C/D
  non-auto-archive anchor, and the three handoff `minimum_experts`/`VIOLATION`
  neighbors all pass.
- **Criterion C/D:** PASS. `tad-maintain/SKILL.md` retains
  `Criterion C and D MUST NOT auto-archive`; the new platform-binding clause
  does not alter the interactive archive rule.
- **Live governance set:** PASS. The live `git grep` set equals the 11-element
  baseline set, and each active `.claude` governance SKILL has exactly one
  clause header. The `.agents` copies are byte-identical by parity.
- **Reviewer count / schema neighbors:** PASS by diff. The
  `hard_requirement_distinct_reviewers` block, `minimum_experts: 2`, both
  required `violations:` lines, `REVIEW_SCHEMA`, and `AUDIT_ROW_SCHEMA` are not
  changed. The workflow change is limited to the INV-4 comment and prompt
  insertion.
- **Parity:** PASS (`release-verify.sh parity .` exit 0); all listed mirrored
  SKILL/reference files compare equal and `.agents/workflows` is absent as
  allowed by the handoff.
- **Sorting/filtering/grep discipline:** AC scripts use the required `-e`
  fixed-string forms, `LC_ALL=C sort`, `comm`, and `|| true` around no-match
  recursive probes. The P1-1/P1-2 findings are the remaining validator
  binding weaknesses.
- **Forbidden scope:** PASS for the current tracked diff: AC8 reports all
  changed lines/files registered, and current status shows no untracked product
  path outside the declared evidence/handoff areas. This is subject to the
  AC8 untracked-file gap above.

## AC result summary

AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, and AC10 each returned `0` in the
repository. The machine results are therefore green, but the final review is
**CONDITIONAL PASS** until P1-1 and P1-2 are hardened; P1-3 should be aligned
in the same repair round before relying on full-channel reviewer provenance.

## 执行证据

The following commands were run read-only in the repository unless explicitly
marked as a scratch copy:

```text
$ for script in .tad/evidence/acceptance-tests/model-vocab-universalization/AC-0*.sh ...; do bash "$script"; done
AC1 PASS: capability tier is present and legacy strong-tier wording is absent in all four lite skills
AC2 PASS: all four lite skills contain the codex/other capture contract and no legacy Anthropic route wording
AC3 PASS: live governance set, interaction binding, stale-comment filter, AGENTS pointer, and portable-rules line-set guard
AC4 PASS: all three reviewer template carriers self-report model provenance and segment boundaries hold
AC5 PASS: sentinel, SAFETY block, reviewer-count, archive, and handoff-neighbor invariants hold
AC6 PASS: parity, skill-body, and runtime-freshness regression guards passed
AC7 PASS: status accepted_limitation, numbered-options note, and last_verified change binding hold
AC8 PASS: baseline=39ba1c1c0fc1a92b373331d23553794dd54da135 registered changed-file and line-set diff are closed
AC9 PASS: codex version and all four harness capture probes were re-run
AC10 PASS: judge calibration is expressed as a capability tier with uncalibrated advisory marking

$ bash .tad/hooks/lib/release-verify.sh parity .
VERDICT: parity PASS (exit 0)

$ bash .tad/hooks/lib/runtime-freshness-verify.sh .
Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0
VERDICT: runtime freshness PASS

$ node --check .claude/workflows/handoff-review.workflow.js
The repository’s direct check reports the pre-existing module-context/top-level-return issue at untouched line 72; the implementation diff does not touch that line. The diff itself contains no schema changes.

$ scratch mutations in /tmp/tad-model-vocab-safety.FbT3i3/repo
AC8_MUTATION_RC=0 ... AC8 PASS ...
AC7_MUTATION_RC=0 ... AC7 PASS ...
```

Evidence read: `.tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md`,
`AC-05-safety-invariants.sh`, `AC-08-registered-line-set.sh`,
`AC-07-ledger-binding.sh`, `AC-09-codex-key-reprobe.sh`,
`ac9-key-reprobe-raw.txt`, and `parity-fix-raw.txt`.
