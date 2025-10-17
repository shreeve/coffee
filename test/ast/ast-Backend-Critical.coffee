# Backend Critical Tests
# ======================
# These tests verify that the Backend properly passes all required parameters
# to AST node constructors. Missing parameters can cause subtle bugs.

# CRITICAL: Code constructor requires funcGlyph parameter
# Without it, arrow functions compile to regular functions, breaking 'this' binding

# Test 1: Arrow function compilation output
code "=>", "(() => {});"
code "(x) => x * 2", "((x) => x * 2);"
code "() => 42", "(() => 42);"

# Test 2: Regular function compilation output (optimized to arrows in ES6 when safe)
code "->", "(() => {});"
code "(x) -> x * 2", "((x) => x * 2);"
code "() -> 42", "(() => 42);"

# Test 3: Arrow function 'this' binding in classes
test """
  class Counter
    constructor: ->
      @count = 0
      @increment = => @count++
      @decrement = -> @count--

    getCount: -> @count

  c = new Counter()
  # Arrow function preserves 'this' when called via reference
  inc = c.increment
  inc()
  inc()
  c.getCount()
""", 2

# Test 4: Arrow functions in nested contexts
test """
  class Multiplier
    constructor: (@factor) ->

    apply: (nums) ->
      nums.map (x) => x * @factor

  m = new Multiplier(3)
  m.apply([1, 2, 3])
""", [3, 6, 9]

# Test 5: Arrow functions in setTimeout/callbacks
test """
  class DelayedValue
    constructor: (@value) ->
      @getValue = => @value

    extract: -> @getValue

  obj = new DelayedValue(42)
  fn = obj.extract()
  fn()
""", 42

# Test 6: Mixed arrow and regular functions
test """
  class Mixed
    constructor: ->
      @x = 10
      @arrow = => @x
      @regular = -> @x

    testArrow: ->
      f = @arrow
      f.call({x: 99})  # Should return 10 (bound)

    testRegular: ->
      f = @regular
      f.call({x: 99})  # Should return 99 (not bound)

  m = new Mixed()
  [m.testArrow(), m.testRegular()]
""", [10, 99]

# Test 7: Arrow function with parameters and 'this'
test """
  class Calculator
    constructor: (@base) ->
      @add = (x) => @base + x
      @multiply = (x) => @base * x

  calc = new Calculator(5)
  calc.add(3) + calc.multiply(2)
""", 18

# Test 8: Deeply nested arrow functions
test """
  class Nested
    constructor: (@value) ->
      @level1 = =>
        level2 = =>
          level3 = => @value
          level3()
        level2()

  n = new Nested(7)
  n.level1()
""", 7

# Test 9: Arrow functions in array methods
test """
  class Processor
    constructor: (@prefix) ->

    process: (items) ->
      items
        .filter (x) => x > 5
        .map (x) => @prefix + x

  p = new Processor('>')
  p.process([3, 7, 4, 9])
""", ['>7', '>9']

# Test 10: Constructor with both arrow and regular, extracted
test """
  class Example
    constructor: ->
      @name = 'test'
      @bound = => "bound:" + @name
      @unbound = -> "unbound:" + @name

  e = new Example()
  b = e.bound
  u = e.unbound
  [b(), u.call({name: 'other'})]
""", ['bound:test', 'unbound:other']
