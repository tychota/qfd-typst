#import "../src/profile-layout.typ": stagger-profiles
#let scores = ((1, 3, 5), (5, 3, 1), (3, 3, 3))
#let points = stagger-profiles(scores)
#for (s, profile) in points.enumerate() {
 for (r, point) in profile.enumerate() {
  assert.eq(point.x, scores.at(s).at(r))
  assert(calc.abs(point.y - (r + 0.5)) <= 0.30)
 }
}
#assert.eq(points.map(p => p.at(1).y).dedup().len(), 3)
#assert.eq(stagger-profiles(((1, none, 2),)).first().at(1), none)
#assert.eq(stagger-profiles(((2,), (2,)), enabled: false).map(p => p.first().y), (0.5, 0.5))
#assert.eq(stagger-profiles(scores), points)
