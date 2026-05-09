# Multi-path fixture

### Multi Path - 2026-04-05
- **Context**: entry depends on multiple files
- **Discovery**: each path independently judged; one OK + one STALE acceptable
- **Action**: emit one finding per path
- **Grounded in**: file_a.py, file_b.py
