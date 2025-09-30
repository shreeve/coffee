# Advanced Assignment Patterns
# ===========================
# Tests for complex assignment patterns and edge cases

# Multiple assignment
test "a = b = c = 5; a + b + c", 15
test "x = y = [1, 2]; x[0] = 9; y[0]", 9  # Reference sharing

# Conditional assignment operators
test "x = 5; x ||= 10; x", 5
test "x = 0; x ||= 10; x", 10
test "x = null; x ?= 5; x", 5
test "x = false; x ?= 5; x", false
test "x = ''; x ||= 'default'; x", "default"
test "x = ''; x ?= 'default'; x", ""

# Compound assignment operators
test "x = 5; x += 3; x", 8
test "x = 10; x -= 3; x", 7
test "x = 4; x *= 3; x", 12
test "x = 15; x /= 3; x", 5
test "x = 17; x %= 5; x", 2
test "x = 17; x //= 5; x", 3
test "x = 2; x **= 3; x", 8

# Logical assignment operators
test "x = true; x &&= false; x", false
test "x = false; x &&= true; x", false
test "x = true; x ||= false; x", true
test "x = null; x ||= 'value'; x", "value"

# Bitwise compound assignment
test "x = 5; x &= 3; x", 1
test "x = 5; x |= 3; x", 7
test "x = 5; x ^= 3; x", 6
test "x = 4; x <<= 2; x", 16
test "x = 16; x >>= 2; x", 4
test "x = -16; x >>>= 2; x > 0", true

# Destructuring with defaults and existing variables
test "x = 10; [x = 5] = []; x", 5
test "x = 10; [x = 5] = [undefined]; x", 5
test "x = 10; [x = 5] = [null]; x", null
test "x = 10; [x = 5] = [20]; x", 20

# Nested destructuring assignment
test "[a, [b, c]] = [1, [2, 3]]; a + b + c", 6
test "[[x], [[y]]] = [[1], [[2]]]; x + y", 3
test "{a: {b: {c}}} = {a: {b: {c: 5}}}; c", 5

# Assignment in expressions
test "x = (y = 5) + 3; x", 8
test "if x = true then x else false", true
test "arr = []; arr[i = 0] = i = 5; arr[0]", 5

# Assignment with side effects
test """
  i = 0
  obj = {}
  obj[i++] = i++
  obj[0]
""", 1

# Assignment precedence
test "x = y = 2 * 3; x", 6
test "x = 1; y = x += 2; y", 3
test "a = b = c = 1 + 2; a + b + c", 9

# Property assignment
test "obj = {}; obj.x = obj.y = 5; obj.x + obj.y", 10
test "obj = {a: {}}; obj.a.b = 10; obj.a.b", 10
test "arr = [{}]; arr[0].x = 5; arr[0].x", 5

# Assignment with method calls
test "obj = {setValue: (@value) -> @}; obj.setValue(10).value", 10
test "arr = []; arr.push(x = 5); x", 5

# Swapping variables
test "a = 1; b = 2; [a, b] = [b, a]; a", 2
test "x = 'a'; y = 'b'; [x, y] = [y, x]; x + y", "ba"

# Assignment with splats
test "[first, ...rest] = [1, 2, 3, 4]; rest.length", 3
test "[a, ..., last] = [1, 2, 3, 4, 5]; last", 5
test "{a, ...rest} = {a: 1, b: 2, c: 3}; rest.b", 2

# Assignment with computed properties
test "key = 'prop'; obj = {}; obj[key] = 'value'; obj.prop", "value"
test "i = 1; obj = {}; obj['key' + i] = 'val'; obj.key1", "val"

# Assignment returns value
test "x = 5", 5
test "obj = {}; obj.prop = 'test'", "test"
test "[a, b] = [1, 2]", [1, 2]

# Empty destructuring
test "[] = [1, 2, 3]; true", true
test "{} = {a: 1}; true", true
test "[,] = [1]; true", true

# Assignment with holes
test "[a, , c] = [1, 2, 3]; c", 3
test "[, , third] = [1, 2, 3]; third", 3
test "[first, , , fourth] = [1, 2, 3, 4]; fourth", 4

# Complex compound assignment
test "obj = {x: 5}; obj.x **= 2; obj.x", 25
test "arr = [10]; arr[0] //= 3; arr[0]", 3
test "obj = {a: {b: 5}}; obj.a.b *= 2; obj.a.b", 10

# Assignment with ternary-like conditionals
test "x = if true then 5 else 10; x", 5
test "y = unless false then 'yes' else 'no'; y", "yes"

# Assignment with for loops
test "arr = (x * 2 for x in [1, 2, 3]); arr.join(',')", "2,4,6"
test "obj = {a: 1, b: 2}; keys = (k for k of obj); keys.sort().join(',')", "a,b"

# Assignment with while loops
test """
  i = 0
  arr = []
  arr.push(i) while i++ < 3
  arr.join(',')
""", "0,1,2,3"

# Parallel assignment
test "[a, b] = [b, a] = [1, 2]; a + b", 3
test "x = y = z = 0; [x, y, z] = [1, 2, 3]; x + y + z", 6

# Compilation output tests
code "a = b = 5", "var a, b;\n\na = b = 5;"
code "x ||= 10", "var x;\n\nx || (x = 10);"
code "y &&= 20", "var y;\n\ny && (y = 20);"
