# Splat Solar Directive Tests
# ===========================
# Tests {$ast: 'Splat'} directive processing

test "func = (args...) -> args; func(1, 2, 3)", [1, 2, 3]
test "f = (a, b...) -> b; f(1, 2, 3, 4)", [2, 3, 4]
test "g = (...rest) -> rest; g('a', 'b')", ['a', 'b']
test "arr = [1, 2]; [0, arr..., 3]", [0, 1, 2, 3]
test "nums = [10, 20]; Math.max(nums...)", 20
test "vals = ['x', 'y']; ['start', vals..., 'end']", ['start', 'x', 'y', 'end']
