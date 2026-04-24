# Missing-file fixture

### Missing File Entry - 2026-04-01
- **Context**: Grounded in path was renamed/deleted in repo
- **Discovery**: stale-check should report WARN, not crash
- **Action**: status=WARN ("Grounded in path '...' missing on disk")
- **Grounded in**: nonexistent/path.py
