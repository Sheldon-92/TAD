The Model Context Protocol (MCP) is an open standard introduced by Anthropic in November 2024 to standardize how AI systems, such as large language models, integrate and share data with external tools and data sources [[1]](https://en.wikipedia.org/wiki/Model_Context_Protocol). Following its announcement, the protocol saw rapid adoption by major AI providers, including OpenAI and Google DeepMind [[1]](https://en.wikipedia.org/wiki/Model_Context_Protocol). 

While MCP uses JSON-RPC 2.0 as its wire protocol and is fundamentally transport-agnostic—meaning it can be implemented over any communication channel that supports bidirectional message exchange—it officially defines specific standard transport mechanisms for client-server communication. 

### Current Standard Transport Mechanisms
As of the most recent specifications, MCP defines two standard transport mechanisms: **stdio** and **Streamable HTTP** [[2]](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports), [[3]](https://modelcontextprotocol.io/docs/concepts/transports).

#### 1. stdio (Standard Input/Output)
* **How it works:** The client launches the MCP server as a local subprocess. Communication occurs via standard input (stdin) and standard output (stdout) using newline-delimited JSON-RPC messages. 
* **Typical Use Cases:** Local development tools, IDE integrations, CLI-based assistants, and desktop applications.
* **Key Characteristics:** 
  * **Lifecycle & Topology:** Features a strict 1:1 client-to-server relationship where the server's lifecycle is tightly coupled to the client process.
  * **Security & Networking:** Requires no network configuration or port management, making it inherently secure with no network surface area.
  * **Session Management:** Implicit, based entirely on the lifetime of the subprocess.

#### 2. Streamable HTTP
* **How it works:** The server operates as an independent process capable of handling multiple concurrent clients. It exposes a single HTTP endpoint that accepts **POST** requests (for client-to-server messages) and **GET** requests (to optionally open a Server-Sent Events stream for server-to-client messages).
* **Typical Use Cases:** Remote or cloud-hosted MCP servers, web applications, SaaS integrations, and multi-client environments.
* **Key Characteristics:**
  * **Lifecycle & Topology:** Supports multiple concurrent clients connecting to a single independent server process.
  * **Infrastructure:** Works seamlessly over standard HTTP infrastructure, including proxies, load balancers, and CDNs.
  * **Session Management:** Explicit. The server may assign a session ID via an `Mcp-Session-Id` HTTP header, which the client must include in subsequent requests. Sessions can be cleanly terminated using an HTTP DELETE request.
  * **Streaming:** SSE is optional, allowing the transport to operate in a simple stateless request-response mode or a stateful streaming mode.

### Deprecated Transport: HTTP+SSE
The original November 2024 specification included a different network-based transport: **HTTP+SSE** [[4]](https://modelcontextprotocol.io/specification/2024-11-05/basic/transports). This older mechanism required two separate endpoints (one for establishing an SSE connection and one for HTTP POST requests) and mandated the use of SSE for all server-to-client communication. 

**Critical Reflection on Source Material:** 
Source [[4]](https://modelcontextprotocol.io/specification/2024-11-05/basic/transports) lists "HTTP with Server-Sent Events (SSE)" alongside stdio as the two standard transport mechanisms. However, this information is outdated. As of the updated 2025-03-26 specification, the HTTP+SSE transport has been officially deprecated and replaced by Streamable HTTP [[2]](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports), [[3]](https://modelcontextprotocol.io/docs/concepts/transports). Streamable HTTP was introduced to simplify the architecture by consolidating the two endpoints into one, making SSE optional rather than mandatory, and adding explicit session management. Therefore, while source [[4]](https://modelcontextprotocol.io/specification/2024-11-05/basic/transports) accurately reflects the original 2024-11-05 specification, it does not represent the current standard as of 2026.

### Custom Transports
Because MCP is fundamentally transport-agnostic, implementers are not strictly limited to the standardized mechanisms. Developers can create custom transport mechanisms—such as WebSocket-based transports, message queues, or gRPC bridges—to suit specific architectural needs, provided the underlying channel supports bidirectional JSON-RPC message exchange.

## Sources

[1] Model Context Protocol (source nr: 1)
   URL: https://en.wikipedia.org/wiki/Model_Context_Protocol

[2] Transports - Model Context Protocol (source nr: 2)
   URL: https://modelcontextprotocol.io/specification/2025-03-26/basic/transports

[3] Transports - Model Context Protocol (source nr: 3)
   URL: https://modelcontextprotocol.io/docs/concepts/transports

[4] Transports - Model Context Protocol (source nr: 4)
   URL: https://modelcontextprotocol.io/specification/2024-11-05/basic/transports




## Research Metrics
- Search Iterations: 8
- Generated at: 2026-07-02T16:12:32.808988+00:00