#!/usr/bin/env python3
"""Static file server with no-cache headers for Flutter Web entry assets."""

from __future__ import annotations

import http.server
import os
import socketserver
import sys

NO_CACHE_NAMES = frozenset({
    "index.html",
    "flutter_bootstrap.js",
    "flutter_service_worker.js",
    "main.dart.js",
    "version.json",
})


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        path = self.path.split("?", 1)[0]
        name = os.path.basename(path.rstrip("/")) or "index.html"
        if name in NO_CACHE_NAMES:
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
        super().end_headers()


def main() -> None:
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", "18027"))
    if len(sys.argv) >= 2:
        port = int(sys.argv[1])
    if len(sys.argv) >= 3:
        host = sys.argv[2]

    with socketserver.TCPServer((host, port), Handler) as httpd:
        print(f"Serving {os.getcwd()} on {host}:{port}", flush=True)
        httpd.serve_forever()


if __name__ == "__main__":
    main()
