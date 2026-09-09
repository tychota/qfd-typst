TYPST ?= typst
PYTHON ?= python3
.PHONY: test examples docs package

test:
	$(PYTHON) tools/test.py --typst $(TYPST)

examples:
	$(PYTHON) tools/build_examples.py

docs: examples
	$(PYTHON) tools/build_docs.py

package:
	$(PYTHON) tools/package.py
