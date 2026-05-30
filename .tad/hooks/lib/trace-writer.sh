#!/bin/bash
# TAD Trace Writer Library — decision-level event helpers
# Source this file, don't execute it directly.
# Usage: source .tad/hooks/lib/trace-writer.sh

TRACE_WRITER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${TRACE_WRITER_DIR}/common.sh"

trace_gate_result() {
  local gate_num="$1" verdict="$2" detail="${3:-}" slug="${4:-}" agent="${5:-alex}"
  TRACE_CONTEXT="Gate $gate_num: $detail" TRACE_OUTCOME="$verdict" TRACE_ACTOR="agent_inferred" \
    TRACE_SLUG="$slug" TRACE_AGENT="$agent" \
    record_trace "gate_result"
}

trace_expert_finding() {
  local reviewer_type="$1" priority="$2" finding="${3:-}" slug="${4:-}"
  TRACE_CONTEXT="$finding" TRACE_OUTCOME="$priority" TRACE_ACTOR="agent_inferred" \
    TRACE_SLUG="$slug" TRACE_AGENT="$reviewer_type" \
    record_trace "expert_review_finding"
}

trace_decision_point() {
  local decision="$1" chosen="$2" rationale="${3:-}" slug="${4:-}" actor="${5:-agent_inferred}"
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg d "$decision" --arg c "$chosen" --arg r "$rationale" \
      '{decision:$d,chosen:$c,rationale:$r}')
  else
    ctx="decision=${decision}|chosen=${chosen}|rationale=${rationale}"
  fi
  # TRACE_DETAIL=full: context is a JSON object; outcome (=chosen) is NOT fail/error so
  # record_trace would NOT auto-escalate, leaving the 200-char summary budget. That can
  # slice the JSON mid-string → fromjson errors in dream-scanner Pass C / analyzer step8.
  # full gives the 2048 budget; callers cap each field ≤200 so assembled JSON stays well under.
  TRACE_CONTEXT="$ctx" TRACE_OUTCOME="$chosen" TRACE_ACTOR="$actor" TRACE_DETAIL="full" \
    TRACE_SLUG="$slug" \
    record_trace "decision_point"
}

trace_tool_outcome() {
  local tool_name="$1" result="$2" detail="${3:-}" duration="${4:-}"
  TRACE_CONTEXT="$detail" TRACE_OUTCOME="$result" TRACE_ACTOR="agent_inferred" \
    TRACE_AGENT="$tool_name" TRACE_DURATION="$duration" \
    record_trace "tool_call_outcome"
}

trace_knowledge_extraction() {
  local file="$1" title="$2" source="${3:-}" slug="${4:-}" actor="${5:-agent_verified}"
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg t "$title" --arg s "$source" '{title:$t,source:$s}')
  else
    ctx="title=${title}|source=${source}"
  fi
  TRACE_CONTEXT="$ctx" TRACE_ACTOR="$actor" TRACE_SLUG="$slug" \
    record_trace "knowledge_extraction" "$file"
}

trace_reflexion_diagnosis() {
  local what_failed="$1" hypothesis="$2" approach="${3:-}" confidence="${4:-medium}" slug="${5:-}"
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg w "$what_failed" --arg h "$hypothesis" --arg a "$approach" --arg c "$confidence" \
      '{what_failed:$w,root_cause_hypothesis:$h,revised_approach:$a,confidence:$c}')
  else
    ctx="what_failed=${what_failed}|root_cause_hypothesis=${hypothesis}|revised_approach=${approach}|confidence=${confidence}"
  fi
  # outcome=fail already auto-escalates record_trace to full/2048; TRACE_DETAIL=full is set
  # explicitly so the JSON-context 2048 budget survives even if outcome ever changes.
  TRACE_CONTEXT="$ctx" TRACE_OUTCOME="fail" TRACE_ACTOR="agent_inferred" TRACE_DETAIL="full" \
    TRACE_SLUG="$slug" TRACE_AGENT="blake" \
    record_trace "reflexion_diagnosis"
}
