# Malformed-grammar fixture

### Malformed Grammar - 2026-04-01
- **Context**: line range syntax disallowed by README grammar
- **Discovery**: stale-check should emit WARN, not crash
- **Action**: status=WARN ("malformed path '...' (line_range)")
- **Grounded in**: file_a.py:42-55
