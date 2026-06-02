# Expert Reviewer Premise Check

**Date:** 2026-05-09
**Linked to:** L2 gate-design "Expert Review Blind Spots"

---

### Expert Reviewer Premise Check - 2026-05-09
- **Discovery**: Expert reviewers can confuse raw CLI calls (`~/.tad-notebooklm-venv/bin/notebooklm ask`) with SKILL command invocations (`*research-notebook ask`). These have fundamentally different execution paths. Add protective comments to raw CLI calls in mixed contexts.
- **Action**: Verify whether invocation is raw CLI or SKILL command. Add "(Raw CLI — NOT *command)" comments.
