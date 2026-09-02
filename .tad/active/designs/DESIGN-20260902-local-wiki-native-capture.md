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

`launch` starts installed Chrome with `--remote-debugging-port=9223`, loopback binding, and a
dedicated user-data directory. `capture` never starts or kills a browser implicitly. Existing
process ownership remains clear. `tabs`/`capture` reject non-page/devtools targets and unsafe
CDP endpoints. Tests use a fake local CDP server; live proof uses a temporary profile/port.

## Scope discipline

No external extension code is imported or loaded. The earlier project may be cited as prior
art, but there is no runtime path, filesystem lookup, or installation instruction pointing
to it. One public YouTube probe is sufficient; authenticated-page behavior uses a local
rendered fixture because no private source was supplied.

