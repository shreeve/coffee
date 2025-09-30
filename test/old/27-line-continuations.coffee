# Line Continuations and Formatting
# ===========================
# Tests for line continuation, indentation, and special formatting

# Backslash line continuation
test """
  1 + \\
  2 + \\
  3
""", 6

test """
  "hello" + \\
  " " + \\
  "world"
""", "hello world"

# Operators that continue lines
test """
  1 +
  2 +
  3
""", 6

test """
  5 *
  2 +
  3
""", 13

test """
  true and
  true and
  true
""", true

# Chained property access
test """
  "test"
  .toUpperCase()
  .split('')
  .join('-')
""", "T-E-S-T"

test """
  [1, 2, 3]
    .map (x) -> x * 2
    .filter (x) -> x > 2
    .join ','
""", "4,6"

# Chained comparisons
test """
  1 < 2 <
  3 < 4
""", true

# Method chaining with optional
test """
  obj = {
    a: -> @
    b: -> @
    c: -> 'done'
  }
  obj
    .a()
    ?.b()
    ?.c()
""", "done"

# Multi-line conditionals
test """
  if true and
     true
    'yes'
  else
    'no'
""", "yes"

# Multi-line parameters
test """
  func = (
    a,
    b,
    c
  ) -> a + b + c
  func(
    1,
    2,
    3
  )
""", 6

# Object literals with line breaks
test """
  obj =
    a: 1
    b: 2
    c: 3
  obj.a + obj.b + obj.c
""", 6

# Array literals with line breaks
test """
  arr = [
    1
    2
    3
  ]
  arr.length
""", 3

# Implicit objects
test """
  func = (obj) -> obj.x + obj.y
  func
    x: 10
    y: 20
""", 30

# YAML-style objects
test """
  obj =
    x: 10
    y:
      z: 20
  obj.y.z
""", 20

# Postfix conditionals with line breaks
test """
  x = 10
  x = 20 if x <
    15
  x
""", 20

# Comprehensions with line breaks
test """
  result = for i in [
    1
    2
    3
  ]
    i * 2
  result.join ','
""", "2,4,6"

# Switch with indentation
test """
  x = 2
  result = switch x
    when 1
      'one'
    when 2
      'two'
    else
      'other'
  result
""", "two"

# Function body indentation
test """
  func = ->
    x = 5
    y = 10
    x + y
  func()
""", 15

# Nested indentation
test """
  outer = ->
    inner = ->
      deepest = ->
        42
      deepest()
    inner()
  outer()
""", 42

# Comments with line continuations
test """
  1 + # comment
  2 + # another
  3
""", 6

# Parentheses for grouping
test """
  (
    1 + 2
  ) * 3
""", 9

# Complex expression indentation
test """
  result =
    if true
      if true
        'nested'
      else
        'not'
    else
      'outer'
  result
""", "nested"

# Implicit return with indentation
test """
  func = ->
    if true
      x = 5
      y = 10
      x + y
  func()
""", 15

# Object method chaining pattern
test """
  calculator =
    value: 0
    add: (n) ->
      @value += n
      @
    multiply: (n) ->
      @value *= n
      @
    get: -> @value
  calculator
    .add(5)
    .multiply(2)
    .get()
""", 10

# Array of objects formatting
test """
  data = [
    {x: 1, y: 2}
    {x: 3, y: 4}
    {x: 5, y: 6}
  ]
  data[1].x
""", 3

# Semicolon usage
test "a = 1; b = 2; a + b", 3
test """
  x = 5; y = 10
  x + y
""", 15

# Empty statements
test ";", undefined
test ";;;", undefined

# Compilation output tests
code "1 + \\\n2", "1 + 2;"
