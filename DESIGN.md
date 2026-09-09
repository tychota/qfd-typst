# Reusable QFD package design

The package renders relationships between named sets: needs, functions, components, or technical characteristics. The low-level `qfd` API remains compatible. Stable IDs in `qfd-stage` allow `qfd-deploy` to carry unrounded priorities into the next stage and `qfd-diff` to match revisions despite reordering.

## Responsibilities
- `model.typ`: normalization and validation of positional matrix data.
- `calculations.typ`: priorities and roof coordinates.
- `stages.typ`: named stages, deployment and revision comparison.
- `theme.typ`: fonts, palette, line and symbol defaults, change colors.
- `layout.typ`: text measurement, padding and bounded marker staggering.
- `draw.typ` and `symbols.typ`: native Typst rendering and symbols.

## Behavior
Auto header and row heights measure content at the requested font size. Explicit dimensions remain available. Padding is independent for row labels and headers. Directions support maximize, minimize, target and none. Roof symbols are bold and can use circled strong signs. Profiles keep their x-coordinate; bounded vertical staggering uses neighboring scores to choose among offsets, reducing avoidable crossings without promising a crossing-free chart.

Changes use pale green additions, pale red removals, pale yellow modifications, dark glyphs, a legend and text status marks. Revisions align stable row/column IDs, retain removed data for display and compute current priorities only from current relationships and weights. Historical values are retained for review.

## Public example
Home coffee substitutes for a local café. Taste and drink temperature are acceptance thresholds. Setup, consecutive drinks, cleaning, space and household safety become explicit constraints. Functions describe transformations or storage; components implement them; technologies are candidate realizations. Numerical example priorities are labeled illustrative judgments, not research measurements.

## Verification and release
Compile calculation, deployment, revision and layout fixtures plus invalid-input cases with Typst 0.15.1. Inspect rendered PDF/SVG examples. Publish a static HTML guide using GitHub Pages and submit a versioned bundle through the Typst packages PR process. Include no private source datasets or documents.
