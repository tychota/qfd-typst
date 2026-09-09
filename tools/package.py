#!/usr/bin/env python3
"""Build a small registry bundle from an explicit public-file allowlist."""
from pathlib import Path
import shutil
import tomllib

ROOT = Path(__file__).resolve().parents[1]

def runtime_files() -> list[Path]:
    return [ROOT / name for name in ("lib.typ", "typst.toml", "LICENSE")] + sorted((ROOT / "src").glob("*.typ"))

def package_files() -> list[Path]:
    return runtime_files() + [ROOT / "README.md", ROOT / "CONTEXT.md", ROOT / "CONTRIBUTING.md"] + sorted((ROOT / "examples").glob("*.typ")) + [ROOT / "examples" / "COFFEE.md"]

def copy_files(destination: Path, files: list[Path]) -> None:
    for source in files:
        target = destination / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)

def main() -> None:
    package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    destination = ROOT / "build" / "packages" / "preview" / package["name"] / package["version"]
    if destination.exists():
        shutil.rmtree(destination)
    copy_files(destination, package_files())
    # Registry README links resolve to source-hosted assets excluded from the bundle.
    readme = destination / "README.md"
    base = package["repository"] + "/blob/main/"
    text = readme.read_text()
    for prefix in ("docs/", "examples/"):
        text = text.replace('src="' + prefix, 'src="' + base + prefix)
        text = text.replace('](' + prefix, '](' + base + prefix)
    for name in ("CONTEXT.md", "CONTRIBUTING.md", "DESIGN.md", "PLAN.md"):
        text = text.replace("](" + name + ")", "](" + base + name + ")")
    readme.write_text(text)
    print(destination)

if __name__ == "__main__":
    main()
