# Source 5: https://en.wikipedia.org/wiki/Model_Context_Protocol
# Fetched: 2026-07-02
# Purpose: A/B evaluation ground truth (judge reference)

# Model Context Protocol

**Model Context Protocol** (**MCP**) is an open standard and open-source framework developed by Anthropic in November 2024. It standardizes how AI systems like large language models integrate and share data with external tools, systems, and data sources.

## Background

Anthropic announced MCP as a solution to the challenge of information silos and legacy systems. Before MCP, developers typically had to build custom connectors for each data source, creating an "N x M" data integration problem. The protocol was created by engineers David Soria Parra and Justin Spahr-Summers at Anthropic.

Earlier approaches like OpenAI's 2023 function-calling API and ChatGPT's plugin framework addressed similar problems but required vendor-specific connectors. MCP reuses the message-flow concepts from the Language Server Protocol.

In December 2025, Anthropic donated MCP to the Agentic AI Foundation (AAIF), a directed fund under the Linux Foundation, co-founded by Anthropic, Block, and OpenAI.

## Features

MCP defines a standardized framework for integrating AI systems with external data sources and tools. The protocol distinguishes between three components:

- **MCP hosts**: typically an AI agent interacting with an LLM
- **MCP clients**: communicate with MCP servers on behalf of the host
- **MCP servers**: provide tools or resources

Each server provides tools (database access, calculators, code repositories) or resources (FAQ documents). The MCP client requests available tools and resources; the server responds with natural-language descriptions. This information goes to the LLM, which can request tool execution through the MCP client. Results are injected back into the conversation.

Client and server communicate using JSON-RPC 2.0. The protocol includes SDKs in Python, TypeScript, C#, and Java with example server implementations.

MCP is used in AI-assisted software development. IDEs, platforms like Replit, and code intelligence tools like Sourcegraph have adopted it to grant AI coding assistants real-time access to project context.

**MCP Apps** is an official extension standardizing delivery of interactive user interfaces — dashboards, forms, data visualizations — from MCP servers to applications like Claude and ChatGPT.

## Adoption

OpenAI officially adopted MCP in March 2025 after integrating it across products including the ChatGPT desktop app. In September 2025, OpenAI added MCP support to ChatGPT apps, enabling third-party access.

MCP can integrate with Microsoft Semantic Kernel and Azure OpenAI. MCP servers can deploy to Cloudflare.

In April 2026, the AAIF held the MCP Dev Summit North America in New York City, drawing approximately 1,200 attendees.

## Reception

The Verge reported that MCP addresses growing demand for contextually aware AI agents pulling from diverse sources.

In April 2025, security researchers identified multiple outstanding security issues, including prompt injection and poisoned tools enabling data exfiltration through connected tools.

MCP has been likened to OpenAPI, a similar specification describing APIs.

## See Also

- Agent2Agent
- AI governance
- Application programming interface
- LangChain
- Machine learning
- Software agent
