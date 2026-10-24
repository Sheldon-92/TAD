# TAD - Triangle Agent Development

**Version 4.0.7 — Claude Code · Codex · OpenCode · Cursor**

**You talk to Cora. She gets the work done and shows you the result.**

TAD is a way of working with AI coding agents (Claude Code, Codex, Cursor, OpenCode) where you stay in one conversation about what you want, and the building and checking happen behind it, by separate agents, with quality gates between the steps.

```
You  -->  Cora  -->  Alex designs  -->  Blake builds  -->  independent checks  -->  You look at the result
```

**How a piece of work goes**

1. Tell Cora what you want. She asks until the result is clear.
2. She has an Epic (the written plan) made and stops. Nothing runs yet.
3. You read it and say "continue".
4. She runs it to the end through subagents and gates. Only questions a human can answer reach you.
5. You look at the result and accept it, or send it back.

Not every job needs the whole flow: Cora first clarifies the request (you confirm a one-line-per-block playback), then tells you whether it is a simple task, a single handoff or an Epic (the steps above are the Epic path; for the other two she states her plan and starts, except a handoff with an irreversible effect, which she asks about first; say 'wait' to stop her). Or pick by what you need:

| You want to... | Go to |
|---|---|
| Decide what to build, why, whether, or what next | **Cora** (`/cora`, Codex `$cora`) |
| Have something built from start to finish | **Cora**: Epic, then Alex, Blake and the gates after you say "continue" |
| Design how to build one thing, or discuss a technical choice | **Alex** (`/alex`) directly |
| Implement one finished handoff, or fix a bug | **Blake** (`/blake`) directly |
| Not sure | **Cora** |

**Start**

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform claude-code --yes   # or codex | opencode | cursor
/cora        # Codex: $cora
```

`/alex` and `/blake` still work directly for a single handoff, a bug or a technical discussion.

Cora has been run on Claude Code and Codex, to the extent listed in [What has been run on each harness](#what-has-been-run-on-each-harness). She has not been run on Cursor or OpenCode yet.

> **[Changelog](CHANGELOG.md)** | **[Installation](INSTALLATION_GUIDE.md)** | **[Multi-Platform Guide](docs/MULTI-PLATFORM.md)** | **[Ralph Loop Guide](docs/RALPH-LOOP.md)**

---

## Three roles

| Role | Command | What she or he does |
|------|---------|---------------------|
| **Cora** (Conductor) | `/cora` (Codex: `$cora`) | The one you talk to. Triages each request (simple task, single handoff or Epic) and tells you which, with the plan; dispatches Alex, Blake and the reviewers as subagents (an Epic after your "continue"; a simple task or a reversible handoff right after stating the plan; a one-way handoff after your answer) and runs the work to the end. Writes no implementation, gives no verdict. |
| **Alex** (Solution Lead) | `/alex` | Requirements, design, handoffs, and relaying Gate 4 (the acceptor that took no part dispatched by Alex). |
| **Blake** (Execution Master) | `/blake` | Implementation, the Ralph Loop; prepares Gate 3 (the run reviewer signs it). |

You are the fourth part: you decide what the result should be, and you accept it at the end.

## How a piece of work goes

1. **Agree a result with Cora.** She asks until what you want is clear.
2. **She gets an Epic written and stops.** The Epic is the plan, in a file you can read. Nothing has run yet.
3. **You say "continue".**
4. **She runs it to the end** through subagents (Alex designs, Blake builds, reviewers check) and the quality gates.
5. **You look at the result** and accept it or send it back.

While she runs, she stops for only three things: something she cannot get past on her own, a change to the result you agreed, or an irreversible or outward action (push, publish, delete).

## Where quality comes from

- **The checker did not see the doer's reasoning.** Whoever reviews a piece of work is a fresh agent that was not part of building it. An agent that reviews its own work will usually approve it.
- **Four gates:** Gate 1 requirements (your confirmed playback), Gate 2 design (two lens reviewers), Gate 3 implementation (run + consistency reviewers), Gate 4 acceptance (an AI acceptor that did not build it, by real use). Evidence goes to files, not to claims.
- **Only human-answerable questions go to the human:** what, why, whether, what next. Questions that a command or a file can answer do not.
- **Separate terminals are one way to get the same independence.** Running `/alex` in one session and `/blake` in another, with you passing the handoff between them, still works and is a fine choice for a single handoff.

## Who to go to for what

- What to build, why, whether it is worth it, what next: **Cora**.
- How to build it: Cora dispatches Alex, or go to **`/alex`** directly.
- A single handoff or a bug: **Cora** triages it and runs it, or go to **`/alex`** or **`/blake`** directly. A technical discussion: **`/alex`**.
- Not sure: **Cora**.

## What has been run on each harness

Facts only. Nothing unrun is described as verified. Fixtures are scripted headless runs, not interactive sessions. Full table and evidence: [docs/MULTI-PLATFORM.md](docs/MULTI-PLATFORM.md#cora-on-each-harness).

| Harness | Run | Not run |
|---------|-----|---------|
| **Claude Code** | Cora headless smoke fixtures (6/6) and queue fixtures (5/5), no P0; one live conducted run (a real Claude Code session conducting a real Epic in this repository), which closed PARTIAL; its open P0 was fixed afterwards and re-checked on the scripted fixtures only. | No interactive live session is on disk. Several paths were checked by text only; they are listed under known limits in the [4.0.0 changelog entry](CHANGELOG.md). |
| **Codex** | The same fixtures, 6/6 and 5/5, no P0; in the live run, Steps Y1 to Y5 only. | Gates, acceptance and distillation were not run on Codex; conducting a run whose fixtures need `claude -p` was blocked. |
| **Cursor** | Nothing. | Cora was not run on Cursor. |
| **OpenCode** | Nothing. | Cora was not run on OpenCode. |

The roles `/alex` and `/blake`, the gates and the lifecycle hooks have their own status per harness in the [status table](docs/MULTI-PLATFORM.md#current-status).

## Install

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

One command; first install and upgrade are the same command, and project data is untouched. It installs the default target (`codex`) and all capability packs.

- **Targets:** `--platform claude-code|codex|opencode|cursor` (default `codex`). `--platform both` is refused before any file is changed.
- **Where skills live:** roles, gates and packs ship as one tree, `.agents/skills/`. Codex, OpenCode and Cursor read it natively; Claude Code reads `.claude/skills/`, which the installer fills with per-skill links into it.
- **What the installer leaves alone:** with `--platform codex|opencode|cursor` it does not change your `CLAUDE.md` or `.claude/settings.json`, nor your own files under `.claude/` (one exception: in a project that already has a TAD Claude Code projection it keeps the `.claude/skills/` links current; `TAD_CLAUDE_STICKY=off` turns that off). With `--platform claude-code` it archives (outside the project, restorable) and replaces only files it can prove byte-for-byte were shipped by an earlier TAD; your hooks, permissions, MCP config and `CLAUDE.md` text stay as they are. An existing `.claude/settings.json` is kept and TAD's hooks are not added to it. Add `--claude-adopt=plan` to see the list without changing anything.
- **Packs:** choose with `--packs web-frontend,web-backend`, or run `npx github:Sheldon-92/TAD` for the interactive picker.
- **Hooks:** each harness gets a lifecycle-hook configuration over the same `.tad/hooks/` scripts (Claude Code: only when the project has no `.claude/settings.json`; Codex: no PreCompact hook, and the configuration did not take effect in a default-trust run, see the status table).

Details: [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md). Claude Code loads `AGENTS.md` by itself only when the project has no `CLAUDE.md`; for a project that already has one, the installer keeps a marked `@AGENTS.md` reference block inside it.

To check an install:

```bash
cat .tad/version.txt     # 4.0.7
```

Installed projects update with one sentence ("升级 TAD" to Cora, `/tad-update`, or `$tad-update`): the check is read-only and prints the exact line to run, `/bin/bash .tad/scripts/tad-update.sh --yes --platform <platforms>`; after your one yes it updates every platform listed in one run, keeps a backup of only the files it changes or removes, and ends with a report (version, project files unchanged or the paths that changed, your edits in TAD files, backup path, holding area). Older backups move to a holding area and are deleted only with your yes ("清掉" clears them; the next update's check also offers it); before each deletion the held item is measured again from its files and kept if anything changed since it was listed. "看备份" lists the TAD files you edited: each diff is written to a local file you open yourself (no file content is printed in the conversation), and one yes absorbs a file into the salvage folder under the project knowledge directory, never into `AGENTS.md`. `AGENTS.md` has a File Ownership section that says which files are TAD's and which are yours.

## Upgrading from 3.x

- Re-run the installer command above (add `--platform` for your harness). `/cora` appears.
- `/alex` and `/blake` keep working unchanged.
- Nothing to migrate by hand unless the migration notes in the [CHANGELOG](CHANGELOG.md) for this release say so.

## When to use TAD

TAD applies to any substantial capability-building work. Software is the most exercised path, but the same loop runs for content production, research and other domains (see [docs/value-proposition.md](docs/value-proposition.md)).

- **Use it for:** a new feature (more than 3 files or a day of work), architecture changes, complex multi-step requirements, cross-module refactoring, multi-phase work in a non-code domain.
- **Skip it for:** a single-file bug fix, config changes, documentation updates, an emergency hotfix, or any small task where the process costs more than the task.

## Frozen: TAD Lite

TAD Lite (`/alex-lite`, `/blake-lite`) is a frozen experiment since 2026-08-13. In-flight Lite contracts run to completion and explicit invocation still works, but no new work starts there.

## Capability packs

Domain packs (frontend, backend, testing, security, research, video and more) ship under `.agents/skills/` and load on demand when a task matches their keywords. See [.agents/skills/](.agents/skills/).

## Troubleshooting

- **"Gate failed - no evidence file":** the reviewers were not called or did not write to `.tad/evidence/reviews/`; run the gate again.
- **"Handoff created without a confirmed requirement playback":** Alex must clarify the requirement block by block and get the playback confirmed before writing a handoff; re-run with the proper flow.
- **"Knowledge files empty":** run `/knowledge-audit --fix` or bootstrap from the templates.

## Contributing

TAD evolves through direct improvement in the [TAD repository](https://github.com/Sheldon-92/TAD). If you find issues or have suggestions, modify the framework directly or open an issue.

## Further reading

- [Changelog](CHANGELOG.md): every version, what changed and what did not land
- [Installation Guide](INSTALLATION_GUIDE.md)
- [Multi-Platform Guide](docs/MULTI-PLATFORM.md): install targets, per-harness status and limits
- [Codex User Guide](docs/CODEX-USER-GUIDE.md)
- [Ralph Loop Guide](docs/RALPH-LOOP.md)
- [Value Proposition](docs/value-proposition.md): every claim cited to an on-disk artifact
- [Configuration](.tad/config.yaml)

---

**TAD v4.0.7 — Claude Code · Codex · OpenCode · Cursor**

*AI does the work. Humans guard the value.*
