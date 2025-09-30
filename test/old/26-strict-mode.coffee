# Strict Mode
# ===========================
# Tests for strict mode behavior and restrictions

# Basic strict mode
test "'use strict'; true", true
test '"use strict"; 5 + 3', 8

# Strict mode in functions
test """
  func = ->
    'use strict'
    42
  func()
""", 42

# Octal literals (should work in non-strict CoffeeScript)
test "0o777", 511
test "0o10", 8
test "0b1010", 10
test "0xFF", 255

# Reserved words as properties (allowed)
test "obj = {class: 'test'}; obj.class", "test"
test "obj = {function: 'func'}; obj.function", "func"
test "obj = {extends: 'ext'}; obj.extends", "ext"

# Arguments and eval as variable names are restricted in CoffeeScript
fail "arguments = 10; arguments", "'arguments' can't be assigned"
fail "eval = 5; eval", "'eval' can't be assigned"

# This binding in strict mode
test """
  'use strict'
  func = -> typeof @
  func()
""", "undefined"

# Delete operator
test "obj = {x: 1}; delete obj.x; obj.x", undefined
test "arr = [1, 2, 3]; delete arr[1]; arr[1]", undefined

# With statement (not supported in CoffeeScript anyway)
# test "with (Math) { PI }", "not supported"

# Duplicate parameters (CoffeeScript handles this)
# test "(a, a) -> a", "should handle duplicates"

# Function declarations in blocks
test """
  if true
    func = -> 'inside'
  else
    func = -> 'outside'
  func()
""", "inside"

# Octal escape sequences in strings
test '"\\0"', "\0"  # Null character is allowed
test '"\\x41"', "A"  # Hex escapes
test '"\\u0041"', "A"  # Unicode escapes

# Global object access
test "typeof global", "object"
test "typeof window", "undefined"  # In Node context

# Strict equality - CoffeeScript uses 'is' not '==='
# === is not valid syntax in CoffeeScript
fail "5 === 5", "unexpected ="
fail "5 === '5'", "unexpected ="
fail "null === undefined", "unexpected ="
fail "NaN === NaN", "unexpected ="

# Arguments object in arrow functions
test """
  regular = ->
    Array.from(arguments).length
  regular(1, 2, 3)
""", 3

# Eval scope (indirect eval is global)
fail "(0, eval)('1 + 1')", "unexpected ,"
test "e = eval; e('2 + 2')", 4

# Property descriptors
test """
  obj = {}
  Object.defineProperty obj, 'x',
    value: 42
    writable: false
  obj.x
""", 42

# Object.freeze and seal
test "obj = Object.freeze({x: 1}); obj.x", 1
test "Object.isFrozen(Object.freeze({}))", true
test "Object.isSealed(Object.seal({}))", true

# Getter/setter syntax (if supported)
# test "obj = {get x() { return 42; }}; obj.x", 42

# Strict mode class requirements
test """
  class StrictClass
    constructor: ->
      @value = 10
  (new StrictClass).value
""", 10

# No implicit globals
test """
  func = ->
    localVar = 10
    localVar
  func()
""", 10

# Eval creating variables - both CS28 and CS29 create variables in current scope
test """
  eval('var evalVar = 5')
  typeof evalVar
""", "number"  # eval creates variable in current scope (not strict mode isolated)

# Function name property
test "(func = ->) and func.name", "func"
test "(-> ).name", ""

# Read-only properties
test "obj = {}; obj.x = 5; obj.x", 5
test "'test'.length", 4  # String length is read-only
test "[1, 2, 3].length", 3

# Non-extensible objects
test """
  obj = {x: 1}
  Object.preventExtensions(obj)
  obj.y = 2
  obj.y
""", undefined

# Strict mode directive position
test """
  # Comment before directive
  'use strict'
  5
""", 5

# Compilation output tests
code '"use strict"', '"use strict";'
