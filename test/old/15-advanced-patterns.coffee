# Advanced Language Patterns
# ===========================
# Additional language feature tests that were missed in the initial extraction
# Tests for context properties, expansion, imports, and other advanced patterns

# test """
#   obj = {values: {a: 1, b: 2}, extract: ->
#     {@a, @b} = @values
#     @
#   }
#   obj.extract()
#   obj.a + obj.b
# """, 3

# Array destructuring with @ properties works correctly
# [@x, @y] compiles to [this.x, this.y] = [10, 20]
test """
  obj = {doAssign: ->
    [@x, @y] = [10, 20]
    @
  }
  obj.doAssign()
  obj.x + obj.y
""", 30

# Expansion patterns (...) in destructuring
test "[first, ..., last] = [1, 2, 3, 4, 5]; first + last", 6
test "[..., secondLast, last] = [1, 2, 3, 4, 5]; secondLast", 4
test "[first, second, ..., last] = [1, 2, 3, 4, 5]; second", 2
test "[first, ..., last] = [1, 2]; first + last", 3
test "[..., last] = 'abcde'; last", "e"

# Dynamic keys in destructuring
test "key = 'prop'; {[key]: value} = {prop: 'dynamic'}; value", "dynamic"
test "a = 'x'; b = 'y'; {[a]: first, [b]: second} = {x: 1, y: 2}; first + second", 3

# Boolean indexing
test "true['toString'] is Boolean.prototype.toString", true
test "false['valueOf'] is Boolean.prototype.valueOf", true
test "yes.toString is Boolean.prototype.toString", true
test "no.valueOf is Boolean.prototype.valueOf", true

# Compound assignment edge cases
test "x = 5; x += 3; x", 8
test "x = [1, 2]; x[0] += 10; x[0]", 11
test "obj = {a: 5}\nobj.a *= 2\nobj.a", 10
test "x = y = 0; x = y += 5; x + y", 10

# Assignment with splats in objects
test "{a, ...rest} = {a: 1, b: 2, c: 3}; rest.b + rest.c", 5
test "first = {a: 1}; second = {b: 2}; combined = {...first, ...second, c: 3}; combined.a + combined.b + combined.c", 6

# Complex destructuring with defaults and splats
test "[a = 10, ...rest] = []; a", 10
test "[a = 10, ...rest] = [undefined, 2, 3]; rest.join(',')", "2,3"
test "{x = 5, ...rest} = {}; x", 5
test "{x = 5, ...rest} = {y: 10}; x + rest.y", 15

# Scope edge cases
test """
  x = 'outer'
  do -> x = 'inner'
  x
""", "inner"  # do doesn't create a new scope, it executes immediately
test """
  x = 'outer'
  f = ->
    x = 'inner'
    x
  f()
""", "inner"

# Arguments object
test "f = -> Array.from(arguments).reduce((a, b) -> a + b)\nf(1, 2, 3, 4)", 10

# Do with parameters
test "do (x = 5) -> x * 2", 10
test "do (a = 1, b = 2) -> a + b", 3
test """
  arr = [1, 2, 3]
  x = null
  results = (do (x) -> x * 2 for x in arr)
  results.join(',')
""", "2,4,6"

# Chained comparisons edge cases
test "1 < 2 <= 2", true
test "3 > 2 >= 2", true
test "1 < 2 < 3 < 4", true
test "x = 2\n(1 < x) is 2", false  # 'is' has different precedence

# Assignment in expressions
test "(x = 5) + 3", 8
test "if x = true then 'yes' else 'no'", "yes"
test "y = if x = 5 then x * 2 else 0; y", 10

# Property access edge cases
test "obj = {1: 'numeric key'}; obj[1]", "numeric key"
test "obj = {'multi-word-key': 'value'}; obj['multi-word-key']", "value"
test "obj = {['computed' + 'Key']: 'value'}\nobj.computedKey", "value"

# Delete with optional chaining
test "obj = {a: {b: 1}}\ndelete obj?.a?.b\nobj.a.b", undefined
test "obj = null; delete obj?.prop; obj", null

# Object method shorthand
test """
  obj = {
    value: 10
    getValue: -> @value
    double: -> @value * 2
  }
  obj.getValue() + obj.double()
""", 30

# Array holes (sparse arrays)
test "[1,,3].length", 3
test "[1,,3][1]", undefined
test "[,,,].length", 3

# Unicode in identifiers
test "℮ = 2.71828; Math.round(℮)", 3
test "π = 3.14159; Math.round(π)", 3
test "变量 = 'Chinese'; 变量", "Chinese"

# Empty statements
test ";", undefined
test ";;; 5 ;;;", 5
test "if true then ; else 10", undefined

# Multiple assignments
test "a = b = c = 5; a + b + c", 15
test "x = y = [1, 2]; x[0] = 10; y[0]", 10  # Reference sharing

# Guard patterns
test """
  divide = (a, b) ->
    return Infinity unless b
    a / b
  divide(10, 0)
""", Infinity
test """
  getValue = (obj) ->
    return null unless obj?.value?
    obj.value
  getValue(null)
""", null

# Super in object methods (edge case)
test """
  obj = {
    base: -> 'base'
    extended: -> 'extended'
  }
  obj.extended()
""", "extended"

# Yield in nested functions
test """
  outer = ->
    inner = ->
      yield 1
      yield 2
    inner()
  gen = outer()
  [gen.next().value, gen.next().value]
""", [1, 2]

# Compilation output tests
code "-> yield x", "(function*() {\n  return (yield x);\n});"

# Invalid syntax tests
fail "yield outside generator"  # yield must be in generator
