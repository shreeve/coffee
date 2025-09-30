# Ranges and Slices
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify ranges and slicing work correctly

# Basic ranges
test "[1..5].join(',')", "1,2,3,4,5"
test "[1...5].join(',')", "1,2,3,4"
test "[0..3].join(',')", "0,1,2,3"
test "[0...3].join(',')", "0,1,2"

# Reverse ranges
test "[5..1].join(',')", "5,4,3,2,1"
test "[5...1].join(',')", "5,4,3,2"
test "[3..0].join(',')", "3,2,1,0"
test "[3...0].join(',')", "3,2,1"

# Single element ranges
test "[5..5].join(',')", "5"
test "[5...5].join(',')", ""
test "[1..1].length", 1
test "[1...1].length", 0

# Empty ranges
test "[5...5].length", 0
test "[10...10].length", 0
test "[1...1].join(',')", ""

# Ranges with variables
test "start = 2; end = 5; [start..end].join(',')", "2,3,4,5"
test "a = 1; b = 3; [a...b].join(',')", "1,2"
test "x = 10; [0..x].length", 11

# Array slicing with ranges
test "[1,2,3,4,5][1..3].join(',')", "2,3,4"
test "[1,2,3,4,5][1...4].join(',')", "2,3,4"
test "['a','b','c','d'][0..2].join(',')", "a,b,c"
test "['a','b','c','d'][0...2].join(',')", "a,b"

# Open-ended slices
test "[1,2,3,4,5][2..].join(',')", "3,4,5"
test "[1,2,3,4,5][2...].join(',')", "3,4,5"
test "[1,2,3,4,5][..2].join(',')", "1,2,3"
test "[1,2,3,4,5][...2].join(',')", "1,2"

# Negative indices in slices
test "[1,2,3,4,5][-2..].join(',')", "4,5"
test "[1,2,3,4,5][-3..-1].join(',')", "3,4,5"
test "[1,2,3,4,5][..-2].join(',')", "1,2,3,4"
test "[1,2,3,4,5][...-2].join(',')", "1,2,3"

# String slicing
test "'hello'[1..3]", "ell"
test "'hello'[1...4]", "ell"
test "'javascript'[0..3]", "java"
test "'javascript'[4..]", "script"
test "'test'[..-1]", "test"
test "'test'[...-1]", "tes"

# Slice assignment
test "a = [1,2,3,4,5]; a[1..3] = [9]; a.join(',')", "1,9,5"
test "a = [1,2,3,4,5]; a[1...3] = [8,9]; a.join(',')", "1,8,9,4,5"
test "a = [1,2,3]; a[..1] = [7,8]; a.join(',')", "7,8,3"
test "a = [1,2,3,4]; a[2..] = [9]; a.join(',')", "1,2,9"

# Compilation output tests
code "[1..5]", "[1, 2, 3, 4, 5];"
code "[1...5]", "[1, 2, 3, 4];"
code "[1,2,3,4,5][2..4]", "[1, 2, 3, 4, 5].slice(2, 5);"
code "[1,2,3,4,5][2...4]", "[1, 2, 3, 4, 5].slice(2, 4);"

# Slice with step (by) - use comprehensions instead
test "(i for i in [0..10] by 2).join(',')", "0,2,4,6,8,10"
test "(i for i in [1..10] by 3).join(',')", "1,4,7,10"
test "(i for i in [10..0] by -2).join(',')", "10,8,6,4,2,0"
test "(i for i in [10...0] by -1).length", 10

# Slice deletion
test "a = [1,2,3,4,5]; a[1..2] = []; a.join(',')", "1,4,5"
test "a = [1,2,3,4,5]; a[2...4] = []; a.join(',')", "1,2,5"

# Complex slice operations
test "a = [0..9]; a[2...8].join(',')", "2,3,4,5,6,7"
test "a = [1,2,3]; b = a[..]; b.join(',')", "1,2,3"
test "a = [1,2,3]; b = a[...]; b.join(',')", "1,2,3"

# Slice with expressions
test "a = [1,2,3,4,5]; i = 1; j = 3; a[i..j].join(',')", "2,3,4"
test "a = [1,2,3,4,5]; a[1+1..2+2].join(',')", "3,4,5"

# Multiple dimensional slicing
test "a = [[1,2],[3,4],[5,6]]; (row[0] for row in a[0..1]).join(',')", "1,3"
test "matrix = [[1,2,3],[4,5,6],[7,8,9]]; matrix[1][1..]

.join(',')", "5,6"

# Checking range membership (in operator)
test "3 in [1..5]", true
test "6 in [1..5]", false
test "5 in [1...5]", false
test "4 in [1...5]", true

# Range comparisons
test "[1..3].length is 3", true
test "[1...3].length is 2", true
test "[5..1].length is 5", true

# Character ranges (don't work in CS, but let's test the concept)
# test "['a'..'e'].join(',')", "a,b,c,d,e"  # This doesn't work in CoffeeScript

# Slice as function argument
test "Math.max(...[1..5])", 5
test "[].concat([1..3], [7..9]).join(',')", "1,2,3,7,8,9"

# Infinite-looking ranges (be careful!)
# test "[1..Infinity]", "throws or hangs"  # Don't actually test this

# Range with computed bounds
test "f = -> 3\n[1..f()].join(',')", "1,2,3"
test "getValue = -> 5\n[getValue()..getValue() + 2].join(',')", "5,6,7"

# Empty slice operations
test "[1,2,3][10..20].length", 0
test "'hello'[10..20]", ""
test "[1,2,3][5...5].length", 0

# Preserving array type with slices
test "[1,2,3][..] instanceof Array", true
test "Array.isArray([1,2,3][1..])", true

# Slice with splice-like behavior
test "a = [1,2,3,4,5]; a[2...4] = [7,8,9]; a.join(',')", "1,2,7,8,9,5"
test "a = [1,2,3]; a[1...1] = [9]; a.join(',')", "1,9,2,3"

# Edge cases
test "[0...0].length", 0
test "[null..null].length", 1  # null coerces to 0
test "[true..true].length", 1  # true coerces to 1
test "[false..false].length", 1  # false coerces to 0
