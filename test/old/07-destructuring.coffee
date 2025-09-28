# Destructuring
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify destructuring assignment works correctly

# Array destructuring basics
test "[a, b] = [1, 2]; a", 1
test "[a, b] = [1, 2]; b", 2
test "[x, y, z] = [10, 20, 30]; x + y + z", 60
test "[first, second] = ['hello', 'world']; first", "hello"

# Array destructuring with more values
test "[a, b] = [1, 2, 3, 4]; a + b", 3
test "[a, b, c] = [1, 2]; c", undefined

# Array destructuring with rest
test "[head, ...tail] = [1, 2, 3, 4]; head", 1
test "[head, ...tail] = [1, 2, 3, 4]; tail.join(',')", "2,3,4"
test "[first, ...rest] = [1]; rest.length", 0
test "[a, b, ...rest] = [1, 2, 3, 4, 5]; rest.join(',')", "3,4,5"

# Skipping elements in array destructuring
test "[a, , c] = [1, 2, 3]; a + c", 4
test "[, , third] = [1, 2, 3]; third", 3
test "[first, , , fourth] = [1, 2, 3, 4]; first + fourth", 5

# Nested array destructuring
test "[[a, b], c] = [[1, 2], 3]; a + b + c", 6
test "[a, [b, c]] = [1, [2, 3]]; a + b + c", 6
test "[[x]] = [[5]]; x", 5

# Object destructuring basics
test "{a} = {a: 1, b: 2}; a", 1
test "{x, y} = {x: 10, y: 20}; x + y", 30
test "{name} = {name: 'Alice', age: 30}; name", "Alice"

# Object destructuring with renaming
test "{a: renamed} = {a: 5}; renamed", 5
test "{x: newX, y: newY} = {x: 1, y: 2}; newX + newY", 3
test "{prop: value} = {prop: 'test'}; value", "test"

# Object destructuring with defaults
test "{x = 10} = {}; x", 10
test "{x = 10} = {x: 5}; x", 5
test "{a = 1, b = 2} = {a: 5}; a + b", 7
test "{name = 'Anonymous'} = {}; name", "Anonymous"

# Object destructuring with rest
test "{a, ...rest} = {a: 1, b: 2, c: 3}; a", 1
test "{a, ...rest} = {a: 1, b: 2, c: 3}; rest.b", 2
test "{a, ...rest} = {a: 1, b: 2, c: 3}; rest.c", 3
test "{x, ...others} = {x: 1, y: 2, z: 3}; Object.keys(others).length", 2

# Nested object destructuring
test "{a: {b}} = {a: {b: 5}}; b", 5
test "{x: {y: {z}}} = {x: {y: {z: 10}}}; z", 10
test "{outer: {inner}} = {outer: {inner: 'nested'}}; inner", "nested"

# Mixed destructuring
test "{x: [a, b]} = {x: [1, 2]}; a + b", 3
test "[{a}, {b}] = [{a: 1}, {b: 2}]; a + b", 3
test "{arr: [first]} = {arr: [10, 20]}; first", 10

# Destructuring in function parameters
test "f = ({x, y}) -> x + y; f({x: 3, y: 4})", 7
test "f = ([a, b]) -> a * b; f([5, 6])", 30
test "f = ({name = 'Unknown'}) -> name; f({})", "Unknown"
test "f = ([first, ...rest]) -> rest.length; f([1, 2, 3, 4])", 3

# Destructuring with computed property names
test "key = 'prop'; {[key]: value} = {prop: 42}; value", 42
test "i = 1; {['key' + i]: val} = {key1: 'test'}; val", "test"

# Destructuring assignment as expression
test "a = b = 0; [{a, b} = {a: 1, b: 2}][0].a", 1
test "x = ({y} = {y: 5}); x.y", 5

# Destructuring with existing variables
test "a = 0; ({a} = {a: 10}); a", 10
test "x = 0; [x] = [5]; x", 5

# Destructuring from function returns
test "f = -> [1, 2, 3]; [a, b] = f(); a + b", 3
test "f = -> {x: 10, y: 20}; {x, y} = f(); x + y", 30

# Destructuring in loops
test "result = []; result.push(a + b) for [a, b] in [[1, 2], [3, 4]]; result.join(',')", "3,7"
test "result = []; result.push(x) for {x} in [{x: 1}, {x: 2}]; result.join(',')", "1,2"

# Default values with destructuring
test "[a = 5, b = 10] = [1]; a + b", 11
test "{x = 5, y = 10} = {x: 2}; x + y", 12

# Complex nested destructuring
test """
  data = {
    user: {
      name: 'Alice'
      scores: [90, 85, 92]
    }
  }
  {user: {name, scores: [first]}} = data
  name + ':' + first
""", "Alice:90"

# Swapping variables
test "a = 1; b = 2; [a, b] = [b, a]; a", 2
test "x = 'first'; y = 'second'; [x, y] = [y, x]; x", "second"

# Destructuring with null/undefined
test "[a] = [null]; a", null
test "{x} = {x: undefined}; x", undefined
test "[a = 'default'] = [undefined]; a", "default"

# String destructuring (array-like)
test "[a, b, c] = 'abc'; a", "a"
test "[first, ...rest] = 'hello'; first", "h"
test "[a, b, c] = 'ab'; c", undefined

# Destructuring with spread in objects
test "{...copy} = {a: 1, b: 2}; copy.a + copy.b", 3
test "original = {x: 1}; {...clone} = original; clone.x", 1

# Multiple destructuring in one statement
test "[a, b] = [1, 2]; [c, d] = [3, 4]; a + b + c + d", 10

# Destructuring with this
test """
  obj = {
    values: [10, 20]
    extract: -> [@first, @second] = @values; @
  }
  obj.extract()
  obj.first + obj.second
""", 30
