#import "model.typ": qfd-matrix, qfd-weights, _dense, _correlations, _alternatives

#let _labels = (
  whats: [Customer needs], importance: [Weight],
  comparison: [Comparative evaluation], poor: [poor], excellent: [excellent],
  relation: [Relation], correlation: [Correlation], evaluation: [Evaluation],
  strong: [Strong (9)], medium: [Medium (3)], weak: [Weak (1)],
  very-positive: [very positive], positive: [positive],
  negative: [negative], very-negative: [very negative],
  target: [Target], absolute: [Σ abs], relative: [Rel. %],
  score-note: auto,
)

#let _as-content(value) = if value == none { [] } else { [#value] }

// Every segment has a nonnegative local bounding box, including roof diagonals.
#let _segment(x1, y1, x2, y2, pen) = {
  let x = calc.min(x1, x2)
  let y = calc.min(y1, y2)
  place(top + left, dx: x, dy: y,
    line(start: (x1 - x, y1 - y), end: (x2 - x, y2 - y), stroke: pen))
}

// A single path per contiguous profile preserves dash phase and line joins.
#let _polyline(points, pen) = {
  if points.len() < 2 { return [] }
  let x = calc.min(..points.map(p => p.at(0)))
  let y = calc.min(..points.map(p => p.at(1)))
  let local = points.map(p => (p.at(0) - x, p.at(1) - y))
  place(top + left, dx: x, dy: y,
    curve(stroke: pen, fill: none, curve.move(local.first()),
      ..local.slice(1).map(p => curve.line(p))))
}

#let _frame(x, y, w, h, pen) = place(top + left, dx: x, dy: y,
  rect(width: w, height: h, inset: 0pt, stroke: pen, fill: none))

#let _marker(shape, size, paint, fill: none, thickness: 0.7pt) = {
  let pen = (paint: paint, thickness: thickness, join: "round")
  let drawing = if shape == "circle" {
    circle(radius: size / 2, fill: fill, stroke: pen)
  } else if shape == "square" {
    rect(width: size, height: size, inset: 0pt, fill: fill, stroke: pen)
  } else if shape == "diamond" {
    polygon((size / 2, 0pt), (size, size / 2), (size / 2, size), (0pt, size / 2),
      fill: fill, stroke: pen)
  } else {
    let n = if shape == "triangle" { 3 } else { 5 }
    let vertices = range(n).map(k => {
      let angle = -90deg + k * 360deg / n
      (size / 2 + size / 2 * calc.cos(angle), size / 2 + size / 2 * calc.sin(angle))
    })
    polygon(..vertices, fill: fill, stroke: pen)
  }
  box(width: size, height: size, place(top + left, drawing))
}

#let _relation(value, size, ink) = {
  if value == 9 { _marker("circle", size, ink, fill: ink) }
  else if value == 3 { _marker("circle", size, ink, fill: none, thickness: 0.8pt) }
  else if value == 1 { _marker("triangle", size * 1.2, ink, fill: none) }
  else { [] }
}

#let _sign(value) = text(if value == "-" { "−" } else if value == "--" { "−−" } else { value })

#let _profile-pen(item) = (
  paint: item.color, thickness: item.thickness, dash: item.dash,
  cap: "round", join: "round",
)

#let _profile-marker(item, size) = _marker(
  item.marker, size, item.color, fill: item.color.lighten(item.fill-lighten), thickness: item.marker-thickness,
)

#let _sample(item, size) = box(width: 0.6cm, height: 0.4cm, {
  _segment(0.02cm, 0.2cm, 0.58cm, 0.2cm, _profile-pen(item))
  place(top + left, dx: 0.3cm - size / 2, dy: 0.2cm - size / 2,
    _profile-marker(item, size))
})

// Constrain content to a cell without clipping or evaluating user strings.
// WHATs wrap first; short values and rotated labels shrink only when necessary.
#let _fit(body, w, h, anchor: center + horizon, wrap: false) = context {
  let body = if wrap { block(width: w, breakable: false, body) } else { box(body) }
  let extent = measure(body)
  let factor = calc.min(1, w / calc.max(0.01pt, extent.width), h / calc.max(0.01pt, extent.height))
  block(width: w, height: h, breakable: false, above: 0pt, below: 0pt,
    align(anchor, scale(factor * 100%, reflow: true, body)))
}

#let _cell(x, y, w, h, body, anchor: center + horizon, wrap: false, inset: 0.1cm) = {
  let inset = calc.min(inset, w / 10, h / 10)
  place(top + left, dx: x + inset, dy: y + inset,
    _fit(_as-content(body), w - 2 * inset, h - 2 * inset, anchor: anchor, wrap: wrap))
}

#let _legend(labels, alternatives, order, limits, width, thin, frame, ink,
  symbol-size, relation: true, correlation: true, evaluation: true) = {
  let row(sample, label) = grid(
    columns: (0.65cm, 1fr), column-gutter: 0.1cm, align: left + horizon,
    align(center, sample), _as-content(label),
  )
  let section(title, entries) = stack(dir: ttb, spacing: 0.15cm,
    strong(_as-content(title)), line(length: 100%, stroke: thin), ..entries)
  let sections = ()
  if relation {
    sections.push(section(labels.relation, (
      row(_relation(9, symbol-size, ink), labels.strong),
      row(_relation(3, symbol-size, ink), labels.medium),
      row(_relation(1, symbol-size, ink), labels.weak),
    )))
  }
  if correlation {
    sections.push(section(labels.correlation, (
      row(_sign("++"), labels.very-positive), row(_sign("+"), labels.positive),
      row(_sign("-"), labels.negative), row(_sign("--"), labels.very-negative),
    )))
  }
  if evaluation {
    let entries = order.map(index => {
      let item = alternatives.at(index - 1)
      let label = _as-content(item.label)
      if item.at("emphasize", default: false) { label = strong(label) }
      row(_sample(item, item.marker-size * (symbol-size / 7pt)), label)
    })
    let note = if labels.score-note == auto {
      [#(limits.at(0)) = #labels.poor, #(limits.at(1)) = #labels.excellent]
    } else { _as-content(labels.score-note) }
    entries.push(emph(note))
    sections.push(section(labels.evaluation, entries))
  }
  if sections.len() == 0 { return none }
  rect(width: width, inset: 0.15cm, radius: 2pt, stroke: frame, fill: none,
    stack(dir: ttb, spacing: 0.4cm, ..sections))
}

// Import as qfd or house-of-quality. No package downloads, TikZ, or WASM needed.
// Dimensions are natural-size lengths; width scales the entire result uniformly.
#let house-of-quality(
  whats: (), hows: (),
  relations: (), matrix: none, importance: none,
  correlations: (), targets: none, basement: auto,
  alternatives: (), score-range: (0, 5), legend-order: auto,
  labels: (:),
  show-roof: true, show-importance: auto, show-basement: true,
  show-competitive: auto, show-legend: true,
  show-rel-legend: true, show-corr-legend: true, show-eval-legend: true,
  width: 100%,
  cell-size: 1cm, row-height: auto, what-width: 4.6cm,
  importance-width: 0.7cm, comparison-width: 3.4cm,
  header-height: 5cm, basement-height: auto,
  legend-width: 5.25cm, legend-gap: 0.55cm,
  font: "New Computer Modern", font-size: 7pt,
  ink: black, grid-thickness: 0.35pt, frame-thickness: 0.7pt,
  symbol-size: 7pt, relative-digits: 0,
) = context {
  assert(type(whats) == array and whats.len() > 0,
    message: "qfd: whats must be a nonempty array")
  assert(type(hows) == array and hows.len() > 0,
    message: "qfd: hows must be a nonempty array")
  let nr = whats.len()
  let nc = hows.len()
  let rel = if matrix == none {
    qfd-matrix(nr, nc, relations: relations)
  } else {
    assert(type(relations) == array and relations.len() == 0,
      message: "qfd: pass either matrix or relations, not both")
    _dense(matrix, nr, nc)
  }
  let corr = _correlations(correlations, nc)
  let weights = if importance == none { none } else {
    qfd-weights(importance, rel, digits: relative-digits)
  }
  if targets != none {
    assert(type(targets) == array and targets.len() == nc,
      message: "qfd: targets must have one entry per HOW")
  }
  assert(type(labels) == dictionary, message: "qfd: labels must be a dictionary")
  for key in labels.keys() {
    assert(key in _labels, message: "qfd: unknown label key: " + key)
  }
  let labels = _labels + labels
  assert(type(score-range) == array and score-range.len() == 2,
    message: "qfd: score-range must contain two integer endpoints")
  let (score-min, score-max) = score-range
  assert(type(score-min) == int and type(score-max) == int and score-min < score-max,
    message: "qfd: score-range must contain increasing integer endpoints")
  let alternatives = _alternatives(alternatives, nr, score-range)
  let show-importance = if show-importance == auto { importance != none } else { show-importance }
  let show-competitive = if show-competitive == auto { alternatives.len() > 0 } else { show-competitive }
  assert(not show-importance or importance != none,
    message: "qfd: show-importance requires importance data")
  for flag in (show-roof, show-importance, show-basement, show-competitive,
    show-legend, show-rel-legend, show-corr-legend, show-eval-legend) {
    assert(type(flag) == bool, message: "qfd: visibility flags must be booleans")
  }
  let order = if legend-order == auto { range(1, alternatives.len() + 1) } else { legend-order }
  assert(type(order) == array and order.sorted() == range(1, alternatives.len() + 1),
    message: "qfd: legend-order must be a permutation of the 1-based alternative indices")

  let basement = if basement == auto {
    let rows = ()
    if targets != none { rows.push((label: labels.target, values: targets)) }
    if weights != none {
      rows.push((label: labels.absolute, values: weights.absolute))
      rows.push((label: labels.relative, values: weights.rounded, bold: true))
    }
    rows
  } else { basement }
  assert(type(basement) == array, message: "qfd: basement must be auto or an array of rows")
  for row in basement {
    assert(type(row) == dictionary and "label" in row and "values" in row,
      message: "qfd: each basement row requires label and values")
    assert(type(row.values) == array and row.values.len() == nc,
      message: "qfd: each basement row must have one value per HOW")
  }
  let basement = if show-basement { basement } else { () }
  let row-height = if row-height == auto { cell-size } else { row-height }
  let basement-height = if basement-height == auto { cell-size } else { basement-height }
  for value in (cell-size, row-height, what-width, importance-width, comparison-width,
    header-height, basement-height, legend-width, font-size, symbol-size,
    grid-thickness, frame-thickness) {
    assert(type(value) == length and value > 0pt,
      message: "qfd: dimensions, font size, symbol size, and line thicknesses must be positive lengths")
  }
  assert(type(legend-gap) == length and legend-gap >= 0pt,
    message: "qfd: legend-gap must be a nonnegative length")
  assert(type(ink) == color, message: "qfd: ink must be a Typst color")

  set text(font: font, size: font-size, fill: ink, weight: "regular", style: "normal", hyphenate: false)
  set par(justify: false, leading: 0.3em, spacing: 0pt, first-line-indent: 0pt)
  set block(above: 0pt, below: 0pt)
  set align(left)
  let thin = (paint: ink, thickness: grid-thickness)
  let frame = (paint: ink, thickness: frame-thickness)
  let pad = calc.max(0.15cm, frame-thickness)
  // Cell insets shrink with dimensions, so tiny custom cells remain positive.
  let inset = calc.min(0.1cm, cell-size / 10, row-height / 10,
    importance-width / 10, basement-height / 10, what-width / 10, header-height / 10)
  let iw = if show-importance { importance-width } else { 0pt }
  let cw = if show-competitive { comparison-width } else { 0pt }
  let mx = pad + what-width + iw
  let mw = nc * cell-size
  let rh = if show-roof { mw / 2 } else { 0pt }
  let roof-base = pad + rh
  let my = roof-base + header-height
  let mh = nr * row-height
  let right-edge = mx + mw + cw
  let legend-x = right-edge + legend-gap
  let legend = if show-legend {
    _legend(labels, alternatives, order, score-range, legend-width, thin, frame, ink, symbol-size,
      relation: show-rel-legend,
      correlation: show-roof and show-corr-legend,
      evaluation: show-competitive and show-eval-legend and alternatives.len() > 0)
  } else { none }
  let legend-size = if legend == none { (width: 0pt, height: 0pt) } else { measure(legend) }
  let canvas-width = (if legend == none { right-edge } else { legend-x + legend-size.width }) + pad
  let under-body = calc.max(basement.len() * basement-height,
    if show-competitive { 0.6cm } else { 0pt })
  let canvas-height = calc.max(my + mh + under-body, roof-base + legend-size.height) + pad
  let score-x(score) = mx + mw + (score - score-min + 0.5) * cw / (score-max - score-min + 1)
  let row-y(index) = my + (index + 0.5) * row-height

  let drawing = box(width: canvas-width, height: canvas-height, {
    // Matrix and neighboring row lines. Frames are stroked last.
    for r in range(1, nr) {
      _segment(pad, my + r * row-height, right-edge, my + r * row-height, thin)
    }
    for c in range(1, nc) {
      _segment(mx + c * cell-size, roof-base, mx + c * cell-size,
        my + mh + basement.len() * basement-height, thin)
    }
    for b in range(1, basement.len()) {
      _segment(mx, my + mh + b * basement-height, mx + mw, my + mh + b * basement-height, thin)
    }

    // Roof lattice: two diagonals from each interior base-grid point.
    if show-roof {
      for k in range(1, nc) {
        _segment(mx + k * cell-size, roof-base,
          mx + (k + nc) * cell-size / 2, roof-base - (nc - k) * cell-size / 2, thin)
        _segment(mx + k * cell-size, roof-base,
          mx + k * cell-size / 2, roof-base - k * cell-size / 2, thin)
      }
      _segment(mx, roof-base, mx + mw / 2, pad, frame)
      _segment(mx + mw / 2, pad, mx + mw, roof-base, frame)
      for item in corr {
        let x = mx + item.point.x * cell-size
        let y = roof-base - item.point.y * cell-size
        _cell(x - cell-size / 4, y - cell-size / 4, cell-size / 2, cell-size / 2,
          _sign(item.sign), inset: 0pt)
      }
    }

    // Labels stay editable native Typst content, including math and line breaks.
    _cell(pad, roof-base, what-width, header-height, strong(_as-content(labels.whats)),
      wrap: true, inset: inset)
    for (c, label) in hows.enumerate() {
      _cell(mx + c * cell-size, roof-base, cell-size, header-height,
        rotate(-90deg, reflow: true, box(_as-content(label))),
        anchor: center + bottom, inset: inset)
    }
    if show-importance {
      _cell(pad + what-width, roof-base, iw, header-height,
        rotate(-90deg, reflow: true, box(strong(_as-content(labels.importance)))),
        anchor: center + bottom, inset: inset)
    }
    for (r, label) in whats.enumerate() {
      _cell(pad, my + r * row-height, what-width, row-height, label,
        anchor: left + horizon, wrap: true, inset: inset)
      if show-importance {
        _cell(pad + what-width, my + r * row-height, iw, row-height, importance.at(r), inset: inset)
      }
      for c in range(nc) {
        let value = rel.at(r).at(c)
        if value != 0 {
          _cell(mx + c * cell-size, my + r * row-height, cell-size, row-height,
            _relation(value, symbol-size, ink), inset: inset)
        }
      }
    }
    for (b, row) in basement.enumerate() {
      _cell(pad, my + mh + b * basement-height, what-width + iw, basement-height,
        emph(_as-content(row.label)), anchor: right + horizon, inset: inset)
      for (c, value) in row.values.enumerate() {
        let body = _as-content(value)
        if row.at("bold", default: false) { body = strong(body) }
        _cell(mx + c * cell-size, my + mh + b * basement-height,
          cell-size, basement-height, body, inset: inset)
      }
    }

    if show-competitive {
      let tick-height = calc.min(0.45cm, header-height / 4)
      let title-height = calc.min(1.1cm, header-height - tick-height)
      _cell(mx + mw, my - tick-height - title-height, cw, title-height,
        strong(_as-content(labels.comparison)), wrap: true, inset: inset)
      let tick-width = cw / (score-max - score-min + 1)
      for tick in range(score-min, score-max + 1) {
        _cell(score-x(tick) - tick-width / 2, my - tick-height,
          tick-width, tick-height, tick, inset: 0pt)
      }
      // All profiles first; all markers second. Missing values break profiles.
      for item in alternatives {
        let run = ()
        for (r, score) in item.scores.enumerate() {
          if score == none {
            _polyline(run, _profile-pen(item))
            run = ()
          } else {
            run.push((score-x(score), row-y(r)))
          }
        }
        _polyline(run, _profile-pen(item))
      }
      for item in alternatives {
        let marker-size = calc.min(item.marker-size * (symbol-size / 7pt), tick-width * 0.75, row-height * 0.7)
        for (r, score) in item.scores.enumerate() {
          if score != none {
            place(top + left, dx: score-x(score) - marker-size / 2, dy: row-y(r) - marker-size / 2,
              _profile-marker(item, marker-size))
          }
        }
      }
      _cell(mx + mw, my + mh, cw / 2, 0.5cm, emph(_as-content(labels.poor)),
        anchor: left + horizon, inset: 0.05cm)
      _cell(mx + mw + cw / 2, my + mh, cw / 2, 0.5cm, emph(_as-content(labels.excellent)),
        anchor: right + horizon, inset: 0.05cm)
    }

    _frame(pad, my, what-width + iw + mw, mh, frame)
    _segment(mx, my, mx, my + mh, frame)
    if show-importance { _segment(pad + what-width, my, pad + what-width, my + mh, frame) }
    _frame(mx, roof-base, mw, header-height, frame)
    if basement.len() > 0 { _frame(mx, my + mh, mw, basement.len() * basement-height, frame) }
    if show-competitive { _frame(mx + mw, my, cw, mh, frame) }
    if legend != none { place(top + left, dx: legend-x, dy: roof-base, legend) }
  })

  // Explicit natural width works on auto-sized pages; ratios need finite layout width.
  layout(region => {
    let requested = if width == auto { canvas-width }
      else if type(width) == length { width }
      else if type(width) == ratio { width * region.width }
      else if type(width) == relative { width.length + width.ratio * region.width }
      else { panic("qfd: width must be auto, a length, a ratio, or a relative length") }
    assert(requested > 0pt and requested < calc.inf * 1pt,
      message: "qfd: width must resolve to a finite positive length; use width: auto on auto-width pages")
    scale((requested / canvas-width) * 100%, reflow: true, drawing)
  })
}
