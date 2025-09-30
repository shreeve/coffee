# Operators
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify operators work correctly

# Arithmetic operators
test "3 + 4", 7
test "10 - 3", 7
test "5 * 6", 30
test "20 / 4", 5
test "17 % 5", 2
test "17 // 5", 3  # Floor division

# Exponentiation
test "2 ** 3", 8
test "3 ** 2", 9
test "10 ** 0", 1
test "2 ** -1", 0.5

# Unary operators
test "+5", 5
test "-5", -5
test "x = 5; +x", 5
test "x = 5; -x", -5

# Increment and decrement
test "x = 5; x++; x", 6
test "x = 5; ++x", 6
test "x = 5; x--; x", 4
test "x = 5; --x", 4

# Postfix vs prefix increment
test "x = 5; y = x++; y", 5
test "x = 5; y = ++x; y", 6
test "x = 5; y = x--; y", 5
test "x = 5; y = --x; y", 4

# Compound assignment
test "x = 5; x += 3; x", 8
test "x = 10; x -= 4; x", 6
test "x = 3; x *= 4; x", 12
test "x = 20; x /= 4; x", 5
test "x = 17; x %= 5; x", 2
test "x = 2; x **= 3; x", 8

# Comparison operators
test "5 > 3", true
test "3 > 5", false
test "5 < 10", true
test "10 < 5", false
test "5 >= 5", true
test "5 >= 3", true
test "3 <= 5", true
test "5 <= 5", true

# Equality operators
test "5 is 5", true
test "5 is '5'", false
test "5 isnt 5", false
test "5 isnt '5'", true
test "5 == 5", true
test "5 == '5'", false  # CoffeeScript's == is strict equality
test "5 != 5", false
test "5 != '5'", true   # CoffeeScript's != is strict inequality

# Strict equality (is/isnt in CoffeeScript)
test "null is null", true
test "undefined is undefined", true
test "null is undefined", false
test "NaN is NaN", false  # Special case
test "0 is -0", true

# Logical operators
test "true and true", true
test "true and false", false
test "false and true", false
test "true or false", true
test "false or false", false
test "not true", false
test "not false", true

# Logical operators with values
test "5 and 10", 10
test "0 and 10", 0
test "5 or 10", 5
test "0 or 10", 10
test "null or 'default'", "default"
test "'value' or 'default'", "value"

# Bitwise operators
test "5 & 3", 1
test "5 | 3", 7
test "5 ^ 3", 6
test "~5", -6
test "5 << 2", 20
test "20 >> 2", 5
test "20 >>> 2", 5

# instanceof operator
test "[] instanceof Array", true
test "{} instanceof Object", true
test "'string' instanceof String", false
test "5 instanceof Number", false
test "new Date() instanceof Date", true

# in operator (for objects) - use 'of' in CoffeeScript
test "'length' of []", true
test "'push' of []", true
test "'x' of {x: 1}", true
test "'y' of {x: 1}", false

# in operator (for arrays in CoffeeScript)
test "2 in [1, 2, 3]", true
test "4 in [1, 2, 3]", false
test "'a' in ['a', 'b', 'c']", true

# typeof operator
test "typeof 5", "number"
test "typeof 'string'", "string"
test "typeof true", "boolean"
test "typeof {}", "object"
test "typeof []", "object"
test "typeof null", "object"
test "typeof undefined", "undefined"
test "typeof (->)", "function"

# Existential operator ?
test "x = 5; x?", true
test "x = null; x?", false
test "x = undefined; x?", false
test "x = 0; x?", true
test "x = ''; x?", true
test "x = false; x?", true

# Existential operator with property access
test "obj = {x: 5}; obj.x?", true
test "obj = {}; obj.x?", false
test "obj = null; obj?.x", undefined
test "obj = {x: {y: 1}}; obj?.x?.y", 1

# Existential assignment ?=
test "x = null; x ?= 5; x", 5
test "x = 10; x ?= 5; x", 10
test "x = undefined; x ?= 'default'; x", "default"
test "x = 0; x ?= 5; x", 0

# Chained comparisons
test "1 < 2 < 3", true
test "1 < 3 < 2", false
test "5 > 4 > 3", true
test "x = 5; 0 < x <= 10", true

# Range creation
fail "1..5"  # Range without brackets is a syntax error
test "[1..3].join(',')", "1,2,3"
test "[1...4].join(',')", "1,2,3"

# Spread operator
test "Math.max(...[1, 5, 3])", 5
test "a = [2, 3]; [1, ...a, 4].join(',')", "1,2,3,4"

# Destructuring assignment operator
test "[a, b] = [1, 2]; a + b", 3
test "{x, y} = {x: 10, y: 20}; x + y", 30

# Delete operator
test "obj = {x: 1}; delete obj.x; obj.x", undefined
test "obj = {x: 1, y: 2}; delete obj.x; 'x' in obj", false

# Operator precedence
test "2 + 3 * 4", 14
test "(2 + 3) * 4", 20
test "10 - 2 - 3", 5
test "2 ** 3 ** 2", 512  # Right associative
test "not true and false", false
test "not (true and false)", true

# Special numeric values
test "Infinity + 1", Infinity
test "-Infinity < 0", true
test "1 / 0", Infinity
test "-1 / 0", -Infinity
test "0 / 0", NaN  # Note: NaN !== NaN
test "Infinity - Infinity", NaN

# String concatenation (not really an operator in CS)
test "'hello' + ' ' + 'world'", "hello world"
test "'test' + 123", "test123"

# Void operator (not supported in CoffeeScript - reserved word)
fail "void 0"
fail "void 42"
fail "void 'test'"
