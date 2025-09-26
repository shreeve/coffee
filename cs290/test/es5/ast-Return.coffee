# Return Solar Directive Tests
# ============================
# Tests {$ast: 'Return'} directive processing

test "(-> return 5)()", 5
test "(-> return 'hello')()", "hello"
test "(-> return true)()", true
test "(-> return null)()", null
test "(-> return [1, 2])()", [1, 2]
test "(-> return {x: 1})()", {x: 1}
test "(-> return Math.PI)()", Math.PI
test "(-> return 2 + 3)()", 5
test "(-> return 'a' + 'b')()", "ab"
test "(-> return false)()", false
test "(-> return 0)()", 0
test "(-> return undefined)()", undefined
test "(-> return 42 * 2)()", 84
test "(-> return 'test'.length)()", 4
