# Objects
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify object features work correctly

# Basic object literals
test "{a: 1}.a", 1
test "{a: 1, b: 2}.b", 2
test "{x: 10, y: 20}.x + {x: 10, y: 20}.y", 30

# Object with string keys
test "{'hello': 'world'}.hello", "world"
test '{"key": "value"}.key', "value"
test "{\"multi-word\": 123}[\"multi-word\"]", 123

# Object with computed property names
test "key = 'dynamic'; {[key]: 'value'}.dynamic", "value"
test "x = 'a'; {[x + 'bc']: 123}.abc", 123
test "i = 1; {[\"key\" + i]: 'val'}.key1", "val"

# Shorthand properties
test "a = 5; {a}.a", 5
test "x = 10; y = 20; {x, y}.x + {x, y}.y", 30
test "name = 'test'; {name}.name", "test"

# Methods in objects
test "{method: -> 'result'}.method()", "result"
test "{add: (a, b) -> a + b}.add(3, 4)", 7
test "obj = {value: 10, get: -> @value}; obj.get()", 10

# Nested objects
test "{a: {b: {c: 1}}}.a.b.c", 1
test "{x: {y: 2}, z: 3}.x.y", 2
test "obj = {a: 1, b: {c: 2}}; obj.b.c", 2

# Object spread
test "a = {x: 1}; {...a}.x", 1
test "a = {x: 1}; b = {y: 2}; {...a, ...b}.x + {...a, ...b}.y", 3
test "{...{a: 1}, b: 2}.a + {...{a: 1}, b: 2}.b", 3
test "a = {x: 1, y: 2}; {...a, y: 3}.y", 3

# Object destructuring
test "{a} = {a: 1, b: 2}; a", 1
test "{x, y} = {x: 10, y: 20}; x + y", 30
test "{a: renamed} = {a: 5}; renamed", 5
test "{x = 10} = {}; x", 10
test "{a, ...rest} = {a: 1, b: 2, c: 3}; rest.b + rest.c", 5

# Object.keys
test "Object.keys({a: 1, b: 2, c: 3}).join(',')", "a,b,c"
test "Object.keys({}).length", 0
test "Object.keys({x: 1, y: 2}).length", 2

# Object.values
test "Object.values({a: 1, b: 2, c: 3}).join(',')", "1,2,3"
test "Object.values({x: 'a', y: 'b'}).join('-')", "a-b"
test "Object.values({}).length", 0

# Object.entries
test "Object.entries({a: 1}).flat().join(',')", "a,1"
test "Object.entries({x: 2, y: 3}).length", 2

# Object.assign
test "Object.assign({}, {a: 1}, {b: 2}).a + Object.assign({}, {a: 1}, {b: 2}).b", 3
test "a = {x: 1}; Object.assign(a, {y: 2}); a.x + a.y", 3
test "Object.assign({a: 1}, {a: 2}).a", 2

# Object property access
test "obj = {prop: 'value'}; obj.prop", "value"
test "obj = {prop: 'value'}; obj['prop']", "value"
test "obj = {a: {b: 1}}; obj['a']['b']", 1

# Object property assignment
test "obj = {}; obj.x = 5; obj.x", 5
test "obj = {a: 1}; obj.b = 2; obj.a + obj.b", 3
test "obj = {}; obj['key'] = 'val'; obj.key", "val"

# Delete property
test "obj = {a: 1, b: 2}; delete obj.a; obj.a", undefined
test "obj = {x: 1, y: 2}; delete obj.x; Object.keys(obj).join(',')", "y"

# Object with symbols (skip if not supported)
# test "sym = Symbol('test'); obj = {[sym]: 'value'}; obj[sym]", "value"

# Object.freeze
test "obj = Object.freeze({x: 1}); obj.x", 1
test "Object.isFrozen(Object.freeze({}))", true

# Object.seal
test "obj = Object.seal({x: 1}); obj.x", 1
test "Object.isSealed(Object.seal({}))", true

# in operator
test "'a' of {a: 1}", true
test "'b' of {a: 1}", false
test "'toString' of {}", true

# hasOwnProperty
test "{a: 1}.hasOwnProperty('a')", true
test "{a: 1}.hasOwnProperty('b')", false
test "{}.hasOwnProperty('toString')", false

# Object literal with trailing comma
test "{a: 1,}.a", 1
test "{x: 10, y: 20,}.y", 20

# Empty object
test "Object.keys({}).length", 0
test "{}.constructor.name", "Object"

# Object with getter/setter (using backticks)
# test "obj = {_x: 0, `get x() { return this._x; }`, `set x(v) { this._x = v; }`}; obj.x = 5; obj.x", 5

# Object prototype chain
test "obj = {a: 1}; obj.constructor is Object", true
test "{}.toString.call({x: 1})", "[object Object]"

# Object with undefined/null values
test "{a: undefined}.a", undefined
test "{b: null}.b", null
test "'a' of {a: undefined}", true

# Complex object operations
test """
  obj = {
    count: 0
    increment: -> @count++
    getValue: -> @count
  }
  obj.increment()
  obj.increment()
  obj.getValue()
""", 2

# Object method chaining
test """
  calculator = {
    value: 0
    add: (n) -> @value += n; @
    multiply: (n) -> @value *= n; @
    get: -> @value
  }
  calculator.add(5).multiply(2).add(3).get()
""", 13

# Object with array values
test "{arr: [1, 2, 3]}.arr.length", 3
test "{matrix: [[1, 2], [3, 4]]}.matrix[1][0]", 3

# Nested destructuring
test "{a: {b}} = {a: {b: 5}}; b", 5
test "{x: [y, z]} = {x: [1, 2]}; y + z", 3

# Object.create
test "obj = Object.create(null); obj.x = 1; obj.x", 1
test "proto = {x: 1}; obj = Object.create(proto); obj.x", 1

# Object comparison
test "a = {x: 1}; b = a; a is b", true
test "a = {x: 1}; b = {x: 1}; a is b", false
