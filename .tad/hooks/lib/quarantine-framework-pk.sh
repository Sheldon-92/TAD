#!/usr/bin/env bash
# quarantine-framework-pk.sh — Opt-in quarantine for legacy framework
# project-knowledge pollution in downstream repositories.
#
# Invoked ONLY via `tad.sh --quarantine-pk` (explicit opt-in; NEVER automatic
# on install/upgrade/migrate/update). Moves byte-identical upstream framework
# files out of the target's `.tad/project-knowledge/` into a timestamped
# archive dir, preserving locally modified files and the sanctioned README.md.
#
# Usage: quarantine-framework-pk.sh [target-root=.]
#   target-root defaults to the current directory (the downstream repo root).
#
# Guarantees:
#   - Scope is strictly <target>/.tad/project-knowledge/.
#   - NEVER moves or modifies .tad/project-knowledge/README.md (P0-3).
#   - Idempotent: 0 matches → prints "0 files quarantined", creates NO
#     archive directory, exits 0.
#   - MANIFEST.md records every action (| Original File | Sha256 | Action |
#     Reason | Timestamp |).
#   - Portable sha256 (sha256sum or shasum -a 256); bash 3.2+ safe
#     (no associative arrays, no |&).
set -euo pipefail

TARGET="${1:-$PWD}"
PK_DIR="$TARGET/.tad/project-knowledge"
ARCHIVE_BASE="$TARGET/.tad/archive"

hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# Inlined reference manifest: known upstream TAD framework project-knowledge
# files (canonical sha256 at v2.45.0 dev). A target file whose hash equals one
# of these rows is an unmodified framework copy ("fake richness") and is
# quarantined. A locally modified file (hash mismatch) is preserved.
# Format per row: "<sha256><two spaces><relative path under project-knowledge/>".
upstream_manifest() {
    cat << 'MANIFEST_EOF'
4c651752a633fb6101dac25114ef4fb785c0ddd1e320567f6b5269a654b7e651  architecture.md
cd7126c66f08e8df43f92bbfbfcfdc1b97defbb71512abf77cfa4c7c84777aa0  code-quality.md
e74d8940dd0096ebdce7fec92a1d58f48be130264e064f5aa5e7b771e8f9a1c8  frontend-design.md
7be0f276bc851efa941fb30d8ccbebbc2b9647fdcd81be05f717ea5ebac0402e  incidents/2026-05/ac-grep-count-reference-pack.md
cca28128023b4ca7cf0608810838231e33baa9d5c90e5092ba86ab07e226074a  incidents/2026-05/ac-verification-command-bug.md
f2b7b5d704305a7c208ba3a75737ab9a6a3b55f442f2fd753f91fc863a6eaf44  incidents/2026-05/academic-research-pack-pilot.md
78f29290a65439abffe4026b65c2f4385576a3da106d026db162b8577563a2a2  incidents/2026-05/ad-hoc-dead-code-audit.md
c922701084f2ee30aa5e8867cdfd94aecde5c4cf7306490a2f74180d8d9a968a  incidents/2026-05/chattts-consistency-pattern.md
3236ac231be09d485e1f4b4c651865a2bb3ea3873992efa110859f02fe5a228a  incidents/2026-05/claude-md-routing-label-conflicts.md
2c3dd815552f89bee7547cff02e4249ba341bc91882eb63f33e8de25e8b28131  incidents/2026-05/codex-agents-md-auto-load.md
89828a063a0cef9d331f04332f05c5f8ab3073654df45c2ea5d8400a3f080435  incidents/2026-05/expert-reviewer-premise-check.md
dc35b1fa73b1c5f88d3e43568016e10a9f704a474283c41af86bfe636274a01d  incidents/2026-05/gemini-cli-constraints.md
874f3bd8f190693db9794c1381dc5615a6c0d09451b6966aeccda5f6d7e79f55  incidents/2026-05/layer2-audit-reviewer-name-drift.md
4281078b5eb107338883b0ad48d5bb3c2fe53894dbdf31820329c1a6459228b1  incidents/2026-05/line-anchored-blockquote-sed.md
6cb341fb22f630e62af88bc0b468a70ced7fce31ddf257498afc7736bcddec15  incidents/2026-05/pack-collision-detection.md
3ab3f9d8b47c2c3a06a7a9891301257fdee3997db5e06eef358d37a8f16cce6e  incidents/2026-05/parser-self-trigger.md
f83ae2240bef0f28e1ffeaa05fb5c1a405900ef72809b5994a97ba9126557e89  incidents/2026-05/progressive-disclosure-extract.md
b63ac69645037afbbbce5605cfa3cdf450923ae75988884fb7c84b52aee3f983  incidents/2026-05/scienceclaw-skill-decoupling.md
b33d92df8f21fcd58821c4eefec0cd2d4e7ba4203c3b7c9751b10bd59be11360  incidents/2026-05/scoring-rubrics-need-methodology-review.md
0e336f923699192d41051de341791167ba0566c7ec7ac2e9c75ffb5ce72785d3  incidents/2026-05/section-9-1-region-marker.md
f7a07ca44c0b747fceea35593f5b0b558fcf41eb218d0b418cbfca246a7dff3b  incidents/2026-06/alex-role-decay-direct-execution.md
92769c5d5b9d5f3cd98362d70061d04c99bed3f5f284e8e16e7ec279faa94e0d  incidents/2026-06/anchorless-tad-sed.md
826e48d8130817f8a043ecbf08b30729e58efdcb3621912644abd8271299f9e6  incidents/2026-06/codex-edition-parity.md
03f0504a8193f79e035fc2b13f6f3fa9a21ea6b82bdd5943c8d3a7ae8899ab42  incidents/2026-06/cross-agent-parity-check.md
d95903b34f0f54e92277a63c20a4519c4f78722ef0ec381534634dff64675a69  incidents/2026-06/derived-copy-set-dotfiles.md
27a648b876199369203c42bd933c5fef57b74e2d54443d58a506daaf0c009742  incidents/2026-06/embedded-copy-drift-check.md
31b2565595c71a09c5b56b9af4a8735db39cee89c413f53338bc01e4689499f5  incidents/2026-06/pack-value-cross-vendor.md
a137ef29b8c54e0719e4d3b2375f71ecdabf75e7d8b364ff5fe70b6aa5ed31da  incidents/2026-06/pack-value-non-monotonic.md
58989f6d5595547ea07dc1d911a984a9be98762e56f6c47799147264525783df  incidents/_index.md
9494448473502b4f7a1c5b0be88abdd27994558943c963dd0026f8272f43995e  patterns/_index.md
514d26e11c6ce20e391cb5df0c86a0b588f08f74dce2687fc7087a36f20ba599  patterns/ac-verification.md
3be4f7e6daab7c17a2402a800b748e4308ccb7b994d1cc24c0d6cf897aaaaa62  patterns/capability-ownership.md
568298b7d42a01c2c1597ca92b5e90f07fd9e9408b0bcd2633c41830556ad3ba  patterns/gate-design.md
e6faf5d1a953193578d9e12c588234226c3c2e47b39fec89809a8b7fd17a8caf  patterns/handoff-design.md
e478b214d5f6dfbb09196494a912850d659048f099085c7abfdf4a1cd81db062  patterns/hook-contracts.md
81367c6bab05ec06f66f473a7e42339b5397e71fa2c739a3d7a0d6153547b087  patterns/memory-and-learning.md
7dd59df85685949adfab87beb4e5f5b4613414f98af91a4cc70c5c0eb24c3d08  patterns/pack-build-rules.md
9cd5c9777eaef89d446f219e006accbf72f9f64774abdb53e57712685e76d8f9  patterns/pack-evaluation.md
46cabc75ddcebf8f56be054759d72a2123b1aef9c2548bd2c62696be5d8679c2  patterns/release-sync.md
83c551c64291de10195e434b46cbd5331582cf57f937d7942effe6a8b77b7e8c  patterns/research-methodology.md
36dd2879482c35eaade6439be25c4e67ba84dbd7a1559814275e317ba2c2d6ee  patterns/shell-portability.md
35dee96cc39092701a67e8d0bdd0706bf886d3551029308d1813de35a5caa543  principles.md
c14b06f0daa7819666c7555db8cd61dd31066cb70e794f739d06f0fa5d946495  security.md
MANIFEST_EOF
}

main() {
    if [ ! -d "$PK_DIR" ]; then
        echo "quarantine: no .tad/project-knowledge/ under target: $TARGET" >&2
        echo "0 files quarantined"
        exit 0
    fi

    local ts dest_dir manifest count
    ts="$(date +%Y%m%d-%H%M%S)"
    dest_dir=""
    manifest=""
    count=0

    local f rel h
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        rel="${f#$PK_DIR/}"
        # P0-3: the sanctioned README.md seed is NEVER quarantined.
        [ "$rel" = "README.md" ] && continue
        h="$(hash_file "$f")"
        if upstream_manifest | grep -qF "$h"; then
            # Lazily create the archive dir ONLY on first quarantine
            # (idempotency: a clean tree creates NO empty archive dir).
            if [ -z "$dest_dir" ]; then
                dest_dir="$ARCHIVE_BASE/quarantine-framework-pk-$ts"
                mkdir -p "$dest_dir"
                manifest="$dest_dir/MANIFEST.md"
                # Append-mode header: a same-second re-run reuses the dir and
                # must NOT truncate the previous run's manifest rows.
                if [ ! -f "$manifest" ]; then
                    printf '# Quarantine Manifest (framework project-knowledge pollution)\n\nQuarantined: %s\nTarget: %s\n\n| Original File | Sha256 | Action | Reason | Timestamp |\n|---|---|---|---|---|\n' "$ts" "$TARGET" > "$manifest"
                fi
            fi
            mkdir -p "$dest_dir/$(dirname "$rel")"
            mv "$f" "$dest_dir/$rel"
            printf '| %s | %s | quarantined | byte-identical to upstream framework file | %s |\n' "$rel" "$h" "$ts" >> "$manifest"
            count=$((count + 1))
        else
            echo "User-modified knowledge preserved: $rel"
        fi
    done <<< "$(find "$PK_DIR" -type f 2>/dev/null | LC_ALL=C sort)"

    if [ "$count" -gt 0 ]; then
        echo "$count files quarantined → $dest_dir"
        # Post-quarantine rebuild of the local semantic index (soft, non-blocking).
        if [ -f "$TARGET/.tad/hooks/lib/brain-index-gen.sh" ]; then
            bash "$TARGET/.tad/hooks/lib/brain-index-gen.sh" >/dev/null 2>&1 || true
        fi
    else
        echo "0 files quarantined"
    fi
    exit 0
}

main "$@"
