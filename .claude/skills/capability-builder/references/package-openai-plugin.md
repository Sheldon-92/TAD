# Capability Builder — Package OpenAI Plugin Protocol (Phase 3)

This reference is **mandatory** when `$capability-builder package` is selected. Read via the non-circular load in `SKILL.md`.

## 1. Entry Conditions

`package` starts from a validated, behavior-proven, projected Skill (`example-skill` for this handoff; Plugin `example-skill`; no MCP/App unless explicitly requested with real project files).

## 2. Commands (`capability-plugin.sh`)

```
capability-plugin.sh validate <root> <skill> <plugin-dir>
capability-plugin.sh package  <root> <skill> <plugin-dir>
capability-plugin.sh verify   <root> <skill> <plugin-dir>
```

Exit classes mirror `capability-skill.sh`: 0 success, 1 usage, 2 invalid path/validation, 3 divergent/lock, 4 I/O. No writes on non-zero except lock cleanup.

## 3. Containment Contract (mandatory; plugin-dir is caller-selected but constrained)

- Physical root resolution (`cd && pwd -P`).
- `plugin-dir` must resolve INSIDE project root (slash-terminated `case` prefix proof: `case "$resolved_child/" in "$resolved_root"/*) ;; *) reject ;; esac` — slash-terminated on BOTH sides plus equality via empty-`*`; `root.evil` sibling fails) AND inside `.tad/evidence/` sandbox for this handoff.
- Full symlink-chain rejection for canonical, template, and generated trees (path-chain components + `find -type l` inside trees).
- Traversal/absolute/slash rejection on skill name; per-entry normalized-name `^[a-z0-9]+(-[a-z0-9]+)*$`; frontmatter `name` vs dirname match.
- Forbidden root artifacts (`CAPABILITY.md`, `README.md`, `CHANGELOG.md`, `install.sh`) and placeholders (`{{...}}`/`[TODO]`/`[TBD]`) reused from skill contract.
- Lock serialization (per-plugin `mkdir` lock, ownership via device:inode, trap cleanup).

## 4. Scaffold / Validate / Install / Drift

- Only `<plugin>/skills/<name>/` generated from canonical (byte-identical, `diff -rq`); manifest/MCP/App are project-owned platform code, absent unless explicitly requested.
- Manifest: minimal `.codex-plugin/plugin.json` {name, version, skills:[name]} from `.tad/templates/openai-plugin/`; folder/name normalized, exactly one generated subtree.
- Validate manifest JSON (`python3` assert `skills==[name]`); `find <plugin>/skills -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort` exactly one line.
- Isolated install/discovery evidence under `.tad/evidence/acceptance-tests/capability-builder-package/`; forbidden roots explicit (`$HOME/.codex`, `$HOME/.config`, marketplaces) — proven by `test ! -e`, never by repo `git status`.
- Temp discipline: sibling `mktemp -d` next to target; `trap EXIT INT TERM HUP`; empty-var + parent-prefix guards; named helper `cleanup_plugin_tmp` separate from user-tree deletion (no shared `rm -rf`); digest shim `shasum -a 256` → `sha256sum` fallback.
- Failure atomicity: failed package leaves canonical + projection digest-identical (per-file `shasum` cmp before/after).
- Drift: `verify` byte-compares canonical vs generated; divergent refuses without mutation.

## 5. Evidence

Raw outputs + manifests + digests under `.tad/evidence/acceptance-tests/capability-builder-package/`; `LC_ALL=C`, `grep -F -e`, baseline tools only, no `for x in $VAR`, literal bound paths (`<FIXTURE_PROJ>`, `<PLUGIN>`, `<SANDBOX>`).

## 6. Out-of-Scope

MCP/App (absent → must stay absent), marketplace writes, multi-skill bundles, catalog/registry, TAD core/Gate/role/hook/installer edits.
