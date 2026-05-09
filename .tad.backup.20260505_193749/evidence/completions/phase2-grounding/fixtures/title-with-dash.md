# Title-with-dash fixture (anchor regex must use LAST ' - ')

### Sub-Agent Safety: Red-Team Triggers Refusal - 2026-04-14
- **Context**: header contains multiple `-` chars in the title
- **Discovery**: regex must anchor to LAST ` - YYYY-MM-DD` to extract correctly
- **Action**: title="Sub-Agent Safety: Red-Team Triggers Refusal", date="2026-04-14"
- **Grounded in**: file_a.py
