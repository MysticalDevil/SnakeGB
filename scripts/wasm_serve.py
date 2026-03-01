#!/usr/bin/env python3
from pathlib import Path
import runpy

runpy.run_path(Path(__file__).resolve().parent / "deploy" / "wasm_serve.py", run_name="__main__")
