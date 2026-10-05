Model: harness=codex | model=unknown | route=unknown

# Independent review — TASK-20261001-TAD-PM-MECH-DOCS-ABSORB

Verdict: **PASS** for the scoped PM documentation.

## Findings

- **No blocking or corrective findings in the reviewed docs.** Intent uses resolvable shared SSOT pointers and labels the 2026-09-13 model precedents historical; it does not add a local model table or `docs/model-routing.md` copy. [docs/pm/intent.md:11](/home/box/云同步/TAD/docs/pm/intent.md:11) [docs/pm/intent.md:12](/home/box/云同步/TAD/docs/pm/intent.md:12)
- **No blocking or corrective findings in the PM operating rules.** Auth points to HO §§3.7b/3.7d/3.10 and the shared open-run/restate templates; it requires card disk + same-body 1:1 + matching stamp before launch, a non-empty restate with a human “understood correctly” trace, and a formal `HANDOFF-*.md` as Blake’s basis. [docs/pm/auth.md:25](/home/box/云同步/TAD/docs/pm/auth.md:25) [docs/pm/auth.md:26](/home/box/云同步/TAD/docs/pm/auth.md:26) [docs/pm/auth.md:27](/home/box/云同步/TAD/docs/pm/auth.md:27) [docs/pm/auth.md:28](/home/box/云同步/TAD/docs/pm/auth.md:28)
- **No blocking or corrective findings in closeout rules.** Acceptance prohibits naked WAIT, requires 1:1 for done/ask/look, explicit KA or “无新发现”, and separate explicit disk/brain dual-write ticks with pointers or “本刀无项目记忆”; it points to HO §§3.8b/3.9/3.12 and both shared closeout templates. [docs/pm/acceptance.md:20](/home/box/云同步/TAD/docs/pm/acceptance.md:20) [docs/pm/acceptance.md:21](/home/box/云同步/TAD/docs/pm/acceptance.md:21) [docs/pm/acceptance.md:22](/home/box/云同步/TAD/docs/pm/acceptance.md:22) [docs/pm/acceptance.md:23](/home/box/云同步/TAD/docs/pm/acceptance.md:23)
- **Next candidate is a valid HOLD.** `now.md` names the reason and unlocker; the segment status agrees on PASS, `continue: no`, and the same HOLD. [docs/pm/now.md:1](/home/box/云同步/TAD/docs/pm/now.md:1) [docs/pm/now.md:2](/home/box/云同步/TAD/docs/pm/now.md:2) [docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:6](/home/box/云同步/TAD/docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:6) [docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:7](/home/box/云同步/TAD/docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:7) [docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:8](/home/box/云同步/TAD/docs/pm/segment-status/seg-20261001-tad-pm-mech-docs-absorb.md:8)

## Scope and hard-stop check

The authorized-doc diff covers the requested intent/auth/acceptance changes plus the permitted now and segment-status updates. No local routing SSOT, checker script, or template fork was added in the reviewed scope. The shared routing, charter, human-operating sections, templates, and GM temporary lock referenced above resolved at the named read-only paths.

The current worktree status also lists out-of-scope paths, including `M NEXT.md` and `D .tad/active/handoffs/HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid.md`. Git status alone cannot attribute their origin; the task owner reports this land did not write those paths. I did not inspect unrelated handoff contents, and I do not count these ambient paths against the scoped-doc verdict.

No tests were run; this was a documentation review.
