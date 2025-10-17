# Range Solar Directive Tests
# ===========================
# Tests {$ast: 'Range'} directive processing

test "[1..5]", [1, 2, 3, 4, 5]
test "[1...5]", [1, 2, 3, 4]
test "[0..3]", [0, 1, 2, 3]
test "[5..1]", [5, 4, 3, 2, 1]
test "[-2..2]", [-2, -1, 0, 1, 2]
test "[10...10]", []
