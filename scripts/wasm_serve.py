#!/usr/bin/env python3
"""Local static file server for WASM with cross-origin isolation headers."""

from __future__ import annotations

import argparse
import functools
import http.server


class WasmCoiHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        # Required for SharedArrayBuffer on modern Chromium.
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        super().end_headers()


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve WASM dist with COOP/COEP headers")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--dir", dest="directory", required=True)
    args = parser.parse_args()

    handler = functools.partial(WasmCoiHandler, directory=args.directory)
    with http.server.ThreadingHTTPServer((args.host, args.port), handler) as httpd:
        print(f"Serving {args.directory} on http://{args.host}:{args.port}/")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
