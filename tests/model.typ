#import "../lib.typ": qfd-matrix, qfd-weights, qfd-correlation-point
#import "../src/model.typ": relation-value, _correlations

#assert.eq(relation-value("S"), 9)
#assert.eq(relation-value("m"), 3)
#assert.eq(relation-value("W"), 1)
#assert.eq(relation-value(none), 0)
#assert.eq(relation-value(""), 0)
#assert.eq(relation-value(0), 0)
#assert.eq(relation-value(9), 9)

#let m = qfd-matrix(2, 3, relations: ((1, 1, "S"), (1, 3, "W"), (2, 2, "M")))
#assert.eq(m, ((9, 0, 1), (0, 3, 0)))
#let w = qfd-weights((10, 5), m)
#assert.eq(w.absolute, (90, 15, 10))
#assert.eq(w.total, 115)
#assert.eq(w.rounded, (78, 13, 9))
#assert.eq(qfd-weights((0, 0), m).rounded, (0, 0, 0))
#assert.eq(qfd-weights((10,), ((0,),)).relative, (0,))
#assert.eq(qfd-weights((0.5,), (("S",),)).absolute, (4.5,))
#assert.eq(qfd-matrix(1, 1), ((0,),))

#assert.eq(qfd-correlation-point(1, 2), (x: 1, y: 0.5))
#assert.eq(qfd-correlation-point(1, 16), (x: 8, y: 7.5))
#assert.eq(qfd-correlation-point(16, 1), qfd-correlation-point(1, 16))
#assert.eq(_correlations(((2, 1, "++"),), 2).first().sign, "++")

// Every pair has a unique, interior diamond center in the triangular roof.
#for n in range(2, 20) {
  let points = ()
  for i in range(1, n) {
    for j in range(i + 1, n + 1) {
      let p = qfd-correlation-point(i, j, columns: n)
      assert(p.y > 0 and p.y < n / 2)
      assert(p.x > p.y and p.x < n - p.y)
      assert(not (p in points))
      points.push(p)
    }
  }
  assert.eq(points.len(), n * (n - 1) / 2)
}

