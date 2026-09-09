#!/usr/bin/env python3
"""Validate and copy the static documentation to a GitHub Pages artifact.

Run after generating docs/site/assets/{espresso,components,revisions}.{svg,pdf}.
Uses only the Python standard library; no frontend package installation required.
"""
from __future__ import annotations

import argparse
from html.parser import HTMLParser
from pathlib import Path
import shutil
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "site"


class References(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.duplicates: set[str] = set()
        self.references: list[str] = []
        self.errors: list[str] = []

    def handle_starttag(self, tag: str, attributes: list[tuple[str, str | None]]) -> None:
        attrs = dict(attributes)
        if identifier := attrs.get("id"):
            if identifier in self.ids:
                self.duplicates.add(identifier)
            self.ids.add(identifier)
        for attribute in ("href", "src"):
            if value := attrs.get(attribute):
                self.references.append(value)
        if tag == "img" and "alt" not in attrs:
            self.errors.append("Image lacks alt text")


def validate(source: Path) -> list[str]:
    documents: dict[Path, References] = {}
    errors: list[str] = []
    for path in source.rglob("*.html"):
        parser = References()
        parser.feed(path.read_text(encoding="utf-8"))
        documents[path.resolve()] = parser
        errors.extend(f"{path.name}: {message}" for message in parser.errors)
        errors.extend(f"{path.name}: duplicate ID {identifier}" for identifier in parser.duplicates)
    for path, parser in documents.items():
        for reference in parser.references:
            parsed = urlsplit(reference)
            if parsed.scheme or parsed.netloc:
                continue
            if parsed.path.startswith("/"):
                errors.append(f"{path.name}: root-relative URL breaks project Pages: {reference}")
                continue
            target = (path.parent / unquote(parsed.path)).resolve() if parsed.path else path
            if target.is_dir():
                target /= "index.html"
            if not target.is_relative_to(source.resolve()):
                errors.append(f"{path.name}: URL leaves site: {reference}")
            elif not target.is_file():
                errors.append(f"{path.name}: missing local target: {reference}")
            elif parsed.fragment and target in documents:
                if unquote(parsed.fragment) not in documents[target].ids:
                    errors.append(f"{path.name}: missing anchor: {reference}")
    return errors


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "build" / "site")
    parser.add_argument("--check", action="store_true", help="Validate without copying files")
    arguments = parser.parse_args()
    errors = validate(SOURCE)
    if errors:
        raise SystemExit("Documentation validation failed:\n" + "\n".join(errors))
    if arguments.check:
        print("Documentation references and image alternatives are valid.")
        return
    destination = arguments.output.resolve()
    if destination == SOURCE.resolve() or SOURCE.resolve().is_relative_to(destination) or destination.is_relative_to(SOURCE.resolve()):
        raise SystemExit("Output must be separate from the documentation source.")
    destination.mkdir(parents=True, exist_ok=True)
    shutil.copytree(SOURCE, destination, dirs_exist_ok=True)
    (destination / ".nojekyll").touch()
    print(f"Documentation built: {destination}")


if __name__ == "__main__":
    main()
