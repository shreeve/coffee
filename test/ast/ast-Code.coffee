# Code Solar Directive Tests
# ==========================
# Tests {$ast: 'Code'} directive processing (functions)

# Runtime tests - basic execution
test "(-> 5)()", 5
test "(=> 10)()", 10
test "((x) -> x)(42)", 42
test "((a, b) -> a + b)(3, 4)", 7
test "(-> 'hello')()", "hello"
test "(=> true)()", true
test "((n) -> n * 2)(10)", 20
test "(-> null)()", null
test "((x) => x + 1)(42)", 43
test "(-> [1, 2, 3])()", [1, 2, 3]
test "((s) -> s.toUpperCase())('hello')", "HELLO"
test "(-> Math.PI)()", Math.PI

# Compilation output tests - verify arrow functions
# In ES6 mode, simple -> functions become arrows when they don't use special contexts
code "->", "(() => {});"
code "=>", "(() => {});"
code "(x) -> x", "((x) => x);"
code "(x) => x", "((x) => x);"
code "(a, b) -> a + b", "((a, b) => a + b);"
code "(a, b) => a + b", "((a, b) => a + b);"

# Runtime tests - verify this binding behavior
test """
  obj = {
    value: 42
    regular: -> @value
    bound: => @value
  }
  obj.regular()
""", 42

test """
  obj = {
    value: 42
    regular: -> @value
    bound: => @value
  }
  # Regular function loses 'this' when extracted
  f = obj.regular
  f.call({value: 99})
""", 99

test """
  class Example
    constructor: ->
      @value = 42
      @getRegular = -> @value
      @getBound = => @value

  obj = new Example()
  # Bound function keeps 'this' when extracted
  f = obj.getBound
  f.call({value: 99})
""", 42

# Nested arrow functions should preserve binding
test """
  obj = {
    value: 10
    outer: ->
      inner = => @value * 2
      inner()
  }
  obj.outer()
""", 20

# Arrow functions in callbacks should preserve this
test """
  obj = {
    values: [1, 2, 3]
    multiplier: 2
    process: ->
      @values.map((x) => x * @multiplier)
  }
  obj.process()
""", [2, 4, 6]

# Multiple levels of arrow function nesting
test """
  class Example
    constructor: ->
      @x = 5
    f: =>
      g = =>
        h = => @x
        h()
      g()

  obj = new Example()
  obj.f()
""", 5
