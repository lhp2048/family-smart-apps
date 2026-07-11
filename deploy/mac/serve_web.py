#!/usr/bin/env python3
"""Static file server with tiered cache headers for Flutter Web."""

from __future__ import annotations

import http.server
import os
import socketserver
import sys

# Entry / version probes: revalidate each visit, but allow storing for 304.
NO_CACHE_NAMES = frozenset({
    "index.html",
    "flutter_bootstrap.js",
    "flutter_service_worker.js",
    "version.json",
    "manifest.json",
    "family-product.json",
    "main.dart.js",
    "pdfjs_loader.js",
})

# Large build artifacts: cache aggressively; entry HTML/JS above must revalidate.
LONG_CACHE_NAMES = frozenset({
    "flutter.js",
    "canvaskit.js",
    "canvaskit.wasm",
    "skwasm.js",
    "skwasm.wasm",
    "skwasm_heavy.js",
    "skwasm_heavy.wasm",
    "wimp.js",
})

LONG_CACHE_SUFFIXES = (
    ".wasm",
    ".js",
    ".mjs",
    ".symbols",
    ".otf",
    ".ttf",
    ".frag",
    ".bin",
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".ico",
    ".json",
)

LONG_CACHE_DIR_PREFIXES = (
    "assets/",
    "canvaskit/",
    "icons/",
    "splash/",
    "js/",
)

ONE_YEAR = "31536000"


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        path = self.path.split("?", 1)[0]
        rel = path.lstrip("/")
        name = os.path.basename(rel.rstrip("/")) or "index.html"

        if name in NO_CACHE_NAMES:
            self.send_header("Cache-Control", "no-cache, must-revalidate")
            self.send_header("Pragma", "no-cache")
        elif _should_long_cache(rel, name):
            self.send_header("Cache-Control", f"public, max-age={ONE_YEAR}, immutable")
        super().end_headers()


def _should_long_cache(rel_path: str, name: str) -> bool:
    if name in LONG_CACHE_NAMES:
        return True
    lower = rel_path.lower()
    if any(lower.startswith(prefix) for prefix in LONG_CACHE_DIR_PREFIXES):
        return True
    return lower.endswith(LONG_CACHE_SUFFIXES)


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
