# Miscellaneous Language Features
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify various language features work correctly

# Regular expressions
test "/test/.test('test')", true
test "/\\d+/.test('123')", true
test "/[a-z]+/i.test('ABC')", true
test "/^hello$/.test('hello')", true
test "/(\\d+)/.exec('abc123')[1]", "123"

# Regex flags
test "/test/i.test('TEST')", true
test "/^multi.*line$/m.test('multi\\nline')", true
test "/test/g.global", true

# Heregex (multiline regex)
test "///\\d+///.test('123')", true
test """
  ///
    \\d+  # digits
    \\.   # dot
    \\d+  # more digits
  ///.test('3.14')
""", true

# Comments
test "x = 5 # this is a comment\nx", 5
test """
  # Comment line
  x = 10
  x
""", 10

test """
  ###
    Block comment
    Multiple lines
  ###
  42
""", 42

# Do expressions
test "do -> 5", 5
test "x = 10; do (y = x) -> y * 2", 20
test "result = do -> 1 + 1; result", 2

# Default parameters
test "f = (x = 5) -> x; f()", 5
test "f = (x = 5) -> x; f(10)", 10
test "f = (a, b = a * 2) -> b; f(3)", 6

# Rest parameters
test "f = (first, rest...) -> rest.length; f(1, 2, 3)", 2
test "f = (items...) -> items.join('-'); f(1, 2, 3)", "1-2-3"

# Spread in calls
test "f = (a, b, c) -> a + b + c; f(...[1, 2, 3])", 6
test "Math.max(...[1, 5, 3])", 5

# Chained comparisons
test "1 < 2 < 3", true
test "3 > 2 > 1", true
test "x = 5; 0 <= x <= 10", true
test "5 < 3 < 10", false

# Switch expressions
test """
  x = 2
  result = switch x
    when 1 then 'one'
    when 2 then 'two'
    else 'other'
  result
""", "two"

# Implicit returns
test "f = -> 42; f()", 42
test "f = (x) -> x * 2; f(5)", 10
test "f = -> x = 5; x + 1; f()", 6

# Everything is an expression
test "x = if true then 5 else 10; x", 5
test "y = for i in [1..3] then i * 2; y.join(',')", "2,4,6"
test "z = try 10 catch e then 20; z", 10

# Number formats
test "0b1010", 10
test "0o12", 10
test "0xA", 10
test "1e3", 1000
test "3.14159", 3.14159

# Numeric separators
test "1_000_000", 1000000
test "0b1010_1010", 170
test "0xFF_FF", 65535

# BigInt literals
test "typeof 123n", "bigint"
test "456n > 400n", true
test "10n + 20n", 30n

# Boolean values
test "true", true
test "false", false
test "yes", true
test "no", false
test "on", true
test "off", false

# Undefined and null
test "undefined", undefined
test "null", null
test "void 0", undefined
test "null?", false
test "undefined?", false

# This binding
test """
  obj = {
    value: 42
    getValue: -> @value
  }
  obj.getValue()
""", 42

# Prototype access
test "class A; A::prop = 5; A.prototype.prop", 5
test "String::custom = -> 'test'; 'any'.custom()", "test"

# Property access
test "obj = {x: 5}; obj.x", 5
test "obj = {x: 5}; obj['x']", 5
test "obj = {'multi-word': 10}; obj['multi-word']", 10

# Dynamic property access
test "obj = {a: 1, b: 2}; key = 'b'; obj[key]", 2
test "arr = [10, 20]; index = 1; arr[index]", 20

# in operator
test "2 in [1, 2, 3]", true
test "'x' in {x: 1}", true
test "5 not in [1, 2, 3]", true

# of operator
test "(k for k of {a: 1, b: 2}).sort().join(',')", "a,b"
test "(v for k, v of {x: 10, y: 20}).sort().join(',')", "10,20"

# instanceof
test "[] instanceof Array", true
test "{} instanceof Object", true
test "5 instanceof Number", false

# typeof
test "typeof 5", "number"
test "typeof 'string'", "string"
test "typeof true", "boolean"
test "typeof {}", "object"
test "typeof []", "object"
test "typeof (->)", "function"

# delete operator
test "obj = {x: 1}; delete obj.x; obj.x", undefined
test "arr = [1, 2, 3]; delete arr[1]; arr[1]", undefined

# void operator
test "void 0", undefined
test "void 'anything'", undefined

# Parentheses for precedence
test "2 + 3 * 4", 14
test "(2 + 3) * 4", 20
test "not true and false", false
test "not (true and false)", true

# Line continuations
test """
  1 + \\
  2 + \\
  3
""", 6

# Statement modifiers
test "x = 5; x = 10 if x < 10; x", 10
test "x = 5; x = 10 unless x > 10; x", 10
test "result = []; result.push(i) for i in [1, 2]; result.join(',')", "1,2"
test "arr = [1, 2, 3]; sum = 0; sum += i while i = arr.shift(); sum", 6
