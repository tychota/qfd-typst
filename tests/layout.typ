#import "../lib.typ": qfd
#set page(width: auto, height: auto, margin: 5mm)

// The following are compilation/inspection fixtures, not pixel-golden tests.
// All 128 combinations of the original seven visibility switches.
#for roof in (false, true) {
  for base in (false, true) {
    for comp in (false, true) {
      for imp in (false, true) {
        for legend in (false, true) {
          for corrleg in (false, true) {
            for evalleg in (false, true) {
              qfd(
                whats: ([First need], [Second need]),
                hows: ([First metric], [Second metric], [Third metric]),
                importance: (10, 5),
                relations: ((1, 1, "S"), (1, 2, "M"), (2, 3, "W")),
                correlations: ((1, 2, "++"), (1, 3, "--")),
                targets: ([1], [2], [3]),
                alternatives: ((label: [Alternative], scores: (0, 5)),),
                header-height: 2cm,
                show-roof: roof, show-basement: base, show-competitive: comp,
                show-importance: imp, show-legend: legend,
                show-corr-legend: corrleg, show-eval-legend: evalleg,
                width: auto,
              )
              pagebreak(weak: true)
            }
          }
        }
      }
    }
  }
}

// One cell, no explicit importance; no basement is inferred.
#qfd(whats: ("One",), hows: ("One",), matrix: ((9,),), width: auto)
#pagebreak(weak: true)

// Missing scores must break a path rather than invent an interpolated value.
#qfd(
  whats: ("A", "B", "C"), hows: ("X", "Y"),
  matrix: ((9, 0), (3, 1), (0, 9)),
  alternatives: ((label: "Sparse", scores: (2.5, none, 4)),),
  show-roof: false, width: auto,
)
#pagebreak(weak: true)

// Empty comparison scale with explicitly enabled panel; no evaluation legend.
#qfd(whats: ("A",), hows: ("X",), show-competitive: true,
  score-range: (-2, 2), width: auto)
#pagebreak(weak: true)

// Arbitrary native content, many alternatives, and an entirely custom basement.
#qfd(
  whats: ([A longer, *formatted* label that should wrap without crossing a cell edge.],),
  hows: ([$t_(95) "(ms)"$],),
  matrix: (("M",),),
  basement: ((label: [Custom], values: ([$alpha + beta$],)),),
  alternatives: range(7).map(i => (label: [Product #i], scores: (calc.rem(i, 6),))),
  show-rel-legend: false, show-corr-legend: false, width: auto,
)
