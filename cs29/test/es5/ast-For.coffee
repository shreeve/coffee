# For Solar Directive Tests
# =========================
# Tests {$ast: 'For'} directive processing

test "for i in [1, 2, 3] then i", [1, 2, 3]
test "for x in [10, 20] then x * 2", [20, 40]
test "for n in [1..3] then n", [1, 2, 3]
test "for item in ['a', 'b'] then item", ['a', 'b']
test "for val in [true, false] then val", [true, false]
test "for num in [5, 10, 15] then num + 1", [6, 11, 16]
test "for char in 'abc' then char", ['a', 'b', 'c']
test "for elem in [] then elem", []
test "for i in [0...5] then i", [0, 1, 2, 3, 4]
test "for x in [42] then x", [42]
test "for i in [0..10] by 2 then i", [0, 2, 4, 6, 8, 10]
test "for i in [10..0] by -2 then i", [10, 8, 6, 4, 2, 0]
test "for i in [1..20] by 5 then i", [1, 6, 11, 16]
test "for i in [0..8] by 3 then i", [0, 3, 6]
