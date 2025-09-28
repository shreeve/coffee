# Special Invocation Patterns
# ===========================
# Tests for special function invocation patterns and implicit calls

# Implicit calls without parentheses
test "func = -> 5; func()", 5
test "add = (a, b) -> a + b; add 2, 3", 5
test "Math.max 1, 2, 3", 3

# Implicit calls with objects
test "func = (obj) -> obj.x; func x: 10", 10
test "func = (obj) -> obj.a + obj.b; func a: 1, b: 2", 3

# Chained calls
test "[1, 2, 3].map((x) -> x * 2).filter((x) -> x > 2).join ','", "4,6"
test "'hello'.replace('l', 'L').replace('o', 'O')", "heLLO"

# Splat calls
test "func = (args...) -> args.length; func 1, 2, 3", 3
test "add = (a, b, c) -> a + b + c; args = [1, 2, 3]; add args...", 6
test "Math.max [1, 5, 3]...", 5

# Implicit objects in calls
test """
  func = (opts) -> opts.x + opts.y
  func
    x: 10
    y: 20
""", 30

# Multiple function arguments
test """
  call = (f1, f2) -> f1() + f2()
  call (-> 10), (-> 20)
""", 30

# Trailing if/unless in calls
test "func = (x) -> x; result = func 10 if true; result", 10
test "func = (x) -> x; result = func 20 unless false; result", 20

# Function calls with operators
test "func = (x) -> x + 1; func +5", 6
test "func = (x) -> x + 1; func -5", -4

# Prefix operators in calls
test "func = (x) -> x; val = 5; func --val", 4
test "func = (x) -> x; val = 5; func ++val", 6

# Chained property access and calls
test "obj = {get: -> {value: -> 42}}; obj.get().value()", 42
test "str = 'test'; str.toUpperCase().split('').join '-'", "T-E-S-T"

# Optional chaining in calls
test "obj = {method: -> 5}; obj.method?()", 5
test "obj = {}; obj.method?()", undefined
test "obj = null; obj?.method?()", undefined

# Destructuring in function parameters
test "func = ([a, b]) -> a + b; func [10, 20]", 30
test "func = ({x, y}) -> x * y; func {x: 3, y: 4}", 12

# Default parameters with calls
test "func = (a = (-> 5)()) -> a; func()", 5
test "func = (a = Math.max(1, 2, 3)) -> a; func()", 3

# Constructor calls
test "class A then constructor: (@x) ->; (new A 5).x", 5
test "class B; typeof new B", "object"
test "Array.isArray new Array 5", true

# Super calls
test """
  class Base
    method: (x) -> x * 2
  class Child extends Base
    method: (x) -> super(x) + 1
  (new Child).method 5
""", 11

# Tagged template calls (if supported)
# test "tag = (s) -> s[0]; tag'hello'", "hello"

# Implicit returns in calls
test "func = -> val = 10; val * 2; func()", 20
test "func = -> if true then 5 else 10; func()", 5

# Parentheses-less chains
test """
  double = (x) -> x * 2
  add = (x) -> (y) -> x + y
  result = add 5 double 3
  result
""", 11

# Function calls in conditionals
test "func = -> true; if func() then 'yes' else 'no'", "yes"
test "func = -> 10; x = 5; x = func() if x < 10; x", 10

# Implicit object with number values
test "func = (obj) -> obj.a; func a: 1", 1
test "func = (x, y) -> y; func 'a', 1", 1

# Execution context for splat calls
test """
  arr = []
  func = -> @ instanceof Array
  func.call arr
""", true

# IIFE patterns
test "(-> 42)()", 42
test "do -> 123", 123
test "((x) -> x * 2) 5", 10

# Method calls with complex receivers
test "[1, 2, 3]['length']", 3
test "{'a': {b: -> 'nested'}}['a'].b()", "nested"
test "(if true then {m: -> 5} else {m: -> 10}).m()", 5

# Arguments in nested functions
test """
  outer = ->
    inner = ->
      Array.from(arguments).join ','
    inner 1, 2, 3
  outer()
""", "1,2,3"

# Call with block parameters
test """
  func = (callback) -> callback 10
  func (x) ->
    x * 2
""", 20
