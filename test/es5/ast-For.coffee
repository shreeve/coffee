# For Solar Directive Tests
# =========================
# Tests {$ast: 'For'} directive processing
# Note: These test natural CoffeeScript behavior (last value returned)

test "for i in [1, 2, 3] then i", 3
test "for x in [10, 20] then x * 2", 40
test "for n in [1..3] then n", 3
test "for item in ['a', 'b'] then item", 'b'
test "for val in [true, false] then val", false
test "for num in [5, 10, 15] then num + 1", 16
test "for char in 'abc' then char", 'c'
test "for elem in [] then elem", undefined
test "for i in [0...5] then i", 4
test "for x in [42] then x", 42
test "for i in [0..10] by 2 then i", 10
test "for i in [10..0] by -2 then i", 0
test "for i in [1..20] by 5 then i", 16
test "for i in [0..8] by 3 then i", 6
