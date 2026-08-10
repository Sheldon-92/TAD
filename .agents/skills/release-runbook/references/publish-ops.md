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
The normative order is: parity → derived sync-set report + version → version-sweep → migration
→ supporting checks. Do not parallelize, defer, or reorder these gates; stop at the first blocker.

### 2.1 Canonical skill parity

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" parity "$repo_root"
```

- `0`: parity is clean.
- `1`: drift. In `plan`/`verify`, report direction without healing. In a separately contracted
  `execute` remediation, `parity --fix` may run only for `claude-newer`; `agents-newer` or
  undecidable direction must refuse. Re-run detect-only parity afterward.
- `2`: hard block for every release type.

Never independently author `.agents/skills`; `.claude/skills` is canonical. A parity pass proves
identity, not semantic correctness, so it does not replace the remaining gates.

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

### 2.5 Supporting checks

- Run `bash "$repo_root/.tad/hooks/lib/pack-registry-driftcheck.sh"`; exit `1` is advisory unless
  another contract makes it blocking.
- If `tad.sh` or `derive-sync-set.sh` changed, `bash "$repo_root/tad.sh" --verify-denylist` must
  exit `0` before tagging.
- The historical `TAD_RELEASE_GATE=warn` cutover graduated on 2026-06-10. It is not an active path.

## 3. Version bump and CHANGELOG execution

Only Blake-Lite in `execute` mode may make handoff-listed version/CHANGELOG edits. Derive affected
tracked files with a fixed-string search for `OLD`, update only the approved set, and run the version
and version-sweep gates again. Do not rely on a remembered file count. Stage explicit paths only.

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
