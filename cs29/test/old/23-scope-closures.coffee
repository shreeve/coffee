# Scope and Closures
# ===========================
# Tests for variable scope, closures, and the do keyword

# Basic scope
test "x = 5; do -> x = 10; x", 5  # Inner scope doesn't affect outer
test "x = 5; (-> x = 10)(); x", 10  # Without 'do', it modifies outer

# do with parameters
test "do (x = 5) -> x", 5
test "do (x = 10, y = 20) -> x + y", 30
test "x = 5; do (x = 10) -> x", 10  # Shadows outer x
test "x = 5; do (x) -> x", 5  # Passes outer x

# Closure basics
test """
  makeAdder = (x) ->
    (y) -> x + y
  add5 = makeAdder(5)
  add5(3)
""", 8

test """
  counter = ->
    count = 0
    -> count++
  c = counter()
  [c(), c(), c()]
""", [0, 1, 2]

# Capturing loop variables with do
test """
  funcs = []
  for i in [0..2]
    do (i) ->
      funcs.push -> i
  (f() for f in funcs).join(',')
""", "0,1,2"

# Without do (captures final value)
test """
  funcs = []
  for i in [0..2]
    funcs.push -> i
  (f() for f in funcs).join(',')
""", "3,3,3"

# Nested scopes
test """
  a = 1
  f = ->
    a = 2
    g = ->
      a = 3
    g()
    a
  f()
""", 3

# Variable shadowing
test """
  x = 'outer'
  f = (x) ->
    x = 'inner'
    x
  f('param')
""", "inner"

# this binding
test """
  obj = {
    value: 42
    regular: -> @value
    arrow: => @value
  }
  obj.regular()
""", 42

# Global scope
test "global.testGlobal = 'test'; global.testGlobal", "test"
test "delete global.testGlobal; global.testGlobal", undefined

# Lexical scope
test """
  x = 'outer'
  f = ->
    x  # References outer x
  g = ->
    x = 'inner'
    f()
  g()
""", "outer"

# Block scope (CoffeeScript doesn't have block scope like let/const)
test """
  x = 1
  if true
    x = 2
  x
""", 2

# Function scope for arguments
test """
  f = ->
    Array.from(arguments).join(',')
  f(1, 2, 3)
""", "1,2,3"

# Immediately invoked functions
test "(-> 'iife')()", "iife"
test "((x) -> x * 2)(5)", 10
test "do -> 'with do'", "with do"

# Closure with objects
test """
  makeObj = (val) ->
    {
      getValue: -> val
      setValue: (newVal) -> val = newVal
    }
  obj = makeObj(10)
  obj.setValue(20)
  obj.getValue()
""", 20

# Hoisting behavior (functions are hoisted in CoffeeScript)
test """
  f()
  f = -> 'hoisted'
""", "hoisted"

# do in comprehensions
test "(do (x) -> x * x for x in [1, 2, 3]).join(',')", "1,4,9"
test """
  results = []
  for x in [1, 2, 3]
    do (x) ->
      results.push -> x * 2
  (f() for f in results).join(',')
""", "2,4,6"

# Scope chain
test """
  a = 1
  f = ->
    b = 2
    g = ->
      c = 3
      h = ->
        a + b + c
      h()
    g()
  f()
""", 6

# Closure with destructuring
test """
  make = ({x, y}) ->
    -> x + y
  f = make({x: 10, y: 20})
  f()
""", 30

# Private variables via closure
test """
  counter = do ->
    count = 0
    {
      increment: -> count++
      get: -> count
    }
  counter.increment()
  counter.increment()
  counter.get()
""", 2

# Scope with try/catch
test """
  x = 1
  try
    x = 2
    throw new Error()
  catch e
    x = 3
  x
""", 3

# Variable declaration positions
test "x = 5; y = (x = 10); x", 10
test "if (x = 5) > 3 then x else 0", 5
test "x = 10; x = 20 if x > 5; x", 20

# Recursive closures
test """
  factorial = do ->
    fact = (n) ->
      if n <= 1 then 1 else n * fact(n - 1)
    fact
  factorial(5)
""", 120
