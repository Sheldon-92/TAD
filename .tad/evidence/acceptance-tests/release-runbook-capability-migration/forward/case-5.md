Decision: the fixture is eligible for a proposed registration, using `merge`. The real registry was not modified.

Proposed entry:

```yaml
- path: "/path/to/TAD/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/fixture-project"
  name: "fixture-project"
  platform: "claude"
  claude_md_strategy: "merge"
  last_synced_version: "2.39.0"
  last_synced_date: "2026-08-09"
```

`platform: "claude"` is inferred because `CLAUDE.md` is readable while `AGENTS.md` is absent. The marker identifies line 4 onward as project-owned content to preserve:

```text
Project-owned content that must be preserved.
```

Read-only evidence:

- The runbook’s exact source-identity guard completed with exit code `0`:
  - root and physical working directory: `/path/to/TAD`
  - origin: `https://github.com/Sheldon-92/TAD.git`
- Physical-path resolution used:

```bash
fixture_parent=$(dirname "$fixture")
fixture_base=$(basename "$fixture")
fixture_physical=$(cd "$fixture_parent" && cd "$fixture_base" && pwd -P)
```

  Result: the physical path exactly matched the supplied absolute path.

- Version check:

```bash
sed -n '1p' "$fixture_physical/.tad/version.txt"
```

  Result: `2.39.0`.

- Marker check:

```bash
grep -cF '<!-- TAD:PROJECT-CONTENT-BELOW -->' "$fixture_physical/CLAUDE.md"
```

  Result: `1`.

- Existing-registration check:

```bash
grep -cF "$fixture_physical" "$repo_root/.tad/sync-registry.yaml"
```

  Result: `0`, so this exact path is not registered.

Registration would establish a baseline using the target’s current version; it would not mean that a sync occurred. Registry status remains `not-started`: no registry, target, commit, push, migration, or downstream write was performed.