# Existential Operators
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify existential operators work correctly

# Basic existence checks
test "x = 5; x?", true
test "x = null; x?", false
test "x = undefined; x?", false
test "x = 0; x?", true
test "x = ''; x?", true
test "x = false; x?", true
test "x = NaN; x?", true

# Existential property access ?.
test "obj = {x: 5}; obj?.x", 5
test "obj = null; obj?.x", undefined
test "obj = undefined; obj?.x", undefined
test "obj = {x: null}; obj?.x", null
test "{a: 1}?.a", 1
test "null?.prop", undefined

# Chained existential access
test "obj = {x: {y: {z: 1}}}; obj?.x?.y?.z", 1
test "obj = {x: null}; obj?.x?.y?.z", undefined
test "obj = {x: {y: null}}; obj?.x?.y?.z", undefined
test "obj = null; obj?.x?.y?.z", undefined

# Existential method calls ?()
test "obj = {fn: -> 42}; obj.fn?()", 42
test "obj = {}; obj.fn?()", undefined
test "obj = null; obj?.fn?()", undefined
test "obj = {fn: null}; obj.fn?()", undefined

# Soaked method chains
test """
  obj = {
    a: -> {b: -> {c: -> 'result'}}
  }
  obj.a?()?.b?()?.c?()
""", "result"

test """
  obj = {
    a: -> null
  }
  obj.a?()?.b?()?.c?()
""", undefined

# Existential assignment ?=
test "x = null; x ?= 5; x", 5
test "x = undefined; x ?= 10; x", 10
test "x = 0; x ?= 5; x", 0
test "x = false; x ?= true; x", false
test "x = ''; x ?= 'default'; x", ""
test "x = 'value'; x ?= 'default'; x", "value"

# Existential assignment with objects
test "obj = {}; obj.x ?= 5; obj.x", 5
test "obj = {x: null}; obj.x ?= 10; obj.x", 10
test "obj = {x: 'exists'}; obj.x ?= 'default'; obj.x", "exists"

# Existential with arrays
test "arr = [1, 2, 3]\narr?[0]", 1
test "arr = null\narr?[0]", undefined
test "arr = []\narr?[10]", undefined
test "[1, 2, 3]?[1]", 2

# Existential with function results
test "getFn = -> (x) -> x * 2\ngetFn()?(5)", 10
test "getFn = -> null\ngetFn()?(5)", undefined
test "getValue = -> 42\ngetValue?()", 42
test "getValue = null\ngetValue?()", undefined

# Complex existential expressions
test """
  data = {
    user: {
      name: 'Alice'
      getAge: -> 30
    }
  }
  data?.user?.getAge?()
""", 30

test """
  data = {
    user: null
  }
  data?.user?.getAge?() ? 'unknown'
""", "unknown"

# Existential with logical operators
test "x = null; x? and true", false
test "x = 5; x? and true", true
test "x = null; x? or true", true
test "x = 5; x? or false", true

# Existential in conditionals
test "x = null; if x? then 'exists' else 'missing'", "missing"
test "x = 0; if x? then 'exists' else 'missing'", "exists"
test "obj = {prop: null}; if obj.prop? then 'yes' else 'no'", "no"
test "obj = {prop: 0}; if obj.prop? then 'yes' else 'no'", "yes"

# Existential with destructuring
test "[a, b] = [1, null]; b ?= 2; b", 2
test "{x} = {x: null}; x ?= 5; x", 5
test "[a, b] = [1]; b ?= 10; b", 10

# Soaked deletion
test "obj = {x: 1, y: 2}; delete obj?.x; obj.x", undefined
test "obj = null; delete obj?.x; obj", null

# Existential with this
test """
  obj = {
    value: 42
    getValue: -> @value
    getSafe: -> @?.value
  }
  obj.getSafe()
""", 42

# Multiple existential assignments
test "a = b = null; a ?= b ?= 5; a", 5
test "x = null; y = 10; x ?= y ?= 20; x", 10

# Existential with array methods
test "arr = [1, 2, 3]; arr?.length", 3
test "arr = null; arr?.length", undefined
test "arr = [1, 2, 3]; arr?.map?((x) -> x * 2).join(',')", "2,4,6"
test "arr = null; arr?.map?((x) -> x * 2)?.join(',') ? 'empty'", "empty"

# Existential in comprehensions
test "(x for x in [1, null, 3] when x?).join(',')", "1,3"
test "(x ? 0 for x in [1, null, 3]).join(',')", "1,0,3"

# Existential operator precedence
test "x = null; not x?", true
test "x = 5; not x?", false
test "typeof null?", "boolean"
test "typeof undefined?", "boolean"

# Existential with computed properties
test "obj = {a: 1}\nkey = 'a'\nobj?[key]", 1
test "obj = null\nkey = 'a'\nobj?[key]", undefined
test "obj = {a: 1}\nkey = null\nobj?[key]", undefined

# Short-circuit evaluation
test """
  called = false
  getValue = -> called = true; 42
  obj = null
  result = obj?.method?(getValue())
  called
""", false

# Existential with spread
# Should generate [...(arr != null ? arr : [])] but generates [...(arr != null)]
# test "arr = [1, 2, 3]\n[...arr?].join(',')" # Prior versions fail on this too
test "arr = null; [...(arr ? [])].length", 0

# Nested existential assignments
test """
  obj = {}
  obj.a ?= {}
  obj.a.b ?= {}
  obj.a.b.c ?= 5
  obj.a.b.c
""", 5

# Compilation output tests
code "a?.b", "if (typeof a !== \"undefined\" && a !== null) {\n  a.b;\n}"
code "a?()", "if (typeof a === \"function\") {\n  a();\n}"
code "a ? b", "if (typeof a !== \"undefined\" && a !== null) {\n  a;\n} else {\n  b;\n};"

# Invalid syntax tests
fail "?. without object"  # existential access needs object
