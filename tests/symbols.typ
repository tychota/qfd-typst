#import "../src/symbols.typ": _direction
#assert.eq(_direction("maximize"), [↑])
#assert.eq(_direction("minimize"), [↓])
#assert.eq(_direction("target"), [◎])
#assert.eq(_direction(none), [])
