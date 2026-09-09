"""Highlight marked code blocks with Typst's own parser at build time."""
from html import unescape
from pathlib import Path
import re
import subprocess
import tempfile

BLOCK = re.compile(r'(<code class="language-typst">)(.*?)(</code>)', re.DOTALL)
OUTPUT = re.compile(r'<code data-lang="typst">(.*?)</code>', re.DOTALL)


def highlight_html(document: str, compiler: str = "typst") -> str:
    blocks = list(BLOCK.finditer(document))
    if not blocks:
        return document
    # Code is read as raw text, never interpolated into executable Typst source.
    with tempfile.TemporaryDirectory(prefix="qualitree-highlight-") as directory:
        root = Path(directory)
        for index, block in enumerate(blocks):
            (root / f"{index}.txt").write_text(unescape(block.group(2)), encoding="utf-8")
        source = root / "highlight.typ"
        source.write_text("\n".join(
            f'#raw(read("{index}.txt"), lang: "typst", block: true)'
            for index in range(len(blocks))), encoding="utf-8")
        output = root / "highlight.html"
        result = subprocess.run([compiler, "compile", "--features", "html", "--format", "html",
            str(source), str(output)], capture_output=True, text=True)
        if result.returncode:
            raise RuntimeError(f"Typst syntax highlighting failed: {result.stderr}")
        rendered = OUTPUT.findall(output.read_text(encoding="utf-8"))
    if len(rendered) != len(blocks):
        raise RuntimeError("Typst HTML output changed: missing highlighted code blocks")
    for block, content in zip(blocks, rendered):
        if unescape(re.sub(r"<[^>]+>", "", content)) != unescape(block.group(2)):
            raise RuntimeError("Highlighting changed the code text")
    fragments = iter(rendered)
    return BLOCK.sub(lambda block: block.group(1) + next(fragments) + block.group(3), document)
