# AI Agent Architecture — Tool Research

## Tool Needs per Capability

| Capability | Need | Tool | Registry? |
|-----------|------|------|-----------|
| reliability_design | Architecture diagrams (layer model, validation flow) | D2 | ✅ diagram_generation |
| reliability_design | PDF design document | Typst | ✅ pdf_generation |
| role_behavior_design | Behavior matrix diagram | D2 | ✅ diagram_generation |
| tool_system_design | Permission pipeline diagram, tool schema | D2 | ✅ diagram_generation |
| memory_design | Memory hierarchy diagram, compaction flow | D2 | ✅ diagram_generation |
| multi_agent_design | Sequence diagrams (agent communication) | Mermaid.ink | ✅ diagram_generation (alt) |
| multi_agent_design | Collaboration flow diagram | D2 | ✅ diagram_generation |
| safety_design | Guardrail architecture diagram | D2 | ✅ diagram_generation |
| prompt_architecture | Prompt hierarchy diagram, token budget chart | D2 + Matplotlib | ✅ both |
| production_readiness | State machine diagram, checklist PDF | D2 + Typst | ✅ both |
| All capabilities | Web research | WebSearch/WebFetch | ✅ builtin |

## Tool Testing Results

### Test 1: D2 — Agent Architecture Diagram

```bash
# Install
brew install d2  # Already installed

# Version
d2 --version  # 0.7.1

# Test: Agent validation pipeline
cat > /tmp/test-agent-seq.d2 << 'EOF'
direction: right
user: User {shape: person}
agent: Agent { style.fill: "#e3f2fd" }
schema: "Schema\nValidator" { style.fill: "#fff3e0" }
hook: "PreToolUse\nHook" { style.fill: "#fff9c4" }
perm: "Permission\nEngine" { style.fill: "#e8f5e9" }
tool: "Tool" { style.fill: "#f3e5f5" }
user -> agent: "1. request"
agent -> schema: "2. validate"
schema -> hook: "3. check rules"
hook -> perm: "4. check access"
perm -> tool: "5. execute"
tool -> agent: "6. result"
agent -> user: "7. response"
EOF
d2 /tmp/test-agent-seq.d2 /tmp/test-agent-seq.svg
```

**Result**: ✅ SUCCESS — 24KB SVG, clean architecture visualization
**Note**: D2 `layers` feature generates multi-file output (directory), use flat for single SVG

### Test 2: Mermaid.ink API — Sequence Diagram

```bash
# No install needed (HTTP API)

# Test: Agent communication sequence
MERMAID_CODE='sequenceDiagram
    participant U as User
    participant A as Agent
    participant V as Validator
    participant T as Tool
    U->>A: Request
    A->>V: Validate schema
    V-->>A: Valid
    A->>T: Execute tool
    T-->>A: Result
    A-->>U: Response'

ENCODED=$(echo "$MERMAID_CODE" | base64 | tr -d '\n')
curl -s -o /tmp/test-mermaid.png "https://mermaid.ink/img/${ENCODED}"
```

**Result**: ✅ SUCCESS — 27KB PNG, clear sequence diagram
**Note**: Free, no API key, works via base64-encoded URL. Best for sequence/timeline diagrams.

## New Tools Evaluated but Not Added

| Tool | Why Considered | Decision |
|------|---------------|----------|
| Anthropic SDK | Test tool_use schema validation | ❌ Skip — requires API key, domain pack teaches design not implementation |
| Agent evaluation tools | Test agent behavior | ❌ Skip — no good CLI tool exists; evaluation is out of scope (ai-evaluation pack) |
| NeMo Guardrails CLI | Test guardrail configs | ❌ Skip — requires GPU, heavy dependency; pack teaches principles not specific framework |

## Conclusion

All 8 capabilities are fully covered by existing registry tools:
- **D2**: Primary diagram tool (architecture, flow, state machine)
- **Mermaid.ink**: Complement for sequence diagrams (multi-agent communication)
- **Typst**: PDF design documents
- **Matplotlib**: Token budget charts, comparison data

No new registry entries needed.
