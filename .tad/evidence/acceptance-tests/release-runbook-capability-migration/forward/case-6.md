Registry listing:

| Name | Absolute path | Platform | Strategy | Current version | Last-synced version | Status |
|---|---|---|---|---|---|---|
| fixture-project | `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/fixture-project` | both | merge | 2.39.0 | 2.38.0 | **Outdated but reachable** — target is behind source 2.40.0; registry metadata is also stale because current differs from last-synced |

Read-only commands executed:

```bash
sed -n '1,240p' '/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/fixture-registry.yaml'
```

Result: exit `0`; one project entry found with the values above.

```bash
target='/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/release-runbook-capability-migration/forward/fixture-project'; source='/Users/sheldonzhao/01-on progress programs/TAD'; if test -r "$target/.tad/version.txt"; then printf 'target_reachable=readable\ntarget_version='; tr -d '\n' < "$target/.tad/version.txt"; printf '\n'; else printf 'target_reachable=missing/unreadable\ntarget_version=missing/unreadable\n'; fi; if test -r "$source/.tad/version.txt"; then printf 'source_version='; tr -d '\n' < "$source/.tad/version.txt"; printf '\n'; else printf 'source_version=missing/unreadable\n'; fi
```

Observed: exit `0`; target readable, target version `2.39.0`, source version `2.40.0`. No writes or healing actions were performed.