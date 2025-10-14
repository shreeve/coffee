# Advanced Arrays Solar Directive Tests
# ======================================
# Tests complex array operations and patterns

test "[1, 2, 3].length", 3
test "[1, 2, 3].join(', ')", "1, 2, 3"
test "[1, 2, 3].reverse()", [3, 2, 1]
test "[3, 1, 2].sort()", [1, 2, 3]
test "[1, 2, 3].slice(1)", [2, 3]
test "[1, 2, 3].slice(0, 2)", [1, 2]
test "[1, 2, 3].concat([4, 5])", [1, 2, 3, 4, 5]
test "[1, 2, 3].indexOf(2)", 1
test "[1, 2, 3].includes(2)", true
test "[1, 2, 3].includes(4)", false
test "[1, 2, 3].push(4)", 4
test "[1, 2, 3].pop()", 3
test "[1, 2, 3].shift()", 1
test "[1, 2, 3].unshift(0)", 4
test "Array.isArray([1, 2])", true
test "Array.isArray('string')", false
test "Array.from('abc')", ['a', 'b', 'c']
test "Array(3).fill(0)", [0, 0, 0]
