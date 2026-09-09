#import "../lib.typ": qfd, qfd-stage, qfd-diff
#set page(width:auto,height:auto)
#let old = qfd-stage(rows:((id:"n",label:"Need",weight:10),),
 columns:((id:"a",label:"A"),(id:"b",label:"B")), matrix:((3,9),), difficulty:(1,2))
#let current = qfd-stage(rows:((id:"n",label:"A much longer revised need",weight:9),),
 columns:((id:"a",label:"A much longer revised function"),), matrix:((9,),), difficulty:(3,))
#let delta = qfd-diff(old,current)
#assert.eq(delta.difficulty,(3,2))
#qfd(..delta, width:auto, ink:rgb("143a62"), theme:(symbol-thickness:1.5pt))
