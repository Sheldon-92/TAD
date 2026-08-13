#!/usr/bin/env bash
# find-action-sha.sh — resolve a GitHub Action tag to its pinnable 40-char commit SHA,
# and (with --attest) verify an artifact's SLSA build provenance.
#
# SHA-pinning (CI2) is only safe if the SHA is RE-RESOLVED for the version you actually
# want — tags get mutated (CVE-2025-30066) and SHAs in docs rot. This wraps the resolve +
# attestation-verify recipes so they ship as an executable verifier, not just prose.
#
# Usage:
#   scripts/find-action-sha.sh <owner/repo> <tag>      # e.g. actions/checkout v4.1.7
#   scripts/find-action-sha.sh --attest <artifact> <owner/repo>
#
# Resolve mode output: the dereferenced commit SHA (annotated tags resolved to the commit,
# preferring the ^{} peeled ref) — paste it as `uses: <owner/repo>@<sha>  # <tag>`.

set -euo pipefail

usage() {
  echo "Usage:" >&2
  echo "  $0 <owner/repo> <tag>                    resolve a tag to its 40-char commit SHA" >&2
  echo "  $0 --attest <artifact> <owner/repo>      verify SLSA build provenance via gh" >&2
  exit 2
}

[ $# -ge 1 ] || usage

if [ "$1" = "--attest" ]; then
  # ---- attestation-verify helper (wraps `gh attestation verify`) ----
  [ $# -eq 3 ] || usage
  artifact="$2"
  repo="$3"
  if ! command -v gh >/dev/null 2>&1; then
    echo "[ERROR] 'gh' (GitHub CLI) not found — install it to verify attestations." >&2
    exit 3
  fi
  echo "[INFO] verifying provenance of '$artifact' against repo '$repo'..." >&2
  # Fails non-zero (and we propagate) if no valid attestation exists for the repo.
  gh attestation verify "$artifact" --repo "$repo"
  exit $?
fi

# ---- resolve mode ----
[ $# -eq 2 ] || usage
repo="$1"
tag="$2"

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] 'git' not found." >&2
  exit 3
fi

# Query the remote for the tag ref. Annotated tags expose a peeled ref "refs/tags/<tag>^{}"
# whose SHA is the underlying commit — that is the one to pin.
out="$(git ls-remote "https://github.com/${repo}" "refs/tags/${tag}" "refs/tags/${tag}^{}" 2>/dev/null || true)"

if [ -z "$out" ]; then
  echo "[ERROR] tag '$tag' not found in https://github.com/${repo} (typo? yanked release?)." >&2
  exit 4
fi

# Prefer the peeled (^{}) line if present (annotated tag -> commit); else the plain tag SHA.
peeled="$(printf '%s\n' "$out" | grep '\^{}$' | awk '{print $1}' | head -n1 || true)"
plain="$(printf '%s\n' "$out" | grep -v '\^{}$' | awk '{print $1}' | head -n1 || true)"
sha="${peeled:-$plain}"

if ! printf '%s' "$sha" | grep -qE '^[0-9a-f]{40}$'; then
  echo "[ERROR] could not resolve a 40-char SHA for '$repo@$tag' (got: '$sha')." >&2
  exit 5
fi

echo "$sha"
echo "uses: ${repo}@${sha}  # ${tag}" >&2
