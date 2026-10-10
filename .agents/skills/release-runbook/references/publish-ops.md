# Publish Operations

Load this reference only for publish planning, execution, or verification. The entry skill's
physical-root guard, role/mode contract, effective-permission intersection,
handoff transaction CAS, exact mandate bindings, and ambiguous-result recovery remain mandatory.

## 1. Derive the release intent

Work from `repo_root`; never use remembered versions or an inherited relative `$PWD`.

1. Read the current version from `$repo_root/.tad/version.txt` and validate SemVer.
2. Derive the requested next version and classify it as patch, minor, or major. Alex-Lite records
   the proposed version, rationale, exact release scope, and selected mode in the sole LITE contract.
3. Read `CHANGELOG.md` and require a user-facing entry for the proposed version before execution.
4. Inspect intentional scope with:

   ```bash
   git -C "$repo_root" status --short
   git -C "$repo_root" log --oneline origin/main..HEAD
   git -C "$repo_root" diff --stat
   ```

   Unexplained dirty files or commits outside the release intent are blockers. Do not absorb them
   into a release commit.

## 2. Read-only preflight gate order

Run every command from the physical root, record stdout/stderr/exit code, and branch on the exact
exit code. A missing tool, malformed invocation, or exit `2` is a wiring failure and always blocks.
The normative order is: structural → derived sync-set report + version → version-sweep → migration → installer-destructive-guard → freshness → supporting checks. Do not parallelize, defer, or reorder these gates; stop at the first blocker.

### 2.1 Canonical skill integrity (structural)

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" structural "$repo_root" "$repo_root"
```

- `0`: `.agents/skills` (the sole skill source since v3.0.0) is self-consistent.
- `1`: drift/omission. In `plan`/`verify`, report without healing. In a separately contracted
  `execute` remediation, fix the copy omission and re-run structural afterward.
- `2`: hard block for every release type.

A structural pass proves copy completeness, not semantic correctness, so it does not replace
the remaining gates. (The dual-tree mirror gate was removed in v3.0.0 — single skill tree,
nothing to mirror.)

### 2.2 Version zero-stale gate

Derive `OLD` from the current repository state and `NEW` from the approved release intent.

```bash
bash "$repo_root/.tad/hooks/lib/derive-sync-set.sh" --report "$repo_root"
bash "$repo_root/.tad/hooks/lib/release-verify.sh" version "$repo_root" "$NEW" "$OLD"
```

- `0`: continue.
- `1`: named stale-reference drift. Block minor/major; for patch, report the advisory result and
  require the LITE contract to record the disposition before continuing.
- `2`: hard block; never reinterpret as drift or downgrade it.

The derivation/gate is authoritative. Any hand-written version-file table is illustrative only.

### 2.3 Full version sweep

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" version-sweep "$repo_root" "$NEW"
```

- `0`: Layer 1 identity markers are current.
- `1`: Layer 1 is blocking for patch/minor/major. Layer 2 findings printed by the verifier are
  advisory and must be reported, not converted into blockers without a separate rule.
- `2`: hard block.

### 2.4 Migration-manifest gate

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" migration "$repo_root"
```

- `0`: continue.
- `1`: unmanifested delete/rename drift. Block minor/major; patch may proceed only with the
  advisory result explicitly recorded in the LITE contract.
- `2`: hard block for every release type.

Do not create an inline migration or verifier wrapper. The existing CLI is the authority.

### 2.4a Installer-destructive-guard and runtime-freshness gates

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" installer-destructive-guard "$repo_root"
bash "$repo_root/.tad/hooks/lib/release-verify.sh" freshness "$repo_root"
```

- `0`: continue. `1`: block. `2`: hard block (wiring failure).
- `freshness` exit `1`: re-verify the flagged ledger row for real (never change only the date), or
  record a human waiver in the release record. A high-volatility row becomes BLOCK on day 31 after
  `last_verified`, whether or not any file changed.

在船断言（Epic P2 件 2.9）：上述命令对 PREV→NEW 的 hop 文件存在且良构另有断言，缺失/畸形输出 `MISSING HOP:`/`MALFORMED HOP:` 并 exit 1——此分支对全部 release 类型（含 patch）HARD BLOCK，与 D/R 漂移的 patch advisory 分支不同。

### 2.5 Supporting checks

- Run `bash "$repo_root/.tad/hooks/lib/pack-registry-driftcheck.sh"`; exit `1` is advisory unless
  another contract makes it blocking.
- Run the validator positive-control self-check defined as publish-protocol step3c3: every
  governed name must pass `capability-skill.sh validate "$repo_root" <name>`; any non-zero result
  stops the release.
- Judge `hooks.json` drift semantically: compare the canonicalized JSON value sequences
  (`jq -S`) of the regenerated file and the archived `.codex/hooks.json`. Equal value sequences
  are not drift even when byte formatting differs; any differing value is drift. Apply the same
  rule to older generated files in downstream repositories.
- If `tad.sh` or `derive-sync-set.sh` changed, `bash "$repo_root/tad.sh" --verify-denylist` must
  exit `0` before tagging.
- The historical `TAD_RELEASE_GATE=warn` cutover graduated on 2026-06-10. It is not an active path.

### 2.6 Release-chain liveness (publish-protocol step3f)

预检序：step3f 在 step3e 之后、step4 之前执行，正本为 publish-protocol 的 step3f 条目，本节只作镜像。判读口径：逐家 runtime 核当周期 transcript 在不在、六字段齐不齐、新不新（执行日期须不早于上一版发布日）；HARD 态缺失即红、硬停；ADVISORY 态缺失不拦发版，但发版记录须逐家登记「缺失＋补齐归属（Epic Phase 3 件 3.3）」，未登记按缺失同罪判红。

## 3. Version bump and CHANGELOG execution

Only Blake-Lite in `execute` mode may make handoff-listed version/CHANGELOG edits. Derive affected
tracked files with a fixed-string search for `OLD`, update only the approved set, and run the version
and version-sweep gates again. Do not rely on a remembered file count. Stage explicit paths only.

Version-surface derivation rule (mirror of publish-protocol step3c, which is the canonical
wording): the version-literal change surface is derived by rule, never remembered. Change surface =
Must-Version Registry assertion surface ∪ state-surface check1–3 assertion surface ∪ any surface
changed by the previous same-type release that the preceding assertion surfaces do not cover ∪
{`.tad/version.txt`, the AGENTS.md version marker line}. First run the version gate detect-only;
triage every hit as a live change, a closeout backfill, or an exemption; and file the record at
`.tad/evidence/releases/<NEW>-version-triage.md`. A patch advisory pass requires that triage record
to be on disk.

### 3.1 Historical version references — minor/major triage

For a minor or major release, classify every hit from the version gate's detect-only run before
changing any historical wording:

- **L — Live surface:** Must-Version Registry assertion surfaces, state-surface check1–3
  surfaces, and prior-release surfaces. Enumerate and change each line with the bump.
- **H1 — Version-event statement:** wording that records an event tied to an already-published
  version (for example, “removed in vX”, an ARCHIVED header, or a note explaining an old
  version). Never rewrite it; exempt the whole class.
- **H2 — Version-floor statement:** wording in the form “vX.Y+” that remains true after the
  bump. Exempt it.
- **H3 — Edition signature / welcome line:** do not mechanically renumber it. Exempt it; whether
  to add a separate new line is an editorial decision for the closeout owner, recorded in the
  triage record.
- **F — Fixture pinned value:** exempt it, unless the fixture's purpose is itself to assert the
  current version, in which case classify it as L.
- **D — Documentation history / prior CHANGELOG entry:** exempt it.

An unclassified hit stops the triage: classify it item by item, record the conclusion and any new
precedent in the current triage record, and do not force it into an existing class. The record's
fields are `path:line` / hit text / category / basis or precedent pointer. For minor/major, the
record must cover 100% of the detect-only hits; any unclassified hit is a hard block.

**check4 OLD_PAT check (minor bumps):** `state-surface-check.sh`'s check4 `OLD_PAT` pins the
current edition row as an escaped literal — on every minor bump, update it to the new
`major\.minor([^0-9.]|$)` row (patch bumps: leave it) and re-run the paired controls before
closing: a bare `Version <major.minor>` sample must FAIL check4 and the full
`Version <major.minor.patch>` sample must PASS.

### 3.2 After the bump: provenance

Once the version-bump commit exists, regenerate the legacy ledger and gate on it:

```bash
bash "$repo_root/.tad/scripts/gen-claude-provenance.sh"
git -C "$repo_root" add .tad/provenance/claude-legacy.tsv .tad/provenance/MANIFEST.sha1 && git -C "$repo_root" commit -m "chore(provenance): regenerate the ledger"
bash "$repo_root/.tad/hooks/lib/release-verify.sh" version-sweep "$repo_root" "$NEW"
bash "$repo_root/.tad/hooks/lib/release-verify.sh" provenance "$repo_root"
```

All gates must complete before the tag; a commit made after the tag makes the migration gate look for an X-to-X hop.
The provenance gate reads the git index: a staged-but-uncommitted skill change keeps it red.
The commit to tag is the last one, the one that contains the regenerated ledger; re-run `provenance` on that commit immediately before the publish step, after any closeout commits. The gate is also red while `.tad/provenance` has uncommitted changes.

The release commit is local preparation, not publish authority. Verify its staged diff and final commit
hash against the accepted mandate before any remote action.

## 4. Mandate-bound publish sequence

One accepted release transaction may contain the exact main update, annotated tag, tag update, and later
sync only when every consequence, target, ref/version, commit and blast-radius binding is present. Before
each command, re-read preconditions and CAS its named action to launched; separate commands are technical
safety boundaries, not separate human decisions.

1. Push the exact approved commit to `refs/heads/main`:
   `git -C "$repo_root" push origin <commit>:refs/heads/main`
2. Create the exact annotated tag:
   `git -C "$repo_root" tag -a "v$NEW" <commit> -m "v$NEW — <approved summary>"`
3. Push only that tag:
   `git -C "$repo_root" push origin "refs/tags/v$NEW:refs/tags/v$NEW"`

Never use `--force`, `--tags`, an unscoped refspec, or a combined shell chain. Diagnose remote-ahead;
never auto-force. A deterministic same-outcome recovery is agent-owned, while a semantic or visible-result
fork is a boundary change.

## 5. Ambiguous result and replay recovery

会话或发布中断后，先在隔离副本跑 `bash .tad/scripts/interrupt-resume-check.sh selftest` 核对恢复判据，再按本节续跑；判据分类见状态图（`.tad/evidence/epic-p2-measurement-20261006/state-graph-gate-chain.md`）。

If a push/tag command times out, disconnects, or returns an ambiguous result, do not blind retry. Read
remote state:

```bash
git -C "$repo_root" ls-remote --heads origin refs/heads/main
git -C "$repo_root" ls-remote --tags origin "refs/tags/v$NEW" "refs/tags/v$NEW^{}"
```

Classify the action in the sole handoff transaction. Completed never repeats; verified not-started retries
the same action without a prompt; deterministic partial recovery stays in the transaction; unresolved
unknown blocks mutation; only a divergent visible recovery returns as a boundary change.

## 6. Post-publish verification and report

Verify the remote main SHA equals the approved commit, the annotated tag and peeled tag resolve to
that commit, and local status contains no unexplained release residue. Report the exact commands,
exit codes, remote SHAs, tag, remaining blockers, and any next sync action. Sync runs only when the same
accepted mandate names its target/consequence binding; publish verification cannot expand authority.

The tag-in-place assertion is owned by publish-protocol step5 (local tag present, remote tag
present, tag pointing at the release commit; any miss is RED with on-the-spot re-tagging and a
line in the release record) — adjudicate it there; this section only mirrors the pointer.
