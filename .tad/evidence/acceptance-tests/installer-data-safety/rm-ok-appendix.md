# Appendix — RM-OK Marker Adjudication (AC2.5)

**Scope**: every destructive-verb site in `tad.sh` @ HEAD (26 marked + 3 prose-excluded).
**Method**: `grep -nE -e 'rm -rf|rm -fr|rm -f|rmdir|-delete tad.sh`, each hit classified.
**Generated**: 2026-09-03. Guard: `release-verify.sh installer-destructive-guard` (same-line binding, per-site markers, unique ids, baked-literal exclusions, mutation-probed by fixture `case_ac25`).
**Allowlist note (reviewer finding #3)**: no separate machine allowlist file — THIS appendix is the allowlist, reviewed at Gate 3. Any id not listed here, any duplicate, any unmarked site → guard FAIL.

## Marked sites (26, all unique — verified `sort | uniq -d` empty)

| id | line | site | justification |
|---|---|---|---|
| source-chokepoint-downloaded-only | 122 | `rm -rf $TAD_SRC` in `cleanup_source_tree` | SOLE rm-site allowed to name `TAD_SRC` (AC-asserted); fires only when `TAD_SRC_DOWNLOADED=1` + non-empty + is-dir. User `--source` trees (`=0`) never removed — FR-1b pinned by AC2.1 regression test |
| pinned-tmp-discard | 140 | `rm -rf $_d` in `discard_tmp_root` | non-empty + is-dir + `basename` must match `tad-update.*` (mktemp template); caller passes download roots only |
| installer-tmp-root | 151 | `rm -rf $_t` in `cleanup_installer_temp` | same triple guard; `_t` set ONLY by download paths from mktemp, never user input (comment-pinned) |
| fork-sed-bak / unfork-sed-bak | 830 / 855 | `rm -f $meta_file.bak` after `sed -i.bak` | removes a `.bak` THIS command just created next to the file it edited; fixed suffix, same statement |
| deprecation-backup-copy-purge | 1709 | `find $backup_base/$target -depth -delete` | purges a backup-tree copy under the run-owned backup base (deprecation path); `-depth -delete`, failure-tolerant `|| true` |
| rollback-snap-consumed | 1854 | `rm -rf $_s` for `tad-rollback.*` | consumes a snapshot THIS run created (basename-pinned `tad-rollback.*`); verified consumed-then-removed |
| rollback-stage-preclean | 1877 | `rm -rf $_stage` (`$dst.rollback-staging`) | staging dir owned by `restore_dir_entry`; pre-clean before copy-back |
| rollback-dst-clear | 1880 | `rm -rf $_dst` inside `restore_dir_entry` | fires ONLY after `cp -R snap → stage` + `diff -rq` verified identical (copy-back+verify before remove = atomicity rule); `_dst` ∈ snapshot-surface list |
| rollback-stage-abort | 1888 | `rm -rf $_stage` on failure path | removes own staging dir when restore aborts; run-owned by construction |
| rollback-backup-consumed | 1932 | `rm -rf $BACKUP_PATH_ABS` | absolutized backup path, consumed after successful restore; absolute + non-empty + under-root asserted upstream |
| rollback-fresh-tad-created | 1941 | `rm -rf $TARGET_ROOT/.tad` | fresh-install branch ONLY (`BACKUP_PATH_ABS` empty + dir exists = entirely run-created); absolute root + `/`-refusal upstream |
| rollback-merge-backup | 1992 | `rm -f $TARGET_ROOT/$MERGE_CREATED_BACKUP` | removes the timestamped merge backup THIS run created (tracked var, non-empty) |
| rollback-created-top | 2001 | `rm -rf $TARGET_ROOT/$_c` for `ROLLBACK_CREATED_TOP` entries | `_c` filtered (`/*\|*..*` skip); list contains ONLY paths recorded as created-this-run |
| rollback-fresh-top-dirs | 2016 | `rm -rf $TARGET_ROOT/$_td` for `.claude/.agents/.codex/.opencode` | fires ONLY for dirs absent pre-run (`ROLLBACK_PRE_TOP` exemption); user content in pre-existing dirs never swept |
| rollback-rmdir-skills / -agents-skills / -workflows | 2025–2027 | `rmdir` (empty-only) on skills/workflows dirs | `rmdir` removes ONLY empty dirs; `|| true` tolerant; post-restore tidy |
| rollback-opencode-created | 2405 | `rm -f $_t/.opencode/commands/tad-update.md` | removes exactly the one file this run created (FR-4 rollback) |
| rollback-opencode-rmdir-commands / -root | 2406–2407 | `rmdir` on `.opencode/commands`, `.opencode` | empty-only tidy of run-created parents; `|| true` |
| merge-tmp-abort / -tail / -mv | 2159/2162/2164 | `rm -f $tmpfile` on merge failure branches | removes own `mktemp` file on abort paths; fixed var, same function |
| rollback-file-stage-preclean / -abort | restore_file_entry | `rm -f $_stage` (`$dst.rollback-staging`) pre-clean + abort path | staging file owned by the file-restore fn; sibling of the dir-restore pair; abort path failure-tolerant |

## Prose exclusions (3, comment-only + baked literal — no live call can match)

| line | baked literal | note |
|---|---|---|
| 1703 | `so the AC that forbids` | design comment on `-depth -delete` choice |
| 2023 | `rmdir removes ONLY empty dirs` | design comment on empty-shell tidy |
| 2402 | `Empty-dir rmdirs keep` | design comment on `\|\| true` retention |

Mutation probe (fixture `case_ac25`): inserts an unmarked `rm -rf` AND an exclusion-masked live call into a sandbox copy → guard FAILs both (rc=1, green evidence). No exclusion covers a real call.

## Reviewer-finding adjudications (narrow re-review 2026-09-03)

- **#1 inline probe**: probe lives in the fixture (green, incl. exclusion-masked live call), cross-referenced by guard comment; guard stays side-effect-free. Closed, no code change.
- **#2 `rm` variants**: tree contains zero `rm -fr`/`\rm`/`command rm` (grep-verified); candidate pattern extended with `rm -fr` anyway (behavior-neutral today, future-proof). Closed.
- **#3 id allowlist**: THIS appendix is the allowlist (26 ids, uniqueness machine-checked). A second machine file would be a second source of truth. Closed by documentation.
- **#4 string literals**: zero `echo "rm -rf"` / marker-in-string lines exist (grep-verified); any future one false-POSITIVES (fail-closed, safe). `echo "# RM-OK:x"; rm -rf` abuse absent. Closed by verification.
- **#5 hardlink `link to`**: FIXED in `validate_tar_members` (identical escaping rules as `->`); proven by `evil-hardlink` (reject) + `ok-hardlink` (pass) probes in `case_ac210` (14/14 green).
- **#6 unchecked second listing**: FIXED (captured once into `$vlisting` with `|| return 1` + empty-refusal).
- **#7 tv-parse fragility**: fail-closed analysis documented in code comment (worst parse → relative target passes while member-name loop still rejects absolute/dot-dot; newline-split fragments reject). Python rewrite deferred with rationale (installer must stay baseline-shell; python3 not guaranteed on targets). P2, accepted residual.

## Fix-round adjudications (full-track review 2026-09-03 → all integrated)

- **P0-1/P0-2/P0-3 rollback granularity+atomicity**: FIXED via manifest-recorded exact-granularity restore + `restore_file_entry` staging + `.tad` step-1 ownership. Red-proven on pre-fix tree (`red-fixround-p0-rollback.log`: sibling wipe drift + truncation loss), green after (`green-ac2.8-fixround.log` 9/9, incl. planted `.codex/config.toml`, `.codex/prompts/mine.md`, `.claude/commands/my-cmd.md`, `.tad/project-knowledge/README.md`).
- **P1-1 disjointness messages**: swapped to truthful strings. Closed.
- **P1-2 glob injection**: `_literal_has_prefix` (sed-escaped, byte-literal; awk rejected for CJK) used by disjointness + `assert_under_root` + `cleanup_source_tree`. Closed.
- **P1-3 version.txt sentinel**: required fail-closed in `resolve_source_mode`. Closed.
- **P1-4 BACKUP guards**: non-empty + is-dir + `/`-refusal + under-root containment, with loud REFUSED branch (never silent skip). Closed.
- **P1-5 defense in depth**: `assert_under_root` on restore entry points + `_c` sweep (added `""|.|/` rejects) + fresh-top sweep; `cleanup_source_tree` additionally requires mktemp-root basename + literal containment. Closed.
- **P1-6 masked mutation**: second probe in `case_ac25` (green). Closed.
- **P1-7 parent sentinel**: mktemp-unique + `guarded_cleanup` (extended to plain files, symlink-refusing). Closed.
- **P1-8 extract hardening**: tail-is-`}` + body-token assertions in `extract_fn` (this very round caught a real harness bug class with it — the (b)-block wrong-filename incident was found by reading, fixed, and is now guarded structurally). Closed.
- **P1-9 `.tad-backup` enumeration**: listed in kept-message. Closed.
- **P1-10 locale+cp**: `LC_ALL=C` on case-fold `tr`; checked `cp` for merge backup (`|| return 1`). Closed.

## N5 / N6 / N3-carry decisions (spec review P1-1)

- **N5 (`->` link-target predicate)**: PINNED — member loop rejects absolute/dot-dot names; `->` and `link to` targets reject absolute/dot-dot escapes; benign relative links pass (escaping-only, proven 14/14). Residual: adversarial filenames fail closed (P2, accepted).
- **N6 (sentinel allowlist)**: `.tad/tests/fixtures/` contains EXACTLY the 2 adversarial YAMLs (`fixtures-allowlist.sha256`); staged runtime sentinels are `CLAUDE.md`, `AGENTS.md`-class user files + `.root-sentinel` (in-target) + mktemp parent sentinel (outside-target, unique per run — enumerable by pattern `/tmp/tad-ac-parent.*`, not by fixed name, by design against parallel races).
- **N3-carry (AC2.6b)**: PROVEN — `green-ac2.6-full.log` 10/10 (2.6a inert + 2.6b user-untouched + stale-templates-removed). The earlier "10/10" citation pointed at a truncated sweep log; canonical logs are now per-case files (see evidence index).
