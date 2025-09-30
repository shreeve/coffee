# Own Properties and Prototype Chain
# ===========================
# Tests for own property iteration and prototype chain handling

# for-own loops
test """
  parent = {inherited: 'parent'}
  child = Object.create(parent)
  child.a = 1
  child.b = 2
  result = []
  for own key of child
    result.push key
  result.sort().join ','
""", "a,b"

test """
  parent = {inherited: 10}
  child = Object.create(parent)
  child.own1 = 1
  child.own2 = 2
  sum = 0
  for own key, value of child
    sum += value
  sum
""", 3

# Regular for-of includes inherited
test """
  parent = {inherited: 'parent'}
  child = Object.create(parent)
  child.own = 'child'
  result = []
  for key of child
    result.push key
  result.sort().join ','
""", "inherited,own"

# hasOwnProperty checks
test """
  obj = {a: 1}
  obj.hasOwnProperty 'a'
""", true

test """
  obj = {a: 1}
  obj.hasOwnProperty 'toString'
""", false

# Object.prototype properties
test "'toString' of {}", true
test "'hasOwnProperty' of {}", true
test "{}.hasOwnProperty 'hasOwnProperty'", false

# Prototype property access
test "Array::slice is Array.prototype.slice", true
test "String::split is String.prototype.split", true
test "Object::toString is Object.prototype.toString", true

# Adding to prototypes
test """
  String::double = -> @ + @
  'test'.double()
""", "testtest"

# Constructor property
test "{}.constructor is Object", true
test "[].constructor is Array", true
test "''.constructor is String", true

# Object.keys only returns own properties
test """
  parent = {inherited: 1}
  child = Object.create(parent)
  child.a = 2
  child.b = 3
  Object.keys(child).sort().join ','
""", "a,b"

# 'of' operator checks prototype chain (use 'of' not 'in' for objects)
test "'toString' of {}", true
test "'length' of []", true
# test "'charAt' of ''", true  # Runtime error: can't use 'in' on string primitive

# Object.create with null prototype
test """
  obj = Object.create(null)
  obj.x = 5
  obj.x
""", 5

test """
  obj = Object.create(null)
  'toString' of obj
""", false

# getOwnPropertyNames
test """
  obj = {a: 1, b: 2}
  Object.getOwnPropertyNames(obj).sort().join ','
""", "a,b"

# Prototype chain walking
test """
  grandparent = {a: 1}
  parent = Object.create(grandparent)
  parent.b = 2
  child = Object.create(parent)
  child.c = 3
  child.a + child.b + child.c
""", 6

# Setting prototype
test """
  obj = {x: 1}
  proto = {y: 2}
  Object.setPrototypeOf(obj, proto)
  obj.x + obj.y
""", 3

# Own property descriptors
test """
  obj = {}
  Object.defineProperty obj, 'prop',
    value: 42
    enumerable: true
  obj.prop
""", 42

# Non-enumerable properties
test """
  obj = {}
  Object.defineProperty obj, 'hidden', {value: 'secret', enumerable: false}
  'hidden' of obj
""", true

# Checking if property is own
test """
  parent = {inherited: 1}
  child = Object.create(parent)
  child.own = 2
  child.hasOwnProperty('own') and not child.hasOwnProperty('inherited')
""", true

# for-own with arrays
test """
  arr = [1, 2, 3]
  arr.custom = 'prop'
  result = []
  for own key of arr
    result.push key if isNaN(parseInt(key))
  result.join ','
""", "custom"

# Object.assign only copies own properties
test """
  source = Object.create({inherited: 1})
  source.own = 2
  target = {}
  Object.assign(target, source)
  target.own
""", 2

test """
  source = Object.create({inherited: 1})
  source.own = 2
  target = {}
  Object.assign(target, source)
  target.inherited
""", undefined

# Compilation output tests
fail "for own k of obj", "unexpected end of input"
code "k for own k of obj", "var k,\n  hasProp = {}.hasOwnProperty;\n\nfor (k in obj) {\n  if (!hasProp.call(obj, k)) continue;\n  k;\n}"
