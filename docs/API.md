# API reference

Import the public API from `lib.typ`. All dimensions describe natural size before the final `width` scale.

## Renderer

`qfd` and `house-of-quality` are aliases.

| Argument | Default | Contract |
| --- | --- | --- |
| `whats`, `hows` | `()` | Nonempty row and column labels; strings or Typst content. |
| `relations` | `()` | Sparse `(row, column, strength)` triples, one-based indices. |
| `matrix` | `none` | Dense rows × columns, exclusive with nonempty relations. |
| `importance` | `none` | Finite nonnegative weight per row. Omission creates no weights. |
| `correlations` | `()` | `(i,j,sign)` pairs; `++`, `+`, `-`, `--`. Reversed pairs accepted; duplicates/self-pairs rejected. |
| `targets`, `difficulty` | `none` | One value per column, used by the automatic basement. |
| `directions` | `none` | One `maximize`, `minimize`, `target`, or `none` per column; Typst `none` is also accepted by the renderer. |
| `basement` | `auto` | Derived targets/difficulty/absolute/relative rows, or custom `(label, values, bold)` dictionaries. |
| `alternatives` | `()` | Dictionaries with `label` and `scores`; `none` scores break paths. |
| `score-range` | `(0,5)` | Increasing integer endpoints; fractional observed scores allowed. |
| `legend-order` | `auto` | Permutation of one-based alternative indices. |
| `labels` | `(:)` | Override known section names. See `src/labels.typ`. |
| `relative-digits` | `0` | Rounding of displayed relative percentages, 0–10. |
| `weight-digits` | `1` | Display rounding of row weights and computed absolute weights, 0–10. |

Strengths: `S/M/W` (case insensitive) or `9/3/1`. `0`, `none`, and `""` mean no relation. Arbitrary weights such as 2 or 5 are rejected. Labels never execute as source.

### Visibility

`show-roof`, `show-basement`, `show-legend`, `show-rel-legend`, `show-corr-legend`, `show-eval-legend` default to `true`. `show-importance` and `show-competitive` default to `auto`, enabling themselves when their data is supplied. Hiding the importance column does not disable calculations. Hiding the roof keeps column headings.

### Layout and styling

| Argument | Default |
| --- | --- |
| `width` | `100%`; `auto` preserves natural size |
| `cell-size` | `9mm` |
| `row-height`, `header-height` | `auto`, measured from rendered labels |
| `what-width`, `importance-width`, `comparison-width` | `54mm`, `8mm`, `38mm` |
| `basement-height` | `auto` → `7mm` |
| `legend-width`, `legend-gap` | `43mm`, `5mm` |
| `cell-padding`, `label-padding`, `header-padding` | `1mm`, `2mm`, `1.5mm` |
| `font`, `serif-font`, `font-size`, `ink` | `auto` → theme |
| `grid-thickness`, `frame-thickness`, `symbol-size` | `auto` → theme |
| `theme` | Partial dictionary overriding `qfd-theme` |
| `correlation-style` | `"circled"`; or `"text"` |
| `marker-stagger`, `marker-spread` | `true`, `0.30` (maximum displacement in row units) |

Theme defaults: Plex Sans/Plex Serif with built-in fallbacks, `9pt` font, dark ink, `0.35pt` grid, `0.7pt` frame, `7pt` symbols and `1.1pt` symbol strokes. Change backgrounds are `added-fill`, `removed-fill`, and `changed-fill`.

```typst
#qfd(whats: ("Need",), hows: ("Function",), matrix: ((9,),),
  theme: (grid-thickness: 0.5pt, added-fill: rgb("ddf4df")),
  label-padding: 2.5mm, header-height: auto, width: auto)
```

Alternative styles may override `color`, `marker` (`circle`, `triangle`, `square`, `diamond`, `pentagon`), `dash`, `thickness`, `marker-size`, `marker-thickness`, `fill-lighten`, and `emphasize`. Styles cycle after the five defaults; supply explicit distinctions for larger comparisons.

Staggering finds nearby points, assigns bounded vertical lanes, and improves their order by counting crossings on both adjacent row transitions. Marker size may decrease when many points tie. The score coordinate is never jittered. Missing observations are never bridged.

## Named stages

`qfd-stage(rows: ..., columns: ..., relations: ..., matrix: ..., importance: auto, ..options)` returns renderer arguments.

- Row records: `(id, label, weight?)`.
- Column records: `(id, label, direction?, target?)`.
- IDs must be unique nonempty strings within each axis. Labels need not be unique.
- Row weights must be all supplied or all omitted unless `importance` is explicit.
- Options pass through to the renderer. Identity, directions and targets come from records.

`qfd-deploy(previous-stage, columns: ..., relations: ..., matrix: ..., ..options)` turns previous columns into rows and derives their weights from unrounded relative priorities. It requires explicit previous importance and rejects a manual importance override.

## Revisions

`qfd-diff(before, after)` returns renderer arguments. Both inputs must be named source stages. It aligns identities in after-order, then appends removed identities in before-order. Styling comes from after. It detects labels, weights, targets, directions, relationship strengths, and correlations; alignment also preserves difficulty values.

The result includes `changes.rows`, `changes.columns`, `changes.cells`, `changes.previous-matrix`, historical labels/weights/targets/directions, and correlation entries `(i,j,status,previous,current)`. Status is `unchanged`, `added`, `removed`, or `changed`.

Current `matrix` and `importance` exclude removed data. The renderer shows historical symbols and removed-row weights for review. A changed relationship displays old → new numeric strength. Deleted columns have zero current computed priority.

Limits: no competitive profiles, no custom basements, no weighted/unweighted mixing, no diff-of-diff. Compare source stages, and render competitive assessment separately. The diff view is not the next deployment stage. Changes to visual options are not semantic edits.

## Calculations

`qfd-matrix(rows, columns, relations: ())` creates a dense validated matrix.

`qfd-weights(importance, matrix, digits: 0)` returns `absolute`, `total`, `relative` and `rounded`:

```text
absolute[j] = Σ importance[i] × matrix[i][j]
relative[j] = 100 × absolute[j] / Σ absolute
```

A zero total yields all zeros. Relative percentages are ordinary numbers in 0–100, not Typst ratios. Independently rounded percentages may not sum to 100. `qfd-correlation-point(i,j,columns:none)` returns logical `(x,y)` measured upward from the roof base.

## Installation

`python3 tools/install_local.py` copies only the runtime library, license and manifest into:

- macOS: `~/Library/Application Support/typst/packages/local/qualitree/0.1.0/`
- Linux: `${XDG_DATA_HOME:-~/.local/share}/typst/packages/local/qualitree/0.1.0/`
- Windows: `%APPDATA%\typst\packages\local\qualitree\0.1.0\`

An existing installation is left untouched unless `--replace` is explicit. `--package-root PATH` selects a custom package root; use the same path with `typst compile --package-path PATH`. Fonts require `--font-path fonts` or operating-system installation.
