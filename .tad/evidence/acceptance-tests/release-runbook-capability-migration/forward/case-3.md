Read-only planning is complete. Source TAD is `2.40.0`; 12 registered projects are reachable and outdated, while 2 must be skipped because their registered paths are missing. No project, registry, Git, or task-state writes were performed. I read only the requested [entry skill](</Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/release-runbook/SKILL.md>) and its routed [sync reference](</Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/release-runbook/references/sync-ops.md>).

## Proposed scope

All targets use platform `both`. Registry metadata says every entry was last synced to `2.30.0` on `2026-06-11`.

| Targets | Current → planned | Strategy |
|---|---:|---|
| menu-snap, OpenClaw Hack, 合规ai, ArtForge, 下载md插件, 买卖, Monica-website | 2.30.0 → 2.40.0 | overwrite |
| toy, 内存管理 | 2.30.0 → 2.40.0 | merge; marker present |
| my-openclaw-agents | 2.32.0 → 2.40.0 | merge; marker present |
| Next Guest | 2.33.0 → 2.40.0 | overwrite |
| Sober Creator | 2.38.0 → 2.40.0 | overwrite |

Required planning skips:

- `运动打卡小助手`: registered path is missing; current version is unreadable.
- `Colin声音项目`: registered path is missing; current version is unreadable.

These remain unchanged in the registry. Importantly, migration must use each target’s actual current version—not stale `last_synced_version`.

## Execution plan—not run

1. Establish executable task state.

   Alex-Lite must pin plan mode/source `2.40.0`, the 12-target scope, skill snapshot, exact copy command, and recovery rules in the sole LITE task state. This independent session deliberately did not read or create that state.

2. Resolve the source-state blocker.

   `main` is three commits ahead of `origin/main`, and the working tree has numerous tracked/untracked changes, including changes inside the managed skill trees. Before execution, the handoff must pin the exact intended source snapshot and explicitly classify any dirty Managed Write Surface content. Unrelated dirty content may not leak into targets.

3. Revalidate immediately before each target approval.

   Confirm canonical path, `.tad/version.txt`, platform/strategy, merge marker where applicable, source version, and current target version. Capture each target’s own pre-state, including hashes/manifests for the derived Managed Write Surface and all zero-touch directories.

4. Process targets sequentially in registry order.

   Use `derive-sync-set.sh` dynamically. The observed authority is:

   - 23 framework-sync directories.
   - Exactly one top-level deny record: `sync-registry.yaml`.
   - 12 zero-touch directories.
   - Registry-only path: `capability-packs/pack-registry.yaml`.

   Copy both authoritative skill trees, exclude `sync-registry.yaml`, preserve zero-touch data, back up entry documents, merge only declared TAD-owned settings keys, and never run capability-pack `install.sh` or `tad.sh`.

5. Require one target-specific human approval per target.

   Each approval digest must bind the canonical target, old/new versions, exact write command, and derived path set. Consume it atomically immediately before launch. Missing/mismatched/replayed approval or failed atomic claim is a hard stop.

6. Run migration exactly once after copying.

   Planned command, not executed:

   ```bash
   bash "$repo_root/.tad/hooks/lib/migration-engine.sh" \
     --from "$old_version" --to "$current_version" \
     --target "$target" --source "$repo_root"
   ```

7. Verify every modified target before continuing.

   Planned commands, not executed:

   ```bash
   bash "$repo_root/.tad/hooks/lib/release-verify.sh" structural "$repo_root" "$target"
   bash "$repo_root/.tad/hooks/lib/release-verify.sh" platform-skills "$repo_root" "$target"
   ```

   Continue only when both exit `0`.

8. Advance the registry separately.

   After successful verification, obtain a separate source-registry approval for the exact verified target set. Re-read and structurally update only those entries. Missing, skipped, partial, failed, or unknown targets remain unchanged.

   Downstream commit and push are out of scope. If later requested, they require two additional independent approvals.

## Failure recovery

- Validation fails before approval: mark `skipped`/`not-started`; consume no approval.
- Migration exits `1` or `2`: classify `partial`, preserve `.tad-backup`, stop the entire batch, and prohibit deprecation, registry advancement, commit, and push.
- Either verifier exits `1`: target is unverified; compare against its own pre-state and stop the batch.
- Either verifier exits `2`: wiring/usage hard-block; stop without healing.
- Timeout, disconnect, truncated output, or unknown exit after launch: never retry. Compare target state with its recorded pre-state and classify:
  - `completed`: exact planned state landed and both gates pass.
  - `not-started`: observed unchanged; retry only with a new approval ID/digest.
  - `partial` or `unknown`: return to Alex-Lite for replanning.
- The original approval always remains consumed. Claims are never removed or reused.
- Registry-update ambiguity receives the same consume-once reconciliation; do not bulk-update or blindly retry.

## Read-only evidence

The exact source guard from the skill was run and returned exit `0` with no stdout:

```bash
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
repo_root=$(cd "$repo_root" && pwd -P) || exit 1
cwd_physical=$(pwd -P) || exit 1
test "$cwd_physical" = "$repo_root" || exit 1
origin=$(git -C "$repo_root" remote get-url origin 2>/dev/null) || exit 1
case "$origin" in
  https://github.com/Sheldon-92/TAD|https://github.com/Sheldon-92/TAD.git|git@github.com:Sheldon-92/TAD.git|ssh://git@github.com:Sheldon-92/TAD.git) ;;
  *) exit 1 ;;
esac
```

Observed identity:

- Physical root: `/Users/sheldonzhao/01-on progress programs/TAD`
- Physical cwd: same
- Origin: `https://github.com/Sheldon-92/TAD.git`

The four required derivations were run exactly as read-only commands:

```bash
bash .tad/hooks/lib/derive-sync-set.sh --dirs "/Users/sheldonzhao/01-on progress programs/TAD"
bash .tad/hooks/lib/derive-sync-set.sh --report "/Users/sheldonzhao/01-on progress programs/TAD"
bash .tad/hooks/lib/derive-sync-set.sh --zero-touch "/Users/sheldonzhao/01-on progress programs/TAD"
bash .tad/hooks/lib/derive-sync-set.sh --registry-only "/Users/sheldonzhao/01-on progress programs/TAD"
```

All exited `0`; the report contained exactly one `(+ top-level file: sync-registry.yaml)` record.

Git state was inspected with:

```bash
git -C "/Users/sheldonzhao/01-on progress programs/TAD" status --short
git -C "/Users/sheldonzhao/01-on progress programs/TAD" status --branch --short
git -C "/Users/sheldonzhao/01-on progress programs/TAD" rev-list --left-right --count HEAD...@{upstream}
```

Observed: dirty working tree, `main...origin/main [ahead 3]`, and divergence `3 0`. No listed file contents were opened.