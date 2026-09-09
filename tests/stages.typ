#import "../lib.typ": qfd-stage, qfd-deploy, qfd-diff, qfd-weights
#let before = qfd-stage(
  rows: ((id: "taste", label: "Good taste", weight: 10), (id: "speed", label: "Quick", weight: 5)),
  columns: ((id: "heat", label: "Heat water"), (id: "flow", label: "Channel water")),
  matrix: ((9, 1), (3, 9)),
)
#let next = qfd-deploy(before, columns: ((id: "heater", label: "Heater"),), matrix: ((9,), (3,)))
#assert.eq(next.importance, (65.625, 34.375))
#assert.eq(qfd-weights(next.importance, next.matrix).absolute, (693.75,))
#let after = qfd-stage(
 rows: ((id: "speed", label: "Quick", weight: 5), (id: "taste", label: "Good taste", weight: 10)),
 columns: ((id: "flow", label: "Channel water"), (id: "heat", label: "Heat water")),
 matrix: ((9, 0), (1, 9)),
)
#let delta = qfd-diff(before, after)
#assert.eq(delta.changes.cells, (("unchanged", "removed"), ("unchanged", "unchanged")))
#assert.eq(delta.matrix, after.matrix)
#assert.eq(delta.changes.previous-matrix, ((9, 3), (1, 9)))
#let zero = qfd-stage(rows: ((id: "n", label: "N", weight: 0),), columns: ((id: "f", label: "F"),))
#assert.eq(qfd-deploy(zero, columns: ((id: "c", label: "C"),)).importance, (0,))

// Missing weights stay missing; explicit overrides and sparse input normalize.
#let unweighted = qfd-stage(rows: ((id: "n", label: [Need]),), columns: ((id: "f", label: [Function]),), relations: ((1, 1, "S"),))
#assert.eq(unweighted.importance, none)
#assert.eq(unweighted.matrix, ((9,),))
#assert.eq(qfd-stage(rows: ((id: "n", label: "N", weight: 8),), columns: ((id: "f", label: "F"),), importance: (2,)).importance, (2,))
#assert.eq(qfd-diff(unweighted, unweighted).importance, none)

// Reordering alone is not a change, including symmetric roof index reversal.
#let roof-before = before + (correlations: ((1, 2, "+"),))
#let reordered = after + (matrix: ((9, 3), (1, 9)), correlations: ((2, 1, "+"),))
#let reorder-diff = qfd-diff(roof-before, reordered)
#assert.eq(reorder-diff.changes.rows, ("unchanged", "unchanged"))
#assert.eq(reorder-diff.changes.columns, ("unchanged", "unchanged"))
#assert.eq(reorder-diff.changes.cells, (("unchanged", "unchanged"), ("unchanged", "unchanged")))
#assert.eq(reorder-diff.changes.correlations.first().status, "unchanged")

// Removals remain visible but do not participate in current priorities.
#let revised = qfd-stage(
  rows: ((id: "speed", label: "Quicker", weight: 5), (id: "clean", label: "Easy cleaning", weight: 4)),
  columns: ((id: "flow", label: "Channel water", target: "2 ml/s", direction: "target"), (id: "pump", label: "Pump water")),
  matrix: ((9, 3), (1, 9)), correlations: ((1, 2, "++"),),
)
#let revision = qfd-diff(roof-before, revised)
#assert.eq(revision.row-ids, ("speed", "clean", "taste"))
#assert.eq(revision.column-ids, ("flow", "pump", "heat"))
#assert.eq(revision.changes.rows, ("changed", "added", "removed"))
#assert.eq(revision.changes.columns, ("changed", "added", "removed"))
#assert.eq(revision.importance, (5, 4, 0))
#assert.eq(revision.matrix, ((9, 3, 0), (1, 9, 0), (0, 0, 0)))
#assert.eq(revision.changes.previous-matrix, ((9, 0, 3), (0, 0, 0), (1, 0, 9)))
#assert.eq(qfd-weights(revision.importance, revision.matrix).absolute, (49, 51, 0))
#assert.eq(revision.changes.previous-whats, ("Quick", none, "Good taste"))
#assert.eq(revision.changes.previous-importance, (5, none, 10))
#assert.eq(revision.changes.correlations.map(item => item.status), ("added", "removed"))
#assert.eq(revision.changes.correlations.last(), (i: 1, j: 3, status: "removed", previous: "+", current: none))
#assert.eq(revision.correlations, ((1, 2, "++"),))
#assert.eq(qfd-diff(roof-before, before + (correlations: ((2, 1, "--"),))).changes.correlations.first().status, "changed")
#assert.eq(qfd-diff(before, before + (matrix: ((3, 1), (3, 9)),)).changes.cells.first().first(), "changed")

// Repeated deployment preserves all internal precision, including equal thirds.
#let thirds = qfd-stage(rows: ((id: "n", label: "N", weight: 1),), columns: ((id: "a", label: "A"), (id: "b", label: "B"), (id: "c", label: "C")), matrix: ((1, 1, 1),))
#let third-next = qfd-deploy(thirds, columns: ((id: "z", label: "Z"),), matrix: ((1,), (1,), (1,)))
#assert.eq(third-next.row-ids, thirds.column-ids)
#assert.eq(third-next.whats, thirds.hows)
#assert.eq(third-next.importance, (100 / 3, 100 / 3, 100 / 3))
#assert.eq(qfd-deploy(third-next, columns: ((id: "final", label: "Final"),)).importance, (100,))
