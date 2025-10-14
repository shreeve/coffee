# Complex Expression Solar Directive Tests
# =========================================
# Tests complex combinations of directives

test "Math.max(1, 2, 3)", 3
test "Math.min(10, 5, 8)", 5
test "'hello'.length", 5
test "[1, 2, 3].length", 3
test "{x: 1, y: 2}.x", 1
test "Object.keys({a: 1})", ['a']
test "Array.isArray([1, 2])", true
test "String('test').toUpperCase()", "TEST"
test "Number('42') + 8", 50
test "Boolean(1) and Boolean(0)", false
test "null ? 'default'", 'default'
test "undefined ? 'fallback'", 'fallback'
test "'test' ? 'found'", 'test'
test "[1, 2, 3][1]", 2
