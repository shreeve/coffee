# Arrays
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify array features work correctly

# Basic array literals
test "[1, 2, 3].length", 3
test "[1, 2, 3][0]", 1
test "[1, 2, 3][2]", 3
test "['a', 'b', 'c'].join('-')", "a-b-c"

# Array with trailing commas
test "[1, 2, 3,].length", 3
test "[1,].length", 1
test "[,].length", 1

# Nested arrays
test "[[1, 2], [3, 4]][0][1]", 2
test "[[[1]]].length", 1
test "[[[1]]][0][0][0]", 1

# Array range literals
test "[1..5].join(',')", "1,2,3,4,5"
test "[1...5].join(',')", "1,2,3,4"
test "[5..1].join(',')", "5,4,3,2,1"
test "[10...10].length", 0
test "[10..10].length", 1

# Array slicing
test "[1,2,3,4,5][1..3].join(',')", "2,3,4"
test "[1,2,3,4,5][1...4].join(',')", "2,3,4"
test "[1,2,3,4,5][2..].join(',')", "3,4,5"
test "[1,2,3,4,5][..2].join(',')", "1,2,3"
test "[1,2,3,4,5][-2..].join(',')", "4,5"

# Array splicing
test "a = [1,2,3,4,5]; a[1..3] = [9]; a.join(',')", "1,9,5"
test "a = [1,2,3]; a[1...2] = [7,8]; a.join(',')", "1,7,8,3"
test "a = [1,2,3]; a[0..0] = [9]; a.join(',')", "9,2,3"

# Array concatenation
test "[1, 2].concat([3, 4]).join(',')", "1,2,3,4"
test "[].concat([1], [2], [3]).join(',')", "1,2,3"

# Spread operator in arrays
test "a = [2, 3]; [1, a..., 4].join(',')", "1,2,3,4"
test "a = [1, 2]; b = [3, 4]; [a..., b...].join(',')", "1,2,3,4"
test "[...[1, 2, 3]].join(',')", "1,2,3"

# Array destructuring
test "[a, b] = [1, 2]; a + b", 3
test "[x, y, z] = [1, 2, 3, 4, 5]; x + y + z", 6
test "[first, ...rest] = [1, 2, 3, 4]; rest.join(',')", "2,3,4"
test "[a, , c] = [1, 2, 3]; a + c", 4

# Array methods
test "[1, 2, 3].map((x) -> x * 2).join(',')", "2,4,6"
test "[1, 2, 3, 4, 5].filter((x) -> x > 2).join(',')", "3,4,5"
test "[1, 2, 3].reduce(((a, b) -> a + b), 0)", 6
test "[1, 2, 3].every((x) -> x > 0)", true
test "[1, 2, 3].some((x) -> x > 2)", true

# Array.from
test "Array.from('abc').join(',')", "a,b,c"
test "Array.from([1, 2, 3], (x) -> x * 2).join(',')", "2,4,6"
test "Array.from({length: 3}, (_, i) -> i).join(',')", "0,1,2"

# Array includes/indexOf
test "[1, 2, 3].includes(2)", true
test "[1, 2, 3].includes(4)", false
test "[1, 2, 3].indexOf(2)", 1
test "[1, 2, 3].indexOf(4)", -1

# Array push/pop
test "a = [1, 2]; a.push(3); a.join(',')", "1,2,3"
test "a = [1, 2, 3]; a.pop(); a.join(',')", "1,2"
test "a = [1, 2]; a.push(3, 4); a.join(',')", "1,2,3,4"

# Array shift/unshift
test "a = [1, 2, 3]; a.shift(); a.join(',')", "2,3"
test "a = [2, 3]; a.unshift(1); a.join(',')", "1,2,3"
test "a = [3]; a.unshift(1, 2); a.join(',')", "1,2,3"

# Array reverse
test "[1, 2, 3].reverse().join(',')", "3,2,1"
test "['a', 'b', 'c'].reverse().join('')", "cba"

# Array sort
test "[3, 1, 2].sort().join(',')", "1,2,3"
test "['c', 'a', 'b'].sort().join(',')", "a,b,c"
test "[10, 2, 3].sort((a, b) -> a - b).join(',')", "2,3,10"

# Array join
test "[1, 2, 3].join()", "1,2,3"
test "[1, 2, 3].join('')", "123"
test "[1, 2, 3].join(' ')", "1 2 3"

# Array comprehensions (for expression)
test "(x * 2 for x in [1, 2, 3]).join(',')", "2,4,6"
test "(x for x in [1, 2, 3, 4, 5] when x > 2).join(',')", "3,4,5"
test "(i for i in [0..4]).join(',')", "0,1,2,3,4"

# Nested array comprehensions
test "(x + y for x in [1, 2] for y in [10, 20]).join(',')", "11,21,12,22"

# Array equality (reference)
test "a = [1, 2]; b = a; a is b", true
test "a = [1, 2]; b = [1, 2]; a is b", false

# Empty arrays
test "[].length", 0
test "[].join(',')", ""
test "[].concat([]).length", 0

# Mixed type arrays
test "[1, 'two', true, null, undefined].length", 5
test "[1, 'two', true][1]", "two"
test "[1, 'two', true][2]", true

# Array with functions
test "a = [((x) -> x * 2), ((x) -> x + 1)]; a[0](5)", 10
test "a = [((x) -> x * 2), ((x) -> x + 1)]; a[1](5)", 6

# Array find/findIndex
test "[1, 2, 3, 4].find((x) -> x > 2)", 3
test "[1, 2, 3, 4].findIndex((x) -> x > 2)", 2

# Array flat/flatMap
test "[[1, 2], [3, 4]].flat().join(',')", "1,2,3,4"
test "[1, 2, 3].flatMap((x) -> [x, x * 2]).join(',')", "1,2,2,4,3,6"

# Array fill
test "[1, 2, 3, 4, 5].fill(0, 2, 4).join(',')", "1,2,0,0,5"
test "Array(3).fill(7).join(',')", "7,7,7"

# Array at method (ES2022)
test "[1, 2, 3].at(0)", 1
test "[1, 2, 3].at(-1)", 3
test "[1, 2, 3].at(-2)", 2
