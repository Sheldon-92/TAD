# Legacy Claude Code provenance ledger

Maintainer-side data for `tad.sh --platform claude-code`. It is read from the
installer source tree only (`$TAD_SRC/.tad/provenance/`); it is not copied into
downstream projects (`provenance` is in `TAD_TRANSIENT`) but it ships in the npm
package (`package.json` `files`).

## Files
- `claude-legacy.tsv`  one row per file TAD ever shipped to the Claude Code surfaces
- `MANIFEST.sha1`      one line: the git blob id of `claude-legacy.tsv`

## Format
First line `# schema=1 rows=<n>` (no commit hash, so regenerating gives the same bytes),
then `kind<TAB>id<TAB>key` rows, `LC_ALL=C sort -u`. `id` is a git blob id unless noted.
Input: every commit reachable from HEAD or a `v*` tag (so it also holds unreleased blobs).
- `skill`        key `<skill>/<path inside the skill>`  (.claude/skills and .agents/skills history)
- `flat`         key `<file name>`  (file directly under .claude/skills)
- `settings`     `.claude/settings.json` and the hook template, key `-`. Two rows are pinned as literals in the generator (`settings` `2cdede5e…` and its `settings-ws` `d94c5a36…`): the Phase 2 relative-path hook template (commit `af97b99a`), which was never in a tag. Literal, so a squash merge or a clone without that commit cannot drop them.
- `settings-ws`  plain SHA-1 of a settings blob with space, TAB, CR, LF removed, key `-`
- `md-whole`     CLAUDE.md blobs without the marker line, key `-`
- `md-head`      plain SHA-1 of the CLAUDE.md head up to and including the marker line, key `-`
- `workflow`, `cmd`  key `<file name>` under .claude/workflows, .claude/commands

## Regenerate
`bash .tad/scripts/gen-claude-provenance.sh` (TAD repo, needs git and all 78+ `v*` tags).
Release gate: `bash .tad/hooks/lib/release-verify.sh provenance .`
Regenerate after any commit that adds a new blob under `.claude/`, `.agents/skills/`,
`CLAUDE.md` or `.tad/templates/claude/settings.json`; the gate fails until you do.
Order when the hook template changes: edit it, commit it (alone, with `git commit --only -- .tad/templates/claude/settings.json`), then regenerate; the generator reads git history, never the working tree.
`MANIFEST.sha1` only guards against accidental damage (truncation, sync conflicts,
hand edits). It does not stop someone who can edit the installer source.
