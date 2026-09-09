# QFD implementation plan

Spec: [DESIGN.md](DESIGN.md). Native Typst 0.15.1; Python standard-library build tools; no runtime package dependencies.

- [x] Preserve the generic calculation and layout fixtures; add failing tests for stage ID alignment, unrounded deployment, zero totals, changed/removed relationships, and bounded staggering.
- [x] Extract calculations and theme, implement stage/deployment/diff helpers, then pass the numerical fixtures.
- [x] Extract symbols/layout, measure automatic header and row heights, add directions and revision backgrounds, and use displaced points consistently for markers and lines.
- [x] Compile visual fixtures for dense labels, small charts, all change states and overlapping series; inspect PDF and SVG output.
- [x] Develop the coffee needs/functions/components example and record assumptions and source attribution in its design notes.
- [x] Write installation, Typst quickstart, API and maintenance docs, generate HTML and set up test/Pages workflows.
- [ ] Commit, push, deploy Pages and submit the verified Typst bundle.
