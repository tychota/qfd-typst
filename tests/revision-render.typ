#import "../lib.typ": qfd, qfd-stage, qfd-diff
#set page(width:auto,height:auto)
#let old = qfd-stage(rows:((id:"n",label:"Need",weight:10),),
 columns:((id:"a",label:"A"),(id:"b",label:"B")), matrix:((3,9),), difficulty:(1,2))
#let current = qfd-stage(rows:((id:"n",label:"A much longer revised need",weight:9),),
 columns:((id:"a",label:"A much longer revised function"),), matrix:((9,),), difficulty:(3,))
#let delta = qfd-diff(old,current)
#assert.eq(delta.difficulty,(3,2))
#qfd(..delta, width:auto, ink:rgb("143a62"), theme:(symbol-thickness:1.5pt))

#import "../src/change-display.typ": cell-background-status
#let bands = (changes: (
  rows: ("added", "removed", "unchanged", "changed"),
  columns: ("added", "removed", "unchanged"),
  cells: (("unchanged", "unchanged", "unchanged"),) * 4,
))
#assert.eq(cell-background-status(bands, 0, 2), "added")
#assert.eq(cell-background-status(bands, 1, 2), "removed")
#assert.eq(cell-background-status(bands, 2, 0), "added")
#assert.eq(cell-background-status(bands, 2, 1), "removed")
#assert.eq(cell-background-status(bands, 0, 1), "unchanged")
#assert.eq(cell-background-status(bands, 1, 0), "unchanged")
#assert.eq(cell-background-status(bands, 3, 2), "unchanged")
