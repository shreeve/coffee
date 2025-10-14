# Functions
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify function features work correctly

# Basic function definition
test "f = -> 5\nf()", 5
test "add = (a, b) -> a + b\nadd(2, 3)", 5
test "greet = (name) -> 'Hello ' + name\ngreet('World')", "Hello World"

# Functions with default parameters
test "f = (x = 10) -> x\nf()", 10
test "f = (x = 10) -> x\nf(5)", 5
test "f = (a = 1, b = 2) -> a + b\nf()", 3
test "f = (a = 1, b = 2) -> a + b\nf(5)", 7
test "f = (a = 1, b = 2) -> a + b\nf(5, 3)", 8

# Rest parameters (splats)
test "f = (first, rest...) -> rest.length\nf(1, 2, 3, 4)", 3
test "f = (items...) -> items.join('-')\nf('a', 'b', 'c')", "a-b-c"
test "sum = (nums...) -> nums.reduce ((a,b) -> a+b), 0\nsum(1,2,3,4)", 10

# Function expressions
test "(-> 42)()", 42
test "((x) -> x * 2)(5)", 10
test "((a, b) -> a + b)(3, 4)", 7

# Functions returning functions
test "makeAdder = (x) -> (y) -> x + y\nadd5 = makeAdder(5)\nadd5(3)", 8
test "f = -> -> 'nested'\nf()()", 'nested'

# IIFE (Immediately Invoked Function Expression)
test "do -> 123", 123
test "x = 5; do -> x * 2", 10

# Fat arrow functions (bound functions)
test """
  obj =
    value: 42
    getValue: -> @value
    getBound: => @value
  obj.getValue()
""", 42

# Function with destructured parameters
test "f = ({x, y}) -> x + y\nf({x: 3, y: 4})", 7
test "f = ([a, b]) -> a * b\nf([5, 6])", 30
test "f = ({name}) -> 'Hello ' + name\nf({name: 'Alice', age: 30})", "Hello Alice"

# Nested functions
test """
  outer = (x) ->
    inner = (y) ->
      x + y
    inner(10)
  outer(5)
""", 15

# Functions with complex bodies
test """
  calculate = (op, a, b) ->
    switch op
      when '+' then a + b
      when '-' then a - b
      when '*' then a * b
      else 0
  calculate('+', 10, 5)
""", 15

# Anonymous functions in expressions
test "[1,2,3].map((x) -> x * 2).join(',')", "2,4,6"
test "[1,2,3].filter((x) -> x > 1).length", 2
test "[1,2,3].reduce(((a, b) -> a + b), 0)", 6

# Functions with explicit return
test "f = -> return 10; 20\nf()", 10
test "f = (x) -> return x * 2 if x > 5; x\nf(10)", 20
test "f = (x) -> return x * 2 if x > 5; x\nf(3)", 3

# Functions without parentheses in calls
test "f = -> 99\nf()", 99
test "double = (x) -> x * 2\ndouble 5", 10

# Recursive functions
test """
  factorial = (n) ->
    if n <= 1 then 1 else n * factorial(n - 1)
  factorial(5)
""", 120

# Functions with multiple statements
test """
  process = (x) ->
    result = x * 2
    result = result + 10
    result = result / 2
    result
  process(5)
""", 10

# Generator functions
test """
  gen = ->
    yield 1
    yield 2
    yield 3
  g = gen()
  [g.next().value, g.next().value, g.next().value]
""", [1, 2, 3]

# Functions with arguments object
test """
  f = ->
    Array.from(arguments).join('-')
  f('a', 'b', 'c')
""", 'a-b-c'

# Function length property
test "((a, b, c) ->).length", 3
test "((a, b = 1) ->).length", 1
test "((a, ...rest) ->).length", 1

# Function name property
test "(f = ->).name", 'f'

# Partial application pattern
test """
  multiply = (a) -> (b) -> a * b
  double = multiply(2)
  triple = multiply(3)
  double(5) + triple(5)
""", 25

# Functions as object methods
test """
  obj =
    x: 10
    getX: -> @x
    doubleX: -> @x * 2
  obj.getX() + obj.doubleX()
""", 30

# Function composition
test """
  compose = (f, g) -> (x) -> f(g(x))
  double = (x) -> x * 2
  addOne = (x) -> x + 1
  doubleThenAdd = compose(addOne, double)
  doubleThenAdd(5)
""", 11

# Currying pattern
test """
  curry = (fn) ->
    (a) -> (b) -> fn(a, b)
  add = (a, b) -> a + b
  curriedAdd = curry(add)
  curriedAdd(3)(4)
""", 7

# Function with guard clauses
test """
  safeDivide = (a, b) ->
    return 0 if b is 0
    a / b
  safeDivide(10, 2)
""", 5

# Compilation output tests
code "->", "(function() {});"
code "=>", "(() => {});"
code "(x) -> x", "(function(x) {\n  return x;\n});"
code "(x) => x", "((x) => {\n  return x;\n});"

# Critical test: Arrow functions MUST compile to arrow syntax to preserve 'this'
# This test catches bugs where funcGlyph isn't passed to Code constructor
test """
  class Timer
    constructor: ->
      @seconds = 0
      @tick = => @seconds++
    start: ->
      @tick()
      @seconds

  timer = new Timer()
  timer.start()
""", 1

# Invalid syntax tests
fail "function foo() {}"  # function keyword not allowed
fail "new function() {}"  # anonymous function with new

# Higher-order functions
test """
  applyTwice = (f, x) -> f(f(x))
  double = (x) -> x * 2
  applyTwice(double, 3)
""", 12
