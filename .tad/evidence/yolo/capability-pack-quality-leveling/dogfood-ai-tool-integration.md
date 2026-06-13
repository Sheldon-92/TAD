# Dogfood Judgment: AI Tool Integration Review (MCP wrapping plan)

Date: 2026-06-13
Task: Review a plan to wrap internal `git` + `curl` + destructive `delete_records` API + a third-party `analytics` MCP server as ONE MCP server. Tutorial used `server.tool(name, desc, schema, handler)`.

## Verdict: Answer 2 wins, CLEAR margin.

## WebSearch verification of key specifics

| Claim | Answer | Verdict | Source |
|-------|--------|---------|--------|
| `server.tool(...)` is deprecated; `registerTool(name, config, handler)` is current; config holds title/description/inputSchema/outputSchema/annotations | Both (A1 calls it "older"; A2 says deprecated 4-arg) | CORRECT | typescript-sdk docs/server.md, commit e9377fb "use registerTool instead of deprecated tool method" |
| SDK **v1.29.0** is current | A2 | CORRECT | npm @modelcontextprotocol/sdk 1.29.0, published 2026-03-30, still latest as of June 2026 |
| CVE-2025-54136 (MCPoison) + CVE-2025-54135 (CurXecute) = MCP tool-poisoning / rug-pull vectors | A2 | CORRECT | Check Point (MCPoison, disclosed Aug 5 2025), AIM Security (CurXecute, Aug 1 2025, CVSS 8.5) |
| Anthropic code-exec: 150K → 2K tokens, 98.7% drop | A2 | CORRECT | Anthropic "Code execution with MCP" (Nov 2025), Jones & Kelly |
| Agent-search: MCP up to 17x more tokens/call | A2 | CORRECT | earezki.com / Rabelo 2026 measurement (also Scalekit 4-32x) |
| 2025-06-18 spec: OAuth 2.1 + PKCE mandatory; `resource` param RFC 8707 now a MUST; PRM RFC 9728; client sends MCP-Protocol-Version | A2 | CORRECT | modelcontextprotocol.io/specification/2025-06-18/basic/authorization |
| Annotation defaults: `destructiveHint` defaults true, `readOnlyHint` defaults false | A2 | CORRECT | MCP blog 2026-03-16 tool-annotations; ToolAnnotations interface |
| STDIO: stdout is the JSON-RPC channel, use console.error not console.log | A2 | CORRECT | well-documented MCP stdio gotcha |
| SSRF metadata endpoint 169.254.169.254, file://, command injection via exec vs execFile/argv | A1 | CORRECT | standard SSRF/cloud-metadata + Node child_process guidance |
| `registerTool(name, {description, inputSchema, annotations}, handler)` shape | A1 | CORRECT | matches SDK |

### Wrong specifics found: NONE in either answer.

Both answers are specific AND accurate. This is not a case where one answer was punished for confident-wrong specifics. Answer 2 simply carried MORE correct, verifiable specifics (versions, CVE IDs, RFC numbers, benchmark figures, protocol-version string) without a single miss.

## Dimension scoring

### Answer 1
- Correctness 5: every claim accurate; no errors. Strong on SSRF/command-injection/argv, the supply-chain "don't proxy" argument, and annotations-are-advisory-not-enforcement.
- Actionability 4: gives a clean recommended plan; names execFile/Zod/allowlist. Slightly less directly checklist-able than A2.
- Specificity 3: correct but more general — names the SDK methods and 169.254.169.254 but no version pins, no CVE IDs, no RFC numbers, no quantified token cost.
- Completeness 4: covers the 4 big issues well. Misses: read/write IAM blast-radius separation, OAuth 2.1/PKCE for remote transport, the "don't even wrap git/curl — the LLM knows them, use Bash" CLI-first argument, annotation defaults.

### Answer 2
- Correctness 5: every verified specific is correct, including hard-to-recall ones (v1.29.0, two CVE numbers, RFC 8707/9728, 2025-06-18, 98.7%/17x). No wrong claims.
- Actionability 5: P0/P1/P2 triage, an annotation audit table, explicit annotation values, concrete next steps per tool. Immediately executable.
- Specificity 5: maximally specific and all of it checks out.
- Completeness 5: adds the two load-bearing dimensions A1 missed — (a) CLI-first: don't wrap git/curl at all because the LLM already knows them and MCP defs cost static context (the 98.7%/17x argument), and (b) read/write server + scoped-IAM blast-radius separation. Also covers remote OAuth, schema strictness (.strict()), output caps, stdio console.error.

## Rationale

Both answers correctly reject the single-server design, correctly refuse to proxy the untrusted third-party `analytics` server, and correctly flag `delete_records` needs a HITL/destructive gate and that `server.tool` is the old signature. So on the CORE judgment they agree and both are right.

Answer 2 wins on three substantive (not cosmetic) advantages:
1. **The CLI-first insight A1 entirely missed.** A1 assumes git/curl SHOULD be wrapped (just narrowly/safely). A2 makes the stronger and more correct architectural call: the LLM already knows git and curl, so wrapping them as MCP just burns static context (verified 17x/98.7% argument) — invoke via Bash, and only `delete_records` (internal, unknown-to-LLM, destructive) actually justifies a wrapper. This is the better answer to "review the plan," because the plan's premise (wrap all four) is itself wrong, and only A2 challenges it.
2. **Blast-radius / read-write IAM separation.** A2 splits destructive `delete_records` onto its own server with its own scoped role so a compromise of a read tool can't inherit delete authority. A1 keeps git/curl/delete on one first-party server.
3. **Density of CORRECT specifics** — versions, CVEs, RFCs, protocol version, annotation defaults — every one verified true. This is winning on correct specifics, NOT verbosity.

Risk on A2: the rule-ID citations ([Rule X7], [Rule M4], etc.) are unverifiable internal references and read as scaffolding; if any rule ID mapped to a wrong claim it would be a problem, but the substantive claims behind them all verified. They neither add nor subtract correctness.

A1 is genuinely excellent and would be a fine standalone review — tighter prose, no internal-jargon leakage. It loses only because A2 is correct about MORE (the CLI-first premise challenge + IAM separation) while making zero factual errors.

Winner: 2. Margin: clear (not decisive — A1 is strong and error-free; A2's edge is real architectural coverage + verified specific density, not a correctness gap).
