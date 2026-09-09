#!/usr/bin/env python3
"""Install the runtime for the local Typst CLI without changing fonts or examples."""
import argparse
import os
from pathlib import Path
import shutil
import sys
import tomllib
from package import ROOT, copy_files, runtime_files

def default_root() -> Path:
    if sys.platform == "darwin":
        return Path.home() / "Library/Application Support/typst/packages"
    if sys.platform == "win32":
        return Path(os.environ["APPDATA"]) / "typst/packages"
    return Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")) / "typst/packages"

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-root", type=Path, default=default_root())
    parser.add_argument("--replace", action="store_true", help="Replace this exact installed version")
    args = parser.parse_args()
    package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    destination = args.package_root / "local" / package["name"] / package["version"]
    if destination.exists() and not args.replace:
        parser.error(f"Already installed: {destination}. Use --replace explicitly.")
    if destination.exists():
        shutil.rmtree(destination)
    copy_files(destination, runtime_files())
    print(destination)

if __name__ == "__main__":
    main()
