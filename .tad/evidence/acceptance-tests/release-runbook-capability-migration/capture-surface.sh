#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
ROOT=$(cd "$ROOT" && pwd -P)
MODE=${1:-}
OUT_ROOT=${2:-}

if [[ "$MODE" != "pre" && "$MODE" != "post" ]]; then
  echo "Usage: capture-surface.sh <pre|post> <output-dir>" >&2
  exit 2
fi
if [[ -z "$OUT_ROOT" ]]; then
  echo "ERROR: output directory required" >&2
  exit 2
fi

mkdir -p "$OUT_ROOT/source" "$OUT_ROOT/targets"

hash_file() {
  shasum -a 256 "$1" | awk '{print $1}'
}

capture_source() {
  git -C "$ROOT" rev-parse HEAD > "$OUT_ROOT/source/head.txt"
  git -C "$ROOT" status --porcelain=v1 -z > "$OUT_ROOT/source/status.z"
  git -C "$ROOT" show-ref --head > "$OUT_ROOT/source/refs.txt"
  git -C "$ROOT" ls-remote --heads --tags origin > "$OUT_ROOT/source/remote-refs.txt"
  hash_file "$ROOT/.tad/sync-registry.yaml" > "$OUT_ROOT/source/sync-registry.sha256"
  hash_file "$ROOT/.tad/deprecation.yaml" > "$OUT_ROOT/source/deprecation.sha256"
  for rel in \
    .claude/skills/alex/references/publish-protocol.md \
    .claude/skills/alex/references/sync-protocol.md \
    .claude/skills/alex/references/sync-add-protocol.md \
    .claude/skills/alex/references/sync-list-protocol.md; do
    printf '%s\t%s\n' "$rel" "$(hash_file "$ROOT/$rel")"
  done > "$OUT_ROOT/source/carrier-hashes.tsv"
  local label option rc
  for label in derived-dirs derive-report zero-touch registry-only; do
    case "$label" in
      derived-dirs) option=--dirs ;;
      derive-report) option=--report ;;
      zero-touch) option=--zero-touch ;;
      registry-only) option=--registry-only ;;
    esac
    set +e
    bash "$ROOT/.tad/hooks/lib/derive-sync-set.sh" "$option" "$ROOT" \
      > "$OUT_ROOT/source/$label.txt" 2> "$OUT_ROOT/source/$label.stderr"
    rc=$?
    set -e
    printf '%s\n' "$rc" > "$OUT_ROOT/source/$label.exit"
    if [[ "$rc" -ne 0 ]]; then
      echo "BLOCKED: derive-sync-set $option exit=$rc" >&2
      return "$rc"
    fi
  done
}

emit_entry() {
  local target=$1 rel=$2 class=$3 manifest=$4 expansion=$5
  local abs="$target/$rel"
  ruby -rfind -rdigest -e '
    target, rel, klass, manifest, expansion = ARGV
    abs = File.join(target, rel)
    File.open(expansion, "a") do |x|
      if File.symlink?(abs)
        x.puts [klass, rel, "present-symlink"].join("\t")
        File.open(manifest, "a") { |m| m.puts [klass, rel, "symlink", File.readlink(abs)].join("\t") }
      elsif File.file?(abs)
        x.puts [klass, rel, "present-file"].join("\t")
        File.open(manifest, "a") { |m| m.puts [klass, rel, "file", Digest::SHA256.file(abs).hexdigest].join("\t") }
      elsif File.directory?(abs)
        x.puts [klass, rel, "present-dir"].join("\t")
        File.open(manifest, "a") do |m|
          Find.find(abs) do |child|
            next if child == abs
            child_rel = child.sub(%r{\A#{Regexp.escape(target)}/?}, "")
            if File.symlink?(child)
              m.puts [klass, child_rel, "symlink", File.readlink(child)].join("\t")
              Find.prune if File.directory?(child)
            elsif File.file?(child)
              m.puts [klass, child_rel, "file", Digest::SHA256.file(child).hexdigest].join("\t")
            elsif File.directory?(child)
              m.puts [klass, child_rel, "dir", "-"].join("\t")
            end
          end
        end
      else
        x.puts [klass, rel, "absent"].join("\t")
      end
    end
  ' "$target" "$rel" "$class" "$manifest" "$expansion"
}

capture_target() {
  local idx=$1 name=$2 target=$3
  local safe_idx
  safe_idx=$(printf '%02d' "$idx")
  local target_out="$OUT_ROOT/targets/$safe_idx"
  mkdir -p "$target_out"
  if [[ "$MODE" == "pre" && -f "$target_out/capture-complete.txt" ]]; then
    return 0
  fi
  printf '%s\n' "$name" > "$target_out/name.txt"
  printf '%s\n' "$target" > "$target_out/path.txt"

  if [[ ! -e "$target" ]]; then
    printf 'missing\n' > "$target_out/reachability.txt"
    return 0
  fi
  if [[ ! -r "$target" || ! -x "$target" ]]; then
    printf 'unreadable\n' > "$target_out/reachability.txt"
    echo "BLOCKED: registered target unreadable: $target" >&2
    return 3
  fi
  printf 'reachable\n' > "$target_out/reachability.txt"
  local physical
  physical=$(cd "$target" && pwd -P)
  printf '%s\n' "$physical" > "$target_out/canonical-path.txt"
  if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    set +e
    git -C "$target" status --porcelain=v1 -z > "$target_out/git-status.z" 2> "$target_out/git-status.stderr"
    printf '%s\n' "$?" > "$target_out/git-status.exit"
    git -C "$target" show-ref --head > "$target_out/git-refs.txt" 2> "$target_out/git-refs.stderr"
    printf '%s\n' "$?" > "$target_out/git-refs.exit"
    set -e
  else
    : > "$target_out/git-status.z"
    : > "$target_out/git-refs.txt"
    : > "$target_out/git-status.stderr"
    : > "$target_out/git-refs.stderr"
    printf 'not-a-git-repo\n' > "$target_out/git-status.exit"
    printf 'not-a-git-repo\n' > "$target_out/git-refs.exit"
  fi

  local manifest="$target_out/managed-manifest.tsv"
  local expansion="$target_out/expanded-path-classes.tsv"
  : > "$manifest"
  : > "$expansion"

  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    [[ "$(basename "$rel")" == "$TOP_DENY" ]] && continue
    emit_entry "$target" ".tad/$(basename "$rel")" "mws:tad-top-file" "$manifest" "$expansion"
  done < <(find "$ROOT/.tad" -maxdepth 1 -type f -print | LC_ALL=C sort)

  while IFS= read -r dir; do
    [[ -n "$dir" ]] || continue
    [[ "$dir" == "capability-packs" ]] && continue
    emit_entry "$target" ".tad/$dir" "mws:derived-dir" "$manifest" "$expansion"
  done < "$OUT_ROOT/source/derived-dirs.txt"

  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    emit_entry "$target" ".tad/$rel" "mws:registry-only" "$manifest" "$expansion"
  done < "$OUT_ROOT/source/registry-only.txt"

  for rel in \
    .claude/skills .agents/skills .claude/settings.json .claude/workflows \
    .codex/hooks.json CLAUDE.md AGENTS.md CLAUDE.md.bak AGENTS.md.bak tad.sh \
    README.md INSTALLATION_GUIDE.md CHANGELOG.md docs/MULTI-PLATFORM.md .tad-backup; do
    emit_entry "$target" "$rel" "mws:explicit" "$manifest" "$expansion"
  done

  while IFS= read -r dir; do
    [[ -n "$dir" ]] || continue
    emit_entry "$target" ".tad/$dir" "zero-touch" "$manifest" "$expansion"
  done < "$OUT_ROOT/source/zero-touch.txt"

  LC_ALL=C sort -u "$manifest" -o "$manifest"
  LC_ALL=C sort -u "$expansion" -o "$expansion"
  printf 'complete\n' > "$target_out/capture-complete.txt"
}

capture_source
top_deny_count=$(grep -cE '^  \(\+ top-level file: [^)]+\)$' "$OUT_ROOT/source/derive-report.txt")
if [[ "$top_deny_count" -ne 1 ]]; then
  echo "BLOCKED: expected exactly one TOP_DENY, observed $top_deny_count" >&2
  exit 3
fi
TOP_DENY=$(sed -nE 's/^  \(\+ top-level file: ([^)]+)\)$/\1/p' "$OUT_ROOT/source/derive-report.txt")
printf '%s\n' "$TOP_DENY" > "$OUT_ROOT/source/top-deny.txt"
idx=0
batch_count=0
pids=()
while IFS=$'\t' read -r name target; do
  idx=$((idx + 1))
  capture_target "$idx" "$name" "$target" &
  pids+=("$!")
  batch_count=$((batch_count + 1))
  if [[ "$batch_count" -eq 4 ]]; then
    for pid in "${pids[@]}"; do wait "$pid"; done
    pids=()
    batch_count=0
  fi
done < <(yq -r '.projects[] | [.name, .path] | @tsv' "$ROOT/.tad/sync-registry.yaml")
for pid in "${pids[@]}"; do wait "$pid"; done

printf 'CAPTURE: %s PASS targets=%d\n' "$MODE" "$idx"
