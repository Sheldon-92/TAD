---
id: probe-blake
assert: A2
assert_keys: role, tad_version, hooks_top, gate3_owner, skill_name
---

You are a fresh sub-agent in the Sober Creator project repository. Act as Blake (Execution Master) by following this repository's activation protocol, then report back in a fixed format. Do not write or modify any file.

Steps:

1. Read `.agents/skills/blake/SKILL.md` and follow its Activation section: read the repository `AGENTS.md`, then the Knowledge Ingress files it routes to — `.tad/project-knowledge/principles.md` and `.tad/project-knowledge/patterns/_index.md`.
2. Read `.tad/version.txt`.
3. Count for yourself the shell scripts sitting directly in `.tad/hooks/` — only files ending in `.sh` at that top level; do not descend into subdirectories such as `lib/`.
4. Read the Gate 3 section of `.tad/gates/gate-canonical-checklist.md` and find its Owner line. Quote, word for word, the part of that line that says who owns Gate 3 — copy the original wording exactly; do not paraphrase it, and do not shorten it to a generic phrase.

If any file named above is missing, still emit the report block and put ABSENT as the value of every field that the missing file would have supplied.

Output: your entire final message must be exactly the following block, filled with the values you found — no prose before or after it:

SELFTEST-REPORT
role: blake
tad_version: <the exact contents of .tad/version.txt>
hooks_top: <your count>
gate3_owner: <your verbatim quote>
skill_name: <the name value in the frontmatter of the SKILL.md you activated>
END-SELFTEST-REPORT
