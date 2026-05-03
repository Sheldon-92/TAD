# NotebookLM Spike — Raw Query Outputs

**Notebook ID**: 32cb8d9f-c74e-40b6-ae59-1c426961953a
**Account**: zhaosheldon2025@gmail.com (PRO)
**Conversation ID**: ede194d0-3b1f-437a-a151-ae636d31353a

---

## Q0: Baseline (Claude WebSearch)

**Query**: "AI agent bash command deny patterns regex categories 2026"
**Method**: Claude WebSearch (1 search)
**Latency**: ~3s

**Summary output**:
- Permission control: "allow" | "ask" | "deny" shorthand or glob patterns
- DCG: 4-stage pipeline (JSON Parse → Normalize → Quick Reject → regex match)
- Key insight: "Maintaining allowlists without sandboxing is fundamentally flawed" (commands like find/grep/git have powerful sub-parameters)
- Categories mentioned: file ops, git ops — limited specific regex examples
- No structured regex catalog produced

**Quality anchor**: 3/5 — accurate but no structured output, shallow on specifics

---

## Q1: Single-Source Fact Extraction

**Query**: "What specific bash commands does the Codex CLI sandbox restrict by default?"
**Latency**: 23s
**Citations**: 8 sources referenced

**Answer summary**:
- Native Codex CLI sandbox restrictions: not in sources (gap correctly identified)
- Omamori defaults: rm (-r/-rf/-fr/--recursive), git reset --hard, git push --force, git clean -f, chmod 777, find -delete, rsync --delete variants
- DCG defaults: rm -rf (outside /tmp), git destructive ops, Docker system prune, PostgreSQL DROP DATABASE/TRUNCATE

**Cross-source synthesis**: ✅ Yes (synthesized Omamori GitHub + DCG GitHub + Claude Code docs)
**YouTube content**: N/A (no YouTube source added)
**Quality**: 4/5 — accurate, well-organized, correctly flagged what wasn't in sources

---

## Q2: Cross-Source Synthesis

**Query**: "Compare how Claude Code and Codex CLI handle dangerous bash operations. Key differences in their security models?"
**Latency**: 30s
**Citations**: 29 sources referenced

**Answer summary**:
- Claude Code: permission-based (allow/ask/deny), built-in sandboxed bash, blocks curl/wget by default, vulnerable to >50-subcommand bypass
- Codex CLI: native sandbox + external hooks (dcg/omamori), hook exits with code 2 on deny, omamori PATH shim layer
- Key differences found:
  1. Complexity bypass: Claude Code fails at >50 subcommands; dcg has lightweight fallback
  2. Config trust: Claude Code trusts CLAUDE.md (attack vector); omamori defends own config files
  3. Two-tier security: Anthropic uses tree-sitter internally, ships regex to public
  4. Codex relies on community open-source rule sets (50+ security packs)

**Cross-source synthesis**: ✅ Yes (used 6+ different sources)
**YouTube content**: N/A
**Quality**: 5/5 — insights not easily derivable from single search; specific vulnerabilities with citations

---

## Q3-FINAL: Multi-YouTube Corpus (9 Videos) ✅✅

**Query**: "Based on all sources including all video content, what bash command patterns should an AI agent deny? What attack techniques from the videos are NOT covered by written documentation?"
**Latency**: 43s
**YouTube cited**: ✅ YES — multiple videos cited inline, 37 total citations

**New deny patterns from videos (not in web docs)**:
- `find -exec` — weaponized to run arbitrary OS commands while allowlisted
- `ping`, `host`, `nslookup`, `dig` — DNS exfiltration of env vars/secrets when curl blocked
- `kubectl delete namespace`, `terraform destroy`, `aws terminate-instances` — cloud infrastructure teardown

**Video-exclusive attack techniques (NOT in any written doc)**:
1. **Invisible Unicode Command Injection** — hidden Unicode tag characters in GitHub issues, Linear, SO; invisible to humans, read by LLM
2. **AI "Clickfix" Social Engineering** — fake "Verify you're a computer" → clipboard payload → agent pastes + executes in terminal
3. **Local Port Exposure Exfiltration** — agent writes local webserver, exposes to internet, leaks filesystem URL to attacker
4. **"Agent Hopper" AI Virus** — single repo compromise → enables YOLO mode → agent scans machine for other repos → spreads payload → pushes to GitHub
5. **Insecure Interagent Communication** — multi-agent trust exploitation; single injected fault cascades across entire workflow
6. **Human-Agent Trust Exploitation** — agent uses persuasive explanations to get human to "Allow" the harmful action; audit trail is clean

**Quality**: 5/5 — this is definitively the "search can't do this" result

---

## Q3-RETEST: Cross-Media Reasoning with YouTube Source ✅

**Query**: "Based on all sources including the video content, what bash command patterns should an AI agent deny? Include any insights specifically from the video."
**Latency**: ~35s
**YouTube cited**: ✅ YES — "According to the provided video..." with [1]-[8] from video

**Video-unique insights** (not in web sources):
- AI agents as "attack amplifiers" when hijacked via prompt injection
- Principle of least privilege + sandboxing as architectural defense
- AI firewall/proxy pattern for DLP (monitors outgoing traffic for sensitive data)
- **pipe-to-shell**: `curl URL | bash`, `curl URL | sudo bash` — explicitly from video
- **Dynamic execution**: `bash -c "$(cmd)"`, `sudo env bash -c "..."` — from video

**Quality**: 5/5 — video content directly incorporated, new patterns found

---

## Q3: Cross-Media Reasoning (Pattern Catalog — original, no YouTube)

**Query**: "Based on all sources, what bash command patterns should an AI agent deny? Provide specific regex patterns organized by category..."
**Latency**: 23s
**Citations**: 8 sources referenced

**Answer summary**:

File Destruction:
- rm + (-r|-rf|-fr|--recursive) — except /tmp, $TMPDIR
- find + (-delete|--delete)

Database:
- PostgreSQL: DROP DATABASE, TRUNCATE, dropdb
- MongoDB: dropDatabase, dropCollection, remove without criteria
- Redis: FLUSHALL, FLUSHDB, mass key deletion
- SQLite: DROP TABLE, DELETE without WHERE

Network:
- Bash(curl:*), Bash(wget:*) — default deny
- rsync + (--delete|--del|--delete-before|--delete-during|--delete-after|--delete-excluded|--delete-delay|--remove-source-files)

Privilege Escalation:
- chmod 777
- Recursive chmod/chown against system dirs

Git Destructive:
- git reset --hard, git reset --merge
- git clean -f, git clean --force
- git push --force, git push -f
- git checkout -- <path>, git restore (without --staged)
- git branch -D
- git stash drop, git stash clear

**Cross-source synthesis**: ✅ Yes
**YouTube content**: N/A (no YouTube source)
**Quality**: 4/5 — comprehensive categories, specific patterns, but no regex syntax (string patterns only)

---

## Q4: Insight Generation (Security Gaps)

**Query**: "What security gaps exist across all the frameworks discussed? What dangerous patterns are NOT covered by any of them?"
**Latency**: 29s
**Citations**: 8 sources referenced

**Gaps identified** (novel insights):

1. **Non-bash interpreter commands**: Python `shutil.rmtree()`, JS file ops — omamori explicitly out-of-scope
2. **Opaque script execution**: `./deploy.sh` — dcg doesn't inspect script internals
3. **Obfuscated commands**: base64 encoding, variable indirection — no static tool catches these
4. **50-subcommand bypass**: Claude Code skips all deny rules at >50 subcommands
5. **Windows WebDAV bypass**: `\\*` paths trigger network requests bypassing permissions (Claude Code-specific)
6. **Sudo PATH bypass**: shim-based tools (omamori) fail when agent uses sudo (PATH changes)
7. **Config poisoning**: All agents trust CLAUDE.md/config files → OWASP supply chain attack vector
8. **Semantic intent gaps**: Safe commands with wrong params (git commit with wrong files) — framework allows

**Cross-source synthesis**: ✅ Yes (synthesized across all 6 sources)
**YouTube content**: N/A
**Quality**: 5/5 — this is the "search can't do this" answer: cross-source gap analysis that identifies what NO framework covers
