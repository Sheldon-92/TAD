#!/usr/bin/env python3
"""bridge-client.py — thin CLI the terminal Claude uses to talk to the bridge.

So the terminal loop never hand-writes HTTP. STDLIB ONLY.

Commands:
  poll          GET /poll (long-poll, ≤25s server block) -> prints the message
                JSON on a message, `IDLE` on timeout, `SESSION_CLOSED` on close.
  reply "<text>"  POST /reply {text} -> pushes an AI reply to the browser (SSE).
  close         POST /close -> ends the session; server shuts down + frees port.

Connection: token + port come from --token/--port (or COREAD_TOKEN/COREAD_PORT
env). Client socket timeout = 30s, deliberately LONGER than the server's 25s
long-poll so the client never kills the connection before the server returns IDLE
(handoff §4.2 invariant 3).
"""
import argparse
import json
import os
import sys
from http.client import HTTPConnection

CLIENT_TIMEOUT = 30          # MUST be > server POLL_TIMEOUT (25)


def _conn(port):
    return HTTPConnection("127.0.0.1", port, timeout=CLIENT_TIMEOUT)


def _headers(token, with_body=False):
    h = {"Host": "127.0.0.1:%d" % _PORT, "X-Coread-Token": token}
    if with_body:
        h["Content-Type"] = "application/json"
    return h


_PORT = 0  # set in main()


def cmd_poll(token, port):
    c = _conn(port)
    try:
        c.request("GET", "/poll", headers={"Host": "127.0.0.1:%d" % port,
                                           "X-Coread-Token": token})
        r = c.getresponse()
        data = r.read().decode("utf-8", "replace")
    finally:
        c.close()
    try:
        obj = json.loads(data)
    except ValueError:
        sys.stderr.write("poll: bad response (%s): %s\n" % (r.status, data))
        return 1
    t = obj.get("type")
    if t == "message":
        sys.stdout.write(json.dumps(obj) + "\n")
    elif t == "closed":
        sys.stdout.write("SESSION_CLOSED\n")
    else:
        sys.stdout.write("IDLE\n")
    return 0


def cmd_reply(token, port, text):
    body = json.dumps({"text": text}).encode("utf-8")
    c = _conn(port)
    try:
        c.request("POST", "/reply", body=body,
                  headers={"Host": "127.0.0.1:%d" % port,
                           "X-Coread-Token": token,
                           "Content-Type": "application/json"})
        r = c.getresponse()
        data = r.read().decode("utf-8", "replace")
    finally:
        c.close()
    if r.status != 200:
        sys.stderr.write("reply failed (%d): %s\n" % (r.status, data))
        return 1
    sys.stdout.write("OK\n")
    return 0


def cmd_close(token, port):
    c = _conn(port)
    try:
        c.request("POST", "/close", body=b"{}",
                  headers={"Host": "127.0.0.1:%d" % port,
                           "X-Coread-Token": token,
                           "Content-Type": "application/json"})
        r = c.getresponse()
        r.read()
    except Exception as e:
        # server may drop the connection as it shuts down — treat as closed
        sys.stdout.write("CLOSED\n")
        return 0
    finally:
        c.close()
    sys.stdout.write("CLOSED\n" if r.status == 200 else "CLOSE_FAILED\n")
    return 0 if r.status == 200 else 1


def cmd_append_thread(state_path, role, text, anchor_json=""):
    """Append one {role,text,anchor?,ts} turn to reading-state.json thread[] (FR7).

    Atomic write (tmp + os.replace) so a concurrent render.py never sees a torn
    file (§10.4 thread-write race). This is the ONLY file write the least-agency
    co-read loop is permitted to do.
    """
    import json as _json
    import time as _time
    try:
        with open(state_path, "r", encoding="utf-8") as f:
            state = _json.load(f)
    except (OSError, ValueError):
        state = {}
    if not isinstance(state, dict):
        state = {}
    state.setdefault("thread", [])
    turn = {"role": role, "text": text,
            "ts": _time.strftime("%Y-%m-%dT%H:%M:%SZ", _time.gmtime())}
    if anchor_json:
        try:
            turn["anchor"] = _json.loads(anchor_json)
        except ValueError:
            pass
    state["thread"].append(turn)
    tmp = state_path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        _json.dump(state, f, ensure_ascii=False, indent=2)
    os.replace(tmp, state_path)
    sys.stdout.write("APPENDED thread len=%d\n" % len(state["thread"]))
    return 0


def main(argv=None):
    global _PORT
    ap = argparse.ArgumentParser(description="Co-Read bridge client CLI")
    ap.add_argument("command", choices=["poll", "reply", "close", "append-thread"])
    ap.add_argument("text", nargs="?", default="", help="reply text (reply) / turn text (append-thread)")
    ap.add_argument("--token", default=os.environ.get("COREAD_TOKEN", ""))
    ap.add_argument("--port", type=int, default=int(os.environ.get("COREAD_PORT", "0")))
    ap.add_argument("--state", default="", help="reading-state.json path (append-thread)")
    ap.add_argument("--role", default="user", choices=["user", "assistant"],
                    help="turn role (append-thread)")
    ap.add_argument("--anchor", default="", help="anchor JSON (append-thread, optional)")
    args = ap.parse_args(argv)

    # append-thread is a local file op — no token/port needed.
    if args.command == "append-thread":
        if not args.state or not args.text:
            sys.stderr.write("append-thread needs --state and text\n")
            return 2
        return cmd_append_thread(args.state, args.role, args.text, args.anchor)

    if not args.token or not args.port:
        sys.stderr.write("need --token and --port (or COREAD_TOKEN / COREAD_PORT env)\n")
        return 2
    _PORT = args.port

    if args.command == "poll":
        return cmd_poll(args.token, args.port)
    if args.command == "reply":
        if not args.text:
            sys.stderr.write("reply needs text\n")
            return 2
        return cmd_reply(args.token, args.port, args.text)
    if args.command == "close":
        return cmd_close(args.token, args.port)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
