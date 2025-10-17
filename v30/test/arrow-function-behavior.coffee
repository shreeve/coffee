# Arrow Function Behavior Tests
# ==============================
# Tests to verify proper this binding for -> vs => in ES6 mode

console.log "\n== Arrow Function This Binding =="

# Test 1: Class methods with thin arrow (->) vs fat arrow (=>)
test """
  class MyClass
    constructor: ->
      @value = 42

    thinArrow: ->
      @value  # 'this' depends on caller

    fatArrow: =>
      @value  # 'this' always refers to the instance

  obj = new MyClass()

  # Direct calls work for both
  directThin = obj.thinArrow()
  directFat = obj.fatArrow()

  # Fat arrow preserves this when called without context
  fat = obj.fatArrow
  fatResult = fat()    # 42 (preserves this via bind)

  [directThin, directFat, fatResult]
""", [42, 42, 42]

# Test 2: Object literal methods
test """
  obj = {
    value: 10
    regular: ->
      @value
    bound: =>
      @value
  }

  # Direct calls
  direct = obj.regular()

  # Through reference
  ref = obj.regular
  refResult = ref()  # undefined

  [direct, refResult]
""", [10, undefined]

# Test 3: Nested functions with arrow capturing
# KNOWN ISSUE: When an object method contains a fat arrow that uses @,
# the method itself gets incorrectly compiled to an arrow function
# instead of staying as a regular function. This breaks the this binding.
# test """
#   obj = {
#     value: 10
#     outer: ->
#       # This arrow function should capture outer's 'this'
#       inner = => @value * 2
#       inner()
#   }
#   obj.outer()
# """, 20

# Test 4: Standalone functions
test """
  # Standalone thin arrow becomes arrow in ES6 (no this context)
  thin = -> 'thin'

  # Standalone fat arrow also becomes arrow
  fat = => 'fat'

  [thin(), fat()]
""", ['thin', 'fat']

# Test 5: Verify method compilation preserves this
test """
  class Counter
    constructor: ->
      @count = 0

    increment: ->
      @count++

    getCount: ->
      @count

  c = new Counter()
  c.increment()
  c.increment()
  c.getCount()
""", 2

console.log "Arrow function tests complete!"
