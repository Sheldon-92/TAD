# Revalidated-stale fixture (mtime > revalidated → still stale)

### Revalidated Stale - 2026-04-01
- **Context**: re-verified, but file changed AGAIN since
- **Discovery**: baseline correctly bumped to revalidated; STALE relative to that
- **Action**: status=STALE, days_delta computed from revalidated_date
- **Grounded in**: file_a.py
- **Revalidated**: 2026-04-05
