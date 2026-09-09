#!/usr/bin/env python3
"""Render source-controlled examples and refresh the documentation previews."""
from pathlib import Path
import subprocess
from test import compile_file

ROOT = Path(__file__).resolve().parents[1]

def main() -> None:
    output = ROOT / "build" / "examples"
    output.mkdir(parents=True, exist_ok=True)
    assets = ROOT / "docs" / "site" / "assets"
    for name in ("minimal", "espresso", "components", "revisions", "revision-components", "milk-automatic", "milk-detailed", "report", "profiles"):
        for extension in (("pdf",) if name in ("report", "milk-automatic", "milk-detailed") else ("pdf", "svg")):
            destination = (assets if name in ("espresso", "components", "revisions", "revision-components", "milk-automatic", "milk-detailed", "profiles") else output) / f"{name}.{extension}"
            compile_file("typst", ROOT / "examples" / f"{name}.typ", destination)
    print("Rendered PDF and SVG examples")

if __name__ == "__main__":
    main()
