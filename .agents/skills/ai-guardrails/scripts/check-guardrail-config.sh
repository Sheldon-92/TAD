#!/usr/bin/env bash
# check-guardrail-config.sh — deterministic guardrail-config linter for the ai-guardrails pack.
#
# Flags the four highest-signal guardrail anti-patterns that an LLM otherwise "punts to Claude":
#   (a) Agentic Rule of Two / lethal-trifecta violation: an agent config that wires
#       untrusted-input + sensitive-data + external-state tools with NO human gate.
#   (b) keyword/blocklist-ONLY prompt-injection defense (no decode-then-validate / classifier).
#   (c) raw SQL or shell sink with no sqlglot/AST gate.
#   (d) raw enterprise text sent to an external LLM with no Presidio Analyzer->Anonymizer.
#
# Usage:   check-guardrail-config.sh <config-file-or-dir> [more files...]
#          check-guardrail-config.sh --self-test
# Exit:    0 = no findings (pass) | 1 = findings present | 2 = usage / file error.
#
# Heuristic by design: deterministic grep over the config TEXT (agent specs, IaC, prompt
# templates, pipeline code). It catches the named patterns so the finding wires into CI and
# into the fixture's Verification Command; it is NOT a full static analyzer.
# POSIX/BSD-portable (macOS + Linux). No Windows paths. No external deps beyond grep.

set -euo pipefail
export LC_ALL=en_US.UTF-8 2>/dev/null || true

FINDINGS=0

emit() {
  # emit <CODE> <OWASP> <message>
  printf '[FINDING %s | %s] %s\n' "$1" "$2" "$3"
  FINDINGS=$((FINDINGS + 1))
}

# grep -qiE wrapper that never trips set -e on "no match"
has() { grep -qiE -- "$1" "$2" 2>/dev/null; }

scan_file() {
  file="$1"
  [ -f "$file" ] || { echo "skip (not a file): $file" >&2; return 0; }

  # --- (a) Rule of Two / lethal trifecta -------------------------------------
  # A = untrusted input, B = sensitive data, C = external state change.
  A=0; B=0; C=0
  has 'untrusted|external (input|content|data)|web ?page|user email|rag chunk|retriev|free.?form|incoming email|summari[sz]e .*(link|url|web)' "$file" && A=1
  has 'sensitive|pii|credit.?card|ssn|order ?db|database|secret|private|customer (data|record)|api ?key|credential' "$file" && B=1
  has 'send (email|message)|email the|write to|insert into|update |delete |drop |execute|shell|subprocess|os\.system|http (post|put|delete)|state.?chang|tool ?call|purchase|transfer' "$file" && C=1
  legs=$((A + B + C))
  if [ "$legs" -ge 3 ]; then
    if ! has 'human.?in.?the.?loop|human (approval|gate|review)|manual approval|require[sd]? (approval|confirmation)|approval gate|confirm before' "$file"; then
      emit "RULE-OF-TWO" "LLM06" "$file: all 3 Rule-of-Two legs present (A=untrusted+B=sensitive+C=state-change) with NO human-in-the-loop gate -> lethal trifecta. Drop one leg or add a human approval gate."
    fi
  fi

  # --- (b) blocklist-only injection defense ----------------------------------
  if has 'blocklist|block.?list|denylist|deny.?list|keyword (filter|list)|banned (word|phrase)|regex (filter|blocklist)|word ?list' "$file"; then
    if ! has 'decode.?then.?validate|post.?decode|semantic (classifier|llm)|spotlight|datamark|lakera|rebuff|nemo|llama ?guard|prompt ?guard|jailbreakdetect' "$file"; then
      emit "BLOCKLIST-ONLY" "LLM01" "$file: prompt-injection defense is keyword/blocklist-ONLY. Base64/ROT13/typoglycemia bypass it. Add decode-then-validate + a semantic classifier or Spotlighting (datamarking)."
    fi
  fi

  # --- (c) raw SQL / shell sink with no AST gate -----------------------------
  if has 'execute_command|os\.system|subprocess|`?\$\(|eval\(|exec\(|raw sql|cursor\.execute|run.*query|sql ?=|select .*from|delete from|drop table' "$file"; then
    if ! has 'sqlglot|ast (gat|pars|check)|parse.*ast|read.?only select|allowlist|allow.?list|parameteri[sz]ed (quer|statement)' "$file"; then
      emit "RAW-SINK" "LLM05" "$file: model-driven SQL/shell sink with NO sqlglot/AST gate or allowlist. Parse with sqlglot AST -> allow read-only SELECT only; reject DELETE/DROP before the engine."
    fi
  fi

  # --- (d) external LLM call with no Presidio de-id --------------------------
  if has 'openai|anthropic|external (model|llm|api)|gpt-|claude|gemini|send.*to.*model|llm ?(api|call|client)|chat\.completions' "$file"; then
    if has 'pii|name|email|address|credit.?card|ssn|phone|customer (data|text|record)|sensitive|personal data' "$file"; then
      if ! has 'presidio|analyzerengine|anonymizerengine|deanonymiz|de.?identif|redact|anonymiz|mask (pii|email|card)|scrub' "$file"; then
        emit "NO-PII-DEID" "LLM02" "$file: raw enterprise text (PII) reaches an external LLM with NO Presidio Analyzer->Anonymizer. Run AnalyzerEngine->AnonymizerEngine before the external call; Encrypt+DeanonymizeEngine if you must restore values."
      fi
    fi
  fi
}

run_scan() {
  # Returns 0 if no findings, 1 if findings present. FINDINGS is updated in THIS
  # shell (no pipe-to-while subshell, which would swallow the increments on BSD/zsh).
  for target in "$@"; do
    if [ -d "$target" ]; then
      # scan common config/text extensions, deterministic order. Read into the
      # current shell via process substitution so scan_file's FINDINGS survives.
      while IFS= read -r f; do
        [ -n "$f" ] && scan_file "$f"
      done <<EOF
$(find "$target" -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' \
        -o -name '*.py' -o -name '*.ts' -o -name '*.js' -o -name '*.md' \
        -o -name '*.toml' -o -name '*.txt' -o -name '*.co' \) | sort)
EOF
    else
      scan_file "$target"
    fi
  done
  [ "$FINDINGS" -eq 0 ]
}

self_test() {
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  # A bad config that should trip ALL four findings.
  cat > "$tmp/bad-agent.yaml" <<'EOF'
agent: support
description: reads the customer's incoming free-form email, summarizes web links
tools:
  - run_sql: cursor.execute(model_generated_sql)   # raw SQL sink
  - send_email: emails the customer back            # external state change
  - orders_db: full access to sensitive order DB with credit-card and PII
injection_defense: keyword blocklist of banned words only
llm: openai gpt-4o   # raw customer email text (names, addresses) sent straight to the model
EOF
  echo "=== self-test: scanning intentionally-bad config (expect 4 findings, exit 1) ==="
  FINDINGS=0
  if run_scan "$tmp/bad-agent.yaml"; then
    echo "SELF-TEST FAIL: bad config returned exit 0 (expected findings)" >&2
    return 1
  fi
  if [ "$FINDINGS" -ne 4 ]; then
    echo "SELF-TEST FAIL: bad config produced $FINDINGS findings (expected 4)" >&2
    return 1
  fi
  # A clean config that should trip NOTHING.
  cat > "$tmp/good-agent.yaml" <<'EOF'
agent: readonly-faq
description: answers FAQ from a static curated knowledge base (trusted, no external input)
tools:
  - lookup_faq: read-only SELECT over faq table, parsed with sqlglot AST allowlist
injection_defense: decode-then-validate + Lakera Guard semantic classifier + Spotlighting datamarking
pii: Presidio AnalyzerEngine -> AnonymizerEngine before any openai call
human_gate: every state-changing action requires manual approval (human-in-the-loop)
EOF
  echo "=== self-test: scanning clean config (expect 0 findings, exit 0) ==="
  FINDINGS=0
  if ! run_scan "$tmp/good-agent.yaml"; then
    echo "SELF-TEST FAIL: clean config returned findings (expected none)" >&2
    return 1
  fi
  echo "SELF-TEST PASS: bad->findings(exit1), good->clean(exit0)"
  return 0
}

# ---- main -------------------------------------------------------------------
if [ "$#" -eq 0 ]; then
  echo "usage: $(basename "$0") <config-file-or-dir> [more...]   |   --self-test" >&2
  exit 2
fi

if [ "$1" = "--self-test" ]; then
  self_test
  exit $?
fi

for t in "$@"; do
  [ -e "$t" ] || { echo "error: no such file or dir: $t" >&2; exit 2; }
done

run_scan "$@" || true

if [ "$FINDINGS" -gt 0 ]; then
  echo "---"
  echo "$FINDINGS guardrail finding(s). Fix before deployment. (exit 1)"
  exit 1
fi
echo "No guardrail findings. (exit 0)"
exit 0
