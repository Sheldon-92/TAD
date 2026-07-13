#!/usr/bin/env bash
# AC9: every committed path maps to handoff §7 table or Required Evidence Manifest
cd "$(git rev-parse --show-toplevel)"
FAIL=0
while IFS= read -r f; do
  case "$f" in
    .tad/hooks/lib/derive-sync-set.sh|tad.sh|.tad/hooks/lib/memory-redirect.sh|.gitignore|CLAUDE.md) ;;                # §7 rows
    .tad/memory/*) ;;                                                                                                  # §7: migration products
    .tad/evidence/memory-migration-sensitivity-report.md) ;;                                                           # §7 T3a
    .claude/skills/alex/references/distillation-loop-protocol.md|.agents/skills/alex/references/distillation-loop-protocol.md) ;; # §7 T4/T6
    .claude/skills/release-runbook/SKILL.md|.agents/skills/release-runbook/SKILL.md) ;;                                # §7 T5b + T6 mirror
    .tad/evidence/acceptance-tests/TASK-20260712-001/*) ;;                                                             # Evidence Manifest (step3b)
    .tad/evidence/ralph-loops/TASK-20260712-001*) ;;                                                                   # Ralph state (protocol)
    .tad/evidence/reviews/blake/memory-redirect-capture-layer/*) ;;                                                    # Evidence Manifest blake_reviews
    *) echo "OUT-OF-TABLE: $f"; FAIL=1 ;;
  esac
done < <(git show --name-only --pretty=format: HEAD | grep -v '^$')
# reverse direction: every §7 MODIFY git-tracked file must appear in the diff
for f in .tad/hooks/lib/derive-sync-set.sh tad.sh .gitignore CLAUDE.md \
         .claude/skills/alex/references/distillation-loop-protocol.md \
         .claude/skills/release-runbook/SKILL.md \
         .agents/skills/alex/references/distillation-loop-protocol.md; do
  git show --name-only --pretty=format: HEAD | grep -qx "$f" || { echo "MISSING §7 MODIFY: $f"; FAIL=1; }
done
[ "$FAIL" -eq 0 ] && echo "AC9 PASS: all $(git show --name-only --pretty=format: HEAD | grep -c .) committed paths map to §7/Evidence-Manifest; all §7 MODIFYs present" || echo "AC9 FAIL"
exit $FAIL
