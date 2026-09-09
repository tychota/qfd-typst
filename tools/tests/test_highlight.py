"""Exercise Typst highlighting with Unicode, escaped HTML, and multiple blocks."""
from html import escape, unescape
from pathlib import Path
import re
import sys
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from highlight import highlight_html

class HighlightTests(unittest.TestCase):
    def test_preserves_code_and_escapes_markup(self):
        snippets = ['#let café = "<script>alert(1)</script>"\n// électricité', '#qfd(matrix: ((9, 1),))']
        document = ''.join('<pre><code class="language-typst">' + escape(code) + '</code></pre>' for code in snippets)
        result = highlight_html(document)
        self.assertIn('<span style="color:', result)
        self.assertNotIn('<script>', result)
        texts = re.findall(r'<code class="language-typst">(.*?)</code>', result, re.S)
        self.assertEqual([unescape(re.sub('<[^>]+>', '', text)) for text in texts], snippets)

    def test_leaves_shell_blocks_untouched(self):
        document = '<pre><code>typst compile main.typ</code></pre>'
        self.assertEqual(highlight_html(document), document)
