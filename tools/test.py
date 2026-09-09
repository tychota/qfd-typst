#!/usr/bin/env python3
"""Compile semantic/layout fixtures and verify rejected inputs with the real CLI.

Every subprocess result is checked. A missing compiler or warning is a failed
check, not a fallback to source inspection. Outputs stay under build/.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def compile_file(compiler: str, source: Path, output: Path) -> None:
    result = subprocess.run([compiler, "compile", "--root", str(ROOT),
        "--font-path", str(ROOT / "fonts"), "--ignore-system-fonts", str(source), str(output)],
        capture_output=True, text=True)
    if result.returncode or result.stderr:
        raise RuntimeError(f"{source.name}:\n{result.stderr}")

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typst", default="typst")
    args = parser.parse_args()
    compiler = shutil.which(args.typst)
    if compiler is None:
        raise RuntimeError("Typst CLI not found; install Typst 0.15.1 or newer")
    build = ROOT / "build" / "tests"
    build.mkdir(parents=True, exist_ok=True)
    for source in sorted((ROOT / "tests").glob("*.typ")):
        compile_file(compiler, source, build / f"{source.stem}.pdf")
        print(f"PASS {source.name}")
    cases = json.loads((ROOT / "tests" / "invalid.json").read_text())
    with tempfile.TemporaryDirectory(prefix="invalid-", dir=build) as directory:
        for name, body, message in cases:
            source = Path(directory) / f"{name}.typ"
            source.write_text('#import "/lib.typ": *\n' + body)
            result = subprocess.run([compiler, "compile", "--root", str(ROOT),
                "--font-path", str(ROOT / "fonts"), str(source), str(source.with_suffix(".pdf"))],
                capture_output=True, text=True)
            if result.returncode == 0 or message not in result.stderr:
                raise RuntimeError(f"{name}: expected rejection containing {message!r}:\n{result.stderr}")
    print(f"PASS {len(cases)} rejected-input cases")
    for name in ("minimal", "espresso", "components", "revisions", "report", "profiles"):
        source = ROOT / "examples" / f"{name}.typ"
        compile_file(compiler, source, build / f"{name}.pdf")
    print("PASS all public examples")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, OSError) as error:
        print(f"FAIL {error}", file=sys.stderr)
        sys.exit(1)
