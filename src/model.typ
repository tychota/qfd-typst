// QFD data normalization. All public row/column indices are ONE-BASED.
// Internal helpers intentionally have an underscore prefix.

#let _number(x) = type(x) == int or type(x) == float
#let _nonnegative(x) = _number(x) and x >= 0 and x < calc.inf

#let relation-value(value) = {
  if value == none or value == "" { return 0 }
  if type(value) == str {
    let values = (S: 9, M: 3, W: 1)
    let key = upper(value)
    assert(key in values, message: "qfd: relation must be S, M, W, 9, 3, 1, 0, none, or an empty string")
    return values.at(key)
  }
  assert(_number(value) and value in (0, 1, 3, 9),
    message: "qfd: numeric relation must be 0, 1, 3, or 9")
  value
}

// Convert sparse (row, column, strength) triples to a dense numeric matrix.
#let qfd-matrix(rows, columns, relations: ()) = {
  assert(type(rows) == int and rows > 0,
    message: "qfd: row count must be a positive integer")
  assert(type(columns) == int and columns > 0,
    message: "qfd: column count must be a positive integer")
  assert(type(relations) == array, message: "qfd: relations must be an array")
  let cells = (:)
  for entry in relations {
    assert(type(entry) == array and entry.len() == 3,
      message: "qfd: each relation must be a (row, column, strength) triple")
    let (r, c, value) = entry
    assert(type(r) == int and r >= 1 and r <= rows,
      message: "qfd: relation row index out of bounds (indices start at 1)")
    assert(type(c) == int and c >= 1 and c <= columns,
      message: "qfd: relation column index out of bounds (indices start at 1)")
    let key = str(r) + ":" + str(c)
    assert(not (key in cells), message: "qfd: duplicate relation at " + key)
    cells.insert(key, relation-value(value))
  }
  range(rows).map(r => range(columns).map(c =>
    cells.at(str(r + 1) + ":" + str(c + 1), default: 0)))
}

#let _dense(matrix, rows, columns) = {
  assert(type(matrix) == array and matrix.len() == rows,
    message: "qfd: matrix must have one row per WHAT")
  matrix.map(row => {
    assert(type(row) == array and row.len() == columns,
      message: "qfd: matrix must have one column per HOW")
    row.map(relation-value)
  })
}

// Absolute weights: sum_i importance[i] * relation[i][j].
// Relative weights are percentages in 0..100, not Typst ratio values.
// Independent rounding is deliberate: rounded percentages may not sum to 100.
#let qfd-weights(importance, matrix, digits: 0) = {
  assert(type(matrix) == array and matrix.len() > 0,
    message: "qfd: matrix must not be empty")
  assert(type(matrix.first()) == array and matrix.first().len() > 0,
    message: "qfd: matrix must have at least one column")
  let rows = matrix.len()
  let columns = matrix.first().len()
  let matrix = _dense(matrix, rows, columns)
  assert(type(importance) == array and importance.len() == rows,
    message: "qfd: importance must have one number per WHAT")
  assert(importance.all(_nonnegative),
    message: "qfd: importance values must be finite, nonnegative numbers")
  assert(type(digits) == int and digits >= 0 and digits <= 10,
    message: "qfd: digits must be an integer from 0 to 10")
  let absolute = range(columns).map(c =>
    range(rows).map(r => importance.at(r) * matrix.at(r).at(c)).sum())
  let total = absolute.sum()
  let relative = absolute.map(v => if total == 0 { 0 } else { 100 * v / total })
  (
    absolute: absolute,
    total: total,
    relative: relative,
    rounded: relative.map(v => calc.round(v, digits: digits)),
  )
}

// Logical coordinates relative to the lower-left corner of the roof.
// The drawing converts y-up here to Typst's y-down coordinates.
#let qfd-correlation-point(i, j, columns: none) = {
  assert(type(i) == int and type(j) == int and i >= 1 and j >= 1,
    message: "qfd: correlation indices must be positive integers")
  assert(i != j, message: "qfd: a HOW cannot correlate with itself")
  if columns != none {
    assert(type(columns) == int and columns > 0,
      message: "qfd: column count must be a positive integer")
    assert(i <= columns and j <= columns,
      message: "qfd: correlation column index out of bounds")
  }
  let a = calc.min(i, j)
  let b = calc.max(i, j)
  (x: (a + b - 1) / 2, y: (b - a) / 2)
}

#let _correlations(values, columns) = {
  assert(type(values) == array, message: "qfd: correlations must be an array")
  let seen = (:)
  let result = ()
  for entry in values {
    assert(type(entry) == array and entry.len() == 3,
      message: "qfd: each correlation must be an (i, j, sign) triple")
    let (i, j, sign) = entry
    let point = qfd-correlation-point(i, j, columns: columns)
    assert(sign in ("++", "+", "-", "--"),
      message: "qfd: correlation sign must be ++, +, -, or --")
    let a = calc.min(i, j)
    let b = calc.max(i, j)
    let key = str(a) + ":" + str(b)
    assert(not (key in seen), message: "qfd: duplicate correlation at " + key)
    seen.insert(key, true)
    result.push((i: a, j: b, sign: sign, point: point))
  }
  result
}

// Five source-palette styles. Additional alternatives cycle these defaults;
// callers can provide explicit color, marker, dash, and thickness per series.
#let qfd-palette = (
  (color: rgb("0072B2"), marker: "circle", dash: "solid", thickness: 1.2pt, marker-size: 6.5pt, marker-thickness: 1.1pt, fill-lighten: 45%),
  (color: rgb("D55E00"), marker: "triangle", dash: "dashed", thickness: 0.8pt, marker-size: 7pt, marker-thickness: 0.9pt, fill-lighten: 45%),
  (color: rgb("009E73"), marker: "square", dash: "dotted", thickness: 0.8pt, marker-size: 5.5pt, marker-thickness: 0.9pt, fill-lighten: 45%),
  (color: rgb("CC79A7"), marker: "diamond", dash: "dash-dotted", thickness: 0.8pt, marker-size: 7pt, marker-thickness: 1pt, fill-lighten: 50%),
  (color: rgb("56B4E9"), marker: "pentagon", dash: (4pt, 2pt, 0.8pt, 2pt, 0.8pt, 2pt), thickness: 0.7pt, marker-size: 5.5pt, marker-thickness: 0.8pt, fill-lighten: 60%),
)

#let _alternatives(values, rows, limits) = {
  assert(type(values) == array, message: "qfd: alternatives must be an array")
  values.enumerate().map(((index, item)) => {
    assert(type(item) == dictionary and "label" in item and "scores" in item,
      message: "qfd: an alternative requires label and scores fields")
    assert(type(item.scores) == array and item.scores.len() == rows,
      message: "qfd: each alternative needs one score per WHAT")
    for score in item.scores {
      assert(score == none or (_number(score) and score >= limits.at(0) and score <= limits.at(1)),
        message: "qfd: scores must lie within score-range; use none for missing data")
    }
    let result = qfd-palette.at(calc.rem(index, qfd-palette.len())) + item
    assert(result.marker in ("circle", "triangle", "square", "diamond", "pentagon"),
      message: "qfd: unknown alternative marker")
    assert(type(result.color) == color, message: "qfd: alternative color must be a Typst color")
    for value in (result.thickness, result.marker-size, result.marker-thickness) {
      assert(type(value) == length and value > 0pt,
        message: "qfd: alternative sizes and thicknesses must be positive lengths")
    }
    assert(type(result.fill-lighten) == ratio and result.fill-lighten >= 0% and result.fill-lighten <= 100%,
      message: "qfd: fill-lighten must be a ratio from 0% to 100%")
    result
  })
}
