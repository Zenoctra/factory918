#!/usr/bin/env python3
"""Local pass-through between a replay's Claude Code and api.anthropic.com.

    proxy.py <port> <logdir|-> [--keep-sandbox-note]

replay.py starts one per run and points the CLI at it with ANTHROPIC_BASE_URL.
Every request goes on to https://api.anthropic.com with the CLI's own headers
(its subscription login); this script never writes a header to disk.

It does two things to the traffic:

- Removes the "## Bash command sandbox" section the CLI adds when the OS sandbox
  is on (on a resumed session, as a system message after the prompt). The sessions being replayed ran without the sandbox, so that text would be
  the one thing in the replay's context the original never had, placed right
  after the prompt. The sandbox itself stays on; only its description goes.
  --keep-sandbox-note turns this off.
- With a logdir, writes each request body to <n>-req.json (after the removal,
  so it is exactly what the model saw) and each response to <n>-resp.txt.
"""
import http.client
import http.server
import json
import os
import re
import sys
import threading

UPSTREAM = "api.anthropic.com"
PORT = int(sys.argv[1])
LOGDIR = None if sys.argv[2] == "-" else sys.argv[2]
KEEP_NOTE = "--keep-sandbox-note" in sys.argv
NOTE_HEAD = "## Bash command sandbox"
if LOGDIR:
    os.makedirs(LOGDIR, exist_ok=True)
_lock = threading.Lock()
_n = [0]
HOP = {"connection", "keep-alive", "transfer-encoding", "proxy-connection", "upgrade", "host", "content-length"}
DROP = HOP | {"accept-encoding"}  # an uncompressed answer keeps the log readable


def _next():
    with _lock:
        _n[0] += 1
        return _n[0]


SECTION = re.compile(r"(?ms)^## Bash command sandbox\n.*?(?=^#{1,2} |\Z)")
DATE = re.compile(r"The date has changed\. Today's date is now [^\n]*\n?")
LOST_TASK = re.compile(r"(?s)<task-notification>.*?before the previous session ended.*?</task-notification>")


def strip_sandbox_note(body):
    """Cut the sandbox section and the date-change line out of every text block of the system prompt and the
    messages; drop a block, or a message, the cut leaves empty."""
    removed = 0

    def cut(text):
        nonlocal removed
        new, k = SECTION.subn("", text)
        new, d = DATE.subn("", new)
        removed += k + d
        if LOST_TASK.search(new):  # the whole reminder that carries it goes
            removed += 1
            return ""
        return new

    for s in body.get("system", []) if isinstance(body.get("system"), list) else []:
        if s.get("type") == "text":
            s["text"] = cut(s["text"])
    msgs = []
    for m in body.get("messages", []):
        c = m.get("content")
        if isinstance(c, str):
            c = cut(c)
            if c.strip():
                msgs.append({**m, "content": c})
            continue
        keep = []
        for blk in c or []:
            if blk.get("type") == "text":
                blk = {**blk, "text": cut(blk["text"])}
                if not blk["text"].strip():
                    continue
            keep.append(blk)
        if keep:
            msgs.append({**m, "content": keep})
    body["messages"] = msgs
    return removed


class H(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *a):
        pass

    def _forward(self):
        n = _next()
        length = int(self.headers.get("content-length") or 0)
        raw = self.rfile.read(length) if length else b""
        body, removed = None, 0
        try:
            body = json.loads(raw) if raw else None
        except ValueError:
            pass
        if isinstance(body, dict) and not KEEP_NOTE:
            removed = strip_sandbox_note(body)
            if removed:
                raw = json.dumps(body).encode()
        if LOGDIR:
            with open(os.path.join(LOGDIR, f"{n:04d}-req.json"), "w") as f:
                json.dump({"method": self.command, "path": self.path, "sandbox_note_blocks_removed": removed,
                           "body": body}, f)
        headers = {k: v for k, v in self.headers.items() if k.lower() not in DROP}
        conn = http.client.HTTPSConnection(UPSTREAM, timeout=900)
        conn.request(self.command, self.path, body=raw, headers=headers)
        resp = conn.getresponse()
        self.send_response(resp.status)
        for k, v in resp.getheaders():
            if k.lower() not in HOP:
                self.send_header(k, v)
        self.send_header("Transfer-Encoding", "chunked")
        self.send_header("Connection", "close")
        self.end_headers()
        out = open(os.path.join(LOGDIR, f"{n:04d}-resp.txt"), "wb") if LOGDIR else None
        if out:
            out.write(f"HTTP {resp.status}\n".encode())
        while True:
            chunk = resp.read1(65536)
            if not chunk:
                break
            if out:
                out.write(chunk)
            self.wfile.write(b"%x\r\n%s\r\n" % (len(chunk), chunk))
            self.wfile.flush()
        if out:
            out.close()
        self.wfile.write(b"0\r\n\r\n")
        self.wfile.flush()
        self.close_connection = True

    do_GET = do_POST = do_PUT = do_DELETE = do_PATCH = _forward


http.server.ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
