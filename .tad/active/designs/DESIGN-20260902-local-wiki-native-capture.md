# Design — Local Wiki Native Browser Capture

## Architecture

`browser-capture.mjs` has four small layers:

1. CLI/parser: `launch`, `tabs`, `capture`; strict flags and concise JSON/text output.
2. CDP transport: loopback-only HTTP discovery plus request-id WebSocket client with timeout,
   pending-request rejection on close, maximum result size, and no event logging.
3. Page extractors: self-contained functions serialized into `Runtime.evaluate`.
4. Publication adapter: writes a private 0600 temporary extension-format Markdown file,
   calls the checked-in `import-clip.py`, then removes the temporary in `finally`.

## Page capture

Choose `main`, `article`, `[role=main]`, or `body`; clone it; remove script/style/nav/header/
footer/form/button/noscript/iframe. A bounded DOM walker converts headings, paragraphs,
lists, blockquotes, pre/code, links, and line breaks to Markdown. The result includes only
`document.title`, `location.href`, optional description, and body Markdown. It does not read
cookies, storage, network headers, hidden browser files, or unrendered responses.

## YouTube capture

Accept only HTTPS YouTube watch/short URLs. Discover `ytInitialPlayerResponse` from the page
global or bounded script scan, select a requested language or prefer manual/default track,
and fetch the trusted `/api/timedtext` URL inside the page context as JSON3. Validate exact
host/path and 5 MiB/event limits. Merge fragments into timestamped paragraphs. If direct
page-context fetch fails, return a clear first-use error; do not add interception or anti-bot
machinery until a real failure demonstrates the need.

## Browser lifecycle

`launch` starts installed Chrome with `--remote-debugging-address=127.0.0.1`, a random port
(`--remote-debugging-port=0`), and a dedicated user-data directory. A 0600 ownership record
inside a 0700 profile binds the TAD marker, canonical path, PID, port, and start time. Existing
marked profiles may be reused; unmarked/pre-existing or known default Chrome profiles are
rejected. An occupied explicit port fails before launch. `capture` never starts or kills a
browser implicitly. Explicit `--port` connections are external and require exact `--tab`.

Only a unique eligible page may be captured without `--tab`; multiple eligible targets fail
closed. Discovery is repeated immediately before extraction and the page extractor checks
its current URL and kind against structured expected arguments. Fixed function declarations
are invoked with `Runtime.callFunctionOn`; no CLI value is concatenated into JavaScript.

Deterministic tests use an injected `CdpTransport` seam and the actual publication adapter,
not a fake WebSocket implementation. Transport framing/close behavior is tested at the client
unit boundary; a real temporary Chrome covers the actual WebSocket/CDP integration.

## Scope discipline

No external extension code is imported or loaded. The earlier project may be cited as prior
art, but there is no runtime path, filesystem lookup, or installation instruction pointing
to it. One public YouTube probe is sufficient; authenticated-page behavior uses a local
rendered fixture because no private source was supplied.

## Frozen bounds

- CDP/connect/extract timeout: 15 seconds per operation.
- WebSocket message and returned UTF-8 payload: 6 MiB and 5 MiB respectively.
- DOM traversal: 50,000 nodes; output: 5 MiB UTF-8.
- Player scan: at most 50 scripts and 5 MiB per candidate script.
- Subtitle payload: 5 MiB and at most 100,000 events.
- Language: 2–3 ASCII letters plus optional 2–8 alphanumeric subtags, total ≤35 chars.
