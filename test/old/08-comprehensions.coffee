# Comprehensions and Loops
# ===========================
# Extracted from CoffeeScript 2.7 test suite
# Tests that verify comprehensions and loop expressions work correctly

# Basic array comprehensions
test "(x for x in [1, 2, 3]).join(',')", "1,2,3"
test "(x * 2 for x in [1, 2, 3]).join(',')", "2,4,6"
test "(x + 1 for x in [0, 1, 2]).join(',')", "1,2,3"

# Comprehensions with filters (when)
test "(x for x in [1, 2, 3, 4, 5] when x > 2).join(',')", "3,4,5"
test "(x for x in [1, 2, 3, 4, 5] when x % 2 is 0).join(',')", "2,4"
test "(x * 2 for x in [1, 2, 3, 4] when x > 2).join(',')", "6,8"

# Range comprehensions
test "(i for i in [0..4]).join(',')", "0,1,2,3,4"
test "(i for i in [5...8]).join(',')", "5,6,7"
test "(i * 2 for i in [1..3]).join(',')", "2,4,6"
test "(i for i in [10..10]).join(',')", "10"
test "(i for i in [10...10]).length", 0

# Comprehensions with index
test "(i for x, i in ['a', 'b', 'c']).join(',')", "0,1,2"
test "(\"#{i}:#{v}\" for v, i in ['a', 'b', 'c']).join(',')", "0:a,1:b,2:c"
test "(i + v for v, i in [10, 20, 30]).join(',')", "10,21,32"

# Object comprehensions (for-of)
test "obj = {a: 1, b: 2, c: 3}; (k for k of obj).sort().join(',')", "a,b,c"
test "obj = {a: 1, b: 2}; (v for k, v of obj).sort().join(',')", "1,2"
test "obj = {x: 10, y: 20}; (k + ':' + v for k, v of obj).sort().join(',')", "x:10,y:20"

# Object comprehensions with when
test "obj = {a: 1, b: 2, c: 3}; (v for k, v of obj when v > 1).sort().join(',')", "2,3"
test "obj = {x: 5, y: 10, z: 15}; (k for k, v of obj when v >= 10).sort().join(',')", "y,z"

# Nested comprehensions
test "(x + y for x in [1, 2] for y in [10, 20]).join(',')", "11,21,12,22"
test "(x * y for x in [1, 2, 3] for y in [1, 2]).join(',')", "1,2,2,4,3,6"
test "(\"#{i},#{j}\" for i in [0..1] for j in [0..1]).join(' ')", "0,0 0,1 1,0 1,1"

# Comprehensions with by (step)
test "(i for i in [0..10] by 2).join(',')", "0,2,4,6,8,10"
test "(i for i in [1..10] by 3).join(',')", "1,4,7,10"
test "(i for i in [10..0] by -2).join(',')", "10,8,6,4,2,0"

# Comprehensions returning objects
test "({x: i} for i in [1, 2, 3]).map((o) -> o.x).join(',')", "1,2,3"
test "({index: i, value: v} for v, i in ['a', 'b'])[0].index", 0

# Comprehensions with destructuring
test "([x, y] for [x, y] in [[1, 2], [3, 4]]).map((p) -> p.join(':')).join(',')", "1:2,3:4"
test "({a} for {a} in [{a: 1}, {a: 2}]).map((o) -> o.a).join(',')", "1,2"

# List comprehension assignments
test "doubled = (x * 2 for x in [1, 2, 3]); doubled.join(',')", "2,4,6"
test "evens = (x for x in [1..10] when x % 2 is 0); evens.length", 5

# Comprehension with continue/break pattern
test """
  result = []
  for i in [1..5]
    continue if i is 3
    result.push(i)
  result.join(',')
""", "1,2,4,5"

# Comprehension expressions in conditionals
test "if (x for x in [1, 2, 3]).length > 2 then 'yes' else 'no'", "yes"
test "if (x for x in [] when x > 0).length then 'yes' else 'no'", "no"

# String comprehensions (treating string as array)
test "(c.toUpperCase() for c in 'hello').join('')", "HELLO"
test "(c for c in 'test' when c isnt 'e').join('')", "tst"

# Own property iteration
test """
  obj = {a: 1}
  Object.prototype.inherited = 99
  result = (k for own k of obj)
  delete Object.prototype.inherited
  result.join(',')
""", "a"

# Comprehensions with function calls
test "((x) -> x * 2)(i) for i in [1, 2, 3]).join(',')", "2,4,6"
test "(parseInt(s) for s in ['1', '2', '3']).join(',')", "1,2,3"

# Comprehensions in function arguments
test "Math.max(...(x for x in [1, 5, 3, 2]))", 5
test "[].concat(...([i, i] for i in [1, 2])).join(',')", "1,1,2,2"

# Do notation with comprehensions
test "(do (x) -> x * 2 for x in [1, 2, 3]).join(',')", "2,4,6"

# Postfix comprehensions
test "result = []; result.push(x * 2) for x in [1, 2, 3]; result.join(',')", "2,4,6"
test "sum = 0; sum += x for x in [1, 2, 3, 4]; sum", 10

# While/until as expressions
test """
  i = 0
  result = while i < 3
    i++
  result
""", undefined  # while doesn't return array by default

# Loop expressions
test """
  i = 0
  result = loop
    break i if i >= 3
    i++
  result
""", 3

# Comprehension with guard and index
test "(\"#{i}:#{v}\" for v, i in [10, 20, 30] when i > 0).join(',')", "1:20,2:30"

# Multiple filters
test "(x for x in [1..10] when x > 3 when x < 8).join(',')", "4,5,6,7"

# Comprehension returning booleans
test "(x > 2 for x in [1, 2, 3, 4]).filter((b) -> b).length", 2

# Array slicing in comprehensions
test "(arr[0] for arr in [[1, 2], [3, 4], [5, 6]]).join(',')", "1,3,5"
test "(arr[1..] for arr in [[1, 2, 3], [4, 5, 6]])[0].join(',')", "2,3"
