#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

extract_host() {
  local value="$1"
  local host
  host="$(printf '%s\n' "$value" |
    sed -nE 's#^[A-Za-z][A-Za-z0-9+.-]*://([^/@[:space:]]+@)?([^/?#[:space:]]+).*#\2#p')"
  if [ -n "$host" ]; then
    printf '%s\n' "$host"
  else
    printf '%s\n' "unknown"
  fi
}

extract_top_level_model_provider() {
  awk '
    BEGIN { section = "<top-level>" }
    /^[[:space:]]*\[/ { section = $0; next }
    section == "<top-level>" && /^[[:space:]]*model_provider[[:space:]]*=/ {
      sub(/^[^=]*=[[:space:]]*/, "")
      sub(/[[:space:]]+#.*$/, "")
      gsub(/^"/, "")
      gsub(/"$/, "")
      print
      exit
    }
  ' "$1"
}

extract_provider_base_url_line() {
  local config_file="$1"
  local provider_id="$2"
  awk -v wanted="[model_providers."$provider_id"]" '
    BEGIN { section = "<top-level>" }
    /^[[:space:]]*\[/ { section = $0; next }
    section == wanted && /^[[:space:]]*base_url[[:space:]]*=/ {
      print
      exit
    }
  ' "$config_file"
}

degraded_with_approval() {
  echo "DEGRADED_WITH_APPROVAL: codex CLI/config unavailable; handoff §6 branch 1 applies"
  echo "Official references (retrieved 2026-08-03):"
  echo "https://learn.chatgpt.com/docs/config-file/config-basic"
  echo "https://learn.chatgpt.com/docs/agent-configuration/subagents"
}

probe_published_codex_capture() {
  local probe_cfg="$1"
  local openai_lines
  CFG="$probe_cfg"

  openai_lines="$(env | grep -E '^OPENAI_BASE_URL=' || true)"
  if [ -n "$openai_lines" ]; then
    while IFS= read -r line; do
      value="$(printf '%s\n' "$line" | sed 's/^[^=]*=//')"
      printf 'OPENAI_BASE_URL host=%s\n' "$(extract_host "$value")"
    done <<EOF
$openai_lines
EOF
  else
    echo "OPENAI_BASE_URL unset (native/degraded)"
  fi

  if [ -f "$CFG/config.toml" ]; then
    grep -E '^(model|model_provider|model_reasoning_effort|default_subagent_model)[[:space:]]*=' \
      "$CFG/config.toml" 2>/dev/null || true
    grep -nE '^[[:space:]]*base_url[[:space:]]*=' "$CFG/config.toml" 2>/dev/null || true
  else
    echo "config.toml unavailable (native/degraded)"
  fi

  if [ -d "$CFG/agents" ]; then
    find "$CFG/agents" -type f -name '*.toml' -exec \
      grep -E '^(model|model_reasoning_effort)[[:space:]]*=' {} + 2>/dev/null || true
  else
    echo "agents directory unavailable (no per-agent overrides)"
  fi
}

probe_tmp="$(mktemp -d "/tmp/tad-model-vocab-ac9.XXXXXX")"
trap 'rm -rf "$probe_tmp"' EXIT

printf '[agents]\nmodel_provider = "nested-should-not-count"\n[projects."/tmp/x"]\nmodel_provider = "project-should-not-count"\n' \
  > "$probe_tmp/nested-only.toml"
nested_only_provider="$(extract_top_level_model_provider "$probe_tmp/nested-only.toml" || true)"
if [ -n "$nested_only_provider" ]; then
  echo "FAIL AC9: nested model_provider was accepted as top-level: $nested_only_provider"
  exit 1
fi
printf 'model_provider = "top-level-provider"\n[agents]\nmodel_provider = "nested-should-not-count"\n[projects."/tmp/x"]\nmodel_provider = "project-should-not-count"\n[model_providers.top-level-provider]\nbase_url = "https://provider.example.invalid/v1"\n' \
  > "$probe_tmp/mixed-sections.toml"
mixed_provider="$(extract_top_level_model_provider "$probe_tmp/mixed-sections.toml" || true)"
if [ "$mixed_provider" != "top-level-provider" ]; then
  echo "FAIL AC9: top-level model_provider ownership was not selected: '$mixed_provider'"
  exit 1
fi
mixed_base_url="$(extract_provider_base_url_line "$probe_tmp/mixed-sections.toml" "$mixed_provider" || true)"
if [ -z "$mixed_base_url" ]; then
  echo "FAIL AC9: selected provider base_url was not resolved from its exact section"
  exit 1
fi
echo "AC9 section-ownership fixture PASS: nested provider keys ignored; exact provider section resolved"

echo "== published codex capture fail-soft probe =="
(
  unset OPENAI_BASE_URL
  probe_published_codex_capture "$probe_tmp/missing"
)
mkdir -p "$probe_tmp/present"
printf 'model = "fixture-model"\n' > "$probe_tmp/present/config.toml"
(
  unset OPENAI_BASE_URL
  probe_published_codex_capture "$probe_tmp/present"
)
echo "AC9 fail-soft capture probe PASS: unset env, missing config, and no-agents directory are native/degraded without nonzero exit"

fixture_host="$(extract_host "https://review-user:SECRET_KEY@relay.example.invalid/v1?token=SECRET_QUERY")"
if [ "$fixture_host" != "relay.example.invalid" ]; then
  echo "FAIL AC9: URL host redaction fixture returned '$fixture_host'"
  exit 1
fi
echo "AC9 redaction fixture PASS: only relay.example.invalid emitted"

if ! command -v codex >/dev/null 2>&1; then
  degraded_with_approval
  exit 0
fi

echo "== codex --version =="
codex --version

CFG="$(printenv CODEX_HOME || true)"
if [ -z "$CFG" ]; then
  CFG="$HOME/.codex"
fi
echo "== CFG =="
echo "$CFG"

if [ ! -f "$CFG/config.toml" ]; then
  echo "config.toml unavailable at $CFG/config.toml"
  degraded_with_approval
  exit 0
fi

echo "== OPENAI_BASE_URL host =="
openai_lines="$(env | grep -E '^OPENAI_BASE_URL=' || true)"
if [ -n "$openai_lines" ]; then
  while IFS= read -r line; do
    value="$(printf '%s\n' "$line" | sed 's/^[^=]*=//')"
    printf 'OPENAI_BASE_URL host=%s\n' "$(extract_host "$value")"
  done <<EOF
$openai_lines
EOF
else
  echo "OPENAI_BASE_URL unset"
fi

selected_provider="$(extract_top_level_model_provider "$CFG/config.toml" || true)"
if [ -z "$selected_provider" ]; then
  selected_provider="unset"
fi
echo "== selected model_provider =="
echo "selected model_provider=$selected_provider"

echo "== config model keys (section annotated) =="
awk '
  BEGIN { section = "<top-level>" }
  /^[[:space:]]*\[/ { section = $0; next }
  /^[[:space:]]*(model|model_provider|model_reasoning_effort|default_subagent_model)[[:space:]]*=/ {
    print section ": " $0
  }
' "$CFG/config.toml" 2>/dev/null || true

echo "== config base_url hosts (section annotated) =="
while IFS=$'\t' read -r section line; do
  value="$(printf '%s\n' "$line" |
    sed -E 's/^[^=]*=[[:space:]]*"?//; s/"[[:space:]]*$//')"
  printf '%s base_url host=%s\n' "$section" "$(extract_host "$value")"
done < <(awk '
  BEGIN { section = "<top-level>" }
  /^[[:space:]]*\[/ { section = $0; next }
  /^[[:space:]]*base_url[[:space:]]*=/ { print section "\t" $0 }
' "$CFG/config.toml" 2>/dev/null || true)

if [ "$selected_provider" != "unset" ]; then
  selected_base_url_line="$(extract_provider_base_url_line "$CFG/config.toml" "$selected_provider" || true)"
  if [ -n "$selected_base_url_line" ]; then
    selected_base_url="$(printf '%s\n' "$selected_base_url_line" |
      sed -E 's/^[^=]*=[[:space:]]*"?//; s/"[[:space:]]*$//')"
    echo "selected route base_url host=$(extract_host "$selected_base_url")"
  else
    echo "selected route base_url unavailable (native/degraded)"
  fi
elif [ -n "$openai_lines" ]; then
  echo "selected route=OPENAI_BASE_URL"
else
  echo "selected route=native"
fi

echo "== per-agent model keys =="
if [ -d "$CFG/agents" ]; then
  find "$CFG/agents" -type f -name '*.toml' -exec \
    grep -E '^(model|model_reasoning_effort)[[:space:]]*=' {} + 2>/dev/null || true
else
  echo "agents directory unavailable (no per-agent overrides)"
fi

echo "AC9 PASS: codex version and all four harness capture probes were re-run with host-only URL evidence"
